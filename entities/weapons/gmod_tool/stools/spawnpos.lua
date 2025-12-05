
TOOL.Category		= "DBT Tools"
TOOL.Name			= "Начало Игры"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.curtime = CurTime()
--TOOL.ClientConVar[ "steerspeed" ] = 8
--TOOL.ClientConVar[ "fadespeed" ] = 535

if CLIENT then


end

function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	if self.curtime >= CurTime() then return end
	self.curtime = CurTime() + 0.1
	--teleportpos[#teleportpos+1] = trace.HitPos
	if ply.manualspwn then  
		teleportpos[#teleportpos+1] = trace.HitPos
	else
		teleportpos = {}
		local segmentdist = 16 / ( 2 * math.pi * math.max( 100, 100 ) / 2 )
		for a = 1, 17 do
		    local acd = a * -22.5 + 0
		    local pos_ = Vector(trace.HitPos.x + math.cos( math.rad( acd ) ) * math.random(50, 170), trace.HitPos.y - math.sin( math.rad( acd ) ) *100, trace.HitPos.z ) --tbl.x + math.cos( math.rad( a + segmentdist ) ) * 100, tbl.y - math.sin( math.rad( a + segmentdist ) ) * 100
		    teleportpos[#teleportpos+1] = pos_
		end
	end
	return true
end

function TOOL:RightClick( trace )
	local ply = self:GetOwner()
	if self.curtime >= CurTime() then return end
	self.curtime = CurTime() + 0.1
	for k, i in pairs(teleportpos) do 
		if i:Distance(trace.HitPos) <= 50 then 
			table.remove( teleportpos, k )
			return
		end
		
	end

	return true
end

function TOOL:Think()

end 

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	teleportpos = {}
	if ply:KeyDown(IN_USE) then  
		SetClassicPosSpawn()
	end
end


function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "Управление спавном", Description = "Инструмент предназачен для настройки спавна игроков в начале игры. \nЛКМ - Поставить\nПКМ - Удалить\nR - Сбросить\nE + R - По умолчанию" } )
	WEP_tool = ""

	local spawn_st = vgui.Create( "DCheckBoxLabel" ) 
	spawn_st:SetPos( panel:GetWide(), 50 )						
	spawn_st:SetText("Ручная расстановка")							
	spawn_st:SetValue( show_ct_pos )	
	spawn_st:SetDark(true)			
	spawn_st:SizeToContents()	
	function spawn_st:OnChange( val )
		netstream.Start("dbt/changemod/spawnpos", val)
		LocalPlayer().manualspwn = val
	end
	panel:AddPanel(spawn_st)

end

netstream.Hook("dbt/changemod/spawnpos", function(ply, bo)
	ply.manualspwn = bo
end)
