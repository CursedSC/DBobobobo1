-- LOTM Artifacts Commands
-- Серверные команды для артефактов и SWEP

if not SERVER then return end

LOTM = LOTM or {}
LOTM.ArtifactWeapons = LOTM.ArtifactWeapons or {}

-- Конфигурации оружий для артефактов
LOTM.ArtifactWeapons.Configs = {
    -- Кольцо Крови - ближний бой
    ring_of_blood = {
        name = "Кольцо Крови",
        model = "models/weapons/c_arms.mdl",
        worldModel = "models/props_junk/meathook001a.mdl",
        holdType = "melee2",
        
        damage = 30,
        range = 70,
        attackSpeed = 0.45,
        
        enableCombos = true,
        enableBlock = true,
        
        attacks = {
            {
                name = "Кровавый разрез",
                damage = 30,
                sound = "weapons/knife/knife_slash1.wav",
                hitSound = "physics/flesh/flesh_bloody_break.wav",
                range = 70,
                delay = 0.4,
                knockback = 80,
                bleed = true,
            },
            {
                name = "Жатва крови",
                damage = 40,
                sound = "weapons/knife/knife_slash2.wav",
                hitSound = "physics/flesh/flesh_impact_hard2.wav",
                range = 65,
                delay = 0.5,
                knockback = 120,
                lifesteal = 15,
            },
            {
                name = "Кровавый взрыв",
                damage = 55,
                sound = "weapons/knife/knife_stab.wav",
                hitSound = "physics/flesh/flesh_squishy_impact_hard1.wav",
                range = 90,
                delay = 0.7,
                knockback = 200,
                bleed = true,
                lifesteal = 25,
            },
        },
        
        block = {
            enabled = true,
            damageReduction = 0.5,
            perfectBlockWindow = 0.15,
            perfectBlockBonus = 0.9,
        },
        
        combo = {
            maxChain = 5,
            resetTime = 1.2,
            damageBonus = 0.15,
            finisherAt = 5,
            finisherDamageMultiplier = 2.5,
        },
        
        visuals = {
            swingTrail = true,
            trailColor = Color(200, 0, 0),
        },
    },
    
    -- Кольцо Теней - быстрые атаки
    ring_of_shadows = {
        name = "Кольцо Теней",
        model = "models/weapons/c_arms.mdl",
        worldModel = "models/props_combine/breenlight.mdl",
        holdType = "knife",
        
        damage = 20,
        range = 60,
        attackSpeed = 0.3,
        
        enableCombos = true,
        enableBlock = false,
        enableDodge = true,
        
        attacks = {
            {
                name = "Теневой укол",
                damage = 18,
                sound = "weapons/knife/knife_slash1.wav",
                range = 55,
                delay = 0.25,
                knockback = 40,
            },
            {
                name = "Двойной удар",
                damage = 25,
                sound = "weapons/knife/knife_slash2.wav",
                range = 60,
                delay = 0.3,
                knockback = 60,
            },
            {
                name = "Теневое касание",
                damage = 35,
                sound = "weapons/knife/knife_stab.wav",
                range = 70,
                delay = 0.35,
                knockback = 100,
                invisible = 2, -- Невидимость на 2 секунды
            },
        },
        
        combo = {
            maxChain = 7,
            resetTime = 1.0,
            damageBonus = 0.08,
            finisherAt = 7,
            finisherDamageMultiplier = 2.0,
        },
    },
    
    -- Мистический клинок
    mystic_blade = {
        name = "Мистический Клинок",
        model = "models/weapons/c_arms.mdl",
        worldModel = "models/weapons/w_knife_t.mdl",
        holdType = "melee2",
        
        damage = 35,
        range = 85,
        attackSpeed = 0.5,
        
        enableCombos = true,
        enableBlock = true,
        enableChargeAttack = true,
        
        attacks = {
            {
                name = "Быстрый взмах",
                damage = 30,
                sound = "weapons/knife/knife_slash1.wav",
                range = 80,
                delay = 0.4,
                knockback = 100,
            },
            {
                name = "Мощный удар",
                damage = 45,
                sound = "weapons/knife/knife_slash2.wav",
                range = 85,
                delay = 0.55,
                knockback = 150,
                stunDuration = 0.3,
            },
            {
                name = "Мистический разряд",
                damage = 60,
                sound = "ambient/energy/zap5.wav",
                hitSound = "ambient/energy/spark1.wav",
                range = 100,
                delay = 0.7,
                knockback = 250,
                magicDamage = true,
            },
        },
        
        block = {
            enabled = true,
            damageReduction = 0.6,
            perfectBlockWindow = 0.2,
            perfectBlockBonus = 1.0,
            sound = "physics/metal/metal_solid_impact_hard2.wav",
        },
        
        combo = {
            maxChain = 6,
            resetTime = 1.5,
            damageBonus = 0.12,
            finisherAt = 6,
            finisherDamageMultiplier = 2.2,
        },
        
        visuals = {
            swingTrail = true,
            trailColor = Color(211, 25, 202),
        },
    },
}

-- Команда спавна артефакта
concommand.Add("lotm_spawn_artifact", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] Только для администраторов")
        return
    end
    
    local artifactId = args[1]
    if not artifactId then
        ply:ChatPrint("[LOTM] Использование: lotm_spawn_artifact <artifact_id>")
        return
    end
    
    -- Получаем данные артефакта
    if not LOTM.Artifacts or not LOTM.Artifacts.Registry or not LOTM.Artifacts.Registry[artifactId] then
        ply:ChatPrint("[LOTM] Артефакт не найден: " .. artifactId)
        return
    end
    
    local artifactData = LOTM.Artifacts.Registry[artifactId]
    
    -- Создаём entity
    local tr = ply:GetEyeTrace()
    local spawnPos = tr.HitPos + Vector(0, 0, 10)
    
    local ent = ents.Create("prop_physics")
    if not IsValid(ent) then
        ply:ChatPrint("[LOTM] Ошибка создания entity")
        return
    end
    
    ent:SetModel(artifactData.model or "models/props_lab/huladoll.mdl")
    ent:SetPos(spawnPos)
    ent:Spawn()
    ent:SetNWString("LOTM_ArtifactId", artifactId)
    ent:SetNWString("LOTM_ArtifactName", artifactData.name)
    
    ply:ChatPrint("[LOTM] Артефакт заспавнен: " .. artifactData.name)
end)

-- Команда выдачи оружия-артефакта
concommand.Add("lotm_give_artifact_weapon", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then
        ply:ChatPrint("[LOTM] Только для администраторов")
        return
    end
    
    local artifactId = args[1] or "mystic_blade"
    
    -- Получаем конфиг
    local config = LOTM.ArtifactWeapons.Configs[artifactId]
    if not config then
        -- Создаём дефолтный конфиг
        config = {
            name = "Артефакт",
            damage = 25,
            range = 80,
            enableCombos = true,
            enableBlock = true,
            attacks = {
                {name = "Удар 1", damage = 25, delay = 0.4, range = 80},
                {name = "Удар 2", damage = 30, delay = 0.5, range = 75},
                {name = "Удар 3", damage = 40, delay = 0.6, range = 90},
            },
            block = {enabled = true, damageReduction = 0.6},
            combo = {maxChain = 5, resetTime = 1.5, damageBonus = 0.1},
        }
    end
    
    -- Выдаём оружие
    local weapon = ply:Give("lotm_artifact_weapon")
    if IsValid(weapon) then
        -- Применяем конфиг
        weapon.ArtifactConfig = config
        weapon.PrintName = config.name
        
        if config.worldModel then
            weapon.WorldModel = config.worldModel
        end
        if config.holdType then
            weapon:SetHoldType(config.holdType)
        end
        
        ply:ChatPrint("[LOTM] Выдано оружие: " .. config.name)
        ply:ChatPrint("[LOTM] ЛКМ - атака (" .. #config.attacks .. " комбо)")
        if config.enableBlock then
            ply:ChatPrint("[LOTM] ПКМ - блок")
        end
    else
        ply:ChatPrint("[LOTM] Ошибка выдачи оружия")
    end
end)

-- Список доступных конфигов
concommand.Add("lotm_artifact_weapons_list", function(ply)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("═══════════════════════════════════")
    ply:ChatPrint("[LOTM] Доступные артефакты-оружия:")
    
    for id, config in pairs(LOTM.ArtifactWeapons.Configs) do
        ply:ChatPrint("• " .. id .. " - " .. config.name)
    end
    
    ply:ChatPrint("═══════════════════════════════════")
    ply:ChatPrint("Использование: lotm_give_artifact_weapon <id>")
end)

print("[LOTM] Artifacts Commands loaded")




