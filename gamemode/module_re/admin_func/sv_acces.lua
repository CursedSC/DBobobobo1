allowed_old =  {
    [ "STEAM_0:1:188105562" ] = true, 
    [ "STEAM_0:1:95796521" ] = true, 
    [ "STEAM_0:1:521065551" ] = true, 
    [ "STEAM_0:1:216502433" ] = true, 
    [ "STEAM_0:0:170628759" ] = true, 
    [ "STEAM_0:0:516436115" ] = true, 
    [ "STEAM_0:0:381811561" ] = true, 
    [ "STEAM_0:0:594178822" ] = true, 
    [ "STEAM_0:0:207956135" ] = true, 
    [ "STEAM_0:1:115171201" ] = true, 
    [ "STEAM_0:0:542396479" ] = true, 
    ["STEAM_0:1:219739348"] = true, 
    ["STEAM_0:1:176216756"] = true, 
    ["STEAM_0:0:90645043"] = true,
    ["STEAM_0:1:108029369"] = true, 
    ["STEAM_0:1:442105758"] = true,
    
}


allowed = allowed or {}  

hook.Add( "CheckPassword", "access_whitelist", function( steamID64 )
    local converted = util.SteamIDFrom64(steamID64)

    if allowed_old[ util.SteamIDFrom64(steamID64) ] then
        return true
    end

    if not allowed[ util.SteamIDFrom64(steamID64) ] then
        return false, "Доступ на сервер только по записи \n"--"Доступ на сервер только по записи \n"
    end 
    
end)

netstream.Hook("dbt/whitelist/request", function(ply)
    if not ply:IsAdmin() then return end
    netstream.Start(ply, "dbt/whitelist/list", allowed)
end)

netstream.Hook("dbt/whitelist/add", function(ply, steamid)
    if not ply:IsAdmin() then return end
    if type(steamid) ~= "string" or not steamid:match("STEAM_%d:%d:%d+") then return end
    
    allowed[steamid] = true
    print("[Whitelist] Admin " .. ply:Nick() .. " added " .. steamid .. " to the whitelist")

    netstream.Start(ply, "dbt/player/text", Color(143, 37, 156), "[Whitelist] ", Color(255,255,255), "SteamID " .. steamid .. " добавлен в список разрешенных")
end)

netstream.Hook("dbt/whitelist/remove", function(ply, steamid)
    if not ply:IsAdmin() then return end
    if type(steamid) ~= "string" then return end
    
    allowed[steamid] = nil

    local target = player.GetBySteamID(steamid)
    if IsValid(target) then
        target:Kick("Вы были удалены из списка разрешенных игроков")
    end
    
    netstream.Start(ply, "dbt/player/text", Color(143, 37, 156), "[Whitelist] ", Color(255,255,255), "SteamID " .. steamid .. " удален из списка разрешенных")
end)

netstream.Hook("dbt/whitelist/clear", function(ply)
    if not ply:IsAdmin() then return end
    
    allowed = {}

    for _, player in pairs(player.GetAll()) do
        if not player:IsAdmin() then
            player:Kick("Список разрешенных игроков был очищен")
        end
    end
    
    netstream.Start(ply, "dbt/player/text", Color(143, 37, 156), "[Whitelist] ", Color(255,255,255), "Список разрешенных SteamID полностью очищен")
end)

netstream.Hook("dbt/whitelist/import", function(ply, steamids)
    if not ply:IsAdmin() then return end
    if type(steamids) ~= "table" then return end
    
    local count = 0
    for _, steamid in pairs(steamids) do
        if type(steamid) == "string" and steamid:match("STEAM_%d:%d:%d+") then
            allowed[steamid] = true
            count = count + 1
        end
    end
    
    netstream.Start(ply, "dbt/player/text", Color(143, 37, 156), "[Whitelist] ", Color(255,255,255), "Импортировано " .. count .. " SteamID в список разрешенных")
end)

netstream.Hook("dbt/whitelist/export", function(ply)
    if not ply:IsAdmin() then return end
    
    local exportText = "# DBT Whitelist Export - " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    local count = 0
    
    for steamid, _ in pairs(allowed) do
        exportText = exportText .. steamid .. "\n"
        count = count + 1
    end
    
    exportText = exportText .. "# Total: " .. count .. " SteamIDs"
    
    netstream.Start(ply, "dbt/whitelist/export_data", exportText)
end)

hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
    return ply:IsSuperAdmin()
end )

concommand.Add("CheckWhiteList", function( ply, cmd, args, argStr )  
    PrintTable(allowed)  
end)





------------------------

local function getMapList()
    local maps = file.Find("maps/*.bsp", "GAME")
    local maplist = {}
    for _, map in ipairs(maps) do
        maplist[#maplist + 1] = string.StripExtension(map)
    end
    return maplist
end

netstream.Hook("dbt/admin/maplist", function(ply)
    if !ply:IsAdmin() then return end 
    local maps = getMapList()
    netstream.Start(ply, "dbt/admin/maplist", maps)
end)


netstream.Hook("dbt/poison/disableall", function(ply, target)
    if not ply:IsAdmin() then return end

    if PoisonKCNIsActive(target) then
        PoisonKCNCure(target)
    end

    if PoisonMethanolIsActive(target) then
        PoisonMethanolCure(target)
    end
end)

netstream.Hook("dbt/players/restorechars", function(ply, target)
    if not ply:IsAdmin() then return end
    target:SetNWInt("hunger", 100)
    target:SetNWInt("sleep", 100)
    target:SetNWInt("Stamina", 100)
    target:SetNWInt("water", 100)
end)

netstream.Hook("dbt/characters/admin/sethealth", function(ply, target, health)
    if not ply:IsAdmin() then return end
    target:SetHealth(health)
end)

netstream.Hook("dbt/characters/admin/setarmor", function(ply, target, armor)
    if not ply:IsAdmin() then return end
    target:SetArmor(armor)
end)

netstream.Hook("dbt/characters/admin/setstat", function(ply, target, name, stat)
    if not ply:IsAdmin() then return end
    target:SetNWInt(name, stat)
end)

netstream.Hook("dbt/admin/telepor/die", function(ply, target)
    if not ply:IsAdmin() then return end
    local charData = charactersInGame[target:Pers()]
    local posDie = charData.diepos 
    local dieData = target.deathData
    if not posDie or not dieData then return end 
    if !target:Alive() then target:Spawn() end
    target:SetPos(target.deathData.Ragdoll:GetPos())
    //target.info = dieData.info
    //target.items = dieData.items
    local corpseStorageId = target.deathData.Ragdoll.dbtCorpseStorageId
    local corpseStorage = dbt.inventory.storage.Get(corpseStorageId)
    if corpseStorage then 
        local w = corpseStorage.weight
        local s = corpseStorage.slots
        
        target.info.slots = s
        target.info.kg = w
        target.items = table.Copy(corpseStorage.items)
    end

    HandleAdminSetAlive(ply, target, true)

    if IsValid(target.deathData.Ragdoll) then target.deathData.Ragdoll:Remove() end

    target.posDie = nil
    target.deathData = nil

    dbt.inventory.SendUpdate(target)
    target:syncInformation()
end)
