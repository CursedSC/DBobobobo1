util.AddNetworkString("admin.ToggleWound")

DBT_WoundsSettings = DBT_WoundsSettings or {
    ["Ушиб"] = true,
    ["Ранение"] = true,
    ["Тяжелое ранение"] = true,
    ["Пулевое ранение"] = true,
    ["Перелом"] = true,
    ["Парализован"] = true
}

local function SaveWoundsSettings()
    file.Write("dbt_wounds_settings.txt", util.TableToJSON(DBT_WoundsSettings))
end

local function LoadWoundsSettings()
    if file.Exists("dbt_wounds_settings.txt", "DATA") then
        local data = file.Read("dbt_wounds_settings.txt", "DATA")
        if data then
            local loaded = util.JSONToTable(data)
            if loaded then
                DBT_WoundsSettings = loaded
            end
        end
    end
end

LoadWoundsSettings()

function DBT_IsWoundEnabled(woundType)
    return DBT_WoundsSettings[woundType] ~= false
end

net.Receive("admin.ToggleWound", function(len, ply)
    if not ply:IsSuperAdmin() then return end
    
    local woundType = net.ReadString()
    local enabled = net.ReadBool()
    
    DBT_WoundsSettings[woundType] = enabled
    SaveWoundsSettings()
    
    netstream.Start(nil, "dbt/wounds/settings_sync", DBT_WoundsSettings)
    
    local statusText = enabled and "включено" or "выключено"
    ply:ChatPrint("Ранение '" .. woundType .. "' " .. statusText)
    
    for _, p in ipairs(player.GetAll()) do
        if p ~= ply and p:IsSuperAdmin() then
            p:ChatPrint("[Админ] " .. ply:Nick() .. " " .. statusText .. " ранение: " .. woundType)
        end
    end
end)

hook.Add("PlayerInitialSpawn", "dbt_wounds_sync_settings", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            netstream.Start(ply, "dbt/wounds/settings_sync", DBT_WoundsSettings)
        end
    end)
end)