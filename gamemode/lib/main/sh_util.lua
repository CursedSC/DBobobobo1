function util.s_FindPlayer(identifier, user, bNoMessage)
	if not identifier then 
		return
	end

    if string.Trim(identifier) == "^" and TypeID(user) == TYPE_ENTITY and user:IsPlayer() then
        return user
    end
	
	local output = { }

	local players = player.GetAll()
    local playerCount = #players

	for playerIndex = 1, playerCount do
        local player = players[playerIndex]

		local playerNick = string.lower(player:Nick())
		local playerName = string.lower(player:Name())

		if  player:SteamID() == identifier or
            player:UniqueID() == identifier or
            player:GetNWString("MonoOwner") == identifier or
		    player:SteamID64() == identifier or
            SERVER and (player:IPAddress():gsub(":%d+", "")) == identifier or
		    playerNick == string.lower(identifier) or
            playerName == string.lower(identifier) or
            hook.Run("util.playerMatchesIdentifier", player, identifier)
        then
			return player
		end

	end

	if #output == 1 then
		return output[1]
	elseif #output > 1 then
		if not bNoMessage then
			if IsValid(user) then
				util.Notify(user, Color(211, 78, 71), "Found more than one player with that identifier.")
			else
				if SERVER then
					Msg("Found more than one player with that identifier.\n")
				end
			end
		end
	else
		if not bNoMessage then
			if IsValid(user) then
                util.Notify(user, Color(211, 78, 71), "Can't find any player with that identifier.")
			else
				if SERVER then
					Msg("Can't find any player with that identifier.\n")
				end
			end
		end
	end
end