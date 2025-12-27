-- LOTM Potion Recipes
-- Рецепты зелий для алтаря зельеварения

LOTM = LOTM or {}
LOTM.Recipes = LOTM.Recipes or {}

-- =============================================
-- СТРУКТУРА РЕЦЕПТА
-- =============================================
--[[
{
    id = "potion_id",
    name = "Название зелья",
    description = "Описание",
    pathway = 16,                    -- ID пути
    sequence = 8,                    -- Последовательность
    ingredients = {                   -- Список ингредиентов (отсортированный)
        "ingredient_id_1",
        "ingredient_id_2",
    },
    result = {                        -- Результат
        abilities = {"ability_1"},    -- Даёт способности
        stats = {},                   -- Изменяет статы
    },
}
]]

-- =============================================
-- РЕГИСТРАЦИЯ РЕЦЕПТОВ
-- =============================================

hook.Add("InitPostEntity", "LOTM.Recipes.Register", function()
    timer.Simple(1, function()
        
        -- ========== ПУТЬ ТЬМЫ (Pathway 16) ==========
        
        -- Seq 9: Спящий (Sleeper)
        LOTM.Recipes["potion_sleeper"] = {
            id = "potion_sleeper",
            name = "Зелье Спящего",
            description = "Первое зелье пути Тьмы. Открывает способности сна и ночного зрения.",
            pathway = 16,
            sequence = 9,
            ingredients = {
                "dream_essence",
                "nightshade",
                "spirit_crystal",
            },
            result = {
                abilities = {"darkness_vision", "dream_walk"},
                stats = {
                    spiritualPower = 10,
                },
            },
        }
        
        -- Seq 8: Полуночный Поэт (Midnight Poet)
        LOTM.Recipes["potion_midnight_poet"] = {
            id = "potion_midnight_poet",
            name = "Зелье Полуночного Поэта",
            description = "Даёт власть над кровью и проклятиями через стихи.",
            pathway = 16,
            sequence = 8,
            ingredients = {
                "beyonder_blood",
                "bloodroot",
                "nightmare_shard",
                "moonflower",
            },
            result = {
                abilities = {"blood_manipulation", "poetry_curse", "wall_walking", "blood_drain"},
                stats = {
                    spiritualPower = 25,
                    corruption = 5,
                },
            },
        }
        
        -- Seq 7: Кошмар (Nightmare)
        LOTM.Recipes["potion_nightmare"] = {
            id = "potion_nightmare",
            name = "Зелье Кошмара",
            description = "Превращает вас в воплощение страха.",
            pathway = 16,
            sequence = 7,
            ingredients = {
                "nightmare_shard",
                "nightmare_shard",
                "soul_fragment",
                "void_stone",
                "ectoplasm",
            },
            result = {
                abilities = {"activate_aura_fear", "activate_aura_darkness"},
                stats = {
                    spiritualPower = 50,
                    mentalResist = 30,
                },
            },
        }
        
        -- ========== ПУТЬ ПРОВИДЦА (Pathway 1) ==========
        
        -- Seq 9: Провидец
        LOTM.Recipes["potion_seer"] = {
            id = "potion_seer",
            name = "Зелье Провидца",
            description = "Открывает духовное зрение и чувство опасности.",
            pathway = 1,
            sequence = 9,
            ingredients = {
                "spirit_crystal",
                "moonflower",
                "ectoplasm",
            },
            result = {
                abilities = {"danger_sense"},
                stats = {
                    perception = 20,
                },
            },
        }
        
        -- ========== УНИВЕРСАЛЬНЫЕ ==========
        
        -- Зелье силы
        LOTM.Recipes["potion_power"] = {
            id = "potion_power",
            name = "Зелье Духовной Силы",
            description = "Усиливает духовные способности.",
            sequence = 9,
            ingredients = {
                "spirit_crystal",
                "spirit_crystal",
                "holy_water",
            },
            result = {
                abilities = {"spiritual_strike"},
                stats = {
                    spiritualPower = 15,
                },
            },
        }
        
        -- Зелье исцеления
        LOTM.Recipes["potion_healing"] = {
            id = "potion_healing",
            name = "Зелье Исцеления",
            description = "Даёт способность исцелять раны.",
            sequence = 8,
            ingredients = {
                "moonflower",
                "holy_water",
                "soulvine",
            },
            result = {
                abilities = {"healing_light"},
                stats = {
                    healthRegen = 5,
                },
            },
        }
        
        -- Зелье защиты
        LOTM.Recipes["potion_protection"] = {
            id = "potion_protection",
            name = "Зелье Защиты",
            description = "Даёт способность создавать барьеры.",
            sequence = 7,
            ingredients = {
                "celestial_ore",
                "spirit_crystal",
                "silver_dust",
                "holy_water",
            },
            result = {
                abilities = {"barrier", "activate_aura_regeneration"},
                stats = {
                    defense = 20,
                },
            },
        }
        
        MsgC(Color(100, 255, 100), "[LOTM Recipes] ", Color(255, 255, 255), 
             "Рецептов зарегистрировано: " .. table.Count(LOTM.Recipes) .. "\n")
    end)
end)

-- Получить рецепт по ID
function LOTM.GetRecipe(recipeId)
    return LOTM.Recipes[recipeId]
end

-- Получить рецепты по пути
function LOTM.GetRecipesByPathway(pathwayId)
    local recipes = {}
    for id, recipe in pairs(LOTM.Recipes) do
        if recipe.pathway == pathwayId or not recipe.pathway then
            table.insert(recipes, recipe)
        end
    end
    return recipes
end

-- Проверить, может ли игрок выпить зелье
function LOTM.CanDrinkPotion(ply, recipe)
    if not IsValid(ply) then return false, "Игрок не найден" end
    if not recipe then return false, "Рецепт не найден" end
    
    local playerSeq = ply:GetNWInt("LOTM_Sequence", 9)
    local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
    
    -- Проверка пути
    if recipe.pathway and recipe.pathway ~= playerPathway and playerPathway ~= 0 then
        return false, "Это зелье другого пути"
    end
    
    -- Проверка последовательности
    if recipe.sequence then
        local seqDiff = playerSeq - recipe.sequence
        
        -- Нельзя пить зелье предыдущей последовательности (понижать себя)
        if seqDiff < 0 then
            return false, "Это зелье прошлой последовательности (Seq " .. recipe.sequence .. ")"
        end
        
        -- Нельзя пропустить более 1 последовательности
        if seqDiff > 1 then
            return false, "Слишком высокая последовательность (пропуск более 1)"
        end
        
        -- Нельзя пить зелье своей же последовательности если уже выпил
        if seqDiff == 0 and playerPathway == recipe.pathway then
            -- TODO: проверка на уже выпитое зелье
        end
    end
    
    return true
end

-- Выпить зелье
function LOTM.DrinkPotion(ply, recipe)
    if not SERVER then return false end
    if not IsValid(ply) then return false end
    
    local canDrink, reason = LOTM.CanDrinkPotion(ply, recipe)
    if not canDrink then
        ply:ChatPrint("[LOTM] " .. reason)
        return false
    end
    
    -- Устанавливаем путь если первое зелье
    local currentPathway = ply:GetNWInt("LOTM_Pathway", 0)
    if currentPathway == 0 and recipe.pathway then
        ply:SetNWInt("LOTM_Pathway", recipe.pathway)
    end
    
    -- Устанавливаем последовательность
    local oldSeq = ply:GetNWInt("LOTM_Sequence", 9)
    if recipe.sequence then
        ply:SetNWInt("LOTM_Sequence", recipe.sequence)
    end
    
    -- Даём способности
    if recipe.result and recipe.result.abilities and LOTM.SequenceAbilities then
        LOTM.SequenceAbilities.AssignToPlayer(ply)
    end
    
    -- Применяем статы
    if recipe.result and recipe.result.stats then
        for stat, value in pairs(recipe.result.stats) do
            local current = ply:GetNWInt("LOTM_Stat_" .. stat, 0)
            ply:SetNWInt("LOTM_Stat_" .. stat, current + value)
        end
    end
    
    -- Сохраняем в БД
    if LOTM.Database then
        local data = LOTM.Database.GetPlayerData(ply) or {}
        data.pathway = ply:GetNWInt("LOTM_Pathway", 0)
        data.sequence = ply:GetNWInt("LOTM_Sequence", 9)
        LOTM.Database.SavePlayerData(ply, data)
    end
    
    -- Эффекты
    ply:EmitSound("ambient/energy/whiteflash.wav")
    
    local effectData = EffectData()
    effectData:SetOrigin(ply:GetPos() + Vector(0, 0, 40))
    util.Effect("cball_explode", effectData)
    
    -- Хук
    hook.Run("LOTM_SequenceChanged", ply, oldSeq, recipe.sequence)
    
    ply:ChatPrint("[LOTM] Вы выпили " .. recipe.name .. "!")
    ply:ChatPrint("[LOTM] Ваша последовательность: " .. recipe.sequence)
    
    return true
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Recipes system loaded\n")

