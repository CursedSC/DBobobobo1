local acces = {
    ["admin"] = true,
    ["founder"] = true,
}


list.Set( "DesktopWindows", "PlayersContext1", {
    title = "Мономеню",
    icon = "icons/ui_bookmark.png",
    init = function( icon, window )
        dbt.OpenAdminMenu()
        RunConsoleCommand("RefrashMusicCustom")
    end
} )

concommand.Add("NestWB", function(ply)
  doPlayerWound(ply)
end)
