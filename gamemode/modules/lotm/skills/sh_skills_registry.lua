-- LOTM Skills Registry v3.0
-- Система скиллов: 3 активных + 2 пассивки на каждую последовательность
-- Ограничение: нельзя взять все скиллы

LOTM = LOTM or {}
LOTM.Skills = LOTM.Skills or {}
LOTM.Skills.Registry = LOTM.Skills.Registry or {}
LOTM.Skills.PlayerData = LOTM.Skills.PlayerData or {}

-- Константы
LOTM.Skills.MAX_ACTIVE_PER_SEQ = 2   -- Максимум активных скиллов из 3 доступных
LOTM.Skills.MAX_PASSIVE_PER_SEQ = 1  -- Максимум пассивок из 2 доступных
LOTM.Skills.TOTAL_SKILLS_PER_SEQ = 5 -- Всего скиллов на последовательность (3 актив + 2 пассив)
LOTM.Skills.MAX_UNLOCKABLE_PER_SEQ = 3 -- Максимум разблокированных скиллов на seq (2 актив + 1 пассив)

-- Типы скиллов
LOTM.Skills.Types = {
    ACTIVE = "active",
    PASSIVE = "passive",
}

-- Создание скилла
function LOTM.Skills.Create(data)
    if not data.id then
        ErrorNoHalt("[LOTM Skills] Error: missing skill id\n")
        return false
    end
    
    local skill = {
        id = data.id,
        name = data.name or "Неизвестный скилл",
        description = data.description or "",
        icon = data.icon or "vgui/notices/generic",
        
        -- Тип скилла
        skillType = data.skillType or LOTM.Skills.Types.ACTIVE,
        
        -- Привязка к пути и последовательности
        pathway = data.pathway,           -- ID пути (nil = универсальный)
        sequence = data.sequence or 9,    -- Последовательность для разблокировки
        slotIndex = data.slotIndex or 1,  -- Индекс в ряду (1-3 для активных, 1-2 для пассивных)
        
        -- Для активных скиллов
        cooldown = data.cooldown or 10,
        castTime = data.castTime or 0,
        maxCharges = data.maxCharges or 1,
        chargeRegenTime = data.chargeRegenTime or 5,
        
        -- Для пассивных скиллов
        bonuses = data.bonuses or {},     -- {stat = value}
        
        -- Эффекты
        selfEffects = data.selfEffects or {},
        targetEffects = data.targetEffects or {},
        damage = data.damage or {enabled = false},
        healing = data.healing or {enabled = false},
        
        -- Визуал
        visuals = data.visuals or {},
        animation = data.animation or {},
        
        -- Кастомная логика
        onCast = data.onCast,
        onHit = data.onHit,
        onApply = data.onApply,  -- Для пассивок
        onRemove = data.onRemove,  -- Для пассивок
    }
    
    -- Создаём ключ для группировки
    skill.groupKey = string.format("%d_%d_%s", skill.pathway or 0, skill.sequence, skill.skillType)
    
    LOTM.Skills.Registry[skill.id] = skill
    return true
end

-- Получить скилл по ID
function LOTM.Skills.Get(skillId)
    return LOTM.Skills.Registry[skillId]
end

-- Получить все скиллы для последовательности пути
function LOTM.Skills.GetForSequence(pathway, sequence)
    local result = {
        active = {},
        passive = {}
    }
    
    for id, skill in pairs(LOTM.Skills.Registry) do
        local pathMatch = skill.pathway == nil or skill.pathway == pathway
        local seqMatch = skill.sequence == sequence
        
        if pathMatch and seqMatch then
            if skill.skillType == LOTM.Skills.Types.ACTIVE then
                table.insert(result.active, skill)
            else
                table.insert(result.passive, skill)
            end
        end
    end
    
    -- Сортируем по индексу слота
    table.sort(result.active, function(a, b) return (a.slotIndex or 1) < (b.slotIndex or 1) end)
    table.sort(result.passive, function(a, b) return (a.slotIndex or 1) < (b.slotIndex or 1) end)
    
    return result
end

-- Получить все скиллы для пути (все последовательности)
function LOTM.Skills.GetForPathway(pathway)
    local result = {}
    
    for seq = 9, 0, -1 do
        result[seq] = LOTM.Skills.GetForSequence(pathway, seq)
    end
    
    return result
end

-- =============================================
-- ДАННЫЕ ИГРОКА
-- =============================================

local function GetPlayerID(ply)
    return ply:SteamID64() or ply:UniqueID()
end

-- Инициализация данных игрока
function LOTM.Skills.InitPlayer(ply)
    local pid = GetPlayerID(ply)
    if not LOTM.Skills.PlayerData[pid] then
        LOTM.Skills.PlayerData[pid] = {
            unlocked = {},        -- {skillId = true}
            equipped = {},        -- {slot = skillId}
            skillPoints = 0,
            totalSpent = 0,
        }
    end
    return LOTM.Skills.PlayerData[pid]
end

-- Получить данные игрока
function LOTM.Skills.GetPlayerData(ply)
    local pid = GetPlayerID(ply)
    return LOTM.Skills.PlayerData[pid] or LOTM.Skills.InitPlayer(ply)
end

-- Проверить, разблокирован ли скилл
function LOTM.Skills.IsUnlocked(ply, skillId)
    local data = LOTM.Skills.GetPlayerData(ply)
    return data.unlocked[skillId] == true
end

-- Подсчитать разблокированные скиллы в группе (seq + type)
function LOTM.Skills.CountUnlockedInGroup(ply, pathway, sequence, skillType)
    local count = 0
    local skills = LOTM.Skills.GetForSequence(pathway, sequence)
    local skillList = skillType == LOTM.Skills.Types.ACTIVE and skills.active or skills.passive
    
    for _, skill in ipairs(skillList) do
        if LOTM.Skills.IsUnlocked(ply, skill.id) then
            count = count + 1
        end
    end
    
    return count
end

-- Проверить, можно ли разблокировать скилл
function LOTM.Skills.CanUnlock(ply, skillId)
    local skill = LOTM.Skills.Get(skillId)
    if not skill then return false, "Скилл не найден" end
    
    -- Уже разблокирован?
    if LOTM.Skills.IsUnlocked(ply, skillId) then
        return false, "Уже разблокирован"
    end
    
    -- Проверка последовательности игрока
    local playerSeq = ply:GetNWInt("LOTM_Sequence", 9)
    if playerSeq > skill.sequence then
        return false, "Требуется Sequence " .. skill.sequence .. " или ниже"
    end
    
    -- Проверка пути
    local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
    if skill.pathway and playerPathway ~= 0 and skill.pathway ~= playerPathway then
        return false, "Этот скилл другого пути"
    end
    
    -- Проверка лимита на тип скилла в этой последовательности
    local maxPerType = skill.skillType == LOTM.Skills.Types.ACTIVE 
        and LOTM.Skills.MAX_ACTIVE_PER_SEQ 
        or LOTM.Skills.MAX_PASSIVE_PER_SEQ
    
    local currentCount = LOTM.Skills.CountUnlockedInGroup(ply, skill.pathway or playerPathway, skill.sequence, skill.skillType)
    
    if currentCount >= maxPerType then
        local typeName = skill.skillType == LOTM.Skills.Types.ACTIVE and "активных скиллов" or "пассивок"
        return false, "Достигнут лимит " .. typeName .. " на этой последовательности (" .. maxPerType .. ")"
    end
    
    -- Проверка очков скиллов
    local data = LOTM.Skills.GetPlayerData(ply)
    if data.skillPoints < 1 then
        return false, "Недостаточно очков скиллов"
    end
    
    return true
end

-- Разблокировать скилл
function LOTM.Skills.Unlock(ply, skillId)
    local canUnlock, reason = LOTM.Skills.CanUnlock(ply, skillId)
    if not canUnlock then
        return false, reason
    end
    
    local data = LOTM.Skills.GetPlayerData(ply)
    data.unlocked[skillId] = true
    data.skillPoints = data.skillPoints - 1
    data.totalSpent = data.totalSpent + 1
    
    local skill = LOTM.Skills.Get(skillId)
    
    -- Для пассивок - применяем бонусы
    if skill.skillType == LOTM.Skills.Types.PASSIVE and skill.onApply then
        skill.onApply(ply, skill)
    end
    
    -- Применяем пассивные бонусы
    if skill.skillType == LOTM.Skills.Types.PASSIVE and skill.bonuses then
        for stat, value in pairs(skill.bonuses) do
            local current = ply:GetNWFloat("LOTM_Bonus_" .. stat, 0)
            ply:SetNWFloat("LOTM_Bonus_" .. stat, current + value)
        end
    end
    
    return true
end

-- Добавить очки скиллов
function LOTM.Skills.AddPoints(ply, amount)
    local data = LOTM.Skills.GetPlayerData(ply)
    data.skillPoints = data.skillPoints + amount
end

-- Получить очки скиллов
function LOTM.Skills.GetPoints(ply)
    local data = LOTM.Skills.GetPlayerData(ply)
    return data.skillPoints
end

-- Получить разблокированные активные скиллы
function LOTM.Skills.GetUnlockedActive(ply)
    local result = {}
    local data = LOTM.Skills.GetPlayerData(ply)
    
    for skillId, unlocked in pairs(data.unlocked) do
        if unlocked then
            local skill = LOTM.Skills.Get(skillId)
            if skill and skill.skillType == LOTM.Skills.Types.ACTIVE then
                table.insert(result, skill)
            end
        end
    end
    
    return result
end

-- Получить разблокированные пассивки
function LOTM.Skills.GetUnlockedPassive(ply)
    local result = {}
    local data = LOTM.Skills.GetPlayerData(ply)
    
    for skillId, unlocked in pairs(data.unlocked) do
        if unlocked then
            local skill = LOTM.Skills.Get(skillId)
            if skill and skill.skillType == LOTM.Skills.Types.PASSIVE then
                table.insert(result, skill)
            end
        end
    end
    
    return result
end

-- =============================================
-- РЕГИСТРАЦИЯ СКИЛЛОВ
-- =============================================

hook.Add("InitPostEntity", "LOTM.Skills.RegisterAll", function()
    
    -- ========================================
    -- ПУТЬ ДУРАКА (Pathway 1) - Провидение
    -- ========================================
    
    -- Seq 9: Провидец
    LOTM.Skills.Create({
        id = "fool_9_active_1",
        name = "Духовное Видение",
        description = "Вы видите духовные сущности и ауры на 30 секунд",
        icon = "lotm/skills/spirit_vision.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 1, sequence = 9, slotIndex = 1,
        cooldown = 45,
        onCast = function(ply, skill)
            if SERVER then
                ply:SetNWBool("LOTM_SpiritVision", true)
                timer.Simple(30, function()
                    if IsValid(ply) then ply:SetNWBool("LOTM_SpiritVision", false) end
                end)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "fool_9_active_2",
        name = "Гадание",
        description = "Предсказывает опасность в течение 20 секунд",
        icon = "lotm/skills/divination.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 1, sequence = 9, slotIndex = 2,
        cooldown = 60,
        onCast = function(ply, skill)
            if SERVER then
                ply:SetNWBool("LOTM_DangerSense", true)
                timer.Simple(20, function()
                    if IsValid(ply) then ply:SetNWBool("LOTM_DangerSense", false) end
                end)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "fool_9_active_3",
        name = "Медитация",
        description = "Восстанавливает духовность и снимает слабые эффекты",
        icon = "lotm/skills/meditation.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 1, sequence = 9, slotIndex = 3,
        cooldown = 90, castTime = 3,
        onCast = function(ply, skill)
            if SERVER then
                ply:SetHealth(math.min(ply:Health() + 20, ply:GetMaxHealth()))
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "fool_9_passive_1",
        name = "Духовная Чувствительность",
        description = "Увеличивает духовность и интуицию. +10% к духовному урону",
        icon = "lotm/skills/spiritual_sense.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 1, sequence = 9, slotIndex = 1,
        bonuses = {spirituality = 10, intuition = 5},
    })
    
    LOTM.Skills.Create({
        id = "fool_9_passive_2",
        name = "Ясновидение",
        description = "Шанс 10% увидеть атаку заранее и уклониться",
        icon = "lotm/skills/clairvoyance.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 1, sequence = 9, slotIndex = 2,
        bonuses = {dodge_chance = 10},
    })
    
    -- Seq 8: Клоун
    LOTM.Skills.Create({
        id = "fool_8_active_1",
        name = "Перевоплощение",
        description = "Копирует внешность цели на 60 секунд",
        icon = "lotm/skills/disguise.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 1, sequence = 8, slotIndex = 1,
        cooldown = 120,
        onCast = function(ply, skill)
            if SERVER then
                local tr = ply:GetEyeTrace()
                if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
                    local origModel = ply:GetModel()
                    ply:SetModel(tr.Entity:GetModel())
                    timer.Simple(60, function()
                        if IsValid(ply) then ply:SetModel(origModel) end
                    end)
                end
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "fool_8_active_2",
        name = "Бумажная Фигурка",
        description = "Создаёт бумажную копию, которая принимает на себя следующий удар",
        icon = "lotm/skills/paper_figurine.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 1, sequence = 8, slotIndex = 2,
        cooldown = 45,
    })
    
    LOTM.Skills.Create({
        id = "fool_8_active_3",
        name = "Выступление",
        description = "Усиливает следующие 3 атаки союзников на 25%",
        icon = "lotm/skills/performance.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 1, sequence = 8, slotIndex = 3,
        cooldown = 60,
    })
    
    LOTM.Skills.Create({
        id = "fool_8_passive_1",
        name = "Мастер Маскировки",
        description = "+25% к скорости бега при переодевании",
        icon = "lotm/skills/master_disguise.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 1, sequence = 8, slotIndex = 1,
        bonuses = {speed_disguised = 25},
    })
    
    LOTM.Skills.Create({
        id = "fool_8_passive_2",
        name = "Артистизм",
        description = "+15% к урону в течение 5 секунд после смены маски",
        icon = "lotm/skills/artistry.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 1, sequence = 8, slotIndex = 2,
        bonuses = {mask_bonus_damage = 15},
    })
    
    -- ========================================
    -- ПУТЬ ТЬМЫ (Pathway 16) - Сны и Кошмары
    -- ========================================
    
    -- Seq 9: Спящий
    LOTM.Skills.Create({
        id = "darkness_9_active_1",
        name = "Ночное Зрение",
        description = "Видеть в темноте как днём на 60 секунд",
        icon = "lotm/skills/night_vision.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 16, sequence = 9, slotIndex = 1,
        cooldown = 30,
        onCast = function(ply, skill)
            if SERVER then
                ply:SetNWBool("LOTM_NightVision", true)
                timer.Simple(60, function()
                    if IsValid(ply) then ply:SetNWBool("LOTM_NightVision", false) end
                end)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "darkness_9_active_2",
        name = "Вход в Сны",
        description = "Становитесь полупрозрачным на 10 секунд",
        icon = "lotm/skills/dream_walk.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 16, sequence = 9, slotIndex = 2,
        cooldown = 45,
        onCast = function(ply, skill)
            if SERVER then
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)
                ply:SetColor(Color(255, 255, 255, 50))
                timer.Simple(10, function()
                    if IsValid(ply) then
                        ply:SetRenderMode(RENDERMODE_NORMAL)
                        ply:SetColor(Color(255, 255, 255, 255))
                    end
                end)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "darkness_9_active_3",
        name = "Сонный Морок",
        description = "Накладывает сонливость на ближайших врагов",
        icon = "lotm/skills/sleepy_fog.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 16, sequence = 9, slotIndex = 3,
        cooldown = 60,
        damage = {enabled = true, amount = 10, type = "mental", radius = 200},
    })
    
    LOTM.Skills.Create({
        id = "darkness_9_passive_1",
        name = "Ночной Охотник",
        description = "+20% к урону в темноте и ночью",
        icon = "lotm/skills/night_hunter.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 16, sequence = 9, slotIndex = 1,
        bonuses = {night_damage = 20},
    })
    
    LOTM.Skills.Create({
        id = "darkness_9_passive_2",
        name = "Отдых во Тьме",
        description = "Регенерация здоровья в тени +2 HP/сек",
        icon = "lotm/skills/shadow_rest.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 16, sequence = 9, slotIndex = 2,
        bonuses = {shadow_regen = 2},
    })
    
    -- Seq 8: Полуночный Поэт
    LOTM.Skills.Create({
        id = "darkness_8_active_1",
        name = "Манипуляция Кровью",
        description = "Контролируйте кровь врагов, нанося урон и замедляя",
        icon = "lotm/skills/blood_manipulation.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 16, sequence = 8, slotIndex = 1,
        cooldown = 12,
        damage = {enabled = true, amount = 35, type = "corruption", range = 300},
        targetEffects = {{id = "slowed", duration = 4, percent = 0.5}},
    })
    
    LOTM.Skills.Create({
        id = "darkness_8_active_2",
        name = "Проклятый Стих",
        description = "Проклятие наносит урон всем в радиусе",
        icon = "lotm/skills/cursed_verse.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 16, sequence = 8, slotIndex = 2,
        cooldown = 20, castTime = 2,
        damage = {enabled = true, amount = 25, type = "mental", radius = 350},
    })
    
    LOTM.Skills.Create({
        id = "darkness_8_active_3",
        name = "Высасывание Крови",
        description = "Высасывает жизнь врага, исцеляя себя",
        icon = "lotm/skills/blood_drain.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 16, sequence = 8, slotIndex = 3,
        maxCharges = 3, chargeRegenTime = 8,
        damage = {enabled = true, amount = 20, type = "physical", range = 150},
        healing = {enabled = true, amount = 15},
    })
    
    LOTM.Skills.Create({
        id = "darkness_8_passive_1",
        name = "Кровавая Связь",
        description = "Вампиризм: 10% урона возвращается здоровьем",
        icon = "lotm/skills/blood_bond.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 16, sequence = 8, slotIndex = 1,
        bonuses = {lifesteal = 10},
    })
    
    LOTM.Skills.Create({
        id = "darkness_8_passive_2",
        name = "Власть Ночи",
        description = "+15% ко всему урону ночью. +10 к макс. здоровью",
        icon = "lotm/skills/night_power.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 16, sequence = 8, slotIndex = 2,
        bonuses = {night_all_damage = 15, max_health = 10},
    })
    
    -- ========================================
    -- ПУТЬ ВОИНА (Pathway 13) - Боевые искусства
    -- ========================================
    
    -- Seq 9: Воин
    LOTM.Skills.Create({
        id = "warrior_9_active_1",
        name = "Удар Воина",
        description = "Мощный удар с повышенным уроном",
        icon = "lotm/skills/warrior_strike.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 13, sequence = 9, slotIndex = 1,
        cooldown = 8,
        damage = {enabled = true, amount = 40, type = "physical", range = 100},
    })
    
    LOTM.Skills.Create({
        id = "warrior_9_active_2",
        name = "Боевой Клич",
        description = "Повышает атаку союзников в радиусе на 20%",
        icon = "lotm/skills/battle_cry.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 13, sequence = 9, slotIndex = 2,
        cooldown = 30,
    })
    
    LOTM.Skills.Create({
        id = "warrior_9_active_3",
        name = "Защитная Стойка",
        description = "Снижает получаемый урон на 50% на 5 секунд",
        icon = "lotm/skills/defensive_stance.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 13, sequence = 9, slotIndex = 3,
        cooldown = 25,
    })
    
    LOTM.Skills.Create({
        id = "warrior_9_passive_1",
        name = "Закалённое Тело",
        description = "+25 к максимальному здоровью",
        icon = "lotm/skills/hardened_body.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 13, sequence = 9, slotIndex = 1,
        bonuses = {max_health = 25},
        onApply = function(ply, skill)
            if SERVER then
                ply:SetMaxHealth(ply:GetMaxHealth() + 25)
                ply:SetHealth(ply:Health() + 25)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "warrior_9_passive_2",
        name = "Мастерство Оружия",
        description = "+15% к урону ближнего боя",
        icon = "lotm/skills/weapon_mastery.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 13, sequence = 9, slotIndex = 2,
        bonuses = {melee_damage = 15},
    })
    
    -- Seq 8: Гладиатор
    LOTM.Skills.Create({
        id = "warrior_8_active_1",
        name = "Вихрь Клинков",
        description = "Круговая атака по всем врагам вокруг",
        icon = "lotm/skills/blade_whirlwind.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 13, sequence = 8, slotIndex = 1,
        cooldown = 15,
        damage = {enabled = true, amount = 30, type = "physical", radius = 200},
    })
    
    LOTM.Skills.Create({
        id = "warrior_8_active_2",
        name = "Казнь",
        description = "Добивающий удар. +100% урона если цель ниже 30% здоровья",
        icon = "lotm/skills/execution.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 13, sequence = 8, slotIndex = 2,
        cooldown = 20,
        damage = {enabled = true, amount = 50, type = "physical", range = 150},
    })
    
    LOTM.Skills.Create({
        id = "warrior_8_active_3",
        name = "Неудержимый Натиск",
        description = "Рывок вперёд с ударом",
        icon = "lotm/skills/unstoppable_charge.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        pathway = 13, sequence = 8, slotIndex = 3,
        cooldown = 12,
        onCast = function(ply, skill)
            if SERVER then
                local vel = ply:GetAimVector() * 600
                vel.z = 100
                ply:SetVelocity(vel)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "warrior_8_passive_1",
        name = "Гладиаторская Выносливость",
        description = "+20% к регенерации стамины",
        icon = "lotm/skills/gladiator_endurance.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 13, sequence = 8, slotIndex = 1,
        bonuses = {stamina_regen = 20},
    })
    
    LOTM.Skills.Create({
        id = "warrior_8_passive_2",
        name = "Критический Глаз",
        description = "+15% шанс критического удара",
        icon = "lotm/skills/critical_eye.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        pathway = 13, sequence = 8, slotIndex = 2,
        bonuses = {crit_chance = 15},
    })
    
    -- ========================================
    -- УНИВЕРСАЛЬНЫЕ СКИЛЛЫ
    -- ========================================
    
    -- Seq 9 универсальные
    LOTM.Skills.Create({
        id = "universal_9_active_1",
        name = "Духовный Удар",
        description = "Базовая атака духовной энергией",
        icon = "lotm/skills/spirit_strike.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        sequence = 9, slotIndex = 1,
        maxCharges = 3, chargeRegenTime = 5,
        damage = {enabled = true, amount = 25, type = "spiritual", range = 150},
    })
    
    LOTM.Skills.Create({
        id = "universal_9_active_2",
        name = "Малое Исцеление",
        description = "Восстанавливает 25 здоровья",
        icon = "lotm/skills/minor_heal.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        sequence = 9, slotIndex = 2,
        cooldown = 30,
        healing = {enabled = true, amount = 25},
        onCast = function(ply, skill)
            if SERVER then
                ply:SetHealth(math.min(ply:Health() + 25, ply:GetMaxHealth()))
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "universal_9_active_3",
        name = "Уклонение",
        description = "Быстрый рывок в сторону",
        icon = "lotm/skills/dodge.png",
        skillType = LOTM.Skills.Types.ACTIVE,
        sequence = 9, slotIndex = 3,
        maxCharges = 2, chargeRegenTime = 4,
        onCast = function(ply, skill)
            if SERVER then
                local dir = ply:GetAimVector()
                if ply:KeyDown(IN_BACK) then dir = -dir end
                if ply:KeyDown(IN_MOVELEFT) then dir = -ply:GetRight() end
                if ply:KeyDown(IN_MOVERIGHT) then dir = ply:GetRight() end
                
                local vel = dir * 400
                vel.z = 100
                ply:SetVelocity(vel)
            end
        end,
    })
    
    LOTM.Skills.Create({
        id = "universal_9_passive_1",
        name = "Живучесть",
        description = "+10 к максимальному здоровью",
        icon = "lotm/skills/vitality.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        sequence = 9, slotIndex = 1,
        bonuses = {max_health = 10},
    })
    
    LOTM.Skills.Create({
        id = "universal_9_passive_2",
        name = "Проворство",
        description = "+5% к скорости бега",
        icon = "lotm/skills/agility.png",
        skillType = LOTM.Skills.Types.PASSIVE,
        sequence = 9, slotIndex = 2,
        bonuses = {run_speed = 5},
    })
    
    MsgC(Color(100, 255, 100), "[LOTM Skills] ", Color(255, 255, 255), 
         "Registered: " .. table.Count(LOTM.Skills.Registry) .. " skills\n")
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Skills Registry v3.0 loaded\n")
