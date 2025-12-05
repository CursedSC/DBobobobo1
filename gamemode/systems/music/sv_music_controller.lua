dbt.music = dbt.music or {}

local function isNightTime()
	if not globaltime then return false end
	local hours = math.floor(globaltime / 3600) % 24
	return hours > 20 or hours < 7
end

function dbt.music.Play(id, idsong, IsCustom)
	local isMulty = GetGlobalBool("MusicMultyMod")
	local targetAlbum = id
	if not IsCustom and not idsong and (targetAlbum == "day" or targetAlbum == "night") then
		targetAlbum = isNightTime() and "night" or "day"
	end

	local tableMusic = AlbumList
	if IsCustom then
		tableMusic = AlbumListCustom
	elseif isMulty and AlbumListCustom and AlbumListCustom[targetAlbum] then
		tableMusic = AlbumListCustom
	end

	local album = tableMusic and tableMusic[targetAlbum]
	if not album then return end

	local song
	if not idsong then
		song = album:RandomSong()
	else
		song = album:GetSong(idsong)
	end
	if not song then return end

	local usingCustom = tableMusic == AlbumListCustom

	dbt.music.CurrentSong = {
		song = song,
		album = targetAlbum,
		custom = usingCustom
	}

	netstream.Start(nil, "dbt/controller/music/play", song.path, targetAlbum, usingCustom)
end
   
netstream.Hook("dbt/controller/music/end", function()
	local current = dbt.music.CurrentSong
	if not current or not current.album then return end
	local nextAlbum = current.album
	if not current.custom and (nextAlbum == "day" or nextAlbum == "night") then
		nextAlbum = isNightTime() and "night" or "day"
	end
	dbt.music.Play(nextAlbum, nil, current.custom)
end)

function dbt.music.StartDayNight()
	if isNightTime() then
		dbt.music.Play("night")
	else
		dbt.music.Play("day")
	end
end

netstream.Hook("dbt/music/start/admin", function(ply, album, id, IsCustom)
	dbt.music.Play(album, id, IsCustom)
end)
netstream.Hook("dbt/music/time", function(ply, t)
	if !ply:IsAdmin() then return end 
	netstream.Start(nil, "dbt/music/time", t)
end)

--[[
netstream.Hook("dbt/music/sync", function(ply)
	local Sync = {}
	for k, i in pairs(AlbumList) do 
		Sync[k] = {}
		Sync[k].name = i.name
		Sync[k].songs = {}
		for id, music in pairs(i.songs) do 
			Sync[k].songs[id] = {
				path = music.path, 
				name = music.name,
			}
		end
	end
	netstream.Start(ply, "dbt/music/sync", Sync)
end)]]
