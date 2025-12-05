
netstream.Hook("dbt/unvisibleplayers/change", function(ply, playertochange, bool)
	playertochange:SetNWBool("IsVisibleScoreboard", bool)
end)

netstream.Hook("dbt/warns/add", function(ply, warn_text, warn_ply)
    local new_warn = {
        intruderid = warn_ply:SteamID(),
        name = "???",
        info = {
            admin = {
                name = ply:Name(),
                steamid = ply:SteamID()
            },
            timesnap = os.time(),
            description = warn_text
        }
    }

    socket:write("warns_add "..util.TableToJSON(new_warn))
    if player.GetBySteamID(warn_ply:SteamID()) then
        netstream.Start(player.GetBySteamID(warn_ply:SteamID()), "dbt/player/text", Color(255, 0, 0), "[WARN] Администратор "..ply:Name().." выдал вам варн по причине: "..warn_text..".")
    end
end)


netstream.Hook("dbt/warns/list/remove", function(ply, id)
	local f = file.Read( "warns.json", "DATA")
	local f = util.JSONToTable(f)
	table.remove(f, id)
	file.Write( "warns.json", util.TableToJSON(f, true))
end)


netstream.Hook("dbt/warns/list", function(ply)
	if not ply:IsAdmin() then return end

	local f = file.Read( "warns.json", "DATA")
	local f = util.JSONToTable(f)
	if #f == 0 then return end
	replications_ = 1
	timer.Create("Send_Warns"..ply:Name(), 0.1, #f, function()
		netstream.Start(ply, "dbt/warns/list/send", f[replications_], replications_)
		replications_ = replications_ + 1
	end)
end)

hook.Add("PlayerSay", 'changebg',function (ply, text)
	if string.StartsWith(text, "/changebg") then
		if not ply:IsAdmin() then netstream.Start(ply, "dbt/player/text", Color(255, 255, 255), "Отказано") return "" end
		local splittedtext = string.Split(text, " ")
		ply:SetNW2String("backgroundmatscoreboard", splittedtext[2])
		netstream.Start(ply, "dbt/player/text", Color(255, 255, 255), "Вы обновили свою обложку в Табе!")
		return ""
	end
end)
