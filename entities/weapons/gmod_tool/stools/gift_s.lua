
TOOL.Category		= "DBT Tools"
TOOL.Name			= "Подарок"
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
	self.curtime = CurTime() + 1
	if CLIENT then 
		local data, id = wep_gift:GetSelected()
		local dsata = {
	      wep = id,
		  isExplode = isEsplode:GetChecked()
    	}
        net.Start("dbt.Gift")
          net.WriteTable(dsata)
        net.SendToServer()

	end
		
	
	return true
end

function TOOL:RightClick( trace )
	local ply = self:GetOwner()
	
	if not simfphys.IsCar( ent ) then return false end
	
	if CLIENT then return true end

	
	return true
end

function TOOL:Think()

end

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	--
end


function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "Создание подарков", Description = "Вставьте название оружия" } )
	itemId = 5
	wep_gift = vgui.Create( "DComboBox" ) 
	wep_gift:SetValue( "Выберите предмет" )
	for k, i in pairs( dbt.inventory.items ) do
		wep_gift:AddChoice( i.name, k )
	end
	panel:AddPanel(wep_gift)

	isEsplode = vgui.Create( "DCheckBoxLabel" )
	isEsplode:SetText( "Взрывной подарок" )
	isEsplode:SetValue( 0 )
	isEsplode:SetTextColor( Color(0,0,0) )
	panel:AddPanel(isEsplode)

end
