local PANEL = {}
local minimumMessageY = dbtPaint.HightSource(50)
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
local xMat = Material("dbt/monopad/X.png")
local msgMat = Material("dbt/monopad/Messages.png")
local paternMat = Material("dbt/monopad/paternm.png")
local systemMessageBg = Color(52,52,52, 240)
local systemMessageTextColor = Color(215,215,215)
local test = http.Material("https://imgur.com/kW1R5tk.png")

local function resolveCharacterName(identifier)
    if not identifier or identifier == "" then return "???" end
    if CharacterNameOnName then
        local display = CharacterNameOnName(identifier)
        if display and display ~= "" then
            return display
        end
    end

    local entry = dbt.chr and dbt.chr[identifier]
    if entry and entry.name and entry.name ~= "" then
        return entry.name
    end

    return identifier
end

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

function PANEL:Init()

    self.ActiveChatId = "chat"
    self.ChatLookup = {}
    self.ContactButtons = {}
    self.AllMonopads = {}
    self.Groups = {}
    self.SelfMonopadId = nil
    self.ActiveChatTitle = "Общий чат"
    self.ActiveChatSubtitle = "Глобальный канал"
    self.ChatHeaderHeight = dbtPaint.HightSource(38)
    self.CreateGroupWindow = nil
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
    self.CloseB:SetPos(dbtPaint.WidthSource(597 - 41), 0)
	self.CloseB.DoClick = function ( button ) self:Close() end
	self.CloseB.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,borderColor)
        draw.RoundedBox(0,1,1,w-2,h-2,bgColor2)
        dbtPaint.DrawRect(xMat, w / 2 - 5.5, h / 2 - 5.5, 11, 11, color_white)

    end

	self.ListContactsBg = vgui.Create( "EditablePanel", self )
    self.ListContactsBg:SetSize(dbtPaint.WidthSource(188), dbtPaint.HightSource(632))
    self.ListContactsBg:SetPos(0, dbtPaint.HightSource(20))
	self.ListContactsBg.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,borderColor)
        draw.RoundedBox(0,1,1,w-2,h-2,bgColor)
    end

    self.yMessage= 6

    self.CreateGroupButton = vgui.Create("DButton", self.ListContactsBg)
    self.CreateGroupButton:SetText("")
    self.CreateGroupButton:SetSize(dbtPaint.WidthSource(180), dbtPaint.HightSource(33))
    self.CreateGroupButton:SetPos(dbtPaint.WidthSource(4), self.yMessage)
    self.CreateGroupButton.Paint = function(panel, w, h)
        draw.RoundedBox(0, 0, 0, w, h, contactColor)
        draw.SimpleText("+ Создать группу", "Comfortaa X26", dbtPaint.WidthSource(5), -1, textColor, TEXT_ALIGN_LEFT)
    end
    self.CreateGroupButton.DoClick = function()
        surface.PlaySound('monopad_click.mp3')
        self:OpenCreateGroupDialog()
    end

    self.ListContacts = vgui.Create( "DScrollPanel", self.ListContactsBg )
    self.ListContacts:SetSize(dbtPaint.WidthSource(188), dbtPaint.HightSource(632) - dbtPaint.HightSource(43))
    self.ListContacts:SetPos(0, dbtPaint.HightSource(43))
    local sbar = self.ListContacts:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h) end

    --self:BuildContacts()


	self.ListMessageBg = vgui.Create( "EditablePanel", self )
    self.ListMessageBg:SetSize(dbtPaint.WidthSource(410), dbtPaint.HightSource(635))
    self.ListMessageBg:SetPos(dbtPaint.WidthSource(187), dbtPaint.HightSource(20))
	self.ListMessageBg.Paint = function( panel, w, h )
        draw.RoundedBox(0, 0, 0, w, h, borderColor)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, bgColor)
        draw.RoundedBox(0, 1, 1, w - 2, self.ChatHeaderHeight, bgColor2)
        local entryHeight = IsValid(self.TextEntryBg) and self.TextEntryBg:GetTall() or 0
        local patternHeight = h - self.ChatHeaderHeight - entryHeight - dbtPaint.HightSource(10)
        if patternHeight > 0 then
            dbtPaint.DrawRect(paternMat, dbtPaint.WidthSource(1), self.ChatHeaderHeight, w - dbtPaint.WidthSource(2), patternHeight, color_white)
        end
        draw.SimpleText(self.ActiveChatTitle or "Общий чат", "Comfortaa X28", dbtPaint.WidthSource(10), dbtPaint.HightSource(-3), textColor, TEXT_ALIGN_LEFT)
        if self.ActiveChatSubtitle and self.ActiveChatSubtitle ~= "" then
            draw.SimpleText(self.ActiveChatSubtitle, "Comfortaa X20", dbtPaint.WidthSource(10), dbtPaint.HightSource(17), textColor2, TEXT_ALIGN_LEFT)
        end
    end

    local entryHeight = dbtPaint.HightSource(32)

    self.TextEntryBg = vgui.Create( "EditablePanel", self.ListMessageBg )
    self.TextEntryBg:SetSize(dbtPaint.WidthSource(408), dbtPaint.HightSource(26))
    self.TextEntryBg:SetPos(dbtPaint.WidthSource(1), dbtPaint.HightSource(604))
	self.TextEntryBg.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,textEntryColor)
    end

    self.TextEntry = vgui.Create( "DTextEntry", self.TextEntryBg ) -- create the form as a child of frame
    self.TextEntry:SetSize(dbtPaint.WidthSource(408), dbtPaint.HightSource(22))
    self.TextEntry:SetPos(0, 0)
    self.TextEntry:SetFont("Comfortaa X25")
    self.TextEntry:SetPaintBackground(false)
    self.TextEntry:SetPlaceholderText( "Сообщение" )
    self.TextEntry:SetPlaceholderColor( placeHolderColor )
    self.TextEntry:SetTextColor(textColor)
    self.TextEntry:SetDrawLanguageID(false)
    self.TextEntry.OnEnter = function(panel)
        if self:SendActiveMessage(panel:GetValue()) then
            panel:SetText("")
        end
        panel:RequestFocus()
    end

    self.ListMessage = vgui.Create( "DScrollPanel", self.ListMessageBg )
    local messagesHeight = math.max(0, self.ListMessageBg:GetTall() - self.ChatHeaderHeight - entryHeight - dbtPaint.HightSource(18))
    self.ListMessage:SetSize(dbtPaint.WidthSource(398), messagesHeight)
    self.ListMessage:SetPos(dbtPaint.WidthSource(6), self.ChatHeaderHeight + dbtPaint.HightSource(6))
    local sbar = self.ListMessage:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h) end

    self.yMessage= 7
end

local mat_circile = CreateMaterial( "circle", "UnlitGeneric", {
    ["$basetexture"] = "dbt/dbt_circle.vtf",
    ["$alphatest"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$smooth"] = 1,
    ["$mips"] = 1,
    ["$allowalphatocoverage"] = 1,
    ["$alphatestreference "] = 0.8,
} )

local cases = {[0] = 3, [1] = 1, [2] = 2, [3] = 2, [4] = 2, [5] = 3}
function pluralize(n, titles)
	n = math.floor(math.abs(n))
	return titles[
		(n % 100 > 4 and n % 100 < 20) and 3 or
		cases[(n % 10 < 5) and n % 10 or 5]
	]
end

local function isURL(str)
    local pattern = "^(https?://)"
    return string.match(str, pattern) ~= nil
end

-- Функция для проверки, содержит ли URL домен imgur.com
local function isImgurLink(str)
    local imgurPattern = "^(https?://)(www%.|m%.|)(imgur%.com)"
    return string.match(str, imgurPattern) ~= nil
end

local function shortenName(str, limit)
    if not isstring(str) then return "" end
    limit = limit or 14
    if utf8.len(str) > limit then
        return utf8.sub(str, 1, limit) .. "..."
    end
    return str
end

local function getLocalMonopadId()
    if not dbt or not dbt.inventory or not dbt.inventory.info then return nil end
    local info = dbt.inventory.info.monopad
    if not info then return nil end
    if istable(info.meta) and info.meta.id then
        return info.meta.id
    end
    return info.id
end

MASAGECOUNT = 1

function PANEL:AddSystemMessage(text, time, meta)
    if not IsValid(self.ListMessage) then return end
    local parent = self.ListMessage
    local messageText = tostring(text or "")
    surface.SetFont("Comfortaa X20")
    local textWidth, textHeight = surface.GetTextSize(messageText)
    local paddingX = dbtPaint.WidthSource(12)
    local paddingY = dbtPaint.HightSource(6)
    local parentWidth = parent:GetWide()
    local canvas = parent.GetCanvas and parent:GetCanvas()
    if IsValid(canvas) and canvas:GetWide() > 0 then
        parentWidth = canvas:GetWide()
    end
    if parentWidth <= 0 then
        parentWidth = dbtPaint.WidthSource(398)
    end
    local panelWidth = math.min(parentWidth, math.max(dbtPaint.WidthSource(140), textWidth + paddingX * 2))
    local panelHeight = textHeight + paddingY * 2

    local panel = parent:Add("DPanel")
    panel:SetSize(panelWidth, panelHeight)
    panel:SetPos(math.max(0, (parentWidth - panelWidth) / 2), self.yMessage)
    panel.CanDelete = true
    panel.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, systemMessageBg)
        draw.SimpleText(messageText, "Comfortaa X20", w / 2, h / 2 - dbtPaint.HightSource(1), systemMessageTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.yMessage = self.yMessage + panelHeight + dbtPaint.HightSource(7)
    local vbar = parent:GetVBar()
    if IsValid(vbar) then
        vbar:AnimateTo(self.yMessage, 0.5, 0, 0.5)
    end
end

function PANEL:AddMessage(text, author, time, extra)
    extra = istable(extra) and extra or {}
    if extra.system then
        self:AddSystemMessage(text, time, extra)
        MASAGECOUNT = MASAGECOUNT + 1
        return
    end

    local msgTime = time or 0
    local formattedTime, _, sentDay = getTimeFrom(msgTime)
    local _, _, currentDay = getTimeFrom(GetGlobalInt("Time"))
    local dayDelta = currentDay - sentDay
    local timeSnap = ""
    if dayDelta >= 1 then
        timeSnap = dayDelta .. " " .. pluralize(dayDelta, {"день", "дня", "дня", "дня", "дней"}) .. " назад, "
    end

    local authorId = isstring(author) and author or "UNKNOWN"
    local char_tbl = (dbt and dbt.chr and dbt.chr[authorId]) or nil
    local color = (char_tbl and char_tbl.color) or textColor
    local pers = LocalPlayer():GetMonopadOwner()
    local isMy = (pers == authorId)

    local _, measuredHeight = surface.DrawMulticolorText(weight_source(0), hight_source(0), "Comfortaa X20", { textColor, text }, weight_source(270))
    local textY = measuredHeight + dbtPaint.HightSource(59)
    if textY < dbtPaint.HightSource(50) then
        textY = minimumMessageY
    end

    local messagePanel = self.ListMessage:Add("DButton")
    messagePanel.Color = textColor
    messagePanel:SetText("")
    messagePanel.text = text
    messagePanel.subColor = color
    messagePanel.id = MASAGECOUNT
    messagePanel.CanDelete = true
    messagePanel:SetSize(dbtPaint.WidthSource(350), dbtPaint.HightSource(textY))
    messagePanel:SetPos(isMy and dbtPaint.WidthSource(53) or dbtPaint.WidthSource(7), self.yMessage)

    messagePanel.DoRightClick = function(panel)
        surface.PlaySound('monopad_click.mp3')
        local menu = DermaMenu()
        menu:AddOption("Копировать", function()
            SetClipboardText(panel.text)
        end)
        menu:Open()
    end

    local mat
    local wimg, himg
    local isUrl = isURL(text)
    local isImgur = isImgurLink(text)
    if isUrl and isImgur then
        mat = HTTP_IMG(text)
        wimg, himg = mat:GetMaterial():Width(), mat:GetMaterial():Height()
    end

    local material2
    if char_tbl and char_tbl.season and char_tbl.char then
        material2 = Material("dbt/characters" .. char_tbl.season .. "/char" .. char_tbl.char .. "/char_ico_1.png", "smooth")
    end

    local nameCharacter = authorId
    if char_tbl then
        if CharacterNameOnName then
            nameCharacter = CharacterNameOnName(authorId) or nameCharacter
        elseif char_tbl.name then
            nameCharacter = char_tbl.name
        end
    end

    messagePanel.Paint = function(panel, w, h)
        draw.RoundedBox(6, 0, 0, w, h, isMy and msgColor2 or msgColor)
        draw.SimpleText(nameCharacter, "Comfortaa X24", dbtPaint.WidthSource(55), hight_source(2), panel.subColor, TEXT_ALIGN_LEFT)
        draw.SimpleText(timeSnap .. formattedTime, "Comfortaa X15", w - dbtPaint.WidthSource(10), h - hight_source(17), textColor2, TEXT_ALIGN_RIGHT)

        if isUrl and isImgur and mat and mat.material then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat.material)
            surface.DrawTexturedRect(55, 55, wimg - 55, himg - 55)
        else
            surface.DrawMulticolorText(weight_source(55), hight_source(25), "Comfortaa X20", { textColor, text }, weight_source(270))

            if material2 then
                dbtPaint.StartStencil()
                    surface.SetDrawColor(255, 255, 255, 255)
	                surface.SetMaterial(mat_circile)
	                surface.DrawTexturedRect(dbtPaint.WidthSource(5), dbtPaint.HightSource(5), dbtPaint.WidthSource(40), dbtPaint.HightSource(40))
                dbtPaint.ApllyStencil()
	                surface.SetDrawColor(255, 255, 255, 255)
	                surface.SetMaterial(material2)
	                surface.DrawTexturedRect(dbtPaint.WidthSource(3), dbtPaint.HightSource(3), dbtPaint.WidthSource(45), dbtPaint.HightSource(45))
                render.SetStencilEnable(false)
            end
        end
    end

    MASAGECOUNT = MASAGECOUNT + 1
    self.yMessage = self.yMessage + textY + dbtPaint.HightSource(7)
    local vbar = self.ListMessage:GetVBar()
    if IsValid(vbar) then
        vbar:AnimateTo(self.yMessage, 0.5, 0, 0.5)
    end
end

function PANEL:ClearMessageList()
    if not IsValid(self.ListMessage) then return end
    local canvas = self.ListMessage.GetCanvas and self.ListMessage:GetCanvas()
    if IsValid(canvas) then
        for _, child in pairs(canvas:GetChildren()) do
            if IsValid(child) then
                child:Remove()
            end
        end
    end
    self.yMessage = 7
    MASAGECOUNT = 1
    local vbar = self.ListMessage:GetVBar()
    if IsValid(vbar) then
        vbar:SetScroll(0)
    end
end

function PANEL:ResetChats()
    self:ClearMessageList()
    if IsValid(self.ListContacts) then
        if self.ListContacts.Clear then
            self.ListContacts:Clear()
        end
        local canvas = self.ListContacts.GetCanvas and self.ListContacts:GetCanvas()
        if IsValid(canvas) then
            for _, child in pairs(canvas:GetChildren()) do
                if IsValid(child) then child:Remove() end
            end
        end
    end
    if IsValid(self.CreateGroupWindow) then
        self.CreateGroupWindow:Close()
        self.CreateGroupWindow = nil
    end
    self.ActiveChatId = "chat"
    self.ActiveChatTitle = "Общий чат"
    self.ActiveChatSubtitle = "Глобальный канал"
    self.ChatLookup = {}
    self.ContactButtons = {}
    self.Groups = {}
    self.AllMonopads = {}
    self.SelfMonopadId = nil
    self.yContact = dbtPaint.HightSource(0)
    self:UpdateChatHeader("chat")
end

function PANEL:GetLocalMonopadId()
    return getLocalMonopadId()
end

function PANEL:AddContactButton(chatId, rawDisplayName, data)
    if not IsValid(self.ListContacts) then return nil end

    self.yContact = self.yContact or dbtPaint.HightSource(0)
    local originalName = rawDisplayName or data.name or chatId
    local displayName = shortenName(originalName)

    local button = self.ListContacts:Add("DButton")
    button:SetText("")
    button:SetSize(dbtPaint.WidthSource(180), dbtPaint.HightSource(33))
    button:SetPos(dbtPaint.WidthSource(4), self.yContact)
    button.Color = textColor
    button.ChatId = chatId
    button.DisplayName = displayName
    button.ChatData = data
    button.Paint = function(panel, w, h)
        draw.RoundedBox(0, 0, 0, w, h, contactColor)
        local textToDraw = panel.DisplayName or panel.ChatId
        local isSelected = (self.ActiveChatId == panel.ChatId)
        if isSelected then
            textToDraw = "> " .. textToDraw
        end
        draw.SimpleText(textToDraw, "Comfortaa X28", dbtPaint.WidthSource(5), -1, isSelected and monopad.MainColorC or panel.Color, TEXT_ALIGN_LEFT)
    end
    button.DoClick = function(panel)
        surface.PlaySound('monopad_click.mp3')
        self:SetActiveChat(panel.ChatId)
    end
    if data.kind == "group" then
        button.DoRightClick = function(panel)
            surface.PlaySound('monopad_click.mp3')
            self:OpenGroupContextMenu(panel.ChatId)
        end
    end

    self.ContactButtons = self.ContactButtons or {}
    self.ChatLookup = self.ChatLookup or {}
    data.displayName = originalName
    data.shortName = displayName
    self.ContactButtons[chatId] = button
    self.ChatLookup[chatId] = data

    self.yContact = self.yContact + dbtPaint.HightSource(37)
    return button
end

function PANEL:RequestMessagesFor(chatId)
    local localId = self:GetLocalMonopadId()
    if not localId then return end

    if chatId == "chat" then
        netstream.Start("dbt/monopad/request/dms", localId, { type = "global" })
        return
    end

    if isstring(chatId) and string.StartWith(chatId, "direct:") then
        local target = tonumber(string.sub(chatId, 8))
        if not target then return end
        netstream.Start("dbt/monopad/request/dms", localId, { type = "direct", id = target })
        return
    end

    if isstring(chatId) and string.StartWith(chatId, "group:") then
        local groupId = tonumber(string.sub(chatId, 7))
        if not groupId then return end
        netstream.Start("dbt/monopad/request/dms", localId, { type = "group", id = groupId })
    end
end

function PANEL:UpdateChatHeader(chatId)
    local title = "Общий чат"
    local subtitle = ""
    local data = self:GetChatData(chatId)

    if data then
        if data.kind == "global" then
            title = data.displayName or data.name or title
            subtitle = "Глобальный канал"
        elseif data.kind == "direct" then
            local prettyName = data.displayName
            if not prettyName and data.character then
                prettyName = CharacterNameOnName and CharacterNameOnName(data.character) or data.character
            end
            title = prettyName or title
            subtitle = "Личные сообщения"
        elseif data.kind == "group" then
            title = data.displayName or data.name or title
            local members = istable(data.members) and data.members or {}
            local count = #members
            if count > 0 then
                subtitle = string.format("%d %s", count, pluralize(count, {"участник", "участника", "участника", "участника", "участников"}))
            else
                subtitle = "Нет участников"
            end
            if data.isOwner then
                if subtitle ~= "" then
                    subtitle = subtitle .. " • вы создатель"
                else
                    subtitle = "Вы создатель"
                end
            end
        end
    else
        if chatId == "chat" then
            subtitle = "Глобальный канал"
        else
            subtitle = ""
        end
    end

    self.ActiveChatTitle = title
    self.ActiveChatSubtitle = subtitle
end

function PANEL:SetActiveChat(chatId, force)
    if not chatId then return end
    self:UpdateChatHeader(chatId)
    if (not force) and self.ActiveChatId == chatId then
        self:RequestMessagesFor(chatId)
        self:UpdateInputState()
        return
    end

    self.ActiveChatId = chatId
    self:UpdateInputState()
    if IsValid(self.TextEntry) and self.TextEntry:IsEnabled() then
        self.TextEntry:RequestFocus()
    end
    self:RequestMessagesFor(chatId)
end

function PANEL:GetChatData(chatId)
    if not self.ChatLookup then return nil end
    return self.ChatLookup[chatId]
end

function PANEL:UpdateInputState()
    if not IsValid(self.TextEntry) then return end
    local data = self:GetChatData(self.ActiveChatId)
    local readOnly = data and data.kind == "group" and data.isMember == false
    self.TextEntry:SetEnabled(not readOnly)
    self.TextEntry:SetEditable(not readOnly)
    if self.TextEntry.SetPlaceholderText then
        if readOnly then
            self.TextEntry:SetPlaceholderText("Только просмотр")
        else
            self.TextEntry:SetPlaceholderText("")
        end
    end
end

function PANEL:BuildContacts(payload)
    if not istable(payload) then return end

    if IsValid(self.ListContacts) then
        if self.ListContacts.Clear then
            self.ListContacts:Clear()
        end
        local canvas = self.ListContacts.GetCanvas and self.ListContacts:GetCanvas()
        if IsValid(canvas) then
            for _, child in ipairs(canvas:GetChildren()) do
                if IsValid(child) then child:Remove() end
            end
        end
    end

    self.yContact = dbtPaint.HightSource(0)
    self.ChatLookup = {}
    self.ContactButtons = {}
    self.AllMonopads = istable(payload.direct) and payload.direct or {}
    self.Groups = istable(payload.groups) and payload.groups or {}
    self.SelfMonopadId = payload.selfId

    local globalData = { kind = "global", id = "chat", name = "Общий чат", displayName = "Общий чат" }
    self:AddContactButton("chat", globalData.name, globalData)

    for _, entry in ipairs(self.AllMonopads) do
        if entry.id ~= self.SelfMonopadId then
            local rawName = entry.character
            if CharacterNameOnName then
                rawName = CharacterNameOnName(entry.character) or entry.character
            end
            local data = {
                kind = "direct",
                id = entry.id,
                character = entry.character,
                displayName = rawName
            }
            self:AddContactButton("direct:" .. tostring(entry.id), rawName, data)
        end
    end

    for _, entry in ipairs(self.Groups) do
        local memberMap = {}
        for _, member in ipairs(entry.members or {}) do
            memberMap[member.id] = true
        end
        local isMember = entry.isMember ~= false
        local data = {
            kind = "group",
            id = entry.id,
            name = entry.name or string.format("Группа #%s", tostring(entry.id)),
            owner = entry.owner,
            isOwner = entry.isOwner,
            members = entry.members or {},
            memberMap = memberMap,
            isMember = isMember
        }
        local displayName = data.name
        if not isMember then
            displayName = displayName .. " (набл.)"
        end
        self:AddContactButton("group:" .. tostring(entry.id), displayName, data)
    end

    local desired = self.ActiveChatId
    if not self.ChatLookup[desired] then
        desired = "chat"
        if not self.ChatLookup[desired] then
            for key in pairs(self.ChatLookup) do
                desired = key
                break
            end
        end
    end

    if desired then
        self:SetActiveChat(desired, true)
    end
end

function PANEL:SendActiveMessage(text)
    if not isstring(text) then return false end
    local trimmed = string.Trim(text)
    if trimmed == "" then return false end

    local chatId = self.ActiveChatId or "chat"
    local localId = self:GetLocalMonopadId()
    if not localId then return false end
    local chatData = self:GetChatData(chatId)

    if chatId == "chat" then
        netstream.Start("dbt/monopad/send/dms", localId, { type = "global" }, trimmed)
        return true
    end

    if string.StartWith(chatId, "direct:") then
        local target = tonumber(string.sub(chatId, 8))
        if not target then return false end
        netstream.Start("dbt/monopad/send/dms", localId, { type = "direct", id = target }, trimmed)
        local owner = LocalPlayer() and LocalPlayer():GetMonopadOwner()
        if owner and dbt and dbt.chr and dbt.chr[owner] then
            self:AddMessage(trimmed, owner, GetGlobalInt("Time"))
        end
        return true
    end

    if string.StartWith(chatId, "group:") then
        if chatData and chatData.kind == "group" and chatData.isMember == false then
            chat.AddText(Color(178, 30, 37), "Монокума наблюдает за этой группой и не может отправлять сообщения.")
            surface.PlaySound("buttons/button10.wav")
            return false
        end
        local groupId = tonumber(string.sub(chatId, 7))
        if not groupId then return false end
        netstream.Start("dbt/monopad/send/group", localId, groupId, trimmed)
        local owner = LocalPlayer() and LocalPlayer():GetMonopadOwner()
        if owner and dbt and dbt.chr and dbt.chr[owner] then
            self:AddMessage(trimmed, owner, GetGlobalInt("Time"))
        end
        return true
    end

    return false
end

function PANEL:OpenGroupInviteDialog(groupData, parentMenu)
    if not istable(groupData) then return false end
    if not groupData.id then return false end

    local menu = parentMenu
    local standalone = false
    if not IsValid(menu) or not menu.AddSubMenu then
        menu = DermaMenu()
        standalone = true
    end

    local submenu = select(1, menu:AddSubMenu("Пригласить участника"))
    local hasOptions = false

    for _, entry in ipairs(self.AllMonopads or {}) do
        local candidateId = entry.id
        if candidateId and candidateId ~= self.SelfMonopadId then
            if not groupData.memberMap or not groupData.memberMap[candidateId] then
                hasOptions = true
                local rawName = entry.character
                if CharacterNameOnName then
                    rawName = CharacterNameOnName(entry.character) or entry.character
                end
                submenu:AddOption(rawName, function()
                    surface.PlaySound('monopad_click.mp3')
                    local localId = self:GetLocalMonopadId()
                    if not localId then return end
                    netstream.Start("dbt/monopad/group/invite", localId, groupData.id, candidateId)
                end)
            end
        end
    end

    if not hasOptions then
        local option = submenu:AddOption("Нет доступных игроков", function() end)
        if option.SetEnabled then option:SetEnabled(false) end
    end

    if standalone then
        menu:Open()
    end

    return hasOptions
end

function PANEL:OpenRenameGroupDialog(groupData)
    if not istable(groupData) then return end
    if not groupData.id then return end

    Derma_StringRequest(
        "Переименовать группу",
        "Введите новое название",
        groupData.name or "",
        function(value)
            local localId = self:GetLocalMonopadId()
            if not localId then return end
            netstream.Start("dbt/monopad/group/rename", localId, groupData.id, value)
        end,
        function() end
    )
end

function PANEL:RemoveGroupMember(groupId, memberId)
    local localId = self:GetLocalMonopadId()
    if not localId then return end
    netstream.Start("dbt/monopad/group/remove", localId, groupId, memberId)
end

function PANEL:CreateGroup(rawName, invited)
    local localId = self:GetLocalMonopadId()
    if not localId then return end
    local packetInvited = {}
    if istable(invited) then
        for _, v in ipairs(invited) do
            local numeric = tonumber(v)
            if numeric then
                packetInvited[#packetInvited + 1] = numeric
            end
        end
    end
    netstream.Start("dbt/monopad/group/create", localId, rawName or "", packetInvited)
end

function PANEL:OpenCreateGroupDialog()
    if IsValid(self.CreateGroupWindow) then
        self.CreateGroupWindow:Close()
    end

    local frame = vgui.Create("MonopadGroupCreateFrame", workPlace)
    frame:SetContext(self.AllMonopads or {}, self.SelfMonopadId, function(name, invited)
        self:CreateGroup(name, invited)
    end)
    frame:Center()
    frame.OnRemove = function()
        if self.CreateGroupWindow == frame then
            self.CreateGroupWindow = nil
        end
    end
    self.CreateGroupWindow = frame
end

function PANEL:OpenGroupContextMenu(chatId)
    local groupData = self:GetChatData(chatId)
    if not groupData or groupData.kind ~= "group" then return end

    local menu = DermaMenu()

    if groupData.isMember == false then
        local option = menu:AddOption("Только просмотр (Монокума)", function() end)
        if option.SetEnabled then option:SetEnabled(false) end
        menu:Open()
        return
    end

    local selfId = self.SelfMonopadId or self:GetLocalMonopadId()

    if groupData.isOwner then
        menu:AddOption("Переименовать группу", function()
            self:OpenRenameGroupDialog(groupData)
        end)
        self:OpenGroupInviteDialog(groupData, menu)
        local removable = {}
        for _, member in ipairs(groupData.members or {}) do
            if member.id ~= selfId then
                removable[#removable + 1] = member
            end
        end
        if #removable > 0 then
            local submenu = select(1, menu:AddSubMenu("Исключить участника"))
            for _, member in ipairs(removable) do
                local rawName = member.character or "???"
                if CharacterNameOnName then
                    rawName = CharacterNameOnName(member.character) or member.character
                end
                submenu:AddOption(rawName, function()
                    surface.PlaySound('monopad_click.mp3')
                    self:RemoveGroupMember(groupData.id, member.id)
                end)
            end
        else
            local submenu = select(1, menu:AddSubMenu("Исключить участника"))
            local option = submenu:AddOption("Нет доступных участников", function() end)
            if option.SetEnabled then option:SetEnabled(false) end
        end
    end

    menu:AddOption("Покинуть группу", function()
        if not selfId then return end
        surface.PlaySound('monopad_click.mp3')
        self:RemoveGroupMember(groupData.id, selfId)
    end)

    menu:Open()
end

function PANEL:OnRemove()
    if IsValid(self.CreateGroupWindow) then
        self.CreateGroupWindow:Remove()
        self.CreateGroupWindow = nil
    end
end

--paternMat
function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,borderColor)
    draw.RoundedBox(0,1,1,w-2,h-2,bgColor)
    draw.RoundedBox(0, 1, 1, w - 2, dbtPaint.HightSource(20) - 1, bgColor2)
    draw.RoundedBox(0,0,dbtPaint.HightSource(20), w, 1, borderColor)
    if self.Dragging then self:RequestFocus() self.IsDragged = true end
    draw.SimpleText("Монограм", "Comfortaa X20", dbtPaint.WidthSource(25), -1, textColor, TEXT_ALIGN_LEFT)
    dbtPaint.DrawRect(msgMat, dbtPaint.WidthSource(5), dbtPaint.HightSource(3), dbtPaint.WidthSource(17), dbtPaint.HightSource(14), color_white)
    dbtPaint.DrawRect(paternMat, 0, dbtPaint.HightSource(21), dbtPaint.WidthSource(595), dbtPaint.HightSource(630), color_white)
end

netstream.Hook("dbt/monopad/request/chats", function(payload)
    if not IsValid(monopadChat) then return end
    monopadChat:BuildContacts(payload)
end)

netstream.Hook("dbt/monopad/request/dms", function(DirectMessages)
    if not IsValid(monopadChat) then return end
    monopadChat:ClearMessageList()
    if istable(DirectMessages) then
        local iterator = ipairs
        if DirectMessages[1] == nil then
            iterator = pairs
        end
        for _, entry in iterator(DirectMessages) do
            if istable(entry) then
                monopadChat:AddMessage(entry.message, entry.own, entry.time, entry)
            end
        end
    end
end)

netstream.Hook("monopad/chat/add", function(chatid, msgtable)
    if not IsValid(monopadChat) then return end
    if chatid ~= monopadChat.ActiveChatId then return end
    monopadChat:AddMessage(msgtable.message, msgtable.own, msgtable.time, msgtable)
end)

netstream.Hook("monopad/chat/show", function(id, msgtable)
    local pers = LocalPlayer():GetMonopadOwner()
    if IsValid(monopadChat) then return end

    local globaltime = GetGlobalInt("Time")
    local    s = globaltime % 60
    local    tmp = math.floor( globaltime / 60 )
    local    m = tmp % 60
    local    tmp = math.floor( tmp / 60 )
    local    h = tmp % 24
    local curtimesys = string.format( "%02i:%02i", h, m)
	/*
    MSG_SENDER = msgtable.own
    MSG_TIME = curtimesys
    MSG_bool = (utf8.len(msgtable.message) > 85)
    MSG_TEXT = utf8.sub(msgtable.message, 1, 85)
    see_msg = true
    see_r = false
    MSG_CAN_LERP1 = false
    MSG_ALPHA1 = 255
    MSG_ALPHA2 = weight_source(1080 - 984)
    timer.Remove("MSG1")
    timer.Create("MSG", 2.5, 1, function()
        MSG_CAN_LERP1 = true
        timer.Create("MSG1", 2, 1, function() see_msg = false end)
    end)*/
    local characterId = msgtable.character or msgtable.own
    local char_tbl = characterId and dbt.chr and dbt.chr[characterId]
    if not char_tbl then return end
	surface.PlaySound('chat_uved.mp3')
    local displayName = resolveCharacterName(characterId)
    notifications_new(4, {icon = "dbt/characters"..char_tbl.season.."/char"..char_tbl.char.."/char_ico_1.png", title = displayName, time = curtimesys, notiftext = msgtable.message})
end)

netstream.Hook("monopad/chat/notiftoall", function(msg, char)
    local pers = LocalPlayer():GetMonopadOwner()
    if char == pers then return end
    if IsValid(monopadChat) then return end
    if dbt.inventory.info.monopad and dbt.inventory.info.monopad.id then
		local globaltime = GetGlobalInt("Time")
	    local    s = globaltime % 60
	    local    tmp = math.floor( globaltime / 60 )
	    local    m = tmp % 60
	    local    tmp = math.floor( tmp / 60 )
	    local    h = tmp % 24
	    local curtimesys = string.format( "%02i:%02i", h, m)

        local senderName = resolveCharacterName(char)
        notifications_new(4, {icon = 'materials/dbt/notifications/notifications_allchat.png', title = 'Общий чат', time = curtimesys, notiftext = senderName..': '..msg})
	end
end)

netstream.Hook("dbt/monopad/chats/reset", function()
    if not IsValid(monopadChat) then return end
    monopadChat:ResetChats()
end)


vgui.Register("MonopadFrame", PANEL, "DFrame")
