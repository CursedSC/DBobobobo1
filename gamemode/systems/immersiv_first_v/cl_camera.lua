hook.Add( "HUDPaint", "ToScreenExample", function()
--[[
	local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
	if IsValid(tr.Entity) then
		for i = 0, tr.Entity:GetBoneCount() - 1 do
			local data2D = tr.Entity:GetBonePosition(i):ToScreen()
			if ( not data2D.visible ) then continue end
			

			draw.SimpleText( i, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end]]

end )


