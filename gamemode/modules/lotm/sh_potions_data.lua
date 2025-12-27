-- LOTM Potion Database
-- База данных зелий и способностей

if not LOTM then return end

-- ======================
-- SEER PATHWAY
-- ======================

-- Sequence 9: Seer
local seer_s9_abilities = {
    LOTM.CreateAbility({
        ID = "seer_s9_divination",
        Name = "Divination",
        Description = "Базовое гадание. Позволяет получить расплывчатую информацию о будущем.",
        Type = LOTM.ABILITY_TYPES.ACTIVE,
        EnergyCost = 15,
        Cooldown = 30,
        Slot = 1,
        OnActivate = function(ply)
            if CLIENT then return end
            ply:ChatPrint("[Divination] Вы концентрируетесь на предмете гадания...")
            -- Логика способности будет добавлена позже
        end
    }),
    
    LOTM.CreateAbility({
        ID = "seer_s9_danger_premonition",
        Name = "Danger Premonition",
        Description = "Пассивное предчувствие опасности.",
        Type = LOTM.ABILITY_TYPES.PASSIVE,
        EnergyCost = 0,
        Slot = 0,
        OnPassive = function(ply)
            -- Пассивная логика обрабатывается в sv_potions.lua
        end
    })
}

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "seer_s9",
    Name = "Seer",
    Sequence = 9,
    Description = "Зелье начального уровня пути Провидца. Дает базовые способности к гаданию.",
    Abilities = seer_s9_abilities,
    DigestionRate = 0.05,
    MadnessRisk = 0.15,
    Model = "models/props_junk/PopCan01a.mdl"
}))

-- Sequence 8: Clown
local clown_s8_abilities = {
    LOTM.CreateAbility({
        ID = "clown_s8_flame_control",
        Name = "Flame Control",
        Description = "Управление небольшим количеством огня.",
        Type = LOTM.ABILITY_TYPES.ACTIVE,
        EnergyCost = 20,
        Cooldown = 15,
        Slot = 1,
        OnActivate = function(ply)
            if CLIENT then return end
            -- Создание небольшого огненного шара
        end
    }),
    
    LOTM.CreateAbility({
        ID = "clown_s8_paper_figurine",
        Name = "Paper Figurine Substitute",
        Description = "Создание бумажной фигурки для замещения.",
        Type = LOTM.ABILITY_TYPES.ACTIVE,
        EnergyCost = 35,
        Cooldown = 60,
        Slot = 2,
        OnActivate = function(ply)
            if CLIENT then return end
            -- Создание фигурки
        end
    }),
    
    LOTM.CreateAbility({
        ID = "clown_s8_enhanced_agility",
        Name = "Enhanced Agility",
        Description = "Повышенная ловкость и акробатика.",
        Type = LOTM.ABILITY_TYPES.PASSIVE,
        EnergyCost = 0,
        Slot = 0,
        OnPassive = function(ply)
            -- Увеличение скорости передвижения
        end
    })
}

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "clown_s8",
    Name = "Clown",
    Sequence = 8,
    Description = "Зелье второго уровня пути Провидца. Дает способности к огненной магии и акробатике.",
    Abilities = clown_s8_abilities,
    DigestionRate = 0.04,
    MadnessRisk = 0.20,
    Model = "models/props_junk/PopCan01a.mdl"
}))

-- ======================
-- MONSTER PATHWAY
-- ======================

-- Sequence 9: Hunter
local hunter_s9_abilities = {
    LOTM.CreateAbility({
        ID = "hunter_s9_tracking",
        Name = "Enhanced Tracking",
        Description = "Улучшенная способность к выслеживанию целей.",
        Type = LOTM.ABILITY_TYPES.PASSIVE,
        EnergyCost = 0,
        Slot = 0,
        OnPassive = function(ply)
            -- Показывать следы игроков
        end
    }),
    
    LOTM.CreateAbility({
        ID = "hunter_s9_precise_shot",
        Name = "Precise Shot",
        Description = "Невероятно точный выстрел.",
        Type = LOTM.ABILITY_TYPES.ACTIVE,
        EnergyCost = 25,
        Cooldown = 20,
        Slot = 1,
        OnActivate = function(ply)
            if CLIENT then return end
            -- Усиление следующего выстрела
        end
    })
}

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "hunter_s9",
    Name = "Hunter",
    Sequence = 9,
    Description = "Зелье начального уровня пути Чудовища. Превосходные навыки охотника.",
    Abilities = hunter_s9_abilities,
    DigestionRate = 0.06,
    MadnessRisk = 0.12,
    Model = "models/props_junk/PopCan01a.mdl"
}))

-- ======================
-- SPECTATOR PATHWAY  
-- ======================

-- Sequence 9: Spectator
local spectator_s9_abilities = {
    LOTM.CreateAbility({
        ID = "spectator_s9_read_minds",
        Name = "Mind Reading",
        Description = "Чтение поверхностных мыслей.",
        Type = LOTM.ABILITY_TYPES.ACTIVE,
        EnergyCost = 20,
        Cooldown = 25,
        Slot = 1,
        OnActivate = function(ply)
            if CLIENT then return end
            -- Показать последнее сообщение в чате цели
        end
    }),
    
    LOTM.CreateAbility({
        ID = "spectator_s9_psychological_insight",
        Name = "Psychological Insight",
        Description = "Понимание психологического состояния.",
        Type = LOTM.ABILITY_TYPES.PASSIVE,
        EnergyCost = 0,
        Slot = 0,
        OnPassive = function(ply)
            -- Показывать HP и статус других игроков
        end
    })
}

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "spectator_s9",
    Name = "Spectator",
    Sequence = 9,
    Description = "Зелье начального уровня пути Наблюдателя. Ментальные способности.",
    Abilities = spectator_s9_abilities,
    DigestionRate = 0.045,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl"
}))

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Loaded ", Color(255, 200, 100), tostring(table.Count(LOTM.Potions)), Color(255, 255, 255), " potions\n")