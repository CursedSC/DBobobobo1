-- LOTM Skill System - Server
-- Серверная логика: урон, резисты, AoE

util.AddNetworkString("LOTM_SkillHit")
util.AddNetworkString("LOTM_SkillCast")

-- Инициализация резистов для игрока
local function InitPlayerResistances(ply)
    ply.LOTM_Resistances = {}
    for dmgType, _ in pairs(LOTM_DAMAGE_TYPES) do
        ply.LOTM_Resistances[dmgType] = 0
    end
end

hook.Add("PlayerSpawn", "LOTM_InitResistances", function(ply)
    InitPlayerResistances(ply)
end)

-- Установить резист
function LOTM_SetResistance(ply, damageType, value)
    if not IsValid(ply) then return end
    if not ply.LOTM_Resistances then InitPlayerResistances(ply) end
    
    ply.LOTM_Resistances[damageType] = math.Clamp(value, -100, 100)
end

-- Получить резист
function LOTM_GetResistance(ply, damageType)
    if not IsValid(ply) then return 0 end
    if not ply.LOTM_Resistances then InitPlayerResistances(ply) end
    
    return ply.LOTM_Resistances[damageType] or 0
end

-- Добавить резист
function LOTM_AddResistance(ply, damageType, value)
    local current = LOTM_GetResistance(ply, damageType)
    LOTM_SetResistance(ply, damageType, current + value)
end

-- Расчёт финального урона с учётом резиста
local function CalculateDamage(baseDamage, damageType, target)
    local resistance = LOTM_GetResistance(target, damageType)
    local multiplier = 1 - (resistance / 100)
    
    return math.max(0, baseDamage * multiplier)
end

-- Проверка попадания в сферу
local function IsInSphere(pos, center, radius)
    return pos:Distance(center) <= radius
end

-- Проверка попадания в куб
local function IsInBox(pos, center, width, height, depth, angles)
    local localPos = WorldToLocal(pos, Angle(), center, angles or Angle())
    
    return math.abs(localPos.x) <= width / 2 and
           math.abs(localPos.y) <= depth / 2 and
           math.abs(localPos.z) <= height / 2
end

-- Проверка попадания в цилиндр
local function IsInCylinder(pos, center, radius, height)
    local horizontalDist = Vector(pos.x - center.x, pos.y - center.y, 0):Length()
    local verticalDist = math.abs(pos.z - center.z)
    
    return horizontalDist <= radius and verticalDist <= height / 2
end

-- Проверка попадания в конус
local function IsInCone(pos, origin, direction, angle, range)
    local toTarget = (pos - origin):GetNormalized()
    local dotProduct = direction:Dot(toTarget)
    local angleToTarget = math.deg(math.acos(dotProduct))
    local distance = pos:Distance(origin)
    
    return angleToTarget <= angle / 2 and distance <= range
end

-- Проверка попадания в круг
local function IsInCircle(pos, center, radius, circlePos)
    local checkHeight = center.z
    
    if circlePos == LOTM_CIRCLE_POS.TOP then
        checkHeight = center.z + 50
    elseif circlePos == LOTM_CIRCLE_POS.BOTTOM then
        checkHeight = center.z - 50
    end
    
    local horizontalDist = Vector(pos.x - center.x, pos.y - center.y, 0):Length()
    local verticalDist = math.abs(pos.z - checkHeight)
    
    return horizontalDist <= radius and verticalDist <= 10
end

-- Проверка попадания луча
local function IsInRay(pos, origin, direction, maxDist)
    local trace = util.TraceLine({
        start = origin,
        endpos = origin + direction * maxDist,
        filter = function(ent) return ent:IsPlayer() or ent:IsNPC() end
    })
    
    if trace.Entity == pos.Entity then
        return true
    end
    
    return false
end

-- Получить цели в области действия
function LOTM_GetTargetsInAOE(skillData, origin, angles, caster)
    local targets = {}
    local checkEnts = {}
    
    -- Собираем всех игроков и NPC
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= caster and ply:Alive() then
            table.insert(checkEnts, ply)
        end
    end
    
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        table.insert(checkEnts, npc)
    end
    
    -- Проверяем каждую цель
    for _, ent in ipairs(checkEnts) do
        local pos = ent:GetPos() + Vector(0, 0, 40) -- Центр массы
        local inAOE = false
        
        if skillData.aoeShape == LOTM_AOE_SHAPES.SPHERE then
            inAOE = IsInSphere(pos, origin, skillData.aoeRadius)
            
        elseif skillData.aoeShape == LOTM_AOE_SHAPES.BOX then
            inAOE = IsInBox(pos, origin, skillData.aoeWidth, skillData.aoeHeight, skillData.aoeDepth, angles)
            
        elseif skillData.aoeShape == LOTM_AOE_SHAPES.CYLINDER then
            inAOE = IsInCylinder(pos, origin, skillData.aoeRadius, skillData.aoeHeight)
            
        elseif skillData.aoeShape == LOTM_AOE_SHAPES.CONE then
            local direction = angles:Forward()
            inAOE = IsInCone(pos, origin, direction, skillData.aoeAngle, skillData.aoeRadius)
            
        elseif skillData.aoeShape == LOTM_AOE_SHAPES.CIRCLE then
            inAOE = IsInCircle(pos, origin, skillData.aoeRadius, skillData.circlePosition)
            
        elseif skillData.aoeShape == LOTM_AOE_SHAPES.RAY then
            pos.Entity = ent
            inAOE = IsInRay(pos, origin, angles:Forward(), skillData.aoeRadius)
        end
        
        if inAOE then
            table.insert(targets, ent)
        end
    end
    
    return targets
end

-- Применить скилл
function LOTM_CastSkill(caster, skillID, targetPos, targetAngles)
    if not IsValid(caster) then return end
    
    local skillData = LOTM_GetSkill(skillID)
    if not skillData then
        print("[LOTM Skills] Скилл " .. skillID .. " не найден")
        return
    end
    
    -- Получаем цели
    local targets = LOTM_GetTargetsInAOE(skillData, targetPos, targetAngles, caster)
    
    -- Отправляем информацию о касте клиентам
    net.Start("LOTM_SkillCast")
        net.WriteString(skillID)
        net.WriteVector(targetPos)
        net.WriteAngle(targetAngles)
        net.WriteEntity(caster)
    net.Broadcast()
    
    -- Наносим урон всем целям
    for _, target in ipairs(targets) do
        if IsValid(target) then
            local finalDamage = CalculateDamage(skillData.baseDamage, skillData.damageType, target)
            
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(finalDamage)
            dmgInfo:SetAttacker(caster)
            dmgInfo:SetInflictor(caster)
            dmgInfo:SetDamageType(DMG_GENERIC)
            
            target:TakeDamageInfo(dmgInfo)
            
            -- Отправляем информацию о попадании
            net.Start("LOTM_SkillHit")
                net.WriteEntity(target)
                net.WriteFloat(finalDamage)
                net.WriteUInt(skillData.damageType, 8)
                net.WriteString(skillData.hitParticle)
            net.Broadcast()
        end
    end
    
    return #targets
end

-- Консольные команды для тестирования
concommand.Add("lotm_set_resistance", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    
    local damageType = tonumber(args[1]) or LOTM_DAMAGE_TYPES.PHYSICAL
    local value = tonumber(args[2]) or 0
    
    LOTM_SetResistance(ply, damageType, value)
    ply:ChatPrint("Резист к " .. LOTM_DAMAGE_NAMES[damageType] .. " установлен на " .. value .. "%")
end)

concommand.Add("lotm_show_resistances", function(ply, cmd, args)
    if not ply.LOTM_Resistances then InitPlayerResistances(ply) end
    
    ply:ChatPrint("=== Ваши резисты ===")
    for dmgType, resist in pairs(ply.LOTM_Resistances) do
        if resist ~= 0 then
            ply:ChatPrint(LOTM_DAMAGE_NAMES[dmgType] .. ": " .. resist .. "%")
        end
    end
end)

print("[LOTM Skills] Серверная часть загружена")