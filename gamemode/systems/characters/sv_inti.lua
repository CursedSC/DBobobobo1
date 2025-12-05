function dbt.setchr(ply, chr)
	if dbt.chr[chr] then 
		ply:SetNWString("dbt.CHR", chr)
		hook.Run("dbt.SetChr", ply, chr)
		return true
	else 
		return false
	end
end 


function dbt.initCustom(ply)
	local chr = ply:Pers()
	if !dbt.chr[chr] then return end  
	local pers = dbt.chr[chr] 
	if pers.customItems then
		for k, i in pairs(pers.customItems) do 
			dbt.inventory.additem(ply, i) 
		end
	end
	if pers.customWeapons then
		ply.spawned = true
		for k, i in pairs(pers.customWeapons) do 
			ply:Give(i, false)
		end
		ply.spawned = false
	end
end 
 
hook.Add("dbt.SpawnInit", "dbt.MainSet", function(ply)
	dbt.setchr(ply, "Гость")
end)

hook.Add("dbt.SetChr", "dbt.MainSet", function(ply, chr)
	ply:SetModel(dbt.chr[chr].model)
	local ent = ply:GetHands()
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
  	local info = player_manager.TranslatePlayerHands(simplemodel)
  	if info and IsValid(ply:GetHands()) then
  	   ply:GetHands():SetModel(info.model)
   	   ply:GetHands():SetSkin(info.skin)
 	end
 	ply:Give("hands")
 	if chr != "Гость" and not InGame(ply) then
		netstream.Start(ply, "dbt/inventory/info", {}, {})
		ply:InitializeInformation()
		ply.items = {}
		local id = dbt.monopads.New(ply:Pers())
	 	dbt.inventory.additem(ply, 1, {owner = ply:Pers(), id = id}) 
		dbt.inventory.additem(ply, 2, {owner = ply:Pers()}) 
		if dbt.inventory and dbt.inventory.SendUpdate then
			dbt.inventory.SendUpdate(ply)
		end
	dbt.initCustom(ply)
	end
end)

hook.Add("dbt.Spawn", "dbt.GiveWeapon", function(ply)
	ply:Give("hands")
end)

local function PlayerInit(ply)
	local character = dbt.GetCharacter(default)
	if character then 
	   dbt.setchr(ply, plycharacter)
	end
	netstream.Start(ply, "dbt.Sync.CHR", dbt.chr)
end
hook.Add("PlayerInitialSpawn", "dbt.PLInit", PlayerInit)

local function cloneCharacterData(source)
	if not istable(source) then return {} end
	local base = source.backup and table.Copy(source.backup) or table.Copy(source)
	base.backup = nil
	base.index = nil
	base.isCustom = nil
	return base
end

local function isCustomKey(name)
	if not isstring(name) then return false end
	return string.StartWith(string.lower(name), "customcharacter")
end

function dbt.CreateCharacter(name, data)
	local chr = setmetatable({}, CHARACTER)
	local sanitized = istable(data) and table.Copy(data) or {}
	chr:Init(name, sanitized)

	local ind = table.Count(dbt.chr) + 1
	dbt.chr[name] = chr

	chr.maxHealth = sanitized.maxHealth or chr.maxHealth or 100
	chr.maxStamina = sanitized.maxStamina or chr.maxStamina or 100
	chr.maxHungry = sanitized.maxHungry or chr.maxHungry or 100
	chr.maxThird = sanitized.maxThird or chr.maxThird or 100
	chr.maxSleep = sanitized.maxSleep or chr.maxSleep or 100
	chr.runSpeed = sanitized.runSpeed or chr.runSpeed or 100

	chr.fistsDamageString = sanitized.fistsDamageString or chr.fistsDamageString or 100
	chr.fistsDamage = sanitized.fistsDamage and table.Copy(sanitized.fistsDamage) or chr.fistsDamage or {min = 1, max = 20}

	chr.maxKG = sanitized.maxKG or chr.maxKG or 100
	chr.maxInventory = sanitized.maxInventory or chr.maxInventory or 20

	chr.food = sanitized.food or chr.food or 1
	chr.water = sanitized.water or chr.water or 1
	chr.sleep = sanitized.sleep or chr.sleep or 1

	chr.backup = chr.backup or {}
	chr.backup.maxHealth = chr.backup.maxHealth or chr.maxHealth
	chr.backup.maxStamina = chr.backup.maxStamina or chr.maxStamina
	chr.backup.maxHungry = chr.backup.maxHungry or chr.maxHungry
	chr.backup.maxThird = chr.backup.maxThird or chr.maxThird
	chr.backup.maxSleep = chr.backup.maxSleep or chr.maxSleep
	chr.backup.runSpeed = chr.backup.runSpeed or chr.runSpeed
	chr.backup.fistsDamageString = chr.backup.fistsDamageString or chr.fistsDamageString
	chr.backup.fistsDamage = chr.backup.fistsDamage or table.Copy(chr.fistsDamage)
	chr.backup.maxKG = chr.backup.maxKG or chr.maxKG
	chr.backup.maxInventory = chr.backup.maxInventory or chr.maxInventory
	chr.backup.food = chr.backup.food or chr.food
	chr.backup.water = chr.backup.water or chr.water
	chr.backup.sleep = chr.backup.sleep or chr.sleep

	chr.index = ind
	return chr
end
netstream.Hook("dbt.Sync.CHR", function(ply)
	netstream.Start(ply, "dbt.Sync.CHR", dbt.chr)
end)
 
netstream.Hook("dbt/characters/resetall", function(ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	local removeList = {}
	for name, character in pairs(dbt.chr) do
		if character and character.backup then
			character:Update(table.Copy(character.backup))
		end

		if isCustomKey(name) or (character and character.isCustom) then
			removeList[#removeList + 1] = name
		end
	end

	for _, name in ipairs(removeList) do
		dbt.chr[name] = nil
	end

	if sortCharacters then
		sortCharacters()
	end

	if istable(DBT_CHAR_SORTED) then
		for idx, charName in ipairs(DBT_CHAR_SORTED) do
			local character = dbt.chr[charName]
			if character then
				character.index = idx
			end
		end
	end

	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
end) 
netstream.Hook("dbt/characters/reset", function(ply, char)
	if not ply:IsAdmin() then return end
	if not dbt.chr[char] or not dbt.chr[char].backup then return end
	local character = dbt.chr[char]
	local backup = table.Copy(character.backup)
	if not backup.name then
		backup.name = char
	end
	character:Update(backup)
	character.backup.name = character.backup.name or char
	character.name = character.backup.name
	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
end)
netstream.Hook("dbt/characters/save", function(ply, tbl, char)
	if not ply:IsAdmin() then return end
	local character = dbt.chr[char]
	if not character or not istable(tbl) then return end

	local preservedBackup = character.backup and table.Copy(character.backup) or nil
	local sanitized = table.Copy(tbl)
	if sanitized then
		sanitized.backup = nil
		character:Update(sanitized)
	else
		character:Update({})
	end
	if preservedBackup then
		character.backup = preservedBackup
	end
	if character.backup and not character.backup.name then
		character.backup.name = char
	end
	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr) 
end) 
netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)

netstream.Hook("dbt/characters/createnew", function(ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	local template = dbt.chr["Макото Наэги"]
	local baseData = cloneCharacterData(template)
	baseData.name = "!Новый персонаж"
	baseData.isCustom = true

	local idName = table.Count(dbt.chr) + 1
	local entryKey = "customCharacter" .. tostring(idName)
	local character = dbt.CreateCharacter(entryKey, baseData)
	character.name = "!Новый персонаж"
	if character.backup then
		character.backup.name = "!Новый персонаж"
	end
	character.isCustom = true

	if sortCharacters then
		sortCharacters()
	end

	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
end) 

netstream.Hook("dbt/charcaters/load", function(ply, tbl)
	if not ply:IsAdmin() then return end
	for k, i in pairs(tbl) do
		if dbt.chr[k] then 
			dbt.chr[k]:Update(i)
		else 
			dbt.CreateCharacter(k, i)
		end
	end

	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
end) 