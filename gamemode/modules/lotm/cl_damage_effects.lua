-- LOTM Damage Visual Effects
-- Визуальные эффекты урона и партиклы

LOTM = LOTM or {}

-- Эффект текста урона
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local damageData = data:GetStart()
    local damage = damageData.x
    local damageType = damageData.y
    
    self.Pos = pos
    self.Damage = math.Round(damage)
    self.DamageType = damageType
    self.LifeTime = 2
    self.StartTime = CurTime()
    self.Velocity = Vector(math.random(-20, 20), math.random(-20, 20), 50)
end

function EFFECT:Think()
    return CurTime() - self.StartTime < self.LifeTime
end

function EFFECT:Render()
    local alpha = 255 * (1 - (CurTime() - self.StartTime) / self.LifeTime)
    local color = LOTM.DamageColors[self.DamageType] or Color(255, 255, 255)
    
    self.Pos = self.Pos + self.Velocity * FrameTime()
    self.Velocity.z = self.Velocity.z - 50 * FrameTime()
    
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(self.Pos, ang, 0.1)
        draw.SimpleText("-" .. self.Damage, "DermaLarge", 0, 0, Color(color.r, color.g, color.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- Регистрация эффекта
function LOTM.RegisterDamageEffect()
    if CLIENT then
        -- Создать файл эффекта если его нет
        local effectCode = [[
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local damageData = data:GetStart()
    self.Pos = pos
    self.Damage = math.Round(damageData.x)
    self.DamageType = damageData.y
    self.LifeTime = 2
    self.StartTime = CurTime()
    self.Velocity = Vector(math.random(-20, 20), math.random(-20, 20), 50)
end

function EFFECT:Think()
    return CurTime() - self.StartTime < self.LifeTime
end

function EFFECT:Render()
    local alpha = 255 * (1 - (CurTime() - self.StartTime) / self.LifeTime)
    local color = LOTM.DamageColors and LOTM.DamageColors[self.DamageType] or Color(255, 255, 255)
    
    self.Pos = self.Pos + self.Velocity * FrameTime()
    self.Velocity.z = self.Velocity.z - 50 * FrameTime()
    
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(self.Pos, ang, 0.1)
        draw.SimpleText("-" .. self.Damage, "DermaLarge", 0, 0, Color(color.r, color.g, color.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
]]
        
        -- Сохранить эффект
        file.CreateDir("effects")
        file.Write("effects/lotm_damage_text.lua", effectCode)
    end
end

-- Партиклы ранения
function LOTM.CreateWoundParticles(pos, damageType, hitNormal)
    local color = LOTM.DamageColors[damageType] or Color(255, 0, 0)
    local emitter = ParticleEmitter(pos)
    
    if not emitter then return end
    
    -- Кровь/энергия
    for i = 1, 15 do
        local particle = emitter:Add("effects/blood_core", pos)
        if particle then
            local dir = VectorRand()
            if hitNormal then
                dir = (hitNormal + VectorRand() * 0.5):GetNormalized()
            end
            
            particle:SetVelocity(dir * math.random(50, 150))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.random(2, 5))
            particle:SetEndSize(0)
            particle:SetRoll(math.random(0, 360))
            particle:SetRollDelta(math.random(-2, 2))
            particle:SetColor(color.r, color.g, color.b)
            particle:SetGravity(Vector(0, 0, -200))
            particle:SetCollide(true)
            particle:SetBounce(0.3)
        end
    end
    
    emitter:Finish()
end

print("[LOTM] Визуальные эффекты урона загружены")