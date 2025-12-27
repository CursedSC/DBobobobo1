-- LOTM Artifact Weapons System
-- Шаблонная система создания SWEP артефактов
-- Один файл - много оружий с разными конфигами

LOTM = LOTM or {}
LOTM.Weapons = LOTM.Weapons or {}
LOTM.Weapons.Registry = {}

-- =============================================
-- БАЗОВЫЙ КОНФИГ ДЛЯ ВСЕХ АРТЕФАКТОВ
-- =============================================
LOTM.Weapons.DefaultConfig = {
    -- Основные параметры
    name = "Артефакт",
    description = "Мистический артефакт",
    model = "models/weapons/w_knife_t.mdl",
    holdType = "melee2",
    
    -- Урон и атаки
    damage = 25,
    range = 80,
    attacksBeforeCooldown = 3,  -- Количество атак до КД
    attackCooldown = 2.0,        -- КД после 3 атак
    attackDelay = 0.6,           -- Задержка между атаками (медленные)
    
    -- Файтинг опции (true/false)
    canBlock = true,             -- Может блокировать
    canDash = true,              -- Может дэшиться
    canParry = false,            -- Может парировать
    canCharge = false,           -- Заряженная атака
    
    -- Блок
    blockDamageReduction = 0.6,
    perfectBlockWindow = 0.2,
    blockStaminaCost = 15,
    
    -- Дэш
    dashForwardSpeed = 800,
    dashBackSpeed = 600,
    dashCooldown = 1.5,
    dashDuration = 0.15,
    
    -- Атаки (3 штуки)
    attacks = {
        {
            name = "Горизонтальный удар",
            damage = 1.0,  -- Множитель от базового урона
            animation = "swing",
            playerAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "weapons/knife/knife_slash1.wav",
            hitSound = "physics/flesh/flesh_impact_hard1.wav",
            knockback = 100,
        },
        {
            name = "Вертикальный удар", 
            damage = 1.2,
            animation = "stab",
            playerAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "weapons/knife/knife_slash2.wav",
            hitSound = "physics/flesh/flesh_impact_hard2.wav",
            knockback = 150,
        },
        {
            name = "Мощный удар",
            damage = 1.5,
            animation = "swing",
            playerAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "weapons/knife/knife_stab.wav",
            hitSound = "physics/flesh/flesh_impact_hard3.wav",
            knockback = 200,
            finisher = true,
        },
    },
    
    -- Способности (до 7)
    abilities = {},
    
    -- Визуалы
    swingTrailColor = Color(211, 25, 202),
    hitEffect = "BloodImpact",
}

-- =============================================
-- РЕГИСТРАЦИЯ АРТЕФАКТА-ОРУЖИЯ
-- =============================================
function LOTM.Weapons.Register(config)
    if not config.id then
        print("[LOTM] Weapons.Register: id required!")
        return
    end
    
    -- Мержим с дефолтным конфигом
    local fullConfig = table.Copy(LOTM.Weapons.DefaultConfig)
    table.Merge(fullConfig, config)
    
    LOTM.Weapons.Registry[config.id] = fullConfig
    
    print("[LOTM] Weapon registered: " .. config.id .. " (" .. fullConfig.name .. ")")
    
    return fullConfig
end

-- =============================================
-- ПОЛУЧЕНИЕ КОНФИГА
-- =============================================
function LOTM.Weapons.Get(id)
    return LOTM.Weapons.Registry[id]
end

function LOTM.Weapons.GetAll()
    return LOTM.Weapons.Registry
end

-- =============================================
-- РЕГИСТРАЦИЯ АРТЕФАКТОВ-ОРУЖИЙ
-- =============================================
hook.Add("InitPostEntity", "LOTM.Weapons.RegisterAll", function()
    timer.Simple(0.5, function()
        
        -- ═══════════════════════════════════════════
        -- КОЛЬЦО КРОВИ - Вампирское оружие
        -- ═══════════════════════════════════════════
        LOTM.Weapons.Register({
            id = "ring_of_blood",
            name = "Когти Крови",
            description = "Тёмные когти, питающиеся кровью врагов",
            model = "models/weapons/w_knife_t.mdl",
            holdType = "knife",
            
            damage = 28,
            range = 70,
            attacksBeforeCooldown = 3,
            attackCooldown = 2.5,
            attackDelay = 0.5,
            
            canBlock = true,
            canDash = true,
            canParry = false,
            
            blockDamageReduction = 0.5,
            dashForwardSpeed = 900,
            dashBackSpeed = 700,
            
            attacks = {
                {
                    name = "Кровавый разрез",
                    damage = 1.0,
                    sound = "weapons/knife/knife_slash1.wav",
                    hitSound = "physics/flesh/flesh_bloody_break.wav",
                    knockback = 80,
                    lifesteal = 5,
                },
                {
                    name = "Жатва крови",
                    damage = 1.3,
                    sound = "weapons/knife/knife_slash2.wav",
                    hitSound = "physics/flesh/flesh_impact_hard2.wav",
                    knockback = 120,
                    lifesteal = 10,
                    bleed = true,
                },
                {
                    name = "Кровавый взрыв",
                    damage = 1.8,
                    sound = "weapons/knife/knife_stab.wav",
                    hitSound = "physics/flesh/flesh_squishy_impact_hard1.wav",
                    knockback = 200,
                    lifesteal = 20,
                    bleed = true,
                    finisher = true,
                },
            },
            
            swingTrailColor = Color(180, 0, 0),
        })
        
        -- ═══════════════════════════════════════════
        -- МИСТИЧЕСКИЙ КЛИНОК - Баланс
        -- ═══════════════════════════════════════════
        LOTM.Weapons.Register({
            id = "mystic_blade",
            name = "Мистический Клинок",
            description = "Клинок, наполненный мистической энергией",
            model = "models/weapons/w_knife_t.mdl",
            holdType = "melee2",
            
            damage = 32,
            range = 85,
            attacksBeforeCooldown = 3,
            attackCooldown = 2.0,
            attackDelay = 0.55,
            
            canBlock = true,
            canDash = true,
            canParry = true,
            
            blockDamageReduction = 0.65,
            perfectBlockWindow = 0.25,
            
            attacks = {
                {
                    name = "Быстрый взмах",
                    damage = 1.0,
                    sound = "weapons/knife/knife_slash1.wav",
                    knockback = 100,
                },
                {
                    name = "Мощный удар",
                    damage = 1.25,
                    sound = "weapons/knife/knife_slash2.wav",
                    knockback = 140,
                    stun = 0.3,
                },
                {
                    name = "Мистический разряд",
                    damage = 1.6,
                    sound = "ambient/energy/zap5.wav",
                    hitSound = "ambient/energy/spark1.wav",
                    knockback = 220,
                    magicDamage = true,
                    finisher = true,
                },
            },
            
            swingTrailColor = Color(211, 25, 202),
        })
        
        -- ═══════════════════════════════════════════
        -- ТЕНЕВОЙ КИНЖАЛ - Быстрые атаки
        -- ═══════════════════════════════════════════
        LOTM.Weapons.Register({
            id = "shadow_dagger",
            name = "Теневой Кинжал",
            description = "Кинжал из чистой тьмы, невероятно быстрый",
            model = "models/weapons/w_knife_t.mdl",
            holdType = "knife",
            
            damage = 20,
            range = 60,
            attacksBeforeCooldown = 3,
            attackCooldown = 1.5,
            attackDelay = 0.35,
            
            canBlock = false,  -- Не может блокировать
            canDash = true,
            canParry = false,
            
            dashForwardSpeed = 1000,
            dashBackSpeed = 800,
            dashCooldown = 1.0,
            
            attacks = {
                {
                    name = "Теневой укол",
                    damage = 0.9,
                    sound = "weapons/knife/knife_slash1.wav",
                    knockback = 50,
                },
                {
                    name = "Двойной удар",
                    damage = 1.1,
                    sound = "weapons/knife/knife_slash2.wav",
                    knockback = 70,
                },
                {
                    name = "Теневое касание",
                    damage = 1.4,
                    sound = "weapons/knife/knife_stab.wav",
                    knockback = 100,
                    invisible = 1.5,  -- Невидимость
                    finisher = true,
                },
            },
            
            swingTrailColor = Color(50, 0, 80),
        })
        
        -- ═══════════════════════════════════════════
        -- СВЯТОЙ МЕЧ - Защитный
        -- ═══════════════════════════════════════════
        LOTM.Weapons.Register({
            id = "holy_sword",
            name = "Святой Меч",
            description = "Благословлённый клинок, несущий свет",
            model = "models/weapons/w_knife_t.mdl",
            holdType = "melee2",
            
            damage = 35,
            range = 90,
            attacksBeforeCooldown = 3,
            attackCooldown = 2.5,
            attackDelay = 0.65,
            
            canBlock = true,
            canDash = true,
            canParry = true,
            
            blockDamageReduction = 0.8,  -- Сильный блок
            perfectBlockWindow = 0.3,
            
            attacks = {
                {
                    name = "Святой удар",
                    damage = 1.0,
                    sound = "weapons/knife/knife_slash1.wav",
                    knockback = 120,
                    holyDamage = true,
                },
                {
                    name = "Очищение",
                    damage = 1.2,
                    sound = "weapons/knife/knife_slash2.wav",
                    knockback = 150,
                    holyDamage = true,
                    heal = 5,  -- Лечит владельца
                },
                {
                    name = "Божественный гнев",
                    damage = 2.0,
                    sound = "ambient/energy/whiteflash.wav",
                    hitSound = "ambient/energy/spark1.wav",
                    knockback = 300,
                    holyDamage = true,
                    heal = 15,
                    finisher = true,
                },
            },
            
            swingTrailColor = Color(255, 215, 100),
        })
        
        -- ═══════════════════════════════════════════
        -- ПОСОХ ХАОСА - Магический
        -- ═══════════════════════════════════════════
        LOTM.Weapons.Register({
            id = "chaos_staff",
            name = "Посох Хаоса",
            description = "Посох, несущий разрушение",
            model = "models/props_combine/breenlight.mdl",
            holdType = "melee2",
            
            damage = 40,
            range = 100,
            attacksBeforeCooldown = 3,
            attackCooldown = 3.0,
            attackDelay = 0.8,
            
            canBlock = false,
            canDash = true,
            canParry = false,
            canCharge = true,  -- Заряженная атака
            
            attacks = {
                {
                    name = "Удар посоха",
                    damage = 0.8,
                    sound = "physics/metal/metal_solid_impact_hard1.wav",
                    knockback = 150,
                    magicDamage = true,
                },
                {
                    name = "Волна хаоса",
                    damage = 1.2,
                    sound = "ambient/energy/zap7.wav",
                    knockback = 200,
                    magicDamage = true,
                    aoe = 100,  -- Урон по площади
                },
                {
                    name = "Хаотический взрыв",
                    damage = 2.0,
                    sound = "ambient/explosions/explode_4.wav",
                    knockback = 350,
                    magicDamage = true,
                    aoe = 150,
                    finisher = true,
                },
            },
            
            swingTrailColor = Color(255, 50, 50),
        })
        
        print("[LOTM] All artifact weapons registered: " .. table.Count(LOTM.Weapons.Registry))
    end)
end)

-- =============================================
-- СИСТЕМА ДЭШЕЙ
-- =============================================
LOTM.Dash = LOTM.Dash or {}
LOTM.Dash.LastDashTime = {}
LOTM.Dash.IsDashing = {}

function LOTM.Dash.CanDash(ply)
    if not IsValid(ply) then return false end
    
    local lastDash = LOTM.Dash.LastDashTime[ply] or 0
    local weapon = ply:GetActiveWeapon()
    
    local cooldown = 1.5
    if IsValid(weapon) and weapon.ArtifactConfig then
        cooldown = weapon.ArtifactConfig.dashCooldown or 1.5
    end
    
    return CurTime() - lastDash >= cooldown
end

function LOTM.Dash.Perform(ply, direction)
    if not IsValid(ply) then return end
    if not LOTM.Dash.CanDash(ply) then return end
    if LOTM.Dash.IsDashing[ply] then return end
    
    local weapon = ply:GetActiveWeapon()
    local config = weapon and weapon.ArtifactConfig
    
    -- Проверяем может ли дэшиться
    if config and not config.canDash then return end
    
    local forwardSpeed = (config and config.dashForwardSpeed) or 800
    local backSpeed = (config and config.dashBackSpeed) or 600
    local duration = (config and config.dashDuration) or 0.15
    
    LOTM.Dash.IsDashing[ply] = true
    LOTM.Dash.LastDashTime[ply] = CurTime()
    
    if SERVER then
        local vel = Vector(0, 0, 0)
        local forward = ply:GetAimVector()
        forward.z = 0
        forward:Normalize()
        
        if direction == "forward" then
            vel = forward * forwardSpeed
        elseif direction == "back" then
            vel = forward * -backSpeed
        elseif direction == "left" then
            vel = forward:Cross(Vector(0, 0, 1)) * -forwardSpeed
        elseif direction == "right" then
            vel = forward:Cross(Vector(0, 0, 1)) * forwardSpeed
        end
        
        ply:SetVelocity(vel)
        ply:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 4) .. ".wav", 60)
        
        -- Эффект
        local effectData = EffectData()
        effectData:SetOrigin(ply:GetPos())
        effectData:SetEntity(ply)
        util.Effect("propspawn", effectData)
    end
    
    timer.Simple(duration, function()
        if IsValid(ply) then
            LOTM.Dash.IsDashing[ply] = false
        end
    end)
end

-- Сетевые команды для дэшей
if SERVER then
    util.AddNetworkString("LOTM.Dash")
    
    net.Receive("LOTM.Dash", function(len, ply)
        local direction = net.ReadString()
        LOTM.Dash.Perform(ply, direction)
    end)
end

if CLIENT then
    function LOTM.Dash.Request(direction)
        net.Start("LOTM.Dash")
        net.WriteString(direction)
        net.SendToServer()
    end
end

print("[LOTM] Artifact Weapons System loaded")

