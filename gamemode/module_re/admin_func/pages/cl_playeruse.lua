local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

local col0 = Color(143, 37, 156, 255)
local col1 = Color(143,37,156, (255 / 100) * 60)
local col2 = Color(126, 78, 148)
local col3 = Color(32, 32, 32, 200)
local col4 = Color(126, 78, 148)

local function BuildListPlayer(tbl)
    y = hight_source(9, 1080)
    for k, i in pairs(tbl) do

        local bb = vgui.Create( "DButton", PlayerListScroll )
        bb:SetText( "" )
        bb:SetPos( weight_source(10 , 1920), y )
        bb:SetSize( weight_source(462 , 1920), hight_source(45, 1080) )
        bb.Paint = function(self, w, h)
            if self:IsHovered() or CURENT_PLAYER == i then
                draw.RoundedBox(0, 0, 0, w, h, col0)
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, (255 / 100) * 70))
            end
            draw.DrawText( i:Name(), "DermaLarge", w * 0.02, h * 0.15, color_white, TEXT_ALIGN_LEFT )

        end
        bb.DoClick = function(self)
            CURENT_PLAYER = i
        end
        y = y + hight_source(8 + 45, 1080)
    end
end 

local function BuildListChar(tbl)
y = hight_source(9, 1080)
    for k, i in pairs(tbl) do

        local bb = vgui.Create( "DButton", CharListScroll )
        bb:SetText( "" )
        bb:SetPos( weight_source(10 , 1920), y )
        bb:SetSize( weight_source(462 , 1920), hight_source(45, 1080) )
        bb.Paint = function(self, w, h)

            if CURENT_CHARACTER == i then
                draw.RoundedBox(0, 0, 0, w, h, col0)
            elseif self:IsHovered() then
                local col0 = Color(col0.r, col0.g, col0.b, col0.a - 100)
                draw.RoundedBox(0, 0, 0, w, h, col0)
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, (255 / 100) * 70))
            end
            draw.DrawText( i, "DermaLarge", w * 0.02, h * 0.15, color_white, TEXT_ALIGN_LEFT )

        end
        bb.DoClick = function(self)
            CURENT_CHARACTER = i
        end
        y = y + hight_source(8 + 45, 1080)
    end
end

dbt.AdminFunc["players_use"] = {
name = "Взаим. c игроками",
build = function(frame)

    CURENT_PLAYER = nil
    CURENT_CHARACTER = nil
    local w,h = frame:GetWide(), frame:GetTall()
    --Игроки
    local player_list_base = vgui.Create( "DPanel", frame )
    player_list_base:SetPos(weight_source(45 , 1920), hight_source(128, 1080))
    player_list_base:SetSize( weight_source(480 , 1920), hight_source(387, 1080) )
    player_list_base.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
    end

    local player_list_search_base = vgui.Create( "DTextEntry", frame )
    player_list_search_base:SetPos(weight_source(45 , 1920), hight_source(77, 1080))
    player_list_search_base:SetSize( weight_source(480 , 1920), hight_source(41, 1080) )
    player_list_search_base.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
    end

    local player_list_search = vgui.Create( "DTextEntry", player_list_search_base )
    player_list_search:SetPos(0,0)
    player_list_search:SetSize( weight_source(480 , 1920), hight_source(41, 1080) )
    player_list_search:SetFont("RobotoLight_32")
    player_list_search:SetPlaceholderColor( Color(200,200,200, 100) )
    player_list_search:SetPaintBackground( false )
    player_list_search:SetTextColor( color_white )
    player_list_search:SetPlaceholderText( "Поиск..." )
    player_list_search.OnEnter = function( self )
        PlayerListScroll:GetCanvas():Clear()
        text_f = string.lower(self:GetValue())
        build_table = {}
        for id, pl in pairs(player.GetAll()) do
            local heckStart, heckEnd = string.find(string.lower(pl:Name()), string.lower(text_f))
            if heckStart then
                build_table[id] = pl
            end
        end
        BuildListPlayer(build_table)
    end

    local character_list_base = vgui.Create( "DPanel", frame )
    character_list_base:SetPos(weight_source(618 , 1920), hight_source(128, 1080))
    character_list_base:SetSize( weight_source(480 , 1920), hight_source(387, 1080) )
    character_list_base.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
    end


    local character_list_search_base = vgui.Create( "DTextEntry", frame )
    character_list_search_base:SetPos(weight_source(618 , 1920), hight_source(77, 1080))
    character_list_search_base:SetSize( weight_source(480 , 1920), hight_source(41, 1080) )
    character_list_search_base.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
    end

    local character_list_search = vgui.Create( "DTextEntry", character_list_search_base )
    character_list_search:SetPos(0,0)
    character_list_search:SetSize( weight_source(480 , 1920), hight_source(41, 1080) )
    character_list_search:SetFont("RobotoLight_32")
    character_list_search:SetPlaceholderColor( Color(200,200,200, 100) )
    character_list_search:SetPaintBackground( false )
    character_list_search:SetTextColor( color_white )
    character_list_search:SetPlaceholderText( "Поиск..." )
    character_list_search.OnEnter = function( self )
        CharListScroll:GetCanvas():Clear()
        text_f = string.lower(self:GetValue())
        build_table = {}
        for id, i in pairs(DBT_CHAR_SORTED) do
            local heckStart, heckEnd = string.find(string.lower(i), string.lower(text_f))
            if heckStart then
                build_table[#build_table+1] = i
            end
        end
        BuildListChar(build_table)
    end

    PlayerListScroll = vgui.Create( "DScrollPanel", player_list_base )
    PlayerListScroll:SetPos(0,0)
    PlayerListScroll:SetSize( weight_source(480 , 1920), hight_source(387, 1080) )
    PlayerListScroll.Paint = function(self, w, h)

    end

    local sbar = PlayerListScroll:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)

    end
    function sbar.btnDown:Paint(w, h)

    end
    function sbar.btnGrip:Paint(w, h)

    end

    BuildListPlayer(player.GetAll())


    CharListScroll = vgui.Create( "DScrollPanel", character_list_base )
    CharListScroll:SetPos(0,0)
    CharListScroll:SetSize( weight_source(485 , 1920), hight_source(387, 1080) )
    CharListScroll.Paint = function(self, w, h)

    end


    local sbar = CharListScroll:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)

    end
    function sbar.btnDown:Paint(w, h)

    end
    function sbar.btnGrip:Paint(w, h)

    end

    BuildListChar(DBT_CHAR_SORTED)

    CrateMonoButton( weight_source(258, 1920), hight_source(551, 1080), weight_source(294 , 1920), hight_source(45, 1080), frame, "Выдать персонажа" , function()
        net.Start("admin.SetChar")
        net.WriteEntity(CURENT_PLAYER)
        net.WriteString(CURENT_CHARACTER)
        net.SendToServer()

        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Персонаж ", dbt.chr[CURENT_CHARACTER].color, CURENT_CHARACTER, Color( 255, 255, 255 ), " выдан игроку ", Color( 116, 40, 151 ), CURENT_PLAYER:Name())
    end, true)

    CrateMonoButton( weight_source(258, 1920), hight_source(551 + 57, 1080), weight_source(294, 1920), hight_source(45, 1080), frame, "Вывести игрока" , function()
        net.Start("admin.SetAlive")
        net.WriteEntity(CURENT_PLAYER)
        net.WriteBool(false)
        net.SendToServer()
    end, true)

    CrateMonoButton( weight_source(258, 1920), hight_source(551 + 57 * 2, 1080), weight_source(294, 1920), hight_source(45, 1080), frame, "Ввести игрока" , function()
        net.Start("admin.SetAlive")
        net.WriteEntity(CURENT_PLAYER)
        net.WriteBool(true)
        net.SendToServer()
    end, true)

    CrateMonoButton( weight_source(258 + 334, 1920), hight_source(551, 1080), weight_source(294, 1920), hight_source(45, 1080), frame, "Ввести персонажа" , function()
        net.Start("admin.SetAliveChr")
        net.WriteString(CURENT_CHARACTER)
        net.WriteBool(true)
        net.SendToServer()
    end, true)

    CrateMonoButton( weight_source(258 + 334, 1920), hight_source(551 + 57, 1080), weight_source(294, 1920), hight_source(45, 1080), frame, "Вывести персонажа" , function()
        net.Start("admin.SetAliveChr")
        net.WriteString(CURENT_CHARACTER)
        net.WriteBool(false)
        net.SendToServer()
    end, true)

    CrateMonoButton( weight_source(258 + 334, 1920), hight_source(551 + 57 * 2, 1080), weight_source(294, 1920), hight_source(45, 1080), frame, "Выдать модель" , function()
        Derma_StringRequest(
            "Модель",
            "Путь до модели",
            "",
            function(text) net.Start("setModel") net.WriteEntity(CURENT_PLAYER) net.WriteString(text) net.SendToServer() end,
            function(text) end
        )
    end, true)
end,
PaintAdv = function(self, w, h)
    draw.DrawText( "Игроки", "RobotoLight_43", weight_source(280 , 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.DrawText( "Персонажи", "RobotoLight_43", weight_source(258 + 334 + 262, 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial( Material("materials/am_arrows.png") )
    surface.DrawTexturedRectRotated( w / 2, h * 0.45, weight_source(57 , 1920), hight_source(57, 1080), 0 )

end
}