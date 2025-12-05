local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

local function save_character(tbl, char)
    if not istable(tbl) then return end
    local payload = table.Copy(tbl)
    payload.backup = nil
    netstream.Start("dbt/characters/save", payload, char)
end

local acb = {
    ["food"] = "Скорость голода",
    ["water"] = "Скорость жажды",
    ["sleep"] = "Скорость сна",
}

local function normalizeColor(col)
    if IsColor and IsColor(col) then
        return Color(col.r, col.g, col.b, col.a or 255)
    end
    if istable(col) and col.r and col.g and col.b then
        return Color(col.r, col.g, col.b, col.a or 255)
    end
    return Color(255, 255, 255)
end

local function colorToHex(col)
    col = normalizeColor(col)
    return string.format("#%02X%02X%02X", col.r, col.g, col.b)
end
local function ShowCharactersInfo(get_acc, chr)
    local frame = PANEL_ADMIN_FUNC
    local w, h = frame:GetWide(), frame:GetTall()
    
    if IsValid(get_acc) then get_acc:Remove() end
    if IsValid(show_info) then show_info:Remove() end
    if IsValid(searchPanel) then searchPanel:Remove() end
    if IsValid(RESET_ALL_B) then RESET_ALL_B:Remove() end
    if IsValid(ADD_CHAR_B) then ADD_CHAR_B:Remove() end
    if IsValid(characterListContainer) then characterListContainer:Remove() end
    
    local char_table = dbt.chr[chr]
    local old_name = chr
	char_table.color = normalizeColor(char_table.color)
    
    -- Helper function to create section headers
    local function CreateSectionHeader(x, y, width, text)
        local header = vgui.Create("DPanel", frame)
        header:SetPos(weight_source(x, 1920), hight_source(y, 1080))
        header:SetSize(weight_source(width, 1920), hight_source(40, 1080))
        header:SetPaintBackground(false)
        header.Paint = function(self, w, h)
            draw.SimpleText(text, "RobotoLight_32", 0, 0, Color(143, 37, 156), TEXT_ALIGN_LEFT)
            draw.RoundedBox(0, 0, hight_source(35, 1080), w, hight_source(2, 1080), Color(70, 70, 70))
        end
        return header
    end
    
    -- Helper function to create labels
    local function CreateLabel(x, y, text)
        local label = vgui.Create("DLabel", frame)
        label:SetPos(weight_source(x, 1920), hight_source(y, 1080))
        label:SetFont("RobotoLight_24")
        label:SetTextColor(Color(200, 200, 200))
        label:SetText(text)
        label:SizeToContents()
        return label
    end
    
    -- Background and character sprite
    PANEL_ADMIN_FUNC.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 40))

        -- Title bar
        draw.RoundedBox(0, 0, 0, w, hight_source(60, 1080), Color(20, 20, 20, 200))
        draw.SimpleText("Редактирование: " .. char_table.name, "RobotoMedium_38", weight_source(20, 1920), hight_source(30, 1080), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Create two main columns for better layout
    local leftColumn = vgui.Create("DPanel", frame)
    leftColumn:SetPos(weight_source(20, 1920), hight_source(70, 1080))
    leftColumn:SetSize(weight_source(500, 1920), hight_source(800, 1080))
    leftColumn:SetPaintBackground(false)
    
    local rightColumn = vgui.Create("DPanel", frame)
    rightColumn:SetPos(weight_source(540, 1920), hight_source(70, 1080))
    rightColumn:SetSize(weight_source(500, 1920), hight_source(800, 1080))
    rightColumn:SetPaintBackground(false)
    
    -- SECTION 1: BASIC INFO (LEFT COLUMN)
    CreateSectionHeader(20, 80, 480, "Основная информация")
    
    -- Name field
    CreateLabel(30, 130, "Имя персонажа")
    local name = build_tet(weight_source(30, 1920), hight_source(155, 1080), weight_source(450, 1920), hight_source(38, 1080))
    local name_entry = name.textentry
    name_entry:SetValue(char_table.name)
    name_entry.OnValueChange = function(self, str)
        char_table.name = str
    end
    
    -- Model field
    CreateLabel(30, 205, "Путь до 3D модели")
    local model = build_tet(weight_source(30, 1920), hight_source(230, 1080), weight_source(450, 1920), hight_source(38, 1080))
    local model_entry = model.textentry
    model_entry:SetValue(char_table.model)
    model_entry.OnValueChange = function(self, str)
        char_table.model = str
    end
    
    -- SECTION 2: VISUAL SETTINGS (LEFT COLUMN)
    CreateSectionHeader(20, 280, 480, "Настройки визуала")
    
    -- Character preview
    local previewPanel = vgui.Create("DPanel", leftColumn)
    previewPanel:SetPos(weight_source(250, 1920), hight_source(270, 1080))
    previewPanel:SetSize(weight_source(220, 1920), hight_source(220, 1080))
    previewPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 200))
        
        local icon = Material("dbt/characters"..char_table.season.."/char"..char_table.char.."/char_ico_1.png", "smooth")
        if not icon:IsError() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(10, 10, w-20, h-20)
        else
            draw.SimpleText("Нет иконки", "RobotoLight_24", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Season field
    CreateLabel(30, 330, "Сезон")
    season = CrateMonoButton(weight_source(30, 1920), hight_source(355, 1080), weight_source(190, 1920), hight_source(38, 1080), frame, "", function()
        local m = DermaMenu()
        local files, directories = file.Find("materials/dbt/characters*", "GAME")
        for k, i in pairs(directories) do
            m:AddOption(string.TrimLeft(i, "characters"), function()
                char_table.season = string.TrimLeft(i, "characters")
                season.val = string.TrimLeft(i, "characters")
            end)
        end
        m:Open()
    end, true)
    season.val = char_table.season
    season.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
        draw.SimpleText(self.val, "RobotoLight_26", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Character ID field
    CreateLabel(30, 405, "Персонаж")
    id_char = CrateMonoButton(weight_source(30, 1920), hight_source(430, 1080), weight_source(190, 1920), hight_source(38, 1080), frame, "", function()
        local m = DermaMenu()
        local files, directories = file.Find("materials/dbt/characters"..char_table.season.."/*", "GAME")
        for k, i in pairs(directories) do
            m:AddOption(i, function()
                char_table.char = string.TrimLeft(i, "char")
                id_char.val = string.TrimLeft(i, "char")
                
                local files, directories = file.Find("materials/dbt/characters"..char_table.season.."/char"..id_char.val.."/ct_sprite_*", "GAME")
                sprites_count.val = #files
                char_table.emote = #files
            end)
        end
        m:Open()
    end, true)
    id_char.val = char_table.char
    id_char.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
        draw.SimpleText(self.val, "RobotoLight_26", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Sprite count field
    CreateLabel(30, 480, "Количество спрайтов")
    sprites_count = CrateMonoButton(weight_source(30, 1920), hight_source(505, 1080), weight_source(190, 1920), hight_source(38, 1080), frame, "", function() end, true)
    sprites_count.val = char_table.emote
    sprites_count.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
        draw.SimpleText(self.val, "RobotoLight_26", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- SECTION 3: CHARACTER PROPERTIES (RIGHT COLUMN)
    CreateSectionHeader(540, 80, 480, "Свойства персонажа")
    
    -- Properties scrollable panel
    local scroll = vgui.Create("DScrollPanel", rightColumn)
    scroll:SetPos(weight_source(0, 1920), hight_source(70, 1080))
    scroll:SetSize(weight_source(480, 1920), hight_source(600, 1080))
    
    -- Style the scrollbar
    local scrollBar = scroll:GetVBar()
    scrollBar:SetWide(weight_source(8, 1920))
    function scrollBar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 30))
    end
    function scrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(143, 37, 156, 80))
        if self.Hovered then draw.RoundedBox(4, 0, 0, w, h, Color(143, 37, 156, 120)) end
        if self.Depressed then draw.RoundedBox(4, 1, 1, w-2, h-2, Color(160, 50, 170, 200)) end
    end
    function scrollBar.btnUp:Paint(w, h) end
    function scrollBar.btnDown:Paint(w, h) end
    
    -- Organize properties into categories
    local categories = {
        ["Базовые"] = {},
        ["Характеристики"] = {},
        ["Настройки"] = {},
        ["Прочее"] = {}
    }
    
    -- Categorize properties
    local sortedKeys = {}
    for k, v in pairs(char_table) do
        local includeProperty = (k == "color") or not istable(v)
        if includeProperty and k ~= "name" and k ~= "model" and k ~= "char" and k ~= "season" and k ~= "emote" then
            table.insert(sortedKeys, k)
            
            -- Assign to categories (this is an example, adjust as needed)
            if k == "absl" or k == "ultimate" or k == "gender" or k == "color" then
                categories["Базовые"][k] = v
            elseif k == "food" or k == "water" or k == "sleep" or k == "stamina" then
                categories["Характеристики"][k] = v
            elseif k == "npc" or k == "enable" or k == "disabled" then
                categories["Настройки"][k] = v
            else
                categories["Прочее"][k] = v
            end
        end
    end
    
    -- Create properties UI
    local yPos = 0
    for categoryName, props in pairs(categories) do
        -- Only show categories with properties
        if table.Count(props) > 0 then
            -- Category header
            local categoryPanel = vgui.Create("DPanel", scroll)
            categoryPanel:SetPos(0, yPos)
            categoryPanel:SetSize(weight_source(480, 1920), hight_source(36, 1080))
            categoryPanel:SetPaintBackground(false)
            categoryPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(143, 37, 156, 50))
                draw.SimpleText(categoryName, "RobotoMedium_24", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            yPos = yPos + hight_source(40, 1080)
            
            -- Sort properties alphabetically
            local catKeys = {}
            for k in pairs(props) do table.insert(catKeys, k) end
            table.sort(catKeys)
            
            -- Create property rows
            for _, k in ipairs(catKeys) do
                local i = props[k]
                
                local row = vgui.Create("DPanel", scroll)
                row:SetPos(0, yPos)
                row:SetSize(weight_source(480, 1920), hight_source(38, 1080))
                row:SetPaintBackground(false)
                
                -- Property name
                local displayName = acb[k] or k -- Use friendly name if available
                local dataNamePanel = vgui.Create("DPanel", row)
                dataNamePanel:SetPos(0, 0)
                dataNamePanel:SetSize(weight_source(220, 1920), hight_source(38, 1080))
                dataNamePanel.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
                    draw.SimpleText(displayName, "RobotoLight_24", 10, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                -- Property value
                local dataValuePanel = vgui.Create("DPanel", row)
                dataValuePanel:SetPos(weight_source(225, 1920), 0)
                dataValuePanel:SetSize(weight_source(255, 1920), hight_source(38, 1080))
                dataValuePanel.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
                end
                
                if k == "color" then
                    local colorButton = vgui.Create("DButton", dataValuePanel)
                    colorButton:Dock(FILL)
                    colorButton:DockMargin(4, 4, 4, 4)
                    colorButton:SetText("")
                    colorButton.currentColor = normalizeColor(char_table.color)
                    colorButton.hex = colorToHex(colorButton.currentColor)

                    local function applyCharacterColor(col)
                        local sanitized = normalizeColor(col)
                        char_table.color = sanitized
                        colorButton.currentColor = sanitized
                        colorButton.hex = colorToHex(sanitized)
                    end

                    local function openColorPicker()
                        if IsValid(colorButton.picker) then
                            colorButton.picker:Remove()
                        end
                        local picker = vgui.Create("DFrame")
                        picker:SetTitle("Выбор цвета")
                        picker:SetSize(weight_source(320, 1920), hight_source(280, 1080))
                        picker:Center()
                        picker:MakePopup()
                        picker:SetDeleteOnClose(true)
                        colorButton.picker = picker

                        local mixer = vgui.Create("DColorMixer", picker)
                        mixer:Dock(FILL)
                        mixer:DockMargin(10, 30, 10, 50)
                        mixer:SetPalette(true)
                        mixer:SetAlphaBar(false)
                        mixer:SetWangs(true)
                        mixer:SetColor(colorButton.currentColor)

                        local applyBtn = vgui.Create("DButton", picker)
                        applyBtn:Dock(BOTTOM)
                        applyBtn:DockMargin(10, 0, 10, 10)
                        applyBtn:SetTall(30)
                        applyBtn:SetText("Сохранить цвет")
                        applyBtn.DoClick = function()
                            local selected = mixer:GetColor()
                            applyCharacterColor(selected)
                            picker:Close()
                        end
                    end

                    colorButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 220))
                        draw.RoundedBox(4, 4, 4, w - 8, h - 8, self.currentColor)
                        draw.SimpleText(self.hex or "#FFFFFF", "RobotoLight_20", w - 10, h / 2, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("Нажмите, чтобы выбрать", "RobotoLight_18", 10, h / 2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end

                    colorButton.DoClick = openColorPicker
                elseif isbool(i) then
                    local boolSelector = vgui.Create("DComboBox", dataValuePanel)
                    boolSelector:SetPos(5, 4)
                    boolSelector:SetSize(weight_source(245, 1920), hight_source(30, 1080))
                    boolSelector:SetFont("RobotoLight_22")
                    boolSelector:SetSortItems(false)
                    boolSelector:AddChoice("Да", true)
                    boolSelector:AddChoice("Нет", false)
                    boolSelector:SetValue(i and "Да" or "Нет")
                    boolSelector:SetTextColor(color_white)

                    boolSelector.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 220))
                        draw.SimpleText(self:GetValue(), "RobotoLight_22", 10, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        return true
                    end

                    boolSelector.OnSelect = function(self, _, value, data)
                        char_table[k] = tobool(data ~= nil and data or value == "Да")
                        self:SetValue(value)
                    end
                else
                    local TextEntry = vgui.Create("DTextEntry", dataValuePanel)
                    TextEntry:SetPos(5, 0)
                    TextEntry:SetSize(weight_source(245, 1920), hight_source(38, 1080))
                    TextEntry:SetPaintBackground(false)
                    TextEntry:SetText(tostring(i))
                    TextEntry:SetFont("RobotoLight_24")
                    TextEntry:SetPlaceholderColor(Color(200, 200, 200, 100))
                    TextEntry:SetTextColor(color_white)
                    TextEntry:SetUpdateOnType(true)
					
                    TextEntry.OnValueChange = function(self, val)
                        if isnumber(i) then
                            local parsed = tonumber(val)
                            if parsed ~= nil then
                                char_table[k] = parsed
                            end
                        else
                            char_table[k] = tostring(val)
                        end
                    end
                end
                
                yPos = yPos + hight_source(42, 1080)
            end
        end
    end
    
    -- FOOTER BUTTONS
    -- Back button
    local backButton = CrateMonoButton(weight_source(866, 1920), hight_source(15, 1080), weight_source(247, 1920), hight_source(51, 1080), frame, "◀ Назад", function()
        local w, h = ScrW() * 0.8, ScrH() * 0.7
        if IsValid(PANEL_ADMIN_FUNC) then PANEL_ADMIN_FUNC:Remove() end
        PANEL_ADMIN_FUNC = vgui.Create("DPanel", admin_frame)
        PANEL_ADMIN_FUNC:SetPos(w * 0.25 + 5, h * 0.05 + 10)
        PANEL_ADMIN_FUNC:SetSize(w * .75 - 10, h)
        PANEL_ADMIN_FUNC.Paint = function(self, w, h)
            if dbt.AdminFunc["edit_characters"].PaintAdv then
                dbt.AdminFunc["edit_characters"].PaintAdv(self, w, h)
            end
        end
        dbt.AdminFunc["edit_characters"].build(PANEL_ADMIN_FUNC)
    end, true)
    
    -- Action buttons panel
    local actionPanel = vgui.Create("DPanel", frame)
    actionPanel:SetPos(weight_source(20, 1920), hight_source(600, 1080))
    actionPanel:SetSize(weight_source(820, 1920), hight_source(49, 1080))
    actionPanel:SetPaintBackground(false)
    
    -- Reset button
    local resetButton = CrateMonoButton(weight_source(0, 1920), hight_source(0, 1080), weight_source(150, 1920), hight_source(49, 1080), actionPanel, "СБРОСИТЬ", function()
        Derma_Query(
            "Вы уверены, что хотите сбросить этого персонажа?",
            "Подтверждение сброса",
            "Да, сбросить",
            function()
                netstream.Start("dbt/characters/reset", chr)
                local w, h = ScrW() * 0.8, ScrH() * 0.7
                if IsValid(PANEL_ADMIN_FUNC) then PANEL_ADMIN_FUNC:Remove() end
                PANEL_ADMIN_FUNC = vgui.Create("DPanel", admin_frame)
                PANEL_ADMIN_FUNC:SetPos(w * 0.25 + 5, h * 0.05 + 10)
                PANEL_ADMIN_FUNC:SetSize(w * .75 - 10, h)
                PANEL_ADMIN_FUNC.Paint = function(self, w, h)
                    if dbt.AdminFunc["edit_characters"].PaintAdv then
                        dbt.AdminFunc["edit_characters"].PaintAdv(self, w, h)
                    end
                end
                dbt.AdminFunc["edit_characters"].build(PANEL_ADMIN_FUNC)
            end,
            "Отмена",
            function() end
        )
    end, true)
    resetButton.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(120, 30, 30, 200))
        draw.SimpleText("Сбросить", "text1", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Apply button
    local applyButton = CrateMonoButton(weight_source(160, 1920), hight_source(0, 1080), weight_source(150, 1920), hight_source(49, 1080), actionPanel, "ПРИМЕНИТЬ", function()
        save_character(char_table, chr)
        
        local flash = vgui.Create("DPanel", actionPanel)
        flash:SetPos(weight_source(562, 1920), hight_source(0, 1080))
        flash:SetSize(weight_source(258, 1920), hight_source(49, 1080))
        flash:SetAlpha(80)
        flash.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 255, 0, self:GetAlpha()))
        end
        flash:AlphaTo(0, 0.5, 0, function() flash:Remove() end)
    end, true)
    applyButton.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 120, 30, 200))
        draw.SimpleText("Применить", "text1", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
end

local function BuildEditCH(tabl, w, h)
    local y = hight_source(9, 1080)

    table.sort(tabl, function(a, b) 
        return string.lower(dbt.chr[a].name) < string.lower(dbt.chr[b].name)
    end)
    
    for k, characterID in pairs(tabl) do
        local character = dbt.chr[characterID]
        if not character then continue end
        
        local characterButton = vgui.Create("DButton", get_acc)
        get_acc.tbl[#get_acc.tbl + 1] = characterButton
        characterButton:SetText("")
        characterButton:SetPos(5, y)
        characterButton:SetSize(weight_source(614, 1080), h * 0.1)
        characterButton.characterID = characterID
        characterButton.character = character
        
        characterButton.hoverAlpha = 0
        characterButton.isSelected = false
        
        characterButton.Paint = function(self, w, h)
            local bgColor = Color(0, 0, 0, (255 / 100) * 70)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)

            if self:IsHovered() or self.isSelected then
                self.hoverAlpha = math.min(self.hoverAlpha + 10, 255)
            else
                self.hoverAlpha = math.max(self.hoverAlpha - 10, 0)
            end
            
            local accentColor = Color(
                143, 37, 156, 
                50 + (205 * self.hoverAlpha / 255)
            )
            draw.RoundedBox(0, 0, 0, 4, h, accentColor)
            
            draw.DrawText(
                character.name, 
                "RobotoMedium_30", 
                w * 0.07, 
                h * 0.2, 
                color_white, 
                TEXT_ALIGN_LEFT
            )
            -- 0 1
            local material2 = Material("dbt/characters"..character.season.."/char"..character.char.."/char_ico_1.png", "smooth")
            if material2:IsError() then
                material2 = Material("dbt/characters0/char1/char_ico_1.png", "smooth")
            end
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( material2 )
            surface.DrawTexturedRect( dbtPaint.WidthSource(10), dbtPaint.HightSource(3), h - dbtPaint.HightSource(5), h - dbtPaint.HightSource(5))
        
            
            if self.isSelected then
                draw.RoundedBox(0, w - 6, 0, 6, h, Color(143, 37, 156))
            end
            
            draw.RoundedBox(0, 10, h - 1, w - 20, 1, Color(60, 60, 60, 100))
        end
        
        characterButton.DoClick = function(self)
            for _, btn in pairs(get_acc.tbl) do
                btn.isSelected = false
            end
            
            self.isSelected = true
            
            surface.PlaySound("ui/buttonclick.wav")
            
            ShowCharactersInfo(get_acc, self.characterID)
        end
        
        characterButton:SetTooltip("Нажмите для редактирования персонажа: " .. character.name)
        
        y = y + h * 0.1 + weight_source(6, 1080)
    end
    
    if #get_acc.tbl == 0 then
        local noCharactersLabel = vgui.Create("DLabel", get_acc)
        noCharactersLabel:SetPos(weight_source(100, 1920), hight_source(100, 1080))
        noCharactersLabel:SetFont("RobotoLight_32")
        noCharactersLabel:SetText("Персонажи не найдены")
        noCharactersLabel:SetTextColor(Color(200, 200, 200))
        noCharactersLabel:SizeToContents()
        
        get_acc.tbl[1] = noCharactersLabel -- Add to table to prevent empty state message
    end
end

dbt.AdminFunc["edit_characters"] = {
    name = "Изменение персонажей",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        
        -- Header with search functionality
        searchPanel = vgui.Create("DPanel", frame)
        searchPanel:SetPos(weight_source(15, 1920), hight_source(19, 1080))
        searchPanel:SetSize(weight_source(1101, 1920), hight_source(48, 1080))
        searchPanel:SetPaintBackground(false)
        
        searchPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
            
            -- Add subtle highlight effect when search box is active
            if self.SearchActive then
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(148, 21, 150, 10))
                draw.RoundedBox(4, 0, 0, w, 2, Color(143, 37, 156, 120))
            end
        end
        
        searchIcon = vgui.Create("DImage", searchPanel)
        searchIcon:SetPos(weight_source(15, 1920), hight_source(14, 1080))
        searchIcon:SetSize(weight_source(20, 1920), hight_source(20, 1080))
        searchIcon:SetImage("icon16/magnifier.png")
        
        character_list_search = vgui.Create("DTextEntry", searchPanel)
        character_list_search:SetPos(weight_source(45, 1920), hight_source(6, 1080))
        character_list_search:SetSize(weight_source(1045, 1920), hight_source(36, 1080))
        character_list_search:SetFont("RobotoLight_32")
        character_list_search:SetPlaceholderColor(Color(200, 200, 200, 100))
        character_list_search:SetPaintBackground(false)
        character_list_search:SetTextColor(color_white)
        character_list_search:SetPlaceholderText("Поиск персонажей...")
        
        character_list_search.OnGetFocus = function()
            searchPanel.SearchActive = true
        end
        
        character_list_search.OnLoseFocus = function()
            searchPanel.SearchActive = false
        end
        
        character_list_search.OnEnter = function(self)
            -- Clear existing character list
            get_acc:GetCanvas():Clear()
            get_acc.tbl = {}
            
            -- Search logic
            local searchText = string.lower(self:GetValue())
            local filteredCharacters = {}
            
            if searchText == "" then
                -- Show all characters if search is empty
                filteredCharacters = table.Copy(DBT_CHAR_SORTED)
            else
                -- Filter characters based on search
                for _, characterName in pairs(DBT_CHAR_SORTED) do
                    if string.find(string.lower(characterName), searchText) then
                        table.insert(filteredCharacters, characterName)
                    end
                end
            end
            
            -- Update character list
            local effectiveWidth = w - 30
            local effectiveHeight = h * 0.8 - 30
            BuildEditCH(filteredCharacters, effectiveWidth, effectiveHeight)
            
            -- Show search results count with animation
            local resultCount = #filteredCharacters
            local resultText = "Найдено: " .. resultCount .. " персонажей"
            
            local resultLabel = vgui.Create("DLabel", searchPanel)
            resultLabel:SetPos(weight_source(800, 1920), hight_source(14, 1080))
            resultLabel:SetFont("RobotoLight_20")
            resultLabel:SetText(resultText)
            resultLabel:SetTextColor(Color(200, 200, 200))
            resultLabel:SizeToContents()
            resultLabel:SetAlpha(0)
            resultLabel:AlphaTo(255, 0.3, 0)
            
            timer.Simple(2, function()
                if IsValid(resultLabel) then
                    resultLabel:AlphaTo(0, 0.5, 0, function()
                        if IsValid(resultLabel) then
                            resultLabel:Remove()
                        end
                    end)
                end
            end)
        end
        
        -- Character list container
        characterListContainer = vgui.Create("DPanel", frame)
        characterListContainer:SetPos(weight_source(15, 1920), hight_source(82, 1080))
        characterListContainer:SetSize(weight_source(1101, 1920), hight_source(587, 1080))
        characterListContainer.Paint = function(self, w, h)
            -- Improved visual styling
            draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
            draw.RoundedBox(4, 1, 1, w-2, h-2, Color(0, 0, 0, 40))
            
            -- Empty state message
            if not IsValid(get_acc) or #get_acc.tbl == 0 then
                draw.SimpleText("Персонажи не найдены", "RobotoLight_32", w/2, h/2 - 20, Color(200, 200, 200, 100), TEXT_ALIGN_CENTER)
                draw.SimpleText("Попробуйте изменить параметры поиска", "RobotoLight_24", w/2, h/2 + 20, Color(180, 180, 180, 80), TEXT_ALIGN_CENTER)
            end
        end
        
        -- Create scrollable character list
        get_acc = vgui.Create("DScrollPanel", characterListContainer)
        get_acc:SetPos(weight_source(10, 1920), hight_source(10, 1080))
        get_acc:SetSize(weight_source(1081, 1920), hight_source(567, 1080))
        get_acc.tbl = {}
        
        -- Style the scrollbar
        local scrollBar = get_acc:GetVBar()
        scrollBar:SetWide(weight_source(8, 1920))
        
        function scrollBar:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 60))
        end
        
        function scrollBar.btnGrip:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(143, 37, 156, 120))
            
            if self.Hovered then
                draw.RoundedBox(4, 0, 0, w, h, Color(143, 37, 156, 180))
            end
            
            if self.Depressed then
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(160, 50, 170, 255))
            end
        end
        
        function scrollBar.btnUp:Paint(w, h) end
        function scrollBar.btnDown:Paint(w, h) end
        
        -- Initialize character list
        local effectiveWidth = w - 30
        local effectiveHeight = h * 0.8 - 30
        BuildEditCH(DBT_CHAR_SORTED, effectiveWidth, effectiveHeight)
        

        ADD_CHAR_B = CrateMonoButton(
            15, 686, 140, 50,
            frame,
            "Добавить",
            function() 
                netstream.Start("dbt/characters/createnew")
            end,
            true
        )
        
        RESET_ALL_B = CrateMonoButton(
            160, 686, 140, 50,
            frame,
            "Сброс",
            function()
                -- Confirmation dialog
                Derma_Query(
                    "Вы уверены, что хотите сбросить все изменения персонажей?\nЭто действие нельзя отменить.",
                    "Подтверждение сброса",
                    "Да, сбросить всё",
                    function()
                        netstream.Start("dbt/characters/resetall")
                    end,
                    "Отмена",
                    function() end
                )
            end
        )
        local y2 = 686
        local function B(x, text, fn)
            return CrateMonoButton(weight_source(x, 1920), hight_source(y2, 1080), weight_source(200, 1920), hight_source(50, 1080), frame, text, fn, true)
        end
        local savePreset = B(305, "Сохранить", function()
            Derma_StringRequest("Имя пресета", "Введите имя пресета", "preset", function(str)
                local selected = {}
                for _,btn in pairs(get_acc.tbl or {}) do if btn.isSelected then selected[#selected+1] = btn.characterID end end
                if #selected == 0 then selected = nil end
                netstream.Start("dbt/characters/preset/save", str, selected)
            end)
        end)
        local loadPreset = B(510, "Загрузить", function()
            CHAR_PRESET_LIST_CALLBACK = function(list)
                local m = DermaMenu()
                for _,id in ipairs(list) do
                    local sub = m:AddSubMenu(id)
                    sub:AddOption("Соеденить", function() netstream.Start("dbt/characters/preset/load", id, "merge") end)
                    sub:AddOption("Заменить", function() netstream.Start("dbt/characters/preset/load", id, "replace") end)
                    sub:AddOption("Скачать", function() netstream.Start("dbt/characters/preset/download", id) end)
                end
                m:Open()
            end
            netstream.Start("dbt/characters/preset/list")
        end)
        local uploadPreset = B(715, "Импорт", function()
            local files = file.Find("dbt/characters_client/presets/*.json", "DATA")
            if #files == 0 then return end
            local m = DermaMenu()
            for _,f in ipairs(files) do
                m:AddOption(f, function()
                    local data = file.Read("dbt/characters_client/presets/"..f, "DATA") or ""
                    if data ~= "" then
                        net.Start("dbt/characters/preset/upload")
                        net.WriteStream(data, function() end)
                        net.SendToServer()
                    end
                end)
            end
            m:Open()
        end)
        RESET_ALL_B.OnRemove = function()
            savePreset:Remove()
            loadPreset:Remove()
            uploadPreset:Remove()
        end
        --local saveSingle = B(825, "Сохранить персонажа", function()
        --    for _,btn in pairs(get_acc.tbl or {}) do if btn.isSelected then netstream.Start("dbt/characters/single/save", btn.characterID) return end end
        --end)
        --y2 = 792
        --local loadSingle = B(15, "Загрузить персонажа", function()
        --    CHAR_SINGLE_LIST_CALLBACK = function(list)
        --        local m = DermaMenu()
        --        for _,id in ipairs(list) do
        --            m:AddOption(id, function() netstream.Start("dbt/characters/single/load", id) end)
        --        end
        --        m:Open()
        --    end
        --    netstream.Start("dbt/characters/single/list")
        --end)
        --local downloadSingle = B(285, "Скачать персонажа", function()
        --    CHAR_SINGLE_LIST_CALLBACK = function(list)
        --        local m = DermaMenu()
        --        for _,id in ipairs(list) do
        --            m:AddOption(id, function() netstream.Start("dbt/characters/single/download", id) end)
        --        end
        --        m:Open()
        --    end
        --    netstream.Start("dbt/characters/single/list")
        --end)
        --local uploadSingle = B(555, "Импорт персонажа", function()
        --    local files = file.Find("dbt/characters_client/single/*.json", "DATA")
        --    if #files == 0 then return end
        --    local m = DermaMenu()
        --    for _,f in ipairs(files) do
        --        m:AddOption(f, function()
        --            local data = file.Read("dbt/characters_client/single/"..f, "DATA") or ""
        --            if data ~= "" then
        --                net.Start("dbt/characters/single/upload")
        --                net.WriteStream(data, function() end)
        --                net.SendToServer()
        --            end
        --        end)
        --    end
        --    m:Open()
        --end)
        --local reloadChars = B(825, "Обновить список", function()
        --    get_acc:GetCanvas():Clear() get_acc.tbl = {} BuildEditCH(DBT_CHAR_SORTED, effectiveWidth, effectiveHeight)
        --end)
        
    end,
    
    PaintAdv = function(self, w, h)
      
        draw.RoundedBox(0, w/2 - weight_source(200, 1920), hight_source(10, 1080), weight_source(400, 1920), hight_source(50, 1080), Color(0, 0, 0, 30))

    end
}

netstream.Hook("dbt/characters/preset/list", function(list) if CHAR_PRESET_LIST_CALLBACK then CHAR_PRESET_LIST_CALLBACK(list) CHAR_PRESET_LIST_CALLBACK=nil end end)
netstream.Hook("dbt/characters/single/list", function(list) if CHAR_SINGLE_LIST_CALLBACK then CHAR_SINGLE_LIST_CALLBACK(list) CHAR_SINGLE_LIST_CALLBACK=nil end end)