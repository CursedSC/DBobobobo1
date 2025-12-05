AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/sickness/stove_01.mdl" )

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
	self:SetNWInt("Cock_amout", 0)
	self.TimeCoolDown = CurTime()
	self.Items = self.Items or default_setting_pech
	self.NamePanel = self.NamePanel or "КУХОННАЯ ПЛИТА"
end


function ENT:Use(activator)
	if self.TimeCoolDown > CurTime() then return end
	if util.TraceLine( util.GetPlayerTrace( activator ) ).Entity != self then return end
	self.TimeCoolDown = CurTime() + 1
	netstream.Start(activator, "dbt/food/furngug", self, self.NamePanel, self.Items)
end

netstream.Hook("dbt/pech/rem", function(ply, ent, amout)
	ent:SetNWInt("Cock_amout", ent:GetNWInt("Cock_amout") - amout)
end)

function ENT:StartTouch(ent)
	-- body
	if ent:GetClass() == "shit" and self:GetNWInt("Cock_amout") < 10 then
		ent:Remove()
		self:SetNWInt("Cock_amout", self:GetNWInt("Cock_amout") + 1)
	end
end
