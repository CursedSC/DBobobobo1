-- LOTM Currency System
-- Система валюты: Фунты, Пенсы, Соли
-- Обмен как в Minecraft

LOTM = LOTM or {}
LOTM.Currency = LOTM.Currency or {}

-- =============================================
-- КОНСТАНТЫ ВАЛЮТ
-- =============================================

-- Градация (от большего к меньшему)
-- 1 Фунт = 20 Пенсов
-- 1 Пенс = 12 Солей
-- 1 Фунт = 240 Солей

LOTM.Currency.Types = {
    POUND = "pound",   -- Фунт (золото)
    PENCE = "pence",   -- Пенс (серебро)
    SOLI = "soli",     -- Соль (медь)
}

LOTM.Currency.Exchange = {
    pound_to_pence = 20,   -- 1 фунт = 20 пенсов
    pence_to_soli = 12,    -- 1 пенс = 12 солей
    pound_to_soli = 240,   -- 1 фунт = 240 солей
}

LOTM.Currency.Names = {
    pound = {singular = "Фунт", plural = "Фунтов", symbol = "£"},
    pence = {singular = "Пенс", plural = "Пенсов", symbol = "p"},
    soli = {singular = "Соль", plural = "Солей", symbol = "s"},
}

LOTM.Currency.Colors = {
    pound = Color(255, 215, 0),    -- Золото
    pence = Color(192, 192, 192),  -- Серебро
    soli = Color(184, 115, 51),    -- Медь
}

-- =============================================
-- ФУНКЦИИ ВАЛЮТЫ
-- =============================================

-- Конвертация в соли (базовую валюту)
function LOTM.Currency.ToSoli(amount, currencyType)
    if currencyType == "pound" then
        return amount * LOTM.Currency.Exchange.pound_to_soli
    elseif currencyType == "pence" then
        return amount * LOTM.Currency.Exchange.pence_to_soli
    else
        return amount
    end
end

-- Конвертация из солей в оптимальный формат
function LOTM.Currency.FromSoli(soli)
    local pounds = math.floor(soli / LOTM.Currency.Exchange.pound_to_soli)
    soli = soli - (pounds * LOTM.Currency.Exchange.pound_to_soli)
    
    local pence = math.floor(soli / LOTM.Currency.Exchange.pence_to_soli)
    soli = soli - (pence * LOTM.Currency.Exchange.pence_to_soli)
    
    return {
        pound = pounds,
        pence = pence,
        soli = soli,
    }
end

-- Форматирование валюты для отображения
function LOTM.Currency.Format(amount, currencyType)
    if type(amount) == "table" then
        -- Таблица {pound = X, pence = Y, soli = Z}
        local parts = {}
        if amount.pound and amount.pound > 0 then
            table.insert(parts, amount.pound .. "£")
        end
        if amount.pence and amount.pence > 0 then
            table.insert(parts, amount.pence .. "p")
        end
        if amount.soli and amount.soli > 0 then
            table.insert(parts, amount.soli .. "s")
        end
        return #parts > 0 and table.concat(parts, " ") or "0s"
    else
        -- Простое число
        local names = LOTM.Currency.Names[currencyType] or LOTM.Currency.Names.soli
        return tostring(amount) .. names.symbol
    end
end

-- Форматирование общей суммы (в солях) красиво
function LOTM.Currency.FormatTotal(totalSoli)
    local breakdown = LOTM.Currency.FromSoli(totalSoli)
    return LOTM.Currency.Format(breakdown)
end

-- =============================================
-- ФУНКЦИИ ДЛЯ ИГРОКОВ
-- =============================================

if SERVER then
    -- Получить валюту игрока
    function LOTM.Currency.Get(ply, currencyType)
        if not IsValid(ply) then return 0 end
        currencyType = currencyType or "soli"
        return ply:GetNWInt("LOTM_Currency_" .. currencyType, 0)
    end
    
    -- Установить валюту
    function LOTM.Currency.Set(ply, currencyType, amount)
        if not IsValid(ply) then return end
        ply:SetNWInt("LOTM_Currency_" .. currencyType, math.max(0, amount))
    end
    
    -- Добавить валюту
    function LOTM.Currency.Add(ply, currencyType, amount)
        local current = LOTM.Currency.Get(ply, currencyType)
        LOTM.Currency.Set(ply, currencyType, current + amount)
    end
    
    -- Отнять валюту
    function LOTM.Currency.Remove(ply, currencyType, amount)
        local current = LOTM.Currency.Get(ply, currencyType)
        if current < amount then return false end
        LOTM.Currency.Set(ply, currencyType, current - amount)
        return true
    end
    
    -- Проверить достаточно ли валюты
    function LOTM.Currency.Has(ply, currencyType, amount)
        return LOTM.Currency.Get(ply, currencyType) >= amount
    end
    
    -- Получить общую сумму в солях
    function LOTM.Currency.GetTotal(ply)
        local pounds = LOTM.Currency.Get(ply, "pound")
        local pence = LOTM.Currency.Get(ply, "pence")
        local soli = LOTM.Currency.Get(ply, "soli")
        
        return LOTM.Currency.ToSoli(pounds, "pound") + 
               LOTM.Currency.ToSoli(pence, "pence") + 
               soli
    end
    
    -- Обмен валюты (как в Minecraft)
    function LOTM.Currency.Exchange(ply, fromType, toType, amount)
        if not LOTM.Currency.Has(ply, fromType, amount) then
            return false, "Недостаточно " .. LOTM.Currency.Names[fromType].plural
        end
        
        -- Конвертируем в соли
        local soliAmount = LOTM.Currency.ToSoli(amount, fromType)
        
        -- Конвертируем в целевую валюту
        local targetAmount
        if toType == "pound" then
            targetAmount = math.floor(soliAmount / LOTM.Currency.Exchange.pound_to_soli)
            soliAmount = soliAmount - (targetAmount * LOTM.Currency.Exchange.pound_to_soli)
        elseif toType == "pence" then
            targetAmount = math.floor(soliAmount / LOTM.Currency.Exchange.pence_to_soli)
            soliAmount = soliAmount - (targetAmount * LOTM.Currency.Exchange.pence_to_soli)
        else
            targetAmount = soliAmount
            soliAmount = 0
        end
        
        -- Применяем изменения
        LOTM.Currency.Remove(ply, fromType, amount)
        LOTM.Currency.Add(ply, toType, targetAmount)
        
        -- Возвращаем сдачу в солях
        if soliAmount > 0 then
            LOTM.Currency.Add(ply, "soli", soliAmount)
        end
        
        return true, targetAmount
    end
    
    -- Оптимизировать кошелёк (разбить на оптимальные номиналы)
    function LOTM.Currency.Optimize(ply)
        local total = LOTM.Currency.GetTotal(ply)
        local breakdown = LOTM.Currency.FromSoli(total)
        
        LOTM.Currency.Set(ply, "pound", breakdown.pound)
        LOTM.Currency.Set(ply, "pence", breakdown.pence)
        LOTM.Currency.Set(ply, "soli", breakdown.soli)
        
        return breakdown
    end
end

if CLIENT then
    function LOTM.Currency.Get(ply, currencyType)
        if not IsValid(ply) then return 0 end
        currencyType = currencyType or "soli"
        return ply:GetNWInt("LOTM_Currency_" .. currencyType, 0)
    end
    
    function LOTM.Currency.GetTotal(ply)
        local pounds = LOTM.Currency.Get(ply, "pound")
        local pence = LOTM.Currency.Get(ply, "pence")
        local soli = LOTM.Currency.Get(ply, "soli")
        
        return LOTM.Currency.ToSoli(pounds, "pound") + 
               LOTM.Currency.ToSoli(pence, "pence") + 
               soli
    end
end

-- =============================================
-- ПРЕДМЕТЫ ВАЛЮТЫ В ИНВЕНТАРЕ
-- =============================================

-- Регистрируем предметы валюты
hook.Add("InitPostEntity", "LOTM.Currency.RegisterItems", function()
    timer.Simple(1, function()
        if not dbt or not dbt.inventory or not dbt.inventory.items then return end
        
        local startId = 900  -- Начинаем с высокого ID
        
        -- Мешочек с солями
        dbt.inventory.items[startId] = {
            name = "Мешочек солей",
            currencyType = "soli",
            currencyAmount = 10,
            mdl = "models/props_junk/garbage_bag001a.mdl",
            kg = 0.1,
            OnUse = function(ply, data, meta)
                if SERVER then
                    LOTM.Currency.Add(ply, "soli", 10)
                    ply:ChatPrint("[Валюта] +10 Солей")
                end
                return meta
            end,
        }
        
        -- Серебряная монета (пенс)
        dbt.inventory.items[startId + 1] = {
            name = "Серебряный пенс",
            currencyType = "pence",
            currencyAmount = 1,
            mdl = "models/props_lab/huladoll.mdl",
            kg = 0.05,
            OnUse = function(ply, data, meta)
                if SERVER then
                    LOTM.Currency.Add(ply, "pence", 1)
                    ply:ChatPrint("[Валюта] +1 Пенс")
                end
                return meta
            end,
        }
        
        -- Золотой фунт
        dbt.inventory.items[startId + 2] = {
            name = "Золотой фунт",
            currencyType = "pound",
            currencyAmount = 1,
            mdl = "models/props_lab/huladoll.mdl",
            kg = 0.1,
            OnUse = function(ply, data, meta)
                if SERVER then
                    LOTM.Currency.Add(ply, "pound", 1)
                    ply:ChatPrint("[Валюта] +1 Фунт")
                end
                return meta
            end,
        }
        
        print("[LOTM] Currency items registered")
    end)
end)

-- =============================================
-- КОНСОЛЬНЫЕ КОМАНДЫ (АДМИН)
-- =============================================
if SERVER then
    concommand.Add("lotm_give_currency", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        
        local target = ply
        local currencyType = args[1] or "soli"
        local amount = tonumber(args[2]) or 100
        
        LOTM.Currency.Add(target, currencyType, amount)
        ply:ChatPrint("[LOTM] +" .. amount .. " " .. currencyType)
    end)
    
    concommand.Add("lotm_check_wallet", function(ply)
        if not IsValid(ply) then return end
        
        local pounds = LOTM.Currency.Get(ply, "pound")
        local pence = LOTM.Currency.Get(ply, "pence")
        local soli = LOTM.Currency.Get(ply, "soli")
        
        ply:ChatPrint("═══════════════════════════════")
        ply:ChatPrint("[Кошелёк]")
        ply:ChatPrint("  Фунты: " .. pounds .. "£")
        ply:ChatPrint("  Пенсы: " .. pence .. "p")
        ply:ChatPrint("  Соли: " .. soli .. "s")
        ply:ChatPrint("  Всего: " .. LOTM.Currency.FormatTotal(LOTM.Currency.GetTotal(ply)))
        ply:ChatPrint("═══════════════════════════════")
    end)
    
    concommand.Add("lotm_exchange", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local fromType = args[1] or "pound"
        local toType = args[2] or "pence"
        local amount = tonumber(args[3]) or 1
        
        local success, result = LOTM.Currency.Exchange(ply, fromType, toType, amount)
        if success then
            ply:ChatPrint("[Обмен] " .. amount .. " " .. fromType .. " → " .. result .. " " .. toType)
        else
            ply:ChatPrint("[Ошибка] " .. result)
        end
    end)
end

print("[LOTM] Currency System loaded (Pounds, Pence, Soli)")

