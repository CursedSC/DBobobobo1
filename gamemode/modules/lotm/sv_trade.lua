-- LOTM Trade System - Server
-- Система торговли: 2 инвентаря + центральные ячейки + валюта

if not SERVER then return end

LOTM = LOTM or {}
LOTM.Trade = LOTM.Trade or {}
LOTM.Trade.Active = {}

-- =============================================
-- СТРУКТУРА ТОРГОВЛИ
-- =============================================
-- {
--     player1 = ply1,
--     player2 = ply2,
--     offer1 = {items = {}, currency = {pound = 0, pence = 0, soli = 0}},
--     offer2 = {items = {}, currency = {pound = 0, pence = 0, soli = 0}},
--     confirmed1 = false,
--     confirmed2 = false,
-- }

-- =============================================
-- NETWORK STRINGS
-- =============================================
util.AddNetworkString("LOTM.Trade.Request")
util.AddNetworkString("LOTM.Trade.Accept")
util.AddNetworkString("LOTM.Trade.Decline")
util.AddNetworkString("LOTM.Trade.Cancel")
util.AddNetworkString("LOTM.Trade.OpenUI")
util.AddNetworkString("LOTM.Trade.Update")
util.AddNetworkString("LOTM.Trade.AddItem")
util.AddNetworkString("LOTM.Trade.RemoveItem")
util.AddNetworkString("LOTM.Trade.SetCurrency")
util.AddNetworkString("LOTM.Trade.Confirm")
util.AddNetworkString("LOTM.Trade.Complete")

-- =============================================
-- ФУНКЦИИ
-- =============================================

function LOTM.Trade.GetSession(ply)
    for id, session in pairs(LOTM.Trade.Active) do
        if session.player1 == ply or session.player2 == ply then
            return session, id
        end
    end
    return nil
end

function LOTM.Trade.CreateSession(ply1, ply2)
    local id = ply1:SteamID64() .. "_" .. ply2:SteamID64()
    
    LOTM.Trade.Active[id] = {
        player1 = ply1,
        player2 = ply2,
        offer1 = {items = {}, currency = {pound = 0, pence = 0, soli = 0}},
        offer2 = {items = {}, currency = {pound = 0, pence = 0, soli = 0}},
        confirmed1 = false,
        confirmed2 = false,
    }
    
    return LOTM.Trade.Active[id], id
end

function LOTM.Trade.SyncSession(session)
    if not session then return end
    
    net.Start("LOTM.Trade.Update")
    net.WriteTable(session.offer1)
    net.WriteTable(session.offer2)
    net.WriteBool(session.confirmed1)
    net.WriteBool(session.confirmed2)
    net.Send({session.player1, session.player2})
end

function LOTM.Trade.Cancel(session, id)
    if not session then return end
    
    net.Start("LOTM.Trade.Cancel")
    net.Send({session.player1, session.player2})
    
    LOTM.Trade.Active[id] = nil
end

function LOTM.Trade.Complete(session, id)
    local ply1 = session.player1
    local ply2 = session.player2
    
    -- Передаём предметы от 1 к 2
    for _, itemData in pairs(session.offer1.items) do
        -- Удаляем у ply1
        if dbt.inventory.removeitem then
            dbt.inventory.removeitem(ply1, itemData.slot)
        end
        -- Добавляем ply2
        if dbt.inventory.additem then
            dbt.inventory.additem(ply2, itemData.id, itemData.meta)
        end
    end
    
    -- Передаём предметы от 2 к 1
    for _, itemData in pairs(session.offer2.items) do
        if dbt.inventory.removeitem then
            dbt.inventory.removeitem(ply2, itemData.slot)
        end
        if dbt.inventory.additem then
            dbt.inventory.additem(ply1, itemData.id, itemData.meta)
        end
    end
    
    -- Передаём валюту
    local curr1 = session.offer1.currency
    local curr2 = session.offer2.currency
    
    -- От 1 к 2
    if LOTM.Currency then
        LOTM.Currency.Remove(ply1, "pound", curr1.pound or 0)
        LOTM.Currency.Remove(ply1, "pence", curr1.pence or 0)
        LOTM.Currency.Remove(ply1, "soli", curr1.soli or 0)
        LOTM.Currency.Add(ply2, "pound", curr1.pound or 0)
        LOTM.Currency.Add(ply2, "pence", curr1.pence or 0)
        LOTM.Currency.Add(ply2, "soli", curr1.soli or 0)
        
        -- От 2 к 1
        LOTM.Currency.Remove(ply2, "pound", curr2.pound or 0)
        LOTM.Currency.Remove(ply2, "pence", curr2.pence or 0)
        LOTM.Currency.Remove(ply2, "soli", curr2.soli or 0)
        LOTM.Currency.Add(ply1, "pound", curr2.pound or 0)
        LOTM.Currency.Add(ply1, "pence", curr2.pence or 0)
        LOTM.Currency.Add(ply1, "soli", curr2.soli or 0)
    end
    
    net.Start("LOTM.Trade.Complete")
    net.Send({ply1, ply2})
    
    ply1:ChatPrint("[Торговля] Обмен завершён!")
    ply2:ChatPrint("[Торговля] Обмен завершён!")
    
    LOTM.Trade.Active[id] = nil
end

-- =============================================
-- СЕТЕВЫЕ ОБРАБОТЧИКИ
-- =============================================

-- Запрос на торговлю (ТЕСТОВЫЙ РЕЖИМ - автопринятие)
net.Receive("LOTM.Trade.Request", function(len, ply)
    local target = net.ReadEntity()
    
    if not IsValid(target) or not target:IsPlayer() then return end
    if target == ply then return end
    if ply:GetPos():Distance(target:GetPos()) > 500 then
        ply:ChatPrint("[Торговля] Слишком далеко!")
        return
    end
    
    -- Проверяем что не в торговле
    if LOTM.Trade.GetSession(ply) or LOTM.Trade.GetSession(target) then
        ply:ChatPrint("[Торговля] Уже в торговле!")
        return
    end
    
    -- ТЕСТОВЫЙ РЕЖИМ: автоматически принимаем торговлю
    local session, id = LOTM.Trade.CreateSession(ply, target)
    
    -- Открываем UI обоим игрокам
    net.Start("LOTM.Trade.OpenUI")
    net.WriteEntity(target)
    net.Send(ply)
    
    net.Start("LOTM.Trade.OpenUI")
    net.WriteEntity(ply)
    net.Send(target)
    
    ply:ChatPrint("[Торговля] Торговля открыта с " .. target:Nick())
    target:ChatPrint("[Торговля] " .. ply:Nick() .. " открыл торговлю с вами")
end)

-- Принятие торговли
net.Receive("LOTM.Trade.Accept", function(len, ply)
    if not ply.TradeRequest or not IsValid(ply.TradeRequest) then
        ply:ChatPrint("[Торговля] Нет активных запросов")
        return
    end
    
    if CurTime() - (ply.TradeRequestTime or 0) > 30 then
        ply:ChatPrint("[Торговля] Запрос истёк")
        ply.TradeRequest = nil
        return
    end
    
    local partner = ply.TradeRequest
    ply.TradeRequest = nil
    
    -- Создаём сессию
    local session, id = LOTM.Trade.CreateSession(partner, ply)
    
    -- Открываем UI
    net.Start("LOTM.Trade.OpenUI")
    net.WriteEntity(ply)
    net.Send(partner)
    
    net.Start("LOTM.Trade.OpenUI")
    net.WriteEntity(partner)
    net.Send(ply)
    
    partner:ChatPrint("[Торговля] " .. ply:Nick() .. " принял торговлю")
    ply:ChatPrint("[Торговля] Торговля началась с " .. partner:Nick())
end)

-- Добавление предмета
net.Receive("LOTM.Trade.AddItem", function(len, ply)
    local itemSlot = net.ReadUInt(16)
    
    local session, id = LOTM.Trade.GetSession(ply)
    if not session then return end
    
    local offer = session.player1 == ply and session.offer1 or session.offer2
    
    -- Получаем предмет из инвентаря
    if not ply.items or not ply.items[itemSlot] then return end
    
    local item = ply.items[itemSlot]
    table.insert(offer.items, {
        slot = itemSlot,
        id = item.id,
        meta = item.meta,
    })
    
    -- Сброс подтверждений
    session.confirmed1 = false
    session.confirmed2 = false
    
    LOTM.Trade.SyncSession(session)
end)

-- Удаление предмета
net.Receive("LOTM.Trade.RemoveItem", function(len, ply)
    local index = net.ReadUInt(8)
    
    local session, id = LOTM.Trade.GetSession(ply)
    if not session then return end
    
    local offer = session.player1 == ply and session.offer1 or session.offer2
    table.remove(offer.items, index)
    
    session.confirmed1 = false
    session.confirmed2 = false
    
    LOTM.Trade.SyncSession(session)
end)

-- Установка валюты
net.Receive("LOTM.Trade.SetCurrency", function(len, ply)
    local currencyType = net.ReadString()
    local amount = net.ReadUInt(32)
    
    local session, id = LOTM.Trade.GetSession(ply)
    if not session then return end
    
    local offer = session.player1 == ply and session.offer1 or session.offer2
    
    -- Проверяем достаточно ли у игрока
    if LOTM.Currency and not LOTM.Currency.Has(ply, currencyType, amount) then
        ply:ChatPrint("[Торговля] Недостаточно " .. currencyType)
        return
    end
    
    offer.currency[currencyType] = amount
    
    session.confirmed1 = false
    session.confirmed2 = false
    
    LOTM.Trade.SyncSession(session)
end)

-- Подтверждение
net.Receive("LOTM.Trade.Confirm", function(len, ply)
    local session, id = LOTM.Trade.GetSession(ply)
    if not session then return end
    
    if session.player1 == ply then
        session.confirmed1 = true
    else
        session.confirmed2 = true
    end
    
    LOTM.Trade.SyncSession(session)
    
    -- Если оба подтвердили - завершаем
    if session.confirmed1 and session.confirmed2 then
        LOTM.Trade.Complete(session, id)
    end
end)

-- Отмена
net.Receive("LOTM.Trade.Cancel", function(len, ply)
    local session, id = LOTM.Trade.GetSession(ply)
    if session then
        LOTM.Trade.Cancel(session, id)
    end
end)

-- Консольные команды
concommand.Add("trade", function(ply, cmd, args)
    local action = args[1]
    
    if action == "accept" then
        net.Start("LOTM.Trade.Accept")
        net.Send(ply)
    elseif action == "decline" then
        ply.TradeRequest = nil
        ply:ChatPrint("[Торговля] Запрос отклонён")
    end
end)

-- ТЕСТОВАЯ КОМАНДА: мгновенная торговля с ближайшим игроком
concommand.Add("lotm_trade_test", function(ply, cmd, args)
    -- Находим ближайшего игрока
    local target = nil
    local minDist = 500
    
    for _, p in ipairs(player.GetAll()) do
        if p ~= ply then
            local dist = ply:GetPos():Distance(p:GetPos())
            if dist < minDist then
                minDist = dist
                target = p
            end
        end
    end
    
    if not target then
        ply:ChatPrint("[Торговля] Нет игроков поблизости")
        return
    end
    
    -- Проверяем что не в торговле
    if LOTM.Trade.GetSession(ply) or LOTM.Trade.GetSession(target) then
        ply:ChatPrint("[Торговля] Уже в торговле!")
        return
    end
    
    -- Создаём сессию и открываем UI
    local session, id = LOTM.Trade.CreateSession(ply, target)
    
    net.Start("LOTM.Trade.OpenUI")
    net.WriteEntity(target)
    net.Send(ply)
    
    net.Start("LOTM.Trade.OpenUI")
    net.WriteEntity(ply)
    net.Send(target)
    
    ply:ChatPrint("[Торговля] Тестовая торговля открыта с " .. target:Nick())
    target:ChatPrint("[Торговля] " .. ply:Nick() .. " открыл тестовую торговлю")
end)

print("[LOTM] Trade System (Server) loaded - TEST MODE")

