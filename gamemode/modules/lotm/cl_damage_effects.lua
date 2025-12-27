<<<<<<< HEAD
-- LOTM Damage Effects System
-- Партикл-эффекты при получении урона
-- Настраиваемые эффекты для каждого типа урона

LOTM = LOTM or {}
LOTM.Effects = LOTM.Effects or {}

-- Настройки эффектов (ConVars)
CreateClientConVar("lotm_effects_enabled", "1", true, false, "Включить эффекты урона")
CreateClientConVar("lotm_effects_intensity", "1", true, false, "Интенсивность эффектов (0.5 - 2.0)")
CreateClientConVar("lotm_effects_screen", "1", true, false, "Экранные эффекты при получении урона")

-- Хранилище кастомных партиклов
LOTM.Effects.CustomParticles = LOTM.Effects.CustomParticles or {}

-- Регистрация кастомного партикла для типа урона
function LOTM.Effects.SetParticle(damageType, particleConfig)
    LOTM.Effects.CustomParticles[damageType] = particleConfig
end

-- Получить конфигурацию партикла для типа урона
function LOTM.Effects.GetParticle(damageType)
    return LOTM.Effects.CustomParticles[damageType] or LOTM.Effects.DefaultParticles[damageType]
end

-- Дефолтные конфигурации партиклов
LOTM.Effects.DefaultParticles = {
    -- Физический урон
    physical = {
        count = 8,
        size = {2, 4},
        velocity = 100,
        gravity = -300,
        lifetime = {0.3, 0.6},
        color = Color(200, 200, 200),
        material = "effects/spark",
        spread = 30,
    },
    slashing = {
        count = 12,
        size = {3, 6},
        velocity = 150,
        gravity = -200,
        lifetime = {0.2, 0.5},
        color = Color(200, 50, 50),
        material = "effects/blood",
        spread = 45,
    },
    piercing = {
        count = 6,
        size = {2, 4},
        velocity = 200,
        gravity = -400,
        lifetime = {0.2, 0.4},
        color = Color(255, 100, 100),
        material = "effects/blood_puff",
        spread = 20,
    },
    blunt = {
        count = 15,
        size = {4, 8},
        velocity = 80,
        gravity = -500,
        lifetime = {0.3, 0.7},
        color = Color(180, 150, 100),
        material = "effects/spark",
        spread = 60,
    },
    
    -- Мистический урон
    spiritual = {
        count = 20,
        size = {3, 7},
        velocity = 60,
        gravity = 50,
        lifetime = {0.5, 1.0},
        color = Color(200, 100, 255),
        material = "sprites/glow04_noz",
        spread = 360,
        glow = true,
    },
    mental = {
        count = 15,
        size = {4, 8},
        velocity = 40,
        gravity = 30,
        lifetime = {0.6, 1.2},
        color = Color(100, 200, 255),
        material = "sprites/light_glow02_add",
        spread = 180,
        glow = true,
        spiral = true,
    },
    corruption = {
        count = 25,
        size = {2, 5},
        velocity = 30,
        gravity = -20,
        lifetime = {0.8, 1.5},
        color = Color(100, 50, 100),
        material = "particle/particle_smokegrenade",
        spread = 360,
        fadeIn = true,
    },
    curse = {
        count = 10,
        size = {5, 10},
        velocity = 20,
        gravity = -50,
        lifetime = {1.0, 2.0},
        color = Color(80, 0, 80),
        material = "sprites/glow04_noz",
        spread = 360,
        pulse = true,
    },
    
    -- Элементальный урон
    fire = {
        count = 20,
        size = {4, 8},
        velocity = 100,
        gravity = 100,
        lifetime = {0.3, 0.6},
        color = Color(255, 100, 0),
        colorEnd = Color(255, 200, 50),
        material = "sprites/flamelet1",
        spread = 90,
        glow = true,
    },
    frost = {
        count = 15,
        size = {3, 6},
        velocity = 50,
        gravity = -100,
        lifetime = {0.5, 1.0},
        color = Color(200, 230, 255),
        colorEnd = Color(100, 200, 255),
        material = "sprites/glow04_noz",
        spread = 120,
    },
    lightning = {
        count = 10,
        size = {2, 4},
        velocity = 300,
        gravity = 0,
        lifetime = {0.1, 0.2},
        color = Color(255, 255, 100),
        material = "sprites/glow04_noz",
        spread = 360,
        glow = true,
        flash = true,
    },
    darkness = {
        count = 30,
        size = {5, 12},
        velocity = 20,
        gravity = -10,
        lifetime = {1.0, 2.0},
        color = Color(20, 0, 30),
        material = "particle/particle_smokegrenade",
        spread = 360,
        fadeIn = true,
    },
    light = {
        count = 25,
        size = {3, 7},
        velocity = 80,
        gravity = 50,
        lifetime = {0.4, 0.8},
        color = Color(255, 255, 200),
        material = "sprites/light_glow02_add",
        spread = 360,
        glow = true,
    },
    storm = {
        count = 20,
        size = {3, 6},
        velocity = 150,
        gravity = -50,
        lifetime = {0.3, 0.6},
        color = Color(100, 150, 200),
        material = "effects/spark",
        spread = 180,
        swirl = true,
    },
    
    -- Особый урон
    beyonder = {
        count = 30,
        size = {4, 10},
        velocity = 50,
        gravity = 20,
        lifetime = {0.8, 1.5},
        color = Color(180, 0, 255),
        material = "sprites/glow04_noz",
        spread = 360,
        glow = true,
        pulse = true,
    },
    madness = {
        count = 35,
        size = {3, 8},
        velocity = 60,
        gravity = 0,
        lifetime = {1.0, 2.0},
        color = Color(150, 0, 150),
        colorEnd = Color(255, 0, 100),
        material = "sprites/glow04_noz",
        spread = 360,
        chaos = true,
    },
    death = {
        count = 20,
        size = {5, 12},
        velocity = 30,
        gravity = -100,
        lifetime = {1.2, 2.5},
        color = Color(30, 30, 30),
        colorEnd = Color(80, 0, 0),
        material = "particle/particle_smokegrenade",
        spread = 360,
        fadeIn = true,
    },
    blood = {
        count = 15,
        size = {3, 7},
        velocity = 120,
        gravity = -400,
        lifetime = {0.3, 0.6},
        color = Color(139, 0, 0),
        material = "effects/blood",
        spread = 60,
    },
    
    -- Временной/пространственный
    time = {
        count = 15,
        size = {4, 8},
        velocity = 40,
        gravity = 0,
        lifetime = {1.5, 3.0},
        color = Color(0, 255, 200),
        material = "sprites/glow04_noz",
        spread = 360,
        spiral = true,
        slowmo = true,
    },
    space = {
        count = 20,
        size = {3, 7},
        velocity = 100,
        gravity = 0,
        lifetime = {0.5, 1.0},
        color = Color(50, 50, 150),
        colorEnd = Color(150, 50, 200),
        material = "sprites/glow04_noz",
        spread = 360,
        warp = true,
    },
}

-- Воспроизведение партикл-эффекта
function LOTM.Effects.PlayDamageEffect(position, damageType, damage)
    if not GetConVar("lotm_effects_enabled"):GetBool() then return end
    
    local config = LOTM.Effects.GetParticle(damageType)
    if not config then
        config = LOTM.Effects.DefaultParticles.physical
    end
    
    local intensity = GetConVar("lotm_effects_intensity"):GetFloat()
    intensity = math.Clamp(intensity, 0.5, 2.0)
    
    local emitter = ParticleEmitter(position)
    if not emitter then return end
    
    local count = math.floor(config.count * intensity * math.min(damage / 20, 2))
    
    for i = 1, count do
        local particle = emitter:Add(config.material, position + VectorRand() * 5)
        if particle then
            local vel = VectorRand()
            if config.spread < 360 then
                local spreadRad = math.rad(config.spread / 2)
                vel = Vector(
                    math.Rand(-1, 1) * math.sin(spreadRad),
                    math.Rand(-1, 1) * math.sin(spreadRad),
                    math.Rand(0.5, 1)
                ):GetNormalized()
            end
            vel = vel * config.velocity * math.Rand(0.7, 1.3)
            
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(config.lifetime[1], config.lifetime[2]))
            
            -- Размер
            local startSize = math.Rand(config.size[1], config.size[2]) * intensity
            particle:SetStartSize(startSize)
            particle:SetEndSize(config.glow and startSize * 0.5 or 0)
            
            -- Цвет
            local color = config.color
            particle:SetStartAlpha(config.fadeIn and 0 or 255)
            particle:SetEndAlpha(config.fadeIn and 255 or 0)
            particle:SetColor(color.r, color.g, color.b)
            
            if config.colorEnd then
                -- Анимация цвета через Think не поддерживается напрямую
                -- Используем усреднённый цвет для End
            end
            
            -- Гравитация
            particle:SetGravity(Vector(0, 0, config.gravity))
            
            -- Свечение
            if config.glow then
                particle:SetLighting(false)
            end
            
            -- Вращение
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-5, 5))
            
            -- Специальные эффекты
            if config.spiral then
                local angle = math.Rand(0, math.pi * 2)
                local radius = math.Rand(20, 50)
                particle:SetVelocity(Vector(
                    math.cos(angle) * radius,
                    math.sin(angle) * radius,
                    vel.z
                ))
            end
=======
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
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
        end
    end
    
    emitter:Finish()
<<<<<<< HEAD
    
    -- Дополнительные эффекты
    if config.flash and damageType == "lightning" then
        local dlight = DynamicLight(0)
        if dlight then
            dlight.pos = position
            dlight.r = 255
            dlight.g = 255
            dlight.b = 100
            dlight.brightness = 5
            dlight.decay = 2000
            dlight.size = 200
            dlight.dietime = CurTime() + 0.2
        end
    end
end

-- Экранный эффект при получении урона
local screenDamageEffect = {
    active = false,
    intensity = 0,
    color = Color(255, 0, 0),
    startTime = 0,
    duration = 0.5,
}

function LOTM.Effects.PlayScreenEffect(damageType, damage)
    if not GetConVar("lotm_effects_screen"):GetBool() then return end
    
    local color = Color(255, 0, 0)
    if LOTM.Damage and LOTM.Damage.Colors then
        color = LOTM.Damage.Colors[damageType] or color
    end
    
    screenDamageEffect.active = true
    screenDamageEffect.intensity = math.Clamp(damage / 50, 0.3, 1.0)
    screenDamageEffect.color = color
    screenDamageEffect.startTime = CurTime()
    screenDamageEffect.duration = math.Clamp(damage / 100, 0.3, 1.0)
end

-- Рендер экранного эффекта
hook.Add("RenderScreenspaceEffects", "LOTM.Effects.Screen", function()
    if not screenDamageEffect.active then return end
    
    local elapsed = CurTime() - screenDamageEffect.startTime
    local progress = elapsed / screenDamageEffect.duration
    
    if progress >= 1 then
        screenDamageEffect.active = false
        return
    end
    
    local alpha = (1 - progress) * screenDamageEffect.intensity * 0.3
    local color = screenDamageEffect.color
    
    -- Виньетка
    surface.SetDrawColor(color.r, color.g, color.b, alpha * 255)
    
    local scrw, scrh = ScrW(), ScrH()
    local vignetteSize = 150 * (1 - progress * 0.5)
    
    -- Верхняя часть
    surface.DrawRect(0, 0, scrw, vignetteSize * (1 - progress))
    -- Нижняя часть
    surface.DrawRect(0, scrh - vignetteSize * (1 - progress), scrw, vignetteSize * (1 - progress))
    -- Левая часть
    surface.DrawRect(0, 0, vignetteSize * (1 - progress), scrh)
    -- Правая часть
    surface.DrawRect(scrw - vignetteSize * (1 - progress), 0, vignetteSize * (1 - progress), scrh)
end)

-- HUD для отображения типа полученного урона (опционально)
local damageIndicators = {}

function LOTM.Effects.AddDamageIndicator(position, damageType, damage)
    table.insert(damageIndicators, {
        pos = position,
        type = damageType,
        damage = damage,
        startTime = CurTime(),
        duration = 1.5,
        offset = Vector(0, 0, math.Rand(20, 40)),
    })
end

hook.Add("HUDPaint", "LOTM.Effects.DamageIndicators", function()
    local curTime = CurTime()
    
    for i = #damageIndicators, 1, -1 do
        local indicator = damageIndicators[i]
        local elapsed = curTime - indicator.startTime
        local progress = elapsed / indicator.duration
        
        if progress >= 1 then
            table.remove(damageIndicators, i)
        else
            local worldPos = indicator.pos + indicator.offset * progress
            local screenPos = worldPos:ToScreen()
            
            if screenPos.visible then
                local alpha = (1 - progress) * 255
                local color = Color(255, 255, 255, alpha)
                
                if LOTM.Damage and LOTM.Damage.Colors then
                    color = LOTM.Damage.Colors[indicator.type] or color
                    color = Color(color.r, color.g, color.b, alpha)
                end
                
                local text = "-" .. math.floor(indicator.damage)
                draw.SimpleTextOutlined(text, "DermaLarge", screenPos.x, screenPos.y, 
                    color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
            end
        end
    end
end)

-- Консольная команда для настройки
concommand.Add("lotm_effects_settings", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 150)
    frame:Center()
    frame:SetTitle("Настройки эффектов урона")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    local y = 35
    
    local enableCheck = vgui.Create("DCheckBoxLabel", frame)
    enableCheck:SetPos(15, y)
    enableCheck:SetText("Включить эффекты")
    enableCheck:SetConVar("lotm_effects_enabled")
    enableCheck:SizeToContents()
    y = y + 25
    
    local screenCheck = vgui.Create("DCheckBoxLabel", frame)
    screenCheck:SetPos(15, y)
    screenCheck:SetText("Экранные эффекты")
    screenCheck:SetConVar("lotm_effects_screen")
    screenCheck:SizeToContents()
    y = y + 30
    
    local intensitySlider = vgui.Create("DNumSlider", frame)
    intensitySlider:SetPos(15, y)
    intensitySlider:SetSize(270, 30)
    intensitySlider:SetText("Интенсивность")
    intensitySlider:SetMin(0.5)
    intensitySlider:SetMax(2)
    intensitySlider:SetDecimals(1)
    intensitySlider:SetConVar("lotm_effects_intensity")
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Damage effects system loaded\n")

=======
end

print("[LOTM] Визуальные эффекты урона загружены")
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
