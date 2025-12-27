-- LOTM Artifact System
-- Система артефактов с баффами, дебаффами, способностями и резистами
-- Интегрирована с инвентарем

LOTM = LOTM or {}
LOTM.Artifacts = LOTM.Artifacts or {}

-- Хранилище зарегистрированных артефактов
LOTM.Artifacts.Registry = LOTM.Artifacts.Registry or {}

-- Экипированные артефакты игроков
-- Структура: EquippedArtifacts[SteamID] = artifactId
LOTM.Artifacts.EquippedArtifacts = LOTM.Artifacts.EquippedArtifacts or {}

-- Кулдауны артефактов
LOTM.Artifacts.Cooldowns = LOTM.Artifacts.Cooldowns or {}

-- =============================================
-- Типы артефактов
-- =============================================
LOTM.Artifacts.Types = {
    SEALED = "sealed",           -- Запечатанный артефакт
    GRADE_0 = "grade_0",         -- Артефакт 0 последовательности
    GRADE_1 = "grade_1",         -- Артефакт 1 последовательности
    GRADE_2 = "grade_2",         -- и т.д.
    GRADE_3 = "grade_3",
    GRADE_4 = "grade_4",
    GRADE_5 = "grade_5",
    GRADE_6 = "grade_6",
    GRADE_7 = "grade_7",
    GRADE_8 = "grade_8",
    GRADE_9 = "grade_9",
    CURSED = "cursed",           -- Проклятый артефакт
    DIVINE = "divine",           -- Божественный артефакт
}

-- Типы резистов
LOTM.Artifacts.ResistTypes = {
    PHYSICAL = "physical",
    FIRE = "fire",
    ICE = "ice",
    LIGHTNING = "lightning",
    POISON = "poison",
    SPIRITUAL = "spiritual",
    MENTAL = "mental",
    CORRUPTION = "corruption",
}

-- =============================================
-- Регистрация артефакта
-- =============================================

function LOTM.Artifacts.Register(artifactData)
    if not artifactData.id then
        ErrorNoHalt("[LOTM Artifacts] Ошибка: отсутствует id\n")
        return false
    end
    
    -- Значения по умолчанию
    artifactData.name = artifactData.name or "Неизвестный Артефакт"
    artifactData.description = artifactData.description or ""
    artifactData.type = artifactData.type or LOTM.Artifacts.Types.SEALED
    artifactData.icon = artifactData.icon or "lotm/artifacts/default.png"
    artifactData.model = artifactData.model or "models/props_lab/box01a.mdl"
    
    -- Бонусы и штрафы
    artifactData.buffs = artifactData.buffs or {}
    artifactData.debuffs = artifactData.debuffs or {}
    artifactData.resistances = artifactData.resistances or {}
    artifactData.vulnerabilities = artifactData.vulnerabilities or {}
    
    -- Способность артефакта
    artifactData.ability = artifactData.ability or nil
    artifactData.abilityCooldown = artifactData.abilityCooldown or 60
    artifactData.abilityEnergyCost = artifactData.abilityEnergyCost or 0
    
    -- Требования
    artifactData.requirements = artifactData.requirements or {}
    
    -- Эффекты при экипировке
    artifactData.onEquip = artifactData.onEquip or nil
    artifactData.onUnequip = artifactData.onUnequip or nil
    artifactData.onUse = artifactData.onUse or nil
    
    LOTM.Artifacts.Registry[artifactData.id] = artifactData
    
    MsgC(Color(255, 215, 100), "[LOTM Artifacts] ", Color(255, 255, 255), 
         "Артефакт зарегистрирован: " .. artifactData.name .. "\n")
    
    return true
end

-- Получить артефакт по ID
function LOTM.Artifacts.Get(artifactId)
    return LOTM.Artifacts.Registry[artifactId]
end

-- =============================================
-- Экипировка артефактов
-- =============================================

local function GetPlayerID(ply)
    return ply:SteamID64() or ply:UniqueID()
end

-- Проверка требований
function LOTM.Artifacts.MeetsRequirements(ply, artifactId)
    local artifact = LOTM.Artifacts.Get(artifactId)
    if not artifact then return false, "Артефакт не найден" end
    
    local reqs = artifact.requirements
    
    -- Проверка последовательности
    if reqs.minSequence then
        local playerSeq = ply:GetNWInt("LOTM_Sequence", 9)
        if playerSeq > reqs.minSequence then
            return false, "Требуется последовательность " .. reqs.minSequence .. " или выше"
        end
    end
    
    -- Проверка пути
    if reqs.pathway then
        local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
        if playerPathway ~= reqs.pathway then
            return false, "Требуется путь " .. LOTM.GetPathwayName(reqs.pathway)
        end
    end
    
    -- Кастомная проверка
    if reqs.custom then
        local result, reason = reqs.custom(ply)
        if not result then
            return false, reason or "Требования не выполнены"
        end
    end
    
    return true
end

-- Экипировать артефакт
function LOTM.Artifacts.Equip(ply, artifactId)
    if not IsValid(ply) then return false, "Игрок не найден" end
    
    local artifact = LOTM.Artifacts.Get(artifactId)
    if not artifact then return false, "Артефакт не найден" end
    
    -- Проверка требований
    local meetsReqs, reason = LOTM.Artifacts.MeetsRequirements(ply, artifactId)
    if not meetsReqs then
        return false, reason
    end
    
    local pid = GetPlayerID(ply)
    
    -- Снимаем текущий артефакт
    local currentArtifact = LOTM.Artifacts.EquippedArtifacts[pid]
    if currentArtifact then
        LOTM.Artifacts.Unequip(ply)
    end
    
    -- Экипируем новый
    LOTM.Artifacts.EquippedArtifacts[pid] = artifactId
    
    -- Применяем эффекты экипировки
    if SERVER then
        -- Применяем баффы
        for stat, value in pairs(artifact.buffs) do
            LOTM.Artifacts.ApplyBuff(ply, stat, value)
        end
        
        -- Применяем дебаффы
        for stat, value in pairs(artifact.debuffs) do
            LOTM.Artifacts.ApplyDebuff(ply, stat, value)
        end
        
        -- Вызываем onEquip
        if artifact.onEquip then
            artifact.onEquip(ply, artifact)
        end
        
        -- Синхронизация
        LOTM.Artifacts.SyncToClient(ply)
    end
    
    return true
end

-- Снять артефакт
function LOTM.Artifacts.Unequip(ply)
    if not IsValid(ply) then return false end
    
    local pid = GetPlayerID(ply)
    local artifactId = LOTM.Artifacts.EquippedArtifacts[pid]
    
    if not artifactId then return false end
    
    local artifact = LOTM.Artifacts.Get(artifactId)
    
    if SERVER and artifact then
        -- Убираем баффы
        for stat, value in pairs(artifact.buffs) do
            LOTM.Artifacts.RemoveBuff(ply, stat, value)
        end
        
        -- Убираем дебаффы
        for stat, value in pairs(artifact.debuffs) do
            LOTM.Artifacts.RemoveDebuff(ply, stat, value)
        end
        
        -- Вызываем onUnequip
        if artifact.onUnequip then
            artifact.onUnequip(ply, artifact)
        end
    end
    
    LOTM.Artifacts.EquippedArtifacts[pid] = nil
    
    if SERVER then
        LOTM.Artifacts.SyncToClient(ply)
    end
    
    return true
end

-- Получить экипированный артефакт
function LOTM.Artifacts.GetEquipped(ply)
    if not IsValid(ply) then return nil end
    
    local pid = GetPlayerID(ply)
    local artifactId = LOTM.Artifacts.EquippedArtifacts[pid]
    
    if artifactId then
        return LOTM.Artifacts.Get(artifactId)
    end
    
    return nil
end

-- =============================================
-- Использование способности артефакта
-- =============================================

function LOTM.Artifacts.UseAbility(ply)
    if not IsValid(ply) then return false, "Игрок не найден" end
    
    local artifact = LOTM.Artifacts.GetEquipped(ply)
    if not artifact then return false, "Артефакт не экипирован" end
    
    if not artifact.ability and not artifact.onUse then
        return false, "Артефакт не имеет активной способности"
    end
    
    -- Проверка кулдауна
    local pid = GetPlayerID(ply)
    if not LOTM.Artifacts.Cooldowns[pid] then
        LOTM.Artifacts.Cooldowns[pid] = {}
    end
    
    local cooldownEnd = LOTM.Artifacts.Cooldowns[pid][artifact.id]
    if cooldownEnd and CurTime() < cooldownEnd then
        local remaining = cooldownEnd - CurTime()
        return false, string.format("Кулдаун: %.1f сек", remaining)
    end
    
    -- Проверка энергии
    if LOTM.Energy and artifact.abilityEnergyCost > 0 then
        local currentEnergy = LOTM.Energy.GetEnergy(ply) or 0
        if currentEnergy < artifact.abilityEnergyCost then
            return false, "Недостаточно энергии"
        end
    end
    
    if SERVER then
        -- Расход энергии
        if LOTM.Energy and artifact.abilityEnergyCost > 0 then
            LOTM.Energy.UseEnergy(ply, artifact.abilityEnergyCost)
        end
        
        -- Установка кулдауна
        LOTM.Artifacts.Cooldowns[pid][artifact.id] = CurTime() + artifact.abilityCooldown
        
        -- Если есть связанная способность
        if artifact.ability and LOTM.Abilities then
            local ability = LOTM.Abilities.Get(artifact.ability)
            if ability and ability.onCast then
                ability.onCast(ply, ability)
            end
        end
        
        -- Вызываем onUse
        if artifact.onUse then
            artifact.onUse(ply, artifact)
        end
        
        -- Применяем эффекты
        if artifact.useEffects and LOTM.Effects then
            for _, effectData in ipairs(artifact.useEffects) do
                if type(effectData) == "string" then
                    LOTM.Effects.Apply(ply, effectData)
                elseif type(effectData) == "table" then
                    LOTM.Effects.Apply(ply, effectData.id, effectData)
                end
            end
        end
        
        -- Синхронизация кулдауна
        net.Start("LOTM.Artifacts.SyncCooldown")
        net.WriteString(artifact.id)
        net.WriteFloat(artifact.abilityCooldown)
        net.Send(ply)
    end
    
    return true
end

-- Получить оставшийся кулдаун
function LOTM.Artifacts.GetCooldownRemaining(ply)
    if not IsValid(ply) then return 0 end
    
    local artifact = LOTM.Artifacts.GetEquipped(ply)
    if not artifact then return 0 end
    
    local pid = GetPlayerID(ply)
    if not LOTM.Artifacts.Cooldowns[pid] then return 0 end
    
    local cooldownEnd = LOTM.Artifacts.Cooldowns[pid][artifact.id]
    if not cooldownEnd then return 0 end
    
    return math.max(0, cooldownEnd - CurTime())
end

-- =============================================
-- Баффы и дебаффы
-- =============================================

function LOTM.Artifacts.ApplyBuff(ply, stat, value)
    if not SERVER then return end
    
    local current = ply:GetNWFloat("LOTM_ArtifactBuff_" .. stat, 0)
    ply:SetNWFloat("LOTM_ArtifactBuff_" .. stat, current + value)
end

function LOTM.Artifacts.RemoveBuff(ply, stat, value)
    if not SERVER then return end
    
    local current = ply:GetNWFloat("LOTM_ArtifactBuff_" .. stat, 0)
    ply:SetNWFloat("LOTM_ArtifactBuff_" .. stat, current - value)
end

function LOTM.Artifacts.ApplyDebuff(ply, stat, value)
    if not SERVER then return end
    
    local current = ply:GetNWFloat("LOTM_ArtifactDebuff_" .. stat, 0)
    ply:SetNWFloat("LOTM_ArtifactDebuff_" .. stat, current + value)
end

function LOTM.Artifacts.RemoveDebuff(ply, stat, value)
    if not SERVER then return end
    
    local current = ply:GetNWFloat("LOTM_ArtifactDebuff_" .. stat, 0)
    ply:SetNWFloat("LOTM_ArtifactDebuff_" .. stat, current - value)
end

-- Получить бонус от артефакта
function LOTM.Artifacts.GetBuff(ply, stat)
    return ply:GetNWFloat("LOTM_ArtifactBuff_" .. stat, 0)
end

-- Получить штраф от артефакта
function LOTM.Artifacts.GetDebuff(ply, stat)
    return ply:GetNWFloat("LOTM_ArtifactDebuff_" .. stat, 0)
end

-- Получить резист
function LOTM.Artifacts.GetResistance(ply, resistType)
    local artifact = LOTM.Artifacts.GetEquipped(ply)
    if not artifact then return 0 end
    
    return artifact.resistances[resistType] or 0
end

-- Получить уязвимость
function LOTM.Artifacts.GetVulnerability(ply, resistType)
    local artifact = LOTM.Artifacts.GetEquipped(ply)
    if not artifact then return 0 end
    
    return artifact.vulnerabilities[resistType] or 0
end

-- =============================================
-- Сетевое взаимодействие
-- =============================================

if SERVER then
    util.AddNetworkString("LOTM.Artifacts.Sync")
    util.AddNetworkString("LOTM.Artifacts.SyncCooldown")
    util.AddNetworkString("LOTM.Artifacts.Use")
    util.AddNetworkString("LOTM.Artifacts.Equip")
    util.AddNetworkString("LOTM.Artifacts.Unequip")
    
    function LOTM.Artifacts.SyncToClient(ply)
        local pid = GetPlayerID(ply)
        local artifactId = LOTM.Artifacts.EquippedArtifacts[pid]
        
        net.Start("LOTM.Artifacts.Sync")
        net.WriteString(artifactId or "")
        net.Send(ply)
    end
    
    -- Обработка запроса использования артефакта
    net.Receive("LOTM.Artifacts.Use", function(len, ply)
        local success, reason = LOTM.Artifacts.UseAbility(ply)
        if not success and reason then
            -- Уведомление игроку
        end
    end)
    
    -- Синхронизация при подключении
    hook.Add("PlayerInitialSpawn", "LOTM.Artifacts.Sync", function(ply)
        timer.Simple(2, function()
            if IsValid(ply) then
                LOTM.Artifacts.SyncToClient(ply)
            end
        end)
    end)
end

if CLIENT then
    -- Синхронизация артефакта
    net.Receive("LOTM.Artifacts.Sync", function()
        local artifactId = net.ReadString()
        local pid = GetPlayerID(LocalPlayer())
        
        LOTM.Artifacts.EquippedArtifacts[pid] = artifactId ~= "" and artifactId or nil
    end)
    
    -- Синхронизация кулдауна
    net.Receive("LOTM.Artifacts.SyncCooldown", function()
        local artifactId = net.ReadString()
        local duration = net.ReadFloat()
        
        local pid = GetPlayerID(LocalPlayer())
        if not LOTM.Artifacts.Cooldowns[pid] then
            LOTM.Artifacts.Cooldowns[pid] = {}
        end
        
        LOTM.Artifacts.Cooldowns[pid][artifactId] = CurTime() + duration
    end)
    
    -- Запрос использования артефакта
    function LOTM.Artifacts.RequestUse()
        net.Start("LOTM.Artifacts.Use")
        net.SendToServer()
    end
end

-- Привязка клавиши H
hook.Add("PlayerButtonDown", "LOTM.Artifacts.UseKey", function(ply, button)
    if button == KEY_H then
        if CLIENT then
            LOTM.Artifacts.RequestUse()
        end
    end
end)

-- =============================================
-- Примеры артефактов
-- =============================================

-- Кольцо Силы
LOTM.Artifacts.Register({
    id = "ring_of_power",
    name = "Кольцо Силы",
    description = "Увеличивает физический урон, но снижает защиту",
    type = LOTM.Artifacts.Types.GRADE_5,
    icon = "lotm/artifacts/ring_of_power.png",
    model = "models/props_lab/huladoll.mdl",
    
    buffs = {
        damage = 25,
        attack_speed = 10,
    },
    
    debuffs = {
        defense = 15,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.PHYSICAL] = 10,
    },
    
    vulnerabilities = {
        [LOTM.Artifacts.ResistTypes.SPIRITUAL] = 20,
    },
    
    ability = nil,
    abilityCooldown = 30,
    
    useEffects = {
        {id = "empowered", duration = 10},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            -- Взрыв урона вокруг
        end
    end,
    
    requirements = {
        minSequence = 7,
    },
})

-- Амулет Защиты
LOTM.Artifacts.Register({
    id = "amulet_of_protection",
    name = "Амулет Защиты",
    description = "Создает защитный барьер при активации",
    type = LOTM.Artifacts.Types.GRADE_6,
    icon = "lotm/artifacts/amulet_protection.png",
    
    buffs = {
        defense = 20,
        health = 50,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.PHYSICAL] = 15,
        [LOTM.Artifacts.ResistTypes.FIRE] = 10,
        [LOTM.Artifacts.ResistTypes.ICE] = 10,
    },
    
    abilityCooldown = 45,
    
    useEffects = {
        {id = "shielded", duration = 8, amount = 75},
    },
})

-- Проклятый Клинок
LOTM.Artifacts.Register({
    id = "cursed_blade",
    name = "Проклятый Клинок",
    description = "Мощное оружие, но наносит урон владельцу",
    type = LOTM.Artifacts.Types.CURSED,
    icon = "lotm/artifacts/cursed_blade.png",
    
    buffs = {
        damage = 50,
        critical = 25,
    },
    
    debuffs = {
        health_regen = -5,
    },
    
    vulnerabilities = {
        [LOTM.Artifacts.ResistTypes.CORRUPTION] = 30,
    },
    
    abilityCooldown = 20,
    
    useEffects = {
        {id = "empowered", duration = 15},
        {id = "burning", duration = 5, damage = 3}, -- Самоповреждение
    },
    
    onEquip = function(ply, artifact)
        if SERVER then
            ply:ChatPrint("[Проклятый Клинок шепчет вам на ухо...]")
        end
    end,
})

-- Слеза Богини
LOTM.Artifacts.Register({
    id = "goddess_tear",
    name = "Слеза Богини",
    description = "Божественный артефакт с мощным исцелением",
    type = LOTM.Artifacts.Types.DIVINE,
    icon = "lotm/artifacts/goddess_tear.png",
    
    buffs = {
        health = 100,
        health_regen = 10,
        energy = 50,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.SPIRITUAL] = 30,
        [LOTM.Artifacts.ResistTypes.CORRUPTION] = 50,
    },
    
    abilityCooldown = 120,
    
    useEffects = {
        {id = "regeneration", duration = 20, heal = 10},
        {id = "elemental_protection", duration = 30},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            -- Полное исцеление
            ply:SetHealth(ply:GetMaxHealth())
            -- Убираем негативные эффекты
            if LOTM.Effects then
                LOTM.Effects.Remove(ply, "burning")
                LOTM.Effects.Remove(ply, "poisoned")
                LOTM.Effects.Remove(ply, "weakened")
            end
        end
    end,
    
    requirements = {
        minSequence = 3,
    },
})

-- Маска Тени
LOTM.Artifacts.Register({
    id = "shadow_mask",
    name = "Маска Тени",
    description = "Позволяет становиться невидимым",
    type = LOTM.Artifacts.Types.GRADE_4,
    icon = "lotm/artifacts/shadow_mask.png",
    
    buffs = {
        speed = 15,
        stealth = 30,
    },
    
    debuffs = {
        defense = 10,
    },
    
    abilityCooldown = 60,
    abilityEnergyCost = 40,
    
    useEffects = {
        {id = "invisible", duration = 15},
        {id = "haste", duration = 10, percent = 1.2},
    },
    
    requirements = {
        minSequence = 5,
    },
})

print("[LOTM] Artifact system loaded")

