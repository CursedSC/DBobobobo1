dbt.chat_m = {}
dbt.chat_m.all = {}
util.AddNetworkString("dbt/chat/recive")
util.AddNetworkString("dbt/chat/recive/self")
net.Receive("dbt/chat/recive", function(len, ply)
	local character = net.ReadString()
	local massege = net.ReadString()

	if character == "chat" then 
		dbt.chat_m.all[#dbt.chat_m.all + 1] = {
			own = ply:GetNWString("MonoOwner"),
			massege = massege,
			all = true
		}
		local tbl_send = {
			character = ply:GetNWString("MonoOwner"),
			massege = massege,
			all = true
		}
		net.Start("dbt/chat/recive")
		net.WriteTable(tbl_send)
		net.Broadcast()	
	else 
		local clinet_2 = util.s_FindPlayer(character)
		if not IsValid(clinet_2) then return end
		local tbl_send = {
			character = ply:GetNWString("MonoOwner"),
			massege = massege,
			all = false
		}


		if not ply.info.monopad.meta.chat then ply.info.monopad.meta.chat = {} ply.info.monopad.meta.chat_m = {} ply.info.monopad.meta.chat[clinet_2:GetNWString("MonoOwner")] = {} ply.info.monopad.meta.chat_m[clinet_2:GetNWString("MonoOwner")] = true end
		if not ply.info.monopad.meta.chat[clinet_2:GetNWString("MonoOwner")] then ply.info.monopad.meta.chat[clinet_2:GetNWString("MonoOwner")] = {} ply.info.monopad.meta.chat_m[clinet_2:GetNWString("MonoOwner")] = true end
		ply.info.monopad.meta.chat[clinet_2:GetNWString("MonoOwner")][#ply.info.monopad.meta.chat[clinet_2:GetNWString("MonoOwner")] + 1] = {
			own = ply:GetNWString("MonoOwner"),
			msg = massege,
			all = false
		}

		if not clinet_2.info.monopad.meta.chat then clinet_2.info.monopad.meta.chat = {} clinet_2.info.monopad.meta.chat_m = {} clinet_2.info.monopad.meta.chat[ply:GetNWString("MonoOwner")] = {} clinet_2.info.monopad.meta.chat_m[ply:GetNWString("MonoOwner")] = true end
		if not clinet_2.info.monopad.meta.chat[clinet_2:GetNWString("MonoOwner")] then clinet_2.info.monopad.meta.chat[ply:GetNWString("MonoOwner")] = {} clinet_2.info.monopad.meta.chat_m[ply:GetNWString("MonoOwner")] = true end
		clinet_2.info.monopad.meta.chat[ply:GetNWString("MonoOwner")][#clinet_2.info.monopad.meta.chat[ply:GetNWString("MonoOwner")] + 1] = {
			own = ply:GetNWString("MonoOwner"),
			msg = massege,
			all = false
		}
		netstream.Start(ply, "dbt/chat/recive/self", tbl_send, character)

		net.Start("dbt/chat/recive")
		net.WriteTable(tbl_send)
		net.Send(clinet_2)
	end
end)