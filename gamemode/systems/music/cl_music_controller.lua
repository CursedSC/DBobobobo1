netstream.Hook("dbt/controller/music/play", function(id_song, id_album, IsCustom)
    
	local isMulty = GetGlobalBool("MusicMultyMod")
	local tableMusic = AlbumList
    if IsCustom then tableMusic = AlbumListCustom end
	if isMulty and AlbumListCustom[id_album] then tableMusic = AlbumListCustom end

	dbt.music.CurrentSong = {
		song = tableMusic[id_album]:GetSong(id_song),
		album = id_album
	}	
	tableMusic[id_album]:GetSong(id_song):Play()
end)
  
hook.Add("dbt.ConfigLoaded", "sync.music", function()
    dbt.music.Sync()
end)

function StopMusic_acc() 
    local MAIN_VALUE = music_valume:GetString()
    hook.Add("HUDPaint", "music_func", function()
        MAIN_VALUE = Lerp(FrameTime() / 2, MAIN_VALUE, 0)
        if IsValid(PlayingSong) then
            PlayingSong:SetVolume( MAIN_VALUE * 0.01 )
        end
    end)
    timer.Simple(3, function()
        if IsValid(PlayingSong) then PlayingSong:Stop() end
        hook.Remove("HUDPaint", "music_func")
    end)
end

settings.OnValueHook("musicChange", "Music", function(value)
    if IsValid(PlayingSong) then
        PlayingSong:SetVolume( value * 0.01 )
    end
end)

netstream.Hook("dbt.music.death", function(ran)

	local isMulty = GetGlobalBool("MusicMultyMod")
	local tableMusic = AlbumList
	if isMulty and AlbumListCustom["body_discovered"] then tableMusic = AlbumListCustom end
    if IsValid(PlayingSong) then  PlayingSong:Stop() end
    tableMusic["body_discovered"]:GetSong("sound/body_discovered/found_"..ran..".mp3"):Play(true, 50)
end)

 
netstream.Hook("dbt/music/time", function(t)    
    if !IsValid(PlayingSong) then return end
	PlayingSong:SetTime(t)
    local timeS = PlayingSong:GetLength()
    local t = timeS - PlayingSong:GetTime()
    timer.Create( "AutoPlay", t, 1, function()
        if not GetGlobalBool("LoopMisuc") then 
            if IsValid(PlayingSong) then PlayingSong:Stop() end
            netstream.Start("dbt/controller/music/end")
        end
        if GetGlobalBool("LoopMisuc") then 
            if IsValid(PlayingSong) then PlayingSong:SetTime(0) PlayingSong:Play() end
        end
    end)

end)