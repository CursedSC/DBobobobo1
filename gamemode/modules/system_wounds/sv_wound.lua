AddCSLuaFile()
local lastdmg = 0
dbt.PlayersWounds = {}

dbt.medicaments = {
	bandage = "Бинт",
	ointment = "Мазь",
	fracturesplint = "Шинадляпереломов",
	cms = "Хирургическийнабор",
}

dbt.woundstypes = {
	bruises = "Ушиб",
	wound = "Ранение",
	hardwound = "Тяжелое ранение",
	bulletwound = "Пулевое ранение",
	fracture = "Перелом",
	paralysed = "Парализован",
}

dbt.woundsposition = {
	head = "Голова",
	chest = "Туловище",
	leftarm = "Левая рука",
	rightarm = "Правая рука",
	leftleg = "Левая нога",
	rightleg = "Правая нога",
}

dbt.twohandlesweps = {
	"tfa_nmrih_bow",
	"tfa_nmrih_asaw",
	"tfa_nmrih_bat",
	"tfa_nmrih_chainsaw",
	"tfa_nmrih_etool",
	"tfa_l4d2_kfkat",
	"tfa_nmrih_pickaxe",
	"tfa_nmrih_sledge",
	"tfa_nmrih_spade",
	"weapon_vfirethrower",
	"tfa_nmrih_fext",
	"tfa_nmrih_fireaxe",
	"tfa_l4d2_talaxe",
	"tfa_nmrih_fubar"
}

dbt.wounds_disconnect = dbt.wounds_disconnect or {}

local function tableIsEmpty(tbl)
	if not tbl then return true end
	return next(tbl) == nil
end

local function buildPublicWoundSnapshot(ply)
	local raw = dbt.PlayersWounds[ply]
	if not raw then return {} end

	local snapshot = {}
	for position, entries in pairs(raw) do
		if istable(entries) then
			for _, entry in pairs(entries) do
				local woundType = entry
				if istable(entry) then
					woundType = entry[1]
				end
				if woundType and woundType ~= "" then
					snapshot[position] = snapshot[position] or {}
					snapshot[position][woundType] = (snapshot[position][woundType] or 0) + 1
				end
			end
		end
	end

	return snapshot
end

local function broadcastWoundState(ply, target)
	if not IsValid(ply) then return end
	local payload = buildPublicWoundSnapshot(ply)
	if target == nil then
		netstream.Start(nil, "dbt/woundsystem/public_state", ply, payload)
	else
		netstream.Start(target, "dbt/woundsystem/public_state", ply, payload)
	end
end

local function sendAllWoundStates(toPly)
	if not IsValid(toPly) then return end
	for _, woundOwner in ipairs(player.GetAll()) do
		if IsValid(woundOwner) then
			broadcastWoundState(woundOwner, toPly)
		end
	end
end

timer.Create("Bleeding_Demit", 15, 0, function()
	for _, ply in ipairs(player.GetHumans()) do
		if ply:IsValid() and (dbt.hasWound(ply, "Ранение")) then
			ply:TakeDamage(3)
			dbt.effects.bleeding(ply)
		end

		if ply:IsValid() and (dbt.hasWound(ply, "Тяжелое ранение") or dbt.hasWound(ply, "Пулевое ранение")) then
			ply:TakeDamage(5)
			dbt.effects.hardbleeding(ply)
		end
	end
end)


dbt.effects = {
	bleeding = function(ply)
		if not ply:IsValid() or not ply:Alive() then return end

		local effectdata = EffectData()
		effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
		effectdata:SetNormal(Vector(0, 0, -1))
		effectdata:SetMagnitude(2)
		effectdata:SetScale(1)
		util.Effect("BloodImpact", effectdata)

		dbt.CreateBloodDecal(ply)
	end,

	hardbleeding = function(ply)
		if not ply:IsValid() or not ply:Alive() then return end

		local effectdata = EffectData()
		effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
		effectdata:SetNormal(Vector(0, 0, -1))
		effectdata:SetMagnitude(4)
		effectdata:SetScale(2)
		util.Effect("BloodImpact", effectdata)

		dbt.CreateBloodDecal(ply, true)
	end,
}

function dbt.CreateBloodDecal(ply, isHeavy)
	if not ply:IsValid() then return end

	local startPos = ply:GetPos() + Vector(0, 0, 10)
	local endPos = startPos + Vector(0, 0, -100)

	local trace = util.TraceLine({
		start = startPos,
		endpos = endPos,
		filter = ply,
		mask = MASK_SOLID_BRUSHONLY
	})

	if trace.Hit then
		local decalSize = isHeavy and math.random(15, 25) or math.random(8, 15)
		local bloodDecals = {
			"Blood",
		}

		local decalName = bloodDecals[math.random(1, #bloodDecals)]

		util.Decal(decalName, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, ply)

		for i = 1, math.random(2, 4) do
			local randomPos = trace.HitPos + Vector(
				math.random(-decalSize, decalSize),
				math.random(-decalSize, decalSize),
				5
			)

			local smallTrace = util.TraceLine({
				start = randomPos,
				endpos = randomPos + Vector(0, 0, -20),
				filter = ply,
				mask = MASK_SOLID_BRUSHONLY
			})

			if smallTrace.Hit then
				util.Decal("Blood", smallTrace.HitPos + smallTrace.HitNormal, smallTrace.HitPos - smallTrace.HitNormal, ply)
			end
		end
	end
end

hook.Add("PlayerDisconnected", "dbt/woundsystem/disconnect_savewounds",function (ply)
	dbt.wounds_disconnect[ply:Name()] = dbt.getWounds(ply)
	broadcastWoundState(ply)
end)

hook.Add("PlayerSpawn", "woundstbl",function (ply)
	if dbt.wounds_disconnect[ply:Name()] then
		dbt.PlayersWounds[ply] = dbt.wounds_disconnect[ply:Name()]
		timer.Simple(3,function ()
			dbt.wounds_disconnect[ply:Name()] = nil
		end)
		netstream.Start(ply, "dbt/woundsystem/cl_getwound", dbt.PlayersWounds[ply])
		broadcastWoundState(ply)
		timer.Simple(0.1, function()
			if not IsValid(ply) then return end
			sendAllWoundStates(ply)
		end)
	elseif !ply.AfterRagdoll then
		timer.Simple(0.5, function()
			if not IsValid(ply) then return end
			dbt.PlayersWounds[ply] = nil
			netstream.Start(ply, "dbt/woundsystem/cl_getwound", dbt.PlayersWounds[ply])
			broadcastWoundState(ply)
			sendAllWoundStates(ply)
		end)
	end
end)

function dbt.hasWound(ply, wound)
	if !dbt.PlayersWounds[ply] then
		dbt.PlayersWounds[ply] = {}
		return false
	end
	for k, v in pairs(dbt.PlayersWounds[ply]) do
		if v[1] and table.HasValue(v[1], wound) then
			return true
		else
		end
	end

	return false
end

function dbt.hasWoundOnpos(ply, wound, position)
	if !dbt.PlayersWounds[ply] then
		return false
	end

	if !dbt.PlayersWounds[ply][position] then
		return false
	end
	for k, i in pairs(dbt.PlayersWounds[ply][position]) do
		if table.HasValue(i, wound) then return true end
	end

	return false
end

function dbt.setWound(ply, wound, position, vector)
	if !dbt.PlayersWounds[ply] then
		dbt.PlayersWounds[ply] = {}
	end
	if (wound ~= "Ушиб" and wound ~= "Ранение") and dbt.hasWoundOnpos(ply, wound, position) then return end

	if wound == "Ранение" or wound == "Пулевое ранение" then
		dbt.effects.bleeding(ply)
	elseif wound == "Тяжелое ранение" then
		dbt.effects.hardbleeding(ply)
	end
	if !dbt.PlayersWounds[ply][position] and ply:IsValid() then
		dbt.PlayersWounds[ply][position] = {{wound, vector}}
	else
		if !ply:IsValid() then return end
		if !dbt.hasWoundOnpos(ply, wound, position) then table.insert(dbt.PlayersWounds[ply][position], {wound, vector}) end

		if wound == "Ушиб" and dbt.hasWound(ply, "Ушиб") then
			local countbruis = table.Count(table.KeysFromValue(dbt.PlayersWounds[ply][position], "Ушиб"))

			if countbruis > 1 then
				local chance = math.Clamp(countbruis*30, 0, 100)
				if math.random(chance, 100) >= math.random(0, 100) then
					dbt.removeWounds(ply, "Ушиб", position)
					table.insert(dbt.PlayersWounds[ply][position], {dbt.woundstypes.fracture, vector})
					if ply:HasWeapon("hands") then
						ply:SelectWeapon("hands")
					end
				end
			end
		elseif wound == "Ранение" and dbt.hasWound(ply, "Ранение") then
			local countwound = table.Count(table.KeysFromValue(dbt.PlayersWounds[ply][position], "Ранение"))
			if countwound > 1 then
				local chance = math.Clamp(countwound*30, 0, 100)
				if math.random(chance, 100) >= math.random(0, 100) then
					dbt.removeWounds(ply, "Ранение", position)
					table.insert(dbt.PlayersWounds[ply][position], {dbt.woundstypes.hardwound, vector})
				end
			end
		end
	end

	netstream.Start(ply, "dbt/woundsystem/cl_getwound", dbt.PlayersWounds[ply])
	netstream.Start(ply, 'dbt/NewNotification', 1, {woundpos = position, wound = wound})
	broadcastWoundState(ply)

	if wound == "Парализован" and IsValid(ply) and ply:Alive() and not ply.isSpectating and not ply:GetNWBool("ragdolled", false) then
		if startRagdoll then
			startRagdoll(ply, {
				initialDamage = 0,
				cause = "paralysis",
			})
		end
	end

	openobserve.Log({
		event = "wound_set",
		name = ply:Name(),
		steamid = ply:SteamID(),
		wound = wound,
	})

	return dbt.PlayersWounds[ply]
end

function dbt.removeWound(ply, wound, position)
	if not dbt.PlayersWounds[ply][position] then return end
	for k, i in pairs(dbt.PlayersWounds[ply][position]) do
		local id = table.KeyFromValue(i, wound)
		if not id then continue end
		table.remove(dbt.PlayersWounds[ply][position][k], id)
		table.remove(dbt.PlayersWounds[ply][position], k)
	end

	netstream.Start(ply, "dbt/woundsystem/cl_getwound", dbt.PlayersWounds[ply])
		broadcastWoundState(ply)
	return dbt.PlayersWounds[ply][position]
end

function dbt.removeWounds(ply, wound, position)
	local tbl = dbt.PlayersWounds[ply][position]
	for k, v in pairs(tbl) do
		if tbl[k] == wound then
			tbl[k] = nil
		end
	end


	netstream.Start(ply, "dbt/woundsystem/cl_getwound", dbt.PlayersWounds[ply])
	broadcastWoundState(ply)
	return dbt.PlayersWounds[ply][position]
end

function dbt.resetWounds(ply)
	if !dbt.PlayersWounds[ply] then
		dbt.PlayersWounds[ply] = {}
	end

	for k, v in pairs(dbt.woundsposition) do
		dbt.PlayersWounds[ply][v] = nil
	end

	netstream.Start(ply, "dbt/woundsystem/cl_getwound", dbt.PlayersWounds[ply])
	broadcastWoundState(ply)
	return dbt.PlayersWounds[ply]
end

function dbt.getWounds(ply)
	return dbt.PlayersWounds[ply] or {}
end
local function DetectHitboxFromDamage(player, dmgpos)
	local closestBone = nil
	local closestDistance = math.huge
	local hitbox = "unknown"
	local woundPosition = ""

	for i = 0, player:GetBoneCount() - 1 do
		local bonePos, boneAng = player:GetBonePosition(i)
		if bonePos then
			local distance = dmgpos:Distance(bonePos)

			if distance < closestDistance then
				closestDistance = distance
				closestBone = i
			end
		end
	end

	if closestBone then
		local boneName = player:GetBoneName(closestBone):lower()

		if string.find(boneName, "head") or string.find(boneName, "neck") or string.find(boneName, "skull") then
			hitbox = "head"
			woundPosition = dbt.woundsposition.head
		elseif string.find(boneName, "spine") or string.find(boneName, "chest") or string.find(boneName, "ribcage") then
			hitbox = "chest"
			woundPosition = dbt.woundsposition.chest
		elseif string.find(boneName, "arm") or string.find(boneName, "hand") or string.find(boneName, "finger") or string.find(boneName, "shoulder") or string.find(boneName, "forearm") or string.find(boneName, "upperarm") then
			if string.find(boneName, "_l_") or string.find(boneName, "left") then
				hitbox = "left_arm"
				woundPosition = dbt.woundsposition.leftarm
			elseif string.find(boneName, "_r_") or string.find(boneName, "right") then
				hitbox = "right_arm"
				woundPosition = dbt.woundsposition.rightarm
			else
				hitbox = "arm"
				woundPosition = dbt.woundsposition.leftarm
			end
		elseif string.find(boneName, "leg") or string.find(boneName, "foot") or string.find(boneName, "toe") or string.find(boneName, "thigh") or string.find(boneName, "calf") or string.find(boneName, "knee") then
			if string.find(boneName, "_l_") or string.find(boneName, "left") then
				hitbox = "left_leg"
				woundPosition = dbt.woundsposition.leftleg
			elseif string.find(boneName, "_r_") or string.find(boneName, "right") then
				hitbox = "right_leg"
				woundPosition = dbt.woundsposition.rightleg
			else
				hitbox = "leg"
				woundPosition = dbt.woundsposition.leftleg
			end
		elseif string.find(boneName, "pelvis") or string.find(boneName, "hip") then
			hitbox = "stomach"
			woundPosition = dbt.woundsposition.chest
		else
			hitbox = "torso"
			woundPosition = dbt.woundsposition.chest
		end
	end

	return closestBone, hitbox, closestDistance, woundPosition
end

SetGlobalBool("Wounds", true)
hook.Add("EntityTakeDamage", "dbt/woundsystem/setwound1", function(target, dmginfo)
	if !target:IsPlayer() then return end
	if IsLobby() then return end
	if !GetGlobalBool("Wounds") then return end
	if target:Pers() == "K1-B0" then return end
	local attacker = dmginfo:GetAttacker()
    local damagetype = dmginfo:GetDamageType()
	local damage = dmginfo:GetDamage()
	local timerdelay = CurTime()
	if timerdelay - lastdmg < 0.1 then
		return
	end
	local trace

	if attacker:IsPlayer() then
		trace = attacker:GetEyeTrace()
	end
	local woundPos
	local hitPos = dmginfo:GetDamagePosition()
	local boneHit, hitbox, distance, detectedWoundPos = DetectHitboxFromDamage(target, hitPos)

    if target:IsPlayer() then
		local hitgroup = target:LastHitGroup()
		local finalWoundPos = detectedWoundPos or dbt.woundsposition.chest

		local useBoneDetection = detectedWoundPos and detectedWoundPos ~= ""

		if damagetype == DMG_FALL then
			if damage > 30 then
				dbt.setWound(target, dbt.woundstypes.fracture, dbt.woundsposition.leftleg, woundPos)
				dbt.setWound(target, dbt.woundstypes.fracture, dbt.woundsposition.rightleg, woundPos)
			else
				dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.leftleg, woundPos)
				dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.rightleg, woundPos)
			end
		elseif damagetype == DMG_BULLET then
				if useBoneDetection then
				dbt.setWound(target, dbt.woundstypes.bulletwound, finalWoundPos, woundPos)
			else
				if hitgroup == HITGROUP_HEAD then
		            dbt.setWound(target, dbt.woundstypes.bulletwound, dbt.woundsposition.head, woundPos)
				elseif hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH then
					dbt.setWound(target, dbt.woundstypes.bulletwound, dbt.woundsposition.chest, woundPos)
				elseif hitgroup == HITGROUP_RIGHTLEG then
					dbt.setWound(target, dbt.woundstypes.bulletwound, dbt.woundsposition.rightleg, woundPos)
				elseif hitgroup == HITGROUP_LEFTARM then
					dbt.setWound(target, dbt.woundstypes.bulletwound, dbt.woundsposition.leftarm, woundPos)
				elseif hitgroup == HITGROUP_RIGHTARM then
					dbt.setWound(target, dbt.woundstypes.bulletwound, dbt.woundsposition.rightarm, woundPos)
				elseif hitgroup == HITGROUP_LEFTLEG then
					dbt.setWound(target, dbt.woundstypes.bulletwound, dbt.woundsposition.leftleg, woundPos)
				end
			end
        elseif damagetype == DMG_CLUB then
			if useBoneDetection then
				dbt.setWound(target, dbt.woundstypes.bruises, finalWoundPos, woundPos)
			else
				if hitgroup == HITGROUP_HEAD then
		            dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.head, woundPos)
				elseif hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH then
					dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.chest, woundPos)
				elseif hitgroup == HITGROUP_RIGHTLEG then
					dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.rightleg, woundPos)
				elseif hitgroup == HITGROUP_LEFTARM then
					dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.leftarm, woundPos)
				elseif hitgroup == HITGROUP_RIGHTARM then
					dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.rightarm, woundPos)
				elseif hitgroup == HITGROUP_LEFTLEG then
					dbt.setWound(target, dbt.woundstypes.bruises, dbt.woundsposition.leftleg, woundPos)
				end
			end
		elseif damagetype == DMG_SLASH then
			if useBoneDetection then
				dbt.setWound(target, dbt.woundstypes.wound, finalWoundPos, woundPos)
			else
				if hitgroup == HITGROUP_HEAD then
		            dbt.setWound(target, dbt.woundstypes.wound, dbt.woundsposition.head, woundPos)
				elseif hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH then
					dbt.setWound(target, dbt.woundstypes.wound, dbt.woundsposition.chest, woundPos)
				elseif hitgroup == HITGROUP_RIGHTLEG then
					dbt.setWound(target, dbt.woundstypes.wound, dbt.woundsposition.rightleg, woundPos)
				elseif hitgroup == HITGROUP_LEFTARM then
					dbt.setWound(target, dbt.woundstypes.wound, dbt.woundsposition.leftarm, woundPos)
				elseif hitgroup == HITGROUP_RIGHTARM then
					dbt.setWound(target, dbt.woundstypes.wound, dbt.woundsposition.rightarm, woundPos)
				elseif hitgroup == HITGROUP_LEFTLEG then
					dbt.setWound(target, dbt.woundstypes.wound, dbt.woundsposition.leftleg, woundPos)
				end
			end
		end
    end
	lastdmg = timerdelay
end)

function dbt.CanUseMedicaments(ply, medclass)
	if medclass == dbt.medicaments.bandage then
		if !dbt.hasWound(ply, "Ранение") then return false end
	elseif medclass == dbt.medicaments.ointment then
		if !dbt.hasWound(ply, "Ушиб") then return false end
	elseif medclass == dbt.medicaments.fracturesplint then
		if !dbt.hasWound(ply, "Перелом") then return false end
	elseif medclass == dbt.medicaments.cms then
		if !dbt.hasWound(ply, "Тяжелое ранение") and !dbt.hasWound("Пулевое ранение") then return false end
	end
	return true
end

function dbt.UseMedicaments(ply, medclass, position)
	if medclass == dbt.medicaments.bandage then
		if !dbt.hasWound(ply, "Ранение") then return false end

		if position then
			if !dbt.hasWound(ply, "Ранение", position) then return false end
			dbt.removeWound(ply, "Ранение", position)
			return true
		end

		for k, v in pairs(dbt.woundsposition) do
			if dbt.hasWoundOnpos(ply, "Ранение", v) then
				dbt.removeWound(ply, "Ранение", v)
				return true
			end
		end

	elseif medclass == dbt.medicaments.ointment then
		if !dbt.hasWound(ply, "Ушиб") then return false end
		if position then
			if !dbt.hasWound(ply, "Ушиб", position) then return false end
			dbt.removeWound(ply, "Ушиб", position)
			return true
		end

		for k, v in pairs(dbt.woundsposition) do
			if dbt.hasWoundOnpos(ply, "Ушиб", v) then
				dbt.removeWound(ply, "Ушиб", v)
				return true
			end
		end

	elseif medclass == dbt.medicaments.fracturesplint then
		if !dbt.hasWound(ply, "Перелом") then return false end

		if position then
			if !dbt.hasWound(ply, "Перелом", position) then return false end
			dbt.removeWound(ply, "Перелом", position)
			return true
		end

		for k, v in pairs(dbt.woundsposition) do
			if dbt.hasWoundOnpos(ply, "Перелом", v) then
				dbt.removeWound(ply, "Перелом", v)
				return true
			end
		end

	elseif medclass == dbt.medicaments.cms then
		if !dbt.hasWound(ply, "Тяжелое ранение") and !dbt.hasWound(ply, "Пулевое ранение") then return false end

		if position then
			if !dbt.hasWound(ply, "Тяжелое ранение", position) then return false end
			dbt.removeWound(ply, "Тяжелое ранение", position)
			return true
		end

		if position then
			if !dbt.hasWound(ply, "Пулевое ранение", position) then return false end
			dbt.removeWound(ply, "Пулевое ранение", position)
			return true
		end

		for k, v in pairs(dbt.woundsposition) do
			if dbt.PlayersWounds[ply][v] then
				if dbt.hasWoundOnpos(ply, "Тяжелое ранение", v) then 
					dbt.removeWound(ply, "Тяжелое ранение", v)
					return true
				end
				if dbt.hasWoundOnpos(ply, "Пулевое ранение", v) then 
					dbt.removeWound(ply, "Пулевое ранение", v)
					return true
				end
			end
		end
	end
end

hook.Add("PlayerUse", "DisableUseFracture",function (ply, ent)
	if dbt.hasWoundOnpos(ply, "Перелом", "Левая рука") and dbt.hasWoundOnpos(ply, "Перелом", "Правая рука") then
		return false
	end
end)

hook.Add("PlayerDeath", "removewounds",function (ply)
	timer.Simple(0.5, function() dbt.resetWounds(ply) end)


	ply.timerbleeding = nil
	ply.timerhardbleeding = nil
end)

hook.Add("PlayerSwitchWeapon", "DisableWeaponFracture", function(ply, oldwep, newwep)
	if ply:IsValid() and (dbt.hasWoundOnpos(ply, "Перелом", "Левая рука") or dbt.hasWoundOnpos(ply, "Перелом", "Правая рука")) then
		if dbt.hasWoundOnpos(ply, "Перелом", "Левая рука") and dbt.hasWoundOnpos(ply, "Перелом", "Правая рука") then
			return true
		end

		if table.HasValue(dbt.twohandlesweps, newwep:GetClass()) then
			return true
		end
	end
end)

netstream.Hook("dbt/woundsystem/usemedicine", function(ply, medclass, entity)
	if ply:IsValid() then
		dbt.UseMedicaments(ply, medclass)
		entity:Remove()
	end
end)

netstream.Hook("dbt/woundsystem/getwounds_properties", function(ply, target)
	if ply:IsValid() then
		local infowound = dbt.getWounds(target)
		PrintTable(infowound)
		netstream.Start(ply, "dbt/woundsystem/getwounds_properties_return", infowound)
	end
end)

concommand.Add("healallw", function(ply)
		local infowound = dbt.getWounds(ply)
		PrintTable(infowound)
end)

netstream.Hook("dbt/woundsystem/setwound", function(admin, ply, woundType, position, state)
	if !admin:IsAdmin() then return end
	if ply:IsValid() then
		if !state then
			dbt.setWound(ply, woundType, position, nil)
		else
			dbt.removeWound(ply, woundType, position)
		end
	end
end)

netstream.Hook("dbt/woundsystem/remove_wound_admin", function(admin, target, woundType, position)
	if not admin:IsAdmin() then 
		admin:ChatPrint("У вас нет прав!")
		return 
	end
	
	if not IsValid(target) then
		target = admin
	end
	
	if not target:IsValid() or not target:IsPlayer() then 
		admin:ChatPrint("Неверная цель!")
		return 
	end
	
	if dbt.hasWoundOnpos(target, woundType, position) then
		dbt.removeWound(target, woundType, position)
		admin:ChatPrint("Успешно убрано ранение: " .. woundType .. " с " .. position .. " у " .. target:Nick())
		
		openobserve.Log({
			event = "wound_removed_admin",
			admin = admin:Nick(),
			admin_steamid = admin:SteamID(),
			target = target:Nick(),
			target_steamid = target:SteamID(),
			wound = woundType,
			position = position
		})
	else
		admin:ChatPrint("У " .. target:Nick() .. " нет такого ранения на данной части тела!")
	end
end)