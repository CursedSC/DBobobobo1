-- LOTM Ability HUD v2.0
-- HUD способностей БЕЗ полоски энергии
-- Компактные слоты способностей внизу по центру

LOTM = LOTM or {}
LOTM.AbilityHUD = LOTM.AbilityHUD or {}

-- Цвета
local colorOutLine = Color(211, 25, 202)
local colorBG = Color(15, 15, 20, 200)
local colorSlotEmpty = Color(40, 40, 50, 180)
local colorSlotFilled = Color(60, 40, 80, 220)
local colorSlotCooldown = Color(30, 30, 40, 220)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorCharge = Color(100, 200, 255)
local colorReady = Color(100, 255, 100)

-- Настройки HUD
LOTM.AbilityHUD.SlotSize = 50
LOTM.AbilityHUD.SlotSpacing = 6
LOTM.AbilityHUD.YOffset = 80 -- Отступ снизу
LOTM.AbilityHUD.Enabled = true

-- Материалы иконок
local iconCache = {}
local function GetIcon(path)
    if not path then return nil end
    if not iconCache[path] then
        local mat = Material(path, "smooth")
        if mat:IsError() then
            iconCache[path] = nil
        else
            iconCache[path] = mat
        end
    end
    return iconCache[path]
end

-- Отрисовка одного слота
local function DrawAbilitySlot(x, y, size, slot, ability, ply)
    -- Фон слота
    local bgColor = colorSlotEmpty
    local isReady = true
    local cooldownText = nil
    local chargeText = nil
    
    if ability then
        bgColor = colorSlotFilled
        
        -- Проверка зарядов или кулдауна
        if LOTM.Abilities then
            if ability.maxCharges and ability.maxCharges > 1 then
                local charges = LOTM.Abilities.GetCharges(ply, ability.id)
                chargeText = charges .. "/" .. ability.maxCharges
                
                if charges <= 0 then
                    isReady = false
                    bgColor = colorSlotCooldown
                    local regenTime = LOTM.Abilities.GetChargeRegenRemaining(ply, ability.id)
                    if regenTime > 0 then
                        cooldownText = string.format("%.1f", regenTime)
                    end
                end
            else
                local cdRemaining = LOTM.Abilities.GetCooldownRemaining(ply, ability.id)
                if cdRemaining > 0 then
                    isReady = false
                    bgColor = colorSlotCooldown
                    cooldownText = string.format("%.1f", cdRemaining)
                end
            end
        end
    end
    
    -- Рисуем фон
    draw.RoundedBox(6, x, y, size, size, bgColor)
    
    if ability then
        -- Иконка способности
        local icon = GetIcon(ability.icon)
        if icon then
            surface.SetDrawColor(255, 255, 255, isReady and 255 or 100)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(x + 4, y + 4, size - 8, size - 8)
        else
            -- Первые буквы названия
            local shortName = string.sub(ability.name, 1, 2)
            draw.SimpleText(shortName, "DermaDefaultBold", x + size/2, y + size/2, 
                isReady and colorText or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Оверлей кулдауна (затемнение снизу вверх)
        if not isReady and cooldownText then
            local maxCD = ability.cooldown or ability.chargeRegenTime or 1
            local cdRemaining = LOTM.Abilities.GetCooldownRemaining(ply, ability.id)
            if ability.maxCharges and ability.maxCharges > 1 then
                cdRemaining = LOTM.Abilities.GetChargeRegenRemaining(ply, ability.id)
                maxCD = ability.chargeRegenTime or 5
            end
            
            local progress = cdRemaining / maxCD
            local overlayH = size * progress
            
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(x, y + (size - overlayH), size, overlayH)
            
            -- Текст кулдауна
            draw.SimpleText(cooldownText, "DermaDefaultBold", x + size/2, y + size/2, 
                colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Заряды (справа вверху)
        if chargeText then
            draw.SimpleText(chargeText, "DermaDefault", x + size - 3, y + 3, 
                colorCharge, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
        end
        
        -- Рамка (подсветка если готово)
        if isReady then
            surface.SetDrawColor(colorReady.r, colorReady.g, colorReady.b, 100)
        else
            surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        end
        surface.DrawOutlinedRect(x, y, size, size, 1)
    else
        -- Пустой слот
        surface.SetDrawColor(60, 60, 70, 50)
        surface.DrawOutlinedRect(x, y, size, size, 1)
    end
    
    -- Номер слота (снизу слева)
    draw.SimpleText("NUM" .. slot, "DermaDefault", x + 3, y + size - 12, 
        Color(100, 100, 110), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

-- Главный хук отрисовки
hook.Add("HUDPaint", "LOTM.AbilityHUD.Draw", function()
    if not LOTM.AbilityHUD.Enabled then return end
    if not LOTM.Abilities then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Проверяем, есть ли путь у игрока
    local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
    if playerPathway == 0 then return end -- Не показываем HUD если игрок не бейондер
    
    local scrw, scrh = ScrW(), ScrH()
    local slotSize = LOTM.AbilityHUD.SlotSize
    local spacing = LOTM.AbilityHUD.SlotSpacing
    local maxSlots = LOTM.Abilities.MAX_SLOTS or 7
    
    local totalWidth = maxSlots * slotSize + (maxSlots - 1) * spacing
    local startX = (scrw - totalWidth) / 2
    local startY = scrh - LOTM.AbilityHUD.YOffset - slotSize
    
    -- Получаем способности игрока
    local abilities = LOTM.Abilities.GetPlayerAbilities(ply)
    
    -- Рисуем слоты
    for slot = 1, maxSlots do
        local x = startX + (slot - 1) * (slotSize + spacing)
        local y = startY
        
        local ability = LOTM.Abilities.GetSlot(ply, slot)
        DrawAbilitySlot(x, y, slotSize, slot, ability, ply)
    end
    
    -- Информация о последовательности (над слотами)
    local playerSeq = ply:GetNWInt("LOTM_Sequence", 9)
    local seqText = "Seq " .. playerSeq
    local digestion = ply:GetNWFloat("LOTM_Digestion", 0)
    
    if digestion > 0 and digestion < 1 then
        seqText = seqText .. " | Переваривание: " .. math.floor(digestion * 100) .. "%"
    end
    
    draw.SimpleText(seqText, "DermaDefault", scrw / 2, startY - 15, 
        colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    
    -- Активная аура (если есть)
    local activeAura = ply:GetNWString("LOTM_ActiveAura", "")
    if activeAura ~= "" and LOTM.Auras then
        local aura = LOTM.Auras.Get(activeAura)
        if aura then
            draw.SimpleText("⟳ " .. aura.name, "DermaDefault", scrw / 2, startY - 30, 
                Color(100, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
    end
end)

-- Отображение ночного зрения
hook.Add("RenderScreenspaceEffects", "LOTM.NightVision", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    if ply:GetNWBool("LOTM_NightVision", false) then
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0.1,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.2,
            ["$pp_colour_contrast"] = 1.2,
            ["$pp_colour_colour"] = 0.8,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
    end
end)

-- Отображение чувства опасности
hook.Add("HUDPaint", "LOTM.DangerSense", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    if ply:GetNWBool("LOTM_DangerSense", false) then
        local scrw, scrh = ScrW(), ScrH()
        
        -- Ищем угрозы
        local threats = {}
        for _, p in ipairs(player.GetAll()) do
            if p ~= ply and p:Alive() then
                local dist = p:GetPos():Distance(ply:GetPos())
                if dist < 500 then
                    -- Проверяем, смотрит ли игрок на нас
                    local toUs = (ply:GetPos() - p:GetPos()):GetNormalized()
                    local theirForward = p:GetAimVector()
                    local dot = toUs:Dot(theirForward)
                    
                    if dot > 0.7 then -- Смотрит примерно в нашу сторону
                        table.insert(threats, {
                            player = p,
                            distance = dist,
                            danger = dot
                        })
                    end
                end
            end
        end
        
        -- Рисуем предупреждения
        if #threats > 0 then
            local pulse = math.abs(math.sin(CurTime() * 4))
            local alpha = 100 + pulse * 100
            
            -- Красная виньетка
            surface.SetDrawColor(255, 0, 0, alpha * 0.3)
            surface.DrawRect(0, 0, 20, scrh)
            surface.DrawRect(scrw - 20, 0, 20, scrh)
            surface.DrawRect(0, 0, scrw, 20)
            surface.DrawRect(0, scrh - 20, scrw, 20)
            
            draw.SimpleText("⚠ ОПАСНОСТЬ", "Comfortaa Bold X20", scrw / 2, 50, 
                Color(255, 100, 100, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)

-- Консольная команда для переключения HUD
concommand.Add("lotm_hud_toggle", function()
    LOTM.AbilityHUD.Enabled = not LOTM.AbilityHUD.Enabled
    LocalPlayer():ChatPrint("[LOTM] HUD " .. (LOTM.AbilityHUD.Enabled and "включен" or "выключен"))
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Ability HUD v2.0 loaded (no energy bar)\n")
