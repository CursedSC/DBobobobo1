AddCSLuaFile()
dbt = dbt or {}
woundstbl = {}
local circles = include("dbt/gamemode/lib/demit/cl_circles.lua")
local progresscircle = circles.New(CIRCLE_OUTLINED, 20, scrw*0.5, scrh*0.5, 5)
progresscircle:SetRotation(270)

surface.CreateFont("DBT_Wounds_Name", {
    font = "Comfortaa",
    size = 26,
    weight = 600,
    extended = true
})

surface.CreateFont("DBT_Wounds_Info", {
    font = "Comfortaa",
    size = 20,
    weight = 400,
    extended = true
})

surface.CreateFont("DBT_Wounds_Question", {
    font = "Comfortaa",
    size = 28,
    weight = 800,
    extended = true
})

dbt.WoundClient = dbt.WoundClient or {}
dbt.WoundClient.publicStates = dbt.WoundClient.publicStates or setmetatable({}, { __mode = "k" })

local publicWounds = dbt.WoundClient.publicStates

local woundPositionOrder = {
    "Голова",
    "Туловище",
    "Левая рука",
    "Правая рука",
    "Левая нога",
    "Правая нога"
}

local woundPriority = {
    ["Пулевое ранение"] = 1,
    ["Тяжелое ранение"] = 2,
    ["Ранение"] = 3,
    ["Перелом"] = 4,
    ["Ушиб"] = 5,
}

local function tableIsEmpty(tbl)
    return not tbl or next(tbl) == nil
end

local function deepCopy(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        if istable(v) then
            out[k] = deepCopy(v)
        else
            out[k] = v
        end
    end
    return out
end

local function formatWoundDetails(entries)
    local details = {}
    for woundName, count in pairs(entries) do
        details[#details + 1] = {
            name = woundName,
            count = count,
            order = woundPriority[woundName] or 99
        }
    end

    table.sort(details, function(a, b)
        if a.order == b.order then
            return a.name < b.name
        end
        return a.order < b.order
    end)

    local formatted = {}
    for _, wound in ipairs(details) do
        if wound.count and wound.count > 1 then
            formatted[#formatted + 1] = string.format("%s x%d", wound.name, wound.count)
        else
            formatted[#formatted + 1] = wound.name
        end
    end

    return table.concat(formatted, ", ")
end

local function buildDisplayLines(data)
    local lines = {}
    for _, positionName in ipairs(woundPositionOrder) do
        local entry = data[positionName]
        if entry then
            local value = formatWoundDetails(entry)
            if value ~= "" then
                lines[#lines + 1] = positionName .. ": " .. value
            end
        end
    end
    return lines
end

local function buildPositionMap(data)
    local out = {}
    for _, positionName in ipairs(woundPositionOrder) do
        local entry = data[positionName]
        if entry then
            local value = formatWoundDetails(entry)
            if value ~= "" then
                out[positionName] = value
            end
        end
    end
    return out
end

function dbt.GetPublicWoundState(target)
    return publicWounds[target]
end

function dbt.GetFormattedPublicWounds(target)
    local state = publicWounds[target]
    if not state then return nil end
    return state, buildDisplayLines(state)
end

function dbt.GetFormattedWoundsByPosition(target)
    local state = publicWounds[target]
    if not state then return nil end
    return state, buildPositionMap(state)
end

dbt.WoundDisplayColors = dbt.WoundDisplayColors or {
    question = Color(255, 235, 130),
    noData = Color(220, 120, 120),
    positive = Color(150, 235, 150),
}

-- Система проецирования текстур
local projectedTextures = {}
local projectorTexture = Material("effects/blood_puddle") -- замените на вашу текстуру
local projectorSize = 64 -- размер проекции

-- Создание проецируемой текстуры
local function CreateProjectedTexture(pos, normal, size, material)
    local projector = ProjectedTexture()
    if not IsValid(projector) then return nil end
    
    projector:SetTexture(material:GetTexture("$basetexture"))
    projector:SetPos(pos + normal * 5)
    projector:SetAngles(normal:Angle())
    projector:SetFOV(45)
    projector:SetFarZ(size * 2)
    projector:SetNearZ(1)
    projector:SetBrightness(1)
    projector:SetColor(Color(255, 255, 255))
    projector:SetEnableShadows(false)
    projector:Update()
    return projector
end

-- Функция для проецирования текстуры на поверхность
local function ProjectTextureOnSurface(startPos, endPos, material, size)
    local trace = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = LocalPlayer()
    })
    
    if trace.Hit then
        local projector = CreateProjectedTexture(trace.HitPos, trace.HitNormal, size or projectorSize, material or projectorTexture)
        if projector then
            table.insert(projectedTextures, {
                projector = projector,
                pos = trace.HitPos,
                normal = trace.HitNormal,
                time = CurTime(),
                entity = trace.Entity
            })
        end
    end
end

netstream.Hook("dbt/woundsystem/cl_getwound", function(wounds)
	woundstbl = wounds
end)

netstream.Hook("dbt/woundsystem/public_state", function(target, state)
    if not IsValid(target) or not target:IsPlayer() then return end
    if not istable(state) then
        publicWounds[target] = nil
        return
    end

    if tableIsEmpty(state) then
        publicWounds[target] = {}
    else
        publicWounds[target] = deepCopy(state)
    end
end)

hook.Add("EntityRemoved", "dbt/woundsystem/public_cleanup", function(ent)
    if publicWounds[ent] then
        publicWounds[ent] = nil
    end
end)

netstream.Hook("dbt/woundsystem/progressuse", function(ply, medclass)
	progress = 0
	timer.Create("dbt/woundsystem/progresstimer", 0, 0,function ()
		local trace = ply:GetEyeTrace()
		if input.IsKeyDown(KEY_E) and progress < 100 and INTERACTIONOO == 1 and trace.Entity:GetClass() == "item" then
			progress = progress + 1
		elseif progress >= 100 then
			progress = nil
			netstream.Start("dbt/woundsystem/usemedicine", medclass, trace.Entity)
			timer.Remove("dbt/woundsystem/progresstimer")
		else
			progress = nil
			timer.Remove("dbt/woundsystem/progresstimer")
		end
	end)
end)

hook.Add("HUDPaint", "dbt/woundsystem/progress",function ()
	if progress then
		surface.SetDrawColor(255, 255, 255, 255)
		draw.NoTexture()
		progresscircle:SetEndAngle(progress*3.6)
		progresscircle()
	end
end)
