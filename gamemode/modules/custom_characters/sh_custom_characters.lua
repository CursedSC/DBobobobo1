-- Custom Characters System with LOTM Integration
-- Система создания кастомных персонажей с интеграцией последовательностей LOTM

DBT = DBT or {}
DBT.CustomCharacters = DBT.CustomCharacters or {}
DBT.CustomCharacters.List = DBT.CustomCharacters.List or {}
DBT.CustomCharacters.DataPath = "dbt/custom_characters.txt"

-- Структура кастомного персонажа
--[[
    {
        id = "custom_123456",
        steamid = "STEAM_0:X:XXXXX",
        name = "Имя персонажа",
        absl = "Абсолютный Талант",
        
        -- LOTM данные
        lotm = {
            pathway = 1, -- ID пути (1-22)
            sequence = 9, -- Текущая последовательность (9-0)
        },
        
        -- Базовые характеристики
        maxHealth = 100,
        maxHungry = 100,
        maxThird = 100,
        maxSleep = 100,
        runSpeed = 195,
        fistsDamageString = "5-10",
        maxKG = 20,
        maxInventory = 8,
        
        -- Кастомные предметы и оружие
        customItems = {},
        customWeapons = {},
        
        -- Модель (если не указана, используется стандартная)
        model = nil,
        
        -- Дата создания
        created = os.time(),
    }
]]

-- Загрузка кастомных персонажей из файла
function DBT.CustomCharacters.Load()
    if not file.Exists(DBT.CustomCharacters.DataPath, "DATA") then
        DBT.CustomCharacters.List = {}
        return
    end
    
    local data = file.Read(DBT.CustomCharacters.DataPath, "DATA")
    DBT.CustomCharacters.List = util.JSONToTable(data) or {}
    
    if SERVER then
        print("[Custom Characters] Загружено " .. table.Count(DBT.CustomCharacters.List) .. " кастомных персонажей")
    end
end

-- Сохранение кастомных персонажей в файл
function DBT.CustomCharacters.Save()
    local data = util.TableToJSON(DBT.CustomCharacters.List, true)
    file.Write(DBT.CustomCharacters.DataPath, data)
    
    if SERVER then
        print("[Custom Characters] Сохранено " .. table.Count(DBT.CustomCharacters.List) .. " кастомных персонажей")
    end
end

-- Создание нового кастомного персонажа
function DBT.CustomCharacters.Create(ply, data)
    if not IsValid(ply) then return false, "Игрок не найден" end
    
    -- Проверка обязательных полей
    if not data.name or data.name == "" then
        return false, "Укажите имя персонажа"
    end
    
    if not data.absl or data.absl == "" then
        return false, "Укажите абсолютный талант"
    end
    
    if not data.lotm or not data.lotm.pathway or not data.lotm.sequence then
        return false, "Выберите путь и последовательность LOTM"
    end
    
    -- Проверка валидности пути и последовательности
    if not LOTM.PathwaysList[data.lotm.pathway] then
        return false, "Неверный путь LOTM"
    end
    
    if data.lotm.sequence < 0 or data.lotm.sequence > 9 then
        return false, "Последовательность должна быть от 0 до 9"
    end
    
    -- Генерация уникального ID
    local charId = "custom_" .. ply:SteamID64() .. "_" .. os.time()
    
    -- Создание структуры персонажа
    local character = {
        id = charId,
        steamid = ply:SteamID(),
        name = data.name,
        absl = data.absl,
        
        lotm = {
            pathway = data.lotm.pathway,
            sequence = data.lotm.sequence,
        },
        
        -- Характеристики (или стандартные значения)
        maxHealth = data.maxHealth or 100,
        maxHungry = data.maxHungry or 100,
        maxThird = data.maxThird or 100,
        maxSleep = data.maxSleep or 100,
        runSpeed = data.runSpeed or 195,
        fistsDamageString = data.fistsDamageString or "5-10",
        maxKG = data.maxKG or 20,
        maxInventory = data.maxInventory or 8,
        
        customItems = data.customItems or {},
        customWeapons = data.customWeapons or {},
        model = data.model,
        
        created = os.time(),
        season = 20, -- Кастомные персонажи имеют season = 20
        char = charId,
    }
    
    -- Сохранение персонажа
    DBT.CustomCharacters.List[charId] = character
    DBT.CustomCharacters.Save()
    
    if SERVER then
        -- Добавление в глобальную таблицу персонажей
        dbt.chr = dbt.chr or {}
        dbt.chr[charId] = character
        
        -- Отправка всем клиентам
        net.Start("dbt.CustomChar.Sync")
        net.WriteTable({[charId] = character})
        net.Broadcast()
        
        print(string.format("[Custom Characters] %s создал персонажа '%s' (Путь: %s, Seq: %d)", 
            ply:Nick(), character.name, LOTM.GetPathwayName(character.lotm.pathway), character.lotm.sequence))
    end
    
    return true, charId
end

-- Получить кастомных персонажей игрока
function DBT.CustomCharacters.GetPlayerCharacters(ply)
    if not IsValid(ply) then return {} end
    
    local chars = {}
    local steamid = ply:SteamID()
    
    for id, char in pairs(DBT.CustomCharacters.List) do
        if char.steamid == steamid then
            table.insert(chars, char)
        end
    end
    
    return chars
end

-- Удаление кастомного персонажа
function DBT.CustomCharacters.Delete(ply, charId)
    if not IsValid(ply) then return false, "Игрок не найден" end
    
    local char = DBT.CustomCharacters.List[charId]
    if not char then return false, "Персонаж не найден" end
    
    -- Проверка прав (только создатель или админ могут удалить)
    if char.steamid ~= ply:SteamID() and not ply:IsAdmin() then
        return false, "Недостаточно прав"
    end
    
    -- Удаление
    DBT.CustomCharacters.List[charId] = nil
    DBT.CustomCharacters.Save()
    
    if SERVER then
        dbt.chr[charId] = nil
        
        net.Start("dbt.CustomChar.Delete")
        net.WriteString(charId)
        net.Broadcast()
        
        print(string.format("[Custom Characters] %s удалил персонажа '%s'", ply:Nick(), char.name))
    end
    
    return true
end

-- Повышение последовательности
function DBT.CustomCharacters.PromoteSequence(ply, charId)
    if not IsValid(ply) then return false, "Игрок не найден" end
    
    local char = DBT.CustomCharacters.List[charId]
    if not char then return false, "Персонаж не найден" end
    
    -- Проверка прав
    if char.steamid ~= ply:SteamID() and not ply:IsAdmin() then
        return false, "Недостаточно прав"
    end
    
    -- Проверка возможности повышения
    if not LOTM.CanPromoteSequence(char.lotm.sequence) then
        return false, "Достигнута максимальная последовательность (Sequence 0)"
    end
    
    -- Повышение
    local oldSeq = char.lotm.sequence
    char.lotm.sequence = LOTM.PromoteSequence(char.lotm.sequence)
    
    DBT.CustomCharacters.Save()
    
    if SERVER then
        dbt.chr[charId] = char
        
        net.Start("dbt.CustomChar.Sync")
        net.WriteTable({[charId] = char})
        net.Broadcast()
        
        print(string.format("[Custom Characters] %s повысил '%s' с Seq %d на Seq %d", 
            ply:Nick(), char.name, oldSeq, char.lotm.sequence))
    end
    
    return true, char.lotm.sequence
end

-- Серверная часть
if SERVER then
    util.AddNetworkString("dbt.CustomChar.Create")
    util.AddNetworkString("dbt.CustomChar.Sync")
    util.AddNetworkString("dbt.CustomChar.Delete")
    util.AddNetworkString("dbt.CustomChar.Request")
    util.AddNetworkString("dbt.CustomChar.Promote")
    
    -- Загрузка при запуске сервера
    hook.Add("Initialize", "DBT.CustomCharacters.Load", function()
        DBT.CustomCharacters.Load()
        
        -- Добавление в глобальную таблицу персонажей
        dbt.chr = dbt.chr or {}
        for id, char in pairs(DBT.CustomCharacters.List) do
            dbt.chr[id] = char
        end
    end)
    
    -- Создание персонажа
    net.Receive("dbt.CustomChar.Create", function(len, ply)
        local data = net.ReadTable()
        local success, result = DBT.CustomCharacters.Create(ply, data)
        
        net.Start("dbt.CustomChar.Create")
        net.WriteBool(success)
        net.WriteString(result)
        net.Send(ply)
    end)
    
    -- Запрос персонажей при подключении
    net.Receive("dbt.CustomChar.Request", function(len, ply)
        net.Start("dbt.CustomChar.Sync")
        net.WriteTable(DBT.CustomCharacters.List)
        net.Send(ply)
    end)
    
    -- Повышение последовательности
    net.Receive("dbt.CustomChar.Promote", function(len, ply)
        local charId = net.ReadString()
        local success, result = DBT.CustomCharacters.PromoteSequence(ply, charId)
        
        net.Start("dbt.CustomChar.Promote")
        net.WriteBool(success)
        net.WriteString(tostring(result))
        net.Send(ply)
    end)
end

-- Клиентская часть
if CLIENT then
    -- Синхронизация персонажей
    net.Receive("dbt.CustomChar.Sync", function()
        local chars = net.ReadTable()
        
        for id, char in pairs(chars) do
            DBT.CustomCharacters.List[id] = char
            dbt.chr = dbt.chr or {}
            dbt.chr[id] = char
        end
        
        print("[Custom Characters] Получено " .. table.Count(chars) .. " кастомных персонажей")
    end)
    
    -- Удаление персонажа
    net.Receive("dbt.CustomChar.Delete", function()
        local charId = net.ReadString()
        DBT.CustomCharacters.List[charId] = nil
        
        if dbt.chr then
            dbt.chr[charId] = nil
        end
    end)
    
    -- Запрос персонажей при загрузке
    hook.Add("InitPostEntity", "DBT.CustomCharacters.Request", function()
        timer.Simple(1, function()
            net.Start("dbt.CustomChar.Request")
            net.SendToServer()
        end)
    end)
end

print("[Custom Characters] Система кастомных персонажей загружена")