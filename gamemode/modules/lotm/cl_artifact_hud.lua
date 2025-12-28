-- LOTM Artifact HUD v1.0
-- Отображение клавиш артефакта в правом нижнем углу при держании артефакта
-- Интеграция со способностями артефакта

LOTM = LOTM or {}
LOTM.ArtifactHUD = LOTM.ArtifactHUD or {}

-- =============================================
-- ЦВЕТА И НАСТРОЙКИ
-- =============================================
local colorOutLine = Color(211, 25, 202)
local colorBG = Color(15, 15, 20, 200)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorReady = Color(100, 255, 100)
local colorCooldown = Color(255, 100, 100)
local colorKey = Color(255, 215, 100)

LOTM.ArtifactHUD.Enabled = true
LOTM.ArtifactHUD.AnimAlpha = 0

-- Материалы
local matGradient = Material("vgui/gradient-l")

-- =============================================
-- ПРОВЕРКА АРТЕФАКТА В РУКАХ
-- =============================================
local function GetHeldArtifact(ply)
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) then return nil end
    
    -- Проверяем есть ли конфиг артефакта
    if weapon.ArtifactConfig then
        return weapon.ArtifactConfig, weapon
    end
    
    -- Проверяем по классу оружия
    local class = weapon:GetClass()
    if string.find(class, "lotm_") or string.find(class, "artifact_") then
        -- Пытаемся найти конфиг в реестре
        local id = string.gsub(class, "weapon_", "")
        if LOTM.Weapons and LOTM.Weapons.Get then
            local config = LOTM.Weapons.Get(id)
            if config then return config, weapon end
        end
    end
    
    return nil
end

-- =============================================
-- ПОЛУЧЕНИЕ НАЗВАНИЯ КЛАВИШИ
-- =============================================
local function GetKeyName(key)
    if not key or key == 0 then return "???" end
    local name = input.GetKeyName(key)
    return name and string.upper(name) or "???"
end

-- =============================================
-- ОТРИСОВКА HUD
-- =============================================
hook.Add("HUDPaint", "LOTM.ArtifactHUD.Draw", function()
    if not LOTM.ArtifactHUD.Enabled then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local artifactConfig, weapon = GetHeldArtifact(ply)
    
    -- Плавная анимация появления/исчезновения
    local targetAlpha = artifactConfig and 255 or 0
    LOTM.ArtifactHUD.AnimAlpha = Lerp(FrameTime() * 8, LOTM.ArtifactHUD.AnimAlpha, targetAlpha)
    
    if LOTM.ArtifactHUD.AnimAlpha < 5 then return end
    
    local scrw, scrh = ScrW(), ScrH()
    local alpha = LOTM.ArtifactHUD.AnimAlpha
    
    -- Размеры панели
    local panelW = 280
    local panelH = 160
    local panelX = scrw - panelW - 20
    local panelY = scrh - panelH - 20
    
    -- Фон панели
    draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(colorBG.r, colorBG.g, colorBG.b, alpha * 0.8))
    
    -- Рамка
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.8)
    surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 1)
    
    -- Заголовок - название артефакта
    local artifactName = artifactConfig and artifactConfig.name or "Артефакт"
    draw.SimpleText(artifactName, "DermaDefaultBold", panelX + panelW / 2, panelY + 15, 
        Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Разделитель
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.5)
    surface.DrawRect(panelX + 15, panelY + 30, panelW - 30, 1)
    
    local yOffset = panelY + 42
    local lineH = 22
    
    -- =============================================
    -- ОТОБРАЖЕНИЕ УПРАВЛЕНИЯ
    -- =============================================
    
    -- ЛКМ - Атака
    draw.SimpleText("[ЛКМ]", "DermaDefaultBold", panelX + 15, yOffset, 
        Color(colorKey.r, colorKey.g, colorKey.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
    local attackInfo = "Атака"
    if artifactConfig and artifactConfig.attacks then
        local attackCount = #artifactConfig.attacks
        attackInfo = attackInfo .. " (x" .. attackCount .. ")"
    end
    draw.SimpleText(attackInfo, "DermaDefault", panelX + 65, yOffset, 
        Color(colorText.r, colorText.g, colorText.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    yOffset = yOffset + lineH
    
    -- ПКМ - Блок (если доступен)
    if not artifactConfig or artifactConfig.canBlock ~= false then
        draw.SimpleText("[ПКМ]", "DermaDefaultBold", panelX + 15, yOffset, 
            Color(colorKey.r, colorKey.g, colorKey.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Блок", "DermaDefault", panelX + 65, yOffset, 
            Color(colorText.r, colorText.g, colorText.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        yOffset = yOffset + lineH
    end
    
    -- Клавиша использования артефакта
    local artifactKey = KEY_H
    if LOTM.Keybinds and LOTM.Keybinds.GetBind then
        artifactKey = LOTM.Keybinds.GetBind("artifact_use") or KEY_H
    elseif GetConVar("lotm_bind_artifact") then
        artifactKey = GetConVar("lotm_bind_artifact"):GetInt()
    end
    
    local keyName = GetKeyName(artifactKey)
    draw.SimpleText("[" .. keyName .. "]", "DermaDefaultBold", panelX + 15, yOffset, 
        Color(colorKey.r, colorKey.g, colorKey.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
    -- Проверяем кулдаун способности артефакта
    local artifactAbilityText = "Способность"
    local abilityColor = colorText
    
    if LOTM.Artifacts and LOTM.Artifacts.GetCooldownRemaining then
        local cdRemaining = LOTM.Artifacts.GetCooldownRemaining(ply)
        if cdRemaining > 0 then
            artifactAbilityText = "КД: " .. string.format("%.1f", cdRemaining) .. "с"
            abilityColor = colorCooldown
        else
            artifactAbilityText = "Способность (готово)"
            abilityColor = colorReady
        end
    end
    
    draw.SimpleText(artifactAbilityText, "DermaDefault", panelX + 65, yOffset, 
        Color(abilityColor.r, abilityColor.g, abilityColor.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    yOffset = yOffset + lineH
    
    -- Клавиша дэша
    local dodgeKey = KEY_LALT
    if LOTM.Keybinds and LOTM.Keybinds.GetBind then
        dodgeKey = LOTM.Keybinds.GetBind("dodge") or KEY_LALT
    elseif GetConVar("lotm_bind_dodge") then
        dodgeKey = GetConVar("lotm_bind_dodge"):GetInt()
    end
    
    if not artifactConfig or artifactConfig.canDash ~= false then
        local dodgeKeyName = GetKeyName(dodgeKey)
        draw.SimpleText("[" .. dodgeKeyName .. "]", "DermaDefaultBold", panelX + 15, yOffset, 
            Color(colorKey.r, colorKey.g, colorKey.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Проверяем кулдаун дэша
        local dashText = "Дэш"
        local dashColor = colorText
        
        if LOTM.Dodge and LOTM.Dodge.LastUse then
            local cdRemaining = (LOTM.Dodge.LastUse or 0) - CurTime()
            if cdRemaining > 0 then
                dashText = "Дэш КД: " .. string.format("%.1f", cdRemaining) .. "с"
                dashColor = colorCooldown
            else
                dashText = "Дэш (готово)"
                dashColor = colorReady
            end
        end
        
        draw.SimpleText(dashText, "DermaDefault", panelX + 65, yOffset, 
            Color(dashColor.r, dashColor.g, dashColor.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        yOffset = yOffset + lineH
    end
    
    -- =============================================
    -- ОТОБРАЖЕНИЕ КОМБО АТАК (если есть)
    -- =============================================
    if IsValid(weapon) and weapon.CurrentCombo then
        local comboCount = weapon.CurrentCombo or 0
        local maxCombo = artifactConfig and artifactConfig.attacksBeforeCooldown or 3
        
        -- Индикатор комбо внизу панели
        local comboBarY = panelY + panelH - 15
        local comboBarW = panelW - 30
        local comboBarH = 6
        
        -- Фон полосы комбо
        draw.RoundedBox(3, panelX + 15, comboBarY, comboBarW, comboBarH, Color(40, 40, 50, alpha))
        
        -- Заполнение полосы комбо
        local comboProgress = comboCount / maxCombo
        local fillW = comboBarW * comboProgress
        
        local comboColor = comboCount >= maxCombo and colorCooldown or colorOutLine
        draw.RoundedBox(3, panelX + 15, comboBarY, fillW, comboBarH, Color(comboColor.r, comboColor.g, comboColor.b, alpha))
        
        -- Текст комбо
        draw.SimpleText(comboCount .. "/" .. maxCombo, "DermaDefault", panelX + panelW - 20, comboBarY - 8, 
            Color(colorTextDim.r, colorTextDim.g, colorTextDim.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end)

-- =============================================
-- КОНСОЛЬНЫЕ КОМАНДЫ
-- =============================================
concommand.Add("lotm_artifact_hud_toggle", function()
    LOTM.ArtifactHUD.Enabled = not LOTM.ArtifactHUD.Enabled
    LocalPlayer():ChatPrint("[LOTM] Artifact HUD " .. (LOTM.ArtifactHUD.Enabled and "включен" or "выключен"))
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Artifact HUD v1.0 loaded\n")

