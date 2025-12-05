  
local meta = FindMetaTable("Entity")
local plyMeta = FindMetaTable("Player")

local doors = {
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true,
}

function meta:isDoor()
    local class = self:GetClass()

    if doors[class] then
        return true
    end

    return false
end

function meta:GetDoorOwner()
    return self:GetNWString("Owner")
end

--dbt.chr[ownerCharacter].door_icon

function GetDoorIcon(ownerCharacter)
    return dbt.chr[ownerCharacter].door_icon
end
