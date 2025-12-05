AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("dbt.Sign")
util.AddNetworkString("dbt.Sig.Create")
function ENT:Initialize()
	self:SetModel( "models/props_lab/clipboard.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.LastUse = CurTime()
	self.name = self.name or 'НАЗВАНИЕ ЗАПИСКИ'
	self.desc = self.text or {[1] = 'Начало записи.'}
end


function ENT:Use(activator)

	if self.LastUse < CurTime() then
	self.LastUse = CurTime() + 1

	netstream.Start(activator, 'dbt/newnotes', self.name, self.desc, self)

	--net.Start("dbt.Sign")
		--net.WriteEntity(self)
		--net.WriteString(self.text)
	--net.Send(activator)

	end
end

netstream.Hook('dbt/newnotes/savebtn', function(ply, ent, title, page)
	ent.name = title
	ent.desc = page
end)
