local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

dbt.AdminFunc["time_system"] = {
    name = "Управление временем",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        
        -- Информационная панель с текущим временем
        local timePanel = vgui.Create("DPanel", frame)
        timePanel:SetPos(weight_source(258, 1920), hight_source(82, 1080))
        timePanel:SetSize(weight_source(650, 1920), hight_source(160, 1080))
        timePanel.Paint = function(self, w, h)
            -- Фон
            draw.RoundedBox(8, 0, 0, w, h, Color(29, 29, 29, 255))
            draw.RoundedBox(8, 2, 2, w-4, h-4, Color(48, 48, 48, 255))
            
            -- Получаем текущие значения времени
            local hours = GetGlobalInt("TimeHours", 0)
            local minutes = GetGlobalInt("TimeMinutes", 0)
            local seconds = GetGlobalInt("TimeSeconds", 0)
            local days = GetGlobalInt("TimeDays", 0)
            
            -- Форматируем время для отображения
            local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            local dayString = "День " .. days
            
            -- Рисуем время
            draw.SimpleText(timeString, "RobotoLight_76", w/2, h/2 - hight_source(15, 1080), Color(145, 0, 190, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(dayString, "RobotoLight_32", w/2, h/2 + hight_source(40, 1080), Color(160, 160, 160, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Индикатор состояния времени
            local running = GetGlobalBool("TimeRunning", true)
            local stateText = running and "Время идёт" or "Время остановлено"
            local stateColor = running and Color(0, 180, 80, 255) or Color(220, 60, 60, 255)
            draw.SimpleText(stateText, "RobotoLight_24", w/2, hight_source(20, 1080), stateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Кнопки управления временем
        CrateMonoButton(weight_source(258, 1920), hight_source(260, 1080), weight_source(210, 1920), hight_source(50, 1080), frame, "Запустить время", function()
            RunConsoleCommand("dbt_time_toggle", "1")
        end, true)
        
        CrateMonoButton(weight_source(478, 1920), hight_source(260, 1080), weight_source(210, 1920), hight_source(50, 1080), frame, "Остановить время", function()
            RunConsoleCommand("dbt_time_toggle", "0")
        end, true)
        
        CrateMonoButton(weight_source(698, 1920), hight_source(260, 1080), weight_source(210, 1920), hight_source(50, 1080), frame, "Сбросить время", function()
            RunConsoleCommand("dbt_time_set", "0")
        end, true)
        
        -- Слайдер скорости времени
        local speedLabel = vgui.Create("DLabel", frame)
        speedLabel:SetPos(weight_source(258, 1920), hight_source(330, 1080))
        speedLabel:SetSize(weight_source(650, 1920), hight_source(30, 1080))
        speedLabel:SetFont("RobotoLight_32")
        speedLabel:SetTextColor(Color(160, 160, 160))
        
        local currentSpeed = GetGlobalInt("speedmultiplier", 24)
        speedLabel:SetText("Скорость времени: " .. currentSpeed .. "x")
        
        timeSpeddSlider = vgui.Create("DNumSlider", frame)
        timeSpeddSlider:SetPos(weight_source(258, 1920), hight_source(370, 1080))
        timeSpeddSlider:SetSize(weight_source(650, 1920), hight_source(30, 1080))
        timeSpeddSlider:SetText("Скорость времени")
        timeSpeddSlider:SetMin(0.1)
        timeSpeddSlider:SetMax(100)
        timeSpeddSlider:SetDecimals(0)
        timeSpeddSlider:SetValue(currentSpeed)
        
        -- Кнопка применения скорости
        CrateMonoButton(weight_source(678, 1920), hight_source(420, 1080), weight_source(230, 1920), hight_source(45, 1080), frame, "Применить", function()
            local speed = math.floor(timeSpeddSlider:GetValue())
            speedLabel:SetText("Скорость времени: " .. speed .. "x")
            RunConsoleCommand("dbt_time_speed", speed)
        end, true)
        
        -- Секция установки конкретного времени 
        local setTimeLabel = vgui.Create("DLabel", frame)
        setTimeLabel:SetPos(weight_source(258, 1920), hight_source(490, 1080))
        setTimeLabel:SetSize(weight_source(650, 1920), hight_source(30, 1080))
        setTimeLabel:SetFont("RobotoLight_32")
        setTimeLabel:SetTextColor(Color(160, 160, 160))
        setTimeLabel:SetText("Установить конкретное время:")
        
        -- Создаем поля ввода времени
        local function CreateInputField(x, y, width, height, min, max, defaultValue)
            local bg = vgui.Create("DPanel", frame)
            bg:SetPos(x, y)
            bg:SetSize(width, height)
            bg.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(29, 29, 29, 255))
                draw.RoundedBox(4, 1, 1, w-2, h-2, Color(48, 48, 48, 255))
            end
            
            local input = vgui.Create("DNumberWang", bg)
            input:SetPos(5, 5)
            input:SetSize(width-10, height-10)
            input:SetMin(min)
            input:SetMax(max)
            input:SetValue(defaultValue)
            input:SetFont("RobotoLight_32")
            input:SetTextColor(Color(255, 255, 255))
            input:SetPaintBackground(false)
            input:SetDrawBorder(false)
            
            return bg, input
        end
        
        local dayBg, dayInput = CreateInputField(
            weight_source(258, 1920), 
            hight_source(530, 1080), 
            weight_source(150, 1920), 
            hight_source(45, 1080), 
            0, 999, 
            math.floor(GetGlobalInt("Time", 0) / 86400)
        )
        
        local hourBg, hourInput = CreateInputField(
            weight_source(418, 1920), 
            hight_source(530, 1080), 
            weight_source(150, 1920), 
            hight_source(45, 1080), 
            0, 23, 
            GetGlobalInt("TimeHours", 0)
        )
        
        local minuteBg, minuteInput = CreateInputField(
            weight_source(578, 1920), 
            hight_source(530, 1080), 
            weight_source(150, 1920), 
            hight_source(45, 1080), 
            0, 59, 
            GetGlobalInt("TimeMinutes", 0)
        )
        
        local secondBg, secondInput = CreateInputField(
            weight_source(738, 1920), 
            hight_source(530, 1080), 
            weight_source(150, 1920), 
            hight_source(45, 1080), 
            0, 59, 
            GetGlobalInt("TimeSeconds", 0)
        )
        
        -- Подписи для полей ввода
        local function CreateLabel(x, y, text)
            local label = vgui.Create("DLabel", frame)
            label:SetPos(x, y)
            label:SetSize(weight_source(150, 1920), hight_source(20, 1080))
            label:SetFont("RobotoLight_18")
            label:SetTextColor(Color(160, 160, 160, 200))
            label:SetText(text)
            label:SetContentAlignment(5) -- CENTER
            return label
        end
        
        CreateLabel(weight_source(258, 1920), hight_source(580, 1080), "Дни")
        CreateLabel(weight_source(418, 1920), hight_source(580, 1080), "Часы")
        CreateLabel(weight_source(578, 1920), hight_source(580, 1080), "Минуты")
        CreateLabel(weight_source(738, 1920), hight_source(580, 1080), "Секунды")
        
        -- Кнопка применения времени
        CrateMonoButton(weight_source(468, 1920), hight_source(600, 1080), weight_source(230, 1920), hight_source(50, 1080), frame, "Применить время", function()
            local days = dayInput:GetValue() or 0
            local hours = hourInput:GetValue() or 0
            local minutes = minuteInput:GetValue() or 0
            local seconds = secondInput:GetValue() or 0
            
            local totalSeconds = days * 86400 + hours * 3600 + minutes * 60 + seconds
            RunConsoleCommand("dbt_time_set", totalSeconds)
        end, true)
        
        -- Кнопки быстрого добавления времени
        CrateMonoButton(weight_source(258, 1920), hight_source(670, 1080), weight_source(210, 1920), hight_source(45, 1080), frame, "+1 час", function()
            RunConsoleCommand("dbt_time_add", "3600")
        end, true)
        
        CrateMonoButton(weight_source(478, 1920), hight_source(670, 1080), weight_source(210, 1920), hight_source(45, 1080), frame, "+6 часов", function()
            RunConsoleCommand("dbt_time_add", "21600")
        end, true)
        
        CrateMonoButton(weight_source(698, 1920), hight_source(670, 1080), weight_source(210, 1920), hight_source(45, 1080), frame, "+1 день", function()
            RunConsoleCommand("dbt_time_add", "86400")
        end, true)
    end,
     
    PaintAdv = function(self, w, h)
        draw.DrawText("Система времени", "RobotoLight_43", weight_source(583, 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
}