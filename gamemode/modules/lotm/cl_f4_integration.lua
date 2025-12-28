-- LOTM F4 Menu Integration v3.0
-- Интеграция LOTM функций в F4 меню в стиле проекта DBT

LOTM = LOTM or {}
LOTM.F4 = LOTM.F4 or {}

-- Цветовая палитра проекта
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255, 200)
local colorButtonExit = Color(250, 250, 250, 1)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

local function draw_border(w, h, color)
    draw.RoundedBox(0, 0, 0, w, 1, color)
    draw.RoundedBox(0, 0, 0, 1, h, color)
    draw.RoundedBox(0, 0, h - 1, w, 1, color)
    draw.RoundedBox(0, w - 1, 0, 1, h, color)
end

-- Открыть LOTM меню настроек (полноэкранное, в стиле F4)
function LOTM.F4.OpenMenu()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.F4.Frame) then
        LOTM.F4.Frame:Close()
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw, scrh)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    LOTM.F4.Frame = frame
    
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
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 150))
        end
        
        -- Заголовок
        local titleY = dbtPaint and dbtPaint.HightSource(70) or 70
        local subtitleY = dbtPaint and dbtPaint.HightSource(135) or 135
        local lineY = dbtPaint and dbtPaint.HightSource(175) or 175
        
        draw.SimpleText("LORD OF THE MYSTERIES", "Comfortaa Bold X60", w / 2, titleY, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("ГЛАВНОЕ МЕНЮ", "Comfortaa Light X28", w / 2, subtitleY, colorText, TEXT_ALIGN_CENTER)
        
        -- Декоративная линия
        local lineW = dbtPaint and dbtPaint.WidthSource(400) or 400
        draw.RoundedBox(0, w / 2 - lineW / 2, lineY, lineW, 2, colorOutLine)
    end
    
    -- Кнопки меню
    local buttonW = dbtPaint and dbtPaint.WidthSource(416) or 416
    local buttonH = dbtPaint and dbtPaint.HightSource(60) or 60
    local startY = dbtPaint and dbtPaint.HightSource(220) or 220
    local spacing = dbtPaint and dbtPaint.HightSource(70) or 70
    local centerX = scrw / 2 - buttonW / 2
    
    local buttons = {
        {text = "📖 Книга скиллов", action = function()
            frame:Close()
            timer.Simple(0.1, function()
                if LOTM.SkillsMenu and LOTM.SkillsMenu.Open then
                    LOTM.SkillsMenu.Open()
                else
                    RunConsoleCommand("lotm_skills")
                end
            end)
        end},
        {text = "🗡 Экипировка артефактов", action = function()
            frame:Close()
            timer.Simple(0.1, function()
                if LOTM.ArtifactSlotsUI and LOTM.ArtifactSlotsUI.Open then
                    LOTM.ArtifactSlotsUI.Open()
                else
                    RunConsoleCommand("lotm_artifacts_equip")
                end
            end)
        end},
        {text = "🧪 Предметы LOTM", action = function()
            frame:Close()
            if LOTM.UnifiedMenu and LOTM.UnifiedMenu.Open then
                LOTM.UnifiedMenu.Open()
            end
        end},
        {text = "⌨ Настройка клавиш", action = function()
            frame:Close()
            timer.Simple(0.1, function()
                if LOTM.Keybinds and LOTM.Keybinds.OpenMenu then
                    LOTM.Keybinds.OpenMenu()
                else
                    RunConsoleCommand("lotm_keybinds")
                end
            end)
        end},
        {text = "📷 Настройка камеры", action = function()
            frame:Close()
            if LOTM.ThirdPerson and LOTM.ThirdPerson.OpenSettings then
                LOTM.ThirdPerson.OpenSettings()
            end
        end},
        {text = "👁 Третье лицо [ВКЛ/ВЫКЛ]", action = function()
            if LOTM.ThirdPerson and LOTM.ThirdPerson.Toggle then
                LOTM.ThirdPerson.Toggle()
            end
            frame:Close()
        end},
        {text = "💰 Кошелёк", action = function()
            if LOTM.CurrencyHUD then
                LOTM.CurrencyHUD.ShowTime = CurTime()
            end
            RunConsoleCommand("lotm_wallet")
        end},
    }
    
    for i, btnData in ipairs(buttons) do
        local button = vgui.Create("DButton", frame)
        button:SetText("")
        button:SetPos(centerX, startY + (i - 1) * spacing)
        button:SetSize(buttonW, buttonH)
        button.ColorBorder = Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 0)
        
        button.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
            
            if hovered then
                self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
                draw_border(w, h, self.ColorBorder)
            else
                self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
            end
            
            local fontName = dbtPaint and "Comfortaa Light X45" or "DermaLarge"
            local textY = dbtPaint and dbtPaint.HightSource(7) or h/2
            draw.SimpleText(btnData.text, fontName, w * 0.5, textY, color_white, TEXT_ALIGN_CENTER, dbtPaint and nil or TEXT_ALIGN_CENTER)
        end
        
        button.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            if btnData.action then btnData.action() end
        end
        
        button.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
        end
    end
    
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
        local fontName = dbtPaint and "Comfortaa Light X40" or "DermaLarge"
        draw.SimpleText("НАЗАД", fontName, w / 2, dbtPaint and h * 0.1 or h/2, color_white, TEXT_ALIGN_CENTER, dbtPaint and nil or TEXT_ALIGN_CENTER)
    end
end

-- Консольные команды
concommand.Add("lotm_menu", function()
    LOTM.F4.OpenMenu()
end)

concommand.Add("+lotm_menu", function()
    LOTM.F4.OpenMenu()
end)

print("[LOTM] F4 menu integration v3.0 loaded")
