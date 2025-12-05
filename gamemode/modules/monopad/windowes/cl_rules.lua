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
local msgMat = Material("dbt/monopad/Rules.png")
local paternMat = Material("dbt/monopad/rules_patern.png")
local editMat = Material("dbt/monopad/notes_edit.png")
local downMat = Material("dbt/monopad/arrow_rules.png")

local mat_rules = Material("dbt/monopad/Rules_Mini.png")
local mat_rules2 = Material("dbt/monopad/monokuma_eye.png")

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

rules_akkad = {
    {color_white,
    "Ученики могут свободно исследовать территорию школы (с минимальными ограничениями)"},
    {color_white,
    "Насилие в отношении директора школы (Монокумы) строго запрещено."},
    {color_white,
    "С 22:00 до 07:00 – официальное «ночное время». В это время некоторые локации школы могут быть закрыты по желанию директора школы.(Столовая, Спорт Зал)"},
    {color_white,
    "Сон вне общежития приравнивается ко сну на уроках и наказывается соответствующе."},
    {color_white,
    "Игрок, совершивший убийство, становится «очерненным». Очерненный выпускается из школы, если не будет раскрыт."},
    {color_white,
    "После обнаружения трупа игрокам дается некоторое время на расследование, после чего начинается школьный суд. Участие в  суде строго обязательно для всех оставшихся в живых игроков."},
    {color_white,
    "Если по итогам школьного суда очерненный определен игроками верно, то наказанию подвергается только он один."},
    {color_white,
    "Если по итогам школьного суда очерненный остается нераскрытым, то он выпускается из школы. Все остальные будут казнены"},
    {color_white,
    "Один игрок может совершить не более двух убийств."},
    {color_white,
    "Если два и более убийства были совершены разными игроками одновременно или с достаточно коротким промежутком времени между ними, то школьный суд проводится по поводу убийства того игрока, чье тело было обнаружено первым. Остальные убийства остаются безнаказанными."},
    {color_white,
    "Взламывать школьные двери строго запрещено. Исключение – двери в общежитии."},
    {color_white,
    "Дополнительные правила могут быть введены по желанию директора школы в любой момент."},
}

netstream.Hook("dbt/rules/update", function(newRules)
    rules_akkad = newRules
end)

function PANEL:Init()
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
    self.CloseB:SetPos(dbtPaint.WidthSource(844 - 41), 0)
	self.CloseB.DoClick = function ( button ) self:Close() end
	self.CloseB.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,borderColor)
        draw.RoundedBox(0,1,1,w-2,h-2,bgColor2)
        dbtPaint.DrawRect(xMat, w / 2 - 5.5, h / 2 - 5.5, 11, 11, color_white)
    end
    self.r_x, self.r_y = dbtPaint.WidthSource(844 / 2), dbtPaint.HightSource(519)
    self.needCorrect = true
    self.rule_id = 1

    self.buttonUp = vgui.Create( "DButton", self )
	self.buttonUp:SetText( "" )
    self.buttonUp:SetSize(dbtPaint.WidthSource(35), dbtPaint.HightSource(21))
    self.buttonUp:SetPos(dbtPaint.WidthSource(844) / 2 - dbtPaint.WidthSource(35), 0)
	self.buttonUp.DoClick = function ( button )
        self.rule_id = self.rule_id - 1
        if self.rule_id <= 0 then self.rule_id = #rules_akkad end
        self:ShowRule(self.rule_id)
		surface.PlaySound('monopad_click.mp3')
    end
	self.buttonUp.Paint = function( panel, w, h )
        dbtPaint.DrawRectR(downMat, w / 2, h / 2, w, h, 180, monopad.MainColorC)
    end

    self.buttonDown = vgui.Create( "DButton", self )
	self.buttonDown:SetText( "" )
    self.buttonDown:SetSize(dbtPaint.WidthSource(35), dbtPaint.HightSource(21))
    self.buttonDown:SetPos(dbtPaint.WidthSource(844) / 2 - dbtPaint.WidthSource(35), dbtPaint.HightSource(300))
	self.buttonDown.DoClick = function ( button )
        self.rule_id = self.rule_id + 1
        if self.rule_id > #rules_akkad then self.rule_id = 1 end
        self:ShowRule(self.rule_id)
		surface.PlaySound('monopad_click.mp3')
    end
	self.buttonDown.Paint = function( panel, w, h )
        dbtPaint.DrawRectR(downMat, w / 2, h / 2, w, h, 0, monopad.MainColorC)
    end

    self:ShowRule(self.rule_id)
end

function PANEL:ShowRule(id)
    local text = rules_akkad[id][2]
    local textTable = {}
    local lenText = utf8.len(text)
    local textmaxline = 46
    local a = math.Round(lenText / textmaxline)
    local b = lenText / textmaxline
    if a < b then a = a + 1 end
    for i = 1, a do
        textTable[i] = utf8.sub(text, (i-1) * textmaxline + 1, i * textmaxline)
    end

    self.textTable = textTable
    self.iters = #self.textTable
    self.corl = ((self.iters * dbtPaint.HightSource(30)) * 0.5)

    self.buttonUp:MoveTo(dbtPaint.WidthSource(844) / 2 - dbtPaint.WidthSource(35) / 2, dbtPaint.HightSource(519) * 0.47 - self.corl - dbtPaint.HightSource(18), 0.1)
    self.buttonDown:MoveTo(dbtPaint.WidthSource(844) / 2 - dbtPaint.WidthSource(35) / 2, dbtPaint.HightSource(519) * 0.47 + self.corl + dbtPaint.HightSource(18), 0.1)
end


function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,borderColor)
    draw.RoundedBox(0,1,1,w-2,h-2,bgColor)

    dbtPaint.DrawRect(paternMat, dbtPaint.WidthSource(1), dbtPaint.HightSource(20), w - 2, h - dbtPaint.HightSource(21), color_white)
    if self.Dragging then self:RequestFocus() self.IsDragged = true end
    draw.RoundedBox(0, 1, 1, w - 2, dbtPaint.HightSource(20) - 1, bgColor2)
    draw.RoundedBox(0,0,dbtPaint.HightSource(20), w, 1, borderColor)

    draw.SimpleText("Правила академии", "Comfortaa X20", dbtPaint.WidthSource(25), -1, textColor, TEXT_ALIGN_LEFT)
    dbtPaint.DrawRect(mat_rules, dbtPaint.WidthSource(8), dbtPaint.HightSource(4), dbtPaint.WidthSource(11), dbtPaint.HightSource(13), color_white)
    dbtPaint.DrawRect(mat_rules2, dbtPaint.WidthSource(6), dbtPaint.HightSource(4), dbtPaint.WidthSource(15), dbtPaint.HightSource(11), monopad.MainColorC)
    for k = 1, self.iters do
        draw.SimpleText(self.textTable[k], "Comfortaa X30", w / 2, h * 0.42 + (k * dbtPaint.HightSource(30)) - self.corl, textColor, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText(self.rule_id.." / "..#rules_akkad, "Comfortaa X45", w / 2, h * 0.05, textColor, TEXT_ALIGN_CENTER)
    --[[
    local x, y = surface.DrawMulticolorText(self.r_x, self.r_y, "Comfortaa Light X30", rules_akkad[1], dbtPaint.WidthSource(600))
    if self.needCorrect then
        local x = x - self.r_x
        local x = x / 2
        self.r_x, self.r_y = self.r_x - x, (self.r_y - (y / 2))
        self.needCorrect = false
    end]]
end



vgui.Register("RulesFrame", PANEL, "DFrame")


local function OpenRulesEditor()
    if !LocalPlayer():IsAdmin() then return end
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Редактор правил")
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()

    local rulesList = vgui.Create("DScrollPanel", frame)
    rulesList:Dock(FILL)

    for k, rule in ipairs(rules_akkad) do
        local rulePanel = vgui.Create("DPanel", rulesList)
        rulePanel:Dock(TOP)
        rulePanel:DockMargin(0, 0, 0, 5)
        rulePanel:SetHeight(40)

        local textEntry = vgui.Create("DTextEntry", rulePanel)
        textEntry:Dock(FILL)
        textEntry:SetValue(rule[2])

        local deleteButton = vgui.Create("DButton", rulePanel)
        deleteButton:Dock(RIGHT)
        deleteButton:SetText("Удалить")
        deleteButton:SetWidth(80)

        deleteButton.DoClick = function()
            table.remove(rules_akkad, k)
            frame:Close()
            OpenRulesEditor()
        end

        textEntry.OnChange = function(self)
            rules_akkad[k][2] = self:GetValue()
        end
    end

    local resetButton = vgui.Create("DButton", frame)
    resetButton:Dock(BOTTOM)
    resetButton:SetText("Сбросить")

    resetButton.DoClick = function()
        frame:Close()
        netstream.Start("dbt/rules/reset")
    end

    local addButton = vgui.Create("DButton", frame)
    addButton:Dock(BOTTOM)
    addButton:SetText("Добавить правило")

    addButton.DoClick = function()
        table.insert(rules_akkad, {color_white, "Новое правило"})
        frame:Close()
        OpenRulesEditor()
    end
    
    local saveButton = vgui.Create("DButton", frame)
    saveButton:Dock(BOTTOM)
    saveButton:SetText("Сохранить")

    saveButton.DoClick = function()
        frame:Close()
        netstream.Start("dbt/rules/update", rules_akkad)
    end


end--"dbt/rules/reset"

-- Пример команды для открытия редактора
concommand.Add("open_rules_editor", OpenRulesEditor)