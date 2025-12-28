-- LOTM Unified Keybinds System v3.0
-- Единая система биндов для всех функций LOTM
-- Интеграция со скиллами

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
local colorActive = Color(100, 255, 200)
local colorPassive = Color(255, 200, 100)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Определение биндов
LOTM.Keybinds.Binds = {
    -- Общие
    {category = "general", id = "dodge", name = "Уклонение (Дэш)", default = KEY_LALT, convar = "lotm_bind_dodge"},
    {category = "general", id = "thirdperson", name = "Третье лицо", default = KEY_F5, convar = "lotm_bind_thirdperson"},
    {category = "general", id = "aura_toggle", name = "Аура (вкл/выкл)", default = KEY_G, convar = "lotm_bind_aura"},
    {category = "general", id = "artifact_use", name = "Использовать артефакт", default = KEY_H, convar = "lotm_bind_artifact"},
    {category = "general", id = "skills_menu", name = "Книга скиллов", default = KEY_K, convar = "lotm_bind_skills"},
    
    -- Скиллы (слоты 1-7)
    {category = "skills", id = "skill_1", name = "Скилл 1", default = KEY_1, convar = "lotm_bind_skill1"},
    {category = "skills", id = "skill_2", name = "Скилл 2", default = KEY_2, convar = "lotm_bind_skill2"},
    {category = "skills", id = "skill_3", name = "Скилл 3", default = KEY_3, convar = "lotm_bind_skill3"},
    {category = "skills", id = "skill_4", name = "Скилл 4", default = KEY_4, convar = "lotm_bind_skill4"},
    {category = "skills", id = "skill_5", name = "Скилл 5", default = KEY_5, convar = "lotm_bind_skill5"},
    {category = "skills", id = "skill_6", name = "Скилл 6", default = KEY_6, convar = "lotm_bind_skill6"},
    {category = "skills", id = "skill_7", name = "Скилл 7", default = KEY_7, convar = "lotm_bind_skill7"},
}

-- Категории
LOTM.Keybinds.Categories = {
    {id = "general", name = "ОБЩЕЕ", icon = "⚙"},
    {id = "skills", name = "СКИЛЛЫ", icon = "⚔"},
}

-- Список названий клавиш
local KEY_NAMES = {}
for i = KEY_FIRST, KEY_LAST do
    local name = input.GetKeyName(i)
    if name and name ~= "" then
        KEY_NAMES[i] = string.upper(name)
    end
end

-- Создание ConVars
for _, bind in ipairs(LOTM.Keybinds.Binds) do
    CreateClientConVar(bind.convar, tostring(bind.default), true, false, bind.name)
end

-- Функции доступа
function LOTM.Keybinds.GetBind(bindId)
    for _, bind in ipairs(LOTM.Keybinds.Binds) do
        if bind.id == bindId then
            local cv = GetConVar(bind.convar)
            return cv and cv:GetInt() or bind.default
        end
    end
    return 0
end

function LOTM.Keybinds.SetBind(bindId, key)
    for _, bind in ipairs(LOTM.Keybinds.Binds) do
        if bind.id == bindId then
            RunConsoleCommand(bind.convar, tostring(key))
            return true
        end
    end
    return false
end

function LOTM.Keybinds.GetKeyName(key)
    return KEY_NAMES[key] or "???"
end

local function draw_border(w, h, color)
    draw.RoundedBox(0, 0, 0, w, 1, color)
    draw.RoundedBox(0, 0, 0, 1, h, color)
    draw.RoundedBox(0, 0, h - 1, w, 1, color)
    draw.RoundedBox(0, w - 1, 0, 1, h, color)
end

-- =============================================
-- МЕНЮ НАСТРОЙКИ БИНДОВ
-- =============================================

function LOTM.Keybinds.OpenMenu()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.Keybinds.Frame) then
        LOTM.Keybinds.Frame:Close()
        return
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    local waitingForKey = nil
    
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
                surface.PlaySound('ui/button_back.mp3')
            else
                RunConsoleCommand(waitingForKey.convar, tostring(key))
                waitingForKey = nil
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
        if BlurScreen then BlurScreen(24) end
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        
        if dbtPaint and dbtPaint.DrawRect then
            dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 150))
        end
        
        local titleY = dbtPaint and dbtPaint.HightSource(70) or 70
        local subtitleY = dbtPaint and dbtPaint.HightSource(135) or 135
        local lineY = dbtPaint and dbtPaint.HightSource(170) or 170
        
        draw.SimpleText("НАСТРОЙКА КЛАВИШ", "Comfortaa Bold X60", w / 2, titleY, color_white, TEXT_ALIGN_CENTER)
        
        if waitingForKey then
            draw.SimpleText("Нажмите клавишу для: " .. waitingForKey.name, "Comfortaa Light X28", w / 2, subtitleY, colorOutLine, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Нажмите на кнопку, чтобы изменить бинд", "Comfortaa Light X22", w / 2, subtitleY, colorText, TEXT_ALIGN_CENTER)
        end
        
        local lineW = dbtPaint and dbtPaint.WidthSource(300) or 300
        draw.RoundedBox(0, w / 2 - lineW / 2, lineY, lineW, 2, colorOutLine)
    end
    
    -- Панель с биндами
    local panelW = dbtPaint and dbtPaint.WidthSource(900) or 900
    local panelH = dbtPaint and dbtPaint.HightSource(650) or 650
    local startX = scrw / 2 - panelW / 2
    local startY = dbtPaint and dbtPaint.HightSource(200) or 200
    
    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:SetPos(startX, startY)
    scrollPanel:SetSize(panelW, panelH)
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(dbtPaint and dbtPaint.WidthSource(8) or 8)
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    local yOffset = 0
    local rowH = dbtPaint and dbtPaint.HightSource(55) or 55
    
    for _, category in ipairs(LOTM.Keybinds.Categories) do
        -- Заголовок категории
        local catH = dbtPaint and dbtPaint.HightSource(45) or 45
        local catPanel = vgui.Create("DPanel", scrollPanel)
        catPanel:SetSize(panelW - 20, catH)
        catPanel:SetPos(0, yOffset)
        catPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
            draw.SimpleText(category.icon .. " " .. category.name, "Comfortaa Bold X28", w / 2, h / 2, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
            surface.DrawRect(0, h - 2, w, 2)
        end
        
        yOffset = yOffset + catH + 10
        
        -- Бинды в категории
        for _, bind in ipairs(LOTM.Keybinds.Binds) do
            if bind.category == category.id then
                local bindPanel = vgui.Create("DPanel", scrollPanel)
                bindPanel:SetSize(panelW - 20, rowH)
                bindPanel:SetPos(0, yOffset)
                
                bindPanel.Paint = function(self, w, h)
                    local hovered = self:IsHovered()
                    local isActive = waitingForKey == bind
                    
                    local bgColor = isActive and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 80) 
                        or (hovered and Color(50, 50, 50, 200) or colorSettingsPanel)
                    draw.RoundedBox(0, 0, 0, w, h, bgColor)
                    
                    local accentColor = isActive and colorOutLine 
                        or (hovered and colorSettingsPanelActive or Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 150))
                    draw.RoundedBox(0, 0, 0, 5, h, accentColor)
                    
                    draw.SimpleText(bind.name, "Comfortaa Light X25", 25, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                bindPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
                
                -- Кнопка с текущим биндом
                local btnW = dbtPaint and dbtPaint.WidthSource(150) or 150
                local btnH = dbtPaint and dbtPaint.HightSource(40) or 40
                local bindBtn = vgui.Create("DButton", bindPanel)
                bindBtn:SetSize(btnW, btnH)
                bindBtn:SetPos(panelW - 190, (rowH - btnH) / 2)
                bindBtn:SetText("")
                
                bindBtn.Paint = function(self, w, h)
                    local cv = GetConVar(bind.convar)
                    local currentKey = cv and cv:GetInt() or 0
                    local keyName = KEY_NAMES[currentKey] or "---"
                    local isActive = waitingForKey == bind
                    local hovered = self:IsHovered()
                    
                    local bgColor = isActive and colorOutLine or (hovered and colorButtonActive or colorButtonInactive)
                    draw.RoundedBox(4, 0, 0, w, h, bgColor)
                    
                    if hovered or isActive then
                        draw_border(w, h, colorOutLine)
                    end
                    
                    local displayText = isActive and "..." or keyName
                    draw.SimpleText(displayText, "Comfortaa Bold X20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                bindBtn.DoClick = function()
                    if waitingForKey then return end
                    waitingForKey = bind
                    surface.PlaySound('ui/button_click.mp3')
                end
                
                yOffset = yOffset + rowH + 5
            end
        end
        
        yOffset = yOffset + 15
    end
    
    -- Кнопка сброса
    local resetW = dbtPaint and dbtPaint.WidthSource(250) or 250
    local resetH = dbtPaint and dbtPaint.HightSource(50) or 50
    local resetButton = vgui.Create("DButton", frame)
    resetButton:SetText("")
    resetButton:SetPos(startX + panelW - resetW, startY + panelH + 15)
    resetButton:SetSize(resetW, resetH)
    
    resetButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(4, 0, 0, w, h, hovered and Color(180, 60, 60, 200) or colorButtonInactive)
        if hovered then draw_border(w, h, Color(255, 100, 100)) end
        draw.SimpleText("СБРОСИТЬ ВСЕ", "Comfortaa Light X25", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    backButton:SetPos(dbtPaint and dbtPaint.WidthSource(48) or 48, dbtPaint and dbtPaint.HightSource(984) or (scrh - 70))
    backButton:SetSize(dbtPaint and dbtPaint.WidthSource(199) or 199, dbtPaint and dbtPaint.HightSource(55) or 55)
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

-- =============================================
-- ОБРАБОТКА НАЖАТИЙ КЛАВИШ
-- =============================================

hook.Add("PlayerButtonDown", "LOTM.Keybinds.Handler", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end
    if LocalPlayer():IsTyping() then return end
    if IsValid(LOTM.Keybinds.Frame) then return end
    
    for _, bind in ipairs(LOTM.Keybinds.Binds) do
        local cv = GetConVar(bind.convar)
        local boundKey = cv and cv:GetInt() or 0
        
        if button == boundKey then
            -- Уклонение / Дэш
            if bind.id == "dodge" then
                if LOTM.Dash and LOTM.Dash.Request then
                    local direction = "back"
                    if ply:KeyDown(IN_FORWARD) then direction = "forward"
                    elseif ply:KeyDown(IN_MOVELEFT) then direction = "left"
                    elseif ply:KeyDown(IN_MOVERIGHT) then direction = "right" end
                    LOTM.Dash.Request(direction)
                end
                return
            end
            
            -- Третье лицо
            if bind.id == "thirdperson" then
                if LOTM.ThirdPerson and LOTM.ThirdPerson.Toggle then
                    LOTM.ThirdPerson.Toggle()
                end
                return
            end
            
            -- Аура
            if bind.id == "aura_toggle" then
                hook.Run("LOTM.Aura.Toggle")
                return
            end
            
            -- Использование артефакта
            if bind.id == "artifact_use" then
                if LOTM.Artifacts and LOTM.Artifacts.RequestUse then
                    LOTM.Artifacts.RequestUse()
                end
                return
            end
            
            -- Книга скиллов
            if bind.id == "skills_menu" then
                if LOTM.SkillsMenu and LOTM.SkillsMenu.Open then
                    LOTM.SkillsMenu.Open()
                else
                    RunConsoleCommand("lotm_skills")
                end
                return
            end
            
            -- Скиллы 1-7
            local skillMatch = string.match(bind.id, "skill_(%d)")
            if skillMatch then
                local slot = tonumber(skillMatch)
                if slot then
                    -- Получаем разблокированные активные скиллы и используем по индексу
                    local unlockedActive = {}
                    if LOTM.Skills and LOTM.Skills.GetUnlockedActive then
                        unlockedActive = LOTM.Skills.GetUnlockedActive(LocalPlayer())
                    end
                    
                    if unlockedActive[slot] then
                        net.Start("LOTM.Skills.Use")
                        net.WriteString(unlockedActive[slot].id)
                        net.SendToServer()
                    end
                end
                return
            end
        end
    end
end)

-- =============================================
-- КОНСОЛЬНЫЕ КОМАНДЫ
-- =============================================

concommand.Add("lotm_keybinds", function()
    LOTM.Keybinds.OpenMenu()
end)

concommand.Add("lotm_binds", function()
    LOTM.Keybinds.OpenMenu()
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Unified Keybinds System v3.0 loaded\n")
