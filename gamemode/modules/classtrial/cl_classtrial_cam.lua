local mapp, mclamp = math.Approach, math.Clamp

net.Receive( "classtrial.ItsArgue", function () CanArgue = net.ReadFloat() end) 
net.Receive( "cclasstrial.NetRandom", function()  r_rValue = net.ReadFloat() end)

local viewFov = 40
local angleFx = 0
local angleFy = 0
local rviewPosX = 0
local rviewPosY = 0
local rviewPosZ = 0
local delaySound = true
local delaySpSound = true
local delayDisclamer = false
local enableChangeStatus = true
local pastSpeaker = nil
local isSpeaker = nil
local itsArgue = nil
local angRec = 0
local CanChageView = false
argTimer = 0
argueCoolDown = 50
local animation = nil


concommand.Add("OpenClassTrial", function()
    local DermaPanel = vgui.Create( "DFrame" )  -- Create a panel to parent it to
    DermaPanel:SetSize( 500, 200 )  -- Set the size
    DermaPanel:Center()             -- Center it
    DermaPanel:MakePopup()          -- Make it a popup

    local DermaNumSlider = vgui.Create( "DNumSlider", DermaPanel )
    DermaNumSlider:SetPos( 50, 40 )             -- Set the position
    DermaNumSlider:SetSize( 300, 100 )          -- Set the size
    DermaNumSlider:SetText( "X pos" )   -- Set the text above the slider
    DermaNumSlider:SetMin( -100000 )                  -- Set the minimum number you can slide to
    DermaNumSlider:SetMax( 100000 )                -- Set the maximum number you can slide to
    DermaNumSlider:SetDecimals( 0 )             -- Decimal places - zero for whole number
    DermaNumSlider:SetValue(normal_camera_position["drp_hopespeak"].x)
    -- If not using convars, you can use this hook + Panel.SetValue()
    DermaNumSlider.OnValueChanged = function( self, value )
        normal_camera_position[game.GetMap()].x = value
            net.Start("dbt/classtrial/update")
      net.WriteTable(GPS_POS)
      net.WriteTable(normal_camera_position)
    net.SendToServer()
    end

    local DermaNumSlider = vgui.Create( "DNumSlider", DermaPanel )
    DermaNumSlider:SetPos( 50, 100 )             -- Set the position
    DermaNumSlider:SetSize( 300, 40 )          -- Set the size
    DermaNumSlider:SetText( "Y pos" )   -- Set the text above the slider
    DermaNumSlider:SetMin( -100000 )                  -- Set the minimum number you can slide to
    DermaNumSlider:SetMax( 100000 )                  -- Set the maximum number you can slide to
    DermaNumSlider:SetDecimals( 0 )             -- Decimal places - zero for whole number
    DermaNumSlider:SetValue(normal_camera_position["drp_hopespeak"].y)
    -- If not using convars, you can use this hook + Panel.SetValue()
    DermaNumSlider.OnValueChanged = function( self, value )
        normal_camera_position[game.GetMap()].y = value
            net.Start("dbt/classtrial/update")
      net.WriteTable(GPS_POS)
      net.WriteTable(normal_camera_position)
    net.SendToServer()
    end


    local DermaNumSlider = vgui.Create( "DNumSlider", DermaPanel )
    DermaNumSlider:SetPos( 50, 150 )             -- Set the position
    DermaNumSlider:SetSize( 300, 40 )          -- Set the size
    DermaNumSlider:SetText( "Z pos" )   -- Set the text above the slider
    DermaNumSlider:SetMin( -100000 )                  -- Set the minimum number you can slide to
    DermaNumSlider:SetMax( 100000 )                  -- Set the maximum number you can slide to
      DermaNumSlider:SetDecimals( 0 )             -- Decimal places - zero for whole number
      DermaNumSlider:SetValue(normal_camera_position["drp_hopespeak"].z)
    -- If not using convars, you can use this hook + Panel.SetValue()
    DermaNumSlider.OnValueChanged = function( self, value )
        normal_camera_position[game.GetMap()].z = value
        normal_camera_position[game.GetMap()].anim.hidht.st  = value + 120
        normal_camera_position[game.GetMap()].anim.hidht.ed  = value + 110
            net.Start("dbt/classtrial/update")
      net.WriteTable(GPS_POS)
      net.WriteTable(normal_camera_position)
    net.SendToServer()
    end

end)



function ViewPostProcessing()
    local matColor = Material( "pp/colour" )
    hook.Add( "RenderScreenspaceEffects", "ct.ColorExample", function()
        if game.GetMap() == "drp_hopespeak" then
            render.UpdateScreenEffectTexture()
            matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
            matColor:SetFloat( "$pp_colour_addr", 0.5 )
            matColor:SetFloat( "$pp_colour_addg", 0.45 )
            matColor:SetFloat( "$pp_colour_addb", 0.4 )
            matColor:SetFloat( "$pp_colour_contrast", 1.5 )
            matColor:SetFloat( "$pp_colour_colour", 0.8 )
            matColor:SetFloat( "$pp_colour_brightness", -0.6 )
            render.SetMaterial( matColor )
            render.DrawScreenQuad()
        else
            --[[
            render.UpdateScreenEffectTexture()
            matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
            matColor:SetFloat( "$pp_colour_addr", 0.3 )
            matColor:SetFloat( "$pp_colour_addg", 0.45 )
            matColor:SetFloat( "$pp_colour_addb", 0.6 )
            matColor:SetFloat( "$pp_colour_contrast", 1.5 )
            matColor:SetFloat( "$pp_colour_colour", 0.8 )
            matColor:SetFloat( "$pp_colour_brightness", -0.6 )
            render.SetMaterial( matColor )
            render.DrawScreenQuad()]]

            render.UpdateScreenEffectTexture()
            matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
            matColor:SetFloat( "$pp_colour_addr", 0.5 )
            matColor:SetFloat( "$pp_colour_addg", 0.45 )
            matColor:SetFloat( "$pp_colour_addb", 0.4 )
            matColor:SetFloat( "$pp_colour_contrast", 1.5 )
            matColor:SetFloat( "$pp_colour_colour", 0.8 )
            matColor:SetFloat( "$pp_colour_brightness", -0.6 )
            render.SetMaterial( matColor )
            render.DrawScreenQuad()

        end
    end )
end

function NearView()
    animNearAng, animNearSpeed = 0.4, 0.3
    sizeNearCircle = 80

    hook.Add("Think", "ct.RotateNearView", function()
        local nearNow = RealTime()
        if nearRotateTime then
            animNearAng = animNearAng + animNearSpeed * (nearNow - nearRotateTime)
            animNearAng = animNearAng % 360
        end
        nearRotateTime = nearNow
    end)

    hook.Remove( "CalcView", "ct.viewPosition" )
    hook.Add("CalcView", "ct.viewPosition", function( ply, pos, angles, fov )

        nearPosY = math.sin( animNearAng ) * sizeNearCircle + (normal_camera_position[game.GetMap()].y)
        nearPosX = math.cos( animNearAng ) * sizeNearCircle + (normal_camera_position[game.GetMap()].x)

        viewPos = Vector( nearPosX, nearPosY, normal_camera_position[game.GetMap()].z )
        nearAngleX = ( Vector( normal_camera_position[game.GetMap()].x, normal_camera_position[game.GetMap()].y, normal_camera_position[game.GetMap()].z )-viewPos ):Angle().x
        nearAngleY = ( Vector( normal_camera_position[game.GetMap()].x, normal_camera_position[game.GetMap()].y, normal_camera_position[game.GetMap()].z )-viewPos ):Angle().y

        local view = {}
        view.origin = viewPos
        view.angles = Angle( nearAngleX, nearAngleY, 5 )
        view.fov = 30
        view.drawviewer = true
        return view
    end)


    AnimationClassTrialMask()
    DrumShow()
    DisclaimerMain()
    enableCangeView = true

    -- hook.Add("PlayerStartVoice", "Cumdfsdfsd", viewonplayer)

end

local function StartAnimationView()
    local animStartAng = 0
    local animStartCir = 350
    local startAngleZ = 0
    local startFov = 60
    local fraction = 0
    local lerptime = 2
    hook.Add("Think", "ct.StartAnimationView", function()
        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        animStartAng = Lerp(fraction, 0, 1)
        animStartCir = Lerp(fraction, 500, 30)
        animStartHeight = Lerp(fraction, normal_camera_position[game.GetMap()].anim.hidht.st, normal_camera_position[game.GetMap()].anim.hidht.ed)
    end)
    timer.Create("ct.timer_1.1", 1.2, 1, function()

        local fraction = 0
        local lerptime = 0.3
        hook.Add("Think", "ct.st_fade", function()
            fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
            if fraction == 0 then return end
            fadeF = Lerp(fraction, 0, 255)
        end)
        hook.Add("HUDPaint", "ct.st_fade", function()
            draw.NoTexture()
            surface.SetDrawColor( 0, 0, 0, fadeF )
            surface.DrawRect( ScrW()*(0/1920), ScrH()*(0/1080), ScrW()*(1920/1920), ScrH()*(1080/1080) )
        end)
        timer.Create("ct.timer_1.1", 0.8, 1, function()

            local fraction = 0
            local lerptime = 0.5
            hook.Add("Think", "ct.st_fade", function()
                fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
                if fraction == 0 then return end
                fadeF = Lerp(fraction, 255, 0)
            end)
            hook.Remove("HUDPaint", "ct.st_fade")
            hook.Add("HUDPaint", "ct.st_fade", function()
                draw.NoTexture()
                surface.SetDrawColor( 0, 0, 0, fadeF )
                surface.DrawRect( ScrW()*(0/1920), ScrH()*(0/1080), ScrW()*(1920/1920), ScrH()*(1080/1080) )
            end)
        end)
    end)
    -- КАМЕРА 2
    timer.Create("ct.timer_1.2", 2, 1, function()


        local fraction = 0
        local lerptime = 4
        startAngleZ = -10
        startFov = 60
        hook.Add("Think", "ct.StartAnimationView", function()
            fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
            if fraction == 0 then return end
            animStartAng = Lerp(fraction, 1, 0)
            animStartCir = Lerp(fraction, 20, -500)
            animStartHeight = Lerp(fraction, normal_camera_position[game.GetMap()].anim.hidht.st, normal_camera_position[game.GetMap()].anim.hidht.ed)
            startAngleZ = Lerp(fraction, -10, 5)
            startFov = Lerp(fraction, 60, 30)
        end)
    end)

    -- ЗАТЕМНЕНИЕ/ ОСВЕТЛЕНИЕ
    timer.Create("ct.timer_1.5s", 4.2, 1, function()

        local fraction = 0
        local lerptime = 0.5
        hook.Add("Think", "ct.st_fade", function()
            fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
            if fraction == 0 then return end
            fadeF = Lerp(fraction, 0, 255)
        end)
        hook.Add("HUDPaint", "ct.st_fade", function()
            draw.NoTexture()
            surface.SetDrawColor( 0, 0, 0, fadeF )
            surface.DrawRect( ScrW()*(0/1920), ScrH()*(0/1080), ScrW()*(1920/1920), ScrH()*(1080/1080) )
        end)
        timer.Create("ct.timer_1.1", 0.8, 1, function()

            local fraction = 0
            local lerptime = 0.5
            hook.Add("Think", "ct.st_fade", function()
                fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
                if fraction == 0 then return end
                fadeF = Lerp(fraction, 255, 0)
            end)
            hook.Remove("HUDPaint", "ct.st_fade")
            hook.Add("HUDPaint", "ct.st_fade", function()
                draw.NoTexture()
                surface.SetDrawColor( 0, 0, 0, fadeF )
                surface.DrawRect( ScrW()*(0/1920), ScrH()*(0/1080), ScrW()*(1920/1920), ScrH()*(1080/1080) )
            end)
        end)
    end)

    -- NEAR VIEW
    timer.Create("ct.timer_1.3", 5, 1, function()
        NearView()

    end)
    -- ХУК ВИДА
    hook.Remove( "CalcView", "ct.viewPosition" )
    hook.Add("CalcView", "ct.viewPosition", function( ply, pos, angles, fov )
        startPosY = math.sin( animStartAng ) * animStartCir + (normal_camera_position[game.GetMap()].y)
        startPosX = math.cos( animStartAng ) * animStartCir + (normal_camera_position[game.GetMap()].x)

        viewPos = Vector( startPosX, startPosY, animStartHeight )
        startAngleX = ( Vector( normal_camera_position[game.GetMap()].x, normal_camera_position[game.GetMap()].y, normal_camera_position[game.GetMap()].z ) - viewPos ):Angle().x
        startAngleY = ( Vector( normal_camera_position[game.GetMap()].x, normal_camera_position[game.GetMap()].y, normal_camera_position[game.GetMap()].z ) - viewPos ):Angle().y

        local view = {}
        view.origin = viewPos
        view.angles = Angle( startAngleX, startAngleY, startAngleZ )
        view.fov = startFov
        view.drawviewer = true
        return view
    end)
end

function True_RandomViewAnimation()

    r_rValue = r_rValue or 1

    if r_rValue == 1 then --==============================

        viewFov = 30
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ - 5 )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 60 )
            viewAng = LerpAngle( FrameTime(), viewAng, Angle( angleFx + 10, angleFy, angRec ) )
            viewPos = LerpVector( FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ + 10 ) )
        end)
    elseif r_rValue == 2 then --==============================

        viewFov = 30
        viewAng = Angle( angleFx, angleFy, angRec + 10 )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 2 * FrameTime(), viewFov, 50 )
            viewAng = LerpAngle( FrameTime(), viewAng, Angle( angleFx - 5, angleFy, angRec - 10 ) )
            viewPos = LerpVector( 0.3 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ - 10 ) )
        end)
    elseif r_rValue == 3 then --==============================

        viewFov = 60
        viewAng = Angle( angleFx, angleFy - 10, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 2 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx, angleFy + 5, angRec + 5 ) )
            viewPos = LerpVector( FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
        end)
    elseif r_rValue == 4 then --==============================

        viewFov = 60
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(0.5 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle(2 * FrameTime(), viewAng, Angle( angleFx + 10, angleFy, angRec ) )
            viewPos = LerpVector(2 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ + 20) )
        end)
    elseif r_rValue == 5 then --==============================

        viewFov = 50
        viewAng = Angle( angleFx, angleFy + 7, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 2 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.2 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec ) )
            viewPos = LerpVector( FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
        end)
    elseif r_rValue == 6 then --==============================

        viewFov = 30
        viewAng = Angle( angleFx + 5, angleFy - 7, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( FrameTime(), viewFov, 40 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec ) )
            viewPos = LerpVector( FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
        end)
    elseif r_rValue == 7 then --==============================

        viewFov = 40
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( FrameTime(), viewFov, 60 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx - 5, angleFy, angRec ) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ - 10 ) )
        end)
    elseif r_rValue == 8 then --==============================

        viewFov = 50
        viewAng = Angle( angleFx + 10, angleFy, angRec + 5)
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ + 10)

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( FrameTime(), viewFov, 40 )
            viewAng = LerpAngle( FrameTime(), viewAng, Angle( angleFx - 5, angleFy, angRec - 2) )
            viewPos = LerpVector( FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ - 10) )
        end)
    elseif r_rValue == 9 then --==============================

        viewFov = 40
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY - 10, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 2 * FrameTime(), viewFov, 50 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx + 5, angleFy, angRec - 5 ) )
            viewPos = LerpVector( 0.3 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ + 10 ) )
        end)
    elseif r_rValue == 10 then --==============================

        viewFov = 40
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY - 10, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 2 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec ) )
            viewPos = LerpVector( 0.3 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY + 5, rviewPosZ ) )
        end)
    elseif r_rValue == 11 then --==============================

        viewFov = 40
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY - 5, rviewPosZ + 5 )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 50 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx, angleFy - 5, angRec + 5 ) )
            viewPos = LerpVector( 0.3 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY + 5, rviewPosZ - 5 ) )
        end)
    elseif r_rValue == 12 then --==============================

        viewFov = 50
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 0.3 * FrameTime(), viewFov, 35 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec ) )
            viewPos = LerpVector( 0.3 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
        end)
    elseif r_rValue == 13 then --==============================

        viewFov = 40
        viewAng = Angle( angleFx - 5, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ - 10 )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( 0.3 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx + 5, angleFy, angRec ) )
            viewPos = LerpVector( 0.3 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ + 5 ) )
        end)
    elseif r_rValue == 14 then --==============================

        viewFov = 50
        viewAng = Angle( angleFx, angleFy, angRec + 2 )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 25 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx, angleFy - 3, angRec + 5 ) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ - 2 ) )
        end)
    elseif r_rValue == 15 then --==============================

        viewFov = 50
        viewAng = Angle( angleFx, angleFy - 3, angRec - 2 )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx + 5, angleFy + 3, angRec - 5 ) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY + 5, rviewPosZ + 5 ) )
        end)
    elseif r_rValue == 16 then --==============================

        viewFov = 60
        viewAng = Angle( angleFx, angleFy, angRec - 5 )
        viewPos = Vector( rviewPosX - 10, rviewPosY - 10, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 40 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx, angleFy + 5, angRec - 5 ) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX + 5, rviewPosY + 5, rviewPosZ ) )
        end)
    elseif r_rValue == 17 then --==============================

        viewFov = 30
        viewAng = Angle( angleFx, angleFy - 5, angRec - 5)
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ - 10 )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx, angleFy - 5, angRec - 5) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ - 2 ) )
        end)
    elseif r_rValue == 18 then --==============================

        viewFov = 30
        viewAng = Angle( angleFx, angleFy - 5, angRec - 5)
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ - 10 )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 50 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx, angleFy - 5, angRec - 5) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ - 2 ) )
        end)
    elseif r_rValue == 19 then --==============================

        viewFov = 60
        viewAng = Angle( angleFx, angleFy, angRec )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ + 10 )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(2 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.5 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec ) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
        end)
    elseif r_rValue == 20 then --==============================

        viewFov = 60
        viewAng = Angle( angleFx, angleFy, angRec - 7 )
        viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp(0.5 * FrameTime(), viewFov, 30 )
            viewAng = LerpAngle( 0.3 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec + 7 ) )
            viewPos = LerpVector( 0.5 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
        end)
    end
end

function ArgueViewAnimation(pers)
    BulletShootMask()
    timer.Simple(1, function()
        if IsMono(isSpeaker:Pers()) then

            if ( isSpeaker != nil and pastSpeaker != nil ) then
                ViewPlayerToMonokuma()
            else
                ViewOnMonokuma()
            end

        elseif ( isSpeaker != nil and pastSpeaker == nil ) then
            AnimationViewNearToPlayer()
        elseif ( isSpeaker != nil and pastSpeaker != nil ) then
            AnimationViewOnPlayer()
        end

        surface.PlaySound( "danganronpa_sfx_13.mp3" )
        ArgueManagerMask(isSpeaker:Pers())
        timer.Create("ct.timer_1.6", 0.3, 1, function()

            viewFov = 40
            viewAng = Angle( angleFx, angleFy, angRec )
            viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )

            hook.Add("Think", "ct.viewPos", function()
                viewFov = Lerp( 2 * FrameTime(), viewFov, 30 )
                viewAng = LerpAngle( 2 * FrameTime(), viewAng, Angle( angleFx, angleFy, angRec - 10 ) )
                viewPos = LerpVector( 2 * FrameTime(), viewPos, Vector( rviewPosX, rviewPosY, rviewPosZ ) )
            end)

        end)
    end)
end

function AnimationViewNearToPlayer()
    hook.Remove( "CalcView", "ct.viewPosition" )
   -- hook.Remove( "Think", "ct.viewPos" ) -- ремув что бы убрать вид для аргумента

    -- переменные нужны для постанимирования
    viewFov = 40
    angRec = 0
    rviewPosX = normal_camera_position[game.GetMap()].x
    rviewPosY = normal_camera_position[game.GetMap()].y
    rviewPosZ = normal_camera_position[game.GetMap()].z
    viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )
    angleFx = ( isSpeaker:EyePos() - viewPos ):Angle().x + 2
    angleFy = ( isSpeaker:GetPos() - viewPos ):Angle().y
    viewAng = Angle( angleFx, angleFy, angRec )

    local fraction = 0
    local lerptime = 0.5

    hook.Add("CalcView", "ct.viewPosition", function( ply, pos, angles, fov )
        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        local view = {}
        view.origin = LerpVector(fraction, Vector( nearPosX, nearPosY, normal_camera_position[game.GetMap()].z ), viewPos )
        view.angles = LerpAngle(fraction, Angle( nearAngleX, nearAngleY, 0 ), viewAng )
        view.fov = Lerp( fraction, 30, viewFov )
        view.drawviewer = true
        return view
    end)
end

function ViewPlayerToMonokuma()
    hook.Remove( "CalcView", "ct.viewPosition" )

    viewPos = normal_camera_position[game.GetMap()].monokuma.vec
    local angleFx = ( isSpeaker:EyePos() - viewPos ):Angle().x + normal_camera_position[game.GetMap()].monokuma.plus
    local angleFy = ( isSpeaker:GetPos() - viewPos ):Angle().y * normal_camera_position[game.GetMap()].monokuma.adi
    local anglePx = ( pastSpeaker:EyePos() - viewPos ):Angle().x + normal_camera_position[game.GetMap()].monokuma.plus
    local anglePy = ( pastSpeaker:GetPos() - viewPos ):Angle().y * normal_camera_position[game.GetMap()].monokuma.adi
    local fraction = 0
    local lerptime = 0.5
    local posAnim = 0

    timer.Create("ct.timer_1.4", 0.5, 1, function()

        local fraction = 0
        local lerptime = 10
        hook.Add("Think", "ct.viewPos", function()
            fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
            if fraction == 0 then return end
            viewFov = Lerp(fraction, 60, 50)
            posAnim = Lerp(fraction, 0, 10)
        end)
    end)
    hook.Add("CalcView", "ct.viewPosition", function( ply, pos, angles, fov )
        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        local view = {}
        view.origin = LerpVector(fraction, Vector( normal_camera_position[game.GetMap()].x, normal_camera_position[game.GetMap()].y, normal_camera_position[game.GetMap()].z ), Vector( normal_camera_position[game.GetMap()].monokuma.vec.x, normal_camera_position[game.GetMap()].monokuma.vec.y, normal_camera_position[game.GetMap()].monokuma.vec.z  - posAnim ))
        view.angles = LerpAngle(fraction, Angle(anglePx, anglePy, 0 ), Angle(angleFx - posAnim / 2, angleFy, angRec ))
        view.fov = viewFov
        view.drawviewer = true
        return view
    end)
end

function ViewOnMonokuma()
    hook.Remove( "CalcView", "ct.viewPosition" )
    viewPos = normal_camera_position[game.GetMap()].monokuma.vec
    local angleFx = ( isSpeaker:EyePos()-viewPos ):Angle().x + normal_camera_position[game.GetMap()].monokuma.plus
    local angleFy = ( isSpeaker:GetPos()-viewPos ):Angle().y * normal_camera_position[game.GetMap()].monokuma.adi
    local fraction = 0
    local lerptime = 0.5
    local posAnim = 0
    viewFov = 60

    timer.Create("ct.timer_1.5", 0.5, 1, function()

        viewFov = 60
        posAnim = 0
        hook.Add("Think", "ct.viewPos", function()
            viewFov = Lerp( FrameTime() / 2, viewFov, 50 )
            posAnim = Lerp( FrameTime() / 2, posAnim, 10 )
        end)
    end)

    hook.Add("CalcView", "ct.viewPosition", function( ply, pos, angles, fov )
        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1) --  * normal_camera_position[game.GetMap()].monocuma.adi
        if fraction == 0 then return end
        local view = {}
        view.origin = LerpVector(fraction, Vector( nearPosX, nearPosY, normal_camera_position[game.GetMap()].z ), Vector( normal_camera_position[game.GetMap()].monokuma.vec.x, normal_camera_position[game.GetMap()].monokuma.vec.y, normal_camera_position[game.GetMap()].monokuma.vec.z - posAnim ))
        view.angles = LerpAngle(fraction, Angle( nearAngleX, nearAngleY, 0 ), Angle( angleFx - posAnim / 2, angleFy, 0 ))
        view.fov = Lerp( fraction, 50, viewFov )
        view.drawviewer = true
        return view
    end)
end

function AnimationViewOnPlayer()
    if isSpeaker == nil or pastSpeaker == nil then return end -- ВНИМАНИЕ надо бы добавить везде
    if not IsValid(pastSpeaker) or not IsValid(isSpeaker) then return end

    hook.Remove( "CalcView", "ct.viewPosition" )
   -- hook.Remove( "Think", "ct.viewPos" ) -- ремув что бы убрать вид для аргумента

    -- переменные нужны для постанимирования
    viewFov = 40
    angRec = 0
    rviewPosX = normal_camera_position[game.GetMap()].x
    rviewPosY = normal_camera_position[game.GetMap()].y
    rviewPosZ = normal_camera_position[game.GetMap()].z
    viewPos = Vector( rviewPosX, rviewPosY, rviewPosZ )
    angleFx = ( isSpeaker:EyePos() - viewPos ):Angle().x + 2
    angleFy = ( isSpeaker:GetPos() - viewPos ):Angle().y
    local anglePx = ( pastSpeaker:EyePos() - viewPos ):Angle().x + 2
    local anglePy = ( pastSpeaker:GetPos() - viewPos ):Angle().y

    viewAng = Angle( angleFx, angleFy, angRec )
    local fraction = 0
    local lerptime = 0.3

    hook.Add("CalcView", "ct.viewPosition", function( ply, pos, angles, fov )
        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        local view = {}
        view.origin = viewPos
        view.angles = LerpAngle(fraction, Angle(anglePx, anglePy, 0 ), viewAng)
        view.fov = viewFov
        view.drawviewer = true
        return view
    end)
end
cd = 1
function DisclaimerMain()
    cd = 1
    hook.Add( "PlayerButtonDown", "ct.Disclaimer", function( ply, button )
        if not IsFirstTimePredicted() then return end
        if not ply:Alive() then return end -- если игрок мёртв, выйти из функции

        if  button == 17 and !IsValid(monopad.Frame) then
            -- Условие. если аргумент еще не восстановился

            if delayDisclamer and enableCangeView and cd and cd == 1 or IsMono(ply:Pers()) then
                net.Start("classtrial.Disclaimer")
                    net.WriteEntity(ply)
                net.SendToServer()

                delayDisclamer = false

                timer.Create("ct.timer_1.8", 3.5, 1, function()


                    delaySound = true
                end)


                local fraction = 0
                local lerptime = 0.5
                hook.Add("Think", "ct.argTimer", function()
                    fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
                    if fraction == 0 then return end
                    argTimer = Lerp(fraction, 60, 0)
                end)

                timer.Create("ct.timer_1.9", 3, 1, function()

                    local fraction = 0
                    local lerptime = argueCoolDown
                    hook.Add("Think", "ct.argTimer", function()
                        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
                        if fraction == 0 then return end
                        argTimer = Lerp(fraction, 0, 60)
                    end)
                end)

                timer.Create("ct.timer_1.10", 60, 1, function()

                    delayDisclamer = true
                    delaySound = false
                end)
            end
        end
    end)
end


net.Receive( "classtrial.ChangeViewToPlayer", function()

    if not CanChageView then return end
    pastSpeaker = isSpeaker
    isSpeaker = net.ReadEntity()
    if gamest == 0 then return end
    if pastSpeaker == isSpeaker then return end
    if (not InGame(isSpeaker) or not isSpeaker:Pers()) and not IsMono(isSpeaker:Pers()) then return end
    if isSpeaker:IsTyping() then return end
    set_activiteplayer(isSpeaker)
    timer.Simple(0.2, function()

            if CanArgue == 1 then
                ArgueViewAnimation(isSpeaker:Pers())
                return
            else
                True_RandomViewAnimation()
            end

        if IsMono(isSpeaker:Pers()) then

            if ( isSpeaker != nil and pastSpeaker != nil ) then
                ViewPlayerToMonokuma()
            else
                ViewOnMonokuma()
            end

        elseif ( not IsValid(pastSpeaker) ) then
            AnimationViewNearToPlayer()
        elseif ( IsValid(isSpeaker) and IsValid(pastSpeaker) ) then
            AnimationViewOnPlayer()
        end
    end)

end)


function StarttClassTrial()

            for k,i in pairs(hook.GetTable().CalcView ) do
                hook.Remove("CalcView", k)
            end
            hook.Remove("HUDPaint", "ct.window")
            StartAnimationView() -- Движение камеры в начале
            ViewPostProcessing()
            timer.Create("classtrial", 1, 1, function()
                timer.Create("classtrial", 1, 1, function()
                    timer.Create("classtrial", 5, 1, function()
                        CanChageView = true
                        delayDisclamer = true --Разрешить аргументирование
                    end)
                    DrawSpritesMenu()
                   ---BulletShootMask()
                    local fraction = 0
                    local lerptime = argueCoolDown
                    hook.Add("Think", "ct.argTimer", function() -- полоса аргумента в начале
                        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
                        if fraction == 0 then return end
                        argTimer = Lerp(fraction, 0, 60)
                    end)
                end)
            end)
end



gamest = 0


net.Receive( "StartClassTrial", function()
    canfind = false
    gamest = 1
    timer.Remove("classtrial.RemoveFade")
    hook.Remove("PostDrawHUD", "classtrial.fade")
    allowcum = 1
    StarttClassTrial()
    pastSpeaker = nil
    isSpeaker = nil
    GDown = false

end)
calc_fr = 0
net.Receive( "EndClassTrial", function()
    gui.EnableScreenClicker(false)
        timer.Remove( "AutoPlay" )
    if IsValid(PlayingSong) then
        PlayingSong:Stop()
    end
    canfind = true
    gamest = 0
    CanChageView = false
    hook.Remove("HUDPaint", "ct.drum_show")
    hook.Remove("HUDPaintBackground", "ct.anim_class_trial_mask")
    hook.Remove("Think", "ct.st_fade")
    hook.Remove("CalcView", "ct.viewPosition")
    hook.Remove("HUDPaint", "ct.bullet_manager_mask")
    hook.Remove("Think", "ct.StartAnimationView")
    hook.Remove("StartCommand", "ct.NullControl")
    hook.Remove("RenderScreenspaceEffects", "ct.ColorExample")
    hook.Remove("Think", "ct.ThinkConditions")
    hook.Remove("StartCommand", "ct.NullControl")
    hook.Remove("CalcView", "ct.viewPosition")
    hook.Remove("Think", "ct.StartAnimationView")
    hook.Remove("PlayerStartVoice", "ImageOnVoice")
    hook.Remove("Think", "ct.viewPos")
    hook.Remove("PlayerButtonDown", "ct.Disclaimer")
    timer.Remove("bullet1") -- нужны для ремува таймеров
    timer.Remove("bullet2") -- нужны для ремува таймеров
    timer.Remove("bullet3") -- нужны для ремува таймеров
    timer.Remove("classtrial")
    timer.Remove("ct.timer_1.1")
    timer.Remove("ct.timer_1.2")
    timer.Remove("ct.timer_1.3")
    timer.Remove("ct.timer_1.4")
    timer.Remove("ct.timer_1.5")
    timer.Remove("ct.timer_1.6")
    timer.Remove("ct.timer_1.7")
    timer.Remove("ct.timer_1.8")
    timer.Remove("ct.timer_1.9")
    timer.Remove("ct.timer_1.10")
    timer.Remove("ct.timer_1.11")
    timer.Remove("ct.timer.muteAll")
    timer.Remove("ct.timer_sound")
    timer.Remove("ct.StopFade")
    timer.Remove("ct.StartFade")

    hook.Add( "CalcView", "dbt.CalcView.self", function( ply, pos, angles, fov )
    if not ply:Alive() then return end
	if not ply:IsValid() then return end
	if ply:GetNWBool("ragdolled", false) then return end

    if ply:GetActiveWeapon() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() and WL_Wep[ply:GetActiveWeapon():GetClass()] then CurView = angles return end
    if fp_enb then
        eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))
        local view = {
            origin = eyeAtt.Pos,
            angles = eyeAtt.Ang,
            fov = fov,
            drawviewer = true
        }

        return view
    else
        local view = {}
        eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))
        FT = FrameTime()
        cof_cam = 0.01
        if ply:IsRunning() then
            cof_cam = 0.2
        end

        if not CurView then
            CurView = angles
        else
            CurView = LerpAngle(mclamp(FT * (35 * (1 - mclamp(0.1, 0, 0.8))), 0, 1), CurView, angles + Angle(eyeAtt.Ang.p * cof_cam, 0, eyeAtt.Ang.r * 0.1))
        end

        if GDown then
            fov = fov - 10
        end

        view.origin = pos
        view.angles = CurView
        view.fov = fov
        view.znear = mclamp(0.4, 0.1, 1)
        view.drawviewer = false

        return view
    end

end )

	if IsValid(spritemenu) then
    	spritemenu:Remove()
	end
end)

local isVoicerecord = false
hook.Add("Think", "ct.VoicerecordCheck", function()
    local keyIsDown = false
    if IsValid(monopad.Frame) then return  end
    for key = 1, 170 do
        if input.LookupKeyBinding(key) == "+voicerecord" then
            keyIsDown = input.IsKeyDown(key)

            if keyIsDown then
                break
            end
        end
    end

    if not isVoicerecord and keyIsDown then
        isVoicerecord = true

        if (enableCangeView) then
            local localPlayer = LocalPlayer()
            if not localPlayer:IsTyping() then
                net.Start("classtrial.+voicerecord_ply")
                net.WriteEntity(localPlayer)
                net.SendToServer()
            end
        elseif (!enableCangeView) then return end

    elseif isVoicerecord and not keyIsDown then
        isVoicerecord = false
        local localPlayer = LocalPlayer()
            if not localPlayer:IsTyping() then
            net.Start("classtrial.-voicerecord_ply")
            net.WriteEntity(localPlayer)
            net.SendToServer()
        end
    end
end)
--
