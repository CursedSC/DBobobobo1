CHARACTER = {}

local function cloneValue(value)
    if istable(value) then
        return table.Copy(value)
    end
    return value
end

function CHARACTER:__tostring()
    return "Персонаж[" .. tostring(self.name) .. "]["..tostring(self.index).."]"
end

function CHARACTER:Init(name, data)
    local input = istable(data) and table.Copy(data) or {}
    input.name = input.name or name

    local applied = {}

    applied.name = input.name
    applied.model = input.model or "models/player/Group01/female_01.mdl"
    applied.male = input.male or false
    applied.hugred = input.hugred ~= false
    applied.starving = input.starving ~= false
    applied.food = input.food or 1
    applied.water = input.water or 1
    applied.discord = input.discord
    applied.sleep = input.sleep or 1
    applied.season = input.season or 0
    applied.char = input.char or 1
    applied.attentiveness = input.attentiveness or 1
    applied.color = cloneValue(input.color) or Color(0, 0, 0)
    applied.blacklistwep = cloneValue(input.blacklistwep) or {}
    applied.med_inv = input.med_inv or false
    applied.absl = input.absl or ""
    applied.emote = input.emote or 1
    applied.maxKG = input.maxKG or 100
    applied.lock = input.lock
    applied.customItems = cloneValue(input.customItems)
    applied.customWeapons = cloneValue(input.customWeapons)
    applied.isCustom = input.isCustom or false

    for k, v in pairs(input) do
        if applied[k] == nil then
            applied[k] = cloneValue(v)
        end
    end

    for k, v in pairs(applied) do
        self[k] = cloneValue(v)
    end

    self.backup = table.Copy(applied)
end

function CHARACTER:Update(tbl) 
    local tbl = tbl or {}
    PrintTable(self.backup)
    for k,v in pairs(tbl) do
        if k == "backup" then continue end
        self[k] = v or self[k]
    end
    PrintTable(self.backup)
end

function CHARACTER:SetModel(mdl)
    self.model = mdl
end

function CHARACTER:SetMale(b)
    self.male = b
end

function CHARACTER:SetHungred(b)
    self.hugred = b
end

function CHARACTER:SetStarving(b)
    self.starving = b
end

function CHARACTER:SetFood(n)
    self.food = n
end

function CHARACTER:SetWater(n)
    self.water = n
end

function CHARACTER:SetSleep(n)
    self.sleep = n
end

function CHARACTER:SetSeason(n)
    self.season = n
end

function CHARACTER:GetChar(n)
    self.char = n
end

function CHARACTER:GetMale(b)
    return self.male
end

function CHARACTER:GetHungred(b)
    return self.hugred
end

function CHARACTER:GetStarving(b)
    return self.starving
end

function CHARACTER:GetFood(n)
    return self.food
end

function CHARACTER:GetWater(n)
    return self.water
end

function CHARACTER:GetSleep(n)
    return self.sleep
end

function CHARACTER:GetSeason(n)
    return self.season
end

function CHARACTER:GetChar(n)
    return self.char
end

function CHARACTER:GetEmotes(n)
    return self.emote
end

CHARACTER.__index = CHARACTER
