music_valume = CreateClientConVar("music_valume", "50", true, false, "Музыка", 1, 100)
local up = Material("up.png")
local right = Material("right.png")
local left = Material("left.png")

local scrw, scrh = ScrW(), ScrH()


local count = Material("menu/count.png")
local exit = Material("menu/exit.png")
local pers = Material("menu/pers.png")
local settings = Material("menu/set.png")

local dcount = Material("menu/countdown.png")
local dexit = Material("menu/exitdown.png")
local dpers = Material("menu/persdown.png")
local dsettings = Material("menu/setdown.png")

local up = Material("up.png")
local right = Material("right.png")
local left = Material("left.png")

-- 1 данганронпа

local pfon1 = Material("pers1/fon.png")
local logo = Material("pers1/logo.png")
local test = Material("pers1/test.png")
local all = Material("pers1/tolp.png")

local prs1 = Material("pers1/1.png")
local prs11 = Material("pers1/11.png")
local prs5 = Material("pers1/5.png")
local prs13 = Material("pers1/13.png")
local prs3 = Material("pers1/3.png")
local prs6 = Material("pers1/6.png")
local prs2 = Material("pers1/2.png")
local prs9 = Material("pers1/9.png")
local prs4 = Material("pers1/4.png")
local prs7 = Material("pers1/7.png")
local prs10 = Material("pers1/10.png")
local prs12 = Material("pers1/12.png")
local prs8 = Material("pers1/8.png")
local prs14 = Material("pers1/14.png")
local prs17 = Material("pers1/17.png")
local prs15 = Material("pers1/15.png")
local prs16 = Material("pers1/16.png")
-- 2 данганронпа

local tpfon1 = Material("pers2/fon.png")
local tlogo = Material("pers2/text.png")
local ttest = Material("pers2/test.png")
local tall = Material("pers2/tolp.png")


local tprs1 = Material("pers2/1.png")
local tprs11 = Material("pers2/11.png")
local tprs5 = Material("pers2/5.png")
local tprs13 = Material("pers2/13.png")
local tprs3 = Material("pers2/3.png")
local tprs6 = Material("pers2/6.png")
local tprs2 = Material("pers2/2.png")
local tprs9 = Material("pers2/9.png")
local tprs4 = Material("pers2/4.png")
local tprs7 = Material("pers2/7.png")
local tprs10 = Material("pers2/10.png")
local tprs12 = Material("pers2/12.png")
local tprs8 = Material("pers2/8.png")
local tprs14 = Material("pers2/14.png")
local tprs15 = Material("pers2/15.png")
local tprs16 = Material("pers2/16.png")

-- 3 данганронпа

local rpfon1 = Material("pers3/fon.png")
local rlogo = Material("pers3/text.png")
local rtest = Material("pers3/test.png")
local rall = Material("pers3/tolp.png")


local rprs1 = Material("pers3/1.png")
local rprs11 = Material("pers3/11.png")
local rprs5 = Material("pers3/5.png")
local rprs13 = Material("pers3/13.png")
local rprs3 = Material("pers3/3.png")
local rprs6 = Material("pers3/6.png")
local rprs2 = Material("pers3/2.png")
local rprs9 = Material("pers3/9.png")
local rprs4 = Material("pers3/4.png")
local rprs7 = Material("pers3/7.png")
local rprs10 = Material("pers3/10.png")
local rprs12 = Material("pers3/12.png")
local rprs8 = Material("pers3/8.png")
local rprs14 = Material("pers3/14.png")
local rprs15 = Material("pers3/15.png")
local rprs16 = Material("pers3/16.png")

-- Доп данганронпа

local dpfon1 = Material("pers4/fon.png")
local dlogo = Material("pers4/text.png")
local dtest = Material("pers4/test.png")
local dall = Material("pers4/tolp.png")


local dprs1 = Material("pers4/1.png")
local dprs11 = Material("pers4/11.png")
local dprs5 = Material("pers4/5.png")
local dprs13 = Material("pers4/13.png")
local dprs3 = Material("pers4/3.png")
local dprs6 = Material("pers4/6.png")
local dprs2 = Material("pers4/2.png")
local dprs9 = Material("pers4/9.png")
local dprs4 = Material("pers4/4.png")
local dprs7 = Material("pers4/7.png")
local dprs10 = Material("pers4/10.png")
local dprs12 = Material("pers4/12.png")
local dprs8 = Material("pers4/8.png")
local dprs14 = Material("pers4/14.png")
local dprs15 = Material("pers4/15.png")
local dprs16 = Material("pers4/16.png")

local element1 = Material("f4/2c2210ca-725c-493b-976b-615c67001bc7.png")
local element2 = Material("f4/da873b42-a6fb-4c14-ac2f-5ccf7d7d1540.png")
local element3 = Material("f4/f1ed1c13-2366-4e2a-9b2e-74160c21b353.png")

local element4 = Material("f4/16981145-a91a-4bd3-8e8a-1bd85953113c.png")
local element = Material("f4/5d16a9fa-47f2-4f3b-9558-743dd82c2a68.png")
local element5 = Material("f4/37438202-120d-4647-bbdf-9307051cf0c3.png")
function dbt.F4menu()
    scrw,scrh = ScrW(), ScrH()
    if IsValid(dbt.sp2menu) then
        dbt.sp2menu:Close()
    end

    dbt.sp2menu = vgui.Create("DFrame")
    dbt.sp2menu:SetSize(ScrW(), ScrH())
    dbt.sp2menu:SetTitle("")
    dbt.sp2menu:SetDraggable(false)
    dbt.sp2menu:ShowCloseButton( false )
    dbt.sp2menu:MakePopup()

    bpers = vgui.Create( "DButton", dbt.sp2menu )
    bpers:SetText( "" )
    bpers:SetSize( scrw * .365, scrh * .1 )
    bpers:SetPos( scrw * .317, scrh * .39 )
    bpers.Paint = function()
    end
    bpers.DoClick = function()
        dbt.sp2menu:Close()
            timer.Simple(0.1, function()   
                surface.PlaySound("ui/button_click.mp3")
            end)
    end
    function bpers:OnCursorEntered()
            timer.Simple(0.1, function()   
                surface.PlaySound("ui/button_active.mp3")
            end) --surface.PlaySound("ui/button_click")
    end

    bsetting = vgui.Create( "DButton", dbt.sp2menu )
    bsetting:SetText( "" )
    bsetting:SetSize( scrw * .365, scrh * .1 )
    bsetting:SetPos( scrw * .317, scrh * .524 )
    bsetting.Paint = function()
    end
    bsetting.DoClick = function()
        pers1()
        dbt.sp2menu:Close()
            timer.Simple(0.1, function()   
                surface.PlaySound("ui/button_click.mp3")
            end)
    end
    function bsetting:OnCursorEntered()
            timer.Simple(0.1, function()   
                surface.PlaySound("ui/button_active.mp3")
            end) --surface.PlaySound("ui/button_click")
    end
    bcont = vgui.Create( "DButton", dbt.sp2menu )
    bcont:SetText( "" )
    bcont:SetSize( scrw * .365, scrh * .1 )
    bcont:SetPos( scrw * .317, scrh * .65 )
    bcont.Paint = function()
    end
    bcont.DoClick = function()
        settingsmenu()
        dbt.sp2menu:Close()
            timer.Simple(0.1, function()   
                surface.PlaySound("ui/button_click.mp3")
            end)
    end
    function bcont:OnCursorEntered()
            timer.Simple(0.1, function()   
                surface.PlaySound("ui/button_active.mp3")
            end) --surface.PlaySound("ui/button_click")
    end

    dbt.sp2menu.Paint = function(self, w, h)
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( element1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if not bpers:IsHovered() and not bcont:IsHovered() and not bsetting:IsHovered()  then 
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( element5 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end
        if bpers:IsHovered() then 
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("f4/54c98879-7107-46d8-abef-063d9d09e923.png") )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        if bcont:IsHovered() then 
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("f4/62c37a4d-3c0b-4ff5-a5dc-f4b9f72228d0.png") )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        if bsetting:IsHovered() then 
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("f4/002591cf-ab25-44fe-9261-be5ba7d9cf07.png") )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end
    
    end
end


function SetCHR( chr )
    if IsGame() or IsClassTrial() then return end
    net.Start("dbt.SetChar")
        net.WriteString(chr)
    net.SendToServer()
end

function pers1(ply)

    local fraction = 0
    local lerptime = 0.3


    if IsValid(changepers) then
        changepers:Close()
    end

    local frameW, frameH, animTime, animDelay, animEase = scrw * .2, scrh * .2, 1.8, 0, .1
    local changepers = vgui.Create("DFrame")
    changepers:SetSize(ScrW(), ScrH())
    changepers:SetTitle("")
    changepers:SetDraggable(false)
    changepers:ShowCloseButton( false )
    changepers:MakePopup()


    local pnsor1 = vgui.Create( "DButton", changepers )
        pnsor1:SetText( "" )
        pnsor1:SetSize( scrw * .09, scrh * .4 )
        pnsor1:SetPos( scrw * .14, scrh * .6 )
        pnsor1.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Аой Асахина")
        end
        pnsor1.Paint = function()
        end

    local pnsor2 = vgui.Create( "DButton", changepers )
        pnsor2:SetText( "" )
        pnsor2:SetSize( scrw * .08, scrh * .4 )
        pnsor2:SetPos( scrw * .39, scrh * .6 )
        pnsor2.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Бьякуя Тогами")
        end
        pnsor2.Paint = function()
        end

    local pnsor3 = vgui.Create( "DButton", changepers )
        pnsor3:SetText( "" )
        pnsor3:SetSize( scrw * .1, scrh * .34 )
        pnsor3:SetPos( scrw * .12, scrh * .28 )
        pnsor3.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Джунко Эношима")
        end
        pnsor3.Paint = function()
        end

    local pnsor4 = vgui.Create( "DButton", changepers )
        pnsor4:SetText( "" )
        pnsor4:SetSize( scrw * .1, scrh * .5 )
        pnsor4:SetPos( scrw * .56, scrh * .57 )
        pnsor4.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Кёко Киригири")
        end
        pnsor4.Paint = function()
        end

    local pnsor5 = vgui.Create( "DButton", changepers )
        pnsor5:SetText( "" )
        pnsor5:SetSize( scrw * .13, scrh * .5 )
        pnsor5:SetPos( scrw * .73, scrh * .57 )
        pnsor5.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Киётака Ишимару")
        end
        pnsor5.Paint = function()
        end

    local pnsor6 = vgui.Create( "DButton", changepers )
        pnsor6:SetText( "" )
        pnsor6:SetSize( scrw * .11, scrh * .4 )
        pnsor6:SetPos( scrw * .29, scrh * .6 )
        pnsor6.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Леон Кувата")
        end
        pnsor6.Paint = function()
        end

    local pnsor7 = vgui.Create( "DButton", changepers )
        pnsor7:SetText( "" )
        pnsor7:SetSize( scrw * .11, scrh * .5 )
        pnsor7:SetPos( scrw * .46, scrh * .56 )
        pnsor7.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Макото Наэги")
        end
        pnsor7.Paint = function()
        end

    local pnsor8 = vgui.Create( "DButton", changepers )
        pnsor8:SetText( "" )
        pnsor8:SetSize( scrw * .1, scrh * .6 )
        pnsor8:SetPos( scrw * .83, scrh * .53 )
        pnsor8.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
           SetCHR("Мондо Овада")
        end
        pnsor8.Paint = function()
        end

    local pnsor9 = vgui.Create( "DButton", changepers )
        pnsor9:SetText( "" )
        pnsor9:SetSize( scrw * .09, scrh * .29 )
        pnsor9:SetPos( scrw * .7, scrh * .29 )
        pnsor9.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Мукуро Икусаба")
        end
        pnsor9.Paint = function()
        end

    local pnsor10 = vgui.Create( "DButton", changepers )
        pnsor10:SetText( "" )
        pnsor10:SetSize( scrw * .25, scrh * .29 )
        pnsor10:SetPos( scrw * .37, scrh * .29 )
        pnsor10.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Сакура Огами")
        end
        pnsor10.Paint = function()
        end

    local pnsor11 = vgui.Create( "DButton", changepers )
        pnsor11:SetText( "" )
        pnsor11:SetSize( scrw * .09, scrh * .5 )
        pnsor11:SetPos( scrw * .23, scrh * .57 )
        pnsor11.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Саяка Майзоно")
        end
        pnsor11.Paint = function()
        end

    local pnsor12 = vgui.Create( "DButton", changepers )
        pnsor12:SetText( "" )
        pnsor12:SetSize( scrw * .11, scrh * .29 )
        pnsor12:SetPos( scrw * .6, scrh * .29 )
        pnsor12.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Селестия Люденберг")
        end
        pnsor12.Paint = function()
        end

    local pnsor14 = vgui.Create( "DButton", changepers )
        pnsor14:SetText( "" )
        pnsor14:SetSize( scrw * .08, scrh * .5 )
        pnsor14:SetPos( scrw * .66, scrh * .57 )
        pnsor14.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Токо Фукава")
        end
        pnsor14.Paint = function()
        end

    local pnsor15 = vgui.Create( "DButton", changepers )
        pnsor15:SetText( "" )
        pnsor15:SetSize( scrw * .17, scrh * .3 )
        pnsor15:SetPos( scrw * .21, scrh * .27 )
        pnsor15.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Хифуми Ямада")
        end
        pnsor15.Paint = function()
        end
    local pnsor16 = vgui.Create( "DButton", changepers )
        pnsor16:SetText( "" )
        pnsor16:SetSize( scrw * .09, scrh * .4 )
        pnsor16:SetPos( scrw * .06, scrh * .6 )
        pnsor16.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Чихиро Фуджисаки")
        end
        pnsor16.Paint = function()
        end

    local pnsor17 = vgui.Create( "DButton", changepers )
        pnsor17:SetText( "" )
        pnsor17:SetSize( scrw * .14 , scrh * .29 )
        pnsor17:SetPos( scrw * .78, scrh * .29 )
        pnsor17.DoClick = function(ply)
            changepers:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Ясухиро Хагакурэ")
        end
        pnsor17.Paint = function()
        end

    local texit = vgui.Create( "DButton", changepers )
        texit:SetText( "" )
        texit:SetSize( scrw * .09, scrh * .07 )
        texit:SetPos( scrw * .01, scrh * .01 )
        texit.DoClick = function()
            changepers:Close()
            dbt.F4menu()
            surface.PlaySound("ui/button_back.mp3")
        end
        texit.Paint = function()
        end

    local leftbut = vgui.Create( "DButton", changepers )
        leftbut:SetText( "" )
        leftbut:SetSize( scrw * .036, scrh * .17 )
        leftbut:SetPos( scrw * .94, scrh * .47 )
        leftbut.DoClick = function()
            changepers:Close()
            pers2()
        end
        leftbut.Paint = function()
        end


    changepers.Paint = function(self, w, h)

        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        local alphas = Lerp(fraction, 0, 255)

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( pfon1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( logo )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )


        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( all )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( right )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( left )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( up )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if pnsor1:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor2:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs2 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor3:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs3 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor4:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs4 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor5:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs5 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor6:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs6 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor7:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs7 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor8:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs8 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor9:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs9 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor10:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs10 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor11:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs11 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor12:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs12 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor14:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs14 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor15:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs15 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor16:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs16 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor17:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( prs17 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end
    end
end

function pers2(ply)
    local fraction = 0
    local lerptime = 0.3
    if IsValid(changepers2) then
        changepers2:Close()
    end

    local frameW, frameH, animTime, animDelay, animEase = scrw * .2, scrh * .2, 1.8, 0, .1
    local changepers2 = vgui.Create("DFrame")
    changepers2:SetSize(ScrW(), ScrH())
    changepers2:SetTitle("")
    changepers2:SetDraggable(false)
    changepers2:ShowCloseButton( false )
    changepers2:MakePopup()

    local texit = vgui.Create( "DButton", changepers2 )
        texit:SetText( "" )
        texit:SetSize( scrw * .09, scrh * .07 )
        texit:SetPos( scrw * .01, scrh * .01 )
        texit.DoClick = function()
            changepers2:Close()
            dbt.F4menu()
        end
        texit.Paint = function()
        end

    local leftbut = vgui.Create( "DButton", changepers2 )
        leftbut:SetText( "" )
        leftbut:SetSize( scrw * .036, scrh * .17 )
        leftbut:SetPos( scrw * .94, scrh * .47 )
        leftbut.DoClick = function()
            changepers2:Close()
            pers3()
            surface.PlaySound( "lobby/item_active.mp3" )
        end
        leftbut.Paint = function()
        end

    local rightbut = vgui.Create( "DButton", changepers2 )
        rightbut:SetText( "" )
        rightbut:SetSize( scrw * .036, scrh * .17 )
        rightbut:SetPos( scrw * .02 , scrh * .47 )
        rightbut.DoClick = function()
            changepers2:Close()
            pers1()
            surface.PlaySound( "lobby/item_active.mp3" )
        end
        rightbut.Paint = function()
        end

        local pnsor1 = vgui.Create( "DButton", changepers2 )
        pnsor1:SetText( "" )
        pnsor1:SetSize( scrw * .12, scrh * .4 )
        pnsor1:SetPos( scrw * .09, scrh * .4 )
        pnsor1.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Аканэ Овари")
        end
        pnsor1.Paint = function()
        end

        local pnsor2 = vgui.Create( "DButton", changepers2 )
        pnsor2:SetText( "" )
        pnsor2:SetSize( scrw * .12, scrh * .4 )
        pnsor2:SetPos( scrw * .3, scrh * .6 )
        pnsor2.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Гандам Танака")
        end
        pnsor2.Paint = function()
        end

        local pnsor3 = vgui.Create( "DButton", changepers2 )
        pnsor3:SetText( "" )
        pnsor3:SetSize( scrw * .14, scrh * .19 )
        pnsor3:SetPos( scrw * .21, scrh * .42 )
        pnsor3.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
           SetCHR("Ибуки Миода")
        end
        pnsor3.Paint = function()
        end

        local pnsor4 = vgui.Create( "DButton", changepers2 )
        pnsor4:SetText( "" )
        pnsor4:SetSize( scrw * .14, scrh * .22 )
        pnsor4:SetPos( scrw * .57, scrh * .37 )
        pnsor4.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Самозванец")
        end
        pnsor4.Paint = function()
        end

        local pnsor5 = vgui.Create( "DButton", changepers2 )
        pnsor5:SetText( "" )
        pnsor5:SetSize( scrw * .06, scrh * .44 )
        pnsor5:SetPos( scrw * .57, scrh * .57 )
        pnsor5.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Махиру Коизуми")
        end
        pnsor5.Paint = function()
        end

        local pnsor6 = vgui.Create( "DButton", changepers2 )
        pnsor6:SetText( "" )
        pnsor6:SetSize( scrw * .06, scrh * .44 )
        pnsor6:SetPos( scrw * .41, scrh * .57 )
        pnsor6.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Микан Цумики")
        end
        pnsor6.Paint = function()
        end

        local pnsor7 = vgui.Create( "DButton", changepers2 )
        pnsor7:SetText( "" )
        pnsor7:SetSize( scrw * .08, scrh * .44 )
        pnsor7:SetPos( scrw * .74, scrh * .57 )
        pnsor7.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Нагито Комаэда")
        end
        pnsor7.Paint = function()
        end

        local pnsor8 = vgui.Create( "DButton", changepers2 )
        pnsor8:SetText( "" )
        pnsor8:SetSize( scrw * .14, scrh * .32 )
        pnsor8:SetPos( scrw * .45, scrh * .27 )
        pnsor8.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Нэкомару Нидай")
        end
        pnsor8.Paint = function()
        end

        local pnsor9 = vgui.Create( "DButton", changepers2 )
        pnsor9:SetText( "" )
        pnsor9:SetSize( scrw * .12, scrh * .44 )
        pnsor9:SetPos( scrw * .2, scrh * .61 )
        pnsor9.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Пеко Пекояма")
        end
        pnsor9.Paint = function()
        end

        local pnsor13 = vgui.Create( "DButton", changepers2 )
        pnsor13:SetText( "" )
        pnsor13:SetSize( scrw * .12, scrh * .47 )
        pnsor13:SetPos( scrw * .08, scrh * .61 )
        pnsor13.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Фуюхико Кузурю")
        end
        pnsor13.Paint = function()
        end

        local pnsor10 = vgui.Create( "DButton", changepers2 )
        pnsor10:SetText( "" )
        pnsor10:SetSize( scrw * .13, scrh * .43 )
        pnsor10:SetPos( scrw * .63, scrh * .58 )
        pnsor10.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Казуичи Сода")
        end
        pnsor10.Paint = function()
        end

        local pnsor11 = vgui.Create( "DButton", changepers2 )
        pnsor11:SetText( "" )
        pnsor11:SetSize( scrw * .13, scrh * .43 )
        pnsor11:SetPos( scrw * .8, scrh * .58 )
        pnsor11.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
             SetCHR("Сония Невермайнд")
        end
        pnsor11.Paint = function()
        end

        local pnsor12 = vgui.Create( "DButton", changepers2 )
        pnsor12:SetText( "" )
        pnsor12:SetSize( scrw * .13, scrh * .18 )
        pnsor12:SetPos( scrw * .8, scrh * .43 )
        pnsor12.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Тэрутэру Ханамура")
        end
        pnsor12.Paint = function()
        end

        local pnsor14 = vgui.Create( "DButton", changepers2 )
        pnsor14:SetText( "" )
        pnsor14:SetSize( scrw * .12, scrh * .44 )
        pnsor14:SetPos( scrw * .47, scrh * .57 )
        pnsor14.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
             SetCHR("Хаджимэ Хината")
        end
        pnsor14.Paint = function()
        end

        local pnsor15 = vgui.Create( "DButton", changepers2 )
        pnsor15:SetText( "" )
        pnsor15:SetSize( scrw * .16, scrh * .2 )
        pnsor15:SetPos( scrw * .67, scrh * .42 )
        pnsor15.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Хиёко Сайонджи")
        end
        pnsor15.Paint = function()
        end

        local pnsor16 = vgui.Create( "DButton", changepers2 )
        pnsor16:SetText( "" )
        pnsor16:SetSize( scrw * .16, scrh * .2 )
        pnsor16:SetPos( scrw * .32, scrh * .4 )
        pnsor16.DoClick = function(ply)
            changepers2:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Чиаки Нанами" )
        end
        pnsor16.Paint = function()
        end

    changepers2.Paint = function(self, w, h)

        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        local alphas = Lerp(fraction, 0, 255)

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( tpfon1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tlogo )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tall )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( right )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( left )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( up )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if pnsor1:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor2:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs2 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor3:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs3 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor4:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs4 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor5:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs5 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor6:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs6 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor7:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs7 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor8:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs8 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor9:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs9 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor10:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs10 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor11:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs11 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor12:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs12 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor13:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs13 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor14:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs14 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor15:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs15 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor16:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( tprs16 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

    end
end

function pers3(ply)

    local fraction = 0
    local lerptime = 0.3
    if IsValid(changepers3) then
        changepers3:Close()
    end

    local frameW, frameH, animTime, animDelay, animEase = scrw * .2, scrh * .2, 1.8, 0, .1
    local changepers3 = vgui.Create("DFrame")
    changepers3:SetSize(ScrW(), ScrH())
    changepers3:SetTitle("")
    changepers3:SetDraggable(false)
    changepers3:ShowCloseButton( false )
    changepers3:MakePopup()

    local pnsor1 = vgui.Create( "DButton", changepers3 )
        pnsor1:SetText( "" )
        pnsor1:SetSize( scrw * .09, scrh * .5 )
        pnsor1:SetPos( scrw * .24, scrh * .54 )
        pnsor1.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Анджи Ёнага")
        end
        pnsor1.Paint = function()
        end

    local pnsor2 = vgui.Create( "DButton", changepers3 )
        pnsor2:SetText( "" )
        pnsor2:SetSize( scrw * .12, scrh * .26 )
        pnsor2:SetPos( scrw * .46, scrh * .27 )
        pnsor2.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Гонта Гокухара")
        end
        pnsor2.Paint = function()
        end


    local pnsor3 = vgui.Create( "DButton", changepers3 )
        pnsor3:SetText( "" )
        pnsor3:SetSize( scrw * .14, scrh * .3 )
        pnsor3:SetPos( scrw * .1, scrh * .3 )
        pnsor3.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Кайто Момота" )
        end
        pnsor3.Paint = function()
        end

    local pnsor4 = vgui.Create( "DButton", changepers3 )
        pnsor4:SetText( "" )
        pnsor4:SetSize( scrw * .09, scrh * .6 )
        pnsor4:SetPos( scrw * .4, scrh * .54 )
        pnsor4.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Каэде Акамацу" )
        end
        pnsor4.Paint = function()
        end

    local pnsor5 = vgui.Create( "DButton", changepers3 )
        pnsor5:SetText( "" )
        pnsor5:SetSize( scrw * .12, scrh * .4 )
        pnsor5:SetPos( scrw * .8, scrh * .36 )
        pnsor5.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "K1-B0" )
        end
        pnsor5.Paint = function()
        end

    local pnsor6 = vgui.Create( "DButton", changepers3 )
        pnsor6:SetText( "" )
        pnsor6:SetSize( scrw * .09, scrh * .5 )
        pnsor6:SetPos( scrw * .76, scrh * .52 )
        pnsor6.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Кируми Тоджо" )
        end
        pnsor6.Paint = function()
        end

    local pnsor7 = vgui.Create( "DButton", changepers3 )
        pnsor7:SetText( "" )
        pnsor7:SetSize( scrw * .12, scrh * .2 )
        pnsor7:SetPos( scrw * .68, scrh * .34 )
        pnsor7.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Кокичи Ома" )
        end
        pnsor7.Paint = function()
        end

    local pnsor8 = vgui.Create( "DButton", changepers3 )
        pnsor8:SetText( "" )
        pnsor8:SetSize( scrw * .12, scrh * .2 )
        pnsor8:SetPos( scrw * .58, scrh * .34 )
        pnsor8.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Корекиё Шингуджи" )
        end
        pnsor8.Paint = function()
        end

    local pnsor9 = vgui.Create( "DButton", changepers3 )
        pnsor9:SetText( "" )
        pnsor9:SetSize( scrw * .12, scrh * .5 )
        pnsor9:SetPos( scrw * .12, scrh * .57 )
        pnsor9.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Маки Харукава" )
        end
        pnsor9.Paint = function()
        end

    local pnsor10 = vgui.Create( "DButton", changepers3 )
        pnsor10:SetText( "" )
        pnsor10:SetSize( scrw * .09, scrh * .48 )
        pnsor10:SetPos( scrw * .59, scrh * .55 )
        pnsor10.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Миу Ирума" )
        end
        pnsor10.Paint = function()
        end

    local pnsor11 = vgui.Create( "DButton", changepers3 )
        pnsor11:SetText( "" )
        pnsor11:SetSize( scrw * .1, scrh * .48 )
        pnsor11:SetPos( scrw * .31, scrh * .55 )
        pnsor11.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Рантаро Амами" )
        end
        pnsor11.Paint = function()
        end

    local pnsor12 = vgui.Create( "DButton", changepers3 )
        pnsor12:SetText( "" )
        pnsor12:SetSize( scrw * .12, scrh * .4 )
        pnsor12:SetPos( scrw * .82, scrh * .73 )
        pnsor12.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Рёма Хоши" )
        end
        pnsor12.Paint = function()
        end

    local pnsor13 = vgui.Create( "DButton", changepers3 )
        pnsor13:SetText( "" )
        pnsor13:SetSize( scrw * .15, scrh * .51 )
        pnsor13:SetPos( scrw * .46, scrh * .52 )
        pnsor13.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR( "Шуичи Сайхара" )
        end
        pnsor13.Paint = function()
        end

    local pnsor14 = vgui.Create( "DButton", changepers3 )
        pnsor14:SetText( "" )
        pnsor14:SetSize( scrw * .11, scrh * .26 )
        pnsor14:SetPos( scrw * .24, scrh * .3 )
        pnsor14.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Тенко Чабашира")
        end
        pnsor14.Paint = function()
        end

    local pnsor15 = vgui.Create( "DButton", changepers3 )
        pnsor15:SetText( "" )
        pnsor15:SetSize( scrw * .14, scrh * .26 )
        pnsor15:SetPos( scrw * .34, scrh * .3 )
        pnsor15.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Химико Юмено")
        end
        pnsor15.Paint = function()
        end

    local pnsor16 = vgui.Create( "DButton", changepers3 )
        pnsor16:SetText( "" )
        pnsor16:SetSize( scrw * .13, scrh * .5 )
        pnsor16:SetPos( scrw * .66, scrh * .52 )
        pnsor16.DoClick = function(ply)
            changepers3:Close() surface.PlaySound("ui/voting_click.mp3")
            SetCHR("Цумуги Широганэ")
        end
        pnsor16.Paint = function()
        end

    local texit = vgui.Create( "DButton", changepers3 )
        texit:SetText( "" )
        texit:SetSize( scrw * .09, scrh * .07 )
        texit:SetPos( scrw * .01, scrh * .01 )
        texit.DoClick = function()
            changepers3:Close()
            dbt.F4menu()
            surface.PlaySound("ui/button_back.mp3")
        end
        texit.Paint = function()
        end

    local leftbut = vgui.Create( "DButton", changepers3 )
        leftbut:SetText( "" )
        leftbut:SetSize( scrw * .036, scrh * .17 )
        leftbut:SetPos( scrw * .94, scrh * .47 )
        leftbut.DoClick = function()
            surface.PlaySound( "lobby/item_active.mp3" )
        end
        leftbut.Paint = function()
            
        end

    local rightbut = vgui.Create( "DButton", changepers3 )
        rightbut:SetText( "" )
        rightbut:SetSize( scrw * .036, scrh * .17 )
        rightbut:SetPos( scrw * .02 , scrh * .47 )
        rightbut.DoClick = function()
            changepers3:Close()
            pers2()
            surface.PlaySound( "lobby/item_active.mp3" )
        end
        rightbut.Paint = function()
        end

    changepers3.Paint = function(self, w, h)

        fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
        if fraction == 0 then return end
        local alphas = Lerp(fraction, 0, 255)

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( rpfon1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rlogo )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rall )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( right )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( left )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( up )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if pnsor1:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor2:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs2 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor3:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs3 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor4:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs4 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor5:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs5 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor6:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs6 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor7:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs7 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor8:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs8 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor9:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs9 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor10:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs10 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor11:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs11 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor12:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs12 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor13:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs13 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor14:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs14 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor15:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs15 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor16:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, alphas )
        surface.SetMaterial( rprs16 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end
    end
end

function pers4(ply)
    if IsValid(changepers4) then
        changepers4:Close()
    end

    local frameW, frameH, animTime, animDelay, animEase = scrw * .2, scrh * .2, 1.8, 0, .1
    local changepers4 = vgui.Create("DFrame")
    changepers4:SetSize(ScrW(), ScrH())
    changepers4:SetTitle("")
    changepers4:SetDraggable(false)
    changepers4:ShowCloseButton( false )
    changepers4:MakePopup()


    local pnsor2 = vgui.Create( "DButton", changepers4 )
        pnsor2:SetText( "" )
        pnsor2:SetSize( scrw * .19, scrh * .7 )
        pnsor2:SetPos( scrw * .155, scrh * .4 )
        pnsor2.DoClick = function(ply)
            changepers4:Close()
            SetCHR("Монака Това")
        end
        pnsor2.Paint = function()
        end

    local pnsor1 = vgui.Create( "DButton", changepers4 )
        pnsor1:SetText( "" )
        pnsor1:SetSize( scrw * .22, scrh * .8 )
        pnsor1:SetPos( scrw * .03, scrh * .2 )
        pnsor1.DoClick = function(ply)
            changepers4:Close()
            SetCHR("Комару Наэги") -- Комару Наэги
        end
        pnsor1.Paint = function()
        end

    local pnsor3 = vgui.Create( "DButton", changepers4 )
        pnsor3:SetText( "" )
        pnsor3:SetSize( scrw * .324, scrh * 1 )
        pnsor3:SetPos( scrw * .344, scrh * .08 )
        pnsor3.DoClick = function(ply)
            changepers4:Close()
            SetCHR("Рёко Отонаши") -- Комару Наэги
        end
        pnsor3.Paint = function()
        end

    local pnsor4 = vgui.Create( "DButton", changepers4 )
        pnsor4:SetText( "" )
        pnsor4:SetSize( scrw * .13, scrh * .8 )
        pnsor4:SetPos( scrw * .665, scrh * .25 )
        pnsor4.DoClick = function(ply)
            changepers4:Close()
            RunConsoleCommand("say", "/nev53") -- аой
        end
        pnsor4.Paint = function()
        end

    local pnsor5 = vgui.Create( "DButton", changepers4 )
        pnsor5:SetText( "" )
        pnsor5:SetSize( scrw * .13, scrh * .8 )
        pnsor5:SetPos( scrw * .73, scrh * .33 )
        pnsor5.DoClick = function(ply)
            changepers4:Close()
            RunConsoleCommand("say", "/nev55") -- аой
        end
        pnsor5.Paint = function()
        end

    local pnsor6 = vgui.Create( "DButton", changepers4 )
        pnsor6:SetText( "" )
        pnsor6:SetSize( scrw * .13, scrh * .8 )
        pnsor6:SetPos( scrw * .83, scrh * .43 )
        pnsor6.DoClick = function(ply)
            changepers4:Close()
            RunConsoleCommand("say", "/nev56") -- аой
        end
        pnsor6.Paint = function()
        end


    local texit = vgui.Create( "DButton", changepers4 )
        texit:SetText( "" )
        texit:SetSize( scrw * .09, scrh * .07 )
        texit:SetPos( scrw * .01, scrh * .01 )
        texit.DoClick = function()
            changepers4:Close()
            dbt.F4menu()
            surface.PlaySound("ui/button_back.mp3")
        end
        texit.Paint = function()
        end

    local leftbut = vgui.Create( "DButton", changepers4 )
        leftbut:SetText( "" )
        leftbut:SetSize( scrw * .036, scrh * .17 )
        leftbut:SetPos( scrw * .94, scrh * .47 )
        leftbut.DoClick = function()

        end
        leftbut.Paint = function()
        end

    local rightbut = vgui.Create( "DButton", changepers4 )
        rightbut:SetText( "" )
        rightbut:SetSize( scrw * .036, scrh * .17 )
        rightbut:SetPos( scrw * .02 , scrh * .47 )
        rightbut.DoClick = function()
            changepers4:Close()
            pers3()
            surface.PlaySound( "lobby/item_active.mp3" )
        end
        rightbut.Paint = function()
        end

    changepers4.Paint = function(self, w, h)

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dpfon1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dlogo )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dall )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( right )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( left )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( up )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if pnsor1:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dprs2 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor2:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dprs4 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor3:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dprs5 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor4:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dprs6 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor5:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dprs1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end

        if pnsor6:IsHovered() then

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( dprs3 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        end
    end
end
showcroshair = 0
function settingsmenu()

    local back = Material("settings/back.png")
    local fon = Material("settings/fon.png")
    local trmplogo = Material("settings/trmplogo.png")
    local pipe = Material("settings/pipe.png")
    local pipe1 = Material("settings/pipe1.png")

    local body = Material("settings/body.png")
    local bodyoff = Material("settings/bodyoff.png")
    local bodyon = Material("settings/bodyon.png")

    local multi = Material("settings/multi.png")
    local multioff = Material("settings/multioff.png")
    local multion = Material("settings/multion.png")


    local hair = Material("settings/hair.png")
    local hairoff = Material("settings/hairoff.png")
    local hairon = Material("settings/hairon.png")

    local asitbody = Material("settings/sitbody.png")
    local sitbodyoff = Material("settings/sitbodyoff.png")
    local sitbodyon = Material("settings/sitbodyon.png")

    local shadow = Material("settings/shadow.png")
    local shadowoff = Material("settings/shadowoff.png")
    local shadowon = Material("settings/shadowon.png")

    local valumem = Material("settings/valumem.png")

    local priceloff = Material("settings/priceloff.png")
    local pricelon = Material("settings/pricelon.png")

        local sllal = Material("settings/all_f4_parameters.png")
        local back22 = Material("settings/backbtn.png")

    if IsValid(settopen) then
        settopen:Remove()
    end


    local frameW, frameH, animTime, animDelay, animEase = scrw * .2, scrh * .2, 1.8, 0, .1
    local settopen = vgui.Create("DFrame")
    settopen:SetSize(ScrW(), ScrH())
    settopen:SetTitle("")
    settopen:SetDraggable(false)
    settopen:ShowCloseButton( false )
    settopen:MakePopup()


local sdexit = vgui.Create( "DButton", settopen )
        sdexit:SetText( "" )
        sdexit:SetSize( scrw * .12, scrh * .05 )
        sdexit:SetPos( scrw * .002, scrh * .93 )
        sdexit.DoClick = function()
            settopen:Close()
            dbt.F4menu()
            surface.PlaySound("ui/button_back.mp3")
        end
        sdexit.Paint = function()
        end
local bodyonoff = vgui.Create( "DButton", settopen )
        bodyonoff:SetText( "" )
        bodyonoff:SetSize( scrw * .09, scrh * .06 )
        bodyonoff:SetPos( scrw * .82, scrh * .33 )
        bodyonoff.DoClick = function()
            offbodycl = 0
            RunConsoleCommand("cl_ec_enabled", "0")
        end
        bodyonoff.Paint = function()
        end

local bodyonon = vgui.Create( "DButton", settopen )
        bodyonon:SetText( "" )
        bodyonon:SetSize( scrw * .06, scrh * .06 )
        bodyonon:SetPos( scrw * .74, scrh * .33 )
        bodyonon.DoClick = function()
            offbodycl = 1
            RunConsoleCommand("cl_ec_enabled", "1")
        end
        bodyonon.Paint = function()
        end

local multionoff = vgui.Create( "DButton", settopen )
        multionoff:SetText( "" )
        multionoff:SetSize( scrw * .09, scrh * .06 )
        multionoff:SetPos( scrw * .82, scrh * .25 )
        multionoff.DoClick = function()
        multienb = 0
        LocalPlayer():ConCommand("gmod_mcore_test 0")
        LocalPlayer():ConCommand("mat_queue_mode 0")
        LocalPlayer():ConCommand("cl_threaded_bone_setup 0")
        LocalPlayer():ConCommand("cl_threaded_client_leaf_system 0")
        LocalPlayer():ConCommand("r_threaded_particles 0")
        LocalPlayer():ConCommand("r_threaded_renderables 0")
        LocalPlayer():ConCommand("r_queued_ropes 0")
        LocalPlayer():ConCommand("studio_queue_mode 0")
        end
        multionoff.Paint = function()
        end

local multionon = vgui.Create( "DButton", settopen )
        multionon:SetText( "" )
        multionon:SetSize( scrw * .06, scrh * .06 )
        multionon:SetPos( scrw * .74, scrh * .25 )
        multionon.DoClick = function()
        multienb = 1
        LocalPlayer():ConCommand("gmod_mcore_test 1")
        LocalPlayer():ConCommand("mat_queue_mode -1")
        LocalPlayer():ConCommand("cl_threaded_bone_setup 1")
        LocalPlayer():ConCommand("cl_threaded_client_leaf_system 1")
        LocalPlayer():ConCommand("r_threaded_particles 1")
        LocalPlayer():ConCommand("r_threaded_renderables 1")
        LocalPlayer():ConCommand("r_queued_ropes 1")
        LocalPlayer():ConCommand("studio_queue_mode 1")
        end
        multionon.Paint = function()
        end

local haironoff = vgui.Create( "DButton", settopen )
        haironoff:SetText( "" )
        haironoff:SetSize( scrw * .09, scrh * .06 )
        haironoff:SetPos( scrw * .82, scrh * .49 )
        haironoff.DoClick = function()
            hairve = 0
            RunConsoleCommand("cl_ec_showhair", "0")
        end
        haironoff.Paint = function()
        end

local haironon = vgui.Create( "DButton", settopen )
        haironon:SetText( "" )
        haironon:SetSize( scrw * .06, scrh * .06 )
        haironon:SetPos( scrw * .74, scrh * .49 )
        haironon.DoClick = function()
            hairve = 1
            RunConsoleCommand("cl_ec_showhair", "1")
        end
        haironon.Paint = function()
        end

local sitbodyonoff = vgui.Create( "DButton", settopen )
        sitbodyonoff:SetText( "" )
        sitbodyonoff:SetSize( scrw * .09, scrh * .06 )
        sitbodyonoff:SetPos( scrw * .82, scrh * .41 )
        sitbodyonoff.DoClick = function()
            sitbody = 0
            RunConsoleCommand("cl_ec_vehicle", "0")
        end
        sitbodyonoff.Paint = function()
        end

local sitbodyonon = vgui.Create( "DButton", settopen )
        sitbodyonon:SetText( "" )
        sitbodyonon:SetSize( scrw * .06, scrh * .06 )
        sitbodyonon:SetPos( scrw * .74, scrh * .41 )
        sitbodyonon.DoClick = function()
            sitbody = 1
            RunConsoleCommand("cl_ec_vehicle", "1")
        end
        sitbodyonon.Paint = function()
        end

local shadowonoff = vgui.Create( "DButton", settopen )
        shadowonoff:SetText( "" )
        shadowonoff:SetSize( scrw * .09, scrh * .06 )
        shadowonoff:SetPos( scrw * .82, scrh * .73 )
        shadowonoff.DoClick = function()
            ashadow = 0
            RunConsoleCommand("r_shadowmaxrendered", "0")
        end
        shadowonoff.Paint = function()
        end

local shadowbodyonon = vgui.Create( "DButton", settopen )
        shadowbodyonon:SetText( "" )
        shadowbodyonon:SetSize( scrw * .06, scrh * .06 )
        shadowbodyonon:SetPos( scrw * .74, scrh * .73 )
        shadowbodyonon.DoClick = function()
            ashadow = 1
            RunConsoleCommand("r_shadowmaxrendered", "1")
        end
        shadowbodyonon.Paint = function()
        end



local haironoff = vgui.Create( "DButton", settopen )
        haironoff:SetText( "" )
        haironoff:SetSize( scrw * .09, scrh * .06 )
        haironoff:SetPos( scrw * .8, scrh * .57 )
        haironoff.DoClick = function()
            showcroshair = 0
            RunConsoleCommand("showcroshair", "0")
        end
        haironoff.Paint = function()
        end

local haironon = vgui.Create( "DButton", settopen )
        haironon:SetText( "" )
        haironon:SetSize( scrw * .06, scrh * .06 )
        haironon:SetPos( scrw * .74, scrh * .57 )
        haironon.DoClick = function()
            showcroshair = 1
            RunConsoleCommand("showcroshair", "1")
        end
        haironon.Paint = function()
        end

        showcroshair = GetConVar("showcroshair"):GetInt()
local DermaNumSlider = vgui.Create( "DNumSlider", settopen )
    DermaNumSlider:SetPos( scrw * .41, scrh * .63 )
    DermaNumSlider:SetSize( scrw * .6, scrh * .1 )          -- Set the size
    DermaNumSlider:SetText( "" )   -- Set the text above the slider
    DermaNumSlider:SetMin( 1 )                  -- Set the minimum number you can slide to
    DermaNumSlider:SetMax( 100 )                -- Set the maximum number you can slide to
    DermaNumSlider:SetDecimals( 0 )             -- Decimal places - zero for whole number
    DermaNumSlider:SetConVar( "music_valume" ) -- Changes the ConVar when you slide


    settopen.Paint = function(self, w, h)


        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( back )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( fon )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )


        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( pipe )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( pipe1 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        -- Тело

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( back22 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( sllal )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( bodyoff )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( bodyon )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if offbodycl == 0 then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( bodyoff )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( bodyon )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        -- Мульти кор



        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( multioff )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( multion )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if multienb == 0 then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( multioff )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( multion )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        -- Отображение волос



        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( hairoff )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( hairon )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if hairve == 0 then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( hairoff )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( hairon )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        -- Сидеть



        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( sitbodyoff )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( sitbodyon )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if sitbody == 0 then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( sitbodyoff )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( sitbodyon )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

        -- Теи




        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( shadowoff )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( shadowon )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if ashadow == 0 then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( shadowoff )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( shadowon )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end



        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( priceloff )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        surface.SetDrawColor( 255, 255, 255, 100 )
        surface.SetMaterial( pricelon )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

        if showcroshair == 0 then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( priceloff )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        else
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( pricelon )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end

    end
end