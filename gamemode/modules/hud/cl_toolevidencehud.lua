local l_SetDrawColor = surface.SetDrawColor
local tblforhalo = {}
local enttablehalo = {}
local function GetENTPos( Ent )
    if Ent:IsValid() then
        local Points = {
            Vector( Ent:OBBMaxs().x, Ent:OBBMaxs().y, Ent:OBBMaxs().z ),
            Vector( Ent:OBBMaxs().x, Ent:OBBMaxs().y, Ent:OBBMins().z ),
            Vector( Ent:OBBMaxs().x, Ent:OBBMins().y, Ent:OBBMins().z ),
            Vector( Ent:OBBMaxs().x, Ent:OBBMins().y, Ent:OBBMaxs().z ),
            Vector( Ent:OBBMins().x, Ent:OBBMins().y, Ent:OBBMins().z ),
            Vector( Ent:OBBMins().x, Ent:OBBMins().y, Ent:OBBMaxs().z ),
            Vector( Ent:OBBMins().x, Ent:OBBMaxs().y, Ent:OBBMins().z ),
            Vector( Ent:OBBMins().x, Ent:OBBMaxs().y, Ent:OBBMaxs().z )
        }
        local MaxX, MaxY, MinX, MinY
        local V1, V2, V3, V4, V5, V6, V7, V8
        local isVis
        for k, v in pairs( Points ) do
            local ScreenPos = Ent:LocalToWorld( v ):ToScreen()
            isVis = ScreenPos.visible
            if MaxX != nil then
                MaxX, MaxY, MinX, MinY = math.max( MaxX, ScreenPos.x ), math.max( MaxY, ScreenPos.y), math.min( MinX, ScreenPos.x ), math.min( MinY, ScreenPos.y)
            else
                MaxX, MaxY, MinX, MinY = ScreenPos.x, ScreenPos.y, ScreenPos.x, ScreenPos.y
            end

            if V1 == nil then
                V1 = ScreenPos
            elseif V2 == nil then
                V2 = ScreenPos
            elseif V3 == nil then
                V3 = ScreenPos
            elseif V4 == nil then
                V4 = ScreenPos
            elseif V5 == nil then
                V5 = ScreenPos
            elseif V6 == nil then
                V6 = ScreenPos
            elseif V7 == nil then
                V7 = ScreenPos
            elseif V8 == nil then
                V8 = ScreenPos
            end
        end
        return MaxX, MaxY, MinX, MinY, V1, V2, V3, V4, V5, V6, V7, V8, isVis
    end
end

hook.Add("HUDPaint", "dbt/hud/evidencetool", function()
	local ply = LocalPlayer()

	if ply:GetTool() and ply:GetTool().Name == "Улика" then
		for _, ent in ipairs( ents.FindByClass( "evidence" ) ) do

			local point = ent:GetPos() + ent:OBBCenter()
			local data2D = point:ToScreen()

			if ( not data2D.visible ) then continue end


			draw.SimpleText( ent:GetNWString("esp_name"), "Default", data2D.x, data2D.y- 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			l_SetDrawColor( 255, 255, 255, 128 )
			surface.DrawOutlinedRect( data2D.x - 25, data2D.y - 25, 50, 50, 2 )
		end
	end

	if LocalPlayer():GetNWBool("ESPMODE") then
        for _, ent in ipairs( ents.FindByClass( "evidence" ) ) do
            local point = ent:GetPos() + ent:OBBCenter()
            local data2D = point:ToScreen()

            if ( not data2D.visible ) then continue end
            draw.SimpleText( ent:GetNWString("esp_name"), "Default", data2D.x, data2D.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
end)

hook.Add("HUDPaint", "dbt/hud/clickableproptool",function ()
	local ply = LocalPlayer()
	if GDown then
		for _, ent in pairs(ents.FindByClass("clickableprop")) do
			if ent:GetPos():Distance(ply:GetPos()) >= 150 then enttablehalo[ent:EntIndex()] = nil return end
			enttablehalo[ent:EntIndex()] = ent
		end
	end
	if !GDown then
		enttablehalo = {}
	end

	if clickchange == true then
		if dbt.clientclickableproplist then
			tblforhalo = dbt.clientclickableproplist
		end
	else
		if tblforhalo then
			tblforhalo = {}
		end
	end
end)

hook.Add( "PreDrawHalos", "AddPropHalos", function()
	if tblforhalo then
		halo.Add(tblforhalo, Color(139, 12, 161, 255), 5, 5, 2 )
	end

	if enttablehalo then
		halo.Add(enttablehalo, Color(139, 12, 161, 255), 5, 5, 2 )
	end
end )
