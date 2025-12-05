local logo = Material("dbt/f4/dbt_logo.png")
local bg_main = Material("dbt/f4/f4_main_bg.png")
local text_setting = Material("dbt/f4/text_setting.png")
local text_pick = Material("dbt/f4/text_pick.png")
local stat_special_item = Material("dbt/f4/stat_special_item.png")
local settingsConsole = {
    Multicore = "gmod_mcore_test",
    Shadows = "r_shadowmaxrendered",
    fp_body = "cl_ec_enabled",
    fp_hair = "cl_ec_showhair",
    fp_sit = "cl_ec_vehicle",
    Crosshair = "showcroshair",
}

local colorOutLine = Color(211,25, 202)
local colorButtonInactive = Color(0,0,0,100)
local colorButtonActive = Color(0,0,0,200)
local colorBG = Color(255, 255, 255, 60)
local colorBG2 = Color(255, 255, 255, 150)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorText = Color(255,255,255,100)
local colorButtonExit = Color(250, 250, 250, 1)

local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

CurrentBG = tableBG[1]

local draw_border = function(w, h, color)
    draw.RoundedBox(0, 0, 0, w, 1, color)
    draw.RoundedBox(0, 0, 0, 1, h, color)

    draw.RoundedBox(0, 0, h - 1, w, 1, color)
        draw.RoundedBox(0, w - 1, 0, 1, h, color)
    end



function openf4()
    if IsValid(dbt.f4) then dbt.f4:Close() end
    local scrw,scrh = ScrW(), ScrH()
    local a = math.random(1, 3)

    CurrentBG = tableBG[a]

    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton( false )
    dbt.f4:MakePopup()

    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_main, 0, 0, w, h, colorBG2)
        dbtPaint.DrawRect(logo, dbtPaint.WidthSource(662), dbtPaint.HightSource(18), dbtPaint.WidthSource(596), dbtPaint.HightSource(241))
    end


    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(752), dbtPaint.HightSource(540))
    button:SetSize(dbtPaint.WidthSource(416), dbtPaint.HightSource(64))
    button.ColorBorder = colorOutLine
    button.ColorBorder.a = 0
    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)

        if hovered then
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 0)
        end

        draw.SimpleText("Продолжить", "Comfortaa Light X50", w * 0.5, dbtPaint.HightSource(5), color_white, TEXT_ALIGN_CENTER)
    end
    button.DoClick = function(self) surface.PlaySound('ui/button_click.mp3') dbt.f4:Close() 
        if LocalPlayer():IsAdmin() then RunConsoleCommand("spawnmenu_reload") end
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end

    dbt.f4.cont = button

    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(752), dbtPaint.HightSource(615))
    button:SetSize(dbtPaint.WidthSource(416), dbtPaint.HightSource(64))
    button.ColorBorder = colorOutLine
    button.ColorBorder.a = 0
    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)

        if hovered then
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 0)
        end

        draw.SimpleText("Выбор персонажа", "Comfortaa Light X50", w * 0.5, dbtPaint.HightSource(5), color_white, TEXT_ALIGN_CENTER)
    end
    button.DoClick = function()
        openseasonselect()
		surface.PlaySound('ui/button_click.mp3')
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    dbt.f4.char = button


    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(752), dbtPaint.HightSource(692))
    button:SetSize(dbtPaint.WidthSource(416), dbtPaint.HightSource(64))
    button.ColorBorder = colorOutLine
    button.ColorBorder.a = 0
    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)

        if hovered then
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 0)
        end

        draw.SimpleText("Наблюдать", "Comfortaa Light X50", w * 0.5, dbtPaint.HightSource(5), color_white, TEXT_ALIGN_CENTER)
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
	button.DoClick = function() surface.PlaySound('ui/button_click.mp3') dbt.f4:Close() dbt.SpectateForUsers(LocalPlayer()) end

    dbt.f4.spec = button

    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(752), dbtPaint.HightSource(769))
    button:SetSize(dbtPaint.WidthSource(416), dbtPaint.HightSource(64))
    button.ColorBorder = colorOutLine
    button.ColorBorder.a = 0
    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)

        if hovered then
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime()*5, self.ColorBorder.a, 0)
        end

        draw.SimpleText("Настройки", "Comfortaa Light X50", w * 0.5, dbtPaint.HightSource(5), color_white, TEXT_ALIGN_CENTER)
    end
    button.DoClick = function()
        open_settings()
		surface.PlaySound('ui/button_click.mp3')
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end

    dbt.f4.settings = button

end


local rect = Material("dbt/f4/season_pick/rect.png")
local bg_seasoins = Material("dbt/f4/f4_charselect_bg.png")

local seasons = {
    1, 2, 3, 5, 4, 6
}
local seasons_img = {
    Material("dbt/f4/season_pick/dr1_logo.png"),
    Material("dbt/f4/season_pick/dr2_logo.png"),
    Material("dbt/f4/season_pick/drv3_logo.png"),
    Material("dbt/f4/season_pick/udg_logo.png"),
    Material("dbt/f4/season_pick/other_logo.png"),
    Material("dbt/f4/season_pick/oc_logo.png"),
}

local seasons_size = {
    {x = dbtPaint.WidthSource(409), y = dbtPaint.HightSource(124)},
    {x = dbtPaint.WidthSource(438), y = dbtPaint.HightSource(96)},
    {x = dbtPaint.WidthSource(472), y = dbtPaint.HightSource(124)},
    {x = dbtPaint.WidthSource(409), y = dbtPaint.HightSource(168)},
    {x = dbtPaint.WidthSource(307), y = dbtPaint.HightSource(68)},
    {x = dbtPaint.WidthSource(177), y = dbtPaint.HightSource(68)},
}

local function sign(p1, p2, p3)
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
end

local function IsPointInParallelogram(point, a, b, c, d)
    local d1 = sign(point, a, b)
    local d2 = sign(point, b, c)
    local d3 = sign(point, c, d)
    local d4 = sign(point, d, a)

    local has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0) or (d4 < 0)
    local has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0) or (d4 > 0)

    return not (has_neg and has_pos)
end

local function GetMousePosition()
    local x, y = input.GetCursorPos()
    return Vector(x, y, 0)
end

function openseasonselect()
    dbt.f4:Close()
    local scrw,scrh = ScrW(), ScrH()
    local a = math.random(1, 3)
	local previousseason = 0
    SelectedSeason = nil
    CurrentBG = tableBG[a]

    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton( false )
    dbt.f4:MakePopup()

    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_seasoins, 0, 0, w, h)
        dbtPaint.DrawRect(text_pick, w * 0.5 - dbtPaint.WidthSource(303), dbtPaint.HightSource(38), dbtPaint.WidthSource(606), dbtPaint.HightSource(88), color_white)

        SelectedSeason = nil

        for k = 1, #seasons do
            local needTwo = (k / 3 > 1)
            local season = seasons[k]
            local k2 = k - 1
            local vec1, vec2, vec3, vec4
            local x2, y2, w2, h2
            if needTwo then
                k2 = k2 - 3
                local x, y, w, h = (dbtPaint.WidthSource(96) + (k2 * dbtPaint.WidthSource(530))), dbtPaint.HightSource(595), dbtPaint.WidthSource(655), dbtPaint.HightSource(230)

                vec1, vec2, vec3, vec4 = Vector(x + dbtPaint.WidthSource(150), y), Vector(x + w, y), Vector(x + w - dbtPaint.WidthSource(150), y + h), Vector(x, y + h)
                local a = IsPointInParallelogram(GetMousePosition(), vec1, vec2, vec3, vec4)
                dbtPaint.DrawRect(rect, x, y, w, h)
                x2, y2, w2, h2 = x, y, w, h
				if a then
					if previousseason != season then
						surface.PlaySound('ui/ui_but/ui_hover.wav')
					end
				end
                if a then dbtPaint.DrawRect(rect, x, y, w, h) SelectedSeason = season previousseason = season end
            else
                local x, y, w, h = (dbtPaint.WidthSource(96) + (k2 * dbtPaint.WidthSource(530))), dbtPaint.HightSource(335), dbtPaint.WidthSource(655), dbtPaint.HightSource(230)

                vec1, vec2, vec3, vec4 = Vector(x + dbtPaint.WidthSource(150), y), Vector(x + w, y), Vector(x + w - dbtPaint.WidthSource(150), y + h), Vector(x, y + h)
                local a = IsPointInParallelogram(GetMousePosition(), vec1, vec2, vec3, vec4)
                dbtPaint.DrawRect(rect, x, y, w, h)
                x2, y2, w2, h2 = x, y, w, h
				if a then
					if previousseason != season then
						surface.PlaySound('ui/ui_but/ui_hover.wav')
					end
				end
                if a then dbtPaint.DrawRect(rect, x, y, w, h) SelectedSeason = season previousseason = season end
            end

            dbtPaint.DrawRectR(seasons_img[season], x2 + dbtPaint.HightSource(655 * 0.5), y2 + dbtPaint.HightSource(230 * 0.5), seasons_size[season].x, seasons_size[season].y, 0)
        end
		
		if !SelectedSeason then previousseason = 0 end

        if input.IsMouseDown(MOUSE_LEFT) then
            if SelectedSeason then open_choose_characters(SelectedSeason) surface.PlaySound('ui/button_click.mp3') end
        end

    end


    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    button:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    button.DoClick = function()
		surface.PlaySound('ui/button_back.mp3')
        dbt.f4:Close()
        openf4()
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

local function SetCHR( chr )
    if IsGame() or IsClassTrial() then return end
    net.Start("dbt.SetChar")
        net.WriteString(chr)
    net.SendToServer()
end

local materialIconHealth = Material("dbt/f4/stats_icons/stat_hp.png")
local materialIconFood = Material("dbt/f4/stats_icons/stat_food.png")
local materialIconWater = Material("dbt/f4/stats_icons/stat_water.png")
local materialIconSleep = Material("dbt/f4/stats_icons/stat_sleep.png")
local materialIconSpeed = Material("dbt/f4/stats_icons/stat_speed.png")
local materialIconPower = Material("dbt/f4/stats_icons/stat_power.png")
local materialIconWeight = Material("dbt/f4/stats_icons/stat_weight.png")
local materialIconSlots = Material("dbt/f4/stats_icons/stat_slots.png")

local statsGet = {}
statsGet["maxHealth"] = materialIconHealth
statsGet["maxHungry"] = materialIconFood
statsGet["maxThird"] = materialIconWater
statsGet["maxSleep"] = materialIconSleep
statsGet["runSpeed"] = materialIconSpeed
statsGet["fistsDamageString"] = materialIconPower
statsGet["maxKG"] = materialIconWeight
statsGet["maxInventory"] = materialIconSlots

SplashArt = SplashArt or nil
local border_white = Color(255, 255, 255, 10)
local border_pu = Color(140, 10, 196, 150)
local border_pu2 = Color(190, 0, 223, 255)
function open_choose_characters(CURRENT_SEASON)
    local CURRENT_SEASON = CURRENT_SEASON
    dbt.f4:Close()
    local scrw,scrh = ScrW(), ScrH()
    local a = math.random(1, 3)
    SelectedSeason = nil
    CurrentBG = tableBG[a]
    local charactersList = {}
    local countTest = 1
    for k, i in pairs(dbt.chr) do

        if tonumber(i.season) == tonumber(CURRENT_SEASON) then charactersList[countTest] = i charactersList[countTest].trueIndex = k countTest = countTest + 1 end
        if CURRENT_SEASON == 6 and tonumber(i.season) == 20 then charactersList[countTest] = i charactersList[countTest].trueIndex = k countTest = countTest + 1 end 
    end
    SplashArt = nil
    alphaSplah = 100
    xSplash = 0
    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton( false )
    dbt.f4:MakePopup()
    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_seasoins, 0, 0, w, h)
        dbtPaint.DrawRectR(seasons_img[CURRENT_SEASON], w / 2, dbtPaint.HightSource(70), seasons_size[CURRENT_SEASON].x, seasons_size[CURRENT_SEASON].y, 0)
        --dbtPaint.DrawRect(logo, dbtPaint.WidthSource(662), dbtPaint.HightSource(18), dbtPaint.WidthSource(596), dbtPaint.HightSource(241))
         if SplashArt then
            alphaSplah = Lerp(FrameTime() * 5, alphaSplah, 255)
            xSplash = Lerp(FrameTime() * 10, xSplash, 0)
            local text = charactersList[SelectedCharacter].name
			local firstWord = utf8.GetChar( text, 1 )
			local textR = utf8.sub( text, 2 )


            surface.DrawMulticolorText(dbtPaint.WidthSource(45), dbtPaint.HightSource(150), "Comfortaa Bold X60", {border_pu2, firstWord, color_white, textR}, 1000)


            local defaultName = charactersList[SelectedCharacter].absl
            local tblAbsl = string.Explode(" ", charactersList[SelectedCharacter].absl)
            local firstWord = tblAbsl[1]
            local secondWord = string.TrimLeft( defaultName, firstWord.." " )
            draw.SimpleText(firstWord, "Comfortaa Light X40", dbtPaint.WidthSource(32 + 50), dbtPaint.HightSource(215), colorText, TEXT_ALIGN_LEFT)
            draw.SimpleText(secondWord, "Comfortaa Light X40", dbtPaint.WidthSource(32 + 50), dbtPaint.HightSource(245), colorText, TEXT_ALIGN_LEFT)

            draw.RoundedBox(0, dbtPaint.WidthSource(32 + 25), dbtPaint.HightSource(210), dbtPaint.WidthSource(1), dbtPaint.HightSource(93), colorText)


            dbtPaint.DrawRectR(SplashArt, w / 2 + xSplash, h * .6, dbtPaint.WidthSource(975), dbtPaint.HightSource(989), 0, Color(255,255,255,alphaSplah))
            dbtPaint.DrawRect(stat_special_item, dbtPaint.WidthSource(1705), dbtPaint.HightSource(126), dbtPaint.WidthSource(77), dbtPaint.HightSource(42))


            local yPos = 0
            for k, i in pairs(statsGet) do
                dbtPaint.DrawRectR(i, dbtPaint.WidthSource(60), dbtPaint.HightSource(355) + yPos + (i:Height() / 2), i:Width(), i:Height(), 0)
                draw.SimpleText(charactersList[SelectedCharacter][k], "Comfortaa Light X40", dbtPaint.WidthSource(100), dbtPaint.HightSource(350) + yPos, colorText, TEXT_ALIGN_LEFT)
                yPos = yPos + i:Height() + dbtPaint.HightSource(20)
            end
            draw.SimpleText("Уникальный предмет:", "Comfortaa Light X40", dbtPaint.WidthSource(1732), dbtPaint.HightSource(183), color_white, TEXT_ALIGN_CENTER)
            local yCustom = dbtPaint.HightSource(40)
            for k, i in pairs(charactersList[SelectedCharacter].customItems) do
                draw.SimpleText(dbt.inventory.items[i].name, "Comfortaa Light X40", dbtPaint.WidthSource(1732), dbtPaint.HightSource(183) + yCustom, color_white, TEXT_ALIGN_CENTER)
                yCustom = yCustom + dbtPaint.HightSource(35)
	        end

	        for k, i in pairs(charactersList[SelectedCharacter].customWeapons) do
	            draw.SimpleText(weapons.GetStored(i) and weapons.GetStored(i).PrintName or "Отсутствует", "Comfortaa Light X40", dbtPaint.WidthSource(1732), dbtPaint.HightSource(183) + yCustom, color_white, TEXT_ALIGN_CENTER)
                yCustom = yCustom + dbtPaint.HightSource(35)
	        end
            if yCustom == dbtPaint.HightSource(35)  then
                draw.SimpleText("Отсуствует.", "Comfortaa Light X40", dbtPaint.WidthSource(1732), dbtPaint.HightSource(183) + yCustom, color_white, TEXT_ALIGN_CENTER)
            end
        end


    end
    for k, i in pairs(charactersList) do
        local char_tbl = i
        local yCustom = math.floor(k / 11)
        local xPos = dbtPaint.WidthSource(355) + dbtPaint.WidthSource(11 + 111) * (k-1)
        local button = vgui.Create("DButton", dbt.f4)
        button:SetText("")
        button:SetPos(xPos - (dbtPaint.WidthSource(11 + 111) * 10 * yCustom), dbtPaint.HightSource(747) + dbtPaint.HightSource(111 + 11) * yCustom)
        button:SetSize(dbtPaint.WidthSource(111), dbtPaint.HightSource(111))
        button.ColorBorder = colorOutLine
        button.ColorBorder.a = 0
        local material2 = Material("dbt/characters"..char_tbl.season.."/char"..char_tbl.char.."/char_ico_1.png", "smooth")

        local art = Material("dbt/characters"..char_tbl.season.."/char"..char_tbl.char.."/char_art.png", "smooth")
        button.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            if hovered and SelectedCharacter != k then

                if SelectedCharacter and SelectedCharacter > k then
                    xSplash = -20
                else xSplash = 20 end
                SplashArt = art SelectedCharacter = k alphaSplah = 0

            end
            local borderSize = hovered and 3 or 1
            draw.RoundedBox(0, 0, 0, w, borderSize, hovered and border_pu or border_white)
            draw.RoundedBox(0, 0, h - borderSize, w, borderSize, hovered and border_pu or border_white)

            draw.RoundedBox(0, 0, 0, borderSize, h, hovered and border_pu or border_white)
            draw.RoundedBox(0, w - borderSize, 0, borderSize, h, hovered and border_pu or border_white)

            dbtPaint.DrawRect(material2, dbtPaint.WidthSource(6), dbtPaint.HightSource(6), w - dbtPaint.WidthSource(12), h - dbtPaint.HightSource(12))
        end
        button.DoClick = function()
			surface.PlaySound('ui/character_menu.mp3')
            SetCHR(char_tbl.trueIndex)
            dbt.f4:Close()
            SplashArt = nil
        end
		button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    end


    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    button:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    button.DoClick = function()
		surface.PlaySound('ui/button_back.mp3')
        openseasonselect()
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

local colorSettingsPanel = Color(0, 0, 0, 255 * .68)
local colorSettingsNUMSLIDER = Color(255, 255, 255, 255)
local colorSettingstext = Color(194, 194, 194, 255)
local colorSettingsPanelUnActive = Color(255, 255, 255, 255 * .58)
local colorSettingsPanelActive = Color(191, 30, 219, 255 * .58)
local colorSettingsSoundUnactive = Color(86, 86, 86, 255* .38)
local colorSettingsSoundUnactive2 = Color(46, 46, 46, 255* .58)
--285
local buildSettingsType = {}
buildSettingsType[SETTING_NUMSLIDER] = function(parent, inf)
    local settingsPanel = vgui.Create("EditablePanel", parent)
    settingsPanel.Value = settings.Get(inf.settingInfo.name, 10)
    settingsPanel:SetSize(dbtPaint.WidthSource(225), dbtPaint.HightSource(30))
    settingsPanel:SetPos(dbtPaint.WidthSource(635), dbtPaint.HightSource(10))
    local pxlPercentage = dbtPaint.WidthSource(225) / 25
    settingsPanel.Paint = function(self, w, h)
        local percent = self.Value
        for k = 1, 24 do
            local b = (percent > k)
            draw.RoundedBox(0, 0 + dbtPaint.WidthSource(9) * (k - 1), 0, dbtPaint.WidthSource(7), dbtPaint.HightSource(30), b and colorSettingsNUMSLIDER or colorSettingsSoundUnactive2 )
        end
        if self:IsHovered() and input.IsMouseDown( MOUSE_LEFT ) then
            local x, y = input.GetCursorPos()
            local x, y = self:ScreenToLocal( x, y )
            draw.RoundedBox(0, x, y, 3, 3, colorSettingsPanelActive)

            local a = math.Round(x / pxlPercentage)
            local nv = a
            if self.Value != (nv) then settings.Set(inf.settingInfo.name, nv)  end
            self.Value = nv
        end
    end
    return settingsPanel
end

buildSettingsType[SETTING_CHOOSE] = function(parent, inf)
    local settingsPanel = vgui.Create("EditablePanel", parent)
    settingsPanel:SetSize(dbtPaint.WidthSource(295), dbtPaint.HightSource(30))
    settingsPanel:SetPos(dbtPaint.WidthSource(600), dbtPaint.HightSource(10))
    settingsPanel.CurrentChoice = settings.Get(inf.settingInfo.name, 1)
    local choiceNumber = #inf.settingInfo.values
    settingsPanel.Paint = function(self, w, h)
        draw.SimpleText(inf.settingInfo.values[self.CurrentChoice], "_Comfortaa Bold X20", w / 2, -dbtPaint.HightSource(2), color_white, TEXT_ALIGN_CENTER)
    end

    local naZad = vgui.Create("DButton", settingsPanel)
    naZad:SetText("")
    naZad.DoClick = function()
        settingsPanel.CurrentChoice = settingsPanel.CurrentChoice - 1
        if settingsPanel.CurrentChoice <= 0 then settingsPanel.CurrentChoice = choiceNumber end
        settings.Set(inf.settingInfo.name, settingsPanel.CurrentChoice)
    end
    naZad:SetSize(dbtPaint.WidthSource(27), dbtPaint.HightSource(30))
    naZad:SetPos(0, 0)
    naZad.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.SimpleText("<", "Comfortaa Bold X40", w / 2, -dbtPaint.HightSource(9), hovered and colorSettingsPanelActive or colorSettingsPanelUnActive, TEXT_ALIGN_LEFT)
    end

    local vpered = vgui.Create("DButton", settingsPanel)
    vpered:SetText("")
    vpered.DoClick = function()
        settingsPanel.CurrentChoice = settingsPanel.CurrentChoice + 1
        if settingsPanel.CurrentChoice > choiceNumber then settingsPanel.CurrentChoice = 1 end
        settings.Set(inf.settingInfo.name, settingsPanel.CurrentChoice)
    end
    vpered:SetSize(dbtPaint.WidthSource(27), dbtPaint.HightSource(30))
    vpered:SetPos(settingsPanel:GetWide() - dbtPaint.WidthSource(27), 0)
    vpered.Paint = function(self, w, h)
    local hovered = self:IsHovered()
        draw.SimpleText(">", "Comfortaa Bold X40", w / 2, -dbtPaint.HightSource(9), hovered and colorSettingsPanelActive or colorSettingsPanelUnActive, TEXT_ALIGN_CENTER)
    end

    return settingsPanel
end

buildSettingsType[SETTING_BOOLEAN] = function(parent, inf)
    local settingsPanel = vgui.Create("EditablePanel", parent)
    settingsPanel:SetSize(dbtPaint.WidthSource(295), dbtPaint.HightSource(30))
    settingsPanel:SetPos(dbtPaint.WidthSource(600), dbtPaint.HightSource(10))
    settingsPanel.CurrentChoice = settings.Get(inf.settingInfo.name, false)
    settingsPanel.Paint = function(self, w, h)
        local ch = self.CurrentChoice and "ВКЛ" or "ВЫКЛ"
        draw.SimpleText(ch, "_Comfortaa Bold X20", w / 2, -dbtPaint.HightSource(2), color_white, TEXT_ALIGN_CENTER)
    end

    local naZad = vgui.Create("DButton", settingsPanel)
    naZad:SetText("")
    naZad.DoClick = function()
        settingsPanel.CurrentChoice = !settingsPanel.CurrentChoice
        settings.Set(inf.settingInfo.name, settingsPanel.CurrentChoice)
        local b = settingsPanel.CurrentChoice and "1" or "0"
        if settingsConsole[inf.settingInfo.name] then   RunConsoleCommand(settingsConsole[inf.settingInfo.name], b) end
    end
    naZad:SetSize(dbtPaint.WidthSource(27), dbtPaint.HightSource(30))
    naZad:SetPos(0, 0)
    naZad.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.SimpleText("<", "Comfortaa Bold X40", w / 2, -dbtPaint.HightSource(9), hovered and colorSettingsPanelActive or colorSettingsPanelUnActive, TEXT_ALIGN_LEFT)
    end

    local vpered = vgui.Create("DButton", settingsPanel)
    vpered:SetText("")
    vpered.DoClick = function()
        settingsPanel.CurrentChoice = !settingsPanel.CurrentChoice
        settings.Set(inf.settingInfo.name, settingsPanel.CurrentChoice)

                local b = settingsPanel.CurrentChoice and "1" or "0"
        if settingsConsole[inf.settingInfo.name] then RunConsoleCommand(settingsConsole[inf.settingInfo.name], b) end
    end
    vpered:SetSize(dbtPaint.WidthSource(27), dbtPaint.HightSource(30))
    vpered:SetPos(settingsPanel:GetWide() - dbtPaint.WidthSource(27), 0)
    vpered.Paint = function(self, w, h)
    local hovered = self:IsHovered()
        draw.SimpleText(">", "Comfortaa Bold X40", w / 2, -dbtPaint.HightSource(9), hovered and colorSettingsPanelActive or colorSettingsPanelUnActive, TEXT_ALIGN_CENTER)
    end

    return settingsPanel
end

local function buildSettingsLine(info)
    local settingsPanel = vgui.Create("EditablePanel", dbt.f4)
    settingsPanel:SetSize(dbtPaint.WidthSource(913), dbtPaint.HightSource(49))
    settingsPanel:SetPos(dbtPaint.WidthSource(47), ySettings)

	settingsPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end

    settingsPanel.Paint = function(self, w, h)
        local hovered = self:IsHovered() or (self.settype and self.settype:IsHovered())
                draw.RoundedBox(0, 0, 0, w, h, hovered and colorSettingsSoundUnactive or colorSettingsPanel)
        draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(10), h, hovered and colorSettingsPanelActive or colorSettingsPanelUnActive)
        draw.SimpleText(info.name, "_Comfortaa Light X22", dbtPaint.WidthSource(26), dbtPaint.HightSource(5), color_white, TEXT_ALIGN_LEFT)


        if hovered then
            SettingsDesc = info.desc

        end
    end

    local a = buildSettingsType[info.type](settingsPanel, info)
    settingsPanel.settype = a
end


local settingsList = {}
settingsList["system"] = {
    name = "Системное",
    settings = {}
}

settingsList["system"].settings[1] = {
    name = "Громкость музыки",
    type = SETTING_NUMSLIDER,
    settingInfo = {
        name = "Music",
    },
    desc = {
        name = {colorSettingsPanelActive, "Г", color_white, "РОМКОСТЬ МУЗЫКИ"},
        text = {colorSettingstext, "Регулирует уровень громкости фоновой музыки."}
    }
}


settingsList["system"].settings[2] = {
    name = "Первичный раздел на TAB",
    type = SETTING_CHOOSE,
    settingInfo = {
        name = "Tab",
        values = {"ИНВЕНТАРЬ", "ТАБ"}
    },
    desc = {
        name = {colorSettingsPanelActive, "П", color_white, "ЕРВИЧНЫЙ РАЗДЕЛ НА TAB"},
        text = {colorSettingstext, "Определяет, какой раздел открывается первым при нажатии TAB. Вы можете выбрать между инвентарём и списком игроков, в зависимости от ваших предпочтений."}
    }
}
settingsList["system"].settings[3] = {
    name = "Показать прицел",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "Crosshair",
    },
    desc = {
        name = {colorSettingsPanelActive, "П", color_white, "ОКАЗАТЬ ПРИЦЕЛ"},
        text = {colorSettingstext, "Включить или выключить отображение прицела (точки) на экране."}
    }
}

settingsList["system"].settings[4] = {
    name = "Мультикор",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "Multicore",
    },
    desc = {
        name = {colorSettingsPanelActive, "М", color_white, "УЛЬТИКОР"},
        text = {colorSettingstext, "Экспериментальная функция для повышения производительности с использованием нескольких ядер процессора."}
    }
}

settingsList["system"].settings[5] = {
    name = "Тени",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "Shadows",
    },
    desc = {
        name = {colorSettingsPanelActive, "Т", color_white, "ЕНИ"},
        text = {colorSettingstext, "Включить или отключить отображение теней."}
    }
}

settingsList["system"].settings[6] = {
    name = "Сглаживание SMAA",
    type = SETTING_CHOOSE,
    settingInfo = {
        name = "smaa",
        values = {"ВЫКЛ", "Низкое", "Средние", "Высокое", "Ультра"}
    },
    desc = {
        name = {colorSettingsPanelActive, "С", color_white, "глаживание SMAA"},
        text = {colorSettingstext, "Регулирует уровень сглаживания графики с помощью SMAA."}
    }
}

settingsList["system"].settings[7] = {
    name = "SSAO (Эксперементальная)",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "ssao",
    },
    desc = {
        name = {colorSettingsPanelActive, "S", color_white, "SAO"},
        text = {colorSettingstext, "Регулирует уровень Ambient Occlusion (AO) для улучшения теней и освещения."}
    }
}

settingsList["system"].settings[8] = {
    name = "Остановка звуков",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "stopsound",
    },
    desc = {
        name = {colorSettingsPanelActive, "О", color_white, "становка звуков"},
        text = {colorSettingstext, "Работает не как настройка, а как вызов консольной комманды для остановки всех звуков проигрывающихся на данный момент. Помогает в случае проблем со звуком."}
    }
}

settingsList["system"].settings[9] = {
    name = "ЗВУК PM",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "pmsound",
    },
    desc = {
        name = {colorSettingsPanelActive, "З", color_white, "ВУК PM"},
        text = {colorSettingstext, "Включает или выключает звук уведомления личного сообщения."}
    }
}

settingsList["Character"] = {
    name = "Персонаж",
    settings = {}
}

settingsList["Character"].settings[1] = {
    name = "Отображение тела от 1 лица",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "fp_body",
    },
    desc = {
        name = {colorSettingsPanelActive, "О", color_white, "ТОБРАЖЕНИЕ ТЕЛА ОТ 1 ЛИЦА"},
        text = {colorSettingstext, "Показывает тело персонажа, когда вы смотрите вниз в режиме от первого лица."}
    }
}

settingsList["Character"].settings[2] = {
    name = "Отображение волос от 1 лица",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "fp_hair",
    },
    desc = {
        name = {colorSettingsPanelActive, "О", color_white, "ТОБРАЖЕНИЕ ВОЛОС ОТ 1 ЛИЦА"},
        text = {colorSettingstext, "Включает видимость волос персонажа в режиме от первого лица."}
    }
}

settingsList["Character"].settings[3] = {
    name = "Отображение тела во время сидения",
    type = SETTING_BOOLEAN,
    settingInfo = {
        name = "fp_sit",
    },
    desc = {
        name = {colorSettingsPanelActive, "О", color_white, "ТОБРАЖЕНИЕ ТЕЛА ВО ВРЕМЯ СИДЕНИЯ"},
        text = {colorSettingstext, "Показывает тело персонажа в режиме от первого лица при нахождении в положении сидя."}
    }
}


function open_settings()
    if IsValid(dbt.f4) then dbt.f4:Close() end
    local scrw,scrh = ScrW(), ScrH()
    local a = math.random(1, 3)

    CurrentBG = tableBG[a]

    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton( false )
    dbt.f4:MakePopup()
    SettingsDesc = false
    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_main, 0, 0, w, h, colorBG2)

        dbtPaint.DrawRect(text_setting, dbtPaint.WidthSource(787), dbtPaint.HightSource(38), dbtPaint.WidthSource(385), dbtPaint.HightSource(97), color_white)

        if SettingsDesc then
            surface.DrawMulticolorText(dbtPaint.WidthSource(1200), dbtPaint.HightSource(235), "_Comfortaa Bold X24", SettingsDesc.name, 1000)

            surface.DrawMulticolorText(dbtPaint.WidthSource(1200), dbtPaint.HightSource(295), "_Comfortaa Light X24", SettingsDesc.text, 500)
        end

        draw.SimpleText("СИСТЕМНОЕ", "_Comfortaa Bold X29", dbtPaint.WidthSource(57), dbtPaint.HightSource(190), color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("ПЕРСОНАЖ", "_Comfortaa Bold X29", dbtPaint.WidthSource(57), ySettingsзPers and ySettingsзPers or dbtPaint.HightSource(-100), color_white, TEXT_ALIGN_LEFT)
        --dbtPaint.DrawRect(logo, dbtPaint.WidthSource(662), dbtPaint.HightSource(18), dbtPaint.WidthSource(596), dbtPaint.HightSource(241))
    end

    local button = vgui.Create("DButton", dbt.f4)
    button:SetText("")
    button:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    button:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    button.DoClick = function()
		surface.PlaySound('ui/button_back.mp3')
        dbt.f4:Close()
        openf4()
    end
	button.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    button.Paint = function(self, w, h)
    local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorSettingsSoundUnactive or colorSettingsPanel)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
    ySettings = dbtPaint.HightSource(246)
    for k, i in pairs(settingsList["system"].settings) do
        buildSettingsLine(i)
        ySettings = ySettings + dbtPaint.HightSource(55)
    end

    ySettings = ySettings + dbtPaint.HightSource(80)
    ySettingsзPers = ySettings - dbtPaint.HightSource(55)
    for k, i in pairs(settingsList["Character"].settings) do
        buildSettingsLine(i)
        ySettings = ySettings + dbtPaint.HightSource(55)
    end

    
end

hook.Add("InitPostEntity", "openf4", function()
   openf4()
   for k, i in pairs(settingsList) do
    for kk, ii in pairs(i.settings) do
        local settData = ii.settingInfo.name
        local settTyoe = ii.type
        if settTyoe == SETTING_BOOLEAN and settingsConsole[settData] then
            local settInfo = settings.Get(settData, true)
            local b = settInfo and "1" or "0"
            RunConsoleCommand(settingsConsole[settData], b)
        end
    end
   end
end)

net.Receive("dbt.f4menu", openf4)


-- Shader Support dev