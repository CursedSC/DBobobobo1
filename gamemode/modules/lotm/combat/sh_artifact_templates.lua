-- LOTM Artifact Templates v1.0
-- Система быстрого создания артефактов с интеграцией в инвентарь
-- Автор: Senior Developer

LOTM = LOTM or {}
LOTM.ArtifactTemplates = LOTM.ArtifactTemplates or {}
LOTM.ArtifactTemplates.Registry = {}

-- =============================================
-- РЕДКОСТИ АРТЕФАКТОВ
-- =============================================
LOTM.ArtifactTemplates.Rarities = {
    COMMON = {
        id = 1,
        name = "Обычный",
        color = Color(180, 180, 180),
        glow = Color(150, 150, 150, 50),
        multiplier = 1.0,
    },
    UNCOMMON = {
        id = 2,
        name = "Необычный",
        color = Color(100, 255, 100),
        glow = Color(50, 200, 50, 80),
        multiplier = 1.2,
    },
    RARE = {
        id = 3,
        name = "Редкий",
        color = Color(100, 150, 255),
        glow = Color(50, 100, 255, 100),
        multiplier = 1.5,
    },
    EPIC = {
        id = 4,
        name = "Эпический",
        color = Color(200, 100, 255),
        glow = Color(150, 50, 255, 120),
        multiplier = 2.0,
    },
    LEGENDARY = {
        id = 5,
        name = "Легендарный",
        color = Color(255, 200, 50),
        glow = Color(255, 180, 0, 150),
        multiplier = 3.0,
    },
    DIVINE = {
        id = 6,
        name = "Божественный",
        color = Color(255, 255, 200),
        glow = Color(255, 255, 150, 180),
        multiplier = 5.0,
    },
    CURSED = {
        id = 7,
        name = "Проклятый",
        color = Color(150, 50, 50),
        glow = Color(180, 0, 0, 150),
        multiplier = 2.5,
        cursed = true,
    },
}

-- Получить редкость по ID
function LOTM.ArtifactTemplates.GetRarity(rarityId)
    for _, rarity in pairs(LOTM.ArtifactTemplates.Rarities) do
        if rarity.id == rarityId then
            return rarity
        end
    end
    return LOTM.ArtifactTemplates.Rarities.COMMON
end

-- =============================================
-- ТИПЫ АРТЕФАКТОВ
-- =============================================
LOTM.ArtifactTemplates.Types = {
    WEAPON = "weapon",      -- Оружие
    ACCESSORY = "accessory",-- Аксессуар
    ARMOR = "armor",        -- Броня
    CONSUMABLE = "consumable", -- Расходуемый
    TOOL = "tool",          -- Инструмент
}

-- =============================================
-- ШАБЛОН АРТЕФАКТА
-- =============================================
--[[
LOTM.ArtifactTemplates.Create({
    -- Основные параметры
    id = "artifact_id",           -- Уникальный ID (строка)
    inventoryId = 500,            -- ID в инвентаре (число)
    name = "Название",
    description = "Описание",
    model = "models/...",
    rarity = LOTM.ArtifactTemplates.Rarities.RARE,
    type = LOTM.ArtifactTemplates.Types.WEAPON,
    
    -- Параметры для оружия
    weapon = {
        class = "lotm_artifact_blade",  -- Класс SWEP
        damage = 25,
        attackSpeed = 0.8,
        range = 100,
    },
    
    -- Боевой стиль (опционально)
    combatStyle = {
        abilities = { ... }
    },
    
    -- Пассивные бонусы
    passives = {
        damage_bonus = 0.15,
        speed_bonus = 0.1,
        health_bonus = 25,
        armor_bonus = 10,
    },
    
    -- Активная способность
    ability = {
        name = "Название",
        cooldown = 30,
        onUse = function(ply) end,
    },
    
    -- Колбэки
    onEquip = function(ply) end,
    onUnequip = function(ply) end,
})
]]

function LOTM.ArtifactTemplates.Create(data)
    if not data.id then
        ErrorNoHalt("[LOTM Artifacts] Ошибка: отсутствует id артефакта\n")
        return nil
    end
    
    -- Генерируем inventory ID если не указан
    if not data.inventoryId then
        data.inventoryId = 1000 + table.Count(LOTM.ArtifactTemplates.Registry)
    end
    
    -- Заполняем дефолтные значения
    local artifact = {
        id = data.id,
        inventoryId = data.inventoryId,
        name = data.name or "Артефакт",
        description = data.description or "Мистический артефакт",
        model = data.model or "models/props_lab/huladoll.mdl",
        rarity = data.rarity or LOTM.ArtifactTemplates.Rarities.COMMON,
        type = data.type or LOTM.ArtifactTemplates.Types.ACCESSORY,
        
        weapon = data.weapon,
        combatStyle = data.combatStyle,
        passives = data.passives or {},
        ability = data.ability,
        
        onEquip = data.onEquip,
        onUnequip = data.onUnequip,
        onUse = data.onUse,
    }
    
    -- Регистрируем в нашем реестре
    LOTM.ArtifactTemplates.Registry[data.id] = artifact
    
    -- Регистрируем боевой стиль если есть
    if data.combatStyle and LOTM.Combat and LOTM.Combat.RegisterStyle then
        local styleData = table.Copy(data.combatStyle)
        styleData.id = "artifact_" .. data.id
        styleData.name = styleData.name or artifact.name
        LOTM.Combat.RegisterStyle(styleData)
        artifact.combatStyleId = styleData.id
    end
    
    -- Регистрируем в dbt.inventory если доступен
    if dbt and dbt.inventory and dbt.inventory.items then
        local rarityData = artifact.rarity
        
        dbt.inventory.items[artifact.inventoryId] = {
            name = artifact.name,
            artifact = true,
            lotmArtifact = true,
            artifactId = artifact.id,
            mdl = artifact.model,
            kg = data.kg or 0.5,
            rarity = rarityData.id,
            rarityName = rarityData.name,
            rarityColor = rarityData.color,
            notEditable = true,
            
            GetDescription = function(self)
                local text = {}
                text[#text+1] = color_white
                text[#text+1] = artifact.description
                text[#text+1] = true
                text[#text+1] = rarityData.color
                text[#text+1] = "Редкость: " .. rarityData.name
                
                if artifact.passives then
                    text[#text+1] = true
                    text[#text+1] = Color(200, 200, 100)
                    text[#text+1] = "--- Бонусы ---"
                    
                    if artifact.passives.damage_bonus then
                        text[#text+1] = true
                        text[#text+1] = Color(255, 100, 100)
                        text[#text+1] = string.format("Урон: +%d%%", artifact.passives.damage_bonus * 100)
                    end
                    if artifact.passives.speed_bonus then
                        text[#text+1] = true
                        text[#text+1] = Color(100, 255, 100)
                        text[#text+1] = string.format("Скорость: +%d%%", artifact.passives.speed_bonus * 100)
                    end
                    if artifact.passives.health_bonus then
                        text[#text+1] = true
                        text[#text+1] = Color(100, 255, 100)
                        text[#text+1] = string.format("Здоровье: +%d", artifact.passives.health_bonus)
                    end
                    if artifact.passives.armor_bonus then
                        text[#text+1] = true
                        text[#text+1] = Color(100, 150, 255)
                        text[#text+1] = string.format("Броня: +%d", artifact.passives.armor_bonus)
                    end
                end
                
                if artifact.ability then
                    text[#text+1] = true
                    text[#text+1] = Color(255, 200, 100)
                    text[#text+1] = "Способность: " .. (artifact.ability.name or "Активация")
                    text[#text+1] = true
                    text[#text+1] = Color(150, 150, 150)
                    text[#text+1] = "Кулдаун: " .. (artifact.ability.cooldown or 30) .. "с"
                end
                
                return text
            end,
            
            descalt = {rarityData.color, "Артефакт | ", Color(175, 175, 175), "ПКМ - Экипировать / H - Использовать способность"},
            
            -- Использование через инвентарь - экипировка
            OnUse = function(ply, data, meta, c_data)
                if SERVER then
                    -- Выдаём SWEP если это оружие
                    if artifact.weapon and artifact.weapon.class then
                        ply:Give(artifact.weapon.class)
                        ply:ChatPrint("[LOTM] Артефакт \"" .. artifact.name .. "\" экипирован!")
                    elseif artifact.onEquip then
                        artifact.onEquip(ply, artifact)
                    end
                end
                return meta
            end,
        }
    end
    
    -- Регистрируем в LOTM.Artifacts если доступен
    if LOTM.Artifacts and LOTM.Artifacts.Register then
        LOTM.Artifacts.Register({
            id = artifact.id,
            name = artifact.name,
            description = artifact.description,
            type = "grade_" .. (7 - math.min(artifact.rarity.id, 7)),
            model = artifact.model,
            
            buffs = artifact.passives,
            abilityCooldown = artifact.ability and artifact.ability.cooldown or 60,
            
            onEquip = artifact.onEquip,
            onUnequip = artifact.onUnequip,
            onUse = artifact.onUse or (artifact.ability and artifact.ability.onUse),
        })
    end
    
    MsgC(Color(255, 215, 100), "[LOTM Artifacts] ", Color(255, 255, 255), 
         "Создан: " .. artifact.name .. " [" .. artifact.rarity.name .. "]\n")
    
    return artifact
end

-- Получить артефакт по ID
function LOTM.ArtifactTemplates.Get(artifactId)
    return LOTM.ArtifactTemplates.Registry[artifactId]
end

-- Получить артефакт по inventory ID
function LOTM.ArtifactTemplates.GetByInventoryId(invId)
    for _, artifact in pairs(LOTM.ArtifactTemplates.Registry) do
        if artifact.inventoryId == invId then
            return artifact
        end
    end
    return nil
end

-- =============================================
-- ПРИМЕРЫ АРТЕФАКТОВ
-- =============================================
hook.Add("InitPostEntity", "LOTM.ArtifactTemplates.RegisterExamples", function()
    timer.Simple(1, function()
        
        -- Клинок Тьмы
        LOTM.ArtifactTemplates.Create({
            id = "shadow_blade",
            inventoryId = 1001,
            name = "Клинок Тьмы",
            description = "Древний клинок, пропитанный тьмой. Наносит дополнительный урон и высасывает жизнь.",
            model = "models/weapons/w_knife_t.mdl",
            rarity = LOTM.ArtifactTemplates.Rarities.EPIC,
            type = LOTM.ArtifactTemplates.Types.WEAPON,
            
            weapon = {
                class = "weapon_crowbar",
                damage = 35,
                attackSpeed = 0.6,
            },
            
            passives = {
                damage_bonus = 0.2,
                lifesteal = 0.1,
            },
            
            combatStyle = {
                name = "Стиль Тьмы",
                abilities = {
                    primary = {
                        name = "[E] Теневой удар",
                        damage = 25,
                        cooldown = 0.6,
                        range = 90,
                        sound = "weapons/knife/knife_slash1.wav",
                        enabled = true,
                    },
                    primary_shift = {
                        name = "[E+Shift] Пронзание тьмой",
                        damage = 45,
                        cooldown = 2.0,
                        range = 120,
                        sound = "weapons/knife/knife_stab.wav",
                        enabled = true,
                        onUse = function(ply, target)
                            if SERVER and IsValid(target) and target:IsPlayer() then
                                -- Лайфстил
                                local heal = 10
                                ply:SetHealth(math.min(ply:Health() + heal, ply:GetMaxHealth()))
                            end
                        end,
                    },
                    secondary = {
                        name = "[R] Теневой шаг",
                        damage = 0,
                        cooldown = 5.0,
                        enabled = true,
                        onUse = function(ply)
                            if SERVER then
                                local tr = ply:GetEyeTrace()
                                local dist = math.min(tr.HitPos:Distance(ply:GetPos()), 300)
                                local dir = (tr.HitPos - ply:GetPos()):GetNormalized()
                                ply:SetPos(ply:GetPos() + dir * dist * 0.8)
                                ply:EmitSound("physics/body/body_medium_impact_soft3.wav")
                            end
                        end,
                    },
                    ultimate = {
                        name = "[F] Взрыв тьмы",
                        damage = 60,
                        cooldown = 15.0,
                        aoe = 200,
                        sound = "ambient/atmosphere/cave_hit5.wav",
                        enabled = true,
                    },
                },
            },
            
            ability = {
                name = "Слияние с тенью",
                cooldown = 45,
                onUse = function(ply)
                    if SERVER then
                        ply:SetNWBool("LOTM_ShadowMerge", true)
                        ply:ChatPrint("[Клинок Тьмы] Вы слились с тенями...")
                        timer.Simple(10, function()
                            if IsValid(ply) then
                                ply:SetNWBool("LOTM_ShadowMerge", false)
                            end
                        end)
                    end
                end,
            },
        })
        
        -- Перстень Пламени
        LOTM.ArtifactTemplates.Create({
            id = "fire_ring",
            inventoryId = 1002,
            name = "Перстень Пламени",
            description = "Кольцо, заключающее в себе силу первозданного огня.",
            model = "models/props_lab/huladoll.mdl",
            rarity = LOTM.ArtifactTemplates.Rarities.RARE,
            type = LOTM.ArtifactTemplates.Types.ACCESSORY,
            
            passives = {
                damage_bonus = 0.1,
                fire_resistance = 0.5,
            },
            
            ability = {
                name = "Огненный шторм",
                cooldown = 60,
                onUse = function(ply)
                    if SERVER then
                        for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
                            if target:IsPlayer() and target ~= ply then
                                target:Ignite(5)
                            end
                        end
                        ply:EmitSound("ambient/fire/ignite.wav")
                        ply:ChatPrint("[Перстень Пламени] Огненный шторм обрушился на врагов!")
                    end
                end,
            },
            
            onEquip = function(ply)
                if SERVER then
                    ply:ChatPrint("[Перстень Пламени] Пламя согревает вашу руку...")
                end
            end,
        })
        
        -- Амулет Исцеления
        LOTM.ArtifactTemplates.Create({
            id = "healing_amulet",
            inventoryId = 1003,
            name = "Амулет Исцеления",
            description = "Священный амулет, медленно восстанавливающий здоровье владельца.",
            model = "models/props_junk/garbage_metalcan001a.mdl",
            rarity = LOTM.ArtifactTemplates.Rarities.UNCOMMON,
            type = LOTM.ArtifactTemplates.Types.ACCESSORY,
            
            passives = {
                health_bonus = 25,
                health_regen = 2,
            },
            
            ability = {
                name = "Мгновенное исцеление",
                cooldown = 90,
                onUse = function(ply)
                    if SERVER then
                        ply:SetHealth(math.min(ply:Health() + 50, ply:GetMaxHealth()))
                        ply:EmitSound("items/medshot4.wav")
                        ply:ChatPrint("[Амулет Исцеления] +50 HP восстановлено!")
                    end
                end,
            },
        })
        
        -- Божественный Меч (Легендарный)
        LOTM.ArtifactTemplates.Create({
            id = "divine_sword",
            inventoryId = 1004,
            name = "Меч Серафима",
            description = "Легендарный клинок, выкованный в небесной кузнице. Несёт божественный свет.",
            model = "models/weapons/w_knife_t.mdl",
            rarity = LOTM.ArtifactTemplates.Rarities.LEGENDARY,
            type = LOTM.ArtifactTemplates.Types.WEAPON,
            kg = 1.5,
            
            passives = {
                damage_bonus = 0.35,
                armor_bonus = 20,
                holy_damage = 25,
            },
            
            combatStyle = {
                name = "Божественный стиль",
                abilities = {
                    primary = {
                        name = "[E] Святой удар",
                        damage = 35,
                        cooldown = 0.7,
                        range = 100,
                        sound = "weapons/knife/knife_slash1.wav",
                        enabled = true,
                    },
                    primary_shift = {
                        name = "[E+Shift] Небесное правосудие",
                        damage = 70,
                        cooldown = 3.0,
                        range = 150,
                        sound = "ambient/energy/whiteflash.wav",
                        enabled = true,
                    },
                    secondary = {
                        name = "[R] Божественный щит",
                        damage = 0,
                        cooldown = 10.0,
                        enabled = true,
                        onUse = function(ply)
                            if SERVER then
                                ply:SetArmor(math.min(ply:Armor() + 50, 100))
                                ply:ChatPrint("[Меч Серафима] Божественный щит активирован!")
                            end
                        end,
                    },
                    ultimate = {
                        name = "[F] Гнев Небес",
                        damage = 100,
                        cooldown = 25.0,
                        aoe = 300,
                        sound = "ambient/explosions/explode_4.wav",
                        enabled = true,
                    },
                },
            },
            
            ability = {
                name = "Воскрешение",
                cooldown = 300,
                onUse = function(ply)
                    if SERVER then
                        ply:SetHealth(ply:GetMaxHealth())
                        ply:SetArmor(100)
                        ply:EmitSound("ambient/energy/whiteflash.wav")
                        ply:ChatPrint("[Меч Серафима] Божественная сила восстановила вас полностью!")
                    end
                end,
            },
        })
        
        MsgC(Color(255, 215, 100), "[LOTM Artifacts] ", Color(255, 255, 255), 
             "Зарегистрировано артефактов: " .. table.Count(LOTM.ArtifactTemplates.Registry) .. "\n")
    end)
end)

MsgC(Color(255, 215, 100), "[LOTM] ", Color(255, 255, 255), "Artifact Templates v1.0 loaded\n")

