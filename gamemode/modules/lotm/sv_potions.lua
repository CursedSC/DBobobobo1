-- LOTM Potion System - Server
-- Серверная логика системы зелий

if not SERVER then return end
if not LOTM then return end

LOTM.PlayerData = LOTM.PlayerData or {}

util.AddNetworkString("LOTM_SyncPlayerData")
util.AddNetworkString("LOTM_ConsumePotion")
util.AddNetworkString("LOTM_ActivateAbility")
util.AddNetworkString("LOTM_Notification")

-- Структура данных игрока
function LOTM.GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    
    local steamID = ply:SteamID64()
    
    if not LOTM.PlayerData[steamID] then
        LOTM.PlayerData[steamID] = {
            CurrentPotion = nil,
            DigestionProgress = 0,
            AbilityCooldowns = {},
            ActedPrinciples = {}
        }
    end
    
    return LOTM.PlayerData[steamID]
end

-- Сохранение данных в SQLite
function LOTM.SavePlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    local data = LOTM.PlayerData[steamID]
    
    if not data then return end
    
    local jsonData = util.TableToJSON(data)
    
    sql.Query(string.format(
        "INSERT OR REPLACE INTO lotm_players (steamid, data) VALUES (%s, %s)",
        sql.SQLStr(steamID),
        sql.SQLStr(jsonData)
    ))
end

-- Загрузка данных из SQLite
function LOTM.LoadPlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local result = sql.Query(string.format(
        "SELECT data FROM lotm_players WHERE steamid = %s",
        sql.SQLStr(steamID)
    ))
    
    if result and result[1] then
        LOTM.PlayerData[steamID] = util.JSONToTable(result[1].data)
    end
end

-- Инициализация БД
function LOTM.InitializeDatabase()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_players (
            steamid TEXT PRIMARY KEY,
            data TEXT
        )
    ]])
    
    MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Database initialized\n")
end

LOTM.InitializeDatabase()

-- Употребление зелья
function LOTM.ConsumePotion(ply, potionUID)
    if not IsValid(ply) then return false, "Invalid player" end
    
    local potion = LOTM.GetPotion(potionUID)
    if not potion then
        return false, "Potion not found"
    end
    
    local data = LOTM.GetPlayerData(ply)
    
    -- Проверка на текущее зелье
    if data.CurrentPotion then
        return false, "Вы уже выпили зелье! Сначала переварите текущее."
    end
    
    -- Устанавливаем зелье
    data.CurrentPotion = potionUID
    data.DigestionProgress = 0
    data.AbilityCooldowns = {}
    
    -- Автоматическое распределение способностей по слотам
    LOTM.AssignAbilities(ply, potion)
    
    -- Применяем пассивные эффекты
    LOTM.ApplyPassiveAbilities(ply, potion)
    
    -- Синхронизация с клиентом
    LOTM.SyncPlayerData(ply)
    
    -- Уведомление
    LOTM.Notify(ply, "Вы выпили зелье: " .. potion.Name .. " (" .. LOTM.SEQUENCES[potion.Sequence] .. ")", Color(100, 255, 100))
    
    -- Сохранение
    LOTM.SavePlayerData(ply)
    
    return true
end

-- Автоматическое распределение способностей
function LOTM.AssignAbilities(ply, potion)
    if not IsValid(ply) or not potion then return end
    
    for _, ability in ipairs(potion.Abilities) do
        if ability.Slot > 0 then
            -- Привязываем способность к слоту
            ply:SetNWString("LOTM_Ability_" .. ability.Slot, ability.ID)
        end
    end
end

-- Применение пассивных способностей
function LOTM.ApplyPassiveAbilities(ply, potion)
    if not IsValid(ply) or not potion then return end
    
    for _, ability in ipairs(potion.Abilities) do
        if ability.Type == LOTM.ABILITY_TYPES.PASSIVE and ability.OnPassive then
            ability.OnPassive(ply)
        end
    end
end

-- Активация способности
net.Receive("LOTM_ActivateAbility", function(len, ply)
    local slot = net.ReadUInt(8)
    
    local data = LOTM.GetPlayerData(ply)
    if not data or not data.CurrentPotion then
        LOTM.Notify(ply, "У вас нет активного зелья!", Color(255, 100, 100))
        return
    end
    
    local potion = LOTM.GetPotion(data.CurrentPotion)
    if not potion then return end
    
    -- Найти способность
    local ability = nil
    for _, ab in ipairs(potion.Abilities) do
        if ab.Slot == slot then
            ability = ab
            break
        end
    end
    
    if not ability then
        LOTM.Notify(ply, "Способность не найдена!", Color(255, 100, 100))
        return
    end
    
    -- Проверка кулдауна
    if data.AbilityCooldowns[ability.ID] and data.AbilityCooldowns[ability.ID] > CurTime() then
        local remaining = math.ceil(data.AbilityCooldowns[ability.ID] - CurTime())
        LOTM.Notify(ply, "Кулдаун: " .. remaining .. " сек.", Color(255, 200, 100))
        return
    end
    
    -- Проверка энергии
    if not LOTM.Energy.Has(ply, ability.EnergyCost) then
        LOTM.Notify(ply, "Недостаточно энергии! (" .. ability.EnergyCost .. " требуется)", Color(255, 100, 100))
        return
    end
    
    -- Проверка условий
    if ability.Condition and not ability.Condition(ply) then
        LOTM.Notify(ply, "Условия для активации не выполнены!", Color(255, 100, 100))
        return
    end
    
    -- Расход энергии
    LOTM.Energy.Remove(ply, ability.EnergyCost)
    
    -- Установка кулдауна
    data.AbilityCooldowns[ability.ID] = CurTime() + ability.Cooldown
    
    -- Активация
    if ability.OnActivate then
        ability.OnActivate(ply)
    end
    
    LOTM.Notify(ply, "Активирована способность: " .. ability.Name, Color(100, 200, 255))
end)

-- Синхронизация данных с клиентом
function LOTM.SyncPlayerData(ply)
    if not IsValid(ply) then return end
    
    local data = LOTM.GetPlayerData(ply)
    
    net.Start("LOTM_SyncPlayerData")
        net.WriteTable(data)
    net.Send(ply)
end

-- Уведомление игрока
function LOTM.Notify(ply, message, color)
    if not IsValid(ply) then return end
    
    net.Start("LOTM_Notification")
        net.WriteString(message)
        net.WriteColor(color or Color(255, 255, 255))
    net.Send(ply)
end

-- Переваривание зелья (автоматическое)
timer.Create("LOTM_DigestionProgress", 30, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local data = LOTM.GetPlayerData(ply)
            
            if data.CurrentPotion then
                local potion = LOTM.GetPotion(data.CurrentPotion)
                
                if potion then
                    data.DigestionProgress = math.min(1.0, data.DigestionProgress + potion.DigestionRate)
                    
                    if data.DigestionProgress >= 1.0 then
                        LOTM.Notify(ply, "Зелье " .. potion.Name .. " полностью переварено! Вы можете принять следующее.", Color(100, 255, 100))
                    end
                    
                    LOTM.SavePlayerData(ply)
                end
            end
        end
    end
end)

-- Хуки
hook.Add("PlayerInitialSpawn", "LOTM_LoadData", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            LOTM.LoadPlayerData(ply)
            LOTM.SyncPlayerData(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "LOTM_SaveData", function(ply)
    LOTM.SavePlayerData(ply)
end)

-- Консольная команда для выдачи зелья (админ)
concommand.Add("lotm_give_potion", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    
    local potionUID = args[1]
    if not potionUID then
        ply:ChatPrint("Использование: lotm_give_potion <potion_uid>")
        return
    end
    
    local success, msg = LOTM.ConsumePotion(ply, potionUID)
    
    if not success then
        ply:ChatPrint("[LOTM Error] " .. msg)
    end
end)

-- Консольная команда для сброса зелья (админ)
concommand.Add("lotm_reset_potion", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    
    local data = LOTM.GetPlayerData(ply)
    data.CurrentPotion = nil
    data.DigestionProgress = 0
    data.AbilityCooldowns = {}
    
    LOTM.SyncPlayerData(ply)
    LOTM.SavePlayerData(ply)
    
    ply:ChatPrint("[LOTM] Ваше зелье сброшено.")
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Server-side potion system loaded\n")