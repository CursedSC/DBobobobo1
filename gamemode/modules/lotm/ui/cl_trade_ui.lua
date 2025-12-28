-- LOTM Trade UI v2.0
-- 2 инвентаря + центральное предложение + валюта
-- Стиль проекта

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.TradeUI = LOTM.TradeUI or {}

-- =============================================
-- ЦВЕТОВАЯ ПАЛИТРА
-- =============================================
local colorOutLine = Color(211, 25, 202)
local colorBG = Color(15, 15, 20, 245)
local colorPanel = Color(25, 25, 35, 230)
local colorSlot = Color(35, 30, 45, 220)
local colorSlotHover = Color(60, 40, 80, 240)
local colorSlotSelected = Color(80, 50, 120, 255)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorGold = Color(255, 215, 0)
local colorSilver = Color(192, 192, 192)
local colorCopper = Color(184, 115, 51)
local colorAccept = Color(60, 180, 60)
local colorDecline = Color(180, 60, 60)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- =============================================
-- ФУНКЦИИ ОТРИСОВКИ
-- =============================================
local function DrawBorder(w, h, color, thickness)
    thickness = thickness or 1
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, thickness)
    surface.DrawRect(0, 0, thickness, h)
    surface.DrawRect(0, h - thickness, w, thickness)
    surface.DrawRect(w - thickness, 0, thickness, h)
end

local function DrawItemSlot(panel, slot, itemData, onClick, onRightClick)
    local btn = vgui.Create("DButton", panel)
    btn:SetSize(64, 64)
    btn:SetText("")
    
    btn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local bgColor = hovered and colorSlotHover or colorSlot
        
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        if hovered then
            DrawBorder(w, h, colorOutLine, 1)
        end
        
        if itemData then
            -- Модель предмета
            local itemInfo = dbt and dbt.inventory and dbt.inventory.items and dbt.inventory.items[itemData.id]
            if itemInfo then
                -- Иконка или первые буквы
                local name = itemInfo.name or "?"
                draw.SimpleText(string.sub(name, 1, 4), "DermaDefault", w/2, h/2 - 5, 
                    colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Количество
                if itemData.amount and itemData.amount > 1 then
                    draw.SimpleText("x" .. itemData.amount, "DermaDefault", w - 5, h - 5, 
                        colorTextDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                end
            end
        end
    end
    
    btn.DoClick = onClick
    btn.DoRightClick = onRightClick
    
    if itemData then
        local itemInfo = dbt and dbt.inventory and dbt.inventory.items and dbt.inventory.items[itemData.id]
        if itemInfo then
            btn:SetTooltip(itemInfo.name or "Предмет")
        end
    end
    
    return btn
end

-- =============================================
-- СОЗДАНИЕ UI ТОРГОВЛИ
-- =============================================
function LOTM.TradeUI.Open(partner, isNPC)
    if IsValid(LOTM.TradeUI.Frame) then
        LOTM.TradeUI.Frame:Remove()
    end
    
    local ply = LocalPlayer()
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH = 900, 600
    
    local CurrentBG = tableBG[math.random(1, 3)]
    
    -- Главное окно
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    LOTM.TradeUI.Frame = frame
    
    frame.Paint = function(self, w, h)
        -- Фон
        draw.RoundedBox(8, 0, 0, w, h, colorBG)
        
        if dbtPaint and dbtPaint.DrawRect and bg_main then
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 30))
        end
        
        -- Рамка
        surface.SetDrawColor(colorOutLine)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Заголовок
        local partnerName = IsValid(partner) and partner:Nick() or (isNPC and "Торговец" or "???")
        draw.SimpleText("ТОРГОВЛЯ", "Comfortaa Bold X40", w/2, 25, 
            colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("с " .. partnerName, "Comfortaa Light X20", w/2, 55, 
            colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Разделительная линия
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(20, 75, w - 40, 1)
        
        -- Вертикальные разделители (3 колонки)
        surface.DrawRect(w/3 - 10, 85, 1, h - 170)
        surface.DrawRect(w*2/3 + 10, 85, 1, h - 170)
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - 35, 10)
    closeBtn:SetSize(25, 25)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.SimpleText("✕", "DermaDefaultBold", w/2, h/2, 
            hovered and colorDecline or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        net.Start("LOTM.Trade.Cancel")
        net.SendToServer()
        frame:Remove()
    end
    
    -- =============================================
    -- ЛЕВАЯ ПАНЕЛЬ - МОЙ ИНВЕНТАРЬ
    -- =============================================
    local leftPanel = vgui.Create("DPanel", frame)
    leftPanel:SetPos(15, 90)
    leftPanel:SetSize(frameW/3 - 30, frameH - 180)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorPanel)
        draw.SimpleText("ВАШ ИНВЕНТАРЬ", "DermaDefaultBold", w/2, 15, 
            colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Валюта игрока
        local pounds = LOTM.Currency and LOTM.Currency.Get(ply, "pound") or 0
        local pence = LOTM.Currency and LOTM.Currency.Get(ply, "pence") or 0
        local soli = LOTM.Currency and LOTM.Currency.Get(ply, "soli") or 0
        
        draw.SimpleText(pounds .. "£", "DermaDefault", 20, h - 25, colorGold, TEXT_ALIGN_LEFT)
        draw.SimpleText(pence .. "p", "DermaDefault", 70, h - 25, colorSilver, TEXT_ALIGN_LEFT)
        draw.SimpleText(soli .. "s", "DermaDefault", 120, h - 25, colorCopper, TEXT_ALIGN_LEFT)
    end
    
    -- Сетка инвентаря
    local invScroll = vgui.Create("DScrollPanel", leftPanel)
    invScroll:SetPos(10, 35)
    invScroll:SetSize(leftPanel:GetWide() - 20, leftPanel:GetTall() - 80)
    
    local invGrid = invScroll:Add("DIconLayout")
    invGrid:Dock(FILL)
    invGrid:SetSpaceX(5)
    invGrid:SetSpaceY(5)
    
    -- Заполняем инвентарь
    local function RefreshMyInventory()
        invGrid:Clear()
        if ply.items and dbt and dbt.inventory and dbt.inventory.items then
            for slot, item in pairs(ply.items) do
                local btn = DrawItemSlot(invGrid, slot, item, function()
                    net.Start("LOTM.Trade.AddItem")
                    net.WriteUInt(slot, 16)
                    net.SendToServer()
                    surface.PlaySound("ui/buttonclick.wav")
                end)
                invGrid:Add(btn)
            end
        end
    end
    RefreshMyInventory()
    
    -- =============================================
    -- ЦЕНТРАЛЬНАЯ ПАНЕЛЬ - ПРЕДЛОЖЕНИЕ
    -- =============================================
    local centerPanel = vgui.Create("DPanel", frame)
    centerPanel:SetPos(frameW/3, 90)
    centerPanel:SetSize(frameW/3, frameH - 180)
    centerPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorPanel)
        
        -- Мое предложение
        draw.SimpleText("ВЫ ОТДАЁТЕ", "DermaDefaultBold", w/2, 15, 
            Color(255, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Разделитель
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(10, h/2, w - 20, 1)
        
        -- Их предложение
        draw.SimpleText("ВЫ ПОЛУЧАЕТЕ", "DermaDefaultBold", w/2, h/2 + 15, 
            Color(150, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Ячейки моего предложения (сверху)
    LOTM.TradeUI.MyOfferGrid = vgui.Create("DIconLayout", centerPanel)
    LOTM.TradeUI.MyOfferGrid:SetPos(10, 35)
    LOTM.TradeUI.MyOfferGrid:SetSize(centerPanel:GetWide() - 20, centerPanel:GetTall()/2 - 80)
    LOTM.TradeUI.MyOfferGrid:SetSpaceX(5)
    LOTM.TradeUI.MyOfferGrid:SetSpaceY(5)
    
    -- Валюта моего предложения
    local myCurrencyPanel = vgui.Create("DPanel", centerPanel)
    myCurrencyPanel:SetPos(10, centerPanel:GetTall()/2 - 40)
    myCurrencyPanel:SetSize(centerPanel:GetWide() - 20, 35)
    myCurrencyPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 30, 30, 200))
        draw.SimpleText("Валюта:", "DermaDefault", 10, h/2, colorTextDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Поля ввода валюты
    local currInputs = {}
    local currencies = {
        {type = "pound", symbol = "£", color = colorGold, x = 70},
        {type = "pence", symbol = "p", color = colorSilver, x = 130},
        {type = "soli", symbol = "s", color = colorCopper, x = 190},
    }
    
    for _, curr in ipairs(currencies) do
        local input = vgui.Create("DTextEntry", myCurrencyPanel)
        input:SetPos(curr.x, 5)
        input:SetSize(50, 25)
        input:SetNumeric(true)
        input:SetText("0")
        input:SetTextColor(curr.color)
        input.OnChange = function(self)
            local amount = tonumber(self:GetText()) or 0
            net.Start("LOTM.Trade.SetCurrency")
            net.WriteString(curr.type)
            net.WriteUInt(amount, 32)
            net.SendToServer()
        end
        currInputs[curr.type] = input
        
        local label = vgui.Create("DLabel", myCurrencyPanel)
        label:SetPos(curr.x + 52, 5)
        label:SetText(curr.symbol)
        label:SetTextColor(curr.color)
        label:SizeToContents()
    end
    
    -- Ячейки их предложения (снизу)
    LOTM.TradeUI.TheirOfferGrid = vgui.Create("DIconLayout", centerPanel)
    LOTM.TradeUI.TheirOfferGrid:SetPos(10, centerPanel:GetTall()/2 + 35)
    LOTM.TradeUI.TheirOfferGrid:SetSize(centerPanel:GetWide() - 20, centerPanel:GetTall()/2 - 80)
    LOTM.TradeUI.TheirOfferGrid:SetSpaceX(5)
    LOTM.TradeUI.TheirOfferGrid:SetSpaceY(5)
    
    -- Валюта их предложения
    local theirCurrencyLabel = vgui.Create("DPanel", centerPanel)
    theirCurrencyLabel:SetPos(10, centerPanel:GetTall() - 45)
    theirCurrencyLabel:SetSize(centerPanel:GetWide() - 20, 35)
    theirCurrencyLabel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 40, 30, 200))
        
        local theirOffer = LOTM.Trade and LOTM.Trade.TheirOffer and LOTM.Trade.TheirOffer.currency or {}
        local pounds = theirOffer.pound or 0
        local pence = theirOffer.pence or 0
        local soli = theirOffer.soli or 0
        
        draw.SimpleText("Валюта:", "DermaDefault", 10, h/2, colorTextDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(pounds .. "£", "DermaDefault", 70, h/2, colorGold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(pence .. "p", "DermaDefault", 130, h/2, colorSilver, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(soli .. "s", "DermaDefault", 190, h/2, colorCopper, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- ПРАВАЯ ПАНЕЛЬ - ИНВЕНТАРЬ ПАРТНЁРА / NPC
    -- =============================================
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:SetPos(frameW*2/3 + 15, 90)
    rightPanel:SetSize(frameW/3 - 30, frameH - 180)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorPanel)
        
        local title = isNPC and "ТОВАРЫ" or "ИНВЕНТАРЬ ПАРТНЁРА"
        draw.SimpleText(title, "DermaDefaultBold", w/2, 15, 
            colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local partnerScroll = vgui.Create("DScrollPanel", rightPanel)
    partnerScroll:SetPos(10, 35)
    partnerScroll:SetSize(rightPanel:GetWide() - 20, rightPanel:GetTall() - 50)
    
    LOTM.TradeUI.PartnerGrid = partnerScroll:Add("DIconLayout")
    LOTM.TradeUI.PartnerGrid:Dock(FILL)
    LOTM.TradeUI.PartnerGrid:SetSpaceX(5)
    LOTM.TradeUI.PartnerGrid:SetSpaceY(5)
    
    -- =============================================
    -- НИЖНЯЯ ПАНЕЛЬ - КНОПКИ
    -- =============================================
    local btnW = 200
    local btnH = 50
    local btnY = frameH - 70
    
    -- Кнопка подтверждения
    local confirmBtn = vgui.Create("DButton", frame)
    confirmBtn:SetPos(frameW/2 - btnW - 20, btnY)
    confirmBtn:SetSize(btnW, btnH)
    confirmBtn:SetText("")
    confirmBtn.Paint = function(self, w, h)
        local confirmed = LOTM.Trade and LOTM.Trade.MyConfirmed
        local hovered = self:IsHovered()
        
        local bgColor = confirmed and colorAccept or (hovered and Color(60, 100, 60) or colorSlot)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        if hovered or confirmed then
            DrawBorder(w, h, colorAccept, 1)
        end
        
        local text = confirmed and "✓ ПОДТВЕРЖДЕНО" or "ПОДТВЕРДИТЬ"
        draw.SimpleText(text, "Comfortaa Light X20", w/2, h/2 - 8, 
            colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local statusText = (LOTM.Trade and LOTM.Trade.TheirConfirmed) and "Партнёр готов ✓" or "Ожидание партнёра..."
        local statusColor = (LOTM.Trade and LOTM.Trade.TheirConfirmed) and colorAccept or colorTextDim
        draw.SimpleText(statusText, "DermaDefault", w/2, h/2 + 10, 
            statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    confirmBtn.DoClick = function()
        net.Start("LOTM.Trade.Confirm")
        net.SendToServer()
        surface.PlaySound("ui/buttonclick.wav")
    end
    
    -- Кнопка отмены
    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetPos(frameW/2 + 20, btnY)
    cancelBtn:SetSize(btnW, btnH)
    cancelBtn:SetText("")
    cancelBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local bgColor = hovered and Color(100, 60, 60) or colorSlot
        
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        if hovered then
            DrawBorder(w, h, colorDecline, 1)
        end
        
        draw.SimpleText("ОТМЕНИТЬ", "Comfortaa Light X20", w/2, h/2, 
            colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    cancelBtn.DoClick = function()
        net.Start("LOTM.Trade.Cancel")
        net.SendToServer()
        frame:Remove()
    end
    
    -- ESC закрывает
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            net.Start("LOTM.Trade.Cancel")
            net.SendToServer()
            self:Remove()
            return true
        end
    end
end

-- =============================================
-- ОБНОВЛЕНИЕ ПРЕДЛОЖЕНИЙ
-- =============================================
function LOTM.TradeUI.UpdateOffers(myOffer, theirOffer, myConf, theirConf)
    LOTM.Trade = LOTM.Trade or {}
    LOTM.Trade.MyOffer = myOffer
    LOTM.Trade.TheirOffer = theirOffer
    LOTM.Trade.MyConfirmed = myConf
    LOTM.Trade.TheirConfirmed = theirConf
    
    if not IsValid(LOTM.TradeUI.Frame) then return end
    
    -- Обновляем мои предметы
    if IsValid(LOTM.TradeUI.MyOfferGrid) then
        LOTM.TradeUI.MyOfferGrid:Clear()
        for i, itemData in ipairs(myOffer.items or {}) do
            local btn = DrawItemSlot(LOTM.TradeUI.MyOfferGrid, i, itemData, function()
                net.Start("LOTM.Trade.RemoveItem")
                net.WriteUInt(i, 8)
                net.SendToServer()
                surface.PlaySound("ui/buttonclick.wav")
            end)
            LOTM.TradeUI.MyOfferGrid:Add(btn)
        end
    end
    
    -- Обновляем их предметы
    if IsValid(LOTM.TradeUI.TheirOfferGrid) then
        LOTM.TradeUI.TheirOfferGrid:Clear()
        for i, itemData in ipairs(theirOffer.items or {}) do
            local pnl = DrawItemSlot(LOTM.TradeUI.TheirOfferGrid, i, itemData)
            LOTM.TradeUI.TheirOfferGrid:Add(pnl)
        end
    end
end

-- =============================================
-- СЕТЕВЫЕ ХУКИ
-- =============================================
net.Receive("LOTM.Trade.OpenUI", function()
    local partner = net.ReadEntity()
    local isNPC = net.ReadBool()
    LOTM.TradeUI.Open(partner, isNPC)
end)

net.Receive("LOTM.Trade.Update", function()
    local myOffer = net.ReadTable()
    local theirOffer = net.ReadTable()
    local myConf = net.ReadBool()
    local theirConf = net.ReadBool()
    LOTM.TradeUI.UpdateOffers(myOffer, theirOffer, myConf, theirConf)
end)

net.Receive("LOTM.Trade.Cancel", function()
    if IsValid(LOTM.TradeUI.Frame) then
        LOTM.TradeUI.Frame:Remove()
    end
end)

net.Receive("LOTM.Trade.Complete", function()
    if IsValid(LOTM.TradeUI.Frame) then
        LOTM.TradeUI.Frame:Remove()
    end
    chat.AddText(colorAccept, "[Торговля] ", colorText, "Обмен успешно завершён!")
    surface.PlaySound("garrysmod/content_downloaded.wav")
end)

MsgC(Color(100, 255, 100), "[LOTM] ", colorText, "Trade UI v2.0 loaded\n")

