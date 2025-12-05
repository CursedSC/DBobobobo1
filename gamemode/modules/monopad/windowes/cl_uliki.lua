local PANEL = {}
local minimumMessageY = dbtPaint.HightSource(50)
local extraColor = Color(127,42,153,255)
local bgColor = Color(29,29,29,255)
local bgColor2 = Color(48,48,48,255)
local borderColor = Color(73,73,73)
local textColor = Color(160,160,160)
local textColor2 = Color(160,160,160, 200)
local contactColor = Color(37,37,37)
local msgColor = Color(37,37,37, 200)
local msgColor2 = Color(47,47,47, 200)
local textEntryColor = Color(40,40,40)
local placeHolderColor = Color(160,160,160, 100)
local selectedColor = Color(145,0,190, 255)
local utfLenToSub = 11
local checkboxColor = Color(46, 46, 46, 255)

local xMat = Material("dbt/monopad/X.png")
local msgMat = Material("dbt/monopad/Evidence.png")
local paternMat = Material("dbt/monopad/ev_bg.png")

local sizeEvBox = 106
local getTimeFrom = function(int)
    local globaltime = int
    local    s = globaltime % 60
    local    tmp = math.floor( globaltime / 60 )
    local    m = tmp % 60
    local    tmp = math.floor( tmp / 60 )
    local    h = tmp % 24

    local    days = math.floor( tmp / 24 )

    return string.format( "%02i:%02i", h, m), h, math.floor(days)
end

local function send_msg(text, mymonopad, tomonopad, monoid)
    netstream.Start("dbt/monopad/send/dms", mymonopad, tomonopad, text, monoid)
end

local helpENUMS = {}
helpENUMS["prolog"] = 1

for i = 1,6 do
    helpENUMS["stage_"..i] = i + 1
end
helpENUMS["epilog"] = table.Count(helpENUMS)

local testEvidiceTable = {
    [1] = {
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd dasdas das das sfasd gfdsag asd fasd dasdas das das sfasd gfdsag asd fasd dasdas das das sfasd gfdsag asd fasd dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавле", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
    },
    [2] = {
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
         {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
    },
    [3] = {
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
                {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
        {name = "Окровавленный молот", desc = "dasdas das das sfasd gfdsag asd fasd"},
    },
}

local glav_type = {}
glav_type["prolog"] = "Пролог"
glav_type["epilog"] = "Епилог"

for i = 1,6 do
    glav_type["stage_"..i] = "Глава "..i
end

local function GetGlavFromInt(int)
    local a
    for k , i in pairs(helpENUMS) do
        if i == int then a = k end
    end
    return glav_type[a]
end




function PANEL:Init()
    self.TableOfOpennedEv = {}
    self.EvidenceTable = {}
    self.EvidenceOpenMulty = false
    self.ActiveChat = "chat"
    self.NameToID = {}
	self:SetFocusTopLevel( true )

	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetScreenLock( true )
	self:SetDeleteOnClose( true )

	self:SetMinWidth( 50 )
	self:SetMinHeight( 50 )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
    self:ShowCloseButton(false)
	self.m_fCreateTime = SysTime()

	self.CloseB = vgui.Create( "DButton", self )
	self.CloseB:SetText( "" )
    self.CloseB:SetSize(dbtPaint.WidthSource(41), dbtPaint.HightSource(21))
    self.CloseB:SetPos(dbtPaint.WidthSource(605 - 41), 0)
	self.CloseB.DoClick = function ( button ) self:Close() end
	self.CloseB.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,borderColor)
        draw.RoundedBox(0,1,1,w-2,h-2,bgColor2)
        dbtPaint.DrawRect(xMat, w / 2 - 5.5, h / 2 - 5.5, 11, 11, color_white)
    end

    self.OpenInWindow = vgui.Create( "DButton", self )
	self.OpenInWindow:SetText( "" )
    self.OpenInWindow:SetSize(dbtPaint.WidthSource(20), dbtPaint.HightSource(20))
    self.OpenInWindow:SetPos(dbtPaint.WidthSource(11), dbtPaint.HightSource(26))
	self.OpenInWindow.DoClick = function ( button ) surface.PlaySound('monopad_click.mp3') self.EvidenceOpenMulty = !self.EvidenceOpenMulty end
	self.OpenInWindow.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,checkboxColor)
        if self.EvidenceOpenMulty then
            draw.RoundedBox(0, 3, 3, w - 6, h - 6, borderColor)
        end
    end

    self.ListEv = vgui.Create( "DScrollPanel", self )
    self.ListEv:SetSize(dbtPaint.WidthSource(605 - 10), dbtPaint.HightSource(625 - 30))
    self.ListEv:SetPos(dbtPaint.WidthSource(11), dbtPaint.HightSource(55))
    local sbar = self.ListEv:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0,w / 2 - 2,0,2,h,borderColor)
    end

    dbt.inventory.info.monopad.meta.edv = dbt.inventory.info.monopad.meta.edv or {}
    self.ListGlav = {}
    self.ListGlavY = 0
    PrintTable(dbt.inventory.info.monopad)
    for k, i in pairs(dbt.inventory.info.monopad.meta.edv) do
        local glavButton= vgui.Create( "DButton", self.ListEv )
	    glavButton:SetText( "" )
        glavButton.id = k
        glavButton.Oppened = false
        glavButton.ListBoxes = {}
        glavButton:SetSize(dbtPaint.WidthSource(578), dbtPaint.HightSource(20))
        glavButton:SetPos(dbtPaint.WidthSource(0), self.ListGlavY)
	    glavButton.DoClick = function ( button )
			surface.PlaySound('monopad_click.mp3')
            self:OpenFullEvidice(button.id, button.Oppened)
            button.Oppened = !button.Oppened
        end
        glavButton.OnOppened = function(panel, cY)
            for k, i in pairs(panel.ListBoxes) do
                if !i.evidiceId then continue end
                local buttonX, buttonY = panel:GetPos()
                local buttonY = cY or buttonY
                local evidiceY = math.floor((i.evidiceId-1) / 5) * dbtPaint.HightSource(117) + dbtPaint.HightSource(30) + buttonY
                i:MoveTo( i.X, evidiceY, 0.1)
            end
        end
	    glavButton.Paint = function( panel, w, h )
            draw.RoundedBox(0,0,0,w,h,borderColor)
            draw.RoundedBox(0,1,1,w-2,h-2,bgColor2)
            local a = GetGlavFromInt(k)
            draw.SimpleText(a, "Comfortaa Light X23", dbtPaint.WidthSource(10), -dbtPaint.HightSource(2), textColor, TEXT_ALIGN_LEFT)
        end
        self.ListGlav[k] = glavButton
        self.ListGlavY = self.ListGlavY + dbtPaint.HightSource(25)
    end
end

function PANEL:OpenEvidice(evidiceMeta)
    if !self.EvidenceOpenMulty and IsValid(self.EvidenceTable[1]) then self.EvidenceTable[1]:Close() end
    if !self.EvidenceOpenMulty then table.remove(self.EvidenceTable, 1) end
    local countEv = #self.EvidenceTable
    local postionSpawn = false
    local buttonX2, buttonY2
    if self.EvidenceOpenMulty and IsValid(self.EvidenceTable[countEv]) and !self.EvidenceTable[countEv].IsDragged then
        postionSpawn = true
    end

    local evidicePanel = vgui.Create("EvidenceVFrame", workPlace)
    evidicePanel:SetTitle("")
    evidicePanel:SetSize(dbtPaint.WidthSource(279), dbtPaint.HightSource(322))

    local buttonX, buttonY = self:GetPos()
    if postionSpawn then buttonX2, buttonY2 = self.EvidenceTable[countEv]:GetPos() end
    local position = (buttonX >=550) and (buttonX - dbtPaint.WidthSource(280)) or (buttonX + dbtPaint.WidthSource(606))
    if postionSpawn then
        evidicePanel:SetPos(position, buttonY2 + dbtPaint.HightSource(21))
    else
        evidicePanel:SetPos(position, buttonY)
    end
    evidicePanel.glav = evidiceMeta.glav
    evidicePanel:SetInfo(evidiceMeta)
    evidicePanel.patentEx = self
    self.TableOfOpennedEv[evidiceMeta.id_ev] = evidicePanel
    table.insert(self.EvidenceTable, evidicePanel)
end

function PANEL:OnClose()
    for k, i in pairs(self.EvidenceTable) do if IsValid(i) then i:Remove() end end
end

function PANEL:OpenFullEvidice(panelId, isOpened)
    local button = self.ListGlav[panelId]
    button.ListBoxes = button.ListBoxes or {}
    local buttonX, buttonY = button:GetPos()
    local evidiceTable = dbt.inventory.info.monopad.meta.edv[panelId]
    --if !evidiceTable then return end
    local evidiceY = math.floor(#evidiceTable / 5) * dbtPaint.HightSource(117) + dbtPaint.HightSource(126)

    if isOpened then
        for id = button.id + 1, #dbt.inventory.info.monopad.meta.edv do
            local glavButton = self.ListGlav[id]
            local x_pos, y_pos = glavButton:GetPos()
            glavButton.OnOppened(glavButton, y_pos - evidiceY)
            glavButton:MoveTo( dbtPaint.WidthSource(0), y_pos - evidiceY, 0.1, 0, -1, function()

            end)
        end
        for k, i in pairs(button.ListBoxes) do
            if IsValid(i) then i:Remove() end
        end
    else
        for id = button.id + 1, #dbt.inventory.info.monopad.meta.edv do
            local glavButton = self.ListGlav[id]
            local x_pos, y_pos = glavButton:GetPos()
            glavButton.OnOppened(glavButton, y_pos + evidiceY)
            glavButton:MoveTo( dbtPaint.WidthSource(0), y_pos + evidiceY, 0.1, 0, -1, function()

            end)
        end

        for evidiceId = 1, #evidiceTable do
            local EvidenceMeta = evidiceTable[evidiceId]
            local evidiceCustom = (math.floor((evidiceId-1) / 5) * dbtPaint.WidthSource(590))
            local evidiceX = (evidiceId - 1) * dbtPaint.WidthSource(118) - evidiceCustom
            local evidiceY = math.floor((evidiceId-1) / 5) * dbtPaint.HightSource(117) + dbtPaint.HightSource(30) + buttonY
            local idEv = panelId.."_"..evidiceId
            local evidiceButton = vgui.Create( "DButton", self.ListEv )
            evidiceButton.ParentButton = button
	        evidiceButton:SetText( "" )
            evidiceButton.id = k
            evidiceButton:SetAlpha(0)
            evidiceButton.Oppened = false
            evidiceButton.X = evidiceX
            evidiceButton.evidiceId = evidiceId
            evidiceButton:SetSize(dbtPaint.WidthSource(106), dbtPaint.HightSource(106))
            evidiceButton:SetPos(evidiceX, evidiceY)
	        evidiceButton.DoClick = function ( button )
				surface.PlaySound('monopad_click.mp3')
                if (self.TableOfOpennedEv[idEv] and IsValid(self.TableOfOpennedEv[idEv])) then
                    table.RemoveByValue(self.EvidenceTable, self.TableOfOpennedEv[idEv])
                    self.TableOfOpennedEv[idEv]:Close()
                    self.TableOfOpennedEv[idEv] = nil
                    return
                end
                PrintTable(self.EvidenceTable)
                if (!self.EvidenceOpenMulty and self.EvidenceTable[1] and IsValid(self.EvidenceTable[1])) then
                    self.EvidenceTable[1]:Close()
                    table.remove(self.EvidenceTable, 1)
                end
                PrintTable(EvidenceMeta)
                self:OpenEvidice({
                    name = EvidenceMeta.name,
                    glav = panelId,
                    desc = EvidenceMeta.desc,
                    icon = EvidenceMeta.icon, --EvidenceMeta.icon
                    locate = EvidenceMeta.location,
                    img = EvidenceMeta.img,
                    evidiceId = evidiceId,
                    id_ev = idEv
                })
            end
            evidiceButton.mat = Material(EvidenceMeta.icon)
            local nameT = evidiceTable[evidiceId].name
            local nameLen = utf8.len(nameT)
            evidiceButton.name = nameT
            local doubleName = false
            if utfLenToSub < nameLen then
                doubleName = true
                name = utf8.sub(nameT, 0, utfLenToSub)
                name2 = utf8.sub(nameT, utfLenToSub + 1, nameLen)
                evidiceButton.name = name
                evidiceButton.name2 = name2
            else

            end
            evidiceButton.doubleName = doubleName


	        evidiceButton.Paint = function( panel, w, h )
                if self.TableOfOpennedEv[idEv] then
                    draw.RoundedBox(0,0,0,w,h,monopad.MainColorC)
                else
                    draw.RoundedBox(0,0,0,w,h,borderColor)
                end
                draw.RoundedBox(0, dbtPaint.WidthSource(1), dbtPaint.WidthSource(1), w-dbtPaint.WidthSource(2), h-dbtPaint.WidthSource(2),bgColor2)

                dbtPaint.DrawRect(panel.mat, dbtPaint.WidthSource(22), dbtPaint.HightSource(7), dbtPaint.WidthSource(62), dbtPaint.HightSource(62), color_white)
                if !panel.doubleName then draw.SimpleText(panel.name, "Comfortaa Light X21",  w / 2, h * 0.7, textColor, TEXT_ALIGN_CENTER) else
                    draw.SimpleText(panel.name, "Comfortaa Light X21", w / 2, h * 0.62, textColor, TEXT_ALIGN_CENTER)
                    draw.SimpleText(panel.name2, "Comfortaa Light X21", w / 2, h * 0.75, textColor, TEXT_ALIGN_CENTER)
                end
            end
            evidiceButton:AlphaTo(255, 0.2)
            button.ListBoxes[evidiceId] = evidiceButton
        end
    end
end

function PANEL:Paint(w,h)
    if self.Dragging then self:RequestFocus() self.IsDragged = true end
    draw.RoundedBox(0,0,0,w,h,borderColor)
    draw.RoundedBox(0,1,1,w-2,h-2,bgColor)
    dbtPaint.DrawRect(paternMat, dbtPaint.WidthSource(1), dbtPaint.HightSource(20), w - 1, dbtPaint.HightSource(630), color_white)
    draw.RoundedBox(0, 1, 1, w - 2, dbtPaint.HightSource(20) - 1, bgColor2)
    draw.RoundedBox(0,0,dbtPaint.HightSource(20), w, 1, borderColor)

    draw.SimpleText("Улики", "Comfortaa X20", dbtPaint.WidthSource(25), -1, textColor, TEXT_ALIGN_LEFT)
    dbtPaint.DrawRect(msgMat, dbtPaint.WidthSource(5), dbtPaint.HightSource(3), dbtPaint.WidthSource(14), dbtPaint.HightSource(13), color_white)

    draw.SimpleText("Открывать в новом окне", "Comfortaa X26", dbtPaint.WidthSource(38), dbtPaint.HightSource(21), textColor, TEXT_ALIGN_LEFT)
end



vgui.Register("EvidenceFrame", PANEL, "DFrame")
