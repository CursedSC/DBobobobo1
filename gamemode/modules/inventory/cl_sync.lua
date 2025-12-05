local scriptedFunctions = {}

scriptedFunctions["description"] = function(text2)
    return function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = text2
        return text
    end
end
 

function syncItems()
	netstream.Start("dbt/inventory/items/sync")
end

hook.Add("InitPostEntity", "dbt/items/sync", function()
    syncItems()
end)

netstream.Hook("dbt/inventory/items/sync", function(tbl)
    for k, i in pairs(dbt.inventory.items) do 
        if i.notEditable or i.OnUse then continue end
        dbt.inventory.items[k] = nil
    end
    for k, itemData in pairs(tbl) do
        if itemData.notEditable then continue end
        if itemData.description then
            local func = scriptedFunctions["description"]
            itemData.GetDescription = func(itemData.description)
        end
        dbt.inventory.items[k] = itemData
    end
end)

syncItems()

concommand.Add("dbt_sync_items", function(ply, cmd, args)
    syncItems()
end)