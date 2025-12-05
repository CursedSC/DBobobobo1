AlbumList = {}
AlbumListCustom = {}

local root_path = "sound/ost/"
local root_path_custom = "sound/custom_music_1/"

local folders = {  
    "day",
    "despair",
    "execution", 
    "investigation",
    "monothemes",
    "night",
    "other",
    "stressy",
    "classtrial",
    "body_discovered",
    "ending",
    "panictrial",
    "pretrial",
    "voting",
}  


local folders_name = {  
    ["day"] = "День",
    ["despair"] = "Отчаяние",
    ["execution"] = "Казнь",
    ["investigation"] = "Раследование",
    ["monothemes"] = "Моно-тема",
    ["night"] = "Ночь",
    ["other"] = "Другое",
    ["stressy"] = "Стрессовая",
    ["classtrial"] = "Классный суд",
    ["body_discovered"] = "Обноружение тела",
    ["ending"] = "Конец",
    ["panictrial"] = "Паника",
    ["pretrial"] = "Перед классным судом",
    ["voting"] = "Голосование"
} 

local function loadMain()
    local files, directories = file.Find( root_path.."*", "GAME" )

    for k, id_album in pairs(directories) do  
        if id_album == nil then continue end
        // Я не ебу надо ли, но пока что закоментирую
        // if !table.HasValue(folders, i) then continue end  
        AlbumList[id_album] = dbt.music.RegisterAlbum(id_album)
        AlbumList[id_album]:SetName(folders_name[id_album]) 

        local path_to_file = root_path..""..id_album.."/"

        local files, directories = file.Find( path_to_file.."*", "GAME" )
 
        for k, i in pairs(files) do 
            local filePath = path_to_file..""..i
            local song = dbt.music.RegisterSong(filePath, "file")
            AlbumList[id_album]:AddSong(song):SetName(folders_name[id_album].. " #"..k)
        end
    end
end

local function loadCustom()
    local files, directories = file.Find( root_path_custom.."*", "GAME" )
    for k, id_album in pairs(directories) do    
        AlbumListCustom[id_album] = dbt.music.RegisterAlbum(id_album)
        AlbumListCustom[id_album]:SetName(id_album) 

        local path_to_file = root_path_custom..""..id_album.."/"

        local files, directories = file.Find( path_to_file.."*", "GAME" )

        for k, i in pairs(files) do 
            local filePath = path_to_file..""..i
            local song = dbt.music.RegisterSong(filePath, "file")

            AlbumListCustom[id_album]:AddSong(song):SetName(i)
        end
    end
end 

local function loadCustom2()
    local files, directories = file.Find( "sound/body_discovered/*", "GAME" )

    AlbumList["body_discovered"] = dbt.music.RegisterAlbum(body_discovered)
    AlbumList["body_discovered"]:SetName(folders_name["body_discovered"]) 

    for k, i in pairs(files) do  
        local filePath = "sound/body_discovered/"..i
        local song = dbt.music.RegisterSong(filePath, "file")

        AlbumList["body_discovered"]:AddSong(song):SetName(folders_name["body_discovered"].. " #"..k)
    end
end 

loadMain()
loadCustom()
loadCustom2()

netstream.Hook("dbt/music/sync", function(ply)
    netstream.Start(ply, "dbt/music/sync", AlbumList, AlbumListCustom)
end)

netstream.Start(nil, "dbt/music/sync", AlbumList, AlbumListCustom)
