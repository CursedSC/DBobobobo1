-- LOTM Dash System v2.1
-- Улучшенная система дэша с реалистичными эффектами
-- Только эффекты земли, без прозрачности игрока

LOTM = LOTM or {}
LOTM.Dodge = LOTM.Dodge or {}
LOTM.Dash = LOTM.Dash or {}

-- =============================================
-- КОНФИГУРАЦИЯ
-- =============================================
LOTM.Dodge.Config = {
    speed = 1000,           -- Скорость дэша
    cooldown = 1.5,         -- Кулдаун
    invulnTime = 0.25,      -- Время неуязвимости
}

-- Network strings
if SERVER then
    util.AddNetworkString("LOTM.Dodge.Do")
    util.AddNetworkString("LOTM.Dash.Effect")
end

-- =============================================
-- СЕРВЕР
-- =============================================
if SERVER then
    LOTM.Dodge.Cooldowns = {}
    LOTM.Dodge.Invuln = {}
    
    -- Создание реалистичных эффектов дэша
    local function CreateDashEffects(ply, direction)
        local pos = ply:GetPos()
        local ang = ply:EyeAngles()
        ang.p = 0
        
        -- Определяем направление
        local moveDir = Vector(0, 0, 0)
        if direction == "forward" then
            moveDir = ang:Forward()
        elseif direction == "back" then
            moveDir = -ang:Forward()
        elseif direction == "left" then
            moveDir = -ang:Right()
        elseif direction == "right" then
            moveDir = ang:Right()
        else
            moveDir = -ang:Forward()
        end
        
        -- Трейс вниз для определения поверхности
        local groundTrace = util.TraceLine({
            start = pos + Vector(0, 0, 10),
            endpos = pos - Vector(0, 0, 50),
            filter = ply,
        })
        
        if groundTrace.Hit then
            local groundPos = groundTrace.HitPos
            local groundNormal = groundTrace.HitNormal
            
            -- Определяем тип поверхности
            local surfaceMat = groundTrace.MatType
            local isDirt = surfaceMat == MAT_DIRT or surfaceMat == MAT_SAND or surfaceMat == MAT_GRASS
            local isWater = surfaceMat == MAT_SLOSH or surfaceMat == MAT_WARPSHIELD
            local isMetal = surfaceMat == MAT_METAL or surfaceMat == MAT_GRATE or surfaceMat == MAT_VENT
            
            -- Эффект пыли на земле
            local dustEffect = EffectData()
            dustEffect:SetOrigin(groundPos + Vector(0, 0, 5))
            dustEffect:SetNormal(groundNormal)
            
            if isDirt then
                -- Эффект земли/пыли
                dustEffect:SetScale(1.5)
                dustEffect:SetMagnitude(2)
                util.Effect("ThumperDust", dustEffect)
            elseif isWater then
                -- Эффект воды
                dustEffect:SetScale(2)
                util.Effect("WaterSplash", dustEffect)
            elseif isMetal then
                -- Эффект искр на металле
                dustEffect:SetScale(0.5)
                util.Effect("ManhackSparks", dustEffect)
            else
                -- Стандартный эффект
                dustEffect:SetScale(1)
                dustEffect:SetMagnitude(1)
                util.Effect("ThumperDust", dustEffect)
            end
            
            -- Создаём несколько точек эффекта позади игрока
            for i = 1, 3 do
                local offsetPos = groundPos - moveDir * (i * 25) + VectorRand() * 10
                offsetPos.z = groundPos.z
                
                local trailEffect = EffectData()
                trailEffect:SetOrigin(offsetPos)
                trailEffect:SetNormal(Vector(0, 0, 1))
                trailEffect:SetScale(0.8)
                
                if isDirt then
                    util.Effect("ThumperDust", trailEffect)
                end
            end
        end
        
        -- Отправляем клиентам
        net.Start("LOTM.Dash.Effect")
        net.WriteVector(pos)
        net.WriteVector(moveDir)
        net.WriteEntity(ply)
        net.WriteUInt(groundTrace.MatType or MAT_CONCRETE, 8)
        net.Broadcast()
    end
    
    net.Receive("LOTM.Dodge.Do", function(len, ply)
        if not IsValid(ply) or not ply:Alive() then return end
        
        -- Проверка кулдауна
        local cd = LOTM.Dodge.Cooldowns[ply] or 0
        if CurTime() < cd then return end
        
        -- Направление
        local ang = ply:EyeAngles()
        ang.p = 0
        
        local moveDir = Vector(0, 0, 0)
        local direction = "back"
        
        if ply:KeyDown(IN_FORWARD) then
            moveDir = ang:Forward()
            direction = "forward"
        elseif ply:KeyDown(IN_BACK) then
            moveDir = -ang:Forward()
            direction = "back"
        end
        
        if ply:KeyDown(IN_MOVELEFT) then
            moveDir = moveDir - ang:Right()
            if direction == "back" then direction = "left" end
        elseif ply:KeyDown(IN_MOVERIGHT) then
            moveDir = moveDir + ang:Right()
            if direction == "back" then direction = "right" end
        end
        
        -- Если нет направления - назад
        if moveDir:Length() < 0.1 then
            moveDir = -ang:Forward()
            direction = "back"
        end
        
        moveDir:Normalize()
        moveDir.z = 0.1
        
        -- Применяем скорость
        ply:SetVelocity(moveDir * LOTM.Dodge.Config.speed)
        
        -- Звук движения
        local groundTrace = util.TraceLine({
            start = ply:GetPos() + Vector(0, 0, 10),
            endpos = ply:GetPos() - Vector(0, 0, 50),
            filter = ply,
        })
        
        if groundTrace.Hit then
            local surfaceMat = groundTrace.MatType
            if surfaceMat == MAT_METAL or surfaceMat == MAT_GRATE then
                ply:EmitSound("physics/metal/metal_box_scrape_smooth_loop1.wav", 55, 150, 0.5)
            elseif surfaceMat == MAT_DIRT or surfaceMat == MAT_SAND then
                ply:EmitSound("physics/body/body_medium_impact_soft3.wav", 60)
            else
                ply:EmitSound("physics/body/body_medium_impact_soft3.wav", 55)
            end
        end
        
        -- Создаём эффекты
        CreateDashEffects(ply, direction)
        
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
    
    -- Материалы для эффектов
    local dustMat = Material("particle/particle_smokegrenade")
    
    -- Локальные частицы
    local groundParticles = {}
    
    -- Получение эффекта от сервера
    net.Receive("LOTM.Dash.Effect", function()
        local pos = net.ReadVector()
        local moveDir = net.ReadVector()
        local ply = net.ReadEntity()
        local surfaceType = net.ReadUInt(8)
        
        if not IsValid(ply) then return end
        
        -- Определяем цвет частиц по типу поверхности
        local particleColor = Color(150, 130, 110, 180)  -- Коричневатая пыль
        
        if surfaceType == MAT_GRASS then
            particleColor = Color(100, 130, 80, 150)      -- Зеленоватая
        elseif surfaceType == MAT_SAND then
            particleColor = Color(200, 180, 140, 180)     -- Песочная
        elseif surfaceType == MAT_METAL or surfaceType == MAT_GRATE then
            particleColor = Color(180, 180, 200, 100)     -- Серая
        elseif surfaceType == MAT_CONCRETE or surfaceType == MAT_TILE then
            particleColor = Color(160, 160, 160, 150)     -- Бетонная
        end
        
        -- Создаём частицы пыли на земле
        local groundPos = pos
        local traceDown = util.TraceLine({
            start = pos + Vector(0, 0, 20),
            endpos = pos - Vector(0, 0, 50),
            filter = ply,
        })
        
        if traceDown.Hit then
            groundPos = traceDown.HitPos
        end
        
        -- Частицы на земле позади игрока
        for i = 1, 8 do
            local offset = VectorRand() * 25
            offset.z = 0
            
            local particlePos = groundPos + offset - moveDir * math.random(10, 50)
            particlePos.z = groundPos.z + math.random(2, 15)
            
            local vel = Vector(
                math.random(-30, 30) - moveDir.x * 50,
                math.random(-30, 30) - moveDir.y * 50,
                math.random(20, 60)
            )
            
            table.insert(groundParticles, {
                pos = particlePos,
                vel = vel,
                lifetime = 0.5 + math.random() * 0.3,
                maxLifetime = 0.8,
                size = math.random(6, 14),
                color = particleColor,
                alpha = particleColor.a,
            })
        end
    end)
    
    -- Отрисовка частиц
    hook.Add("PostDrawTranslucentRenderables", "LOTM.Dash.Particles", function()
        if #groundParticles == 0 then return end
        
        local ft = FrameTime()
        local toRemove = {}
        
        render.SetMaterial(dustMat)
        
        for i, p in ipairs(groundParticles) do
            -- Физика частицы
            p.pos = p.pos + p.vel * ft
            p.vel = p.vel * 0.92
            p.vel.z = p.vel.z - 80 * ft  -- Гравитация
            
            p.lifetime = p.lifetime - ft
            
            if p.lifetime <= 0 then
                table.insert(toRemove, i)
            else
                local lifeRatio = p.lifetime / p.maxLifetime
                local alpha = p.alpha * lifeRatio
                local size = p.size * (0.5 + lifeRatio * 0.5)
                
                render.DrawSprite(p.pos, size, size, Color(p.color.r, p.color.g, p.color.b, alpha))
            end
        end
        
        -- Удаляем мёртвые частицы
        for i = #toRemove, 1, -1 do
            table.remove(groundParticles, toRemove[i])
        end
    end)
    
    -- Запрос дэша
    function LOTM.Dodge.Request()
        if CurTime() < LOTM.Dodge.LastUse then return end
        
        net.Start("LOTM.Dodge.Do")
        net.SendToServer()
        
        LOTM.Dodge.LastUse = CurTime() + LOTM.Dodge.Config.cooldown
    end
    
    -- Консольная команда
    concommand.Add("lotm_dodge", function()
        LOTM.Dodge.Request()
    end)
    
    concommand.Add("lotm_dash", function()
        LOTM.Dodge.Request()
    end)
    
    -- Алиас для совместимости
    LOTM.Dash.Request = LOTM.Dodge.Request
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Dash System v2.1 loaded (realistic ground effects)\n")
