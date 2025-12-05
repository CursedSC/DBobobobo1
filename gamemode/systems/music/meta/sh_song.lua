song = {}

song.type = "file"
song.path = "none"

song.PlayTypes = {}
song.PlayTypes["file"] = function(self, bRepeat, cValue)
    sound.PlayFile( self.path , "noblock noplay", function( CurrentSong, ErrorID, ErrorName )
        if not CurrentSong then return end
        CurrentSong:SetVolume( cValue and cValue * 0.01 or (settings.Get("Music", 10) * 0.01)  )
        CurrentSong:Play()
        if IsValid(PlayingSong) then PlayingSong:Stop() end
        PlayingSong = CurrentSong
        if !bRepeat then 
            timer.Create( "AutoPlay", CurrentSong:GetLength(), 1, function()
                if not GetGlobalBool("LoopMisuc") then 
                    if IsValid(PlayingSong) then PlayingSong:Stop() end
                    netstream.Start("dbt/controller/music/end")
                end
                if GetGlobalBool("LoopMisuc") then 
                    if IsValid(PlayingSong) then  PlayingSong:Stop() end
                    self:Play()
                end
            end)
        end
    end)
end
function song:Play(bRepeat, cValue)
  	timer.Remove( "AutoPlay" )
  	if song.PlayTypes[self.type] then 
  		song.PlayTypes[self.type](self, bRepeat, cValue)
  	end
end

function song:__tostring()
    return "Музыка[" .. self.path .. "]["..self.type.."]"
end
function song:SetName(name)
    self.name = name
end

song.__index = song
function dbt.music.RegisterSong(path, type)
	return setmetatable({
        path = path,
        type = type,
    }, 
    song)
end