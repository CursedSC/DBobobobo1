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
        Sequence = data.Sequence or 9,
        Description = data.Description or "",
        Abilities = data.Abilities or {},
        DigestionRate = data.DigestionRate or 0.01,
        MadnessRisk = data.MadnessRisk or 0.1,
        Model = data.Model or "models/props_junk/PopCan01a.mdl",
        Icon = data.Icon or "icon16/pill.png"
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
    
    if SERVER then
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Registered potion: ", Color(100, 200, 255), potion.Name, " (", potion.UID, ")\n")
    end
    
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

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Core system loaded\n")