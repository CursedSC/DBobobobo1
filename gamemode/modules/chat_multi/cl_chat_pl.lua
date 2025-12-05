dbt.chat_m = {}
dbt.chat_m_msg = {}

net.Receive("dbt/chat/recive", function(ply)
	local rec_tbl = net.ReadTable()

	if rec_tbl.all then
		if not dbt.inventory.info.monopad.meta then dbt.inventory.info.monopad.meta = {} end
		if not dbt.inventory.info.monopad.meta.chat then
			dbt.inventory.info.monopad.meta.chat = {}
			dbt.inventory.info.monopad.meta.chat_m = {}
			dbt.inventory.info.monopad.meta.chat["chat"] = {}
			dbt.inventory.info.monopad.meta.chat_m["chat"] = true
		end
		if not dbt.inventory.info.monopad.meta.chat["chat"] then
			dbt.inventory.info.monopad.meta.chat["chat"] = {}
			dbt.inventory.info.monopad.meta.chat_m["chat"] = true
		end



		dbt.inventory.info.monopad.meta.chat["chat"][#dbt.inventory.info.monopad.meta.chat["chat"] + 1] = {
			own = rec_tbl.character,
			msg = rec_tbl.massege,
		}

		dbt.inventory.info.monopad.meta.chat_m["chat"] = true

	else
		if not dbt.inventory.info.monopad.meta.chat then
			dbt.inventory.info.monopad.meta.chat = {}
			dbt.inventory.info.monopad.meta.chat_m = {}
			dbt.inventory.info.monopad.meta.chat[rec_tbl.character] = {}
			dbt.inventory.info.monopad.meta.chat_m[rec_tbl.character] = true
		end
		if not dbt.inventory.info.monopad.meta.chat[rec_tbl.character] then
			dbt.inventory.info.monopad.meta.chat[rec_tbl.character] = {}
			dbt.inventory.info.monopad.meta.chat_m[rec_tbl.character] = true
		end



		dbt.inventory.info.monopad.meta.chat[rec_tbl.character][#dbt.inventory.info.monopad.meta.chat[rec_tbl.character] + 1] = {
			own = rec_tbl.character,
			msg = rec_tbl.massege,
		}

		dbt.inventory.info.monopad.meta.chat_m[rec_tbl.character] = true

		timer.Simple(300, function()
		    if dbt.inventory and dbt.inventory.info and dbt.inventory.info.monopad and dbt.inventory.info.monopad.meta and dbt.inventory.info.monopad.meta.chat_m and dbt.inventory.info.monopad.meta.chat_m[rec_tbl.character] then
		        dbt.inventory.info.monopad.meta.chat_m[rec_tbl.character] = false
		    end
		end)
		local globaltime = GetGlobalInt("Time")
    	local    s = globaltime % 60
    	local    tmp = math.floor( globaltime / 60 )
    	local    m = tmp % 60
    	local    tmp = math.floor( tmp / 60 )
    	local    h = tmp % 24
    	local curtimesys = string.format( "%02i:%02i", h, m)

		MSG_SENDER = rec_tbl.character
		MSG_TIME = curtimesys
		MSG_bool = (utf8.len(rec_tbl.massege) > 85)
		MSG_TEXT = utf8.sub(rec_tbl.massege, 1, 85)
		see_msg = true
		see_r = false
		MSG_CAN_LERP1 = false
		MSG_ALPHA1 = 255
		MSG_ALPHA2 = weight_source(1080 - 984)
		timer.Remove("MSG1")
		timer.Create("MSG", 2.5, 1, function()
		    MSG_CAN_LERP1 = true
		    timer.Create("MSG1", 2, 1, function() see_msg = false end)
		end)
	end


	if ACTIVE_CHR and IsValid(DScrollPanel__S) then
		BuildChat(DScrollPanel__S, dbt.inventory.info.monopad.meta.chat[ACTIVE_CHR])
	end
	surface.PlaySound("ui/ui_but/ui_hover.wav")
end)

net.Receive("dbt/chat/recive/self", function(ply)
	local rec_tbl = net.ReadTable()
	local chr = net.ReadString()
	if not dbt.inventory.info.monopad.meta.chat then
		dbt.inventory.info.monopad.meta.chat = {}
		dbt.inventory.info.monopad.meta.chat_m = {}
		dbt.inventory.info.monopad.meta.chat[chr] = {}
		dbt.inventory.info.monopad.meta.chat_m[chr] = true
	end
	if not dbt.inventory.info.monopad.meta.chat[chr] then
		dbt.inventory.info.monopad.meta.chat[chr] = {}
		dbt.inventory.info.monopad.meta.chat_m[chr] = true
	end
	dbt.inventory.info.monopad.meta.chat[chr][#dbt.inventory.info.monopad.meta.chat[chr] + 1] = {
		own = rec_tbl.character,
		msg = rec_tbl.massege,
	}

	if ACTIVE_CHR and IsValid(DScrollPanel__S) then
		BuildChat(DScrollPanel__S, dbt.inventory.info.monopad.meta.chat[ACTIVE_CHR])
	end
end)

netstream.Hook("dbt/chat/recive/self", function(rec_tbl, chr)
	if not dbt.inventory.info.monopad.meta.chat then
		dbt.inventory.info.monopad.meta.chat = {}
		dbt.inventory.info.monopad.meta.chat_m = {}
		dbt.inventory.info.monopad.meta.chat[chr] = {}
		dbt.inventory.info.monopad.meta.chat_m[chr] = true
	end
	if not dbt.inventory.info.monopad.meta.chat[chr] then
		dbt.inventory.info.monopad.meta.chat[chr] = {}
		dbt.inventory.info.monopad.meta.chat_m[chr] = true
	end
	dbt.inventory.info.monopad.meta.chat[chr][#dbt.inventory.info.monopad.meta.chat[chr] + 1] = {
		own = rec_tbl.character,
		msg = rec_tbl.massege,
	}

	if ACTIVE_CHR and IsValid(DScrollPanel__S) then
		BuildChat(DScrollPanel__S, dbt.inventory.info.monopad.meta.chat[ACTIVE_CHR])
	end
end)

--standart chat removes
hook.Remove("ChatText", "CHAT_dbt_joinleave")
hook.Remove("ChatText", "vrutil_hook_chattext")
hook.Add( "ChatText", "dbt.ChatText.relay", function( index, name, text, type )
  if type == "joinleave" then
    return false
  end
end )
