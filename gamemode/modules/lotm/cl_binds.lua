-- LOTM Binds System - Client
-- Бинды для дэшей и 7 способностей

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.Binds = LOTM.Binds or {}

-- =============================================
-- НАСТРОЙКИ БИНДОВ
-- =============================================
LOTM.Binds.Config = {
    -- Бинды на способности (1-7 по умолчанию)
    abilityKeys = {
        [1] = KEY_1,
        [2] = KEY_2,
        [3] = KEY_3,
        [4] = KEY_4,
        [5] = KEY_5,
        [6] = KEY_6,
        [7] = KEY_7,
    },
    
    -- Модификатор для дэшей
    dashModifier = IN_SPEED,  -- Shift
    
    -- Показывать подсказки
    showHints = true,
}

-- Состояние
LOTM.Binds.LastDashTime = 0
LOTM.Binds.DashCooldown = 1.5
LOTM.Binds.AbilityCooldowns = {}

-- =============================================
-- ОБРАБОТКА ВВОДА
-- =============================================
hook.Add("PlayerButtonDown", "LOTM.Binds.Input", function(ply, button)
    if not IsFirstTimePredicted() then return end
    if ply ~= LocalPlayer() then return end
    if not ply:Alive() then return end
    if gui.IsConsoleVisible() or gui.IsGameUIVisible() then return end
    
    local curTime = CurTime()
    local config = LOTM.Binds.Config
    
    -- =============================================
    -- ДЭШИ (Shift + WASD)
    -- =============================================
    if ply:KeyDown(config.dashModifier) then
        local direction = nil
        
        if button == KEY_W then direction = "forward"
        elseif button == KEY_S then direction = "back"
        elseif button == KEY_A then direction = "left"
        elseif button == KEY_D then direction = "right"
        end
        
        if direction then
            if curTime > LOTM.Binds.LastDashTime + LOTM.Binds.DashCooldown then
                if LOTM.Dash and LOTM.Dash.Request then
                    LOTM.Dash.Request(direction)
                    LOTM.Binds.LastDashTime = curTime
                    surface.PlaySound("physics/body/body_medium_impact_soft3.wav")
                end
            end
            return
        end
    end
    
    -- =============================================
    -- 7 СПОСОБНОСТЕЙ (1-7)
    -- =============================================
    for slot, key in pairs(config.abilityKeys) do
        if button == key then
            -- Проверяем КД
            local cd = LOTM.Binds.AbilityCooldowns[slot] or 0
            if curTime < cd then return end
            
            -- Отправляем на сервер
            net.Start("LOTM_ActivateAbility")
            net.WriteUInt(slot, 8)
            net.SendToServer()
            
            -- Локальный КД (0.5 сек минимум)
            LOTM.Binds.AbilityCooldowns[slot] = curTime + 0.5
            
            surface.PlaySound("ui/button_click.mp3")
            return
        end
    end
end)

-- =============================================
-- HUD ПОДСКАЗКИ
-- =============================================
hook.Add("HUDPaint", "LOTM.Binds.HUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local config = LOTM.Binds.Config
    if not config.showHints then return end
    
    local scrw, scrh = ScrW(), ScrH()
    local colorOutLine = Color(211, 25, 202)
    local colorText = Color(255, 255, 255)
    local colorDim = Color(150, 150, 150)
    
    -- Подсказка дэша при зажатом Shift
    if ply:KeyDown(IN_SPEED) then
        local text = "SHIFT + WASD = Дэш"
        local cdRemaining = (LOTM.Binds.LastDashTime + LOTM.Binds.DashCooldown) - CurTime()
        
        if cdRemaining > 0 then
            text = "DASH КД: " .. string.format("%.1f", cdRemaining) .. "с"
            draw.SimpleText(text, "DermaDefaultBold", scrw / 2, scrh - 50, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(text, "DermaDefaultBold", scrw / 2, scrh - 50, colorOutLine, TEXT_ALIGN_CENTER)
        end
    end
    
    -- =============================================
    -- HUD СПОСОБНОСТЕЙ
    -- =============================================
    local abilities = LOTM.PlayerAbilities or {}
    local panelW = 400
    local panelH = 60
    local panelX = scrw / 2 - panelW / 2
    local panelY = scrh - 80
    
    draw.RoundedBox(4, panelX, panelY, panelW, panelH, Color(0, 0, 0, 150))
    
    local slotW = panelW / 7
    local curTime = CurTime()
    
    for i = 1, 7 do
        local x = panelX + (i - 1) * slotW + 5
        local y = panelY + 5
        local w = slotW - 10
        local h = panelH - 10
        
        local ability = abilities[i]
        local onCd = LOTM.Binds.AbilityCooldowns[i] and curTime < LOTM.Binds.AbilityCooldowns[i]
        
        -- Фон слота
        local bgColor = Color(40, 40, 50, 200)
        if ability then bgColor = Color(60, 30, 80, 220) end
        if onCd then bgColor = Color(80, 30, 30, 220) end
        
        draw.RoundedBox(4, x, y, w, h, bgColor)
        
        -- Номер клавиши
        draw.SimpleText(tostring(i), "DermaDefaultBold", x + w/2, y + 8, colorDim, TEXT_ALIGN_CENTER)
        
        -- Название способности
        if ability then
            draw.SimpleText(string.sub(ability.name or "", 1, 4), "DermaDefault", x + w/2, y + 28, colorText, TEXT_ALIGN_CENTER)
        end
        
        -- Рамка
        if ability then
            surface.SetDrawColor(colorOutLine)
            surface.DrawOutlinedRect(x, y, w, h, 1)
        end
    end
end)

-- =============================================
-- МЕНЮ НАСТРОЙКИ БИНДОВ
-- =============================================
function LOTM.Binds.OpenSettings()
    if IsValid(LOTM.Binds.SettingsFrame) then
        LOTM.Binds.SettingsFrame:Remove()
        return
    end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 350)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    LOTM.Binds.SettingsFrame = frame
    
    local colorOutLine = Color(211, 25, 202)
    local colorBG = Color(0, 0, 0, 230)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorBG)
        surface.SetDrawColor(colorOutLine)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("НАСТРОЙКИ БИНДОВ", "Comfortaa Bold X20", w/2, 20, colorOutLine, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(365, 10)
    closeBtn:SetSize(25, 25)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.SimpleText("✕", "DermaDefaultBold", w/2, h/2, 
            self:IsHovered() and Color(255, 100, 100) or Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() frame:Remove() end
    
    -- Контент
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 50)
    scroll:SetSize(380, 290)
    
    -- Подсказки
    local hintsCheck = scroll:Add("DCheckBoxLabel")
    hintsCheck:Dock(TOP)
    hintsCheck:DockMargin(0, 0, 0, 10)
    hintsCheck:SetText("Показывать подсказки на экране")
    hintsCheck:SetTextColor(Color(255, 255, 255))
    hintsCheck:SetValue(LOTM.Binds.Config.showHints)
    hintsCheck.OnChange = function(self, val)
        LOTM.Binds.Config.showHints = val
    end
    
    -- Заголовок способностей
    local abilLabel = scroll:Add("DLabel")
    abilLabel:Dock(TOP)
    abilLabel:DockMargin(0, 10, 0, 5)
    abilLabel:SetText("СПОСОБНОСТИ (1-7)")
    abilLabel:SetFont("DermaDefaultBold")
    abilLabel:SetTextColor(colorOutLine)
    
    local abilInfo = scroll:Add("DLabel")
    abilInfo:Dock(TOP)
    abilInfo:DockMargin(0, 0, 0, 10)
    abilInfo:SetText("Используйте клавиши 1-7 для активации способностей")
    abilInfo:SetTextColor(Color(150, 150, 150))
    
    -- Заголовок дэшей
    local dashLabel = scroll:Add("DLabel")
    dashLabel:Dock(TOP)
    dashLabel:DockMargin(0, 10, 0, 5)
    dashLabel:SetText("ДЭШИ")
    dashLabel:SetFont("DermaDefaultBold")
    dashLabel:SetTextColor(colorOutLine)
    
    local dashInfo = scroll:Add("DLabel")
    dashInfo:Dock(TOP)
    dashInfo:DockMargin(0, 0, 0, 5)
    dashInfo:SetText("SHIFT + W = Дэш вперёд")
    dashInfo:SetTextColor(Color(255, 255, 255))
    
    local dashInfo2 = scroll:Add("DLabel")
    dashInfo2:Dock(TOP)
    dashInfo2:DockMargin(0, 0, 0, 5)
    dashInfo2:SetText("SHIFT + S = Дэш назад")
    dashInfo2:SetTextColor(Color(255, 255, 255))
    
    local dashInfo3 = scroll:Add("DLabel")
    dashInfo3:Dock(TOP)
    dashInfo3:DockMargin(0, 0, 0, 5)
    dashInfo3:SetText("SHIFT + A = Дэш влево")
    dashInfo3:SetTextColor(Color(255, 255, 255))
    
    local dashInfo4 = scroll:Add("DLabel")
    dashInfo4:Dock(TOP)
    dashInfo4:DockMargin(0, 0, 0, 10)
    dashInfo4:SetText("SHIFT + D = Дэш вправо")
    dashInfo4:SetTextColor(Color(255, 255, 255))
    
    -- Заголовок артефактов
    local artLabel = scroll:Add("DLabel")
    artLabel:Dock(TOP)
    artLabel:DockMargin(0, 10, 0, 5)
    artLabel:SetText("АРТЕФАКТЫ")
    artLabel:SetFont("DermaDefaultBold")
    artLabel:SetTextColor(colorOutLine)
    
    local artInfo = scroll:Add("DLabel")
    artInfo:Dock(TOP)
    artInfo:DockMargin(0, 0, 0, 5)
    artInfo:SetText("ЛКМ = Атака (3 удара, затем КД)")
    artInfo:SetTextColor(Color(255, 255, 255))
    
    local artInfo2 = scroll:Add("DLabel")
    artInfo2:Dock(TOP)
    artInfo2:DockMargin(0, 0, 0, 5)
    artInfo2:SetText("ПКМ (зажать) = Блок")
    artInfo2:SetTextColor(Color(255, 255, 255))
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then self:Remove() return true end
    end
end

-- Консольная команда
concommand.Add("lotm_binds", function()
    LOTM.Binds.OpenSettings()
end)

print("[LOTM] Binds System (Client) loaded")
