local PANEL_ADMIN_FUNC = PANEL_ADMIN_FUNC 
local admin_frame = admin_frame 

local COLORS = {
    white = Color(255, 255, 255),
    mono_button = Color(50, 50, 50, 200),
    mono_button_hover = Color(70, 70, 70, 200),
    mono_button_active = Color(90, 90, 90, 200),
    panel_outline = Color(30, 30, 30, 200),
    panel_background = Color(10, 10, 10, 150),
    dropdown_background = Color(20, 20, 20, 150),
    placeholder_text = Color(200, 200, 200, 100),
    frame_background = Color(0, 0, 0, 40),
    header_background = Color(20, 20, 20, 200),
    label_text = Color(200, 200, 200),
    disabled_text = Color(150, 150, 150),
    scroll_track = Color(0, 0, 0, 60),
    scroll_grip = Color(143, 37, 156, 120),
    accent = Color(143, 37, 156),
    button_success = Color(30, 120, 30, 200),
    button_success_hover = Color(40, 150, 40, 220),
    button_success_active = Color(50, 170, 50, 240),
    button_delete = Color(120, 30, 30, 200),
    button_delete_hover = Color(150, 40, 40, 220),
    button_delete_active = Color(170, 50, 50, 240),
    divider = Color(60, 60, 60, 100),
    list_background = Color(148, 21, 150, 36), -- (255 / 100) * 14
    item_background = Color(0, 0, 0, 178)      -- (255 / 100) * 70
}

local color_white = Color(255, 255, 255)
local monobuttons_1 = Color(148, 21, 150, (255 / 100) * 14)

local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a * x
end


local function hight_source(x, custom)
    local a = custom or 1080
    return ScrH() / a * x
end

local function colorInvert(color)
    return Color(255 - color.r, 255 - color.g, 255 - color.b, color.a)
end

local searchOnlyCustom = false

local function FilterItems(searchText)
    local s = string.lower(tostring(searchText or ""))
    local onlyCustom = not not searchOnlyCustom
    local category = (searchCategory ~= "all") and searchCategory or nil

    local out = {}
    for id, data in pairs(dbt.inventory.items) do
        -- Поиск по ID или названию (plain find)
        local matchesSearch =
            (s == "") or
            string.find(string.lower(tostring(id)), s, 1, true) or
            (data.name and string.find(string.lower(data.name), s, 1, true)) or
            false

        -- Фильтр по категории
        local matchesCategory = (not category) or (data[category] and data[category] ~= 0 and data[category] ~= "")

        -- Фильтр "только отредактированные"
        local editedFlag = data.edited
        if isstring(editedFlag) then
            local lowered = string.lower(editedFlag)
            editedFlag = (lowered == "true" or lowered == "1" or lowered == "yes")
        end
        if not editedFlag then
            editedFlag = tonumber(data.edited) and tonumber(data.edited) ~= 0 or false
        end

        local matchesCustom = (not onlyCustom) or editedFlag

        if matchesSearch and matchesCategory and matchesCustom then
            out[#out + 1] = id
        end
    end
    return out
end

local function build_combo(x, y, w, h, parent, options, default)
    parent = parent or PANEL_ADMIN_FUNC
    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(x, y)
    panel:SetSize(w, h)
    panel.Paint = function(self, w_paint, h_paint) 
        draw.RoundedBox(4, 0, 0, w_paint, h_paint, Color(30,30,30,200))
        draw.RoundedBox(4, 1, 1, w_paint-2, h_paint-2, Color(10,10,10,150))
    end

    local comboBox = vgui.Create("DComboBox", panel)
    comboBox:SetPos(5, 0)
    comboBox:SetSize(w - 10, h)
    comboBox:SetFont("RobotoLight_24")
    comboBox:SetTextColor(color_white)
    comboBox:SetValue(default or "")
    
    -- Add options if provided
    if options and type(options) == "table" then
        for k, v in pairs(options) do
            if type(k) == "number" then
                comboBox:AddChoice(v)
            else
                comboBox:AddChoice(k, v)
            end
        end
    end
    
    -- Style the dropdown
    comboBox.Paint = function(self, w_combo, h_combo)
        draw.RoundedBox(4, 0, 0, w_combo, h_combo, Color(20,20,20,150))
    end
    
    panel.combobox = comboBox
    return panel
end

local function build_tet(x, y, w, h, parent)
    parent = parent or PANEL_ADMIN_FUNC
    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(x, y)
    panel:SetSize(w, h)
    panel.Paint = function(self, w_paint, h_paint) 
        draw.RoundedBox(4, 0, 0, w_paint, h_paint, Color(30,30,30,200))
        draw.RoundedBox(4, 1, 1, w_paint-2, h_paint-2, Color(10,10,10,150))
    end

    local textEntry = vgui.Create("DTextEntry", panel)
    textEntry:SetPos(5, 0)
    textEntry:SetSize(w - 10, h)
    textEntry:SetFont("RobotoLight_24") 
    textEntry:SetPaintBackground(false)
    textEntry:SetTextColor(color_white)
    textEntry:SetPlaceholderColor(Color(200, 200, 200, 100))
    textEntry:SetUpdateOnType(true)
    
    panel.textentry = textEntry
    return panel
end


local function CrateMonoButton(x, y, w, h, parent, text, func, unknownBool)
    parent = parent or PANEL_ADMIN_FUNC
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x,y)
    btn:SetSize(w,h)
    btn:SetText("") 
    btn.txt = text
    btn.DoClick = func or function() end
    btn.Paint = function(self, w_paint, h_paint) 
        local bgColor = monobuttons_1
        if self:IsHovered() then bgColor = Color(70,70,70,200) end
        if self:IsDown() then bgColor = Color(90,90,90,200) end
        draw.RoundedBox(4, 0, 0, w_paint, h_paint, bgColor)
        draw.SimpleText(self.txt, "RobotoLight_24", w_paint/2, h_paint/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Ensure font is loaded
    end
    btn.hoverAlpha = 0 
    return btn
end


local currentEditItemPanel = nil
local itemSearchPanel = nil
local itemAddButton = nil
local itemListContainer = nil
local itemsScrollPanel = nil 
local itemPreviewModel = nil

local function save_item_data(itemId, itemData)
    if not itemId or not itemData then
        return 
    end
    itemData.icon = nil
    local description = itemData.description or ""
    if itemData.GetDescription and description == "" then
        description = ""
        local oldText = itemData:GetDescription({})
        for k, i in pairs(oldText) do
            if type(i) == "string"  then
                description = description .." ".. i
            end
        end
    end
    itemData.GetDescription = nil
    itemData.description = description
    
    -- Медицина
    local IsMedicine = itemData.medicine or false
    if IsMedicine then
        local str = itemData.medicine
        local medicineAdd = "" 
        if str == "Аптечка" then
            str = "medicineАптечка"
            medicineAdd = itemData.Heal or 25
        elseif str == "Хирургический набор" then
            str = "medicineХирургическийнабор"
        else 
            str = "medicine"
            medicineAdd = itemData.Wound or "Ушиб"
        end

        itemData.medicinefunction = str
        itemData.medicineAdd = medicineAdd
        itemData.OnUse = nil
    end
    itemData.edited = true
    dbt.inventory.items[itemId] = itemData
    netstream.Start("dbt/items/save", itemId, itemData)
end

local function delete_item_data(itemId)
    if not itemId then
        return
    end
    Derma_Query(
        "Вы уверены, что хотите удалить этот предмет: " .. (dbt.inventory.items[itemId] and dbt.inventory.items[itemId].name or itemId) .. "?\nЭто действие нельзя отменить.",
        "Подтверждение удаления",
        "Да, удалить",
        function()
            netstream.Start("dbt/items/delete", itemId)
            if IsValid(PANEL_ADMIN_FUNC) then
                dbt.AdminFunc["edit_items"].build(PANEL_ADMIN_FUNC)
            end
        end,
        "Отмена",
        function() end
    )
end

local function UpdateItemPreviewPanel(modelPanel, modelPath, itemAngle, itemFov)
    if not IsValid(modelPanel) then return end
    if not modelPath or modelPath == "" then
        --modelPanel:SetModel(nil)
        return
    end

    modelPanel:SetModel(modelPath)
    local ent = modelPanel.Entity
    if not IsValid(ent) then return end

    -- Allow DModelPanel to set up its camera, or do it manually
    -- For simplicity, let DModelPanel handle it initially.
    -- If more control is needed, similar to cl_ditem.lua:
    timer.Simple(0.01, function() -- Delay to ensure entity is spawned and bounds are available
        if not IsValid(ent) then return end
        local mn, mx = ent:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        size = math.max(size, 0.1) -- Minimum size

        modelPanel:SetFOV(tonumber(itemFov) or 45)
        modelPanel:SetCamPos(Vector(size, size, size) * 1.3) -- Adjust multiplier as needed
        modelPanel:SetLookAt((mn + mx) * 0.5)
        ent:SetAngles(itemAngle or Angle(0,0,0))
    end)
    modelPanel.LayoutEntity = function(s, e) end -- Basic override to prevent default layout if using manual cam
end


local function ShowItemInfo(itemId, _currentUnsavedData)
    local frame = PANEL_ADMIN_FUNC
    if not IsValid(frame) then return end
    local w, h = frame:GetWide(), frame:GetTall()

    -- Clear previous panels specific to item editing or list
    if IsValid(currentEditItemPanel) then currentEditItemPanel:Remove() currentEditItemPanel = nil end
    if IsValid(itemSearchPanel) then itemSearchPanel:Remove() itemSearchPanel = nil end
    // if IsValid(itemResetAllButton) then itemResetAllButton:Remove() itemResetAllButton = nil end
    if IsValid(itemAddButton) then itemAddButton:Remove() itemAddButton = nil end
    if IsValid(itemListContainer) then itemListContainer:Remove() itemListContainer = nil end
    if IsValid(itemsScrollPanel) then itemsScrollPanel:Remove() itemsScrollPanel = nil end
    if IsValid(itemPreviewModel) then itemPreviewModel:Remove() itemPreviewModel = nil end
    if IsValid(presetsButton) then presetsButton:Remove() end
    if IsValid(SavepresetButton) then SavepresetButton:Remove() end
    if IsValid(reloadQMenuButton) then reloadQMenuButton:Remove() end
    if IsValid(itemFilterCombo) then itemFilterCombo:Remove() end
    if IsValid(isCustomCheck) then isCustomCheck:Remove() end


    currentEditItemPanel = vgui.Create("DPanel", frame)
    currentEditItemPanel:SetPos(0,0)
    currentEditItemPanel:SetSize(w,h)
    currentEditItemPanel:SetPaintBackground(false)

    local itemData
    if _currentUnsavedData then
        itemData = table.Copy(_currentUnsavedData) -- Use provided data if available (e.g. after adding a field)
    else
        itemData = table.Copy(dbt.inventory.items[itemId] or {})
    end
    
    local originalItemId = itemId 

    local isNewItem = not dbt.inventory.items[itemId]
    if isNewItem and not _currentUnsavedData then -- Only init defaults if truly new and not a refresh
        itemData.name = "Новый предмет"
        itemData.mdl = ""
        itemData.icon = ""
        itemData.angle = Angle(0,0,0)
        itemData.fov = 45
        -- Initialize other default fields if necessary
    end

    currentEditItemPanel.Paint = function(self, pW, pH)
        draw.RoundedBox(0, 0, 0, pW, pH, Color(0, 0, 0, 40))
        draw.RoundedBox(0, 0, 0, pW, hight_source(60, 1080), Color(20, 20, 20, 200))
        draw.SimpleText((isNewItem and "Создание предмета" or "Редактирование: " .. (itemData.name or "Без имени")), "RobotoMedium_38", weight_source(20, 1920), hight_source(30, 1080), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local topOffsetY = hight_source(70, 1080)
    local propertiesWidth = w * 0.58 - weight_source(30, 1920)
    local previewWidth = w * 0.4 - weight_source(30, 1920)
    local previewX = weight_source(20, 1920) + propertiesWidth + weight_source(10, 1920)

    itemPreviewModel = vgui.Create("DModelPanel", currentEditItemPanel)
    itemPreviewModel:SetPos(previewX, topOffsetY)
    itemPreviewModel:SetSize(previewWidth, h - topOffsetY - hight_source(80, 1080)) // Same bottom margin as scroll
    itemPreviewModel.PaintOver = function(self_mp, pW, pH)
        draw.RoundedBox(4,0,0,pW,pH,Color(10,10,10,150))
        if not IsValid(self_mp.Entity) or not self_mp.Entity:GetModel() or self_mp.Entity:GetModel() == "" then
            draw.SimpleText("Нет модели", "RobotoLight_24", pW/2, pH/2, Color(150,150,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov)


    local propertiesScroll = vgui.Create("DScrollPanel", currentEditItemPanel)
    propertiesScroll:SetPos(weight_source(20, 1920), topOffsetY)
    propertiesScroll:SetSize(propertiesWidth, h - topOffsetY - hight_source(80, 1080)) // Adjusted for footer buttons

    local yPos = hight_source(10, 1080)
    local rowSpacing = hight_source(6, 1080)
    local russianNames = {
        name = "Название", icon = "Иконка", mdl = "Модель", kg = "Вес (кг)",
        food = "Еда", water = "Вода", time = "Время употребления (сек)", cost = "Цена",
        weapon = "Оружие", poison = "Яд", monopad = "Монопад", keys = "Ключи",
        medicine = "Лекарство", angle = "Угол", fov = "FOV",
        descalt = "Описание (alt)", color = "Цвет", bNotDeleteOnUse = "Не удалять при исп.",
        id = "ID (внутренний)", description = "Описание", spoil_time = "Время гниения (мин)"
    }
    local function CreatePropertyRow(key, value)
        local rowPanel = vgui.Create("DPanel", propertiesScroll)
        rowPanel:SetPos(0, yPos)
        rowPanel:SetSize(propertiesScroll:GetWide() - propertiesScroll:GetVBar():GetWide() - 10, hight_source(38, 1080))
        rowPanel:SetPaintBackground(false)

        local lbl = vgui.Create("DLabel", rowPanel)
        lbl:SetPos(0, 0)
        lbl:SetText(tostring(russianNames[key] or key) .. ":")
        lbl:SetFont("RobotoLight_24")
        lbl:SetTextColor(Color(200,200,200))
        lbl:SizeToContents()
        lbl:SetWide(weight_source(100, 1920))
        lbl:SetContentAlignment(5) -- Center Y

        local inputX = lbl:GetWide() + weight_source(10, 1920)
        local inputWidth = rowPanel:GetWide() - inputX

        if type(value) == "boolean" then
            local chk = vgui.Create("DCheckBoxLabel", rowPanel)
            chk:SetPos(inputX, 0)
            chk:SetText("")
            chk:SetValue(value)
            chk:SizeToContents()
            chk.OnChange = function(self, val)
                itemData[key] = val
            end
        elseif type(value) == "number" then
            local numEntry = build_tet(inputX, 0, inputWidth, hight_source(38, 1080), rowPanel)
            numEntry.textentry:SetNumeric(true)
            numEntry.textentry:SetValue(tostring(value))
            numEntry.textentry.OnValueChange = function(self, val)
                local num = tonumber(val)
                if num ~= nil then
                    itemData[key] = num
                    if key == "fov" and IsValid(itemPreviewModel) then
                        UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov)
                    end
                end
            end
        elseif key == "medicine" then
            local comboentry = build_combo(inputX, 0, inputWidth, hight_source(38, 1080), rowPanel, {"Аптечка", "Хирургический набор", "Ушиб", "Ранение", "Тяжелое ранение", "Пулевое ранение", "Перелом"}, value)
            comboentry.combobox.OnSelect = function(self, index, value)
                itemData[key] = value
                if value == "Аптечка" then
                    itemData.Heal = 25
                    CreatePropertyRow("Heal", 25)
                end
            end
        elseif key == "mdl" then -- Special handling for model path to update preview
            local strEntry = build_tet(inputX, 0, inputWidth, hight_source(38, 1080), rowPanel)
            strEntry.textentry:SetValue(tostring(value or ""))
            strEntry.textentry.OnValueChange = function(self, val)
                itemData[key] = val
                if IsValid(itemPreviewModel) then
                    UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov)
                end
            end
        elseif key == "description" or value == nil then
            local strEntry = build_tet(inputX, 0, inputWidth, hight_source(80, 1080), rowPanel)
            rowPanel:SetTall(hight_source(80, 1080)) 
            strEntry.textentry:SetMultiline(true)
            strEntry.textentry:SetValue(tostring(value or ""))
            strEntry.textentry.OnValueChange = function(self, val)
                itemData[key] = val
            end
        elseif type(value) == "string" or value == nil then
            local strEntry = build_tet(inputX, 0, inputWidth, hight_source(38, 1080), rowPanel)
            strEntry.textentry:SetValue(tostring(value or ""))
            strEntry.textentry.OnValueChange = function(self, val)
                itemData[key] = val
            end
        elseif type(value) == "table" and value.isAngle and value.isAngle() then -- Angle
             local pEntry = build_tet(inputX, 0, inputWidth/3 - 5, hight_source(38, 1080), rowPanel)
             pEntry.textentry:SetNumeric(true)
             pEntry.textentry:SetValue(value.p)
             pEntry.textentry.OnValueChange = function(s,v) 
                itemData[key].p = tonumber(v) or 0
                if IsValid(itemPreviewModel) then UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov) end
             end
             
             local yEntry = build_tet(inputX + inputWidth/3, 0, inputWidth/3 - 5, hight_source(38, 1080), rowPanel)
             yEntry.textentry:SetNumeric(true)
             yEntry.textentry:SetValue(value.y)
             yEntry.textentry.OnValueChange = function(s,v) 
                itemData[key].y = tonumber(v) or 0
                if IsValid(itemPreviewModel) then UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov) end
            end

             local rEntry = build_tet(inputX + (inputWidth/3)*2, 0, inputWidth/3, hight_source(38, 1080), rowPanel)
             rEntry.textentry:SetNumeric(true)
             rEntry.textentry:SetValue(value.r)
             rEntry.textentry.OnValueChange = function(s,v) 
                itemData[key].r = tonumber(v) or 0
                if IsValid(itemPreviewModel) then UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov) end
            end
        elseif type(value) == "table" and value.IsColor and value:IsColor() then -- Color object
            local colorDisplay = vgui.Create("DPanel", rowPanel)
            colorDisplay:SetPos(inputX, 0)
            colorDisplay:SetSize(inputWidth, hight_source(38, 1080))
            colorDisplay.Paint = function(s_panel, s_w, s_h)
                draw.RoundedBox(4,0,0,s_w,s_h, value)
                draw.SimpleText(string.format("R:%d G:%d B:%d A:%d", value.r, value.g, value.b, value.a), "RobotoLight_20", s_w/2, s_h/2, colorInvert(value), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            -- Basic color picker on click
            colorDisplay.DoClick = function()
                Derma_ColorPicker(value, function(newColor)
                    itemData[key] = newColor
                    ShowItemInfo(originalItemId, itemData) -- Refresh to show new color
                end)
            end
        elseif type(value) == "table" then
            local valStr = util.TableToKeyValues(value)
            if string.len(valStr) > 100 then valStr = string.sub(valStr, 1, 97) .. "..." end
            local complexDisplay = vgui.Create("DLabel", rowPanel)
            complexDisplay:SetPos(inputX, 0)
            complexDisplay:SetText("Table: " .. valStr .. " (Редактирование не поддерживается)")
            complexDisplay:SetFont("RobotoLight_20")
            complexDisplay:SetTextColor(Color(150,150,150))
            complexDisplay:SetSize(inputWidth, hight_source(38, 1080))
        elseif type(value) == "function" then
            local funcDisplay = vgui.Create("DLabel", rowPanel)
            funcDisplay:SetPos(inputX, 0)
            funcDisplay:SetText("Function (Редактирование не поддерживается)")
            funcDisplay:SetFont("RobotoLight_20")
            funcDisplay:SetTextColor(Color(150,150,150))
            funcDisplay:SetSize(inputWidth, hight_source(38, 1080))
        elseif type(value) == "Angle"  then 
             local pEntry = build_tet(inputX, 0, inputWidth/3 - 5, hight_source(38, 1080), rowPanel)
             pEntry.textentry:SetNumeric(true)
             pEntry.textentry:SetValue(value.p)
             pEntry.textentry.OnValueChange = function(s,v) 
                itemData[key].p = tonumber(v) or 0
                if IsValid(itemPreviewModel) then UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov) end
             end
             
             local yEntry = build_tet(inputX + inputWidth/3, 0, inputWidth/3 - 5, hight_source(38, 1080), rowPanel)
             yEntry.textentry:SetNumeric(true)
             yEntry.textentry:SetValue(value.y)
             yEntry.textentry.OnValueChange = function(s,v) 
                itemData[key].y = tonumber(v) or 0
                if IsValid(itemPreviewModel) then UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov) end
            end

             local rEntry = build_tet(inputX + (inputWidth/3)*2, 0, inputWidth/3, hight_source(38, 1080), rowPanel)
             rEntry.textentry:SetNumeric(true)
             rEntry.textentry:SetValue(value.r)
             rEntry.textentry.OnValueChange = function(s,v) 
                itemData[key].r = tonumber(v) or 0
            if IsValid(itemPreviewModel) then UpdateItemPreviewPanel(itemPreviewModel, itemData.mdl, itemData.angle, itemData.fov) end
             end
        else
            local otherDisplay = vgui.Create("DLabel", rowPanel)
            otherDisplay:SetPos(inputX, 0)
            otherDisplay:SetText(tostring(value) .. " (Тип: " .. type(value) .. ", редактирование не поддерживается)")
            otherDisplay:SetFont("RobotoLight_20")
            otherDisplay:SetTextColor(Color(150,150,150))
            otherDisplay:SetSize(inputWidth, hight_source(38, 1080))
        end
        local finalHeight = rowPanel:GetTall() or hight_source(38, 1080)
        yPos = yPos + finalHeight + rowSpacing
        return finalHeight
    end

    local standardFields = {"name", "mdl", "kg", "food", "water", "time", "cost", "weapon", "medicine", "angle", "fov", "description", "spoil_time", "color"}
    local standartFieldsForNew = {
        ["name"] = true, 
        ["mdl"] = true, 
        ["angle"] = true, 
        ["fov"] = true, 
        ["kg"] = true, 
        ["description"] = true 
    }
    local processedKeys = {}
    for _, key in ipairs(standardFields) do
        if itemData[key] ~= nil or (isNewItem and table.HasValue({"name", "mdl", "icon", "angle", "fov"}, key)) then
            CreatePropertyRow(key, itemData[key])
            processedKeys[key] = true
        elseif isNewItem and itemData[key] == nil and standartFieldsForNew[key] then -- Initialize standard fields for new items if not already set
            if key == "angle" then itemData[key] = Angle(0,0,0)
            elseif key == "fov" then itemData[key] = 45
            elseif key == "cost" or key == "spoil_time" then itemData[key] = 0
            elseif type(dbt.inventory.items[1] and dbt.inventory.items[1][key]) == "number" then itemData[key] = 0
            elseif type(dbt.inventory.items[1] and dbt.inventory.items[1][key]) == "boolean" then itemData[key] = false
            else itemData[key] = "" end
            CreatePropertyRow(key, itemData[key])
            processedKeys[key] = true
        end
    end
    
    -- Add field button directly under the last property row inside the scroll
    do
        local btnW = propertiesScroll:GetWide() - propertiesScroll:GetVBar():GetWide() - 10
        local btnH = hight_source(38, 1080)
        local btnX = 0
        local btnY = yPos + rowSpacing

        local addFieldButton = CrateMonoButton(
            btnX, btnY,
            btnW, btnH,
            propertiesScroll, "Добавить поле",
            function()
                local menu = DermaMenu()
                local hasOptions = false
                local allKnownFieldsWithDefaults = {
                    { key = "name", default = "", type = "string" },
                    { key = "mdl", default = "", type = "string" }, { key = "kg", default = 0, type = "number" },
                    { key = "food", default = 0, type = "number" }, { key = "water", default = 0, type = "number" },
                    { key = "time", default = 0, type = "number" }, { key = "cost", default = 0, type = "number" },
                    { key = "weapon", default = "", type = "string" },
                    { key = "medicine", default = "", type = "string" }, { key = "angle", default = Angle(0,0,0), type = "angle" },
                    { key = "fov", default = 45, type = "number" }, 
                    { key = "bNotDeleteOnUse", default = false, type = "boolean" },
                    { key = "spoil_time", default = 0, type = "number" },
                }
                for _, fieldInfo in ipairs(allKnownFieldsWithDefaults) do
                    if itemData[fieldInfo.key] == nil then
                        menu:AddOption("Добавить: " .. (russianNames[fieldInfo.key] or fieldInfo.key), function()
                            if fieldInfo.type == "angle" then itemData[fieldInfo.key] = Angle(fieldInfo.default.p, fieldInfo.default.y, fieldInfo.default.r)
                            elseif fieldInfo.type == "color" then itemData[fieldInfo.key] = Color(fieldInfo.default.r, fieldInfo.default.g, fieldInfo.default.b, fieldInfo.default.a)
                            elseif fieldInfo.type == "table" then itemData[fieldInfo.key] = table.Copy(fieldInfo.default)
                            else itemData[fieldInfo.key] = fieldInfo.default end
                            ShowItemInfo(originalItemId, itemData)
                        end)
                        hasOptions = true
                    end
                end
                if not hasOptions then
                    menu:AddOption("Все известные поля уже добавлены", function() end):SetDisabled(true)
                end
                menu:Open()
            end
        )

        -- Make sure scroll area can fit the new button (helps when last row is tall)
        if IsValid(propertiesScroll:GetCanvas()) then
            local neededTall = btnY + btnH + rowSpacing
            if propertiesScroll:GetCanvas():GetTall() < neededTall then
                propertiesScroll:GetCanvas():SetTall(neededTall)
            end
        end
    end


    -- Footer Buttons
    local backButton = CrateMonoButton(
        weight_source(20, 1920), h - hight_source(65, 1080),
        weight_source(150, 1920), hight_source(45, 1080),
        currentEditItemPanel, "◀ Назад",
        function()
            if IsValid(PANEL_ADMIN_FUNC) then
                 dbt.AdminFunc["edit_items"].build(PANEL_ADMIN_FUNC)
            end
        end
    )

    if not isNewItem then
        local deleteButton = CrateMonoButton(
            weight_source(180, 1920), h - hight_source(65, 1080),
            weight_source(150, 1920), hight_source(45, 1080),
            currentEditItemPanel, "Удалить",
            function()
                delete_item_data(originalItemId)
            end
        )
    end

    local applyButton = CrateMonoButton(
        w - weight_source(170, 1920), h - hight_source(65, 1080),
        weight_source(150, 1920), hight_source(45, 1080),
        currentEditItemPanel, (isNewItem and "Создать" or "Применить"),
        function()
            local finalItemId = originalItemId
            if isNewItem then
                local newId = 1
                while dbt.inventory.items[newId] do newId = newId + 1 end
                finalItemId = newId
            end
            
            -- Clean up nil values that might have been added if a default was nil
            local cleanedItemData = table.Copy(itemData)
            for k, v in pairs(cleanedItemData) do
                if v == nil then cleanedItemData[k] = false end -- Or some other appropriate default
            end

            save_item_data(finalItemId, cleanedItemData)
            if IsValid(PANEL_ADMIN_FUNC) then
                 timer.Simple(0.1, function() 
                    if dbt.inventory.items[finalItemId] then 
                        ShowItemInfo(finalItemId) 
                    else 
                        dbt.AdminFunc["edit_items"].build(PANEL_ADMIN_FUNC) 
                    end
                 end)
            end
        end
    )
end


local function BuildEditItemsList(parentPanel, itemsToDisplay, panelW, panelH)
    if not IsValid(parentPanel) then return end
    parentPanel:Clear() 

    local y = hight_source(9, 1080)
    local itemButtonHeight = math.max(hight_source(50,1080) ,panelH * 0.08) // Ensure min height
    local itemButtonSpacing = hight_source(6, 1080)

    if not itemsToDisplay or #itemsToDisplay == 0 then
        local noItemsLabel = vgui.Create("DLabel", parentPanel)
        noItemsLabel:SetPos(0, hight_source(50,1080))
        noItemsLabel:SetSize(parentPanel:GetWide(), hight_source(50,1080))
        noItemsLabel:SetFont("RobotoLight_32")
        noItemsLabel:SetText("Предметы не найдены")
        noItemsLabel:SetTextColor(Color(200, 200, 200))
        noItemsLabel:SetContentAlignment(5) 
        return
    end

    table.sort(itemsToDisplay, function(a, b)
        local itemA = dbt.inventory.items[a]
        local itemB = dbt.inventory.items[b]
        if not itemA then return false end
        if not itemB then return true end
        return string.lower(itemA.name or tostring(a)) < string.lower(itemB.name or tostring(b))
    end)

    for _, itemId in ipairs(itemsToDisplay) do
        local item = dbt.inventory.items[itemId]
        if not item then continue end
        if not item.name or item.name == "" then continue end
    if item.notEditable then continue end

        local itemButton = vgui.Create("DButton", parentPanel)
        itemButton:SetText("") 
        itemButton:SetPos(5, y)
        itemButton:SetSize(parentPanel:GetWide() - parentPanel:GetVBar():GetWide() - 10, itemButtonHeight) 
        itemButton.itemId = itemId
        itemButton.hoverAlpha = 0
        itemButton.isSelected = false
        itemButton.Paint = function(self, w, h)
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
                item.name, 
                "RobotoMedium_30", 
                w * 0.07, 
                h * 0.2, 
                color_white, 
                TEXT_ALIGN_LEFT
            )
            -- 0 1
            
            if self.isSelected then
                draw.RoundedBox(0, w - 6, 0, 6, h, Color(143, 37, 156))
            end
            
            draw.RoundedBox(0, 10, h - 1, w - 20, 1, Color(60, 60, 60, 100))
        end

        itemButton.DoClick = function(self_btn)
            surface.PlaySound("ui/buttonclick.wav")
            ShowItemInfo(self_btn.itemId)
        end

        local mdlIcon = vgui.Create("DModelPanel", itemButton)
        mdlIcon:SetPos(5, 1)
        mdlIcon:SetSize(itemButtonHeight - 2, itemButtonHeight - 2)
        mdlIcon:SetModel(item.mdl or "")
        if IsValid(mdlIcon.Entity) then 
	    local mn, mx = mdlIcon.Entity:GetRenderBounds()
	    local size = 0
	    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
	    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
	    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

	    mdlIcon:SetFOV( item.fov or 45 )
	    mdlIcon:SetCamPos( Vector( size, size, size ) )
	    mdlIcon:SetLookAt( (mn + mx) * 0.5 )
	    mdlIcon.Entity:SetAngles(item.angle or Angle(0,0,0))
        function mdlIcon:LayoutEntity( Entity ) return end
        end
        y = y + itemButtonHeight + itemButtonSpacing
    end
    parentPanel:GetCanvas():SetSize(parentPanel:GetWide() - parentPanel:GetVBar():GetWide() -10, y + itemButtonSpacing)
end


dbt.AdminFunc["edit_items"] = {
    name = "Редактор предметов",
    build = function(frame)
        PANEL_ADMIN_FUNC = frame 
        local w, h = frame:GetWide(), frame:GetTall()

        -- Clear everything that ShowItemInfo might create, plus list-specific panels
        if IsValid(currentEditItemPanel) then currentEditItemPanel:Remove() currentEditItemPanel = nil end
        if IsValid(itemPreviewModel) then itemPreviewModel:Remove() itemPreviewModel = nil end
        if IsValid(itemSearchPanel) then itemSearchPanel:Remove() itemSearchPanel = nil end
        if IsValid(itemAddButton) then itemAddButton:Remove() itemAddButton = nil end
        if IsValid(itemListContainer) then itemListContainer:Remove() itemListContainer = nil end
        if IsValid(itemsScrollPanel) then itemsScrollPanel:Remove() itemsScrollPanel = nil end

        itemSearchPanel = vgui.Create("DPanel", frame)
        itemSearchPanel:SetPos(weight_source(805, 1920), hight_source(15, 1080))
        itemSearchPanel:SetSize(w * 0.3 - weight_source(20,1920), hight_source(25, 1080))
        itemSearchPanel:SetPaintBackground(false)
        itemSearchPanel.Paint = function(self_panel, pW, pH)
            draw.RoundedBox(4, 0, 0, pW, pH, monobuttons_1)
        end

        local searchEntry = vgui.Create("DTextEntry", itemSearchPanel)
        searchEntry:SetPos(weight_source(10,1920), hight_source(-5,1080))
        searchEntry:SetSize(itemSearchPanel:GetWide() - weight_source(20,1920), hight_source(36,1080))
        searchEntry:SetFont("RobotoLight_22")
        searchEntry:SetPlaceholderText("Поиск по ID или названию...")
        searchEntry:SetTextColor(color_white)
        searchEntry:SetPlaceholderColor(Color(100,100,100, 150))
        searchEntry:SetPaintBackground(false)
        searchEntry:SetUpdateOnType(true)
        searchEntry:SetDrawLanguageID(false) 

        searchEntry.OnValueChange = function(self_entry, text)
            local searchText = string.lower(tostring(text or ""))
            searchEntry.searchText = searchText

            local filteredItemIds = FilterItems(searchText)
            if IsValid(itemsScrollPanel) and IsValid(itemListContainer) then
                BuildEditItemsList(itemsScrollPanel, filteredItemIds, itemListContainer:GetWide(), itemListContainer:GetTall())
            end
        end
        
        reloadQMenuButton = CrateMonoButton(
            weight_source(15,1920), 
            hight_source(700,1080),
            weight_source(220, 1920), 
            hight_source(40,1080),
            frame, 
            "Перегрузка QMenu",
            function()
                RunConsoleCommand("spawnmenu_reload")
            end
        )

        presetsButton = CrateMonoButton(
            w - (weight_source(250,1920) + weight_source(535,1920)), 
            hight_source(700,1080),
            weight_source(250,1920), 
            hight_source(40,1080),
            frame, 
            "Пресеты",
            function()
                local menu = DermaMenu()

                local listPresets = GetListPresets()
                for k, v in pairs(listPresets) do
                    menu:AddOption(v, function()
                        local fileData = util.JSONToTable(file.Read("dbt/items/presets/"..k))
                        if not fileData then return end
                        net.Start( "dbt/inventory/items/load/preset" )
		                net.WriteStream(pon.encode(fileData), function()
                                local targetFrame = admin_frame or frame
                                if IsValid(targetFrame) then
                                    targetFrame:Close()
                                end
		                end)
		                net.SendToServer()
                    end)
                end
                menu:Open()
            end
        )
        SavepresetButton = CrateMonoButton(
            w - (weight_source(250,1920) + weight_source(15,1920) + weight_source(260,1920)), 
            hight_source(700,1080),
            weight_source(250,1920), 
            hight_source(40,1080),
            frame, 
            "Сохранить пресет",
            function()
                Derma_StringRequest(
                    "Сохранить пресет", 
                    "Введите имя пресета:", 
                    "", 
                    function(text)
                        if text and text ~= "" then
                            local presetData = {}
                            presetData.Name = text

                            local cleanItems = {}
                            for itemId, item in pairs(dbt.inventory.items or {}) do
                                if item.notEditable then continue end
                                local copy = table.Copy(item)
                                copy.GetDescription = nil
                                copy.OnUse = nil
                                cleanItems[itemId] = copy
                            end

                            presetData.Items = cleanItems
                            file.Write("dbt/items/presets/" .. util.SHA256(text) .. ".json", util.TableToJSON(presetData, true))
                            dbt.AdminFunc["edit_items"].build(PANEL_ADMIN_FUNC)
                        end
                    end,
                    function() end,
                    "Сохранить", "Отмена"
                )
            end
        )
        itemAddButton = CrateMonoButton(
            w - (weight_source(250,1920) + weight_source(15,1920)), 
            hight_source(700,1080),
            weight_source(250,1920), 
            hight_source(40,1080),
            frame, "Добавить предмет (+)",
            function()
                ShowItemInfo(nil) 
            end
        )
        searchCategory = "all"
        itemFilterCombo = vgui.Create("DComboBox", frame)
        itemFilterCombo:SetPos(weight_source(15, 1920), hight_source(15, 1080))
        itemFilterCombo:SetSize(weight_source(170, 1920), hight_source(25, 1080))
        itemFilterCombo:AddChoice("Все предметы", "all")
        itemFilterCombo:AddChoice("Оружие", "weapon")
        itemFilterCombo:AddChoice("Еда", "food")
        itemFilterCombo:AddChoice("Напитки", "water")
        itemFilterCombo.OnSelect = function( self, index, value )
            searchCategory = self:GetOptionData(index)

            local filteredItemIds = FilterItems(searchEntry and searchEntry.searchText or "")
            if IsValid(itemsScrollPanel) and IsValid(itemListContainer) then
                BuildEditItemsList(itemsScrollPanel, filteredItemIds, itemListContainer:GetWide(), itemListContainer:GetTall())
            end
        end

        isCustomCheck = build_checkbox(weight_source(200, 1920), hight_source(15, 1080), weight_source(600, 1920), hight_source(25, 1080), "Только отредактированные", frame)
        isCustomCheck.check_b.checked = not not searchOnlyCustom
        isCustomCheck.check_b.OnEdit = function(b)
            searchOnlyCustom = b
            local filteredItemIds = FilterItems(searchEntry and searchEntry.searchText or "")
            if IsValid(itemsScrollPanel) and IsValid(itemListContainer) then
                BuildEditItemsList(itemsScrollPanel, filteredItemIds, itemListContainer:GetWide(), itemListContainer:GetTall())
            end
        end
        if searchOnlyCustom then
            isCustomCheck.check_b.OnEdit(searchOnlyCustom)
        end
        itemListContainer = vgui.Create("DPanel", frame)
        itemListContainer:SetPos(weight_source(15, 1920), hight_source(45, 1080))
        itemListContainer:SetSize(w - weight_source(30,1920), hight_source(650, 1080)) // Adjusted height
        itemListContainer.Paint = function(self_panel, pW, pH)
           draw.RoundedBox(4, 0, 0, w, h, Color(148, 21, 150, (255 / 100) * 14))
        end
        
        itemsScrollPanel = vgui.Create("DScrollPanel", itemListContainer)
        itemsScrollPanel:SetPos(weight_source(10,1920), hight_source(10,1080))
        itemsScrollPanel:SetSize(itemListContainer:GetWide() - weight_source(20,1920), itemListContainer:GetTall() - hight_source(20,1080))

        local scrollBar = itemsScrollPanel:GetVBar()
        scrollBar:SetWide(weight_source(8, 1920))
        function scrollBar:Paint(w_bar, h_bar) draw.RoundedBox(4, 0, 0, w_bar, h_bar, Color(0,0,0,60)) end
        function scrollBar.btnGrip:Paint(w_bar_grip, h_bar_grip) draw.RoundedBox(4, 0, 0, w_bar_grip, h_bar_grip, Color(143,37,156,120)) end
        function scrollBar.btnUp:Paint() end
        function scrollBar.btnDown:Paint() end

        local allItemIds = {}
        local initialItemIds = FilterItems("")
        BuildEditItemsList(itemsScrollPanel, initialItemIds, itemListContainer:GetWide(), itemListContainer:GetTall())
  
end,
    PaintAdv = function(self, w, h)
      
    end
}


file.CreateDir("dbt/items")
file.CreateDir("dbt/items/presets")
function GetListPresets()
    local findedFiles = file.Find("dbt/items/presets/*.json", "DATA")
    local listPresets = {}
    for k, i in pairs(findedFiles) do
        local fileData = util.JSONToTable(file.Read("dbt/items/presets/"..i))
        if fileData then
            listPresets[i] = fileData.Name
        end
    end
    return listPresets
end

