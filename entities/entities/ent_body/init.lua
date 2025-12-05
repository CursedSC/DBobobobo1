AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("OpenBodyMenu")
util.AddNetworkString("investigation.St")
--
--
function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube05x1x025.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)       -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.adverted = false
	self.sees = {}
	self.see = 0
end


function ENT:SetKiller(sss)
		self.keller = sss
end

function ENT:SetDataTable(name, title, time, type, pos, player)
	self.data = {
    name = name,
    title = title,
    time = time,
    type = type,
    pos = pos,
		player = player,
  }
end



function ENT:Think()
	if self.adverted or not GetGlobalString("AnuceStatus") then return end
	if self.see == 1 then
		self.adverted = true
		timer.Simple(18, function()
			dbt.music.Play("investigation")
			net.Start("investigation.St")
			net.Broadcast()
		end)
	end
	for k, v in pairs( player.GetAll() ) do
		local tr = util.TraceLine( util.GetPlayerTrace( v ) )
		local ent = tr.Entity
		if ent == self then
			if v == self.keller or self.sees[v] or not InGame(v) or IsMono(v:Pers()) then return end
			self.sees[v] = true
			self.see = self.see + 1
				local ran = math.random(1, 3)
				net.Start("dbt.music.death")
				net.WriteFloat(ran)
				net.Send(v)
				net.Start("Noise.Start")
				net.WriteFloat(ran)
				net.Send(v)
		end
	end
end

function ENT:Use(activator)
  if not activator.rrr then
    activator.rrr = true
      net.Start("OpenBodyMenu")
        net.WriteTable(self.data)
      net.Send(activator)
      timer.Create("rtert", 1, 1,function() activator.rrr = false end)
  end
end
