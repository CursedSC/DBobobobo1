album = {}

album.songs = {}
function album:AddSong(song)
	self.songs[song.path] = song
	return song
end

function album:SetName(name)
	self.name = name
end

function album:GetSong(id)
	return self.songs[id]
end

function album:RandomSong()
	return table.Random(self.songs)
end

function album:GetId()
	return self.id
end

function album:SetId(id)
	self.id = id
end

function album:__tostring()
    return "Альбом[" .. self.id .. "]["..table.Count(self.songs).."]"
end
album.__index = album

function dbt.music.RegisterAlbum(id)
	return setmetatable({
		songs = {},
        id = id,
    }, 
    album)
end