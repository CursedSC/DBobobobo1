-- LOTM Module Autoloader v4.0
-- Полная загрузка всех модулей LOTM
-- Организованная структура папок

local basePath = "dbt/gamemode/modules/lotm/"

MsgC(Color(211, 25, 202), "═══════════════════════════════════════════\n")
MsgC(Color(211, 25, 202), "[LOTM] ", Color(255, 255, 255), "Starting LOTM v4.0 - Zero Abyss\n")
MsgC(Color(211, 25, 202), "═══════════════════════════════════════════\n")

-- =============================================
-- СТРУКТУРА ЗАГРУЗКИ
-- =============================================
local MODULES = {
    -- Базовые shared файлы (ядро)
    {path = "", files = {
        {name = "sh_lotm_pathways.lua",     realm = "shared"},
        {name = "sh_effect_templates.lua",  realm = "shared"},
        {name = "sh_abilities_unified.lua", realm = "shared"},
        {name = "sh_aura_system.lua",       realm = "shared"},
        {name = "sh_dash.lua",              realm = "shared"},
        {name = "sh_artifacts.lua",         realm = "shared"},
        {name = "sh_artifact_slots.lua",    realm = "shared"},
        {name = "sh_artifacts_data.lua",    realm = "shared"},
        {name = "sh_artifact_weapons.lua",  realm = "shared"},
        {name = "sh_currency.lua",          realm = "shared"},
        {name = "sh_mystical_ingredients.lua", realm = "shared"},
        {name = "sh_recipes.lua",           realm = "shared"},
        {name = "sh_potions_core.lua",      realm = "shared"},
        {name = "sh_potions_data.lua",      realm = "shared"},
        {name = "sh_hitbox_system.lua",     realm = "shared"},
        {name = "sh_damage_types.lua",      realm = "shared"},
        {name = "sh_area_shapes.lua",       realm = "shared"},
        {name = "sh_skills_core.lua",       realm = "shared"},
    }},
    
    -- Серверные файлы
    {path = "", files = {
        {name = "sv_database.lua",          realm = "server"},
        {name = "sv_potions.lua",           realm = "server"},
        {name = "sv_artifacts_commands.lua", realm = "server"},
        {name = "sv_artifact_slots.lua",    realm = "server"},
        {name = "sv_trade.lua",             realm = "server"},
        {name = "sv_binds.lua",             realm = "server"},
        {name = "sv_energy.lua",            realm = "server"},
    }},
    
    -- Клиентские файлы
    {path = "", files = {
        {name = "cl_ability_hud.lua",       realm = "client"},
        {name = "cl_status_hud.lua",        realm = "client"},
        {name = "cl_f4_integration.lua",    realm = "client"},
        {name = "cl_ability_menu.lua",      realm = "client"},
        {name = "cl_keybinds_unified.lua",  realm = "client"},
        {name = "cl_thirdperson.lua",       realm = "client"},
        {name = "cl_damage_effects.lua",    realm = "client"},
        {name = "cl_potions.lua",           realm = "client"},
        {name = "cl_artifact_slots.lua",    realm = "client"},
        {name = "cl_notes_system.lua",      realm = "client"},
        {name = "cl_trade.lua",             realm = "client"},
        {name = "cl_unified_menu.lua",      realm = "client"},
        {name = "cl_artifact_hud.lua",      realm = "client"},
    }},
    
    -- =============================================
    -- COMBAT SYSTEM (Боевая система)
    -- =============================================
    {path = "combat/", files = {
        {name = "sh_combat_core.lua",       realm = "shared"},
        {name = "sh_artifact_templates.lua", realm = "shared"},
        {name = "cl_combat_hud.lua",        realm = "client"},
    }},
    
    -- =============================================
    -- SKILLS SYSTEM (Система скиллов)
    -- =============================================
    {path = "skills/", files = {
        {name = "sh_skills_registry.lua",   realm = "shared"},
        {name = "sv_skills_manager.lua",    realm = "server"},
        {name = "cl_skills_menu.lua",       realm = "client"},
    }},
    
    -- =============================================
    -- TRADE SYSTEM (Система торговли)
    -- =============================================
    {path = "trade/", files = {
        {name = "sv_npc_trader.lua",        realm = "server"},
        {name = "cl_npc_trader.lua",        realm = "client"},
    }},
    
    -- =============================================
    -- UI SYSTEM (Интерфейсы)
    -- =============================================
    {path = "ui/", files = {
        {name = "cl_trade_ui.lua",          realm = "client"},
        {name = "cl_currency_hud.lua",      realm = "client"},
    }},
}

-- =============================================
-- ФУНКЦИЯ ЗАГРУЗКИ
-- =============================================
local function LoadFile(filePath, realm)
    local success = true
    local err = nil
    
    if SERVER then
        if realm == "shared" or realm == "client" then
            AddCSLuaFile(filePath)
        end
        
        if realm == "shared" or realm == "server" then
            local loadSuccess, loadErr = pcall(include, filePath)
            if not loadSuccess then
                success = false
                err = loadErr
            end
        end
    end
    
    if CLIENT and (realm == "shared" or realm == "client") then
        local loadSuccess, loadErr = pcall(include, filePath)
        if not loadSuccess then
            success = false
            err = loadErr
        end
    end
    
    return success, err
end

-- =============================================
-- ЗАГРУЗКА МОДУЛЕЙ
-- =============================================
local loadedCount = 0
local errorCount = 0

for _, module in ipairs(MODULES) do
    for _, fileData in ipairs(module.files) do
        local fullPath = basePath .. module.path .. fileData.name
        local success, err = LoadFile(fullPath, fileData.realm)
        
        if success then
            loadedCount = loadedCount + 1
        else
            errorCount = errorCount + 1
            MsgC(Color(255, 100, 100), "[LOTM] ✗ ", Color(255, 255, 255), 
                 fileData.name .. ": " .. tostring(err) .. "\n")
        end
    end
end

-- =============================================
-- ИТОГ
-- =============================================
MsgC(Color(211, 25, 202), "═══════════════════════════════════════════\n")
MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
     "Loaded: " .. loadedCount .. " files")

if errorCount > 0 then
    MsgC(Color(255, 100, 100), " | Errors: " .. errorCount)
end

MsgC(Color(255, 255, 255), "\n")
MsgC(Color(211, 25, 202), "[LOTM] ", Color(255, 255, 255), "LOTM v4.0 - Zero Abyss initialized!\n")
MsgC(Color(211, 25, 202), "═══════════════════════════════════════════\n")
