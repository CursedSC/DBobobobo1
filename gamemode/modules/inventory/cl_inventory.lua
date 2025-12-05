dbt.inventory = dbt.inventory or {}
dbt.inventory.player = dbt.inventory.player or {}
dbt.inventory.info = dbt.inventory.info or {}
local clientInventory = clientInventory or {}
dbt.inventory.storageActive = dbt.inventory.storageActive or nil
dbt.inventory.storageSlots = dbt.inventory.storageSlots or {}
dbt.inventory.storageItemPanels = dbt.inventory.storageItemPanels or {}
dbt.inventory._skipStorageClose = false

netstream.Hook("dbt/inventory/update", function(items)
	dbt.inventory.player = istable(items) and items or {}
	if IsValid(dbt.inventory.Frame) then
		dbt.inventory.RebuildPlayer()
	end
end)

netstream.Hook("dbt/inventory/storage/open", function(data)
	if not istable(data) then return end
	local items = data.items or {}
	local storageEnt = data.ent
	dbt.inventory.storageActive = {
		id = data.id or "",
		ent = IsValid(storageEnt) and storageEnt or nil,
		name = (data.name and data.name ~= "" and data.name) or "Хранилище",
		maxSlots = (tonumber(data.maxSlots) or #items),
		weight = tonumber(data.weight) or 0,
		maxWeight = tonumber(data.maxWeight) or nil,
		autoCloseDistance = tonumber(data.autoCloseDistance) or 0,
		items = items,
	}
	if dbt.inventory.storageActive.maxSlots <= 0 then
		dbt.inventory.storageActive.maxSlots = math.max(#items, 1)
	end

	if IsValid(dbt.inventory.Frame) then
		dbt.inventory._skipStorageClose = true
		dbt.inventory.Frame:Close()
	end

	timer.Simple(0, function()
		if dbt.inventory.storageActive then
			dbt.inventory.New()
		end
	end)
end)

netstream.Hook("dbt/inventory/storage/update", function(data)
	if not istable(data) then return end
	local storage = dbt.inventory.storageActive
	if not storage or storage.id ~= data.id then return end

	storage.items = data.items or {}
	storage.weight = tonumber(data.weight) or 0

	if IsValid(dbt.inventory.Frame) then
		dbt.inventory.RebuildStorage()
	end
end)

netstream.Hook("dbt/inventory/storage/close", function(data)
	if not istable(data) then return end
	local storage = dbt.inventory.storageActive
	if not storage or storage.id ~= data.id then return end

	dbt.inventory.storageActive = nil

	if IsValid(dbt.inventory.Frame) then
		dbt.inventory._skipStorageClose = true
		dbt.inventory.Frame:Close()
		if not data.forced then
			timer.Simple(0, function()
				if not IsValid(dbt.inventory.Frame) then
					dbt.inventory.New()
				end
			end)
		end
	end
end)

netstream.Hook("dbt/inventory/error", function(error)
	chat.AddText( Color( 116, 40, 151 ), "[DBT] ", Color( 255, 255, 255 ), error)
	if IsValid(dbt.inventory.Frame) then
		dbt.inventory.Rebuild()
	end
end)

netstream.Hook("dbt/inventory/world_consume/start", function(payload)
	if not istable(payload) then return end
	local ent = payload.ent
	if not IsValid(ent) then return end
	local seconds = math.max(tonumber(payload.seconds) or 1, 0.1)
	local label = payload.label or "Употребление..."
	if IsValid(LocalPlayer()) then
		LocalPlayer():EmitSound("inv_use.mp3")
	end
	dbt.ShowTimerTarget(seconds, label, ent, function()
		if IsValid(LocalPlayer()) then
			LocalPlayer():StopSound("inv_use.mp3")
		end
		netstream.Start("dbt/inventory/world_consume/finish", ent)
	end, function()
		if IsValid(LocalPlayer()) then
			LocalPlayer():StopSound("inv_use.mp3")
		end
		netstream.Start("dbt/inventory/world_consume/cancel", ent)
	end)
end)

netstream.Hook("dbt/inventory/info", function(info)
	local normalized = istable(info) and table.Copy(info) or {}
	normalized.monopad = normalized.monopad or {}
	normalized.keys = normalized.keys or {}
	normalized.weapon = normalized.weapon or {}
	normalized.slots = normalized.slots or {}
	normalized.kg = normalized.kg or 0
	dbt.inventory.info = normalized
end)

local meta = FindMetaTable("Player")
function l_HasItem(id)
	local inv = dbt.inventory.player

	for k, v in pairs( inv ) do
		if tonumber(v.id) == tonumber(id) then
			return k
		end
	end
	return false
end

function meta:HasMonopad()
	if dbt.inventory.info.monopad and dbt.inventory.info.monopad.meta then
		return true
	else
		return false
	end
end

function meta:GetMonopadOwner()
	if dbt.inventory.info.monopad and dbt.inventory.info.monopad.meta and dbt.inventory.info.monopad.meta.owner then
		return dbt.inventory.info.monopad.meta.owner
	else
		return false
	end
end


local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()

local function weight_source(x)
    return ScreenWidth / 1920  * x
end

local function hight_source(x)
    return ScreenHeight / 1080  * x
end

local function Alpha(pr)
    return (255 / 100) * pr
end

local mat = Material("bg_new.jpg")
local paralax = Material("paralax.png")
local d_mat = Material("d_mat.png")
local LineItem = Material("LineItem.png")
local color_1 = Color(50,51,50, Alpha(21))

local list_ItemPods = {}
local storage_ItemPods = {}
local listDItems = {}
local storageDItems = {}

local storageEscWasDown = false

hook.Add("Think", "dbt.inventory.StorageEscClose", function()
	local frame = dbt.inventory and dbt.inventory.Frame
	if not IsValid(frame) then
		storageEscWasDown = false
		return
	end

	local storageCtx = dbt.inventory.storageActive
	if not storageCtx then
		storageEscWasDown = false
		return
	end

	local isDown = input.IsKeyDown(KEY_ESCAPE)
	if isDown and not storageEscWasDown then
		frame:Close()
		gui.HideGameUI()
	end
	storageEscWasDown = isDown
end)

local function copyTokenList(src)
	if not istable(src) then return {} end
	local out = {}
	for i = 1, #src do
		out[i] = src[i]
	end
	return out
end

local function formatSpoilDuration(seconds)
	seconds = math.floor(seconds or 0)
	if seconds <= 0 then return nil end

	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	local hours = math.floor(minutes / 60)
	minutes = minutes % 60
	local days = math.floor(hours / 24)
	hours = hours % 24

	local parts = {}
	if days > 0 then parts[#parts + 1] = days .. " д" end
	if hours > 0 then parts[#parts + 1] = hours .. " ч" end
	if minutes > 0 then parts[#parts + 1] = minutes .. " м" end
	if #parts == 0 then
		parts[#parts + 1] = secs .. " с"
	elseif secs > 0 and #parts < 2 then
		parts[#parts + 1] = secs .. " с"
	end

	return table.concat(parts, " ")
end

local function getBaseSpoilSeconds(itemData)
	if not itemData then return nil end
	local minutes = tonumber(itemData.spoil_time)
	if not minutes then
		minutes = tonumber(itemData.time)
	end
	if not minutes or minutes <= 0 then return nil end
	return minutes * 60
end

local function appendSpoilInfo(descTokens, meta, itemData)
	if not istable(descTokens) then return end
	if not itemData then return end

	local isSpoilable = itemData.spoil_time or itemData.time or itemData.food or itemData.water
	if not isSpoilable and not (meta and (meta.spoiled or meta.spoilAt)) then return end

	meta = meta or {}
	local spoilAt = meta.spoilAt
	local now = CurTime()
	local remaining = spoilAt and (spoilAt - now) or nil
	local spoiled = meta.spoiled or (remaining and remaining <= 0)
	local baseSeconds = getBaseSpoilSeconds(itemData)

	descTokens[#descTokens + 1] = true
	descTokens[#descTokens + 1] = Color(175, 175, 175, 150)
	descTokens[#descTokens + 1] = "• Время до порчи: "

	if spoiled then
		descTokens[#descTokens + 1] = Color(215, 63, 65)
		descTokens[#descTokens + 1] = "испорчено"
	elseif remaining then
		local formatted = formatSpoilDuration(remaining)
		if formatted then
			descTokens[#descTokens + 1] = Color(175, 19, 186, 255)
			descTokens[#descTokens + 1] = formatted
		else
			descTokens[#descTokens + 1] = Color(175, 19, 186, 255)
			descTokens[#descTokens + 1] = "скоро"
		end
	elseif baseSeconds then
		local formatted = formatSpoilDuration(baseSeconds)
		if formatted then
			descTokens[#descTokens + 1] = Color(175, 19, 186, 255)
			descTokens[#descTokens + 1] = formatted
		else
			descTokens[#descTokens + 1] = Color(175, 175, 175, 150)
			descTokens[#descTokens + 1] = "нет данных"
		end
	else
		descTokens[#descTokens + 1] = Color(175, 175, 175, 150)
		descTokens[#descTokens + 1] = "нет данных"
	end
end

local function appendCostInfo(descTokens, itemData)
	if not istable(descTokens) then return end
	if not itemData then return end
	local cost = tonumber(itemData.cost)
	if not cost then return end

	descTokens[#descTokens + 1] = true
	descTokens[#descTokens + 1] = Color(175, 175, 175, 150)
	descTokens[#descTokens + 1] = "• Стоимость: "
	descTokens[#descTokens + 1] = Color(222, 193, 49)
	descTokens[#descTokens + 1] = cost
end

local function clearPanelList(panelList)
	for _, pnl in ipairs(panelList) do
		if IsValid(pnl) then
			pnl:Remove()
		end
	end
end

local function resetSlotPanels(slotTable)
	for _, slotPanel in pairs(slotTable) do
		if IsValid(slotPanel) then
			slotPanel.IsEmpty = true
			for _, child in ipairs(slotPanel:GetChildren()) do
				if IsValid(child) then
					child:Remove()
				end
			end
		end
	end
end

function ShowItemData(dp, id, idInv)
	if dbt.inventory.storageActive then return end
	if not IsValid(inv_IconPanel) then return end
	local data = dbt.inventory.items[id]
	inv_ShowData = true
	local name = dp.meta and dp.meta.custom_name or data.name
	inv_Name = name
	inv_Mass = data.kg or 1
	inv_Desc = dp.GetDescription and dp:GetDescription() or {color_white, "???"}

	local baseAlt
	if data.food then
		baseAlt = data.descalt or {Color(175, 175, 175, 150), "Использование: ", true, "• Можно съесть."}
	elseif data.poison then
		baseAlt = data.descalt or {Color(175, 175, 175, 150), "Использование: ", true, "• Можно выпить.", true, "• Можно отравить еду."}
	elseif data.water then
		baseAlt = data.descalt or {Color(175, 175, 175, 150), "Использование: ", true, "• Можно выпить."}
	elseif data.medicine then
		baseAlt = data.descalt or {Color(175, 175, 175, 150), "Использование: ", true, "• Можно применить для лечения."}
	else
		baseAlt = data.descalt or {Color(175, 175, 175, 150), "Использование: ", true, "• Неизвестно."}
	end
	inv_DescALt = data.descalt and copyTokenList(baseAlt) or baseAlt
	appendSpoilInfo(inv_DescALt, dp.meta, data)
		appendCostInfo(inv_DescALt, data)



	inv_IconPanel:SetModel(data.mdl)
	local mn, mx = inv_IconPanel.Entity:GetRenderBounds()
	local size = 0
	size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
	size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
	size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

	inv_IconPanel:SetFOV( 45 )
	inv_IconPanel:SetCamPos( Vector( size, size, size ) )
	inv_IconPanel:SetLookAt( (mn + mx) * 0.5 )

end


local InventoryItems = {}

InventoryItems[1] = {
	id = 25,
	slot = 3,
	meta = {}
}

local inventoryMonopad = Material("dbt/inventory/inventoryMonopad.png", "smooth mips")
local inventoryKey = Material("dbt/inventory/inventoryKey.png", "smooth mips")
local inventoryHand = Material("dbt/inventory/inventoryHand.png", "smooth mips")

local tabmenuInventory = Material("dbt/inventory/tabmenuInventory1.png")
local tabmenuScoreboard = Material("dbt/inventory/tabmenuScoreboard1.png")

function dbt.inventory.RebuildPlayer()
	if not IsValid(dbt.inventory.Frame) then return end
	clearPanelList(listDItems)
	listDItems = {}
	resetSlotPanels(list_ItemPods)
	for k, entry in ipairs(dbt.inventory.player or {}) do
		local owner = dbt.inventory.currentOwner or LocalPlayer()
		dbt.inventory.AddItem(entry.id, entry.slot, k, entry.meta, owner, k)
	end
end

function dbt.inventory.RebuildStorage()
	if not IsValid(dbt.inventory.Frame) then return end
	local storage = dbt.inventory.storageActive
	if not storage then return end
	clearPanelList(storageDItems)
	storageDItems = {}
	dbt.inventory.storageItemPanels = storageDItems
	resetSlotPanels(storage_ItemPods)
	for index, entry in ipairs(storage.items or {}) do
		local slot = entry.slot or index
		local container = storage_ItemPods[slot]
		if IsValid(container) then
			local itemPanel = vgui.Create("DItem", container)
			itemPanel:SetSize(weight_source(123), weight_source(123))
			itemPanel:FromItem(entry.id)
			itemPanel.idInv = index
			itemPanel.meta = entry.meta
			itemPanel.Owner = nil
			itemPanel.IsStorageItem = true
			itemPanel.storageSlot = slot
			itemPanel.storageIndex = index
			itemPanel.storageItemId = entry.id
			itemPanel:Droppable("Item")
			itemPanel:Droppable("storage_item")
			itemPanel.DoRightClick = function() end
			itemPanel.DoClick = function() end
			container.IsEmpty = false
			storageDItems[#storageDItems + 1] = itemPanel
		end
	end
end

function dbt.inventory.Rebuild()
	dbt.inventory.RebuildPlayer()
	if dbt.inventory.storageActive then
		dbt.inventory.RebuildStorage()
	end
end

function dbt.inventory.AddItem(id, slot, idInv, linkmeta, own, kkk)
	if not list_ItemPods[slot] then return end
	local ItemPod = vgui.Create( "DItem", list_ItemPods[slot])
	ItemPod:SetSize( weight_source(123), weight_source(123) )
	ItemPod.kkk = kkk
	ItemPod:FromItem(id)
	ItemPod.idInv = idInv
	ItemPod.meta = linkmeta
	ItemPod.Owner = own
	ItemPod.IsStorageItem = false
	ItemPod.storageIndex = nil
	ItemPod.storageSlot = nil
	local data = dbt.inventory.items[id]
		if data then 
		if data.OverPaint then  ItemPod.OverPaint = data.OverPaint end
		if data.GetDescription then ItemPod.GetDescription = data.GetDescription end
	end
	list_ItemPods[slot].IsEmpty = false
	listDItems[#listDItems+1] = ItemPod
end

function dbt.inventory.RemoveItem(item)
	if not dbt.inventory.player[item] then return end
	local itemData = dbt.inventory.items[dbt.inventory.player[item].id]
	dbt.inventory.info.kg = dbt.inventory.info.kg - (itemData.kg or 1)
	dbt.inventory.info.slots[dbt.inventory.player[item].slot] = false

    table.remove(dbt.inventory.player, item)
	dbt.inventory.Rebuild()
end

dbt.playerHotBar = {}

local function buildHotBar(Chach, inventoryOwner)
	dbt.inventory.info = dbt.inventory.info or {}
	dbt.inventory.info.monopad = dbt.inventory.info.monopad or {}
	dbt.inventory.info.keys = dbt.inventory.info.keys or {}
	dbt.inventory.info.weapon = dbt.inventory.info.weapon or {}
	dbt.inventory.info.slots = dbt.inventory.info.slots or {}

	for k, i in pairs(dbt.playerHotBar) do
		if IsValid(i) then i:Remove() end
	end

	local monopadData = dbt.inventory.info.monopad or {}
	local monopadEquped = monopadData.id ~= nil

	local monopadSlot = Chach:Add( "DPanel" )
	monopadSlot:SetSize( weight_source(123), weight_source(123) )
	monopadSlot:SetPos(weight_source(56), weight_source(849))
	monopadSlot.IsEmpty = !monopadEquped
	monopadSlot.Paint = function(self, w, h)
		local x2, y2 = self:LocalToScreen( 0, 0 )
		local x, y = self:GetPos()

		surface.SetDrawColor( 255, 255, 255, Alpha(20) )
		surface.SetMaterial( paralax )
		surface.DrawTexturedRect( 0 - x - weight_source(55), 0 - y - weight_source(101), ScreenWidth, ScreenHeight )
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, 200))

		if !monopadEquped then
			surface.SetDrawColor( 0, 0, 0, Alpha(50) )
			surface.SetMaterial( inventoryMonopad )
			surface.DrawTexturedRectRotated( w * 0.5, h * 0.5, weight_source(71), weight_source(87), 0 )
		end
	end
	monopadSlot:Receiver("Item", function(receiver, panels, bDropped, menuIndex, x, y)
		if bDropped and receiver.IsEmpty then
			local itemPanel = panels[1]
			if not IsValid(itemPanel) or itemPanel.IsStorageItem then return end
			local id = itemPanel.idInv
			if dbt.inventory.player[id].id != 1 then return end
			netstream.Start("dbt/inventory/equp/mono", inventoryOwner, id)
			dbt.inventory.info.monopad = dbt.inventory.player[id]
			buildHotBar(Chach, inventoryOwner)

			itemPanel:GetParent().IsEmpty = true
			itemPanel:Remove()
			receiver.IsEmpty = false
			dbt.inventory.RemoveItem(id)
		end
	end)
	dbt.playerHotBar[#dbt.playerHotBar+1] = monopadSlot
	if monopadEquped then
		local ItemPod = vgui.Create( "DItem", monopadSlot)
		ItemPod:SetSize( weight_source(123), weight_source(123) )
		ItemPod:FromItem(monopadData.id)
		ItemPod.m_DragSlot["Item"] = nil
		ItemPod:Droppable("monopad")
		ItemPod.meta = monopadData.meta

		local data = dbt.inventory.items[monopadData.id]
		if data.OverPaint then  ItemPod.OverPaint = data.OverPaint end
		if data.GetDescription then ItemPod.GetDescription = data.GetDescription end

		monopadSlot.IsEmpty = false
	end


	local keyData = dbt.inventory.info.keys or {}
	local keyEquped = keyData.id ~= nil

	local keySlot = Chach:Add( "DPanel" )
	keySlot:SetSize( weight_source(123), weight_source(123) )
	keySlot:SetPos(weight_source(186), weight_source(849))
	keySlot.IsEmpty = true
	keySlot.Paint = function(self, w, h)
		local x2, y2 = self:LocalToScreen( 0, 0 )
		local x, y = self:GetPos()

		surface.SetDrawColor( 255, 255, 255, Alpha(20) )
		surface.SetMaterial( paralax )
		surface.DrawTexturedRect( 0 - x - weight_source(55), 0 - y - weight_source(101), ScreenWidth, ScreenHeight )
		if !keyEquped then
			surface.SetDrawColor( 0, 0, 0, Alpha(50) )
			surface.SetMaterial( inventoryKey )
			surface.DrawTexturedRectRotated( w * 0.5, h * 0.5, weight_source(78), weight_source(74), 0 )
		end
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, 200))
	end
	keySlot:Receiver("Item", function(receiver, panels, bDropped, menuIndex, x, y)
		if bDropped and receiver.IsEmpty then
			local itemPanel = panels[1]
			if not IsValid(itemPanel) or itemPanel.IsStorageItem then return end
			local id = itemPanel.idInv
			if dbt.inventory.player[id].id != 2 then return end
			netstream.Start("dbt/inventory/equp/key", inventoryOwner, id)
			dbt.inventory.info.keys = dbt.inventory.player[id]
			buildHotBar(Chach, inventoryOwner)

			itemPanel:GetParent().IsEmpty = true
			itemPanel:Remove()
			receiver.IsEmpty = false
			dbt.inventory.RemoveItem(id)
		end
	end)
	dbt.playerHotBar[#dbt.playerHotBar+1] = keySlot

	if keyEquped then
		local ItemPod = vgui.Create( "DItem", keySlot)
		ItemPod:SetSize( weight_source(123), weight_source(123) )
		ItemPod:FromItem(keyData.id)
		ItemPod.m_DragSlot["Item"] = nil
		ItemPod:Droppable("key")
		ItemPod.meta = keyData.meta

		local data = dbt.inventory.items[keyData.id]
		if data.OverPaint then  ItemPod.OverPaint = data.OverPaint end
		if data.GetDescription then ItemPod.GetDescription = data.GetDescription end
		keySlot.IsEmpty = false
	end

	dbt.inventory.info.weapon = dbt.inventory.info.weapon or {}
	for id = 1, 3 do
		if dbt.inventory.info.weapon[id] then  end
		local weaponEquped = (dbt.inventory.info.weapon[id] != nil)
		local weaponData = dbt.inventory.info.weapon[id]

		local weaponSlot = Chach:Add( "DPanel" )
		weaponSlot:SetSize( weight_source(123), weight_source(123) )
		weaponSlot:SetPos(weight_source(186) + (id * weight_source(129)), weight_source(849))
		weaponSlot.IsEmpty = true
		weaponSlot.id = id
		weaponSlot.Paint = function(self, w, h)
			local x2, y2 = self:LocalToScreen( 0, 0 )
			local x, y = self:GetPos()

			draw.DrawText(id, "Comfortaa X40", w - weight_source(13), h - weight_source(40), Color(255,255,255, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( 255, 255, 255, Alpha(20) )
			surface.SetMaterial( paralax )
			surface.DrawTexturedRect( 0 - x - weight_source(55), 0 - y - weight_source(101), ScreenWidth, ScreenHeight )
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, 200))

			if !weaponEquped then
				surface.SetDrawColor( 0, 0, 0, Alpha(50) )
				surface.SetMaterial( inventoryHand )
				surface.DrawTexturedRectRotated( w * 0.5 - weight_source(3), h * 0.5, weight_source(74), weight_source(88), 0 )
			end

		end
		weaponSlot:Receiver("Item", function(receiver, panels, bDropped, menuIndex, x, y)
			if not bDropped or not receiver.IsEmpty then return end
			local panel = panels[1]
			if not IsValid(panel) or panel.IsStorageItem then return end

			local itemIndex = panel.idInv
			local entry = dbt.inventory.player[itemIndex]
			if not entry then return end

			local itemId = entry.id
			local weaponClass = itemId and dbt.inventory.items[itemId] and dbt.inventory.items[itemId].weapon
			if not weaponClass then return end

			local owner = inventoryOwner or LocalPlayer()
			if owner:HasWeapon(weaponClass) then
				notifications_new(3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'Уведомление', titlecolor = Color(222, 193, 49), notiftext = 'Вы уже держите в руках это оружие. Зачем вам ещё?'})
				return
			end

			receiver.IsEmpty = false
			dbt.inventory.info.weapon[id] = entry
			buildHotBar(Chach, owner)

			local parent = panel:GetParent()
			if IsValid(parent) then parent.IsEmpty = true end
			local panelOwner = panel.Owner
			panel:Remove()
			dbt.inventory.RemoveItem(itemIndex)
			netstream.Start("dbt/inventory/equp/weapon", owner, panelOwner, itemIndex, id)
		end)


		if weaponEquped then
			local ItemPod = vgui.Create( "DItem", weaponSlot)
			ItemPod:SetSize( weight_source(123), weight_source(123) )
			ItemPod:FromItem(weaponData.id)
			ItemPod.m_DragSlot["Item"] = nil
			ItemPod:Droppable("weapon")
			ItemPod.idWep = id
			ItemPod.meta = weaponData.meta
			ItemPod.Owner = inventoryOwner
			local data = dbt.inventory.items[weaponData.id]
			if data.OverPaint then  ItemPod.OverPaint = data.OverPaint end
			if data.GetDescription then ItemPod.GetDescription = data.GetDescription end
			weaponSlot.IsEmpty = false
		end


		dbt.playerHotBar[#dbt.playerHotBar+1] = weaponSlot
	end
end


function dbt.inventory.New(typeOpen)
	surface.PlaySound('inv_open.mp3')
	inv_ShowData = false
	dbt.inventory._skipStorageClose = false
	dbt.inventory.Frame = vgui.Create("DFrame")
	dbt.inventory.frame = dbt.inventory.Frame
	dbt.inventory.Frame:SetDraggable(false)
	dbt.inventory.Frame:SetSize(ScreenWidth, ScreenHeight)
	dbt.inventory.Frame:Center()
	dbt.inventory.Frame:SetTitle("")
	dbt.inventory.Frame:ShowCloseButton(false)
	dbt.inventory.Frame:MakePopup()
	dbt.inventory.Frame:SetKeyboardInputEnabled(false)
	dbt.inventory.Frame.Paint = function(self, w, h)
		BlurScreen(24)
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,200))

		surface.SetDrawColor( 255, 255, 255, Alpha(10) )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( 0,0,w,h )

		draw.RoundedBox(0, 0, 0, w, h, color_1)
		draw.RoundedBox(0, 0, 0, w, hight_source(60), Color(0,0,0, 160))
	end
	dbt.inventory.Frame.OnClose = function(self)
		LocalPlayer():StopSound( "inv_use.mp3" )
		timer.Remove("EatInv")
		surface.PlaySound('inv_close.mp3')
		if dbt.scoreboard and dbt.scoreboard.TeardownCursorControl then
			dbt.scoreboard.TeardownCursorControl()
		end
		if dbt.inventory.storageActive then
			netstream.Start("dbt/inventory/storage/close", dbt.inventory.storageActive.id)
			dbt.inventory.storageActive = nil
		end
		dbt.inventory._skipStorageClose = false
		list_ItemPods = {}
		storage_ItemPods = {}
		listDItems = {}
		storageDItems = {}
		dbt.inventory.storageSlots = {}
		dbt.inventory.storageItemPanels = {}
		dbt.inventory.currentOwner = nil
		dbt.inventory.Frame = nil
		dbt.inventory.frame = nil
	end

	local buttonInventory = dbt.inventory.Frame:Add( "DButton" )
	buttonInventory:SetSize( weight_source(206), weight_source(60) )
	buttonInventory:SetPos(0, 0)
	buttonInventory:SetText("")
	buttonInventory.Paint = function(self, w, h)

		surface.SetDrawColor( 255, 255, 255, Alpha(255) )
		surface.SetMaterial( tabmenuInventory )
		surface.DrawTexturedRectRotated( hight_source(31), h * 0.5, weight_source(25), hight_source(30), 0 )

		draw.DrawText("Инвентарь", "Comfortaa X35", w * 0.6, h * 0.17, Color(255,255,255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	buttonInventory.DoClick = function()
		if IsValid(dbt.scoreboard.frame) then
			if IsValid(dbt.inventory.Frame) then
		    	dbt.inventory.Frame:Close()
		    end
		    dbt.inventory.New()
		end
	end

	local buttonScoreboard = dbt.inventory.Frame:Add( "DButton" )
	buttonScoreboard:SetSize( weight_source(256), weight_source(60) )
	buttonScoreboard:SetPos(weight_source(206), 0)
	buttonScoreboard:SetText("")
	buttonScoreboard.Paint = function(self, w, h)

		surface.SetDrawColor( 255, 255, 255, Alpha(255) )
		surface.SetMaterial( tabmenuScoreboard )
		surface.DrawTexturedRectRotated( hight_source(31), h * 0.5, weight_source(29), hight_source(24), 0 )

		draw.DrawText("Список игроков", "Comfortaa X35", w * 0.58, h * 0.17, Color(255,255,255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if typeOpen == 2 then dbt.inventory.TAB_menu(true) return end
	local char = dbt.chr[LocalPlayer():Pers()]
	local Chach = vgui.Create("EditablePanel", dbt.inventory.Frame)
	Chach:SetPos(0, weight_source(60))
	Chach:SetSize(ScreenWidth, ScreenHeight - weight_source(60))
	Chach.Paint = function(self, w, h)

		draw.DrawText("Предметы", "Comfortaa X40", weight_source(56), hight_source(51), Color(255,255,255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		surface.SetFont("Comfortaa X40")
		local www, hhh = surface.GetTextSize(" / "..(char.maxKG).." кг")
		--dbt.inventory.info.kg..
		draw.DrawText(" / "..(char.maxKG).." кг", "Comfortaa X40", weight_source(690), hight_source(51), Color(255,255,255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.DrawText(dbt.inventory.info.kg, "Comfortaa Bold X40", weight_source(690) - www, hight_source(51), Color(175, 19, 186, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.DrawText("Экипировка", "Comfortaa X40", weight_source(56), hight_source(801), Color(255,255,255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		local storageCtx = dbt.inventory.storageActive
		if storageCtx then
			draw.DrawText(storageCtx.name or "Хранилище", "Comfortaa X40", weight_source(1205), hight_source(51), Color(255,255,255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			local maxWeight = tonumber(storageCtx.maxWeight)
			if maxWeight and maxWeight > 0 then
				local currentWeight = math.Round(math.max(0, tonumber(storageCtx.weight) or 0),2)
				local maxSuffix = " / "..maxWeight.." кг"

				local weightY = hight_source(51)
				local anchorX = weight_source(1846)
				surface.SetFont("Comfortaa X40")
				local suffixWidth = select(1, surface.GetTextSize(maxSuffix))
				surface.SetFont("Comfortaa Bold X40")
				local currentAnchor = anchorX - suffixWidth
				draw.DrawText(currentWeight, "Comfortaa Bold X40", currentAnchor, weightY, Color(175, 19, 186, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				draw.DrawText(maxSuffix, "Comfortaa X40", anchorX, weightY, Color(255,255,255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end

		elseif inv_ShowData then
			draw.DrawText("Информация о предмете", "Comfortaa X40", weight_source(1305), hight_source(68), Color(255,255,255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( LineItem )
			surface.DrawTexturedRect( weight_source(1295), hight_source(98), weight_source(584), hight_source(27) )

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( d_mat )
			surface.DrawTexturedRect( weight_source(1305), hight_source(137), weight_source(561), hight_source(161) )

			local massText = tostring(inv_Mass or "0") .. " кг"
			draw.DrawText(massText, "Comfortaa X40", weight_source(1315), hight_source(255), Color(255,255,255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			local displayName = inv_Name or ""
			surface.DrawMulticolorText(weight_source(1315), hight_source(135), "Comfortaa X35", {color_white, displayName}, weight_source(300))

			local descTokens = inv_Desc or {color_white, ""}
			local x, y = surface.DrawMulticolorText(weight_source(1305), hight_source(310), "Comfortaa X28", descTokens, weight_source(550))

			surface.SetDrawColor( 107, 107, 107, 150 )
			surface.DrawLine( weight_source(1305), y + hight_source(40), weight_source(1305 + 561), y + hight_source(40) )

			local descAltTokens = inv_DescALt or nil
			if descAltTokens then
				surface.DrawMulticolorText(weight_source(1305), y + hight_source(50), "Comfortaa X28", descAltTokens, weight_source(550))
			end
		end
	end

	Chach:Receiver( 'Item', function( receiver, tableOfDroppedPanels, isDropped, menuIndex, mouseX, mouseY )
		if not isDropped then return end
		local panel = tableOfDroppedPanels[1]
		if not IsValid(panel) then return end
		if panel.IsStorageItem then return end
		panel:GetParent().IsEmpty = true
		panel:Remove()
		surface.PlaySound('inv_drop.mp3')
		dbt.inventory.RemoveItem(panel.idInv)
		netstream.Start("dbt/inventory/slot/drop", panel.idInv)
	end,{})

	Chach:Receiver( 'weapon', function( receiver, tableOfDroppedPanels, isDropped, menuIndex, mouseX, mouseY )
		if isDropped then
			local panel = tableOfDroppedPanels[1]
			local wepId = panel.idWep
			netstream.Start("dbt/inventory/slot/drop_weapon", panel.Owner, LocalPlayer(), wepId)
			dbt.inventory.info.weapon[wepId] = nil
			buildHotBar(Chach, inventoryOwner)
			surface.PlaySound('inv_drop.mp3')
		end
	end,{})


	if dbt.inventory.storageActive then
		inv_IconPanel = nil
	else
		inv_IconPanel = vgui.Create( "DModelPanel", Chach )
		inv_IconPanel:SetSize( hight_source(161), hight_source(161) )
		inv_IconPanel:SetPos(weight_source(1715), hight_source(135))

		function inv_IconPanel:LayoutEntity( Entity ) return end
	end

	local inventoryOwner = LocalPlayer()
	dbt.inventory.currentOwner = inventoryOwner

	local List = vgui.Create( "DIconLayout", Chach )
	List:SetPos(weight_source(55), weight_source(101))
	List:SetSize(weight_source(646), weight_source(872))
	List:SetSpaceY( weight_source(6) )
	List:SetSpaceX( weight_source(6) )
	List.Owner = inventoryOwner
	list_ItemPods = {}
	CurrentY = 1
	CurrentX = 1
	local characterInventory = dbt.chr[inventoryOwner:Pers()].maxInventory or 10
	for i = 1, characterInventory do
		local ItemPod = List:Add( "DPanel" )
		ItemPod:SetSize( weight_source(123), weight_source(123) )
		ItemPod.x = (i - ((CurrentY - 1) * 5))
		ItemPod.y = CurrentY
		ItemPod.IsEmpty = true
		ItemPod.slot = i
		if (i % 5) == 0 then CurrentY = CurrentY + 1 end
		ItemPod.Paint = function(self, w, h)
			local x2, y2 = self:LocalToScreen( 0, 0 )
			local x, y = self:GetPos()

			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, 150))

			surface.SetDrawColor( 255, 255, 255, Alpha(20) )
			surface.SetMaterial( paralax )
			surface.DrawTexturedRect( 0 - x - weight_source(55), 0 - y - weight_source(101), ScreenWidth, ScreenHeight )
		end
		--[[
		]]
		ItemPod:Receiver("monopad", function(receiver, panels, bDropped, menuIndex, x, y)
			if bDropped and receiver.IsEmpty then
				receiver.IsEmpty = false
				local panel = panels[1]
				netstream.Start("dbt/inventory/slot/mono_a", inventoryOwner, receiver.slot)
				dbt.inventory.info.monopad = {}
				buildHotBar(Chach, inventoryOwner)
				dbt.inventory.AddItem(panel.id, i, #dbt.inventory.player+1, panel.meta)
			end
		end)
		ItemPod:Receiver("key", function(receiver, panels, bDropped, menuIndex, x, y)
			if bDropped and receiver.IsEmpty then
				receiver.IsEmpty = false
				local panel = panels[1]
				netstream.Start("dbt/inventory/slot/keys_a", inventoryOwner, receiver.slot)
				dbt.inventory.info.keys = {}
				buildHotBar(Chach, inventoryOwner)
				dbt.inventory.AddItem(panel.id, i, #dbt.inventory.player+1, panel.meta)
			end
		end)
		ItemPod:Receiver("weapon", function(receiver, panels, bDropped, menuIndex, x, y)
			if bDropped and receiver.IsEmpty then
				receiver.IsEmpty = false
				local panel = panels[1]
				netstream.Start("dbt/inventory/slot/weapon_a", panel.Owner, inventoryOwner, receiver.slot, panel.idWep)
				local itemId = panel.id
				local itemMeta = panel.meta

				dbt.inventory.AddItem(itemId, i, #dbt.inventory.player+1, itemMeta)

				dbt.inventory.info.weapon[panel.idWep] = nil

				buildHotBar(Chach, inventoryOwner)
			end
		end)
		ItemPod:Receiver("Item", function(receiver, panels, bDropped, menuIndex, x, y)
			if not bDropped then return end
			local panel = panels[1]
			if not IsValid(panel) then return end
			if panel.IsStorageItem then
				if not dbt.inventory.storageActive then return end
				if not receiver.IsEmpty then return end
				if storage_ItemPods[panel.storageSlot] then
					storage_ItemPods[panel.storageSlot].IsEmpty = true
				end
				local itemWeight = 0
				local storageCtx = dbt.inventory.storageActive
				if storageCtx then
					local itemData = panel.storageItemId and dbt.inventory.items[panel.storageItemId]
					itemWeight = (itemData and itemData.kg) or 1
					storageCtx.weight = math.max(0, (tonumber(storageCtx.weight) or 0) - itemWeight)
				end
				panel:Remove()
				netstream.Start("dbt/inventory/storage/withdraw", dbt.inventory.storageActive.id, panel.storageIndex, receiver.slot)
				return
			end
			if receiver.IsEmpty then
				receiver.IsEmpty = false
				if dbt.inventory.player[panel.idInv] then
					dbt.inventory.player[panel.idInv].slot = receiver.slot
				end
				panel:GetParent().IsEmpty = true
				panel:SetParent(receiver)

				netstream.Start("dbt/inventory/slot/change", inventoryOwner, panel.idInv, receiver.slot)
			end
		end)

		list_ItemPods[i] = ItemPod
	end
	for k, i in pairs(dbt.inventory.player) do
		dbt.inventory.AddItem(i.id, i.slot, k, i.meta, inventoryOwner, k)
	end

	if dbt.inventory.storageActive then
		storage_ItemPods = {}
		storageDItems = {}
		dbt.inventory.storageSlots = storage_ItemPods
		dbt.inventory.storageItemPanels = storageDItems

		local storagePanel = vgui.Create("DPanel", Chach)
		storagePanel:SetPos(weight_source(1205), hight_source(101))
		storagePanel:SetSize(weight_source(646), hight_source(872))
		storagePanel.Paint = function(self, w, h)

		end

		local storageList = vgui.Create("DIconLayout", storagePanel)
		storageList:SetPos(0, 0)
		storageList:SetSize(storagePanel:GetWide(), storagePanel:GetTall())
		storageList:SetSpaceY(weight_source(6))
		storageList:SetSpaceX(weight_source(6))

		local maxSlots = math.max(dbt.inventory.storageActive.maxSlots or 0, 0)
		for i = 1, maxSlots do
			local slotPanel = storageList:Add("DPanel")
			slotPanel:SetSize(weight_source(123), weight_source(123))
			slotPanel.IsEmpty = true
			slotPanel.slot = i
			slotPanel.Paint = function(self, w, h)
				local x2, y2 = self:LocalToScreen(0, 0)
				local x, y = self:GetPos()

				draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, 150))

				surface.SetDrawColor( 255, 255, 255, Alpha(20) )
				surface.SetMaterial( paralax )
				surface.DrawTexturedRect( 0 - x - weight_source(55), 0 - y - weight_source(101), ScreenWidth, ScreenHeight )
			end

			slotPanel:Receiver("Item", function(receiver, panels, bDropped, menuIndex, x, y)
				if not bDropped then return end
				if not receiver.IsEmpty then return end
				local panel = panels[1]
				if not IsValid(panel) then return end
				if panel.IsStorageItem then return end

				local storageCtx = dbt.inventory.storageActive
				if storageCtx then
					local entry = dbt.inventory.player[panel.idInv]
					local itemData = entry and dbt.inventory.items[entry.id]
					local itemWeight = (itemData and itemData.kg) or 1
					local maxWeight = tonumber(storageCtx.maxWeight)
					local currentWeight = tonumber(storageCtx.weight) or 0
					if maxWeight and maxWeight > 0 and (currentWeight + itemWeight) > maxWeight then
						chat.AddText(Color(116, 40, 151), "[DBT] ", Color(255, 255, 255), "Хранилище переполнено по весу.")
						return
					end
					storageCtx.weight = currentWeight + itemWeight
				end
				if IsValid(panel:GetParent()) then
					panel:GetParent().IsEmpty = true
				end
				panel:Remove()
				surface.PlaySound('inv_drop.mp3')
				dbt.inventory.RemoveItem(panel.idInv)
				receiver.IsEmpty = false
				netstream.Start("dbt/inventory/storage/deposit", dbt.inventory.storageActive.id, panel.idInv, receiver.slot)
			end)

			slotPanel:Receiver("storage_item", function(receiver, panels, bDropped)
				if not bDropped then return end
				local panel = panels[1]
				if not IsValid(panel) or not panel.IsStorageItem then return end
				if receiver.slot == panel.storageSlot then return end
				if not receiver.IsEmpty then
					chat.AddText(Color(116, 40, 151), "[DBT] ", Color(255, 255, 255), "Слот уже занят.")
					return
				end

				receiver.IsEmpty = false
				local previousContainer = storage_ItemPods[panel.storageSlot]
				if IsValid(previousContainer) then
					previousContainer.IsEmpty = true
				end

				panel.storageSlot = receiver.slot
				panel:SetParent(receiver)
				panel:SetPos(0, 0)
				surface.PlaySound('inv_drop.mp3')
				netstream.Start("dbt/inventory/storage/move", dbt.inventory.storageActive.id, panel.storageIndex, receiver.slot)
			end)

			storage_ItemPods[i] = slotPanel
		end

		dbt.inventory.RebuildStorage()
	else
		storage_ItemPods = {}
		storageDItems = {}
		dbt.inventory.storageSlots = {}
		dbt.inventory.storageItemPanels = {}
	end

	buildHotBar(Chach, inventoryOwner)

	buttonScoreboard.DoClick = function()
		dbt.inventory.TAB_menu()
		Chach:Remove()
	end
end

function dbt.inventory.TAB_menu(lockCursor)
	if IsValid(dbt.scoreboard.frame) then
		dbt.scoreboard.frame:Remove()
	end

	dbt.inventory.Frame.Paint = function(self, w, h)
		BlurScreen(24)
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,200))

		surface.SetDrawColor( 255, 255, 255, Alpha(20) )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( 0,0,w,h )

		draw.RoundedBox(0, 0, 0, w, h, color_1)
		draw.RoundedBox(0, 0, 0, w, hight_source(60), Color(0,0,0, 160))
	end

	dbt.scoreboard:Open()
	if lockCursor then
		dbt.scoreboard.SetupCursorControl()
	else
		dbt.scoreboard.TeardownCursorControl()
		dbt.scoreboard.SetCursorEnabled(true)
	end
end

if IsValid(dbt.inventory.Frame) then dbt.inventory.Frame:Close() dbt.inventory.New() end
concommand.Add("opennn", dbt.inventory.New)

hook.Add("InitPostEntity", "spdsa", function()
    for k, i in pairs(weapons.GetList()) do
        local class = i.ClassName
        if string.StartsWith(class, "tfa_nmrih") then
            dbt.inventory.items[#dbt.inventory.items+1] = {
                name = i.PrintName,
                weapon = class,
                mdl = i.WorldModel,
				kg = i.kg or 1,
            }
        end
    end



    dbt.inventory.weaponsId = {}

    for k, i in pairs(dbt.inventory.items) do
        if i.weapon then
            dbt.inventory.weaponsId[i.weapon] = k
        end
    end
end)
