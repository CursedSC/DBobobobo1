AddCSLuaFile('')

dbt.votingsystem = dbt.votingsystem or {}
voting_allbuttons_table = voting_allbuttons_table or {}
local scrw, scrh = ScrW(), ScrH()
local soundlevel_before = 0
local material_voting_start_bg = Material('dbt/voting_system/voting_start_bg.png', 'smooth')
local material_voting_start_text = Material('dbt/voting_system/voting_start_text.png', 'smooth')
local material_voting_result_text = Material('dbt/voting_system/voting_result.png', 'smooth')
local material_voting_bg = Material('dbt/voting_system/voting_bg.png', 'smooth')
local material_voting_lines = Material('dbt/voting_system/voting_lines.png', 'smooth')
local material_voting_lines_light = Material('dbt/voting_system/voting_lines_light.png', 'smooth')
local material_voting_underlines = Material('dbt/voting_system/voting_underlines.png', 'smooth')
local material_voting_logo_text = Material('dbt/voting_system/voting_logo_text.png', 'smooth')
local material_voting_icon_test = Material('dbt/voting_system/voting_icon_character.png', 'smooth')
local material_voting_waitend = Material('dbt/voting_system/voting_wait_end.png', 'smooth')
local material_voting_results_voting = Material('dbt/voting_system/voting_results_of_voting.png', 'smooth')
local material_voting_chibi_character = Material('dbt/voting_system/voting_chibi_mikan.png', 'smooth')
local material_voting_died_character = Material('dbt/voting_system/voting_character_died.png', 'smooth')
local material_voting_shtamp = Material('dbt/voting_system/voting_shtamp.png', 'smooth')
local texture_height_logotext, texture_width_logotext = material_voting_logo_text:Height(), material_voting_logo_text:Width()
local test = http.Material("https://imgur.com/kW1R5tk.png")
hook.Add("OnScreenSizeChanged", 'dbt/votingsystem/screensizechanged',function ()
	scrw, scrh = ScrW(), ScrH()
end)
local colorPic = Color(248, 225, 255, 255)
local colorPic2 = Color(100, 100, 100, 255)

local function playVotingSound(defaultPath, customPath)
	if customPath and file.Exists("sound/" .. customPath, "GAME") then
		surface.PlaySound(customPath)
	else
		surface.PlaySound(defaultPath)
	end
end

function sizebywidth(w)
	return (w and scrw/1920 * w)
end
function sizebyheight(h)
	return (h and scrh/1080 * h)
end

function dbt.votingsystem.votingPanel()
	if IsValid(voting_mainpanel) then voting_mainpanel:Remove() end
	if IsValid(PlayingSong) then PlayingSong:Stop() end
	surface.PlaySound('ui/voting_begin.mp3')
	timer.Simple(2,function () playVotingSound('ui/voting_begin2.mp3', 'custom/voting_begin.mp3') end)
	timer.Simple(2,function ()
		LocalPlayer():EmitSound("ost/other/other4.mp3")
	end)
	voting_mainpanel = vgui.Create('DFrame')
	local startbgsize = 0.55
	local sizeh = 0.5
	local sizeh2 = 0.5
	local first_curtains = vgui.Create('DPanel', voting_mainpanel)
	local second_curtains = vgui.Create('DPanel', voting_mainpanel)

	voting_mainpanel.OnRemove = function() LocalPlayer():StopSound("ost/other/other4.mp3") end

	second_curtains.Think = function()
		second_curtains:MoveToFront()
	end
	first_curtains.Think = function()
		first_curtains:MoveToFront()
	end

	second_curtains.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end
	first_curtains.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end
	first_curtains:SetSize(scrw, scrh*0.5)
	second_curtains:SetPos(0, scrh*0.5)
	second_curtains:SetSize(scrw, scrh*0.5)
	first_curtains:SizeTo(scrw, 0, 0.5, 0, -1,function () end)
	second_curtains:MoveTo(0, scrh, 0.5, 0, -1,function () end)

	voting_mainpanel:MakePopup()
	voting_mainpanel:SetTitle("")
	voting_mainpanel:SetDraggable(false)
	voting_mainpanel:SetSizable(false)
	voting_mainpanel:ShowCloseButton(false)
	voting_mainpanel:SetSize(scrw, scrh)

	timer.Create('dbt/votingsystem/sizetextup', 0, 0, function ()
		if !voting_mainpanel:IsValid() then timer.Remove('dbt/votingsystem/sizetextup') end
		if startbgsize >= 1.4 then timer.Remove('dbt/votingsystem/sizetextup') end
		startbgsize = startbgsize + 0.01
	end)

	voting_mainpanel.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(255, 255, 255, 255)
		BlurScreen(10)
		surface.SetMaterial(material_voting_start_text)
		surface.DrawTexturedRect(w*0.5 - (w*startbgsize)*0.5, h*0.5 - (h*startbgsize)*0.5, w*startbgsize, h*startbgsize)
	end

	timer.Simple(2,function ()
		first_curtains:SizeTo(scrw, scrh*0.5, 0.55, 0, -1,function () end)
		second_curtains:MoveTo(0, scrh*0.5, 0.55, 0, -1,function () end)
	end)

	timer.Simple(2.5,function () --second stage
		first_curtains:SizeTo(scrw, 0, 0.5, 0, -1,function () end)
		second_curtains:MoveTo(0, scrh, 0.5, 0, -1,function () end)
		timer.Create('dbt/votingsystem/removebg', 0, 0, function ()
			if !voting_mainpanel:IsValid() then timer.Remove('dbt/votingsystem/removebg') end
			if sizeh >= 0.5 then
				timer.Remove('dbt/votingsystem/removebg')
				local heightlinefirst = math.random(0, 15) / 100
				local heightlinesecond = math.random(25, 40) / 100
				local heightlinethird = math.random(45, 55) / 100
				local heightlinefourth = math.random(60, 70) / 100
				local sizefirstrand = math.random(2, 4) / 100
				local sizesecondrand = math.random(2, 4) / 100
				local sizethirdrand = math.random(2, 4) / 100
				local sizefourthrand = math.random(2, 4) / 100

				local isplusfirst = false
				local isplussecond = false
				local isplusthird = false
				local isplusfourth = false
				local newheightlinefirst = heightlinefirst
				local newsizefirstrand = sizefirstrand
				local newheightlinesecond = heightlinesecond
				local newsizesecondrand = sizesecondrand
				local newheightlinethird = heightlinethird
				local newsizethirdrand = sizethirdrand
				local newheightlinefourth = heightlinefourth
				local newsizefourthrand = sizefourthrand
				voting_time = 30
				local fonttime = 126
				local stringtext
				local isplusfont = false
				local textcolor = Color(255, 255, 255, 255)
				timer.Create('dbt/votingsystem/animationthink', 0, 0, function ()
					if !voting_mainpanel:IsValid() then timer.Remove('dbt/votingsystem/animationthink') end
					newheightlinefirst = newheightlinefirst + 0.01
					if isplusfirst then
						newsizefirstrand = newsizefirstrand + 0.001
					else
						newsizefirstrand = newsizefirstrand - 0.001
					end

					if newsizefirstrand <= sizefirstrand*0.35 then isplusfirst = true end
					if newsizefirstrand >= sizefirstrand then isplusfirst = false end
					if newheightlinefirst >= 1 then newheightlinefirst = 0 newsizefirstrand = sizefirstrand end

					newheightlinesecond = newheightlinesecond + 0.01
					if isplussecond then
						newsizesecondrand = newsizesecondrand + 0.001
					else
						newsizesecondrand = newsizesecondrand - 0.001
					end

					if newsizesecondrand <= sizesecondrand*0.35 then isplussecond = true end
					if newsizesecondrand >= sizesecondrand then isplussecond = false end
					if newheightlinesecond >= 1 then newheightlinesecond = 0 newsizesecondrand = sizesecondrand end

					newheightlinethird = newheightlinethird - 0.01
					if isplusthird then
						newsizethirdrand = newsizethirdrand + 0.001
					else
						newsizethirdrand = newsizethirdrand - 0.001
					end

					if newsizethirdrand <= sizethirdrand*0.35 then isplusthird = true end
					if newsizethirdrand >= sizethirdrand then isplusthird = false end
					if newheightlinethird <= 0 then newheightlinethird = 1 newsizethirdrand = sizethirdrand end

					newheightlinefourth = newheightlinefourth + 0.01
					if isplusfourth then
						newsizefourthrand = newsizefourthrand + 0.001
					else
						newsizefourthrand = newsizefourthrand - 0.001
					end

					if newsizefourthrand <= sizefourthrand*0.35 then isplusfourth = true end
					if newsizefourthrand >= sizefourthrand then isplusfourth = false end
					if newheightlinefourth >= 1 then newheightlinefourth = 0 newsizefourthrand = sizefourthrand end
				end)

				timer.Create('dbt/votingsystem/timer', 1, 0,function ()
					if !voting_mainpanel:IsValid() then timer.Remove('dbt/votingsystem/timer') end
					if voting_time == 0 then timer.Remove('dbt/votingsystem/timer') return end
					if voting_time <= 10 then
						timer.Create('dbt/votingsystem/timerfont', 0, 0,function ()
							if voting_time == 0 then textcolor = Color(217, 0, 0, 255) return timer.Remove('dbt/votingsystem/timerfont') end
							if fonttime == 126 then
								isplusfont = false
								if textcolor == Color(217, 0, 0, 255) then
									textcolor = Color(255, 255, 255, 255)
								else
									textcolor = Color(217, 0, 0, 255)
								end
							elseif fonttime == 111 then
								isplusfont = true
							end
							if isplusfont then
								fonttime = fonttime + 3
							else
								fonttime = fonttime - 3
							end
						end)
					end

					voting_time = voting_time - 1
				end)

				local voting_panel_players = vgui.Create('DPanel', voting_mainpanel)
				voting_pickedbtn = nil
				voting_sprite = nil
				voting_name_sprite = nil
				voting_name_alpha = 0
				voting_ispicked = false
				voting_ispicked1 = false
				voting_end_stage = false
				voting_shtamp_proc = 1.3
				voting_procent_width = 1
				voting_procent_height = 1
				voting_color_sprite = Color(248, 225, 255, 255)
				voting_panel_players:SetSize(sizebywidth(811), sizebyheight(811))
				voting_panel_players:SetPos(sizebywidth(108), sizebyheight(236))
				voting_panel_players.Paint = function(self, width, height)
					if voting_ispicked then
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial(material_voting_waitend)
						surface.DrawTexturedRect(0, 0, width, height)
					end
				end

				local voting_list_players = vgui.Create('DIconLayout', voting_panel_players)
				voting_list_players:Dock(FILL)
				voting_list_players:SetSpaceY(sizebyheight(20.75))
				voting_list_players:SetSpaceX(sizebywidth(20.75))
				voting_allbuttons_table = {}

				timer.Create('dbt/votingsystem/check_timer', 0, 0,function ()
					if voting_time == 0 then
						timer.Remove('dbt/votingsystem/check_timer')
						timer.Simple(2.5,function ()
							local voting_panel_results = vgui.Create('DPanel', voting_mainpanel)
							voting_panel_results:SetAlpha(0)
							voting_panel_results:SetSize(sizebywidth(811), sizebyheight(811))
							voting_panel_results:SetPos(sizebywidth(108), sizebyheight(236))

							local c = 0
							local d = 0
							local width, height = voting_panel_results:GetSize()
							voting_themost_suspected_num = {num = 0, votes = 0, charactername = '???'}

							for i = 1, 16 do
								local posx, posy = sizebywidth(30) + (sizebywidth(400) * c), sizebyheight(30) + (sizebyheight(94) * d)
								local voting_votes_character = voting_allbuttons_table[i].voting_num

								if voting_votes_character ~= 0 then
									if voting_themost_suspected_num.votes < voting_votes_character then
										if voting_allbuttons_table[i].character:Pers() then
											voting_themost_suspected_num = {num = i, votes = voting_votes_character, charactername = voting_allbuttons_table[i].character:Pers()}
										end
									elseif voting_themost_suspected_num == voting_votes_character then
										voting_themost_suspected_num = {num = 0, votes = voting_themost_suspected_num.votes, charactername = '???'}
									end

									for e = 0, voting_votes_character - 1 do
										local voting_vote = vgui.Create('DPanel', voting_panel_results)
										surface.SetFont('Comfortaa X40')
										local textwidth, textheight
										if voting_allbuttons_table[i].character:Pers() then
											textwidth, textheight = surface.GetTextSize(voting_allbuttons_table[i].character:Pers())
										else
											textheight = sizebyheight(10)
										end

										voting_vote:SetAlpha(0)
										voting_vote:SetSize(sizebywidth(7), sizebyheight(30))
										voting_vote:SetPos(posx + width*0.11 + sizebywidth(12)*e, posy + textheight)
										voting_vote.Paint = function(self, w, h)
											surface.SetDrawColor(137, 0, 179, 255)
											surface.DrawRect(0, 0, w, h)
										end

										timer.Simple(e*0.2,function ()
											voting_vote:AlphaTo(255, 0.1, 0,function () end)
										end)
									end
								end

								d = d + 1
								if i == 8 then
									c = c + 1
									d = 0
								end
							end
							for i = 1, 16 do
								if !voting_allbuttons_table[i].character then continue end
								local s = dbt.chr[voting_allbuttons_table[i].character:Pers()].season
						        local ch = dbt.chr[voting_allbuttons_table[i].character:Pers()].char
						        local chibimat = CreateMaterial( ch.."cool."..s, "UnlitGeneric", {
						                ["$basetexture"] = "dbt/characters"..s.."/char"..ch.."/pixel_sprite.vtf",
						                ["$alphatest"] = 1,
						                ["$vertexalpha"] = 1,
						                ["$vertexcolor"] = 1,
						                ["$smooth"] = 0,

						                ["$allowalphatocoverage"] = 1,
						                ["$alphatestreference "] = 0.8,
						        } )
								voting_allbuttons_table[i].chibi = chibimat
							end

							voting_panel_results.Paint = function(self, width, height)
								local c = 0
								local d = 0
								surface.SetDrawColor(255, 255, 255, 255)
								surface.SetMaterial(material_voting_results_voting)
								surface.DrawTexturedRect(0, 0, width, height)

								for i = 1, 16 do
									if !voting_allbuttons_table[i].character then continue end
									local posx, posy = sizebywidth(30) + (sizebywidth(400) * c), sizebyheight(30) + (sizebyheight(94) * d)
									surface.SetDrawColor(255, 255, 255, 255)
									surface.SetMaterial(voting_allbuttons_table[i].chibi)
									surface.DrawTexturedRect(posx, posy - sizebyheight(5), width*0.11, height*0.11)

									surface.SetTextPos(posx + width*0.11, posy)
									surface.SetTextColor(255, 255, 255, 255)
									surface.SetFont('Comfortaa X40')
									surface.DrawText(CharacterNameOnName(voting_allbuttons_table[i].character:Pers()))

									d = d + 1
									if i == 8 then
										c = c + 1
										d = 0
									end
								end

								surface.SetDrawColor(217, 68, 255, 255)
								surface.DrawOutlinedRect(0, 0, width, height, sizebywidth(13)*0.25)
							end

							voting_panel_results:AlphaTo(255, 0.5, 0,function () end)

							timer.Simple(2,function ()
								if voting_themost_suspected_num.num ~= 0 then
									local voting_id_button_character = voting_themost_suspected_num.num
									voting_sprite = voting_sprite
									voting_end_stage = true
									playVotingSound('ui/voting_results_win.mp3', 'custom/voting_results_win.mp3')

									timer.Simple(5,function ()
										first_curtains:SizeTo(scrw, scrh*0.5, 0.5, 0, -1,function () end)
										second_curtains:MoveTo(0, scrh*0.5, 0.5, 0, -1,function ()
											timer.Simple(0.1,function ()
												first_curtains:Remove()
												second_curtains:Remove()
												voting_mainpanel:Remove()
											end)
										end)
									end)
								else
									timer.Simple(5,function ()
										first_curtains:SizeTo(scrw, scrh*0.5, 0.5, 0, -1,function () timer.Simple(0.1,function () first_curtains:Remove() end) end)
										second_curtains:MoveTo(0, scrh*0.5, 0.5, 0, -1,function () timer.Simple(0.1,function () second_curtains:Remove() voting_mainpanel:Remove() end)  end)
										netstream.Start("dbt/votingsystem/end_vote")
									end)
								end
							end)
						end)
					end
				end)
				local playerstable = GetPlayersInGame()
				local countI = 1
				for i = 1, 16 do
					local ply = playerstable[i]
					local btn
					if IsMono(ply) then continue end

					if ply then
						if !InGame(ply) and !IsMono(ply) then
							btn = dbt.votingsystem.votingButtons(voting_list_players, i, ply, true)
							btn.number = i
							btn.player = ply
						else
							btn = dbt.votingsystem.votingButtons(voting_list_players, i, ply)
							btn.number = i
							btn.player = ply
						end
					else
						btn = dbt.votingsystem.votingButtons(voting_list_players, i)
						btn.number = i
						btn.player = ply
					end

					voting_allbuttons_table[i] = btn
					second_curtains:MoveToFront()
					first_curtains:MoveToFront()
				end

				second_curtains.Paint = function(self, w, h)
					surface.SetDrawColor(0, 0, 0, 255)
					surface.DrawRect(0, 0, w, h)
				end
				first_curtains.Paint = function(self, w, h)
					surface.SetDrawColor(0, 0, 0, 255)
					surface.DrawRect(0, 0, w, h)
				end
				first_curtains:SetSize(scrw, scrh*0.5)
				second_curtains:SetPos(0, scrh*0.5)
				second_curtains:SetSize(scrw, scrh*0.5)
				first_curtains:SizeTo(scrw, 0, 0.5, 0, -1,function () end)
				second_curtains:MoveTo(0, scrh, 0.5, 0, -1,function () end)

				voting_mainpanel.Paint = function(self, w, h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(material_voting_bg)
					surface.DrawTexturedRect(0, 0, w, h)

					surface.SetDrawColor(0, 0, 0, 150)
					surface.DrawRect(0, 0, w, h)

					for i = 1, 4 do
						surface.SetDrawColor(130, 130, 130, 10)

						if i == 1 then
							surface.DrawRect(0, h*newheightlinefirst, w, h*newsizefirstrand)
						elseif i == 2 then
							surface.DrawRect(0, h*newheightlinesecond, w, h*newsizesecondrand)
						elseif i == 3 then
							surface.DrawRect(0, h*newheightlinethird, w, h*newsizethirdrand)
						elseif i == 4 then
							surface.DrawRect(0, h*newheightlinefourth, w, h*newsizefourthrand)
						end
					end

					if voting_sprite then
						if voting_time == 0 and !voting_end_stage then
							voting_color_sprite.r = Lerp(RealFrameTime()*4, voting_color_sprite.r, 0)
							voting_color_sprite.g = Lerp(RealFrameTime()*4, voting_color_sprite.g, 0)
							voting_color_sprite.b = Lerp(RealFrameTime()*4, voting_color_sprite.b, 0)
							voting_name_alpha = 255
							voting_name_sprite = '???'
						end

						if voting_end_stage then
							voting_color_sprite.r = Lerp(RealFrameTime()*4, voting_color_sprite.r, 241)
							voting_color_sprite.g = Lerp(RealFrameTime()*4, voting_color_sprite.g, 189)
							voting_color_sprite.b = Lerp(RealFrameTime()*4, voting_color_sprite.b, 255)
							voting_shtamp_proc =  Lerp(RealFrameTime()*10, voting_shtamp_proc, 1)
							voting_name_alpha = 255
							voting_name_sprite = CharacterNameOnName(voting_themost_suspected_num.charactername)  
						end
						voting_color_sprite.a = voting_name_alpha

						surface.SetDrawColor(voting_color_sprite)
						surface.SetMaterial(voting_sprite)
						surface.DrawTexturedRect(sizebywidth(920)*voting_procent_width, sizebyheight(40)*voting_procent_height, sizebywidth(1000), sizebyheight(1000))

						if voting_end_stage then
							surface.SetDrawColor(255, 255, 255, 255)
							surface.SetMaterial(material_voting_shtamp)
							surface.DrawTexturedRect(sizebywidth(1071), sizebyheight(225), sizebywidth(690)*voting_shtamp_proc, sizebyheight(634)*voting_shtamp_proc)
						end
					end

					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(material_voting_lines_light)
					surface.DrawTexturedRect(0, 0, w, h)
					surface.SetMaterial(material_voting_lines)
					surface.DrawTexturedRect(0, 0, w, h)
					surface.SetMaterial(material_voting_underlines)
					surface.DrawTexturedRect(0, 0, w, h)
					surface.SetMaterial(material_voting_logo_text)
					surface.DrawTexturedRect(sizebywidth(52), sizebyheight(0), sizebywidth(texture_width_logotext), sizebyheight(texture_height_logotext))

					if voting_time >= 10 then
						stringtext = '00:'..voting_time
					else
						stringtext = '00:0'..voting_time
					end

					if voting_time == 0 then
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial(material_voting_result_text)
						surface.DrawTexturedRect(sizebywidth(471), sizebyheight(35), sizebywidth(290), sizebyheight(102))
						stringtext = ''
					end

					draw.RotatedText(stringtext, 'Comfortaa X'..fonttime, sizebywidth(610), sizebyheight(75), textcolor, 5, 1)

					if voting_sprite then
						surface.SetFont('Comfortaa X75')
						local textwidth23, textheight23 = surface.GetTextSize(voting_name_sprite)
						draw.RotatedText(voting_name_sprite, 'Comfortaa X75', sizebywidth(1880) - textwidth23*0.5, sizebyheight(60), Color(255, 255, 255, voting_name_alpha), 6, 1)
					end
				end
			end
			sizeh = sizeh + 0.04
			sizeh2 = sizeh2 - 0.04
		end)
	end)
end

function dbt.votingsystem.votingButtons(mainlist, num, player, isdead)
	local button = mainlist:Add( "DButton" )
	local sizew = 0.25
	button:SetSize(sizebywidth(187), sizebyheight(187))
	button:SetText('')
	button:SetName('voting_'..num)
	button.voting_num = 0
	button.num = num
	button.isdead = isdead

	if player then
		button.character = player
		button.player = player
	end

	button.OnCursorEntered = function(self)
		if !player then return end
		if voting_pickedbtn == button then return end
		voting_pickedbtn = button
		local selfindex = self.player:GetNWInt("Index")
	    local data = Spots[selfindex]
	    local s = dbt.chr[data.char].season
	    local ch = dbt.chr[data.char].char
		surface.PlaySound('ui/voting_active.mp3')
		voting_sprite = Material("dbt/characters"..s.."/char"..ch.."/char_art.png") or Material("dbt/characters0/char_art.png")
		voting_name_sprite = CharacterNameOnName(player:Pers())  
		timer.Create('dbt/votingsystem/think_alpha_voting', 0, 0,function ()
			if voting_name_alpha >= 255 then return timer.Remove('dbt/votingsystem/think_alpha_voting') end
			voting_name_alpha = Lerp(RealFrameTime()*60, voting_name_alpha, 255)
		end)
	end

	button.OnCursorExited = function()
		voting_pickedbtn = nil
		timer.Create('dbt/votingsystem/think_alpha_voting', 0, 0,function ()
			if voting_name_alpha <= 0 then
				voting_sprite = nil
				voting_name_sprite = nil
				return timer.Remove('dbt/votingsystem/think_alpha_voting')
			end
			voting_name_alpha = Lerp(RealFrameTime()*60, voting_name_alpha, 0)
		end)
	end

	button.Think = function(self)
		if voting_ispicked1 then button.Think = function() end return end
		if voting_time == 0 and !voting_ispicked1 then
			voting_ispicked1 = true
			button.Think = function() end
			local selfindex = self.player:GetNWInt("Index")
		    local data = Spots[selfindex]
			if not data then return end
		    local s = dbt.chr[data.char].season
		    local ch = dbt.chr[data.char].char
			voting_sprite = Material("dbt/characters"..s.."/char"..ch.."/char_art.png") or Material("dbt/characters0/char_art.png")
			voting_name_sprite = player:Pers()
			local i = 0
			for k, v in pairs(voting_allbuttons_table) do
				v.DoClick = function() end
				v.OnCursorEntered = function() end
				v.OnCursorExited = function() end
				timer.Simple(i,function ()
					local width, height = v:GetSize()
					local posx, posy = v:GetPos()
					v:SizeTo(width, 0, 0.15, 0, -1,function ()
						v.Paint = function(self, w, h)
							surface.SetDrawColor(34, 0, 40, 255)
							surface.DrawRect(0, 0, w, h)
						end
						v:SizeTo(width, height, 0.15, 0, -1,function () end)
					end)
					v:MoveTo(posx, posy + height*0.5, 0.15, 0, -1,function ()
						v:MoveTo(posx, posy, 0.15, 0, -1,function ()
							if k == #voting_allbuttons_table then
								voting_ispicked = true
							end
						end)
					end)
				end)
				i = i + 0.05
			end
		end
	end

	button.DoClick = function(self)
		if !player then return end
		if voting_ispicked1 then return end
		voting_ispicked1 = true
		local numberbtn = button.number
		netstream.Start("dbt/votingsystem/add_vote", numberbtn, CharacterNameOnName(player:Pers()))
		surface.PlaySound('ui/voting_click.mp3')
		local i = 0

		if voting_time <= 6 and voting_time ~= 0 then
			local selfindex = self.player:GetNWInt("Index")
		    local data = Spots[selfindex]
			if not data then return end
		    local s = dbt.chr[data.char].season
		    local ch = dbt.chr[data.char].char
			voting_sprite = Material("dbt/characters"..s.."/char"..ch.."/char_art.png") or Material("dbt/characters0/char_art.png")
			voting_name_sprite = CharacterNameOnName(player:Pers())   
			local i = 0
			for k, v in pairs(voting_allbuttons_table) do
				v.DoClick = function() end
				v.OnCursorEntered = function() end
				v.OnCursorExited = function() end
				timer.Simple(i,function ()
					local width, height = v:GetSize()
					local posx, posy = v:GetPos()
					v:SizeTo(width, 0, 0.15, 0, -1,function ()
						v.Paint = function(self, w, h)
							surface.SetDrawColor(34, 0, 40, 255)
							surface.DrawRect(0, 0, w, h)
						end
						v:SizeTo(width, height, 0.15, 0, -1,function () end)
					end)
					v:MoveTo(posx, posy + height*0.5, 0.15, 0, -1,function ()
						v:MoveTo(posx, posy, 0.15, 0, -1,function ()
							if k == #voting_allbuttons_table then
								voting_ispicked = true
							end
						end)
					end)
				end)
				i = i + 0.05
			end
		else
			button.Think = function()
				if voting_time == 0 then
					button.Think = function() end
					for k, v in pairs(voting_allbuttons_table) do
						local width, height = v:GetSize()
						local posx, posy = v:GetPos()
						local alpha = 0

						timer.Create('dbt/votingsystem/wait_end/alpha_voting'..k, 0, 0,function ()
							if alpha >= 255 then timer.Remove('dbt/votingsystem/wait_end/alpha_voting'..k) return end
							alpha = alpha + 5
						end)

						v.Paint = function(self, w, h)
							surface.SetDrawColor(190, 41, 255, 255)
							surface.DrawOutlinedRect(0, 0, w, h, sizebywidth(13)*0.25)

							surface.SetDrawColor(34, 0, 40, alpha)
							surface.DrawRect(0, 0, w, h)
						end
					end
				end
			end
			for k, v in pairs(voting_allbuttons_table) do
				v.DoClick = function() end
				v.OnCursorEntered = function() end
				v.OnCursorExited = function() end
				timer.Simple(i,function ()
					local width, height = v:GetSize()
					local posx, posy = v:GetPos()
					v:SizeTo(width, 0, 0.15, 0, -1,function ()
						v.Paint = function(self, w, h)
							surface.SetDrawColor(34, 0, 40, 255)
							surface.DrawRect(0, 0, w, h)
						end
						v:SizeTo(width, height, 0.15, 0, -1,function () end)
					end)
					v:MoveTo(posx, posy + height*0.5, 0.15, 0, -1,function ()
						v:MoveTo(posx, posy, 0.15, 0, -1,function ()
							if k == #voting_allbuttons_table then
								voting_ispicked = true
							end
						end)
					end)

					if k == #voting_allbuttons_table then
						local b = 0
						timer.Simple(0.15,function ()
							for k, v in pairs(voting_allbuttons_table) do
								timer.Simple(b,function ()
									local alpha = 255
									timer.Create('dbt/votingsystem/wait_end/alpha_voting'..k, 0, 0,function ()
										if alpha <= 0 then timer.Remove('dbt/votingsystem/wait_end/alpha_voting'..k) return end
										alpha = alpha - 5
									end)
									v.Paint = function(self, w, h)
										surface.SetDrawColor(217, 68, 255, 255)
										surface.DrawOutlinedRect(0, 0, w, h, sizebywidth(13)*0.25)

										surface.SetDrawColor(34, 0, 40, alpha)
										surface.DrawRect(0, 0, w, h)
									end
								end)
								b = b + 0.15
							end
						end)
					end
				end)
				i = i + 0.05
			end
		end
	end
	local selfindex
	local data
	local s
	local ch
	local materialforbutton
	if button.player then
		selfindex = button.player:GetNWInt("Index")
		data = Spots[selfindex]
		if not data then return end
		s = dbt.chr[data.char].season
		ch = dbt.chr[data.char].char
		materialforbutton = Material("dbt/characters"..s.."/char"..ch.."/char_ico_1.png") or Material("dbt/characters0/char_ico_1.png")
	end



	button.Paint = function(self, w, h)
		if !player then
			surface.SetDrawColor(0, 0, 0, 155)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(material_voting_died_character)
			surface.DrawTexturedRect(0, 0, w, h)

			surface.SetDrawColor(190, 41, 255, 255)
			surface.DrawOutlinedRect(0, 0, w, h, sizebywidth(13)*0.25)
		else
			if voting_pickedbtn == button then
				sizew = Lerp(RealFrameTime()*4, sizew, 1)
				surface.SetDrawColor(0, 0, 0, 155)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(isdead and colorPic2 or colorPic)
				surface.SetMaterial(materialforbutton)
				surface.DrawTexturedRect(w*0.5 - w*0.5, h*0.5 - w*0.5, w, w)

				surface.SetDrawColor(217, 68, 255, 255)
				surface.DrawOutlinedRect(0, 0, w, h, sizebywidth(13)*sizew)
			else
				sizew = Lerp(RealFrameTime()*4, sizew, 0.25)
				surface.SetDrawColor(0, 0, 0, 155)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(isdead and colorPic2 or colorPic)
				surface.SetMaterial(materialforbutton)
				surface.DrawTexturedRect(w*0.5 - w*0.5, h*0.5 - w*0.5, w, w)

				surface.SetDrawColor(190, 41, 255, 255)
				surface.DrawOutlinedRect(0, 0, w, h, sizebywidth(13)*sizew)
			end
			if isdead then 
				surface.SetDrawColor(255, 255, 255, 200)
				surface.SetMaterial(material_voting_died_character)
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end
	end

	return button
end

netstream.Hook("dbt/votingsystem/vote_update", function(butnnumber)
	for k, v in pairs(voting_allbuttons_table) do
		if k == butnnumber then
			v.voting_num = v.voting_num + 1
		end
	end
end)

netstream.Hook("dbt/classtrial/voting", function()
	dbt.votingsystem.votingPanel()
end)

netstream.Hook("dbt/votingsystem/notvoting_tomono", function(notvoting)
	local stringtoprint = ""
	for k, v in pairs(notvoting) do
		stringtoprint = stringtoprint..v:Pers()..", "
	end
	chat.AddText(Color(255, 0, 0), 'Не проголосовали: '..stringtoprint)
end)

netstream.Hook("dbt/votingsystem/winner", function(winner, votingsystem_tablevoting)
	chat.AddText(Color(255, 255, 255), 'ПОБЕДИТЕЛЬ ГОЛОСОВАНИЯ: '..winner)
	for k, i in pairs(votingsystem_tablevoting) do 
		local kname = k:GetCharacterName()
		local iname = i
		chat.AddText(Color(255, 255, 255), kname..': проголосовал за '..iname)
	end

	dbt = dbt or {}
	dbt.AdminVoteHistory = dbt.AdminVoteHistory or {}

	local voteEntry = {
		time = os.date("%d.%m %H:%M"),
		winner = winner or '—',
		votes = {}
	}

	for voter, choice in pairs(votingsystem_tablevoting or {}) do
		local voterName = 'Неизвестно'
		if IsValid(voter) then
			voterName = voter.GetCharacterName and voter:GetCharacterName() or voter:Nick()
		elseif istable(voter) then
			voterName = voter.name or voter.charname or voter.nick or voter.steamid or voter[1] or voterName
		end

		voteEntry.votes[#voteEntry.votes + 1] = {
			voter = voterName,
			choice = choice or '—'
		}
	end

	table.sort(voteEntry.votes, function(a, b)
		return a.voter < b.voter
	end)

	table.insert(dbt.AdminVoteHistory, 1, voteEntry)
	while #dbt.AdminVoteHistory > 10 do
		table.remove(dbt.AdminVoteHistory)
	end

	if dbt.AdminStats and isfunction(dbt.AdminStats.RebuildVoteList) then
		dbt.AdminStats.RebuildVoteList()
	end

	notifications_new(3, {
		icon = 'materials/dbt/notifications/notifications_main.png',
		title = 'Голосование завершено',
		titlecolor = Color(222, 193, 49),
		notiftext = 'Голоса участников в мономеню.'
	})
end)
