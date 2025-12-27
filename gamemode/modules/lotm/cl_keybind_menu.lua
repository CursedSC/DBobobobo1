-- LOTM Keybind Menu
-- Меню настройки клавиш для способностей

LOTM = LOTM or {}
LOTM.KeybindMenu = LOTM.KeybindMenu or {}

-- Конфигурация кейбиндов
LOTM.Keybinds = {
    {id = "ability_1", name = "Способность 1", key = KEY_1, category = "abilities"},
    {id = "ability_2", name = "Способность 2", key = KEY_2, category = "abilities"},
    {id = "ability_3", name = "Способность 3", key = KEY_3, category = "abilities"},
    {id = "ability_4", name = "Способность 4", key = KEY_4, category = "abilities"},
    {id = "ability_5", name = "Способность 5", key = KEY_5, category = "abilities"},
    {id = "third_person", name = "Третье лицо", key = KEY_C, category = "view"},
    {id = "aura", name = "Аура", key = KEY_V, category = "powers"},
    {id = "artifacts", name = "Артефакты", key = KEY_B, category = "items"}
}

-- Категории для группировки
LOTM.KeybindCategories = {
    {id = "abilities", name = "Способности", color = Color(100, 150, 255)},
    {id = "view", name = "Вид", color = Color(150, 255, 150)},
    {id = "powers", name = "Силы", color = Color(255, 150, 100)},
    {id = "items", name = "Предметы", color = Color(255, 200, 100)}
}

-- Загрузка сохраненных кейбиндов
function LOTM.LoadKeybinds()
    for _, keybind in ipairs(LOTM.Keybinds) do
        local saved = cookie.GetNumber("lotm_keybind_" .. keybind.id, keybind.key)
        keybind.key = saved
    end
end

-- Сохранение кейбинда
function LOTM.SaveKeybind(id, key)
    cookie.Set("lotm_keybind_" .. id, key)
end

-- Получение кейбинда по ID
function LOTM.GetKeybind(id)
    for _, keybind in ipairs(LOTM.Keybinds) do
        if keybind.id == id then
            return keybind.key
        end
    end
    return KEY_NONE
end

-- Переменные для UI
local menuOpen = false
local menuPanel = nil
local awaitingKey = nil
local scrollPanel = nil

-- Цветовая палитра (современный dark theme)
local colors = {
    background = Color(20, 20, 25, 245),
    header = Color(30, 30, 35),
    accent = Color(100, 120, 255),
    accentHover = Color(120, 140, 255),
    text = Color(240, 240, 245),
    textDim = Color(160, 160, 170),
    panel = Color(35, 35, 40),
    panelHover = Color(45, 45, 50),
    border = Color(60, 60, 70),
    success = Color(100, 200, 100),
    warning = Color(255, 180, 80)
}

-- Функция для рисования закругленного прямоугольника с тенью
local function DrawRoundedBoxWithShadow(x, y, w, h, radius, color, shadowSize)
    shadowSize = shadowSize or 8
    
    -- Тень
    for i = 1, shadowSize do
        local alpha = (shadowSize - i) * 4
        draw.RoundedBox(radius, x - i, y - i, w + i * 2, h + i * 2, Color(0, 0, 0, alpha))
    end
    
    -- Основной прямоугольник
    draw.RoundedBox(radius, x, y, w, h, color)
end

-- Создание меню
function LOTM.CreateKeybindMenu()
    if IsValid(menuPanel) then
        menuPanel:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local menuW, menuH = math.min(900, scrW * 0.7), math.min(700, scrH * 0.8)
    
    menuPanel = vgui.Create("DFrame")
    menuPanel:SetSize(menuW, menuH)
    menuPanel:Center()
    menuPanel:SetTitle("")
    menuPanel:SetDraggable(true)
    menuPanel:ShowCloseButton(false)
    menuPanel:MakePopup()
    menuPanel:SetAlpha(0)
    menuPanel:AlphaTo(255, 0.15, 0)
    
    menuPanel.Paint = function(self, w, h)
        -- Фон с тенью
        DrawRoundedBoxWithShadow(0, 0, w, h, 12, colors.background, 10)
        
        -- Шапка
        draw.RoundedBoxEx(12, 0, 0, w, 70, colors.header, true, true, false, false)
        
        -- Линия под шапкой
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, 70, w, 2)
        
        -- Заголовок
        draw.SimpleText("Lord of The Mysteries", "DermaLarge", 30, 20, colors.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Настройка управления", "DermaDefault", 30, 50, colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", menuPanel)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(menuW - 50, 15)
    closeBtn:SetText("")
    
    closeBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and colors.warning or colors.text
        draw.RoundedBox(8, 0, 0, w, h, self:IsHovered() and Color(50, 50, 55) or Color(40, 40, 45))
        
        surface.SetDrawColor(col)
        surface.DrawLine(12, 12, w - 12, h - 12)
        surface.DrawLine(w - 12, 12, 12, h - 12)
    end
    
    closeBtn.DoClick = function()
        menuPanel:AlphaTo(0, 0.15, 0, function()
            menuPanel:Remove()
            menuOpen = false
        end)
    end
    
    -- Скролл панель
    scrollPanel = vgui.Create("DScrollPanel", menuPanel)
    scrollPanel:SetPos(20, 90)
    scrollPanel:SetSize(menuW - 40, menuH - 110)
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colors.panel)
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and colors.accentHover or colors.accent)
    end
    sbar.btnUp:SetVisible(false)
    sbar.btnDown:SetVisible(false)
    
    -- Группировка по категориям
    local yOffset = 0
    local categoryMap = {}
    
    -- Создание карты категорий
    for _, cat in ipairs(LOTM.KeybindCategories) do
        categoryMap[cat.id] = {data = cat, keybinds = {}}
    end
    
    -- Распределение кейбиндов по категориям
    for _, keybind in ipairs(LOTM.Keybinds) do
        if categoryMap[keybind.category] then
            table.insert(categoryMap[keybind.category].keybinds, keybind)
        end
    end
    
    -- Создание UI для каждой категории
    for _, cat in ipairs(LOTM.KeybindCategories) do
        local categoryData = categoryMap[cat.id]
        if #categoryData.keybinds > 0 then
            -- Заголовок категории
            local catHeader = vgui.Create("DPanel", scrollPanel)
            catHeader:SetPos(0, yOffset)
            catHeader:SetSize(menuW - 60, 40)
            
            catHeader.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, colors.header)
                surface.SetDrawColor(cat.color)
                surface.DrawRect(0, 0, 4, h)
                
                draw.SimpleText(cat.name, "DermaDefaultBold", 15, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            yOffset = yOffset + 50
            
            -- Кейбинды категории
            for _, keybind in ipairs(categoryData.keybinds) do
                local keybindPanel = vgui.Create("DPanel", scrollPanel)
                keybindPanel:SetPos(0, yOffset)
                keybindPanel:SetSize(menuW - 60, 60)
                
                keybindPanel.Paint = function(self, w, h)
                    local col = self:IsHovered() and colors.panelHover or colors.panel
                    draw.RoundedBox(8, 0, 0, w, h, col)
                    
                    -- Описание
                    draw.SimpleText(keybind.name, "DermaDefaultBold", 20, h/2 - 8, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    -- Подсказка
                    local hint = "ID: " .. keybind.id
                    draw.SimpleText(hint, "DermaDefault", 20, h/2 + 10, colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                -- Кнопка бинда
                local bindBtn = vgui.Create("DButton", keybindPanel)
                bindBtn:SetSize(140, 40)
                bindBtn:SetPos(menuW - 220, 10)
                bindBtn:SetText("")
                
                bindBtn.Paint = function(self, w, h)
                    local isWaiting = awaitingKey == keybind.id
                    local col = isWaiting and colors.accent or (self:IsHovered() and colors.accentHover or colors.border)
                    
                    draw.RoundedBox(8, 0, 0, w, h, col)
                    
                    local keyText = isWaiting and "Нажмите клавишу..." or input.GetKeyName(keybind.key)
                    local textCol = isWaiting and colors.background or colors.text
                    
                    draw.SimpleText(keyText, "DermaDefaultBold", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                bindBtn.DoClick = function()
                    awaitingKey = keybind.id
                end
                
                yOffset = yOffset + 70
            end
        end
    end
    
    -- Кнопка сброса настроек
    local resetBtn = vgui.Create("DButton", menuPanel)
    resetBtn:SetSize(200, 45)
    resetBtn:SetPos(menuW/2 - 100, menuH - 65)
    resetBtn:SetText("")
    
    resetBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(200, 80, 80) or Color(150, 60, 60)
        draw.RoundedBox(8, 0, 0, w, h, col)
        draw.SimpleText("Сбросить настройки", "DermaDefaultBold", w/2, h/2, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    resetBtn.DoClick = function()
        for _, keybind in ipairs(LOTM.Keybinds) do
            cookie.Delete("lotm_keybind_" .. keybind.id)
        end
        LOTM.LoadKeybinds()
        LOTM.CreateKeybindMenu()
    end
end

-- Обработчик нажатия клавиш для изменения биндов
hook.Add("PlayerBindPress", "LOTM_KeybindCapture", function(ply, bind, pressed)
    if awaitingKey and menuOpen then
        return true
    end
end)

hook.Add("OnPlayerChat", "LOTM_KeybindCaptureChat", function(ply, text)
    if awaitingKey and menuOpen then
        return true
    end
end)

-- Обработчик нажатия клавиш
hook.Add("Think", "LOTM_KeybindInput", function()
    if awaitingKey and menuOpen then
        for key = KEY_FIRST, KEY_LAST do
            if input.IsKeyDown(key) and key ~= KEY_ESCAPE then
                for _, keybind in ipairs(LOTM.Keybinds) do
                    if keybind.id == awaitingKey then
                        keybind.key = key
                        LOTM.SaveKeybind(keybind.id, key)
                        awaitingKey = nil
                        surface.PlaySound("buttons/button15.wav")
                        break
                    end
                end
                break
            end
        end
        
        if input.IsKeyDown(KEY_ESCAPE) then
            awaitingKey = nil
            surface.PlaySound("buttons/button10.wav")
        end
    end
end)

-- Открытие/закрытие меню по F4
hook.Add("PlayerButtonDown", "LOTM_OpenKeybindMenu", function(ply, button)
    if button == KEY_F4 then
        if not menuOpen then
            LOTM.CreateKeybindMenu()
            menuOpen = true
        else
            if IsValid(menuPanel) then
                menuPanel:AlphaTo(0, 0.15, 0, function()
                    menuPanel:Remove()
                end)
            end
            menuOpen = false
        end
    end
    
    -- Проверка кейбиндов способностей
    if not menuOpen then
        for _, keybind in ipairs(LOTM.Keybinds) do
            if button == keybind.key then
                hook.Run("LOTM_KeybindPressed", keybind.id)
                
                -- Для способностей - запрос атаки
                if string.StartWith(keybind.id, "ability_") then
                    local abilityNum = tonumber(string.sub(keybind.id, -1))
                    if abilityNum then
                        -- Здесь можно добавить логику вызова способности
                        chat.AddText(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Способность " .. abilityNum .. " активирована!")
                    end
                end
                
                break
            end
        end
    end
end)

-- Загрузка кейбиндов при инициализации
LOTM.LoadKeybinds()

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Keybind Menu loaded (F4 to open)\n")