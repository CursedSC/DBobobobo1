-- LOTM Skill System - Shared
-- Система скиллов с формами AoE, типами урона и резистами

-- Типы урона LOTM
LOTM_DAMAGE_TYPES = {
    PHYSICAL = 1,      -- Физический урон
    MYSTICAL = 2,      -- Мистический урон
    SPIRITUAL = 3,     -- Духовный урон
    MENTAL = 4,        -- Ментальный урон
    CURSE = 5,         -- Проклятие
    CORRUPTION = 6,    -- Искажение
    DIVINE = 7,        -- Божественный
    SHADOW = 8,        -- Теневой
    FLAME = 9,         -- Огненный
    FROST = 10,        -- Ледяной
    LIGHTNING = 11,    -- Молния
    POISON = 12,       -- Яд
    BLOOD = 13,        -- Кровь
    CHAOS = 14,        -- Хаос
    VOID = 15,         -- Пустота
}

-- Названия типов урона
LOTM_DAMAGE_NAMES = {
    [LOTM_DAMAGE_TYPES.PHYSICAL] = "Физический",
    [LOTM_DAMAGE_TYPES.MYSTICAL] = "Мистический",
    [LOTM_DAMAGE_TYPES.SPIRITUAL] = "Духовный",
    [LOTM_DAMAGE_TYPES.MENTAL] = "Ментальный",
    [LOTM_DAMAGE_TYPES.CURSE] = "Проклятие",
    [LOTM_DAMAGE_TYPES.CORRUPTION] = "Искажение",
    [LOTM_DAMAGE_TYPES.DIVINE] = "Божественный",
    [LOTM_DAMAGE_TYPES.SHADOW] = "Теневой",
    [LOTM_DAMAGE_TYPES.FLAME] = "Огненный",
    [LOTM_DAMAGE_TYPES.FROST] = "Ледяной",
    [LOTM_DAMAGE_TYPES.LIGHTNING] = "Молния",
    [LOTM_DAMAGE_TYPES.POISON] = "Яд",
    [LOTM_DAMAGE_TYPES.BLOOD] = "Кровь",
    [LOTM_DAMAGE_TYPES.CHAOS] = "Хаос",
    [LOTM_DAMAGE_TYPES.VOID] = "Пустота",
}

-- Формы области действия
LOTM_AOE_SHAPES = {
    SPHERE = 1,        -- Сферический
    BOX = 2,           -- Прямоугольный (для стен/барьеров)
    CYLINDER = 3,      -- Цилиндрический
    CONE = 4,          -- Конусообразный
    RAY = 5,           -- Луч
    CIRCLE = 6,        -- Круг (центр/сверху/снизу)
}

-- Позиция круга
LOTM_CIRCLE_POS = {
    CENTER = 1,        -- По центру
    TOP = 2,           -- Сверху
    BOTTOM = 3,        -- Снизу
}

-- Структура скилла
LOTM_SkillData = {
    id = "",
    name = "",
    description = "",
    
    -- Форма действия
    aoeShape = LOTM_AOE_SHAPES.SPHERE,
    aoeRadius = 100,
    aoeHeight = 200,
    aoeWidth = 100,
    aoeDepth = 100,
    aoeAngle = 60,
    circlePosition = LOTM_CIRCLE_POS.CENTER,
    
    -- Урон
    damageType = LOTM_DAMAGE_TYPES.MYSTICAL,
    baseDamage = 50,
    
    -- Партиклы
    particleEffect = "dbt_skill_default",
    hitParticle = "dbt_hit_default",
    
    -- Кулдаун
    cooldown = 5,
    
    -- Привязка клавиши
    keybind = KEY_NONE,
    sequenceSlot = 1,  -- Позиция в последовательности (1-9)
}

-- Хранилище зарегистрированных скиллов
LOTM_RegisteredSkills = LOTM_RegisteredSkills or {}

-- Регистрация скилла
function LOTM_RegisterSkill(skillData)
    if not skillData.id or skillData.id == "" then
        ErrorNoHalt("[LOTM Skills] Ошибка: ID скилла не указан\n")
        return false
    end
    
    LOTM_RegisteredSkills[skillData.id] = skillData
    print("[LOTM Skills] Зарегистрирован скилл: " .. skillData.name .. " (" .. skillData.id .. ")")
    return true
end

-- Получить скилл по ID
function LOTM_GetSkill(skillID)
    return LOTM_RegisteredSkills[skillID]
end

-- Получить все скиллы
function LOTM_GetAllSkills()
    return LOTM_RegisteredSkills
end