local bg = Material("qmenu/background.png")

activateNY = 0

function StatsM()

    QMENU = true


    hook.Add("PlayerButtonUp", "hud.huddisable", function( ply , button )
        if not ply:IsTyping() then
            if button == KEY_Q then
                QMENU = false
            else return end
        end
        hook.Remove("PlayerButtonUp", "hud.huddisable")
    end)

end

hook.Add( "SpawnMenuOpen", "CheckQmenu", function()
    if not IsValid(LocalPlayer():GetActiveWeapon()) then StatsM() return false end
    local inHeands = LocalPlayer():GetActiveWeapon():GetClass()

    if inHeands == "weapon_physgun" or inHeands == "weapon_physcannon" or inHeands == "gmod_tool" or inHeands == "" then
        return true
    else
        StatsM()
        return false
    end
end)
