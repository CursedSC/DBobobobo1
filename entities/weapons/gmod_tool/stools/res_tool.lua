
TOOL.Category		= "DBT Tools"
TOOL.Name			= "Размер игрока"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.curtime = CurTime()
--TOOL.ClientConVar[ "steerspeed" ] = 8
--TOOL.ClientConVar[ "fadespeed" ] = 535

if CLIENT then


end


function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	local ent = trace.Entity
	if self.curtime >= CurTime() then return end
	if not ent or not ent:IsPlayer() then return end
	netstream.Start("dbt/player/res", ent, TOOL_res)
	
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
	lvl = panel:AddControl( "slider", {type 	= "float", min = 0.1, max = 2, label = 'Размер'})
	lvl.OnValueChanged = function( self, value )
		TOOL_res = value 
	end

end
