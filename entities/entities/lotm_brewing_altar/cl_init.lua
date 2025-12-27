-- LOTM Brewing Altar - Client v3.0
-- Алтарь с ритуальной символикой на полу

include("shared.lua")

local colorOutLine = Color(211, 25, 202)
local colorBG = Color(0, 0, 0, 230)
local colorBG2 = Color(49, 0, 54, 40)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(180, 180, 180)
local colorSlot = Color(40, 40, 50, 200)
local colorSlotFilled = Color(100, 40, 120, 220)
local colorRitual = Color(150, 50, 180, 150)

local function draw_border(x, y, w, h, color)
    surface.SetDrawColor(color)
    surface.DrawRect(x, y, w, 1)
    surface.DrawRect(x, y, 1, h)
    surface.DrawRect(x, y + h - 1, w, 1)
    surface.DrawRect(x + w - 1, y, 1, h)
end

ENT.CirclePulse = 0
ENT.BrewingProgress = 0
ENT.IsBrewingVisual = false
ENT.IngredientSlots = {}

-- =============================================
-- РИТУАЛЬНАЯ СИМВОЛИКА НА ПОЛУ (Минималистичный стиль DBT)
-- =============================================
function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos()
    self.CirclePulse = (self.CirclePulse + FrameTime() * 0.8) % (math.pi * 2)
    local pulse = math.sin(self.CirclePulse) * 0.15 + 0.85
    
    -- Основной слой - улучшенный визуал в стиле DBT
    cam.Start3D2D(pos + Vector(0, 0, 0.5), Angle(0, 0, 0), 0.3)
        local alpha = 200 * pulse
        local slots = self.IngredientSlots or {}
        local filledCount = 0
        for i = 1, 6 do if slots[i] then filledCount = filledCount + 1 end end
        
        -- Фон круга (затемнённый)
        surface.SetDrawColor(0, 0, 0, alpha * 0.3)
        self:DrawFilledCircle(0, 0, 180, 64)
        
        -- Внешний круг (толстый, стиль DBT)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.8)
        self:DrawCircleOutline(0, 0, 180, 64, 3)
        
        -- Средний круг (декоративный)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.6)
        self:DrawCircleOutline(0, 0, 140, 48, 2)
        
        -- 6 линий к слотам (улучшенные)
        for i = 1, 6 do
            local angle = math.rad((i - 1) * 60 - 90)
            local slotFilled = slots[i] ~= nil
            local lineAlpha = slotFilled and alpha or alpha * 0.4
            
            -- Толстая линия
            surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, lineAlpha)
            for offset = -1, 1 do
                surface.DrawLine(
                    math.cos(angle) * 50 + math.cos(angle + math.pi/2) * offset, 
                    math.sin(angle) * 50 + math.sin(angle + math.pi/2) * offset,
                    math.cos(angle) * 130 + math.cos(angle + math.pi/2) * offset, 
                    math.sin(angle) * 130 + math.sin(angle + math.pi/2) * offset
                )
            end
        end
        
        -- Центральный круг (яркий)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha)
        self:DrawCircleOutline(0, 0, 50, 32, 3)
        
        -- Внутренний заполненный круг
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.2)
        self:DrawFilledCircle(0, 0, 45, 32)
        
        -- Слоты ингредиентов (квадраты вместо кругов - стиль F4)
        for i = 1, 6 do
            local angle = math.rad((i - 1) * 60 - 90)
            local x = math.cos(angle) * 110
            local y = math.sin(angle) * 110
            local slotFilled = slots[i] ~= nil
            
            local slotSize = 35
            local sx = x - slotSize / 2
            local sy = y - slotSize / 2
            
            -- Фон слота
            if slotFilled then
                surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.4)
                surface.DrawRect(sx, sy, slotSize, slotSize)
            else
                surface.SetDrawColor(0, 0, 0, alpha * 0.5)
                surface.DrawRect(sx, sy, slotSize, slotSize)
            end
            
            -- Рамка слота
            local borderColor = slotFilled and colorOutLine or Color(80, 80, 100)
            surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, slotFilled and alpha or alpha * 0.5)
            surface.DrawOutlinedRect(sx, sy, slotSize, slotSize, 1)
            
            -- Номер или индикатор
            if slotFilled then
                draw.SimpleText("✓", "DermaDefaultBold", x, y, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(tostring(i), "DermaDefault", x, y, Color(100, 100, 120, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        -- Центральный символ
        if self.IsBrewingVisual then
            local brewPulse = math.sin(CurTime() * 4) * 0.5 + 0.5
            surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200 * brewPulse)
            self:DrawFilledCircle(0, 0, 30 + brewPulse * 10, 20)
            draw.SimpleText("⚗", "DermaLarge", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            -- Индикатор заполненности
            if filledCount > 0 then
                draw.SimpleText(filledCount .. "/6", "DermaDefaultBold", 0, 0, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("○", "DermaLarge", 0, 0, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.7), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    cam.End3D2D()
end

-- Рисование контура круга
function ENT:DrawCircleOutline(x, y, radius, segments, thickness)
    for i = 0, segments - 1 do
        local a1 = (i / segments) * math.pi * 2
        local a2 = ((i + 1) / segments) * math.pi * 2
        
        for t = 0, thickness - 1 do
            local r = radius + t
            surface.DrawLine(
                x + math.cos(a1) * r, y + math.sin(a1) * r,
                x + math.cos(a2) * r, y + math.sin(a2) * r
            )
        end
    end
end

-- Рисование заполненного круга
function ENT:DrawFilledCircle(x, y, radius, segments)
    local poly = {}
    for i = 0, segments do
        local angle = (i / segments) * math.pi * 2
        table.insert(poly, {
            x = x + math.cos(angle) * radius,
            y = y + math.sin(angle) * radius
        })
    end
    draw.NoTexture()
    surface.DrawPoly(poly)
end

-- Рисование гексаграммы (6 точек, соответствует 6 слотам)
function ENT:DrawHexagram(x, y, radius, alpha)
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.7)
    
    -- Два треугольника образуют гексаграмму
    local points1 = {}
    local points2 = {}
    
    for i = 0, 2 do
        local angle1 = math.rad(i * 120 - 90)
        local angle2 = math.rad(i * 120 - 90 + 60)
        table.insert(points1, {
            x = x + math.cos(angle1) * radius,
            y = y + math.sin(angle1) * radius
        })
        table.insert(points2, {
            x = x + math.cos(angle2) * radius,
            y = y + math.sin(angle2) * radius
        })
    end
    
    -- Первый треугольник
    for i = 1, 3 do
        local p1 = points1[i]
        local p2 = points1[(i % 3) + 1]
        surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
    end
    
    -- Второй треугольник
    for i = 1, 3 do
        local p1 = points2[i]
        local p2 = points2[(i % 3) + 1]
        surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
    end
end

-- Рисование пентаграммы (оставлено для совместимости)
function ENT:DrawPentagram(x, y, radius, alpha)
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.6)
    
    local points = {}
    for i = 0, 4 do
        local angle = math.rad(i * 72 - 90)
        table.insert(points, {
            x = x + math.cos(angle) * radius,
            y = y + math.sin(angle) * radius
        })
    end
    
    -- Соединяем точки через одну (пентаграмма)
    local order = {1, 3, 5, 2, 4, 1}
    for i = 1, #order - 1 do
        local p1 = points[order[i]]
        local p2 = points[order[i + 1]]
        surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
    end
end

-- Рисование рун по кругу
function ENT:DrawRunes(x, y, radius, alpha)
    local runes = {"ᚠ", "ᚢ", "ᚦ", "ᚨ", "ᚱ", "ᚲ", "ᚷ", "ᚹ", "ᚺ", "ᚾ", "ᛁ", "ᛃ"}
    
    for i, rune in ipairs(runes) do
        local angle = math.rad((i - 1) * 30 - 90)
        local rx = x + math.cos(angle) * radius
        local ry = y + math.sin(angle) * radius
        
        draw.SimpleText(rune, "DermaDefaultBold", rx, ry, 
            Color(colorRitual.r, colorRitual.g, colorRitual.b, alpha * 0.7), 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Рисование стрелки
function ENT:DrawArrow(x1, y1, mx, my, x2, y2, color)
    surface.SetDrawColor(color)
    
    -- Линия
    surface.DrawLine(x1, y1, mx, my)
    
    -- Наконечник
    local angle = math.atan2(y2 - my, x2 - mx)
    local arrowSize = 10
    
    local ax1 = mx + math.cos(angle + math.rad(150)) * arrowSize
    local ay1 = my + math.sin(angle + math.rad(150)) * arrowSize
    local ax2 = mx + math.cos(angle - math.rad(150)) * arrowSize
    local ay2 = my + math.sin(angle - math.rad(150)) * arrowSize
    
    surface.DrawLine(mx, my, ax1, ay1)
    surface.DrawLine(mx, my, ax2, ay2)
end

function ENT:Think()
    if self.IsBrewingVisual then
        self.BrewingProgress = math.min(1, self.BrewingProgress + FrameTime() / 3)
        if self.BrewingProgress >= 1 then
            self.IsBrewingVisual = false
            self.BrewingProgress = 0
        end
    end
end

-- =============================================
-- СЕТЕВЫЕ ХУКИ
-- =============================================
net.Receive("LOTM.BrewingAltar.SyncSlots", function()
    local altar = net.ReadEntity()
    local slots = net.ReadTable()
    if IsValid(altar) then altar.IngredientSlots = slots end
end)

net.Receive("LOTM.BrewingAltar.OpenUI", function()
    local altar = net.ReadEntity()
    local slots = net.ReadTable()
    local playerPathway = net.ReadInt(8)
    local playerSequence = net.ReadInt(8)
    
    if IsValid(altar) then altar.IngredientSlots = slots end
    
    LOTM = LOTM or {}
    LOTM.BrewingAltar = LOTM.BrewingAltar or {}
    LOTM.BrewingAltar.OpenUI(altar, playerPathway, playerSequence)
end)

net.Receive("LOTM.BrewingAltar.BrewingStarted", function()
    local altar = net.ReadEntity()
    if IsValid(altar) then
        altar.IsBrewingVisual = true
        altar.BrewingProgress = 0
    end
    surface.PlaySound("ambient/fire/mtov_flame2.wav")
end)

net.Receive("LOTM.BrewingAltar.BrewingComplete", function()
    local altar = net.ReadEntity()
    local potionName = net.ReadString()
    local sequence = net.ReadInt(8)
    local pathwayName = net.ReadString()
    
    if IsValid(altar) then
        altar.IsBrewingVisual = false
        altar.IngredientSlots = {}
    end
    
    surface.PlaySound("ambient/energy/whiteflash.wav")
    LOTM.BrewingAltar.ShowNotification(potionName, sequence, pathwayName)
end)

-- =============================================
-- UI АЛТАРЯ В СТИЛЕ F4
-- =============================================
LOTM = LOTM or {}
LOTM.BrewingAltar = LOTM.BrewingAltar or {}

function LOTM.BrewingAltar.OpenUI(altar, playerPathway, playerSequence)
    if not IsValid(altar) then return end
    if IsValid(LOTM.BrewingAltar.Frame) then LOTM.BrewingAltar.Frame:Remove() end
    
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH = 900, 550
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    LOTM.BrewingAltar.Frame = frame
    LOTM.BrewingAltar.CurrentAltar = altar
    
    frame.startTime = RealTime()
    
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.startTime)
        draw.RoundedBox(0, 0, 0, w, h, colorBG)
        draw.RoundedBox(0, 0, 0, w, h, colorBG2)
        draw_border(0, 0, w, h, colorOutLine)
        
        draw.SimpleText("АЛТАРЬ ЗЕЛЬЕВАРЕНИЯ", "Comfortaa Bold X30", w/2, 30, colorOutLine, TEXT_ALIGN_CENTER)
        
        -- Разделитель
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(w/2, 60, 2, h - 120)
        
        draw.SimpleText("ИНВЕНТАРЬ", "Comfortaa Bold X18", w/4, 55, colorTextDim, TEXT_ALIGN_CENTER)
        draw.SimpleText("АЛТАРЬ", "Comfortaa Bold X18", w*3/4, 55, colorOutLine, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - 40, 10)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.SimpleText("✕", "Comfortaa Bold X20", w/2, h/2, 
            self:IsHovered() and Color(255, 100, 100) or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
        surface.PlaySound("ui/button_back.mp3")
    end
    
    -- =============================================
    -- ЛЕВАЯ ЧАСТЬ - ИНВЕНТАРЬ
    -- =============================================
    local invPanel = vgui.Create("DPanel", frame)
    invPanel:SetPos(10, 75)
    invPanel:SetSize(frameW/2 - 20, frameH - 140)
    invPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 30, 200))
    end
    
    local invScroll = vgui.Create("DScrollPanel", invPanel)
    invScroll:Dock(FILL)
    invScroll:DockMargin(5, 5, 5, 5)
    
    local invGrid = invScroll:Add("DIconLayout")
    invGrid:Dock(FILL)
    invGrid:SetSpaceX(5)
    invGrid:SetSpaceY(5)
    
    -- Заполняем ингредиентами
    local ply = LocalPlayer()
    if ply.items then
        for slot, item in pairs(ply.items) do
            local itemData = dbt.inventory.items[item.id]
            if not itemData or not itemData.ingredient then continue end
            
            local ingData = LOTM.Ingredients and LOTM.Ingredients.Get(itemData.ingredientId)
            if not ingData then continue end
            
            local itemBtn = vgui.Create("DButton")
            itemBtn:SetSize(70, 80)
            itemBtn:SetText("")
            
            local rarityColor = Color(200, 200, 200)
            if LOTM.Ingredients and LOTM.Ingredients.RarityColors then
                rarityColor = LOTM.Ingredients.RarityColors[ingData.rarity] or rarityColor
            end
            
            itemBtn.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(60, 30, 80) or colorSlot)
                draw.RoundedBox(0, 0, h - 4, w, 4, rarityColor)
                if self:IsHovered() then draw_border(0, 0, w, h, colorOutLine) end
                draw.SimpleText(string.sub(ingData.name, 1, 2):upper(), "Comfortaa Bold X18", w/2, h/2 - 10, rarityColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(string.sub(ingData.name, 1, 8), "DermaDefault", w/2, h - 15, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            itemBtn:SetTooltip(ingData.name .. "\n" .. (ingData.description or ""))
            
            itemBtn.DoClick = function()
                -- Находим свободный слот
                local slots = altar.IngredientSlots or {}
                local freeSlot = nil
                for i = 1, 6 do
                    if not slots[i] then freeSlot = i break end
                end
                
                if not freeSlot then
                    LocalPlayer():ChatPrint("[LOTM] Все слоты заняты!")
                    return
                end
                
                net.Start("LOTM.BrewingAltar.AddIngredient")
                net.WriteEntity(altar)
                net.WriteString(itemData.ingredientId)
                net.WriteUInt(freeSlot, 8)
                net.SendToServer()
                surface.PlaySound("items/ammopickup.wav")
            end
            
            invGrid:Add(itemBtn)
        end
    end
    
    -- =============================================
    -- ПРАВАЯ ЧАСТЬ - АЛТАРЬ
    -- =============================================
    local altarPanel = vgui.Create("DPanel", frame)
    altarPanel:SetPos(frameW/2 + 10, 75)
    altarPanel:SetSize(frameW/2 - 20, frameH - 140)
    altarPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 30, 200))
    end
    
    -- Круговое расположение слотов
    local slotsPanel = vgui.Create("DPanel", altarPanel)
    slotsPanel:SetPos(10, 10)
    slotsPanel:SetSize(altarPanel:GetWide() - 20, 250)
    slotsPanel.Paint = function(self, w, h)
        local cx, cy = w/2, h/2
        
        -- Центральный круг
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 50)
        for i = 0, 31 do
            local a1 = (i / 32) * math.pi * 2
            local a2 = ((i+1) / 32) * math.pi * 2
            surface.DrawLine(cx + math.cos(a1) * 30, cy + math.sin(a1) * 30,
                           cx + math.cos(a2) * 30, cy + math.sin(a2) * 30)
        end
        
        draw.SimpleText("☆", "Comfortaa Bold X25", cx, cy, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    LOTM.BrewingAltar.SlotButtons = {}
    local radius = 90
    local cx, cy = slotsPanel:GetWide() / 2, slotsPanel:GetTall() / 2
    
    for i = 1, 6 do
        local angle = math.rad((i - 1) * 60 - 90)
        local x = cx + math.cos(angle) * radius - 35
        local y = cy + math.sin(angle) * radius - 35
        
        local slotBtn = vgui.Create("DButton", slotsPanel)
        slotBtn:SetPos(x, y)
        slotBtn:SetSize(70, 70)
        slotBtn:SetText("")
        slotBtn.SlotIndex = i
        
        slotBtn.Paint = function(self, w, h)
            local slots = altar.IngredientSlots or {}
            local slot = slots[self.SlotIndex]
            
            local bgColor = slot and colorSlotFilled or colorSlot
            if self:IsHovered() then bgColor = Color(80, 40, 100) end
            
            draw.RoundedBox(35, 0, 0, w, h, bgColor)
            draw_border(0, 0, w, h, slot and colorOutLine or Color(80, 80, 90))
            
            if slot then
                draw.SimpleText("✓", "Comfortaa Bold X20", w/2, h/2 - 8, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(string.sub(slot.name or "", 1, 6), "DermaDefault", w/2, h/2 + 12, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(tostring(i), "Comfortaa Bold X25", w/2, h/2, Color(80, 80, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        slotBtn.DoClick = function(self)
            local slots = altar.IngredientSlots or {}
            if slots[self.SlotIndex] then
                net.Start("LOTM.BrewingAltar.RemoveIngredient")
                net.WriteEntity(altar)
                net.WriteUInt(self.SlotIndex, 8)
                net.SendToServer()
                surface.PlaySound("items/ammopickup.wav")
            end
        end
        
        LOTM.BrewingAltar.SlotButtons[i] = slotBtn
    end
    
    -- Кнопка ПРИМЕНИТЬ
    local brewBtn = vgui.Create("DButton", altarPanel)
    brewBtn:SetPos(10, 270)
    brewBtn:SetSize(altarPanel:GetWide() - 20, 50)
    brewBtn:SetText("")
    brewBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(60, 30, 80) or Color(40, 20, 50)
        draw.RoundedBox(4, 0, 0, w, h, color)
        draw_border(0, 0, w, h, colorOutLine)
        draw.SimpleText("⚗ ПРИМЕНИТЬ", "Comfortaa Bold X25", w/2, h/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    brewBtn.DoClick = function()
        net.Start("LOTM.BrewingAltar.Brew")
        net.WriteEntity(altar)
        net.SendToServer()
        surface.PlaySound("ui/button_click.mp3")
    end
    
    -- Кнопки снизу
    local btnW = (altarPanel:GetWide() - 30) / 2
    
    local clearBtn = vgui.Create("DButton", altarPanel)
    clearBtn:SetPos(10, 330)
    clearBtn:SetSize(btnW, 35)
    clearBtn:SetText("")
    clearBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(80, 40, 40) or Color(50, 30, 30))
        draw.SimpleText("Очистить", "DermaDefaultBold", w/2, h/2, Color(255, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    clearBtn.DoClick = function()
        net.Start("LOTM.BrewingAltar.Clear")
        net.WriteEntity(altar)
        net.SendToServer()
    end
    
    local notesBtn = vgui.Create("DButton", altarPanel)
    notesBtn:SetPos(20 + btnW, 330)
    notesBtn:SetSize(btnW, 35)
    notesBtn:SetText("")
    notesBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(60, 50, 30) or Color(40, 35, 20))
        draw.SimpleText("📜 Записки", "DermaDefaultBold", w/2, h/2, Color(255, 215, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    notesBtn.DoClick = function()
        if LOTM.Notes then LOTM.Notes.OpenNotesPanel() end
    end
    
    -- Инфо панель
    local infoPanel = vgui.Create("DPanel", altarPanel)
    infoPanel:SetPos(10, 375)
    infoPanel:SetSize(altarPanel:GetWide() - 20, 50)
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 200))
        draw.SimpleText("Путь: " .. (playerPathway > 0 and playerPathway or "—") .. " | Seq: " .. playerSequence, 
            "DermaDefault", w/2, h/2, colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then self:Remove() return true end
    end
end

function LOTM.BrewingAltar.ShowNotification(potionName, sequence, pathwayName)
    local notif = vgui.Create("DPanel")
    notif:SetSize(400, 120)
    notif:SetPos(ScrW() / 2 - 200, -130)
    notif.Alpha = 255
    
    notif.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 220))
        draw_border(0, 0, w, h, colorOutLine)
        draw.SimpleText("ЗЕЛЬЕ СОЗДАНО!", "Comfortaa Bold X25", w/2, 25, colorOutLine, TEXT_ALIGN_CENTER)
        draw.SimpleText(potionName, "Comfortaa Bold X20", w/2, 55, colorText, TEXT_ALIGN_CENTER)
        draw.SimpleText("Seq " .. sequence .. (pathwayName ~= "" and (" | " .. pathwayName) or ""), "DermaDefault", w/2, 85, colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    notif:MoveTo(ScrW() / 2 - 200, 50, 0.4, 0, 0.3)
    
    timer.Simple(3, function()
        if IsValid(notif) then
            notif:AlphaTo(0, 0.3, 0, function() if IsValid(notif) then notif:Remove() end end)
        end
    end)
end

print("[LOTM] Brewing Altar Client v3.0 loaded")
