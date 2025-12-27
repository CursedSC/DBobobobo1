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
            ply.LOTMResistances[damageType] = 0
        end
    end
    
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
                    particle:SetEndSize(0)
                    particle:SetColor(color.r, color.g, color.b)
                    particle:SetGravity(Vector(0, 0, -100))
                end
            end
            emitter:Finish()
        end
        
        -- Текст урона
        local effectData = EffectData()
        effectData:SetOrigin(pos)
        effectData:SetStart(Vector(damage, damageType, 0))
        util.Effect("lotm_damage_text", effectData)
    end)
end

print("[LOTM] Система типов урона и резистов загружена")