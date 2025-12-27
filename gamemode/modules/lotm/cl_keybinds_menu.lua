-- LOTM Keybinds Menu
-- Меню настройки горячих клавиш в стиле проекта DBT

LOTM = LOTM or {}
LOTM.Keybinds = LOTM.Keybinds or {}

-- Цветовая палитра проекта
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255, 200)
local colorButtonExit = Color(250, 250, 250, 1)
local colorSettingsPanel = Color(0, 0, 0, 170)
local colorSettingsPanelActive = Color(191, 30, 219, 150)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Функция отрисовки рамки
local function draw_border(w, h, color)
    draw.RoundedBox(0, 0, 0, w, 1, color)
    draw.RoundedBox(0, 0, 0, 1, h, color)
    draw.RoundedBox(0, 0, h - 1, w, 1, color)
    draw.RoundedBox(0, w - 1, 0, 1, h, color)
end

-- Список клавиш для отображения
local KEY_NAMES = {}
for i = KEY_FIRST, KEY_LAST do
    local name = input.GetKeyName(i)
    if name and name ~= "" then
        KEY_NAMES[i] = string.upper(name)
    end
end

-- Определение биндов
LOTM.Keybinds.Binds = {
    {category = "general", id = "dodge", name = "Уклонение", default = KEY_LALT, convar = "lotm_keybind_dodge"},
    {category = "general", id = "thirdperson", name = "Третье лицо", default = KEY_F5, convar = "lotm_keybind_thirdperson"},
    {category = "general", id = "aura", name = "Аура", default = KEY_G, convar = "lotm_keybind_aura"},
    {category = "abilities", id = "ability_1", name = "Способность 1", default = KEY_1, convar = "lotm_keybind_ability1"},
    {category = "abilities", id = "ability_2", name = "Способность 2", default = KEY_2, convar = "lotm_keybind_ability2"},
    {category = "abilities", id = "ability_3", name = "Способность 3", default = KEY_3, convar = "lotm_keybind_ability3"},
    {category = "abilities", id = "ability_4", name = "Способность 4", default = KEY_4, convar = "lotm_keybind_ability4"},
    {category = "abilities", id = "ability_5", name = "Способность 5", default = KEY_5, convar = "lotm_keybind_ability5"},
}

-- Категории
LOTM.Keybinds.Categories = {
    {id = "abilities", name = "СПОСОБНОСТИ"},
    {id = "general", name = "ОБЩЕЕ"},
}

-- Создание ConVars
for _, bind in ipairs(LOTM.Keybinds.Binds) do
    CreateClientConVar(bind.convar, tostring(bind.default), true, false, bind.name)
end

-- Получить текущий бинд
function LOTM.Keybinds.GetBind(bindId)
    for _, bind in ipairs(LOTM.Keybinds.Binds) do
        if bind.id == bindId then
            return GetConVar(bind.convar):GetInt()
        end
    end
    return 0
end

-- Установить бинд
function LOTM.Keybinds.SetBind(bindId, key)
    for _, bind in ipairs(LOTM.Keybinds.Binds) do
        if bind.id == bindId then
            RunConsoleCommand(bind.convar, tostring(key))
            return true
        end
    end
    return false
end

-- Главное меню биндов в стиле проекта
function LOTM.Keybinds.OpenMenu()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.Keybinds.Frame) then
        LOTM.Keybinds.Frame:Close()
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    local waitingForKey = nil
    local waitingPanel = nil
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw, scrh)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    LOTM.Keybinds.Frame = frame
    
    frame.OnKeyCodePressed = function(self, key)
        if waitingForKey then
            if key == KEY_ESCAPE then
                waitingForKey = nil
                waitingPanel = nil
                surface.PlaySound('ui/button_back.mp3')
            else
                RunConsoleCommand(waitingForKey.convar, tostring(key))
                waitingForKey = nil
                waitingPanel = nil
                surface.PlaySound('ui/button_click.mp3')
            end
            return true
        elseif key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            self:Close()
            return true
        end
    end
    
    frame.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 150))
        
        draw.SimpleText("НАСТРОЙКА КЛАВИШ", "Comfortaa Bold X60", w / 2, dbtPaint.HightSource(80), color_white, TEXT_ALIGN_CENTER)
        
        if waitingForKey then
            draw.SimpleText("Нажмите клавишу для: " .. waitingForKey.name, "Comfortaa Light X30", w / 2, dbtPaint.HightSource(150), colorOutLine, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Нажмите на клавишу, чтобы изменить бинд", "Comfortaa Light X25", w / 2, dbtPaint.HightSource(150), colorText, TEXT_ALIGN_CENTER)
        end
        
        local lineW = dbtPaint.WidthSource(300)
        draw.RoundedBox(0, w / 2 - lineW / 2, dbtPaint.HightSource(180), lineW, 2, colorOutLine)
    end
    
    -- Панель с биндами
    local panelW = dbtPaint.WidthSource(900)
    local panelH = dbtPaint.HightSource(600)
    local startX = scrw / 2 - panelW / 2
    local startY = dbtPaint.HightSource(220)
    
    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:SetPos(startX, startY)
    scrollPanel:SetSize(panelW, panelH)
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(8))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    local yOffset = 0
    local rowH = dbtPaint.HightSource(55)
    
    for _, category in ipairs(LOTM.Keybinds.Categories) do
        -- Заголовок категории
        local catPanel = vgui.Create("DPanel", scrollPanel)
        catPanel:SetSize(panelW - dbtPaint.WidthSource(20), dbtPaint.HightSource(40))
        catPanel:SetPos(0, yOffset)
        catPanel.Paint = function(self, w, h)
            draw.SimpleText(category.name, "Comfortaa Bold X30", w / 2, h / 2, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
            surface.DrawRect(0, h - 1, w, 1)
        end
        
        yOffset = yOffset + dbtPaint.HightSource(50)
        
        -- Бинды в категории
        for _, bind in ipairs(LOTM.Keybinds.Binds) do
            if bind.category == category.id then
                local bindPanel = vgui.Create("DPanel", scrollPanel)
                bindPanel:SetSize(panelW - dbtPaint.WidthSource(20), rowH)
                bindPanel:SetPos(0, yOffset)
                bindPanel.isBinding = false
                
                bindPanel.Paint = function(self, w, h)
                    local hovered = self:IsHovered()
                    local isActive = waitingForKey == bind
                    
                    local bgColor = isActive and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 80) or (hovered and Color(50, 50, 50, 200) or colorSettingsPanel)
                    draw.RoundedBox(0, 0, 0, w, h, bgColor)
                    
                    -- Левая полоса
                    local accentColor = isActive and colorOutLine or (hovered and colorSettingsPanelActive or Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 150))
                    draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, accentColor)
                    
                    -- Название
                    draw.SimpleText(bind.name, "Comfortaa Light X28", dbtPaint.WidthSource(30), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                bindPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
                
                -- Кнопка с текущим биндом
                local bindBtn = vgui.Create("DButton", bindPanel)
                bindBtn:SetSize(dbtPaint.WidthSource(150), dbtPaint.HightSource(40))
                bindBtn:SetPos(panelW - dbtPaint.WidthSource(200), (rowH - dbtPaint.HightSource(40)) / 2)
                bindBtn:SetText("")
                
                bindBtn.Paint = function(self, w, h)
                    local currentKey = GetConVar(bind.convar):GetInt()
                    local keyName = KEY_NAMES[currentKey] or "---"
                    local isActive = waitingForKey == bind
                    local hovered = self:IsHovered()
                    
                    local bgColor = isActive and colorOutLine or (hovered and colorButtonActive or colorButtonInactive)
                    draw.RoundedBox(0, 0, 0, w, h, bgColor)
                    
                    if hovered or isActive then
                        draw_border(w, h, colorOutLine)
                    end
                    
                    local displayText = isActive and "..." or keyName
                    draw.SimpleText(displayText, "Comfortaa Bold X22", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                bindBtn.DoClick = function()
                    if waitingForKey then return end
                    waitingForKey = bind
                    waitingPanel = bindPanel
                    surface.PlaySound('ui/button_click.mp3')
                end
                
                yOffset = yOffset + rowH + dbtPaint.HightSource(5)
            end
        end
        
        yOffset = yOffset + dbtPaint.HightSource(20)
    end
    
    -- Кнопка сброса
    local resetButton = vgui.Create("DButton", frame)
    resetButton:SetText("")
    resetButton:SetPos(startX + panelW - dbtPaint.WidthSource(250), startY + panelH + dbtPaint.HightSource(20))
    resetButton:SetSize(dbtPaint.WidthSource(250), dbtPaint.HightSource(50))
    resetButton.ColorBorder = Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 0)
    
    resetButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(180, 60, 60, 200) or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, Color(255, 100, 100))
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("СБРОСИТЬ ВСЕ", "Comfortaa Light X28", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    resetButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        for _, bind in ipairs(LOTM.Keybinds.Binds) do
            RunConsoleCommand(bind.convar, tostring(bind.default))
        end
    end
    
    resetButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Кнопка НАЗАД
    local backButton = vgui.Create("DButton", frame)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        frame:Close()
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- Безопасный вызов способности
local function SafeRequestAbility(slot)
    if not LOTM then return end
    if not LOTM.Abilities then return end
    if type(LOTM.Abilities.RequestUse) ~= "function" then
        -- Fallback - прямой запрос на сервер
        net.Start("LOTM.Abilities.Use")
        net.WriteUInt(slot, 8)
        net.SendToServer()
        return
    end
    LOTM.Abilities.RequestUse(slot)
end

-- Обработка нажатий клавиш
hook.Add("PlayerButtonDown", "LOTM.Keybinds.Handler", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end
    if LocalPlayer():IsTyping() then return end
    if IsValid(LOTM.Keybinds.Frame) then return end
    
    for _, bind in ipairs(LOTM.Keybinds.Binds) do
        local boundKey = GetConVar(bind.convar):GetInt()
        
        if button == boundKey then
            if bind.id == "dodge" then
                if LOTM.Dodge and LOTM.Dodge.Request then LOTM.Dodge.Request() end
            elseif bind.id == "ability_1" then
                SafeRequestAbility(1)
            elseif bind.id == "ability_2" then
                SafeRequestAbility(2)
            elseif bind.id == "ability_3" then
                SafeRequestAbility(3)
            elseif bind.id == "ability_4" then
                SafeRequestAbility(4)
            elseif bind.id == "ability_5" then
                SafeRequestAbility(5)
            elseif bind.id == "thirdperson" then
                if LOTM.ThirdPerson and LOTM.ThirdPerson.Toggle then LOTM.ThirdPerson.Toggle() end
            elseif bind.id == "aura" then
                hook.Run("LOTM.Aura.Toggle")
            end
            break
        end
    end
end)

-- Консольная команда
concommand.Add("lotm_keybinds", function()
    LOTM.Keybinds.OpenMenu()
end)

print("[LOTM] Keybinds menu loaded")
