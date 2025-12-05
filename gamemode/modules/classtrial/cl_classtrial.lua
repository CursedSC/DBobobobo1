argue_bg = Material("classtrial/argue_bg.png")

argue = Material("classtrial/argue.png")

argue_letters_active = Material("classtrial/argue_letters_active.png")

argue_letters = Material("classtrial/argue_letters.png")

blot_argue_top = Material("classtrial/argue_top.png")

	x_b = 0
	y_b = 0
local matParam = nil
start_cd = false
local wsc = 1
local wsc2 = 0
local wsc3 = 0
local wsc4 = 0
local mot = 0
local size_circles = 1.1
local hud_logo_tr = 0
local classtrial_timer = 0
class_trial_alpha = class_trial_alpha or true
AngAnimBig, SpeedAnimBig = 0, -70
AngAnimSmall, SpeedAnimSmall = 0, 50
AngAnimDrug, SpeedAnimDrug = 0, 10

local trial_underbg = Material("dbt/classtrial/trial_underbg.png")
local trial_lines = Material("dbt/classtrial/trial_lines.png")
local trial_lines_options = Material("dbt/classtrial/trial_lines_underoptions.png")
local drum = Material( "classtrial/cl_clock.png", matParam )
local circles_big = Material( "classtrial/cl_a1.png", matParam )
local circles_small = Material( "classtrial/cl_a2.png", matParam )
local bullet_b = Material( "classtrial/sadsa.png", matParam )
local trial_filter = Material("dbt/classtrial/trial_filter.png", "smooth")
local trial_bullet = Material("dbt/classtrial/trial_bullet.png", "smooth")
local trial_clocks = Material("dbt/classtrial/trial_clocks.png", "smooth")

local partriet = {
	{ x = dbtPaint.WidthSource(1615), y = dbtPaint.HightSource(564)},
	{ x = dbtPaint.WidthSource(1876), y = dbtPaint.HightSource(535)},
	{ x = dbtPaint.WidthSource(1850), y = dbtPaint.HightSource(1037)},
	{ x = dbtPaint.WidthSource(1548), y = dbtPaint.HightSource(838)},
}

hook.Add("Think", "ct.RotateS", function()
	local now = RealTime()
	if RotateTime then
		AngAnimBig = AngAnimBig + SpeedAnimBig * (now - RotateTime)
		AngAnimBig = AngAnimBig % 360

		AngAnimSmall = AngAnimSmall + SpeedAnimSmall * (now - RotateTime)
		AngAnimSmall = AngAnimSmall % 360
		if endanim then
		AngAnimDrug = AngAnimDrug + SpeedAnimDrug * (now - RotateTime)
		AngAnimDrug = AngAnimDrug % 360
		end
	end
	RotateTime = now
end)

local vector_one = Vector( 1, 1, 1 )
function draw.RotatedText( text, font, x, y, color, ang, scale )
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	local m = Matrix()
	m:Translate( Vector( x, y, 0 ) )
	m:Rotate( Angle( 0, ang, 0 ) )
	m:Scale( vector_one * ( scale or 1 ) )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	m:Translate( Vector( -w / 2, -h / 2, 0 ) )

	cam.PushModelMatrix( m, true )
		draw.DrawText( text, font, 0, 0, color )
	cam.PopModelMatrix()

	render.PopFilterMag()
	render.PopFilterMin()
end

function draw.RotatedTextColorify( text, font, x, y, color, ang, scale, extra_text )
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	local m = Matrix()
	m:Translate( Vector( x, y, 0 ) )
	m:Rotate( Angle( 0, ang, 0 ) )
	m:Scale( vector_one * ( scale or 1 ) )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( extra_text )

	m:Translate( Vector( -w / 2, -h / 2, 0 ) )

	cam.PushModelMatrix( m, true )
		surface.DrawMulticolorText(0, 0, font, text)
	cam.PopModelMatrix()

	render.PopFilterMag()
	render.PopFilterMin()
end


local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()

local function weight_source(x)
    return ScreenWidth / 1920  * x
end

local function hight_source(x)
    return ScreenHeight / 1080  * x
end

local function Alpha(pr)
    return (255 / 100) * pr
end

local partriet = {
	{ x = dbtPaint.WidthSource(1615), y = dbtPaint.HightSource(564)},
	{ x = dbtPaint.WidthSource(1876), y = dbtPaint.HightSource(535)},
	{ x = dbtPaint.WidthSource(1852), y = dbtPaint.HightSource(905)},
	{ x = dbtPaint.WidthSource(1548), y = dbtPaint.HightSource(838)},
}

function AnimationClassTrialMask()
	classtrial_timer = CurTime()
	bullet_alpha = 255
	bull_anim_x = 620
	bull_anim_y = 952
	bull_fade = 0
	start_cd = false
	local tb_b_tr = 0;	tb_l_tr = 0;	tb_t_tr = 0;
	local tb_b_x = 0;	tb_l_x = -50;	tb_t_x = -50;
	local tb_b_y = 55;	tb_l_y = 6; 	tb_t_y = 6;
	local ani_hud_right_x = 2200
	local ani_hud_down_y = 1480
	local ani_drum_x = -300
	local hud_bg_tr = 0
	local hud_logo_tr = 0
	drum_rotate = 0
	pos_drum = -300
	local tr_line = 0
	local ani_bullet_x = -220
	local ani_bullet_y = 970

	timer.Create('classtrial_timer', 0, FrameTime(),function ()
		classtrial_timer_string = CurTime() - classtrial_timer
	end)

	timer.Create("ct.timer_7", 0, 1, function()

		local fraction = 0
		local lerptime = 1
		hook.Add("Think", "ct.anim_hud", function()
			fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
			if fraction == 0 then return end
			ani_hud_right_x = Lerp(fraction, 2200, 0)
			ani_hud_down_y = Lerp(fraction, 1480, 810)
		end)
		timer.Simple(5, function()
			ani_hud_right_x = 0
		end)
		timer.Create("ct.timer_7", 1.1, 1, function()

			local fraction = 0
			local lerptime = 0.1
			hook.Add("Think", "ct.anim_hud", function()
				fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
				if fraction == 0 then return end
				tr_line = Lerp(fraction, 0, 255)
				ani_drum_x = Lerp(fraction, -300, 90)
				pos_drum = Lerp(fraction, -300, 90)
				hud_bg_tr = Lerp(fraction, 0, 200)
			end)
			timer.Create("ct.timer_7", 0.2, 1, function()

				local fraction = 0
				local lerptime = 0.1
				hook.Add("Think", "ct.anim_hud", function()
					fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
					if fraction == 0 then return end
					drum_rotate = Lerp(fraction, 0, 180)
					hud_logo_tr = Lerp(fraction, 0, 255)
					tb_l_tr = Lerp(fraction, 0, 255)
					tb_l_x = Lerp(fraction, -50, 0)
					tb_l_y = Lerp(fraction, 6, 55)
				end)
				timer.Create("ct.timer_7", 0.2, 1, function()

					local fraction = 0
					local lerptime = 0.1
					hook.Add("Think", "ct.anim_hud", function()
						fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
						if fraction == 0 then return end
						drum_rotate = Lerp(fraction, 180, 360)
						tb_t_tr = Lerp(fraction, 0, 255)
						tb_t_x = Lerp(fraction, -50, 0)
						tb_t_y = Lerp(fraction, 60, 55)
						tb_b_tr = Lerp(fraction, 0, 255)
					end)
					timer.Create("bullet3", argueCoolDown - 0.5, 1, function() -- Анимация выезда пули в начале
					end)
				end)
			end)
		end)
	end)

	--====================================================
	-- ТЕЛО HUDPaint
	--====================================================
	hook.Remove("HUDPaintBackground", "ct.anim_class_trial_mask")
	hook.Add("HUDPaintBackground", "ct.anim_class_trial_mask", function()
		--[[
		if not start_cd then
			surface.SetMaterial( Material("classtrial/cl_bullet.png") )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( x_b, y_b, ScrW(), ScrH())
		end]]

		-- TB LINES
		surface.SetDrawColor( 255, 255, 255, 20 )
		surface.SetMaterial(trial_filter)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		surface.SetDrawColor( 255, 255, 255, class_trial_alpha )
		surface.SetMaterial( trial_underbg )
		surface.DrawTexturedRect( ScrW()*(0/1920),  ScrH()*(-ani_hud_right_x/1080), ScrW(), ScrH())
		surface.SetMaterial( trial_clocks )
		surface.DrawTexturedRect( weight_source(-245),  ScrH()*(ani_hud_right_x/1080) + hight_source(560), weight_source(800), hight_source(800))
		surface.SetTextPos(weight_source(545),  ScrH()*(ani_hud_right_x/1080) + hight_source(980))
		if IsValid(isSpeaker) and dbt.chr[isSpeaker:Pers()] then
				local data = dbt.chr[isSpeaker:Pers()]


				surface.SetMaterial( Material("dbt/characters"..data.season.."/char"..data.char.."/trial_pic.png") )
				surface.SetDrawColor( 255, 255, 255, class_trial_alpha )
				surface.DrawTexturedRect( ScrW()*(0/1920),  ScrH()*(-ani_hud_right_x/1080), ScrW(), ScrH())


		end

		-- TB LINESц3
		surface.SetMaterial( trial_lines )
		surface.SetDrawColor( 255, 255, 255, class_trial_alpha )
		surface.DrawTexturedRect( ScrW()*(0/1920),  ScrH()* -1 * (ani_hud_right_x/1080), ScrW(), ScrH())
		surface.SetMaterial(trial_lines_options)
		local widthscr, heightscr = ScrW(), ScrH()
		surface.DrawTexturedRect( weight_source(-68), ScrH() * (-ani_hud_right_x/1080) + hight_source(412), weight_source(474), hight_source(156))
		surface.SetMaterial(Material('dbt/classtrial/cases/trial_ch_'..math.Clamp(GetGlobalInt("round", 0), 1, 6)..'_case.png'))
		surface.DrawTexturedRect(weight_source(1670), ScrH() * (-ani_hud_right_x/1080) + heightscr*0.375, weight_source(160), hight_source(109))

		draw.RotatedText(string.ToMinutesSecondsMilliseconds(classtrial_timer_string), 'Comfortaa X60', widthscr*0.233, ScrH() * (-ani_hud_right_x/1080) + heightscr*0.14, Color(255, 255, 255, class_trial_alpha), -58, 1)

		if IsValid(isSpeaker) and dbt.chr[isSpeaker:Pers()] then
				local data = dbt.chr[isSpeaker:Pers()]




				surface.SetFont( "Comfortaa X53" )

				local text = CharacterNameOnName(isSpeaker:Pers())
				local firstWord = utf8.GetChar( text, 1 )
				local textR = utf8.sub( text, 2 )
				if utf8.len(text) >= 15 then
					draw.RotatedTextColorify({Color(190, 0, 223, class_trial_alpha), firstWord, Color(255, 255, 255, class_trial_alpha), textR}, 'Comfortaa X46', widthscr*0.9, ScrH() * (ani_hud_right_x/1080) + heightscr*0.835, Color(255, 255, 0, class_trial_alpha), 12, 1, text)
				else
				--draw.RotatedText(isSpeaker:Pers(), 'Comfortaa X53', widthscr*0.9, heightscr*0.835, Color(255, 255, 255, class_trial_alpha), 12, 1)
					draw.RotatedTextColorify({Color(190, 0, 223, class_trial_alpha), firstWord, Color(255, 255, 255, class_trial_alpha), textR}, 'Comfortaa X56', widthscr*0.9, ScrH() * (ani_hud_right_x/1080) + heightscr*0.835, Color(255, 255, 0, class_trial_alpha), 12, 1, text)
				end

			--end
		end


		--[[
		surface.SetMaterial( Material("classtrial/cl_3.png") )
		surface.SetDrawColor( 255, 255, 255, class_trial_alpha )
		surface.DrawTexturedRect( ScrW()*(0/1920),  ScrH()*(ani_hud_right_x/1080), ScrW(), ScrH())]]

	end)
end

function set_activiteplayer( ply )
	isSpeaker = ply
end

function DrumShow()
	local motion_drum = 0
	local rotate_drum = 0

	local motion_bullet_x_1 = 2200
	local motion_bullet_y_1 = 410

	local motion_bullet_x_2 = 2200
	local motion_bullet_y_2 = 410

	local motion_bullet_x_3 = 2200
	local motion_bullet_y_3 = 410

	local motion_bullet_x_4 = 2200
	local motion_bullet_y_4 = 410

	local motion_bullet_x_5 = 2200
	local motion_bullet_y_5 = 410

	local fade_bullet_1 = 255
	local fade_bullet_2 = 255
	local fade_bullet_3 = 255
	local fade_bullet_4 = 255
	local fade_bullet_5 = 0

	-- ВЫДВИНУТЬ БАРАБАН
	timer.Create("ct.timer_5", 0, 1, function()

		local fraction = 0
		local lerptime = 0.3
		hook.Add("Think", "ct.drum", function()
			fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
			if fraction == 0 then return end
			motion_drum = Lerp(fraction, 0, 200)
		end)
		-- ПРОВОРОТ БАРАБАНА 3 РАЗА
		-- 1 БАРАБАН
		timer.Create("ct.timer_5", 0.5, 1, function()

			local fraction = 0
			local lerptime = 0.2
			hook.Add("Think", "ct.drum", function()
				fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
				if fraction == 0 then return end
				rotate_drum = Lerp(fraction, 0, 60)
			end)
			--ПУЛЯ 1
			timer.Create("ct.timer_5", 0.1, 1, function()

				local fraction = 0
				local lerptime = 0.2
				hook.Add("Think", "ct.bullet", function()
					fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
					if fraction == 0 then return end
					motion_bullet_x_1 = Lerp(fraction, 2200, 700)
					motion_bullet_y_1 = Lerp(fraction, 410, 540)
				end)
				-- ПУЛЯ 1
				timer.Create("ct.timer_5.2", 0.2, 1, function()
					local fraction = 0
					local lerptime = 0.1
					hook.Add("Think", "ct.bullet", function()
						fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
						if fraction == 0 then return end
						motion_bullet_x_1 = Lerp(fraction, 700, 680)
						motion_bullet_y_1 = Lerp(fraction, 540, 440)
					end)
				end)
				-- 2 БАРАБАН
				timer.Create("ct.timer_5", 0.5, 1, function()

					local fraction = 0
					local lerptime = 0.2
					hook.Add("Think", "ct.drum", function()
						fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
						if fraction == 0 then return end
						rotate_drum = Lerp(fraction, 60, 120)
					end)
					-- ПУЛЯ 2
					timer.Create("ct.timer_5", 0.1, 1, function()

						local fraction = 0
						local lerptime = 0.2
						hook.Add("Think", "ct.bullet", function()
							fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
							if fraction == 0 then return end
							motion_bullet_x_2 = Lerp(fraction, 2200, 700)
							motion_bullet_y_2 = Lerp(fraction, 410, 540)
						end)
						-- ПУЛЯ 2
						timer.Create("ct.timer_5", 0.2, 1, function()

							local fraction = 0
							local lerptime = 0.1
							hook.Add("Think", "ct.bullet", function()
								fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
								if fraction == 0 then return end
								motion_bullet_x_2 = Lerp(fraction, 700, 680)
								motion_bullet_y_2 = Lerp(fraction, 540, 440)

								motion_bullet_x_1 = Lerp(fraction, 680, 660)
								motion_bullet_y_1 = Lerp(fraction, 440, 320)

								fade_bullet_1 = Lerp(fraction, 255, 0)

								motion_bullet_x_4 = Lerp(fraction, 680, 720)
								motion_bullet_y_4 = Lerp(fraction, 740, 660)

								fade_bullet_4 = Lerp(fraction, 0, 255)
							end)
								-- 2 БАРАБАН
							timer.Create("ct.timer_5", 0.5, 1, function()

								local fraction = 0
								local lerptime = 0.2
								hook.Add("Think", "ct.drum", function()
									fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
									if fraction == 0 then return end
									rotate_drum = Lerp(fraction, 120, 180)
								end)
								-- ПУЛЯ 3
								timer.Create("ct.timer_5", 0.1, 1, function()

									local fraction = 0
									local lerptime = 0.2
									hook.Add("Think", "ct.bullet", function()
										fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
										if fraction == 0 then return end
										motion_bullet_x_3 = Lerp(fraction, 2200, 700)
										motion_bullet_y_3 = Lerp(fraction, 410, 540)
									end)
									-- ПУЛЯ 3
									timer.Create("ct.timer_5", 0.2, 1, function()

										local fraction = 0
										local lerptime = 0.1
										hook.Add("Think", "ct.bullet", function()
											fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
											if fraction == 0 then return end
											motion_bullet_x_3 = Lerp(fraction, 700, 680)
											motion_bullet_y_3 = Lerp(fraction, 540, 440)

											motion_bullet_x_2 = Lerp(fraction, 680, 660)
											motion_bullet_y_2 = Lerp(fraction, 440, 320)

											fade_bullet_2 = Lerp(fraction, 255, 0)

											motion_bullet_x_4 = Lerp(fraction, 680, 700)
											motion_bullet_y_4 = Lerp(fraction, 660, 560)

											motion_bullet_x_1 = Lerp(fraction, 680, 720)
											motion_bullet_y_1 = Lerp(fraction, 740, 680)

											fade_bullet_1 = Lerp(fraction, 0, 255)
										end)
										timer.Create("ct.timer_5", 0.2, 1, function()

											local fraction = 0
											local lerptime = 0.2
											hook.Add("Think", "ct.bullet", function()
												fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
												if fraction == 0 then return end
												motion_bullet_x_5 = Lerp(fraction, 700, 860)
												motion_bullet_y_5 = Lerp(fraction, 560, 545)

												fade_bullet_5 = 255
												fade_bullet_4 = 0
												fade_bullet_4 = 0
											end)
											timer.Create("ct.timer_5", 5, 1, function()

												local fraction = 0
												local lerptime = 0.2
												hook.Add("Think", "ct.bullet", function()
													fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
													if fraction == 0 then return end
													motion_bullet_x_1 = Lerp(fraction, 720, 700)
													motion_bullet_y_1 = Lerp(fraction, 680, 560)

													motion_bullet_x_2 = Lerp(fraction, 660, 700)
													motion_bullet_y_2 = Lerp(fraction, 320, 560)

													motion_bullet_x_3 = Lerp(fraction, 680, 700)
													motion_bullet_y_3 = Lerp(fraction, 440, 560)

													motion_bullet_x_5 = Lerp(fraction, 860, 700)
													motion_bullet_y_5 = Lerp(fraction, 545, 560)

													fade_bullet_1 = Lerp(fraction, 255, 0)
													fade_bullet_3 = Lerp(fraction, 255, 0)
													fade_bullet_5 = Lerp(fraction, 255, 0)
												end)
												-- УБРАТЬ БАРАБАН
												timer.Create("ct.timer_5", 0, 1, function()

													local fraction = 0
													local lerptime = 0.3
													endanim = true
													hook.Add("Think", "ct.drum", function()
														fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
														if fraction == 0 then return end

													end)
												end)
											end)
										end)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
	alpha_b = 255
	hook.Add("HUDPaint", "ct.bullet_manager_mask", function()
		--if IsMono(LocalPlayer():Pers()) then return end
		if !start_cd then
			x_b = Lerp(FrameTime() * 2.5, x_b, ScrW())
			y_b = Lerp(FrameTime() * 3, y_b, -80)
		end

		if start_cd and timer.TimeLeft("ct.timer.arg") then
			cd = (60 - timer.TimeLeft("ct.timer.arg")) / 60
			alpha_b = Lerp(FrameTime() * 3, alpha_b, 255)


			surface.SetMaterial( Material("classtrial/cl_bullet.png") )
			surface.SetDrawColor( 100, 100, 100, alpha_b )
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH())

			render.SetScissorRect( weight_source(490), 0, weight_source(490) + weight_source(554) * cd, ScrH(), true )
				surface.SetDrawColor( 255, 255, 255, alpha_b )
				surface.SetMaterial( Material("classtrial/cl_bullet.png") )
				surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
			render.SetScissorRect( x_b, y_b, ScrW(), ScrH(), false )

		elseif start_cd and not timer.TimeLeft("ct.timer.arg") then
			cd = 1
			start_cd = false
		else
			surface.SetDrawColor( 255, 255, 255, alpha_b )
			surface.SetMaterial( Material("classtrial/cl_bullet.png") )
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		end

	end)
end


local red_mins = {
	[0] = 5,
	[1] = 4,
	[2] = 3,
	[3] = 2,
	[4] = 1,
	[5] = -1,
	[6] = -2,
	[7] = -3,
	[8] = -3,
	[9] = -3,
	[10] = -2,
	[11] = -1,
	[12] = 1,
	[13] = 2,
	[14] = 4,
	[15] = 5,
}

hook.Add("PostDrawOpaqueRenderables", "dbt.Show.Pos", function()
	if IsGame() and not IsMono(LocalPlayer():Pers()) and InGame(LocalPlayer()) and Spots and Spots[LocalPlayer():GetNWInt("Index")]then --
		local angle = EyeAngles()

		angle = Angle( 0, angle.y, 0 )

		angle.y = angle.y + math.sin( CurTime() ) * 10

		angle:RotateAroundAxis( angle:Up(), -90 )
		angle:RotateAroundAxis( angle:Forward(), 90 )



		cam.Start3D2D( GPS_POS[LocalPlayer():GetNWInt("Index")], angle, 0.1 ) -- Spots[LocalPlayer():GetNWInt("Index")].pos
			mins = red_mins[LocalPlayer():GetNWInt("Index")] or 0
			local text = "Ваше место на суде"
			surface.SetFont( "Default" )
			local tW, tH = surface.GetTextSize( "Ваше место на суде" )
			local tW = tW + mins
			local pad = 5

			surface.SetDrawColor( 0, 0, 0, 200 )
			surface.DrawRect( -tW / 1.5, -pad * 1.5, tW + pad * 6, tH + pad * 3 )


			surface.SetDrawColor( 100, 100, 100, 200 )
			surface.DrawRect( -tW / 1.5, -pad * 1.5, tW + pad * 6, 2 )

			surface.SetDrawColor( 100, 100, 100, 200 )
			surface.DrawRect( -tW / 1.5, -pad * 1.5 , 2, tH + pad * 3 )

			surface.SetDrawColor( 100, 100, 100, 200 )
			surface.DrawRect( -tW / 1.5, -pad * 1.5 + tH + pad * 2.9 , tW + pad * 6, 2 )

			surface.SetDrawColor( 100, 100, 100, 200 )
			surface.DrawRect( -tW / 1.5 + tW + pad * 5.9, -pad * 1.5 , 2, tH + pad * 3 )
		cam.End3D2D()

		cam.Start3D2D( GPS_POS[LocalPlayer():GetNWInt("Index")], angle, 0.01 ) -- Spots[LocalPlayer():GetNWInt("Index")].pos

		local text = "Ваше место на суде"
		surface.SetFont( "CLASS" )
		local tW, tH = surface.GetTextSize( "Ваше место на суде" )
		draw.SimpleText( "Ваше место на суде", "CLASS", -tW / 2, 0, color_white )


		cam.End3D2D()

	end
end )


function ArgueManagerMask(pers)
	if 1 == 1 then
		class_trial_alpha = 0
		local s = dbt.chr[pers].season
		local ch = dbt.chr[pers].char

		argue_sprite = "dbt/characters"..s.."/char"..ch.."/ct_argue_1.png"
		local mattest = Material(argue_sprite)
		local materialwidth, materialheight = mattest:Width(), mattest:Height()
		hook.Remove("HUDPaint", "ct.argue_manager_mask")
		hook.Remove("Think", "ct.argue_animation")
		hook.Remove("Think", "ct.second_argue_animation")
		hook.Remove("Think", "ct.third_argue_animation")

		local set_transp = 255
		local set_transp_top = 255
		local set_transp_argue = 255
		local set_transp_letters = 255
		local set_transp_character = 0
		local motion_argue_h = 0
		local motion_argue_w = 0
		local motion_argue_size_h = 0
		local motion_argue_size_w = 0
		local motion_character_h = 1080
		local motion_character_w = 0
		local motion_character_size_h = 0
		local motion_character_size_w = 0

		--====================================================
		-- ТЕЛО АНИМАЦИЙ
		--====================================================
		-- (ТРИГГЕР) Таймер для эффекта триггера. выдаёт Булиевое значение
		local shaked_exe = false
		timer.Create("Shake_argue", 0.05, 65, function()
			if shaked_exe == true then
				shaked_exe = false
			elseif shaked_exe == false then
				shaked_exe = true
			end
		end)
		--Начало анимации (ВЫЕЗД ЭЛЕМЕНТОВ)
		timer.Create("ct.timer_12", 0, 1, function()

			local fraction = 0
			local lerptime = 0.3
			hook.Add("Think", "ct.argue_animation", function()
				fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
				if fraction == 0 then return end

				motion_argue_h = Lerp( fraction, 1080, 540)
				motion_argue_w = Lerp( fraction, 0, 960)
				motion_argue_size_h = Lerp( fraction, 0, 1080)
				motion_argue_size_w = Lerp( fraction, 0, 1920)

				motion_character_h = Lerp( fraction, 1080, 540)
				motion_character_w = Lerp( fraction, 0, 740)
				motion_character_size_h = Lerp( fraction, 0, materialheight)
				motion_character_size_w = Lerp( fraction, 0, materialwidth)

				set_transp_character = Lerp( fraction, 0, 255 )
			end)
			timer.Create("ct.timer_12", 0.35, 1, function()

				local fraction = 0
				local lerptime = 2.3
				hook.Add("Think", "ct.argue_animation", function()
					fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
					if fraction == 0 then return end

					motion_character_h = Lerp( fraction, 540, 560)
					motion_character_w = Lerp( fraction, 740, 760)
					motion_character_size_h = Lerp( fraction, materialheight, materialheight + 20)
					motion_character_size_w = Lerp( fraction, materialwidth, materialwidth + 20)
				end)
				--Начало анимации (ИСЧЕЗНОВЕНИЕ ЭЛЕМЕНТОВ)
				timer.Create("ct.timer_12", 1.8, 1, function()

					local fraction = 0
					local lerptime = 0.3
					hook.Add("Think", "ct.argue_animation", function()
						fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
						if fraction == 0 then return end

						set_transp = Lerp( fraction, 255, 0 )
						set_transp_top = Lerp( fraction, 255, 0 )
						set_transp_argue = Lerp( fraction, 255, 0 )
						set_transp_letters = Lerp( fraction, 255, 0 )
						set_transp_character = Lerp( fraction, 255, 0 )
						class_trial_alpha = Lerp( fraction, 0, 255 )
					end)
				end)
			end)
		end)

		--====================================================
		-- ТЕЛО HUDPaint
		--====================================================
		hook.Add("HUDPaint", "ct.argue_manager_mask", function()
			--Условия для триггера
			if shaked_exe == true then
				shaked_letters = 1
				shaked_argue = -1
			elseif shaked_exe == false then
				shaked_letters = -1
				shaked_argue = 1
			end
			--Точки фигуры для ФУНКЦИИ МАСОК обязательно в хуке HUDPaint
			local trianglevertex = {
				{ x = ScrW() * (530/1920),   y = ScrH() * (0/1080)},
				{ x = ScrW() * (1605/1920),  y = ScrH() * (0/1080)},
				{ x = ScrW() * (880/1920),   y = ScrH() * (1080/1080)},
				{ x = ScrW() * (280/1920),   y = ScrH() * (1080/1080)},
			}
			--рисуем жёлтый фон
			surface.SetMaterial( argue_bg )
			surface.SetDrawColor( 255, 255, 255, set_transp_argue )
			surface.DrawTexturedRectRotated( ScrW()*( motion_argue_w/1920 ) + shaked_argue, ScrH()*( motion_argue_h/1080 ) + shaked_argue, ScrW()*( motion_argue_size_w/1920 ), ScrH()*( motion_argue_size_h/1080 ), 0 )

			surface.SetMaterial( argue )
			surface.SetDrawColor( 255, 255, 255, set_transp_argue )
			surface.DrawTexturedRectRotated( ScrW()*( motion_argue_w/1920 ) + shaked_argue, ScrH()*( motion_argue_h/1080 ) + shaked_argue, ScrW()*( motion_argue_size_w/1920 ), ScrH()*( motion_argue_size_h/1080 ), 0 )

			draw.FillMask(
				function()
					surface.SetDrawColor( 255, 255, 255, set_transp )
					draw.NoTexture()
					surface.DrawPoly( trianglevertex )
				end,
				function()
					surface.SetDrawColor( 255, 255, 255, set_transp_character )
					surface.SetMaterial( Material(argue_sprite) )
					surface.DrawTexturedRectRotated( ScrW()*( motion_character_w/1920 ), ScrH()*( motion_character_h/1080 ), ScrW()*( motion_character_size_w/1920 )*1.3, ScrH()*( motion_character_size_h/1080 )*1.3, 0)
			end)

			--рисуем буквы
			surface.SetMaterial( argue_letters_active )
			surface.SetDrawColor( 255, 255, 255, set_transp_letters )
			surface.DrawTexturedRectRotated( ScrW()*( motion_argue_w/1920 ) + shaked_letters, ScrH()*( motion_argue_h/1080 ) + shaked_letters, ScrW()*( motion_argue_size_w/1920 ), ScrH()*( motion_argue_size_h/1080 ), 0 )

			surface.SetMaterial( argue_letters )
			surface.SetDrawColor( 255, 255, 255, set_transp_letters )
			surface.DrawTexturedRectRotated( ScrW()*( motion_argue_w/1920 ) + shaked_letters, ScrH()*( motion_argue_h/1080 ) + shaked_letters, ScrW()*( motion_argue_size_w/1920 ), ScrH()*( motion_argue_size_h/1080 ), 0 )

			--рисуем полосы и кляксы
			surface.SetMaterial( blot_argue_top )
			surface.SetDrawColor( 255, 255, 255, set_transp_top )
			surface.DrawTexturedRectRotated( ScrW()*( motion_argue_w/1920 ), ScrH()*( motion_argue_h/1080), ScrW()*( motion_argue_size_w/1920 ), ScrH()*( motion_argue_size_h/1080 ), 0 )
		end)
	elseif not class_trial then return end
end

local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()

local function weight_source(x)
	return ScreenWidth / 1920  * x
end

local function hight_source(x)
	return ScreenHeight / 1080  * x
end

function BulletShootMask()
	x_b = 0
	y_b = 0
	timer.Create("ct.timer.arg", 60, 1, function() end)
	cd = ScrW()
	start_cd = false
	alpha_b = 0
	surface.PlaySound("bulet_shoot.mp3")

	timer.Simple(3, function() start_cd = true timer.Create("ct.timer.arg", 57, 1, function() end) end)
end

concommand.Add("SetNewClassTrialPos", function(ply)
    if not ply:IsAdmin() then return end
    GPS_POS = {}
    if not normal_camera_position[game.GetMap()] then
      normal_camera_position[game.GetMap()] = {}
    end
    normal_camera_position[game.GetMap()].x = ply:GetPos().x
    normal_camera_position[game.GetMap()].y = ply:GetPos().y
    normal_camera_position[game.GetMap()].z = ply:GetPos().z + 60
    normal_camera_position[game.GetMap()].anim.hidht.st  = ply:GetPos().z + 60 + 120
    normal_camera_position[game.GetMap()].anim.hidht.ed  = ply:GetPos().z + 60 + 110

    local tbl = normal_camera_position[game.GetMap()]
    local segmentdist = 16 / ( 2 * math.pi * math.max( 100, 100 ) / 2 )
    for a = 0, 15 do
        local acd = a * -22.5
        local pos_ = Vector(tbl.x + math.cos( math.rad( acd ) ) * 100, tbl.y - math.sin( math.rad( acd ) ) * 100, normal_camera_position[game.GetMap()].z ) --tbl.x + math.cos( math.rad( a + segmentdist ) ) * 100, tbl.y - math.sin( math.rad( a + segmentdist ) ) * 100
        GPS_POS[a + 2] = pos_
    end
    net.Start("dbt/classtrial/update")
      net.WriteTable(GPS_POS)
      net.WriteTable(normal_camera_position)
    net.SendToServer()
end)

net.Receive("dbt/classtrial/update", function()
    local gps = net.ReadTable()
    local sdr = net.ReadTable()

    GPS_POS = gps
    normal_camera_position = sdr
end)

net.Receive("dbt/classtrial/update/mnualy", function()
    GPS_POS = net.ReadTable()
    normal_camera_position = net.ReadTable()
end)
