<<<<<<< HEAD
-- LOTM Module Autoloader v3.0
-- Полная загрузка всех модулей LOTM

local path = "dbt/gamemode/modules/lotm/"

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Starting LOTM v3.0...\n")

-- =============================================
-- SHARED FILES
-- =============================================
local sharedFiles = {
    "sh_lotm_pathways.lua",
    "sh_effect_templates.lua",
    "sh_abilities_unified.lua",
    "sh_aura_system.lua",
    "sh_dash.lua",                  -- Система дэшей
    "sh_artifacts.lua",
    "sh_artifact_slots.lua",
    "sh_artifacts_data.lua",
    "sh_artifact_weapons.lua",      -- Шаблоны SWEP артефактов
    "sh_currency.lua",              -- Валюта: Фунты, Пенсы, Соли
    "sh_mystical_ingredients.lua",
    "sh_recipes.lua",
    "sh_potions_core.lua",
    "sh_potions_data.lua",
    "sh_hitbox_system.lua",
    "sh_damage_types.lua",
}

-- =============================================
-- SERVER FILES
-- =============================================
local serverFiles = {
    "sv_database.lua",
    "sv_potions.lua",
    "sv_artifacts_commands.lua",
    "sv_artifact_slots.lua",        -- Слоты артефактов
    "sv_trade.lua",                 -- Торговля
    "sv_binds.lua",                 -- Бинды на сервере
}

-- =============================================
-- CLIENT FILES
-- =============================================
local clientFiles = {
    "cl_ability_hud.lua",
    "cl_status_hud.lua",            -- HUD статусов, валюты, способностей
    "cl_f4_integration.lua",
    "cl_ability_menu.lua",
    "cl_keybinds_menu.lua",
    "cl_thirdperson.lua",
    "cl_damage_effects.lua",
    "cl_potions.lua",
    "cl_items_spawnmenu.lua",
    "cl_artifacts_spawnmenu.lua",   -- Q-меню артефактов
    "cl_artifact_slots.lua",        -- Слоты и инвентарь v3.0
    "cl_spawnmenu.lua",
    "cl_notes_system.lua",          -- Записки зелий
    "cl_trade.lua",                 -- UI торговли v3.0
    "cl_binds.lua",                 -- Бинды клиента
    "cl_unified_menu.lua",          -- Единая вкладка LOTM Предметы
}

-- =============================================
-- ЗАГРУЗКА
-- =============================================
local function LoadFile(file, realm)
    local fullPath = path .. file
    
    if SERVER then
        if realm == "shared" or realm == "client" then
            AddCSLuaFile(fullPath)
        end
    end
    
    if realm == "client" and SERVER then return true end
    
    local success, err = pcall(function()
        include(fullPath)
    end)
    
    if not success then
        MsgC(Color(255, 100, 100), "[LOTM] ✗ " .. file .. ": " .. tostring(err) .. "\n")
    end
    
    return success
end

for _, file in ipairs(sharedFiles) do LoadFile(file, "shared") end
if SERVER then for _, file in ipairs(serverFiles) do LoadFile(file, "server") end end
for _, file in ipairs(clientFiles) do LoadFile(file, "client") end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "LOTM v3.0 loaded!\n")
=======
-- LOTM Module Autoloader
-- Автоматическая загрузка модулей LOTM

local path = "lotm/modules/lotm/"

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Starting LOTM system initialization...\n")

-- Shared files (загружаются и на сервере, и на клиенте)
local sharedFiles = {
    "sh_potions_core.lua",
    "sh_potions_data.lua",
    "sh_hitbox_system.lua"  -- Система хитбоксов и атак
}

-- Server files (только сервер)
local serverFiles = {
    "sv_energy.lua",
    "sv_potions.lua"
}

-- Client files (только клиент)
local clientFiles = {
    "cl_keybind_menu.lua"  -- Меню управления
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
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
