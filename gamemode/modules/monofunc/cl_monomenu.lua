surface.CreateFont( "text1", {
    font = "Roboto",
    size = 24,
    weight = 1000,
})

local frameColor = Color(47, 54, 64)
local frameColorRed = Color(200, 0, 0)
local frameColorDarkRed = Color(200, 150, 150)
local buttonColor = Color(47, 54, 64)

local frameColor1 = Color(135, 35, 82)
local buttonColor1 = Color(47, 54, 64)

net.Receive("GetGameStatus", function()

    temp = net.ReadString()

    if temp == 1 then

        gamestaus = "Игра"

    else

        gamestaus = "Лобби"

    end

end)



local glav_type = {}
glav_type["Пролог"] = "prolog"
glav_type["Епилог"] = "epilog"

for i = 1,6 do
    glav_type["Глава "..i] = "stage_"..i
end

local time_type = {}
time_type["Свободное время"] = "freetime"
time_type["Классный суд"] = "classtrial"
time_type["Расследование"] = "find"

function dgdfgdf()


    players = {}

    local frame = vgui.Create( "DFrame" )
    frame:SetSize( 500, 140 )
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame.Paint = function(me, w, h)
        surface.SetDrawColor(frameColor)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(frameColor1)
        surface.DrawRect(0,0,w,h * 0.2)
    end

    local comboBox = vgui.Create("DComboBox", frame )
    comboBox:SetPos(5, 30)
    comboBox:SetSize(200, 20)
    comboBox:SetValue("All Players")

    comboBox.OnSelect = function( _, _, value)
        curplayer = players[value]
    end

    for k,v in pairs(player.GetAll()) do
        comboBox:AddChoice(v:Pers())
        players[v:Pers()] = v
    end

    local DermaButton = vgui.Create( "DButton", frame ) // Create the button and parent it to the frame
    DermaButton:SetText( "Выйти" )                 // Set the text on the button
    DermaButton:SetPos( 5, 60 )                    // Set the position on the frame
    DermaButton:SetSize( 100, 20 )                  // Set the size
    DermaButton.DoClick = function()                // A custom function run when clicked ( note the . instead of : )
        RunConsoleCommand("StopSpectator")            // Run the console command "say hi" when you click it ( command, args )
    end

    local DsermaButton = vgui.Create( "DButton", frame ) // Create the button and parent it to the frame
    DsermaButton:SetText( "Начать" )                 // Set the text on the button
    DsermaButton:SetPos( 110, 60 )                    // Set the position on the frame
    DsermaButton:SetSize( 100, 20 )                  // Set the size
    DsermaButton.DoClick = function()                // A custom function run when clicked ( note the . instead of : )
        net.Start("SpectatorNet")
            net.WriteEntity(curplayer)
        net.SendToServer()          // Run the console command "say hi" when you click it ( command, args )
    end

end
concommand.Add("SpecMenu", function( ply, cmd, args )
    dgdfgdf()
end)


function CreateInfoFrame(one, two, free, four, five)
  local sw, sh = ScrW(), ScrH()
  local frameW, frameH, animTime, animDelay, animEase = 300, 200, 1.8, 0, .1
  PlayerMenuBode = vgui.Create( "DFrame" )
  PlayerMenuBode:SetSize( 300, 0 )
  PlayerMenuBode:Center()
  PlayerMenuBode:SetTitle("Табличка")
  PlayerMenuBode:MakePopup()
  local isAnimating = true
PlayerMenuBode:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
    isAnimating = false
end)
    PlayerMenuBode.Think = function(me)
    if isAnimating then
        me:Center()
    end
end
  PlayerMenuBode.Paint = function(me, w, h)
      surface.SetDrawColor(Color(50, 50, 50, 255))
      surface.DrawRect(0,0,w,h)

      surface.SetDrawColor(Color(0, 0, 0, 255))
      surface.DrawRect(0,0,w,h * 0.2)
  end

end






function ShowPlayerList()
    local f = vgui.Create( "DFrame" )
    f:SetTitle("Таблица игроков")
    f:SetSize( 500, 500 )
    f:Center()
    f:MakePopup()

    local AppList = vgui.Create( "DListView", f )
    AppList:Dock( FILL )
    AppList:SetMultiSelect( false )
    AppList:AddColumn( "Песронаж" )
    AppList:AddColumn( "SteamID" )
    AppList:AddColumn( "Живой" )

    for k,v in pairs(charactersInGame) do
        AppList:AddLine( k, v.steamID, v.alive )
    end


    AppList.OnRowSelected = function( lst, index, pnl )

                local Menu = DermaMenu()

                local addgame = Menu:AddOption( "Ввести в игру", function()
                    charactersInGame[pnl:GetValue( 1 )].alive = true

                    player.GetBySteamID(pnl:GetValue(2)):SetNWBool("InGame", true)

                    net.Start("sv.Update.charactersInGame")
                        net.WriteTable(charactersInGame)
                    net.SendToServer()
                end )
                addgame:SetIcon( "icon16/briefcase.png" )

                local removegame = Menu:AddOption( "Вывести с игры", function()
                    charactersInGame[pnl:GetValue( 1 )].alive = false

                    player.GetBySteamID(pnl:GetValue(2)):SetNWBool("InGame", false)

                    net.Start("sv.Update.charactersInGame")
                        net.WriteTable(charactersInGame)
                    net.SendToServer()
                end )
                removegame:SetIcon( "icon16/briefcase.png" )
                Menu:Open()
    end
end




surface.CreateFont( "Button_Font", {
    font = "Century751 BT", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 15,
    weight = 500,
    blursize = 0,
    scanlines = 1,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )


local mono_bunttons = {}
mono_bunttons[#mono_bunttons + 1] = {
    name = "Начать игру",
    func = function()
        net.Start("dbt.StartGame")
        net.SendToServer()
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Игра начата." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Закончить игру",
    func = function()
            net.Start("dbt.EndGame")
            net.SendToServer()
            chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Игра закончена." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Начать суд",
    func = function()
        RunConsoleCommand("StartClassTrial")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Суд начат." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Закончить суд",
    func = function()
        RunConsoleCommand("EndClassTrial")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Суд закончен." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "ESP MODE",
    func = function()
        RunConsoleCommand("say", "/espmode")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " ESP мод включен." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Удал. Улик",
    func = function()
        RunConsoleCommand("ClearE")
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Ред. Правила",
    func = function()
        RunConsoleCommand("ShowAcad")
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Полная очистка",
    func = function()
        RunConsoleCommand("sd_text_s")

        net.Start("pp_info_send")
            net.WriteTable({CMD = "CLR_MAP"})
        net.SendToServer()
    end
}
