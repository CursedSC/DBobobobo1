-- LOTM Artifact Slots UI v3.0
-- Визуальный интерфейс для слотов артефактов
-- Интеграция с инвентарём DBT

LOTM = LOTM or {}
LOTM.ArtifactSlotsUI = LOTM.ArtifactSlotsUI or {}

-- Цвета проекта
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255, 200)
local colorTextDim = Color(150, 150, 150)
local colorSettingsPanel = Color(0, 0, 0, 170)
local colorGold = Color(255, 215, 100)
local colorEmpty = Color(60, 60, 70, 200)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

local function draw_border(w, h, color, thickness)
    thickness = thickness or 1
    draw.RoundedBox(0, 0, 0, w, thickness, color)
    draw.RoundedBox(0, 0, 0, thickness, h, color)
    draw.RoundedBox(0, 0, h - thickness, w, thickness, color)
    draw.RoundedBox(0, w - thickness, 0, thickness, h, color)
end

-- Цвета по типу артефакта
local typeColors = {
    ["grade_9"] = Color(200, 200, 200),
    ["grade_8"] = Color(100, 255, 100),
    ["grade_7"] = Color(100, 150, 255),
    ["grade_6"] = Color(150, 100, 255),
    ["grade_5"] = Color(255, 100, 255),
    ["grade_4"] = Color(255, 150, 50),
    ["cursed"] = Color(255, 50, 50),
    ["divine"] = Color(255, 215, 0),
}

-- =============================================
-- ОТКРЫТЬ МЕНЮ СЛОТОВ АРТЕФАКТОВ
-- =============================================

function LOTM.ArtifactSlotsUI.Open()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.ArtifactSlotsUI.Frame) then
        LOTM.ArtifactSlotsUI.Frame:Close()
        return
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    
    local selectedSlot = nil
    local selectedArtifact = nil
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw, scrh)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    LOTM.ArtifactSlotsUI.Frame = frame
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            self:Close()
            return true
        end
    end
    
    frame.Paint = function(self, w, h)
        if BlurScreen then BlurScreen(24) end
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        
        if dbtPaint and dbtPaint.DrawRect then
            dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 100))
        end
        
        local titleY = dbtPaint and dbtPaint.HightSource(50) or 50
        draw.SimpleText("ЭКИПИРОВКА АРТЕФАКТОВ", "Comfortaa Bold X60", w / 2, titleY, color_white, TEXT_ALIGN_CENTER)
        
        local subtitleY = dbtPaint and dbtPaint.HightSource(110) or 110
        draw.SimpleText("Выберите слот для экипировки артефакта", "Comfortaa Light X22", w / 2, subtitleY, colorText, TEXT_ALIGN_CENTER)
        
        local lineW = dbtPaint and dbtPaint.WidthSource(400) or 400
        local lineY = dbtPaint and dbtPaint.HightSource(145) or 145
        draw.RoundedBox(0, w / 2 - lineW / 2, lineY, lineW, 2, colorOutLine)
    end
    
    -- =============================================
    -- ЛЕВАЯ ПАНЕЛЬ - СЛОТЫ ЭКИПИРОВКИ
    -- =============================================
    
    local slotsW = dbtPaint and dbtPaint.WidthSource(500) or 500
    local slotsH = dbtPaint and dbtPaint.HightSource(650) or 650
    local slotsX = dbtPaint and dbtPaint.WidthSource(100) or 100
    local slotsY = dbtPaint and dbtPaint.HightSource(180) or 180
    
    local slotsPanel = vgui.Create("DPanel", frame)
    slotsPanel:SetPos(slotsX, slotsY)
    slotsPanel:SetSize(slotsW, slotsH)
    slotsPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.SimpleText("СЛОТЫ ЭКИПИРОВКИ", "Comfortaa Bold X25", w / 2, 20, colorOutLine, TEXT_ALIGN_CENTER)
        draw_border(w, h, colorOutLine, 1)
    end
    
    -- Создаём слоты
    local slotTypes = {
        {type = LOTM.ArtifactSlots.Types.HEAD, name = "Голова", icon = "👑"},
        {type = LOTM.ArtifactSlots.Types.NECK, name = "Шея", icon = "📿"},
        {type = LOTM.ArtifactSlots.Types.RING_LEFT, name = "Левое кольцо", icon = "💍"},
        {type = LOTM.ArtifactSlots.Types.RING_RIGHT, name = "Правое кольцо", icon = "💍"},
        {type = LOTM.ArtifactSlots.Types.WEAPON, name = "Оружие", icon = "⚔"},
        {type = LOTM.ArtifactSlots.Types.ARMOR, name = "Броня", icon = "🛡"},
        {type = LOTM.ArtifactSlots.Types.ACCESSORY, name = "Аксессуар", icon = "✨"},
    }
    
    local slotSize = dbtPaint and dbtPaint.WidthSource(80) or 80
    local slotSpacing = dbtPaint and dbtPaint.HightSource(85) or 85
    local startY = 60
    
    for i, slotData in ipairs(slotTypes) do
        local slotBtn = vgui.Create("DButton", slotsPanel)
        slotBtn:SetPos(20, startY + (i - 1) * slotSpacing)
        slotBtn:SetSize(slotsW - 40, slotSize)
        slotBtn:SetText("")
        slotBtn.slotType = slotData.type
        
        slotBtn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local isSelected = selectedSlot == slotData.type
            
            -- Получаем экипированный артефакт
            local equippedArt = nil
            if LOTM.ArtifactSlots and LOTM.ArtifactSlots.GetSlot then
                equippedArt = LOTM.ArtifactSlots.GetSlot(LocalPlayer(), slotData.type)
            end
            
            local bgColor = isSelected and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100) or
                           (hovered and Color(50, 50, 60, 200) or colorEmpty)
            
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            if isSelected or hovered then
                draw_border(w, h, colorOutLine, 2)
            end
            
            -- Иконка слота
            draw.SimpleText(slotData.icon, "DermaLarge", 40, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Название слота
            draw.SimpleText(slotData.name, "Comfortaa Bold X20", 90, h / 2 - 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Артефакт в слоте
            if equippedArt then
                local artColor = typeColors[equippedArt.type] or colorGold
                draw.SimpleText(equippedArt.name, "Comfortaa Light X16", 90, h / 2 + 12, artColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.RoundedBox(0, w - 10, 0, 10, h, artColor)
            else
                draw.SimpleText("Пусто", "Comfortaa Light X16", 90, h / 2 + 12, colorTextDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
        
        slotBtn.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            selectedSlot = slotData.type
            LOTM.ArtifactSlotsUI.RefreshArtifactList(frame, selectedSlot, slotsX + slotsW + 30, slotsY, scrw - slotsX - slotsW - 150, slotsH)
        end
        
        slotBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    end
    
    -- =============================================
    -- ПРАВАЯ ПАНЕЛЬ - ДОСТУПНЫЕ АРТЕФАКТЫ
    -- =============================================
    
    LOTM.ArtifactSlotsUI.RefreshArtifactList(frame, nil, slotsX + slotsW + 30, slotsY, scrw - slotsX - slotsW - 150, slotsH)
    
    -- =============================================
    -- КНОПКА НАЗАД
    -- =============================================
    
    local backButton = vgui.Create("DButton", frame)
    backButton:SetText("")
    backButton:SetPos(dbtPaint and dbtPaint.WidthSource(48) or 48, dbtPaint and dbtPaint.HightSource(984) or (scrh - 70))
    backButton:SetSize(dbtPaint and dbtPaint.WidthSource(199) or 199, dbtPaint and dbtPaint.HightSource(55) or 55)
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        frame:Close()
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or Color(250, 250, 250, 1))
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- =============================================
-- ОБНОВИТЬ СПИСОК АРТЕФАКТОВ
-- =============================================

function LOTM.ArtifactSlotsUI.RefreshArtifactList(frame, selectedSlot, x, y, w, h)
    if IsValid(LOTM.ArtifactSlotsUI.ArtifactPanel) then
        LOTM.ArtifactSlotsUI.ArtifactPanel:Remove()
    end
    
    local panel = vgui.Create("DPanel", frame)
    panel:SetPos(x, y)
    panel:SetSize(w, h)
    LOTM.ArtifactSlotsUI.ArtifactPanel = panel
    
    panel.Paint = function(self, pw, ph)
        draw.RoundedBox(4, 0, 0, pw, ph, Color(0, 0, 0, 180))
        draw_border(pw, ph, colorOutLine, 1)
        
        local headerText = selectedSlot and "ДОСТУПНЫЕ АРТЕФАКТЫ" or "ВЫБЕРИТЕ СЛОТ"
        draw.SimpleText(headerText, "Comfortaa Bold X25", pw / 2, 20, colorOutLine, TEXT_ALIGN_CENTER)
    end
    
    if not selectedSlot then
        local hintLabel = vgui.Create("DLabel", panel)
        hintLabel:SetPos(20, h / 2 - 30)
        hintLabel:SetSize(w - 40, 60)
        hintLabel:SetFont("Comfortaa Light X20")
        hintLabel:SetText("Выберите слот слева\nдля просмотра доступных артефактов")
        hintLabel:SetTextColor(colorTextDim)
        hintLabel:SetContentAlignment(5)
        return
    end
    
    -- Скролл с артефактами
    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:SetPos(10, 55)
    scroll:SetSize(w - 20, h - 120)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, sw, sh) draw.RoundedBox(0, 0, 0, sw, sh, Color(0, 0, 0, 100)) end
    sbar.btnGrip.Paint = function(self, sw, sh) draw.RoundedBox(4, 0, 0, sw, sh, colorOutLine) end
    
    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(w - 40, h - 120)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)
    
    -- Получаем артефакты, которые можно экипировать в этот слот
    if LOTM.Artifacts and LOTM.Artifacts.Registry then
        for artId, art in pairs(LOTM.Artifacts.Registry) do
            local canEquip = true
            if LOTM.ArtifactSlots and LOTM.ArtifactSlots.CanEquipInSlot then
                canEquip = LOTM.ArtifactSlots.CanEquipInSlot(artId, selectedSlot)
            end
            
            if canEquip then
                local artBtn = layout:Add("DButton")
                artBtn:SetSize(dbtPaint and dbtPaint.WidthSource(150) or 150, dbtPaint and dbtPaint.HightSource(100) or 100)
                artBtn:SetText("")
                
                local artColor = typeColors[art.type] or colorGold
                
                artBtn.Paint = function(self, bw, bh)
                    local hovered = self:IsHovered()
                    draw.RoundedBox(4, 0, 0, bw, bh, hovered and Color(60, 40, 80, 220) or Color(40, 40, 50, 200))
                    
                    if hovered then
                        draw_border(bw, bh, artColor, 2)
                    end
                    
                    -- Название
                    draw.SimpleText(art.name, "Comfortaa Bold X14", bw / 2, 20, artColor, TEXT_ALIGN_CENTER)
                    
                    -- Тип
                    local typeName = art.type and string.upper(art.type) or "АРТЕФАКТ"
                    draw.SimpleText(typeName, "DermaDefault", bw / 2, 40, colorTextDim, TEXT_ALIGN_CENTER)
                    
                    -- Кулдаун
                    draw.SimpleText("CD: " .. (art.abilityCooldown or 60) .. "с", "DermaDefault", bw / 2, 60, Color(100, 200, 255), TEXT_ALIGN_CENTER)
                    
                    -- Индикатор экипировки
                    local isEquipped = false
                    if LOTM.ArtifactSlots and LOTM.ArtifactSlots.GetSlot then
                        local equipped = LOTM.ArtifactSlots.GetSlot(LocalPlayer(), selectedSlot)
                        if equipped and equipped.id == artId then
                            isEquipped = true
                        end
                    end
                    
                    if isEquipped then
                        draw.RoundedBox(0, 0, bh - 5, bw, 5, Color(100, 255, 100))
                        draw.SimpleText("ЭКИПИРОВАНО", "DermaDefault", bw / 2, bh - 20, Color(100, 255, 100), TEXT_ALIGN_CENTER)
                    end
                end
                
                artBtn.DoClick = function()
                    surface.PlaySound('ui/button_click.mp3')
                    
                    if LOTM.ArtifactSlots and LOTM.ArtifactSlots.RequestEquip then
                        LOTM.ArtifactSlots.RequestEquip(artId, selectedSlot)
                    end
                    
                    timer.Simple(0.2, function()
                        if IsValid(panel) then
                            LOTM.ArtifactSlotsUI.RefreshArtifactList(frame, selectedSlot, x, y, w, h)
                        end
                    end)
                end
                
                artBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
            end
        end
    end
    
    -- Кнопка снять артефакт
    local unequipBtn = vgui.Create("DButton", panel)
    unequipBtn:SetPos(10, h - 55)
    unequipBtn:SetSize(w - 20, 45)
    unequipBtn:SetText("")
    
    unequipBtn.Paint = function(self, bw, bh)
        local hovered = self:IsHovered()
        draw.RoundedBox(4, 0, 0, bw, bh, hovered and Color(150, 50, 50, 200) or Color(100, 40, 40, 180))
        
        if hovered then
            draw_border(bw, bh, Color(255, 100, 100), 2)
        end
        
        draw.SimpleText("СНЯТЬ АРТЕФАКТ", "Comfortaa Bold X20", bw / 2, bh / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    unequipBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        
        if LOTM.ArtifactSlots and LOTM.ArtifactSlots.RequestUnequip then
            LOTM.ArtifactSlots.RequestUnequip(selectedSlot)
        end
        
        timer.Simple(0.2, function()
            if IsValid(panel) then
                LOTM.ArtifactSlotsUI.RefreshArtifactList(frame, selectedSlot, x, y, w, h)
            end
        end)
    end
    
    unequipBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- =============================================
-- КОНСОЛЬНАЯ КОМАНДА
-- =============================================

concommand.Add("lotm_artifacts_equip", function()
    LOTM.ArtifactSlotsUI.Open()
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Artifact Slots UI v3.0 loaded\n")

