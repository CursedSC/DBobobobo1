-- LOTM Trade - Минимальная тестовая версия
-- Простая торговля без лишнего оформления

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.Trade = LOTM.Trade or {}

local colorOutLine = Color(211, 25, 202)
local colorBG = Color(0, 0, 0, 220)
local colorSlot = Color(40, 40, 50, 200)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)

LOTM.Trade.Partner = nil
LOTM.Trade.MyOffer = {items = {}, currency = {}}
LOTM.Trade.TheirOffer = {items = {}, currency = {}}
LOTM.Trade.MyConfirmed = false
LOTM.Trade.TheirConfirmed = false

function LOTM.Trade.OpenUI(partner)
    if IsValid(LOTM.Trade.Frame) then
        LOTM.Trade.Frame:Remove()
    end
    
    LOTM.Trade.Partner = partner
    LOTM.Trade.MyConfirmed = false
    LOTM.Trade.TheirConfirmed = false
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 400)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    LOTM.Trade.Frame = frame
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorBG)
        surface.SetDrawColor(colorOutLine)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        local partnerName = IsValid(partner) and partner:Nick() or "???"
        draw.SimpleText("ТОРГОВЛЯ с " .. partnerName, "DermaDefaultBold", w/2, 15, colorOutLine, TEXT_ALIGN_CENTER)
        
        -- Разделитель
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(w/2 - 1, 35, 2, h - 80)
        
        draw.SimpleText("ВЫ ОТДАЁТЕ", "DermaDefault", w/4, 40, Color(255, 150, 150), TEXT_ALIGN_CENTER)
        draw.SimpleText("ВЫ ПОЛУЧАЕТЕ", "DermaDefault", w*3/4, 40, Color(150, 255, 150), TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(470, 5)
    closeBtn:SetSize(25, 25)
    closeBtn:SetText("X")
    closeBtn.DoClick = function()
        net.Start("LOTM.Trade.Cancel")
        net.SendToServer()
        frame:Remove()
    end
    
    -- Мои предметы (слева)
    LOTM.Trade.MyPanel = vgui.Create("DIconLayout", frame)
    LOTM.Trade.MyPanel:SetPos(10, 60)
    LOTM.Trade.MyPanel:SetSize(230, 200)
    LOTM.Trade.MyPanel:SetSpaceX(5)
    LOTM.Trade.MyPanel:SetSpaceY(5)
    
    -- Их предметы (справа)
    LOTM.Trade.TheirPanel = vgui.Create("DIconLayout", frame)
    LOTM.Trade.TheirPanel:SetPos(260, 60)
    LOTM.Trade.TheirPanel:SetSize(230, 200)
    LOTM.Trade.TheirPanel:SetSpaceX(5)
    LOTM.Trade.TheirPanel:SetSpaceY(5)
    
    -- Мой инвентарь (снизу слева)
    local invLabel = vgui.Create("DLabel", frame)
    invLabel:SetPos(10, 265)
    invLabel:SetText("Ваш инвентарь (клик для добавления):")
    invLabel:SetTextColor(colorTextDim)
    invLabel:SizeToContents()
    
    local invScroll = vgui.Create("DScrollPanel", frame)
    invScroll:SetPos(10, 285)
    invScroll:SetSize(230, 70)
    
    local invGrid = invScroll:Add("DIconLayout")
    invGrid:Dock(FILL)
    invGrid:SetSpaceX(3)
    invGrid:SetSpaceY(3)
    
    -- Заполняем инвентарь
    local ply = LocalPlayer()
    if ply.items and dbt and dbt.inventory and dbt.inventory.items then
        for slot, item in pairs(ply.items) do
            local itemData = dbt.inventory.items[item.id]
            if not itemData then continue end
            
            local btn = vgui.Create("DButton")
            btn:SetSize(40, 40)
            btn:SetText("")
            btn.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(60, 40, 80) or colorSlot)
                draw.SimpleText(string.sub(itemData.name or "?", 1, 3), "DermaDefault", w/2, h/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btn:SetTooltip(itemData.name)
            btn.DoClick = function()
                net.Start("LOTM.Trade.AddItem")
                net.WriteUInt(slot, 16)
                net.SendToServer()
            end
            invGrid:Add(btn)
        end
    end
    
    -- Кнопка подтверждения
    local confirmBtn = vgui.Create("DButton", frame)
    confirmBtn:SetPos(260, 330)
    confirmBtn:SetSize(230, 40)
    confirmBtn:SetText("")
    confirmBtn.Paint = function(self, w, h)
        local confirmed = LOTM.Trade.MyConfirmed
        draw.RoundedBox(4, 0, 0, w, h, confirmed and Color(40, 100, 40) or (self:IsHovered() and Color(60, 40, 80) or colorSlot))
        draw.SimpleText(confirmed and "✓ ПОДТВЕРЖДЕНО" or "ПОДТВЕРДИТЬ", "DermaDefaultBold", w/2, h/2 - 5, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local status = LOTM.Trade.TheirConfirmed and "Партнёр готов ✓" or "Ожидание..."
        draw.SimpleText(status, "DermaDefault", w/2, h/2 + 12, LOTM.Trade.TheirConfirmed and Color(100, 255, 100) or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    confirmBtn.DoClick = function()
        net.Start("LOTM.Trade.Confirm")
        net.SendToServer()
    end
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            net.Start("LOTM.Trade.Cancel")
            net.SendToServer()
            self:Remove()
            return true
        end
    end
end

function LOTM.Trade.UpdateOffers(myOffer, theirOffer, myConf, theirConf)
    LOTM.Trade.MyOffer = myOffer or LOTM.Trade.MyOffer
    LOTM.Trade.TheirOffer = theirOffer or LOTM.Trade.TheirOffer
    LOTM.Trade.MyConfirmed = myConf or false
    LOTM.Trade.TheirConfirmed = theirConf or false
    
    -- Обновляем панели
    if IsValid(LOTM.Trade.MyPanel) then
        LOTM.Trade.MyPanel:Clear()
        for i, itemData in ipairs(myOffer.items or {}) do
            local data = dbt and dbt.inventory and dbt.inventory.items and dbt.inventory.items[itemData.id]
            if not data then continue end
            
            local btn = vgui.Create("DButton")
            btn:SetSize(40, 40)
            btn:SetText("")
            btn.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(80, 50, 50))
                draw.SimpleText(string.sub(data.name or "?", 1, 3), "DermaDefault", w/2, h/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btn:SetTooltip(data.name .. "\nКлик - убрать")
            btn.DoClick = function()
                net.Start("LOTM.Trade.RemoveItem")
                net.WriteUInt(i, 8)
                net.SendToServer()
            end
            LOTM.Trade.MyPanel:Add(btn)
        end
    end
    
    if IsValid(LOTM.Trade.TheirPanel) then
        LOTM.Trade.TheirPanel:Clear()
        for _, itemData in ipairs(theirOffer.items or {}) do
            local data = dbt and dbt.inventory and dbt.inventory.items and dbt.inventory.items[itemData.id]
            if not data then continue end
            
            local pnl = vgui.Create("DPanel")
            pnl:SetSize(40, 40)
            pnl.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 80, 50))
                draw.SimpleText(string.sub(data.name or "?", 1, 3), "DermaDefault", w/2, h/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            pnl:SetTooltip(data.name)
            LOTM.Trade.TheirPanel:Add(pnl)
        end
    end
end

-- Сетевые хуки
net.Receive("LOTM.Trade.OpenUI", function()
    local partner = net.ReadEntity()
    LOTM.Trade.OpenUI(partner)
end)

net.Receive("LOTM.Trade.Update", function()
    local myOffer = net.ReadTable()
    local theirOffer = net.ReadTable()
    local myConf = net.ReadBool()
    local theirConf = net.ReadBool()
    LOTM.Trade.UpdateOffers(myOffer, theirOffer, myConf, theirConf)
end)

net.Receive("LOTM.Trade.Cancel", function()
    if IsValid(LOTM.Trade.Frame) then
        LOTM.Trade.Frame:Remove()
    end
end)

net.Receive("LOTM.Trade.Complete", function()
    if IsValid(LOTM.Trade.Frame) then
        LOTM.Trade.Frame:Remove()
    end
    chat.AddText(Color(100, 255, 100), "[Торговля] Успешно!")
end)

concommand.Add("lotm_trade", function(ply, cmd, args)
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
    
    if target then
        net.Start("LOTM.Trade.Request")
        net.WriteEntity(target)
        net.SendToServer()
    end
end)

MsgC(Color(100, 255, 100), "[LOTM] ", colorText, "Trade (minimal) loaded\n")
