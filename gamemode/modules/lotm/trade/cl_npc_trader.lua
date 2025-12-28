-- LOTM NPC Trader Client
-- Клиентская часть торговца

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.NPCTrader = LOTM.NPCTrader or {}

-- =============================================
-- ЦВЕТА
-- =============================================
local colorOutLine = Color(211, 25, 202)
local colorBG = Color(15, 15, 20, 245)
local colorPanel = Color(25, 25, 35, 230)
local colorSlot = Color(35, 30, 45, 220)
local colorSlotHover = Color(60, 40, 80, 240)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorGold = Color(255, 215, 0)
local colorSilver = Color(192, 192, 192)
local colorCopper = Color(184, 115, 51)
local colorBuy = Color(60, 180, 60)
local colorSell = Color(180, 120, 60)

LOTM.NPCTrader.Stock = {}

-- =============================================
-- ОТКРЫТИЕ МАГАЗИНА
-- =============================================
function LOTM.NPCTrader.OpenShop(stock)
    if IsValid(LOTM.NPCTrader.Frame) then
        LOTM.NPCTrader.Frame:Remove()
    end
    
    LOTM.NPCTrader.Stock = stock
    
    local ply = LocalPlayer()
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH = 800, 550
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    LOTM.NPCTrader.Frame = frame
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colorBG)
        surface.SetDrawColor(colorOutLine)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("🏪 ТОРГОВЕЦ", "Comfortaa Bold X40", w/2, 25, 
            colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Валюта игрока
        local pounds = LOTM.Currency and LOTM.Currency.Get(ply, "pound") or 0
        local pence = LOTM.Currency and LOTM.Currency.Get(ply, "pence") or 0
        local soli = LOTM.Currency and LOTM.Currency.Get(ply, "soli") or 0
        
        draw.SimpleText("Ваши деньги:", "DermaDefault", 20, 55, colorTextDim, TEXT_ALIGN_LEFT)
        draw.SimpleText(pounds .. "£", "DermaDefaultBold", 110, 55, colorGold, TEXT_ALIGN_LEFT)
        draw.SimpleText(pence .. "p", "DermaDefaultBold", 160, 55, colorSilver, TEXT_ALIGN_LEFT)
        draw.SimpleText(soli .. "s", "DermaDefaultBold", 200, 55, colorCopper, TEXT_ALIGN_LEFT)
        
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(20, 75, w - 40, 1)
        
        -- Разделитель
        surface.DrawRect(w/2, 85, 1, h - 170)
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - 35, 10)
    closeBtn:SetSize(25, 25)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.SimpleText("✕", "DermaDefaultBold", w/2, h/2, 
            self:IsHovered() and Color(255, 100, 100) or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        net.Start("LOTM.NPCTrader.Close")
        net.SendToServer()
        frame:Remove()
    end
    
    -- =============================================
    -- ЛЕВАЯ ПАНЕЛЬ - ТОВАРЫ
    -- =============================================
    local leftPanel = vgui.Create("DPanel", frame)
    leftPanel:SetPos(15, 85)
    leftPanel:SetSize(frameW/2 - 25, frameH - 170)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorPanel)
        draw.SimpleText("КУПИТЬ", "DermaDefaultBold", w/2, 12, colorBuy, TEXT_ALIGN_CENTER)
    end
    
    local shopScroll = vgui.Create("DScrollPanel", leftPanel)
    shopScroll:SetPos(10, 30)
    shopScroll:SetSize(leftPanel:GetWide() - 20, leftPanel:GetTall() - 40)
    
    local shopList = shopScroll:Add("DIconLayout")
    shopList:Dock(FILL)
    shopList:SetSpaceX(5)
    shopList:SetSpaceY(5)
    
    for itemId, price in pairs(stock) do
        local itemData = dbt and dbt.inventory and dbt.inventory.items and dbt.inventory.items[itemId]
        if not itemData then continue end
        
        local itemPanel = vgui.Create("DPanel")
        itemPanel:SetSize(leftPanel:GetWide() - 40, 60)
        
        itemPanel.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            draw.RoundedBox(4, 0, 0, w, h, hovered and colorSlotHover or colorSlot)
            
            -- Название
            draw.SimpleText(itemData.name or "???", "DermaDefaultBold", 70, 15, colorText, TEXT_ALIGN_LEFT)
            
            -- Цена
            local priceText = LOTM.Currency and LOTM.Currency.FormatTotal(price) or (price .. "s")
            draw.SimpleText("Цена: " .. priceText, "DermaDefault", 70, 35, colorGold, TEXT_ALIGN_LEFT)
        end
        
        -- Иконка предмета
        local icon = vgui.Create("DModelPanel", itemPanel)
        icon:SetPos(5, 5)
        icon:SetSize(50, 50)
        if itemData.mdl then
            icon:SetModel(itemData.mdl)
            local ent = icon:GetEntity()
            if IsValid(ent) then
                local mins, maxs = ent:GetRenderBounds()
                local size = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z)
                icon:SetCamPos(Vector(size * 1.5, size * 1.5, size * 0.5))
                icon:SetLookAt((mins + maxs) / 2)
            end
        end
        icon:SetMouseInputEnabled(false)
        
        -- Кнопка покупки
        local buyBtn = vgui.Create("DButton", itemPanel)
        buyBtn:SetPos(itemPanel:GetWide() - 70, 15)
        buyBtn:SetSize(60, 30)
        buyBtn:SetText("")
        buyBtn.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and colorBuy or Color(40, 80, 40))
            draw.SimpleText("КУПИТЬ", "DermaDefault", w/2, h/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        buyBtn.DoClick = function()
            net.Start("LOTM.NPCTrader.Buy")
            net.WriteUInt(itemId, 16)
            net.WriteUInt(1, 8)
            net.SendToServer()
            surface.PlaySound("ui/buttonclick.wav")
        end
        
        shopList:Add(itemPanel)
    end
    
    -- =============================================
    -- ПРАВАЯ ПАНЕЛЬ - ПРОДАЖА
    -- =============================================
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:SetPos(frameW/2 + 10, 85)
    rightPanel:SetSize(frameW/2 - 25, frameH - 170)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorPanel)
        draw.SimpleText("ПРОДАТЬ", "DermaDefaultBold", w/2, 12, colorSell, TEXT_ALIGN_CENTER)
        draw.SimpleText("(50% от цены)", "DermaDefault", w/2, 26, colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    local sellScroll = vgui.Create("DScrollPanel", rightPanel)
    sellScroll:SetPos(10, 45)
    sellScroll:SetSize(rightPanel:GetWide() - 20, rightPanel:GetTall() - 55)
    
    local sellList = sellScroll:Add("DIconLayout")
    sellList:Dock(FILL)
    sellList:SetSpaceX(5)
    sellList:SetSpaceY(5)
    
    -- Заполняем инвентарем игрока
    if ply.items and dbt and dbt.inventory and dbt.inventory.items then
        for slot, item in pairs(ply.items) do
            local itemData = dbt.inventory.items[item.id]
            if not itemData then continue end
            
            local basePrice = stock[item.id]
            if not basePrice then continue end -- Торговец не покупает
            
            local sellPrice = math.floor(basePrice * 0.5)
            
            local itemPanel = vgui.Create("DPanel")
            itemPanel:SetSize(rightPanel:GetWide() - 40, 60)
            
            itemPanel.Paint = function(self, w, h)
                local hovered = self:IsHovered()
                draw.RoundedBox(4, 0, 0, w, h, hovered and colorSlotHover or colorSlot)
                
                draw.SimpleText(itemData.name or "???", "DermaDefaultBold", 70, 15, colorText, TEXT_ALIGN_LEFT)
                
                local priceText = LOTM.Currency and LOTM.Currency.FormatTotal(sellPrice) or (sellPrice .. "s")
                draw.SimpleText("Цена: " .. priceText, "DermaDefault", 70, 35, colorSell, TEXT_ALIGN_LEFT)
            end
            
            -- Иконка
            local icon = vgui.Create("DModelPanel", itemPanel)
            icon:SetPos(5, 5)
            icon:SetSize(50, 50)
            if itemData.mdl then
                icon:SetModel(itemData.mdl)
                local ent = icon:GetEntity()
                if IsValid(ent) then
                    local mins, maxs = ent:GetRenderBounds()
                    local size = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z)
                    icon:SetCamPos(Vector(size * 1.5, size * 1.5, size * 0.5))
                    icon:SetLookAt((mins + maxs) / 2)
                end
            end
            icon:SetMouseInputEnabled(false)
            
            -- Кнопка продажи
            local sellBtn = vgui.Create("DButton", itemPanel)
            sellBtn:SetPos(itemPanel:GetWide() - 75, 15)
            sellBtn:SetSize(65, 30)
            sellBtn:SetText("")
            sellBtn.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and colorSell or Color(80, 60, 30))
                draw.SimpleText("ПРОДАТЬ", "DermaDefault", w/2, h/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            sellBtn.DoClick = function()
                net.Start("LOTM.NPCTrader.Sell")
                net.WriteUInt(slot, 16)
                net.SendToServer()
                surface.PlaySound("ui/buttonclick.wav")
                
                -- Перезагружаем магазин
                timer.Simple(0.3, function()
                    if IsValid(LOTM.NPCTrader.Frame) then
                        LOTM.NPCTrader.Frame:Remove()
                        LOTM.NPCTrader.OpenShop(LOTM.NPCTrader.Stock)
                    end
                end)
            end
            
            sellList:Add(itemPanel)
        end
    end
    
    -- ESC закрывает
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            net.Start("LOTM.NPCTrader.Close")
            net.SendToServer()
            self:Remove()
            return true
        end
    end
end

-- =============================================
-- СЕТЕВЫЕ ХУКИ
-- =============================================
net.Receive("LOTM.NPCTrader.OpenShop", function()
    local stock = net.ReadTable()
    LOTM.NPCTrader.OpenShop(stock)
end)

-- =============================================
-- ОТРИСОВКА ИМЕНИ НАД NPC
-- =============================================
hook.Add("PostDrawTranslucentRenderables", "LOTM.NPCTrader.DrawNames", function()
    for _, ent in ipairs(ents.GetAll()) do
        if not IsValid(ent) then continue end
        if not ent:GetNWBool("IsLOTMTrader", false) then continue end
        
        local pos = ent:GetPos() + Vector(0, 0, 80)
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Up(), -90)
        ang:RotateAroundAxis(ang:Forward(), 90)
        
        cam.Start3D2D(pos, ang, 0.15)
            draw.SimpleText("🏪 ТОРГОВЕЦ", "DermaLarge", 0, 0, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("[E] - Открыть магазин", "DermaDefault", 0, 30, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "NPC Trader Client loaded\n")

