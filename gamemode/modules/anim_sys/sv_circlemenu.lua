AddCSLuaFile()
local meta = FindMetaTable("Player")
local ragdollTimerPrefix = "dbt/ragdoll/monitor/"
local ragdollOwnerKey = "owner"
local ragdollStateKey = "_dbtRagdollState"

local woundsModuleAvailable = true

hook.Add("GetFallDamage", "RealisticDamage", function(ply, speed)
	if ply.dbtPhysgunFallImmunity and ply.dbtPhysgunFallImmunity > CurTime() then
		return 0
	end

	return (speed / 8)
end)

local woundPositionFallback = dbt.woundsposition.chest or "chest"
local woundTypes = dbt.woundstypes or {}

local fallRagdollSpeedThreshold = 750 -- units/sec; tweak to taste
local fallRagdollDamageScale = 0.1   -- scale for converting impact speed into HP damage
local fallRagdollSafeSpeed = 300
local fallImpactCooldown = 0.1
local fallAirRagdollSpeed = 450

local function getMonitorId(ply)
	return ragdollTimerPrefix .. (ply:SteamID64() or ply:UserID())
end

local function getPlayerHull(ply)
	local mins, maxs = ply:GetHull()
	if not mins or not maxs or mins == maxs then
		mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 72)
	end
	return mins, maxs
end

local candidateOffsets = {}
do
	-- precompute radial search offsets so we can quickly scan for open space
	table.insert(candidateOffsets, Vector(0, 0, 0))
	local radii = {32, 64, 96, 128}
	for _, radius in ipairs(radii) do
		for angle = 0, 315, 45 do
			local rad = math.rad(angle)
			table.insert(candidateOffsets, Vector(math.cos(rad) * radius, math.sin(rad) * radius, 0))
		end
	end
end

function findSafeRecoveryPosition(ply, desiredPos)
	if not desiredPos then return nil end

	local mins, maxs = getPlayerHull(ply)
	local traceConfig = {
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID,
		filter = ply,
	}

	local function isClear(pos)
		traceConfig.start = pos
		traceConfig.endpos = pos
		local hullTrace = util.TraceHull(traceConfig)
		return not hullTrace.StartSolid and not hullTrace.Hit
	end

	local function snapToGround(pos)
		local downTrace = util.TraceLine({
			start = pos + Vector(0, 0, 64),
			endpos = pos - Vector(0, 0, 256),
			mask = MASK_PLAYERSOLID,
			filter = ply,
		})
		if downTrace.Hit then
			return downTrace.HitPos + downTrace.HitNormal * 2
		end
		return pos
	end

	local base = snapToGround(desiredPos)
	if isClear(base) then
		return base
	end

	for _, offset in ipairs(candidateOffsets) do
		local candidate = snapToGround(base + offset)
		if isClear(candidate) then
			return candidate
		end
	end

	return base
end

local function capturePlayerState(ply)
	local state = {
		health = ply:Health(),
		armor = ply:Armor(),
		water = ply:GetNWInt("water"),
		hunger = ply:GetNWInt("hunger"),
		sleep = ply:GetNWInt("sleep"),
		stamina = ply:GetNWInt("Stamina"),
	}

	ply[ragdollStateKey] = state
	ply.data = state -- maintain compatibility with older code paths

	return state
end

local function applyStateToPlayer(ply, state)
	if not state then return end

	ply:SetNWInt("hunger", state.hunger or ply:GetNWInt("hunger"))
	ply:SetNWInt("water", state.water or ply:GetNWInt("water"))
	ply:SetNWInt("sleep", state.sleep or ply:GetNWInt("sleep"))
	ply:SetNWInt("Stamina", state.stamina or ply:GetNWInt("Stamina"))
	ply:SetArmor(math.max(0, state.armor or 0))

	local targetHealth = math.max(0, math.floor(state.health or ply:Health()))
	if targetHealth <= 0 then
		ply:SetHealth(1)
		ply:Kill()
	else
		ply:SetHealth(targetHealth)
	end
end

local function copyAppearanceToRagdoll(ply, ragdoll)
	if not IsValid(ply) or not IsValid(ragdoll) then return end

	local overrideMaterial = ply:GetMaterial()
	if overrideMaterial and overrideMaterial ~= "" then
		ragdoll:SetMaterial(overrideMaterial)
	end

	local materialSlots = ply:GetMaterials()
	local slotCount = materialSlots and #materialSlots or 0
	for slot = 0, slotCount - 1 do
		local subMat = ply:GetSubMaterial(slot)
		if subMat and subMat ~= "" then
			ragdoll:SetSubMaterial(slot, subMat)
		end
	end
end

local function clearRagdollState(ply)
	local monitorId = getMonitorId(ply)
	timer.Remove(monitorId)
	ply:SetNWBool("ragdolled", false)
	ply:SetNWEntity("ragdoll", nil)
	ply[ragdollStateKey] = nil
	ply.data = nil
end

local function removeRagdollEntity(ragdoll)
	if IsValid(ragdoll) then
		ragdoll:Remove()
	end
end

local forceKillFromRagdoll

local function finalizeRagdollSpawn(ply, ragdoll, state, context)
	ply:SetNWEntity("ragdoll", ragdoll)
	ply:SetNWBool("ragdolled", true)

	spectator.Spectate(ply, ragdoll, OBS_MODE_CHASE)

	local velocity = context and context.overrideVelocity or ply:GetVelocity()
	for id = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local physObj = ragdoll:GetPhysicsObjectNum(id)
		if physObj:IsValid() then
			local boneId = ragdoll:TranslatePhysBoneToBone(id)
			local _, boneAng = ply:GetBonePosition(boneId)
			if boneAng then
				physObj:SetAngles(boneAng)
			end
			physObj:AddVelocity(velocity)
		end
	end

	hook.Run("dbt/ragdoll/created", ply, ragdoll, state, context)

	local monitorId = getMonitorId(ply)
	timer.Create(monitorId, 0.1, 0, function()
		if not IsValid(ply) then
			timer.Remove(monitorId)
			removeRagdollEntity(ragdoll)
			return
		end

		if not IsValid(ragdoll) then
			timer.Remove(monitorId)
			forceKillFromRagdoll(ply)
			return
		end

		local activeState = ply[ragdollStateKey]
		if activeState and (activeState.health or 0) <= 0 then
			forceKillFromRagdoll(ply)
			return
		end

		if ply:GetObserverTarget() ~= ragdoll then
			spectator.Spectate(ply, ragdoll, OBS_MODE_CHASE)
		end
	end)

	ragdoll._dbtNextImpactDamage = 0
	ragdoll:AddCallback("PhysicsCollide", function(rag, data)

	end)
end

function startRagdoll(ply, context)
	if not IsValid(ply) or not ply:Alive() or ply.isSpectating then return false end
	if ply:InVehicle() then return false end
	if ply:GetNWBool("ragdolled", false) then return false end

	local existing = ply:GetNWEntity("ragdoll")
	if IsValid(existing) then return false end

	local ragdoll = ents.Create("prop_ragdoll")
	if not IsValid(ragdoll) then return false end
	ply:SelectWeapon("hands")
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetPos(context and context.positionOverride or ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetKeyValue("spawnflags", 4)
	ragdoll:Spawn()
	ragdoll:SetNWEntity(ragdollOwnerKey, ply)
	ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	copyAppearanceToRagdoll(ply, ragdoll)

	for i = 0, ply:GetNumBodyGroups() - 1 do
		ragdoll:SetBodygroup(i, ply:GetBodygroup(i))
	end

	local state = capturePlayerState(ply)

	if context and context.initialDamage and context.initialDamage > 0 then
		state.health = math.max(0, state.health - context.initialDamage)
		if state.health <= 0 then
			ply:SetHealth(1)
			removeRagdollEntity(ragdoll)
			clearRagdollState(ply)
			ply:Kill()
			return false
		else
			ply:SetHealth(math.max(1, math.floor(state.health)))
		end
	end

	finalizeRagdollSpawn(ply, ragdoll, state, context)

	return true, ragdoll, state
end

hook.Add( "PlayerLeaveVehicle", "findSafeRecoveryPosition", function( ply, veh )
		local safe = findSafeRecoveryPosition(ply, veh:GetPos())
		if safe then
			ply:SetPos(safe)
		end
end)

function restoreFromRagdoll(ply, opts)
	if dbt.hasWoundOnpos(ply, "Парализован", "Туловище") then return end
	local ragdoll = ply:GetNWEntity("ragdoll")
	local state = ply[ragdollStateKey]
	ply.AfterRagdoll = true
	spectator.UnSpectate(ply)

	if IsValid(ragdoll) then
		local safe = findSafeRecoveryPosition(ply, ragdoll:GetPos())
		if safe then
			ply:SetPos(safe)
		end
	end

	applyStateToPlayer(ply, state)
	clearRagdollState(ply)
	removeRagdollEntity(ragdoll)
	ply.NextAirRagdole = CurTime() + 0.2
	hook.Run("dbt/ragdoll/restored", ply, opts)
	netstream.Start(nil, "dbt/change/sq/anim", ply, "stand_up", true)
	ply:Freeze( true )

	timer.Simple(1.4, function()
		netstream.Start(nil, "dbt/change/sq/anim", ply, "idle_layer", true)
		ply.AfterRagdoll = false
		ply:Freeze( false )
	end)
end

forceKillFromRagdoll = function(ply)
	local ragdoll = ply:GetNWEntity("ragdoll")
	spectator.UnSpectate(ply)
	clearRagdollState(ply)

	if IsValid(ragdoll) then
		local safe = findSafeRecoveryPosition(ply, ragdoll:GetPos())
		if safe then
			ply:SetPos(safe)
		end
		ragdoll:Remove()
	end

	ply:Kill()
	hook.Run("dbt/ragdoll/killed", ply)
end

netstream.Hook("CharChangeModel", function(ply)
	local model = ply:GetModel() == "models/player/dewobedil/danganronpa/toko_fukawa/genocide_p.mdl" and "models/player/dewobedil/danganronpa/toko_fukawa/default_p.mdl" or "models/player/dewobedil/danganronpa/toko_fukawa/genocide_p.mdl"
	ply:SetModel(model)
end)

netstream.Hook("ChangeBodyGroup", function(ply, player, bgid, value)
	ply:SetBodygroup(bgid, value)
end)

netstream.Hook("RagdollPlayer", function(playergame)
	if IsValid(playergame) and playergame:Alive() and !playergame.isSpectating then
        startRagdoll(playergame)
    end
end)

local function shouldAirRagdoll(ply, velocity)
	ply.NextAirRagdole = ply.NextAirRagdole or 0
	if not IsValid(ply) or not ply:Alive() then return false end
	if ply.NextAirRagdole > CurTime() then return false end
	if ply:GetNWBool("ragdolled", false) then return false end
	if ply:InVehicle() then return false end
	if ply:IsOnGround() then return false end
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return false end
	if velocity.z >= -fallAirRagdollSpeed then return false end
	return true
end

hook.Add("SetupMove", "dbt/ragdoll/fall_air", function(ply, mv)
	local vel = mv:GetVelocity()
	if not shouldAirRagdoll(ply, vel) then return end

	local speed = math.abs(vel.z)
	local success = startRagdoll(ply, {
		initialDamage = 0,
		overrideVelocity = vel,
		cause = "fall_air",
		impactSpeed = speed,
	})

	if success and woundsModuleAvailable then
		hook.Run("dbt/ragdoll/fall_air", ply, speed)
	end
end)

hook.Add("OnPlayerHitGround", "dbt/ragdoll/fall", function(ply, inWater, onFloater, speed)

end)

local directionalTokens = {
	left = {"_l", "left"},
	right = {"_r", "right"},
}

local function containsAny(str, tokens)
	for _, token in ipairs(tokens) do
		if string.find(str, token, 1, true) then
			return true
		end
	end
	return false
end

-- Function to detect hitbox from damage position
local function DetectHitboxFromDamage(ragdoll, dmgpos)
	local closestBone = nil
	local closestDistance = math.huge
	local hitbox = "unknown"
	local woundPosition = woundPositionFallback

	-- Get all physics bones and find the closest one to damage position
	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local physBone = ragdoll:GetPhysicsObjectNum(i)
		if physBone:IsValid() then
			local boneID = ragdoll:TranslatePhysBoneToBone(i)
			local bonePos = ragdoll:GetBonePosition(boneID)
			local distance = dmgpos:Distance(bonePos)

			if distance < closestDistance then
				closestDistance = distance
				closestBone = boneID
			end
		end
	end

	-- Map bone to hitbox regions
	if closestBone then
		local boneName = ragdoll:GetBoneName(closestBone):lower()
		local isLeft = containsAny(boneName, directionalTokens.left)
		local isRight = containsAny(boneName, directionalTokens.right)

		-- Head hitbox
		if containsAny(boneName, {"head", "neck", "skull"}) then
			hitbox = "head"
			woundPosition = woundsModuleAvailable and dbt.woundsposition.head or "head"
		-- Chest/torso hitbox
		elseif containsAny(boneName, {"spine", "chest", "rib", "clavicle"}) then
			hitbox = "chest"
			woundPosition = woundsModuleAvailable and dbt.woundsposition.chest or "chest"
		-- Arm hitboxes
		elseif containsAny(boneName, {"arm", "hand", "finger", "shoulder", "forearm"}) then
			if isLeft and not isRight then
				hitbox = "left_arm"
				woundPosition = woundsModuleAvailable and dbt.woundsposition.leftarm or "left_arm"
			elseif isRight and not isLeft then
				hitbox = "right_arm"
				woundPosition = woundsModuleAvailable and dbt.woundsposition.rightarm or "right_arm"
			else
				hitbox = "arm"
				woundPosition = woundsModuleAvailable and dbt.woundsposition.leftarm or "arm"
			end
		-- Leg hitboxes
		elseif containsAny(boneName, {"leg", "foot", "toe", "thigh", "calf", "knee"}) then
			if isLeft and not isRight then
				hitbox = "left_leg"
				woundPosition = woundsModuleAvailable and dbt.woundsposition.leftleg or "left_leg"
			elseif isRight and not isLeft then
				hitbox = "right_leg"
				woundPosition = woundsModuleAvailable and dbt.woundsposition.rightleg or "right_leg"
			else
				hitbox = "leg"
				woundPosition = woundsModuleAvailable and dbt.woundsposition.leftleg or "leg"
			end
		-- Pelvis/stomach
		elseif containsAny(boneName, {"pelvis", "hip", "spine1"}) then
			hitbox = "stomach"
			woundPosition = woundsModuleAvailable and dbt.woundsposition.chest or "stomach"
		else
			hitbox = "torso"
			woundPosition = woundsModuleAvailable and dbt.woundsposition.chest or "torso"
		end
	end

	return closestBone, hitbox, closestDistance, woundPosition
end
local nextRagDamage = 0
hook.Add( "EntityTakeDamage", "ragdolldamage", function( target, dmginfo )
	if target:IsRagdoll() and IsGame() then
		local dmgpos = dmginfo:GetDamagePosition()
		local boneHit, hitbox, _, woundPosition = DetectHitboxFromDamage(target, dmgpos)
		local owner = target:GetNWEntity(ragdollOwnerKey)
		if not IsValid(owner) then return end
		local now = CurTime()
		if now < nextRagDamage then return end
		nextRagDamage = now + 0.15
		local state = owner[ragdollStateKey]
		if not state then return end

		local rawDamage = dmginfo:GetDamage()
		if dmginfo:GetDamageType() == 1 then
			if rawDamage > 50 then rawDamage = rawDamage * 0.7 end
		end

		if rawDamage <= 0 then return end

		state.health = math.max(0, (state.health or owner:Health()) - rawDamage)
		if state.health > 0 then
			owner:SetHealth(math.max(1, math.floor(state.health)))
		end

		if woundsModuleAvailable then
			local woundType
			local dmgType = dmginfo:GetDamageType()
			if bit.band(dmgType, DMG_BULLET) > 0 then
				woundType = woundTypes.bulletwound
			elseif bit.band(dmgType, DMG_SLASH) > 0 then
				woundType = woundTypes.wound
			elseif bit.band(dmgType, DMG_CLUB) > 0 then
				woundType = woundTypes.bruises
			elseif (bit.band(dmgType, DMG_CRUSH) > 0 or bit.band(dmgType, DMG_FALL) > 0) and (rawDamage >= 5) then
				woundType = (rawDamage >= 20) and woundTypes.fracture or woundTypes.bruises
			elseif bit.band(dmgType, DMG_BURN) > 0 or bit.band(dmgType, DMG_SLOWBURN) > 0 then
				woundType = woundTypes.hardwound or woundTypes.wound
			end

			if woundType and woundPosition then
				dbt.setWound(owner, woundType, woundPosition, dmgpos)
			end
			if bit.band(dmgType, DMG_BURN) > 0 or bit.band(dmgType, DMG_SLOWBURN) > 0 then
				owner:Ignite(1)
			end
		end

		hook.Run("dbt/ragdoll/damage", owner, target, dmginfo, {
			bone = boneHit,
			hitbox = hitbox,
			woundPosition = woundPosition,
			damage = rawDamage,
			state = state,
		})

		if state.health <= 0 then
			forceKillFromRagdoll(owner)
		end
	end
end )

hook.Add("PlayerButtonDown", 'ragdolldisable',function (ply, btn)
	if btn == KEY_SPACE and ply:GetNWBool("ragdolled", false) and !dbt.hasWoundOnpos(ply, "Парализован", "Туловище") then
		restoreFromRagdoll(ply, {
			setPosition = true,
		})
		ply:SelectWeapon("hands")
	end
end)

hook.Add("PlayerDisconnected", "dbt/ragdoll/cleanup", function(ply)
	if not IsValid(ply) then return end
	if ply:GetNWBool("ragdolled", false) then
		restoreFromRagdoll(ply, {})
	end
	local monitorId = getMonitorId(ply)
	timer.Remove(monitorId)
end)
