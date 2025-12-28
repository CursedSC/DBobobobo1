-- ============================================
-- Система артефактов для DBT
-- Автор: Senior Developer
-- Дата: 28.12.2025
-- ============================================

dbt.artifacts = dbt.artifacts or {}
dbt.artifacts.SLOTS = 3 -- Количество слотов для артефактов
dbt.artifacts.registry = {} -- Реестр всех артефактов

-- Типы артефактов
dbt.artifacts.TYPES = {
    DEFENSE = "defense",
    ATTACK = "attack",
    UTILITY = "utility",
    SUPPORT = "support"
}

-- Базовый класс артефакта
local ArtifactBase = {}
ArtifactBase.__index = ArtifactBase

function ArtifactBase:New(data)
    local artifact = setmetatable({}, self)
    
    artifact.id = data.id or 0
    artifact.name = data.name or "Неизвестный артефакт"
    artifact.description = data.description or "Описание отсутствует"
    artifact.artifactType = data.artifactType or dbt.artifacts.TYPES.UTILITY
    artifact.model = data.model or "models/props_lab/huladoll.mdl"
    artifact.icon = data.icon or Material("icons/artifact_default.png")
    artifact.rarity = data.rarity or 1 -- 1-5, где 5 = легендарный
    artifact.kg = data.kg or 0.5
    
    -- Колбэки
    artifact.OnEquip = data.OnEquip
    artifact.OnUnequip = data.OnUnequip
    artifact.OnThink = data.OnThink -- Вызывается каждую секунду, пока артефакт экипирован
    
    return artifact
end

-- Регистрация артефакта
function dbt.artifacts.Register(data)
    if not data.id then
        ErrorNoHalt("[DBT Artifacts] Попытка регистрации артефакта без ID!\n")
        return false
    end
    
    local artifact = ArtifactBase:New(data)
    dbt.artifacts.registry[data.id] = artifact
    
    -- Добавляем артефакт в систему инвентаря
    dbt.inventory.items[data.id] = {
        name = artifact.name,
        artifact = true,
        artifactType = artifact.artifactType,
        mdl = artifact.model,
        icon = artifact.icon,
        kg = artifact.kg,
        notEditable = true,
        rarity = artifact.rarity,
        
        GetDescription = function(self)
            local text = {}
            text[#text+1] = color_white
            text[#text+1] = artifact.description
            text[#text+1] = true
            text[#text+1] = Color(200, 200, 50)
            text[#text+1] = "Тип: " .. artifact.artifactType
            text[#text+1] = true
            text[#text+1] = Color(150, 150, 255)
            text[#text+1] = "Редкость: " .. string.rep("★", artifact.rarity)
            return text
        end,
        
        descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Экипировать в слот артефакта (H для использования)"},
        
        OnEquip = artifact.OnEquip,
        OnUnequip = artifact.OnUnequip,
        OnThink = artifact.OnThink
    }
    
    if CLIENT then
        print("[DBT Artifacts] Зарегистрирован артефакт: " .. artifact.name .. " (ID: " .. data.id .. ")")
    end
    
    return true
end

-- Получить артефакт по ID
function dbt.artifacts.Get(id)
    return dbt.artifacts.registry[id]
end

-- Проверка, является ли предмет артефактом
function dbt.artifacts.IsArtifact(itemID)
    local item = dbt.inventory.items[itemID]
    return item and item.artifact == true
end

-- ============================================
-- РЕГИСТРАЦИЯ АРТЕФАКТОВ
-- ============================================

-- Артефакт защиты
dbt.artifacts.Register({
    id = 100,
    name = "Артефакт: Щит Монокумы",
    description = "Древний артефакт, дарующий защиту своему владельцу. Повышает броню на 25 единиц.",
    artifactType = dbt.artifacts.TYPES.DEFENSE,
    model = "models/props_lab/huladoll.mdl",
    icon = Material("icons/artifact_defense.png", "smooth"),
    rarity = 3,
    kg = 0.5,
    
    OnEquip = function(ply)
        if SERVER then
            ply.artifact_defenseActive = true
            ply:SetArmor(math.min(ply:Armor() + 25, 100))
            ply:ChatPrint("[Артефакт] Щит Монокумы активирован! +25 броня")
        end
    end,
    
    OnUnequip = function(ply)
        if SERVER then
            ply.artifact_defenseActive = false
            ply:SetArmor(math.max(0, ply:Armor() - 25))
            ply:ChatPrint("[Артефакт] Щит Монокумы деактивирован.")
        end
    end
})

-- Артефакт атаки
dbt.artifacts.Register({
    id = 101,
    name = "Артефакт: Клык Монобиста",
    description = "Усиливает физические удары владельца. Увеличивает урон в ближнем бою на 15%.",
    artifactType = dbt.artifacts.TYPES.ATTACK,
    model = "models/props_lab/binderredlabel.mdl",
    icon = Material("icons/artifact_attack.png", "smooth"),
    rarity = 4,
    kg = 0.3,
    
    OnEquip = function(ply)
        if SERVER then
            ply.artifact_damageBonus = 1.15
            ply:ChatPrint("[Артефакт] Клык Монобиста активирован! +15% урона")
        end
    end,
    
    OnUnequip = function(ply)
        if SERVER then
            ply.artifact_damageBonus = nil
            ply:ChatPrint("[Артефакт] Клык Монобиста деактивирован.")
        end
    end
})

-- Артефакт восстановления
dbt.artifacts.Register({
    id = 102,
    name = "Артефакт: Сердце Надежды",
    description = "Медленно восстанавливает здоровье владельца. +1 HP каждые 5 секунд.",
    artifactType = dbt.artifacts.TYPES.SUPPORT,
    model = "models/props_c17/doll01.mdl",
    icon = Material("icons/artifact_heal.png", "smooth"),
    rarity = 5,
    kg = 0.4,
    
    OnEquip = function(ply)
        if SERVER then
            ply.artifact_healActive = true
            ply:ChatPrint("[Артефакт] Сердце Надежды активировано! Регенерация HP")
            
            timer.Create("artifact_heal_" .. ply:SteamID(), 5, 0, function()
                if IsValid(ply) and ply:Alive() and ply.artifact_healActive then
                    local newHP = math.min(ply:Health() + 1, ply:GetMaxHealth())
                    ply:SetHealth(newHP)
                end
            end)
        end
    end,
    
    OnUnequip = function(ply)
        if SERVER then
            ply.artifact_healActive = false
            timer.Remove("artifact_heal_" .. ply:SteamID())
            ply:ChatPrint("[Артефакт] Сердце Надежды деактивировано.")
        end
    end
})

-- Артефакт скорости
dbt.artifacts.Register({
    id = 103,
    name = "Артефакт: Крылья Свободы",
    description = "Повышает скорость передвижения владельца на 20%.",
    artifactType = dbt.artifacts.TYPES.UTILITY,
    model = "models/props_lab/clipboard.mdl",
    icon = Material("icons/artifact_speed.png", "smooth"),
    rarity = 3,
    kg = 0.2,
    
    OnEquip = function(ply)
        if SERVER then
            ply.artifact_speedBonus = 1.2
            ply:SetWalkSpeed(ply:GetWalkSpeed() * 1.2)
            ply:SetRunSpeed(ply:GetRunSpeed() * 1.2)
            ply:ChatPrint("[Артефакт] Крылья Свободы активированы! +20% скорость")
        end
    end,
    
    OnUnequip = function(ply)
        if SERVER then
            ply.artifact_speedBonus = nil
            ply:SetWalkSpeed(ply:GetWalkSpeed() / 1.2)
            ply:SetRunSpeed(ply:GetRunSpeed() / 1.2)
            ply:ChatPrint("[Артефакт] Крылья Свободы деактивированы.")
        end
    end
})

-- Артефакт восприятия
dbt.artifacts.Register({
    id = 104,
    name = "Артефакт: Глаз Истины",
    description = "Позволяет видеть скрытую информацию о других игроках.",
    artifactType = dbt.artifacts.TYPES.UTILITY,
    model = "models/maxofs2d/camera.mdl",
    icon = Material("icons/artifact_vision.png", "smooth"),
    rarity = 4,
    kg = 0.3,
    
    OnEquip = function(ply)
        if SERVER then
            ply.artifact_enhancedVision = true
            ply:ChatPrint("[Артефакт] Глаз Истины активирован! Улучшенное восприятие")
        end
    end,
    
    OnUnequip = function(ply)
        if SERVER then
            ply.artifact_enhancedVision = false
            ply:ChatPrint("[Артефакт] Глаз Истины деактивирован.")
        end
    end
})

print("[DBT] Система артефактов загружена. Зарегистрировано артефактов: " .. table.Count(dbt.artifacts.registry))