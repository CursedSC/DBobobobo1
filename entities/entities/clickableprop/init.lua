AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.LastUse = CurTime()

end


function ENT:Use(activator)
	if self.LastUse < CurTime() then
		self.LastUse = CurTime() + 1
		netstream.Start(activator, "dbt/tools/clickableprops", self, self.texttitle, self.text)
	end
end
