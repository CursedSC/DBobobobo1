if CLIENT then
    return
end

ragdoll = { }

function ragdoll.IsRagdoll(entity)
    return TypeID(entity) == TYPE_ENTITY and entity:IsRagdoll()
end

function ragdoll.Rotate(ragdoll, angle)
    if  not ragdoll.IsRagdoll(ragdoll) or
        TypeID(angle) ~= TYPE_ANGLE
    then
        return false
    end

    local physObjectCount = ragdoll:GetPhysicsObjectCount() - 1
    local bones = { }

    for i = 0, physObjectCount do
        local PhysBone = ragdoll:GetPhysicsObjectNum(i)

        if PhysBone and PhysBone:IsValid() then
            bones[i] = {
                pos = ragdoll:WorldToLocal(PhysBone:GetPos()),
                angles = ragdoll:WorldToLocalAngles(PhysBone:GetAngles())
            }
        end
    end

    ragdoll:SetAngles(angle)

    for i = 0, physObjectCount do
        local PhysBone = ragdoll:GetPhysicsObjectNum(i)

        if PhysBone and PhysBone:IsValid() then
            local boneData = bones[i]

            PhysBone:SetPos(ragdoll:LocalToWorld(boneData.pos))
            PhysBone:SetAngles(ragdoll:LocalToWorldAngles(boneData.angles))
        end
    end

    return true
end

function ragdoll.Move(ragdoll, offset)
    if  not ragdoll.IsRagdoll(ragdoll) or
        TypeID(offset) ~= TYPE_VECTOR
    then
        return false
    end

    local physObjectCount = ragdoll:GetPhysicsObjectCount() - 1

    for i = 0, physObjectCount do
        local PhysBone = ragdoll:GetPhysicsObjectNum(i)

        if PhysBone and PhysBone:IsValid() then
            PhysBone:SetPos(PhysBone:GetPos() + offset)
        end
    end

    return true
end