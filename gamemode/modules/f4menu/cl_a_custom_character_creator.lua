-- Custom Character Creator UI v3.2
-- Упрощённая версия с материалами иконок

local bg_creator = Material("dbt/f4/f4_charselect_bg.png")
local logo = Material("dbt/f4/dbt_logo.png")

-- Цвета
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorText = Color(255, 255, 255, 200)
local colorGold = Color(255, 215, 0)
local colorGreen = Color(46, 204, 113)

-- Фоны
local tableBG_creator = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Данные персонажа
local CharCreatorData = {
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

-- Этапы
local CreatorStage = {
    FAITH_SELECT = 1,
    INFO_INPUT = 2,
    APPEARANCE = 3,
    STATS_ROLL = 4,
}

local CurrentStage = CreatorStage.FAITH_SELECT
local CurrentBG_Creator = nil
local SelectedFaithHover = nil
local ModelSearchQuery = ""
local AllPlayerModels = {}

-- Список вер
local FaithsList = {
    {id = 1, name = "Церковь Вечной Тьмы", nameEn = "Church of Eternal Darkness", color = Color(75, 0, 130),
        desc = "Поклонение древним силам тьмы. Черпайте силу из теней и познавайте запретные знания."},
    {id = 2, name = "Орден Алого Света", nameEn = "Order of Crimson Light", color = Color(220, 20, 60),
        desc = "Война и жертвоприношение - путь к истинной силе. Алый свет указывает дорогу завоевателям."},
    {id = 3, name = "Культ Безумной Луны", nameEn = "Cult of Mad Moon", color = Color(138, 43, 226),
        desc = "Луна открывает врата в запретные миры. Безумие - это просветление, хаос - истинный порядок."},
    {id = 4, name = "Братство Вечного Солнца", nameEn = "Brotherhood of Eternal Sun", color = Color(255, 215, 0),
        desc = "Свет солнца изгоняет тьму и дарует жизнь. Верующие несут очищение и справедливость."},
    {id = 5, name = "Секта Забытых Богов", nameEn = "Sect of Forgotten Gods", color = Color(105, 105, 105),
        desc = "Древние боги не умерли, они лишь спят. Их пробуждение изменит мир навсегда."},
    {id = 6, name = "Атеизм", nameEn = "Atheism", color = Color(200, 200, 200),
        desc = "Отрицание всех богов. Сила в разуме, знаниях и собственных усилиях."},
}

-- Генерация характеристик
local function RollStats()
    return {
        maxHealth = math.random(8, 15) * 10,
        maxHungry = math.random(8, 15) * 10,
        maxThird = math.random(8, 15) * 10,
        maxSleep = math.random(8, 15) * 10,
        runSpeed = math.random(36, 46) * 5,
        maxKG = math.random(15, 40),
        maxInventory = math.random(6, 10),
        fistsDamage = math.random(3, 8) .. "-" .. math.random(10, 20)
    }
end

-- Получение списка моделей
local function GetAllPlayerModels()
    if #AllPlayerModels > 0 then return AllPlayerModels end
    
    local models = {}
    
    -- Стандартные модели
    for _, modelPath in ipairs(player_manager.AllValidModels()) do
        if not table.HasValue(models, modelPath) then
            table.insert(models, modelPath)
        end
    end
    
    -- Дополнительные популярные модели
    local additional = {
        "models/player/alyx.mdl",
        "models/player/barney.mdl",
        "models/player/breen.mdl",
        "models/player/combine_soldier.mdl",
        "models/player/police.mdl",
    }
    
    for _, model in ipairs(additional) do
        if not table.HasValue(models, model) and file.Exists(model, "GAME") then
            table.insert(models, model)
        end
    end
    
    table.sort(models)
    AllPlayerModels = models
    return models
end

-- Фильтрация моделей
local function FilterModels(query)
    local allModels = GetAllPlayerModels()
    if query == "" then return allModels end
    
    local filtered = {}
    query = string.lower(query)
    
    for _, model in ipairs(allModels) do
        if string.find(string.lower(model), query, 1, true) then
            table.insert(filtered, model)
        end
    end
    
    return filtered
end

-- Главная функция
function open_custom_character_creator()
    if IsValid(dbt.f4) then dbt.f4:Close() end
    
    local scrw, scrh = ScrW(), ScrH()
    CurrentBG_Creator = tableBG_creator[math.random(1, 3)]
    
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
    end
    
    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton(false)
    dbt.f4:MakePopup()
    
    dbt.f4.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            if CurrentStage == CreatorStage.FAITH_SELECT then
                self:Close()
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
        dbtPaint.DrawRect(logo, w / 2 - dbtPaint.WidthSource(298), dbtPaint.HightSource(30), dbtPaint.WidthSource(596), dbtPaint.HightSource(241))
        
        local titles = {
            [CreatorStage.FAITH_SELECT] = "ВЫБЕРИТЕ ВЕРУ",
            [CreatorStage.INFO_INPUT] = "ИНФОРМАЦИЯ О ПЕРСОНАЖЕ",
            [CreatorStage.APPEARANCE] = "ВНЕШНОСТЬ ПЕРСОНАЖА",
            [CreatorStage.STATS_ROLL] = "ХАРАКТЕРИСТИКИ"
        }
        
        local title = titles[CurrentStage] or "СОЗДАНИЕ ПЕРСОНАЖА"
        local titleY = dbtPaint.HightSource(285)
        
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2 + 2, titleY + 2, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2, titleY, colorOutLine, TEXT_ALIGN_CENTER)
    end
    
    CreateStageContent(dbt.f4)
    
    -- Кнопка назад
    local backButton = vgui.Create("DButton", dbt.f4)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        if CurrentStage == CreatorStage.FAITH_SELECT then
            dbt.f4:Close()
            openseasonselect()
        else
            CurrentStage = CurrentStage - 1
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and colorButtonActive or colorButtonInactive)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
end

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
    local faithsPanel = vgui.Create("DScrollPanel", parent)
    faithsPanel:SetPos(dbtPaint.WidthSource(60), dbtPaint.HightSource(360))
    faithsPanel:SetSize(dbtPaint.WidthSource(450), dbtPaint.HightSource(560))
    
    local sbar = faithsPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(5))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    local descPanel = vgui.Create("DPanel", parent)
    descPanel:SetPos(dbtPaint.WidthSource(540), dbtPaint.HightSource(360))
    descPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(560))
    descPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        
        if SelectedFaithHover then
            local faith = FaithsList[SelectedFaithHover]
            draw.SimpleText(faith.name, "Comfortaa Bold X50", w / 2, dbtPaint.HightSource(80), faith.color, TEXT_ALIGN_CENTER)
            draw.SimpleText(faith.nameEn, "Comfortaa Light X30", w / 2, dbtPaint.HightSource(140), colorText, TEXT_ALIGN_CENTER)
            
            local wrappedDesc = dbtPaint.WrapText(faith.desc, "Comfortaa Light X25", w - dbtPaint.WidthSource(100))
            local yOffset = dbtPaint.HightSource(220)
            for _, line in ipairs(wrappedDesc) do
                draw.SimpleText(line, "Comfortaa Light X25", w / 2, yOffset, color_white, TEXT_ALIGN_CENTER)
                yOffset = yOffset + dbtPaint.HightSource(35)
            end
        else
            draw.SimpleText("Наведите на веру для просмотра описания", "Comfortaa Light X30", w / 2, h / 2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    for i, faith in ipairs(FaithsList) do
        local btn = vgui.Create("DButton", faithsPanel)
        btn:SetPos(0, (i - 1) * dbtPaint.HightSource(85))
        btn:SetSize(dbtPaint.WidthSource(430), dbtPaint.HightSource(75))
        btn:SetText("")
        
        btn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
            if hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(faith.color.r, faith.color.g, faith.color.b, 40))
            end
            draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, faith.color)
            draw.SimpleText(faith.name, "Comfortaa Bold X28", dbtPaint.WidthSource(20), dbtPaint.HightSource(15), faith.color, TEXT_ALIGN_LEFT)
            draw.SimpleText(faith.nameEn, "Comfortaa Light X18", dbtPaint.WidthSource(20), dbtPaint.HightSource(48), colorText, TEXT_ALIGN_LEFT)
        end
        
        btn.OnCursorEntered = function() SelectedFaithHover = i surface.PlaySound('ui/ui_but/ui_hover.wav') end
        btn.OnCursorExited = function() SelectedFaithHover = nil end
        btn.DoClick = function()
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
    local faith = FaithsList[CharCreatorData.faith]
    
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(370))
    infoPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(100))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.SimpleText("Выбрана вера: " .. faith.name, "Comfortaa Bold X35", w / 2, h / 2, faith.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Имя
    local nameLabel = vgui.Create("DLabel", parent)
    nameLabel:SetPos(dbtPaint.WidthSource(350), dbtPaint.HightSource(520))
    nameLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    nameLabel:SetFont("Comfortaa Light X30")
    nameLabel:SetText("Имя персонажа:")
    nameLabel:SetTextColor(colorGold)
    
    local nameEntry = vgui.Create("DTextEntry", parent)
    nameEntry:SetPos(dbtPaint.WidthSource(680), dbtPaint.HightSource(515))
    nameEntry:SetSize(dbtPaint.WidthSource(850), dbtPaint.HightSource(50))
    nameEntry:SetFont("Comfortaa Light X28")
    nameEntry:SetText(CharCreatorData.name)
    nameEntry:SetPlaceholderText("Введите имя...")
    nameEntry.OnChange = function(self) CharCreatorData.name = self:GetValue() end
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 220))
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Талант
    local talentLabel = vgui.Create("DLabel", parent)
    talentLabel:SetPos(dbtPaint.WidthSource(350), dbtPaint.HightSource(620))
    talentLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    talentLabel:SetFont("Comfortaa Light X30")
    talentLabel:SetText("Абсолютный талант:")
    talentLabel:SetTextColor(colorGold)
    
    local talentEntry = vgui.Create("DTextEntry", parent)
    talentEntry:SetPos(dbtPaint.WidthSource(680), dbtPaint.HightSource(615))
    talentEntry:SetSize(dbtPaint.WidthSource(850), dbtPaint.HightSource(100))
    talentEntry:SetFont("Comfortaa Light X25")
    talentEntry:SetText(CharCreatorData.talent)
    talentEntry:SetPlaceholderText("Опишите уникальный талант...")
    talentEntry:SetMultiline(true)
    talentEntry.OnChange = function(self) CharCreatorData.talent = self:GetValue() end
    talentEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 220))
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(850))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.Paint = function(self, w, h)
        local canContinue = CharCreatorData.name ~= "" and CharCreatorData.talent ~= ""
        if not canContinue then
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))
            draw.SimpleText("ЗАПОЛНИТЕ ВСЕ ПОЛЯ", "Comfortaa Bold X28", w / 2, h / 2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and colorButtonActive or colorButtonInactive)
            draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X38", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    continueButton.DoClick = function()
        if CharCreatorData.name ~= "" and CharCreatorData.talent ~= "" then
            surface.PlaySound('ui/button_click.mp3')
            CurrentStage = CreatorStage.APPEARANCE
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 3: Внешность
function CreateAppearance(parent)
    -- Левая панель: рост
    local leftPanel = vgui.Create("DPanel", parent)
    leftPanel:SetPos(dbtPaint.WidthSource(60), dbtPaint.HightSource(360))
    leftPanel:SetSize(dbtPaint.WidthSource(450), dbtPaint.HightSource(560))
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.SimpleText("РОСТ ПЕРСОНАЖА", "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(20), colorGold, TEXT_ALIGN_CENTER)
        local heightText = string.format("%.2f (%.0f%%)", CharCreatorData.height, (CharCreatorData.height - 0.5) / 1.0 * 100)
        draw.SimpleText(heightText, "Comfortaa Bold X40", w / 2, dbtPaint.HightSource(80), color_white, TEXT_ALIGN_CENTER)
    end
    
    local heightSlider = vgui.Create("DNumSlider", leftPanel)
    heightSlider:SetPos(dbtPaint.WidthSource(30), dbtPaint.HightSource(150))
    heightSlider:SetSize(dbtPaint.WidthSource(390), dbtPaint.HightSource(50))
    heightSlider:SetMin(0.5)
    heightSlider:SetMax(1.5)
    heightSlider:SetDecimals(2)
    heightSlider:SetValue(CharCreatorData.height)
    heightSlider:SetText("")
    heightSlider.OnValueChanged = function(self, value) CharCreatorData.height = value end
    heightSlider.Label:SetVisible(false)
    heightSlider.TextArea:SetVisible(false)
    
    -- Правая панель: выбор модели
    local rightPanel = vgui.Create("DPanel", parent)
    rightPanel:SetPos(dbtPaint.WidthSource(540), dbtPaint.HightSource(360))
    rightPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(560))
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.SimpleText("ВЫБОР МОДЕЛИ", "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(20), colorGold, TEXT_ALIGN_CENTER)
    end
    
    -- Поиск по файлу
    local searchEntry = vgui.Create("DTextEntry", rightPanel)
    searchEntry:SetPos(dbtPaint.WidthSource(30), dbtPaint.HightSource(70))
    searchEntry:SetSize(dbtPaint.WidthSource(600), dbtPaint.HightSource(40))
    searchEntry:SetFont("Comfortaa Light X22")
    searchEntry:SetPlaceholderText("Поиск: male, female, combine...")
    searchEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 220))
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Прямой ввод пути
    local directEntry = vgui.Create("DTextEntry", rightPanel)
    directEntry:SetPos(dbtPaint.WidthSource(660), dbtPaint.HightSource(70))
    directEntry:SetSize(dbtPaint.WidthSource(630), dbtPaint.HightSource(40))
    directEntry:SetFont("Comfortaa Light X20")
    directEntry:SetPlaceholderText("Прямой путь: models/player/...")
    directEntry.OnChange = function(self)
        local mdlPath = self:GetValue()
        if mdlPath ~= "" and string.EndsWith(string.lower(mdlPath), ".mdl") and file.Exists(mdlPath, "GAME") then
            CharCreatorData.model = mdlPath
            surface.PlaySound('ui/button_click.mp3')
        end
    end
    directEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 220))
        self:DrawTextEntryText(color_white, colorGreen, color_white)
    end
    
    -- Список моделей
    local modelsList = vgui.Create("DScrollPanel", rightPanel)
    modelsList:SetPos(dbtPaint.WidthSource(30), dbtPaint.HightSource(130))
    modelsList:SetSize(dbtPaint.WidthSource(1260), dbtPaint.HightSource(400))
    
    local sbar = modelsList:GetVBar()
    sbar:SetWide(5)
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    local function UpdateModelsList()
        modelsList:Clear()
        local filtered = FilterModels(ModelSearchQuery)
        
        for i, model in ipairs(filtered) do
            if i > 50 then break end -- Ограничение для производительности
            
            local btn = vgui.Create("DButton", modelsList)
            btn:SetPos(0, (i - 1) * 50)
            btn:SetSize(1240, 45)
            btn:SetText("")
            
            btn.Paint = function(self, w, h)
                local selected = CharCreatorData.model == model
                local hovered = self:IsHovered()
                
                if selected then
                    draw.RoundedBox(0, 0, 0, w, h, Color(colorGreen.r, colorGreen.g, colorGreen.b, 100))
                elseif hovered then
                    draw.RoundedBox(0, 0, 0, w, h, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 80))
                else
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 120))
                end
                
                local displayName = string.gsub(model, "models/player/", "")
                draw.SimpleText(displayName, "Comfortaa Light X20", 15, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                if selected then
                    draw.SimpleText("✓", "Comfortaa Bold X30", w - 25, h / 2, colorGreen, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            
            btn.DoClick = function()
                CharCreatorData.model = model
                surface.PlaySound('ui/button_click.mp3')
            end
            btn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
        end
    end
    
    searchEntry.OnChange = function(self)
        ModelSearchQuery = self:GetValue()
        UpdateModelsList()
    end
    
    UpdateModelsList()
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(950))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and colorButtonActive or colorButtonInactive)
        draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X38", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    continueButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local stats = RollStats()
        for k, v in pairs(stats) do CharCreatorData[k] = v end
        CurrentStage = CreatorStage.STATS_ROLL
        dbt.f4:Close()
        open_custom_character_creator()
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 4: Характеристики с материалами
function CreateStatsRoll(parent)
    -- Материалы иконок
    local iconHealth = Material("dbt/f4/stats_icons/stat_hp.png")
    local iconFood = Material("dbt/f4/stats_icons/stat_food.png")
    local iconWater = Material("dbt/f4/stats_icons/stat_water.png")
    local iconSleep = Material("dbt/f4/stats_icons/stat_sleep.png")
    local iconSpeed = Material("dbt/f4/stats_icons/stat_speed.png")
    local iconPower = Material("dbt/f4/stats_icons/stat_power.png")
    local iconWeight = Material("dbt/f4/stats_icons/stat_weight.png")
    local iconSlots = Material("dbt/f4/stats_icons/stat_slots.png")
    
    local stats = {
        {name = "Здоровье", key = "maxHealth", icon = iconHealth},
        {name = "Голод", key = "maxHungry", icon = iconFood},
        {name = "Жажда", key = "maxThird", icon = iconWater},
        {name = "Сон", key = "maxSleep", icon = iconSleep},
        {name = "Скорость", key = "runSpeed", icon = iconSpeed},
        {name = "Урон кулаками", key = "fistsDamage", icon = iconPower},
        {name = "Макс. вес (кг)", key = "maxKG", icon = iconWeight},
        {name = "Инвентарь", key = "maxInventory", icon = iconSlots},
    }
    
    local statsPanel = vgui.Create("DPanel", parent)
    statsPanel:SetPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(370))
    statsPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(450))
    statsPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.SimpleText("РЕЗУЛЬТАТ БРОСКА", "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(20), colorOutLine, TEXT_ALIGN_CENTER)
        
        local yStart = dbtPaint.HightSource(90)
        local leftX = dbtPaint.WidthSource(100)
        local rightX = dbtPaint.WidthSource(700)
        
        for i, stat in ipairs(stats) do
            local xPos = (i <= 4) and leftX or rightX
            local yPos = yStart + ((i <= 4) and (i - 1) or (i - 5)) * dbtPaint.HightSource(85)
            
            -- Иконка
            if stat.icon then
                dbtPaint.DrawRect(stat.icon, xPos, yPos, stat.icon:Width(), stat.icon:Height())
            end
            
            -- Название
            draw.SimpleText(stat.name, "Comfortaa Light X22", xPos + 50, yPos + 10, colorText, TEXT_ALIGN_LEFT)
            
            -- Значение
            draw.SimpleText(tostring(CharCreatorData[stat.key]), "Comfortaa Bold X35", xPos + 50, yPos + 40, color_white, TEXT_ALIGN_LEFT)
        end
    end
    
    -- Кнопка переброса
    local rerollButton = vgui.Create("DButton", parent)
    rerollButton:SetPos(dbtPaint.WidthSource(610), dbtPaint.HightSource(870))
    rerollButton:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(70))
    rerollButton:SetText("")
    rerollButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and colorButtonActive or colorButtonInactive)
        draw.SimpleText("🎲 ПЕРЕБРОСИТЬ", "Comfortaa Bold X32", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    rerollButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local stats = RollStats()
        for k, v in pairs(stats) do CharCreatorData[k] = v end
        dbt.f4:Close()
        open_custom_character_creator()
    end
    rerollButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Кнопка создать
    local acceptButton = vgui.Create("DButton", parent)
    acceptButton:SetPos(dbtPaint.WidthSource(930), dbtPaint.HightSource(870))
    acceptButton:SetSize(dbtPaint.WidthSource(350), dbtPaint.HightSource(70))
    acceptButton:SetText("")
    acceptButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200) or colorButtonInactive)
        draw.SimpleText("СОЗДАТЬ ПЕРСОНАЖА", "Comfortaa Bold X28", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

-- Вспомогательные функции
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
        if IsValid(dbt.f4) then dbt.f4:Close() end
        CurrentStage = CreatorStage.FAITH_SELECT
        openseasonselect()
    else
        chat.AddText(Color(255, 0, 0), "[Ошибка] ", color_white, message)
    end
end)

print("[Custom Character Creator] v3.2 загружен - Упрощённая версия с материалами")