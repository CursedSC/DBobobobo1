--

netstream.Hook("dbt.InCT", function()
    canfind = false
    gamest = 1
    timer.Remove("classtrial.RemoveFade")
    hook.Remove("PostDrawHUD", "classtrial.fade")
    allowcum = 1
    StarttClassTrial()
    pastSpeaker = nil
    isSpeaker = nil

    timer.Simple(10, function()
        if IsValid(spritemenu) then 
            spritemenu:Remove()
        end
        DrawSpritesMenu()
    end)
end)

hook.Add( "InitPostEntity", "some_unique_name", function()
    if IsClassTrial() then 
        timer.Simple(5, function()
            spritemenu:Remove()
            DrawSpritesMenu()
        end)
    end
    PrintTable(LocalPlayer():SelfData())
end )