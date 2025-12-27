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
    
end