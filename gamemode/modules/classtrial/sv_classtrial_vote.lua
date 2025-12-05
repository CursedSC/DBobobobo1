AddCSLuaFile('')
votingsystem_tablevoting = votingsystem_tablevoting or {}
votingsystem_tablevotinG = votingsystem_tablevotinG or {}
votingsystem_isend = false

concommand.Add('dbt/classtrial/startvoting',function (ply)
	if ply:IsAdmin() then
		votingsystem_tablevoting = {}
		votingsystem_tablevotinG = {}
		for k, v in pairs(player.GetAll()) do
			if InGame(v) then
				netstream.Start(v, "dbt/classtrial/voting")
			end

			if IsMono(v:Pers()) then
				netstream.Start(v, "dbt/classtrial/voting")
			end
		end

		openobserve.Log({
			event = "voting_start",
			name = ply:Nick(),
			steamid = ply:SteamID(),
			gameStatus = GetGlobalString("gameStatus_mono"),
			gameStage = GetGlobalString("gameStage_mono"),
		})
	end
end)

netstream.Hook("dbt/votingsystem/add_vote", function(ply, btnnum, char)
	votingsystem_tablevoting = votingsystem_tablevoting or {}

	votingsystem_tablevoting[ply] = char

	votingsystem_tablevotinG[char] = votingsystem_tablevotinG[char] or 0
	votingsystem_tablevotinG[char] = votingsystem_tablevotinG[char] + 1
	for k, v in pairs(player.GetAll()) do
		if InGame(v) then
			netstream.Start(v, "dbt/votingsystem/vote_update", btnnum)
		end
	end
end)

local function GetMostVoting()
	local winCharacter = table.GetFirstKey(votingsystem_tablevotinG)
	local winCharacterCount = table.GetFirstValue(votingsystem_tablevotinG)
	for k, i in pairs(votingsystem_tablevotinG) do 
		if winCharacterCount < i then 
			winCharacter = k 
			winCharacterCount = i
		end
	end
	return winCharacter
end

netstream.Hook("dbt/votingsystem/end_vote", function()
	if votingsystem_isend then return end

	votingsystem_isend = true
	local tablenotvoting = {}
	for k, v in pairs(player.GetAll()) do
		if InGame(v) and !IsMono(v:Pers()) and !votingsystem_tablevoting[v] then
			tablenotvoting[#tablenotvoting + 1] = v
		end

		if k == #player.GetAll() then
			for a, b in pairs(player.GetAll()) do
				if IsMono(b:Pers()) then
					if tablenotvoting then
						netstream.Start(b, "dbt/votingsystem/notvoting_tomono", tablenotvoting)
					end
				end
			end
		end
	end
	local winer = GetMostVoting() 
	for k, v in pairs(player.GetAll()) do
		if v:IsAdmin() then 
			netstream.Start(v, "dbt/votingsystem/winner", winer, votingsystem_tablevoting)
		end
	end
	timer.Simple(5,function ()
		votingsystem_isend = false
	end)
end)
