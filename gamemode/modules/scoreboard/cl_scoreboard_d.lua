dbt.scoreboard = dbt.scoreboard or {}

local SCOREBOARD_CURSOR_HOOK = "dbt.Scoreboard.CursorControl"
local function scoreboardEnableCursor(enable)
	local frame = dbt.inventory and dbt.inventory.Frame
	if IsValid(frame) then
		frame:SetMouseInputEnabled(enable)
	end
	gui.EnableScreenClicker(enable)
	dbt.scoreboard.cursorEnabled = enable and true or false
end

function dbt.scoreboard.SetCursorEnabled(enable)
	scoreboardEnableCursor(enable and true or false)
end

function dbt.scoreboard.SetupCursorControl()
	scoreboardEnableCursor(false)
	if dbt.scoreboard.cursorHookActive then return end
	dbt.scoreboard.cursorHookActive = true
	hook.Add("Think", SCOREBOARD_CURSOR_HOOK, function()
		if not IsValid(dbt.inventory and dbt.inventory.Frame) then
			dbt.scoreboard.TeardownCursorControl()
			return
		end
		local wantsCursor = input.IsMouseDown(MOUSE_RIGHT)
		if wantsCursor ~= (dbt.scoreboard.cursorEnabled == true) then
			scoreboardEnableCursor(wantsCursor)
		end
	end)
end

function dbt.scoreboard.TeardownCursorControl()
	if dbt.scoreboard.cursorHookActive then
		hook.Remove("Think", SCOREBOARD_CURSOR_HOOK)
		dbt.scoreboard.cursorHookActive = nil
	end
	dbt.scoreboard.cursorEnabled = nil
	scoreboardEnableCursor(false)
end

local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()

local function weight_source(x)
    return ScreenWidth / 1920  * x
end

local function hight_source(x)
    return ScreenHeight / 1080  * x
end

surface.CreateFont( "dbt/font/200", {
	font = "Comfortaa Light", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 220,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "dbt/font/250", {
	font = "Comfortaa Light", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 270,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "dbt/font/5", {
	font = "Comfortaa Ligh", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = ScrW() / 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "dbt/font/1", {
	font = "Comfortaa Ligh", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = ScrW() / 100,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "dbt/font/3", {
	font = "Comfortaa Ligh", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = ScrW() / 80,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
local score_groups = {
	["founder"] = "Основатель",
	["gm"] = "Игровой Мастер",
	["admin"] = "Администратор",
}
local mat = Material( "pp/blurscreen" )
local visiblemat = http.Material("https://imgur.com/dzXzlit.png", "smooth")
local notvisiblemat = http.Material("https://imgur.com/EQmsv6s.png", "smooth")
CurrentScoreBoardBlur = 0
local testGif = CreateMaterial( "testGif3", "UnlitGeneric", {
    ["$basetexture"] = "dbt/banners/test.vtf",
} )
local bannerFrames = 138                       -- total frames in the sheet
local bannerFps = 24    

function dbt.scoreboard:Open()
	local w,h = ScrW(),ScrH()
	local ply = LocalPlayer()

	--gui.EnableScreenClicker( true )
	dbt.scoreboard.frame = vgui.Create( "DPanel", dbt.inventory.Frame )
	dbt.scoreboard.frame:SetPos( 0, hight_source(60) )
	dbt.scoreboard.frame:SetSize( w, hight_source(1020) )

	dbt.scoreboard.frame.Paint = function(self,w,h)
		--CurrentScoreBoardBlur = Lerp(FrameTime() * 5, CurrentScoreBoardBlur, 24)
	--BlurScreen(CurrentScoreBoardBlur)
    	local frame = math.floor(CurTime() * bannerFps) % bannerFrames
    	testGif:SetInt("$frame", frame)

		--draw.DrawText( "ТАБЛИЦА ИГРОКОВ", "dbt/font/5", w / 2, h * 0.07, color_white, TEXT_ALIGN_CENTER )


		draw.DrawText( "Имя", "Comfortaa X30", w  * 0.24, h * 0.17, color_white, TEXT_ALIGN_LEFT )
		draw.DrawText( "Персонаж", "Comfortaa X30", w  * 0.465, h * 0.17, color_white, TEXT_ALIGN_LEFT )
		draw.DrawText( "Привилегия", "Comfortaa X30", w  * 0.648, h * 0.17, color_white, TEXT_ALIGN_LEFT )
		draw.DrawText( "Пинг", "Comfortaa X30", w  * 0.765, h * 0.17, color_white, TEXT_ALIGN_LEFT )
		draw.DrawText( "СПИСОК ИГРОКОВ", "Comfortaa X58", w  / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER )

		draw.DrawText( "Игроков онлайн", "Comfortaa X27", w  * 0.22, h * 0.935, color_white, TEXT_ALIGN_LEFT )

		surface.SetFont( "Comfortaa X27" )

		local text = "Игроков онлайн"
		local width_1, height = surface.GetTextSize( text )
		draw.DrawText( player.GetCount(), "Comfortaa X27", w  * 0.22 + width_1 + 5, h * 0.935, Color(175, 19, 186), TEXT_ALIGN_LEFT )

		local text = tostring(player.GetCount())
		local width_2, height = surface.GetTextSize( text )
		draw.DrawText( "из", "Comfortaa X27", w  * 0.22 + width_1 + width_2 + 10, h * 0.935, color_white, TEXT_ALIGN_LEFT )	--game.MaxPlayers()

		local text = "из"
		local width_3, height = surface.GetTextSize( text )
		draw.DrawText( game.MaxPlayers(), "Comfortaa X27", w  * 0.22 + width_1 + width_2 + width_3 + 15, h * 0.935, Color(175, 19, 186), TEXT_ALIGN_LEFT )

	end

	dbt.scoreboard.scoreboard = vgui.Create( "DScrollPanel", dbt.scoreboard.frame)
	dbt.scoreboard.scoreboard:SetPos( w / 2 - w * 0.3 - h*0.05, h * 0.2 )
	dbt.scoreboard.scoreboard:SetSize( w * 0.6 + 30 + h*0.05,h * 0.73 )

	local sbar = dbt.scoreboard.scoreboard:GetVBar()
    function sbar:Paint(w, h)
      draw.RoundedBox(0, w / 2 - ((w / 2) / 2), 2, w / 2, h, Color(175, 19, 186, 20))
    end
    function sbar.btnUp:Paint(w, h)
    end
    function sbar.btnDown:Paint(w, h)
    end
    function sbar.btnGrip:Paint(w, h)
      draw.RoundedBox(0, 2, 0, w-5, h , Color(175, 19, 186))
    end
    y_player = 0
    for k, i in pairs(player.GetAll()) do
    if not i:GetNWBool("IsVisibleScoreboard", true) and not LocalPlayer():IsAdmin() then continue end
    local S_color = dbt.chr[i:Pers()].color or Color(49, 71, 93)

	 	local player_panel = vgui.Create( "DButton", dbt.scoreboard.scoreboard)
		player_panel:SetPos(h*0.05, y_player )
		player_panel:SetSize( w * 0.6 + 30 - 30, h * 0.05 )
		player_panel:SetText("")
		local bckgrnd = i:GetNW2String("backgroundmatscoreboard", false)

		player_panel.Paint = function(self,w,h)
			if not IsValid(i) then return end

			--if not bckgrnd then
				draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 120))
				dbtPaint.DrawRect(testGif, 0, 0 - h, w, h * 4, color_white)

			--elseif bckgrnd == "cancel" then
			--	bckgrndmat = nil
			--	bckgrnd = false
			--else
			--	bckgrndmat = http.Material(bckgrnd, "smooth")
			--	surface.SetDrawColor(255, 255, 255, 120)
			--	bckgrndmat:Draw(0, 0, scrw*0.6 + 30, scrh*0.05)
			--end

			S_color.a = 255
			draw.RoundedBox(0, h * 0.2, 0, w * 0.048, h, S_color)

			draw.DrawText( i:Name(), "Comfortaa X28", w * 0.07, h * 0.2, color_white, TEXT_ALIGN_LEFT )

			draw.DrawText( dbt.chr[i:Pers()].name, "Comfortaa X28", w * 0.493, h * 0.2, color_white, TEXT_ALIGN_CENTER )

			if score_groups[i:GetUserGroup()] then
				draw.DrawText( score_groups[i:GetUserGroup()], "Comfortaa X28", w * 0.798, h * 0.2, color_white, TEXT_ALIGN_CENTER )
			end

			draw.DrawText( i:Ping(), "Comfortaa X28", w * 0.96, h * 0.2, color_white, TEXT_ALIGN_CENTER )
			draw.RoundedBox(0, w - 17, 8, 12, 12, Color(61, 7, 65, 200))
			if i:Ping() <= 35 then
				draw.RoundedBox(0, w - 17, 8, 12, 12, Color(175, 19, 186, 100))
			end

			draw.RoundedBox(0, w - 17, 22, 12, 12, Color(61, 7, 65, 200))
			if i:Ping() <= 60 then
				draw.RoundedBox(0, w - 17, 22, 12, 12, Color(175, 19, 186, 100))
			end
			draw.RoundedBox(0, w - 17, 36, 12, 12, Color(61, 7, 65, 100))
			draw.RoundedBox(0, w - 17, 36, 12, 12, Color(175, 19, 186, 100))
		end
		player_panel.DoClick = function()
			local Menu = DermaMenu()
			if LocalPlayer():IsAdmin() then
				Menu:AddOption( "Выдать варн", function()
				Derma_StringRequest(
					"Выдача варна",
					"Укажите причину варна.",
					"",
					function(text) netstream.Start("dbt/warns/add", text, i) end,
					function(text)  end
				) end )
			end
				Menu:AddOption( "Личное сообщение", function()
					netstream.Start("dbt/chat/bool", true)
				Derma_StringRequest(
					"Написать сообщение",
					"Сообщение",
					"",
					function(text)
						local name = string.Split( i:Name(), " " )
						RunConsoleCommand("say", "!pm "..name[1].." "..text)
						netstream.Start("dbt/chat/bool", false)
					end,
					function(text)  end
				) end )

			Menu:Open()
		end
		local Avatar = vgui.Create( "AvatarImage", player_panel )
		Avatar:SetSize( h * 0.05, h * 0.05 )
		Avatar:SetPos( 0, 0 )
		Avatar:SetPlayer( i, 64 )

		local steam_profile = vgui.Create( "DButton", player_panel )
		steam_profile:SetText( "" )
		steam_profile:SetSize( h * 0.05, h * 0.05 )
		steam_profile.Paint = function(self,w,h)
		end
		function steam_profile:DoClick()
			gui.OpenURL("https://steamcommunity.com/profiles/"..i:SteamID64())
		end

		if LocalPlayer():IsAdmin() then
			local visibleornot = vgui.Create( "DImageButton", dbt.scoreboard.scoreboard)
			local visibleornotimg = i:GetNWBool("IsVisibleScoreboard", true) and visiblemat or notvisiblemat
			visibleornot.Paint = function()
				surface.SetDrawColor(0, 0, 0, 120)
      			visibleornotimg:Draw(h*0.01, h*0.01, h*0.035, h*0.035)
      		end

			visibleornot:SetSize( h * 0.05, h * 0.05 )
			visibleornot:SetPos(0, y_player)

			visibleornot.DoClick = function()
				local visability = i:GetNWBool("IsVisibleScoreboard", true)
				netstream.Start("dbt/unvisibleplayers/change", i, !visability)
				visibleornotimg = !visability and visiblemat or notvisiblemat
			end
		end

		y_player = y_player + h * 0.055
	end
end

hook.Add( "ScoreboardShow", "dbt.Scoreboard_Open", function()
    if IsValid(dbt.inventory.Frame) then
    	dbt.inventory.Frame:Close()
    end
	local typeOpen = settings.Get("Tab", 1)
    dbt.inventory.New(typeOpen)
    return true
end )

hook.Add( "ScoreboardHide", "dbt.Scoreboard_Close", function()
	dbt.scoreboard.TeardownCursorControl()
    if IsValid(dbt.inventory.Frame) then
    	dbt.inventory.Frame:Close()
    end
end )
