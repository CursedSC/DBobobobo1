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
    
end