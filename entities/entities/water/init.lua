AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("dbt.AddEvidence")

function ENT:Initialize()
	self:SetModel( "models/props_everything/milk.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end




function ENT:Use(activator)
	self:Remove()
	timer.Create("Food_Update".. math.random(1, 100000000), 0.2, 10, function()
		if activator:GetNWInt("water") >= 100 then return end
		activator:SetNWInt("water", math.random( 1, 5 ) + activator:GetNWInt("water"))
	end)
end
