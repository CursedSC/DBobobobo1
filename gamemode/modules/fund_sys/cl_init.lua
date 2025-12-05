
hook.Add( "HUDPaint", "ToScreenExample", function()

    if GDown then

      --  surface.SetDrawColor(0,0,0,190)
      --  surface.DrawRect(0, 0, ScrW(), ScrH())

        local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )

        local ent = tr.Entity

        local point = ent:GetPos() + ent:OBBCenter() * 2
        local data2D = point:ToScreen()


        if ent:GetPos():Distance(LocalPlayer():GetPos()) > 100 or not ent:IsPlayer() then return end


    end

end )


hook.Add( "RenderScreenspaceEffects", "MotionBlurEffect", function()
	if GDown  then
        local matColor = Material( "pp/colour" )
        matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
        matColor:SetFloat( "$pp_colour_addr", 0.5 )
        matColor:SetFloat( "$pp_colour_addg", 0.5 )
        matColor:SetFloat( "$pp_colour_addb", 0.5 )
        matColor:SetFloat( "$pp_colour_contrast", 0.5 )
        matColor:SetFloat( "$pp_colour_colour", 0.9 )
        matColor:SetFloat( "$pp_colour_brightness", -0.5 )
		DrawMotionBlur( 0.5, 1, 0.01 )
          render.SetMaterial( matColor )
          render.DrawScreenQuad()
	end
end )


GDown = false
hook.Add("PlayerButtonUp", "dbt.ResetLerp", function( ply , button )
    if not LocalPlayer():IsTyping() and !IsClassTrial() and not ply.Instrument then
        if button == KEY_G then
            fn_fraction = 0
            if not cd_time or cd_time < CurTime() then
                cd_time = CurTime() + 1
                GDown = !GDown
                if GDown then
                surface.PlaySound("search.mp3")
                ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 1, 0 )
				ply:SetNWBool("findmode", false)
                end
                if !GDown then
                ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 2, 0 )
				ply:SetNWBool("findmode", false)
                end
            end

        else
            return
        end
    end

    end)

sp_lerp = 0
sp_lerp_color = 100
hook.Add("PlayerButtonDown", "dbt.ResetLerp", function( ply , button )
    if not LocalPlayer():IsTyping() and IsGame() then
        if button == KEY_G then
            fn_fraction = 0
            sp_lerp = 0
        else return end
    end
end)--render.MaterialOverride



hook.Add( "PostDrawTranslucentRenderables", "test", function()
    local pos = LocalPlayer():GetPos()

    if GDown and sp_lerp < 1000 then
        render.SetColorMaterial()
        local pos = LocalPlayer():GetPos()
        sp_lerp = sp_lerp + 3

        if sp_lerp_color > 1 then
            sp_lerp_color = sp_lerp_color - 0.3
        end

        render.DrawSphere( pos, -sp_lerp, 30, 30, Color( 116, 40, 151, sp_lerp_color ), true )
    elseif not GDown then
        sp_lerp = 0
        sp_lerp_color = 100
    end


end )
