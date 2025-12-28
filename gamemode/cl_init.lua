include("shared.lua")

-- =============================================
-- CONVARS
-- =============================================
CreateClientConVar("thw_evidice", "icons/1.png", true, false, "")
CreateClientConVar("name_evidice", "icons/1.png", true, false, "")
CreateClientConVar("desc_evidice", "icons/1.png", true, false, "")
CreateClientConVar("name_sign", " ", true, false, "")
CreateClientConVar("text_sign", " ", true, false, "")
CreateClientConVar("showcroshair", 0, true, false, "")
CreateClientConVar("text_clickable", " ", true, false, "")
CreateClientConVar("name_clickable", " ", true, false, "")

RunConsoleCommand("cl_showhints", 0) 

ScreenWidth = ScrW()
ScreenHeight = ScrH()
charactersInGame = {}

hook.Add('OnScreenSizeChanged', 'local', function()
    ScreenWidth = ScrW()
    ScreenHeight = ScrH()
end)

netstream.Hook("dbt/config/init", function(id)
    config[id].init()
end)

-- =============================================
-- ШРИФТЫ ДЛЯ SPAWN MENU
-- =============================================
surface.CreateFont("LOTM_SpawnMenu_Title", {
    font = "Roboto",
    size = 14,
    weight = 700,
    antialias = true,
})

surface.CreateFont("LOTM_SpawnMenu_Small", {
    font = "Roboto",
    size = 12,
    weight = 500,
    antialias = true,
})

surface.CreateFont("LOTM_SpawnMenu_Tiny", {
    font = "Roboto",
    size = 10,
    weight = 400,
    antialias = true,
})

-- =============================================
-- ЦВЕТОВАЯ ПАЛИТРА ПРОЕКТА
-- =============================================
local colorOutLine = Color(211, 25, 202)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorPanelBG = Color(20, 18, 25, 240)
local colorItemBG = Color(30, 28, 38, 250)
local colorItemHover = Color(50, 40, 65, 255)

-- =============================================
-- РЕДКОСТИ
-- =============================================
local RARITY_COLORS = {
    [1] = {name = "Обычный", color = Color(180, 180, 180)},
    [2] = {name = "Необычный", color = Color(100, 255, 100)},
    [3] = {name = "Редкий", color = Color(100, 150, 255)},
    [4] = {name = "Эпический", color = Color(200, 100, 255)},
    [5] = {name = "Легендарный", color = Color(255, 200, 50)},
    [6] = {name = "Божественный", color = Color(255, 255, 200)},
    [7] = {name = "Проклятый", color = Color(150, 50, 50)},
}

-- =============================================
-- КАТЕГОРИИ ИНВЕНТАРЯ
-- =============================================
local INVENTORY_CATEGORIES = {
    {id = "all", name = "Все предметы", icon = "icon16/package.png", color = Color(211, 25, 202)},
    {id = "artifact", name = "Артефакты", icon = "icon16/ruby.png", color = Color(255, 200, 100)},
    {id = "food", name = "Еда", icon = "icon16/cake.png", color = Color(255, 180, 100)},
    {id = "water", name = "Вода", icon = "icon16/cup.png", color = Color(100, 180, 255)},
    {id = "medicine", name = "Медицина", icon = "icon16/heart.png", color = Color(255, 100, 100)},
    {id = "weapon", name = "Оружие", icon = "icon16/gun.png", color = Color(200, 200, 200)},
    {id = "ammo", name = "Патроны", icon = "icon16/bullet_black.png", color = Color(150, 150, 150)},
    {id = "tools", name = "Инструменты", icon = "icon16/wrench.png", color = Color(255, 200, 50)},
    {id = "keys", name = "Ключи", icon = "icon16/key.png", color = Color(255, 215, 0)},
    {id = "documents", name = "Документы", icon = "icon16/page_white_text.png", color = Color(200, 200, 255)},
    {id = "currency", name = "Валюта", icon = "icon16/coins.png", color = Color(255, 215, 0)},
    {id = "other", name = "Остальное", icon = "icon16/box.png", color = Color(180, 180, 180)},
}

-- =============================================
-- ТИПЫ LOTM АРТЕФАКТОВ
-- =============================================
local LOTM_ARTIFACT_TYPES = {
    {type = nil, name = "Все", icon = "icon16/star.png", color = Color(211, 25, 202)},
    {type = "divine", name = "Божественные", icon = "icon16/weather_sun.png", color = Color(255, 255, 200)},
    {type = "cursed", name = "Проклятые", icon = "icon16/exclamation.png", color = Color(150, 50, 50)},
    {type = "grade_0", name = "Seq 0", icon = "icon16/award_star_gold_3.png", color = Color(255, 255, 100)},
    {type = "grade_1", name = "Seq 1", icon = "icon16/award_star_gold_2.png", color = Color(255, 200, 50)},
    {type = "grade_2", name = "Seq 2", icon = "icon16/award_star_gold_1.png", color = Color(255, 150, 50)},
    {type = "grade_3", name = "Seq 3", icon = "icon16/award_star_silver_3.png", color = Color(255, 100, 200)},
    {type = "grade_4", name = "Seq 4", icon = "icon16/award_star_silver_2.png", color = Color(200, 100, 255)},
    {type = "grade_5", name = "Seq 5", icon = "icon16/award_star_silver_1.png", color = Color(150, 100, 255)},
    {type = "grade_6", name = "Seq 6", icon = "icon16/award_star_bronze_3.png", color = Color(100, 150, 255)},
    {type = "grade_7", name = "Seq 7", icon = "icon16/award_star_bronze_2.png", color = Color(100, 200, 255)},
    {type = "grade_8", name = "Seq 8", icon = "icon16/award_star_bronze_1.png", color = Color(100, 255, 100)},
    {type = "grade_9", name = "Seq 9", icon = "icon16/asterisk_yellow.png", color = Color(200, 200, 200)},
    {type = "sealed", name = "Запечатанные", icon = "icon16/lock.png", color = Color(150, 150, 150)},
}

-- =============================================
-- ОПРЕДЕЛЕНИЕ КАТЕГОРИИ ПРЕДМЕТА
-- =============================================
local function DetectItemCategory(itemData)
    if itemData.artifact or itemData.lotmArtifact then return "artifact" end
    if itemData.ammo then return "ammo" end
    if itemData.weapon then return "weapon" end
    if itemData.medicine then return "medicine" end
    if itemData.food and not itemData.water then return "food" end
    if itemData.water and not itemData.food then return "water" end
    if itemData.food and itemData.water then return "food" end
    if itemData.currency then return "currency" end
    if itemData.key or itemData.keys or (itemData.name and string.find(string.lower(itemData.name or ""), "ключ")) then return "keys" end
    if itemData.document or itemData.monopad then return "documents" end
    if itemData.tool then return "tools" end
    return "other"
end

-- =============================================
-- ПОЛУЧЕНИЕ ЦВЕТА
-- =============================================
local function GetCategoryColor(catId)
    for _, cat in ipairs(INVENTORY_CATEGORIES) do
        if cat.id == catId then return cat.color end
    end
    return Color(180, 180, 180)
end

local function GetRarityColor(rarityId)
    local rarity = RARITY_COLORS[rarityId]
    return rarity and rarity.color or Color(180, 180, 180)
end

local function GetArtifactColor(artifactType)
    for _, t in ipairs(LOTM_ARTIFACT_TYPES) do
        if t.type == artifactType then return t.color end
    end
    return Color(255, 255, 255)
end

-- =============================================
-- СОЗДАНИЕ КАРТОЧКИ ПРЕДМЕТА
-- =============================================
local function CreateItemCard(parent, size, model, name, color, rarity, onClick, onRightClick, tooltip)
    local itemPanel = vgui.Create("DPanel", parent)
    itemPanel:SetSize(size, size + 28)
    
    local rarityColor = rarity and GetRarityColor(rarity) or color
    
    itemPanel.hovered = false
    itemPanel.Paint = function(self, w, h)
        local bgColor = self.hovered and colorItemHover or colorItemBG
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
        
        -- Полоса редкости/категории сверху
        draw.RoundedBoxEx(6, 0, 0, w, 3, rarityColor, true, true, false, false)
        
        -- Свечение редкости при наведении
        if self.hovered and rarity and rarity >= 3 then
            local glowAlpha = 30 + math.sin(CurTime() * 3) * 15
            draw.RoundedBox(6, 0, 0, w, h, Color(rarityColor.r, rarityColor.g, rarityColor.b, glowAlpha))
        end
        
        -- Рамка при наведении
        if self.hovered then
            surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end
    
    -- Модель предмета
    local icon = vgui.Create("DModelPanel", itemPanel)
    icon:SetSize(size - 12, size - 12)
    icon:SetPos(6, 6)
    icon:SetModel(model or "models/props_junk/garbage_takeoutcarton001a.mdl")
    icon.LayoutEntity = function() return end
    
    if IsValid(icon.Entity) then
        local mn, mx = icon.Entity:GetRenderBounds()
        local modelSize = math.max(
            math.abs(mn.x) + math.abs(mx.x),
            math.abs(mn.y) + math.abs(mx.y),
            math.abs(mn.z) + math.abs(mx.z)
        )
        icon:SetFOV(45)
        icon:SetCamPos(Vector(modelSize, modelSize, modelSize))
        icon:SetLookAt((mn + mx) * 0.5)
    end
    
    -- Название
    local nameLabel = vgui.Create("DLabel", itemPanel)
    nameLabel:SetPos(3, size - 6)
    nameLabel:SetSize(size - 6, 28)
    
    -- Сокращаем длинные названия
    local displayName = name or "???"
    if string.len(displayName) > 12 then
        displayName = string.sub(displayName, 1, 10) .. ".."
    end
    
    nameLabel:SetText(displayName)
    nameLabel:SetWrap(true)
    nameLabel:SetFont("LOTM_SpawnMenu_Small")
    nameLabel:SetTextColor(rarityColor)
    nameLabel:SetContentAlignment(5)
    
    -- Кнопка
    local button = vgui.Create("DButton", itemPanel)
    button:SetSize(size, size + 28)
    button:SetPos(0, 0)
    button:SetText("")
    button.Paint = nil
    
    button.OnCursorEntered = function()
        itemPanel.hovered = true
    end
    
    button.OnCursorExited = function()
        itemPanel.hovered = false
    end
    
    button.DoClick = function()
        if onClick then onClick() end
        surface.PlaySound("ui/buttonclickrelease.wav")
    end
    
    button.DoRightClick = function()
        if onRightClick then onRightClick() end
    end
    
    if tooltip then
        button:SetTooltip(tooltip)
    end
    
    return itemPanel
end

-- =============================================
-- СОЗДАНИЕ КОНТЕНТА СПАВН-МЕНЮ
-- =============================================
local function CreateSpawnMenuContent()
    local root = vgui.Create("DPanel")
    root:SetPaintBackground(false)
    
    -- Левая панель - дерево категорий
    local treePanel = vgui.Create("DPanel", root)
    treePanel:Dock(LEFT)
    treePanel:SetWidth(200)
    treePanel:DockMargin(0, 0, 8, 0)
    treePanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, colorPanelBG)
        
        -- Заголовок
        draw.SimpleText("КАТЕГОРИИ", "LOTM_SpawnMenu_Title", w/2, 12, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(10, 24, w - 20, 1)
    end
    
    local tree = vgui.Create("DTree", treePanel)
    tree:Dock(FILL)
    tree:DockMargin(5, 30, 5, 5)
    tree.Paint = function() end
    
    -- Правая панель - сетка предметов
    local contentPanel = vgui.Create("DPanel", root)
    contentPanel:Dock(FILL)
    contentPanel.currentTitle = "Все предметы"
    contentPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, colorPanelBG)
        
        -- Заголовок
        draw.SimpleText(self.currentTitle or "Предметы", "LOTM_SpawnMenu_Title", 15, 12, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(10, 24, w - 20, 1)
    end
    
    local contentScroll = vgui.Create("DScrollPanel", contentPanel)
    contentScroll:Dock(FILL)
    contentScroll:DockMargin(5, 30, 5, 5)
    
    local sbar = contentScroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, colorOutLine) end
    
    local currentGrid = nil
    
    local function ClearGrid()
        if IsValid(currentGrid) then
            currentGrid:Remove()
        end
        currentGrid = nil
    end
    
    -- =============================================
    -- ЗАПОЛНЕНИЕ ПРЕДМЕТАМИ ИНВЕНТАРЯ
    -- =============================================
    local function PopulateItems(categoryId, categoryName)
        ClearGrid()
        contentPanel.currentTitle = categoryName or "Предметы"
        
        currentGrid = vgui.Create("DIconLayout", contentScroll)
        currentGrid:Dock(TOP)
        currentGrid:SetSpaceX(6)
        currentGrid:SetSpaceY(6)
        
        if not dbt or not dbt.inventory or not dbt.inventory.items then
            local emptyLabel = vgui.Create("DLabel", currentGrid)
            emptyLabel:SetText("Инвентарь не загружен")
            emptyLabel:SetFont("LOTM_SpawnMenu_Small")
            emptyLabel:SetTextColor(colorTextDim)
            emptyLabel:SizeToContents()
            return
        end
        
        local items = {}
        for id, data in pairs(dbt.inventory.items) do
            if istable(data) and data.mdl and data.mdl ~= "" then
                local itemCategory = DetectItemCategory(data)
                if not categoryId or categoryId == "all" or itemCategory == categoryId then
                    table.insert(items, {id = id, data = data, category = itemCategory})
                end
            end
        end
        
        table.sort(items, function(a, b)
            -- Сначала по редкости (если есть), потом по имени
            local rarityA = a.data.rarity or 1
            local rarityB = b.data.rarity or 1
            if rarityA ~= rarityB then return rarityA > rarityB end
            return (a.data.name or "") < (b.data.name or "")
        end)
        
        for _, entry in ipairs(items) do
            local itemData = entry.data
            local catColor = GetCategoryColor(entry.category)
            local rarity = itemData.rarity
            
            local tooltipLines = {
                "[" .. (RARITY_COLORS[rarity] and RARITY_COLORS[rarity].name or entry.category) .. "]",
                itemData.name or "???",
                "ID: " .. tostring(entry.id),
            }
            if itemData.food then table.insert(tooltipLines, "Еда: +" .. itemData.food) end
            if itemData.water then table.insert(tooltipLines, "Вода: +" .. itemData.water) end
            if itemData.kg then table.insert(tooltipLines, "Вес: " .. itemData.kg .. " кг") end
            
            local tooltipText = table.concat(tooltipLines, "\n")
            
            local card = CreateItemCard(
                currentGrid,
                85,
                itemData.mdl,
                itemData.name or tostring(entry.id),
                catColor,
                rarity,
                function()
                    -- Выдать предмет
                    RunConsoleCommand("AddItemn__", tostring(entry.id))
                end,
                function()
                    local menu = DermaMenu()
                    menu:AddOption("Выдать 1", function()
                        RunConsoleCommand("AddItemn__", tostring(entry.id))
                    end):SetIcon("icon16/add.png")
                    menu:AddOption("Выдать 5", function()
                        for i = 1, 5 do
                            RunConsoleCommand("AddItemn__", tostring(entry.id))
                        end
                    end):SetIcon("icon16/add.png")
                    menu:AddSpacer()
                    menu:AddOption("Копировать ID", function()
                        SetClipboardText(tostring(entry.id))
                    end):SetIcon("icon16/page_copy.png")
                    menu:Open()
                end,
                tooltipText
            )
            
            currentGrid:Add(card)
        end
        
        if #items == 0 then
            local emptyLabel = vgui.Create("DLabel", currentGrid)
            emptyLabel:SetText("Нет предметов в этой категории")
            emptyLabel:SetFont("LOTM_SpawnMenu_Small")
            emptyLabel:SetTextColor(colorTextDim)
            emptyLabel:SizeToContents()
        end
        
        contentScroll:GetCanvas():InvalidateLayout(true)
    end
    
    -- =============================================
    -- ЗАПОЛНЕНИЕ LOTM АРТЕФАКТАМИ
    -- =============================================
    local function PopulateLOTMArtifacts(filterType, categoryName)
        ClearGrid()
        contentPanel.currentTitle = categoryName or "LOTM Артефакты"
        
        currentGrid = vgui.Create("DIconLayout", contentScroll)
        currentGrid:Dock(TOP)
        currentGrid:SetSpaceX(6)
        currentGrid:SetSpaceY(6)
        
        -- Проверяем оба источника артефактов
        local artifacts = {}
        
        -- Из LOTM.Artifacts.Registry
        if LOTM and LOTM.Artifacts and LOTM.Artifacts.Registry then
            for artifactId, artifactData in pairs(LOTM.Artifacts.Registry) do
                if not filterType or artifactData.type == filterType then
                    table.insert(artifacts, {
                        id = artifactId,
                        data = artifactData,
                        source = "lotm"
                    })
                end
            end
        end
        
        -- Из LOTM.ArtifactTemplates.Registry
        if LOTM and LOTM.ArtifactTemplates and LOTM.ArtifactTemplates.Registry then
            for artifactId, artifactData in pairs(LOTM.ArtifactTemplates.Registry) do
                table.insert(artifacts, {
                    id = artifactId,
                    data = artifactData,
                    source = "template",
                    invId = artifactData.inventoryId
                })
            end
        end
        
        if #artifacts == 0 then
            local emptyLabel = vgui.Create("DLabel", currentGrid)
            emptyLabel:SetText("Артефакты не найдены")
            emptyLabel:SetFont("LOTM_SpawnMenu_Small")
            emptyLabel:SetTextColor(colorTextDim)
            emptyLabel:SizeToContents()
            return
        end
        
        table.sort(artifacts, function(a, b)
            return (a.data.name or "") < (b.data.name or "")
        end)
        
        for _, entry in ipairs(artifacts) do
            local artifactData = entry.data
            local typeColor = GetArtifactColor(artifactData.type)
            
            -- Цвет редкости для шаблонных артефактов
            local rarity = nil
            if entry.source == "template" and artifactData.rarity then
                typeColor = artifactData.rarity.color or typeColor
                rarity = artifactData.rarity.id
            end
            
            local tooltipText = string.format("[%s] %s\n\n%s", 
                artifactData.type or (artifactData.rarity and artifactData.rarity.name) or "Артефакт", 
                artifactData.name or entry.id,
                artifactData.description or "Нет описания")
            
            local card = CreateItemCard(
                currentGrid,
                85,
                artifactData.model or "models/props_lab/huladoll.mdl",
                artifactData.name or entry.id,
                typeColor,
                rarity,
                function()
                    -- Выдаём артефакт
                    if entry.invId then
                        -- Через инвентарь
                        RunConsoleCommand("AddItemn__", tostring(entry.invId))
                    else
                        -- Через команду LOTM
                        RunConsoleCommand("lotm_give_artifact", LocalPlayer():Name(), entry.id)
                    end
                end,
                function()
                    local menu = DermaMenu()
                    menu:AddOption("Выдать артефакт", function()
                        if entry.invId then
                            RunConsoleCommand("AddItemn__", tostring(entry.invId))
                        else
                            RunConsoleCommand("lotm_give_artifact", LocalPlayer():Name(), entry.id)
                        end
                    end):SetIcon("icon16/ruby.png")
                    if entry.source == "lotm" then
                        menu:AddOption("Выдать SWEP", function()
                            RunConsoleCommand("lotm_give_artifact_weapon", entry.id)
                        end):SetIcon("icon16/wand.png")
                    end
                    menu:AddSpacer()
                    menu:AddOption("Копировать ID", function()
                        SetClipboardText(tostring(entry.id))
                    end):SetIcon("icon16/page_copy.png")
                    menu:Open()
                end,
                tooltipText
            )
            
            currentGrid:Add(card)
        end
        
        contentScroll:GetCanvas():InvalidateLayout(true)
    end
    
    -- =============================================
    -- ЗАПОЛНЕНИЕ ИНГРЕДИЕНТАМИ
    -- =============================================
    local function PopulateIngredients(categoryId, categoryName)
        ClearGrid()
        contentPanel.currentTitle = categoryName or "Ингредиенты"
        
        currentGrid = vgui.Create("DIconLayout", contentScroll)
        currentGrid:Dock(TOP)
        currentGrid:SetSpaceX(6)
        currentGrid:SetSpaceY(6)
        
        if not LOTM or not LOTM.Ingredients or not LOTM.Ingredients.Registry then 
            local emptyLabel = vgui.Create("DLabel", currentGrid)
            emptyLabel:SetText("Ингредиенты не загружены")
            emptyLabel:SetFont("LOTM_SpawnMenu_Small")
            emptyLabel:SetTextColor(colorTextDim)
            emptyLabel:SizeToContents()
            return
        end
        
        local ingredients = {}
        for ingredientId, data in pairs(LOTM.Ingredients.Registry) do
            if not categoryId or data.category == categoryId then
                table.insert(ingredients, {id = ingredientId, data = data})
            end
        end
        
        table.sort(ingredients, function(a, b)
            return (a.data.name or "") < (b.data.name or "")
        end)
        
        for _, entry in ipairs(ingredients) do
            local data = entry.data
            local rarityColor = (LOTM.Ingredients.RarityColors and LOTM.Ingredients.RarityColors[data.rarity]) or Color(200, 200, 200)
            local rarityName = (LOTM.Ingredients.RarityNames and LOTM.Ingredients.RarityNames[data.rarity]) or "?"
            
            local tooltipText = string.format("[%s] %s\n\n%s\n\nРитуальная сила: %d", 
                rarityName, data.name or entry.id, data.description or "", data.ritualPower or 0)
            
            local card = CreateItemCard(
                currentGrid,
                85,
                data.model or "models/props_junk/garbage_takeoutcarton001a.mdl",
                data.name or entry.id,
                rarityColor,
                data.rarity,
                function()
                    RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), entry.id, "1")
                end,
                function()
                    local menu = DermaMenu()
                    menu:AddOption("Выдать 1", function()
                        RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), entry.id, "1")
                    end):SetIcon("icon16/add.png")
                    menu:AddOption("Выдать 10", function()
                        RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), entry.id, "10")
                    end):SetIcon("icon16/add.png")
                    menu:AddOption("Выдать 50", function()
                        RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), entry.id, "50")
                    end):SetIcon("icon16/add.png")
                    menu:AddSpacer()
                    menu:AddOption("Копировать ID", function()
                        SetClipboardText(entry.id)
                    end):SetIcon("icon16/page_copy.png")
                    menu:Open()
                end,
                tooltipText
            )
            
            currentGrid:Add(card)
        end
        
        contentScroll:GetCanvas():InvalidateLayout(true)
    end
    
    -- =============================================
    -- ПОСТРОЕНИЕ ДЕРЕВА КАТЕГОРИЙ
    -- =============================================
    
    -- Предметы инвентаря
    local itemsNode = tree:AddNode("Предметы", "icon16/package.png")
    itemsNode:SetExpanded(true)
    
    for _, cat in ipairs(INVENTORY_CATEGORIES) do
        local node = itemsNode:AddNode(cat.name, cat.icon)
        node.DoClick = function()
            PopulateItems(cat.id, cat.name)
        end
    end
    
    -- LOTM Артефакты
    local artifactsNode = tree:AddNode("LOTM Артефакты", "icon16/ruby.png")
    
    for _, typeData in ipairs(LOTM_ARTIFACT_TYPES) do
        local node = artifactsNode:AddNode(typeData.name, typeData.icon)
        node.DoClick = function()
            PopulateLOTMArtifacts(typeData.type, "LOTM: " .. typeData.name)
        end
    end
    
    -- LOTM Ингредиенты
    local ingredientsNode = tree:AddNode("LOTM Ингредиенты", "icon16/flower_dead.png")
    
    local allIngNode = ingredientsNode:AddNode("Все ингредиенты", "icon16/package.png")
    allIngNode.DoClick = function()
        PopulateIngredients(nil, "Все ингредиенты")
    end
    
    if LOTM and LOTM.Ingredients and LOTM.Ingredients.CategoryNames then
        local categoryIcons = {
            ["plants"] = "icon16/flower_dead.png",
            ["minerals"] = "icon16/ruby.png",
            ["blood"] = "icon16/heart.png",
            ["spiritual"] = "icon16/eye.png",
            ["materials"] = "icon16/box.png",
            ["beyonder"] = "icon16/star.png",
            ["divine"] = "icon16/weather_sun.png",
        }
        
        for catId, catName in pairs(LOTM.Ingredients.CategoryNames) do
            local node = ingredientsNode:AddNode(catName, categoryIcons[catId] or "icon16/box.png")
            node.DoClick = function()
                PopulateIngredients(catId, catName)
            end
        end
    end
    
    -- Загружаем предметы по умолчанию
    timer.Simple(0.1, function()
        if IsValid(root) then
            PopulateItems("all", "Все предметы")
        end
    end)
    
    return root
end

-- =============================================
-- РЕГИСТРАЦИЯ ВКЛАДКИ В SPAWN MENU
-- =============================================
spawnmenu.AddCreationTab("Предметы", CreateSpawnMenuContent, "icon16/application_view_tile.png", 4)

-- =============================================
-- КОМАНДА ДЛЯ ПРОСМОТРА КОСТЕЙ ПРОПА
-- =============================================
concommand.Add("bones", function()
    local ent = LocalPlayer():GetEyeTrace().Entity
    if not IsValid(ent) then 
        print("Направь прицел на проп!")
        return 
    end
    
    local boneCount = ent:GetBoneCount()
    if boneCount == 0 then
        print("У этого пропа нет костей")
        return
    end
    
    print("=== Кости: " .. tostring(ent) .. " ===")
    for i = 0, boneCount - 1 do
        local boneName = ent:GetBoneName(i)
        print(string.format("[%d] %s", i, boneName))
    end
    print("=== Всего костей: " .. boneCount .. " ===")
end)
