dbt.AdminFunc = {}
local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

local AvatarsApi = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/"

local function ParseJson(json, ...)
    local tbl = util.JSONToTable(json)
    if tbl == nil then return end

    local args = {...}

    for _, key in pairs(args) do
        if tbl[key] then
            tbl = tbl[key]
        end
    end

    return tbl
end


function GetName(sid, callback)
    HTTP({
        method = "get",
        url = AvatarsApi,
        parameters = {
            key = "801E41C35ACBB8ED18FECA7A1E338080",
            steamids = sid
        },
        failed = function(error)
            MsgC(Red, "Steam Avatar API HTTP Error:", White, error, "\n")
        end,
        success = function(code, response)
           local name = ParseJson(response, "response", "players", 1, "personaname")
           callback(name)
        end
    })
end


local col0 = Color(143, 37, 156, 255)
local col1 = Color(143,37,156, (255 / 100) * 60)
local col2 = Color(126, 78, 148)
local col3 = Color(32, 32, 32, 200)
local col4 = Color(126, 78, 148)
monobuttons_1 = Color(148, 21, 150, (255 / 100) * 14)
monobuttons_2 = Color(148, 21, 150, (255 / 100) * 30)
surface.CreateFont( "text1", {
    font = "Roboto",
    size = 24,
    weight = 100,
})

-- Helper function for creating UI elements with standard positioning and sizing
local function createUIElement(elementType, parent, x, y, w, h, options)
    parent = parent or PANEL_ADMIN_FUNC
    local element = vgui.Create(elementType, parent)
    element:SetPos(x, y)
    element:SetSize(w, h)
    
    if options then
        for k, v in pairs(options) do
            if type(v) == "function" then
                element[k] = v
            else
                element:SetValue(k, v)
            end
        end
    end
    
    return element
end

-- Improved checkbox with better visuals
function build_checkbox(x, y, w, h, text, pr)
    local parent = pr or PANEL_ADMIN_FUNC
    local container = createUIElement("EditablePanel", parent, x, y, w, h)
    
    container.Paint = function(self, ww, h)
        draw.SimpleText(text, "RobotoLight_26", h + 15, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local check_b = createUIElement("DButton", container, 0, 0, h, h)
    check_b:SetText("")
    check_b.checked = false
    
    check_b.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
        
        if self.checked then
            -- Draw checkmark
            surface.SetDrawColor(255, 255, 255, 255)
            local checkSize = h * 0.6
            local margin = (h - checkSize) / 2
            
            draw.RoundedBox(2, margin, margin, checkSize, checkSize, Color(143, 37, 156, 180))
            
            -- Better checkmark
            surface.SetDrawColor(255, 255, 255, 255)
            local x1, y1 = margin + checkSize * 0.2, margin + checkSize * 0.5
            local x2, y2 = margin + checkSize * 0.4, margin + checkSize * 0.7
            local x3, y3 = margin + checkSize * 0.8, margin + checkSize * 0.3
            
            surface.DrawLine(x1, y1, x2, y2)
            surface.DrawLine(x2, y2, x3, y3)
        end
    end
    
    check_b.DoClick = function(self)
        self.checked = not self.checked
        if self.OnEdit then self.OnEdit(self.checked) end
    end
    
    container.check_b = check_b
    return container
end



function build_tet(x, y, w, h)
    local frame = PANEL_ADMIN_FUNC
    local container = createUIElement("DPanel", frame, x, y, w, h)
    
    container.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
    end
    
    local textEntry = createUIElement("DTextEntry", frame, x, y, w, h)
    textEntry:SetPaintBackground(false)
    textEntry:SetFont("RobotoLight_32")
    textEntry:SetPlaceholderColor(Color(200, 200, 200, 100))
    textEntry:SetTextColor(color_white)
    textEntry:SetUpdateOnType(true)
    

    textEntry.Paint = function(self, w, h)
        if self:HasFocus() then
            draw.RoundedBox(4, 0, 0, w, 2, col0)
        end
        self:DrawTextEntryText(color_white, Color(143, 37, 156), color_white)
    end
    
    container.textentry = textEntry
    return container
end

function build_button(x, y, w, h, text)
    local frame = PANEL_ADMIN_FUNC
    local button = createUIElement("DButton", frame, x, y, w, h)
    button:SetText("")
    button.ttt = text
    button.hoverAlpha = 0
    
    button.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, col1)
        
        if self:IsHovered() and not self.pressed then
            self.hoverAlpha = math.min(self.hoverAlpha + 10, 255)
        else
            self.hoverAlpha = math.max(self.hoverAlpha - 10, 0)
        end
        
        local borderColor = Color(
            col0.r, 
            col0.g, 
            col0.b, 
            55 + (200 * self.hoverAlpha / 255)
        )
        
        -- Sleeker border effect
        draw.RoundedBox(4, 0, 0, w, 2, borderColor)
        draw.RoundedBox(4, 0, h-2, w, 2, borderColor)
        draw.RoundedBox(4, 0, 0, 2, h, borderColor)
        draw.RoundedBox(4, w-2, 0, 2, h, borderColor)
        
        -- Centered text with shadow for better readability
        draw.SimpleText(self.ttt, "text1", w * 0.5 + 1, h * 0.5 + 1, Color(0, 0, 0, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.ttt, "text1", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    button.OnMousePressed = function(self)
        self.pressed = true
    end
    
    button.OnMouseReleased = function(self)
        self.pressed = false
    end
    
    return button
end

-- Improved confirmation button with smoother transitions
ASKING_BUTTON = nil
function CrateMonoButton(x, y, w, h, parent, name, func, nocheck)
    local button = createUIElement("DButton", parent, x, y, w, h)
    button:SetText("")
    button.ask = false
    button.hoverAlpha = 0
    button.confirmAlpha = 0
    
    button.Think = function(self)
        -- Smooth transitions
        if self.ask then
            self.confirmAlpha = math.min(self.confirmAlpha + 15, 255)
        else
            self.confirmAlpha = math.max(self.confirmAlpha - 15, 0)
        end
        
        if self:IsHovered() and not self.ask then
            self.hoverAlpha = math.min(self.hoverAlpha + 15, 255)
        else
            self.hoverAlpha = math.max(self.hoverAlpha - 15, 0)
        end
    end
    
    button.Paint = function(self, w, h)
        -- Base color
        local baseColor = monobuttons_1
        
        -- Hover effect
        if self.hoverAlpha > 0 then
            local hoverColor = Color(
                monobuttons_2.r,
                monobuttons_2.g,
                monobuttons_2.b,
                monobuttons_1.a + (monobuttons_2.a - monobuttons_1.a) * (self.hoverAlpha/255)
            )
            baseColor = hoverColor
        end
        
        -- Confirmation mode
        if self.confirmAlpha > 0 then
            local confirmColor = Color(255, 0, 0, 100 * (self.confirmAlpha/255))
            draw.RoundedBox(4, 0, 0, w, h, confirmColor)
        else
            draw.RoundedBox(4, 0, 0, w, h, baseColor)
        end
        
        -- Add subtle border when hovered
        if self.hoverAlpha > 0 and self.confirmAlpha == 0 then
            draw.RoundedBox(4, 0, 0, w, 2, Color(143, 37, 156, 150 * (self.hoverAlpha/255)))
            draw.RoundedBox(4, 0, h-2, w, 2, Color(143, 37, 156, 150 * (self.hoverAlpha/255)))
        end
        
        -- Text
        local text = self.confirmAlpha > 0 and "Подтвердить?" or name
        local textColor = self.confirmAlpha > 0 and Color(255, 255, 255) or color_white
        
        -- Text shadow for better readability
        draw.SimpleText(text, "RobotoLight_32", w/2 + 1, h * 0.5 + 1, Color(0, 0, 0, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, "RobotoLight_32", w/2, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    button.DoClick = function(self)
        if nocheck then
            func()
            
            -- Add click effect
            local flash = vgui.Create("DPanel", parent)
            flash:SetPos(x, y)
            flash:SetSize(w, h)
            flash:SetAlpha(50)
            flash.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, self:GetAlpha()))
            end
            flash:AlphaTo(0, 0.3, 0, function() flash:Remove() end)
        else
            if self.ask then
                func()
                self.ask = false
                
                -- Add success effect
                local flash = vgui.Create("DPanel", parent)
                flash:SetPos(x, y)
                flash:SetSize(w, h)
                flash:SetAlpha(50)
                flash.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 255, 0, self:GetAlpha()))
                end
                flash:AlphaTo(0, 0.3, 0, function() flash:Remove() end)
            else
                if IsValid(ASKING_BUTTON) then ASKING_BUTTON.ask = false end
                self.ask = true
                ASKING_BUTTON = self
            end
        end
    end
    
    return button
end

for i = 1, 128 do
    surface.CreateFont("RobotoLight_"..i, {
        font = "Roboto Light",
        size = weight_source(i),
        weight = 100,
        antialias = true,
        extended = true,
    })
    surface.CreateFont("RobotoMedium_"..i, {
        font = "Roboto Medium",
        size = weight_source(i),
        weight = 100,
        antialias = true,
        extended = true,
    })
end

charapter_img = {
    [0] = "Пролог",
    [1] = "Глава 1",
    [2] = "Глава 2",
    [3] = "Глава 3",
    [4] = "Глава 4",
    [5] = "Глава 5",
    [6] = "Глава 6",
    [7] = "Глава 7",
    [8] = "Эпилог",
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

netstream.Hook("dbt/getinfo/edicts", function(num)
    EidctsCount = num
end)

PANEL_ADMIN_FUNC = nil

function dbt.OpenAdminMenu()
    ReqList()
	local w,h = ScrW(),ScrH()
    CURRENT_TYPE = nil
 	RunConsoleCommand("RefreshMusicCustom")
    if not LocalPlayer():IsAdmin() then return end
    admin_frame = vgui.Create( "DFrame" )
    admin_frame:SetSize(weight_source(1535 , 1920), hight_source(805, 1080))
    admin_frame:Center()
    admin_frame:SetTitle( "" )
    admin_frame:MakePopup()
    admin_frame:ShowCloseButton(false)

    admin_frame.Paint = function( self, w, h )--https://media.discordapp.net/attachments/881430976926973952/1085999975000985621/adminmenu_frame.png?width=1246&height=701
        draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, (255 / 100) * 95))

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial( Material("materials/adminmenu_frame.png") )
        surface.DrawTexturedRect( 0, 0, w, h )
        if dbt.music.CurrentSong and IsValid(PlayingSong) then
            draw.DrawText( "Мономеню | Сейчас играет: "..dbt.music.CurrentSong.song.path, "DermaLarge", weight_source(55), hight_source(15), color_white, TEXT_ALIGN_LEFT )
        else
            draw.DrawText( "Мономеню", "DermaLarge", weight_source(55), hight_source(15), color_white, TEXT_ALIGN_LEFT )
        end
    end

    local w,h = w * 0.8,h * 0.7
    local exit = vgui.Create( "DButton", admin_frame )
    exit:SetText( "" )
    exit:SetPos( w * 0.87, hight_source(15) )
    exit:SetSize( w * .15 + 1, h * 0.05 - 5 )
    exit.Paint = function(self, w, h)

        draw.DrawText( "ЗАКРЫТЬ", "DermaLarge", w * 0.5, h * 0.05, color_white, TEXT_ALIGN_CENTER )

    end
    exit.DoClick = function(self)
        self:GetParent():Close()
    end

    monoScroll = vgui.Create( "DScrollPanel", admin_frame )
    monoScroll:SetPos(5, h * 0.05 + 20)
    monoScroll:SetSize( w * 0.3 - 5, h * 0.95 )
            local sbar = monoScroll:GetVBar()
        function sbar:Paint(w, h) end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)

        end
    y = hight_source(19, 1080)
    ButtonsListAdmin = {}
    for k, i in pairs(dbt.AdminFunc) do
        local bb = vgui.Create( "DButton", monoScroll )
        bb:SetText( "" )
        bb:SetPos( weight_source(10, 1920), y )
        bb.ind = k
        bb:SetSize( weight_source(355 , 1920), hight_source(48, 1080) )
        bb.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
            if self.ind == CURRENT_TYPE or self:IsHovered() then
                draw.RoundedBox(0, 0, 0, 10, h, col0)
            else
                draw.RoundedBox(0, 0, 0, 10, h, Color(255,255,255))
            end

            draw.DrawText( i.name, "RobotoMedium_31", w * 0.05, h * 0.15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

        end
        bb.DoClick = function(self)
            if IsValid(PANEL_ADMIN_FUNC) then PANEL_ADMIN_FUNC:Remove() end
            CURRENT_TYPE = self.ind
            PANEL_ADMIN_FUNC = vgui.Create( "DScrollPanel", admin_frame )
            PANEL_ADMIN_FUNC:SetPos( w * 0.25 + 5, h * 0.05 + 10 )
            PANEL_ADMIN_FUNC:SetSize( w * .75 - 10, h )
            local vbar = PANEL_ADMIN_FUNC:GetVBar()
            function vbar:Paint(w, h) end
            function vbar.btnUp:Paint(w, h) end
            function vbar.btnDown:Paint(w, h) end
            function vbar.btnGrip:Paint(w, h)   
            end

            PANEL_ADMIN_FUNC.Paint = function(self, w, h)
                if i.PaintAdv then
                    i.PaintAdv(self, w, h)
                end
            end
            i.build(PANEL_ADMIN_FUNC)
        end
        ButtonsListAdmin[k] = bb
        y = y + hight_source(63, 1080) 
    end
end

if IsValid(admin_frame) then admin_frame:Close() 
    timer.Simple(1, function()
        dbt.OpenAdminMenu() 
        local w,h = ScrW(),ScrH()
            local w,h = w * 0.8,h * 0.7
            if IsValid(PANEL_ADMIN_FUNC) then PANEL_ADMIN_FUNC:Remove() end
            local i = dbt.AdminFunc["edit_items"]
            CURRENT_TYPE = "edit_items"
            PANEL_ADMIN_FUNC = vgui.Create( "DScrollPanel", admin_frame )
            PANEL_ADMIN_FUNC:SetPos( w * 0.25 + 5, h * 0.05 + 10 )
            PANEL_ADMIN_FUNC:SetSize( w * .75 - 10, h )
            local vbar = PANEL_ADMIN_FUNC:GetVBar()
            function vbar:Paint(w, h) end
            function vbar.btnUp:Paint(w, h) end
            function vbar.btnDown:Paint(w, h) end
            function vbar.btnGrip:Paint(w, h)   
            end

            PANEL_ADMIN_FUNC.Paint = function(self, w, h)
                if i.PaintAdv then
                    i.PaintAdv(self, w, h)
                end
            end
            i.build(PANEL_ADMIN_FUNC)

    end)
    

end

concommand.Add("monomenu", function(ply)
    if ply:IsAdmin() then
       dbt.OpenAdminMenu()
    end
end)

function GetAllAc()

    local chace = {}


    for k, i in pairs(allowed) do
        chace[#chace + 1] = {
            type = "in-game",
            steamid = k,
        }
    end


    return chace
end
