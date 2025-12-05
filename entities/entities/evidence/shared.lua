ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Улика[NOT SPAWN]"
ENT.Spawnable = false
ENT.Category = "DBT - Entity"

local triangle1 = Material("triangle1.png")
local draw_funcs = {
	[1] = function(self ,att_ent, dist)
		local att_ent = tonumber(att_ent)
		if att_ent == 1 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (230 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		elseif att_ent == 2 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (120 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		end
	end,
	[2] = function(self ,att_ent, dist)
		local att_ent = tonumber(att_ent)
		if att_ent == 1 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (230 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		elseif att_ent == 2 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (180 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		elseif att_ent == 3 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (120 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		end
	end,
	[3] = function(self ,att_ent, dist)
		local att_ent = tonumber(att_ent)
		if att_ent <= 2 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (230 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		elseif att_ent == 3 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (180 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		elseif att_ent == 4 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (120 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		end
	end,
	[4] = function(self ,att_ent, dist)
		local att_ent = tonumber(att_ent)
		if att_ent <= 3 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (230 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		elseif att_ent == 4 then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
					surface.SetDrawColor( 255, 255, 255, (180 - dist)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
			cam.End3D2D()
		end
	end,
	[5] = function(self ,att_ent, dist)

		cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
				surface.SetDrawColor( 255, 255, 255, (230 - dist)) --  + 150 * math.cos(CurTime() * 2)
				surface.SetMaterial( Material("icons/159.png") )
				surface.DrawTexturedRectRotated(0,0,16,16,-90)
		cam.End3D2D()

	end,
}
function ENT:Draw()

	local mins, maxs = self:GetModelBounds()
	local pos = self:GetPos() + Vector( 0, 0, maxs.z + 2 )
	local tb = dbt.chr[LocalPlayer():Pers()]
	if not LocalPlayer():Pers() then return end
	if not dbt.chr[LocalPlayer():Pers()] then return end
	local att = dbt.chr[LocalPlayer():Pers()].attentiveness
	if not att then return end
	local att_ent = self:GetNWString("att")
	local ang = -2 * LocalPlayer():GetAngles() 
	if not tonumber(att_ent) then return end
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())



	if (GDown or IsMono(LocalPlayer():Pers()) or LocalPlayer():GetUserGroup() == "gm") and dist <= 230 then

		if LocalPlayer():GetUserGroup() == "gm" or IsMono(LocalPlayer():Pers()) then 
			cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
	

				if not self:GetNWBool("medic") then
					surface.SetDrawColor( 255, 255, 255, (255)) 
					surface.SetMaterial( Material("icons/159.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
				else
					surface.SetDrawColor( 255, 255, 255, (255)) --  + 150 * math.cos(CurTime() * 2)
					surface.SetMaterial( Material("icons/160.png") )
					surface.DrawTexturedRectRotated(0,0,16,16,-90)
				end

			cam.End3D2D()
			return
		end

		if not self:GetNWBool("medic") and draw_funcs[att] then
			draw_funcs[att](self ,att_ent, dist)
		else
			if tb.med_inv then
				cam.Start3D2D( self:GetPos() + Vector(0,0,0), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.3 )
						surface.SetDrawColor( 255, 255, 255, (230 - dist)) --  + 150 * math.cos(CurTime() * 2)
						surface.SetMaterial( Material("icons/160.png") )
						surface.DrawTexturedRectRotated(0,0,16,16,-90)
				cam.End3D2D()
			end
		end
	end
end