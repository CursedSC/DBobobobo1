-- LOTM Area Shapes System
-- Система областей эффектов для скиллов

LOTM = LOTM or {}
LOTM.AreaShapes = LOTM.AreaShapes or {}

-- Типы областей
LOTM.AreaShapes.Types = {
    SPHERE = 1,      -- Сферическая область
    BOX = 2,         -- Прямоугольная область (для стен/барьеров)
    CYLINDER = 3,    -- Цилиндрическая область
    CONE = 4,        -- Конусообразная область
    RAY = 5,         -- Луч
    CIRCLE = 6,      -- Круг (можно выбрать: центр, верх, низ)
}

-- Позиция круга
LOTM.AreaShapes.CirclePosition = {
    CENTER = 1,
    TOP = 2,
    BOTTOM = 3,
}

-- Создать сферическую область
function LOTM.AreaShapes.CreateSphere(center, radius)
    return {
        type = LOTM.AreaShapes.Types.SPHERE,
        center = center,
        radius = radius,
    }
end

-- Создать прямоугольную область (box)
function LOTM.AreaShapes.CreateBox(center, mins, maxs, angle)
    return {
        type = LOTM.AreaShapes.Types.BOX,
        center = center,
        mins = mins,
        maxs = maxs,
        angle = angle or Angle(0, 0, 0),
    }
end

-- Создать цилиндр
function LOTM.AreaShapes.CreateCylinder(center, radius, height)
    return {
        type = LOTM.AreaShapes.Types.CYLINDER,
        center = center,
        radius = radius,
        height = height,
    }
end

-- Создать конус
function LOTM.AreaShapes.CreateCone(origin, direction, range, angle)
    return {
        type = LOTM.AreaShapes.Types.CONE,
        origin = origin,
        direction = direction,
        range = range,
        angle = angle,
    }
end

-- Создать луч
function LOTM.AreaShapes.CreateRay(start, endPos, width)
    return {
        type = LOTM.AreaShapes.Types.RAY,
        start = start,
        endPos = endPos,
        width = width or 10,
    }
end

-- Создать круг
function LOTM.AreaShapes.CreateCircle(center, radius, position)
    return {
        type = LOTM.AreaShapes.Types.CIRCLE,
        center = center,
        radius = radius,
        position = position or LOTM.AreaShapes.CirclePosition.CENTER,
    }
end

-- Проверка попадания точки в область
function LOTM.AreaShapes.IsPointInArea(point, area)
    if area.type == LOTM.AreaShapes.Types.SPHERE then
        return point:Distance(area.center) <= area.radius
        
    elseif area.type == LOTM.AreaShapes.Types.BOX then
        local localPoint = WorldToLocal(point, Angle(0, 0, 0), area.center, area.angle)
        return localPoint.x >= area.mins.x and localPoint.x <= area.maxs.x and
               localPoint.y >= area.mins.y and localPoint.y <= area.maxs.y and
               localPoint.z >= area.mins.z and localPoint.z <= area.maxs.z
               
    elseif area.type == LOTM.AreaShapes.Types.CYLINDER then
        local distance2D = math.sqrt((point.x - area.center.x)^2 + (point.y - area.center.y)^2)
        local heightDiff = math.abs(point.z - area.center.z)
        return distance2D <= area.radius and heightDiff <= area.height / 2
        
    elseif area.type == LOTM.AreaShapes.Types.CONE then
        local toPoint = (point - area.origin):GetNormalized()
        local dotProduct = toPoint:Dot(area.direction)
        local angleToPoint = math.deg(math.acos(dotProduct))
        local distance = point:Distance(area.origin)
        return angleToPoint <= area.angle and distance <= area.range
        
    elseif area.type == LOTM.AreaShapes.Types.RAY then
        local line = area.endPos - area.start
        local lineLength = line:Length()
        local lineDir = line:GetNormalized()
        local toPoint = point - area.start
        local projection = toPoint:Dot(lineDir)
        
        if projection < 0 or projection > lineLength then return false end
        
        local closestPoint = area.start + lineDir * projection
        return point:Distance(closestPoint) <= area.width
        
    elseif area.type == LOTM.AreaShapes.Types.CIRCLE then
        local centerPos = area.center
        
        if area.position == LOTM.AreaShapes.CirclePosition.BOTTOM then
            centerPos = centerPos + Vector(0, 0, -50)
        elseif area.position == LOTM.AreaShapes.CirclePosition.TOP then
            centerPos = centerPos + Vector(0, 0, 50)
        end
        
        local distance2D = math.sqrt((point.x - centerPos.x)^2 + (point.y - centerPos.y)^2)
        local heightDiff = math.abs(point.z - centerPos.z)
        return distance2D <= area.radius and heightDiff <= 25
    end
    
    return false
end

-- Получить всех игроков в области
function LOTM.AreaShapes.GetPlayersInArea(area)
    local players = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            if LOTM.AreaShapes.IsPointInArea(ply:GetPos(), area) then
                table.insert(players, ply)
            end
        end
    end
    
    return players
end

-- Получить всех NPC в области
function LOTM.AreaShapes.GetNPCsInArea(area)
    local npcs = {}
    
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:Health() > 0 then
            if LOTM.AreaShapes.IsPointInArea(npc:GetPos(), area) then
                table.insert(npcs, npc)
            end
        end
    end
    
    return npcs
end

-- Визуализация области (только клиент)
if CLIENT then
    function LOTM.AreaShapes.DebugDraw(area, color, duration)
        color = color or Color(255, 0, 0, 50)
        duration = duration or 0.1
        
        if area.type == LOTM.AreaShapes.Types.SPHERE then
            debugoverlay.Sphere(area.center, area.radius, duration, color, true)
            
        elseif area.type == LOTM.AreaShapes.Types.BOX then
            debugoverlay.Box(area.center, area.mins, area.maxs, duration, color)
            
        elseif area.type == LOTM.AreaShapes.Types.CYLINDER then
            -- Отрисовка цилиндра кольцами
            local segments = 16
            for i = 0, segments do
                local angle1 = (i / segments) * 360
                local angle2 = ((i + 1) / segments) * 360
                
                local x1 = area.center.x + math.cos(math.rad(angle1)) * area.radius
                local y1 = area.center.y + math.sin(math.rad(angle1)) * area.radius
                local x2 = area.center.x + math.cos(math.rad(angle2)) * area.radius
                local y2 = area.center.y + math.sin(math.rad(angle2)) * area.radius
                
                local bottom1 = Vector(x1, y1, area.center.z - area.height / 2)
                local bottom2 = Vector(x2, y2, area.center.z - area.height / 2)
                local top1 = Vector(x1, y1, area.center.z + area.height / 2)
                local top2 = Vector(x2, y2, area.center.z + area.height / 2)
                
                debugoverlay.Line(bottom1, bottom2, duration, color, true)
                debugoverlay.Line(top1, top2, duration, color, true)
                debugoverlay.Line(bottom1, top1, duration, color, true)
            end
            
        elseif area.type == LOTM.AreaShapes.Types.CONE then
            -- Отрисовка конуса
            local segments = 12
            for i = 0, segments do
                local ang = (i / segments) * 360
                local rad = math.rad(ang)
                
                local perpendicular = area.direction:Angle():Up()
                perpendicular:Rotate(Angle(0, ang, 0))
                
                local offset = perpendicular * math.tan(math.rad(area.angle)) * area.range
                local endPoint = area.origin + area.direction * area.range + offset
                
                debugoverlay.Line(area.origin, endPoint, duration, color, true)
            end
            
        elseif area.type == LOTM.AreaShapes.Types.RAY then
            debugoverlay.Line(area.start, area.endPos, duration, color, true)
            
        elseif area.type == LOTM.AreaShapes.Types.CIRCLE then
            local centerPos = area.center
            if area.position == LOTM.AreaShapes.CirclePosition.BOTTOM then
                centerPos = centerPos + Vector(0, 0, -50)
            elseif area.position == LOTM.AreaShapes.CirclePosition.TOP then
                centerPos = centerPos + Vector(0, 0, 50)
            end
            
            debugoverlay.Sphere(centerPos, area.radius, duration, color, true)
        end
    end
end

print("[LOTM] Система областей эффектов загружена")