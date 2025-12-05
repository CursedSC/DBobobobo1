local scriptedFunctions = {}
util.AddNetworkString("dbt/inventory/items/load/preset")
scriptedFunctions["description"] = function(text2)
    return function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = text2
        return text
    end
end

scriptedFunctions["medicineАптечка"] = function(text)
    return function(ply, data, meta, c_data)
        ply:SetHealth(math.Clamp(ply:Health() + text, 0, ply:GetMaxHealth()))
    end
end

scriptedFunctions["medicineХирургическийнабор"] = function(text)
    return function(ply, data, meta, c_data)
        dbt.removeWound(ply, dbt.woundstypes.bulletwound, c_data.position)
        dbt.removeWound(ply, dbt.woundstypes.hardwound, c_data.position)
    end
end

scriptedFunctions["medicine"] = function(text)
    return function(ply, data, meta, c_data)
        dbt.UseMedicaments(ply, data.medicine, c_data.position)
    end
end

netstream.Hook("dbt/items/delete", function(ply, itemId)
    if !ply:IsAdmin() then return end
    if dbt.inventory.items[itemId] then
        dbt.inventory.items[itemId] = nil
        syncItems(nil)
    end
end)

netstream.Hook("dbt/items/save", function(ply, itemId, itemData)
    if !ply:IsAdmin() then return end
    if itemData.description then
        local func = scriptedFunctions["description"]
        itemData.GetDescription = func(itemData.description)
    end
    if itemData.medicinefunction then 
        local func = scriptedFunctions[itemData.medicinefunction]
        if func then
            itemData.OnUse = func(itemData.medicineAdd)
        end
    end
    itemData.edited = true
    dbt.inventory.items[itemId] = itemData 
    dbt.inventory.items[itemId].id = itemId
    syncItems(nil)
end)

function syncItems(target)
    local sendItems = {}
    for k, i in pairs(dbt.inventory.items) do 
        if i.notEditable then continue end
        sendItems[k] = table.Copy(i) 
        sendItems[k].icon = nil
        local description = sendItems[k].description or ""
        if sendItems[k].GetDescription and description == "" then
            description = ""
            local oldText = sendItems[k]:GetDescription({meta = {}}) 
            for k, i in pairs(oldText) do
                if type(i) == "string"  then
                    description = description .." ".. i
                end
            end
        end
        sendItems[k].GetDescription = nil
        sendItems[k].description = description
        sendItems[k].OnUse = nil
    end

    netstream.Start(target, "dbt/inventory/items/sync", sendItems)
end

netstream.Hook("dbt/inventory/items/sync", syncItems)

net.Receive("dbt/inventory/items/load/preset", function(len, ply)
    net.ReadStream(ply, function(data)
        if !ply:IsAdmin() then return end
        for k, i in pairs(dbt.inventory.items) do 
            if i.notEditable then continue end
            dbt.inventory.items[k] = nil
        end

            local nTab = pon.decode(data) or {}
            local presetName = tostring(nTab.Name or id or "preset")
            local imported = istable(nTab.Items) and nTab.Items or {}
            for id, itemData in pairs(imported) do
                if itemData.notEditable then continue end
                local entry = istable(itemData) and table.Copy(itemData) or {}
                entry.notEditable = nil
                if entry.description and entry.description ~= "" then
                    local func = scriptedFunctions["description"]
                    entry.GetDescription = func(entry.description)
                end
                if entry.medicinefunction then 
                    local func = scriptedFunctions[entry.medicinefunction]
                    if func then
                        entry.OnUse = func(entry.medicineAdd)
                    end
                end
                entry.edited = true
                entry.id = id
                dbt.inventory.items[id] = entry
            end
        syncItems(nil)
        netstream.Start(nil, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'System', titlecolor = Color(255, 0, 255), notiftext = 'Пресет '.. presetName .. ' загружен!', time = 5}) 
	end)
end)
