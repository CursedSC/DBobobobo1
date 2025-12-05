ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Clickable Prop"
ENT.Spawnable = false
ENT.Catagory = "Dev"


function ENT:Draw(f)
	self:DrawModel(f)
	
end
