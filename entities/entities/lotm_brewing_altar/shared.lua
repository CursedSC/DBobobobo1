-- LOTM Brewing Altar - Shared
-- Алтарь зельеварения с кругами для ингредиентов

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Алтарь Зельеварения"
ENT.Author = "LOTM System"
ENT.Category = "LOTM"
ENT.Spawnable = true
ENT.AdminOnly = true

-- Константы
ENT.MAX_INGREDIENT_SLOTS = 6
ENT.INTERACTION_DISTANCE = 150
ENT.CIRCLE_RADIUS = 80 -- Радиус размещения кругов от центра

-- Позиции слотов по кругу (углы в градусах)
ENT.SLOT_ANGLES = {0, 60, 120, 180, 240, 300}

-- Получить мировую позицию слота
function ENT:GetSlotWorldPos(slotIndex)
    local basePos = self:GetPos()
    local angle = math.rad(self.SLOT_ANGLES[slotIndex] or 0)
    local radius = self.CIRCLE_RADIUS
    
    local offset = Vector(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
        5 -- Немного над землёй
    )
    
    return basePos + offset
end

-- Проверить, находится ли позиция рядом со слотом
function ENT:GetNearestSlot(worldPos)
    local nearestSlot = nil
    local nearestDist = math.huge
    
    for i = 1, self.MAX_INGREDIENT_SLOTS do
        local slotPos = self:GetSlotWorldPos(i)
        local dist = slotPos:Distance(worldPos)
        
        if dist < 40 and dist < nearestDist then -- 40 единиц - радиус захвата
            nearestDist = dist
            nearestSlot = i
        end
    end
    
    return nearestSlot, nearestDist
end
