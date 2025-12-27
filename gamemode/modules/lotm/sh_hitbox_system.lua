-- LOTM Hitbox System
-- Система хитбоксов для боевой механики
-- Поддерживает: SPHERE, BOX, CYLINDER, CONE, RAY, CIRCLE

LOTM = LOTM or {}
LOTM.Hitbox = LOTM.Hitbox or {}

-- Типы хитбоксов
LOTM.Hitbox.Types = {
    SPHERE = 1,     -- Сферический
    BOX = 2,        -- Прямоугольный (для стен/барьеров)
    CYLINDER = 3,   -- Цилиндрический
    CONE = 4,       -- Конусообразный
    RAY = 5,        -- Луч
    CIRCLE = 6,     -- Круг (2D на плоскости)
}

-- Позиции для CIRCLE
LOTM.Hitbox.CirclePosition = {
    CENTER = 1,     -- По центру игрока
    TOP = 2,        -- Сверху (над головой)
    BOTTOM = 3,     -- Снизу (под ногами)
}

-- Хранилище активных хитбоксов
LOTM.Hitbox.ActiveHitboxes = LOTM.Hitbox.ActiveHitboxes or {}
local hitboxCounter = 0

-- Создание хитбокса
-- hitboxType: тип хитбокса (SPHERE, BOX, etc.)
-- params: таблица параметров
-- Возвращает hitboxId
function LOTM.Hitbox.Create(hitboxType, params)
    hitboxCounter = hitboxCounter + 1
    local hitboxId = hitboxCounter
    
    local hitbox = {
        id = hitboxId,
        type = hitboxType,
        owner = params.owner,               -- Владелец хитбокса (Entity)
        origin = params.origin or Vector(0, 0, 0),  -- Начальная позиция
        direction = params.direction or Vector(1, 0, 0), -- Направление
        duration = params.duration or 0,    -- Длительность (0 = мгновенный)
        startTime = CurTime(),
        damage = params.damage or 0,
        damageType = params.damageType or "physical",
        onHit = params.onHit,               -- Callback при попадании
        filter = params.filter or {},       -- Фильтр сущностей
        hitEntities = {},                   -- Уже задетые сущности
        active = true,
        particle = params.particle,         -- Партикл эффект
        color = params.color or Color(255, 0, 0, 100),
        
        -- Параметры специфичные для типа
        radius = params.radius or 100,      -- Для SPHERE, CYLINDER, CIRCLE
        size = params.size or Vector(100, 100, 100), -- Для BOX
        height = params.height or 200,      -- Для CYLINDER
        angle = params.angle or 45,         -- Для CONE (угол конуса в градусах)
        length = params.length or 500,      -- Для CONE и RAY
        circlePos = params.circlePos or LOTM.Hitbox.CirclePosition.CENTER, -- Для CIRCLE
        
        -- Визуализация
        showDebug = params.showDebug or false,
    }
    
    LOTM.Hitbox.ActiveHitboxes[hitboxId] = hitbox
    
    return hitboxId
end

-- Проверка попадания для SPHERE
function LOTM.Hitbox.CheckSphere(hitbox, entity)
    local entPos = entity:GetPos()
    local distance = entPos:Distance(hitbox.origin)
    return distance <= hitbox.radius
end

-- Проверка попадания для BOX
function LOTM.Hitbox.CheckBox(hitbox, entity)
    local entPos = entity:GetPos()
    local origin = hitbox.origin
    local size = hitbox.size
    
    -- Простая AABB проверка
    local mins = origin - size / 2
    local maxs = origin + size / 2
    
    return entPos.x >= mins.x and entPos.x <= maxs.x and
           entPos.y >= mins.y and entPos.y <= maxs.y and
           entPos.z >= mins.z and entPos.z <= maxs.z
end

-- Проверка попадания для CYLINDER
function LOTM.Hitbox.CheckCylinder(hitbox, entity)
    local entPos = entity:GetPos()
    local origin = hitbox.origin
    
    -- Проверка высоты
    if entPos.z < origin.z or entPos.z > origin.z + hitbox.height then
        return false
    end
    
    -- Проверка радиуса (игнорируем Z)
    local dist2D = math.sqrt((entPos.x - origin.x)^2 + (entPos.y - origin.y)^2)
    return dist2D <= hitbox.radius
end

-- Проверка попадания для CONE
function LOTM.Hitbox.CheckCone(hitbox, entity)
    local entPos = entity:GetPos()
    local origin = hitbox.origin
    local direction = hitbox.direction:GetNormalized()
    
    -- Вектор к сущности
    local toEntity = (entPos - origin)
    local distance = toEntity:Length()
    
    -- Проверка длины конуса
    if distance > hitbox.length then
        return false
    end
    
    -- Проверка угла
    toEntity:Normalize()
    local dot = direction:Dot(toEntity)
    local angleRad = math.rad(hitbox.angle / 2)
    
    return dot >= math.cos(angleRad)
end

-- Проверка попадания для RAY
function LOTM.Hitbox.CheckRay(hitbox, entity)
    local startPos = hitbox.origin
    local direction = hitbox.direction:GetNormalized()
    local endPos = startPos + direction * hitbox.length
    
    -- Трассировка луча
    local trace = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = hitbox.filter,
    })
    
    if trace.Hit and trace.Entity == entity then
        return true
    end
    
    -- Также проверяем близость к линии луча
    local entPos = entity:GetPos()
    local closest = LOTM.Hitbox.ClosestPointOnLine(startPos, endPos, entPos)
    local dist = closest:Distance(entPos)
    
    -- Радиус попадания для луча (толщина луча)
    local rayRadius = hitbox.radius or 10
    return dist <= rayRadius
end

-- Проверка попадания для CIRCLE
function LOTM.Hitbox.CheckCircle(hitbox, entity)
    local entPos = entity:GetPos()
    local origin = hitbox.origin
    
    -- Определяем Z-позицию круга
    local circleZ = origin.z
    if hitbox.circlePos == LOTM.Hitbox.CirclePosition.TOP then
        circleZ = origin.z + 70  -- Над головой
    elseif hitbox.circlePos == LOTM.Hitbox.CirclePosition.BOTTOM then
        circleZ = origin.z - 5   -- Под ногами
    end
    
    -- Проверка что сущность примерно на той же высоте (±50 единиц)
    local zThreshold = 50
    if math.abs(entPos.z - circleZ) > zThreshold then
        return false
    end
    
    -- Проверка радиуса на плоскости XY
    local dist2D = math.sqrt((entPos.x - origin.x)^2 + (entPos.y - origin.y)^2)
    return dist2D <= hitbox.radius
end

-- Вспомогательная функция: ближайшая точка на линии
function LOTM.Hitbox.ClosestPointOnLine(lineStart, lineEnd, point)
    local line = lineEnd - lineStart
    local len = line:Length()
    line:Normalize()
    
    local v = point - lineStart
    local d = v:Dot(line)
    d = math.Clamp(d, 0, len)
    
    return lineStart + line * d
end

-- Основная проверка попадания
function LOTM.Hitbox.CheckHit(hitbox, entity)
    if not IsValid(entity) then return false end
    if hitbox.hitEntities[entity] then return false end  -- Уже задели
    if table.HasValue(hitbox.filter, entity) then return false end
    
    local hit = false
    
    if hitbox.type == LOTM.Hitbox.Types.SPHERE then
        hit = LOTM.Hitbox.CheckSphere(hitbox, entity)
    elseif hitbox.type == LOTM.Hitbox.Types.BOX then
        hit = LOTM.Hitbox.CheckBox(hitbox, entity)
    elseif hitbox.type == LOTM.Hitbox.Types.CYLINDER then
        hit = LOTM.Hitbox.CheckCylinder(hitbox, entity)
    elseif hitbox.type == LOTM.Hitbox.Types.CONE then
        hit = LOTM.Hitbox.CheckCone(hitbox, entity)
    elseif hitbox.type == LOTM.Hitbox.Types.RAY then
        hit = LOTM.Hitbox.CheckRay(hitbox, entity)
    elseif hitbox.type == LOTM.Hitbox.Types.CIRCLE then
        hit = LOTM.Hitbox.CheckCircle(hitbox, entity)
    end
    
    return hit
end

-- Получить все сущности в хитбоксе
function LOTM.Hitbox.GetEntitiesInHitbox(hitbox)
    local entities = {}
    
    -- Определяем область поиска
    local searchRadius = hitbox.radius or hitbox.length or 500
    if hitbox.type == LOTM.Hitbox.Types.BOX then
        searchRadius = hitbox.size:Length()
    end
    
    -- Находим сущности в области
    local nearbyEnts = ents.FindInSphere(hitbox.origin, searchRadius)
    
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
            if LOTM.Hitbox.CheckHit(hitbox, ent) then
                table.insert(entities, ent)
            end
        end
    end
    
    return entities
end

-- Обработка хитбокса (наносит урон, вызывает callback)
function LOTM.Hitbox.Process(hitboxId)
    local hitbox = LOTM.Hitbox.ActiveHitboxes[hitboxId]
    if not hitbox or not hitbox.active then return {} end
    
    local hitEntities = {}
    local entities = LOTM.Hitbox.GetEntitiesInHitbox(hitbox)
    
    for _, ent in ipairs(entities) do
        if not hitbox.hitEntities[ent] then
            hitbox.hitEntities[ent] = true
            table.insert(hitEntities, ent)
            
            -- Callback при попадании
            if hitbox.onHit then
                hitbox.onHit(hitbox, ent)
            end
            
            -- Нанесение урона (только на сервере)
            if SERVER and hitbox.damage > 0 then
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamage(hitbox.damage)
                dmgInfo:SetAttacker(IsValid(hitbox.owner) and hitbox.owner or game.GetWorld())
                dmgInfo:SetInflictor(IsValid(hitbox.owner) and hitbox.owner or game.GetWorld())
                
                -- Используем LOTM тип урона если доступен
                if LOTM.Damage and LOTM.Damage.Apply then
                    LOTM.Damage.Apply(ent, hitbox.damage, hitbox.damageType, hitbox.owner, hitbox.origin)
                else
                    ent:TakeDamageInfo(dmgInfo)
                end
            end
        end
    end
    
    return hitEntities
end

-- Удаление хитбокса
function LOTM.Hitbox.Remove(hitboxId)
    LOTM.Hitbox.ActiveHitboxes[hitboxId] = nil
end

-- Деактивация хитбокса
function LOTM.Hitbox.Deactivate(hitboxId)
    if LOTM.Hitbox.ActiveHitboxes[hitboxId] then
        LOTM.Hitbox.ActiveHitboxes[hitboxId].active = false
    end
end

-- Think-хук для обработки активных хитбоксов
hook.Add("Think", "LOTM.Hitbox.Think", function()
    local curTime = CurTime()
    
    for id, hitbox in pairs(LOTM.Hitbox.ActiveHitboxes) do
        if hitbox.active then
            -- Проверка времени жизни
            if hitbox.duration > 0 and (curTime - hitbox.startTime) > hitbox.duration then
                LOTM.Hitbox.Remove(id)
            else
                -- Обработка попаданий
                LOTM.Hitbox.Process(id)
            end
        end
    end
end)

-- Отладочная визуализация (только на клиенте)
if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "LOTM.Hitbox.Debug", function()
        for id, hitbox in pairs(LOTM.Hitbox.ActiveHitboxes) do
            if hitbox.showDebug and hitbox.active then
                local color = hitbox.color
                
                if hitbox.type == LOTM.Hitbox.Types.SPHERE then
                    render.SetColorMaterial()
                    render.DrawSphere(hitbox.origin, hitbox.radius, 16, 16, color)
                    
                elseif hitbox.type == LOTM.Hitbox.Types.BOX then
                    render.SetColorMaterial()
                    render.DrawWireframeBox(hitbox.origin, Angle(0,0,0), -hitbox.size/2, hitbox.size/2, color, true)
                    
                elseif hitbox.type == LOTM.Hitbox.Types.CYLINDER then
                    render.SetColorMaterial()
                    local segments = 16
                    for i = 0, segments - 1 do
                        local a1 = (i / segments) * math.pi * 2
                        local a2 = ((i + 1) / segments) * math.pi * 2
                        
                        local p1 = hitbox.origin + Vector(math.cos(a1) * hitbox.radius, math.sin(a1) * hitbox.radius, 0)
                        local p2 = hitbox.origin + Vector(math.cos(a2) * hitbox.radius, math.sin(a2) * hitbox.radius, 0)
                        local p3 = p1 + Vector(0, 0, hitbox.height)
                        local p4 = p2 + Vector(0, 0, hitbox.height)
                        
                        render.DrawLine(p1, p2, color, true)
                        render.DrawLine(p3, p4, color, true)
                        render.DrawLine(p1, p3, color, true)
                    end
                    
                elseif hitbox.type == LOTM.Hitbox.Types.CONE then
                    render.SetColorMaterial()
                    local endPos = hitbox.origin + hitbox.direction:GetNormalized() * hitbox.length
                    render.DrawLine(hitbox.origin, endPos, color, true)
                    
                elseif hitbox.type == LOTM.Hitbox.Types.RAY then
                    render.SetColorMaterial()
                    local endPos = hitbox.origin + hitbox.direction:GetNormalized() * hitbox.length
                    render.DrawLine(hitbox.origin, endPos, color, true)
                    render.DrawSphere(hitbox.origin, 5, 8, 8, color)
                    render.DrawSphere(endPos, 5, 8, 8, color)
                    
                elseif hitbox.type == LOTM.Hitbox.Types.CIRCLE then
                    render.SetColorMaterial()
                    local circleZ = hitbox.origin.z
                    if hitbox.circlePos == LOTM.Hitbox.CirclePosition.TOP then
                        circleZ = hitbox.origin.z + 70
                    elseif hitbox.circlePos == LOTM.Hitbox.CirclePosition.BOTTOM then
                        circleZ = hitbox.origin.z - 5
                    end
                    
                    local segments = 32
                    for i = 0, segments - 1 do
                        local a1 = (i / segments) * math.pi * 2
                        local a2 = ((i + 1) / segments) * math.pi * 2
                        
                        local p1 = Vector(hitbox.origin.x + math.cos(a1) * hitbox.radius, 
                                         hitbox.origin.y + math.sin(a1) * hitbox.radius, circleZ)
                        local p2 = Vector(hitbox.origin.x + math.cos(a2) * hitbox.radius, 
                                         hitbox.origin.y + math.sin(a2) * hitbox.radius, circleZ)
                        
                        render.DrawLine(p1, p2, color, true)
                    end
                end
            end
        end
    end)
end

-- Быстрые функции для создания хитбоксов
function LOTM.Hitbox.CreateSphere(origin, radius, params)
    params = params or {}
    params.origin = origin
    params.radius = radius
    return LOTM.Hitbox.Create(LOTM.Hitbox.Types.SPHERE, params)
end

function LOTM.Hitbox.CreateBox(origin, size, params)
    params = params or {}
    params.origin = origin
    params.size = size
    return LOTM.Hitbox.Create(LOTM.Hitbox.Types.BOX, params)
end

function LOTM.Hitbox.CreateCylinder(origin, radius, height, params)
    params = params or {}
    params.origin = origin
    params.radius = radius
    params.height = height
    return LOTM.Hitbox.Create(LOTM.Hitbox.Types.CYLINDER, params)
end

function LOTM.Hitbox.CreateCone(origin, direction, angle, length, params)
    params = params or {}
    params.origin = origin
    params.direction = direction
    params.angle = angle
    params.length = length
    return LOTM.Hitbox.Create(LOTM.Hitbox.Types.CONE, params)
end

function LOTM.Hitbox.CreateRay(origin, direction, length, params)
    params = params or {}
    params.origin = origin
    params.direction = direction
    params.length = length
    return LOTM.Hitbox.Create(LOTM.Hitbox.Types.RAY, params)
end

function LOTM.Hitbox.CreateCircle(origin, radius, circlePos, params)
    params = params or {}
    params.origin = origin
    params.radius = radius
    params.circlePos = circlePos or LOTM.Hitbox.CirclePosition.CENTER
    return LOTM.Hitbox.Create(LOTM.Hitbox.Types.CIRCLE, params)
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Hitbox system loaded\n")

