AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/props_lab/binderblue.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNWInt("AdvencedUse", true)
end

--

hook.Add( "PlayerSwitchWeapon", "dbt.wep.check", function( player, oldWeapon, newWeapon )

end )

function ENT:Use(activator)
	self:Remove() 
	activator:Give(self:GetNWString("Weapon"))
end

