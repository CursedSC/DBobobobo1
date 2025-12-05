
TOOL.Category		= "DBT Tools"
TOOL.Name			= "Настройка суда"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.curtime = CurTime()

if SERVER then 
	last_stoyka = nil
	netstream.Hook("dbt.SpawnCT", function(ply, x, y, z)
		if IsValid(last_stoyka) then last_stoyka:Remove() end
		local button = ents.Create( "prop_physics" )
		button:SetPos( Vector( x, y, z ) )
		button:SetModel( "models/drp_props/podium_classroomtest.mdl" )
		button:Spawn()
		button:SetMoveType( MOVETYPE_NONE )
		last_stoyka = button
	end)
end

if CLIENT then

	show_ct_pos = false
	show_ct_pos_sp = false

end

	local function ToDefault()
		normal_camera_position[game.GetMap()] = {
		    x = -200, 
		    y = -2500,
		    z = -890,
		    anim = {
		        hidht = {
		            st = -760,
		            ed = -780
		        }
		    },
		    monokuma = {
		        vec = Vector( -426, -2404, -849 ), 
		        vec_sp = Vector(-527.722717, -2354.135254, -821.366455),
		        adi = 1,
		        plus = 2
		    },
		    add_dist = 100,
		    acd = 0,
		}

	    GPS_POS = {}
		local tbl = normal_camera_position[game.GetMap()]
		local segmentdist = 17 / ( 2 * math.pi * math.max( 100, 100 ) / 2 )
		for a = 0, 18 do
		    local acd = a * -22.5 + tbl.acd
		    local pos_ = Vector(tbl.x + math.cos( math.rad( acd ) ) * tbl.add_dist, tbl.y - math.sin( math.rad( acd ) ) * tbl.add_dist, normal_camera_position[game.GetMap()].z ) --tbl.x + math.cos( math.rad( a + segmentdist ) ) * 100, tbl.y - math.sin( math.rad( a + segmentdist ) ) * 100
		    GPS_POS[a + 2] = pos_
		end
    	normal_camera_position[game.GetMap()].anim.hidht.st = normal_camera_position[game.GetMap()].z + 130
    	normal_camera_position[game.GetMap()].anim.hidht.ed = normal_camera_position[game.GetMap()].z + 110
    	
		net.Start("dbt/classtrial/update")
			net.WriteTable(GPS_POS)
			net.WriteTable(normal_camera_position)
		net.SendToServer()

	pos_x:SetValue(normal_camera_position[game.GetMap()].x)
	pos_y:SetValue(normal_camera_position[game.GetMap()].y)
	pos_z:SetValue(normal_camera_position[game.GetMap()].z)
	add_dist:SetValue(normal_camera_position[game.GetMap()].add_dist)
	acd_slider:SetValue( normal_camera_position[game.GetMap()].acd )

	end

	local function rebuild_classtriasl()
	    GPS_POS = {}
		local tbl = normal_camera_position[game.GetMap()]
		local segmentdist = 16 / ( 2 * math.pi * math.max( 100, 100 ) / 2 )
		for a = 0, 15 do
		    local acd = a * -22.5 + tbl.acd
		    local pos_ = Vector(tbl.x + math.cos( math.rad( acd ) ) * tbl.add_dist, tbl.y - math.sin( math.rad( acd ) ) * tbl.add_dist, normal_camera_position[game.GetMap()].z ) --tbl.x + math.cos( math.rad( a + segmentdist ) ) * 100, tbl.y - math.sin( math.rad( a + segmentdist ) ) * 100
		    GPS_POS[a + 2] = pos_
		end
    	normal_camera_position[game.GetMap()].anim.hidht.st = normal_camera_position[game.GetMap()].z + 130
    	normal_camera_position[game.GetMap()].anim.hidht.ed = normal_camera_position[game.GetMap()].z + 110
    	
		net.Start("dbt/classtrial/update")
			net.WriteTable(GPS_POS)
			net.WriteTable(normal_camera_position)
		net.SendToServer()

		pos_x:SetValue(normal_camera_position[game.GetMap()].x)
		pos_y:SetValue(normal_camera_position[game.GetMap()].y)
		pos_z:SetValue(normal_camera_position[game.GetMap()].z)
		add_dist:SetValue(normal_camera_position[game.GetMap()].add_dist)
		acd_slider:SetValue( normal_camera_position[game.GetMap()].acd )

	end
function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	if self.curtime >= CurTime() then return end

	if CLIENT then
		local vec = trace.HitPos

		normal_camera_position[game.GetMap()].x = vec.x
		normal_camera_position[game.GetMap()].y = vec.y
		normal_camera_position[game.GetMap()].z = vec.z + 60
		
		rebuild_classtriasl()

		if spawn_st_b then 
			netstream.Start("dbt.SpawnCT", vec.x, vec.y, vec.z)
		end
		self.curtime = CurTime() + 1
	end

	return true
end

function TOOL:RightClick( trace )
	local ply = self:GetOwner()
	if CLIENT then  
		local vec = trace.HitPos 

		normal_camera_position[game.GetMap()].monokuma.vec_sp = vec + Vector(0,0,65)


        local tbl = normal_camera_position[game.GetMap()]
        local vec = tbl.monokuma.vec_sp 
		local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180 + 90
		local dist = Vector( tbl.x, tbl.y, tbl.z ):Distance(normal_camera_position[game.GetMap()].monokuma.vec_sp) - 100
		local a = math.rad( ( cool / 366 ) * -360 )

		normal_camera_position[game.GetMap()].monokuma.vec = Vector(tbl.x + math.sin( a ) * dist, tbl.y + math.cos( a ) * dist, vec.z - 35)

		net.Start("dbt/classtrial/update")
			net.WriteTable(GPS_POS)
			net.WriteTable(normal_camera_position)
		net.SendToServer()
		self.curtime = CurTime() + 1

	end


	
	return true
end

function TOOL:Think()

end

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
end


function TOOL.BuildCPanel( panel )

	panel:AddControl( "Header", { Text = "Настройка суда", Description = "Здесь вы можете более тотечно настроить суд. ПКМ - создать кастомное место для ведущего" } )
	

	local spawn_st = vgui.Create( "DCheckBoxLabel" ) 
	spawn_st:SetPos( panel:GetWide(), 50 )						
	spawn_st:SetText("Ставить кастомную стойку")							
	spawn_st:SetValue( show_ct_pos )	
	spawn_st:SetDark(true)			
	spawn_st:SizeToContents()	
	function spawn_st:OnChange( val )
		spawn_st_b = val
	end
	panel:AddPanel(spawn_st)

	local show_ct_pos_val = vgui.Create( "DCheckBoxLabel" ) 
	show_ct_pos_val:SetPos( panel:GetWide(), 50 )						
	show_ct_pos_val:SetText("Показывать места на суде")							
	show_ct_pos_val:SetValue( show_ct_pos )	
	show_ct_pos_val:SetDark(true)			
	show_ct_pos_val:SizeToContents()	
	function show_ct_pos_val:OnChange( val )
		show_ct_pos = val
	end
	panel:AddPanel(show_ct_pos_val)

	local show_ct_pos_val_sp = vgui.Create( "DCheckBoxLabel" ) 
	show_ct_pos_val_sp:SetPos( panel:GetWide(), 50 )						
	show_ct_pos_val_sp:SetText("Использовать спрайты")							
	show_ct_pos_val_sp:SetValue( show_ct_pos_sp )				
	show_ct_pos_val_sp:SizeToContents()	
	show_ct_pos_val_sp:SetDark(true)	
	function show_ct_pos_val_sp:OnChange( val )
		show_ct_pos_sp = val
		if not show_ct_pos then 
			show_ct_pos = true
			show_ct_pos_val:SetValue( show_ct_pos )	
		end
	end
	panel:AddPanel(show_ct_pos_val_sp)

	pos_x = vgui.Create( "DTextEntry") -- create the form as a child of frame
	pos_x:SetUpdateOnType(true)
	pos_x:SetNumeric(true)
	pos_x:SetValue(normal_camera_position[game.GetMap()].x)
	pos_x.OnTextChanged = function( self )
		normal_camera_position[game.GetMap()].x = self:GetValue()
		rebuild_classtriasl()
	end
	panel:AddPanel(pos_x)
	
	pos_y = vgui.Create( "DTextEntry") -- create the form as a child of frame
	pos_y:SetUpdateOnType(true)
	pos_y:SetNumeric(true)
	pos_y:SetValue(normal_camera_position[game.GetMap()].y)
	pos_y.OnTextChanged = function( self )
		normal_camera_position[game.GetMap()].y = self:GetValue()
		rebuild_classtriasl()
	end
	panel:AddPanel(pos_y)

	pos_z = vgui.Create( "DTextEntry") -- create the form as a child of frame
	pos_z:SetUpdateOnType(true)
	pos_z:SetNumeric(true)
	pos_z:SetValue(normal_camera_position[game.GetMap()].z)
	pos_z.OnTextChanged = function( self )
		normal_camera_position[game.GetMap()].z = self:GetValue()
		rebuild_classtriasl()
	end
	panel:AddPanel(pos_z)

	add_dist = vgui.Create( "DTextEntry") -- create the form as a child of frame
	add_dist:SetUpdateOnType(true)
	add_dist:SetNumeric(true)
	add_dist:SetValue(normal_camera_position[game.GetMap()].add_dist)
	add_dist.OnTextChanged = function( self )
		normal_camera_position[game.GetMap()].add_dist = self:GetValue()
		rebuild_classtriasl()
	end
	panel:AddPanel(add_dist)

	acd_slider = vgui.Create( "DNumSlider")		
	acd_slider:SetSize( panel:GetWide(), 50 )		
	acd_slider:SetText( "Угол" )	
	acd_slider:SetMin( 0 )				 	
	acd_slider:SetMax( 360 )				
	acd_slider:SetDecimals( 0 )
	acd_slider:SetDark(true)				
	acd_slider:SetValue( normal_camera_position[game.GetMap()].acd )
	acd_slider.OnValueChanged = function( self, value )
		normal_camera_position[game.GetMap()].acd = value
		rebuild_classtriasl()
	end
	panel:AddPanel(acd_slider)

	local def_butt = vgui.Create( "DButton") 
	def_butt:SetText( "Сбросить" )							
	def_butt.DoClick = function()		
		ToDefault()
	end
	panel:AddPanel(def_butt)
end
