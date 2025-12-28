-- LOTM Combat HUD v2.0
-- Боевой интерфейс как на изображении
-- Гексагональные иконки способностей

LOTM = LOTM or {}
LOTM.CombatHUD = LOTM.CombatHUD or {}

-- =============================================
-- ЦВЕТОВАЯ ПАЛИТРА
-- =============================================
local colorOutLine = Color(211, 25, 202)
local colorOutLineGlow = Color(255, 50, 255, 150)
local colorBG = Color(20, 15, 25, 230)
local colorBGLight = Color(40, 30, 50, 200)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorReady = Color(100, 255, 100)
local colorCooldown = Color(255, 80, 80)
local colorKey = Color(255, 255, 255)
local colorKeyBG = Color(30, 30, 40, 240)
local colorShift = Color(255, 200, 50)

-- =============================================
-- НАСТРОЙКИ
-- =============================================
LOTM.CombatHUD.Enabled = true
LOTM.CombatHUD.AnimAlpha = 0
LOTM.CombatHUD.ComboCount = 0
LOTM.CombatHUD.ComboTime = 0
LOTM.CombatHUD.COMBO_TIMEOUT = 3.0

-- Способности в порядке отображения
local COMBAT_ABILITIES = {
    {id = "primary",        key = "E",  shift = false, icon = "icon16/lightning.png",     defaultIcon = "⚔"},
    {id = "primary_shift",  key = "E",  shift = true,  icon = "icon16/lightning_add.png", defaultIcon = "⚡"},
    {id = "secondary",      key = "R",  shift = false, icon = "icon16/shield.png",        defaultIcon = "🛡"},
    {id = "secondary_shift",key = "R",  shift = true,  icon = "icon16/shield_add.png",    defaultIcon = "⛨"},
    {id = "ultimate",       key = "F",  shift = false, icon = "icon16/star.png",          defaultIcon = "★"},
    {id = "ultimate_shift", key = "F",  shift = true,  icon = "icon16/asterisk_yellow.png", defaultIcon = "✦"},
}

-- =============================================
-- МАТЕРИАЛЫ
-- =============================================
local matHexBorder = Material("vgui/gradient-u")
local matGlow = Material("sprites/light_glow02_add")

-- =============================================
-- ФУНКЦИИ ОТРИСОВКИ
-- =============================================

-- Рисуем гексагональный слот
local function DrawHexSlot(x, y, size, bgColor, borderColor, glowIntensity)
    local hw = size / 2
    local hh = size / 2 * 0.866 -- cos(30)
    
    local vertices = {
        {x = x, y = y - hh},           -- верх
        {x = x + hw, y = y - hh/2},    -- право-верх
        {x = x + hw, y = y + hh/2},    -- право-низ
        {x = x, y = y + hh},           -- низ
        {x = x - hw, y = y + hh/2},    -- лево-низ
        {x = x - hw, y = y - hh/2},    -- лево-верх
    }
    
    -- Свечение
    if glowIntensity > 0 then
        surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, 50 * glowIntensity)
        surface.SetMaterial(matGlow)
        surface.DrawTexturedRect(x - size, y - size, size * 2, size * 2)
    end
    
    -- Фон (через полигон)
    surface.SetDrawColor(bgColor)
    draw.NoTexture()
    surface.DrawPoly(vertices)
    
    -- Граница (линиями)
    surface.SetDrawColor(borderColor)
    for i = 1, #vertices do
        local v1 = vertices[i]
        local v2 = vertices[i % #vertices + 1]
        surface.DrawLine(v1.x, v1.y, v2.x, v2.y)
    end
end

-- Рисуем иконку способности
local function DrawAbilityIcon(x, y, iconPath, fallbackText, size, alpha)
    local mat = Material(iconPath)
    if mat and not mat:IsError() then
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(mat)
        local iconSize = size * 0.5
        surface.DrawTexturedRect(x - iconSize/2, y - iconSize/2, iconSize, iconSize)
    else
        -- Fallback текст
        draw.SimpleText(fallbackText, "DermaLarge", x, y, 
            Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Рисуем индикатор клавиши
local function DrawKeyBadge(x, y, key, isShift, isActive, alpha)
    local text = isShift and (key .. "+") or key
    local tw = surface.GetTextSize(text)
    local padding = 6
    local w = tw + padding * 2
    local h = 20
    
    -- Фон бейджа
    local bgColor = isActive and colorOutLine or colorKeyBG
    draw.RoundedBox(4, x - w/2, y - h/2, w, h, Color(bgColor.r, bgColor.g, bgColor.b, alpha))
    
    -- Рамка при активности
    if isActive then
        surface.SetDrawColor(255, 255, 255, alpha * 0.5)
        surface.DrawOutlinedRect(x - w/2, y - h/2, w, h, 1)
    end
    
    -- Текст
    local textColor = isShift and colorShift or colorKey
    draw.SimpleText(text, "DermaDefaultBold", x, y, 
        Color(textColor.r, textColor.g, textColor.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- =============================================
-- ПОЛУЧЕНИЕ ДАННЫХ
-- =============================================
local function GetCombatStyle()
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end
    
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) then return nil end
    
    -- Стиль оружия
    if weapon.CombatStyleID and LOTM.Combat and LOTM.Combat.GetStyle then
        return LOTM.Combat.GetStyle(weapon.CombatStyleID)
    end
    
    -- Артефакт
    if weapon.ArtifactConfig and weapon.ArtifactConfig.combatStyleId then
        return LOTM.Combat.GetStyle(weapon.ArtifactConfig.combatStyleId)
    end
    
    -- Дефолтный
    if LOTM.Combat and LOTM.Combat.GetStyle then
        return LOTM.Combat.GetStyle("default_melee")
    end
    
    return nil
end

local function IsHoldingCombatWeapon()
    local ply = LocalPlayer()
    if not IsValid(ply) then return false end
    
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) then return false end
    
    local class = weapon:GetClass()
    local excludedClasses = {
        "hands", "gmod_hands", "weapon_physgun", "gmod_tool", 
        "weapon_physcannon", "gmod_camera", "weapon_fists"
    }
    
    for _, excluded in ipairs(excludedClasses) do
        if class == excluded then return false end
    end
    
    return true
end

-- =============================================
-- ОСНОВНАЯ ОТРИСОВКА
-- =============================================
hook.Add("HUDPaint", "LOTM.CombatHUD.Draw", function()
    if not LOTM.CombatHUD.Enabled then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local holdingWeapon = IsHoldingCombatWeapon()
    
    -- Плавная анимация появления
    local targetAlpha = holdingWeapon and 1 or 0
    LOTM.CombatHUD.AnimAlpha = Lerp(FrameTime() * 8, LOTM.CombatHUD.AnimAlpha, targetAlpha)
    
    if LOTM.CombatHUD.AnimAlpha < 0.01 then return end
    
    local alpha = LOTM.CombatHUD.AnimAlpha * 255
    local scrw, scrh = ScrW(), ScrH()
    
    -- Проверка Shift
    local shiftHeld = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
    
    -- Позиция панели (правый край)
    local panelX = scrw - 120
    local panelY = scrh / 2 - 180
    
    -- Получаем стиль
    local style = GetCombatStyle()
    
    -- =============================================
    -- COMBO COUNTER
    -- =============================================
    if LOTM.CombatHUD.ComboCount > 0 and CurTime() < LOTM.CombatHUD.ComboTime + LOTM.CombatHUD.COMBO_TIMEOUT then
        local comboY = panelY - 60
        local comboPulse = math.sin(CurTime() * 8) * 0.1 + 1
        local comboSize = 40 * comboPulse
        
        -- Круг под цифрой
        draw.RoundedBox(20, panelX - 30, comboY - 25, 60, 50, 
            Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.6))
        
        -- Цифра комбо
        draw.SimpleText(tostring(LOTM.CombatHUD.ComboCount), "Comfortaa Bold X40", 
            panelX, comboY, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- ABILITY SLOTS
    -- =============================================
    local slotSize = 70
    local slotSpacing = 85
    
    for i, abilityInfo in ipairs(COMBAT_ABILITIES) do
        local slotY = panelY + (i - 1) * slotSpacing
        
        -- Данные способности
        local ability = style and style.abilities[abilityInfo.id]
        local isEnabled = ability and ability.enabled
        local isShiftVariant = abilityInfo.shift
        
        -- Кулдаун
        local cdRemaining = 0
        if LOTM.Combat and LOTM.Combat.GetLocalCooldown then
            cdRemaining = LOTM.Combat.GetLocalCooldown(abilityInfo.id)
        end
        local isReady = cdRemaining <= 0
        local cdPercent = 1 - math.Clamp(cdRemaining / (ability and ability.cooldown or 5), 0, 1)
        
        -- Активность (подсвечиваем если нужная клавиша)
        local isHighlighted = (isShiftVariant == shiftHeld) and isEnabled
        
        -- Цвета
        local borderColor = colorOutLine
        if not isEnabled then
            borderColor = Color(60, 60, 70, alpha)
        elseif not isReady then
            borderColor = Color(colorCooldown.r, colorCooldown.g, colorCooldown.b, alpha)
        elseif isHighlighted then
            borderColor = Color(colorOutLineGlow.r, colorOutLineGlow.g, colorOutLineGlow.b, alpha)
        end
        
        local bgColor = colorBG
        if isHighlighted and isReady then
            bgColor = Color(colorBGLight.r, colorBGLight.g, colorBGLight.b, alpha)
        end
        
        -- Рисуем гексагон
        local glowIntensity = isHighlighted and isReady and 1 or 0
        DrawHexSlot(panelX, slotY, slotSize, 
            Color(bgColor.r, bgColor.g, bgColor.b, alpha * 0.9), 
            borderColor, glowIntensity)
        
        -- Иконка способности
        local iconAlpha = isEnabled and alpha or alpha * 0.3
        DrawAbilityIcon(panelX, slotY, abilityInfo.icon, abilityInfo.defaultIcon, slotSize, iconAlpha)
        
        -- Прогресс кулдауна (дуга)
        if not isReady and isEnabled then
            -- Затемнение
            DrawHexSlot(panelX, slotY, slotSize * 0.9, 
                Color(0, 0, 0, alpha * 0.6), 
                Color(0, 0, 0, 0), 0)
            
            -- Текст кулдауна
            draw.SimpleText(string.format("%.1f", cdRemaining), "DermaDefaultBold", 
                panelX, slotY + 5, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Бейдж с клавишей (слева от гексагона)
        local keyX = panelX - slotSize/2 - 20
        local keyY = slotY
        DrawKeyBadge(keyX, keyY, abilityInfo.key, isShiftVariant, isHighlighted and isReady, alpha)
        
        -- Название способности (справа, при наведении или подсветке)
        if isHighlighted and isEnabled then
            local abilityName = ability and ability.name or "Способность"
            local nameX = panelX + slotSize/2 + 10
            
            -- Фон для текста
            local tw = surface.GetTextSize(abilityName)
            draw.RoundedBox(4, nameX - 5, slotY - 10, tw + 15, 20, 
                Color(0, 0, 0, alpha * 0.7))
            
            draw.SimpleText(abilityName, "DermaDefault", nameX, slotY, 
                Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Урон
            if ability and ability.damage then
                draw.SimpleText(ability.damage .. " урона", "DermaDefault", nameX, slotY + 15, 
                    Color(255, 150, 100, alpha * 0.8), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- =============================================
    -- ПОДСКАЗКА SHIFT
    -- =============================================
    local hintY = panelY + #COMBAT_ABILITIES * slotSpacing + 20
    local hintText = shiftHeld and "SHIFT АКТИВЕН" or "Зажми SHIFT"
    local hintColor = shiftHeld and colorShift or colorTextDim
    
    draw.SimpleText(hintText, "DermaDefault", panelX, hintY, 
        Color(hintColor.r, hintColor.g, hintColor.b, alpha * 0.8), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- =============================================
    -- DASH INFO (внизу)
    -- =============================================
    local dashY = hintY + 30
    local dashCd = 0
    if LOTM.Dash and LOTM.Dash.LastTime then
        local dashCooldown = LOTM.Dash.Config and LOTM.Dash.Config.cooldown or 1.5
        dashCd = math.max(0, (LOTM.Dash.LastTime + dashCooldown) - CurTime())
    end
    
    local dashText = dashCd > 0 and string.format("[ALT] %.1fs", dashCd) or "[ALT] Дэш"
    local dashColor = dashCd > 0 and colorCooldown or colorReady
    
    draw.RoundedBox(4, panelX - 40, dashY - 12, 80, 24, 
        Color(colorKeyBG.r, colorKeyBG.g, colorKeyBG.b, alpha * 0.8))
    draw.SimpleText(dashText, "DermaDefault", panelX, dashY, 
        Color(dashColor.r, dashColor.g, dashColor.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

-- =============================================
-- ОБРАБОТКА ВВОДА
-- =============================================
hook.Add("PlayerButtonDown", "LOTM.CombatHUD.Input", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end
    if LocalPlayer():IsTyping() then return end
    
    if not IsHoldingCombatWeapon() then return end
    
    local shiftHeld = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
    local abilityType = nil
    
    -- E - Primary
    if button == KEY_E then
        abilityType = shiftHeld and "primary_shift" or "primary"
    end
    
    -- R - Secondary
    if button == KEY_R then
        abilityType = shiftHeld and "secondary_shift" or "secondary"
    end
    
    -- F - Ultimate
    if button == KEY_F then
        abilityType = shiftHeld and "ultimate_shift" or "ultimate"
    end
    
    if abilityType then
        -- Увеличиваем комбо
        LOTM.CombatHUD.ComboCount = LOTM.CombatHUD.ComboCount + 1
        LOTM.CombatHUD.ComboTime = CurTime()
        
        -- Отправляем запрос
        if LOTM.Combat and LOTM.Combat.RequestAbility then
            LOTM.Combat.RequestAbility(abilityType)
        end
    end
end)

-- Сброс комбо при таймауте
hook.Add("Think", "LOTM.CombatHUD.ComboReset", function()
    if LOTM.CombatHUD.ComboCount > 0 then
        if CurTime() > LOTM.CombatHUD.ComboTime + LOTM.CombatHUD.COMBO_TIMEOUT then
            LOTM.CombatHUD.ComboCount = 0
        end
    end
end)

-- =============================================
-- КОНСОЛЬНЫЕ КОМАНДЫ
-- =============================================
concommand.Add("lotm_combat_hud", function()
    LOTM.CombatHUD.Enabled = not LOTM.CombatHUD.Enabled
    LocalPlayer():ChatPrint("[LOTM] Combat HUD " .. (LOTM.CombatHUD.Enabled and "включен" or "выключен"))
end)

MsgC(Color(100, 200, 255), "[LOTM] ", Color(255, 255, 255), "Combat HUD v2.0 loaded\n")
