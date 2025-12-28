-- LOTM Skills Menu v3.0
-- Полноэкранное древо скиллов в стиле проекта DBT
-- 3 активных + 2 пассивки на каждую последовательность

LOTM = LOTM or {}
LOTM.SkillsMenu = LOTM.SkillsMenu or {}

-- Цветовая палитра проекта
local colorOutLine = Color(211, 25, 202)
local colorOutLineSecondary = Color(150, 100, 220)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255, 200)
local colorTextDim = Color(150, 150, 150)
local colorButtonExit = Color(250, 250, 250, 1)
local colorSettingsPanel = Color(0, 0, 0, 170)
local colorActive = Color(100, 255, 200)
local colorPassive = Color(255, 200, 100)
local colorLocked = Color(80, 80, 80)
local colorUnlocked = Color(100, 255, 100)
local colorMaxed = Color(255, 100, 100)

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

-- =============================================
-- ОТКРЫТИЕ МЕНЮ СКИЛЛОВ
-- =============================================

function LOTM.SkillsMenu.Open()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.SkillsMenu.Frame) then
        LOTM.SkillsMenu.Frame:Close()
        return
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    
    -- Получаем данные игрока
    local playerPathway = LocalPlayer():GetNWInt("LOTM_Pathway", 1)
    local playerSequence = LocalPlayer():GetNWInt("LOTM_Sequence", 9)
    local pathwayData = LOTM.PathwaysList and LOTM.PathwaysList[playerPathway]
    local pathwayColor = pathwayData and pathwayData.color or colorOutLine
    local pathwayName = pathwayData and pathwayData.name or "Неизвестный путь"
    
    -- Выбранный скилл для отображения деталей
    local selectedSkill = nil
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw, scrh)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    LOTM.SkillsMenu.Frame = frame
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            self:Close()
            return true
        end
    end
    
    -- Основная отрисовка
    frame.Paint = function(self, w, h)
        if BlurScreen then BlurScreen(24) end
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        
        if dbtPaint and dbtPaint.DrawRect then
            dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 100))
        end
        
        local titleY = dbtPaint and dbtPaint.HightSource(40) or 40
        local subtitleY = dbtPaint and dbtPaint.HightSource(95) or 95
        
        -- Заголовок
        draw.SimpleText("КНИГА СКИЛЛОВ", "Comfortaa Bold X60", w / 2, titleY, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText(pathwayName .. " — Seq " .. playerSequence, "Comfortaa Light X25", w / 2, subtitleY, pathwayColor, TEXT_ALIGN_CENTER)
        
        -- Линия
        local lineW = dbtPaint and dbtPaint.WidthSource(500) or 500
        local lineY = dbtPaint and dbtPaint.HightSource(125) or 125
        draw.RoundedBox(0, w / 2 - lineW / 2, lineY, lineW, 2, colorOutLine)
        
        -- Очки скиллов
        local points = LOTM.Skills and LOTM.Skills.GetPoints and LOTM.Skills.GetPoints(LocalPlayer()) or 0
        local pointsY = dbtPaint and dbtPaint.HightSource(145) or 145
        draw.SimpleText("Доступно очков: " .. points, "Comfortaa Bold X25", w / 2, pointsY, points > 0 and colorUnlocked or colorTextDim, TEXT_ALIGN_CENTER)
        
        -- Подсказки внизу
        local hintY = h - (dbtPaint and dbtPaint.HightSource(60) or 60)
        draw.SimpleText("Нажмите на скилл для просмотра деталей. ЛКМ - изучить скилл.", "Comfortaa Light X18", w / 2, hintY, colorTextDim, TEXT_ALIGN_CENTER)
        draw.SimpleText("На каждую последовательность: макс. 2 активных из 3, макс. 1 пассивка из 2", "Comfortaa Light X16", w / 2, hintY + 25, colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- ЛЕВАЯ ПАНЕЛЬ - ДРЕВО СКИЛЛОВ
    -- =============================================
    
    local treeW = dbtPaint and dbtPaint.WidthSource(1100) or 1100
    local treeH = dbtPaint and dbtPaint.HightSource(700) or 700
    local treeX = dbtPaint and dbtPaint.WidthSource(50) or 50
    local treeY = dbtPaint and dbtPaint.HightSource(180) or 180
    
    local treeScroll = vgui.Create("DScrollPanel", frame)
    treeScroll:SetPos(treeX, treeY)
    treeScroll:SetSize(treeW, treeH)
    
    local sbar = treeScroll:GetVBar()
    sbar:SetWide(10)
    sbar.Paint = function(self, sw, sh) draw.RoundedBox(0, 0, 0, sw, sh, Color(0, 0, 0, 100)) end
    sbar.btnGrip.Paint = function(self, sw, sh) draw.RoundedBox(4, 0, 0, sw, sh, colorOutLine) end
    
    local treePanel = vgui.Create("DPanel", treeScroll)
    treePanel:Dock(TOP)
    treePanel:SetTall(1200)
    treePanel.Paint = function() end
    
    -- Создаём ряды скиллов для каждой последовательности
    local rowH = dbtPaint and dbtPaint.HightSource(120) or 120
    local skillSize = dbtPaint and dbtPaint.WidthSource(90) or 90
    local spacing = dbtPaint and dbtPaint.WidthSource(20) or 20
    local yOffset = 10
    
    -- Отображаем последовательности от текущей до 5 (или 0 для высоких уровней)
    for seq = 9, 5, -1 do
        local seqName = LOTM.GetSequenceName and LOTM.GetSequenceName(playerPathway, seq) or "Seq " .. seq
        local seqAvailable = playerSequence <= seq
        
        -- Заголовок последовательности
        local seqHeader = vgui.Create("DPanel", treePanel)
        seqHeader:SetPos(0, yOffset)
        seqHeader:SetSize(treeW - 20, 35)
        seqHeader.Paint = function(self, w, h)
            local headerColor = seqAvailable and pathwayColor or colorLocked
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
            draw.RoundedBox(0, 0, 0, 5, h, headerColor)
            draw.SimpleText("SEQ " .. seq .. " — " .. seqName, "Comfortaa Bold X22", 20, h / 2, seqAvailable and color_white or colorTextDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Счётчик разблокированных
            if LOTM.Skills then
                local activeCount = LOTM.Skills.CountUnlockedInGroup(LocalPlayer(), playerPathway, seq, LOTM.Skills.Types.ACTIVE) or 0
                local passiveCount = LOTM.Skills.CountUnlockedInGroup(LocalPlayer(), playerPathway, seq, LOTM.Skills.Types.PASSIVE) or 0
                
                local countText = string.format("Активных: %d/2  |  Пассивок: %d/1", activeCount, passiveCount)
                local countColor = colorTextDim
                if activeCount >= 2 and passiveCount >= 1 then
                    countColor = colorMaxed
                elseif activeCount > 0 or passiveCount > 0 then
                    countColor = colorUnlocked
                end
                
                draw.SimpleText(countText, "Comfortaa Light X18", w - 20, h / 2, countColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        yOffset = yOffset + 40
        
        -- Получаем скиллы для этой последовательности
        local skills = LOTM.Skills and LOTM.Skills.GetForSequence(playerPathway, seq) or {active = {}, passive = {}}
        
        -- Также добавляем универсальные скиллы
        local universalSkills = LOTM.Skills and LOTM.Skills.GetForSequence(nil, seq) or {active = {}, passive = {}}
        for _, skill in ipairs(universalSkills.active) do table.insert(skills.active, skill) end
        for _, skill in ipairs(universalSkills.passive) do table.insert(skills.passive, skill) end
        
        -- Панель со скиллами
        local skillsRow = vgui.Create("DPanel", treePanel)
        skillsRow:SetPos(0, yOffset)
        skillsRow:SetSize(treeW - 20, rowH)
        skillsRow.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
        end
        
        local xPos = 20
        
        -- Активные скиллы
        local activeLabel = vgui.Create("DLabel", skillsRow)
        activeLabel:SetPos(xPos, 5)
        activeLabel:SetSize(200, 20)
        activeLabel:SetFont("Comfortaa Light X16")
        activeLabel:SetText("АКТИВНЫЕ")
        activeLabel:SetTextColor(colorActive)
        
        xPos = 20
        for i, skill in ipairs(skills.active) do
            if i <= 3 then
                local skillBtn = LOTM.SkillsMenu.CreateSkillButton(skillsRow, skill, xPos, 28, skillSize, function(s)
                    selectedSkill = s
                    LOTM.SkillsMenu.RefreshDetails(frame, selectedSkill, treeW + treeX + 30, treeY, scrw - treeW - treeX - 80, treeH)
                end)
                xPos = xPos + skillSize + spacing
            end
        end
        
        -- Разделитель
        local separator = vgui.Create("DPanel", skillsRow)
        separator:SetPos(xPos + 20, 25)
        separator:SetSize(2, skillSize)
        separator.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, colorOutLine)
        end
        
        xPos = xPos + 50
        
        -- Пассивные скиллы
        local passiveLabel = vgui.Create("DLabel", skillsRow)
        passiveLabel:SetPos(xPos, 5)
        passiveLabel:SetSize(200, 20)
        passiveLabel:SetFont("Comfortaa Light X16")
        passiveLabel:SetText("ПАССИВНЫЕ")
        passiveLabel:SetTextColor(colorPassive)
        
        for i, skill in ipairs(skills.passive) do
            if i <= 2 then
                local skillBtn = LOTM.SkillsMenu.CreateSkillButton(skillsRow, skill, xPos, 28, skillSize, function(s)
                    selectedSkill = s
                    LOTM.SkillsMenu.RefreshDetails(frame, selectedSkill, treeW + treeX + 30, treeY, scrw - treeW - treeX - 80, treeH)
                end)
                xPos = xPos + skillSize + spacing
            end
        end
        
        yOffset = yOffset + rowH + 15
    end
    
    -- =============================================
    -- ПРАВАЯ ПАНЕЛЬ - ДЕТАЛИ СКИЛЛА
    -- =============================================
    
    LOTM.SkillsMenu.RefreshDetails(frame, nil, treeW + treeX + 30, treeY, scrw - treeW - treeX - 80, treeH)
    
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
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- =============================================
-- СОЗДАНИЕ КНОПКИ СКИЛЛА
-- =============================================

function LOTM.SkillsMenu.CreateSkillButton(parent, skill, x, y, size, onSelect)
    local isUnlocked = LOTM.Skills and LOTM.Skills.IsUnlocked(LocalPlayer(), skill.id)
    local canUnlock = LOTM.Skills and LOTM.Skills.CanUnlock(LocalPlayer(), skill.id)
    
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x, y)
    btn:SetSize(size, size)
    btn:SetText("")
    btn.skill = skill
    
    btn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local isActive = skill.skillType == LOTM.Skills.Types.ACTIVE
        
        -- Фон
        local bgColor = Color(20, 20, 25, 220)
        if isUnlocked then
            bgColor = isActive and Color(40, 80, 60, 220) or Color(80, 60, 40, 220)
        elseif not canUnlock then
            bgColor = Color(30, 30, 35, 150)
        end
        
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        -- Рамка
        local borderColor = colorLocked
        if isUnlocked then
            borderColor = colorUnlocked
        elseif canUnlock then
            borderColor = isActive and colorActive or colorPassive
        end
        
        if hovered then
            borderColor = Color(math.min(borderColor.r + 50, 255), math.min(borderColor.g + 50, 255), math.min(borderColor.b + 50, 255))
        end
        
        draw_border(w, h, borderColor, hovered and 3 or 2)
        
        -- Иконка типа
        local typeIcon = isActive and "⚔" or "★"
        local typeColor = isActive and colorActive or colorPassive
        draw.SimpleText(typeIcon, "DermaLarge", w / 2, h / 2 - 10, typeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Индекс
        draw.SimpleText(skill.slotIndex or 1, "Comfortaa Bold X16", w - 8, 8, colorTextDim, TEXT_ALIGN_RIGHT)
        
        -- Статус внизу
        if isUnlocked then
            draw.RoundedBox(0, 0, h - 5, w, 5, colorUnlocked)
        elseif canUnlock then
            draw.RoundedBox(0, 0, h - 3, w, 3, Color(255, 255, 100, 150))
        end
        
        -- Короткое имя
        local shortName = string.sub(skill.name, 1, 8)
        if #skill.name > 8 then shortName = shortName .. ".." end
        draw.SimpleText(shortName, "Comfortaa Light X12", w / 2, h - 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
    
    btn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        if onSelect then onSelect(skill) end
    end
    
    btn.OnCursorEntered = function()
        surface.PlaySound('ui/ui_but/ui_hover.wav')
    end
    
    return btn
end

-- =============================================
-- ПАНЕЛЬ ДЕТАЛЕЙ СКИЛЛА
-- =============================================

function LOTM.SkillsMenu.RefreshDetails(frame, skill, x, y, w, h)
    if IsValid(LOTM.SkillsMenu.DetailsPanel) then
        LOTM.SkillsMenu.DetailsPanel:Remove()
    end
    
    local panel = vgui.Create("DPanel", frame)
    panel:SetPos(x, y)
    panel:SetSize(w, h)
    LOTM.SkillsMenu.DetailsPanel = panel
    
    if not skill then
        panel.Paint = function(self, pw, ph)
            draw.RoundedBox(4, 0, 0, pw, ph, Color(0, 0, 0, 150))
            draw.SimpleText("Выберите скилл", "Comfortaa Bold X30", pw / 2, ph / 2 - 20, colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("для просмотра деталей", "Comfortaa Light X20", pw / 2, ph / 2 + 20, colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return
    end
    
    local isUnlocked = LOTM.Skills and LOTM.Skills.IsUnlocked(LocalPlayer(), skill.id)
    local canUnlock, unlockReason = false, "Недоступно"
    if LOTM.Skills and LOTM.Skills.CanUnlock then
        canUnlock, unlockReason = LOTM.Skills.CanUnlock(LocalPlayer(), skill.id)
    end
    
    local isActive = skill.skillType == LOTM.Skills.Types.ACTIVE
    local typeColor = isActive and colorActive or colorPassive
    local typeName = isActive and "АКТИВНЫЙ СКИЛЛ" or "ПАССИВНЫЙ СКИЛЛ"
    
    panel.Paint = function(self, pw, ph)
        draw.RoundedBox(4, 0, 0, pw, ph, Color(0, 0, 0, 200))
        draw_border(pw, ph, typeColor, 2)
        
        -- Заголовок
        draw.SimpleText(skill.name, "Comfortaa Bold X35", pw / 2, 30, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText(typeName, "Comfortaa Light X18", pw / 2, 65, typeColor, TEXT_ALIGN_CENTER)
        
        -- Линия
        draw.RoundedBox(0, 20, 90, pw - 40, 2, typeColor)
        
        -- Описание
        local descY = 110
        draw.SimpleText("Описание:", "Comfortaa Bold X20", 20, descY, colorOutLine)
        
        -- Разбиваем описание на строки
        local desc = skill.description or "Нет описания"
        local words = string.Explode(" ", desc)
        local line = ""
        local lineY = descY + 30
        local maxLineW = pw - 40
        
        for _, word in ipairs(words) do
            local testLine = line .. (line ~= "" and " " or "") .. word
            surface.SetFont("Comfortaa Light X18")
            local tw = surface.GetTextSize(testLine)
            
            if tw > maxLineW then
                draw.SimpleText(line, "Comfortaa Light X18", 20, lineY, colorText)
                lineY = lineY + 22
                line = word
            else
                line = testLine
            end
        end
        if line ~= "" then
            draw.SimpleText(line, "Comfortaa Light X18", 20, lineY, colorText)
            lineY = lineY + 22
        end
        
        lineY = lineY + 20
        
        -- Характеристики для активных скиллов
        if isActive then
            draw.SimpleText("Характеристики:", "Comfortaa Bold X20", 20, lineY, colorOutLine)
            lineY = lineY + 30
            
            if skill.cooldown and skill.cooldown > 0 then
                draw.SimpleText("• Кулдаун: " .. skill.cooldown .. " сек", "Comfortaa Light X18", 30, lineY, colorText)
                lineY = lineY + 25
            end
            
            if skill.maxCharges and skill.maxCharges > 1 then
                draw.SimpleText("• Зарядов: " .. skill.maxCharges, "Comfortaa Light X18", 30, lineY, colorText)
                lineY = lineY + 25
                draw.SimpleText("• Восстановление заряда: " .. (skill.chargeRegenTime or 5) .. " сек", "Comfortaa Light X18", 30, lineY, colorText)
                lineY = lineY + 25
            end
            
            if skill.damage and skill.damage.enabled then
                local dmgText = "• Урон: " .. (skill.damage.amount or 0)
                if skill.damage.type then dmgText = dmgText .. " (" .. skill.damage.type .. ")" end
                draw.SimpleText(dmgText, "Comfortaa Light X18", 30, lineY, Color(255, 150, 150))
                lineY = lineY + 25
                
                if skill.damage.radius and skill.damage.radius > 0 then
                    draw.SimpleText("• Радиус: " .. skill.damage.radius, "Comfortaa Light X18", 30, lineY, colorText)
                    lineY = lineY + 25
                end
            end
            
            if skill.healing and skill.healing.enabled then
                draw.SimpleText("• Исцеление: " .. (skill.healing.amount or 0), "Comfortaa Light X18", 30, lineY, Color(150, 255, 150))
                lineY = lineY + 25
            end
        end
        
        -- Бонусы для пассивок
        if not isActive and skill.bonuses and table.Count(skill.bonuses) > 0 then
            draw.SimpleText("Бонусы:", "Comfortaa Bold X20", 20, lineY, colorOutLine)
            lineY = lineY + 30
            
            for stat, value in pairs(skill.bonuses) do
                local bonusText = "• +" .. value .. " " .. stat
                draw.SimpleText(bonusText, "Comfortaa Light X18", 30, lineY, Color(150, 255, 150))
                lineY = lineY + 25
            end
        end
        
        -- Требования
        lineY = lineY + 20
        draw.SimpleText("Требования:", "Comfortaa Bold X20", 20, lineY, colorOutLine)
        lineY = lineY + 30
        
        draw.SimpleText("• Последовательность: " .. skill.sequence .. " или ниже", "Comfortaa Light X18", 30, lineY, colorText)
        lineY = lineY + 25
        
        if skill.pathway then
            local pathName = LOTM.GetPathwayName and LOTM.GetPathwayName(skill.pathway) or "Путь " .. skill.pathway
            draw.SimpleText("• Путь: " .. pathName, "Comfortaa Light X18", 30, lineY, colorText)
        else
            draw.SimpleText("• Путь: Универсальный", "Comfortaa Light X18", 30, lineY, colorText)
        end
        
        -- Статус
        local statusY = ph - 100
        draw.RoundedBox(0, 20, statusY - 10, pw - 40, 2, colorOutLine)
        
        local statusText, statusColor
        if isUnlocked then
            statusText = "✓ ИЗУЧЕНО"
            statusColor = colorUnlocked
        elseif canUnlock then
            statusText = "ДОСТУПНО ДЛЯ ИЗУЧЕНИЯ"
            statusColor = Color(255, 255, 100)
        else
            statusText = unlockReason or "НЕДОСТУПНО"
            statusColor = colorMaxed
        end
        
        draw.SimpleText(statusText, "Comfortaa Bold X22", pw / 2, statusY + 15, statusColor, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка изучения
    if canUnlock and not isUnlocked then
        local learnBtn = vgui.Create("DButton", panel)
        learnBtn:SetPos(20, h - 60)
        learnBtn:SetSize(w - 40, 45)
        learnBtn:SetText("")
        
        learnBtn.Paint = function(self, bw, bh)
            local hovered = self:IsHovered()
            draw.RoundedBox(4, 0, 0, bw, bh, hovered and Color(50, 150, 80, 220) or Color(40, 120, 60, 200))
            
            if hovered then
                draw_border(bw, bh, colorUnlocked, 2)
            end
            
            draw.SimpleText("ИЗУЧИТЬ СКИЛЛ (1 очко)", "Comfortaa Bold X22", bw / 2, bh / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        learnBtn.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            
            -- Отправляем запрос на сервер
            net.Start("LOTM.Skills.Unlock")
            net.WriteString(skill.id)
            net.SendToServer()
            
            -- Закрываем и открываем заново для обновления
            timer.Simple(0.2, function()
                if IsValid(LOTM.SkillsMenu.Frame) then
                    LOTM.SkillsMenu.Frame:Close()
                    LOTM.SkillsMenu.Open()
                end
            end)
        end
        
        learnBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    end
end

-- =============================================
-- СЕТЕВОЕ ВЗАИМОДЕЙСТВИЕ
-- =============================================

net.Receive("LOTM.Skills.Sync", function()
    local skillPoints = net.ReadUInt(16)
    local unlockedCount = net.ReadUInt(16)
    
    local unlocked = {}
    for i = 1, unlockedCount do
        local skillId = net.ReadString()
        unlocked[skillId] = true
    end
    
    local pid = LocalPlayer():SteamID64() or LocalPlayer():UniqueID()
    LOTM.Skills.PlayerData[pid] = LOTM.Skills.PlayerData[pid] or {}
    LOTM.Skills.PlayerData[pid].skillPoints = skillPoints
    LOTM.Skills.PlayerData[pid].unlocked = unlocked
end)

net.Receive("LOTM.Skills.Notify", function()
    local message = net.ReadString()
    local color = net.ReadColor()
    chat.AddText(Color(100, 255, 100), "[LOTM Skills] ", color, message)
end)

-- =============================================
-- КОНСОЛЬНЫЕ КОМАНДЫ
-- =============================================

concommand.Add("lotm_skills", function()
    LOTM.SkillsMenu.Open()
end)

concommand.Add("lotm_skillmenu", function()
    LOTM.SkillsMenu.Open()
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Skills Menu v3.0 loaded\n")
