-- Custom Character Creator UI v3.0
-- Система создания кастомного персонажа
-- Выбор веры, роста, модели с D&D характеристиками

local bg_creator = Material("dbt/f4/f4_charselect_bg.png")
local logo = Material("dbt/f4/dbt_logo.png")
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorButtonExit = Color(250, 250, 250, 1)
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorText = Color(255, 255, 255, 100)
local colorPurple = Color(191, 30, 219)
local colorPurpleLight = Color(211, 25, 202)
local colorGold = Color(255, 215, 0)
local colorWhiteAlpha = Color(255, 255, 255, 200)
local colorGreen = Color(46, 204, 113)
local colorRed = Color(231, 76, 60)

-- Локальные фоны
local tableBG_creator = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Данные для создания персонажа
local CharCreatorData = {
    name = "",
    talent = "",
    faith = nil,        -- Вера вместо пути
    height = 1.0,       -- Рост (0.5 - 1.5)
    model = "",         -- Выбранная модель
    
    -- Характеристики (генерируются рандомно как в D&D)
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
    FAITH_SELECT = 1,    -- Выбор веры
    INFO_INPUT = 2,      -- Ввод имени и таланта
    APPEARANCE = 3,      -- Внешность (рост и модель)
    STATS_ROLL = 4,      -- Бросок характеристик
}

local CurrentStage = CreatorStage.FAITH_SELECT
local CurrentBG_Creator = nil
local SelectedFaithHover = nil
local ModelSearchQuery = ""
local FilteredModels = {}
local CurrentModelPage = 1
local ModelsPerPage = 10
local AllPlayerModels = {}

-- Список вер с описаниями
local FaithsList = {
    {
        id = 1,
        name = "Церковь Вечной Тьмы",
        nameEn = "Church of Eternal Darkness",
        color = Color(75, 0, 130),
        desc = "Поклонение древним силам, скрытым во тьме. Верующие черпают силу из теней и познают запретные знания.",
    },
    {
        id = 2,
        name = "Орден Алого Света",
        nameEn = "Order of Crimson Light",
        color = Color(220, 20, 60),
        desc = "Война и жертвоприношение - путь к истинной силе. Алый свет указывает дорогу завоевателям.",
    },
    {
        id = 3,
        name = "Культ Безумной Луны",
        nameEn = "Cult of Mad Moon",
        color = Color(138, 43, 226),
        desc = "Луна открывает врата в запретные миры. Безумие - это просветление, хаос - истинный порядок.",
    },
    {
        id = 4,
        name = "Братство Вечного Солнца",
        nameEn = "Brotherhood of Eternal Sun",
        color = Color(255, 215, 0),
        desc = "Свет солнца изгоняет тьму и дарует жизнь. Верующие несут очищение и справедливость.",
    },
    {
        id = 5,
        name = "Секта Забытых Богов",
        nameEn = "Sect of Forgotten Gods",
        color = Color(105, 105, 105),
        desc = "Древние боги не умерли, они лишь спят. Их пробуждение изменит мир навсегда.",
    },
    {
        id = 6,
        name = "Атеизм",
        nameEn = "Atheism",
        color = Color(200, 200, 200),
        desc = "Отрицание всех богов и сверхъестественного. Сила в разуме, знаниях и собственных усилиях.",
    },
}

-- Функция генерации характеристик (D&D стиль)
local function RollStats()
    local stats = {}
    stats.maxHealth = math.random(8, 15) * 10
    stats.maxHungry = math.random(8, 15) * 10
    stats.maxThird = math.random(8, 15) * 10
    stats.maxSleep = math.random(8, 15) * 10
    stats.runSpeed = math.random(36, 46) * 5
    stats.maxKG = math.random(15, 40)
    stats.maxInventory = math.random(6, 10)
    local minDmg = math.random(3, 8)
    local maxDmg = minDmg + math.random(5, 12)
    stats.fistsDamage = minDmg .. "-" .. maxDmg
    return stats
end

-- Получение списка всех моделей игроков
local function GetAllPlayerModels()
    if #AllPlayerModels > 0 then return AllPlayerModels end
    
    local models = {}
    
    -- Основные модели из player/
    for _, modelPath in ipairs(player_manager.AllValidModels()) do
        table.insert(models, modelPath)
    end
    
    -- Дополнительные популярные модели
    local additionalModels = {
        -- HL2
        "models/player/alyx.mdl",
        "models/player/barney.mdl",
        "models/player/breen.mdl",
        "models/player/eli.mdl",
        "models/player/gman_high.mdl",
        "models/player/kleiner.mdl",
        "models/player/magnusson.mdl",
        "models/player/mossman.mdl",
        "models/player/monk.mdl",
        
        -- Combine
        "models/player/combine_soldier.mdl",
        "models/player/combine_soldier_prisonguard.mdl",
        "models/player/combine_super_soldier.mdl",
        "models/player/police.mdl",
        "models/player/police_fem.mdl",
        
        -- Citizens
        "models/player/group01/female_01.mdl",
        "models/player/group01/female_02.mdl",
        "models/player/group01/female_03.mdl",
        "models/player/group01/female_04.mdl",
        "models/player/group01/female_06.mdl",
        "models/player/group01/male_01.mdl",
        "models/player/group01/male_02.mdl",
        "models/player/group01/male_03.mdl",
        "models/player/group01/male_04.mdl",
        "models/player/group01/male_05.mdl",
        "models/player/group01/male_06.mdl",
        "models/player/group01/male_07.mdl",
        "models/player/group01/male_08.mdl",
        "models/player/group01/male_09.mdl",
        
        -- Refugees
        "models/player/group02/male_02.mdl",
        "models/player/group02/male_04.mdl",
        "models/player/group02/male_06.mdl",
        "models/player/group02/male_08.mdl",
        
        -- Medics
        "models/player/group03/female_01.mdl",
        "models/player/group03/female_02.mdl",
        "models/player/group03/female_03.mdl",
        "models/player/group03/female_04.mdl",
        "models/player/group03/female_06.mdl",
        "models/player/group03/male_01.mdl",
        "models/player/group03/male_02.mdl",
        "models/player/group03/male_03.mdl",
        "models/player/group03/male_04.mdl",
        "models/player/group03/male_05.mdl",
        "models/player/group03/male_06.mdl",
        "models/player/group03/male_07.mdl",
        "models/player/group03/male_08.mdl",
        "models/player/group03/male_09.mdl",
    }
    
    for _, model in ipairs(additionalModels) do
        if not table.HasValue(models, model) and file.Exists(model, "GAME") then
            table.insert(models, model)
        end
    end
    
    -- Сортировка по алфавиту
    table.sort(models)
    
    AllPlayerModels = models
    return models
end

-- Фильтрация моделей по поисковому запросу
local function FilterModels(query)
    local allModels = GetAllPlayerModels()
    
    if query == "" then
        return allModels
    end
    
    local filtered = {}
    query = string.lower(query)
    
    for _, model in ipairs(allModels) do
        if string.find(string.lower(model), query, 1, true) then
            table.insert(filtered, model)
        end
    end
    
    return filtered
end

-- Функция отрисовки границы
local function draw_border(w, h, color, size)
    size = size or 1
    draw.RoundedBox(0, 0, 0, w, size, color)
    draw.RoundedBox(0, 0, size, h, color)
    draw.RoundedBox(0, h - size, w, size, color)
    draw.RoundedBox(0, w - size, 0, size, h, color)
end

-- Функция открытия создателя персонажа
function open_custom_character_creator()
    if IsValid(dbt.f4) then dbt.f4:Close() end
    
    local scrw, scrh = ScrW(), ScrH()
    local a = math.random(1, 3)
    CurrentBG_Creator = tableBG_creator[a]
    
    -- Сброс данных только при первом открытии
    if CurrentStage == CreatorStage.FAITH_SELECT then
        CharCreatorData = {
            name = "",
            talent = "",
            faith = nil,
            height = 1.0,
            model = "models/player/group01/male_01.mdl",
            maxHealth = 100,
            maxHungry = 100,
            maxThird = 100,
            maxSleep = 100,
            runSpeed = 195,
            fistsDamage = "5-10",
            maxKG = 20,
            maxInventory = 8,
        }
        SelectedFaithHover = nil
        ModelSearchQuery = ""
        CurrentModelPage = 1
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
            if CurrentStage == CreatorStage.FAITH_SELECT then
                self:Close()
                CurrentStage = CreatorStage.FAITH_SELECT
                openseasonselect()
            else
                CurrentStage = CurrentStage - 1
                self:Close()
                open_custom_character_creator()
            end
            return true
        end
    end
    
    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG_Creator, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_creator, 0, 0, w, h)
        
        -- Логотип
        dbtPaint.DrawRect(logo, w / 2 - dbtPaint.WidthSource(298), dbtPaint.HightSource(30), dbtPaint.WidthSource(596), dbtPaint.HightSource(241))
        
        -- Заголовок
        local title = "СОЗДАНИЕ ПЕРСОНАЖА"
        local titleY = dbtPaint.HightSource(285)
        
        if CurrentStage == CreatorStage.FAITH_SELECT then
            title = "ВЫБЕРИТЕ ВЕРУ"
        elseif CurrentStage == CreatorStage.INFO_INPUT then
            title = "ИНФОРМАЦИЯ О ПЕРСОНАЖЕ"
        elseif CurrentStage == CreatorStage.APPEARANCE then
            title = "ВНЕШНОСТЬ ПЕРСОНАЖА"
        elseif CurrentStage == CreatorStage.STATS_ROLL then
            title = "ХАРАКТЕРИСТИКИ"
        end
        
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2 + 2, titleY + 2, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2, titleY, colorPurpleLight, TEXT_ALIGN_CENTER)
    end
    
    CreateStageContent(dbt.f4)
    
    -- Кнопка назад
    local backButton = vgui.Create("DButton", dbt.f4)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.ColorBorder = colorOutLine
    backButton.ColorBorder.a = 0
    
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        if CurrentStage == CreatorStage.FAITH_SELECT then
            dbt.f4:Close()
            CurrentStage = CreatorStage.FAITH_SELECT
            openseasonselect()
        else
            CurrentStage = CurrentStage - 1
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
    
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    backButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
end

-- Создание контента для текущего этапа
function CreateStageContent(parent)
    if CurrentStage == CreatorStage.FAITH_SELECT then
        CreateFaithSelection(parent)
    elseif CurrentStage == CreatorStage.INFO_INPUT then
        CreateInfoInput(parent)
    elseif CurrentStage == CreatorStage.APPEARANCE then
        CreateAppearance(parent)
    elseif CurrentStage == CreatorStage.STATS_ROLL then
        CreateStatsRoll(parent)
    end
end

-- ЭТАП 1: Выбор веры
function CreateFaithSelection(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Панель с верами (левая сторона)
    local faithsPanel = vgui.Create("DScrollPanel", parent)
    faithsPanel:SetPos(dbtPaint.WidthSource(60), dbtPaint.HightSource(360))
    faithsPanel:SetSize(dbtPaint.WidthSource(450), dbtPaint.HightSource(560))
    
    local sbar = faithsPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(5))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    -- Панель описания веры (правая сторона)
    local descPanel = vgui.Create("DPanel", parent)
    descPanel:SetPos(dbtPaint.WidthSource(540), dbtPaint.HightSource(360))
    descPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(560))
    descPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        draw_border(w, h, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100), 2)
        
        if SelectedFaithHover then
            local faith = FaithsList[SelectedFaithHover]
            
            -- Заголовок
            draw.SimpleText(faith.name, "Comfortaa Bold X50", w / 2, dbtPaint.HightSource(60), faith.color, TEXT_ALIGN_CENTER)
            draw.SimpleText(faith.nameEn, "Comfortaa Light X30", w / 2, dbtPaint.HightSource(120), colorText, TEXT_ALIGN_CENTER)
            
            -- Линия
            draw.RoundedBox(0, dbtPaint.WidthSource(100), dbtPaint.HightSource(170), w - dbtPaint.WidthSource(200), 2, faith.color)
            
            -- Описание
            local wrappedDesc = dbtPaint.WrapText(faith.desc, "Comfortaa Light X25", w - dbtPaint.WidthSource(120))
            local yOffset = dbtPaint.HightSource(230)
            for i, line in ipairs(wrappedDesc) do
                draw.SimpleText(line, "Comfortaa Light X25", w / 2, yOffset, colorWhiteAlpha, TEXT_ALIGN_CENTER)
                yOffset = yOffset + dbtPaint.HightSource(35)
            end
        else
            draw.SimpleText("Наведите на веру для просмотра описания", "Comfortaa Light X30", w / 2, h / 2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Создание кнопок вер
    local buttonHeight = dbtPaint.HightSource(75)
    local spacing = dbtPaint.HightSource(10)
    
    for i, faith in ipairs(FaithsList) do
        local faithButton = vgui.Create("DButton", faithsPanel)
        faithButton:SetPos(0, (i - 1) * (buttonHeight + spacing))
        faithButton:SetSize(dbtPaint.WidthSource(430), buttonHeight)
        faithButton:SetText("")
        
        faithButton.ColorBorder = Color(faith.color.r, faith.color.g, faith.color.b, 100)
        faithButton.glowAlpha = 0
        
        faithButton.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            
            if hovered then
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 60)
                self.ColorBorder.a = Lerp(FrameTime() * 8, self.ColorBorder.a, 255)
            else
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 0)
                self.ColorBorder.a = Lerp(FrameTime() * 8, self.ColorBorder.a, 100)
            end
            
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
            
            if self.glowAlpha > 0 then
                draw.RoundedBox(0, 0, 0, w, h, Color(faith.color.r, faith.color.g, faith.color.b, self.glowAlpha))
            end
            
            draw_border(w, h, self.ColorBorder, 2)
            draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, self.ColorBorder)
            
            draw.SimpleText(faith.name, "Comfortaa Bold X28", dbtPaint.WidthSource(20), dbtPaint.HightSource(15), faith.color, TEXT_ALIGN_LEFT)
            draw.SimpleText(faith.nameEn, "Comfortaa Light X18", dbtPaint.WidthSource(20), dbtPaint.HightSource(48), colorText, TEXT_ALIGN_LEFT)
            
            if hovered then
                draw.SimpleText("►", "Comfortaa Bold X35", w - dbtPaint.WidthSource(30), h / 2 - dbtPaint.HightSource(15), faith.color, TEXT_ALIGN_RIGHT)
            end
        end
        
        faithButton.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
            SelectedFaithHover = i
        end
        
        faithButton.OnCursorExited = function()
            SelectedFaithHover = nil
        end
        
        faithButton.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            CharCreatorData.faith = faith.id
            CurrentStage = CreatorStage.INFO_INPUT
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
end

-- ЭТАП 2: Ввод информации
function CreateInfoInput(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    local faith = FaithsList[CharCreatorData.faith]
    
    -- Информационная панель о выбранной вере
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(370))
    infoPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(120))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw_border(w, h, faith.color, 3)
        
        draw.SimpleText("Выбрана вера: " .. faith.name, "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(35), faith.color, TEXT_ALIGN_CENTER)
        draw.SimpleText(faith.nameEn, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(80), colorWhiteAlpha, TEXT_ALIGN_CENTER)
    end
    
    -- Поля ввода
    local inputsPanel = vgui.Create("DPanel", parent)
    inputsPanel:SetPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(520))
    inputsPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(300))
    inputsPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw_border(w, h, colorOutLine, 2)
    end
    
    -- Имя
    local nameLabel = vgui.Create("DLabel", inputsPanel)
    nameLabel:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(40))
    nameLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    nameLabel:SetFont("Comfortaa Light X30")
    nameLabel:SetText("Имя персонажа:")
    nameLabel:SetTextColor(colorGold)
    
    local nameEntry = vgui.Create("DTextEntry", inputsPanel)
    nameEntry:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(35))
    nameEntry:SetSize(dbtPaint.WidthSource(850), dbtPaint.HightSource(55))
    nameEntry:SetFont("Comfortaa Light X28")
    nameEntry:SetText(CharCreatorData.name)
    nameEntry:SetPlaceholderText("Введите имя...")
    nameEntry.OnChange = function(self) CharCreatorData.name = self:GetValue() end
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 220))
        draw_border(w, h, colorPurpleLight, 2)
        
        -- Внутренняя тень
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(0, 0, 0, 80))
        
        self:DrawTextEntryText(color_white, colorPurpleLight, color_white)
    end
    
    -- Талант
    local talentLabel = vgui.Create("DLabel", inputsPanel)
    talentLabel:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(140))
    talentLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    talentLabel:SetFont("Comfortaa Light X30")
    talentLabel:SetText("Абсолютный талант:")
    talentLabel:SetTextColor(colorGold)
    
    local talentEntry = vgui.Create("DTextEntry", inputsPanel)
    talentEntry:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(135))
    talentEntry:SetSize(dbtPaint.WidthSource(850), dbtPaint.HightSource(120))
    talentEntry:SetFont("Comfortaa Light X25")
    talentEntry:SetText(CharCreatorData.talent)
    talentEntry:SetPlaceholderText("Опишите уникальный талант персонажа...")
    talentEntry:SetMultiline(true)
    talentEntry.OnChange = function(self) CharCreatorData.talent = self:GetValue() end
    talentEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 220))
        draw_border(w, h, colorPurpleLight, 2)
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(0, 0, 0, 80))
        self:DrawTextEntryText(color_white, colorPurpleLight, color_white)
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(870))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.ColorBorder = colorOutLine
    continueButton.ColorBorder.a = 0
    
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local canContinue = CharCreatorData.name ~= "" and CharCreatorData.talent ~= ""
        
        if not canContinue then
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))
            draw.SimpleText("ЗАПОЛНИТЕ ВСЕ ПОЛЯ", "Comfortaa Bold X28", w / 2, h / 2 - dbtPaint.HightSource(10), Color(150, 150, 150), TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
            
            if hovered then
                self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
                draw_border(w, h, self.ColorBorder)
            else
                self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
            end
            
            draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X38", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
        end
    end
    
    continueButton.DoClick = function()
        if CharCreatorData.name ~= "" and CharCreatorData.talent ~= "" then
            surface.PlaySound('ui/button_click.mp3')
            CurrentStage = CreatorStage.APPEARANCE
            dbt.f4:Close()
            open_custom_character_creator()
        else
            surface.PlaySound('ui/item_info_close.wav')
        end
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 3: Внешность (рост и модель)
function CreateAppearance(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Левая панель: настройка роста и превью
    local leftPanel = vgui.Create("DPanel", parent)
    leftPanel:SetPos(dbtPaint.WidthSource(60), dbtPaint.HightSource(360))
    leftPanel:SetSize(dbtPaint.WidthSource(450), dbtPaint.HightSource(560))
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw_border(w, h, colorOutLine, 2)
        
        draw.SimpleText("РОСТ ПЕРСОНАЖА", "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(20), colorGold, TEXT_ALIGN_CENTER)
        
        -- Отображение текущего роста
        local heightPercent = math.Round((CharCreatorData.height - 0.5) / 1.0 * 100)
        local heightText = string.format("%.2f (%.0f%%)", CharCreatorData.height, heightPercent)
        draw.SimpleText(heightText, "Comfortaa Bold X40", w / 2, dbtPaint.HightSource(120), colorWhiteAlpha, TEXT_ALIGN_CENTER)
    end
    
    -- Слайдер роста
    local heightSlider = vgui.Create("DNumSlider", leftPanel)
    heightSlider:SetPos(dbtPaint.WidthSource(30), dbtPaint.HightSource(180))
    heightSlider:SetSize(dbtPaint.WidthSource(390), dbtPaint.HightSource(50))
    heightSlider:SetMin(0.5)
    heightSlider:SetMax(1.5)
    heightSlider:SetDecimals(2)
    heightSlider:SetValue(CharCreatorData.height)
    heightSlider:SetText("")
    heightSlider.OnValueChanged = function(self, value)
        CharCreatorData.height = value
    end
    heightSlider.Label:SetVisible(false)
    heightSlider.TextArea:SetVisible(false)
    heightSlider.Slider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, h / 2 - 3, w, 6, Color(50, 50, 50))
        draw.RoundedBox(4, 0, h / 2 - 3, w * self:GetSlideX(), 6, colorPurpleLight)
    end
    heightSlider.Slider.Knob.Paint = function(self, w, h)
        draw.RoundedBox(w / 2, 0, 0, w, h, colorGold)
    end
    
    -- Model preview (optional)
    local modelPreview = vgui.Create("DModelPanel", leftPanel)
    modelPreview:SetPos(dbtPaint.WidthSource(75), dbtPaint.HightSource(250))
    modelPreview:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(280))
    modelPreview:SetModel(CharCreatorData.model)
    modelPreview:SetFOV(50)
    modelPreview.LayoutEntity = function(self, ent)
        ent:SetModelScale(CharCreatorData.height, 0)
        self:RunAnimation()
    end
    local eyepos = modelPreview.Entity:GetBonePosition(modelPreview.Entity:LookupBone("ValveBiped.Bip01_Head1") or 0)
    modelPreview:SetLookAt(eyepos)
    modelPreview:SetCamPos(eyepos - Vector(-40, 0, 0))
    modelPreview.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw_border(w, h, colorPurpleLight, 1)
    end
    
    -- Правая панель: выбор модели с 2 вариантами поиска
    local rightPanel = vgui.Create("DPanel", parent)
    rightPanel:SetPos(dbtPaint.WidthSource(540), dbtPaint.HightSource(360))
    rightPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(560))
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw_border(w, h, colorOutLine, 2)
        
        draw.SimpleText("ВЫБОР МОДЕЛИ", "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(20), colorGold, TEXT_ALIGN_CENTER)
    end
    
    -- Поисковая строка 1 (по имени файла)
    local searchLabel1 = vgui.Create("DLabel", rightPanel)
    searchLabel1:SetPos(dbtPaint.WidthSource(30), dbtPaint.HightSource(70))
    searchLabel1:SetSize(dbtPaint.WidthSource(200), dbtPaint.HightSource(30))
    searchLabel1:SetFont("Comfortaa Light X22")
    searchLabel1:SetText("Поиск по файлу:")
    searchLabel1:SetTextColor(color_white)
    
    local searchEntry1 = vgui.Create("DTextEntry", rightPanel)
    searchEntry1:SetPos(dbtPaint.WidthSource(250), dbtPaint.HightSource(65))
    searchEntry1:SetSize(dbtPaint.WidthSource(500), dbtPaint.HightSource(40))
    searchEntry1:SetFont("Comfortaa Light X22")
    searchEntry1:SetPlaceholderText("Например: male, female, combine...")
    searchEntry1.OnChange = function(self)
        ModelSearchQuery = self:GetValue()
        FilteredModels = FilterModels(ModelSearchQuery)
        CurrentModelPage = 1
    end
    searchEntry1.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 220))
        draw_border(w, h, colorPurpleLight, 1)
        self:DrawTextEntryText(color_white, colorPurpleLight, color_white)
    end
    
    -- Поисковая строка 2 (полный путь .mdl)
    local searchLabel2 = vgui.Create("DLabel", rightPanel)
    searchLabel2:SetPos(dbtPaint.WidthSource(780), dbtPaint.HightSource(70))
    searchLabel2:SetSize(dbtPaint.WidthSource(200), dbtPaint.HightSource(30))
    searchLabel2:SetFont("Comfortaa Light X22")
    searchLabel2:SetText("Полный путь:")
    searchLabel2:SetTextColor(color_white)
    
    local searchEntry2 = vgui.Create("DTextEntry", rightPanel)
    searchEntry2:SetPos(dbtPaint.WidthSource(920), dbtPaint.HightSource(65))
    searchEntry2:SetSize(dbtPaint.WidthSource(360), dbtPaint.HightSource(40))
    searchEntry2:SetFont("Comfortaa Light X20")
    searchEntry2:SetPlaceholderText("models/player/...")
    searchEntry2.OnChange = function(self)
        local mdlPath = self:GetValue()
        if mdlPath ~= "" and string.EndsWith(string.lower(mdlPath), ".mdl") then
            if file.Exists(mdlPath, "GAME") then
                CharCreatorData.model = mdlPath
                modelPreview:SetModel(mdlPath)
                surface.PlaySound('ui/button_click.mp3')
            end
        end
    end
    searchEntry2.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 220))
        draw_border(w, h, colorGreen, 1)
        self:DrawTextEntryText(color_white, colorGreen, color_white)
    end
    
    -- Список моделей
    local modelsList = vgui.Create("DScrollPanel", rightPanel)
    modelsList:SetPos(dbtPaint.WidthSource(30), dbtPaint.HightSource(125))
    modelsList:SetSize(dbtPaint.WidthSource(1260), dbtPaint.HightSource(390))
    
    local sbar = modelsList:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(5))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    -- Функция обновления списка моделей
    local function UpdateModelsList()
        modelsList:Clear()
        FilteredModels = FilterModels(ModelSearchQuery)
        
        local startIndex = (CurrentModelPage - 1) * ModelsPerPage + 1
        local endIndex = math.min(startIndex + ModelsPerPage - 1, #FilteredModels)
        
        for i = startIndex, endIndex do
            local model = FilteredModels[i]
            local modelButton = vgui.Create("DButton", modelsList)
            modelButton:SetPos(0, (i - startIndex) * (dbtPaint.HightSource(45) + dbtPaint.HightSource(5)))
            modelButton:SetSize(dbtPaint.WidthSource(1240), dbtPaint.HightSource(45))
            modelButton:SetText("")
            
            modelButton.Paint = function(self, w, h)
                local hovered = self:IsHovered()
                local selected = CharCreatorData.model == model
                
                if selected then
                    draw.RoundedBox(4, 0, 0, w, h, Color(colorGreen.r, colorGreen.g, colorGreen.b, 100))
                elseif hovered then
                    draw.RoundedBox(4, 0, 0, w, h, Color(colorPurpleLight.r, colorPurpleLight.g, colorPurpleLight.b, 80))
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 120))
                end
                
                draw_border(w, h, selected and colorGreen or (hovered and colorPurpleLight or Color(60, 60, 60)), 1)
                
                -- Укороченный путь для отображения
                local displayName = string.gsub(model, "models/player/", "")
                draw.SimpleText(displayName, "Comfortaa Light X20", dbtPaint.WidthSource(15), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                if selected then
                    draw.SimpleText("✓", "Comfortaa Bold X30", w - dbtPaint.WidthSource(25), h / 2, colorGreen, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            
            modelButton.DoClick = function()
                CharCreatorData.model = model
                modelPreview:SetModel(model)
                surface.PlaySound('ui/button_click.mp3')
            end
            
            modelButton.OnCursorEntered = function()
                surface.PlaySound('ui/ui_but/ui_hover.wav')
            end
        end
        
        -- Информация о пагинации
        if #FilteredModels > ModelsPerPage then
            local totalPages = math.ceil(#FilteredModels / ModelsPerPage)
            local paginationInfo = vgui.Create("DLabel", modelsList)
            paginationInfo:SetPos(0, (endIndex - startIndex + 1) * (dbtPaint.HightSource(45) + dbtPaint.HightSource(5)) + dbtPaint.HightSource(10))
            paginationInfo:SetSize(dbtPaint.WidthSource(1240), dbtPaint.HightSource(30))
            paginationInfo:SetFont("Comfortaa Light X20")
            paginationInfo:SetText(string.format("Страница %d из %d (всего моделей: %d)", CurrentModelPage, totalPages, #FilteredModels))
            paginationInfo:SetTextColor(colorText)
            paginationInfo:SetContentAlignment(5)
        end
    end
    
    UpdateModelsList()
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(950))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.ColorBorder = colorOutLine
    continueButton.ColorBorder.a = 0
    
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X38", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
    
    continueButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local stats = RollStats()
        for k, v in pairs(stats) do
            CharCreatorData[k] = v
        end
        CurrentStage = CreatorStage.STATS_ROLL
        dbt.f4:Close()
        open_custom_character_creator()
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 4: Бросок характеристик
function CreateStatsRoll(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    local materialIconHealth = Material("dbt/f4/stats_icons/stat_hp.png")
    local materialIconFood = Material("dbt/f4/stats_icons/stat_food.png")
    local materialIconWater = Material("dbt/f4/stats_icons/stat_water.png")
    local materialIconSleep = Material("dbt/f4/stats_icons/stat_sleep.png")
    local materialIconSpeed = Material("dbt/f4/stats_icons/stat_speed.png")
    local materialIconPower = Material("dbt/f4/stats_icons/stat_power.png")
    local materialIconWeight = Material("dbt/f4/stats_icons/stat_weight.png")
    local materialIconSlots = Material("dbt/f4/stats_icons/stat_slots.png")
    
    local stats = {
        {name = "Здоровье", key = "maxHealth", icon = materialIconHealth},
        {name = "Голод", key = "maxHungry", icon = materialIconFood},
        {name = "Жажда", key = "maxThird", icon = materialIconWater},
        {name = "Сон", key = "maxSleep", icon = materialIconSleep},
        {name = "Скорость", key = "runSpeed", icon = materialIconSpeed},
        {name = "Урон кулаками", key = "fistsDamage", icon = materialIconPower},
        {name = "Макс. вес (кг)", key = "maxKG", icon = materialIconWeight},
        {name = "Слотов инвентаря", key = "maxInventory", icon = materialIconSlots},
    }
    
    local statsPanel = vgui.Create("DPanel", parent)
    statsPanel:SetPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(370))
    statsPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(450))
    statsPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw_border(w, h, colorOutLine, 2)
        
        draw.SimpleText("РЕЗУЛЬТАТ БРОСКА", "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(20), colorPurpleLight, TEXT_ALIGN_CENTER)
        
        local yPos = dbtPaint.HightSource(80)
        local leftX = dbtPaint.WidthSource(100)
        local rightX = dbtPaint.WidthSource(700)
        
        for i, stat in ipairs(stats) do
            local xPos = (i <= 4) and leftX or rightX
            local currentY = yPos + ((i <= 4) and (i - 1) or (i - 5)) * dbtPaint.HightSource(85)
            
            if stat.icon then
                dbtPaint.DrawRect(stat.icon, xPos, currentY, stat.icon:Width(), stat.icon:Height())
            end
            
            local value = tostring(CharCreatorData[stat.key])
            draw.SimpleText(value, "Comfortaa Light X35", xPos + dbtPaint.WidthSource(50), currentY, color_white, TEXT_ALIGN_LEFT)
        end
    end
    
    local rerollButton = vgui.Create("DButton", parent)
    rerollButton:SetPos(dbtPaint.WidthSource(610), dbtPaint.HightSource(870))
    rerollButton:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(70))
    rerollButton:SetText("")
    rerollButton.ColorBorder = colorPurpleLight
    rerollButton.ColorBorder.a = 0
    
    rerollButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("🎲 ПЕРЕБРОСИТЬ", "Comfortaa Bold X32", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
    
    rerollButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local stats = RollStats()
        for k, v in pairs(stats) do
            CharCreatorData[k] = v
        end
        dbt.f4:Close()
        open_custom_character_creator()
    end
    rerollButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    local acceptButton = vgui.Create("DButton", parent)
    acceptButton:SetPos(dbtPaint.WidthSource(930), dbtPaint.HightSource(870))
    acceptButton:SetSize(dbtPaint.WidthSource(350), dbtPaint.HightSource(70))
    acceptButton:SetText("")
    acceptButton.ColorBorder = colorOutLine
    acceptButton.ColorBorder.a = 0
    
    acceptButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200) or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, Color(255, 255, 255, 255), 2)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("СОЗДАТЬ ПЕРСОНАЖА", "Comfortaa Bold X28", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
    
    acceptButton.DoClick = function()
        surface.PlaySound('ui/character_menu.mp3')
        
        net.Start("dbt.CustomChar.Create")
        net.WriteTable({
            name = CharCreatorData.name,
            absl = CharCreatorData.talent,
            faith = CharCreatorData.faith,
            height = CharCreatorData.height,
            model = CharCreatorData.model,
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
    acceptButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

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

net.Receive("dbt.CustomChar.Create", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    
    if success then
        chat.AddText(Color(0, 255, 0), "[Кастомные персонажи] ", color_white, "Персонаж успешно создан!")
        if IsValid(dbt.f4) then
            dbt.f4:Close()
        end
        CurrentStage = CreatorStage.FAITH_SELECT
        openseasonselect()
    else
        chat.AddText(Color(255, 0, 0), "[Ошибка] ", color_white, message)
    end
end)

print("[Custom Character Creator] v3.0 загружен - Выбор веры, роста, модели + D&D система")