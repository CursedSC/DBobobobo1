-- LOTM Unified Abilities System v2.0
-- Единый файл всех способностей с интеграцией wound системы
-- БЕЗ системы энергии

LOTM = LOTM or {}
LOTM.Abilities = LOTM.Abilities or {}
LOTM.Abilities.Registry = LOTM.Abilities.Registry or {}
LOTM.Abilities.MAX_SLOTS = 7

-- =============================================
-- УПРОЩЁННЫЙ ШАБЛОН СПОСОБНОСТИ
-- =============================================
--[[
LOTM.Abilities.Create({
    id = "ability_id",                   -- Уникальный ID (обязательно)
    name = "Название",                    -- Название
    description = "Описание",             -- Описание
    icon = "path/to/icon.png",            -- Иконка
    
    -- Базовые параметры
    cooldown = 10,                        -- Кулдаун (сек)
    castTime = 0,                         -- Время каста (0 = мгновенно)
    maxCharges = 1,                       -- Макс. зарядов (1 = без зарядов)
    chargeRegenTime = 5,                  -- Время восстановления заряда
    
    -- Требования
    pathway = nil,                        -- ID пути (nil = любой)
    requiredSequence = 9,                 -- Мин. последовательность
    
    -- Эффекты на себя (true/false или таблица)
    selfEffects = {
        haste = true,                     -- Ускорение
        invisible = false,                -- Невидимость
        regeneration = false,             -- Регенерация
        -- Или с параметрами:
        -- {id = "haste", duration = 5, percent = 1.5}
    },
    
    -- Эффекты на цель
    targetEffects = {
        slowed = true,
        burning = false,
        stunned = false,
    },
    
    -- Урон
    damage = {
        enabled = true,
        amount = 25,
        type = "spiritual",               -- physical, fire, ice, spiritual, mental, corruption
        radius = 0,                       -- 0 = single target
        range = 200,                      -- Дальность
    },
    
    -- Лечение (с поддержкой wound системы)
    healing = {
        enabled = false,
        amount = 20,
        healWounds = true,                -- Лечит раны из dbt wound системы?
        woundTypes = {"Ранение", "Ушиб"}, -- Какие типы ран лечит
        healAllWounds = false,            -- Лечит ВСЕ раны?
    },
    
    -- Анимации
    animation = {
        gesture = ACT_GMOD_GESTURE_WAVE,  -- Жест при касте
        sequence = nil,                   -- Последовательность анимации
    },
    
    -- Визуальные эффекты
    visuals = {
        castSound = "path/to/sound.wav",
        hitSound = nil,
        castParticle = nil,
        hitParticle = nil,
        screenEffect = nil,               -- "shake", "flash"
    },
    
    -- Аура
    aura = {
        enabled = false,
        auraId = "aura_regeneration",
        duration = 30,
    },
    
    -- Кастомная логика
    onCast = function(ply, ability) end,
    onHit = function(ply, target, ability) end,
    onEnd = function(ply, ability) end,
})
]]

-- =============================================
-- СОЗДАНИЕ СПОСОБНОСТИ
-- =============================================

function LOTM.Abilities.Create(data)
    if not data.id then
        ErrorNoHalt("[LOTM] Ошибка: отсутствует id способности\n")
        return false
    end
    
    local ability = {
        id = data.id,
        name = data.name or "Неизвестная способность",
        description = data.description or "",
        icon = data.icon or "vgui/notices/generic",
        
        cooldown = data.cooldown or 0,
        castTime = data.castTime or 0,
        maxCharges = data.maxCharges or 1,
        chargeRegenTime = data.chargeRegenTime or data.cooldown or 5,
        
        pathway = data.pathway,
        requiredSequence = data.requiredSequence or 9,
        
        selfEffects = data.selfEffects or {},
        targetEffects = data.targetEffects or {},
        damage = data.damage or {enabled = false},
        healing = data.healing or {enabled = false},
        animation = data.animation or {},
        visuals = data.visuals or {},
        aura = data.aura or {enabled = false},
        
        onCast = data.onCast,
        onHit = data.onHit,
        onEnd = data.onEnd,
    }
    
    LOTM.Abilities.Registry[ability.id] = ability
    
    return true
end

-- Получить способность
function LOTM.Abilities.Get(abilityId)
    return LOTM.Abilities.Registry[abilityId]
end

-- =============================================
-- ВСЕ СПОСОБНОСТИ
-- =============================================

hook.Add("InitPostEntity", "LOTM.Abilities.RegisterAll", function()
    
    -- ========== ПУТЬ ТЬМЫ (Pathway 16) ==========
    
    -- Seq 9: Спящий
    LOTM.Abilities.Create({
        id = "darkness_vision",
        name = "Ночное Зрение",
        description = "Видьте в темноте как днём на 60 секунд",
        icon = "lotm/abilities/darkness_vision.png",
        pathway = 16,
        requiredSequence = 9,
        cooldown = 30,
        
        selfEffects = {
            {id = "night_vision", duration = 60},
        },
        
        visuals = {
            castSound = "ambient/atmosphere/cave_hit1.wav",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                ply:SetNWBool("LOTM_NightVision", true)
                timer.Simple(60, function()
                    if IsValid(ply) then
                        ply:SetNWBool("LOTM_NightVision", false)
                    end
                end)
            end
        end,
    })
    
    LOTM.Abilities.Create({
        id = "dream_walk",
        name = "Вход в Сны",
        description = "Становитесь невидимым на 10 секунд",
        icon = "lotm/abilities/dream_walk.png",
        pathway = 16,
        requiredSequence = 9,
        cooldown = 45,
        
        selfEffects = {
            {id = "invisible", duration = 10},
        },
        
        animation = {
            gesture = ACT_GMOD_GESTURE_AGREE,
        },
        
        onCast = function(ply, ability)
            if SERVER then
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)
                ply:SetColor(Color(255, 255, 255, 30))
                
                timer.Simple(10, function()
                    if IsValid(ply) then
                        ply:SetRenderMode(RENDERMODE_NORMAL)
                        ply:SetColor(Color(255, 255, 255, 255))
                    end
                end)
            end
        end,
    })
    
    -- Seq 8: Полуночный Поэт
    LOTM.Abilities.Create({
        id = "blood_manipulation",
        name = "Манипуляция Кровью",
        description = "Контролируйте кровь врагов, нанося урон и замедляя",
        icon = "lotm/abilities/blood_manipulation.png",
        pathway = 16,
        requiredSequence = 8,
        cooldown = 8,
        
        damage = {
            enabled = true,
            amount = 35,
            type = "corruption",
            range = 300,
            radius = 0,
        },
        
        targetEffects = {
            {id = "slowed", duration = 4, percent = 0.5},
            {id = "weakened", duration = 6},
        },
        
        animation = {
            gesture = ACT_GMOD_GESTURE_ITEM_THROW,
        },
        
        visuals = {
            castSound = "physics/flesh/flesh_bloody_break.wav",
            hitParticle = "blood_impact_red_01",
        },
    })
    
    LOTM.Abilities.Create({
        id = "poetry_curse",
        name = "Проклятие Стихов",
        description = "Прочтите проклятый стих, поражая всех врагов вокруг",
        icon = "lotm/abilities/poetry_curse.png",
        pathway = 16,
        requiredSequence = 8,
        cooldown = 15,
        castTime = 2.0,
        
        damage = {
            enabled = true,
            amount = 20,
            type = "mental",
            range = 400,
            radius = 400,
        },
        
        targetEffects = {
            {id = "cursed", duration = 10},
            {id = "weakened", duration = 8},
        },
        
        animation = {
            gesture = ACT_GMOD_GESTURE_ITEM_GIVE,
        },
        
        visuals = {
            castSound = "ambient/atmosphere/cave_hit5.wav",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                local poems = {
                    "«В полночь тёмную, когда луна скрыта...»",
                    "«Кровь течёт рекой, проклятье пробуждается...»",
                    "«Тени шепчут, души трепещут...»",
                }
                
                local poem = poems[math.random(#poems)]
                for _, p in ipairs(player.GetAll()) do
                    if p:GetPos():Distance(ply:GetPos()) < 500 then
                        p:ChatPrint(ply:Name() .. " читает: " .. poem)
                    end
                end
            end
        end,
    })
    
    LOTM.Abilities.Create({
        id = "blood_drain",
        name = "Высасывание Крови",
        description = "Высосите кровь врага, исцеляя себя и раны",
        icon = "lotm/abilities/blood_drain.png",
        pathway = 16,
        requiredSequence = 8,
        maxCharges = 3,
        chargeRegenTime = 6,
        
        damage = {
            enabled = true,
            amount = 25,
            type = "physical",
            range = 200,
        },
        
        healing = {
            enabled = true,
            amount = 20,
            healWounds = true,
            woundTypes = {"Ранение"},
        },
        
        visuals = {
            castSound = "physics/flesh/flesh_squishy_impact_hard4.wav",
            hitParticle = "blood_impact_red_01",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                -- Исцеление
                ply:SetHealth(math.min(ply:Health() + 20, ply:GetMaxHealth()))
                
                -- Лечение раны
                if dbt and dbt.hasWound and dbt.removeWound then
                    if dbt.hasWound(ply, "Ранение") then
                        for _, position in pairs(dbt.woundsposition or {}) do
                            if dbt.hasWoundOnpos and dbt.hasWoundOnpos(ply, "Ранение", position) then
                                dbt.removeWound(ply, "Ранение", position)
                                ply:ChatPrint("[LOTM] Кровь исцелила ваше ранение!")
                                break
                            end
                        end
                    end
                end
            end
        end,
    })
    
    -- ========== ПУТЬ ПРОВИДЦА (Pathway 1) ==========
    
    LOTM.Abilities.Create({
        id = "danger_sense",
        name = "Чувство Опасности",
        description = "Ощутите опасность заранее на 30 секунд",
        icon = "lotm/abilities/danger_sense.png",
        pathway = 1,
        requiredSequence = 9,
        cooldown = 60,
        
        selfEffects = {
            {id = "danger_sense", duration = 30},
        },
        
        onCast = function(ply, ability)
            if SERVER then
                ply:SetNWBool("LOTM_DangerSense", true)
                timer.Simple(30, function()
                    if IsValid(ply) then
                        ply:SetNWBool("LOTM_DangerSense", false)
                    end
                end)
            end
        end,
    })
    
    -- ========== УНИВЕРСАЛЬНЫЕ СПОСОБНОСТИ ==========
    
    LOTM.Abilities.Create({
        id = "spiritual_strike",
        name = "Духовный Удар",
        description = "Мощный удар духовной энергией",
        icon = "lotm/abilities/spiritual_strike.png",
        requiredSequence = 9,
        maxCharges = 3,
        chargeRegenTime = 5,
        
        damage = {
            enabled = true,
            amount = 25,
            type = "spiritual",
            range = 150,
            radius = 150,
        },
        
        selfEffects = {
            {id = "empowered", duration = 3},
        },
        
        targetEffects = {
            {id = "weakened", duration = 5},
        },
        
        visuals = {
            castSound = "ambient/energy/whiteflash.wav",
        },
    })
    
    -- ИСЦЕЛЯЮЩИЙ СВЕТ - с полной интеграцией wound системы
    LOTM.Abilities.Create({
        id = "healing_light",
        name = "Исцеляющий Свет",
        description = "Мгновенно восстанавливает здоровье и лечит раны",
        icon = "lotm/abilities/healing_light.png",
        requiredSequence = 8,
        maxCharges = 5,
        chargeRegenTime = 4,
        
        healing = {
            enabled = true,
            amount = 25,
            healWounds = true,
            woundTypes = {"Ранение", "Ушиб", "Тяжелое ранение"},
        },
        
        selfEffects = {
            {id = "regeneration", duration = 5, heal = 5},
        },
        
        visuals = {
            castSound = "items/medshot4.wav",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                -- Восстановление HP
                ply:SetHealth(math.min(ply:Health() + 25, ply:GetMaxHealth()))
                
                -- Лечим раны через dbt систему
                if dbt and dbt.hasWound and dbt.removeWound and dbt.woundsposition then
                    local healed = false
                    
                    -- Приоритет лечения: сначала легкие раны
                    local woundPriority = {"Ушиб", "Ранение", "Тяжелое ранение"}
                    
                    for _, woundType in ipairs(woundPriority) do
                        if dbt.hasWound(ply, woundType) then
                            for _, position in pairs(dbt.woundsposition) do
                                if dbt.hasWoundOnpos and dbt.hasWoundOnpos(ply, woundType, position) then
                                    dbt.removeWound(ply, woundType, position)
                                    ply:ChatPrint("[LOTM] Исцеляющий свет вылечил: " .. woundType .. " (" .. position .. ")")
                                    healed = true
                                    break
                                end
                            end
                            if healed then break end
                        end
                    end
                    
                    if not healed then
                        ply:ChatPrint("[LOTM] Исцеляющий свет: раны не обнаружены")
                    end
                end
            end
        end,
    })
    
    -- ПОЛНОЕ ИСЦЕЛЕНИЕ - мощная способность высокой последовательности
    LOTM.Abilities.Create({
        id = "divine_healing",
        name = "Божественное Исцеление",
        description = "Полностью исцеляет все раны и восстанавливает здоровье",
        icon = "lotm/abilities/divine_healing.png",
        requiredSequence = 5,
        cooldown = 120,
        
        healing = {
            enabled = true,
            amount = 100,
            healWounds = true,
            healAllWounds = true,
        },
        
        visuals = {
            castSound = "ambient/energy/whiteflash.wav",
            screenEffect = "flash",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                -- Полное восстановление HP
                ply:SetHealth(ply:GetMaxHealth())
                
                -- Убираем ВСЕ раны
                if dbt and dbt.resetWounds then
                    dbt.resetWounds(ply)
                    ply:ChatPrint("[LOTM] Божественное исцеление: все раны исцелены!")
                end
                
                -- Эффект
                local effectData = EffectData()
                effectData:SetOrigin(ply:GetPos() + Vector(0, 0, 40))
                util.Effect("cball_explode", effectData)
            end
        end,
    })
    
    -- ЛЕЧЕНИЕ ПЕРЕЛОМОВ
    LOTM.Abilities.Create({
        id = "bone_mending",
        name = "Восстановление Костей",
        description = "Исцеляет переломы магией",
        icon = "lotm/abilities/bone_mending.png",
        requiredSequence = 7,
        cooldown = 60,
        
        healing = {
            enabled = true,
            amount = 10,
            healWounds = true,
            woundTypes = {"Перелом"},
        },
        
        visuals = {
            castSound = "physics/body/body_medium_impact_soft5.wav",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                if dbt and dbt.hasWound and dbt.removeWound and dbt.woundsposition then
                    local healed = false
                    
                    if dbt.hasWound(ply, "Перелом") then
                        for _, position in pairs(dbt.woundsposition) do
                            if dbt.hasWoundOnpos and dbt.hasWoundOnpos(ply, "Перелом", position) then
                                dbt.removeWound(ply, "Перелом", position)
                                ply:ChatPrint("[LOTM] Кости восстановлены: " .. position)
                                healed = true
                                break
                            end
                        end
                    end
                    
                    if not healed then
                        ply:ChatPrint("[LOTM] Переломы не обнаружены")
                    end
                end
            end
        end,
    })
    
    LOTM.Abilities.Create({
        id = "barrier",
        name = "Защитный Барьер",
        description = "Создаёт щит, поглощающий урон",
        icon = "lotm/abilities/barrier.png",
        requiredSequence = 7,
        cooldown = 25,
        
        selfEffects = {
            {id = "shielded", duration = 10, amount = 100},
        },
        
        animation = {
            gesture = ACT_GMOD_GESTURE_BOW,
        },
        
        visuals = {
            castSound = "weapons/physcannon/energy_sing_loop4.wav",
        },
    })
    
    LOTM.Abilities.Create({
        id = "fire_dash",
        name = "Огненный Рывок",
        description = "Мгновенный рывок вперёд",
        icon = "lotm/abilities/fire_dash.png",
        requiredSequence = 8,
        maxCharges = 2,
        chargeRegenTime = 8,
        
        selfEffects = {
            {id = "haste", duration = 2, percent = 1.3},
        },
        
        targetEffects = {
            {id = "burning", duration = 3, damage = 5},
        },
        
        visuals = {
            castSound = "ambient/fire/ignite.wav",
        },
        
        onCast = function(ply, ability)
            if SERVER then
                local vel = ply:GetAimVector() * 800
                vel.z = math.max(vel.z, 200)
                ply:SetVelocity(vel)
            end
        end,
    })
    
    -- ========== АУРЫ ==========
    
    LOTM.Abilities.Create({
        id = "activate_aura_regeneration",
        name = "Аура Регенерации",
        description = "Активирует ауру исцеления, лечащую раны союзников",
        icon = "lotm/auras/regeneration.png",
        requiredSequence = 7,
        cooldown = 60,
        
        aura = {
            enabled = true,
            auraId = "aura_regeneration",
            duration = 30,
        },
        
        onCast = function(ply, ability)
            if SERVER then
                if LOTM.Auras and LOTM.Auras.Activate then
                    LOTM.Auras.Activate(ply, "aura_regeneration", 30)
                end
                
                -- Лечим раны всем в радиусе
                for _, target in ipairs(player.GetAll()) do
                    if target:GetPos():Distance(ply:GetPos()) < 250 then
                        if dbt and dbt.hasWound and dbt.removeWound then
                            if dbt.hasWound(target, "Ранение") then
                                for _, position in pairs(dbt.woundsposition or {}) do
                                    if dbt.hasWoundOnpos and dbt.hasWoundOnpos(target, "Ранение", position) then
                                        dbt.removeWound(target, "Ранение", position)
                                        target:ChatPrint("[LOTM] Аура исцелила ваше ранение!")
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end,
    })
    
    LOTM.Abilities.Create({
        id = "activate_aura_fear",
        name = "Аура Страха",
        description = "Активирует ауру страха, ослабляющую врагов",
        icon = "lotm/auras/fear.png",
        pathway = 16,
        requiredSequence = 7,
        cooldown = 90,
        
        aura = {
            enabled = true,
            auraId = "aura_fear",
            duration = 20,
        },
        
        onCast = function(ply, ability)
            if SERVER then
                if LOTM.Auras and LOTM.Auras.Activate then
                    LOTM.Auras.Activate(ply, "aura_fear", 20)
                end
                ply:EmitSound("ambient/atmosphere/cave_hit6.wav")
            end
        end,
    })
    
    LOTM.Abilities.Create({
        id = "activate_aura_darkness",
        name = "Аура Тьмы",
        description = "Активирует мощную ауру тьмы",
        icon = "lotm/auras/darkness.png",
        pathway = 16,
        requiredSequence = 6,
        cooldown = 120,
        
        aura = {
            enabled = true,
            auraId = "aura_darkness",
            duration = 20,
        },
        
        onCast = function(ply, ability)
            if SERVER then
                if LOTM.Auras and LOTM.Auras.Activate then
                    LOTM.Auras.Activate(ply, "aura_darkness", 20)
                end
            end
        end,
    })
    
    MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), 
         "Unified abilities registered: " .. table.Count(LOTM.Abilities.Registry) .. "\n")
end)

-- =============================================
-- УПРАВЛЕНИЕ СПОСОБНОСТЯМИ ИГРОКА
-- =============================================

LOTM.Abilities.PlayerAbilities = LOTM.Abilities.PlayerAbilities or {}
LOTM.Abilities.Cooldowns = LOTM.Abilities.Cooldowns or {}
LOTM.Abilities.Charges = LOTM.Abilities.Charges or {}
LOTM.Abilities.ChargeRegen = LOTM.Abilities.ChargeRegen or {}

local function GetPlayerID(ply)
    return ply:SteamID64() or ply:UniqueID()
end

function LOTM.Abilities.GetPlayerAbilities(ply)
    local pid = GetPlayerID(ply)
    if not LOTM.Abilities.PlayerAbilities[pid] then
        LOTM.Abilities.PlayerAbilities[pid] = {}
    end
    return LOTM.Abilities.PlayerAbilities[pid]
end

function LOTM.Abilities.SetSlot(ply, slot, abilityId)
    if slot < 1 or slot > LOTM.Abilities.MAX_SLOTS then return false end
    local abilities = LOTM.Abilities.GetPlayerAbilities(ply)
    abilities[slot] = abilityId
    return true
end

function LOTM.Abilities.GetSlot(ply, slot)
    local abilities = LOTM.Abilities.GetPlayerAbilities(ply)
    local abilityId = abilities[slot]
    if abilityId then
        return LOTM.Abilities.Get(abilityId)
    end
    return nil
end

function LOTM.Abilities.ClearSlot(ply, slot)
    return LOTM.Abilities.SetSlot(ply, slot, nil)
end

-- Кулдауны
function LOTM.Abilities.GetCooldownRemaining(ply, abilityId)
    local pid = GetPlayerID(ply)
    if not LOTM.Abilities.Cooldowns[pid] then return 0 end
    local endTime = LOTM.Abilities.Cooldowns[pid][abilityId]
    if not endTime then return 0 end
    return math.max(0, endTime - CurTime())
end

function LOTM.Abilities.SetCooldown(ply, abilityId, duration)
    local pid = GetPlayerID(ply)
    if not LOTM.Abilities.Cooldowns[pid] then
        LOTM.Abilities.Cooldowns[pid] = {}
    end
    LOTM.Abilities.Cooldowns[pid][abilityId] = CurTime() + duration
end

function LOTM.Abilities.IsOnCooldown(ply, abilityId)
    return LOTM.Abilities.GetCooldownRemaining(ply, abilityId) > 0
end

-- Заряды
function LOTM.Abilities.GetCharges(ply, abilityId)
    local pid = GetPlayerID(ply)
    if not LOTM.Abilities.Charges[pid] then
        LOTM.Abilities.Charges[pid] = {}
    end
    local ability = LOTM.Abilities.Get(abilityId)
    if not ability then return 0 end
    if LOTM.Abilities.Charges[pid][abilityId] == nil then
        LOTM.Abilities.Charges[pid][abilityId] = ability.maxCharges or 1
    end
    return LOTM.Abilities.Charges[pid][abilityId]
end

function LOTM.Abilities.SetCharges(ply, abilityId, charges)
    local pid = GetPlayerID(ply)
    if not LOTM.Abilities.Charges[pid] then
        LOTM.Abilities.Charges[pid] = {}
    end
    local ability = LOTM.Abilities.Get(abilityId)
    if not ability then return end
    charges = math.Clamp(charges, 0, ability.maxCharges or 1)
    LOTM.Abilities.Charges[pid][abilityId] = charges
end

function LOTM.Abilities.UseCharge(ply, abilityId)
    local charges = LOTM.Abilities.GetCharges(ply, abilityId)
    if charges <= 0 then return false end
    LOTM.Abilities.SetCharges(ply, abilityId, charges - 1)
    LOTM.Abilities.StartChargeRegen(ply, abilityId)
    return true
end

function LOTM.Abilities.StartChargeRegen(ply, abilityId)
    local ability = LOTM.Abilities.Get(abilityId)
    if not ability then return end
    
    local pid = GetPlayerID(ply)
    local timerName = "LOTM_ChargeRegen_" .. pid .. "_" .. abilityId
    
    if timer.Exists(timerName) then return end
    
    timer.Create(timerName, ability.chargeRegenTime or 5, 1, function()
        if not IsValid(ply) then return end
        local currentCharges = LOTM.Abilities.GetCharges(ply, abilityId)
        if currentCharges < (ability.maxCharges or 1) then
            LOTM.Abilities.SetCharges(ply, abilityId, currentCharges + 1)
            
            -- Продолжаем восстановление если нужно
            if currentCharges + 1 < (ability.maxCharges or 1) then
                LOTM.Abilities.StartChargeRegen(ply, abilityId)
            end
        end
    end)
end

function LOTM.Abilities.GetChargeRegenRemaining(ply, abilityId)
    local pid = GetPlayerID(ply)
    local timerName = "LOTM_ChargeRegen_" .. pid .. "_" .. abilityId
    if timer.Exists(timerName) then
        return timer.TimeLeft(timerName) or 0
    end
    return 0
end

-- =============================================
-- АКТИВАЦИЯ СПОСОБНОСТИ (SERVER)
-- =============================================

if SERVER then
    util.AddNetworkString("LOTM.Abilities.Use")
    util.AddNetworkString("LOTM.Abilities.Notify")
    util.AddNetworkString("LOTM.Abilities.SyncCooldowns")
    
    function LOTM.Abilities.Activate(ply, slot)
        local ability = LOTM.Abilities.GetSlot(ply, slot)
        if not ability then
            LOTM.Abilities.Notify(ply, "Слот " .. slot .. " пуст!", Color(255, 100, 100))
            return false
        end
        
        -- Проверка последовательности
        local playerSeq = ply:GetNWInt("LOTM_Sequence", 9)
        if ability.requiredSequence and playerSeq > ability.requiredSequence then
            LOTM.Abilities.Notify(ply, "Требуется Seq " .. ability.requiredSequence .. " или ниже!", Color(255, 100, 100))
            return false
        end
        
        -- Проверка пути
        local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
        if ability.pathway and playerPathway ~= 0 and ability.pathway ~= playerPathway then
            LOTM.Abilities.Notify(ply, "Эта способность другого пути!", Color(255, 100, 100))
            return false
        end
        
        -- Проверка зарядов или кулдауна
        if ability.maxCharges and ability.maxCharges > 1 then
            local charges = LOTM.Abilities.GetCharges(ply, ability.id)
            if charges <= 0 then
                LOTM.Abilities.Notify(ply, "Нет зарядов! Восстановление...", Color(255, 200, 100))
                return false
            end
            LOTM.Abilities.UseCharge(ply, ability.id)
        else
            if LOTM.Abilities.IsOnCooldown(ply, ability.id) then
                local remaining = math.ceil(LOTM.Abilities.GetCooldownRemaining(ply, ability.id))
                LOTM.Abilities.Notify(ply, "Кулдаун: " .. remaining .. " сек.", Color(255, 200, 100))
                return false
            end
            if ability.cooldown and ability.cooldown > 0 then
                LOTM.Abilities.SetCooldown(ply, ability.id, ability.cooldown)
            end
        end
        
        -- Звук каста
        if ability.visuals and ability.visuals.castSound then
            ply:EmitSound(ability.visuals.castSound)
        end
        
        -- Анимация
        if ability.animation and ability.animation.gesture then
            ply:DoAnimationEvent(ability.animation.gesture)
        end
        
        -- Основная логика
        if ability.onCast then
            ability.onCast(ply, ability)
        end
        
        -- Урон по цели
        if ability.damage and ability.damage.enabled then
            LOTM.Abilities.ApplyDamage(ply, ability)
        end
        
        -- Уведомление
        LOTM.Abilities.Notify(ply, "Активировано: " .. ability.name, Color(100, 200, 255))
        
        return true
    end
    
    function LOTM.Abilities.ApplyDamage(ply, ability)
        local dmgData = ability.damage
        local range = dmgData.range or 200
        local radius = dmgData.radius or 0
        
        if radius > 0 then
            -- AoE урон
            for _, target in ipairs(ents.FindInSphere(ply:GetPos(), radius)) do
                if target:IsPlayer() and target ~= ply and target:Alive() then
                    local dmg = DamageInfo()
                    dmg:SetDamage(dmgData.amount or 10)
                    dmg:SetAttacker(ply)
                    dmg:SetInflictor(ply)
                    target:TakeDamageInfo(dmg)
                    
                    if ability.onHit then
                        ability.onHit(ply, target, ability)
                    end
                end
            end
        else
            -- Single target по трейсу
            local tr = ply:GetEyeTrace()
            if IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity ~= ply then
                if tr.HitPos:Distance(ply:GetPos()) <= range then
                    local dmg = DamageInfo()
                    dmg:SetDamage(dmgData.amount or 10)
                    dmg:SetAttacker(ply)
                    dmg:SetInflictor(ply)
                    tr.Entity:TakeDamageInfo(dmg)
                    
                    if ability.onHit then
                        ability.onHit(ply, tr.Entity, ability)
                    end
                end
            end
        end
    end
    
    function LOTM.Abilities.Notify(ply, message, color)
        net.Start("LOTM.Abilities.Notify")
        net.WriteString(message)
        net.WriteColor(color or Color(255, 255, 255))
        net.Send(ply)
    end
    
    net.Receive("LOTM.Abilities.Use", function(len, ply)
        local slot = net.ReadUInt(8)
        LOTM.Abilities.Activate(ply, slot)
    end)
end

-- =============================================
-- КЛИЕНТСКАЯ ЧАСТЬ
-- =============================================

if CLIENT then
    -- Функция запроса использования способности (для кастомных биндов)
    function LOTM.Abilities.RequestUse(slot)
        if not slot or slot < 1 or slot > LOTM.Abilities.MAX_SLOTS then return end
        
        net.Start("LOTM.Abilities.Use")
        net.WriteUInt(slot, 8)
        net.SendToServer()
    end
    
    net.Receive("LOTM.Abilities.Notify", function()
        local message = net.ReadString()
        local color = net.ReadColor()
        chat.AddText(Color(100, 255, 100), "[LOTM] ", color, message)
    end)
    
    -- Хоткеи для способностей (1-7)
    hook.Add("PlayerButtonDown", "LOTM.Abilities.Hotkeys", function(ply, button)
        if not IsFirstTimePredicted() then return end
        if ply ~= LocalPlayer() then return end
        
        -- Проверяем, не в чате ли мы
        if gui.IsConsoleVisible() then return end
        if vgui.GetKeyboardFocus() then return end
        
        local slot = nil
        
        -- Numpad keys
        if button == KEY_PAD_1 then slot = 1
        elseif button == KEY_PAD_2 then slot = 2
        elseif button == KEY_PAD_3 then slot = 3
        elseif button == KEY_PAD_4 then slot = 4
        elseif button == KEY_PAD_5 then slot = 5
        elseif button == KEY_PAD_6 then slot = 6
        elseif button == KEY_PAD_7 then slot = 7
        end
        
        if slot then
            net.Start("LOTM.Abilities.Use")
            net.WriteUInt(slot, 8)
            net.SendToServer()
        end
    end)
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Unified abilities system v2.0 loaded\n")
