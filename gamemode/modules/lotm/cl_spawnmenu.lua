-- LOTM Spawn Menu Integration
-- Добавление категорий Артефакты и Мистические ингредиенты в спавн меню

if not CLIENT then return end

LOTM = LOTM or {}

-- Цвета редкости для артефактов
local ArtifactTypeColors = {
    ["sealed"] = Color(150, 150, 150),
    ["grade_9"] = Color(200, 200, 200),
    ["grade_8"] = Color(100, 255, 100),
    ["grade_7"] = Color(100, 200, 255),
    ["grade_6"] = Color(100, 150, 255),
    ["grade_5"] = Color(150, 100, 255),
    ["grade_4"] = Color(200, 100, 255),
    ["grade_3"] = Color(255, 100, 200),
    ["grade_2"] = Color(255, 150, 50),
    ["grade_1"] = Color(255, 200, 50),
    ["grade_0"] = Color(255, 255, 100),
    ["cursed"] = Color(150, 50, 50),
    ["divine"] = Color(255, 255, 200),
}

local colorOutLine = Color(211, 25, 202)

-- =============================================
-- Создание панели артефактов
-- =============================================

local function CreateArtifactsPanel()
    local root = vgui.Create("DPanel")
    root:SetPaintBackground(false)
    
    local tree = root:Add("DTree")
    tree:Dock(LEFT)
    tree:SetWidth(200)
    tree:DockMargin(0, 0, 8, 0)
    
    local contentScroll = root:Add("DScrollPanel")
    contentScroll:Dock(FILL)
    
    local currentGrid = nil
    
    local function clearGrid()
        if IsValid(currentGrid) then
            currentGrid:Remove()
        end
        currentGrid = nil
    end
    
    local function populateArtifacts(filterType)
        clearGrid()
        
        currentGrid = contentScroll:Add("DIconLayout")
        currentGrid:Dock(TOP)
        currentGrid:SetSpaceX(8)
        currentGrid:SetSpaceY(8)
        
        if not LOTM.Artifacts or not LOTM.Artifacts.Registry then return end
        
        for artifactId, artifactData in pairs(LOTM.Artifacts.Registry) do
            -- Фильтрация по типу
            if filterType and artifactData.type ~= filterType then continue end
            
            local itemPanel = vgui.Create("DPanel")
            itemPanel:SetSize(100, 130)
            
            local typeColor = ArtifactTypeColors[artifactData.type] or Color(255, 255, 255)
            
            itemPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
                
                -- Рамка по типу
                surface.SetDrawColor(typeColor)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            -- Модель
            local icon = vgui.Create("DModelPanel", itemPanel)
            icon:SetSize(80, 80)
            icon:SetPos(10, 5)
            icon:SetModel(artifactData.model or "models/props_lab/huladoll.mdl")
            icon.LayoutEntity = function() return end
            
            if IsValid(icon.Entity) then
                local mn, mx = icon.Entity:GetRenderBounds()
                local size = math.max(
                    math.abs(mn.x) + math.abs(mx.x),
                    math.abs(mn.y) + math.abs(mx.y),
                    math.abs(mn.z) + math.abs(mx.z)
                )
                icon:SetFOV(45)
                icon:SetCamPos(Vector(size, size, size))
                icon:SetLookAt((mn + mx) * 0.5)
            end
            
            -- Название
            local nameLabel = vgui.Create("DLabel", itemPanel)
            nameLabel:SetPos(5, 85)
            nameLabel:SetSize(90, 40)
            nameLabel:SetText(artifactData.name or artifactId)
            nameLabel:SetWrap(true)
            nameLabel:SetFont("Comfortaa X12")
            nameLabel:SetTextColor(typeColor)
            nameLabel:SetContentAlignment(5)
            
            -- Кнопка
            local button = vgui.Create("DButton", itemPanel)
            button:SetSize(100, 130)
            button:SetPos(0, 0)
            button:SetText("")
            button.Paint = nil
            
            button.DoClick = function()
                RunConsoleCommand("lotm_give_artifact", LocalPlayer():Name(), artifactId)
                surface.PlaySound("ui/button_click.mp3")
            end
            
            button.DoRightClick = function()
                local menu = DermaMenu()
                menu:AddOption("Копировать ID", function()
                    SetClipboardText(artifactId)
                end)
                menu:AddOption("Выдать себе", function()
                    RunConsoleCommand("lotm_give_artifact", LocalPlayer():Name(), artifactId)
                end)
                menu:Open()
            end
            
            -- Тултип
            button:SetTooltip(artifactData.description or "")
            
            currentGrid:Add(itemPanel)
        end
        
        contentScroll:GetCanvas():InvalidateLayout(true)
    end
    
    -- Узлы дерева по типам
    local allNode = tree:AddNode("Все артефакты", "icon16/star.png")
    allNode.DoClick = function()
        populateArtifacts(nil)
    end
    
    local typeNodes = {
        {type = "divine", name = "Божественные", icon = "icon16/weather_sun.png"},
        {type = "cursed", name = "Проклятые", icon = "icon16/exclamation.png"},
        {type = "grade_0", name = "Seq 0 (Бог)", icon = "icon16/award_star_gold_3.png"},
        {type = "grade_1", name = "Seq 1 (Ангел)", icon = "icon16/award_star_gold_2.png"},
        {type = "grade_2", name = "Seq 2 (Высший)", icon = "icon16/award_star_gold_1.png"},
        {type = "grade_3", name = "Seq 3", icon = "icon16/award_star_silver_3.png"},
        {type = "grade_4", name = "Seq 4", icon = "icon16/award_star_silver_2.png"},
        {type = "grade_5", name = "Seq 5", icon = "icon16/award_star_silver_1.png"},
        {type = "grade_6", name = "Seq 6", icon = "icon16/award_star_bronze_3.png"},
        {type = "grade_7", name = "Seq 7", icon = "icon16/award_star_bronze_2.png"},
        {type = "grade_8", name = "Seq 8", icon = "icon16/award_star_bronze_1.png"},
        {type = "grade_9", name = "Seq 9", icon = "icon16/asterisk_yellow.png"},
        {type = "sealed", name = "Запечатанные", icon = "icon16/lock.png"},
    }
    
    for _, typeData in ipairs(typeNodes) do
        local node = tree:AddNode(typeData.name, typeData.icon)
        node.DoClick = function()
            populateArtifacts(typeData.type)
        end
    end
    
    -- Показываем все по умолчанию
    timer.Simple(0.1, function()
        if IsValid(root) then
            populateArtifacts(nil)
        end
    end)
    
    return root
end

-- =============================================
-- Создание панели ингредиентов
-- =============================================

local function CreateIngredientsPanel()
    local root = vgui.Create("DPanel")
    root:SetPaintBackground(false)
    
    local tree = root:Add("DTree")
    tree:Dock(LEFT)
    tree:SetWidth(180)
    tree:DockMargin(0, 0, 8, 0)
    
    local contentScroll = root:Add("DScrollPanel")
    contentScroll:Dock(FILL)
    
    local currentGrid = nil
    
    local function clearGrid()
        if IsValid(currentGrid) then
            currentGrid:Remove()
        end
        currentGrid = nil
    end
    
    local function populateIngredients(category)
        clearGrid()
        
        currentGrid = contentScroll:Add("DIconLayout")
        currentGrid:Dock(TOP)
        currentGrid:SetSpaceX(6)
        currentGrid:SetSpaceY(6)
        
        if not LOTM.Ingredients or not LOTM.Ingredients.Registry then return end
        
        for ingredientId, data in pairs(LOTM.Ingredients.Registry) do
            -- Фильтрация по категории
            if category and data.category ~= category then continue end
            
            local itemPanel = vgui.Create("DPanel")
            itemPanel:SetSize(90, 110)
            
            local rarityColor = LOTM.Ingredients.RarityColors[data.rarity] or Color(200, 200, 200)
            
            itemPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
                
                -- Полоска редкости
                draw.RoundedBox(0, 0, h - 3, w, 3, rarityColor)
            end
            
            -- Модель
            local icon = vgui.Create("DModelPanel", itemPanel)
            icon:SetSize(70, 70)
            icon:SetPos(10, 5)
            icon:SetModel(data.model or "models/props_junk/garbage_takeoutcarton001a.mdl")
            icon.LayoutEntity = function() return end
            
            if IsValid(icon.Entity) then
                local mn, mx = icon.Entity:GetRenderBounds()
                local size = math.max(
                    math.abs(mn.x) + math.abs(mx.x),
                    math.abs(mn.y) + math.abs(mx.y),
                    math.abs(mn.z) + math.abs(mx.z)
                )
                icon:SetFOV(45)
                icon:SetCamPos(Vector(size, size, size))
                icon:SetLookAt((mn + mx) * 0.5)
            end
            
            -- Название
            local nameLabel = vgui.Create("DLabel", itemPanel)
            nameLabel:SetPos(3, 75)
            nameLabel:SetSize(84, 32)
            nameLabel:SetText(data.name or ingredientId)
            nameLabel:SetWrap(true)
            nameLabel:SetFont("Comfortaa X10")
            nameLabel:SetTextColor(rarityColor)
            nameLabel:SetContentAlignment(5)
            
            -- Кнопка
            local button = vgui.Create("DButton", itemPanel)
            button:SetSize(90, 110)
            button:SetPos(0, 0)
            button:SetText("")
            button.Paint = nil
            
            button.DoClick = function()
                RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), ingredientId, 1)
                surface.PlaySound("ui/button_click.mp3")
            end
            
            button.DoRightClick = function()
                local menu = DermaMenu()
                menu:AddOption("Выдать 1", function()
                    RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), ingredientId, 1)
                end)
                menu:AddOption("Выдать 10", function()
                    RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), ingredientId, 10)
                end)
                menu:AddOption("Выдать 50", function()
                    RunConsoleCommand("lotm_give_ingredient", LocalPlayer():Name(), ingredientId, 50)
                end)
                menu:AddOption("Копировать ID", function()
                    SetClipboardText(ingredientId)
                end)
                menu:Open()
            end
            
            -- Тултип
            local rarityName = LOTM.Ingredients.RarityNames[data.rarity] or "?"
            button:SetTooltip(string.format("[%s] %s\n\n%s\n\nРитуальная сила: %d", 
                rarityName, data.name, data.description or "", data.ritualPower or 0))
            
            currentGrid:Add(itemPanel)
        end
        
        contentScroll:GetCanvas():InvalidateLayout(true)
    end
    
    -- Узлы дерева
    local allNode = tree:AddNode("Все ингредиенты", "icon16/package.png")
    allNode.DoClick = function()
        populateIngredients(nil)
    end
    
    if LOTM.Ingredients and LOTM.Ingredients.Categories then
        local categoryIcons = {
            ["plants"] = "icon16/flower_dead.png",
            ["minerals"] = "icon16/ruby.png",
            ["blood"] = "icon16/heart.png",
            ["spiritual"] = "icon16/eye.png",
            ["materials"] = "icon16/box.png",
            ["beyonder"] = "icon16/star.png",
            ["divine"] = "icon16/weather_sun.png",
        }
        
        for catId, catName in pairs(LOTM.Ingredients.CategoryNames or {}) do
            local node = tree:AddNode(catName, categoryIcons[catId] or "icon16/box.png")
            node.DoClick = function()
                populateIngredients(catId)
            end
        end
    end
    
    -- Показываем все по умолчанию
    timer.Simple(0.1, function()
        if IsValid(root) then
            populateIngredients(nil)
        end
    end)
    
    return root
end

-- =============================================
-- Регистрация вкладок в спавн меню
-- =============================================

hook.Add("PopulateToolMenu", "LOTM.SpawnMenu.Tools", function()
    spawnmenu.AddToolMenuOption("Utilities", "LOTM", "lotm_commands", "Команды", "", "", function(panel)
        panel:ClearControls()
        
        panel:Help("Консольные команды LOTM:")
        panel:Help("lotm_give_potion <игрок> <potion_id> [кол-во]")
        panel:Help("lotm_give_ingredient <игрок> <ingredient_id> [кол-во]")
        panel:Help("lotm_give_artifact <игрок> <artifact_id>")
        panel:Help("lotm_set_pathway <игрок> <pathway_id>")
        panel:Help("lotm_set_sequence <игрок> <sequence>")
        panel:Help("")
        panel:Help("Списки:")
        panel:Help("lotm_list_potions")
        panel:Help("lotm_list_ingredients")
        panel:Help("lotm_list_artifacts")
    end)
end)

-- Добавляем вкладки в Creation меню
hook.Add("InitPostEntity", "LOTM.SpawnMenu.Register", function()
    timer.Simple(1, function()
        spawnmenu.AddCreationTab("LOTM Артефакты", CreateArtifactsPanel, "icon16/ruby.png", 10)
        spawnmenu.AddCreationTab("LOTM Ингредиенты", CreateIngredientsPanel, "icon16/package.png", 11)
        
        MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Spawn menu tabs registered\n")
    end)
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Spawn menu integration loaded\n")

