-- LOTM Combat System v1.0
-- Ядро боевой системы
-- Единая система для артефактов, оружия и способностей

LOTM = LOTM or {}
LOTM.Combat = LOTM.Combat or {}

-- =============================================
-- КОНФИГУРАЦИЯ БОЕВОЙ СИСТЕМЫ
-- =============================================
LOTM.Combat.Config = {
    -- Клавиши способностей
    ABILITY_KEYS = {
        PRIMARY = IN_USE,           -- E - Основная атака
        PRIMARY_SHIFT = "E_SHIFT",  -- E+Shift - Усиленная основная
        SECONDARY = IN_RELOAD,      -- R - Вторичная способность  
        SECONDARY_SHIFT = "R_SHIFT",-- R+Shift - Усиленная вторичная
        ULTIMATE = IN_ATTACK2,      -- F - Ультимативная (через bind)
        ULTIMATE_SHIFT = "F_SHIFT", -- F+Shift - Усиленная ульта
    },
    
    -- Клавиши движения
    DASH_KEY = KEY_LALT,            -- Дэш
    BLOCK_KEY = IN_ATTACK2,         -- Блок (ПКМ при оружии)
    
    -- Кулдауны
    DEFAULT_COOLDOWNS = {
        primary = 1.0,
        primary_shift = 2.5,
        secondary = 5.0,
        secondary_shift = 8.0,
        ultimate = 15.0,
        ultimate_shift = 25.0,
        dash = 1.5,
    },
    
    -- Урон
    DEFAULT_DAMAGE = {
        primary = 15,
        primary_shift = 25,
        secondary = 35,
        secondary_shift = 50,
        ultimate = 75,
        ultimate_shift = 100,
    },
}

-- =============================================
-- РЕЕСТР БОЕВЫХ СТИЛЕЙ (для артефактов и оружия)
-- =============================================
LOTM.Combat.Styles = LOTM.Combat.Styles or {}

-- Структура боевого стиля
--[[
LOTM.Combat.RegisterStyle({
    id = "style_id",
    name = "Название стиля",
    description = "Описание",
    
    -- Способности (6 слотов)
    abilities = {
        primary = {
            name = "E - Атака",
            damage = 15,
            cooldown = 1.0,
            range = 100,
            animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "weapons/knife/knife_slash1.wav",
            onUse = function(ply, target) end,
        },
        primary_shift = { ... },
        secondary = { ... },
        secondary_shift = { ... },
        ultimate = { ... },
        ultimate_shift = { ... },
    },
    
    -- Пассивные бонусы
    passives = {
        damage_bonus = 1.0,
        speed_bonus = 1.0,
        defense_bonus = 0,
    },
})
]]

function LOTM.Combat.RegisterStyle(data)
    if not data.id then
        ErrorNoHalt("[LOTM Combat] Ошибка: отсутствует id стиля\n")
        return false
    end
    
    -- Заполняем дефолтными значениями
    data.name = data.name or "Неизвестный стиль"
    data.description = data.description or ""
    data.abilities = data.abilities or {}
    data.passives = data.passives or {}
    
    -- Заполняем дефолтные способности
    local abilityTypes = {"primary", "primary_shift", "secondary", "secondary_shift", "ultimate", "ultimate_shift"}
    for _, abilityType in ipairs(abilityTypes) do
        if not data.abilities[abilityType] then
            data.abilities[abilityType] = {
                name = "Способность",
                damage = LOTM.Combat.Config.DEFAULT_DAMAGE[abilityType] or 10,
                cooldown = LOTM.Combat.Config.DEFAULT_COOLDOWNS[abilityType] or 1.0,
                range = 100,
                enabled = false,
            }
        else
            data.abilities[abilityType].enabled = true
        end
    end
    
    LOTM.Combat.Styles[data.id] = data
    
    MsgC(Color(100, 200, 255), "[LOTM Combat] ", Color(255, 255, 255), 
         "Стиль зарегистрирован: " .. data.name .. "\n")
    
    return true
end

function LOTM.Combat.GetStyle(styleId)
    return LOTM.Combat.Styles[styleId]
end

-- =============================================
-- УПРАВЛЕНИЕ КУЛДАУНАМИ
-- =============================================
LOTM.Combat.Cooldowns = LOTM.Combat.Cooldowns or {}

local function GetPlayerID(ply)
    return ply:SteamID64() or ply:UniqueID()
end

function LOTM.Combat.SetCooldown(ply, abilityType, duration)
    local pid = GetPlayerID(ply)
    if not LOTM.Combat.Cooldowns[pid] then
        LOTM.Combat.Cooldowns[pid] = {}
    end
    LOTM.Combat.Cooldowns[pid][abilityType] = CurTime() + duration
end

function LOTM.Combat.GetCooldownRemaining(ply, abilityType)
    local pid = GetPlayerID(ply)
    if not LOTM.Combat.Cooldowns[pid] then return 0 end
    local endTime = LOTM.Combat.Cooldowns[pid][abilityType]
    if not endTime then return 0 end
    return math.max(0, endTime - CurTime())
end

function LOTM.Combat.IsOnCooldown(ply, abilityType)
    return LOTM.Combat.GetCooldownRemaining(ply, abilityType) > 0
end

-- =============================================
-- СЕТЕВЫЕ СТРОКИ
-- =============================================
if SERVER then
    util.AddNetworkString("LOTM.Combat.UseAbility")
    util.AddNetworkString("LOTM.Combat.AbilityEffect")
    util.AddNetworkString("LOTM.Combat.SyncCooldown")
    util.AddNetworkString("LOTM.Combat.Dash")
end

-- =============================================
-- АКТИВАЦИЯ СПОСОБНОСТИ (SERVER)
-- =============================================
if SERVER then
    function LOTM.Combat.UseAbility(ply, abilityType)
        if not IsValid(ply) or not ply:Alive() then return false end
        
        -- Получаем активный стиль боя (от оружия или артефакта)
        local style = LOTM.Combat.GetPlayerCombatStyle(ply)
        if not style then return false end
        
        local ability = style.abilities[abilityType]
        if not ability or not ability.enabled then return false end
        
        -- Проверка кулдауна
        if LOTM.Combat.IsOnCooldown(ply, abilityType) then
            return false
        end
        
        -- Устанавливаем кулдаун
        LOTM.Combat.SetCooldown(ply, abilityType, ability.cooldown or 1.0)
        
        -- Синхронизируем кулдаун с клиентом
        net.Start("LOTM.Combat.SyncCooldown")
        net.WriteString(abilityType)
        net.WriteFloat(ability.cooldown or 1.0)
        net.Send(ply)
        
        -- Анимация
        if ability.animation then
            ply:DoAnimationEvent(ability.animation)
        end
        
        -- Звук
        if ability.sound then
            ply:EmitSound(ability.sound)
        end
        
        -- Урон по цели
        if ability.damage and ability.damage > 0 then
            LOTM.Combat.DealDamage(ply, ability)
        end
        
        -- Кастомная логика
        if ability.onUse then
            local target = ply:GetEyeTrace().Entity
            ability.onUse(ply, target, ability)
        end
        
        -- Эффект на клиенте
        net.Start("LOTM.Combat.AbilityEffect")
        net.WriteString(abilityType)
        net.WriteEntity(ply)
        net.Broadcast()
        
        return true
    end
    
    function LOTM.Combat.DealDamage(ply, ability)
        local range = ability.range or 100
        local tr = ply:GetEyeTrace()
        
        if ability.aoe and ability.aoe > 0 then
            -- AoE урон
            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), ability.aoe)) do
                if ent:IsPlayer() and ent ~= ply and ent:Alive() then
                    local dmg = DamageInfo()
                    dmg:SetDamage(ability.damage)
                    dmg:SetAttacker(ply)
                    dmg:SetInflictor(ply)
                    dmg:SetDamageType(ability.damageType or DMG_GENERIC)
                    ent:TakeDamageInfo(dmg)
                end
            end
        else
            -- Single target
            if IsValid(tr.Entity) and tr.HitPos:Distance(ply:GetPos()) <= range then
                local dmg = DamageInfo()
                dmg:SetDamage(ability.damage)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(ply)
                dmg:SetDamageType(ability.damageType or DMG_GENERIC)
                tr.Entity:TakeDamageInfo(dmg)
                
                -- Звук попадания
                if ability.hitSound then
                    tr.Entity:EmitSound(ability.hitSound)
                end
            end
        end
    end
    
    -- Получение активного боевого стиля игрока
    function LOTM.Combat.GetPlayerCombatStyle(ply)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            -- Проверяем есть ли у оружия боевой стиль
            if weapon.CombatStyleID then
                return LOTM.Combat.GetStyle(weapon.CombatStyleID)
            end
            
            -- Проверяем артефакт в руках
            if weapon.ArtifactConfig and weapon.ArtifactConfig.combatStyleId then
                return LOTM.Combat.GetStyle(weapon.ArtifactConfig.combatStyleId)
            end
        end
        
        -- Дефолтный стиль
        return LOTM.Combat.GetStyle("default_melee")
    end
    
    -- Обработка сетевого запроса
    net.Receive("LOTM.Combat.UseAbility", function(len, ply)
        local abilityType = net.ReadString()
        LOTM.Combat.UseAbility(ply, abilityType)
    end)
end

-- =============================================
-- КЛИЕНТСКАЯ ЧАСТЬ
-- =============================================
if CLIENT then
    LOTM.Combat.LocalCooldowns = {}
    
    -- Синхронизация кулдауна
    net.Receive("LOTM.Combat.SyncCooldown", function()
        local abilityType = net.ReadString()
        local duration = net.ReadFloat()
        LOTM.Combat.LocalCooldowns[abilityType] = CurTime() + duration
    end)
    
    function LOTM.Combat.GetLocalCooldown(abilityType)
        local endTime = LOTM.Combat.LocalCooldowns[abilityType]
        if not endTime then return 0 end
        return math.max(0, endTime - CurTime())
    end
    
    function LOTM.Combat.RequestAbility(abilityType)
        net.Start("LOTM.Combat.UseAbility")
        net.WriteString(abilityType)
        net.SendToServer()
    end
    
    -- Проверка, держит ли игрок оружие (не руки)
    function LOTM.Combat.IsHoldingWeapon()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) then return false end
        
        local class = weapon:GetClass()
        -- Исключаем руки и физган
        if class == "hands" or class == "gmod_hands" or class == "weapon_physgun" or class == "gmod_tool" then
            return false
        end
        
        return true
    end
end

-- =============================================
-- РЕГИСТРАЦИЯ ДЕФОЛТНОГО СТИЛЯ
-- =============================================
LOTM.Combat.RegisterStyle({
    id = "default_melee",
    name = "Базовый бой",
    description = "Стандартный стиль ближнего боя",
    
    abilities = {
        primary = {
            name = "[E] Удар",
            damage = 15,
            cooldown = 0.8,
            range = 80,
            animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "weapons/knife/knife_slash1.wav",
            hitSound = "physics/flesh/flesh_impact_hard1.wav",
            enabled = true,
        },
        primary_shift = {
            name = "[E+Shift] Мощный удар",
            damage = 30,
            cooldown = 2.0,
            range = 100,
            animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "weapons/knife/knife_slash2.wav",
            hitSound = "physics/flesh/flesh_impact_hard2.wav",
            enabled = true,
        },
        secondary = {
            name = "[R] Толчок",
            damage = 5,
            cooldown = 3.0,
            range = 120,
            animation = ACT_GMOD_GESTURE_ITEM_THROW,
            sound = "physics/body/body_medium_impact_soft3.wav",
            enabled = true,
            onUse = function(ply, target, ability)
                if SERVER and IsValid(target) and target:IsPlayer() then
                    local dir = (target:GetPos() - ply:GetPos()):GetNormalized()
                    target:SetVelocity(dir * 400 + Vector(0, 0, 150))
                end
            end,
        },
        secondary_shift = {
            name = "[R+Shift] Захват",
            damage = 10,
            cooldown = 6.0,
            range = 60,
            animation = ACT_GMOD_GESTURE_BOW,
            sound = "physics/body/body_medium_impact_soft5.wav",
            enabled = true,
        },
        ultimate = {
            name = "[F] Финишер",
            damage = 50,
            cooldown = 12.0,
            range = 80,
            aoe = 0,
            animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "ambient/energy/whiteflash.wav",
            hitSound = "physics/flesh/flesh_squishy_impact_hard1.wav",
            enabled = true,
        },
        ultimate_shift = {
            name = "[F+Shift] Ультимативный удар",
            damage = 80,
            cooldown = 20.0,
            range = 150,
            aoe = 150,
            animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
            sound = "ambient/explosions/explode_4.wav",
            enabled = true,
        },
    },
})

MsgC(Color(100, 200, 255), "[LOTM] ", Color(255, 255, 255), "Combat Core v1.0 loaded\n")

