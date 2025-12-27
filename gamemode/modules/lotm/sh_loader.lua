-- LOTM Module Autoloader
-- Автоматическая загрузка модулей LOTM

local path = "lotm/modules/lotm/"

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Starting LOTM system initialization...\n")

-- Shared files (загружаются и на сервере, и на клиенте)
local sharedFiles = {
    "sh_potions_core.lua",
    "sh_potions_data.lua"
}

-- Server files (только сервер)
local serverFiles = {
    "sv_energy.lua",
    "sv_potions.lua"
}

-- Client files (только клиент)
local clientFiles = {
    "cl_potions.lua"
}

-- Загрузка shared файлов
for _, file in ipairs(sharedFiles) do
    local fullPath = path .. file
    
    if SERVER then
        AddCSLuaFile(fullPath)
    end
    
    include(fullPath)
    
    if SERVER then
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(200, 200, 200), "Loaded (shared): ", Color(255, 255, 255), file .. "\n")
    end
end

-- Загрузка server файлов
if SERVER then
    for _, file in ipairs(serverFiles) do
        local fullPath = path .. file
        include(fullPath)
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(200, 200, 200), "Loaded (server): ", Color(255, 255, 255), file .. "\n")
    end
end

-- Загрузка client файлов
if SERVER then
    for _, file in ipairs(clientFiles) do
        local fullPath = path .. file
        AddCSLuaFile(fullPath)
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(200, 200, 200), "Added to client: ", Color(255, 255, 255), file .. "\n")
    end
else
    for _, file in ipairs(clientFiles) do
        local fullPath = path .. file
        include(fullPath)
    end
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "System initialization complete!\n")
MsgC(Color(100, 255, 100), string.rep("=", 50) .. "\n")