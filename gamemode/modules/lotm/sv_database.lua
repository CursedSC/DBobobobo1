-- LOTM Database System
-- Централизованная система базы данных для LOTM

if not SERVER then return end

LOTM = LOTM or {}
LOTM.Database = LOTM.Database or {}

-- =============================================
-- Инициализация таблиц
-- =============================================

function LOTM.Database.Initialize()
    -- Таблица данных игроков
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_players (
            steamid TEXT PRIMARY KEY,
            pathway INTEGER DEFAULT 0,
            sequence INTEGER DEFAULT 9,
            current_potion TEXT,
            digestion_progress REAL DEFAULT 0,
            abilities TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Таблица зелий игроков
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_potions (
            steamid TEXT,
            potion_id TEXT,
            quantity INTEGER DEFAULT 1,
            PRIMARY KEY (steamid, potion_id)
        )
    ]])
    
    -- Таблица ингредиентов игроков
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_ingredients (
            steamid TEXT,
            ingredient_id TEXT,
            quantity INTEGER DEFAULT 1,
            PRIMARY KEY (steamid, ingredient_id)
        )
    ]])
    
    -- Таблица артефактов игроков
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_player_artifacts (
            steamid TEXT,
            artifact_id TEXT,
            equipped_slot TEXT,
            PRIMARY KEY (steamid, artifact_id)
        )
    ]])
    
    -- Таблица логов
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT,
            action TEXT,
            details TEXT,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Database initialized\n")
end

LOTM.Database.Initialize()

-- =============================================
-- Данные игроков
-- =============================================

function LOTM.Database.GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    
    local steamId = ply:SteamID64()
    
    local result = sql.Query(string.format(
        "SELECT * FROM lotm_players WHERE steamid = %s",
        sql.SQLStr(steamId)
    ))
    
    if result and result[1] then
        return {
            pathway = tonumber(result[1].pathway) or 0,
            sequence = tonumber(result[1].sequence) or 9,
            currentPotion = result[1].current_potion,
            digestionProgress = tonumber(result[1].digestion_progress) or 0,
            abilities = result[1].abilities and util.JSONToTable(result[1].abilities) or {},
        }
    end
    
    -- Создаем запись если её нет
    LOTM.Database.CreatePlayerData(ply)
    
    return {
        pathway = 0,
        sequence = 9,
        currentPotion = nil,
        digestionProgress = 0,
        abilities = {},
    }
end

function LOTM.Database.CreatePlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamId = ply:SteamID64()
    
    sql.Query(string.format(
        "INSERT OR IGNORE INTO lotm_players (steamid) VALUES (%s)",
        sql.SQLStr(steamId)
    ))
end

function LOTM.Database.SavePlayerData(ply, data)
    if not IsValid(ply) then return end
    
    local steamId = ply:SteamID64()
    local abilitiesJson = util.TableToJSON(data.abilities or {})
    
    sql.Query(string.format(
        [[UPDATE lotm_players SET 
            pathway = %d,
            sequence = %d,
            current_potion = %s,
            digestion_progress = %f,
            abilities = %s,
            updated_at = CURRENT_TIMESTAMP
        WHERE steamid = %s]],
        data.pathway or 0,
        data.sequence or 9,
        sql.SQLStr(data.currentPotion or ""),
        data.digestionProgress or 0,
        sql.SQLStr(abilitiesJson),
        sql.SQLStr(steamId)
    ))
end

-- =============================================
-- Зелья
-- =============================================

function LOTM.Database.GetPlayerPotions(ply)
    if not IsValid(ply) then return {} end
    
    local steamId = ply:SteamID64()
    
    local result = sql.Query(string.format(
        "SELECT potion_id, quantity FROM lotm_potions WHERE steamid = %s",
        sql.SQLStr(steamId)
    ))
    
    local potions = {}
    if result then
        for _, row in ipairs(result) do
            potions[row.potion_id] = tonumber(row.quantity) or 0
        end
    end
    
    return potions
end

function LOTM.Database.AddPotion(ply, potionId, amount)
    if not IsValid(ply) then return end
    
    local steamId = ply:SteamID64()
    amount = amount or 1
    
    sql.Query(string.format(
        [[INSERT INTO lotm_potions (steamid, potion_id, quantity) VALUES (%s, %s, %d)
          ON CONFLICT(steamid, potion_id) DO UPDATE SET quantity = quantity + %d]],
        sql.SQLStr(steamId),
        sql.SQLStr(potionId),
        amount,
        amount
    ))
    
    LOTM.Database.Log(ply, "potion_add", potionId .. " x" .. amount)
end

function LOTM.Database.RemovePotion(ply, potionId, amount)
    if not IsValid(ply) then return end
    
    local steamId = ply:SteamID64()
    amount = amount or 1
    
    -- Получаем текущее количество
    local result = sql.Query(string.format(
        "SELECT quantity FROM lotm_potions WHERE steamid = %s AND potion_id = %s",
        sql.SQLStr(steamId),
        sql.SQLStr(potionId)
    ))
    
    if result and result[1] then
        local current = tonumber(result[1].quantity) or 0
        local newAmount = current - amount
        
        if newAmount <= 0 then
            sql.Query(string.format(
                "DELETE FROM lotm_potions WHERE steamid = %s AND potion_id = %s",
                sql.SQLStr(steamId),
                sql.SQLStr(potionId)
            ))
        else
            sql.Query(string.format(
                "UPDATE lotm_potions SET quantity = %d WHERE steamid = %s AND potion_id = %s",
                newAmount,
                sql.SQLStr(steamId),
                sql.SQLStr(potionId)
            ))
        end
    end
end

-- =============================================
-- Ингредиенты
-- =============================================

function LOTM.Database.GetPlayerIngredients(ply)
    if not IsValid(ply) then return {} end
    
    local steamId = ply:SteamID64()
    
    local result = sql.Query(string.format(
        "SELECT ingredient_id, quantity FROM lotm_ingredients WHERE steamid = %s",
        sql.SQLStr(steamId)
    ))
    
    local ingredients = {}
    if result then
        for _, row in ipairs(result) do
            ingredients[row.ingredient_id] = tonumber(row.quantity) or 0
        end
    end
    
    return ingredients
end

function LOTM.Database.AddIngredient(ply, ingredientId, amount)
    if not IsValid(ply) then return end
    
    local steamId = ply:SteamID64()
    amount = amount or 1
    
    sql.Query(string.format(
        [[INSERT INTO lotm_ingredients (steamid, ingredient_id, quantity) VALUES (%s, %s, %d)
          ON CONFLICT(steamid, ingredient_id) DO UPDATE SET quantity = quantity + %d]],
        sql.SQLStr(steamId),
        sql.SQLStr(ingredientId),
        amount,
        amount
    ))
end

function LOTM.Database.RemoveIngredient(ply, ingredientId, amount)
    if not IsValid(ply) then return end
    
    local steamId = ply:SteamID64()
    amount = amount or 1
    
    local result = sql.Query(string.format(
        "SELECT quantity FROM lotm_ingredients WHERE steamid = %s AND ingredient_id = %s",
        sql.SQLStr(steamId),
        sql.SQLStr(ingredientId)
    ))
    
    if result and result[1] then
        local current = tonumber(result[1].quantity) or 0
        local newAmount = current - amount
        
        if newAmount <= 0 then
            sql.Query(string.format(
                "DELETE FROM lotm_ingredients WHERE steamid = %s AND ingredient_id = %s",
                sql.SQLStr(steamId),
                sql.SQLStr(ingredientId)
            ))
        else
            sql.Query(string.format(
                "UPDATE lotm_ingredients SET quantity = %d WHERE steamid = %s AND ingredient_id = %s",
                newAmount,
                sql.SQLStr(steamId),
                sql.SQLStr(ingredientId)
            ))
        end
    end
end

-- =============================================
-- Логирование
-- =============================================

function LOTM.Database.Log(ply, action, details)
    local steamId = IsValid(ply) and ply:SteamID64() or "SYSTEM"
    
    sql.Query(string.format(
        "INSERT INTO lotm_logs (steamid, action, details) VALUES (%s, %s, %s)",
        sql.SQLStr(steamId),
        sql.SQLStr(action),
        sql.SQLStr(details or "")
    ))
end

-- =============================================
-- Консольные команды
-- =============================================

-- Выдать зелье игроку
concommand.Add("lotm_give_potion", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local targetName = args[1]
    local potionId = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not targetName or not potionId then
        local msg = "Использование: lotm_give_potion <игрок> <potion_id> [количество]"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        local msg = "[LOTM] Игрок не найден: " .. targetName
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    LOTM.Database.AddPotion(target, potionId, amount)
    
    local msg = string.format("[LOTM] Выдано зелье %s x%d игроку %s", potionId, amount, target:Name())
    if IsValid(ply) then ply:ChatPrint(msg) end
    print(msg)
    target:ChatPrint(string.format("[LOTM] Вы получили зелье: %s x%d", potionId, amount))
end)

-- Выдать ингредиент игроку
concommand.Add("lotm_give_ingredient", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local targetName = args[1]
    local ingredientId = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not targetName or not ingredientId then
        local msg = "Использование: lotm_give_ingredient <игрок> <ingredient_id> [количество]"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        local msg = "[LOTM] Игрок не найден: " .. targetName
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    LOTM.Database.AddIngredient(target, ingredientId, amount)
    
    local ingredient = LOTM.Ingredients and LOTM.Ingredients.Get(ingredientId)
    local name = ingredient and ingredient.name or ingredientId
    
    local msg = string.format("[LOTM] Выдан ингредиент %s x%d игроку %s", name, amount, target:Name())
    if IsValid(ply) then ply:ChatPrint(msg) end
    print(msg)
    target:ChatPrint(string.format("[LOTM] Вы получили: %s x%d", name, amount))
end)

-- Установить путь игроку
concommand.Add("lotm_set_pathway", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local targetName = args[1]
    local pathwayId = tonumber(args[2])
    
    if not targetName or not pathwayId then
        local msg = "Использование: lotm_set_pathway <игрок> <pathway_id>\nПути: 1-22 (см. sh_lotm_pathways.lua)"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        local msg = "[LOTM] Игрок не найден: " .. targetName
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    target:SetNWInt("LOTM_Pathway", pathwayId)
    
    local data = LOTM.Database.GetPlayerData(target)
    data.pathway = pathwayId
    LOTM.Database.SavePlayerData(target, data)
    
    -- Назначаем способности
    if LOTM.SequenceAbilities then
        LOTM.SequenceAbilities.AssignToPlayer(target)
    end
    
    local pathwayName = LOTM.GetPathwayName and LOTM.GetPathwayName(pathwayId) or tostring(pathwayId)
    
    local msg = string.format("[LOTM] Установлен путь %s для %s", pathwayName, target:Name())
    if IsValid(ply) then ply:ChatPrint(msg) end
    print(msg)
    target:ChatPrint(string.format("[LOTM] Ваш путь: %s", pathwayName))
    
    hook.Run("LOTM_PathwaySelected", target, pathwayId)
end)

-- Установить последовательность игроку
concommand.Add("lotm_set_sequence", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local targetName = args[1]
    local sequence = tonumber(args[2])
    
    if not targetName or not sequence then
        local msg = "Использование: lotm_set_sequence <игрок> <sequence>\nПоследовательности: 9 (начало) -> 0 (бог)"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        local msg = "[LOTM] Игрок не найден: " .. targetName
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    local oldSequence = target:GetNWInt("LOTM_Sequence", 9)
    target:SetNWInt("LOTM_Sequence", sequence)
    
    local data = LOTM.Database.GetPlayerData(target)
    data.sequence = sequence
    LOTM.Database.SavePlayerData(target, data)
    
    -- Назначаем способности
    if LOTM.SequenceAbilities then
        LOTM.SequenceAbilities.AssignToPlayer(target)
    end
    
    local pathwayId = target:GetNWInt("LOTM_Pathway", 0)
    local seqName = LOTM.GetSequenceName and LOTM.GetSequenceName(pathwayId, sequence) or tostring(sequence)
    
    local msg = string.format("[LOTM] Установлена последовательность %d (%s) для %s", sequence, seqName, target:Name())
    if IsValid(ply) then ply:ChatPrint(msg) end
    print(msg)
    target:ChatPrint(string.format("[LOTM] Ваша последовательность: %d - %s", sequence, seqName))
    
    hook.Run("LOTM_SequenceChanged", target, oldSequence, sequence)
end)

-- Выдать артефакт
concommand.Add("lotm_give_artifact", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local targetName = args[1]
    local artifactId = args[2]
    
    if not targetName or not artifactId then
        local msg = "Использование: lotm_give_artifact <игрок> <artifact_id>"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        local msg = "[LOTM] Игрок не найден: " .. targetName
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    local artifact = LOTM.Artifacts and LOTM.Artifacts.Get(artifactId)
    if not artifact then
        local msg = "[LOTM] Артефакт не найден: " .. artifactId
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    -- Добавляем в инвентарь как предмет
    -- Тут нужна интеграция с инвентарем проекта
    
    local msg = string.format("[LOTM] Выдан артефакт %s игроку %s", artifact.name, target:Name())
    if IsValid(ply) then ply:ChatPrint(msg) end
    print(msg)
    target:ChatPrint(string.format("[LOTM] Вы получили артефакт: %s", artifact.name))
end)

-- Список всех зелий
concommand.Add("lotm_list_potions", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local msg = "=== Доступные зелья ==="
    if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
    
    if LOTM.Potions then
        for id, data in pairs(LOTM.Potions) do
            msg = string.format("  %s - %s (Seq %d)", id, data.Name or id, data.Sequence or 9)
            if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        end
    end
end)

-- Список ингредиентов
concommand.Add("lotm_list_ingredients", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local msg = "=== Мистические ингредиенты ==="
    if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
    
    if LOTM.Ingredients then
        for id, data in pairs(LOTM.Ingredients.Registry) do
            local rarityName = LOTM.Ingredients.RarityNames[data.rarity] or "?"
            msg = string.format("  %s - %s [%s]", id, data.name, rarityName)
            if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        end
    end
end)

-- Список артефактов
concommand.Add("lotm_list_artifacts", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] У вас нет прав!")
        return
    end
    
    local msg = "=== Артефакты ==="
    if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
    
    if LOTM.Artifacts then
        for id, data in pairs(LOTM.Artifacts.Registry) do
            msg = string.format("  %s - %s (%s)", id, data.name, data.type or "unknown")
            if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        end
    end
end)

-- Хуки сохранения/загрузки
hook.Add("PlayerInitialSpawn", "LOTM.Database.Load", function(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        
        local data = LOTM.Database.GetPlayerData(ply)
        
        -- Восстанавливаем NWVars
        ply:SetNWInt("LOTM_Pathway", data.pathway)
        ply:SetNWInt("LOTM_Sequence", data.sequence)
        
        -- Назначаем способности
        if LOTM.SequenceAbilities and data.pathway > 0 then
            LOTM.SequenceAbilities.AssignToPlayer(ply)
        end
        
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
             "Loaded data for " .. ply:Name() .. "\n")
    end)
end)

hook.Add("PlayerDisconnected", "LOTM.Database.Save", function(ply)
    local data = {
        pathway = ply:GetNWInt("LOTM_Pathway", 0),
        sequence = ply:GetNWInt("LOTM_Sequence", 9),
        currentPotion = nil,
        digestionProgress = 0,
        abilities = LOTM.Abilities and LOTM.Abilities.GetPlayerAbilities(ply) or {},
    }
    
    LOTM.Database.SavePlayerData(ply, data)
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Database system loaded\n")

