local PANEL = {}
local bgColor = Color(29, 29, 29, 255)
local bgColor2 = Color(48, 48, 48, 255)
local borderColor = Color(73, 73, 73)
local textColor = Color(160, 160, 160)
local textColor2 = Color(160, 160, 160, 200)
local contactColor = Color(37, 37, 37)
local selectedColor = Color(145, 0, 190, 255)
local headerHeight = dbtPaint.HightSource(21)

local xMat = Material("dbt/monopad/X.png")
local iconMat = Material("dbt/monopad/Messages.png")
local patternMat = Material("dbt/monopad/paternm.png")

function PANEL:Init()
    self:SetFocusTopLevel(true)
    self:SetDraggable(true)
    self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)

    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
    self:ShowCloseButton(false)
    self:SetTitle("")

    self:SetSize(dbtPaint.WidthSource(360), dbtPaint.HightSource(420))
    self:Center()
    self.m_fCreateTime = SysTime()

    self.AllMonopads = {}
    self.PlayerRows = {}
    self.SelfMonopadId = nil
    self.OnCreateCallback = nil

    self.CloseB = vgui.Create("DButton", self)
    self.CloseB:SetText("")
    self.CloseB:SetSize(dbtPaint.WidthSource(41), dbtPaint.HightSource(21))
    self.CloseB:SetPos(self:GetWide() - self.CloseB:GetWide(), 0)
    self.CloseB.DoClick = function()
        surface.PlaySound('monopad_click.mp3')
        self:Close()
    end
    self.CloseB.Paint = function(panel, w, h)
        draw.RoundedBox(0, 0, 0, w, h, borderColor)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, bgColor2)
        dbtPaint.DrawRect(xMat, w / 2 - 5.5, h / 2 - 5.5, 11, 11, color_white)
    end

    self.NameEntry = vgui.Create("DTextEntry", self)
    self.NameEntry:SetSize(self:GetWide() - dbtPaint.WidthSource(24), dbtPaint.HightSource(32))
    self.NameEntry:SetPos(dbtPaint.WidthSource(12), headerHeight + dbtPaint.HightSource(20))
    self.NameEntry:SetFont("Comfortaa X24")
    self.NameEntry:SetPlaceholderText("Название группы")
    self.NameEntry:SetTextColor(textColor)
    self.NameEntry:SetDrawLanguageID(false)
    self.NameEntry.Paint = function(panel, w, h)
        draw.RoundedBox(6, 0, 0, w, h, contactColor)
        panel:DrawTextEntryText(panel:GetTextColor(), monopad.MainColorC or selectedColor, panel:GetTextColor())
    end

    local listTop = self.NameEntry:GetY() + self.NameEntry:GetTall() + dbtPaint.HightSource(12)
    local listHeight = math.max(0, self:GetTall() - listTop - dbtPaint.HightSource(80))
    self.Scroll = vgui.Create("DScrollPanel", self)
    self.Scroll:SetSize(self:GetWide() - dbtPaint.WidthSource(24), listHeight)
    self.Scroll:SetPos(dbtPaint.WidthSource(12), listTop)
    local vbar = self.Scroll:GetVBar()
    function vbar:Paint(w, h) end
    function vbar.btnUp:Paint(w, h) end
    function vbar.btnDown:Paint(w, h) end
    function vbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, bgColor2)
    end

    self.NoPlayersLabel = vgui.Create("DLabel", self)
    self.NoPlayersLabel:SetSize(self.Scroll:GetWide(), dbtPaint.HightSource(60))
    self.NoPlayersLabel:SetPos(self.Scroll.x, self.Scroll.y)
    self.NoPlayersLabel:SetFont("Comfortaa X20")
    self.NoPlayersLabel:SetTextColor(textColor2)
    self.NoPlayersLabel:SetWrap(true)
    self.NoPlayersLabel:SetText("Нет доступных участников. Вы сможете пригласить их позже через меню группы.")
    self.NoPlayersLabel:SetVisible(false)

    self.CreateButton = vgui.Create("DButton", self)
    self.CreateButton:SetSize(self:GetWide() - dbtPaint.WidthSource(24), dbtPaint.HightSource(36))
    self.CreateButton:SetPos(dbtPaint.WidthSource(12), self:GetTall() - dbtPaint.HightSource(48))
    self.CreateButton:SetText("Создать")
    self.CreateButton:SetFont("Comfortaa X24")
    self.CreateButton:SetTextColor(color_white)
    self.CreateButton.Paint = function(panel, w, h)
        draw.RoundedBox(6, 0, 0, w, h, monopad.MainColorC or selectedColor)
    end
    self.CreateButton.DoClick = function()
        surface.PlaySound('monopad_click.mp3')
        self:Submit()
    end

    self.NameEntry.OnEnter = function()
        surface.PlaySound('monopad_click.mp3')
        self:Submit()
    end
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_ESCAPE then
        surface.PlaySound('monopad_click.mp3')
        self:Close()
    else
        self:DefaultKeyCode(key)
    end
end

function PANEL:SetContext(monopads, selfId, callback)
    self.AllMonopads = monopads or {}
    self.SelfMonopadId = selfId
    self.OnCreateCallback = callback
    self.NameEntry:SetValue("")
    self.NameEntry:RequestFocus()
    self:RebuildList()
end

function PANEL:RebuildList()
    self.PlayerRows = {}
    if self.Scroll.Clear then
        self.Scroll:Clear()
    end
    local canvas = self.Scroll.GetCanvas and self.Scroll:GetCanvas()
    if IsValid(canvas) then
        for _, child in ipairs(canvas:GetChildren()) do
            if IsValid(child) then child:Remove() end
        end
    end

    local hasChoices = false
    for _, entry in ipairs(self.AllMonopads or {}) do
        if entry.id ~= self.SelfMonopadId then
            hasChoices = true
            local displayName = (CharacterNameOnName and CharacterNameOnName(entry.character)) or entry.character or "???"
            local row = self.Scroll:Add("DButton")
            row:SetText("")
            row:SetTall(dbtPaint.HightSource(34))
            row:Dock(TOP)
            row:DockMargin(dbtPaint.WidthSource(6), dbtPaint.HightSource(4), dbtPaint.WidthSource(6), 0)
            row.PlayerId = entry.id
            row.Selected = false
            row.DisplayName = displayName
            row.Paint = function(panel, w, h)
                local base = contactColor
                local txtCol = textColor
                if panel.Selected then
                    base = monopad.MainColorC or selectedColor
                    txtCol = color_white
                elseif panel:IsHovered() then
                    base = Color(44, 44, 44)
                end
                draw.RoundedBox(6, 0, 0, w, h, base)
                draw.SimpleText(panel.DisplayName, "Comfortaa X22", dbtPaint.WidthSource(12), h / 2 - dbtPaint.HightSource(10), txtCol, TEXT_ALIGN_LEFT)
            end
            row.DoClick = function(panel)
                panel.Selected = not panel.Selected
                surface.PlaySound('monopad_click.mp3')
            end
            self.PlayerRows[#self.PlayerRows + 1] = row
        end
    end

    self.NoPlayersLabel:SetVisible(not hasChoices)
    self.Scroll:SetVisible(hasChoices)
end

function PANEL:GetInvited()
    local invited = {}
    for _, row in ipairs(self.PlayerRows or {}) do
        if row.Selected and row.PlayerId then
            invited[#invited + 1] = row.PlayerId
        end
    end
    return invited
end

function PANEL:Submit()
    local callback = self.OnCreateCallback
    if not callback then
        self:Close()
        return
    end

    local name = string.Trim(self.NameEntry:GetValue() or "")
    local invited = self:GetInvited()
    callback(name, invited)
    self:Close()
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, borderColor)
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, bgColor)
    draw.RoundedBox(0, 1, 1, w - 2, headerHeight - 1, bgColor2)
    draw.RoundedBox(0, 0, headerHeight, w, 1, borderColor)
    if self.Dragging then self:RequestFocus() self.IsDragged = true end
    draw.SimpleText("Создание группы", "Comfortaa X20", dbtPaint.WidthSource(25), -1, textColor, TEXT_ALIGN_LEFT)
    dbtPaint.DrawRect(iconMat, dbtPaint.WidthSource(5), dbtPaint.HightSource(3), dbtPaint.WidthSource(17), dbtPaint.HightSource(14), color_white)
    dbtPaint.DrawRect(patternMat, dbtPaint.WidthSource(1), headerHeight, w - dbtPaint.WidthSource(2), h - headerHeight - dbtPaint.HightSource(2), color_white)
end

vgui.Register("MonopadGroupCreateFrame", PANEL, "DFrame")
