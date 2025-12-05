AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/box/box.mdl" )

	-- Sets what color to use
	self:SetColor( Color( 255, 255, 255 ) )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end
	
	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end
	self.TimeCoolDown = CurTime()
end


function ENT:Use(activator)
	if self.al then return end
	self.al = true
	netstream.Start(activator, "gift/up", true)

	timer.Simple(3, function()
		netstream.Start(activator, "gift/up", false)
		local suc = dbt.inventory.additem(activator, self.wep)
		if self.isExplode then 
			local explosion = ents.Create("env_explosion")
			explosion:SetPos(self:GetPos())
			explosion:SetOwner(activator)
			explosion:Spawn()
			explosion:SetKeyValue("iMagnitude", "100")
			explosion:Fire("Explode", 0, 0)
			self:Remove()
		else 
			self:Remove()
		end
	end)
end
