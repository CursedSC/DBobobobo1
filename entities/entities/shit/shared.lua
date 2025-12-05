ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Тесто"
ENT.Spawnable = true
ENT.Category = "DBT - Entity"

function ENT:Draw(f)
	self:DrawModel(f)
end