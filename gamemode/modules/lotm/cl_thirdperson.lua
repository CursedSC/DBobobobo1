-- LOTM Third Person Camera System
-- Приятная камера третьего лица с ограничениями

LOTM = LOTM or {}
LOTM.ThirdPerson = LOTM.ThirdPerson or {}

-- Настройки камеры
LOTM.ThirdPerson.Enabled = false
LOTM.ThirdPerson.Distance = 100
LOTM.ThirdPerson.Height = 20
LOTM.ThirdPerson.SmoothSpeed = 10
LOTM.ThirdPerson.CollisionEnabled = true

-- Текущие значения
local currentDistance = 0
local currentHeight = 0
local targetPos = Vector(0, 0, 0)
local currentPos = Vector(0, 0, 0)

-- Включить/выключить камеру третьего лица
function LOTM.ThirdPerson.Toggle()
    LOTM.ThirdPerson.Enabled = not LOTM.ThirdPerson.Enabled
    
    if LOTM.ThirdPerson.Enabled then
        currentDistance = 0
        currentHeight = 0
    end
end

-- Установить расстояние камеры
function LOTM.ThirdPerson.SetDistance(distance)
    LOTM.ThirdPerson.Distance = math.Clamp(distance, 50, 300)
end

-- Установить высоту камеры
function LOTM.ThirdPerson.SetHeight(height)
    LOTM.ThirdPerson.Height = math.Clamp(height, -50, 100)
end

-- Расчёт позиции камеры
local function CalculateCameraPosition(ply, view)
    if not IsValid(ply) or not ply:Alive() then return view end
    
    local eyePos = ply:EyePos()
    local eyeAngles = view.angles
    
    -- Целевая позиция камеры
    local backward = -eyeAngles:Forward()
    targetPos = eyePos + backward * LOTM.ThirdPerson.Distance + Vector(0, 0, LOTM.ThirdPerson.Height)
    
    -- Проверка коллизий
    if LOTM.ThirdPerson.CollisionEnabled then
        local trace = util.TraceLine({
            start = eyePos,
            endpos = targetPos,
            filter = ply,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if trace.Hit then
            -- Сдвинуть камеру ближе к игроку при столкновении
            targetPos = trace.HitPos + trace.HitNormal * 5
        end
    end
    
    -- Плавное движение камеры
    currentPos = LerpVector(FrameTime() * LOTM.ThirdPerson.SmoothSpeed, currentPos, targetPos)
    
    -- Ограничение от ухода за текстуры
    local mins, maxs = ply:GetCollisionBounds()
    local playerCenter = ply:GetPos() + Vector(0, 0, (maxs.z - mins.z) / 2)
    
    -- Проверка что камера не слишком далеко
    local maxAllowedDistance = LOTM.ThirdPerson.Distance + 50
    if currentPos:Distance(playerCenter) > maxAllowedDistance then
        local direction = (currentPos - playerCenter):GetNormalized()
        currentPos = playerCenter + direction * maxAllowedDistance
    end
    
    -- Финальная проверка что камера не в текстуре
    local finalTrace = util.TraceLine({
        start = eyePos,
        endpos = currentPos,
        filter = ply,
        mask = MASK_SOLID_BRUSHONLY
    })
    
    if finalTrace.StartSolid or finalTrace.AllSolid then
        -- Если камера в стене, вернуть её к игроку
        currentPos = eyePos + Vector(0, 0, 20)
    end
    
    return currentPos
end

-- Хук на калькулятор вида
hook.Add("CalcView", "LOTM.ThirdPersonCamera", function(ply, origin, angles, fov)
    if not LOTM.ThirdPerson.Enabled then return end
    if not IsValid(ply) or not ply:Alive() then return end
    
    local view = {
        origin = origin,
        angles = angles,
        fov = fov,
        drawviewer = true
    }
    
    view.origin = CalculateCameraPosition(ply, view)
    
    return view
end)

-- Команда для переключения камеры
concommand.Add("lotm_thirdperson", function(ply, cmd, args)
    LOTM.ThirdPerson.Toggle()
    
    if LOTM.ThirdPerson.Enabled then
        chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Камера третьего лица включена")
    else
        chat.AddText(Color(255, 0, 0), "[LOTM] ", color_white, "Камера третьего лица выключена")
    end
end)

-- Команды для настройки камеры
concommand.Add("lotm_camera_distance", function(ply, cmd, args)
    local distance = tonumber(args[1]) or 100
    LOTM.ThirdPerson.SetDistance(distance)
    chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Расстояние камеры: " .. distance)
end)

concommand.Add("lotm_camera_height", function(ply, cmd, args)
    local height = tonumber(args[1]) or 20
    LOTM.ThirdPerson.SetHeight(height)
    chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Высота камеры: " .. height)
end)

-- Сброс при смерти
hook.Add("PlayerDeath", "LOTM.ResetThirdPerson", function(ply)
    if ply == LocalPlayer() then
        LOTM.ThirdPerson.Enabled = false
        currentPos = Vector(0, 0, 0)
        targetPos = Vector(0, 0, 0)
    end
end)

print("[LOTM] Система камеры третьего лица загружена")