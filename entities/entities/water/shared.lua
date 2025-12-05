ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Вода"
ENT.Spawnable = false
ENT.Category = "DBT - Entity"

function ENT:Draw()
	self:DrawModel()
end