-- LOTM System Initialization
-- Инициализация системы зелий LOTM
-- Подключить этот файл в shared.lua или init.lua добавив строку: include("sh_lotm_init.lua")

local lotmPath = "lotm/modules/lotm/"

-- Загрузка loader файла, который автоматически подгрузит все остальное
if SERVER then
    AddCSLuaFile(lotmPath .. "sh_loader.lua")
end

include(lotmPath .. "sh_loader.lua")

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Module initialized successfully!\n")