sprites = {}
sprites.Spots = {}

sprites.WideExceps = {
    ["3_4_2"]   = true, ["3_4_3"]   = true, ["3_4_4"]   = true, ["3_4_5"]   = true, ["3_4_9"]   = true,
    ["3_4_18"]  = true, ["3_4_19"]  = true, ["3_4_24"]  = true, ["3_14_43"] = true, ["3_14_41"] = true,
    ["3_4_26"]  = true, ["3_4_36"]  = true, ["3_4_37"]  = true, ["3_14_39"] = true,
    ["3_4_38"]  = true, ["3_4_44"]  = true, ["3_4_45"]  = true,  ["3_6_11"]  = true,
    ["3_6_21"]  = true, ["3_6_20"]  = true, ["3_7_10"]  = true,
    ["3_7_12"]  = true, ["3_7_15"]  = true, ["3_7_16"]  = true,
    ["3_7_17"]  = true, ["3_14_49"] = true, ["3_14_48"] = true,
    ["3_7_31"]  = true, ["4_2_25"]  = true,
    ["3_9_10"]  = true, ["3_9_13"]  = true, ["3_9_21"]  = true, ["3_9_22"]  = true, ["3_9_24"]  = true,
    ["3_9_25"]  = true, ["3_9_26"]  = true, ["3_9_27"]  = true, ["3_9_41"]  = true, ["3_14_3"]  = true,
    ["3_14_17"] = true, ["3_14_18"] = true, ["3_14_21"] = true, ["3_14_22"] = true, ["3_14_26"] = true,
    ["3_15_4"]  = true, ["1_8_15"]  = true, ["1_8_16"]  = true,
    ["4_2_10"]  = true, ["4_2_11"]  = true, ["3_4_1"]  = true, ["3_4_12"]  = true, ["3_4_13"]  = true,
    ["3_4_14"]  = true, ["3_4_16"]  = true, ["3_4_17"]  = true,
    ["3_4_25"]  = true, ["3_4_27"]  = true, ["3_4_31"]  = true, ["3_4_32"]  = true, ["3_4_41"]  = true,
    ["3_4_42"]  = true, ["3_4_46"]  = true, ["3_4_49"]  = true, ["3_4_52"]  = true, ["2_3_19"]   = true,
    ["2_3_24"]   = true, ["2_3_25"]   = true, ["2_3_26"]   = true, ["1_13_20"]   = true, ["2_14_12"]   = true,
    ["1_15_6"]   = true, ["1_15_8"]   = true, ["1_15_9"]   = true, ["2_1_25"]   = true, ["2_1_25"]   = true,
    ["3_5_14"]   = true, ["2_13_9"]   = true, ["2_13_12"]   = true, ["2_13_15"]   = true, ["2_14_3"]   = true, ["2_14_13"]   = true, ["dbt/characters9/char29/ct_spriteico_1.vtf"]   = true, ["dbt/characters9/char29/ct_spriteico_2.vtf"]   = true, ["dbt/characters9/char29/ct_spriteico_3.vtf"]   = true,
    ["9_30_1"]   = true, ["9_30_2"]   = true, ["9_30_3"]   = true, ["9_30_4"]   = true, ["9_30_5"]   = true, ["9_30_6"]   = true, ["9_30_7"]   = true, ["9_30_8"]   = true, ["9_30_9"]   = true,
}

for i = 1, 12 do -- 7
    sprites.WideExceps["1_12_" .. i] = true
end
sprites.WideExceps["1_12_" .. 6] = false

for i = 7, 13 do -- 7
    sprites.WideExceps["2_3_" .. i] = true
end

for i = 15, 17 do -- 15
    sprites.WideExceps["2_3_" .. i] = true
end

for i = 1, 5 do -- 15
    sprites.WideExceps["1_13_" .. i] = true
end

for i = 12, 17 do -- 15
    sprites.WideExceps["1_13_" .. i] = true
end
--[[
for SS = 20, 40 do -- 15
   for i = 1, 12 do -- 15
        sprites.WideExceps["20_"..SS.."_" .. i] = true
    end
end]]

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

local fav_icon = Material("dbt/classtrial/trial_fav_sprite.png")

spriteMenu = spriteMenu or {}
spritemenu_Options = {}


function spriteMenu.BuiltButton(seasonId, characterID, spriteID)
    local isMono = (seasonId == 10 and characterID == 1)
    local material = CreateMaterial( seasonId.."_"..characterID.."_"..spriteID, "UnlitGeneric", {
        ["$basetexture"] = "dbt/characters"..seasonId.."/char"..characterID.."/ct_sprite_"..spriteID..".vtf",
        ["$alphatest"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1,
        ["$smooth"] = 1,
        ["$allowalphatocoverage"] = 1,
        ["$alphatestreference "] = 0.8,
    } )
    local button = spritemenu.SpriteList:Add( "DButton" )
    button:SetSize( weight_source(116), (ScrW() * 0.25 / 3) - 15 )
    button:SetText("")
    button.Index = spriteID
    button.HiverEffect = 0
    button.Paint = function(self, w, h)
        factor = 1
        draw.RoundedBox(5, 1, 1, w-2, h-2, Color(39, 0, 49, class_trial_alpha - 100))
        if sprites.WideExceps[ material:GetName() ] then factor = 2 end
        if self:IsHovered() then  self.HiverEffect = Lerp(FrameTime() * 10, self.HiverEffect, -10) else  self.HiverEffect = Lerp(FrameTime() * 10, self.HiverEffect, 0) end
        --local w = (ScrW() * 0.2 / 3) - 15 -- Так надо чтобы спарйты не растягивались
        local pos  = (factor == 2) and (w - w*2) or w - w*1.6 + w*0.3
        surface.SetDrawColor( 255, 255, 255, class_trial_alpha )
        surface.SetMaterial( material )
        surface.DrawTexturedRect( (pos) + self.HiverEffect, isMono and (-190 + self.HiverEffect) or (-30 + self.HiverEffect), (w*1.6 * factor) - self.HiverEffect * 1.5, w*3 - self.HiverEffect * 2)

    end
    button.DoClick = function(self)
        net.Start("ChangeSprite")
            net.WriteFloat(spriteID)
        net.SendToServer()
    end
    local idShort = seasonId.."_"..characterID
    favorieSpriteList[idShort] = favorieSpriteList[idShort] or {}
    local fav_button = button:Add( "DButton" )
    fav_button:SetSize( weight_source(21), weight_source(19) )
    fav_button:SetText("")
    fav_button:SetPos(weight_source(3), weight_source(3))
    fav_button.Index = spriteID
    fav_button.HiverEffect = 0
    fav_button.Paint = function(self, w, h)
        local a = math.Clamp(class_trial_alpha, 0, 200)
        if self:IsHovered() then
           surface.SetDrawColor( 255, 255, 255, a )
            surface.SetMaterial( fav_icon )
            surface.DrawTexturedRect(0,0, w, h)
        else
            if favorieSpriteList[idShort][spriteID] then
                surface.SetDrawColor( 137, 30, 164, a )
                surface.SetMaterial( fav_icon )
                surface.DrawTexturedRect(0,0, w, h)
            else
                surface.SetDrawColor( 100, 100, 100, a )
                surface.SetMaterial( fav_icon )
                surface.DrawTexturedRect(0,0, w, h)
            end
        end
    end
    fav_button.DoClick = function(self)
        if favorieSpriteList[idShort][spriteID] then
            favorieSpriteList[idShort][spriteID] = nil
        else
            favorieSpriteList[idShort][spriteID] = true
        end
        settings.Set("favoriteSprite", favorieSpriteList)
        spriteMenu.BuildList()
    end


    return button
end

spriteMenu.BuildList = function()
    for k, i in pairs(spriteMenu.Buttons) do if IsValid(i) then i:Remove() end end
    spriteMenu.Buttons = {}
    local ply = LocalPlayer()

    favorieSpriteList = settings.Get("favoriteSprite", {})

    if IsMono(ply:Pers()) then 
        local s = dbt.chr[ply:Pers()].season
        local ch = dbt.chr[ply:Pers()].char
        local max_emote = LocalPlayer():SelfData().emote
        local id_char = s.."_"..ch
        
        favorieSpriteList[id_char] = favorieSpriteList[id_char] or {}
        
        for k, i in pairs(favorieSpriteList[id_char]) do
            local button = spriteMenu.BuiltButton(s, ch, k)
            spriteMenu.Buttons[k] = button
        end
    
        for index = 1, LocalPlayer():SelfData().emote do
            if spriteMenu.Buttons[index] then continue end
            local button = spriteMenu.BuiltButton(s, ch, index)
            spriteMenu.Buttons[index] = button
        end
    else 
        local selfindex = ply:GetNWInt("Index")

        local data = Spots[selfindex]
        local s = dbt.chr[data.char].season
        local ch = dbt.chr[data.char].char
        local max_emote = LocalPlayer():SelfData().emote
        local id_char = s.."_"..ch

        favorieSpriteList[id_char] = favorieSpriteList[id_char] or {}

        for k, i in pairs(favorieSpriteList[id_char]) do
            local button = spriteMenu.BuiltButton(s, ch, k)
            spriteMenu.Buttons[k] = button
        end

        for index = 1, LocalPlayer():SelfData().emote do
            if spriteMenu.Buttons[index] then continue end
            local button = spriteMenu.BuiltButton(s, ch, index)
            spriteMenu.Buttons[index] = button
        end
    end
end

spriteMenu.Buttons = spriteMenu.Buttons or {}


function DrawSpritesMenu()
	timer.Simple(2,function ()
	    local ply = LocalPlayer()
	    spriteMenu.Buttons = {}
	    if not InGame(ply) and not IsMono(ply:Pers()) then return end
	    class_trial_alpha = 255

	    spritemenu = vgui.Create("DPanel")
		spritemenu:MakePopup()
		spritemenu:SetKeyboardInputEnabled(false)
	    spritemenu:SetSize(weight_source(401), hight_source(433))
	    spritemenu:SetPos(weight_source(5), hight_source(-2200))
		spritemenu:MoveTo(weight_source(5), 0, 2, 0, -1,function () spritemenu_Optionsfunc() end)
	    spritemenu.Paint = function(self, w, h)
	        if not IsClassTrial() then self:Remove() end
	    end

	    spritemenu.scrollPanel = vgui.Create("DScrollPanel", spritemenu)
	    spritemenu.scrollPanel:Dock(FILL)

	    local sbar = spritemenu.scrollPanel:GetVBar()
	    function sbar:Paint(w, h) end function sbar.btnUp:Paint(w, h) end function sbar.btnDown:Paint(w, h) end function sbar.btnGrip:Paint(w, h) end

	    spritemenu.SpriteList = vgui.Create( "DIconLayout", spritemenu.scrollPanel )
	    spritemenu.SpriteList:Dock( FILL )
	    spritemenu.SpriteList:SetSpaceY( weight_source(9) )
	    spritemenu.SpriteList:SetSpaceX( weight_source(9) )

	    spriteMenu.BuildList()
	end)
end

function spritemenu_Optionsfunc()

	spritemenu_Options = vgui.Create("DButton")
	spritemenu_Options:MakePopup()
	spritemenu_Options:SetKeyboardInputEnabled(false)
	spritemenu_Options:SetSize(weight_source(380), hight_source(50))
	spritemenu_Options:SetPos(weight_source(0), hight_source(435))
	spritemenu_Options:SetFont('Comfortaa X36')
	spritemenu_Options:SetTextColor(Color(255, 255, 255, class_trial_alpha))
	spritemenu_Options:SetText('ПРЕДОСТАВИТЬ УЛИКУ')
	spritemenu_Options.Paint = function(self, w, h)
        if not IsClassTrial() then self:Remove() end
		self:SetTextColor(Color(255, 255, 255, class_trial_alpha))
    end
	spritemenu_Options.DoClick = function()
		local meta = dbt.inventory.info.monopad.meta
		if !meta then return end
		if monopadIsOpen then return end
		openMonopad()
		if IsValid(monopadEv) then monopadEv:Close() end
		monopadEv = vgui.Create("EvidenceFrame", workPlace)
		monopadEv.OnRemove = function() surface.PlaySound('monopad_app_close.mp3') end
        monopadEv:SetTitle("")
        monopadEv:SetSize(dbtPaint.WidthSource(605), dbtPaint.HightSource(652))
        monopadEv:Center()
	end
end

--fav_icon
function GetSprite( index )
    if Spots then
        local data = Spots[index]
        if not data.char then return end
        local s = dbt.chr[data.char].season
        local ch = dbt.chr[data.char].char
        local emote = data.emote

        local material = CreateMaterial( s.."_"..ch.."_"..emote, "UnlitGeneric", {
            ["$basetexture"] = "dbt/characters"..s.."/char"..ch.."/ct_sprite_"..emote..".vtf",
            ["$alphatest"] = 1,
            ["$vertexalpha"] = 1,
            ["$vertexcolor"] = 1,
            ["$smooth"] = 1,

            ["$allowalphatocoverage"] = 1,
            ["$alphatestreference "] = 0.8,
        } )
    --
        return material
    end
end

function spritemenu_OptionsPanel(evidences)
	if IsValid(spritemenu_Options_Panel) then spritemenu_Options_Panel:AlphaTo(0, 0.1, 0.1,function () spritemenu_Options_Panel:Remove() end) return end

	spritemenu_Options_Panel = vgui.Create('DPanel')
	spritemenu_Options_Panel:SetAlpha(0)
	spritemenu_Options_Panel:MakePopup()
	spritemenu_Options_Panel:SetKeyboardInputEnabled(false)
    spritemenu_Options_Panel:SetSize(weight_source(381), hight_source(433))
	spritemenu_Options_Panel:SetPos(weight_source(0), hight_source(487))
	spritemenu_Options_Panel:AlphaTo(255, 0.1, 0.1,function () end)

	spritemenu_Options_Panel.Paint = function(self, w, h)
        if not IsClassTrial() then self:Remove() end

		surface.SetDrawColor(0, 0, 0, 175)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(101, 0, 125, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 3)
    end
	spritemenu_Options_Panel.scrollPanel = vgui.Create("DScrollPanel", spritemenu_Options_Panel)
    spritemenu_Options_Panel.scrollPanel:SetSize(weight_source(375), hight_source(427))
	spritemenu_Options_Panel.scrollPanel:SetPos(weight_source(3), hight_source(3))

    local sbar = spritemenu_Options_Panel.scrollPanel:GetVBar()
    function sbar:Paint(w, h) end function sbar.btnUp:Paint(w, h) end function sbar.btnDown:Paint(w, h) end function sbar.btnGrip:Paint(w, h) end

    spritemenu_Options_Panel.EvidenceList = vgui.Create( "DIconLayout", spritemenu_Options_Panel.scrollPanel )
    spritemenu_Options_Panel.EvidenceList:Dock( FILL )
    spritemenu_Options_Panel.EvidenceList:SetSpaceY( weight_source(9) )
    spritemenu_Options_Panel.EvidenceList:SetSpaceX( weight_source(9) )
	local DButtonDescription
	if dbt.inventory.info.monopad.meta.edv then
		PrintTable(dbt.inventory.info.monopad.meta.edv)
		for i = 1, #dbt.inventory.info.monopad.meta.edv do
			for k, v in pairs(dbt.inventory.info.monopad.meta.edv[i]) do
				local DButton = spritemenu_Options_Panel.EvidenceList:Add( "DButton" )
				DButton.Evidence = v
				local text = DButton.Evidence['name'] or '???'

				if utf8.len(text) > 10 then
					text = utf8.sub(text, 1, 7)
					text = text .. '...'
				end

				DButton:SetSize( weight_source(116), hight_source(150))
			    DButton:SetText("")

				DButton.Paint = function(self, wid, hei)
					surface.SetDrawColor(101, 0, 125, 255)
					surface.DrawRect(0, 0, wid, hei)

					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(Material('materials/'..self.Evidence['icon']))
					surface.DrawTexturedRect(wid*0.5 - hei*0.3, 0, hei*0.6, hei*0.6)

					surface.SetDrawColor(0, 0, 0, 255)
					surface.DrawOutlinedRect(0, 0, wid, hei, 3)

					surface.DrawMulticolorText(4, hei*0.6, 'Comfortaa X30', {color_white, text}, wid - 3)
				end

				DButton.DoClick = function(self)
					if self.Evidence.IsActivated then return end
					netstream.Start("dbt/classtrial/evidence_toall", self.Evidence)
					self.Evidence.IsActivated = true
				end
			end
		end
	end
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

hook.Add("PostDrawTranslucentRenderables", "sprites.Draw", function()

        if game.GetMap() == "drp_hopespeak" then



            if IsClassTrial() then

                    local tbl = normal_camera_position[game.GetMap()]
                    local vec = tbl.monokuma.vec_sp
                    local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                    local material = GetSprite( 1 )
                    cam.Start3D2D( vec, Angle(-90, cool + 90, 90), 1 )
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.SetMaterial( material )
                        surface.DrawTexturedRectRotated( -20, -1, 45, 90, -90 ) --ДРУГОЙ СПРАЙТ 50
                    cam.End3D2D()

                local index = 0
                repeat

                    local factor = 1
                    local vec = GPS_POS[index + 1]
                    local material = GetSprite( index + 1 )
                    if sprites.WideExceps[ material:GetName() ] then factor = 2 end

                    if InGameCHR(Spots[index + 1].char) then
                        local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                        mins = red_mins[index] or 0
                        cam.Start3D2D( vec, Angle(-90, cool + 90, 90), 1 )
                            surface.SetDrawColor( 255, 255, 255, 255 )
                            surface.SetMaterial( material )
                            surface.DrawTexturedRectRotated( -20, mins, 40 * factor, 80, -90 )
                        cam.End3D2D()

                    end

                    index = 1 + index

                until index == #Spots

                local index = 0
                repeat

                    local factor = 1

                    local vec = GPS_POS[index + 1]
                    local material = GetSprite( index + 1 )
                    if sprites.WideExceps[ material:GetName() ] then factor = 2  end

                    if InGameCHR(Spots[index + 1].char) then -- Spots[index + 1].char  player.GetBySteamID(charactersInGame[Spots[index + 1].char].steamID )
                        local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                        cam.Start3D2D( vec, Angle(-90, cool - 90, 90), 1 )
                            surface.SetDrawColor( 0, 0, 0, 255 )
                            surface.SetMaterial( material )
                            surface.DrawTexturedRectRotated( -20, 0, 40 * factor, 80, -90 )
                        cam.End3D2D()
                    end

                    index = 1 + index

                until index == #Spots

            end
        else

             if IsClassTrial() then
                local tbl = normal_camera_position[game.GetMap()]
                    local vec = tbl.monokuma.vec_sp
                    local material = GetSprite( 1 )
                    cam.Start3D2D( vec, Angle(-90, -45 + 90, 90), 1 )
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.SetMaterial( material )
                        surface.DrawTexturedRectRotated( -20, -1, 50 * 1, 90, -90 )
                    cam.End3D2D()

                local index = 0
                repeat

                    local factor = 1
                    local vec = GPS_POS[index + 1]
                    local material = GetSprite( index + 1 )
                    if sprites.WideExceps[ material:GetName() ] then factor = 2 end

                    if InGameCHR(Spots[index + 1].char) then
                        local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                        mins = red_mins[index] or 0
                        cam.Start3D2D( vec, Angle(-90, cool + 90, 90), 1 )
                            surface.SetDrawColor( 255, 255, 255, 255 )
                            surface.SetMaterial( material )
                            surface.DrawTexturedRectRotated( -20, mins, 40 * factor, 80, -90 )
                        cam.End3D2D()

                    end

                    index = 1 + index

                until index == #Spots

                local index = 0
                repeat

                    local factor = 1

                    local vec = GPS_POS[index + 1]
                    local material = GetSprite( index + 1 )
                    if sprites.WideExceps[ material:GetName() ] then factor = 2  end

                    if InGameCHR(Spots[index + 1].char) then -- Spots[index + 1].char  player.GetBySteamID(charactersInGame[Spots[index + 1].char].steamID )
                        local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                        cam.Start3D2D( vec, Angle(-90, cool - 90, 90), 1 )
                            surface.SetDrawColor( 0, 0, 0, 255 )
                            surface.SetMaterial( material )
                            surface.DrawTexturedRectRotated( -20, 0, 40 * factor, 80, -90 )
                        cam.End3D2D()
                    end

                    index = 1 + index

                until index == #Spots

            end

        end
end )


local render_mat = CreateMaterial( "1_1_1", "UnlitGeneric", {
    ["$basetexture"] = "dbt/characters1/char1/ct_sprite_1.vtf",
    ["$alphatest"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$smooth"] = 1,
    ["$allowalphatocoverage"] = 1,
    ["$alphatestreference "] = 0.8,
} )

local render_mat_mono = CreateMaterial( "32423423423", "UnlitGeneric", {
    ["$basetexture"] = "dbt/characters10/char1/ct_sprite_1.vtf",
    ["$alphatest"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$smooth"] = 1,
    ["$allowalphatocoverage"] = 1,
    ["$alphatestreference "] = 0.8,
} )



hook.Add( "PostDrawTranslucentRenderables", "Cooldbt_show", function()


    render.SetColorMaterial()

    if show_ct_pos and GPS_POS then



        if show_ct_pos_sp then


                    local tbl = normal_camera_position[game.GetMap()]
                    local vec = tbl.monokuma.vec_sp
                    local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                    cam.Start3D2D( vec, Angle(-90, cool + 90, 90), 1 )
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.SetMaterial( render_mat_mono )
                        surface.DrawTexturedRectRotated( -20, -1, 45, 90, -90 ) --ДРУГОЙ СПРАЙТ 50
                    cam.End3D2D()

                    local tbl = normal_camera_position[game.GetMap()]
                    local factor = 1

                    index = 0
                    for k,i in pairs(GPS_POS) do
                        local vec = i
                        local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                        local cool = math.Round(cool, 1)


                        mins = red_mins[index] or 0
                        cam.Start3D2D( vec, Angle(-90, cool + 90, 90), 1 )
                            surface.SetDrawColor( 255, 255, 255, 255 )
                            surface.SetMaterial( render_mat )
                            surface.DrawTexturedRectRotated( -20, mins, 40 * factor, 80, -90 )
                        cam.End3D2D()
                        index = index + 1
                    end

        else
            for k,i in pairs(GPS_POS) do
                render.DrawSphere( i, 10, 30, 30, Color( 0, 175, 175, 100 ) )
            end
              local tbl = normal_camera_position[game.GetMap()]
              render.SetColorMaterial()
              render.DrawSphere( tbl.monokuma.vec_sp, 10, 30, 30, Color( 0, 175, 175, 100 ) )

        end
    end
end )

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
    if show_ct_pos and GPS_POS then
                    local tbl = normal_camera_position[game.GetMap()]
                    local factor = 1

                    index = 0
                    for k,i in pairs(GPS_POS) do
                        local vec = i
                        local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
                        local cool = math.Round(cool, 1)
                        local data2D = vec:ToScreen()

                        draw.SimpleText( cool, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        draw.SimpleText( "Index: "..index, "Default", data2D.x, data2D.y + 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                        mins = red_mins[index] or 0
                        cam.Start3D2D( vec, Angle(-90, math.Round(cool, 1) + 90, 90), 1 )
                            surface.SetDrawColor( 255, 255, 255, 255 )
                            surface.SetMaterial( render_mat )
                            surface.DrawTexturedRectRotated( -20, mins, 40 * factor, 80, -90 )
                        cam.End3D2D()
                        index = index + 1
                    end
    end
end )

concommand.Add("GetSekf", function()
    PrintTable(LocalPlayer():SelfData())
end)

local linemat = Material('materials/dbt/lockpick_system/lockpick_line.png')

function dbt.evidence_ShowToAll(evidence)
	surface.PlaySound("ui/tablet_get_bullet.mp3")
	local DPanel = vgui.Create('DPanel')
	DPanel:SetSize(ScreenWidth, ScreenHeight)
	DPanel:MakePopup()
	surface.SetFont('_Comfortaa Bold X18')
	local x, y = surface.GetTextSize(evidence.name)
	surface.SetFont('_Comfortaa Regular X16')
	local x2, y2 = surface.GetTextSize('Улика от:')
	DPanel.Paint = function(self, w, h)
	    if not IsClassTrial() then self:Remove() end

		BlurScreen(20)
		surface.SetDrawColor(0, 0, 0, 221)
		surface.DrawRect(ScreenWidth*0.5 - dbtPaint.WidthSource(255), ScreenHeight*0.5 - dbtPaint.HightSource(275), dbtPaint.WidthSource(510), dbtPaint.HightSource(550))

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material('materials/'..evidence.icon))
		surface.DrawTexturedRect(ScreenWidth*0.5 - dbtPaint.WidthSource(230), ScreenHeight*0.5 - dbtPaint.HightSource(235), dbtPaint.WidthSource(130), dbtPaint.HightSource(130))
		surface.SetMaterial(linemat)
		surface.DrawTexturedRect(ScreenWidth*0.5 - dbtPaint.WidthSource(255), ScreenHeight*0.5 - dbtPaint.HightSource(258), dbtPaint.WidthSource(520), dbtPaint.HightSource(30))

		surface.SetFont('_Comfortaa Bold X18')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(ScreenWidth*0.5 - x * 0.5, ScreenHeight*0.5 - dbtPaint.HightSource(275))
		surface.DrawText(evidence.name)

		surface.SetFont('_Comfortaa Regular X16')
		surface.SetTextColor(244, 173, 255, 255)
		surface.SetTextPos(ScreenWidth*0.5 - dbtPaint.WidthSource(80), ScreenHeight*0.5 - dbtPaint.HightSource(235))
		surface.DrawText('Улика от:')

		surface.SetFont('_Comfortaa Light X16')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(ScreenWidth*0.5 - dbtPaint.WidthSource(80), ScreenHeight*0.5 - dbtPaint.HightSource(235) + y2*0.9)
		surface.DrawText(CharacterNameOnName(evidence.user))

		surface.SetFont('_Comfortaa Regular X16')
		surface.SetTextColor(244, 173, 255, 255)
		surface.SetTextPos(ScreenWidth*0.5 - dbtPaint.WidthSource(80), ScreenHeight*0.5 - dbtPaint.HightSource(235) + (y2*0.9) * 2)
		surface.DrawText('Локация:')

		surface.SetFont('_Comfortaa Light X16')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(ScreenWidth*0.5 - dbtPaint.WidthSource(80), ScreenHeight*0.5 - dbtPaint.HightSource(235) + (y2*0.9) * 3)
		surface.DrawText(evidence.location and evidence.location or '???')

		surface.SetFont('_Comfortaa Regular X16')
		surface.SetTextColor(244, 173, 255, 255)
		surface.SetTextPos(ScreenWidth*0.5 - dbtPaint.WidthSource(255) + dbtPaint.WidthSource(20), ScreenHeight*0.5 - dbtPaint.HightSource(95))
		surface.DrawText('Описание:')
		surface.DrawMulticolorText(ScreenWidth*0.5 - dbtPaint.WidthSource(255) + dbtPaint.WidthSource(20), ScreenHeight*0.5 - dbtPaint.HightSource(95) + y2*0.9, '_Comfortaa Light X16', {color_white, evidence.description and evidence.description or 'Нет описания.'}, dbtPaint.WidthSource(490))

		surface.SetDrawColor(34, 34, 34, 255)
		surface.DrawRect(ScreenWidth*0.5 + dbtPaint.WidthSource(250), ScreenHeight*0.5 - dbtPaint.HightSource(110) + y2*0.9, dbtPaint.WidthSource(5), dbtPaint.HightSource(320))
	end

	local closebtn = vgui.Create('DButton', DPanel)
	closebtn:SetSize(dbtPaint.WidthSource(510), dbtPaint.HightSource(30))
	closebtn:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(255), ScreenHeight*0.5 + dbtPaint.HightSource(245))
	closebtn:SetFont('_Comfortaa Light X18')
	closebtn:SetTextColor(Color(255, 255, 255, 255))
	closebtn:SetText('OK')
	closebtn.Paint = function(self, w, h)
		surface.SetDrawColor(80, 20, 90, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	closebtn.DoClick = function(self) DPanel:Remove() end
end

netstream.Hook("dbt/classtrial/evidence_toall/design", function(evidence, pers, locate)
	dbt.evidence_ShowToAll({name = evidence.name, user = pers, location = locate, description = evidence.desc, icon = evidence.icon})
end)
