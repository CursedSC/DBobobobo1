<<<<<<< HEAD
-- Система управления скоростью передвижения
-- Поддерживает зелья, баффы и боевой режим

dbt = dbt or {}
dbt.movespeed = dbt.movespeed or {}

-- Конфигурация
dbt.movespeed.config = {
    defaultWalkSpeed = 200,
    defaultRunSpeed = 300,
    combatModeSpeed = 360,
    combatModeDuration = 0, -- 0 = бесконечно, пока не выключат
}

-- Типы модификаторов скорости
dbt.movespeed.MODIFIER_POTION = 1
dbt.movespeed.MODIFIER_BUFF = 2
dbt.movespeed.MODIFIER_DEBUFF = 3
dbt.movespeed.MODIFIER_COMBAT = 4

if SERVER then
    util.AddNetworkString("dbt.movespeed.toggle_combat")
    util.AddNetworkString("dbt.movespeed.sync")
    
    -- Инициализация игрока
    hook.Add("PlayerInitialSpawn", "dbt.movespeed.init", function(ply)
        ply.dbt_movespeed_modifiers = ply.dbt_movespeed_modifiers or {}
        ply.dbt_combat_mode = false
        ply.dbt_base_speed = dbt.movespeed.config.defaultRunSpeed
        
        ply:SetWalkSpeed(dbt.movespeed.config.defaultWalkSpeed)
        ply:SetRunSpeed(dbt.movespeed.config.defaultRunSpeed)
    end)
    
    -- Функция для добавления модификатора скорости
    function dbt.movespeed.AddModifier(ply, id, speed, duration, modifierType)
        if not IsValid(ply) then return end
        
        ply.dbt_movespeed_modifiers = ply.dbt_movespeed_modifiers or {}
        
        local modifier = {
            id = id,
            speed = speed,
            endTime = duration > 0 and (CurTime() + duration) or 0,
            type = modifierType or dbt.movespeed.MODIFIER_BUFF
        }
        
        ply.dbt_movespeed_modifiers[id] = modifier
        dbt.movespeed.UpdateSpeed(ply)
        
        return modifier
    end
    
    -- Функция для удаления модификатора
    function dbt.movespeed.RemoveModifier(ply, id)
        if not IsValid(ply) then return end
        if not ply.dbt_movespeed_modifiers then return end
        
        ply.dbt_movespeed_modifiers[id] = nil
        dbt.movespeed.UpdateSpeed(ply)
    end
    
    -- Проверка истекших модификаторов
    hook.Add("Think", "dbt.movespeed.check_expired", function()
        for _, ply in ipairs(player.GetAll()) do
            if not ply.dbt_movespeed_modifiers then continue end
            
            local needUpdate = false
            for id, modifier in pairs(ply.dbt_movespeed_modifiers) do
                if modifier.endTime > 0 and CurTime() >= modifier.endTime then
                    ply.dbt_movespeed_modifiers[id] = nil
                    needUpdate = true
                end
            end
            
            if needUpdate then
                dbt.movespeed.UpdateSpeed(ply)
            end
        end
    end)
    
    -- Обновление скорости игрока
    function dbt.movespeed.UpdateSpeed(ply)
        if not IsValid(ply) then return end
        
        local finalSpeed = ply.dbt_base_speed or dbt.movespeed.config.defaultRunSpeed
        local highestModifier = 0
        
        -- Боевой режим имеет приоритет
        if ply.dbt_combat_mode then
            finalSpeed = dbt.movespeed.config.combatModeSpeed
        else
            -- Применяем модификаторы (берём максимальный)
            if ply.dbt_movespeed_modifiers then
                for _, modifier in pairs(ply.dbt_movespeed_modifiers) do
                    if modifier.speed > highestModifier then
                        highestModifier = modifier.speed
                    end
                end
            end
            
            if highestModifier > 0 then
                finalSpeed = highestModifier
            end
        end
        
        ply:SetRunSpeed(finalSpeed)
        ply:SetWalkSpeed(finalSpeed * 0.5)
        
        -- Синхронизация с клиентом
        net.Start("dbt.movespeed.sync")
            net.WriteBool(ply.dbt_combat_mode or false)
            net.WriteFloat(finalSpeed)
        net.Send(ply)
    end
    
    -- Переключение боевого режима
    net.Receive("dbt.movespeed.toggle_combat", function(len, ply)
        ply.dbt_combat_mode = not ply.dbt_combat_mode
        
        dbt.movespeed.UpdateSpeed(ply)
        
        -- Уведомление
        if ply.dbt_combat_mode then
            dbt.notification.Send(ply, "Вы перешли в боевой режим!", "combat_on", 3)
        else
            dbt.notification.Send(ply, "Боевой режим отключён", "combat_off", 3)
        end
    end)
    
else -- CLIENT
    
    -- Локальные переменные
    local combatMode = false
    local currentSpeed = 300
    
    -- Синхронизация с сервером
    net.Receive("dbt.movespeed.sync", function()
        combatMode = net.ReadBool()
        currentSpeed = net.ReadFloat()
    end)
    
    -- Бинд на кнопку B
    hook.Add("PlayerButtonDown", "dbt.movespeed.combat_toggle", function(ply, button)
        if button == KEY_B then
            net.Start("dbt.movespeed.toggle_combat")
            net.SendToServer()
            
            surface.PlaySound("buttons/button14.wav")
        end
    end)
    
    -- Получить текущий режим (для UI)
    function dbt.movespeed.IsCombatMode()
        return combatMode
    end
    
    function dbt.movespeed.GetCurrentSpeed()
        return currentSpeed
    end
=======
-- Система уведомлений для боевого режима и зелий
-- Интегрируется с существующей системой уведомлений

dbt = dbt or {}
dbt.notification = dbt.notification or {}

if SERVER then
    util.AddNetworkString("dbt.notification.send")
    
    -- Отправить уведомление игроку
    function dbt.notification.Send(ply, text, notifType, duration)
        if not IsValid(ply) then return end
        
        net.Start("dbt.notification.send")
            net.WriteString(text or "")
            net.WriteString(notifType or "info")
            net.WriteFloat(duration or 3)
        net.Send(ply)
    end
    
    -- Отправить уведомление всем
    function dbt.notification.SendAll(text, notifType, duration)
        net.Start("dbt.notification.send")
            net.WriteString(text or "")
            net.WriteString(notifType or "info")
            net.WriteFloat(duration or 3)
        net.Broadcast()
    end
    
else -- CLIENT
    
    -- Очередь уведомлений
    dbt.notification.queue = dbt.notification.queue or {}
    
    -- Типы уведомлений с цветами
    dbt.notification.types = {
        ["info"] = Color(100, 150, 255),
        ["success"] = Color(100, 255, 100),
        ["warning"] = Color(255, 200, 100),
        ["error"] = Color(255, 100, 100),
        ["combat_on"] = Color(255, 50, 50),
        ["combat_off"] = Color(100, 255, 100),
        ["potion"] = Color(200, 100, 255),
    }
    
    -- Получение уведомления
    net.Receive("dbt.notification.send", function()
        local text = net.ReadString()
        local notifType = net.ReadString()
        local duration = net.ReadFloat()
        
        local notification = {
            text = text,
            type = notifType,
            startTime = CurTime(),
            endTime = CurTime() + duration,
            alpha = 0,
            yPos = 0
        }
        
        table.insert(dbt.notification.queue, notification)
        
        -- Звуковой эффект
        if notifType == "combat_on" then
            surface.PlaySound("buttons/button14.wav")
        elseif notifType == "combat_off" then
            surface.PlaySound("buttons/button15.wav")
        elseif notifType == "potion" then
            surface.PlaySound("items/medshot4.wav")
        end
    end)
    
    -- Отрисовка уведомлений
    hook.Add("HUDPaint", "dbt.notification.draw", function()
        if #dbt.notification.queue == 0 then return end
        
        local scrw, scrh = ScrW(), ScrH()
        local baseX = scrw * 0.5
        local baseY = scrh * 0.15
        local offsetY = 0
        
        for i = #dbt.notification.queue, 1, -1 do
            local notif = dbt.notification.queue[i]
            local timeLeft = notif.endTime - CurTime()
            
            -- Удаление истекших уведомлений
            if timeLeft <= 0 then
                table.remove(dbt.notification.queue, i)
                continue
            end
            
            -- Анимация появления/исчезновения
            local lifetime = notif.endTime - notif.startTime
            if timeLeft > lifetime - 0.3 then
                notif.alpha = Lerp(FrameTime() * 10, notif.alpha, 255)
            elseif timeLeft < 0.5 then
                notif.alpha = Lerp(FrameTime() * 10, notif.alpha, 0)
            end
            
            -- Плавное смещение
            notif.yPos = Lerp(FrameTime() * 8, notif.yPos, baseY + offsetY)
            
            -- Получить цвет по типу
            local color = dbt.notification.types[notif.type] or Color(255, 255, 255)
            
            -- Размеры панели
            surface.SetFont("Comfortaa Light X40")
            local textW, textH = surface.GetTextSize(notif.text)
            local panelW = textW + 40
            local panelH = textH + 20
            local panelX = baseX - panelW / 2
            local panelY = notif.yPos
            
            -- Фон
            draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(0, 0, 0, notif.alpha * 0.8))
            
            -- Рамка
            surface.SetDrawColor(color.r, color.g, color.b, notif.alpha)
            surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 2)
            
            -- Текст
            draw.SimpleText(notif.text, "Comfortaa Light X40", baseX, panelY + panelH / 2, ColorAlpha(color_white, notif.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            offsetY = offsetY + panelH + 10
        end
    end)
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
    
end