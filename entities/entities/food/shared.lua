ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Еда"
ENT.Spawnable = false
ENT.Category = "DBT - Entity"

function ENT:Draw()
	self:DrawModel()
	if not dbt.inventory.items[self:GetNWInt("_id")] then return end
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
	local angle = EyeAngles()


	angle = Angle( 0, angle.y, 0 )


	angle.y = angle.y + math.sin( CurTime() ) * 10


	angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )


	local pos =self:GetPos() + Vector(0, 0, 1)


	pos = pos + Vector( 0, 0, math.cos( CurTime() / 2 ) + 20 )

	if dist <= 255 then 
		cam.Start3D2D( pos, angle, 0.01 )
			
			//surface.SetDrawColor( 255, 255, 255,  255 - dist   ) 
			//surface.SetMaterial( dbt.inventory.items[self:GetNWInt("_id")].icon) 
			//surface.DrawTexturedRect( 512 / 2 * -1, 0, 512, 512 ) 
			
		cam.End3D2D()
	end
end