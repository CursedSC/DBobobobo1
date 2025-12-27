-- LOTM Unified Items Menu
-- Меню всех LOTM предметов в стиле F4

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.UnifiedMenu = LOTM.UnifiedMenu or {}

-- Цветовая палитра проекта (из cl_new_f4.lua)
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorBG2 = Color(255, 255, 255, 150)
local colorText = Color(255, 255, 255, 200)
local colorTextDim = Color(180, 180, 180)
local colorSettingsPanel = Color(0, 0, 0, 170)
local colorSettingsPanelActive = Color(191, 30, 219, 150)

-- Материалы
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

-- =============================================
-- ОТКРЫТИЕ МЕНЮ LOTM ПРЕДМЕТОВ
-- =============================================

function LOTM.UnifiedMenu.Open()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.UnifiedMenu.Frame) then
        LOTM.UnifiedMenu.Frame:Close()
        return
    end
    
    local a = math.random(1, 3)
    local CurrentBG = tableBG[a]
    local selectedCategory = "potions"
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw, scrh)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    LOTM.UnifiedMenu.Frame = frame
    
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
        if dbtPaint and dbtPaint.DrawRect then
            dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, colorBG2)
        end
        
        draw.SimpleText("LOTM ПРЕДМЕТЫ", "Comfortaa Bold X60", w / 2, dbtPaint and dbtPaint.HightSource(80) or 80, color_white, TEXT_ALIGN_CENTER)
        
        -- Линия под заголовком
        local lineW = dbtPaint and dbtPaint.WidthSource(400) or 400
        draw.RoundedBox(0, w / 2 - lineW / 2, dbtPaint and dbtPaint.HightSource(140) or 140, lineW, 2, colorOutLine)
    end
    
    -- Контейнер для категорий и контента
    local catWidth = dbtPaint and dbtPaint.WidthSource(250) or 250
    local contentX = dbtPaint and dbtPaint.WidthSource(320) or 320
    local startY = dbtPaint and dbtPaint.HightSource(180) or 180
    local contentH = dbtPaint and dbtPaint.HightSource(700) or 700
    
    -- =============================================
    -- КАТЕГОРИИ
    -- =============================================
    
    local categories = {
        {id = "potions", name = "ЗЕЛЬЯ", icon = "💧"},
        {id = "ingredients", name = "ИНГРЕДИЕНТЫ", icon = "🌿"},
        {id = "artifacts", name = "АРТЕФАКТЫ", icon = "💎"},
        {id = "info", name = "ИНФОРМАЦИЯ", icon = "📜"},
    }
    
    local catPanel = vgui.Create("DPanel", frame)
    catPanel:SetPos(dbtPaint and dbtPaint.WidthSource(50) or 50, startY)
    catPanel:SetSize(catWidth, contentH)
    catPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
    end
    
    local catButtons = {}
    local yOffset = 10
    
    for _, cat in ipairs(categories) do
        local btn = vgui.Create("DButton", catPanel)
        btn:SetPos(10, yOffset)
        btn:SetSize(catWidth - 20, 50)
        btn:SetText("")
        btn.catId = cat.id
        
        btn.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local isActive = selectedCategory == cat.id
            
            local bgColor = isActive and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100) or 
                           (hovered and Color(50, 50, 50, 200) or Color(0, 0, 0, 100))
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            if isActive then
                draw.RoundedBox(0, 0, 0, 4, h, colorOutLine)
            end
            
            draw.SimpleText(cat.icon, "DermaDefaultBold", 20, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(cat.name, "Comfortaa Light X20", 45, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            selectedCategory = cat.id
            surface.PlaySound('ui/button_click.mp3')
            LOTM.UnifiedMenu.RefreshContent(frame, selectedCategory, contentX, startY, scrw - contentX - 50, contentH)
        end
        
        btn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
        
        catButtons[cat.id] = btn
        yOffset = yOffset + 60
    end
    
    -- =============================================
    -- КОНТЕНТ
    -- =============================================
    
    LOTM.UnifiedMenu.RefreshContent(frame, selectedCategory, contentX, startY, scrw - contentX - 50, contentH)
    
    -- =============================================
    -- КНОПКА НАЗАД
    -- =============================================
    
    local backButton = vgui.Create("DButton", frame)
    backButton:SetText("")
    backButton:SetPos(dbtPaint and dbtPaint.WidthSource(48) or 48, dbtPaint and dbtPaint.HightSource(984) or (scrh - 70))
    backButton:SetSize(dbtPaint and dbtPaint.WidthSource(199) or 199, dbtPaint and dbtPaint.HightSource(55) or 55)
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        frame:Close()
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(50, 50, 50, 200) or colorSettingsPanel)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- =============================================
-- ОБНОВЛЕНИЕ КОНТЕНТА
-- =============================================

function LOTM.UnifiedMenu.RefreshContent(frame, category, x, y, w, h)
    -- Удаляем старый контент
    if IsValid(LOTM.UnifiedMenu.ContentPanel) then
        LOTM.UnifiedMenu.ContentPanel:Remove()
    end
    
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetPos(x, y)
    contentPanel:SetSize(w, h)
    contentPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(4, 0, 0, pw, ph, Color(0, 0, 0, 150))
    end
    
    LOTM.UnifiedMenu.ContentPanel = contentPanel
    
    if category == "potions" then
        LOTM.UnifiedMenu.DrawPotions(contentPanel, w, h)
    elseif category == "ingredients" then
        LOTM.UnifiedMenu.DrawIngredients(contentPanel, w, h)
    elseif category == "artifacts" then
        LOTM.UnifiedMenu.DrawArtifacts(contentPanel, w, h)
    elseif category == "info" then
        LOTM.UnifiedMenu.DrawInfo(contentPanel, w, h)
    end
end

-- =============================================
-- ЗЕЛЬЯ
-- =============================================

function LOTM.UnifiedMenu.DrawPotions(parent, w, h)
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 15)
    title:SetSize(w - 40, 30)
    title:SetFont("Comfortaa Bold X30")
    title:SetText("ДОСТУПНЫЕ ЗЕЛЬЯ")
    title:SetTextColor(colorOutLine)
    
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetPos(10, 55)
    scroll:SetSize(w - 20, h - 65)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, sw, sh) draw.RoundedBox(0, 0, 0, sw, sh, Color(0, 0, 0, 100)) end
    sbar.btnGrip.Paint = function(self, sw, sh) draw.RoundedBox(4, 0, 0, sw, sh, colorOutLine) end
    
    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(w - 30, h - 65)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)
    
    if not LOTM.Potions then return end
    
    -- Сортируем по последовательности
    local sortedPotions = {}
    for uid, potion in pairs(LOTM.Potions) do
        table.insert(sortedPotions, potion)
    end
    table.sort(sortedPotions, function(a, b) 
        if a.Pathway == b.Pathway then
            return a.Sequence > b.Sequence
        end
        return a.Pathway < b.Pathway
    end)
    
    for _, potion in ipairs(sortedPotions) do
        local potionPanel = layout:Add("DButton")
        potionPanel:SetSize(180, 120)
        potionPanel:SetText("")
        
        local seqColors = {
            [9] = Color(200, 200, 200),
            [8] = Color(100, 255, 100),
            [7] = Color(100, 200, 255),
            [6] = Color(150, 100, 255),
            [5] = Color(255, 100, 255),
        }
        local potionColor = seqColors[potion.Sequence] or Color(255, 200, 100)
        
        potionPanel.Paint = function(self, pw, ph)
            local hovered = self:IsHovered()
            draw.RoundedBox(4, 0, 0, pw, ph, hovered and Color(60, 30, 80, 220) or Color(40, 40, 50, 200))
            
            if hovered then
                draw_border(pw, ph, colorOutLine)
            end
            
            -- Название
            draw.SimpleText(potion.Name, "DermaDefaultBold", pw / 2, 15, potionColor, TEXT_ALIGN_CENTER)
            
            -- Последовательность
            draw.SimpleText("Seq " .. potion.Sequence, "DermaDefault", pw / 2, 35, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            
            -- Путь
            local pathName = "Универсальное"
            if LOTM.PathwaysList and LOTM.PathwaysList[potion.Pathway] then
                pathName = LOTM.PathwaysList[potion.Pathway].name
            end
            draw.SimpleText(pathName, "DermaDefault", pw / 2, 55, Color(150, 150, 150), TEXT_ALIGN_CENTER)
            
            -- Риск
            local riskColor = potion.MadnessRisk > 0.3 and Color(255, 100, 100) or Color(100, 255, 100)
            draw.SimpleText("Риск: " .. math.floor(potion.MadnessRisk * 100) .. "%", "DermaDefault", pw / 2, 80, riskColor, TEXT_ALIGN_CENTER)
            
            -- Способности
            local abCount = potion.Abilities and #potion.Abilities or 0
            draw.SimpleText("Способностей: " .. abCount, "DermaDefault", pw / 2, 100, Color(100, 200, 255), TEXT_ALIGN_CENTER)
        end
        
        potionPanel.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            LOTM.UnifiedMenu.ShowPotionDetails(potion)
        end
        
        potionPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    end
end

-- =============================================
-- ИНГРЕДИЕНТЫ
-- =============================================

function LOTM.UnifiedMenu.DrawIngredients(parent, w, h)
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 15)
    title:SetSize(w - 40, 30)
    title:SetFont("Comfortaa Bold X30")
    title:SetText("МИСТИЧЕСКИЕ ИНГРЕДИЕНТЫ")
    title:SetTextColor(colorOutLine)
    
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetPos(10, 55)
    scroll:SetSize(w - 20, h - 65)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, sw, sh) draw.RoundedBox(0, 0, 0, sw, sh, Color(0, 0, 0, 100)) end
    sbar.btnGrip.Paint = function(self, sw, sh) draw.RoundedBox(4, 0, 0, sw, sh, colorOutLine) end
    
    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(w - 30, h - 65)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)
    
    if not LOTM.Ingredients or not LOTM.Ingredients.Registry then return end
    
    for ingId, ing in pairs(LOTM.Ingredients.Registry) do
        local ingPanel = layout:Add("DButton")
        ingPanel:SetSize(150, 100)
        ingPanel:SetText("")
        
        local rarityColor = LOTM.Ingredients.RarityColors[ing.rarity] or Color(200, 200, 200)
        
        ingPanel.Paint = function(self, pw, ph)
            local hovered = self:IsHovered()
            draw.RoundedBox(4, 0, 0, pw, ph, hovered and Color(60, 30, 80, 220) or Color(40, 40, 50, 200))
            
            if hovered then
                draw_border(pw, ph, rarityColor)
            end
            
            -- Название
            draw.SimpleText(ing.name, "DermaDefaultBold", pw / 2, 20, rarityColor, TEXT_ALIGN_CENTER)
            
            -- Категория
            local catName = LOTM.Ingredients.CategoryNames[ing.category] or "Материалы"
            draw.SimpleText(catName, "DermaDefault", pw / 2, 45, Color(150, 150, 150), TEXT_ALIGN_CENTER)
            
            -- Ритуальная сила
            draw.SimpleText("Сила: " .. (ing.ritualPower or 0), "DermaDefault", pw / 2, 70, Color(255, 200, 100), TEXT_ALIGN_CENTER)
        end
        
        ingPanel.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
        end
        
        ingPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    end
end

-- =============================================
-- АРТЕФАКТЫ
-- =============================================

function LOTM.UnifiedMenu.DrawArtifacts(parent, w, h)
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 15)
    title:SetSize(w - 40, 30)
    title:SetFont("Comfortaa Bold X30")
    title:SetText("АРТЕФАКТЫ")
    title:SetTextColor(colorOutLine)
    
    -- Текущий артефакт
    local currentPanel = vgui.Create("DPanel", parent)
    currentPanel:SetPos(20, 55)
    currentPanel:SetSize(w - 40, 80)
    currentPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(4, 0, 0, pw, ph, Color(30, 30, 40, 200))
        draw.SimpleText("ЭКИПИРОВАННЫЙ АРТЕФАКТ", "DermaDefaultBold", 15, 10, colorOutLine)
        
        local equipped = nil
        if LOTM.Artifacts and LOTM.Artifacts.GetEquipped then
            equipped = LOTM.Artifacts.GetEquipped(LocalPlayer())
        end
        
        if equipped then
            draw.SimpleText(equipped.name, "Comfortaa Bold X25", 15, 40, Color(255, 215, 100))
        else
            draw.SimpleText("Нет экипированного артефакта", "Comfortaa Light X20", 15, 40, colorTextDim)
        end
    end
    
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetPos(10, 145)
    scroll:SetSize(w - 20, h - 155)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, sw, sh) draw.RoundedBox(0, 0, 0, sw, sh, Color(0, 0, 0, 100)) end
    sbar.btnGrip.Paint = function(self, sw, sh) draw.RoundedBox(4, 0, 0, sw, sh, colorOutLine) end
    
    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(w - 30, h - 155)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)
    
    if not LOTM.Artifacts or not LOTM.Artifacts.Registry then return end
    
    local typeColors = {
        [LOTM.Artifacts.Types.GRADE_9] = Color(200, 200, 200),
        [LOTM.Artifacts.Types.GRADE_8] = Color(100, 255, 100),
        [LOTM.Artifacts.Types.GRADE_7] = Color(100, 150, 255),
        [LOTM.Artifacts.Types.GRADE_6] = Color(150, 100, 255),
        [LOTM.Artifacts.Types.GRADE_5] = Color(255, 100, 255),
        [LOTM.Artifacts.Types.GRADE_4] = Color(255, 150, 50),
        [LOTM.Artifacts.Types.CURSED] = Color(255, 50, 50),
        [LOTM.Artifacts.Types.DIVINE] = Color(255, 215, 0),
    }
    
    for artId, art in pairs(LOTM.Artifacts.Registry) do
        local artPanel = layout:Add("DButton")
        artPanel:SetSize(180, 110)
        artPanel:SetText("")
        
        local artColor = typeColors[art.type] or Color(255, 255, 255)
        
        artPanel.Paint = function(self, pw, ph)
            local hovered = self:IsHovered()
            draw.RoundedBox(4, 0, 0, pw, ph, hovered and Color(60, 30, 80, 220) or Color(40, 40, 50, 200))
            
            if hovered then
                draw_border(pw, ph, artColor)
            end
            
            -- Название
            draw.SimpleText(art.name, "DermaDefaultBold", pw / 2, 15, artColor, TEXT_ALIGN_CENTER)
            
            -- Тип
            local typeName = art.type and string.upper(art.type) or "АРТЕФАКТ"
            draw.SimpleText(typeName, "DermaDefault", pw / 2, 35, Color(150, 150, 150), TEXT_ALIGN_CENTER)
            
            -- Кулдаун
            draw.SimpleText("CD: " .. (art.abilityCooldown or 60) .. "с", "DermaDefault", pw / 2, 55, Color(100, 200, 255), TEXT_ALIGN_CENTER)
            
            -- Требования
            if art.requirements and art.requirements.minSequence then
                draw.SimpleText("Req: Seq " .. art.requirements.minSequence, "DermaDefault", pw / 2, 75, Color(255, 200, 100), TEXT_ALIGN_CENTER)
            end
        end
        
        artPanel.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
        end
        
        artPanel.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    end
end

-- =============================================
-- ИНФОРМАЦИЯ
-- =============================================

function LOTM.UnifiedMenu.DrawInfo(parent, w, h)
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 15)
    title:SetSize(w - 40, 30)
    title:SetFont("Comfortaa Bold X30")
    title:SetText("ПУТИ BEYONDER")
    title:SetTextColor(colorOutLine)
    
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetPos(10, 55)
    scroll:SetSize(w - 20, h - 65)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, sw, sh) draw.RoundedBox(0, 0, 0, sw, sh, Color(0, 0, 0, 100)) end
    sbar.btnGrip.Paint = function(self, sw, sh) draw.RoundedBox(4, 0, 0, sw, sh, colorOutLine) end
    
    local yOffset = 10
    
    if not LOTM.PathwaysList then return end
    
    for id, pathway in pairs(LOTM.PathwaysList) do
        local pathPanel = vgui.Create("DPanel", scroll)
        pathPanel:SetPos(10, yOffset)
        pathPanel:SetSize(w - 50, 60)
        pathPanel.Paint = function(self, pw, ph)
            draw.RoundedBox(4, 0, 0, pw, ph, Color(30, 30, 40, 200))
            
            -- Цветная линия
            draw.RoundedBox(0, 0, 0, 5, ph, pathway.color or colorOutLine)
            
            -- Название
            draw.SimpleText(pathway.name, "Comfortaa Bold X25", 20, 10, pathway.color or color_white)
            draw.SimpleText(pathway.nameEn, "Comfortaa Light X18", 20, 35, colorTextDim)
            
            -- Количество зелий
            local potionCount = 0
            if LOTM.Potions then
                for _, potion in pairs(LOTM.Potions) do
                    if potion.Pathway == id then
                        potionCount = potionCount + 1
                    end
                end
            end
            draw.SimpleText("Зелий: " .. potionCount, "DermaDefault", pw - 20, ph / 2, Color(100, 200, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        
        yOffset = yOffset + 70
    end
end

-- =============================================
-- ДЕТАЛИ ЗЕЛЬЯ
-- =============================================

function LOTM.UnifiedMenu.ShowPotionDetails(potion)
    if IsValid(LOTM.UnifiedMenu.DetailFrame) then
        LOTM.UnifiedMenu.DetailFrame:Close()
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH = 500, 400
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    LOTM.UnifiedMenu.DetailFrame = frame
    
    local seqColors = {
        [9] = Color(200, 200, 200),
        [8] = Color(100, 255, 100),
        [7] = Color(100, 200, 255),
        [6] = Color(150, 100, 255),
        [5] = Color(255, 100, 255),
    }
    local potionColor = seqColors[potion.Sequence] or Color(255, 200, 100)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 240))
        draw_border(w, h, colorOutLine)
        
        -- Заголовок
        draw.SimpleText(potion.Name, "Comfortaa Bold X30", w / 2, 20, potionColor, TEXT_ALIGN_CENTER)
        draw.SimpleText("Последовательность " .. potion.Sequence, "Comfortaa Light X20", w / 2, 50, colorTextDim, TEXT_ALIGN_CENTER)
        
        -- Описание
        draw.SimpleText(potion.Description, "DermaDefault", 20, 90, color_white, TEXT_ALIGN_LEFT)
        
        -- Статистика
        local yPos = 130
        
        local pathName = "Универсальное"
        if LOTM.PathwaysList and LOTM.PathwaysList[potion.Pathway] then
            pathName = LOTM.PathwaysList[potion.Pathway].name
        end
        draw.SimpleText("Путь: " .. pathName, "Comfortaa Light X18", 20, yPos, Color(150, 100, 255))
        yPos = yPos + 25
        
        draw.SimpleText("Скорость переваривания: " .. math.floor(potion.DigestionRate * 100) .. "%", "Comfortaa Light X18", 20, yPos, Color(100, 255, 100))
        yPos = yPos + 25
        
        local riskColor = potion.MadnessRisk > 0.3 and Color(255, 100, 100) or Color(255, 200, 100)
        draw.SimpleText("Риск безумия: " .. math.floor(potion.MadnessRisk * 100) .. "%", "Comfortaa Light X18", 20, yPos, riskColor)
        yPos = yPos + 35
        
        -- Способности
        if potion.Abilities and #potion.Abilities > 0 then
            draw.SimpleText("СПОСОБНОСТИ:", "Comfortaa Bold X18", 20, yPos, colorOutLine)
            yPos = yPos + 25
            
            for _, ab in ipairs(potion.Abilities) do
                local abType = ab.Type == LOTM.ABILITY_TYPES.PASSIVE and "[Пассив]" or "[Актив]"
                local abColor = ab.Type == LOTM.ABILITY_TYPES.PASSIVE and Color(100, 200, 255) or Color(255, 200, 100)
                
                draw.SimpleText(abType .. " " .. ab.Name, "DermaDefault", 30, yPos, abColor)
                yPos = yPos + 20
                
                if ab.Description and ab.Description ~= "" then
                    draw.SimpleText("   " .. ab.Description, "DermaDefault", 30, yPos, colorTextDim)
                    yPos = yPos + 20
                end
            end
        end
        
        -- Ингредиенты
        if potion.Ingredients and #potion.Ingredients > 0 then
            yPos = yPos + 10
            draw.SimpleText("ИНГРЕДИЕНТЫ:", "Comfortaa Bold X18", 20, yPos, colorOutLine)
            yPos = yPos + 25
            
            for _, ingId in ipairs(potion.Ingredients) do
                local ing = LOTM.Ingredients and LOTM.Ingredients.Get(ingId)
                local ingName = ing and ing.name or ingId
                draw.SimpleText("• " .. ingName, "DermaDefault", 30, yPos, Color(100, 255, 100))
                yPos = yPos + 18
            end
        end
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - 35, 5)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.SimpleText("✕", "DermaDefaultBold", w/2, h/2, 
            self:IsHovered() and Color(255, 100, 100) or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        frame:Close()
    end
end

-- Консольная команда
concommand.Add("lotm_items", function()
    LOTM.UnifiedMenu.Open()
end)

-- Хук для F4 интеграции
hook.Add("LOTM.F4.OpenSubmenu", "LOTM.UnifiedMenu.FromF4", function(submenu)
    if submenu == "items" then
        LOTM.UnifiedMenu.Open()
    end
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Unified Menu loaded\n")
