local function tablesToMeta(tbl)
    local newTable = {}
    for k, i in pairs(tbl) do 
        newTable[k] = dbt.music.RegisterAlbum(k)
        newTable[k]:SetName(i.name) 
        for music_path, music_info in pairs(i.songs) do 
            local song = dbt.music.RegisterSong(music_path, music_info.type)
            newTable[k]:AddSong(song):SetName(music_info.name)
        end
    end
    return newTable
end

function dbt.music.Sync()
    netstream.Start("dbt/music/sync") 
end

netstream.Hook("dbt/music/sync", function(AlbumList, AlbumListCustom)
    _G.AlbumList = tablesToMeta(AlbumList)
    _G.AlbumListCustom = tablesToMeta(AlbumListCustom)
end)

hook.Add( "InitPostEntity", "dbt.music.Sync", function()
	dbt.music.Sync()
end )