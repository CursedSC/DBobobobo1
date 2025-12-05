local lerp_msg_door = 0
local lerp_msg_door_out = false
local l_DrawText = draw.DrawText

hook.Add("HUDPaint", "dbt/hud/doors", function()
	local ply = LocalPlayer()
	if ply:GetNWBool("HasNoMonoDoor") then
		if lerp_msg_door > 200 then
			lerp_msg_door_out = true
		end
		if lerp_msg_door_out then
			lerp_msg_door = Lerp(FrameTime() * 2, lerp_msg_door, 0)
		else
			lerp_msg_door = Lerp(FrameTime(), lerp_msg_door, 255)
		end
		l_DrawText("Вы не можете открыть дверь без монопада", "DermaLarge", ScreenWidth / 2, ScreenHeight / 2, Color(255,255,255, lerp_msg_door), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ply:GetNWBool("HasNoFEMALEDoor") then
		if lerp_msg_door > 200 then
			lerp_msg_door_out = true
		end
		if lerp_msg_door_out then
			lerp_msg_door = Lerp(FrameTime() * 2, lerp_msg_door, 0)
		else
			lerp_msg_door = Lerp(FrameTime(), lerp_msg_door, 255)
		end
		l_DrawText("Вы не можете открыть дверь в женскую раздевалку", "DermaLarge", ScreenWidth / 2, ScreenHeight / 2, Color(255,255,255, lerp_msg_door), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ply:GetNWBool("HasNoMALEDoor") then
		if lerp_msg_door > 200 then
			lerp_msg_door_out = true
		end
		if lerp_msg_door_out then
			lerp_msg_door = Lerp(FrameTime() * 2, lerp_msg_door, 0)
		else
			lerp_msg_door = Lerp(FrameTime(), lerp_msg_door, 255)
		end
		l_DrawText("Вы не можете открыть дверь в мужскую раздевалку", "DermaLarge", ScreenWidth / 2, ScreenHeight / 2, Color(255,255,255, lerp_msg_door), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		lerp_msg_door = 0
		lerp_msg_door_out = false
	end
end)
