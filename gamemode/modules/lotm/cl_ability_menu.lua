-- LOTM Ability Selection Menu
-- Меню выбора способностей в стиле проекта DBT

LOTM = LOTM or {}
LOTM.AbilityMenu = LOTM.AbilityMenu or {}

-- Цветовая палитра проекта
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255, 200)
local colorButtonExit = Color(250, 250, 250, 1)
local colorSettingsPanel = Color(0, 0, 0, 170)
local colorSettingsPanelActive = Color(191, 30, 219, 150)
local colorSlotEmpty = Color(40, 35, 50, 200)
local colorSlotFilled = Color(80, 50, 100, 220)
local colorEquipped = Color(50, 120, 50, 200)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Функция отрисовки рамки
local function draw_border(w, h, color)
    draw.RoundedBox(0, 0, 0, w, 1, color)
    draw.RoundedBox(0, 0, 0, 1, h, color)
    draw.RoundedBox(0, 0, h - 1, w, 1, color)
    draw.RoundedBox(0, w - 1, 0, 1, h, color)
end

-- Выбранный слот для назначения
local selectedSlot = 1

-- Открыть меню выбора способностей
function LOTM.AbilityMenu.Open()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.AbilityMenu.Frame) then
        LOTM.AbilityMenu.Frame:Close()
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw, scrh)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    LOTM.AbilityMenu.Frame = frame
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            self:Close()
            return true
        end
    end
    
    frame.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 150))
        
        draw.SimpleText("СПОСОБНОСТИ", "Comfortaa Bold X60", w / 2, dbtPaint.HightSource(80), color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("Выберите слот и назначьте способность", "Comfortaa Light X25", w / 2, dbtPaint.HightSource(145), colorText, TEXT_ALIGN_CENTER)
        
        local lineW = dbtPaint.WidthSource(300)
        draw.RoundedBox(0, w / 2 - lineW / 2, dbtPaint.HightSource(180), lineW, 2, colorOutLine)
    end
    
    -- Левая панель - слоты
    local slotPanelW = dbtPaint.WidthSource(280)
    local slotPanelH = dbtPaint.HightSource(550)
    local slotPanelX = dbtPaint.WidthSource(150)
    local slotPanelY = dbtPaint.HightSource(220)
    
    local slotsContainer = vgui.Create("DPanel", frame)
    slotsContainer:SetPos(slotPanelX, slotPanelY)
    slotsContainer:SetSize(slotPanelW, slotPanelH)
    slotsContainer.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorSettingsPanel)
        draw.SimpleText("СЛОТЫ", "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(20), colorOutLine, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 150)
        surface.DrawRect(dbtPaint.WidthSource(20), dbtPaint.HightSource(45), w - dbtPaint.WidthSource(40), 1)
    end
    
    local slotH = dbtPaint.HightSource(85)
    local slotStartY = dbtPaint.HightSource(60)
    local slotButtons = {}
    
    local function RefreshSlots()
        for i = 1, 5 do
            if IsValid(slotButtons[i]) then
                slotButtons[i]:Remove()
            end
            
            local slotBtn = vgui.Create("DButton", slotsContainer)
            slotBtn:SetPos(dbtPaint.WidthSource(15), slotStartY + (i - 1) * (slotH + dbtPaint.HightSource(10)))
            slotBtn:SetSize(slotPanelW - dbtPaint.WidthSource(30), slotH)
            slotBtn:SetText("")
            slotButtons[i] = slotBtn
            
            slotBtn.Paint = function(self, w, h)
                local isSelected = selectedSlot == i
                local ability = LOTM.Abilities and LOTM.Abilities.GetSlot and LOTM.Abilities.GetSlot(LocalPlayer(), i) or nil
                local hovered = self:IsHovered()
                
                local bgColor = ability and colorSlotFilled or colorSlotEmpty
                if isSelected then
                    bgColor = Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
                elseif hovered then
                    bgColor = colorButtonActive
                end
                
                draw.RoundedBox(0, 0, 0, w, h, bgColor)
                
                if isSelected or hovered then
                    draw_border(w, h, colorOutLine)
                end
                
                -- Номер слота
                draw.SimpleText(tostring(i), "Comfortaa Bold X35", dbtPaint.WidthSource(25), h / 2, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Разделитель
                surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
                surface.DrawRect(dbtPaint.WidthSource(50), dbtPaint.HightSource(10), 1, h - dbtPaint.HightSource(20))
                
                if ability then
                    draw.SimpleText(ability.name, "Comfortaa Light X22", dbtPaint.WidthSource(65), h / 2 - dbtPaint.HightSource(12), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("CD: " .. (ability.cooldown or 0) .. "s", "Comfortaa Light X16", dbtPaint.WidthSource(65), h / 2 + dbtPaint.HightSource(12), colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    if hovered then
                        draw.SimpleText("ОЧИСТИТЬ", "Comfortaa Light X14", w - dbtPaint.WidthSource(15), h / 2, Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end
                else
                    draw.SimpleText("Пусто", "Comfortaa Light X22", dbtPaint.WidthSource(65), h / 2, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
            
            slotBtn.DoClick = function()
                surface.PlaySound('ui/button_click.mp3')
                local ability = LOTM.Abilities and LOTM.Abilities.GetSlot and LOTM.Abilities.GetSlot(LocalPlayer(), i) or nil
                if ability then
                    LOTM.AbilityMenu.ClearSlot(i)
                    timer.Simple(0.1, RefreshSlots)
                end
                selectedSlot = i
            end
            
            slotBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
        end
    end
    
    RefreshSlots()
    
    -- Правая панель - список способностей
    local listPanelW = dbtPaint.WidthSource(1300)
    local listPanelH = slotPanelH
    local listPanelX = slotPanelX + slotPanelW + dbtPaint.WidthSource(30)
    local listPanelY = slotPanelY
    
    local listContainer = vgui.Create("DPanel", frame)
    listContainer:SetPos(listPanelX, listPanelY)
    listContainer:SetSize(listPanelW, listPanelH)
    listContainer.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorSettingsPanel)
        draw.SimpleText("ДОСТУПНЫЕ СПОСОБНОСТИ", "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(20), colorOutLine, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 150)
        surface.DrawRect(dbtPaint.WidthSource(20), dbtPaint.HightSource(45), w - dbtPaint.WidthSource(40), 1)
    end
    
    local scrollPanel = vgui.Create("DScrollPanel", listContainer)
    scrollPanel:SetPos(dbtPaint.WidthSource(15), dbtPaint.HightSource(60))
    scrollPanel:SetSize(listPanelW - dbtPaint.WidthSource(30), listPanelH - dbtPaint.HightSource(75))
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(8))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    local function RefreshAbilityList()
        scrollPanel:Clear()
        
        local abilities = LOTM.Abilities and LOTM.Abilities.GetAll and LOTM.Abilities.GetAll() or {}
        local y = 0
        local abilityH = dbtPaint.HightSource(90)
        
        for id, ability in pairs(abilities) do
            local isEquipped = false
            for slot = 1, 5 do
                local equipped = LOTM.Abilities and LOTM.Abilities.GetSlot and LOTM.Abilities.GetSlot(LocalPlayer(), slot) or nil
                if equipped and equipped.id == id then
                    isEquipped = true
                    break
                end
            end
            
            local abilityPanel = vgui.Create("DButton", scrollPanel)
            abilityPanel:SetPos(0, y)
            abilityPanel:SetSize(scrollPanel:GetWide() - dbtPaint.WidthSource(15), abilityH)
            abilityPanel:SetText("")
            
            abilityPanel.Paint = function(self, w, h)
                local hovered = self:IsHovered()
                local bgColor = isEquipped and colorEquipped or (hovered and colorButtonActive or colorSettingsPanel)
                
                draw.RoundedBox(0, 0, 0, w, h, bgColor)
                
                -- Левая полоса
                local accentColor = isEquipped and Color(100, 200, 100) or (hovered and colorSettingsPanelActive or colorOutLine)
                draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, accentColor)
                
                -- Иконка заглушка
                draw.RoundedBox(0, dbtPaint.WidthSource(20), dbtPaint.HightSource(12), dbtPaint.WidthSource(66), h - dbtPaint.HightSource(24), colorSlotFilled)
                draw.SimpleText("✦", "Comfortaa Bold X30", dbtPaint.WidthSource(53), h / 2, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Название
                draw.SimpleText(ability.name, "Comfortaa Bold X26", dbtPaint.WidthSource(100), dbtPaint.HightSource(22), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Описание
                local desc = ability.description or "Нет описания"
                if #desc > 70 then desc = string.sub(desc, 1, 67) .. "..." end
                draw.SimpleText(desc, "Comfortaa Light X18", dbtPaint.WidthSource(100), dbtPaint.HightSource(48), colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Характеристики
                local statsX = dbtPaint.WidthSource(100)
                local statsY = dbtPaint.HightSource(72)
                
                draw.SimpleText("CD: " .. (ability.cooldown or 0) .. "s", "Comfortaa Light X16", statsX, statsY, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                statsX = statsX + dbtPaint.WidthSource(80)
                
                draw.SimpleText("Энергия: " .. (ability.energyCost or 0), "Comfortaa Light X16", statsX, statsY, Color(100, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                statsX = statsX + dbtPaint.WidthSource(120)
                
                if ability.hitboxParams and ability.hitboxParams.damage then
                    draw.SimpleText("Урон: " .. ability.hitboxParams.damage, "Comfortaa Light X16", statsX, statsY, Color(255, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                -- Статус справа
                if isEquipped then
                    draw.SimpleText("НАЗНАЧЕНО", "Comfortaa Bold X20", w - dbtPaint.WidthSource(20), h / 2, Color(100, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                elseif hovered then
                    draw.SimpleText("НАЗНАЧИТЬ В СЛОТ " .. selectedSlot, "Comfortaa Bold X18", w - dbtPaint.WidthSource(20), h / 2, colorOutLine, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            
            abilityPanel.DoClick = function()
                if not isEquipped then
                    surface.PlaySound('ui/button_click.mp3')
                    LOTM.AbilityMenu.SetSlot(selectedSlot, id)
                    timer.Simple(0.1, function()
                        RefreshAbilityList()
                        RefreshSlots()
                    end)
                else
                    surface.PlaySound('ui/item_info_close.wav')
                end
            end
            
            abilityPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
            
            y = y + abilityH + dbtPaint.HightSource(8)
        end
        
        if table.Count(abilities) == 0 then
            local emptyLabel = vgui.Create("DLabel", scrollPanel)
            emptyLabel:SetPos(0, dbtPaint.HightSource(50))
            emptyLabel:SetSize(scrollPanel:GetWide(), dbtPaint.HightSource(40))
            emptyLabel:SetText("Нет доступных способностей")
            emptyLabel:SetFont("Comfortaa Light X25")
            emptyLabel:SetTextColor(colorText)
            emptyLabel:SetContentAlignment(5)
        end
    end
    
    RefreshAbilityList()
    
    -- Кнопка НАЗАД
    local backButton = vgui.Create("DButton", frame)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        frame:Close()
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- Установить способность в слот (сетевой запрос)
function LOTM.AbilityMenu.SetSlot(slot, abilityId)
    net.Start("LOTM.Abilities.SetSlot")
    net.WriteUInt(slot, 4)
    net.WriteString(abilityId)
    net.SendToServer()
end

-- Очистить слот
function LOTM.AbilityMenu.ClearSlot(slot)
    net.Start("LOTM.Abilities.SetSlot")
    net.WriteUInt(slot, 4)
    net.WriteString("")
    net.SendToServer()
end

-- Хук для открытия меню
hook.Add("LOTM.Abilities.OpenMenu", "LOTM.AbilityMenu.Open", function()
    LOTM.AbilityMenu.Open()
end)

-- Консольная команда
concommand.Add("lotm_abilities", function()
    LOTM.AbilityMenu.Open()
end)

print("[LOTM] Ability selection menu loaded")
