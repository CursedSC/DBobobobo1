-- LOTM Mystical Ingredients System
-- Система мистических ингредиентов для зелий

LOTM = LOTM or {}
LOTM.Ingredients = LOTM.Ingredients or {}

-- Хранилище ингредиентов
LOTM.Ingredients.Registry = LOTM.Ingredients.Registry or {}

-- Категории ингредиентов
LOTM.Ingredients.Categories = {
    PLANTS = "plants",           -- Растения
    MINERALS = "minerals",       -- Минералы и камни
    BLOOD = "blood",             -- Кровь и телесные жидкости
    SPIRITUAL = "spiritual",     -- Духовные сущности
    MATERIALS = "materials",     -- Обычные материалы
    BEYONDER = "beyonder",       -- Beyonder-ингредиенты
    DIVINE = "divine",           -- Божественные ингредиенты
}

-- Названия категорий
LOTM.Ingredients.CategoryNames = {
    [LOTM.Ingredients.Categories.PLANTS] = "Растения",
    [LOTM.Ingredients.Categories.MINERALS] = "Минералы",
    [LOTM.Ingredients.Categories.BLOOD] = "Кровь",
    [LOTM.Ingredients.Categories.SPIRITUAL] = "Духовное",
    [LOTM.Ingredients.Categories.MATERIALS] = "Материалы",
    [LOTM.Ingredients.Categories.BEYONDER] = "Beyonder",
    [LOTM.Ingredients.Categories.DIVINE] = "Божественное",
}

-- Регистрация ингредиента
function LOTM.Ingredients.Register(ingredientData)
    if not ingredientData.id then
        ErrorNoHalt("[LOTM] Ошибка регистрации ингредиента: отсутствует id\n")
        return false
    end
    
    ingredientData.name = ingredientData.name or "Неизвестный ингредиент"
    ingredientData.description = ingredientData.description or ""
    ingredientData.category = ingredientData.category or LOTM.Ingredients.Categories.MATERIALS
    ingredientData.rarity = ingredientData.rarity or 1 -- 1-5, 5 = legendary
    ingredientData.icon = ingredientData.icon or "lotm/ingredients/default.png"
    ingredientData.model = ingredientData.model or "models/props_junk/garbage_takeoutcarton001a.mdl"
    ingredientData.stackable = ingredientData.stackable ~= false
    ingredientData.maxStack = ingredientData.maxStack or 99
    
    LOTM.Ingredients.Registry[ingredientData.id] = ingredientData
    
    return true
end

-- Получить ингредиент
function LOTM.Ingredients.Get(ingredientId)
    return LOTM.Ingredients.Registry[ingredientId]
end

-- Получить все ингредиенты категории
function LOTM.Ingredients.GetByCategory(category)
    local ingredients = {}
    for id, data in pairs(LOTM.Ingredients.Registry) do
        if data.category == category then
            table.insert(ingredients, data)
        end
    end
    return ingredients
end

-- Получить все ингредиенты
function LOTM.Ingredients.GetAll()
    return LOTM.Ingredients.Registry
end

-- Цвета редкости
LOTM.Ingredients.RarityColors = {
    [1] = Color(200, 200, 200),     -- Common - серый
    [2] = Color(100, 255, 100),     -- Uncommon - зеленый
    [3] = Color(100, 150, 255),     -- Rare - синий
    [4] = Color(180, 100, 255),     -- Epic - фиолетовый
    [5] = Color(255, 180, 50),      -- Legendary - оранжевый
}

LOTM.Ingredients.RarityNames = {
    [1] = "Обычный",
    [2] = "Необычный",
    [3] = "Редкий",
    [4] = "Эпический",
    [5] = "Легендарный",
}

-- =============================================
-- Регистрация ингредиентов
-- =============================================

-- Регистрация происходит сразу, не ждем InitPostEntity
local function RegisterAllIngredients()
    
    -- =============================================
    -- РАСТЕНИЯ
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "nightshade",
        name = "Ночная Тень",
        description = "Ядовитое растение, цветущее только в полнолуние. Используется в проклятиях.",
        category = LOTM.Ingredients.Categories.PLANTS,
        rarity = 2,
        model = "models/props_foliage/tree_poplar01.mdl",
        ritualPower = 10,
    })
    
    LOTM.Ingredients.Register({
        id = "moonflower",
        name = "Лунный Цветок",
        description = "Редкий цветок, впитавший лунный свет. Усиливает духовные способности.",
        category = LOTM.Ingredients.Categories.PLANTS,
        rarity = 3,
        model = "models/props_foliage/tree_poplar01.mdl",
        ritualPower = 25,
    })
    
    LOTM.Ingredients.Register({
        id = "bloodroot",
        name = "Кровяной Корень",
        description = "Корень, растущий на местах массовых смертей. Содержит духовную энергию.",
        category = LOTM.Ingredients.Categories.PLANTS,
        rarity = 3,
        model = "models/props_junk/garbage_bag001a.mdl",
        ritualPower = 30,
    })
    
    LOTM.Ingredients.Register({
        id = "soulvine",
        name = "Лоза Душ",
        description = "Растение из мира духов. Способно улавливать эманации душ.",
        category = LOTM.Ingredients.Categories.PLANTS,
        rarity = 4,
        model = "models/props_foliage/tree_poplar01.mdl",
        ritualPower = 50,
    })
    
    -- =============================================
    -- МИНЕРАЛЫ
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "spirit_crystal",
        name = "Духовный Кристалл",
        description = "Кристалл, способный накапливать духовную энергию.",
        category = LOTM.Ingredients.Categories.MINERALS,
        rarity = 2,
        model = "models/props_junk/rock001a.mdl",
        ritualPower = 15,
    })
    
    LOTM.Ingredients.Register({
        id = "void_stone",
        name = "Камень Пустоты",
        description = "Чёрный камень из глубин земли. Поглощает свет и звук.",
        category = LOTM.Ingredients.Categories.MINERALS,
        rarity = 3,
        model = "models/props_junk/rock001a.mdl",
        ritualPower = 35,
    })
    
    LOTM.Ingredients.Register({
        id = "celestial_ore",
        name = "Небесная Руда",
        description = "Руда, упавшая с небес. Содержит частицы божественной силы.",
        category = LOTM.Ingredients.Categories.MINERALS,
        rarity = 4,
        model = "models/props_junk/rock001a.mdl",
        ritualPower = 60,
    })
    
    LOTM.Ingredients.Register({
        id = "primordial_gem",
        name = "Первозданный Камень",
        description = "Камень из времён сотворения мира. Невероятно редкий.",
        category = LOTM.Ingredients.Categories.MINERALS,
        rarity = 5,
        model = "models/props_junk/rock001a.mdl",
        ritualPower = 100,
    })
    
    -- =============================================
    -- КРОВЬ И ТЕЛЕСНЫЕ ЖИДКОСТИ
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "human_blood",
        name = "Человеческая Кровь",
        description = "Свежая человеческая кровь. Базовый ингредиент многих ритуалов.",
        category = LOTM.Ingredients.Categories.BLOOD,
        rarity = 1,
        model = "models/props_lab/jar01b.mdl",
        ritualPower = 5,
    })
    
    LOTM.Ingredients.Register({
        id = "beyonder_blood",
        name = "Кровь Бейондера",
        description = "Кровь существа, принявшего зелье. Содержит следы необыкновенных сил.",
        category = LOTM.Ingredients.Categories.BLOOD,
        rarity = 3,
        model = "models/props_lab/jar01b.mdl",
        ritualPower = 40,
    })
    
    LOTM.Ingredients.Register({
        id = "angel_tears",
        name = "Слёзы Ангела",
        description = "Слёзы существа последовательности 2 или выше. Крайне редки.",
        category = LOTM.Ingredients.Categories.BLOOD,
        rarity = 5,
        model = "models/props_lab/jar01b.mdl",
        ritualPower = 120,
    })
    
    -- =============================================
    -- ДУХОВНОЕ
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "ectoplasm",
        name = "Эктоплазма",
        description = "Субстанция духовного мира. Оставляется призраками.",
        category = LOTM.Ingredients.Categories.SPIRITUAL,
        rarity = 2,
        model = "models/props_junk/garbage_plasticbottle001a.mdl",
        ritualPower = 15,
    })
    
    LOTM.Ingredients.Register({
        id = "dream_essence",
        name = "Эссенция Снов",
        description = "Конденсированная субстанция из мира снов.",
        category = LOTM.Ingredients.Categories.SPIRITUAL,
        rarity = 3,
        model = "models/props_lab/jar01a.mdl",
        ritualPower = 35,
    })
    
    LOTM.Ingredients.Register({
        id = "nightmare_shard",
        name = "Осколок Кошмара",
        description = "Кристаллизованный кошмар. Излучает страх.",
        category = LOTM.Ingredients.Categories.SPIRITUAL,
        rarity = 4,
        model = "models/props_junk/rock001a.mdl",
        ritualPower = 55,
    })
    
    LOTM.Ingredients.Register({
        id = "soul_fragment",
        name = "Осколок Души",
        description = "Фрагмент человеческой души. Получение связано с тёмными практиками.",
        category = LOTM.Ingredients.Categories.SPIRITUAL,
        rarity = 4,
        model = "models/props_combine/breenglobe.mdl",
        ritualPower = 70,
    })
    
    -- =============================================
    -- МАТЕРИАЛЫ
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "silver_dust",
        name = "Серебряная Пыль",
        description = "Мелко измельчённое серебро. Защищает от нечистой силы.",
        category = LOTM.Ingredients.Categories.MATERIALS,
        rarity = 1,
        model = "models/props_junk/garbage_metalcan001a.mdl",
        ritualPower = 8,
    })
    
    LOTM.Ingredients.Register({
        id = "holy_water",
        name = "Святая Вода",
        description = "Вода, освящённая священником. Отталкивает зло.",
        category = LOTM.Ingredients.Categories.MATERIALS,
        rarity = 1,
        model = "models/props_junk/glassjug01.mdl",
        ritualPower = 10,
    })
    
    LOTM.Ingredients.Register({
        id = "ritual_candle",
        name = "Ритуальная Свеча",
        description = "Чёрная свеча из особого воска. Необходима для большинства ритуалов.",
        category = LOTM.Ingredients.Categories.MATERIALS,
        rarity = 1,
        model = "models/props_c17/candle01a.mdl",
        ritualPower = 5,
    })
    
    LOTM.Ingredients.Register({
        id = "ritual_chalk",
        name = "Ритуальный Мел",
        description = "Мел для рисования магических кругов.",
        category = LOTM.Ingredients.Categories.MATERIALS,
        rarity = 1,
        model = "models/props_junk/garbage_plasticbottle001a.mdl",
        ritualPower = 3,
    })
    
    -- =============================================
    -- BEYONDER
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "characteristic_fragment",
        name = "Фрагмент Характеристики",
        description = "Осколок характеристики Бейондера. Содержит его силу.",
        category = LOTM.Ingredients.Categories.BEYONDER,
        rarity = 4,
        model = "models/props_junk/rock001a.mdl",
        ritualPower = 80,
    })
    
    LOTM.Ingredients.Register({
        id = "pathway_essence",
        name = "Эссенция Пути",
        description = "Концентрированная сила определённого пути.",
        category = LOTM.Ingredients.Categories.BEYONDER,
        rarity = 4,
        model = "models/props_lab/jar01a.mdl",
        ritualPower = 65,
    })
    
    -- =============================================
    -- БОЖЕСТВЕННОЕ
    -- =============================================
    
    LOTM.Ingredients.Register({
        id = "divine_blessing",
        name = "Божественное Благословение",
        description = "Материализованное благословение божества.",
        category = LOTM.Ingredients.Categories.DIVINE,
        rarity = 5,
        model = "models/props_combine/breenglobe.mdl",
        ritualPower = 150,
    })
    
    LOTM.Ingredients.Register({
        id = "sefirot_shard",
        name = "Осколок Сефиры",
        description = "Невероятно редкий осколок Древа Сефирот.",
        category = LOTM.Ingredients.Categories.DIVINE,
        rarity = 5,
        model = "models/props_combine/breenglobe.mdl",
        ritualPower = 200,
    })
    
    MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
         "Mystical ingredients registered: " .. table.Count(LOTM.Ingredients.Registry) .. "\n")
end

-- Регистрируем сразу
RegisterAllIngredients()

-- =============================================
-- Интеграция с инвентарем
-- =============================================

-- Таблица соответствия ID инвентаря и ID ингредиентов
LOTM.Ingredients.InventoryIDs = {}

hook.Add("InitPostEntity", "LOTM.Ingredients.RegisterInventory", function()
    timer.Simple(1, function()
        if not dbt or not dbt.inventory or not dbt.inventory.items then 
            MsgC(Color(255, 100, 100), "[LOTM] ", Color(255, 255, 255), "Warning: dbt.inventory not found\n")
            return 
        end
        
        local baseId = 500 -- Начальный ID для ингредиентов
        
        for ingredientId, data in pairs(LOTM.Ingredients.Registry) do
            local itemId = baseId
            baseId = baseId + 1
            
            -- Сохраняем соответствие
            LOTM.Ingredients.InventoryIDs[ingredientId] = itemId
            
            local rarityColor = LOTM.Ingredients.RarityColors[data.rarity] or Color(255, 255, 255)
            local rarityName = LOTM.Ingredients.RarityNames[data.rarity] or "Обычный"
            
            dbt.inventory.items[itemId] = {
                name = data.name,
                mdl = data.model,
                kg = 0.1,
                ingredient = true,
                ingredientId = ingredientId,
                notEditable = true,
                lotmItem = true,
                
                GetDescription = function(self)
                    local text = {}
                    text[#text+1] = rarityColor
                    text[#text+1] = "[" .. rarityName .. "] "
                    text[#text+1] = color_white
                    text[#text+1] = data.description
                    text[#text+1] = true
                    text[#text+1] = Color(150, 150, 255)
                    text[#text+1] = "Категория: " .. (LOTM.Ingredients.CategoryNames[data.category] or "Неизвестно")
                    text[#text+1] = true
                    text[#text+1] = Color(255, 200, 100)
                    text[#text+1] = "Ритуальная сила: " .. (data.ritualPower or 0)
                    return text
                end,
                
                descalt = {Color(175, 175, 175, 150), "Мистический ингредиент LOTM", true, "• Используется для создания зелий"},
            }
        end
        
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
             "Ingredients added to inventory system\n")
    end)
end)

-- Получить ID предмета инвентаря для ингредиента
function LOTM.Ingredients.GetInventoryID(ingredientId)
    return LOTM.Ingredients.InventoryIDs[ingredientId]
end

-- Проверить, есть ли у игрока ингредиент (серверная функция)
function LOTM.Ingredients.PlayerHas(ply, ingredientId)
    if not SERVER then return false end
    if not IsValid(ply) then return false end
    
    local itemId = LOTM.Ingredients.GetInventoryID(ingredientId)
    if not itemId then return false end
    
    -- Проверяем инвентарь игрока
    local playerInv = ply.dbt_inventory or {}
    for _, item in pairs(playerInv) do
        if item.id == itemId then
            return true
        end
    end
    
    return false
end

-- Получить количество ингредиента у игрока
function LOTM.Ingredients.PlayerCount(ply, ingredientId)
    if not SERVER then return 0 end
    if not IsValid(ply) then return 0 end
    
    local itemId = LOTM.Ingredients.GetInventoryID(ingredientId)
    if not itemId then return 0 end
    
    local count = 0
    local playerInv = ply.dbt_inventory or {}
    for _, item in pairs(playerInv) do
        if item.id == itemId then
            count = count + 1
        end
    end
    
    return count
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Mystical ingredients system loaded\n")
