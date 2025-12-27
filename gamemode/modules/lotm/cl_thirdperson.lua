-- LOTM Third Person Camera System
<<<<<<< HEAD
-- Система третьего лица с матричной настройкой камеры
=======
-- Приятная камера третьего лица с ограничениями
>>>>>>> d91069482183f2bffeadcd5549a7797711402222

LOTM = LOTM or {}
LOTM.ThirdPerson = LOTM.ThirdPerson or {}

<<<<<<< HEAD
-- ConVars
CreateClientConVar("lotm_thirdperson_enabled", "0", true, false, "Включить третье лицо")
CreateClientConVar("lotm_thirdperson_distance", "100", true, false, "Дистанция камеры")
CreateClientConVar("lotm_thirdperson_height", "10", true, false, "Высота камеры")
CreateClientConVar("lotm_thirdperson_offset", "30", true, false, "Боковое смещение камеры")
CreateClientConVar("lotm_thirdperson_collision", "1", true, false, "Коллизия камеры с миром")

-- Цвета проекта для настроек
local colorOutLine = Color(211, 25, 202)
local colorOutLineSecondary = Color(150, 100, 220)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorText = Color(255, 255, 255, 200)
local colorTextDim = Color(150, 150, 150, 200)
local colorButtonExit = Color(250, 250, 250, 1)
local colorSettingsPanel = Color(0, 0, 0, 170)
local colorSettingsPanelActive = Color(191, 30, 219, 150)
local colorGridBg = Color(20, 20, 25, 240)
local colorGridLine = Color(80, 80, 90, 100)
local colorGridCenter = Color(211, 25, 202, 150)
local colorGridPoint = Color(255, 215, 100, 255)

local bg_main = Material("dbt/f4/f4_main_bg.png")
local tableBG = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Функция отрисовки рамки
local function draw_border(w, h, color, thickness)
    thickness = thickness or 1
    draw.RoundedBox(0, 0, 0, w, thickness, color)
    draw.RoundedBox(0, 0, 0, thickness, h, color)
    draw.RoundedBox(0, 0, h - thickness, w, thickness, color)
    draw.RoundedBox(0, w - thickness, 0, thickness, h, color)
end

-- Переключение третьего лица
function LOTM.ThirdPerson.Toggle()
    local current = GetConVar("lotm_thirdperson_enabled"):GetBool()
    RunConsoleCommand("lotm_thirdperson_enabled", current and "0" or "1")
    
    if not current then
        surface.PlaySound("buttons/button14.wav")
    else
        surface.PlaySound("buttons/button10.wav")
    end
end

-- Включить третье лицо
function LOTM.ThirdPerson.Enable()
    RunConsoleCommand("lotm_thirdperson_enabled", "1")
    surface.PlaySound("buttons/button14.wav")
end

-- Выключить третье лицо
function LOTM.ThirdPerson.Disable()
    RunConsoleCommand("lotm_thirdperson_enabled", "0")
    surface.PlaySound("buttons/button10.wav")
end

-- Проверка, включено ли третье лицо
function LOTM.ThirdPerson.IsEnabled()
    return GetConVar("lotm_thirdperson_enabled"):GetBool()
end

-- Расчёт позиции камеры с коллизией (без размытия)
local function CalculateCameraPosition(ply, viewAngles)
    local eyePos = ply:EyePos()
    local distance = GetConVar("lotm_thirdperson_distance"):GetFloat()
    local height = GetConVar("lotm_thirdperson_height"):GetFloat()
    local sideOffset = GetConVar("lotm_thirdperson_offset"):GetFloat()
    local useCollision = GetConVar("lotm_thirdperson_collision"):GetBool()
    
    -- Направление камеры
    local forward = viewAngles:Forward()
    local right = viewAngles:Right()
    local up = Vector(0, 0, 1)
    
    -- Базовая позиция (немного выше глаз)
    local basePos = eyePos + up * height
    
    -- Целевая позиция камеры
    local targetPos = basePos - forward * distance + right * sideOffset
    
    -- Коллизия с миром
    if useCollision then
        local trace = util.TraceLine({
            start = basePos,
            endpos = targetPos,
            filter = ply,
            mask = MASK_SOLID_BRUSHONLY,
        })
        
        if trace.Hit then
            -- Отступаем от стены
            targetPos = trace.HitPos + trace.HitNormal * 5
            
            -- Минимальная дистанция от игрока
            local minDist = 20
            if basePos:Distance(targetPos) < minDist then
                local dir = (targetPos - basePos):GetNormalized()
                targetPos = basePos + dir * minDist
            end
        end
    end
    
    return targetPos
end

-- Главный хук калькуляции вида (без интерполяции - чёткая картинка)
hook.Add("CalcView", "LOTM.ThirdPerson.CalcView", function(ply, pos, angles, fov)
    if not IsValid(ply) or not ply:Alive() then return end
    if not GetConVar("lotm_thirdperson_enabled"):GetBool() then return end
    
    -- Рассчитываем позицию камеры напрямую без интерполяции
    local camPos = CalculateCameraPosition(ply, angles)
    
    return {
        origin = camPos,
        angles = angles,
        fov = fov,
        drawviewer = true,
    }
end)

-- Отображение игрока в третьем лице
hook.Add("ShouldDrawLocalPlayer", "LOTM.ThirdPerson.DrawPlayer", function(ply)
    if GetConVar("lotm_thirdperson_enabled"):GetBool() then
        return true
    end
end)

-- Скрыть viewmodel в третьем лице
hook.Add("PreDrawViewModel", "LOTM.ThirdPerson.HideVM", function(vm, ply, wep)
    if GetConVar("lotm_thirdperson_enabled"):GetBool() then
        return true
    end
end)

-- =============================================
-- МАТРИЧНАЯ ПАНЕЛЬ НАСТРОЙКИ КАМЕРЫ
-- =============================================

function LOTM.ThirdPerson.OpenMatrixSettings()
    local scrw, scrh = ScrW(), ScrH()
    
    if IsValid(LOTM.ThirdPerson.SettingsFrame) then
        LOTM.ThirdPerson.SettingsFrame:Close()
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
    LOTM.ThirdPerson.SettingsFrame = frame
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            self:Close()
            return true
        end
    end
    
    -- Состояние матрицы
    local matrixState = {
        dragging = false,
        offsetX = GetConVar("lotm_thirdperson_offset"):GetFloat(),
        height = GetConVar("lotm_thirdperson_height"):GetFloat(),
        distance = GetConVar("lotm_thirdperson_distance"):GetFloat(),
    }
    
    frame.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 100))
        
        -- Заголовок
        draw.SimpleText("НАСТРОЙКА КАМЕРЫ", "Comfortaa Bold X60", w / 2, dbtPaint.HightSource(60), color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("Третье лицо - Матричное управление", "Comfortaa Light X25", w / 2, dbtPaint.HightSource(120), colorOutLine, TEXT_ALIGN_CENTER)
        
        -- Декоративная линия
        local lineW = dbtPaint.WidthSource(400)
        draw.RoundedBox(0, w / 2 - lineW / 2, dbtPaint.HightSource(155), lineW, 2, colorOutLine)
        
        -- Подсказки
        draw.SimpleText("Перемещайте точку на сетках для настройки камеры", "Comfortaa Light X20", w / 2, h - dbtPaint.HightSource(100), colorTextDim, TEXT_ALIGN_CENTER)
        draw.SimpleText("Левая сетка: смещение и высота | Правая сетка: дистанция", "Comfortaa Light X18", w / 2, h - dbtPaint.HightSource(70), colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- Матричная сетка для смещения и высоты
    -- =============================================
    local matrixSize = dbtPaint.WidthSource(400)
    local matrixY = dbtPaint.HightSource(200)
    
    local offsetHeightMatrix = vgui.Create("DPanel", frame)
    offsetHeightMatrix:SetPos(scrw / 2 - matrixSize - dbtPaint.WidthSource(50), matrixY)
    offsetHeightMatrix:SetSize(matrixSize, matrixSize)
    
    offsetHeightMatrix.Paint = function(self, w, h)
        -- Фон
        draw.RoundedBox(4, 0, 0, w, h, colorGridBg)
        
        -- Сетка
        local gridLines = 10
        local cellW = w / gridLines
        local cellH = h / gridLines
        
        surface.SetDrawColor(colorGridLine)
        for i = 1, gridLines - 1 do
            -- Вертикальные линии
            surface.DrawLine(i * cellW, 0, i * cellW, h)
            -- Горизонтальные линии
            surface.DrawLine(0, i * cellH, w, i * cellH)
        end
        
        -- Центральные оси
        surface.SetDrawColor(colorGridCenter)
        surface.DrawLine(w / 2, 0, w / 2, h)
        surface.DrawLine(w / 2 - 1, 0, w / 2 - 1, h)
        surface.DrawLine(0, h / 2, w, h / 2)
        surface.DrawLine(0, h / 2 - 1, w, h / 2 - 1)
        
        -- Текущая позиция точки
        local offsetRange = 100 -- -100 до +100
        local heightRange = 60 -- -30 до +30
        
        local pointX = w / 2 + (matrixState.offsetX / offsetRange) * (w / 2)
        local pointY = h / 2 - (matrixState.height / heightRange) * (h / 2)
        
        -- Линии к точке
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 80)
        surface.DrawLine(pointX, 0, pointX, h)
        surface.DrawLine(0, pointY, w, pointY)
        
        -- Точка
        local pointSize = 12
        surface.SetDrawColor(colorGridPoint)
        draw.RoundedBox(pointSize / 2, pointX - pointSize / 2, pointY - pointSize / 2, pointSize, pointSize, colorGridPoint)
        
        -- Внутренняя точка
        draw.RoundedBox(3, pointX - 4, pointY - 4, 8, 8, colorOutLine)
        
        -- Обработка ввода
        if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = self:CursorPos()
            
            -- Преобразуем позицию мыши в значения
            matrixState.offsetX = ((mx / w) - 0.5) * 2 * offsetRange
            matrixState.height = (0.5 - (my / h)) * 2 * heightRange
            
            -- Ограничиваем
            matrixState.offsetX = math.Clamp(matrixState.offsetX, -offsetRange, offsetRange)
            matrixState.height = math.Clamp(matrixState.height, -heightRange / 2, heightRange / 2)
            
            -- Применяем
            RunConsoleCommand("lotm_thirdperson_offset", tostring(math.Round(matrixState.offsetX)))
            RunConsoleCommand("lotm_thirdperson_height", tostring(math.Round(matrixState.height)))
        end
        
        -- Рамка
        draw_border(w, h, colorOutLine, 2)
        
        -- Метки
        draw.SimpleText("СМЕЩЕНИЕ / ВЫСОТА", "Comfortaa Bold X20", w / 2, -dbtPaint.HightSource(30), colorOutLine, TEXT_ALIGN_CENTER)
        draw.SimpleText("Влево", "Comfortaa Light X14", dbtPaint.WidthSource(10), h / 2, colorTextDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вправо", "Comfortaa Light X14", w - dbtPaint.WidthSource(10), h / 2, colorTextDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вверх", "Comfortaa Light X14", w / 2, dbtPaint.HightSource(10), colorTextDim, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вниз", "Comfortaa Light X14", w / 2, h - dbtPaint.HightSource(10), colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
    
    -- Значения под матрицей смещения
    local offsetLabel = vgui.Create("DPanel", frame)
    offsetLabel:SetPos(scrw / 2 - matrixSize - dbtPaint.WidthSource(50), matrixY + matrixSize + dbtPaint.HightSource(10))
    offsetLabel:SetSize(matrixSize, dbtPaint.HightSource(50))
    offsetLabel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        
        draw.SimpleText("Смещение: ", "Comfortaa Light X22", dbtPaint.WidthSource(20), h / 2, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(math.Round(matrixState.offsetX)), "Comfortaa Bold X22", dbtPaint.WidthSource(130), h / 2, colorOutLine, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        draw.SimpleText("Высота: ", "Comfortaa Light X22", w / 2 + dbtPaint.WidthSource(20), h / 2, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(math.Round(matrixState.height)), "Comfortaa Bold X22", w / 2 + dbtPaint.WidthSource(110), h / 2, colorOutLine, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- Вертикальная полоса для дистанции
    -- =============================================
    local distanceBarW = dbtPaint.WidthSource(80)
    local distanceBarH = matrixSize
    
    local distanceMatrix = vgui.Create("DPanel", frame)
    distanceMatrix:SetPos(scrw / 2 + dbtPaint.WidthSource(50), matrixY)
    distanceMatrix:SetSize(distanceBarW, distanceBarH)
    
    distanceMatrix.Paint = function(self, w, h)
        -- Фон
        draw.RoundedBox(4, 0, 0, w, h, colorGridBg)
        
        -- Сетка
        local gridLines = 10
        local cellH = h / gridLines
        
        surface.SetDrawColor(colorGridLine)
        for i = 1, gridLines - 1 do
            surface.DrawLine(0, i * cellH, w, i * cellH)
        end
        
        -- Текущая позиция
        local minDist, maxDist = 50, 200
        local distRange = maxDist - minDist
        local pointY = h - ((matrixState.distance - minDist) / distRange) * h
        
        -- Заполнение
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(0, pointY, w, h - pointY)
        
        -- Линия-указатель
        surface.SetDrawColor(colorGridPoint)
        surface.DrawRect(0, pointY - 3, w, 6)
        
        -- Обработка ввода
        if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = self:CursorPos()
            
            -- Преобразуем позицию мыши в дистанцию
            matrixState.distance = maxDist - (my / h) * distRange
            matrixState.distance = math.Clamp(matrixState.distance, minDist, maxDist)
            
            RunConsoleCommand("lotm_thirdperson_distance", tostring(math.Round(matrixState.distance)))
        end
        
        -- Рамка
        draw_border(w, h, colorOutLine, 2)
        
        -- Метка
        draw.SimpleText("ДИСТАНЦИЯ", "Comfortaa Bold X16", w / 2, -dbtPaint.HightSource(30), colorOutLine, TEXT_ALIGN_CENTER)
        draw.SimpleText("Близко", "Comfortaa Light X12", w / 2, h - dbtPaint.HightSource(5), colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText("Далеко", "Comfortaa Light X12", w / 2, dbtPaint.HightSource(5), colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    -- Значение дистанции
    local distLabel = vgui.Create("DPanel", frame)
    distLabel:SetPos(scrw / 2 + dbtPaint.WidthSource(50), matrixY + matrixSize + dbtPaint.HightSource(10))
    distLabel:SetSize(distanceBarW, dbtPaint.HightSource(50))
    distLabel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText(tostring(math.Round(matrixState.distance)), "Comfortaa Bold X25", w / 2, h / 2, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- Превью игрока (справа)
    -- =============================================
    local previewSize = dbtPaint.WidthSource(350)
    local previewPanel = vgui.Create("DModelPanel", frame)
    previewPanel:SetPos(scrw / 2 + dbtPaint.WidthSource(180), matrixY)
    previewPanel:SetSize(previewSize, matrixSize)
    
    previewPanel:SetModel(LocalPlayer():GetModel())
    previewPanel:SetFOV(45)
    previewPanel:SetCamPos(Vector(100, 50, 50))
    previewPanel:SetLookAt(Vector(0, 0, 40))
    
    previewPanel.LayoutEntity = function(self, ent)
        ent:SetAngles(Angle(0, RealTime() * 20 % 360, 0))
    end
    
    previewPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorGridBg)
        draw_border(w, h, colorOutLine, 1)
    end
    
    -- Метка превью
    local previewLabel = vgui.Create("DPanel", frame)
    previewLabel:SetPos(scrw / 2 + dbtPaint.WidthSource(180), matrixY + matrixSize + dbtPaint.HightSource(10))
    previewLabel:SetSize(previewSize, dbtPaint.HightSource(50))
    previewLabel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText("Предпросмотр персонажа", "Comfortaa Light X20", w / 2, h / 2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- =============================================
    -- Дополнительные настройки
    -- =============================================
    local settingsY = matrixY + matrixSize + dbtPaint.HightSource(80)
    local settingsW = dbtPaint.WidthSource(600)
    local settingsX = scrw / 2 - settingsW / 2
    
    -- Переключатель третьего лица
    local toggleBtn = vgui.Create("DButton", frame)
    toggleBtn:SetPos(settingsX, settingsY)
    toggleBtn:SetSize(settingsW, dbtPaint.HightSource(50))
    toggleBtn:SetText("")
    
    toggleBtn.Paint = function(self, w, h)
        local enabled = GetConVar("lotm_thirdperson_enabled"):GetBool()
        local hovered = self:IsHovered()
        
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorSettingsPanel)
        draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(10), h, enabled and Color(100, 255, 100) or Color(255, 100, 100))
        
        draw.SimpleText("Третье лицо", "Comfortaa Light X25", dbtPaint.WidthSource(30), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО", "Comfortaa Bold X25", w - dbtPaint.WidthSource(30), h / 2, enabled and Color(100, 255, 100) or Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    toggleBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        LOTM.ThirdPerson.Toggle()
    end
    toggleBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Переключатель коллизии
    local collisionBtn = vgui.Create("DButton", frame)
    collisionBtn:SetPos(settingsX, settingsY + dbtPaint.HightSource(60))
    collisionBtn:SetSize(settingsW, dbtPaint.HightSource(50))
    collisionBtn:SetText("")
    
    collisionBtn.Paint = function(self, w, h)
        local enabled = GetConVar("lotm_thirdperson_collision"):GetBool()
        local hovered = self:IsHovered()
        
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorSettingsPanel)
        draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(10), h, hovered and colorSettingsPanelActive or colorOutLine)
        
        draw.SimpleText("Коллизия с миром", "Comfortaa Light X25", dbtPaint.WidthSource(30), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(enabled and "ВКЛ" or "ВЫКЛ", "Comfortaa Bold X25", w - dbtPaint.WidthSource(30), h / 2, enabled and Color(100, 255, 100) or Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    collisionBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local current = GetConVar("lotm_thirdperson_collision"):GetBool()
        RunConsoleCommand("lotm_thirdperson_collision", current and "0" or "1")
    end
    collisionBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Кнопка сброса
    local resetBtn = vgui.Create("DButton", frame)
    resetBtn:SetPos(settingsX, settingsY + dbtPaint.HightSource(120))
    resetBtn:SetSize(settingsW, dbtPaint.HightSource(50))
    resetBtn:SetText("")
    
    resetBtn.ColorBorder = Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 0)
    resetBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder, 2)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("СБРОСИТЬ НАСТРОЙКИ", "Comfortaa Light X25", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    resetBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        RunConsoleCommand("lotm_thirdperson_distance", "100")
        RunConsoleCommand("lotm_thirdperson_height", "10")
        RunConsoleCommand("lotm_thirdperson_offset", "30")
        RunConsoleCommand("lotm_thirdperson_collision", "1")
        
        matrixState.offsetX = 30
        matrixState.height = 10
        matrixState.distance = 100
    end
    resetBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
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
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
    end
end

-- Обновляем функцию OpenSettings для использования новой матричной версии
LOTM.ThirdPerson.OpenSettings = LOTM.ThirdPerson.OpenMatrixSettings

-- Консольные команды
concommand.Add("lotm_thirdperson_toggle", function()
    LOTM.ThirdPerson.Toggle()
end)

concommand.Add("lotm_thirdperson_settings", function()
    LOTM.ThirdPerson.OpenMatrixSettings()
end)

print("[LOTM] Third person camera system loaded (Matrix UI)")
=======
-- Настройки камеры
LOTM.ThirdPerson.Enabled = false
LOTM.ThirdPerson.Distance = 100
LOTM.ThirdPerson.Height = 20
LOTM.ThirdPerson.SmoothSpeed = 10
LOTM.ThirdPerson.CollisionEnabled = true

-- Текущие значения
local currentDistance = 0
local currentHeight = 0
local targetPos = Vector(0, 0, 0)
local currentPos = Vector(0, 0, 0)

-- Включить/выключить камеру третьего лица
function LOTM.ThirdPerson.Toggle()
    LOTM.ThirdPerson.Enabled = not LOTM.ThirdPerson.Enabled
    
    if LOTM.ThirdPerson.Enabled then
        currentDistance = 0
        currentHeight = 0
    end
end

-- Установить расстояние камеры
function LOTM.ThirdPerson.SetDistance(distance)
    LOTM.ThirdPerson.Distance = math.Clamp(distance, 50, 300)
end

-- Установить высоту камеры
function LOTM.ThirdPerson.SetHeight(height)
    LOTM.ThirdPerson.Height = math.Clamp(height, -50, 100)
end

-- Расчёт позиции камеры
local function CalculateCameraPosition(ply, view)
    if not IsValid(ply) or not ply:Alive() then return view end
    
    local eyePos = ply:EyePos()
    local eyeAngles = view.angles
    
    -- Целевая позиция камеры
    local backward = -eyeAngles:Forward()
    targetPos = eyePos + backward * LOTM.ThirdPerson.Distance + Vector(0, 0, LOTM.ThirdPerson.Height)
    
    -- Проверка коллизий
    if LOTM.ThirdPerson.CollisionEnabled then
        local trace = util.TraceLine({
            start = eyePos,
            endpos = targetPos,
            filter = ply,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if trace.Hit then
            -- Сдвинуть камеру ближе к игроку при столкновении
            targetPos = trace.HitPos + trace.HitNormal * 5
        end
    end
    
    -- Плавное движение камеры
    currentPos = LerpVector(FrameTime() * LOTM.ThirdPerson.SmoothSpeed, currentPos, targetPos)
    
    -- Ограничение от ухода за текстуры
    local mins, maxs = ply:GetCollisionBounds()
    local playerCenter = ply:GetPos() + Vector(0, 0, (maxs.z - mins.z) / 2)
    
    -- Проверка что камера не слишком далеко
    local maxAllowedDistance = LOTM.ThirdPerson.Distance + 50
    if currentPos:Distance(playerCenter) > maxAllowedDistance then
        local direction = (currentPos - playerCenter):GetNormalized()
        currentPos = playerCenter + direction * maxAllowedDistance
    end
    
    -- Финальная проверка что камера не в текстуре
    local finalTrace = util.TraceLine({
        start = eyePos,
        endpos = currentPos,
        filter = ply,
        mask = MASK_SOLID_BRUSHONLY
    })
    
    if finalTrace.StartSolid or finalTrace.AllSolid then
        -- Если камера в стене, вернуть её к игроку
        currentPos = eyePos + Vector(0, 0, 20)
    end
    
    return currentPos
end

-- Хук на калькулятор вида
hook.Add("CalcView", "LOTM.ThirdPersonCamera", function(ply, origin, angles, fov)
    if not LOTM.ThirdPerson.Enabled then return end
    if not IsValid(ply) or not ply:Alive() then return end
    
    local view = {
        origin = origin,
        angles = angles,
        fov = fov,
        drawviewer = true
    }
    
    view.origin = CalculateCameraPosition(ply, view)
    
    return view
end)

-- Команда для переключения камеры
concommand.Add("lotm_thirdperson", function(ply, cmd, args)
    LOTM.ThirdPerson.Toggle()
    
    if LOTM.ThirdPerson.Enabled then
        chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Камера третьего лица включена")
    else
        chat.AddText(Color(255, 0, 0), "[LOTM] ", color_white, "Камера третьего лица выключена")
    end
end)

-- Команды для настройки камеры
concommand.Add("lotm_camera_distance", function(ply, cmd, args)
    local distance = tonumber(args[1]) or 100
    LOTM.ThirdPerson.SetDistance(distance)
    chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Расстояние камеры: " .. distance)
end)

concommand.Add("lotm_camera_height", function(ply, cmd, args)
    local height = tonumber(args[1]) or 20
    LOTM.ThirdPerson.SetHeight(height)
    chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Высота камеры: " .. height)
end)

-- Сброс при смерти
hook.Add("PlayerDeath", "LOTM.ResetThirdPerson", function(ply)
    if ply == LocalPlayer() then
        LOTM.ThirdPerson.Enabled = false
        currentPos = Vector(0, 0, 0)
        targetPos = Vector(0, 0, 0)
    end
end)

print("[LOTM] Система камеры третьего лица загружена")
>>>>>>> d91069482183f2bffeadcd5549a7797711402222
