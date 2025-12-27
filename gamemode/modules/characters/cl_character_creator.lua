-- Система создания персонажей
local PANEL = {}

-- Конфигурация роста
local HEIGHT_CONFIG = {
    min = 150,  -- Минимальный рост в см
    max = 200,  -- Максимальный рост в см
    default = 175,  -- Стандартный рост
    scaleMin = 0.85,  -- Минимальный scale модели (при 150 см)
    scaleMax = 1.15   -- Максимальный scale модели (при 200 см)
}

-- Функция расчета scale на основе роста
local function HeightToScale(height)
    local normalized = (height - HEIGHT_CONFIG.min) / (HEIGHT_CONFIG.max - HEIGHT_CONFIG.min)
    return HEIGHT_CONFIG.scaleMin + (normalized * (HEIGHT_CONFIG.scaleMax - HEIGHT_CONFIG.scaleMin))
end

-- Функция создания UI для создания персонажа
function OpenCharacterCreator()
    if IsValid(CharCreatorFrame) then
        CharCreatorFrame:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local frameW, frameH = scrW * 0.5, scrH * 0.6
    
    CharCreatorFrame = vgui.Create("DFrame")
    CharCreatorFrame:SetSize(frameW, frameH)
    CharCreatorFrame:Center()
    CharCreatorFrame:SetTitle("Создание персонажа")
    CharCreatorFrame:MakePopup()
    CharCreatorFrame:SetDraggable(true)
    CharCreatorFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40, 250))
        draw.RoundedBox(8, 0, 0, w, 30, Color(25, 25, 30, 255))
    end
    
    -- Скролл панель для контента
    local scroll = vgui.Create("DScrollPanel", CharCreatorFrame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)
    
    local contentPanel = vgui.Create("DPanel", scroll)
    contentPanel:Dock(TOP)
    contentPanel:SetTall(frameH - 120)
    contentPanel.Paint = nil
    
    local yPos = 10
    
    -- Заголовок
    local titleLabel = vgui.Create("DLabel", contentPanel)
    titleLabel:SetPos(10, yPos)
    titleLabel:SetSize(frameW - 40, 30)
    titleLabel:SetFont("DermaLarge")
    titleLabel:SetText("Создайте своего персонажа")
    titleLabel:SetTextColor(Color(255, 255, 255))
    yPos = yPos + 40
    
    -- Поле: Имя
    local nameLabel = vgui.Create("DLabel", contentPanel)
    nameLabel:SetPos(10, yPos)
    nameLabel:SetSize(150, 25)
    nameLabel:SetFont("DermaDefault")
    nameLabel:SetText("Имя:")
    nameLabel:SetTextColor(Color(200, 200, 200))
    
    local nameEntry = vgui.Create("DTextEntry", contentPanel)
    nameEntry:SetPos(170, yPos)
    nameEntry:SetSize(frameW - 200, 25)
    nameEntry:SetPlaceholderText("Введите имя персонажа")
    yPos = yPos + 35
    
    -- Поле: Фамилия
    local surnameLabel = vgui.Create("DLabel", contentPanel)
    surnameLabel:SetPos(10, yPos)
    surnameLabel:SetSize(150, 25)
    surnameLabel:SetFont("DermaDefault")
    surnameLabel:SetText("Фамилия:")
    surnameLabel:SetTextColor(Color(200, 200, 200))
    
    local surnameEntry = vgui.Create("DTextEntry", contentPanel)
    surnameEntry:SetPos(170, yPos)
    surnameEntry:SetSize(frameW - 200, 25)
    surnameEntry:SetPlaceholderText("Введите фамилию персонажа")
    yPos = yPos + 35
    
    -- Поле: Рост (слайдер)
    local heightLabel = vgui.Create("DLabel", contentPanel)
    heightLabel:SetPos(10, yPos)
    heightLabel:SetSize(150, 25)
    heightLabel:SetFont("DermaDefault")
    heightLabel:SetText("Рост (см):")
    heightLabel:SetTextColor(Color(200, 200, 200))
    
    local heightValueLabel = vgui.Create("DLabel", contentPanel)
    heightValueLabel:SetPos(170, yPos)
    heightValueLabel:SetSize(100, 25)
    heightValueLabel:SetFont("DermaDefaultBold")
    heightValueLabel:SetText(HEIGHT_CONFIG.default .. " см")
    heightValueLabel:SetTextColor(Color(100, 200, 255))
    
    yPos = yPos + 30
    
    local heightSlider = vgui.Create("DNumSlider", contentPanel)
    heightSlider:SetPos(10, yPos)
    heightSlider:SetSize(frameW - 40, 25)
    heightSlider:SetText("")
    heightSlider:SetMin(HEIGHT_CONFIG.min)
    heightSlider:SetMax(HEIGHT_CONFIG.max)
    heightSlider:SetValue(HEIGHT_CONFIG.default)
    heightSlider:SetDecimals(0)
    heightSlider.OnValueChanged = function(self, value)
        local rounded = math.Round(value)
        heightValueLabel:SetText(rounded .. " см (Scale: " .. string.format("%.2f", HeightToScale(rounded)) .. ")")
    end
    
    yPos = yPos + 40
    
    -- Поле: Описание (многострочное)
    local descLabel = vgui.Create("DLabel", contentPanel)
    descLabel:SetPos(10, yPos)
    descLabel:SetSize(150, 25)
    descLabel:SetFont("DermaDefault")
    descLabel:SetText("Описание:")
    descLabel:SetTextColor(Color(200, 200, 200))
    
    yPos = yPos + 30
    
    local descEntry = vgui.Create("DTextEntry", contentPanel)
    descEntry:SetPos(10, yPos)
    descEntry:SetSize(frameW - 40, 120)
    descEntry:SetMultiline(true)
    descEntry:SetPlaceholderText("Напишите описание вашего персонажа...")
    
    yPos = yPos + 130
    
    -- Кнопка: Создать персонажа
    local createButton = vgui.Create("DButton", CharCreatorFrame)
    createButton:SetPos(10, frameH - 50)
    createButton:SetSize(frameW / 2 - 15, 40)
    createButton:SetText("Создать персонажа")
    createButton:SetFont("DermaDefaultBold")
    createButton.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(50, 150, 50, 255) or Color(40, 120, 40, 255)
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    createButton.DoClick = function()
        local name = string.Trim(nameEntry:GetValue())
        local surname = string.Trim(surnameEntry:GetValue())
        local height = math.Round(heightSlider:GetValue())
        local description = string.Trim(descEntry:GetValue())
        
        -- Валидация
        if name == "" then
            notification.AddLegacy("Введите имя персонажа!", NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        if surname == "" then
            notification.AddLegacy("Введите фамилию персонажа!", NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        if description == "" or #description < 20 then
            notification.AddLegacy("Описание должно содержать минимум 20 символов!", NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        -- Отправка данных на сервер
        netstream.Start("dbt/character/create", {
            name = name,
            surname = surname,
            height = height,
            scale = HeightToScale(height),
            description = description
        })
        
        notification.AddLegacy("Персонаж создаётся...", NOTIFY_GENERIC, 2)
        surface.PlaySound("buttons/button15.wav")
        CharCreatorFrame:Close()
    end
    
    -- Кнопка: Отмена
    local cancelButton = vgui.Create("DButton", CharCreatorFrame)
    cancelButton:SetPos(frameW / 2 + 5, frameH - 50)
    cancelButton:SetSize(frameW / 2 - 15, 40)
    cancelButton:SetText("Отмена")
    cancelButton:SetFont("DermaDefaultBold")
    cancelButton.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(150, 50, 50, 255) or Color(120, 40, 40, 255)
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    cancelButton.DoClick = function()
        CharCreatorFrame:Close()
    end
end

-- Команда для открытия меню создания
concommand.Add("dbt_create_character", function()
    OpenCharacterCreator()
end)

-- Нетворк хук для ответа от сервера
netstream.Hook("dbt/character/created", function(success, message)
    if success then
        notification.AddLegacy(message or "Персонаж успешно создан!", NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button14.wav")
    else
        notification.AddLegacy(message or "Ошибка создания персонажа!", NOTIFY_ERROR, 5)
        surface.PlaySound("buttons/button10.wav")
    end
end)

print("[DBT] Character Creator loaded successfully!")