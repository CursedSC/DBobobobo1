if CLIENT then 
    netstream.Hook("dbt/can't/weapon", function()
        local color = dbt.chr[LocalPlayer():Pers()].color or Color( 89, 255, 6)
       chat.AddText( Color( 89, 255, 6), "", color, " Вы не можете ударить этим оружием, потому что оно слишком тяжёлое для вас.")
    end)
end
