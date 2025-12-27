-- LOTM Hitbox & Attack Registration System
-- Система хитбоксов и регистрации атак для способностей

LOTM = LOTM or {}
LOTM.Attacks = LOTM.Attacks or {}
LOTM.AttackRegistry = LOTM.AttackRegistry or {}
LOTM.HitboxData = LOTM.HitboxData or {}

-- Константы для хитбоксов
LOTM.HITBOX_GROUPS = {
    HEAD = 1,
    CHEST = 2,
    STOMACH = 3,
    LEFT_ARM = 4,
    RIGHT_ARM = 5,
    LEFT_LEG = 6,
    RIGHT_LEG = 7
}

-- Мультипликаторы урона по хитбоксам
LOTM.HITBOX_DAMAGE_MULTIPLIERS = {
    [LOTM.HITBOX_GROUPS.HEAD] = 2.0,
    [LOTM.HITBOX_GROUPS.CHEST] = 1.0,
    [LOTM.HITBOX_GROUPS.STOMACH] = 0.9,
    [LOTM.HITBOX_GROUPS.LEFT_ARM] = 0.7,
    [LOTM.HITBOX_GROUPS.RIGHT_ARM] = 0.7,
    [LOTM.HITBOX_GROUPS.LEFT_LEG] = 0.8,
    [LOTM.HITBOX_GROUPS.RIGHT_LEG] = 0.8
}

-- Маппинг костей к группам хитбоксов
LOTM.BONE_TO_HITBOX = {
    ["ValveBiped.Bip01_Head1"] = LOTM.HITBOX_GROUPS.HEAD,
    ["ValveBiped.Bip01_Neck1"] = LOTM.HITBOX_GROUPS.HEAD,
    
    ["ValveBiped.Bip01_Spine4"] = LOTM.HITBOX_GROUPS.CHEST,
    ["ValveBiped.Bip01_Spine2"] = LOTM.HITBOX_GROUPS.CHEST,
    
    ["ValveBiped.Bip01_Spine1"] = LOTM.HITBOX_GROUPS.STOMACH,
    ["ValveBiped.Bip01_Spine"] = LOTM.HITBOX_GROUPS.STOMACH,
    
    ["ValveBiped.Bip01_L_UpperArm"] = LOTM.HITBOX_GROUPS.LEFT_ARM,
    ["ValveBiped.Bip01_L_Forearm"] = LOTM.HITBOX_GROUPS.LEFT_ARM,
    ["ValveBiped.Bip01_L_Hand"] = LOTM.HITBOX_GROUPS.LEFT_ARM,
    
    ["ValveBiped.Bip01_R_UpperArm"] = LOTM.HITBOX_GROUPS.RIGHT_ARM,
    ["ValveBiped.Bip01_R_Forearm"] = LOTM.HITBOX_GROUPS.RIGHT_ARM,
    ["ValveBiped.Bip01_R_Hand"] = LOTM.HITBOX_GROUPS.RIGHT_ARM,
    
    ["ValveBiped.Bip01_L_Thigh"] = LOTM.HITBOX_GROUPS.LEFT_LEG,
    ["ValveBiped.Bip01_L_Calf"] = LOTM.HITBOX_GROUPS.LEFT_LEG,
    ["ValveBiped.Bip01_L_Foot"] = LOTM.HITBOX_GROUPS.LEFT_LEG,
    
    ["ValveBiped.Bip01_R_Thigh"] = LOTM.HITBOX_GROUPS.RIGHT_LEG,
    ["ValveBiped.Bip01_R_Calf"] = LOTM.HITBOX_GROUPS.RIGHT_LEG,
    ["ValveBiped.Bip01_R_Foot"] = LOTM.HITBOX_GROUPS.RIGHT_LEG
}

--[[
    Регистрация атаки
    @param attackID string - Уникальный идентификатор атаки
    @param attackData table - Данные атаки
        - name: string - Название атаки
        - damage: number - Базовый урон
        - range: number - Дальность атаки
        - cooldown: number - Время перезарядки
        - hitboxMultipliers: table - Кастомные мультипликаторы для хитбоксов (опционально)
        - onHit: function - Коллбэк при попадании (опционально)
        - onMiss: function - Коллбэк при промахе (опционально)
        - canHit: function - Проверка возможности попадания (опционально)
]]--
function LOTM.RegisterAttack(attackID, attackData)
    if not attackID or not isstring(attackID) then
        ErrorNoHalt("[LOTM Attacks] Invalid attackID provided\n")
        return false
    end
    
    if not attackData or not istable(attackData) then
        ErrorNoHalt("[LOTM Attacks] Invalid attackData provided for " .. attackID .. "\n")
        return false
    end
    
    -- Валидация обязательных полей
    if not attackData.name then attackData.name = attackID end
    if not attackData.damage then attackData.damage = 10 end
    if not attackData.range then attackData.range = 100 end
    if not attackData.cooldown then attackData.cooldown = 1 end
    
    -- Установка дефолтных мультипликаторов
    if not attackData.hitboxMultipliers then
        attackData.hitboxMultipliers = LOTM.HITBOX_DAMAGE_MULTIPLIERS
    end
    
    LOTM.AttackRegistry[attackID] = attackData
    
    if SERVER then
        MsgC(Color(100, 255, 100), "[LOTM Attacks] ", 
             Color(255, 255, 255), "Registered attack: ",
             Color(255, 200, 100), attackData.name,
             Color(255, 255, 255), " (" .. attackID .. ")\n")
    end
    
    return true
end

--[[
    Получить данные атаки
    @param attackID string
    @return table or nil
]]--
function LOTM.GetAttack(attackID)
    return LOTM.AttackRegistry[attackID]
end

--[[
    Определить хитбокс по трейсу
    @param trace table - Результат трейса
    @return number - ID группы хитбокса
]]--
function LOTM.GetHitboxFromTrace(trace)
    if not trace.Hit or not IsValid(trace.Entity) then
        return nil
    end
    
    local hitBone = trace.PhysicsBone
    local ent = trace.Entity
    
    if not ent:IsPlayer() and not ent:IsNPC() then
        return LOTM.HITBOX_GROUPS.CHEST -- Дефолт для не-гуманоидов
    end
    
    -- Получаем имя кости
    local boneName = ent:GetBoneName(hitBone)
    
    -- Ищем соответствие в маппинге
    if LOTM.BONE_TO_HITBOX[boneName] then
        return LOTM.BONE_TO_HITBOX[boneName]
    end
    
    -- Fallback: определяем по позиции
    local hitPos = trace.HitPos
    local entPos = ent:GetPos()
    local height = hitPos.z - entPos.z
    
    if height > 60 then
        return LOTM.HITBOX_GROUPS.HEAD
    elseif height > 40 then
        return LOTM.HITBOX_GROUPS.CHEST
    elseif height > 20 then
        return LOTM.HITBOX_GROUPS.STOMACH
    else
        return LOTM.HITBOX_GROUPS.LEFT_LEG
    end
end

if SERVER then
    --[[
        Выполнить атаку
        @param attacker Player - Атакующий игрок
        @param attackID string - ID зарегистрированной атаки
        @param target Entity - Цель (опционально, если nil - используется трейс)
        @return boolean - Успешность атаки
    ]]--
    function LOTM.PerformAttack(attacker, attackID, target)
        if not IsValid(attacker) or not attacker:IsPlayer() then
            return false
        end
        
        local attackData = LOTM.GetAttack(attackID)
        if not attackData then
            ErrorNoHalt("[LOTM Attacks] Unknown attack ID: " .. tostring(attackID) .. "\n")
            return false
        end
        
        -- Проверка кулдауна
        local cooldownKey = "lotm_attack_cd_" .. attackID
        local lastUse = attacker:GetNWFloat(cooldownKey, 0)
        local curTime = CurTime()
        
        if curTime < lastUse + attackData.cooldown then
            return false
        end
        
        -- Определение цели
        local hitEntity = target
        local trace
        
        if not IsValid(hitEntity) then
            trace = attacker:GetEyeTrace()
            
            if trace.Hit and IsValid(trace.Entity) and 
               trace.StartPos:Distance(trace.HitPos) <= attackData.range then
                hitEntity = trace.Entity
            end
        else
            -- Создаем "виртуальный" трейс для цели
            trace = {
                Hit = true,
                Entity = hitEntity,
                HitPos = hitEntity:GetPos() + hitEntity:OBBCenter(),
                PhysicsBone = 0
            }
        end
        
        -- Проверка на попадание
        if not IsValid(hitEntity) then
            if attackData.onMiss then
                attackData.onMiss(attacker)
            end
            return false
        end
        
        -- Дополнительная проверка через canHit
        if attackData.canHit and not attackData.canHit(attacker, hitEntity) then
            if attackData.onMiss then
                attackData.onMiss(attacker)
            end
            return false
        end
        
        -- Определение хитбокса и расчет урона
        local hitbox = LOTM.GetHitboxFromTrace(trace)
        local multiplier = attackData.hitboxMultipliers[hitbox] or 1.0
        local finalDamage = attackData.damage * multiplier
        
        -- Применение урона
        local dmgInfo = DamageInfo()
        dmgInfo:SetAttacker(attacker)
        dmgInfo:SetInflictor(attacker)
        dmgInfo:SetDamage(finalDamage)
        dmgInfo:SetDamageType(DMG_DIRECT)
        dmgInfo:SetDamagePosition(trace.HitPos)
        
        hitEntity:TakeDamageInfo(dmgInfo)
        
        -- Установка кулдауна
        attacker:SetNWFloat(cooldownKey, curTime)
        
        -- Коллбэк onHit
        if attackData.onHit then
            attackData.onHit(attacker, hitEntity, hitbox, finalDamage)
        end
        
        -- Отправка данных клиенту для визуализации
        net.Start("LOTM_AttackPerformed")
            net.WriteString(attackID)
            net.WriteEntity(hitEntity)
            net.WriteVector(trace.HitPos)
            net.WriteUInt(hitbox or 0, 4)
        net.Send(attacker)
        
        return true
    end
    
    -- Сетевые сообщения
    util.AddNetworkString("LOTM_AttackPerformed")
    util.AddNetworkString("LOTM_RequestAttack")
    
    net.Receive("LOTM_RequestAttack", function(len, ply)
        local attackID = net.ReadString()
        LOTM.PerformAttack(ply, attackID)
    end)
else
    -- Клиентская функция запроса атаки
    function LOTM.RequestAttack(attackID)
        net.Start("LOTM_RequestAttack")
            net.WriteString(attackID)
        net.SendToServer()
    end
    
    -- Получение информации о выполненной атаке
    net.Receive("LOTM_AttackPerformed", function()
        local attackID = net.ReadString()
        local target = net.ReadEntity()
        local hitPos = net.ReadVector()
        local hitbox = net.ReadUInt(4)
        
        -- Здесь можно добавить визуальные эффекты
        hook.Run("LOTM_OnAttackPerformed", attackID, target, hitPos, hitbox)
    end)
end

-- Пример регистрации базовой атаки (для демонстрации)
LOTM.RegisterAttack("basic_punch", {
    name = "Basic Punch",
    damage = 15,
    range = 80,
    cooldown = 0.5,
    onHit = function(attacker, target, hitbox, damage)
        if SERVER then
            target:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav")
        end
    end
})

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Hitbox & Attack System loaded\n")