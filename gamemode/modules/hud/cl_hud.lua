local KeyDown = KeyDown
local KeyPressed = KeyPressed
local KeyReleased = KeyReleased
local l_SetDrawColor = surface.SetDrawColor
local l_SetMaterial = surface.SetMaterial
local l_DrawTexturedRect = surface.DrawTexturedRect
local Material = Material
local Lerp = Lerp
local l_DrawText = draw.DrawText
local l_IsKeyDown = input.IsKeyDown
local l_RoundedBoxEx = draw.RoundedBoxEx
local Color = Color
local ClassTrial_Frame = Material("classtrial/classtrial_frame.png")
local low_hp = http.Material("https://imgur.com/bcPNVR4.png")
local ply = LocalPlayer()
local run_fraction = 0
local lerptime = 10
local alpha = 0
local stamina_ss = 100
local calc_fr = 0
local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()
local CircleColor = Color( 255, 255, 255, 100 )
local HurtColor = Color( 255, 0, 0, 128 )
local staminaalpha = 0
local col = Color(255, 255, 255)

local function weight_source(x)
    return ScreenWidth / 1920  * x
end

local function hight_source(x)
    return ScreenHeight / 1080  * x
end

local function Alpha(pr)
    return (255 / 100) * pr
end

hp_TS = 0

hook.Add("HUDShouldDraw","KDHideHUD",function( name )
  if name == "CHudHealth" or name == "CHudBattery" or name == "CHudVoiceSelfStatus" or name == "CHudVoiceStatus" then
    return false
  end
  if name == "CHudAmmo" and not AmmoHUD then
    return false
  end--
end)

hook.Add("DrawDeathNotice", "nodn", function()
  return 0,0
end)

function GM:HUDDrawTargetID()
  return false
end

function GM:HUDItemPickedUp()
  return false
end

hook.Add( "Think", "CheckPlayerForward", function()
    local ply = LocalPlayer()
    if ply:KeyReleased( IN_SPEED ) then
        run_fraction = 0
    end
    if ply:KeyPressed( IN_SPEED ) then
        run_fraction = 0
    end
end )
--[[
concommand.Add("test_blur", function()
    local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
    if IsValid(tr.Entity) then BLUR_OVER = tr.Entity end
end)


concommand.Add("test_osmotr", function()
    gui.EnableScreenClicker(true)
end)

hook.Add( "PostDrawTranslucentRenderables", "Stencil Tutorial Example", function()
	local trace = util.TraceLine( {
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + gui.ScreenToVector(gui.MousePos()) * 1024,
	} )

    render.DrawSphere( trace.HitPos, 2, 30, 30, Color( 0, 175, 175, 100 ) )
end)

hook.Add("RenderScreenspaceEffects", "BlurScreenExceptEntity", function()

    if false and IsValid(BLUR_OVER) then
        BlurScreen(24)


        cam.Start3D()
        BLUR_OVER:SetRenderMode(RENDERMODE_TRANSCOLOR)
        BLUR_OVER:DrawModel()
        cam.End3D()
    end
end)

local minDistance = 35  -- Минимальное расстояние от камеры до энтити

-- Функция для установки камеры
hook.Add("CalcView", "EntityCameraView", function(ply, pos, angles, fov)
    if 1 then return  end
    local targetEntity = BLUR_OVER
    if not IsValid(targetEntity) then return end

    local entityPos = targetEntity:GetPos()
    local view = {}

    -- Вычисляем желаемую позицию камеры, отступив назад на минимальную дистанцию
    local cameraPos = entityPos - (angles:Forward() * minDistance)

    -- Выполняем трассировку, чтобы проверить, не заходит ли камера в стену
    local traceData = {
        start = entityPos,
        endpos = cameraPos,
        filter = {targetEntity, ply}
    }
    local traceResult = util.TraceLine(traceData)

    -- Если трассировка столкнулась с препятствием, перемещаем камеру ближе к энтити
    if traceResult.Hit then
        cameraPos = traceResult.HitPos + traceResult.HitNormal * 5  -- Отступаем немного от препятствия
    end

    -- Устанавливаем параметры вида камеры
    view.origin = cameraPos
    view.angles = (entityPos - cameraPos):Angle()  -- Направляем камеру на энтити
    view.fov = fov

    return view
end)]]


local partriet = {
	{ x = dbtPaint.WidthSource(1615), y = dbtPaint.HightSource(564)},
	{ x = dbtPaint.WidthSource(1876), y = dbtPaint.HightSource(535)},
	{ x = dbtPaint.WidthSource(1850), y = dbtPaint.HightSource(903)},
	{ x = dbtPaint.WidthSource(1548), y = dbtPaint.HightSource(838)},
}

croshair_mat2 = http.Material("https://imgur.com/bih6VYm.png")
BLUR_OVER = BLUR_OVER or nil
SoundScare = true
StaminaLerp = nil
hook.Add("HUDPaint", "dbt.HudMain", function()
    local ply = LocalPlayer()


    local hp = ply:Health()
    local hpMax = ply:GetMaxHealth()
    if GDown then
        calc_fr = Lerp(FrameTime(), calc_fr, 10)
    else
        calc_fr = Lerp(FrameTime() * 5, calc_fr, 0)
    end

    /*if IsGame() and InGame(ply) and ply:Pers() != "K1-B0" then

        local stamina_ss = Lerp(2 * FrameTime(), stamina_ss, ply:GetNWInt("Stamina"))

        if ply:GetNWInt("Stamina") <= 80 or ply:IsRunning()  then
            run_fraction = math.Clamp(run_fraction + FrameTime()/lerptime, 0, 1)
            if run_fraction == 0 then return end

            local alpha = Lerp(run_fraction, alpha, 255)
            l_RoundedBoxEx(9, 90,  ScreenHeight * 0.97 - 32.5 ,200, 15, Color(0,0,0,alpha - 100), true, true, true, true)
            l_RoundedBoxEx(9, 90,  ScreenHeight * 0.97 - 32.5 , stam ina_ss * 2, 15, Color(255,255,255,alpha), true, true, true, true)
        else
            run_fraction = math.Clamp(run_fraction + FrameTime()/lerptime, 0, 1)
            if run_fraction == 0 then return end

            local alpha = Lerp(run_fraction, alpha, 0)

            l_RoundedBoxEx(9, 90,  ScreenHeight * 0.97 - 32.5 ,200, 15, Color(0,0,0,alpha - 100), true, true, true, true)
            l_RoundedBoxEx(9, 90,  ScreenHeight * 0.97 - 32.5 , stamina_ss * 2, 15, Color(255,255,255,alpha), true, true, true, true)
        end
    end
	*/
    if IsGame() and InGame(ply) and ply:Pers() != "K1-B0" and not ply.isSpect then
        if not isnumber(StaminaLerp) then
            StaminaLerp = ply:GetNWInt("Stamina")
        end
        local char = dbt.chr[ply:Pers()] 
        StaminaLerp = Lerp(FrameTime() * 10, StaminaLerp, ply:GetNWInt("Stamina"))
        local staminacol = StaminaLerp * 2.5
        local barWidth = (StaminaLerp / char.maxStamina)
        local barX, barY = 90, ScreenHeight * 0.97 - 32.5
        local barColor = Color(col.r, col.g, col.b, staminaalpha)
        local needShow = (barWidth < 0.95)
        if needShow then
            staminaalpha = Lerp(FrameTime() * 10, staminaalpha, 255)
        else
            staminaalpha = Lerp(FrameTime() * 10, staminaalpha, 0)
        end
		if LocalPlayer():GetVelocity():LengthSqr() == 0 then
			col = col:Lerp(Color(170, 98, 201, staminaalpha), FrameTime()*5)
        elseif barWidth < 0.3 then
            col = col:Lerp(Color(255, 0, 0, staminaalpha), FrameTime()*5)
        else
            col = col:Lerp(Color(255, 255, 255, staminaalpha), FrameTime()*5)
        end
        -- Рисование полосы стамины
        l_RoundedBoxEx(9, barX, barY, 200, 15, Color(0, 0, 0, staminaalpha - 100), true, true, true, true)
        l_RoundedBoxEx(9, barX, barY, 200 * barWidth, 15, barColor, true, true, true, true)
    end


	if ply:GetNWBool("PoisonedMethanolLastEffect") or ply:GetNWBool("PoisonedKCN") then
		l_SetDrawColor( 255, 0, 0, 255)
		low_hp:Draw(0, 0, ScreenWidth, ScreenHeight)
		surface.PlaySound("player/low_hp.mp3")
   end

    if hp <= 30 then
        if ply:GetNWBool("Adrenaline") then
            if SoundScare then surface.PlaySound("player/lowhp_atmo.mp3") SoundScare = false end
            if hp_TS_Reverse then hp_TS = hp_TS - 0.05 else hp_TS = hp_TS + 0.03 end
            if hp_TS >= 1 then surface.PlaySound("player/adren_low_hp.mp3") end
            if hp_TS >= 1 then hp_TS_Reverse = true hp_TS = 0.9 elseif hp_TS <= 0 then hp_TS_Reverse = false end
        else
            SoundScare = true
            if hp_TS_Reverse then
                if hp <= 20 then
                    hp_TS = hp_TS - 0.03
                 else
                    hp_TS = hp_TS - 0.01
                end
            else
                if hp <= 20 then
                    hp_TS = hp_TS + 0.01
                else
                    hp_TS = hp_TS + 0.005
                end
            end
            if hp_TS == 0.78 and hp <= 20 then
                surface.PlaySound("player/low_hp.mp3")
            end
            if hp_TS >= 1 then
                hp_TS_Reverse = true
                hp_TS = 0.9
            elseif hp_TS <= 0 then
                hp_TS_Reverse = false
            end

        end
        if hp <= 20 then
            l_SetDrawColor( 255, 0, 0, 255 * hp_TS )
            low_hp:Draw(0, 0, ScreenWidth, ScreenHeight)
        elseif hp <= 30 then
            l_SetDrawColor( 255, 0, 0, 50 * hp_TS )
            low_hp:Draw(0, 0, ScreenWidth, ScreenHeight)
        end
   else
    hp_TS = 0
   end

    if HelpText then
        surface.DrawMulticolorText(ScreenWidth * 0.37, ScreenHeight*0.968, "Comfortaa X30", HelpText, 1000)
    end

    if TipsText then
        if TipsTime < CurTime() then TipsText = false end
        l_DrawText(TipsText, "Comfortaa X40", ScreenWidth / 2, ScreenHeight * 0.95, Color(255,255,255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if TargetPlayer then
        local tr = util.TraceLine( util.GetPlayerTrace( ply ) )
        if tr.Entity != TargetPlayer or ply:GetPos():Distance(TargetPlayer:GetPos()) > 50 then dbt_emote.wheel:Remove() TargetPlayer = nil end
    end
    if ply:GetNWInt("VerySleepy") == 1 then
        draw.RoundedBox( 0, 0, 0, ScreenWidth, ScreenHeight , Color( 0, 0, 0, 255 * math.sin(CurTime()) ) )
    end

	if disablebuild or q_alpha >= 1 then

	else
		draw.SimpleText( BUILD, "Comfortaa X20", ScreenWidth - 2, 0, Color(255,255,255, 150), TEXT_ALIGN_RIGHT )
	end
    if not GetGlobalBool("IsConnectedCoordinal") and ply:IsAdmin() then
        -- draw.SimpleText( "Ошибка подключения к кардиналу, выдать доступ на сервер невозможно.", "Comfortaa X20", 2, ScreenHeight - 20, Color(255,255,255, 150), TEXT_ALIGN_LEFT )
    end
    showcroshair = GetConVar("showcroshair"):GetInt()

    if IsValid(ply:GetActiveWeapon()) and showcroshair == 1 and ply:GetActiveWeapon():GetClass() == "hands" and !ply:GetActiveWeapon().drag and not IsClassTrial() and not NotShowCross and not ply.isSpect and q_alpha < 100 and !IsValid(dbt_emote.wheel) then
        l_SetDrawColor( 255, 255, 255, 255 )
       croshair_mat:DrawR(ScreenWidth / 2, ScreenHeight / 2, weight_source(226),weight_source(226),0)
    end
end)
croshair_mat = http.Material("https://imgur.com/9kMiDiW.png")
hook.Add( "PlayerHurt", "dbt/PlayerHurt/Effect", function( ply )
    ply:ScreenFade( SCREENFADE.IN, HurtColor, 0.3, 0 )
end )

net.Receive("Hungred", function()
    chat.AddText( Color( 100, 100, 255 ), "[#Подсказка] ", Color( 100, 255, 100 ), "Вы проголодались" )
end)

local noise = {}

for i = 0, 99 do
    noise[i] = Material("noise/white_noise-"..i..".png", "mips")
end
iss = 0

local mini_s = {
    [1] = 16,
    [2] = 10,
    [3] = 17
}

net.Receive("Noise.Start", function() local number = net.ReadFloat() is_noise = true timer.Simple(mini_s[number], function() is_noise = false end) end)

hook.Add("HUDPaint", "dbt.Noise", function()
    if is_noise then
        iss = iss + 1
        if iss == 100 then iss = 0 end
        l_SetDrawColor( 255, 255, 255, 50 )
        l_SetMaterial( noise[iss] )
        l_DrawTexturedRect( 0, 0, ScreenWidth, ScreenHeight)
    end
end)

hook.Add( "PlayerSwitchWeapon", "dbt/PlayerSwitchWeapon/Text", function( ply, oldWeapon, newWeapon )
    if newWeapon:GetClass() == "nightvision" then
        HelpText = {"Нажмите ", Color( 139, 12, 161 ), "N", color_white," для включения и отключения ПНВ"}
        timer.Simple(3, function()
            HelpText = nil
        end)
    end
end )

TimerCircle = circles.New(CIRCLE_OUTLINED, 23, ScreenWidth / 2, ScreenHeight / 2, weight_source(8))
TimerCircle:SetColor(Color(255, 255, 255, 255) )
TimerCircle:SetEndAngle(1)

function dbt.ShowTimerTarget(seconds, name, target, callback, cancelCallback)
    timer.Create("TargetTimer", seconds, 1, function()
            if callback then callback() end
            hook.Remove("HUDPaint", "TargetTimer")
    end)
    hook.Add("HUDPaint", "TargetTimer", function()
            local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
            if (not IsValid(target)) or tr.Entity ~= target then
                hook.Remove("HUDPaint", "TargetTimer")
                timer.Remove("TargetTimer")
                netstream.Start("dbt/player/stopsound")
                if cancelCallback then cancelCallback() end
                return
            end
            local ang = 360 - (timer.TimeLeft("TargetTimer") / seconds) * 360
            TimerCircle:SetEndAngle(ang)
            TimerCircle()

            draw.SimpleText(
                name, "Comfortaa X40", ScreenWidth / 2, ScreenHeight / 2 + hight_source(50),
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )

    end)

end

 function dbt.ShowTimer(seconds, name, target, callback)
  timer.Create("TargetTimer", seconds, 1, function()
      callback()
      hook.Remove("HUDPaint", "TargetTimer")
  end)
  hook.Add("HUDPaint", "TargetTimer", function()
      local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
      local ang = 360 - (timer.TimeLeft("TargetTimer") / seconds) * 360
      TimerCircle:SetEndAngle(ang)
      TimerCircle()

      draw.SimpleText(
        name, "Comfortaa X40", ScreenWidth / 2, ScreenHeight / 2 + hight_source(50),
        Color(255, 255, 255, 255),
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
      )

  end)

end

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.04,
	["$pp_colour_contrast"] = 1.35,
	["$pp_colour_colour"] = 5,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}


local matColor = Material( "pp/colour" )
hook.Add( "RenderScreenspaceEffects", "ct.ColorExample", function()
        render.UpdateScreenEffectTexture()
        matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
        --matColor:SetFloat( "$pp_colour_addr", 0.5 )
        --matColor:SetFloat( "$pp_colour_addg", 0.45 )
        --matColor:SetFloat( "$pp_colour_addb", 0.4 )
        matColor:SetFloat( "$pp_colour_contrast", 1.6 )
        matColor:SetFloat( "$pp_colour_colour", 1 )
        matColor:SetFloat( "$pp_colour_brightness", -0.55 )
        render.SetMaterial( matColor )
       --  render.DrawScreenQuad()

end)
