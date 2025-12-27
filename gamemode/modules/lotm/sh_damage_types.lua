-- LOTM Damage Types System
-- Система типов урона для Lord of the Mysteries
-- Включает резисты и партикл-эффекты

LOTM = LOTM or {}
LOTM.Damage = LOTM.Damage or {}

-- Типы урона характерные для LOTM
LOTM.Damage.Types = {
    -- Физический урон
    PHYSICAL = "physical",
    SLASHING = "slashing",      -- Режущий
    PIERCING = "piercing",      -- Проникающий
    BLUNT = "blunt",            -- Тупой
    
    -- Мистический урон
    SPIRITUAL = "spiritual",    -- Духовный урон
    MENTAL = "mental",          -- Ментальный урон
    CORRUPTION = "corruption",  -- Коррупция/порча
    CURSE = "curse",            -- Проклятие
    
    -- Элементальный урон
    FIRE = "fire",              -- Огонь
    FROST = "frost",            -- Холод/лёд
    LIGHTNING = "lightning",    -- Молния
    DARKNESS = "darkness",      -- Тьма
    LIGHT = "light",            -- Свет
    STORM = "storm",            -- Буря
    
    -- Особый урон
    BEYONDER = "beyonder",      -- Урон от сверхъестественных существ
    SEALED = "sealed",          -- Запечатывающий урон
    TRUE = "true",              -- Чистый урон (игнорирует резисты)
    MADNESS = "madness",        -- Безумие
    FATE = "fate",              -- Урон судьбы
    TIME = "time",              -- Временной урон
    SPACE = "space",            -- Пространственный урон
    DREAM = "dream",            -- Урон снов
    DEATH = "death",            -- Смертельный урон
    BLOOD = "blood",            -- Кровавый урон
}

-- Цвета для каждого типа урона (для партиклов и визуализации)
LOTM.Damage.Colors = {
    [LOTM.Damage.Types.PHYSICAL] = Color(200, 200, 200),
    [LOTM.Damage.Types.SLASHING] = Color(255, 100, 100),
    [LOTM.Damage.Types.PIERCING] = Color(255, 150, 100),
    [LOTM.Damage.Types.BLUNT] = Color(180, 150, 100),
    
    [LOTM.Damage.Types.SPIRITUAL] = Color(200, 100, 255),
    [LOTM.Damage.Types.MENTAL] = Color(100, 200, 255),
    [LOTM.Damage.Types.CORRUPTION] = Color(100, 50, 100),
    [LOTM.Damage.Types.CURSE] = Color(80, 0, 80),
    
    [LOTM.Damage.Types.FIRE] = Color(255, 100, 0),
    [LOTM.Damage.Types.FROST] = Color(100, 200, 255),
    [LOTM.Damage.Types.LIGHTNING] = Color(255, 255, 100),
    [LOTM.Damage.Types.DARKNESS] = Color(30, 0, 50),
    [LOTM.Damage.Types.LIGHT] = Color(255, 255, 200),
    [LOTM.Damage.Types.STORM] = Color(100, 150, 200),
    
    [LOTM.Damage.Types.BEYONDER] = Color(180, 0, 255),
    [LOTM.Damage.Types.SEALED] = Color(255, 215, 0),
    [LOTM.Damage.Types.TRUE] = Color(255, 255, 255),
    [LOTM.Damage.Types.MADNESS] = Color(150, 0, 150),
    [LOTM.Damage.Types.FATE] = Color(255, 215, 100),
    [LOTM.Damage.Types.TIME] = Color(0, 255, 200),
    [LOTM.Damage.Types.SPACE] = Color(50, 50, 150),
    [LOTM.Damage.Types.DREAM] = Color(150, 100, 200),
    [LOTM.Damage.Types.DEATH] = Color(50, 50, 50),
    [LOTM.Damage.Types.BLOOD] = Color(139, 0, 0),
}

-- Названия типов урона
LOTM.Damage.Names = {
    [LOTM.Damage.Types.PHYSICAL] = "Физический",
    [LOTM.Damage.Types.SLASHING] = "Режущий",
    [LOTM.Damage.Types.PIERCING] = "Проникающий",
    [LOTM.Damage.Types.BLUNT] = "Дробящий",
    
    [LOTM.Damage.Types.SPIRITUAL] = "Духовный",
    [LOTM.Damage.Types.MENTAL] = "Ментальный",
    [LOTM.Damage.Types.CORRUPTION] = "Порча",
    [LOTM.Damage.Types.CURSE] = "Проклятие",
    
    [LOTM.Damage.Types.FIRE] = "Огненный",
    [LOTM.Damage.Types.FROST] = "Ледяной",
    [LOTM.Damage.Types.LIGHTNING] = "Молния",
    [LOTM.Damage.Types.DARKNESS] = "Тьма",
    [LOTM.Damage.Types.LIGHT] = "Свет",
    [LOTM.Damage.Types.STORM] = "Буря",
    
    [LOTM.Damage.Types.BEYONDER] = "Сверхъестественный",
    [LOTM.Damage.Types.SEALED] = "Запечатывающий",
    [LOTM.Damage.Types.TRUE] = "Чистый",
    [LOTM.Damage.Types.MADNESS] = "Безумие",
    [LOTM.Damage.Types.FATE] = "Судьба",
    [LOTM.Damage.Types.TIME] = "Временной",
    [LOTM.Damage.Types.SPACE] = "Пространственный",
    [LOTM.Damage.Types.DREAM] = "Сновидческий",
    [LOTM.Damage.Types.DEATH] = "Смертельный",
    [LOTM.Damage.Types.BLOOD] = "Кровавый",
}

-- Партиклы для каждого типа урона (можно настроить)
LOTM.Damage.Particles = {
    [LOTM.Damage.Types.PHYSICAL] = "blood_impact_red_01",
    [LOTM.Damage.Types.SLASHING] = "blood_impact_red_01",
    [LOTM.Damage.Types.PIERCING] = "blood_impact_red_01",
    [LOTM.Damage.Types.BLUNT] = "impact_concrete",
    
    [LOTM.Damage.Types.SPIRITUAL] = nil,  -- Настраиваемый
    [LOTM.Damage.Types.MENTAL] = nil,
    [LOTM.Damage.Types.CORRUPTION] = nil,
    [LOTM.Damage.Types.CURSE] = nil,
    
    [LOTM.Damage.Types.FIRE] = "burning_character",
    [LOTM.Damage.Types.FROST] = nil,
    [LOTM.Damage.Types.LIGHTNING] = "electrical_arc_01_system",
    [LOTM.Damage.Types.DARKNESS] = nil,
    [LOTM.Damage.Types.LIGHT] = nil,
    [LOTM.Damage.Types.STORM] = nil,
    
    [LOTM.Damage.Types.BEYONDER] = nil,
    [LOTM.Damage.Types.SEALED] = nil,
    [LOTM.Damage.Types.TRUE] = nil,
    [LOTM.Damage.Types.MADNESS] = nil,
    [LOTM.Damage.Types.FATE] = nil,
    [LOTM.Damage.Types.TIME] = nil,
    [LOTM.Damage.Types.SPACE] = nil,
    [LOTM.Damage.Types.DREAM] = nil,
    [LOTM.Damage.Types.DEATH] = nil,
    [LOTM.Damage.Types.BLOOD] = "blood_impact_red_01",
}

--[[
    Система резистов
    Каждый игрок имеет таблицу резистов (по умолчанию все 0)
    Резист в процентах: 0 = нет резиста, 100 = полный иммунитет, -50 = уязвимость 50%
]]

-- Получить резисты игрока
function LOTM.Damage.GetResistances(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return {} end
    
    if not ply.LOTMResistances then
        ply.LOTMResistances = {}
        -- Инициализация всех резистов на 0
        for _, damageType in pairs(LOTM.Damage.Types) do
            ply.LOTMResistances[damageType] = 0
        end
    end
    
    return ply.LOTMResistances
end

-- Получить резист к определённому типу урона
function LOTM.Damage.GetResistance(ply, damageType)
    local resistances = LOTM.Damage.GetResistances(ply)
    return resistances[damageType] or 0
end

-- Установить резист к определённому типу урона
function LOTM.Damage.SetResistance(ply, damageType, value)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local resistances = LOTM.Damage.GetResistances(ply)
    resistances[damageType] = math.Clamp(value, -100, 100)
    
    if SERVER then
        -- Синхронизация с клиентом
        net.Start("LOTM.Damage.SyncResistance")
        net.WriteString(damageType)
        net.WriteFloat(resistances[damageType])
        net.Send(ply)
    end
end

-- Добавить резист к определённому типу урона
function LOTM.Damage.AddResistance(ply, damageType, value)
    local current = LOTM.Damage.GetResistance(ply, damageType)
    LOTM.Damage.SetResistance(ply, damageType, current + value)
end

-- Сбросить все резисты
function LOTM.Damage.ResetResistances(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    ply.LOTMResistances = nil
    LOTM.Damage.GetResistances(ply) -- Пересоздаст с нулями
    
    if SERVER then
        net.Start("LOTM.Damage.ResetResistances")
        net.Send(ply)
    end
end

-- Рассчитать финальный урон с учётом резистов
function LOTM.Damage.CalculateDamage(baseDamage, damageType, target)
    -- TRUE урон игнорирует резисты
    if damageType == LOTM.Damage.Types.TRUE then
        return baseDamage
    end
    
    local resistance = LOTM.Damage.GetResistance(target, damageType)
    local multiplier = 1 - (resistance / 100)
    
    return math.max(0, baseDamage * multiplier)
end

-- Сетевые сообщения
if SERVER then
    util.AddNetworkString("LOTM.Damage.SyncResistance")
    util.AddNetworkString("LOTM.Damage.ResetResistances")
    util.AddNetworkString("LOTM.Damage.Effect")
    
    -- Нанесение урона с учётом всех систем
    function LOTM.Damage.Apply(target, baseDamage, damageType, attacker, hitPosition)
        if not IsValid(target) then return 0 end
        
        damageType = damageType or LOTM.Damage.Types.PHYSICAL
        local finalDamage = LOTM.Damage.CalculateDamage(baseDamage, damageType, target)
        
        if finalDamage > 0 then
            -- Создаём DamageInfo
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(finalDamage)
            dmgInfo:SetAttacker(IsValid(attacker) and attacker or game.GetWorld())
            dmgInfo:SetInflictor(IsValid(attacker) and attacker or game.GetWorld())
            dmgInfo:SetDamagePosition(hitPosition or target:GetPos())
            
            -- Применяем урон
            target:TakeDamageInfo(dmgInfo)
            
            -- Отправляем эффект клиентам
            net.Start("LOTM.Damage.Effect")
            net.WriteEntity(target)
            net.WriteString(damageType)
            net.WriteVector(hitPosition or target:GetPos())
            net.WriteFloat(finalDamage)
            net.Broadcast()
        end
        
        return finalDamage
    end
end

if CLIENT then
    -- Приём синхронизации резистов
    net.Receive("LOTM.Damage.SyncResistance", function()
        local damageType = net.ReadString()
        local value = net.ReadFloat()
        
        local ply = LocalPlayer()
        if not ply.LOTMResistances then
            LOTM.Damage.GetResistances(ply)
        end
        ply.LOTMResistances[damageType] = value
    end)
    
    net.Receive("LOTM.Damage.ResetResistances", function()
        LocalPlayer().LOTMResistances = nil
    end)
    
    -- Эффект при получении урона
    net.Receive("LOTM.Damage.Effect", function()
        local target = net.ReadEntity()
        local damageType = net.ReadString()
        local hitPos = net.ReadVector()
        local damage = net.ReadFloat()
        
        if IsValid(target) then
            LOTM.Damage.PlayEffect(target, damageType, hitPos, damage)
        end
    end)
    
    -- Воспроизведение эффекта урона
    function LOTM.Damage.PlayEffect(target, damageType, hitPos, damage)
        local color = LOTM.Damage.Colors[damageType] or Color(255, 255, 255)
        local particleName = LOTM.Damage.Particles[damageType]
        
        -- Партикл эффект
        if particleName then
            local effectData = EffectData()
            effectData:SetOrigin(hitPos)
            effectData:SetEntity(target)
            effectData:SetScale(1)
            util.Effect(particleName, effectData)
        end
        
        -- Дополнительный визуальный эффект - цветная вспышка
        local emitter = ParticleEmitter(hitPos)
        if emitter then
            for i = 1, math.min(damage / 5, 20) do
                local particle = emitter:Add("effects/spark", hitPos + VectorRand() * 5)
                if particle then
                    particle:SetVelocity(VectorRand() * 50)
                    particle:SetLifeTime(0)
                    particle:SetDieTime(math.Rand(0.3, 0.6))
                    particle:SetStartAlpha(255)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.Rand(2, 4))
                    particle:SetEndSize(0)
                    particle:SetColor(color.r, color.g, color.b)
                    particle:SetGravity(Vector(0, 0, -100))
                end
            end
            emitter:Finish()
        end
    end
    
    -- Настраиваемые партиклы для типов урона
    LOTM.Damage.CustomParticles = LOTM.Damage.CustomParticles or {}
    
    function LOTM.Damage.SetCustomParticle(damageType, particleName)
        LOTM.Damage.Particles[damageType] = particleName
        LOTM.Damage.CustomParticles[damageType] = particleName
    end
end

-- Получить информацию о типе урона
function LOTM.Damage.GetTypeInfo(damageType)
    return {
        id = damageType,
        name = LOTM.Damage.Names[damageType] or "Неизвестный",
        color = LOTM.Damage.Colors[damageType] or Color(255, 255, 255),
        particle = LOTM.Damage.Particles[damageType],
    }
end

-- Получить список всех типов урона
function LOTM.Damage.GetAllTypes()
    local types = {}
    for _, v in pairs(LOTM.Damage.Types) do
        table.insert(types, LOTM.Damage.GetTypeInfo(v))
    end
    return types
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Damage types system loaded (" .. table.Count(LOTM.Damage.Types) .. " types)\n")

