local PANEL = {}
local dbtwoundsposition = {
	head = "Голова",
	chest = "Туловище",
	leftarm = "Левая рука",
	rightarm = "Правая рука",
	leftleg = "Левая нога",
	rightleg = "Правая нога",
}

local function weight_source(x)
    return ScreenWidth / 1920  * x
end

local function hight_source(x)
    return ScreenHeight / 1080  * x
end

local function Alpha(pr)
    return (255 / 100) * pr
end


function PANEL:Init()
	self:Dock(FILL)
	self:SetModel( "models/props_interiors/pot01a.mdl" )
	function self:LayoutEntity( Entity ) return end
end

function PANEL:FromItem(id)
	self.id = id
	local data = dbt.inventory.items[id]
	if !data then
		self:SetModel( "models/box/box.mdl" )
		local mn, mx = self.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
		size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
		size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

		self:SetFOV( 45 )
		self:SetCamPos( Vector( size, size, size ) )
		self:SetLookAt( (mn + mx) * 0.5 )
		self.Entity:SetAngles(Angle(0,0,0))
		self.IsError = true
		return
	end
	self.data = data
	self:SetModel( data.mdl )
	local mn, mx = self.Entity:GetRenderBounds()
	local size = 0
	size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
	size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
	size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

	self:SetFOV( data.fov or 45 )
	self:SetCamPos( Vector( size, size, size ) )
	self:SetLookAt( (mn + mx) * 0.5 )
	self.Entity:SetAngles(data.angle or Angle(0,0,0))
	self:Droppable("Item")
end

function PANEL:PaintOver(width, height)

end

function PANEL:ExtraPaint(width, height)

end

function PANEL:DoClick()
	if self.IsError then return end
	ShowItemData(self, self.id, 0)
end

function PANEL:OnCursorEntered()

end

function PANEL:PaintEH( w, h )

	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = ( self.vLookatPos - self.vCamPos ):Angle()
	end

	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
	render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
	render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()

	for i = 0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end

	self:DrawModel()

	render.SuppressEngineLighting( false )
	cam.End3D()

	self.LastPaint = RealTime()

end
function PANEL:OverPaint(w, h)

end


function PANEL:EatPaint(w, h)
	draw.RoundedBox( 10, 0, 0, w, h, Color(0,0,0,150) )
	local ang = 360 - (timer.TimeLeft("EatInv") / self.seconds) * 360
    self.TimerCircle:SetEndAngle(ang)
    self.TimerCircle:SetPos(w / 2, h / 2)
    self.TimerCircle.m_Material = true
    self.TimerCircle()
end

function PANEL:DoEatEvent(position)
	if timer.Exists("EatInv") then return end
	self.seconds = self.data.time and 5 or 1
	if LocalPlayer():GetNWInt("water") >= 100 then

	notifications_new(3, {
        icon = 'materials/dbt/notifications/notifications_main.png',
        title = "Уведомление",
        titlecolor = Color(222, 193, 49),
        notiftext = "Вы не можете это выпить, вы не хотите пить."
    })

	return end
	if LocalPlayer():GetNWInt("hunger") >= 100 then

	notifications_new(3, {
        icon = 'materials/dbt/notifications/notifications_main.png',
        title = "Уведомление",
        titlecolor = Color(222, 193, 49),
        notiftext = "Вы не можете это съесть, вы не хотите есть."
    })

	return end
	self.Eating = true
	LocalPlayer():EmitSound( "inv_use.mp3" )
	position = position and position or ""

	timer.Create("EatInv", self.seconds + 0.1, 1, function()
  	    self.Eating = false
		netstream.Start("dbt/inventory/eat", self.idInv, position)

		table.remove(dbt.inventory.player, self.idInv)
		self:GetParent().IsEmpty = true
		LocalPlayer():StopSound( "inv_use.mp3" )
		self:Remove()
  	end)

  	self.TimerCircle = circles.New(CIRCLE_OUTLINED, 23, 1, 1, weight_source(8))
	self.TimerCircle:SetColor(Color(255, 255, 255, 255) )
	self.TimerCircle:SetEndAngle(1)
end

function PANEL:DoMedicineEvent(position)
	if timer.Exists("EatInv") then return end
	LocalPlayer():EmitSound( "inv_use.mp3" )
	self.Eating = true
	self.seconds = 5
	position = position and position or ""

	timer.Create("EatInv", self.seconds + 0.1, 1, function()
  	    self.Eating = false
		netstream.Start("dbt/inventory/use", self.idInv, {position = position})
		if self.data.OnRemove and self.data.OnRemove(LocalPlayer(), self.data, self.meta, {}) then
			table.remove(dbt.inventory.player, self.idInv)
			self:GetParent().IsEmpty = true
			self:Remove()
		elseif !self.data.bNotDeleteOnUse then
			table.remove(dbt.inventory.player, self.idInv)
			self:GetParent().IsEmpty = true
			self:Remove()
		end
		LocalPlayer():StopSound( "inv_use.mp3" )
  	end)

  	self.TimerCircle = circles.New(CIRCLE_OUTLINED, 23, 1, 1, weight_source(8))
	self.TimerCircle:SetColor(Color(255, 255, 255, 255) )
	self.TimerCircle:SetEndAngle(1)
end

function PANEL:DoRightClick()
	if self.IsError then
		local menu = DermaMenu()
		menu:AddOption( "Удали меня!", function()
			netstream.Start("dbt/inventory/remove/bug", self.kkk)
			self:Remove()
		end)
		menu:Open()
		return
	end
	local menu = DermaMenu()
	if self.data.medicine then
		if self.data.id == 37 then
			menu:AddOption( "Лечение", function()
				self:DoMedicineEvent(v)
			end)
		elseif self.data.id == 42 or self.data.id == 43 then
			menu:AddOption( "Использовать на себе", function()
				self:DoMedicineEvent(v)
			end)
		else
			local newmenu = menu:AddSubMenu("Лечение")
			for k, v in pairs(dbtwoundsposition) do
				newmenu:AddOption(v,function ()
					self:DoMedicineEvent(v)
				end)
			end
		end
	end
	if self.data.time and (self.data.water or self.data.food) then
		menu:AddOption( "Употребить", function()
			self:DoEatEvent()
		end)
	end
	if self.data.ammo then 
		menu:AddOption( "Распокавать пачку", function()
			netstream.Start("dbt/inventory/use", self.idInv)
		end)
	end
	menu:Open()
end

function PANEL:Paint(w, h)
	--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0, 255))
	self:ExtraPaint(w, h)
	self:PaintEH(w, h)
	self:OverPaint(w, h)
	if self.Eating then self:EatPaint(w, h) end
end

vgui.Register("DItem", PANEL, "DModelPanel")
