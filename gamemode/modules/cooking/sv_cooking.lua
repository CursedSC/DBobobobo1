---

netstream.Hook("dbt/food/spawn", function(ply, mdl, food, id, water)
	/*
	local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
        filter = ply,
    })

    local itemEnt = ents.Create("item")
    itemEnt:SetPos(tr.HitPos)
    itemEnt:SetAngles(Angle(180,0,0))
    itemEnt:SetNWInt("AdvencedUse", 1)
    itemEnt:SetInfo(id, {})
    itemEnt:Spawn()

    itemEnt:SetModel(mdl)
    itemEnt:PhysicsInit( SOLID_VPHYSICS )
	itemEnt:SetMoveType( MOVETYPE_VPHYSICS )
	itemEnt:SetSolid( SOLID_VPHYSICS )

    if dbt.inventory.items[id].color then
        itemEnt:SetColor( dbt.inventory.items[id].color )
        itemEnt:SetRenderMode( RENDERMODE_TRANSCOLOR )
    end
	local phys = itemEnt:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	*/
	dbt.inventory.additem(ply, id, {})
end)

netstream.Hook("dbt/food/entity_settings", function(ply, entity, name, items)
	entity.Items = items and items or entity.Items
	entity.NamePanel = name and name or entity.NamePanel
end)
