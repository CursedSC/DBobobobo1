local function LerpColor(ratio, startColor, endColor)
    return Color(
            startColor.r + (endColor.r - startColor.r) * ratio,
            startColor.g + (endColor.g - startColor.g) * ratio,
            startColor.b + (endColor.b - startColor.b) * ratio,
            startColor.a + (endColor.a - startColor.a) * ratio
        )
end

already_death = {}

local bg = Material("dbt/change_part/bg.png")
local box = Material("dbt/change_part/box.png")
local endd = Material("dbt/change_part/ended.png")
local end_d = Material("dbt/change_part/end.png")
local to_be_counted = Material("dbt/change_part/to_be_counted.png")
local test = Material("dbt/change_part/prebg.png")
LERP_CHENGE = 0
BG_COL = 0 
LERP_X_SP = 1

surface.CreateFont("stable_change_font", {
    font = "Futura-Normal", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = true,
    size = ScrW() / 35,
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
})
surface.CreateFont("stable_change_font1", {
    font = "Futura-Normal", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = true,
    size = ScrW() / 34,
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
})

count_life = 16

local charapter_img = {
    [0] = Material("dbt/change_part/prolog.png"),
    [1] = Material("dbt/change_part/charapter_1.png"),
    [2] = Material("dbt/change_part/charapter_2.png"),
    [3] = Material("dbt/change_part/charapter_3.png"),
    [4] = Material("dbt/change_part/charapter_4.png"),
    [5] = Material("dbt/change_part/charapter_5.png"),
    [6] = Material("dbt/change_part/charapter_6.png"),
    [7] = Material("dbt/change_part/charapter_7.png"),
    [8] = Material("dbt/change_part/ended.png"), 
}
local function show_change()
    local w, h = ScrW(), ScrH() 
    StopMusic_acc()
    
    local round = GetGlobalInt("round")
    local characterW, characterH = ui.Scale(504 / 2, 1089 / 2, w / 4, h / 4)
    local charactersH = 200 / 1080 * h
    local charactersY = h + characterH - 1 * (charactersH + characterH)
    surface.PlaySound("changepart.mp3")
    LERP_CHENGE = 0
    BG_COL = 0 
    LERP_X_SP = 1
    TIMER_CHENGE = 0
    CHAR_LERP = 255
    animate_x = 0
    animate_lerp_a = 0
    animate_lerp_b = 0
    animate_box_a = h / 3
    BG_COLOR = Color(255,255,255)
    TWO_PHASE = false
    ZERO_PHASE = true
    lines_leinght = 0
    box_lerp = 0
    timer.Simple(5, function()
        ZERO_PHASE = false
    end)
    count_noise_ex = 1
    timer.Create("Noise_Change", 0.08, 0, function() if count_noise_ex > 27 then count_noise_ex = 1 end count_noise_ex = count_noise_ex + 1 end)
    local mina_frm = vgui.Create("EditablePanel")
    FUCKFRMAE = mina_frm
    mina_frm:SetSize(w,h)
    mina_frm.is_end = false
    mina_frm.Paint = function(self, w, h)
        if not TWO_PHASE then 
           BG_COL = Lerp(FrameTime() * 2, BG_COL, 255)
        end
        surface.SetDrawColor(0,0,0,BG_COL)
        surface.DrawRect(0, 0, w, h)
        if BG_COL >= 200 and not self.is_end and not TWO_PHASE then 
            if not ZERO_PHASE then 
                LERP_X_SP = Lerp(FrameTime(), LERP_X_SP, 0)
            end
            LERP_CHENGE = Lerp(FrameTime(), LERP_CHENGE, 255)
            animate_lerp_a = LERP_CHENGE
        end
        if TWO_PHASE and not self.is_end then 
            BG_COLOR = LerpColor(FrameTime(), BG_COLOR, Color(0, 0, 0))
            animate_x = Lerp(FrameTime() * 2, animate_x, 200)
            animate_lerp_a = Lerp(FrameTime() * 7, animate_lerp_a, 0)
            if animate_lerp_a < 20 then 
                animate_lerp_b = Lerp(FrameTime() * 7, animate_lerp_b, 255)
            end
        end
        if self.is_end then 
            LERP_CHENGE = Lerp(FrameTime() * 3, LERP_CHENGE, 0)
            CHAR_LERP = Lerp(FrameTime(), CHAR_LERP, 0)
            BG_COL = Lerp(FrameTime() * 2, BG_COL, 0)
            animate_lerp_b = Lerp(FrameTime() * 3, animate_lerp_b, 0)
            box_lerp = Lerp(FrameTime() * 3, box_lerp, 0)
        end
        if not ZERO_PHASE then 
            animate_box_a = Lerp(FrameTime() * 3, animate_box_a, 0)
        end



        surface.SetDrawColor( BG_COLOR.r, BG_COLOR.g, BG_COLOR.b, LERP_CHENGE ) 
        surface.SetMaterial( test ) 
        surface.DrawTexturedRect( 0,0,w,h ) 


        
        surface.SetDrawColor( BG_COLOR.r, BG_COLOR.g, BG_COLOR.b, LERP_CHENGE - 100 ) 
        surface.SetMaterial( Material("dbt/change_part/noise/"..count_noise_ex..".jpg", "smooth") ) 
        surface.DrawTexturedRect( 0,0,w,h )       

        if not ZERO_PHASE then 
            surface.SetDrawColor(0,0,0,LERP_CHENGE)
            surface.DrawRect(0,h - h * 0.08, w, h * 0.08)
        end
        surface.SetDrawColor(0,0,0,box_lerp)
        surface.DrawRect((w / 2) - (w * 0.18 / 2), animate_box_a, w * 0.18, w * 0.18)



        if ZERO_PHASE then

            lines_leinght = Lerp(FrameTime() * 2, lines_leinght, 1)
            -- Первая полоска
            local x = (w / 2) - (w * 0.18 / 2)
            local Height = (h / 2) + (w * 0.18 / 2) - h * 0.01
            surface.SetDrawColor(0,0,0,255)
            surface.DrawRect(x, 0, 2, Height * lines_leinght)

            -- Вторая полоска
            local x = w - ((w / 2) - (w * 0.18 / 2)) 
            local Height = (h / 2) + (w * 0.18 / 2) - h * 0.01
            surface.SetDrawColor(0,0,0,255)
            surface.DrawRect(x - 2, h - Height * lines_leinght, 2, Height * lines_leinght)

            -- Третья полоска
            local h_h = (h / 2) + (w * 0.18 / 2) - h * 0.01 + 1
            local Len = (w / 2) + (w * 0.18 / 2)
            surface.SetDrawColor(0,0,0,255)
            surface.DrawRect(0, h_h, Len * lines_leinght, 2)

            -- Четвертая полоска
            local h_h = (h / 2) - (w * 0.18 / 2) - h * 0.005 - 1
            local Len = (w / 2) + (w * 0.18 / 2)
            surface.SetDrawColor(0,0,0,255)
            surface.DrawRect(w - Len * lines_leinght, h_h, Len * lines_leinght, 2)

            if math.Round(lines_leinght, 2) > 0.7 then 
                box_lerp = Lerp(FrameTime() * 3, box_lerp, 255) 
            end
        end
        if round == 0 or round == 8 then 
            surface.SetDrawColor( 0, 0, 0, box_lerp ) 
            surface.SetMaterial( end_d ) 
            surface.DrawTexturedRect( 0,0 + animate_box_a,w,h ) 
        else 
            surface.SetDrawColor( 0, 0, 0, box_lerp ) 
            surface.SetMaterial( endd ) 
            surface.DrawTexturedRect( 0,0 + animate_box_a,w,h ) 
        end

        if TWO_PHASE then 
            surface.SetDrawColor( 139, 12, 161, animate_lerp_b ) 
            surface.SetMaterial( to_be_counted ) 
            surface.DrawTexturedRect( -220 + animate_x, 0,w,h )  
        end

        surface.SetDrawColor( 139, 12, 161, LERP_CHENGE ) 
        surface.SetMaterial( charapter_img[round] ) 
        surface.DrawTexturedRect( 0,0 + animate_box_a,w,h )  
       
        draw.SimpleText( "ВЫЖИВШИХ ОСТАЛОСЬ: ", "stable_change_font", 50 + animate_x, h * 0.935 + animate_box_a, Color(255,255,255, animate_lerp_a) )  
        draw.SimpleText( count_life, "stable_change_font1", w * 0.33 + 50 + animate_x, h * 0.935 + animate_box_a, Color(139, 12, 161, animate_lerp_a) )  

    end

    xIndex = 1
    TIMER_CHENGE = 1
    for k, i in pairs(charactersInGame) do
            local data = dbt.chr[k]
            local persona = data.season.."_"..data.char
            local material = CreateMaterial( "dbt/characters"..data.season.."/char"..data.char.."/sprite_white.vtf", "UnlitGeneric", { -- 10  1
                ["$basetexture"] = "dbt/characters"..data.season.."/char"..data.char.."/sprite_white.vtf",
                ["$alphatest"] = 1, 
                ["$vertexalpha"] = 1,
                ["$vertexcolor"] = 1,
                ["$smooth"] = 1,
                ["$mips"] = 1,
      
                ["$allowalphatocoverage"] = 1,
                ["$alphatestreference "] = 0.8,
            } )

            timer.Remove("change_person_"..k) 
            local chr_frm = vgui.Create("EditablePanel", mina_frm)
            
            local x_pos = ((w - (characterW * 17)) / 20 + characterW) * xIndex - w * .04
            WideFactor = 1
            if persona == "1_12" or persona == "1_13" then WideFactor = 2 x_pos = x_pos - characterW * 0.5 end
            chr_frm:SetSize(characterW * WideFactor, characterH)
            chr_frm:SetPos(x_pos, charactersY - characterH * 0.57) --57
            chr_frm.index = k
            chr_frm.first_phase = true
            chr_frm.color = Color(0,0,0,255)
            chr_frm.Paint = function(self, w, h)
                local me = self
                if math.Round(LERP_X_SP, 2) < 0.05 then 
                    if not i.alive and not timer.Exists("change_person_"..self.index) then 
                        timer.Create("change_person_"..k, TIMER_CHENGE, 0, function()
                            if IsValid(me) then 
                                me.canlerp = true
                            end
                        end)
                        TIMER_CHENGE = TIMER_CHENGE + 1
                    end
                end 
                if self.canlerp and self.first_phase and not already_death[k] then 
                    if not self.emit then 
                        timer.Simple(0.2, function()  surface.PlaySound("udar_molotom.mp3") end)
                        self.emit = true
                        count_life = count_life - 1
                        already_death[k] = true
                    end
                    self.color = LerpColor(FrameTime(), self.color, Color(139, 12, 161))
                end
                if already_death[k] and self.first_phase then 
                    self.color = Color(139, 12, 161)
                end

                if not self.first_phase and i.alive then 
                    self.color = LerpColor(FrameTime(), self.color, Color(255,255,255))
                end
                surface.SetDrawColor( self.color.r, self.color.g, self.color.b, CHAR_LERP ) 
                surface.SetMaterial( material ) 
                surface.DrawTexturedRect( 0, h * LERP_X_SP, w, h) 
            end
            timer.Simple(13, function()
                chr_frm.first_phase = false
                TWO_PHASE = true
            end) 
        xIndex = xIndex + 1
    end
    timer.Simple(17, function() mina_frm.is_end = true timer.Simple(1, function() mina_frm:Remove() timer.Remove("Noise_Change")  end)   end)
end


hook.Add( "PlayerBindPress", "PlayerBindPressPlayerBindPress", function( ply, mv )
    if IsValid(FUCKFRMAE) then return false end

end)


hook.Add( "StartCommand", "dontmovemono", function( ply, cmd )
    if IsValid(FUCKFRMAE) then
        cmd:ClearMovement() 
        cmd:ClearButtons()
    end
end )



netstream.Hook("dbt/new/round", show_change) 
concommand.Add("ShowTest", show_change)