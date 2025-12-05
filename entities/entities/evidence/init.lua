AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("dbt.AddEvidence")

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)         -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false) -- keep evidence in place but still weldable
	end

	self.whouse = {}

end

function ENT:CanTool(ply, trace, tool)
	if tool == "weld" then return true end
	return false
end

function ENT:SetItem(data)
	self:SetNWString("esp_name", data.name)
	self:SetNWBool("medic", data.medic)
	self:SetNWString("att", data.rank)
	self.data = data
end


local can_up = {
	[1] = function(att)
		if att <= 2 then
			return true
		else
			return false
		end
	end,
	[2] = function(att)
		if att <= 3 then
			return true
		else
			return false
		end
	end,
	[3] = function(att)
		if att <= 4 then
			return true
		else
			return false
		end
	end,
	[4] = function(att)
		if att <= 4 then
			return true
		else
			return false
		end
	end,
	[5] = function(att)
		if att <= 5 then
			return true
		else
			return false
		end
	end,
}

local glav_type = {}
glav_type["prolog"] = 1

for i = 1,6 do
    glav_type["stage_"..i] = i+1
end

glav_type["epilog"] = table.Count(glav_type)

function ENT:Use(activator)

	if not self.whouse[activator] then
		local tb = dbt.chr[activator:Pers()]
		local att = dbt.chr[activator:Pers()].attentiveness
		local att_ent = self:GetNWString("att")
		if not (IsMono(activator:Pers()) or activator:GetUserGroup() == "gm") then
			if self:GetNWBool("medic") and not tb.med_inv then return end
			if not can_up[att](att_ent) and not self:GetNWBool("medic") then return end
		end

		if not activator.info.monopad or not activator.info.monopad.meta then netstream.Start(activator, "dbt/inventory/error", "У вас нет монопада!") return end
		self.whouse[activator] = true
		self.data.ent = self
		self.data.whouse = self.whouse

		if not activator.info.monopad.meta.edv then
			activator.info.monopad.meta.edv = {}
		end
		local round = GetGlobalString("gameStatus_mono")
		activator.info.monopad.meta.edv[glav_type[round]] = activator.info.monopad.meta.edv[glav_type[round]] or {}

		table.insert(activator.info.monopad.meta.edv[glav_type[round]], self.data) 

		activator:syncInformation()

		net.Start("dbt.AddEvidence")
			net.WriteTable(self.data)
		net.Send(activator)

	end
end
