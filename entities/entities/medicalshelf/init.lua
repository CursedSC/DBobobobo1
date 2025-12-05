AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/gta_prop_michou/v_med_cor_wallunitb.mdl" )

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

	if self.TimeCoolDown > CurTime() then return end
		if util.TraceLine( util.GetPlayerTrace( activator ) ).Entity != self then return end
	self.TimeCoolDown = CurTime() + 1
	netstream.Start(activator, "dbt/woundsystem/medicalshelf")
end
