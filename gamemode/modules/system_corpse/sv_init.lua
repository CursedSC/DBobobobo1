util.AddNetworkString("ragdeath_client")

local MaxDRagsVar = CreateConVar("ragdeath_keepmax","2",FCVAR_ARCHIVE,"")
local FPRagVar = CreateConVar("ragdeath_firstperson","1",FCVAR_ARCHIVE,"")
local OwnRagVar = CreateConVar("ragdeath_playerown","1",FCVAR_ARCHIVE,"")
local TimeRagVar = CreateConVar("ragdeath_timeremove","120", FCVAR_ARCHIVE,"")
local CollideRagVar = CreateConVar("ragdeath_playercollide","1", FCVAR_ARCHIVE,"")

local DeathRagdolls = {}
testGloobalTable = {}

local function SpawnCorpseItem(itemId, meta, position, angle)
	local drop = ents.Create("item")
	if not IsValid(drop) then return nil end

	position = position or vector_origin
	angle = angle or Angle(0, 0, 0)

	drop:SetPos(position)
	drop:SetAngles(angle)
	drop:SetInfo(itemId, meta)
	drop:Spawn()

	local cfg = dbt.inventory.items[itemId]
	if cfg and cfg.mdl then
		drop:SetModel(cfg.mdl)
		drop:PhysicsInit(SOLID_VPHYSICS)
		drop:SetMoveType(MOVETYPE_VPHYSICS)
		drop:SetSolid(SOLID_VPHYSICS)
		local phys = drop:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end

	return drop
end

local function createRagdoll(player, inf, sss)
	local OldRagdoll = player:GetRagdollEntity()
	if ( OldRagdoll && OldRagdoll:IsValid() ) then OldRagdoll:Remove() end
	

	charactersInGame[player:Pers()].diepos = player:GetPos()
	player.deathData = {
		info = table.Copy(player.info or {}),
		items = table.Copy(player.items or {}),
	}

	if sss == player then
		text = "Нет информации"
	else
		text = "казнь"
		if sss:IsPlayer() then
			text = sss:GetActiveWeapon():GetClass()
		end
	end
	globaltime = GetGlobalInt("Time")
    s = globaltime % 60
    tmp = math.floor( globaltime / 60 )
    m = tmp % 60
    tmp = math.floor( tmp / 60 )
    h = tmp % 24
    curtimesys = string.format( "%02ih %02im %02is", h, m, s)

	local Ragdoll = ents.Create( "prop_ragdoll" )
	Ragdoll:SetModel(player:GetModel())
	Ragdoll:SetPos(player:GetPos())
	--[[
	if dbt.PlayersWounds[player] then
		testGloobalTable[Ragdoll] = dbt.PlayersWounds[player]
		PrintTable(dbt.PlayersWounds[player])
		Ragdoll.wounds = dbt.PlayersWounds[player]
		PrintTable(Ragdoll.wounds)
	end]]
	--[[
	local body = ents.Create("ent_body")
	body:SetPos(player:GetPos())
	body:SetParent(Ragdoll)
	body:SetDataTable(player:Pers(), dbt.chr[player:Pers()].absl or "Пусто", curtimesys, "dfsdfsd", text, "fd")
	body:SetKiller(sss)
	body:Spawn()
	body:SetNoDraw(true)]]

	for k,v in pairs(player:GetBodyGroups()) do
		Ragdoll:SetBodygroup(v.id,player:GetBodygroup(v.id))
	end

	Ragdoll:Spawn()

	Ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local inventoryCount = 0
	if istable(player.items) then
		inventoryCount = #player.items
	else
		player.items = {}
	end

	local corpseStorage
	if inventoryCount > 0 then
		local steam64 = player:SteamID64() or ("bot" .. player:UserID())
		local storageId = string.format("corpse_%s_%d_%d", steam64, player:EntIndex(), math.floor(CurTime() * 1000))

		local charData = dbt.chr and dbt.chr[player:Pers()]
		local inventoryCapacity = 0
		if charData and tonumber(charData.maxInventory) then
			inventoryCapacity = math.max(math.floor(charData.maxInventory), 0)
		end

		local maxSlots = math.max(inventoryCount, inventoryCapacity, 16)

		corpseStorage = dbt.inventory.storage.Attach(Ragdoll, {
			id = storageId,
			name = "Труп",
			maxSlots = maxSlots,
			autoCloseDistance = 150,
			spoilSlowdown = true,
		})

		if corpseStorage then
			Ragdoll:SetUseType(SIMPLE_USE)
			Ragdoll:SetNWInt("AdvencedUse", 1)
			Ragdoll:SetNWBool("dbt_is_storage", true)
			Ragdoll.dbtCorpseStorageId = corpseStorage.id
			player.deathData.corpseStorageId = corpseStorage.id

			local removedEntries = {}
			for idx = inventoryCount, 1, -1 do
				local entry = dbt.inventory.removeitem(player, idx, false, true)
				if entry then
					removedEntries[#removedEntries + 1] = {
						id = entry.id,
						meta = entry.meta and table.Copy(entry.meta) or nil
					}
				end
			end

			for i = #removedEntries, 1, -1 do
				local entry = removedEntries[i]
				dbt.inventory.storage.AddItem(corpseStorage, entry.id, entry.meta)
			end

			Ragdoll:CallOnRemove("dbt_corpse_storage_cleanup", function(ent, storageIdParam)
				local storageRef = dbt.inventory.storage.Get(storageIdParam)
				if not storageRef then return end

				if storageRef.occupant then
					dbt.inventory.storage.Close(storageRef, { forced = true })
				end

				if storageRef.items and #storageRef.items > 0 then
					local basePos = ent:GetPos() + Vector(0, 0, 8)
					for _, stored in ipairs(storageRef.items) do
						SpawnCorpseItem(stored.id, stored.meta, basePos + VectorRand() * 6, AngleRand())
					end
				end

				dbt.inventory.storage.Detach(storageRef)
			end, corpseStorage.id)
		end
	end

	if not corpseStorage then
		Ragdoll:SetNWBool("dbt_is_storage", false)
		for idx = inventoryCount, 1, -1 do
			local entry = dbt.inventory.removeitem(player, idx, false, true)
			if entry then
				local drop = SpawnCorpseItem(entry.id, entry.meta, player:GetPos() + VectorRand() * 6 + Vector(0, 0, 5), AngleRand())
				if IsValid(drop) then
					player.deathData.entsItems[#player.deathData.entsItems + 1] = drop
				end
			end
		end
	end

	player:SetNWEntity("DeathRagdoll", Ragdoll)
	Ragdoll:CallOnRemove("dbt_clearDeathView", function(ent, owner)
		if not IsValid(owner) then return end
		if owner:GetNWEntity("DeathRagdoll") == ent then
			owner:SetNWEntity("DeathRagdoll", nil)
		end
	end, player)

	local PlyVel = player:GetVelocity() * 0.1

	for ID = 0, Ragdoll:GetPhysicsObjectCount()-1 do
		local PhysBone = Ragdoll:GetPhysicsObjectNum( ID )
		if ( PhysBone:IsValid() ) then
			local Pos, Ang = player:GetBonePosition( Ragdoll:TranslatePhysBoneToBone( ID ) )
			PhysBone:SetPos( Pos )
			PhysBone:SetAngles( Ang )
			PhysBone:AddVelocity( PlyVel )
		end
	end

	Ragdoll.CanConstrain = true
	Ragdoll.GravGunPunt = true
	Ragdoll.PhysgunDisabled = false

	local PlayerColor = player:GetPlayerColor()
	Ragdoll.RagColor = Vector(PlayerColor.r, PlayerColor.g, PlayerColor.b)

	Ragdoll:SetCreator(OwnRagVar:GetBool() and player or nil)

	if CPPI and OwnRagVar:GetBool() then
		Ragdoll:CPPISetOwner( player )
	end
	player.deathData.Ragdoll = Ragdoll
	player.deathData.entsItems = {}
	for _, weapon in ipairs(player:GetWeapons()) do
		local class = weapon:GetClass()
		if class == "hands" or class == "weapon_physgun" or class == "gmod_tool" then continue end
		local itemId
		for k, data in pairs(dbt.inventory.items) do
			if data.weapon == class then
				itemId = k
				break
			end
		end
		if not itemId then continue end

		local drop = SpawnCorpseItem(itemId, nil, player:GetPos() + VectorRand() * 8 + Vector(0, 0, 5), AngleRand())
		if IsValid(drop) then
			player.deathData.entsItems[#player.deathData.entsItems + 1] = drop
		end
	end
	if player.info then
		player.info.weapon = {}
	end

	if player.info.monopad.id then
		local drop = SpawnCorpseItem(player.info.monopad.id, player.info.monopad.meta, player:GetPos() + VectorRand() * 6 + Vector(0, 0, 5), AngleRand())
		if IsValid(drop) then
			player.deathData.entsItems[#player.deathData.entsItems + 1] = drop
		end
		player.info.monopad = {}
	end
	if player.info.keys.id then
		local drop = SpawnCorpseItem(player.info.keys.id, player.info.keys.meta, player:GetPos() + VectorRand() * 6 + Vector(0, 0, 5), AngleRand())
		if IsValid(drop) then
			player.deathData.entsItems[#player.deathData.entsItems + 1] = drop
		end
		player.info.keys = {}
	end

	if player.syncInformation then
		player:syncInformation()
	end

	return Ragdoll
end
--
local function playerDie(ply, inf, sss)
	local Ragdoll = createRagdoll(ply, inf, sss)
	if not IsValid(Ragdoll) then return end
	DeathRagdolls[ply] = DeathRagdolls[ply] or {}
	maxrags = math.max(MaxDRagsVar:GetInt(),1)
	while #DeathRagdolls[ply]>=maxrags do
		local olrag = DeathRagdolls[ply][1]
		if IsValid(olrag) then olrag:Remove() end
		table.remove(DeathRagdolls[ply],1)
	end
	DeathRagdolls[ply][#DeathRagdolls[ply]+1] = Ragdoll

end

hook.Add("PlayerDeath","RagDeath_Death", playerDie)

hook.Add("PlayerSpawn", "dbt_clearDeathRagdoll", function(ply)
	ply:SetNWEntity("DeathRagdoll", nil)
end)
