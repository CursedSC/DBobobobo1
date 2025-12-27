-- LOTM Potion System Core
-- Базовая архитектура системы зелий

LOTM = LOTM or {}
LOTM.Potions = LOTM.Potions or {}
LOTM.Players = LOTM.Players or {}

-- Константы
LOTM.SEQUENCES = {
    [9] = "Sequence 9",
    [8] = "Sequence 8",
    [7] = "Sequence 7",
    [6] = "Sequence 6",
    [5] = "Sequence 5",
    [4] = "Sequence 4",
    [3] = "Sequence 3",
    [2] = "Sequence 2",
    [1] = "Sequence 1",
    [0] = "Sequence 0"
}

LOTM.ABILITY_TYPES = {
    ACTIVE = 1,
    PASSIVE = 2
}

-- Структура зелья
function LOTM.CreatePotion(data)
    local potion = {
        UID = data.UID or "",
        Name = data.Name or "Unknown Potion",
<<<<<<< HEAD
        Pathway = data.Pathway or 0,
=======
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
        Sequence = data.Sequence or 9,
        Description = data.Description or "",
        Abilities = data.Abilities or {},
        DigestionRate = data.DigestionRate or 0.01,
        MadnessRisk = data.MadnessRisk or 0.1,
        Model = data.Model or "models/props_junk/PopCan01a.mdl",
<<<<<<< HEAD
        Icon = data.Icon or "icon16/pill.png",
        Ingredients = data.Ingredients or {},
=======
        Icon = data.Icon or "icon16/pill.png"
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
    }
    
    return potion
end

-- Структура способности
function LOTM.CreateAbility(data)
    local ability = {
        ID = data.ID or "",
        Name = data.Name or "Unknown Ability",
        Description = data.Description or "",
        Type = data.Type or LOTM.ABILITY_TYPES.ACTIVE,
        EnergyCost = data.EnergyCost or 10,
        Cooldown = data.Cooldown or 5,
        Slot = data.Slot or 1,
        Icon = data.Icon or "icon16/wand.png",
        OnActivate = data.OnActivate or function(ply) end,
        OnPassive = data.OnPassive or function(ply) end,
        Condition = data.Condition or function(ply) return true end
    }
    
    return ability
end

-- Регистрация зелья
function LOTM.RegisterPotion(potion)
    if not potion.UID or potion.UID == "" then
        ErrorNoHalt("[LOTM] Cannot register potion without UID!\n")
        return false
    end
    
    LOTM.Potions[potion.UID] = potion
    
<<<<<<< HEAD
=======
    if SERVER then
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Registered potion: ", Color(100, 200, 255), potion.Name, " (", potion.UID, ")\n")
    end
    
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
    return true
end

-- Получить зелье по UID
function LOTM.GetPotion(uid)
    return LOTM.Potions[uid]
end

-- Получить все зелья
function LOTM.GetAllPotions()
    return LOTM.Potions
end

-- Получить зелья по уровню sequence
function LOTM.GetPotionsBySequence(sequence)
    local result = {}
    
    for uid, potion in pairs(LOTM.Potions) do
        if potion.Sequence == sequence then
            table.insert(result, potion)
        end
    end
    
    return result
end

<<<<<<< HEAD
-- Получить зелья по пути
function LOTM.GetPotionsByPathway(pathway)
    local result = {}
    
    for uid, potion in pairs(LOTM.Potions) do
        if potion.Pathway == pathway then
            table.insert(result, potion)
        end
    end
    
    -- Сортировка по последовательности (от 9 к 0)
    table.sort(result, function(a, b) return a.Sequence > b.Sequence end)
    
    return result
end

-- =============================================
-- Интеграция с инвентарем
-- =============================================

LOTM.Potions.InventoryIDs = LOTM.Potions.InventoryIDs or {}

hook.Add("InitPostEntity", "LOTM.Potions.RegisterInventory", function()
    timer.Simple(2, function()
        if not dbt or not dbt.inventory or not dbt.inventory.items then 
            MsgC(Color(255, 100, 100), "[LOTM] ", Color(255, 255, 255), "Warning: dbt.inventory not found for potions\n")
            return 
        end
        
        local baseId = 600 -- Начальный ID для зелий
        
        for potionUID, data in pairs(LOTM.Potions) do
            local itemId = baseId
            baseId = baseId + 1
            
            -- Сохраняем соответствие
            LOTM.Potions.InventoryIDs[potionUID] = itemId
            
            -- Цвет по последовательности
            local seqColors = {
                [9] = Color(200, 200, 200),
                [8] = Color(100, 255, 100),
                [7] = Color(100, 200, 255),
                [6] = Color(150, 100, 255),
                [5] = Color(255, 100, 255),
                [4] = Color(255, 150, 50),
                [3] = Color(255, 100, 100),
                [2] = Color(255, 215, 0),
                [1] = Color(255, 50, 50),
                [0] = Color(255, 255, 255),
            }
            
            local potionColor = seqColors[data.Sequence] or Color(255, 255, 255)
            local pathwayName = "Универсальное"
            if LOTM.PathwaysList and LOTM.PathwaysList[data.Pathway] then
                pathwayName = LOTM.PathwaysList[data.Pathway].name
            end
            
            dbt.inventory.items[itemId] = {
                name = "Зелье: " .. data.Name,
                mdl = data.Model,
                kg = 0.3,
                potion = true,
                potionUID = potionUID,
                notEditable = true,
                lotmItem = true,
                
                GetDescription = function(self)
                    local text = {}
                    text[#text+1] = potionColor
                    text[#text+1] = "[Seq " .. data.Sequence .. "] "
                    text[#text+1] = color_white
                    text[#text+1] = data.Description
                    text[#text+1] = true
                    text[#text+1] = Color(150, 100, 255)
                    text[#text+1] = "Путь: " .. pathwayName
                    text[#text+1] = true
                    text[#text+1] = Color(255, 200, 100)
                    text[#text+1] = "Скорость переваривания: " .. math.floor(data.DigestionRate * 100) .. "%"
                    text[#text+1] = true
                    text[#text+1] = Color(255, 100, 100)
                    text[#text+1] = "Риск безумия: " .. math.floor(data.MadnessRisk * 100) .. "%"
                    
                    if data.Abilities and #data.Abilities > 0 then
                        text[#text+1] = true
                        text[#text+1] = Color(100, 255, 100)
                        text[#text+1] = "Способности:"
                        for _, ab in ipairs(data.Abilities) do
                            text[#text+1] = true
                            text[#text+1] = Color(100, 255, 100)
                            text[#text+1] = "  • " .. ab.Name
                        end
                    end
                    
                    return text
                end,
                
                descalt = {potionColor, "Зелье Beyonder", true, "• Выпейте, чтобы стать Beyonder'ом"},
                
                -- Использование зелья
                OnUse = function(ply, itemData)
                    if SERVER then
                        -- Здесь логика принятия зелья
                        ply:ChatPrint("[LOTM] Вы выпили зелье " .. data.Name .. "!")
                        ply:SetNWInt("LOTM_Pathway", data.Pathway)
                        ply:SetNWInt("LOTM_Sequence", data.Sequence)
                        return true -- Удалить предмет
                    end
                end,
            }
        end
        
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
             "Potions added to inventory: " .. table.Count(LOTM.Potions) .. "\n")
    end)
end)

-- Получить ID предмета инвентаря для зелья
function LOTM.GetPotionInventoryID(potionUID)
    return LOTM.Potions.InventoryIDs[potionUID]
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Potion core system loaded\n")
=======
MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Core system loaded\n")
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
