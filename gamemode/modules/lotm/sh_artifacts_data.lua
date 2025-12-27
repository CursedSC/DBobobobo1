-- LOTM Artifacts Data & Inventory Integration
-- Регистрация артефактов и интеграция с инвентарём

if not LOTM or not LOTM.Artifacts then return end

-- =============================================
-- Таблица соответствия ID инвентаря и ID артефактов
-- =============================================
LOTM.Artifacts.InventoryIDs = LOTM.Artifacts.InventoryIDs or {}

-- =============================================
-- АРТЕФАКТЫ ПУТЕЙ
-- =============================================

-- Путь Дурака
LOTM.Artifacts.Register({
    id = "gray_fog_token",
    name = "Жетон Серого Тумана",
    description = "Загадочный жетон, связывающий владельца с Серым Туманом. Усиливает способности Провидца.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_lab/huladoll.mdl",
    pathway = 1,
    
    buffs = {
        spirituality = 30,
        divination = 25,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.MENTAL] = 20,
        [LOTM.Artifacts.ResistTypes.SPIRITUAL] = 15,
    },
    
    abilityCooldown = 60,
    
    useEffects = {
        {id = "gray_fog_vision", duration = 30},
    },
    
    onEquip = function(ply, artifact)
        if SERVER then
            ply:ChatPrint("[Серый туман окутывает ваш разум...]")
        end
    end,
    
    requirements = {
        pathway = 1,
        minSequence = 7,
    },
})

LOTM.Artifacts.Register({
    id = "paper_figurine",
    name = "Бумажная Фигурка",
    description = "Древняя бумажная фигурка, способная заменить владельца в момент смертельной опасности.",
    type = LOTM.Artifacts.Types.GRADE_7,
    model = "models/props_junk/garbage_newspaper001a.mdl",
    pathway = 1,
    
    buffs = {
        agility = 15,
    },
    
    abilityCooldown = 180,
    
    useEffects = {
        {id = "substitute", duration = 0.5},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            -- Создаём бумажную фигурку-обманку
            ply:ChatPrint("[Бумажная фигурка заменяет вас...]")
        end
    end,
})

-- Путь Зрителя
LOTM.Artifacts.Register({
    id = "third_eye_pendant",
    name = "Кулон Третьего Глаза",
    description = "Открывает третий глаз, позволяя видеть скрытое.",
    type = LOTM.Artifacts.Types.GRADE_6,
    model = "models/props_lab/jar01b.mdl",
    pathway = 7,
    
    buffs = {
        perception = 40,
        mind_reading = 20,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.MENTAL] = 25,
    },
    
    abilityCooldown = 45,
    
    useEffects = {
        {id = "true_sight", duration = 20},
    },
    
    requirements = {
        pathway = 7,
        minSequence = 6,
    },
})

LOTM.Artifacts.Register({
    id = "dream_catcher",
    name = "Ловец Снов",
    description = "Защищает разум во время сна и позволяет контролировать сновидения.",
    type = LOTM.Artifacts.Types.GRADE_7,
    model = "models/props_junk/MetalBucket01a.mdl",
    pathway = 7,
    
    buffs = {
        dream_control = 30,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.MENTAL] = 15,
    },
    
    abilityCooldown = 120,
    
    useEffects = {
        {id = "lucid_dream", duration = 60},
    },
})

-- Путь Монстра
LOTM.Artifacts.Register({
    id = "blood_chalice",
    name = "Кровавая Чаша",
    description = "Древний сосуд вампиров. Пьющий из неё обретает силу крови.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_junk/garbage_metalcan001a.mdl",
    pathway = 12,
    
    buffs = {
        damage = 35,
        lifesteal = 20,
    },
    
    debuffs = {
        light_weakness = 25,
    },
    
    vulnerabilities = {
        [LOTM.Artifacts.ResistTypes.FIRE] = 15,
    },
    
    abilityCooldown = 30,
    
    useEffects = {
        {id = "blood_frenzy", duration = 15},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            -- Восстановление здоровья
            local heal = math.min(ply:GetMaxHealth() - ply:Health(), 50)
            ply:SetHealth(ply:Health() + heal)
            ply:ChatPrint("[Кровь наполняет вас силой...]")
        end
    end,
    
    requirements = {
        pathway = 12,
        minSequence = 6,
    },
})

LOTM.Artifacts.Register({
    id = "wolf_fang_necklace",
    name = "Ожерелье Волчьего Клыка",
    description = "Клык альфа-оборотня, усиливающий звериные инстинкты.",
    type = LOTM.Artifacts.Types.GRADE_8,
    model = "models/props_junk/rock001a.mdl",
    pathway = 12,
    
    buffs = {
        speed = 20,
        tracking = 30,
        night_vision = 1,
    },
    
    abilityCooldown = 60,
    
    useEffects = {
        {id = "wolf_senses", duration = 30},
    },
})

-- Путь Воина
LOTM.Artifacts.Register({
    id = "iron_gauntlet",
    name = "Железная Перчатка",
    description = "Перчатка легендарного гладиатора. Несокрушимая защита руки.",
    type = LOTM.Artifacts.Types.GRADE_6,
    model = "models/props_junk/garbage_metalcan002a.mdl",
    pathway = 13,
    
    buffs = {
        defense = 30,
        punch_damage = 25,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.PHYSICAL] = 20,
    },
    
    abilityCooldown = 45,
    
    useEffects = {
        {id = "iron_fist", duration = 10},
    },
    
    requirements = {
        pathway = 13,
        minSequence = 7,
    },
})

LOTM.Artifacts.Register({
    id = "berserker_helm",
    name = "Шлем Берсерка",
    description = "Шлем, вселяющий боевое безумие. Опасен для владельца и врагов.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_junk/garbage_metalcan001a.mdl",
    pathway = 13,
    
    buffs = {
        damage = 50,
        attack_speed = 30,
    },
    
    debuffs = {
        defense = 20,
        sanity = 10,
    },
    
    vulnerabilities = {
        [LOTM.Artifacts.ResistTypes.MENTAL] = 25,
    },
    
    abilityCooldown = 90,
    
    useEffects = {
        {id = "berserk_rage", duration = 20},
    },
    
    onEquip = function(ply, artifact)
        if SERVER then
            ply:ChatPrint("[Ярость берсерка заполняет ваш разум!]")
        end
    end,
})

-- Путь Охотника
LOTM.Artifacts.Register({
    id = "explosive_pouch",
    name = "Сумка Взрывчатки",
    description = "Бездонная сумка с взрывчаткой. Осторожнее с огнём!",
    type = LOTM.Artifacts.Types.GRADE_7,
    model = "models/props_junk/garbage_bag001a.mdl",
    pathway = 14,
    
    buffs = {
        explosion_damage = 40,
    },
    
    abilityCooldown = 20,
    
    useEffects = {
        {id = "grenade_throw", duration = 0},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            -- Бросок гранаты
            ply:ChatPrint("[Вы бросаете взрывчатку!]")
        end
    end,
})

LOTM.Artifacts.Register({
    id = "fire_crystal",
    name = "Огненный Кристалл",
    description = "Кристалл, пылающий вечным огнём. Даёт иммунитет к пламени.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_junk/rock001a.mdl",
    pathway = 14,
    
    buffs = {
        fire_damage = 35,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.FIRE] = 100,
    },
    
    abilityCooldown = 60,
    
    useEffects = {
        {id = "fire_aura", duration = 20},
    },
    
    requirements = {
        pathway = 14,
        minSequence = 6,
    },
})

-- Путь Смерти
LOTM.Artifacts.Register({
    id = "death_shroud",
    name = "Саван Смерти",
    description = "Саван из могилы святого. Позволяет становиться призраком.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_junk/garbage_newspaper001a.mdl",
    pathway = 15,
    
    buffs = {
        stealth = 40,
        ghost_damage = 25,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.PHYSICAL] = 30,
    },
    
    vulnerabilities = {
        [LOTM.Artifacts.ResistTypes.SPIRITUAL] = 20,
    },
    
    abilityCooldown = 90,
    
    useEffects = {
        {id = "ghost_form", duration = 15},
    },
    
    requirements = {
        pathway = 15,
        minSequence = 6,
    },
})

LOTM.Artifacts.Register({
    id = "necromancer_staff",
    name = "Посох Некроманта",
    description = "Посох древнего некроманта. Позволяет поднимать мёртвых.",
    type = LOTM.Artifacts.Types.GRADE_4,
    model = "models/props_junk/garbage_plasticbottle001a.mdl",
    pathway = 15,
    
    buffs = {
        undead_control = 50,
        spirituality = 30,
    },
    
    debuffs = {
        sanity = 15,
    },
    
    abilityCooldown = 120,
    
    useEffects = {
        {id = "raise_undead", duration = 60},
    },
    
    requirements = {
        pathway = 15,
        minSequence = 5,
    },
})

-- Путь Тьмы
LOTM.Artifacts.Register({
    id = "nightmare_lantern",
    name = "Фонарь Кошмаров",
    description = "Фонарь, излучающий тьму вместо света. Материализует страхи.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_c17/candle01a.mdl",
    pathway = 16,
    
    buffs = {
        fear_aura = 35,
        darkness_control = 30,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.MENTAL] = 25,
    },
    
    abilityCooldown = 60,
    
    useEffects = {
        {id = "nightmare_manifest", duration = 20},
    },
    
    requirements = {
        pathway = 16,
        minSequence = 6,
    },
})

LOTM.Artifacts.Register({
    id = "dream_pillow",
    name = "Подушка Снов",
    description = "Подушка, позволяющая путешествовать по снам других людей.",
    type = LOTM.Artifacts.Types.GRADE_7,
    model = "models/props_junk/garbage_bag001a.mdl",
    pathway = 16,
    
    buffs = {
        dream_walk = 40,
    },
    
    abilityCooldown = 180,
    
    useEffects = {
        {id = "dream_travel", duration = 120},
    },
})

-- Путь Солнца
LOTM.Artifacts.Register({
    id = "solar_amulet",
    name = "Солнечный Амулет",
    description = "Амулет, хранящий частицу солнечного света. Изгоняет тьму.",
    type = LOTM.Artifacts.Types.GRADE_6,
    model = "models/props_lab/huladoll.mdl",
    pathway = 17,
    
    buffs = {
        light_damage = 30,
        healing = 20,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.CORRUPTION] = 40,
    },
    
    abilityCooldown = 45,
    
    useEffects = {
        {id = "sunburst", duration = 0},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            -- Вспышка света
            ply:ChatPrint("[Солнечный свет ослепляет врагов!]")
        end
    end,
    
    requirements = {
        pathway = 17,
        minSequence = 7,
    },
})

LOTM.Artifacts.Register({
    id = "healing_chalice",
    name = "Чаша Исцеления",
    description = "Святая чаша с целебной водой. Исцеляет любые раны.",
    type = LOTM.Artifacts.Types.DIVINE,
    model = "models/props_junk/garbage_metalcan001a.mdl",
    pathway = 17,
    
    buffs = {
        health = 100,
        health_regen = 15,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.POISON] = 50,
        [LOTM.Artifacts.ResistTypes.CORRUPTION] = 30,
    },
    
    abilityCooldown = 180,
    
    onUse = function(ply, artifact)
        if SERVER then
            ply:SetHealth(ply:GetMaxHealth())
            ply:ChatPrint("[Божественная сила исцеляет вас полностью!]")
        end
    end,
    
    requirements = {
        pathway = 17,
        minSequence = 4,
    },
})

-- Путь Бури
LOTM.Artifacts.Register({
    id = "storm_compass",
    name = "Штормовой Компас",
    description = "Компас, указывающий направление бури. Даёт власть над ветром.",
    type = LOTM.Artifacts.Types.GRADE_6,
    model = "models/props_junk/garbage_metalcan002a.mdl",
    pathway = 18,
    
    buffs = {
        wind_control = 35,
        navigation = 50,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.LIGHTNING] = 30,
    },
    
    abilityCooldown = 45,
    
    useEffects = {
        {id = "wind_blast", duration = 0},
    },
    
    requirements = {
        pathway = 18,
        minSequence = 7,
    },
})

LOTM.Artifacts.Register({
    id = "lightning_rod",
    name = "Молниеотвод",
    description = "Жезл, притягивающий молнии. Позволяет метать их во врагов.",
    type = LOTM.Artifacts.Types.GRADE_5,
    model = "models/props_junk/garbage_plasticbottle001a.mdl",
    pathway = 18,
    
    buffs = {
        lightning_damage = 45,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.LIGHTNING] = 100,
    },
    
    abilityCooldown = 30,
    
    useEffects = {
        {id = "lightning_strike", duration = 0},
    },
    
    onUse = function(ply, artifact)
        if SERVER then
            ply:ChatPrint("[Молния поражает ваших врагов!]")
        end
    end,
    
    requirements = {
        pathway = 18,
        minSequence = 6,
    },
})

-- Путь Демонессы
LOTM.Artifacts.Register({
    id = "seduction_mirror",
    name = "Зеркало Соблазна",
    description = "Зеркало, показывающее желания смотрящего. Опасный артефакт.",
    type = LOTM.Artifacts.Types.CURSED,
    model = "models/props_junk/garbage_metalcan001a.mdl",
    pathway = 21,
    
    buffs = {
        charm = 50,
        manipulation = 40,
    },
    
    debuffs = {
        sanity = 20,
    },
    
    vulnerabilities = {
        [LOTM.Artifacts.ResistTypes.SPIRITUAL] = 25,
    },
    
    abilityCooldown = 90,
    
    useEffects = {
        {id = "mass_charm", duration = 15},
    },
    
    onEquip = function(ply, artifact)
        if SERVER then
            ply:ChatPrint("[Зеркало шепчет вам сладкие обещания...]")
        end
    end,
    
    requirements = {
        pathway = 21,
        minSequence = 5,
    },
})

LOTM.Artifacts.Register({
    id = "poison_ring",
    name = "Кольцо Яда",
    description = "Кольцо с потайным отделением для яда. Классика убийц.",
    type = LOTM.Artifacts.Types.GRADE_8,
    model = "models/props_lab/jar01b.mdl",
    pathway = 21,
    
    buffs = {
        poison_damage = 25,
        stealth = 15,
    },
    
    abilityCooldown = 30,
    
    useEffects = {
        {id = "poison_blade", duration = 30},
    },
})

-- =============================================
-- УНИВЕРСАЛЬНЫЕ АРТЕФАКТЫ
-- =============================================

LOTM.Artifacts.Register({
    id = "spirit_crystal_amulet",
    name = "Амулет Духовного Кристалла",
    description = "Простой амулет с духовным кристаллом. Немного усиливает духовность.",
    type = LOTM.Artifacts.Types.GRADE_9,
    model = "models/props_junk/rock001a.mdl",
    
    buffs = {
        spirituality = 10,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.SPIRITUAL] = 5,
    },
    
    abilityCooldown = 120,
})

LOTM.Artifacts.Register({
    id = "protective_talisman",
    name = "Защитный Талисман",
    description = "Талисман начального уровня. Даёт небольшую защиту от зла.",
    type = LOTM.Artifacts.Types.GRADE_9,
    model = "models/props_junk/garbage_newspaper001a.mdl",
    
    buffs = {
        defense = 5,
    },
    
    resistances = {
        [LOTM.Artifacts.ResistTypes.CORRUPTION] = 10,
        [LOTM.Artifacts.ResistTypes.MENTAL] = 5,
    },
    
    abilityCooldown = 180,
})

-- =============================================
-- Интеграция с инвентарем
-- =============================================

hook.Add("InitPostEntity", "LOTM.Artifacts.RegisterInventory", function()
    timer.Simple(1.5, function()
        if not dbt or not dbt.inventory or not dbt.inventory.items then 
            MsgC(Color(255, 100, 100), "[LOTM] ", Color(255, 255, 255), "Warning: dbt.inventory not found for artifacts\n")
            return 
        end
        
        local baseId = 700 -- Начальный ID для артефактов
        
        for artifactId, data in pairs(LOTM.Artifacts.Registry) do
            local itemId = baseId
            baseId = baseId + 1
            
            -- Сохраняем соответствие
            LOTM.Artifacts.InventoryIDs[artifactId] = itemId
            
            -- Определяем цвет по типу
            local typeColors = {
                [LOTM.Artifacts.Types.GRADE_9] = Color(200, 200, 200),
                [LOTM.Artifacts.Types.GRADE_8] = Color(100, 255, 100),
                [LOTM.Artifacts.Types.GRADE_7] = Color(100, 150, 255),
                [LOTM.Artifacts.Types.GRADE_6] = Color(150, 100, 255),
                [LOTM.Artifacts.Types.GRADE_5] = Color(255, 100, 255),
                [LOTM.Artifacts.Types.GRADE_4] = Color(255, 150, 50),
                [LOTM.Artifacts.Types.CURSED] = Color(255, 50, 50),
                [LOTM.Artifacts.Types.DIVINE] = Color(255, 215, 0),
            }
            
            local artifactColor = typeColors[data.type] or Color(255, 255, 255)
            local typeName = data.type and string.upper(data.type) or "АРТЕФАКТ"
            
            dbt.inventory.items[itemId] = {
                name = data.name,
                mdl = data.model,
                kg = 0.5,
                artifact = true,
                artifactId = artifactId,
                notEditable = true,
                lotmItem = true,
                autoEquipArtifact = true, -- Флаг для авто-экипировки
                
                GetDescription = function(self)
                    local text = {}
                    text[#text+1] = artifactColor
                    text[#text+1] = "[" .. typeName .. "] "
                    text[#text+1] = color_white
                    text[#text+1] = data.description
                    text[#text+1] = true
                    
                    -- Баффы
                    if data.buffs and table.Count(data.buffs) > 0 then
                        text[#text+1] = Color(100, 255, 100)
                        text[#text+1] = "Бонусы:"
                        for stat, val in pairs(data.buffs) do
                            text[#text+1] = true
                            text[#text+1] = Color(100, 255, 100)
                            text[#text+1] = "  +" .. val .. " " .. stat
                        end
                    end
                    
                    -- Дебаффы
                    if data.debuffs and table.Count(data.debuffs) > 0 then
                        text[#text+1] = true
                        text[#text+1] = Color(255, 100, 100)
                        text[#text+1] = "Штрафы:"
                        for stat, val in pairs(data.debuffs) do
                            text[#text+1] = true
                            text[#text+1] = Color(255, 100, 100)
                            text[#text+1] = "  -" .. val .. " " .. stat
                        end
                    end
                    
                    text[#text+1] = true
                    text[#text+1] = Color(255, 200, 100)
                    text[#text+1] = "Кулдаун: " .. (data.abilityCooldown or 60) .. " сек"
                    
                    return text
                end,
                
                descalt = {artifactColor, "Артефакт LOTM", true, "• Автоматически экипируется при получении"},
                
                -- Функция при добавлении в инвентарь
                OnPickup = function(ply, itemData)
                    if SERVER and LOTM.Artifacts.Equip then
                        LOTM.Artifacts.Equip(ply, artifactId)
                        if ply.ChatPrint then
                            ply:ChatPrint("[LOTM] Артефакт " .. data.name .. " экипирован автоматически!")
                        end
                    end
                end,
            }
        end
        
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
             "Artifacts added to inventory: " .. table.Count(LOTM.Artifacts.Registry) .. "\n")
    end)
end)

-- Получить ID предмета инвентаря для артефакта
function LOTM.Artifacts.GetInventoryID(artifactId)
    return LOTM.Artifacts.InventoryIDs[artifactId]
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Artifacts data loaded: " .. table.Count(LOTM.Artifacts.Registry) .. " artifacts\n")
