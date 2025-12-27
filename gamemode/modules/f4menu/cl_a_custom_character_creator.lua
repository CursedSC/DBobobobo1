-- Custom Character Creator UI
-- UI создания кастомного персонажа с выбором путей LOTM

local bg_creator = Material("dbt/f4/f4_charselect_bg.png")
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorButtonExit = Color(250, 250, 250, 1)
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorText = Color(255, 255, 255, 200)

-- Локальные фоны для создателя персонажа
local tableBG_creator = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Данные для создания персонажа
local CharCreatorData = {
    name = "",
    talent = "",
    pathway = nil,
    sequence = 9,
    
    -- Характеристики
    maxHealth = 100,
    maxHungry = 100,
    maxThird = 100,
    maxSleep = 100,
    runSpeed = 195,
    fistsDamage = "5-10",
    maxKG = 20,
    maxInventory = 8,
}

-- Этапы создания
local CreatorStage = {
    PATHWAY_SELECT = 1,  -- Выбор пути
    SEQUENCE_SELECT = 2, -- Выбор последовательности
    INFO_INPUT = 3,      -- Ввод имени и таланта
    STATS_CONFIG = 4,    -- Настройка характеристик
    CONFIRM = 5,         -- Подтверждение
}

local CurrentStage = CreatorStage.PATHWAY_SELECT
local CurrentBG_Creator = nil

-- Функция открытия создателя персонажа
function open_custom_character_creator()
    if IsValid(dbt.f4) then dbt.f4:Close() end
    
    local scrw, scrh = ScrW(), ScrH()
    local a = math.random(1, 3)
    CurrentBG_Creator = tableBG_creator[a]
    
    -- Сброс данных только при первом открытии
    if CurrentStage == CreatorStage.PATHWAY_SELECT then
        CharCreatorData = {
            name = "",
            talent = "",
            pathway = nil,
            sequence = 9,
            maxHealth = 100,
            maxHungry = 100,
            maxThird = 100,
            maxSleep = 100,
            runSpeed = 195,
            fistsDamage = "5-10",
            maxKG = 20,
            maxInventory = 8,
        }
    end
    
    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton(false)
    dbt.f4:MakePopup()
    
    -- Обработка ESC
    dbt.f4.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            openseasonselect()
            return true
        end
    end
    
    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG_Creator, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_creator, 0, 0, w, h)
        
        -- Заголовок в зависимости от этапа
        local title = "СОЗДАНИЕ ПЕРСОНАЖА"
        if CurrentStage == CreatorStage.PATHWAY_SELECT then
            title = "ВЫБЕРИТЕ ПУТЬ LOTM"
        elseif CurrentStage == CreatorStage.SEQUENCE_SELECT then
            title = "ВЫБЕРИТЕ ПОСЛЕДОВАТЕЛЬНОСТЬ"
        elseif CurrentStage == CreatorStage.INFO_INPUT then
            title = "ИНФОРМАЦИЯ О ПЕРСОНАЖЕ"
        elseif CurrentStage == CreatorStage.STATS_CONFIG then
            title = "НАСТРОЙКА ХАРАКТЕРИСТИК"
        elseif CurrentStage == CreatorStage.CONFIRM then
            title = "ПОДТВЕРЖДЕНИЕ СОЗДАНИЯ"
        end
        
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2, dbtPaint.HightSource(50), color_white, TEXT_ALIGN_CENTER)
    end
    
    -- Создание контента в зависимости от этапа
    CreateStageContent(dbt.f4)
    
    -- Кнопка назад
    local backButton = vgui.Create("DButton", dbt.f4)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        if CurrentStage == CreatorStage.PATHWAY_SELECT then
            dbt.f4:Close()
            openseasonselect()
        else
            -- Вернуться на предыдущий этап
            CurrentStage = CurrentStage - 1
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- Создание контента для текущего этапа
function CreateStageContent(parent)
    if CurrentStage == CreatorStage.PATHWAY_SELECT then
        CreatePathwaySelection(parent)
    elseif CurrentStage == CreatorStage.SEQUENCE_SELECT then
        CreateSequenceSelection(parent)
    elseif CurrentStage == CreatorStage.INFO_INPUT then
        CreateInfoInput(parent)
    elseif CurrentStage == CreatorStage.STATS_CONFIG then
        CreateStatsConfig(parent)
    elseif CurrentStage == CreatorStage.CONFIRM then
        CreateConfirmation(parent)
    end
end

-- ЭТАП 1: Выбор пути LOTM
function CreatePathwaySelection(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Скролл панель для путей
    local scrollPanel = vgui.Create("DScrollPanel", parent)
    scrollPanel:SetPos(dbtPaint.WidthSource(100), dbtPaint.HightSource(150))
    scrollPanel:SetSize(dbtPaint.WidthSource(1720), dbtPaint.HightSource(750))
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(8))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    -- Создание карточек путей (3 в ряд)
    local pathways = LOTM.GetAvailablePathways()
    local cardWidth = dbtPaint.WidthSource(540)
    local cardHeight = dbtPaint.HightSource(250)
    local spacing = dbtPaint.WidthSource(20)
    
    for i = 1, #pathways do
        local pathway = pathways[i]
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        
        local xPos = col * (cardWidth + spacing)
        local yPos = row * (cardHeight + spacing)
        
        -- Карточка пути
        local pathwayCard = vgui.Create("DButton", scrollPanel)
        pathwayCard:SetPos(xPos, yPos)
        pathwayCard:SetSize(cardWidth, cardHeight)
        pathwayCard:SetText("")
        
        pathwayCard.ColorBorder = Color(pathway.color.r, pathway.color.g, pathway.color.b)
        pathwayCard.ColorBorder.a = 100
        pathwayCard.glowAlpha = 0
        pathwayCard.scaleAnim = 0
        
        pathwayCard.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            
            -- Анимация свечения
            if hovered then
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 80)
                self.ColorBorder.a = Lerp(FrameTime() * 8, self.ColorBorder.a, 255)
                self.scaleAnim = Lerp(FrameTime() * 10, self.scaleAnim, 1)
            else
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 0)
                self.ColorBorder.a = Lerp(FrameTime() * 8, self.ColorBorder.a, 120)
                self.scaleAnim = Lerp(FrameTime() * 10, self.scaleAnim, 0)
            end
            
            -- Фон с градиентом
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
            
            -- Градиентное свечение сверху
            draw.RoundedBox(0, 0, 0, w, dbtPaint.HightSource(80), Color(pathway.color.r, pathway.color.g, pathway.color.b, 30 + self.glowAlpha))
            
            -- Анимированная граница
            local borderSize = 2
            draw.RoundedBox(0, 0, 0, w, borderSize, self.ColorBorder)
            draw.RoundedBox(0, 0, h - borderSize, w, borderSize, self.ColorBorder)
            draw.RoundedBox(0, 0, 0, borderSize, h, self.ColorBorder)
            draw.RoundedBox(0, w - borderSize, 0, borderSize, h, self.ColorBorder)
            
            -- Внутреннее свечение при наведении
            if self.glowAlpha > 0 then
                draw.RoundedBox(0, borderSize, borderSize, w - borderSize * 2, h - borderSize * 2, Color(pathway.color.r, pathway.color.g, pathway.color.b, self.glowAlpha / 3))
            end
            
            -- Название пути с эффектом масштаба
            local yOffset = -self.scaleAnim * dbtPaint.HightSource(5)
            draw.SimpleText(pathway.name, "Comfortaa Bold X40", w / 2, dbtPaint.HightSource(25) + yOffset, pathway.color, TEXT_ALIGN_CENTER)
            draw.SimpleText(pathway.nameEn, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(70) + yOffset, Color(colorText.r, colorText.g, colorText.b, 150 + self.glowAlpha), TEXT_ALIGN_CENTER)
            
            -- Линия разделитель
            draw.RoundedBox(0, dbtPaint.WidthSource(50), dbtPaint.HightSource(110), w - dbtPaint.WidthSource(100), 1, Color(pathway.color.r, pathway.color.g, pathway.color.b, 100))
            
            -- Информация о последовательностях
            local seq9 = LOTM.GetSequenceName(pathway.id, 9)
            local seq0 = LOTM.GetSequenceName(pathway.id, 0)
            
            draw.SimpleText("Seq 9: " .. seq9, "Comfortaa Light X20", w / 2, dbtPaint.HightSource(135), color_white, TEXT_ALIGN_CENTER)
            draw.SimpleText("• • •", "Comfortaa Bold X20", w / 2, dbtPaint.HightSource(165), Color(pathway.color.r, pathway.color.g, pathway.color.b, 150), TEXT_ALIGN_CENTER)
            draw.SimpleText("Seq 0: " .. seq0, "Comfortaa Light X20", w / 2, dbtPaint.HightSource(195), pathway.color, TEXT_ALIGN_CENTER)
            
            -- Иконка выбора при наведении
            if hovered then
                draw.SimpleText("►", "Comfortaa Bold X40", dbtPaint.WidthSource(20), h / 2, pathway.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
        
        pathwayCard.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            CharCreatorData.pathway = pathway.id
            CurrentStage = CreatorStage.SEQUENCE_SELECT
            dbt.f4:Close()
            open_custom_character_creator()
        end
        
        pathwayCard.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
        end
    end
end

-- ЭТАП 2: Выбор последовательности
function CreateSequenceSelection(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    if not CharCreatorData.pathway then
        CurrentStage = CreatorStage.PATHWAY_SELECT
        dbt.f4:Close()
        open_custom_character_creator()
        return
    end
    
    local pathway = LOTM.PathwaysList[CharCreatorData.pathway]
    
    -- Информация о выбранном пути
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(dbtPaint.WidthSource(100), dbtPaint.HightSource(150))
    infoPanel:SetSize(dbtPaint.WidthSource(1720), dbtPaint.HightSource(100))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(0, 0, 0, w, 3, pathway.color)
        draw.SimpleText("Выбран путь: " .. pathway.name .. " (" .. pathway.nameEn .. ")", "Comfortaa Bold X35", w / 2, h / 2, pathway.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопки выбора последовательности (9-0)
    local buttonWidth = dbtPaint.WidthSource(160)
    local buttonHeight = dbtPaint.HightSource(180)
    local spacing = dbtPaint.WidthSource(15)
    local startX = dbtPaint.WidthSource(100)
    local startY = dbtPaint.HightSource(280)
    
    for seq = 9, 0, -1 do
        local col = 9 - seq
        local xPos = startX + col * (buttonWidth + spacing)
        
        local seqButton = vgui.Create("DButton", parent)
        seqButton:SetPos(xPos, startY)
        seqButton:SetSize(buttonWidth, buttonHeight)
        seqButton:SetText("")
        
        local seqName = LOTM.GetSequenceName(CharCreatorData.pathway, seq)
        
        seqButton.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local selected = CharCreatorData.sequence == seq
            
            local bgColor = selected and Color(pathway.color.r, pathway.color.g, pathway.color.b, 100) or (hovered and Color(pathway.color.r, pathway.color.g, pathway.color.b, 50) or Color(0, 0, 0, 150))
            draw.RoundedBox(0, 0, 0, w, h, bgColor)
            
            local borderSize = (selected or hovered) and 3 or 1
            local borderColor = selected and pathway.color or (hovered and pathway.color or Color(255, 255, 255, 100))
            
            draw.RoundedBox(0, 0, 0, w, borderSize, borderColor)
            draw.RoundedBox(0, 0, h - borderSize, w, borderSize, borderColor)
            draw.RoundedBox(0, 0, 0, borderSize, h, borderColor)
            draw.RoundedBox(0, w - borderSize, 0, borderSize, h, borderColor)
            
            -- Номер последовательности
            draw.SimpleText("Seq " .. seq, "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(20), pathway.color, TEXT_ALIGN_CENTER)
            
            -- Название последовательности (многострочное)
            local wrappedText = dbtPaint.WrapText(seqName, "Comfortaa Light X18", w - dbtPaint.WidthSource(10))
            local yOffset = dbtPaint.HightSource(60)
            for i, line in ipairs(wrappedText) do
                draw.SimpleText(line, "Comfortaa Light X18", w / 2, yOffset, color_white, TEXT_ALIGN_CENTER)
                yOffset = yOffset + dbtPaint.HightSource(22)
            end
        end
        
        seqButton.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            CharCreatorData.sequence = seq
        end
        
        seqButton.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
        end
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(900))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X40", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    continueButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        CurrentStage = CreatorStage.INFO_INPUT
        dbt.f4:Close()
        open_custom_character_creator()
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 3: Ввод информации о персонаже
function CreateInfoInput(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Поле ввода имени
    local nameLabel = vgui.Create("DLabel", parent)
    nameLabel:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(250))
    nameLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    nameLabel:SetFont("Comfortaa Light X35")
    nameLabel:SetText("Имя персонажа:")
    nameLabel:SetTextColor(color_white)
    
    local nameEntry = vgui.Create("DTextEntry", parent)
    nameEntry:SetPos(dbtPaint.WidthSource(750), dbtPaint.HightSource(250))
    nameEntry:SetSize(dbtPaint.WidthSource(600), dbtPaint.HightSource(50))
    nameEntry:SetFont("Comfortaa Light X30")
    nameEntry:SetText(CharCreatorData.name)
    nameEntry:SetPlaceholderText("Введите имя персонажа")
    nameEntry.OnChange = function(self)
        CharCreatorData.name = self:GetValue()
    end
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        draw.RoundedBox(0, 0, 0, w, 2, colorOutLine)
        draw.RoundedBox(0, 0, h - 2, w, 2, colorOutLine)
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Поле ввода таланта
    local talentLabel = vgui.Create("DLabel", parent)
    talentLabel:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(350))
    talentLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    talentLabel:SetFont("Comfortaa Light X35")
    talentLabel:SetText("Талант:")
    talentLabel:SetTextColor(color_white)
    
    local talentEntry = vgui.Create("DTextEntry", parent)
    talentEntry:SetPos(dbtPaint.WidthSource(750), dbtPaint.HightSource(350))
    talentEntry:SetSize(dbtPaint.WidthSource(600), dbtPaint.HightSource(50))
    talentEntry:SetFont("Comfortaa Light X30")
    talentEntry:SetText(CharCreatorData.talent)
    talentEntry:SetPlaceholderText("Абсолютный Талант")
    talentEntry.OnChange = function(self)
        CharCreatorData.talent = self:GetValue()
    end
    talentEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        draw.RoundedBox(0, 0, 0, w, 2, colorOutLine)
        draw.RoundedBox(0, 0, h - 2, w, 2, colorOutLine)
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Информация о выбранном пути
    local pathway = LOTM.PathwaysList[CharCreatorData.pathway]
    local seqName = LOTM.GetSequenceName(CharCreatorData.pathway, CharCreatorData.sequence)
    
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(500))
    infoPanel:SetSize(dbtPaint.WidthSource(950), dbtPaint.HightSource(300))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(0, 0, 0, w, 3, pathway.color)
        
        draw.SimpleText("Путь: " .. pathway.name, "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(30), pathway.color, TEXT_ALIGN_CENTER)
        draw.SimpleText("Последовательность " .. CharCreatorData.sequence .. ": " .. seqName, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(80), color_white, TEXT_ALIGN_CENTER)
        
        draw.SimpleText("Характеристики можно будет настроить на следующем шаге", "Comfortaa Light X20", w / 2, dbtPaint.HightSource(150), colorText, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(900))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local canContinue = CharCreatorData.name ~= "" and CharCreatorData.talent ~= ""
        
        if not canContinue then
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))
            draw.SimpleText("ЗАПОЛНИТЕ ВСЕ ПОЛЯ", "Comfortaa Bold X30", w / 2, h / 2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
            draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X40", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    continueButton.DoClick = function()
        if CharCreatorData.name ~= "" and CharCreatorData.talent ~= "" then
            surface.PlaySound('ui/button_click.mp3')
            CurrentStage = CreatorStage.STATS_CONFIG
            dbt.f4:Close()
            open_custom_character_creator()
        else
            surface.PlaySound('ui/item_info_close.wav')
        end
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 4: Настройка характеристик
function CreateStatsConfig(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    local stats = {
        {name = "Здоровье", key = "maxHealth", min = 50, max = 200, step = 10},
        {name = "Голод", key = "maxHungry", min = 50, max = 200, step = 10},
        {name = "Жажда", key = "maxThird", min = 50, max = 200, step = 10},
        {name = "Сон", key = "maxSleep", min = 50, max = 200, step = 10},
        {name = "Скорость бега", key = "runSpeed", min = 150, max = 250, step = 5},
        {name = "Макс. вес (кг)", key = "maxKG", min = 10, max = 50, step = 5},
        {name = "Слотов инвентаря", key = "maxInventory", min = 6, max = 12, step = 1},
    }
    
    local yPos = dbtPaint.HightSource(200)
    
    for i, stat in ipairs(stats) do
        -- Название характеристики
        local label = vgui.Create("DLabel", parent)
        label:SetPos(dbtPaint.WidthSource(300), yPos)
        label:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
        label:SetFont("Comfortaa Light X30")
        label:SetText(stat.name .. ":")
        label:SetTextColor(color_white)
        
        -- Слайдер
        local slider = vgui.Create("DNumSlider", parent)
        slider:SetPos(dbtPaint.WidthSource(620), yPos)
        slider:SetSize(dbtPaint.WidthSource(700), dbtPaint.HightSource(40))
        slider:SetMin(stat.min)
        slider:SetMax(stat.max)
        slider:SetDecimals(0)
        slider:SetValue(CharCreatorData[stat.key])
        slider:SetText("")
        slider.OnValueChanged = function(self, value)
            CharCreatorData[stat.key] = math.Round(value / stat.step) * stat.step
        end
        
        slider.Label:SetFont("Comfortaa Light X25")
        slider.Label:SetTextColor(colorOutLine)
        slider.TextArea:SetFont("Comfortaa Light X25")
        slider.TextArea:SetTextColor(color_white)
        
        slider.Slider.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, h / 2 - 2, w, 4, Color(100, 100, 100))
        end
        
        slider.Slider.Knob.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, colorOutLine)
        end
        
        yPos = yPos + dbtPaint.HightSource(80)
    end
    
    -- Кнопка создать
    local createButton = vgui.Create("DButton", parent)
    createButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(900))
    createButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    createButton:SetText("")
    createButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200) or Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100))
        draw.SimpleText("СОЗДАТЬ ПЕРСОНАЖА", "Comfortaa Bold X35", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        
        -- Отправка данных на сервер
        net.Start("dbt.CustomChar.Create")
        net.WriteTable({
            name = CharCreatorData.name,
            absl = CharCreatorData.talent,
            lotm = {
                pathway = CharCreatorData.pathway,
                sequence = CharCreatorData.sequence,
            },
            maxHealth = CharCreatorData.maxHealth,
            maxHungry = CharCreatorData.maxHungry,
            maxThird = CharCreatorData.maxThird,
            maxSleep = CharCreatorData.maxSleep,
            runSpeed = CharCreatorData.runSpeed,
            fistsDamageString = CharCreatorData.fistsDamage,
            maxKG = CharCreatorData.maxKG,
            maxInventory = CharCreatorData.maxInventory,
        })
        net.SendToServer()
    end
    createButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- Вспомогательная функция для переноса текста
dbtPaint = dbtPaint or {}
function dbtPaint.WrapText(text, font, maxWidth)
    surface.SetFont(font)
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""
    
    for i, word in ipairs(words) do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
        local w, h = surface.GetTextSize(testLine)
        
        if w > maxWidth and currentLine ~= "" then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Обработка ответа от сервера
net.Receive("dbt.CustomChar.Create", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    
    if success then
        chat.AddText(Color(0, 255, 0), "[Кастомные персонажи] ", color_white, "Персонаж успешно создан!")
        if IsValid(dbt.f4) then
            dbt.f4:Close()
        end
        -- Сбрасываем этап для следующего создания
        CurrentStage = CreatorStage.PATHWAY_SELECT
        openseasonselect()
    else
        chat.AddText(Color(255, 0, 0), "[Ошибка] ", color_white, message)
    end
end)

print("[Custom Character Creator] UI загружен")