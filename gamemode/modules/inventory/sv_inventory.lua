dbt.inventory = dbt.inventory or {}

-- Spoilage helpers (no timers used)
local function SpoilEnabled()
	return GetGlobalBool("dbt_spoil_enabled", true)
end


local function IsEdible(itemData)
	return itemData and (itemData.food or itemData.water)
end

local function GetSpoilSeconds(itemData)
	-- Prefer explicit spoil_time if present, else reuse item.time for edible items; default 30 minutes
	if not itemData then return 0 end
	local minutes = itemData.spoil_time or 30
	return (minutes or 1) * 60
end

local function SendInventoryUpdate(ply)
	if not IsValid(ply) then return end
	netstream.Start(ply, "dbt/inventory/update", ply.items or {})
end

function dbt.inventory.SendUpdate(ply)
	SendInventoryUpdate(ply)
end

-- Convert an inventory entry to rotten (ID 40)
local function ConvertInventoryToRotten(ply, idx)
	if not ply.items or not ply.items[idx] then return false end
	local entry = ply.items[idx]
	local oldId = entry.id
	if oldId == 40 then return false end
	local oldData = dbt.inventory.items[oldId]
	if not IsEdible(oldData) then return false end
	-- adjust carry weight
	local oldKg = (oldData and oldData.kg) or 1
	local newData = dbt.inventory.items[40]
	local newKg = (newData and newData.kg) or 1
	entry.id = 40
	entry.meta = { spoiled = true, fromId = oldId, spoiledAt = CurTime() }
	if ply.info then
		ply.info.kg = math.max(0, (ply.info.kg or 0) - oldKg + newKg)
		ply:syncInformation()
	end
	return true
end

-- Check and spoil items for player lazily
local function CheckSpoilForPlayer(ply)
	if not SpoilEnabled() then return end
	if not IsValid(ply) then return end
	if not ply.items or #ply.items == 0 then return end
	local now = CurTime()
	local changed = false
	for i = 1, #ply.items do
		local entry = ply.items[i]
		local data = dbt.inventory.items[entry.id]
		if IsEdible(data) and entry.meta then
			local spoilAt = entry.meta.spoilAt
			if not spoilAt then
				-- Initialize if missing
				entry.meta.spoilAt = now + GetSpoilSeconds(data)
			elseif now >= spoilAt then
				if ConvertInventoryToRotten(ply, i) then changed = true end
			end
		end
	end
	if changed then
		SendInventoryUpdate(ply)
	end
end

-- New
netstream.Hook("dbt/inventory/equp/mono", function(ply, inventoryOwner, itemID)
	if not inventoryOwner.items then inventoryOwner.items = {} end
	if not inventoryOwner.info then inventoryOwner.info = {} end
	local playerInventory = inventoryOwner.items or {}
	local itemMeta = playerInventory[itemID]
	inventoryOwner:SetNWString("MonoOwner", itemMeta.meta.owner)
	local monopad = dbt.monopads.list[itemMeta.meta.id]
	monopad.nowowned = inventoryOwner
	inventoryOwner.info.monopad = playerInventory[itemID]

	dbt.inventory.removeitem(inventoryOwner, itemID, true)

	inventoryOwner.info.monopad = inventoryOwner.info.monopad or {}
	inventoryOwner.info.monopad.meta = inventoryOwner.info.monopad.meta or {}

	inventoryOwner:syncInformation()
end)


-- New
netstream.Hook("dbt/inventory/equp/key", function(ply, inventoryOwner, itemID)
	if not inventoryOwner.items then inventoryOwner.items = {} end
	if not inventoryOwner.info then inventoryOwner.info = {} end
	local playerInventory = inventoryOwner.items or {}
	local itemMeta = playerInventory[itemID]
	inventoryOwner:SetNWString("KeyOwner", itemMeta.meta.owner)

	inventoryOwner.info.keys = playerInventory[itemID]

	dbt.inventory.removeitem(inventoryOwner, itemID, true)

	inventoryOwner:syncInformation()
end)

netstream.Hook("dbt/inventory/use", function(inventoryOwner, itemID, data)
	local inv_player = inventoryOwner.items or {}
	local meta = inv_player[itemID].meta
	local itemTable = dbt.inventory.items[inv_player[itemID].id]

	if itemTable.OnUse then
		meta = itemTable.OnUse(inventoryOwner, itemTable, meta, data)
		inventoryOwner.items[itemID].meta = meta
		SendInventoryUpdate(inventoryOwner)
	end
	if itemTable.OnRemove and itemTable.OnRemove(inventoryOwner, itemTable, meta, data) then
		dbt.inventory.removeitem(inventoryOwner, itemID)
	elseif !itemTable.bNotDeleteOnUse then
		dbt.inventory.removeitem(inventoryOwner, itemID)
	end
	openobserve.Log({
		event = "item_use",
		name = inventoryOwner:Nick(),
		steamid = inventoryOwner:SteamID(),
		item = itemTable.name,
	})
end)

netstream.Hook("dbt/inventory/equp/weapon", function(ply, hotbarOwner, inventoryOwner, itemID, slotId)
	local inventoryOwner = inventoryOwner or ply
	local hotbarOwner = hotbarOwner or ply
	if not inventoryOwner.items then inventoryOwner.items = {} end
	if not hotbarOwner.info then hotbarOwner.info = {} end

	local playerInventory = inventoryOwner.items or {}
	local itemMeta = playerInventory[itemID]

	hotbarOwner.info.weapon = hotbarOwner.info.weapon or {}
	hotbarOwner.info.weapon[slotId] = playerInventory[itemID]

	hotbarOwner.spawned = true
	hotbarOwner:Give(dbt.inventory.items[itemMeta.id].weapon, true)
	hotbarOwner.spawned = false

	dbt.inventory.removeitem(inventoryOwner, itemID, true)

	hotbarOwner:syncInformation()

	openobserve.Log({
		event = "item_equip",
		name = hotbarOwner:Nick(),
		steamid = hotbarOwner:SteamID(),
		item = itemMeta.name,
	})
end)

netstream.Hook("dbt/inventory/remove/bug", function(ply, itemID)
	if not ply.items then ply.items = {} end
	local inv_player = ply.items or {}
	if inv_player[itemID] then
		ply.info.slots[inv_player[itemID].slot] = false
		ply.items[itemID] = nil
	end
	SendInventoryUpdate(ply)
end)


local meta = FindMetaTable("Player")

function meta:HasItem(id)
	local inv = self.items or {}

	for k, v in pairs( inv ) do
		if tonumber(v.id) == tonumber(id) then
			return tonumber(k)
		end
	end
	return false
end

function meta:RemoveEdvidice()
	local inv = self.items or {}

	for k, v in pairs( inv ) do
		if tonumber(v.id) == 1 then
			if v.meta.edv then
				v.meta.edv = {}
			end
		end
	end
	if self.info.monopad and self.info.monopad.meta.edv then
		self.info.monopad.meta.edv = {}
		self:syncInformation()
	end
end

function meta:InitializeInformation()
	self.info = { keys = {}, monopad = {}, use_slots = 0, slots = {}, kg = 0 }
	self:syncInformation()
end

function meta:syncInformation()
	self.info = self.info or { keys = {}, monopad = {}, use_slots = 0, slots = {}, kg = 0 }
	netstream.Start(self, "dbt/inventory/info", self.info)
end
concommand.Add("AddItemn__", function(ply, cmd, args)
	dbt.inventory.additem(ply, args[1], {owner = ply:Pers()})
end)

function dbt.inventory.removeitem(ply, itemIndex, bNoKG, returnEntry)
	if not IsValid(ply) then return nil end
	if not ply.items or not ply.items[itemIndex] then return nil end

	local entry = ply.items[itemIndex]
	local itemData = dbt.inventory.items[entry.id]

	if not bNoKG and ply.info then
		local itemWeight = (itemData and itemData.kg) or 1
		ply.info.kg = math.Clamp((ply.info.kg or 0) - itemWeight, 0, 10000)
		ply.info.kg = math.Round(ply.info.kg, 2)
	end

	if ply.info and ply.info.slots then
		ply.info.slots[entry.slot] = false
	end

	table.remove(ply.items, itemIndex)
	SendInventoryUpdate(ply)

	if ply.syncInformation then
		ply:syncInformation()
	end

	if returnEntry then
		return entry
	end
end


--ply.items
function dbt.inventory.additem(ply, id, meta, slot_ex, bNoKG)
	if not ply.items then ply.items = {} end
	ply.info = ply.info or { keys = {}, monopad = {}, use_slots = 0, slots = {}, kg = 0 }
	local inv_player = ply.items or {}
	local itemData = dbt.inventory.items[tonumber(id)]
	local characterInventory = dbt.chr[ply:Pers()].maxInventory or 10
	if #inv_player >= characterInventory then
		SendInventoryUpdate(ply)

		netstream.Start(ply, "dbt/inventory/error", "Недостаточно места в инвентаре!")
		return false
	end

	local chosenSlot
	if slot_ex ~= nil then
		local explicitSlot = tonumber(slot_ex)
		if explicitSlot then
			explicitSlot = math.floor(explicitSlot)
			if explicitSlot > 0 then
				if ply.info.slots and ply.info.slots[explicitSlot] then
					netstream.Start(ply, "dbt/inventory/error", "Слот уже занят.")
					SendInventoryUpdate(ply)
					return false
				end
				chosenSlot = explicitSlot
			end
		end
	end

	if not chosenSlot then
		local slot_it = 0
		repeat
			slot_it = slot_it + 1
		until not ply.info.slots[slot_it]
		chosenSlot = slot_it
	end

	-- set spoilAt for edible items if not present and spoilage is enabled
	local newMeta = meta or {}
	local itemCfg = dbt.inventory.items[tonumber(id)] or {}
	if SpoilEnabled() and IsEdible(itemCfg) and not newMeta.spoilAt then
		newMeta.spoilAt = CurTime() + GetSpoilSeconds(itemCfg)
	end

	inv_player[#ply.items + 1] = {
		id = tonumber(id),
		meta = newMeta,
		slot = chosenSlot,
	}

	if ply.info and ply.info.slots then
		ply.info.slots[chosenSlot] = true
	end
	if not bNoKG and ply.info then
		ply.info.kg = (ply.info.kg or 0) + (itemData.kg or 1)
	end
	ply.info.use_slots = (ply.info.use_slots or 0) + 1
	netstream.Start(ply, 'dbt/NewNotification', 2, {id})
	ply:syncInformation()
	ply.items = inv_player
	SendInventoryUpdate(ply)

	openobserve.Log({
		event = "item_add",
		name = ply:Nick(),
		steamid = ply:SteamID(),
		item = itemData.name,
	})

	return true
end

netstream.Hook("dbt/create/key", function(ply, grp, name)
	dbt.inventory.additem(ply, 2, {owner = grp, custom_name = name})
end)


hook.Add("PlayerSpawn", "dbt/inventory/info", function(ply)
	if ply:GetNWBool("ragdolled", false) then return end
	if ply.isSpectating then return end
	ply:syncInformation()
	ply.items = {}
	SendInventoryUpdate(ply)
end)--"dbt/inventory/slot/change"


netstream.Hook("dbt/inventory/slot/change", function(ply, inventoryOwner, item, newslot)
	local old = inventoryOwner.items[item].slot
	inventoryOwner.info.slots[old] = false
	inventoryOwner.items[item].slot = newslot
	inventoryOwner.info.slots[newslot] = true
	SendInventoryUpdate(inventoryOwner)
end)

netstream.Hook("dbt/inventory/slot/drop", function(ply, item)
	if not ply.items then ply.items = {} end
	local inv_player = ply.items or {}
	if (dbt.inventory.items[inv_player[item].id].monopad or dbt.inventory.items[inv_player[item].id].keys) and not IsGame() then
		netstream.Start(ply, "dbt/inventory/error", "Вещи можно выкидывать только во время игры!")
		return
	end

	local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
        filter = ply,
    })

	if inv_player[item].id == 25 then
	    itemEnt = ents.Create("shit")
	    itemEnt:SetPos(tr.HitPos)
	    itemEnt:SetAngles(Angle(180,0,0))
	    itemEnt:Spawn()
	elseif inv_player[item].id == 38 then
		itemEnt = ents.Create("diskcard_800")
	    itemEnt:SetPos(tr.HitPos)
	    itemEnt:SetAngles(Angle(0,0,0))
	    itemEnt:Spawn()

		itemEnt.DiskContent = {
			Author = inv_player[item].meta.Author,
			Message = inv_player[item].meta.Message,
			Size = inv_player[item].meta.Size,
			Password = inv_player[item].meta.Password,
		}

		itemEnt:SetNWString("DN", itemEnt.DiskContent["Author"])
	elseif inv_player[item].id == 39 then
		itemEnt = ents.Create("decoder")
	    itemEnt:SetPos(tr.HitPos)
	    itemEnt:SetAngles(Angle(0,0,0))
	    itemEnt:Spawn()
		itemEnt:SetNWBool("IsWorking", inv_player[item].meta.IsWorking)
		itemEnt:SetNWBool("CardInsert", inv_player[item].meta.CardInsert)
		itemEnt.DiskContent = inv_player[item].meta.DiskContent
	else

	    itemEnt = ents.Create("item")
	    itemEnt:SetPos(tr.HitPos)
	    itemEnt:SetAngles(Angle(0,0,0))
		-- preserve spoilAt meta when moving to world
		itemEnt:SetInfo(inv_player[item].id, inv_player[item].meta)
	    itemEnt:Spawn()
	    if dbt.inventory.items[inv_player[item].id].mdl then
	    	itemEnt:SetModel(dbt.inventory.items[inv_player[item].id].mdl)
	    	itemEnt:PhysicsInit( SOLID_VPHYSICS )
			itemEnt:SetMoveType( MOVETYPE_VPHYSICS )
			itemEnt:SetSolid( SOLID_VPHYSICS )
			local phys = itemEnt:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
			end
	    end
	    if dbt.inventory.items[inv_player[item].id].color then
			itemEnt:SetColor( dbt.inventory.items[inv_player[item].id].color )
			itemEnt:SetRenderMode( RENDERMODE_TRANSCOLOR )
	    end
		itemEnt:SetPos(tr.HitPos + itemEnt:OBBCenter())
	end
	openobserve.Log({
		event = "item_drop",
		name = ply:Nick(),
		steamid = ply:SteamID(),
		item = dbt.inventory.items[inv_player[item].id].name,
	})

    dbt.inventory.removeitem(ply, item)
end)

netstream.Hook("dbt/inventory/slot/mono_a", function(ply, inventoryOwner, slot)
	local inv_player = inventoryOwner.items

	if #inv_player >= 23 then
		SendInventoryUpdate(inventoryOwner)
		netstream.Start(inventoryOwner, "dbt/inventory/error", "Недостаточно места в инвентаре!")
		return
	end
	local id = inventoryOwner.info.monopad.meta.id
	local monopad = dbt.monopads.list[id]
	monopad.nowowned = nil

	dbt.inventory.additem(inventoryOwner, inventoryOwner.info.monopad.id, inventoryOwner.info.monopad.meta, slot, true)
	inventoryOwner.info.monopad = {}
	inventoryOwner:SetNWString("MonoOwner", "")
	SendInventoryUpdate(inventoryOwner)
	inventoryOwner:syncInformation()
end)

netstream.Hook("dbt/inventory/slot/keys_a", function(ply, inventoryOwner, slot)
	local inv_player = inventoryOwner.items

	if #inv_player >= 23 then
		SendInventoryUpdate(inventoryOwner)


		netstream.Start(inventoryOwner, "dbt/inventory/error", "Недостаточно места в инвентаре!")
		return
	end

	dbt.inventory.additem(inventoryOwner, inventoryOwner.info.keys.id, inventoryOwner.info.keys.meta, slot, true)
	inventoryOwner.info.keys = {}
	inventoryOwner:SetNWString("KeyOwner", "")
	SendInventoryUpdate(inventoryOwner)
	inventoryOwner:syncInformation()
end)

netstream.Hook("dbt/inventory/slot/weapon_a", function(ply, hotbarOwner, inventoryOwner, slot, idWeapon)
	dbt.inventory.additem(inventoryOwner, hotbarOwner.info.weapon[idWeapon].id, hotbarOwner.info.weapon[idWeapon].meta, slot, true)
	local idItem = hotbarOwner.info.weapon[idWeapon].id
	hotbarOwner:StripWeapon(dbt.inventory.items[idItem].weapon)
	hotbarOwner.info.weapon[idWeapon] = nil
	hotbarOwner:syncInformation()
end)

netstream.Hook("dbt/inventory/slot/drop_weapon", function(ply, hotbarOwner, inventoryOwner, idWeapon, a)
	local idItem = hotbarOwner.info.weapon[idWeapon].id
	hotbarOwner:StripWeapon(dbt.inventory.items[idItem].weapon)
	local item = hotbarOwner.info.weapon[idWeapon]
	local inv_player = inventoryOwner.items
	local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
        filter = ply,
    })

	itemEnt = ents.Create("item")
	itemEnt:SetPos(tr.HitPos)
	itemEnt:SetAngles(Angle(180,0,0))
	itemEnt:SetInfo(item.id, item.meta)
	itemEnt:Spawn()
	if dbt.inventory.items[item.id].mdl then
		itemEnt:SetModel(dbt.inventory.items[item.id].mdl)
		itemEnt:PhysicsInit( SOLID_VPHYSICS )
		itemEnt:SetMoveType( MOVETYPE_VPHYSICS )
		itemEnt:SetSolid( SOLID_VPHYSICS )
		local phys = itemEnt:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	end
	if dbt.inventory.items[item.id].color then
		itemEnt:SetColor( dbt.inventory.items[item.id].color )
		itemEnt:SetRenderMode( RENDERMODE_TRANSCOLOR )
	end

	hotbarOwner.info.weapon[idWeapon] = nil
	hotbarOwner:syncInformation()
end)

concommand.Add("giveall_items", function(ply, cmd, arg)
	if not ply:IsSuperAdmin() then return end

	for k,i in pairs(player.GetAll()) do
		dbt.inventory.additem(i, 1, {owner = i:Pers()})
		dbt.inventory.additem(i, 2, {owner = i:Pers()})
	end
end)

netstream.Hook("dbt/characters/admin/giveitem", function(ply, target, id)
	if not ply:IsAdmin() then return end

	dbt.inventory.additem(target, id, {owner = target:Pers()})
	target:syncInformation()
end)

function sddd(ply, id, meta)
	dbt.inventory.additem(ply, id, meta)
end

netstream.Hook("dbt/inventory/eat", function(ply, item, pos)
	-- Before any action, lazily check spoilage on player's inventory
	CheckSpoilForPlayer(ply)
	if not ply.items or not ply.items[item] then return end
	local itemq = dbt.inventory.items[ply.items[item].id]
	local itemmeta = ply.items[item].meta or {}
	if not itemq then return end
	if ply.items[item].id == 40 then
		netstream.Start(ply, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'Уведомление', titlecolor = Color(222, 193, 49), notiftext = 'Это нельзя употреблять.'})
		return
	end
	if itemq.medicine then
		local medclass = itemq.medicine
		if dbt.CanUseMedicaments(ply, medclass) then
			dbt.UseMedicaments(ply, medclass, pos)
		end
	end

	if itemq.food then
		if ply:GetNWBool("PoisonedMethanolUseFood") then
			netstream.Start(ply, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_heart.png', title = 'Уведомление', titlecolor = Color(215, 63, 65), notiftext = 'Вас тошнит от вида еды и напитков. Вы не можете это съесть.'})
			return false
		end
		if itemmeta["poisonedKCN"] == true then timer.Simple(0.2,function () PoisonKCNActivate(ply, itemmeta["poisonedby"]) end) end
		if itemmeta["poisonedMETHANOL"] == true then timer.Simple(0.2,function () PoisonMethanolActivate(ply, itemmeta["poisonedby"]) end) end
		ply:SetNWInt("hunger", ply:GetNWInt("hunger") + itemq.food)
		if ply:GetNWInt("hunger") >= 100 then ply:SetNWInt("hunger", 100) end

		openobserve.Log({
			event = "item_eat",
			name = ply:Nick(),
			steamid = ply:SteamID(),
			item = itemq.name,
			poisened = itemmeta["poisonedKCN"] or itemmeta["poisonedMETHANOL"],
		})
	end
	if itemq.water then
		if ply:GetNWBool("PoisonedMethanolUseFood") then
			netstream.Start(ply, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_heart.png', title = 'Уведомление', titlecolor = Color(215, 63, 65), notiftext = 'Вас тошнит от вида еды и напитков. Вы не можете это выпить.'})
			return false
		end
		if itemmeta["poisonedKCN"] == true then timer.Simple(0.2,function () PoisonKCNActivate(ply, itemmeta["poisonedby"]) end) end
		if itemmeta["poisonedMETHANOL"] == true then timer.Simple(0.2,function () PoisonMethanolActivate(ply, itemmeta["poisonedby"]) end) end
		if itemq.id == 13 and not timer.Exists("can'tcofee"..ply:Name()) then
			ply:SetNWInt("sleep", ply:GetNWInt("sleep") + 20)
			timer.Create("can'tcofee"..ply:Name(), 2400, 1, function()
			end)
		end

		ply:SetNWInt("water", ply:GetNWInt("water") + itemq.water)
		if ply:GetNWInt("water") >= 100 then ply:SetNWInt("water", 100) end

		openobserve.Log({
			event = "item_drink",
			name = ply:Nick(),
			steamid = ply:SteamID(),
			item = itemq.name,
			poisened = itemmeta["poisonedKCN"] or itemmeta["poisonedMETHANOL"],
		})
	end

	-- Remove only if item was actually edible/drinkable and processed
	if itemq.food or itemq.water or itemq.medicine then
		dbt.inventory.removeitem(ply, item)
	end
	SendInventoryUpdate(ply)
end)


-- Lazy global spoilage scanner (no timers). Runs in Think at low frequency.
hook.Add("Think", "dbt_inventory_spoil_scan", function()
	if not SpoilEnabled() then return end
	local now = CurTime()
	for _, ply in ipairs(player.GetAll()) do
		ply._nextSpoilCheck = ply._nextSpoilCheck or 0
		if ply._nextSpoilCheck <= now then
			CheckSpoilForPlayer(ply)
			-- Recheck every ~10 seconds to keep overhead tiny
			ply._nextSpoilCheck = now + 10
		end
	end
end)


hook.Add( "PlayerCanPickupWeapon", "dbt.Pickup", function( ply, weapon )
    if ply.spawned then return true end
    local useBind = ply:KeyDown(IN_USE)
    local weaponClass = weapon:GetClass()
    ply.cdPick = ply.cdPick or CurTime()
    if ply.cdPick > CurTime() then return false end
    if dbt.inventory.weaponsId[weaponClass] and useBind  then
    	local idItem = dbt.inventory.weaponsId[weaponClass]

    	dbt.inventory.additem(ply, idItem)
    	weapon:Remove()
    	ply.cdPick = CurTime() + 0.1
    	return false
    end
    return useBind --useBind and (ply.cdPick < CurTime())
end )

hook.Add( "PlayerGiveSWEP", "BlockPlayerSWEPs", function( ply, class, spawninfo )
	if dbt.inventory.weaponsId[class] then
		local idItem = dbt.inventory.weaponsId[class]
    	dbt.inventory.additem(ply, idItem)
		return false
	end
end )

-- Storage system ----------------------------------------------------------

dbt.inventory.storage = dbt.inventory.storage or {}

local function StorageGet(ref)
	if not ref then return nil end
	if istable(ref) and ref.__isStorage then return ref end
	if isstring(ref) then return dbt.inventory.storage[ref] end
	if IsEntity(ref) and ref.dbtStorageId then
		return dbt.inventory.storage[ref.dbtStorageId]
	end
	return nil
end

local function StorageApplySpoilModifier(storage, entry, now, itemData)
	if not SpoilEnabled() then
		if entry.meta then entry.meta._storageLast = nil end
		return
	end

	itemData = itemData or dbt.inventory.items[entry.id]
	if not IsEdible(itemData) then
		if entry.meta then entry.meta._storageLast = nil end
		return
	end

	entry.meta = entry.meta or {}
	now = now or CurTime()

	if not entry.meta.spoilAt then
		entry.meta.spoilAt = now + GetSpoilSeconds(itemData)
	end

	if (storage.spoilTimeMultiplier or 1) > 1 then
		entry.meta._storageLast = now
	else
		entry.meta._storageLast = nil
	end
end

local function ConvertStorageEntryToRotten(storage, idx, now)
	local entry = storage.items[idx]
	if not entry then return false end

	local oldId = entry.id
	if oldId == 40 then return false end

	local oldData = dbt.inventory.items[oldId]
	if not IsEdible(oldData) then return false end

	local oldKg = (oldData and oldData.kg) or 1
	local rottenData = dbt.inventory.items[40]
	local rottenKg = (rottenData and rottenData.kg) or 1

	entry.id = 40
	entry.meta = { spoiled = true, fromId = oldId, spoiledAt = now or CurTime() }

	storage.weight = math.max(0, (storage.weight or 0) - oldKg + rottenKg)

	return true
end

local function StorageRecalculate(storage)
	storage.weight = 0
	storage.slots = {}

	local now = CurTime()

	for idx, entry in ipairs(storage.items) do
		if not entry.slot then
			entry.slot = idx
		end
		storage.slots[entry.slot] = true
		local data = dbt.inventory.items[entry.id]
		storage.weight = storage.weight + ((data and data.kg) or 1)
		StorageApplySpoilModifier(storage, entry, now, data)
	end
end

local function StorageCheckSpoilage(storage, now)
	if not SpoilEnabled() then return end
	if not storage or not storage.items then return end

	now = now or CurTime()
	local multiplier = storage.spoilTimeMultiplier or 1
	local converted = false

	for idx = #storage.items, 1, -1 do
		local entry = storage.items[idx]
		local data = dbt.inventory.items[entry.id]

		if IsEdible(data) then
			entry.meta = entry.meta or {}
			if not entry.meta.spoilAt then
				entry.meta.spoilAt = now + GetSpoilSeconds(data)
			end

			if multiplier > 1 then
				local last = entry.meta._storageLast or now
				if last < now then
					local elapsed = now - last
					entry.meta.spoilAt = entry.meta.spoilAt + elapsed * (multiplier - 1)
				end
				entry.meta._storageLast = now
			else
				entry.meta._storageLast = nil
			end

			if entry.meta.spoilAt and now >= entry.meta.spoilAt then
				if ConvertStorageEntryToRotten(storage, idx, now) then
					converted = true
				end
			end
		else
			if entry.meta then
				entry.meta._storageLast = nil
			end
		end
	end

	if converted then
		StorageSendUpdate(storage)
	end
end

local function StorageFindFreeSlot(storage)
	local limit = storage.maxSlots or (#storage.items + 1)
	if limit <= 0 then return nil end
	for i = 1, limit do
		if not storage.slots[i] then
			return i
		end
	end
	return nil
end

local function StorageSendUpdate(storage)
	local occupant = storage.occupant
	if not IsValid(occupant) then return end

	netstream.Start(occupant, "dbt/inventory/storage/update", {
		id = storage.id or "",
		weight = storage.weight or 0,
		items = storage.items or {},
	})
end

local function StorageSendOpen(storage, ply)
	netstream.Start(ply, "dbt/inventory/storage/open", {
		id = storage.id or "",
		ent = (IsValid(storage.entity) and storage.entity or NULL),
		name = storage.name or "",
		maxSlots = math.Clamp(math.floor(storage.maxSlots or 0), 0, 4095),
		weight = storage.weight or 0,
		maxWeight = storage.maxWeight,
		items = storage.items or {},
		autoCloseDistance = storage.autoCloseDistance,
	})
end

function dbt.inventory.storage.Attach(ent, config)
	if not IsValid(ent) then return nil end

	config = config or {}
	local id = config.id or ("storage_" .. ent:EntIndex())
	local storage = dbt.inventory.storage[id]

	if storage and storage.occupant then
		dbt.inventory.storage.Close(storage, { forced = true })
	end

	if not storage then
		storage = {
			id = id,
			items = {},
			slots = {},
			weight = 0,
		}
	end

	storage.__isStorage = true
	storage.entity = ent
	storage.name = config.name or storage.name or "Хранилище"
	storage.maxSlots = tonumber(config.maxSlots or config.slots or storage.maxSlots) or 25
	storage.maxSlots = math.max(math.floor(storage.maxSlots), 1)
	if config.maxWeight ~= nil then
		storage.maxWeight = tonumber(config.maxWeight)
		if storage.maxWeight and storage.maxWeight <= 0 then
			storage.maxWeight = nil
		end
	end

	if config.autoCloseDistance ~= nil then
		storage.autoCloseDistance = math.max(tonumber(config.autoCloseDistance) or 0, 0)
	else
		storage.autoCloseDistance = storage.autoCloseDistance or 0
	end
	storage.autoCloseDistSqr = (storage.autoCloseDistance > 0) and (storage.autoCloseDistance * storage.autoCloseDistance) or nil

	if config.spoilSlowdown ~= nil then
		storage.spoilSlowdown = config.spoilSlowdown and true or false
	else
		storage.spoilSlowdown = storage.spoilSlowdown or false
	end
	storage.spoilTimeMultiplier = storage.spoilSlowdown and 2 or 1

	storage.lastInteract = storage.lastInteract or 0
	storage.openOnUse = config.openOnUse ~= false
	storage.items = storage.items or {}

	StorageRecalculate(storage)

	dbt.inventory.storage[id] = storage
	ent.dbtStorageId = id
	ent:SetNWString("dbt_storage_name", storage.name)
	ent:SetNWString("dbt_storage_id", id)
	ent:SetNWEntity("dbt_storage_user", storage.occupant or NULL)
	ent:SetNWBool("dbt_storage_spoilslow", storage.spoilSlowdown)

	return storage
end

function dbt.inventory.storage.Detach(ref)
	local storage = StorageGet(ref)
	if not storage then return end

	if storage.occupant then
		dbt.inventory.storage.Close(storage, { forced = true })
	end

	if IsValid(storage.entity) then
	storage.entity.dbtStorageId = nil
	storage.entity:SetNWString("dbt_storage_id", false)
	storage.entity:SetNWEntity("dbt_storage_user", NULL)
	storage.entity:SetNWBool("dbt_storage_spoilslow", false)
	end

	dbt.inventory.storage[storage.id] = nil
end

function dbt.inventory.storage.Get(ref)
	return StorageGet(ref)
end

function dbt.inventory.storage.AddItem(ref, id, meta, slot)
	local storage = StorageGet(ref)
	if not storage then return false, "invalid_storage" end

	local itemId = tonumber(id)
	local itemData = dbt.inventory.items[itemId]
	if not itemData then return false, "invalid_item" end

	local chosenSlot
	if slot ~= nil then
		chosenSlot = tonumber(slot)
		if not chosenSlot then return false, "invalid_slot" end
		chosenSlot = math.floor(chosenSlot)
		if chosenSlot <= 0 then return false, "invalid_slot" end

		local limit = storage.maxSlots or (#storage.items)
		if limit > 0 and chosenSlot > limit then
			return false, "invalid_slot"
		end

		if storage.slots[chosenSlot] then
			return false, "occupied"
		end
	else
		chosenSlot = StorageFindFreeSlot(storage)
		if not chosenSlot then
			return false, "no_slots"
		end
	end

	local kg = itemData.kg or 1
	local currentWeight = storage.weight or 0
	if storage.maxWeight and (currentWeight + kg) > storage.maxWeight then
		return false, "no_weight"
	end

	local entry = {
		id = itemId,
		meta = meta and table.Copy(meta) or {},
		slot = chosenSlot,
	}

	storage.items[#storage.items + 1] = entry
	storage.slots[chosenSlot] = true
	storage.weight = currentWeight + kg
	StorageApplySpoilModifier(storage, entry, CurTime(), itemData)

	storage.lastInteract = CurTime()
	StorageSendUpdate(storage)
	return true, entry
end

function dbt.inventory.storage.RemoveItem(ref, index)
	local storage = StorageGet(ref)
	if not storage then return false, "invalid_storage" end

	local entry = storage.items[index]
	if not entry then return false, "invalid_index" end
	if entry.meta then
		entry.meta._storageLast = nil
	end

	table.remove(storage.items, index)
	if entry.slot then
		storage.slots[entry.slot] = nil
	end

	local data = dbt.inventory.items[entry.id]
	local kg = (data and data.kg) or 1
	storage.weight = math.max(0, (storage.weight or 0) - kg)

	storage.lastInteract = CurTime()
	StorageSendUpdate(storage)
	return true, entry
end

function dbt.inventory.storage.MoveItem(ref, index, newSlot)
	local storage = StorageGet(ref)
	if not storage then return false, "invalid_storage" end

	local fromIndex = tonumber(index)
	local targetSlot = tonumber(newSlot)
	if not fromIndex or not targetSlot then
		return false, "invalid_params"
	end

	local entry = storage.items[fromIndex]
	if not entry then return false, "invalid_index" end

	targetSlot = math.floor(targetSlot)
	if targetSlot < 1 then return false, "invalid_slot" end

	local maxSlots = storage.maxSlots or (#storage.items)
	if maxSlots > 0 and targetSlot > maxSlots then
		return false, "invalid_slot"
	end

	if entry.slot == targetSlot then
		return true, entry
	end

	if storage.slots[targetSlot] then
		return false, "occupied"
	end

	if entry.slot then
		storage.slots[entry.slot] = nil
	end

	entry.slot = targetSlot
	storage.slots[targetSlot] = true
	storage.lastInteract = CurTime()

	StorageSendUpdate(storage)
	return true, entry
end

function dbt.inventory.storage.Clear(ref)
	local storage = StorageGet(ref)
	if not storage then return false end

	storage.items = {}
	storage.slots = {}
	StorageRecalculate(storage)
	storage.lastInteract = CurTime()
	StorageSendUpdate(storage)
	return true
end

function dbt.inventory.storage.Open(ply, ref)
	if not IsValid(ply) then return false, "invalid_player" end
	local storage = StorageGet(ref)
	if not storage then return false, "invalid_storage" end

	if storage.occupant and IsValid(storage.occupant) and storage.occupant ~= ply then
		return false, "occupied"
	end

	storage.occupant = ply
	ply.dbtActiveStorage = storage.id
	storage.lastInteract = CurTime()

	if IsValid(storage.entity) then
	storage.entity:SetNWEntity("dbt_storage_user", ply)
	end

	if SpoilEnabled() then
		StorageCheckSpoilage(storage)
	end

	StorageSendOpen(storage, ply)
	return true
end

function dbt.inventory.storage.Close(ref, opts)
	local storage = StorageGet(ref)
	if not storage then return end

	opts = opts or {}
	local occupant = storage.occupant
	if not IsValid(occupant) then
		storage.occupant = nil
		if IsValid(storage.entity) then
		storage.entity:SetNWEntity("dbt_storage_user", NULL)
		end
		return
	end

	if opts.ply and occupant ~= opts.ply then return end

	storage.occupant = nil
	occupant.dbtActiveStorage = nil

	if IsValid(storage.entity) then
	storage.entity:SetNWEntity("dbt_storage_user", NULL)
	end

	if not opts.skipNotify then
		netstream.Start(occupant, "dbt/inventory/storage/close", {
			id = storage.id or "",
			forced = opts.forced or false,
		})
	end
end


netstream.Hook("dbt/inventory/storage/deposit", function(ply, storageId, playerIndex, targetSlot)
	if not IsValid(ply) then return end
	local storage = StorageGet(storageId)
	if not storage or storage.occupant ~= ply then return end

	local itemIndex = tonumber(playerIndex)
	if not itemIndex then return end

	local desiredSlot = tonumber(targetSlot)

	local removed = dbt.inventory.removeitem(ply, itemIndex, nil, true)
	if not removed then return end

	local success, reason = dbt.inventory.storage.AddItem(storage, removed.id, removed.meta, desiredSlot)
	if not success then
		dbt.inventory.additem(ply, removed.id, removed.meta, removed.slot)

		if reason == "no_slots" then
			netstream.Start(ply, "dbt/inventory/error", "В хранилище нет свободных слотов.")
		elseif reason == "no_weight" then
			netstream.Start(ply, "dbt/inventory/error", "Хранилище переполнено по весу.")
		elseif reason == "occupied" then
			netstream.Start(ply, "dbt/inventory/error", "Слот уже занят.")
		elseif reason == "invalid_slot" then
			netstream.Start(ply, "dbt/inventory/error", "Недопустимый слот.")
		else
			netstream.Start(ply, "dbt/inventory/error", "Не удалось переместить предмет в хранилище.")
		end
	end
end)

netstream.Hook("dbt/inventory/storage/withdraw", function(ply, storageId, storageIndex, targetSlot)
	if not IsValid(ply) then return end
	local storage = StorageGet(storageId)
	if not storage or storage.occupant ~= ply then return end

	local index = tonumber(storageIndex)
	if not index then return end

	local entry = storage.items[index]
	if not entry then return end
	if entry.meta and entry.meta._storageLast then
		entry.meta._storageLast = nil
	end

	local metaCopy = entry.meta and table.Copy(entry.meta) or nil
	local desiredSlot = tonumber(targetSlot)
	local success = dbt.inventory.additem(ply, entry.id, metaCopy, desiredSlot)
	if not success then
		netstream.Start(ply, "dbt/inventory/error", "Слот занят или нет места в инвентаре.")
		return
	end

	dbt.inventory.storage.RemoveItem(storage, index)
end)

netstream.Hook("dbt/inventory/storage/move", function(ply, storageId, storageIndex, targetSlot)
	if not IsValid(ply) then return end
	local storage = StorageGet(storageId)
	if not storage or storage.occupant ~= ply then return end

	local index = tonumber(storageIndex)
	local slot = tonumber(targetSlot)
	if not index or not slot then return end

	local success, reason = dbt.inventory.storage.MoveItem(storage, index, slot)
	if success then return end

	if reason == "occupied" then
		netstream.Start(ply, "dbt/inventory/error", "Слот уже занят.")
	elseif reason == "invalid_slot" then
		netstream.Start(ply, "dbt/inventory/error", "Недопустимый слот.")
	elseif reason == "invalid_index" then
		netstream.Start(ply, "dbt/inventory/error", "Предмет не найден.")
	else
		netstream.Start(ply, "dbt/inventory/error", "Не удалось переместить предмет внутри хранилища.")
	end
end)

netstream.Hook("dbt/inventory/storage/close", function(ply, storageId)
	if not IsValid(ply) then return end
	local storage = StorageGet(storageId)
	if not storage then return end

	if storage.occupant ~= ply then
		if not IsValid(storage.occupant) then
			dbt.inventory.storage.Close(storage, { forced = true })
		end
		return
	end

	dbt.inventory.storage.Close(storage, { ply = ply, skipNotify = true })
end)

local function ReleasePlayerStorage(ply, forced)
	if not ply.dbtActiveStorage then return end
	dbt.inventory.storage.Close(ply.dbtActiveStorage, { forced = forced })
	ply.dbtActiveStorage = nil
end

hook.Add("PlayerDisconnected", "dbt_inventory_storage_release", function(ply)
	ReleasePlayerStorage(ply, true)
end)

hook.Add("PlayerDeath", "dbt_inventory_storage_death", function(ply)
	ReleasePlayerStorage(ply, true)
end)

hook.Add("EntityRemoved", "dbt_inventory_storage_removed", function(ent)
	if not IsValid(ent) or not ent.dbtStorageId then return end
	local storage = dbt.inventory.storage[ent.dbtStorageId]
	if not storage then return end
	dbt.inventory.storage.Close(storage, { forced = true })
	dbt.inventory.storage[storage.id] = nil
end)

do
	local nextScan = 0
	hook.Add("Think", "dbt_inventory_storage_maintenance", function()
		local now = CurTime()
		if nextScan > now then return end
		nextScan = now + 0.5

		for _, storage in pairs(dbt.inventory.storage) do
			if istable(storage) and storage.__isStorage then
				if SpoilEnabled() then
					StorageCheckSpoilage(storage, now)
				end

				local occupant = storage.occupant
				if IsValid(occupant) then
					local ent = storage.entity
					if storage.autoCloseDistSqr and IsValid(ent) and ent:GetPos():DistToSqr(occupant:GetPos()) > storage.autoCloseDistSqr then
						dbt.inventory.storage.Close(storage, { forced = true })
					end
				elseif occupant ~= nil then
					dbt.inventory.storage.Close(storage, { forced = true })
				end
			end
		end
	end)
end
