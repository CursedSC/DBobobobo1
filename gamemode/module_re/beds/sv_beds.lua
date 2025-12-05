
beds = {}

function beds.Load()
    local f = file.Read( "beds.json", "DATA")
    local data = util.JSONToTable(f) 

    local all_ents = ents.GetAll()

    for k, i in pairs(all_ents) do 
        if i.IsServer then i:Remove() end
    end

    for id, info in pairs(data) do
        local bed = ents.Create( "prop_vehicle_prisoner_pod" )
        bed:SetPos( info.pos )
        bed:SetModel("models/vehicles/prisoner_pod_inner.mdl")
        bed:SetAngles( info.angle )

        bed:Spawn()
        bed:SetMoveType(MOVETYPE_NONE)
        bed:SetCollisionGroup(COLLISION_GROUP_WORLD)
        bed:SetColor( Color( 255, 255, 255, 0 ) ) 
        bed:SetRenderMode( RENDERMODE_TRANSCOLOR ) 
        bed.IsServer = true
    end
end

concommand.Add("SaveBed", function(ply)
    local bed = {}

    for id, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "prop_vehicle_prisoner_pod" then 
            bed[#bed + 1] = {
                pos = ent:GetPos(),
                angle = ent:GetAngles()
            }
        end 
    end
    local data = util.TableToJSON(bed)

    file.Write( "beds.json", data) 
end)

concommand.Add("LoadBeds", function(ply)
    beds.Load()
end)

hook.Add("PostCleanupMap", "PostCleanup_Beds", function()
    beds.Load()
end)
hook.Add( "Initialize", "Initialize_Beds", function()
    beds.Load()
end )

-- Програзка кроватей
beds.Load()