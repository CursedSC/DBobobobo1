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
local lineColor = Color(105, 105, 105, 100)

local xMat = Material("dbt/monopad/X.png")
local msgMat = Material("dbt/monopad/Notes.png")
local paternMat = Material("dbt/monopad/db_signs.png")
local editMat = Material("dbt/monopad/notes_edit.png")
local downMat = Material("dbt/monopad/drop_down.png")
local editMatComplete = Material("dbt/monopad/edit_complete.png")
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

local function build_RichText(testPanel, y)
    local richtext = vgui.Create( "RichText", testPanel )
    richtext:SetPos(weight_source(10), hight_source(40))
    richtext:SetSize(weight_source(520), y + hight_source(40) )
    function richtext:PerformLayout()
        self:SetFontInternal("Comfortaa X20")
    end
    richtext:SetVerticalScrollbarEnabled(false)
    richtext:InsertColorChange( 192, 192, 192, 255 )
    richtext:AppendText( testPanel.Text )
    return richtext
end

-- k = id; i = либо строка (старый формат) либо таблица {name,text,editable}
function PANEL:AddSign(k, i, bNew)
        local noteName, noteText, noteEditable

        noteName = i.name or ("Заметка "..k)
        noteText = i.text or ""
        noteEditable = (i.editable ~= false)


        local testPanel = vgui.Create("DButton", self.ListEv)
        testPanel:SetText("")
        testPanel.Text = noteText
        testPanel.Name = noteName
        testPanel.Editable = noteEditable
        testPanel.id = k
        if !bNew then
            testPanel:SetPos(0, self.SignsY)
        elseif bNew and #self.signs == 1 then
            testPanel:SetPos(0, self.SignsY)
        else
            local glavButton = self.signs[#self.signs]
            local x_pos, y_pos = glavButton:GetPos()
            local x_s, y_s = glavButton:GetSize()
            testPanel:SetPos(0, y_pos + y_s + hight_source(11))
        end

        testPanel:SetSize(dbtPaint.WidthSource(570), dbtPaint.HightSource(39))
        -- handle explicit newlines and Enter presses
        local text = tostring(testPanel.Text or "")
        text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
        testPanel.Text = text

        surface.SetFont("Comfortaa X20")
        local maxw = weight_source(510)
        local totalY = 0

        for line in (text .. "\n"):gmatch("(.-)\n") do
            local _, lh = surface.GetTextSize(" ")
            if line == "" then
            totalY = totalY + lh
            else
            local _, ly = surface.DrawMulticolorText(0, 0, "Comfortaa X20", { textColor, line }, maxw)
            local ly = (ly == 0) and lh or ly
            totalY = totalY + ly
            end
        end

        local y = totalY
        testPanel.YSizeText = y + hight_source(40)

        testPanel.rt = build_RichText(testPanel, y)



        local editPanel = vgui.Create("DButton", testPanel)
        editPanel:SetText("")
        editPanel:SetPos(dbtPaint.WidthSource(510), dbtPaint.HightSource(10))
        editPanel:SetSize(dbtPaint.WidthSource(19), dbtPaint.HightSource(19))
        editPanel.DoClick = function(panel)
            local p = panel:GetParent()
            local b = p.isOpened
            if !b or not p.Editable then return end
			surface.PlaySound('monopad_click.mp3')
            if p.TextEditor and IsValid(p.TextEditor) then
                p.bNoShow = false p.TextEditor:Remove()
                testPanel.rt:Remove()
                testPanel.rt = build_RichText(testPanel, testPanel.YSizeText - hight_source(40))
                netstream.Start("dbt/monopad/notes/edit", testPanel.id, testPanel.Text)
                panel:MoveTo(dbtPaint.WidthSource(510), dbtPaint.HightSource(10), 0.1)
                return
            end

            panel:MoveTo(dbtPaint.WidthSource(543), dbtPaint.HightSource(10), 0.1)
            p.bNoShow = true
            testPanel.rt:SetAlpha(0)
            local TextEntry = vgui.Create( "DTextEntry", p ) -- create the form as a child of frame
            TextEntry:SetPos(weight_source(10), hight_source(40))
            TextEntry:SetSize(weight_source(510), y + hight_source(40) + dbtPaint.HightSource(39))
            TextEntry:SetFont("Comfortaa X20")
            TextEntry:SetTextColor(textColor)
            TextEntry:SetDrawLanguageID(false)
            TextEntry:SetMultiline(true)
            TextEntry:SetValue(p.Text)
            TextEntry:SetUpdateOnType( true )
            TextEntry.OnValueChange = function(panel, code)
                -- normalize newlines to \n and account for Enter presses
                local val = panel:GetValue() or ""
                val = val:gsub("\r\n", "\n"):gsub("\r", "\n")

                p.Text = val
                local meta = dbt.inventory.info.monopad.meta.signs[p.id]
                if type(meta) == "table" then
                    meta.text = p.Text
                else
                    dbt.inventory.info.monopad.meta.signs[p.id] = { name = p.Name, text = p.Text, editable = true }
                end

                -- measure height with explicit \n taken into account
                local maxw = weight_source(510)
                local totalY = 0
                surface.SetFont("Comfortaa X20")
                for line in (val .. "\n"):gmatch("([^\n]*)\n") do
                    local _, lh = surface.GetTextSize(" ")
                    if line == "" then
                        totalY = totalY + lh
                    else
                        local _, ly = surface.DrawMulticolorText(0, 0, "Comfortaa X20", { textColor, line }, maxw)
                        local ly = (ly == 0) and lh or ly
                        totalY = totalY + ly
                    end
                end

                p.YSizeText = totalY + hight_source(40)

                local old_x, old_y = p:GetSize()
                local sizeR = (p.YSizeText + dbtPaint.HightSource(39)) - old_y
                for id = k + 2, table.Count(self.signs) do
                    local glavButton = self.signs[id]
                    local x_pos, y_pos = glavButton:GetPos()
                    glavButton:MoveTo(dbtPaint.WidthSource(0), y_pos + sizeR, 0.1, 0, -1, function() end)
                end

                testPanel:SetSize(dbtPaint.WidthSource(570), dbtPaint.HightSource(39) + p.YSizeText)

                local _, te_old_y = panel:GetSize()
                TextEntry:SetSize(dbtPaint.WidthSource(510), te_old_y + sizeR + dbtPaint.HightSource(39))
	        end
            TextEntry:SetPaintBackground(false)
            p.TextEditor = TextEntry
        end
        editPanel.Paint = function(panel, w, h)
            local p = panel:GetParent()
            local w, h = w, h
            if not p.Editable then
                return
            end
            if IsValid(p.TextEditor) then w = dbtPaint.WidthSource(21) h = dbtPaint.HightSource(15) end
            dbtPaint.DrawRect(IsValid(p.TextEditor) and editMatComplete or editMat, 0, 0, w, h, color_white)
        end
        local colorcheckboxColor = Color(checkboxColor.r, checkboxColor.g, checkboxColor.b, 200)
        testPanel.Paint = function(panel, w, h)
            draw.RoundedBox(0,0,0,w,h,colorcheckboxColor)
            --local text = IsValid(panel.TextEditor) and {textColor, "Заметка "..k, monopad.MainColorC, " [Редактирование]"} or {textColor, "Заметка "..k}
            surface.SetFont("Comfortaa Bold X30")
            local title = panel.Name or ("Заметка "..k)
            local lw = surface.GetTextSize(title)
            draw.SimpleText(title, "Comfortaa Bold X30", dbtPaint.WidthSource(10), dbtPaint.HightSource(3), textColor, TEXT_ALIGN_LEFT)
            if IsValid(panel.TextEditor) then
                draw.SimpleText(" [редактирование]", "Comfortaa Bold X30", lw + dbtPaint.WidthSource(12), dbtPaint.HightSource(3), monopad.MainColorC, TEXT_ALIGN_LEFT)
            elseif not panel.Editable then
                draw.SimpleText(" [только чтение]", "Comfortaa Bold X30", lw + dbtPaint.WidthSource(12), dbtPaint.HightSource(3), monopad.MainColorC, TEXT_ALIGN_LEFT)
            end
            --surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(3), "Comfortaa Light X30", text, dbtPaint.WidthSource(600))
            if panel.isOpened then draw.RoundedBox(0, dbtPaint.WidthSource(10), dbtPaint.WidthSource(37), w - dbtPaint.WidthSource(20), 1, lineColor) end

            if !IsValid(panel.TextEditor) then dbtPaint.DrawRectR(downMat, dbtPaint.WidthSource(543) + dbtPaint.WidthSource(10), dbtPaint.HightSource(20), dbtPaint.WidthSource(21), dbtPaint.HightSource(11), panel.isOpened and 0 or 180) end
        end

        testPanel.DoClick = function(panel)
            if IsValid(panel.TextEditor) then return end
			surface.PlaySound('monopad_click.mp3')
            local evidiceY = panel.YSizeText
            if panel.isOpened then
                testPanel:SizeTo(dbtPaint.WidthSource(570), dbtPaint.HightSource(39), 0.1)
                for id = panel.id + 2, table.Count(self.signs) do
                    local glavButton = self.signs[id]
                    local x_pos, y_pos = glavButton:GetPos()
                    glavButton:MoveTo( dbtPaint.WidthSource(0), y_pos - evidiceY, 0.1, 0, -1, function()
                    end)
                end
            else
                testPanel:SizeTo(dbtPaint.WidthSource(570), dbtPaint.HightSource(39) + evidiceY, 0.1)
                for id = panel.id + 2, table.Count(self.signs) do
                    local glavButton = self.signs[id]
                    local x_pos, y_pos = glavButton:GetPos()
                    glavButton:MoveTo( dbtPaint.WidthSource(0), y_pos + evidiceY, 0.1, 0, -1, function()
                    end)
                end
            end
            panel.isOpened = !panel.isOpened
        end
        self.SignsY = self.SignsY + dbtPaint.HightSource(50)
        table.insert(self.signs, testPanel)
end

function PANEL:BuildList()
    for k, i in pairs(self.Signs) do
        self:AddSign(k, i)
    end
end

function PANEL:Init()
    self.Signs = dbt.inventory.info.monopad.meta.signs
    -- Миграция всех строк в структуры на клиенте
    for id, v in pairs(self.Signs) do
        if type(v) == "string" then
            self.Signs[id] = { name = "Заметка "..id, text = v, editable = true }
            dbt.inventory.info.monopad.meta.signs[id] = self.Signs[id]
        end
    end
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

    self.ListEv = vgui.Create( "DScrollPanel", self )
    self.ListEv:SetSize(dbtPaint.WidthSource(597 - 10), dbtPaint.HightSource(625 - 30))
    self.ListEv:SetPos(dbtPaint.WidthSource(11), dbtPaint.HightSource(30))
    local sbar = self.ListEv:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0,w / 2 - 2,0,2,h,borderColor)
    end
    self.SignsY = 0
    self.signs = {}


    local createNew = vgui.Create("DButton", self.ListEv)
    createNew:SetText("")
    createNew:SetPos(0, self.SignsY)
    createNew:SetSize(dbtPaint.WidthSource(570), dbtPaint.HightSource(39))
    local colorcheckboxColor = Color(checkboxColor.r, checkboxColor.g, checkboxColor.b, 200)
    createNew.Paint = function(panel, w, h)
        draw.RoundedBox(0,0,0,w,h,colorcheckboxColor)
        draw.SimpleText("Создать заметку", "Comfortaa X30", w / 2, dbtPaint.HightSource(3), textColor, TEXT_ALIGN_CENTER)
    end
    createNew.DoClick = function(panel)
        local id = table.Count(self.Signs) + 1
		surface.PlaySound('monopad_click.mp3')
        local newStruct = { name = "Заметка "..id, text = "Текст новой записки", editable = true }
        self.Signs[id] = newStruct
        dbt.inventory.info.monopad.meta.signs[id] = newStruct
        self:AddSign(id, newStruct, true)
        netstream.Start("dbt/monopad/notes/add", id, newStruct.name, newStruct.text, newStruct.editable)
    end
    table.insert(self.signs, createNew)
    self.SignsY = self.SignsY + dbtPaint.HightSource(50)
    self:BuildList()

end


function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,borderColor)
    draw.RoundedBox(0,1,1,w-2,h-2,bgColor)

    dbtPaint.DrawRect(paternMat, dbtPaint.WidthSource(1), dbtPaint.HightSource(20), w - 3, dbtPaint.HightSource(630), color_white)
if self.Dragging then self:RequestFocus() self.IsDragged = true end
    draw.RoundedBox(0, 1, 1, w - 2, dbtPaint.HightSource(20) - 1, bgColor2)
    draw.RoundedBox(0,0,dbtPaint.HightSource(20), w, 1, borderColor)

    draw.SimpleText("Заметки", "Comfortaa X20", dbtPaint.WidthSource(25), -1, textColor, TEXT_ALIGN_LEFT)
    dbtPaint.DrawRect(msgMat, dbtPaint.WidthSource(5), dbtPaint.HightSource(3), dbtPaint.WidthSource(14), dbtPaint.HightSource(13), color_white)

end



vgui.Register("SignFrame", PANEL, "DFrame")
