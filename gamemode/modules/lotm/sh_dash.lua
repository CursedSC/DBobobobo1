-- LOTM Dodge System (Уклонение)
-- Простая система уклонения с одной клавишей

LOTM = LOTM or {}
LOTM.Dodge = LOTM.Dodge or {}

-- Конфигурация
LOTM.Dodge.Config = {
    speed = 1200,           -- Скорость уклонения
    cooldown = 1.5,         -- Кулдаун
    invulnTime = 0.3,       -- Время неуязвимости
}

-- Network strings
if SERVER then
    util.AddNetworkString("LOTM.Dodge.Do")
end

-- =============================================
-- СЕРВЕР
-- =============================================
if SERVER then
    LOTM.Dodge.Cooldowns = {}
    LOTM.Dodge.Invuln = {}
    
    net.Receive("LOTM.Dodge.Do", function(len, ply)
        if not IsValid(ply) or not ply:Alive() then return end
        
        -- Проверка кулдауна
        local cd = LOTM.Dodge.Cooldowns[ply] or 0
        if CurTime() < cd then return end
        
        -- Направление (куда смотрит игрок, без вертикали)
        local ang = ply:EyeAngles()
        ang.p = 0
        
        -- Определяем направление по нажатым клавишам
        local moveDir = Vector(0, 0, 0)
        
        if ply:KeyDown(IN_FORWARD) then
            moveDir = moveDir + ang:Forward()
        elseif ply:KeyDown(IN_BACK) then
            moveDir = moveDir - ang:Forward()
        end
        
        if ply:KeyDown(IN_MOVELEFT) then
            moveDir = moveDir - ang:Right()
        elseif ply:KeyDown(IN_MOVERIGHT) then
            moveDir = moveDir + ang:Right()
        end
        
        -- Если нет направления - назад
        if moveDir:Length() < 0.1 then
            moveDir = -ang:Forward()
        end
        
        moveDir:Normalize()
        moveDir.z = 0.1
        
        -- Применяем скорость
        ply:SetVelocity(moveDir * LOTM.Dodge.Config.speed)
        
        -- Звук
        ply:EmitSound("physics/body/body_medium_impact_soft3.wav", 60)
        
        -- Неуязвимость
        LOTM.Dodge.Invuln[ply] = CurTime() + LOTM.Dodge.Config.invulnTime
        
        -- Кулдаун
        LOTM.Dodge.Cooldowns[ply] = CurTime() + LOTM.Dodge.Config.cooldown
    end)
    
    -- Неуязвимость
    hook.Add("EntityTakeDamage", "LOTM.Dodge.Invuln", function(target, dmg)
        if not IsValid(target) or not target:IsPlayer() then return end
        local invuln = LOTM.Dodge.Invuln[target]
        if invuln and CurTime() < invuln then
            return true
        end
    end)
    
    -- Очистка
    hook.Add("PlayerDisconnected", "LOTM.Dodge.Cleanup", function(ply)
        LOTM.Dodge.Cooldowns[ply] = nil
        LOTM.Dodge.Invuln[ply] = nil
    end)
end

-- =============================================
-- КЛИЕНТ
-- =============================================
if CLIENT then
    LOTM.Dodge.LastUse = 0
    
    -- Запрос уклонения
    function LOTM.Dodge.Request()
        if CurTime() < LOTM.Dodge.LastUse then return end
        
        net.Start("LOTM.Dodge.Do")
        net.SendToServer()
        
        LOTM.Dodge.LastUse = CurTime() + LOTM.Dodge.Config.cooldown
        
        -- Звук на клиенте
        surface.PlaySound("physics/body/body_medium_impact_soft3.wav")
    end
    
    -- Консольная команда
    concommand.Add("lotm_dodge", function()
        LOTM.Dodge.Request()
    end)
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Dodge System loaded\n")
