-- LOTM Skill System - Client
-- Клиентская логика: эффекты, партиклы, keybind

-- Цвета для типов урона
local LOTM_DAMAGE_COLORS = {
    [LOTM_DAMAGE_TYPES.PHYSICAL] = Color(200, 200, 200),
    [LOTM_DAMAGE_TYPES.MYSTICAL] = Color(138, 43, 226),
    [LOTM_DAMAGE_TYPES.SPIRITUAL] = Color(100, 200, 255),
    [LOTM_DAMAGE_TYPES.MENTAL] = Color(255, 100, 255),
    [LOTM_DAMAGE_TYPES.CURSE] = Color(139, 0, 139),
    [LOTM_DAMAGE_TYPES.CORRUPTION] = Color(75, 0, 130),
    [LOTM_DAMAGE_TYPES.DIVINE] = Color(255, 215, 0),
    [LOTM_DAMAGE_TYPES.SHADOW] = Color(50, 50, 50),
    [LOTM_DAMAGE_TYPES.FLAME] = Color(255, 69, 0),
    [LOTM_DAMAGE_TYPES.FROST] = Color(135, 206, 250),
    [LOTM_DAMAGE_TYPES.LIGHTNING] = Color(255, 255, 0),
    [LOTM_DAMAGE_TYPES.POISON] = Color(0, 255, 0),
    [LOTM_DAMAGE_TYPES.BLOOD] = Color(139, 0, 0),
    [LOTM_DAMAGE_TYPES.CHAOS] = Color(255, 0, 255),
    [LOTM_DAMAGE_TYPES.VOID] = Color(0, 0, 0),
}

-- Хранилище активных индикаторов урона
local damageIndicators = {}

-- Добавить индикатор урона
local function AddDamageIndicator(pos, damage, damageType)
    table.insert(damageIndicators, {
        pos = pos + Vector(math.Rand(-10, 10), math.Rand(-10, 10), 50),
        damage = math.Round(damage),
        damageType = damageType,
        startTime = CurTime(),
        lifetime = 2,
        color = LOTM_DAMAGE_COLORS[damageType] or Color(255, 255, 255),
    })
end

-- Отрисовка индикаторов урона
hook.Add("PostDrawTranslucentRenderables", "LOTM_DrawDamageIndicators", function()
    for i = #damageIndicators, 1, -1 do
        local indicator = damageIndicators[i]
        local elapsed = CurTime() - indicator.startTime
        
        if elapsed >= indicator.lifetime then
            table.remove(damageIndicators, i)
        else
            local progress = elapsed / indicator.lifetime
            local alpha = (1 - progress) * 255
            local rise = progress * 50
            
            local drawPos = indicator.pos + Vector(0, 0, rise)
            local screenPos = drawPos:ToScreen()
            
            if screenPos.visible then
                local color = ColorAlpha(indicator.color, alpha)
                local scale = 1 + progress * 0.5
                
                draw.SimpleText(
                    "-" .. indicator.damage,
                    "DermaLarge",
                    screenPos.x,
                    screenPos.y,
                    color,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            end
        end
    end
end)

-- Получение информации о попадании
net.Receive("LOTM_SkillHit", function()
    local target = net.ReadEntity()
    local damage = net.ReadFloat()
    local damageType = net.ReadUInt(8)
    local particleName = net.ReadString()
    
    if IsValid(target) then
        local hitPos = target:GetPos() + Vector(0, 0, 40)
        
        -- Индикатор урона
        AddDamageIndicator(hitPos, damage, damageType)
        
        -- Партикл попадания
        if particleName ~= "" then
            ParticleEffect(particleName, hitPos, Angle(0, 0, 0))
        end
        
        -- Партикл ранения (кровь)
        ParticleEffect("blood_impact_red_01", hitPos, Angle(0, 0, 0))
    end
end)

-- Получение информации о касте скилла
net.Receive("LOTM_SkillCast", function()
    local skillID = net.ReadString()
    local pos = net.ReadVector()
    local angles = net.ReadAngle()
    local caster = net.ReadEntity()
    
    local skillData = LOTM_GetSkill(skillID)
    if not skillData then return end
    
    -- Партикл каста
    if skillData.particleEffect ~= "" then
        ParticleEffect(skillData.particleEffect, pos, angles)
    end
    
    -- Звук каста
    if skillData.castSound then
        sound.Play(skillData.castSound, pos, 75, 100, 1)
    end
end)

-- Система привязки клавиш
local playerSkills = {}
local skillCooldowns = {}

-- Установить скилл на слот
function LOTM_SetSkillSlot(slot, skillID)
    if slot < 1 or slot > 9 then return end
    playerSkills[slot] = skillID
end

-- Получить скилл со слота
function LOTM_GetSkillSlot(slot)
    return playerSkills[slot]
end

-- Проверка кулдауна
function LOTM_IsSkillOnCooldown(skillID)
    local cooldownEnd = skillCooldowns[skillID]
    if not cooldownEnd then return false end
    return CurTime() < cooldownEnd
end

-- Получить оставшееся время кулдауна
function LOTM_GetSkillCooldown(skillID)
    local cooldownEnd = skillCooldowns[skillID]
    if not cooldownEnd then return 0 end
    return math.max(0, cooldownEnd - CurTime())
end

-- Установить кулдаун
function LOTM_SetSkillCooldown(skillID, duration)
    skillCooldowns[skillID] = CurTime() + duration
end

-- Применить скилл со слота
local function UseSkillSlot(slot)
    local skillID = LOTM_GetSkillSlot(slot)
    if not skillID then return end
    
    local skillData = LOTM_GetSkill(skillID)
    if not skillData then return end
    
    if LOTM_IsSkillOnCooldown(skillID) then
        chat.AddText(Color(255, 0, 0), "[Скилл] ", color_white, "На кулдауне: " .. math.Round(LOTM_GetSkillCooldown(skillID), 1) .. "с")
        return
    end
    
    -- Отправляем запрос на сервер
    net.Start("LOTM_UseSkill")
        net.WriteString(skillID)
    net.SendToServer()
    
    -- Устанавливаем кулдаун
    LOTM_SetSkillCooldown(skillID, skillData.cooldown)
end

-- Бинды клавиш для слотов 1-9
hook.Add("PlayerButtonDown", "LOTM_SkillKeybinds", function(ply, button)
    if ply ~= LocalPlayer() then return end
    
    -- Цифры 1-9
    if button >= KEY_1 and button <= KEY_9 then
        local slot = button - KEY_1 + 1
        UseSkillSlot(slot)
    end
end)

-- HUD для отображения скиллов
hook.Add("HUDPaint", "LOTM_SkillBar", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local scrw, scrh = ScrW(), ScrH()
    local barWidth = 500
    local barHeight = 60
    local barX = scrw / 2 - barWidth / 2
    local barY = scrh - 100
    local slotSize = 50
    local slotSpacing = 5
    
    -- Фон панели
    draw.RoundedBox(8, barX, barY, barWidth, barHeight, Color(0, 0, 0, 180))
    
    -- Слоты скиллов
    for i = 1, 9 do
        local slotX = barX + 10 + (i - 1) * (slotSize + slotSpacing)
        local slotY = barY + 5
        
        local skillID = LOTM_GetSkillSlot(i)
        local hasSkill = skillID ~= nil
        
        -- Фон слота
        draw.RoundedBox(4, slotX, slotY, slotSize, slotSize, hasSkill and Color(50, 50, 50, 200) or Color(30, 30, 30, 150))
        
        if hasSkill then
            local skillData = LOTM_GetSkill(skillID)
            if skillData then
                -- Номер слота
                draw.SimpleText(tostring(i), "DermaDefault", slotX + 5, slotY + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                -- Кулдаун
                if LOTM_IsSkillOnCooldown(skillID) then
                    local cooldown = LOTM_GetSkillCooldown(skillID)
                    local progress = 1 - (cooldown / skillData.cooldown)
                    
                    draw.RoundedBox(4, slotX, slotY, slotSize, slotSize, Color(0, 0, 0, 150))
                    draw.RoundedBox(4, slotX, slotY + slotSize * (1 - progress), slotSize, slotSize * progress, Color(100, 100, 100, 100))
                    
                    draw.SimpleText(math.Round(cooldown, 1), "DermaDefaultBold", slotX + slotSize / 2, slotY + slotSize / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        else
            -- Пустой слот
            draw.SimpleText(tostring(i), "DermaDefault", slotX + slotSize / 2, slotY + slotSize / 2, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)

print("[LOTM Skills] Клиентская часть загружена")