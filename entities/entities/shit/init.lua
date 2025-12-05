AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/props_junk/garbage_bag001a.mdl" )


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
end

function ENT:Use(activator)
		if #activator.items >= 6 then	
			netstream.Start(activator, "dbt/inventory/error", "Недостаточно места в инвентаре!")
			return 
		end
		
	dbt.inventory.additem(activator, 25, {}) 
	self:Remove()--25

	
end
