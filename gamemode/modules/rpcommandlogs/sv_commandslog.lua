local logsmessage = logsmessage or {}
local colortbl = colortbl or {}
local logstosend = logstosend or {}
local RPCommands = {
	"/me",
	"/do",
	"/try",
	"/roll"
}

util.AddNetworkString("NewRPCommandMessage")
util.AddNetworkString("OpenLogs")

hook.Add("PlayerSay", "logs", function(ply, text)
	for k, v in ipairs(RPCommands) do
		if string.StartsWith(text, v) then
			local newtext = string.TrimLeft(text, v)
			local color = dbt.chr[ply:Pers()].color
			if v == "/try" then
				timer.Simple(0.1, function()
					if a == true then
						local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. newtext .. " (Удачно)"

						table.insert(logstosend, {color, logtext})
					else
						local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. newtext .. " (Неудачно)"

						table.insert(logstosend, {color, logtext})
					end
					return
				end)
			end

			if v == "/me" or v == "/do" then
				local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. newtext .. " (" .. v .. ")"

				table.insert(logstosend, {color, logtext})
			end

			if v == "/roll" then
				timer.Simple(0.1, function()
					local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. "Бросил игровой кубик" .. " (" .. globalroll .. ")"

					table.insert(logstosend, {color, logtext})
				end)
			end

			timer.Simple(0.1,function ()
				net.Start("NewRPCommandMessage")
				if v == "/try" then
					if a == true then
						net.WriteColor(dbt.chr[ply:Pers()].color)
						net.WriteString("\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. newtext .. " (Удачно)")
						net.Broadcast()
					else
						net.WriteColor(dbt.chr[ply:Pers()].color)
						net.WriteString("\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. newtext .. " (Неудачно)")
						net.Broadcast()
					end
					return
				end

				if v == "/me" or v == "/do" then
					net.WriteColor(dbt.chr[ply:Pers()].color)
					net.WriteString("\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. newtext .. " (" .. v .. ")")
					net.Broadcast()
				end

				if v == "/roll" then
					net.WriteColor(dbt.chr[ply:Pers()].color)
					net.WriteString("\n" .. ply:Name() .. " (" .. ply:Pers() .. "): " .. "Бросил игровой кубик" .. " (" .. globalroll .. ")")
					net.Broadcast()
				end
			end)
		end
	end
end)

hook.Add("PlayerButtonUp", "Open Logs", function(ply, btn)
	if btn == KEY_L then
		if not ply:IsAdmin() then return end
		net.Start("OpenLogs")
		net.WriteTable(logstosend)
		net.Send(ply)
	end
end)

hook.Add("PlayerDeath", "PlayerDeathLogs",function (ply, item, killer)
	local color = Color(255, 7, 7, 255)
	local Timestamp = os.time()
	local TimeString = os.date( "%H:%M:%S" , Timestamp )
	if killer:IsValid() and killer != ply then
		local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): Погиб от рук " .. killer:Name() .. " (" .. killer:Pers() .. ") при помощи: "..killer:GetActiveWeapon():GetPrintName().."\nВремя убийства: " .. TimeString
		table.insert(logstosend, {color, logtext})

		net.Start("NewRPCommandMessage")
		net.WriteColor(color)
		net.WriteString(logtext)
		net.Broadcast()
	else
		if ply:GetNWBool("KilledByPoison", false) then
			local color = Color(0, 255, 0, 255)
			local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): Погиб от употребленного яда." .. "\nВремя смерти: " .. TimeString
			table.insert(logstosend, {color, logtext})

			net.Start("NewRPCommandMessage")
			net.WriteColor(color)
			net.WriteString(logtext)
			net.Broadcast()
			ply:SetNWBool("KilledByPoison", false)
		else
			local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): Погиб" .. "\nВремя смерти: " .. TimeString
			table.insert(logstosend, {color, logtext})

			net.Start("NewRPCommandMessage")
			net.WriteColor(color)
			net.WriteString(logtext)
			net.Broadcast()
		end
	end
	ply:SetNWBool("KilledByPoison", false)
end)

hook.Add("PoisonKCNActivate", "PoisonActivatedLogs",function (ply, poisonedby)
	local color = Color(0, 255, 0, 255)
	local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): Отравился быстродействующим ядом. Отравил предмет: " .. poisonedby
	table.insert(logstosend, {color, logtext})

	net.Start("NewRPCommandMessage")
	net.WriteColor(color)
	net.WriteString(logtext)
	net.Broadcast()
end)

hook.Add("PoisonMethanolActivatedHook", "PoisonActivatedLogs",function (ply, poisonedby)
	local color = Color(0, 255, 0, 255)
	local logtext = "\n" .. ply:Name() .. " (" .. ply:Pers() .. "): Отравился долгодействующим ядом. Отравил предмет: " .. poisonedby
	table.insert(logstosend, {color, logtext})

	net.Start("NewRPCommandMessage")
	net.WriteColor(color)
	net.WriteString(logtext)
	net.Broadcast()
end)
