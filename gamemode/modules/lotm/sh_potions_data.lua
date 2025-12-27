<<<<<<< HEAD
-- LOTM Complete Potion Database
-- Полная база данных зелий для всех путей и последовательностей

if not LOTM then return end

-- =============================================
-- ПУТЬ 1: ДУРАК (THE FOOL)
-- =============================================

-- Sequence 9: Провидец (Seer)
LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "fool_s9_seer",
    Name = "Провидец",
    Pathway = 1,
    Sequence = 9,
    Description = "Зелье начального уровня пути Дурака. Дает базовые способности к гаданию и предчувствию опасности.",
    Abilities = {
        LOTM.CreateAbility({ID = "seer_divination", Name = "Гадание", Description = "Получение туманных видений о будущем", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 15, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "seer_danger_sense", Name = "Предчувствие опасности", Description = "Пассивное ощущение угроз", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.15,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"moonflower", "spirit_crystal", "human_blood"},
}))

-- Sequence 8: Клоун (Clown)
LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "fool_s8_clown",
    Name = "Клоун",
    Pathway = 1,
    Sequence = 8,
    Description = "Дает способности к огненной магии, акробатике и иллюзиям.",
    Abilities = {
        LOTM.CreateAbility({ID = "clown_flame", Name = "Контроль пламени", Description = "Управление небольшим огнём", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 15, Slot = 1}),
        LOTM.CreateAbility({ID = "clown_paper", Name = "Бумажная фигурка", Description = "Создание фигурки-заместителя", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 60, Slot = 2}),
        LOTM.CreateAbility({ID = "clown_agility", Name = "Усиленная ловкость", Description = "Повышенная акробатика", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.20,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"bloodroot", "ectoplasm", "ritual_candle"},
}))

-- Sequence 7: Фокусник (Magician)
LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "fool_s7_magician",
    Name = "Фокусник",
    Pathway = 1,
    Sequence = 7,
    Description = "Мастерство иллюзий и фокусов, контроль огня усиливается.",
    Abilities = {
        LOTM.CreateAbility({ID = "magician_illusion", Name = "Иллюзия", Description = "Создание зрительных обманов", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 20, Slot = 1}),
        LOTM.CreateAbility({ID = "magician_fire_control", Name = "Мастерство огня", Description = "Полный контроль пламени", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 15, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.25,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"dream_essence", "void_stone", "pathway_essence"},
}))

-- Sequence 6: Безликий (Faceless)
LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "fool_s6_faceless",
    Name = "Безликий",
    Pathway = 1,
    Sequence = 6,
    Description = "Способность принимать облик других людей.",
    Abilities = {
        LOTM.CreateAbility({ID = "faceless_transform", Name = "Превращение", Description = "Принять облик другого человека", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 120, Slot = 1}),
        LOTM.CreateAbility({ID = "faceless_voice", Name = "Имитация голоса", Description = "Копирование голоса", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 15, Cooldown = 10, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.30,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"soul_fragment", "nightmare_shard", "beyonder_blood"},
}))

-- Sequence 5: Марионетист (Marionettist)
LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "fool_s5_marionettist",
    Name = "Марионетист",
    Pathway = 1,
    Sequence = 5,
    Description = "Контроль над марионетками и духовными нитями.",
    Abilities = {
        LOTM.CreateAbility({ID = "marionette_control", Name = "Контроль марионеток", Description = "Управление куклами", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "marionette_threads", Name = "Духовные нити", Description = "Невидимые нити контроля", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 25, Slot = 2}),
    },
    DigestionRate = 0.025,
    MadnessRisk = 0.35,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"soulvine", "characteristic_fragment", "celestial_ore"},
}))

-- =============================================
-- ПУТЬ 4: ПРОВИДЕЦ (THE SEER/MYSTERY PRYER)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "seer_s9",
    Name = "Провидец",
    Pathway = 4,
    Sequence = 9,
    Description = "Путь познания тайн. Начальные способности к гаданию.",
    Abilities = {
        LOTM.CreateAbility({ID = "seer_basic_div", Name = "Базовое гадание", Description = "Простое гадание", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 10, Cooldown = 20, Slot = 1}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.12,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"moonflower", "silver_dust", "holy_water"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "seer_s8_clown",
    Name = "Клоун",
    Pathway = 4,
    Sequence = 8,
    Description = "Развитие способностей к манипуляции и иллюзиям.",
    Abilities = {
        LOTM.CreateAbility({ID = "seer_clown_trick", Name = "Трюк", Description = "Ловкий фокус", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 15, Cooldown = 15, Slot = 1}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightshade", "ectoplasm", "ritual_candle"},
}))

-- =============================================
-- ПУТЬ 7: ЗРИТЕЛЬ (THE SPECTATOR)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "spectator_s9",
    Name = "Зритель",
    Pathway = 7,
    Sequence = 9,
    Description = "Путь разума. Способности к чтению мыслей.",
    Abilities = {
        LOTM.CreateAbility({ID = "spectator_read", Name = "Чтение мыслей", Description = "Чтение поверхностных мыслей", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 25, Slot = 1}),
        LOTM.CreateAbility({ID = "spectator_insight", Name = "Психологический анализ", Description = "Понимание эмоций", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.045,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"moonflower", "dream_essence", "spirit_crystal"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "spectator_s8_telepathist",
    Name = "Телепат",
    Pathway = 7,
    Sequence = 8,
    Description = "Развитие ментальных способностей. Телепатия.",
    Abilities = {
        LOTM.CreateAbility({ID = "telepathy", Name = "Телепатия", Description = "Мысленная связь", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "mental_shield", Name = "Ментальный щит", Description = "Защита разума", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 45, Slot = 2}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.22,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightmare_shard", "ectoplasm", "beyonder_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "spectator_s7_psychologist",
    Name = "Психолог",
    Pathway = 7,
    Sequence = 7,
    Description = "Глубокое понимание человеческой психики.",
    Abilities = {
        LOTM.CreateAbility({ID = "psycho_analysis", Name = "Глубокий анализ", Description = "Полное понимание личности", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 40, Slot = 1}),
        LOTM.CreateAbility({ID = "psycho_suggest", Name = "Внушение", Description = "Ментальное внушение", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 60, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.28,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"soul_fragment", "pathway_essence", "void_stone"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "spectator_s6_hypnotist",
    Name = "Гипнотизёр",
    Pathway = 7,
    Sequence = 6,
    Description = "Мастер гипноза и контроля сознания.",
    Abilities = {
        LOTM.CreateAbility({ID = "hypnosis", Name = "Гипноз", Description = "Ввести в транс", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 90, Slot = 1}),
        LOTM.CreateAbility({ID = "mind_control", Name = "Контроль разума", Description = "Кратковременный контроль", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 120, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.35,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"characteristic_fragment", "nightmare_shard", "soulvine"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "spectator_s5_dream_walker",
    Name = "Манипулятор снами",
    Pathway = 7,
    Sequence = 5,
    Description = "Способность входить в сны и манипулировать ими.",
    Abilities = {
        LOTM.CreateAbility({ID = "dream_walk", Name = "Хождение по снам", Description = "Вход в чужие сны", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 180, Slot = 1}),
        LOTM.CreateAbility({ID = "dream_manipulation", Name = "Манипуляция снами", Description = "Контроль содержания снов", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 45, Cooldown = 60, Slot = 2}),
    },
    DigestionRate = 0.025,
    MadnessRisk = 0.40,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"dream_essence", "celestial_ore", "angel_tears"},
}))

-- =============================================
-- ПУТЬ 12: МОНСТР (THE MONSTER)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "monster_s9",
    Name = "Монстр",
    Pathway = 12,
    Sequence = 9,
    Description = "Путь чудовища. Усиление физических способностей.",
    Abilities = {
        LOTM.CreateAbility({ID = "monster_strength", Name = "Сила монстра", Description = "Усиленная физическая сила", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "monster_night_vision", Name = "Ночное зрение", Description = "Видение в темноте", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.06,
    MadnessRisk = 0.15,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"bloodroot", "human_blood", "nightshade"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "monster_s8_werewolf",
    Name = "Оборотень",
    Pathway = 12,
    Sequence = 8,
    Description = "Способность к частичной трансформации.",
    Abilities = {
        LOTM.CreateAbility({ID = "werewolf_transform", Name = "Трансформация", Description = "Частичное превращение в волка", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "werewolf_claws", Name = "Когти", Description = "Острые когти", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 15, Slot = 2}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.22,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"beyonder_blood", "nightmare_shard", "bloodroot"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "monster_s7_night_beast",
    Name = "Зверь Рождественской Ночи",
    Pathway = 12,
    Sequence = 7,
    Description = "Полная трансформация в чудовищную форму.",
    Abilities = {
        LOTM.CreateAbility({ID = "beast_form", Name = "Форма зверя", Description = "Полная трансформация", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 120, Slot = 1}),
        LOTM.CreateAbility({ID = "beast_regeneration", Name = "Регенерация", Description = "Ускоренное исцеление", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.30,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"soul_fragment", "characteristic_fragment", "ectoplasm"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "monster_s6_vampire",
    Name = "Вампир",
    Pathway = 12,
    Sequence = 6,
    Description = "Способности вампира - питание кровью и бессмертие.",
    Abilities = {
        LOTM.CreateAbility({ID = "vampire_drain", Name = "Поглощение крови", Description = "Высасывание жизненной силы", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 20, Slot = 1}),
        LOTM.CreateAbility({ID = "vampire_bat_form", Name = "Форма летучей мыши", Description = "Превращение в летучую мышь", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 90, Slot = 2}),
        LOTM.CreateAbility({ID = "vampire_immortality", Name = "Бессмертие", Description = "Отсутствие старения", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.35,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"angel_tears", "primordial_gem", "beyonder_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "monster_s5_blood_baron",
    Name = "Барон Крови",
    Pathway = 12,
    Sequence = 5,
    Description = "Власть над кровью и ночными созданиями.",
    Abilities = {
        LOTM.CreateAbility({ID = "blood_control", Name = "Контроль крови", Description = "Управление кровью", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 45, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "blood_servant", Name = "Кровавый слуга", Description = "Создание слуги из крови", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 120, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.42,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"divine_blessing", "sefirot_shard", "characteristic_fragment"},
}))

-- =============================================
-- ПУТЬ 13: ВОИН (THE WARRIOR)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "warrior_s9",
    Name = "Воин",
    Pathway = 13,
    Sequence = 9,
    Description = "Путь войны. Усиление боевых способностей.",
    Abilities = {
        LOTM.CreateAbility({ID = "warrior_strength", Name = "Сила воина", Description = "Усиленная физическая мощь", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "warrior_endurance", Name = "Выносливость", Description = "Повышенная стойкость", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.06,
    MadnessRisk = 0.12,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"bloodroot", "silver_dust", "human_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "warrior_s8_gladiator",
    Name = "Гладиатор",
    Pathway = 13,
    Sequence = 8,
    Description = "Мастерство всех видов оружия.",
    Abilities = {
        LOTM.CreateAbility({ID = "weapon_master", Name = "Мастер оружия", Description = "Владение любым оружием", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "power_strike", Name = "Мощный удар", Description = "Сокрушительная атака", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 20, Slot = 1}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"spirit_crystal", "bloodroot", "ritual_candle"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "warrior_s7_berserker",
    Name = "Берсерк",
    Pathway = 13,
    Sequence = 7,
    Description = "Боевое безумие и невероятная сила.",
    Abilities = {
        LOTM.CreateAbility({ID = "berserk_rage", Name = "Ярость берсерка", Description = "Боевое безумие", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "pain_immunity", Name = "Иммунитет к боли", Description = "Игнорирование боли", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.28,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightmare_shard", "beyonder_blood", "void_stone"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "warrior_s6_dawn_paladin",
    Name = "Рассветный Паладин",
    Pathway = 13,
    Sequence = 6,
    Description = "Святой воин со способностями света.",
    Abilities = {
        LOTM.CreateAbility({ID = "holy_light", Name = "Святой свет", Description = "Атака святым светом", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 25, Slot = 1}),
        LOTM.CreateAbility({ID = "divine_protection", Name = "Божественная защита", Description = "Щит света", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 60, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.32,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"celestial_ore", "pathway_essence", "soul_fragment"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "warrior_s5_guardian",
    Name = "Хранитель",
    Pathway = 13,
    Sequence = 5,
    Description = "Неуязвимый защитник с мощной бронёй.",
    Abilities = {
        LOTM.CreateAbility({ID = "iron_body", Name = "Железное тело", Description = "Невероятная защита", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 45, Cooldown = 45, Slot = 1}),
        LOTM.CreateAbility({ID = "fortress", Name = "Крепость", Description = "Абсолютная оборона", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 90, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.38,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"characteristic_fragment", "divine_blessing", "primordial_gem"},
}))

-- =============================================
-- ПУТЬ 14: ОХОТНИК (THE HUNTER)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "hunter_s9",
    Name = "Охотник",
    Pathway = 14,
    Sequence = 9,
    Description = "Путь охотника. Выслеживание и точная стрельба.",
    Abilities = {
        LOTM.CreateAbility({ID = "hunter_tracking", Name = "Выслеживание", Description = "Следование за добычей", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "hunter_precision", Name = "Точный выстрел", Description = "Невероятная меткость", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 20, Slot = 1}),
    },
    DigestionRate = 0.06,
    MadnessRisk = 0.12,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightshade", "silver_dust", "human_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "hunter_s8_provocateur",
    Name = "Провокатор",
    Pathway = 14,
    Sequence = 8,
    Description = "Мастер провокаций и ловушек.",
    Abilities = {
        LOTM.CreateAbility({ID = "trap_setting", Name = "Установка ловушек", Description = "Скрытые ловушки", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "provocation", Name = "Провокация", Description = "Вызов ярости врага", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 25, Slot = 2}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"bloodroot", "ectoplasm", "ritual_candle"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "hunter_s7_pyromaniac",
    Name = "Поджигатель",
    Pathway = 14,
    Sequence = 7,
    Description = "Контроль над огнём и взрывчаткой.",
    Abilities = {
        LOTM.CreateAbility({ID = "fire_bomb", Name = "Огненная бомба", Description = "Взрывчатка с огнём", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 25, Slot = 1}),
        LOTM.CreateAbility({ID = "fire_immunity", Name = "Иммунитет к огню", Description = "Невосприимчивость к пламени", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.25,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"void_stone", "nightmare_shard", "beyonder_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "hunter_s6_conspirator",
    Name = "Заговорщик",
    Pathway = 14,
    Sequence = 6,
    Description = "Мастер интриг и взрывов.",
    Abilities = {
        LOTM.CreateAbility({ID = "grand_explosion", Name = "Великий взрыв", Description = "Мощнейший взрыв", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "conspiracy", Name = "Заговор", Description = "Организация интриг", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 120, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.32,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"pathway_essence", "soul_fragment", "celestial_ore"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "hunter_s5_pyromaniac_master",
    Name = "Пироман",
    Pathway = 14,
    Sequence = 5,
    Description = "Абсолютная власть над огнём.",
    Abilities = {
        LOTM.CreateAbility({ID = "inferno", Name = "Инферно", Description = "Стена огня", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 90, Slot = 1}),
        LOTM.CreateAbility({ID = "phoenix_rebirth", Name = "Возрождение Феникса", Description = "Возрождение из пламени", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 100, Cooldown = 300, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.40,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"characteristic_fragment", "divine_blessing", "sefirot_shard"},
}))

-- =============================================
-- ПУТЬ 15: СМЕРТЬ (THE DEATH)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "death_s9_corpse_collector",
    Name = "Трупособиратель",
    Pathway = 15,
    Sequence = 9,
    Description = "Путь смерти. Связь с мёртвыми.",
    Abilities = {
        LOTM.CreateAbility({ID = "corpse_sense", Name = "Чувство мёртвых", Description = "Ощущение трупов", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "corpse_preserve", Name = "Сохранение тела", Description = "Предотвращение гниения", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 15, Cooldown = 30, Slot = 1}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.15,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightshade", "human_blood", "ectoplasm"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "death_s8_undertaker",
    Name = "Гробовщик",
    Pathway = 15,
    Sequence = 8,
    Description = "Общение с духами мёртвых.",
    Abilities = {
        LOTM.CreateAbility({ID = "spirit_talk", Name = "Разговор с духами", Description = "Общение с умершими", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "ghost_vision", Name = "Видение призраков", Description = "Видеть духов", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.045,
    MadnessRisk = 0.20,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"spirit_crystal", "bloodroot", "ritual_candle"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "death_s7_wraith",
    Name = "Призрак",
    Pathway = 15,
    Sequence = 7,
    Description = "Способность становиться бестелесным.",
    Abilities = {
        LOTM.CreateAbility({ID = "ethereal_form", Name = "Эфирная форма", Description = "Бестелесность", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "ghost_walk", Name = "Призрачная ходьба", Description = "Проход сквозь стены", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 30, Slot = 2}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.28,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"soul_fragment", "nightmare_shard", "void_stone"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "death_s6_puppet_master",
    Name = "Кукловод",
    Pathway = 15,
    Sequence = 6,
    Description = "Контроль над нежитью.",
    Abilities = {
        LOTM.CreateAbility({ID = "raise_dead", Name = "Поднятие мёртвых", Description = "Создание зомби", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 90, Slot = 1}),
        LOTM.CreateAbility({ID = "undead_control", Name = "Контроль нежити", Description = "Управление мёртвыми", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 30, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.35,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"characteristic_fragment", "pathway_essence", "beyonder_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "death_s5_bizarre_hunter",
    Name = "Бизарный Охотник",
    Pathway = 15,
    Sequence = 5,
    Description = "Охотник на нежить с мощными способностями.",
    Abilities = {
        LOTM.CreateAbility({ID = "death_strike", Name = "Удар смерти", Description = "Мгновенная смерть цели", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 80, Cooldown = 120, Slot = 1}),
        LOTM.CreateAbility({ID = "soul_harvest", Name = "Жатва душ", Description = "Сбор душ", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 60, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.42,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"sefirot_shard", "divine_blessing", "angel_tears"},
}))

-- =============================================
-- ПУТЬ 16: ТЬМА (THE DARKNESS)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "darkness_s9_sleeper",
    Name = "Спящий",
    Pathway = 16,
    Sequence = 9,
    Description = "Путь тьмы. Связь со сном и тенями.",
    Abilities = {
        LOTM.CreateAbility({ID = "lucid_dreaming", Name = "Осознанные сны", Description = "Контроль собственных снов", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "deep_sleep", Name = "Глубокий сон", Description = "Восстановление во сне", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 120, Slot = 1}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.15,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"moonflower", "dream_essence", "silver_dust"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "darkness_s8_midnight_poet",
    Name = "Полуночный Поэт",
    Pathway = 16,
    Sequence = 8,
    Description = "Власть над снами и тенями.",
    Abilities = {
        LOTM.CreateAbility({ID = "shadow_step", Name = "Шаг тени", Description = "Телепорт через тени", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 25, Slot = 1}),
        LOTM.CreateAbility({ID = "night_vision", Name = "Ночное зрение", Description = "Идеальное видение в темноте", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.045,
    MadnessRisk = 0.20,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightmare_shard", "ectoplasm", "void_stone"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "darkness_s7_nightmare",
    Name = "Кошмар",
    Pathway = 16,
    Sequence = 7,
    Description = "Создание кошмаров и страха.",
    Abilities = {
        LOTM.CreateAbility({ID = "nightmare_creation", Name = "Создание кошмара", Description = "Материализация страхов", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 45, Cooldown = 45, Slot = 1}),
        LOTM.CreateAbility({ID = "fear_aura", Name = "Аура страха", Description = "Распространение ужаса", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 30, Slot = 2}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.28,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"soul_fragment", "nightmare_shard", "beyonder_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "darkness_s6_dream_walker",
    Name = "Путешественник снов",
    Pathway = 16,
    Sequence = 6,
    Description = "Свободное перемещение между снами.",
    Abilities = {
        LOTM.CreateAbility({ID = "dream_portal", Name = "Портал снов", Description = "Путешествие через сны", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 90, Slot = 1}),
        LOTM.CreateAbility({ID = "dream_trap", Name = "Ловушка снов", Description = "Заточение во сне", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 120, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.35,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"pathway_essence", "celestial_ore", "characteristic_fragment"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "darkness_s5_guardian",
    Name = "Хранитель",
    Pathway = 16,
    Sequence = 5,
    Description = "Страж границы между сном и явью.",
    Abilities = {
        LOTM.CreateAbility({ID = "dream_realm", Name = "Царство снов", Description = "Создание собственного мира снов", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 80, Cooldown = 180, Slot = 1}),
        LOTM.CreateAbility({ID = "eternal_sleep", Name = "Вечный сон", Description = "Погружение в бесконечный сон", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 100, Cooldown = 300, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.42,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"divine_blessing", "sefirot_shard", "angel_tears"},
}))

-- =============================================
-- ПУТЬ 17: СОЛНЦЕ (THE SUN)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "sun_s9_singer",
    Name = "Певец",
    Pathway = 17,
    Sequence = 9,
    Description = "Путь света и тепла. Магия голоса.",
    Abilities = {
        LOTM.CreateAbility({ID = "enchanting_voice", Name = "Чарующий голос", Description = "Магическое пение", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 15, Cooldown = 20, Slot = 1}),
        LOTM.CreateAbility({ID = "light_affinity", Name = "Сродство со светом", Description = "Связь со светом", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.10,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"moonflower", "holy_water", "silver_dust"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "sun_s8_light_suppliant",
    Name = "Молитвослов",
    Pathway = 17,
    Sequence = 8,
    Description = "Молитвы к свету и исцеление.",
    Abilities = {
        LOTM.CreateAbility({ID = "healing_light", Name = "Исцеляющий свет", Description = "Лечение светом", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "purification", Name = "Очищение", Description = "Очищение от зла", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 45, Slot = 2}),
    },
    DigestionRate = 0.045,
    MadnessRisk = 0.15,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"spirit_crystal", "ritual_candle", "bloodroot"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "sun_s7_solar_priest",
    Name = "Священник Солнца",
    Pathway = 17,
    Sequence = 7,
    Description = "Жрец солнечного культа.",
    Abilities = {
        LOTM.CreateAbility({ID = "solar_blessing", Name = "Солнечное благословение", Description = "Благословение силой солнца", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "daylight", Name = "Дневной свет", Description = "Создание яркого света", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 20, Slot = 2}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.22,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"celestial_ore", "pathway_essence", "ectoplasm"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "sun_s6_light_denier",
    Name = "Отвергающий Свет",
    Pathway = 17,
    Sequence = 6,
    Description = "Парадоксальная власть над светом и тьмой.",
    Abilities = {
        LOTM.CreateAbility({ID = "light_absorption", Name = "Поглощение света", Description = "Поглощение фотонов", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 45, Slot = 1}),
        LOTM.CreateAbility({ID = "solar_flare", Name = "Солнечная вспышка", Description = "Ослепляющий взрыв света", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 90, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.30,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"void_stone", "soul_fragment", "nightmare_shard"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "sun_s5_chaplain",
    Name = "Капеллан",
    Pathway = 17,
    Sequence = 5,
    Description = "Духовный лидер с мощной магией света.",
    Abilities = {
        LOTM.CreateAbility({ID = "divine_light", Name = "Божественный свет", Description = "Чистейший свет", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 120, Slot = 1}),
        LOTM.CreateAbility({ID = "mass_healing", Name = "Массовое исцеление", Description = "Лечение всех союзников", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 80, Cooldown = 180, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.38,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"divine_blessing", "angel_tears", "characteristic_fragment"},
}))

-- =============================================
-- ПУТЬ 18: БУРЯ (THE TYRANT)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "tyrant_s9_sailor",
    Name = "Матрос",
    Pathway = 18,
    Sequence = 9,
    Description = "Путь бури. Связь с морем и ветром.",
    Abilities = {
        LOTM.CreateAbility({ID = "sea_affinity", Name = "Сродство с морем", Description = "Способность дышать под водой", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
        LOTM.CreateAbility({ID = "wind_whisper", Name = "Шёпот ветра", Description = "Слышать ветер", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.12,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"moonflower", "silver_dust", "holy_water"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "tyrant_s8_wind_master",
    Name = "Мастер по Ветру",
    Pathway = 18,
    Sequence = 8,
    Description = "Контроль над ветром.",
    Abilities = {
        LOTM.CreateAbility({ID = "wind_control", Name = "Контроль ветра", Description = "Управление потоками воздуха", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 25, Cooldown = 20, Slot = 1}),
        LOTM.CreateAbility({ID = "gust", Name = "Порыв", Description = "Мощный порыв ветра", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 15, Slot = 2}),
    },
    DigestionRate = 0.045,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"spirit_crystal", "ectoplasm", "bloodroot"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "tyrant_s7_dawn_singer",
    Name = "Певец Рассвета",
    Pathway = 18,
    Sequence = 7,
    Description = "Магия голоса и стихий.",
    Abilities = {
        LOTM.CreateAbility({ID = "storm_song", Name = "Песнь бури", Description = "Призыв шторма голосом", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 40, Cooldown = 45, Slot = 1}),
        LOTM.CreateAbility({ID = "lightning_call", Name = "Призыв молнии", Description = "Удар молнией", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 30, Slot = 2}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.25,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"pathway_essence", "void_stone", "nightmare_shard"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "tyrant_s6_wind_eater",
    Name = "Пожиратель Ветра",
    Pathway = 18,
    Sequence = 6,
    Description = "Поглощение стихийных сил.",
    Abilities = {
        LOTM.CreateAbility({ID = "element_absorption", Name = "Поглощение стихий", Description = "Впитывание стихийной энергии", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 50, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "hurricane", Name = "Ураган", Description = "Создание урагана", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 120, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.32,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"celestial_ore", "soul_fragment", "characteristic_fragment"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "tyrant_s5_ocean_lord",
    Name = "Повелитель Океанских Волн",
    Pathway = 18,
    Sequence = 5,
    Description = "Абсолютная власть над водой.",
    Abilities = {
        LOTM.CreateAbility({ID = "tsunami", Name = "Цунами", Description = "Гигантская волна", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 90, Cooldown = 180, Slot = 1}),
        LOTM.CreateAbility({ID = "water_breathing", Name = "Водное дыхание", Description = "Вечное дыхание под водой", Type = LOTM.ABILITY_TYPES.PASSIVE, Slot = 0}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.40,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"divine_blessing", "sefirot_shard", "primordial_gem"},
}))

-- =============================================
-- ПУТЬ 21: ПРОВИДИЦА (THE DEMONESS)
-- =============================================

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "demoness_s9_assassin",
    Name = "Убийца",
    Pathway = 21,
    Sequence = 9,
    Description = "Путь демонессы. Скрытность и яд.",
    Abilities = {
        LOTM.CreateAbility({ID = "stealth", Name = "Скрытность", Description = "Невидимость в тенях", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 20, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "poison_blade", Name = "Отравленный клинок", Description = "Нанесение яда", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 15, Cooldown = 20, Slot = 2}),
    },
    DigestionRate = 0.05,
    MadnessRisk = 0.18,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightshade", "human_blood", "bloodroot"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "demoness_s8_instigator",
    Name = "Инсигатор",
    Pathway = 21,
    Sequence = 8,
    Description = "Манипуляция эмоциями и провокации.",
    Abilities = {
        LOTM.CreateAbility({ID = "emotion_manipulation", Name = "Манипуляция эмоциями", Description = "Контроль чувств", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 30, Slot = 1}),
        LOTM.CreateAbility({ID = "charm", Name = "Очарование", Description = "Соблазнение", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 35, Cooldown = 45, Slot = 2}),
    },
    DigestionRate = 0.045,
    MadnessRisk = 0.25,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"dream_essence", "ectoplasm", "spirit_crystal"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "demoness_s7_witch",
    Name = "Ведьма",
    Pathway = 21,
    Sequence = 7,
    Description = "Тёмная магия и проклятия.",
    Abilities = {
        LOTM.CreateAbility({ID = "curse", Name = "Проклятие", Description = "Наложение проклятия", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 45, Cooldown = 60, Slot = 1}),
        LOTM.CreateAbility({ID = "hex", Name = "Сглаз", Description = "Временное ослабление", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 30, Cooldown = 30, Slot = 2}),
    },
    DigestionRate = 0.04,
    MadnessRisk = 0.32,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"nightmare_shard", "soul_fragment", "void_stone"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "demoness_s6_pleasure",
    Name = "Удовольствие",
    Pathway = 21,
    Sequence = 6,
    Description = "Власть над желаниями.",
    Abilities = {
        LOTM.CreateAbility({ID = "desire_control", Name = "Контроль желаний", Description = "Манипуляция желаниями", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 55, Cooldown = 75, Slot = 1}),
        LOTM.CreateAbility({ID = "seduction", Name = "Соблазнение", Description = "Абсолютное очарование", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 60, Cooldown = 90, Slot = 2}),
    },
    DigestionRate = 0.035,
    MadnessRisk = 0.40,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"characteristic_fragment", "pathway_essence", "beyonder_blood"},
}))

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "demoness_s5_misfortune",
    Name = "Несчастье",
    Pathway = 21,
    Sequence = 5,
    Description = "Воплощение неудачи.",
    Abilities = {
        LOTM.CreateAbility({ID = "bad_luck", Name = "Невезение", Description = "Наложение неудачи", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 70, Cooldown = 120, Slot = 1}),
        LOTM.CreateAbility({ID = "calamity", Name = "Катастрофа", Description = "Призыв бедствия", Type = LOTM.ABILITY_TYPES.ACTIVE, EnergyCost = 90, Cooldown = 180, Slot = 2}),
    },
    DigestionRate = 0.03,
    MadnessRisk = 0.48,
    Model = "models/props_junk/PopCan01a.mdl",
    Ingredients = {"sefirot_shard", "divine_blessing", "angel_tears"},
}))

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Loaded ", Color(255, 200, 100), tostring(table.Count(LOTM.Potions)), Color(255, 255, 255), " potions for all pathways\n")
=======
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
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
