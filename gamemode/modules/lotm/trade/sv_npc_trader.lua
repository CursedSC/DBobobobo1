-- LOTM NPC Trader System
-- Торговец-NPC

if not SERVER then return end

LOTM = LOTM or {}
LOTM.NPCTrader = LOTM.NPCTrader or {}

-- =============================================
-- КОНФИГУРАЦИЯ
-- =============================================
LOTM.NPCTrader.Config = {
    interactDistance = 150,
    model = "models/humans/group01/male_07.mdl",
}

-- Товары торговца (id предмета = цена в солях)
LOTM.NPCTrader.Stock = {}

-- =============================================
-- РЕГИСТРАЦИЯ ТОВАРОВ
-- =============================================
function LOTM.NPCTrader.AddStock(itemId, price)
    LOTM.NPCTrader.Stock[itemId] = price
end

-- Дефолтные товары
hook.Add("InitPostEntity", "LOTM.NPCTrader.DefaultStock", function()
    timer.Simple(2, function()
        if not dbt or not dbt.inventory or not dbt.inventory.items then return end
        
        -- Добавляем все предметы с базовой ценой
        for id, item in pairs(dbt.inventory.items) do
            if item.name and not LOTM.NPCTrader.Stock[id] then
                -- Базовая цена = вес * 10 + 5 солей
                local weight = item.kg or 1
                local basePrice = math.floor(weight * 10) + 5
                LOTM.NPCTrader.Stock[id] = basePrice
            end
        end
        
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
             "NPC Trader stock initialized: " .. table.Count(LOTM.NPCTrader.Stock) .. " items\n")
    end)
end)

-- =============================================
-- ТОРГОВЛЯ С NPC
-- =============================================
LOTM.NPCTrader.ActiveSessions = {}

util.AddNetworkString("LOTM.NPCTrader.OpenShop")
util.AddNetworkString("LOTM.NPCTrader.Buy")
util.AddNetworkString("LOTM.NPCTrader.Sell")
util.AddNetworkString("LOTM.NPCTrader.Close")

function LOTM.NPCTrader.OpenShop(ply, npc)
    if not IsValid(ply) or not IsValid(npc) then return end
    
    local dist = ply:GetPos():Distance(npc:GetPos())
    if dist > LOTM.NPCTrader.Config.interactDistance then
        ply:ChatPrint("[Торговец] Подойдите ближе!")
        return
    end
    
    LOTM.NPCTrader.ActiveSessions[ply:SteamID64()] = {
        npc = npc,
        startTime = CurTime(),
    }
    
    net.Start("LOTM.NPCTrader.OpenShop")
    net.WriteTable(LOTM.NPCTrader.Stock)
    net.Send(ply)
    
    ply:ChatPrint("[Торговец] Добро пожаловать! Посмотрите мои товары.")
end

-- Покупка предмета
net.Receive("LOTM.NPCTrader.Buy", function(len, ply)
    local itemId = net.ReadUInt(16)
    local amount = net.ReadUInt(8)
    
    if amount < 1 then amount = 1 end
    if amount > 99 then amount = 99 end
    
    local session = LOTM.NPCTrader.ActiveSessions[ply:SteamID64()]
    if not session then
        ply:ChatPrint("[Торговец] Сначала откройте магазин!")
        return
    end
    
    local price = LOTM.NPCTrader.Stock[itemId]
    if not price then
        ply:ChatPrint("[Торговец] Этого товара нет в наличии!")
        return
    end
    
    local totalPrice = price * amount
    
    -- Проверяем валюту
    if not LOTM.Currency or not LOTM.Currency.GetTotal then
        ply:ChatPrint("[Торговец] Ошибка системы валюты!")
        return
    end
    
    local playerMoney = LOTM.Currency.GetTotal(ply)
    if playerMoney < totalPrice then
        ply:ChatPrint("[Торговец] Недостаточно денег! Нужно: " .. LOTM.Currency.FormatTotal(totalPrice))
        return
    end
    
    -- Списываем деньги (конвертируем в соли и снимаем)
    local remaining = totalPrice
    
    -- Сначала снимаем соли
    local soli = LOTM.Currency.Get(ply, "soli")
    local soliToRemove = math.min(soli, remaining)
    LOTM.Currency.Remove(ply, "soli", soliToRemove)
    remaining = remaining - soliToRemove
    
    -- Потом пенсы
    if remaining > 0 then
        local pence = LOTM.Currency.Get(ply, "pence")
        local penceNeeded = math.ceil(remaining / 12)
        local penceToRemove = math.min(pence, penceNeeded)
        LOTM.Currency.Remove(ply, "pence", penceToRemove)
        remaining = remaining - (penceToRemove * 12)
        
        -- Сдача в соли
        if remaining < 0 then
            LOTM.Currency.Add(ply, "soli", -remaining)
            remaining = 0
        end
    end
    
    -- Потом фунты
    if remaining > 0 then
        local pounds = LOTM.Currency.Get(ply, "pound")
        local poundsNeeded = math.ceil(remaining / 240)
        local poundsToRemove = math.min(pounds, poundsNeeded)
        LOTM.Currency.Remove(ply, "pound", poundsToRemove)
        remaining = remaining - (poundsToRemove * 240)
        
        -- Сдача
        if remaining < 0 then
            LOTM.Currency.Add(ply, "soli", -remaining)
        end
    end
    
    -- Выдаём предмет
    for i = 1, amount do
        if dbt.inventory and dbt.inventory.additem then
            dbt.inventory.additem(ply, itemId, {})
        end
    end
    
    local itemData = dbt.inventory.items[itemId]
    local itemName = itemData and itemData.name or "Предмет"
    
    ply:ChatPrint("[Торговец] Вы купили: " .. itemName .. " x" .. amount .. " за " .. LOTM.Currency.FormatTotal(totalPrice))
end)

-- Продажа предмета
net.Receive("LOTM.NPCTrader.Sell", function(len, ply)
    local slot = net.ReadUInt(16)
    
    local session = LOTM.NPCTrader.ActiveSessions[ply:SteamID64()]
    if not session then
        ply:ChatPrint("[Торговец] Сначала откройте магазин!")
        return
    end
    
    if not ply.items or not ply.items[slot] then
        ply:ChatPrint("[Торговец] Этого предмета нет в инвентаре!")
        return
    end
    
    local item = ply.items[slot]
    local price = LOTM.NPCTrader.Stock[item.id]
    
    if not price then
        ply:ChatPrint("[Торговец] Я не покупаю этот товар!")
        return
    end
    
    -- Цена продажи = 50% от цены покупки
    local sellPrice = math.floor(price * 0.5)
    
    -- Удаляем предмет
    if dbt.inventory and dbt.inventory.removeitem then
        dbt.inventory.removeitem(ply, slot)
    end
    
    -- Выдаём деньги
    if LOTM.Currency then
        local breakdown = LOTM.Currency.FromSoli(sellPrice)
        LOTM.Currency.Add(ply, "pound", breakdown.pound)
        LOTM.Currency.Add(ply, "pence", breakdown.pence)
        LOTM.Currency.Add(ply, "soli", breakdown.soli)
    end
    
    local itemData = dbt.inventory.items[item.id]
    local itemName = itemData and itemData.name or "Предмет"
    
    ply:ChatPrint("[Торговец] Вы продали: " .. itemName .. " за " .. LOTM.Currency.FormatTotal(sellPrice))
end)

-- Закрытие магазина
net.Receive("LOTM.NPCTrader.Close", function(len, ply)
    LOTM.NPCTrader.ActiveSessions[ply:SteamID64()] = nil
end)

-- =============================================
-- КОНСОЛЬНЫЕ КОМАНДЫ
-- =============================================
concommand.Add("lotm_spawn_trader", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local tr = ply:GetEyeTrace()
    local pos = tr.HitPos + Vector(0, 0, 10)
    
    local npc = ents.Create("npc_citizen")
    npc:SetPos(pos)
    npc:SetAngles(Angle(0, ply:GetAngles().y + 180, 0))
    npc:SetModel(LOTM.NPCTrader.Config.model)
    npc:Spawn()
    npc:Activate()
    
    npc:SetNWBool("IsLOTMTrader", true)
    npc:SetNWString("LOTMTraderName", "Торговец")
    
    -- Делаем неуязвимым
    npc:SetHealth(999999)
    npc:AddFlags(FL_GODMODE)
    
    ply:ChatPrint("[LOTM] Торговец создан!")
end)

-- Взаимодействие с NPC
hook.Add("PlayerUse", "LOTM.NPCTrader.Interact", function(ply, ent)
    if not IsValid(ent) then return end
    if not ent:GetNWBool("IsLOTMTrader", false) then return end
    
    LOTM.NPCTrader.OpenShop(ply, ent)
end)

-- Хук для рисования имени над NPC (передача на клиент)
hook.Add("PlayerInitialSpawn", "LOTM.NPCTrader.SendInfo", function(ply)
    timer.Simple(3, function()
        if not IsValid(ply) then return end
        -- NPC информация синхронизируется через NWVars
    end)
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "NPC Trader System loaded\n")

