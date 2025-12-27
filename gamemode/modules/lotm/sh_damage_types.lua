<<<<<<< HEAD
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
=======
-- LOTM Damage Types & Resistances System
-- Типы урона характерные для LOTM

LOTM = LOTM or {}
LOTM.DamageTypes = LOTM.DamageTypes or {}
LOTM.Resistances = LOTM.Resistances or {}

-- Типы урона LOTM
LOTM.DamageTypes = {
    PHYSICAL = 1,          -- Физический урон
    MENTAL = 2,            -- Ментальный урон (атаки на разум)
    SPIRITUAL = 3,         -- Духовный урон
    CORRUPTION = 4,        -- Урон от искажения
    FROST = 5,             -- Ледяной урон
    FLAME = 6,             -- Огненный урон
    LIGHTNING = 7,         -- Электрический урон
    POISON = 8,            -- Ядовитый урон
    DIVINATION = 9,        -- Урон от гадания/провидения
    MYSTERY = 10,          -- Мистический урон
    DEATH = 11,            -- Урон смерти/некромантии
    FATE = 12,             -- Урон от манипуляций судьбой
    DREAM = 13,            -- Урон из мира снов
    DARKNESS = 14,         -- Урон тьмы
    SUN = 15,              -- Урон света/солнца
    STORM = 16,            -- Урон бури/ветра
    SPECTATOR = 17,        -- Урон наблюдателя/всевидящего ока
    ERROR = 18,            -- Урон от ошибок реальности
}

-- Названия типов урона
LOTM.DamageNames = {
    [LOTM.DamageTypes.PHYSICAL] = "Физический",
    [LOTM.DamageTypes.MENTAL] = "Ментальный",
    [LOTM.DamageTypes.SPIRITUAL] = "Духовный",
    [LOTM.DamageTypes.CORRUPTION] = "Искажение",
    [LOTM.DamageTypes.FROST] = "Лёд",
    [LOTM.DamageTypes.FLAME] = "Огонь",
    [LOTM.DamageTypes.LIGHTNING] = "Молния",
    [LOTM.DamageTypes.POISON] = "Яд",
    [LOTM.DamageTypes.DIVINATION] = "Провидение",
    [LOTM.DamageTypes.MYSTERY] = "Мистика",
    [LOTM.DamageTypes.DEATH] = "Смерть",
    [LOTM.DamageTypes.FATE] = "Судьба",
    [LOTM.DamageTypes.DREAM] = "Сон",
    [LOTM.DamageTypes.DARKNESS] = "Тьма",
    [LOTM.DamageTypes.SUN] = "Свет",
    [LOTM.DamageTypes.STORM] = "Буря",
    [LOTM.DamageTypes.SPECTATOR] = "Всевидящее око",
    [LOTM.DamageTypes.ERROR] = "Ошибка реальности",
}

-- Цвета для типов урона (для партиклов)
LOTM.DamageColors = {
    [LOTM.DamageTypes.PHYSICAL] = Color(200, 200, 200),
    [LOTM.DamageTypes.MENTAL] = Color(138, 43, 226),
    [LOTM.DamageTypes.SPIRITUAL] = Color(0, 191, 255),
    [LOTM.DamageTypes.CORRUPTION] = Color(75, 0, 130),
    [LOTM.DamageTypes.FROST] = Color(173, 216, 230),
    [LOTM.DamageTypes.FLAME] = Color(255, 69, 0),
    [LOTM.DamageTypes.LIGHTNING] = Color(255, 255, 0),
    [LOTM.DamageTypes.POISON] = Color(0, 255, 0),
    [LOTM.DamageTypes.DIVINATION] = Color(255, 215, 0),
    [LOTM.DamageTypes.MYSTERY] = Color(148, 0, 211),
    [LOTM.DamageTypes.DEATH] = Color(0, 0, 0),
    [LOTM.DamageTypes.FATE] = Color(218, 165, 32),
    [LOTM.DamageTypes.DREAM] = Color(221, 160, 221),
    [LOTM.DamageTypes.DARKNESS] = Color(25, 25, 25),
    [LOTM.DamageTypes.SUN] = Color(255, 223, 0),
    [LOTM.DamageTypes.STORM] = Color(70, 130, 180),
    [LOTM.DamageTypes.SPECTATOR] = Color(192, 192, 192),
    [LOTM.DamageTypes.ERROR] = Color(255, 0, 255),
}

if SERVER then
    -- Инициализация резистов игрока
    function LOTM.InitPlayerResistances(ply)
        ply.LOTMResistances = ply.LOTMResistances or {}
        
        for damageType, _ in pairs(LOTM.DamageTypes) do
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
            ply.LOTMResistances[damageType] = 0
        end
    end
    
<<<<<<< HEAD
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
=======
    -- Получить резист игрока к типу урона
    function LOTM.GetPlayerResistance(ply, damageType)
        if not ply.LOTMResistances then LOTM.InitPlayerResistances(ply) end
        return ply.LOTMResistances[damageType] or 0
    end
    
    -- Установить резист игрока
    function LOTM.SetPlayerResistance(ply, damageType, value)
        if not ply.LOTMResistances then LOTM.InitPlayerResistances(ply) end
        ply.LOTMResistances[damageType] = math.Clamp(value, -100, 100)
    end
    
    -- Добавить резист игрока
    function LOTM.AddPlayerResistance(ply, damageType, value)
        local current = LOTM.GetPlayerResistance(ply, damageType)
        LOTM.SetPlayerResistance(ply, damageType, current + value)
    end
    
    -- Применить урон с учётом резистов
    function LOTM.ApplyDamage(ply, damage, damageType, attacker, hitPos)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        
        local resistance = LOTM.GetPlayerResistance(ply, damageType)
        local finalDamage = damage * (1 - resistance / 100)
        
        if finalDamage > 0 then
            local dmg = DamageInfo()
            dmg:SetDamage(finalDamage)
            dmg:SetAttacker(IsValid(attacker) and attacker or game.GetWorld())
            dmg:SetInflictor(IsValid(attacker) and attacker or game.GetWorld())
            dmg:SetDamageType(DMG_GENERIC)
            
            if hitPos then
                dmg:SetDamagePosition(hitPos)
            end
            
            ply:TakeDamageInfo(dmg)
            
            -- Отправить информацию для партиклов
            net.Start("LOTM.DamageParticle")
            net.WriteEntity(ply)
            net.WriteVector(hitPos or ply:GetPos())
            net.WriteUInt(damageType, 8)
            net.WriteFloat(finalDamage)
            net.Broadcast()
        end
    end
    
    hook.Add("PlayerInitialSpawn", "LOTM.InitResistances", function(ply)
        LOTM.InitPlayerResistances(ply)
    end)
    
    util.AddNetworkString("LOTM.DamageParticle")
end

if CLIENT then
    -- Получение партиклов урона
    net.Receive("LOTM.DamageParticle", function()
        local ply = net.ReadEntity()
        local pos = net.ReadVector()
        local damageType = net.ReadUInt(8)
        local damage = net.ReadFloat()
        
        if not IsValid(ply) then return end
        
        -- Создание партиклов урона
        local color = LOTM.DamageColors[damageType] or Color(255, 255, 255)
        
        -- Эффект урона
        local emitter = ParticleEmitter(pos)
        if emitter then
            for i = 1, 10 do
                local particle = emitter:Add("effects/spark", pos)
                if particle then
                    particle:SetVelocity(VectorRand() * 50)
                    particle:SetLifeTime(0)
                    particle:SetDieTime(1)
                    particle:SetStartAlpha(255)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(5)
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
                    particle:SetEndSize(0)
                    particle:SetColor(color.r, color.g, color.b)
                    particle:SetGravity(Vector(0, 0, -100))
                end
            end
            emitter:Finish()
        end
<<<<<<< HEAD
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

=======
        
        -- Текст урона
        local effectData = EffectData()
        effectData:SetOrigin(pos)
        effectData:SetStart(Vector(damage, damageType, 0))
        util.Effect("lotm_damage_text", effectData)
    end)
end

print("[LOTM] Система типов урона и резистов загружена")
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
