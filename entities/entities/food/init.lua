AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("dbt.AddEvidence")

function ENT:Initialize()
	self:SetModel( "models/props_everything/pancake1.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

end




function ENT:Use(activator)
	if activator:GetNWInt("INTERACTIONOO") == 2 then
		if #activator.items >= 6 then
			netstream.Start(activator, "dbt/inventory/error", "Недостаточно места в инвентаре!")
			return
		end

		dbt.inventory.additem(activator, self:GetNWInt("_id"), {mt = true, poisoned = self:GetNWBool("poisoned")})
		self:Remove()
		return
	end

	if activator:GetNWInt("INTERACTIONOO") == 3 then
		self:SetNWBool("poisoned", true)
		return
	end

	if activator:GetNWInt("INTERACTIONOO") == 1 then
		if self:GetNWInt("_id") == 13 and not timer.Exists("can'tcofee"..activator:Name()) then
			if self:GetNWBool("poisoned") == true then activator:Kill() return end
			activator:SetNWInt("sleep", activator:GetNWInt("sleep") + 10)
			timer.Create("can'tcofee"..activator:Name(), 3600, 1, function()

			end)
		end

		if dbt.inventory.items[self:GetNWInt("_id")].food then
			if activator:GetNWInt("hunger") >= 100 then activator:SetNWInt("hunger", 100) return end
			if self:GetNWBool("poisoned") == true then activator:Kill() self:Remove() return end
			activator:SetNWInt("hunger", activator:GetNWInt("hunger") + self:GetNWInt("Food"))
			self:Remove()
		else
			if activator:GetNWInt("water") >= 100 then activator:SetNWInt("water", 100) return end
			if self:GetNWBool("poisoned") == true then activator:Kill() return end
			activator:SetNWInt("water", activator:GetNWInt("water") + self:GetNWInt("Water"))
			self:Remove()
		end
	end
end
