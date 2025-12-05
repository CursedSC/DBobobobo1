
ULIKI_TABLE = {}
IsFistTime = true
net.Receive("dbt/mono/rules/update", function()
     rules_akkad = net.ReadString()
     if not IsFistTime then
        surface.PlaySound("ui/ui_but/ui_click.wav")
        see_r = true
        see_msg = false
        R_CAN_LERP1 = false
        R_ALPHA1 = 255
        R_ALPHA2 = ScrH() + 10
        timer.Remove("RMSG1")
        timer.Create("RMSG", 2.5, 1,function()
            R_CAN_LERP1 = true
           timer.Create("RMSG1", 2, 1, function() see_r = false end)
        end)

    end
    IsFistTime = false
end)


surface.CreateFont("mono_pix_hud_ex", {
  font = "PxPlusIBMMDA",
  extended = true,
  size = ScrW() / 30.4,
  weight = 200,
  antialias = true
})
concommand.Add("ShowAcad", function()
    if not LocalPlayer():IsAdmin() then return end
    NEW_RULES = nil
    Oprndesc = vgui.Create("DFrame")
    Oprndesc:SetTitle("Редактирование")
    Oprndesc:MakePopup()
    Oprndesc:SetSize(400, 480)
    Oprndesc:Center()


    local TextEntry = vgui.Create( "DTextEntry", Oprndesc )
    TextEntry:SetPos(0, 30)
    TextEntry:SetSize(400, 400)
    TextEntry:SetMultiline(true)
    TextEntry:SetText(rules_akkad)
    TextEntry:SetUpdateOnType(true)
    TextEntry.OnValueChange = function( self )
        NEW_RULES = self:GetValue()

    end

    local DermaButton = vgui.Create( "DButton", Oprndesc )
    DermaButton:SetText( "Сбросить" )
    DermaButton:SetPos( 25, 440 )
    DermaButton:SetSize( 100, 30 )
    DermaButton.DoClick = function()
       RunConsoleCommand("ResetRule")
       Oprndesc:Close()
    end

    local DermaButton = vgui.Create( "DButton", Oprndesc )
    DermaButton:SetText( "Сохранить" )
    DermaButton:SetPos( 275, 440 )
    DermaButton:SetSize( 100, 30 )
    DermaButton.DoClick = function()
        if not NEW_RULES then return end
        net.Start("dbt/mono/rules/update")
        net.WriteString(NEW_RULES)
        net.SendToServer()
    end


end)

net.Receive("clear.Adv", function() ULIKI_TABLE = {} end)

net.Receive("dbt.AddEvidence", function()

    local data = net.ReadTable()
    find_ulik = true
    find_name = data.name
    --phase_one = true
    --x = ScrW() * -1
    --lerp_m = 2


    EvidaceLerp = Tween(ScrW() * -1, 0, 1, TWEEN_EASE_LINEAR, function()
        timer.Simple(0.7, function()
            EvidaceLerp = Tween(0, ScrW(), 1, TWEEN_EASE_LINEAR, function()
                find_ulik = false
            end)
            EvidaceLerp:Start()
        end)
    end)
    EvidaceLerp:Start()

    surface.PlaySound("ui/tablet_get_bullet.mp3")
end)

local mat_bullet = Material("investigation/get_bullet_1.png")
x = ScrW() * -1
lerp_m = 2
phase_one = true
multy_lll = 1
anim_time_edv = CurTime()
hook.Add("HUDPaint", "dbt.HudEdv", function()
    if find_ulik then
        local w,h = ScrW(),ScrH()
       -- if x > -30 and x < 10 and phase_one then lerp_m = 10 elseif phase_one then lerp_m = 2 end
       -- if x > 10 and x < 40 and not phase_one then lerp_m = 10 elseif not phase_one then lerp_m = 2 end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( mat_bullet )
        surface.DrawTexturedRect( EvidaceLerp:GetValue(), 0, w,h )
        local len = utf8.len( find_name )
        if len > 6 then
            if len > 11 then
                draw.SimpleText( utf8.sub( find_name, 1, 11 ).."-", "mono_pix_hud_ex", w * 0.35 + EvidaceLerp:GetValue(), h * 0.465, color_white, TEXT_ALIGN_LEFT )
            else
                draw.SimpleText( find_name, "mono_pix_hud_ex", w * 0.35 + EvidaceLerp:GetValue(), h * 0.465, color_white, TEXT_ALIGN_LEFT )
            end
        else
            draw.SimpleText( find_name, "mono_pix_hud_ex", w * 0.48 + EvidaceLerp:GetValue(), h * 0.465, color_white, TEXT_ALIGN_CENTER )
        end
    end
end)


hook.Add("OnContextMenuOpen", "dbt.MonoPad", function()
   -- TestMonopad()
    if not LocalPlayer():IsAdmin() then return false end
end)



net.Receive("dbt.Sign", function()
            local ent = net.ReadEntity()
            local str = net.ReadString()
            local frameW, frameH, animTime, animDelay, animEase = 300, 400, 1.8, 0, .1
            Oprndesc = vgui.Create("DFrame")
            Oprndesc:SetTitle("Записка")
            Oprndesc:MakePopup()
            Oprndesc:SetSize(0, 400)
            Oprndesc:Center()
            local isAnimating = true
            Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
                isAnimating = false
            end)
            Oprndesc.Paint = function(self,w,h)

                surface.SetDrawColor(51, 43, 54, 255)
                surface.DrawRect(0, 0, w,h)

                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w, h * 0.07)

                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( Material( "icons/78.png" ) )
                surface.DrawTexturedRect( 8, h * 0.07 + 5, 64, 64 )

				surface.DrawMulticolorText(72, h * 0.07 + 3, 'DermaDefaultBold', {Color(255,255,255,255), ent:GetNWString("Title")}, self:GetWide() - 50)
            end

            sign_richtext = vgui.Create( "RichText", Oprndesc )
            sign_richtext:SetPos( 0,100 )
            sign_richtext:SetSize( 300,300 )

            sign_richtext:InsertColorChange(255, 255, 224, 255)
            sign_richtext:AppendText(str)

            function sign_richtext:PerformLayout()

              self:SetFontInternal("DermaDefaultBold")
              self:SetFGColor(Color(255, 255, 255))

            end

            if ent:GetNWEntity("Owner") == LocalPlayer() then
                local edit = vgui.Create( "DButton", Oprndesc )
                edit:SetText( "" )
                edit:SetPos( 73, 70 )
                edit:SetSize( 150, 30 )
                edit.DoClick = function()
                    if not IsValid(Edit_TextEntry) then

                        sign_richtext:Remove()
                        Edit_TextEntry = vgui.Create( "DTextEntry", Oprndesc )
                        Edit_TextEntry:SetPos( 0,100 )
                        Edit_TextEntry:SetSize( 300,300 )
                        Edit_TextEntry:SetMultiline(true)
                        Edit_TextEntry:SetPaintBackground(false)
                        Edit_TextEntry:SetTextColor( Color(255,255,255) )
                        Edit_TextEntry:SetFont("DermaDefaultBold")
                        Edit_TextEntry:SetValue(str)
                        Edit_TextEntry.OnEnter = function( self )
                        end
                    else
                        netstream.Start("dbt.edit.sign", ent, Edit_TextEntry:GetValue())
                        str = Edit_TextEntry:GetValue()
                        sign_richtext = vgui.Create( "RichText", Oprndesc )
                        sign_richtext:SetPos( 0,100 )
                        sign_richtext:SetSize( 300,300 )

                        sign_richtext:InsertColorChange(255, 255, 224, 255)
                        sign_richtext:AppendText(str)

                        function sign_richtext:PerformLayout()

                          self:SetFontInternal("DermaDefaultBold")
                          self:SetFGColor(Color(255, 255, 255))

                        end
                        netstream.Start("dbt/edit/sign", ent, Edit_TextEntry:GetValue())
                        Edit_TextEntry:Remove()
                    end

                end
                edit.Paint = function(self,w,h)
                    if IsValid(Edit_TextEntry) then
                        draw.DrawText("Сохранить записку", "TargetID", 0, h * 0.2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    else
                        draw.DrawText("Изменить записку", "TargetID", 0, h * 0.2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                end
            end
end)


local m_pad = {}
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/bg.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/lines_vertical.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/icon_cat.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/clock.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/bg_name.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/pyatna.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/colonki.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/black_lines.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/parametrs.png")

--m_pad[#m_pad + 1] = Material("dbt/monopad/bg/drop_weapon.png")
--m_pad[#m_pad + 1] = Material("dbt/monopad/bg/icon_weapon.png")

m_pad[#m_pad + 1] = Material("dbt/monopad/button/un_hovered/Knopka_1_neaktiv.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/button/un_hovered/Knopka_2_neaktiv.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/button/un_hovered/Knopka_3_neaktiv.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/button/un_hovered/Knopka_4_neaktiv.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/button/un_hovered/Knopka_5_neaktiv.png")
m_pad[#m_pad + 1] = Material("dbt/monopad/button/un_hovered/Knopka_6_neaktiv.png")
-- ПОТОМ УБРАТЬ
m_pad[#m_pad + 1] = Material("dbt/monopad/bg/lines_new.png")



local m_pad_rules = {}
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/bg/bg.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/bg/lines_new.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/bg/icon_cat_2.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/button/un_hovered/Knopka_1_neaktiv.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/button/un_hovered/Knopka_2_neaktiv.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/button/un_hovered/Knopka_3_neaktiv.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/button/un_hovered/Knopka_4_neaktiv.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/button/un_hovered/Knopka_5_neaktiv.png")
m_pad_rules[#m_pad_rules + 1] = Material("dbt/monopad/button/un_hovered/Knopka_6_neaktiv.png")

local m_pad_categories = {}
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/bg/bg.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/categories/bg_1.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/categories/line_uliki.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/button/un_hovered/Knopka_1_neaktiv.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/button/un_hovered/Knopka_2_neaktiv.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/button/un_hovered/Knopka_3_neaktiv.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/button/un_hovered/Knopka_4_neaktiv.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/button/un_hovered/Knopka_5_neaktiv.png")
m_pad_categories[#m_pad_categories + 1] = Material("dbt/monopad/button/un_hovered/Knopka_6_neaktiv.png")


local m_pad_ChatMono = {}
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/bg/bg.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/chat/chat_bg.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/chat/chat_type_bg.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/chat/chat_lines.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/categories/line_chat.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/button/un_hovered/Knopka_1_neaktiv.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/button/un_hovered/Knopka_2_neaktiv.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/button/un_hovered/Knopka_3_neaktiv.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/button/un_hovered/Knopka_4_neaktiv.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/button/un_hovered/Knopka_5_neaktiv.png")
m_pad_ChatMono[#m_pad_ChatMono + 1] = Material("dbt/monopad/button/un_hovered/Knopka_6_neaktiv.png")



local glav_type = {}
glav_type["prolog"] = Material("dbt/monopad/stages/stage_prologue.png")
glav_type["epilog"] = Material("dbt/monopad/stages/stage_epilog.png")

for i = 1,6 do
    glav_type["stage_"..i] = Material("dbt/monopad/stages/stage_"..i..".png")
end

local time_type = {}
time_type["freetime"] = Material("dbt/monopad/stages/stage_freetime.png")
time_type["classtrial"] = Material("dbt/monopad/stages/stage_classtrial.png")
time_type["find"] = Material("dbt/monopad/stages/stage_investigation.png")

function but_pres(i)
            timer.Simple(0.1, function()
                surface.PlaySound("ui/monopad_click.mp3")
            end)
            if i == 0 then
                netstream.Start("dbt.open.mono", false)
                monopad:Close()
                TestMonopad()
            end
            if i == 1 then
                monopad:Close()
                AcadRules()
            end
            if i == 3 then
                monopad:Close()
                EvidiceRules()
            end

            if i == 4 then
                monopad:Close()
                ChatMono()
            end

            if i == 5 then
                if not IsGame() then return end
                if not InGame(LocalPlayer()) then
                    if spectator.IsSpectator(LocalPlayer()) then
                        RunConsoleCommand("StopSpectator")
                    else
                    local players = player.GetAll()
                    net.Start("SpectatorNet")
                        net.WriteEntity(players[math.random(1, #players)]) --player.GetBySteamID64(charactersInGame[math.random(1, #charactersInGame)].steamID)
                    net.SendToServer()
                    end
                end
                if spectator.IsSpectator(LocalPlayer()) then
                    RunConsoleCommand("StopSpectator")
                end
            end
end

NextTickClose = CurTime()
hook.Add("PreRender", "esc menu", function()

end)

hook.Add( "PlayerButtonDown", "dbt/inventory/button/close/mono", function( ply, button )

end)

function TestMonopad()


    if not LocalPlayer():HasMonopad() then return end
    if LocalPlayer():InVehicle() then return end
    if LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun" or LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" or not IsValid(LocalPlayer():GetActiveWeapon()) then return end
    mono_pos = 0
    if not LocalPlayer():InVehicle() then
        netstream.Start("dbt.open.mono", true)
    end
    local mp_owner = LocalPlayer():GetMonopadOwner()
    local globaltime = GetGlobalInt("Time")
    local    s = globaltime % 60
    local    tmp = math.floor( globaltime / 60 )
    local    m = tmp % 60
    local    tmp = math.floor( tmp / 60 )
    local    h = tmp % 24
    local curtimesys = string.format( "%02i:%02i", h, m)
    local scrw,scrh = ScrW(), ScrH()
    local button_tbl = {}
    if IsValid(monopad) then
        monopad:Close()
    end
    surface.PlaySound("ui/monopad_open.mp3")
    monopad = vgui.Create("DFrame")
    monopad:SetSize(ScrW(), ScrH())
    monopad:SetTitle("")
    monopad:SetDraggable(false)
    monopad:ShowCloseButton(false)
    monopad:MakePopup()
    text_poss = text_poss or 0
    monopad.Paint = function(self, w, h)
        local globaltime = GetGlobalInt("Time")
        local    s = globaltime % 60
        local    tmp = math.floor( globaltime / 60 )
        local    m = tmp % 60
        local    tmp = math.floor( tmp / 60 )
        local    h = tmp % 24
        local curtimesys = string.format( "%02i:%02i", h, m)
        local time = h
        local time_ = m

        mono_pos = Lerp(FrameTime() * 10, mono_pos, 255)

        for k,i in pairs(m_pad) do
            surface.SetDrawColor( 255, 255, 255, mono_pos )
            surface.SetMaterial( i )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        surface.SetDrawColor( 255, 255, 255, mono_pos )
        surface.SetMaterial( Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/icon_monopad.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, mono_pos )
        surface.SetMaterial( Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/info_monopad.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, mono_pos )
        surface.SetMaterial( Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/name_monopad.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )


        surface.SetDrawColor( 255, 255, 255, mono_pos )
        surface.SetMaterial( glav_type[GetGlobalString("gameStatus_mono")] )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, mono_pos )
        surface.SetMaterial( time_type[GetGlobalString("gameStage_mono")] )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, mono_pos )
        surface.SetMaterial( Material("dbt/monopad/bg/lines_new.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        for k,i in pairs(button_tbl) do
            if i:IsHovered() then
                surface.SetDrawColor( 255, 255, 255, mono_pos )
                surface.SetMaterial( Material("dbt/monopad/button/un_hovered/Knopka_"..k.."_neaktiv.png") )
                surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
            end
        end

        if text_poss > ScrW() * 0.781 then
            text_poss = ScrW() * 0.4 * -1
        end
        if time > 20 or time < 7 then
            surface.SetDrawColor( 255, 255, 255, mono_pos )
            surface.SetMaterial( Material("dbt/monopad/bg/night_icon.png") )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, mono_pos )
            surface.SetMaterial( Material("dbt/monopad/bg/day_icon.png") )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end
        text_poss = text_poss + 0.5
        render.SetScissorRect( ScrW() * 0.112, 0, ScrW() * 0.793, ScrH(), true )
            surface.SetDrawColor( 255, 255, 255, mono_pos )
            surface.SetMaterial( Material("dbt/monopad/bg/run_text.png") )
            surface.DrawTexturedRect( 0 + text_poss, 0, ScrW(), ScrH() )
        render.SetScissorRect( 0, 0, 0, 0, false )



        draw.DrawText( string.format( "%02i:%02i", time, time_), "mono", ScrW() * 0.575, ScrH() * 0.44, color_white, TEXT_ALIGN_LEFT )
    end


    for i = 0, 5 do
        button_tbl[i + 1] = vgui.Create( "DButton", monopad )
        button_tbl[i + 1]:SetText( "" )
        button_tbl[i + 1]:SetPos( ScrW() * 0.01, ScrH() * 0.015 + (ScrH() * 0.155 + ScrH() * 0.01) * i )
        button_tbl[i + 1]:SetSize( ScrW() * 0.085, ScrH() * 0.155 )
        button_tbl[i + 1].DoClick = function()
            but_pres(i)
        end
        button_tbl[i + 1].Paint = function(self, w, h)
        end
        local sss = button_tbl[i + 1]
        function sss:OnCursorEntered()
            surface.PlaySound("ui/monopad_choose.mp3") --surface.PlaySound("ui/button_click")
        end
    end

end


function AcadRules()
    local scrw,scrh = ScrW(), ScrH()
    local button_tbl = {}
    if IsValid(monopad) then
        monopad:Close()
    end
    local mp_owner = LocalPlayer():GetMonopadOwner()
    monopad = vgui.Create("DFrame")
    monopad:SetSize(ScrW(), ScrH())
    monopad:SetTitle("")
    monopad:SetDraggable(false)
    monopad:ShowCloseButton( false )
    monopad:MakePopup()
    text_poss = text_poss or 0
    monopad.Paint = function(self, w, h)
        for k,i in pairs(m_pad_rules) do
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( i )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/icon_monopad.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("dbt/monopad/bg/lines_new.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        for k,i in pairs(button_tbl) do
            if i:IsHovered() then
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( Material("dbt/monopad/button/un_hovered/Knopka_"..k.."_neaktiv.png") )
                surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
            end
        end

        if text_poss > ScrW() * 0.781 then
            text_poss = ScrW() * 0.5 * -1
        end

        text_poss = text_poss + 0.5
        render.SetScissorRect( ScrW() * 0.112, 0, ScrW() * 0.793, ScrH(), true )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("dbt/monopad/bg/run_texts.png") )
            surface.DrawTexturedRect( 0 + text_poss, 0, ScrW(), ScrH() )
        render.SetScissorRect( 0, 0, 0, 0, false )

    end

    local richtext = vgui.Create( "RichText", monopad )
    richtext:SetPos(ScrW() * 0.115, ScrH() * 0.34)
    richtext:SetSize(ScrW() * 0.65, ScrH() * 0.61)

    function richtext.Paint( w, h )

    end

    function richtext:PerformLayout()

        self:SetFontInternal("mono_pix")
        self:SetFGColor(Color(255, 255, 255))

    end

    richtext:InsertColorChange(255, 255, 255, 255)
    richtext:AppendText(rules_akkad)



    for i = 0, 5 do
        button_tbl[i + 1] = vgui.Create( "DButton", monopad )
        button_tbl[i + 1]:SetText( "" )
        button_tbl[i + 1]:SetPos( ScrW() * 0.01, ScrH() * 0.015 + (ScrH() * 0.155 + ScrH() * 0.01) * i )
        button_tbl[i + 1]:SetSize( ScrW() * 0.085, ScrH() * 0.155 )
        button_tbl[i + 1].DoClick = function()
            but_pres(i)
        end
        button_tbl[i + 1].Paint = function(self, w, h)
        end
                local sss = button_tbl[i + 1]
        function sss:OnCursorEntered()
            surface.PlaySound("ui/monopad_choose.mp3") --surface.PlaySound("ui/button_click")
        end
    end
end

MapX = nil
function EvidiceRules()
    local scrw,scrh = ScrW(), ScrH()
    local button_tbl = {}
    if IsValid(monopad) then
        monopad:Close()
    end
    local mp_owner = LocalPlayer():GetMonopadOwner()
    monopad = vgui.Create("DFrame")
    monopad:SetSize(ScrW(), ScrH())
    monopad:SetTitle("")
    monopad:SetDraggable(false)
    monopad:ShowCloseButton( false )
    monopad:MakePopup()
    text_poss = text_poss or 0
    local image = vgui.Create( "DButton", monopad )
        image:SetPos(ScrW() * 0.53, ScrH() * 0.46)
        image:SetSize(ScrW() * 0.22, ScrH() * 0.05)
        image:SetText("")
        image.Paint = function(self, w, h)
            if ACTIVE_EV and ACTIVE_EV.img != "" then
                draw.DrawText( "[Посмотреть фото]", "mono_pix", 0, h / 5, Color(33,200,186), TEXT_ALIGN_LEFT )
            end
        end

        image.DoClick = function()

            image_show = vgui.Create( "Panel", monopad )
            image_show:SetPos(0, 0)
            image_show:SetSize(ScrW(), ScrH())
            image_show:SetText("")

            local closess = vgui.Create( "DButton", image_show )
            closess:SetPos(ScrW() - ScrW() * 0.1, 0)
            closess:SetSize(ScrW() * 0.1, ScrH() * 0.05)
            closess:SetText("")
            closess.Paint = function(self, w, h)
                draw.DrawText( "Закрыть", "mono_pix", 0, h / 5, Color(255,255,255), TEXT_ALIGN_LEFT )
            end
            closess.DoClick = function()
                image_show:Remove()
            end


            function image_show:OnMouseWheeled(delta)
                if N_MapSizeX + delta * 10 <= 50 then return end
                N_MapSizeX = N_MapSizeX + (N_MapSizeX / 1) * delta / 25--delta * 10
                N_MapSizeY = N_MapSizeY + (N_MapSizeY / 1) * delta / 25--delta * 10
            end

            image_show.Paint = function(self, ww, hh)
                if ACTIVE_EV and ACTIVE_EV.img != "" then
                    local mat = HTTP_IMG(ACTIVE_EV.img)
                    local w,h = mat:GetMaterial():Width(), mat:GetMaterial():Height()
                    if not MapX then
                        MapX, MapY, MapSizeX, MapSizeY = ScrW() * 0.5, ScrH() * 0.5, w / 2, h / 2
                        N_MapX, N_MapY, N_MapSizeX, N_MapSizeY = MapX, MapY, MapSizeX, MapSizeY
                    end
                    local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
                    local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
                    if ( self.Dragging ) then
                        local x = mousex - self.Dragging[1]
                        local y = mousey - self.Dragging[2]
                        N_MapX = x
                        N_MapY = y
                    end
                    MapX = Lerp(FrameTime() * 5, MapX, N_MapX)
                    MapY = Lerp(FrameTime() * 5, MapY, N_MapY)
                    MapSizeX = Lerp(FrameTime() * 5, MapSizeX, N_MapSizeX)
                    MapSizeY = Lerp(FrameTime() * 5, MapSizeY, N_MapSizeY)


                    surface.SetDrawColor(0,0,0,240)

                    surface.DrawRect(0,0,ww,hh)

                    surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(mat.material)
                        surface.DrawTexturedRectRotated(MapX, MapY, MapSizeX, MapSizeY, 0)
                end
            end
            function image_show:OnMousePressed()
                self.Dragging = { gui.MouseX() - MapX, gui.MouseY() - MapY }
                self:MouseCapture( true )
            end
            function image_show:OnMouseReleased()
                self.Dragging = nil
                self:MouseCapture( false )
            end
            image_show.DoClick = function()
                image_show:Remove()
                MapX = nil
            end
        end
    monopad.Paint = function(self, w, h)
        for k,i in pairs(m_pad_categories) do
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( i )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/icon_monopad.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("dbt/monopad/bg/lines_new.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )


        for k,i in pairs(button_tbl) do
            if i:IsHovered() then
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( Material("dbt/monopad/button/un_hovered/Knopka_"..k.."_neaktiv.png") )
                surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
            end
        end

        if text_poss > ScrW() * 0.781 then
            text_poss = ScrW() * 0.5 * -1
        end

        text_poss = text_poss + 0.5
        render.SetScissorRect( ScrW() * 0.112, 0, ScrW() * 0.793, ScrH(), true )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("dbt/monopad/categories/run_text.png") )
            surface.DrawTexturedRect( 0 + text_poss, 0, ScrW(), ScrH() )
        render.SetScissorRect( 0, 0, 0, 0, false )



        if ACTIVE_EV then

            surface.SetDrawColor(0,0,0,150)
            surface.DrawRect(ScrW() * 0.42, ScrH() * 0.351, ScrH() / 5.625, ScrH() / 5.625)

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material( ACTIVE_EV.icon ) )
            surface.DrawTexturedRect( ScrW() * 0.42 + 10, ScrH() * 0.351 + 10, ScrH() / 5.625 - 20, ScrH() / 5.625 - 20 )

            draw.DrawText( "Название улики:", "mono_pix", ScrW() * 0.53, ScrH() * 0.38, color_white, TEXT_ALIGN_LEFT )
			surface.DrawMulticolorText(ScrW() * 0.53, ScrH() * 0.42, "mono_pix", {color_white, ACTIVE_EV.name}, ScrW()*0.27)
            --draw.DrawText( ACTIVE_EV.name, "mono_pix", ScrW() * 0.53, ScrH() * 0.42, color_white, TEXT_ALIGN_LEFT )

            local w,h = ScrH() / 5.625, ScrH() / 5.625
                draw.RoundedBox( 2, ScrW() * 0.42, ScrH() * 0.351, w, 2, Color(255, 255, 255) )
                draw.RoundedBox( 2, ScrW() * 0.42, ScrH() * 0.351 + h - 2, w, 2, Color(255, 255, 255) )
                draw.RoundedBox( 2, ScrW() * 0.42, ScrH() * 0.351, 2, h, Color(255, 255, 255) )
                draw.RoundedBox( 2, ScrW() * 0.42 + w - 2, ScrH() * 0.351, 2, h, Color(255, 255, 255) )

        end

    end

    local DScrollPanel = vgui.Create( "DScrollPanel", monopad )
    DScrollPanel:SetPos(ScrW() * 0.115, ScrH() * 0.34)
    DScrollPanel:SetSize(ScrW() * 0.3, ScrH() * 0.61)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)
      --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnDown:Paint(w, h)
      --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnGrip:Paint(w, h)

    end

    ACTIVE_EV = nil
    y = 0

    if not dbt.inventory.info.monopad.meta.edv then dbt.inventory.info.monopad.meta.edv = {} end
    for k,i in pairs(dbt.inventory.info.monopad.meta.edv) do
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetPos(10, y)
        DButton:SetSize(ScrW() / 3.548, ScrH() / 17.14)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor(0,0,0,150)
            surface.DrawRect(0, 0, w, h)

            draw.RoundedBox( 2, 0, 0, w, 2, Color(255, 255, 255) )
            draw.RoundedBox( 2, 0, h - 2, w, 2, Color(255, 255, 255) )

            draw.RoundedBox( 2, 0, 0, 2, h, Color(255, 255, 255) )

            draw.RoundedBox( 2, w - 2, 0, 2, h, Color(255, 255, 255) )

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material( i.icon ) )
            surface.DrawTexturedRect( w / 60, h / 10, ScrH() / 22.5, ScrH() / 22.5 )

            draw.DrawText( i.name, "mono_pix", w / 40 + ScrH() / 22.5, h / 5, color_white, TEXT_ALIGN_LEFT )

        end
        DButton.DoClick = function()
            ACTIVE_EV = i
            showevidice(i.desc)
        end

        y = y + ScrH() / 17.14 + 10
    end


    for i = 0, 5 do
        button_tbl[i + 1] = vgui.Create( "DButton", monopad )
        button_tbl[i + 1]:SetText( "" )
        button_tbl[i + 1]:SetPos( ScrW() * 0.01, ScrH() * 0.015 + (ScrH() * 0.155 + ScrH() * 0.01) * i )
        button_tbl[i + 1]:SetSize( ScrW() * 0.085, ScrH() * 0.155 )
        button_tbl[i + 1].DoClick = function()
            but_pres(i)
        end
        button_tbl[i + 1].Paint = function(self, w, h)
        end
                local sss = button_tbl[i + 1]
        function sss:OnCursorEntered()
            surface.PlaySound("ui/monopad_choose.mp3") --surface.PlaySound("ui/button_click")
        end
    end
end

function showevidice(text)
    if IsValid(ulik_text) then
        ulik_text:Remove()
    end

    ulik_text = vgui.Create( "RichText", monopad )
    ulik_text:SetPos(ScrW() * 0.42, ScrH() * 0.54)
    ulik_text:SetSize(ScrH() * 0.63, ScrH() * 0.4)

    function ulik_text:PerformLayout()

        self:SetFontInternal("mono_pix")
        self:SetFGColor(Color(255, 255, 255))

    end
    local parsed = markup.Parse(text)
    for i, blk in ipairs( parsed.blocks ) do
        ulik_text:InsertColorChange(blk.colour.r, blk.colour.g, blk.colour.b, 255)
        ulik_text:AppendText('\n'..blk.text)
    end
end
LASTINDEXMESSEGE = 0
function CoolMsg(text, mymonopad, tomonopad)
    netstream.Start("dbt/monopad/send/dms", mymonopad, tomonopad, text)
end



ACTIVE_CHR = nil
function ChatMono()

    local scrw,scrh = ScrW(), ScrH()
    local button_tbl = {}
    if not dbt.inventory.info.monopad.meta.chat_m then
        dbt.inventory.info.monopad.meta.chat_m = {}
    end
    if not dbt.inventory.info.monopad.meta.chat then
        dbt.inventory.info.monopad.meta.chat = {}
    end
    if IsValid(monopad) then
        monopad:Close()
    end
    local mp_owner = LocalPlayer():GetMonopadOwner()
    monopad = vgui.Create("DFrame")
    monopad:SetSize(ScrW(), ScrH())
    monopad:SetTitle("")
    monopad:SetDraggable(false)
    monopad:ShowCloseButton( false )
    monopad:MakePopup()
    text_poss = text_poss or 0
    monopad.Paint = function(self, w, h)
        for k,i in pairs(m_pad_ChatMono) do
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( i )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/icon_monopad.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("dbt/monopad/categories/line_chat.png") )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        for k,i in pairs(button_tbl) do
            if i:IsHovered() then
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.SetMaterial( Material("dbt/monopad/button/un_hovered/Knopka_"..k.."_neaktiv.png") )
                surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
            end
        end

    end

    ChatScrollMono = vgui.Create( "DScrollPanel", monopad )
    ChatScrollMono:SetPos(ScrW() * 0.1235, ScrH() * 0.058)
    ChatScrollMono:SetSize(ScrW() * 0.3332, ScrH() * 0.81)

    local sbar = ChatScrollMono:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)
      --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnDown:Paint(w, h)
      --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnGrip:Paint(w, h)

    end


    MonopadsScrolls = vgui.Create( "DScrollPanel", monopad )
    MonopadsScrolls:SetPos(ScrW() * 0.4615, ScrH() * 0.058)
    MonopadsScrolls:SetSize(ScrW() * 0.3032, ScrH() * 0.81)
    local sbar = MonopadsScrolls:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)
      --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnDown:Paint(w, h)
      --draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end
    function sbar.btnGrip:Paint(w, h)

    end
    netstream.Start("dbt/monopad/request/chats", dbt.inventory.info.monopad.meta.id)
    MonopadsListY = 0
    local player_ = MonopadsScrolls:Add( "DButton" )
    player_:SetPos(10, MonopadsListY)
    player_:SetSize(ScrW() * 0.29, ScrH() / 12.14)
    player_:SetText("")
    player_.Paint = function(self, w, h)
        surface.SetDrawColor(0,0,0,150)
        surface.DrawRect(0, 0, w, h)
        draw.RoundedBox( 2, 0, 0, w, 2, Color(255, 255, 255) )
        draw.RoundedBox( 2, 0, h - 2, w, 2, Color(255, 255, 255) )
        draw.RoundedBox( 2, 0, 0, 2, h, Color(255, 255, 255) )
        draw.RoundedBox( 2, w - 2, 0, 2, h, Color(255, 255, 255) )
        draw.DrawText( "Общий чат", "mono_pix", w * 0.175, ScrH() * 0.02, Color(255,255,255), TEXT_ALIGN_LEFT )

        if ACTIVE_CHR == "chat" then
            surface.DrawLine(w * 0.03, h * 0.1, w * 0.05,h * 0.1)
            surface.DrawLine(w * 0.03, h * 0.1, w * 0.03,h * 0.23)
            surface.DrawLine(w * 0.03, h * 0.87, w * 0.05,h * 0.87)
            surface.DrawLine(w * 0.03, h * 0.87, w * 0.03,h * 0.73)
            surface.DrawLine(w * 0.15, h * 0.1, w * 0.13,h * 0.1)
            surface.DrawLine(w * 0.15, h * 0.1, w * 0.15,h * 0.23)
            surface.DrawLine(w * 0.15, h * 0.87,  w * 0.13,h * 0.87)
            surface.DrawLine(w * 0.15, h * 0.87, w * 0.15,h * 0.73)
        end
    end
    player_.DoClick = function()
        netstream.Start("dbt/monopad/request/dms", dbt.inventory.info.monopad.meta.id, "chat")
        ACTIVE_CHR = "chat"
        mono_textentry:RequestFocus()

    end
    MonopadsListY = MonopadsListY + ScrH() / 12.14 + 10

    if ACTIVE_CHR then
        netstream.Start("dbt/monopad/request/dms", dbt.inventory.info.monopad.meta.id, ACTIVE_CHR)
    end
    --BuildChat(DScrollPanel, dbt.chat_m["Цумуги Широганэ"])
    mono_textentry = vgui.Create( "DTextEntry", monopad ) -- create the form as a child of frame
    mono_textentry:SetPos(ScrW() * 0.1235, ScrH() * 0.89)
    mono_textentry:SetSize(ScrW() * 0.6332, ScrH() * 0.066)
    --TextEntry:SetMultiline(true)
    mono_textentry:SetFont("mono_pix_chat")
    mono_textentry:SetPaintBackground(false)
    mono_textentry:SetPlaceholderText( "Сообщение" )
    mono_textentry.OnEnter = function( self )
        if not ACTIVE_CHR then return end
        if self:GetValue() == "" or self:GetValue() == " " then return end
        CoolMsg(self:GetValue(), dbt.inventory.info.monopad.meta.id, ACTIVE_CHR)
        mono_textentry:RequestFocus()
        mono_textentry:SetText("")
    end

    for i = 0, 5 do
        button_tbl[i + 1] = vgui.Create( "DButton", monopad )
        button_tbl[i + 1]:SetText( "" )
        button_tbl[i + 1]:SetPos( ScrW() * 0.01, ScrH() * 0.015 + (ScrH() * 0.155 + ScrH() * 0.01) * i )
        button_tbl[i + 1]:SetSize( ScrW() * 0.085, ScrH() * 0.155 )
        button_tbl[i + 1].DoClick = function()
            but_pres(i)
        end
        button_tbl[i + 1].Paint = function(self, w, h)
        end
                local sss = button_tbl[i + 1]
        function sss:OnCursorEntered()
            surface.PlaySound("ui/monopad_choose.mp3") --surface.PlaySound("ui/button_click")
        end

    end
end


function BuildChat(tables)
    msges = msges or {}
    for k,i in pairs(msges) do
        if IsValid(i) then
            i:Remove()
        end
    end
    MesssegesY = 0
    for k,i in pairs(tables) do
        local stra = #i.message / 33
        local sart = {}

        msges[k] = ChatScrollMono:Add( "DButton" )
        msges[k]:SetPos(10, MesssegesY)
        msges[k]:SetSize(ScrW() * 0.32, ScrH() / 12.14 + ScrH() * 0.011 * stra)
        msges[k]:SetText("")

        msges[k].Paint = function(self, w, h)
            if i.own == LocalPlayer():Pers() then
                draw.RoundedBox(10, 0, 0, w, h, Color(35,35,35,150))
            else
                draw.RoundedBox(10, 0, 0, w, h, Color(0,0,0,150))
            end

            draw.DrawText( i.own, "mono_pix_chat", w * 0.175, ScrH() * 0.01, dbt.chr[i.own].color, TEXT_ALIGN_LEFT )

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("dbt/characters"..dbt.chr[i.own].season.."/char"..dbt.chr[i.own].char.."/icon_chat_monopad.png", "smooth mips") )
            surface.DrawTexturedRect( 10, 0, w * 0.15, w * 0.15)
        end

        local txt = vgui.Create( "RichText", msges[k] )
        txt:SetPos(ScrW() * 0.055, ScrH() * 0.04)
        txt:SetSize(ScrW() * 0.26, ScrH() / 12.14 + ScrH() * 0.011 * stra)
        txt:SetVerticalScrollbarEnabled(false)
        function txt:PerformLayout()
            self:SetFontInternal("mono_pix_chat")
            self:SetFGColor(Color(255, 255, 255))
        end

        txt:InsertColorChange(255, 255, 255, 255)
        txt:AppendText(i.message)

        MesssegesY = MesssegesY + ScrH() / 17.14 + 40 + ScrH() * 0.011 * stra
        LASTINDEXMESSEGE = k
    end
    ChatScrollMono:GetVBar():AnimateTo( MesssegesY, 0.5, 0, 0.5 )
end

function BuildListMonopads(MonopadsList)
    for k,i in pairs(MonopadsList) do
        local player_ = MonopadsScrolls:Add( "DButton" )
        player_:SetPos(10, MonopadsListY)
        player_:SetSize(ScrW() * 0.29, ScrH() / 12.14)
        player_:SetText("")
        player_.Paint = function(self, w, h)
            surface.SetDrawColor(0,0,0,150)
            surface.DrawRect(0, 0, w, h)
            draw.RoundedBox( 2, 0, 0, w, 2, Color(255, 255, 255) )
            draw.RoundedBox( 2, 0, h - 2, w, 2, Color(255, 255, 255) )
            draw.RoundedBox( 2, 0, 0, 2, h, Color(255, 255, 255) )
            draw.RoundedBox( 2, w - 2, 0, 2, h, Color(255, 255, 255) )
            draw.DrawText( i.character, "mono_pix", w * 0.175, ScrH() * 0.02, dbt.chr[i.character].color, TEXT_ALIGN_LEFT )

            if ACTIVE_CHR == i.id then
                surface.DrawLine(w * 0.03, h * 0.1, w * 0.05,h * 0.1)
                surface.DrawLine(w * 0.03, h * 0.1, w * 0.03,h * 0.23)
                surface.DrawLine(w * 0.03, h * 0.87, w * 0.05,h * 0.87)
                surface.DrawLine(w * 0.03, h * 0.87, w * 0.03,h * 0.73)
                surface.DrawLine(w * 0.15, h * 0.1, w * 0.13,h * 0.1)
                surface.DrawLine(w * 0.15, h * 0.1, w * 0.15,h * 0.23)
                surface.DrawLine(w * 0.15, h * 0.87,  w * 0.13,h * 0.87)
                surface.DrawLine(w * 0.15, h * 0.87, w * 0.15,h * 0.73)
            end
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("dbt/characters"..dbt.chr[i.character].season.."/char"..dbt.chr[i.character].char.."/icon_chat_monopad.png", "smooth mips") )
            surface.DrawTexturedRect( 10, 2, w * 0.15, w * 0.15)
        end
        player_.DoClick = function()
            netstream.Start("dbt/monopad/request/dms", dbt.inventory.info.monopad.meta.id, i.id)
            ACTIVE_CHR = i.id
            --mono_textentry:RequestFocus()
            --BuildChat(DScrollPanel__S, dbt.inventory.info.monopad.meta.chat[ACTIVE_CHR])
        end
        MonopadsListY = MonopadsListY + ScrH() / 12.14 + 10
    end
end



netstream.Hook("dbt/monopad/request/dms", function(DirectMessages)
    BuildChat(DirectMessages)
end)
