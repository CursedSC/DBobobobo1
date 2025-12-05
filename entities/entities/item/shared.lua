ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Item"
ENT.Spawnable = false
ENT.Catagory = "Dev"


function ENT:Draw(f)
	self:DrawModel(f)
	
end