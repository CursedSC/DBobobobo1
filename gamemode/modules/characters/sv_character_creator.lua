-- Серверная часть системы создания персонажей

util.AddNetworkString("dbt/character/create")
util.AddNetworkString("dbt/character/created")

-- Конфигурация
local CHARACTER_CONFIG = {
    minNameLength = 2,
    maxNameLength = 32,
    minDescLength = 20,
    maxDescLength = 500,
    minHeight = 150,
    maxHeight = 200,
    defaultModel = "models/player/group01/male_01.mdl", -- Можно настроить
    saveToFile = true, -- Сохранять ли в файл
}

-- Функция валидации данных
local function ValidateCharacterData(data)
    if not istable(data) then
        return false, "Некорректные данные!"
    end
    
    -- Проверка имени
    if not isstring(data.name) or #data.name < CHARACTER_CONFIG.minNameLength then
        return false, "Имя слишком короткое!"
    end
    
    if #data.name > CHARACTER_CONFIG.maxNameLength then
        return false, "Имя слишком длинное!"
    end
    
    -- Проверка фамилии
    if not isstring(data.surname) or #data.surname < CHARACTER_CONFIG.minNameLength then
        return false, "Фамилия слишком короткая!"
    end
    
    if #data.surname > CHARACTER_CONFIG.maxNameLength then
        return false, "Фамилия слишком длинная!"
    end
    
    -- Проверка описания
    if not isstring(data.description) or #data.description < CHARACTER_CONFIG.minDescLength then
        return false, "Описание слишком короткое (минимум " .. CHARACTER_CONFIG.minDescLength .. " символов)!"
    end
    
    if #data.description > CHARACTER_CONFIG.maxDescLength then
        return false, "Описание слишком длинное!"
    end
    
    -- Проверка роста
    if not isnumber(data.height) or data.height < CHARACTER_CONFIG.minHeight or data.height > CHARACTER_CONFIG.maxHeight then
        return false, "Некорректный рост!"
    end
    
    -- Проверка scale
    if not isnumber(data.scale) or data.scale < 0.5 or data.scale > 2.0 then
        return false, "Некорректный scale!"
    end
    
    return true
end

-- Функция генерации уникального ID для персонажа
local function GenerateCharacterID(ply, name, surname)
    local steamID = ply:SteamID64() or "unknown"
    local timestamp = os.time()
    local cleanName = string.gsub(name .. "_" .. surname, "[^%w_]", "")
    return "CustomCharacter_" .. cleanName .. "_" .. steamID .. "_" .. timestamp
end

-- Функция создания персонажа
local function CreateCharacter(ply, data)
    -- Валидация
    local valid, error = ValidateCharacterData(data)
    if not valid then
        return false, error
    end
    
    -- Генерация ID
    local charID = GenerateCharacterID(ply, data.name, data.surname)
    
    -- Создание данных персонажа
    local characterData = {
        name = data.name .. " " .. data.surname,
        firstName = data.name,
        lastName = data.surname,
        description = data.description,
        height = data.height,
        scale = data.scale,
        model = CHARACTER_CONFIG.defaultModel,
        isCustom = true,
        createdBy = ply:SteamID64(),
        createdTime = os.time(),
        backup = {}
    }
    
    -- Добавляем персонажа в глобальную таблицу
    if not dbt then dbt = {} end
    if not dbt.chr then dbt.chr = {} end
    
    -- Используем существующую функцию, если есть
    if dbt.CreateCharacter then
        local character = dbt.CreateCharacter(charID, characterData)
        if character then
            character.isCustom = true
        end
    else
        -- Если функции нет, просто добавляем в таблицу
        dbt.chr[charID] = characterData
    end
    
    -- Сохранение в файл
    if CHARACTER_CONFIG.saveToFile then
        file.CreateDir("dbt/characters")
        file.CreateDir("dbt/characters/custom")
        
        local saveData = {
            Character = charID,
            Data = characterData
        }
        
        local json = util.TableToJSON(saveData, true)
        file.Write("dbt/characters/custom/" .. charID .. ".json", json)
    end
    
    -- Синхронизация с клиентами
    if netstream and netstream.Start then
        netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
    end
    
    -- Логирование
    print(string.format("[DBT] Character created: %s by %s (%s)", 
        characterData.name, 
        ply:Nick(), 
        ply:SteamID()
    ))
    
    return true, charID, characterData
end

-- Функция применения scale к игроку
function ApplyCharacterScale(ply, scale)
    if not IsValid(ply) then return end
    if not isnumber(scale) then scale = 1.0 end
    
    scale = math.Clamp(scale, 0.5, 2.0)
    
    ply:SetModelScale(scale, 0)
    
    -- Сохраняем scale на игроке
    ply.CharacterScale = scale
end

-- Нетворк хук для создания персонажа
netstream.Hook("dbt/character/create", function(ply, data)
    if not IsValid(ply) then return end
    
    -- Защита от спама
    if ply.NextCharacterCreate and ply.NextCharacterCreate > CurTime() then
        netstream.Start(ply, "dbt/character/created", false, "Подождите немного перед созданием нового персонажа!")
        return
    end
    
    ply.NextCharacterCreate = CurTime() + 5 -- Кулдаун 5 секунд
    
    -- Создаем персонажа
    local success, result, characterData = CreateCharacter(ply, data)
    
    if success then
        -- Успешно создан
        local message = string.format("Персонаж '%s' успешно создан!", characterData.name)
        netstream.Start(ply, "dbt/character/created", true, message)
        
        -- Применяем scale к игроку, если нужно
        if characterData.scale then
            ApplyCharacterScale(ply, characterData.scale)
        end
        
        -- Отправляем уведомление
        if netstream and netstream.Start then
            netstream.Start(ply, 'dbt/NewNotification', 3, {
                icon = 'materials/dbt/notifications/notifications_main.png',
                title = 'Персонаж',
                titlecolor = Color(100, 200, 100),
                notiftext = message,
                time = 5
            })
        end
    else
        -- Ошибка
        netstream.Start(ply, "dbt/character/created", false, result)
    end
end)

-- Хук для применения scale при смене персонажа
hook.Add("PlayerSetModel", "DBT_ApplyCharacterScale", function(ply, model)
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end
        
        -- Проверяем, есть ли у персонажа scale
        local charName = ply:GetNWString("CharacterName", "")
        if charName ~= "" and dbt and dbt.chr and dbt.chr[charName] then
            local charData = dbt.chr[charName]
            if charData.scale then
                ApplyCharacterScale(ply, charData.scale)
            end
        elseif ply.CharacterScale then
            -- Если у игрока уже есть сохраненный scale
            ApplyCharacterScale(ply, ply.CharacterScale)
        end
    end)
end)

print("[DBT] Character Creator Server loaded successfully!")