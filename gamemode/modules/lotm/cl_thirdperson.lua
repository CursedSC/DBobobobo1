-- LOTM Third Person Camera System v3.0
-- Чёткая камера без размытия и интерполяции

LOTM = LOTM or {}
LOTM.ThirdPerson = LOTM.ThirdPerson or {}

-- ConVars
CreateClientConVar("lotm_thirdperson_enabled", "0", true, false, "Включить третье лицо")
CreateClientConVar("lotm_thirdperson_distance", "100", true, false, "Дистанция камеры")
CreateClientConVar("lotm_thirdperson_height", "10", true, false, "Высота камеры")
CreateClientConVar("lotm_thirdperson_offset", "30", true, false, "Боковое смещение камеры")
CreateClientConVar("lotm_thirdperson_collision", "1", true, false, "Коллизия камеры с миром")

-- Цвета проекта
local colorOutLine = Color(211, 25, 202)
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

function LOTM.ThirdPerson.Enable()
    RunConsoleCommand("lotm_thirdperson_enabled", "1")
    surface.PlaySound("buttons/button14.wav")
end

function LOTM.ThirdPerson.Disable()
    RunConsoleCommand("lotm_thirdperson_enabled", "0")
    surface.PlaySound("buttons/button10.wav")
end

function LOTM.ThirdPerson.IsEnabled()
    return GetConVar("lotm_thirdperson_enabled"):GetBool()
end

-- Расчёт позиции камеры (без интерполяции - чёткая картинка)
local function CalculateCameraPosition(ply, viewAngles)
    local eyePos = ply:EyePos()
    local distance = GetConVar("lotm_thirdperson_distance"):GetFloat()
    local height = GetConVar("lotm_thirdperson_height"):GetFloat()
    local sideOffset = GetConVar("lotm_thirdperson_offset"):GetFloat()
    local useCollision = GetConVar("lotm_thirdperson_collision"):GetBool()
    
    local forward = viewAngles:Forward()
    local right = viewAngles:Right()
    local up = Vector(0, 0, 1)
    
    local basePos = eyePos + up * height
    local targetPos = basePos - forward * distance + right * sideOffset
    
    if useCollision then
        local trace = util.TraceLine({
            start = basePos,
            endpos = targetPos,
            filter = ply,
            mask = MASK_SOLID_BRUSHONLY,
        })
        
        if trace.Hit then
            targetPos = trace.HitPos + trace.HitNormal * 5
            
            local minDist = 20
            if basePos:Distance(targetPos) < minDist then
                local dir = (targetPos - basePos):GetNormalized()
                targetPos = basePos + dir * minDist
            end
        end
    end
    
    return targetPos
end

-- Хук калькуляции вида (без интерполяции)
hook.Add("CalcView", "LOTM.ThirdPerson.CalcView", function(ply, pos, angles, fov)
    if not IsValid(ply) or not ply:Alive() then return end
    if not GetConVar("lotm_thirdperson_enabled"):GetBool() then return end
    
    local camPos = CalculateCameraPosition(ply, angles)
    
    return {
        origin = camPos,
        angles = angles,
        fov = fov,
        drawviewer = true,
    }
end)

hook.Add("ShouldDrawLocalPlayer", "LOTM.ThirdPerson.DrawPlayer", function(ply)
    if GetConVar("lotm_thirdperson_enabled"):GetBool() then
        return true
    end
end)

hook.Add("PreDrawViewModel", "LOTM.ThirdPerson.HideVM", function(vm, ply, wep)
    if GetConVar("lotm_thirdperson_enabled"):GetBool() then
        return true
    end
end)

-- Меню настройки камеры (полноэкранное)
function LOTM.ThirdPerson.OpenSettings()
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
    
    local matrixState = {
        dragging = false,
        offsetX = GetConVar("lotm_thirdperson_offset"):GetFloat(),
        height = GetConVar("lotm_thirdperson_height"):GetFloat(),
        distance = GetConVar("lotm_thirdperson_distance"):GetFloat(),
    }
    
    frame.Paint = function(self, w, h)
        if BlurScreen then BlurScreen(24) end
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        if dbtPaint and dbtPaint.DrawRect then
            dbtPaint.DrawRect(CurrentBG, 0, 0, w, h, colorBG)
            dbtPaint.DrawRect(bg_main, 0, 0, w, h, Color(255, 255, 255, 100))
        end
        
        local titleY = dbtPaint and dbtPaint.HightSource(60) or 60
        local subtitleY = dbtPaint and dbtPaint.HightSource(120) or 120
        local lineY = dbtPaint and dbtPaint.HightSource(155) or 155
        
        draw.SimpleText("НАСТРОЙКА КАМЕРЫ", "Comfortaa Bold X60", w / 2, titleY, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("Третье лицо - Матричное управление", "Comfortaa Light X25", w / 2, subtitleY, colorOutLine, TEXT_ALIGN_CENTER)
        
        local lineW = dbtPaint and dbtPaint.WidthSource(400) or 400
        draw.RoundedBox(0, w / 2 - lineW / 2, lineY, lineW, 2, colorOutLine)
        
        local hintY = h - (dbtPaint and dbtPaint.HightSource(100) or 100)
        draw.SimpleText("Перемещайте точку на сетках для настройки камеры", "Comfortaa Light X20", w / 2, hintY, colorTextDim, TEXT_ALIGN_CENTER)
        draw.SimpleText("Левая сетка: смещение и высота | Правая сетка: дистанция", "Comfortaa Light X18", w / 2, hintY + 30, colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    -- Матричная сетка для смещения и высоты
    local matrixSize = dbtPaint and dbtPaint.WidthSource(350) or 350
    local matrixY = dbtPaint and dbtPaint.HightSource(200) or 200
    
    local offsetHeightMatrix = vgui.Create("DPanel", frame)
    offsetHeightMatrix:SetPos(scrw / 2 - matrixSize - (dbtPaint and dbtPaint.WidthSource(100) or 100), matrixY)
    offsetHeightMatrix:SetSize(matrixSize, matrixSize)
    
    offsetHeightMatrix.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorGridBg)
        
        local gridLines = 10
        local cellW = w / gridLines
        local cellH = h / gridLines
        
        surface.SetDrawColor(colorGridLine)
        for i = 1, gridLines - 1 do
            surface.DrawLine(i * cellW, 0, i * cellW, h)
            surface.DrawLine(0, i * cellH, w, i * cellH)
        end
        
        surface.SetDrawColor(colorGridCenter)
        surface.DrawLine(w / 2, 0, w / 2, h)
        surface.DrawLine(w / 2 - 1, 0, w / 2 - 1, h)
        surface.DrawLine(0, h / 2, w, h / 2)
        surface.DrawLine(0, h / 2 - 1, w, h / 2 - 1)
        
        local offsetRange = 100
        local heightRange = 60
        
        local pointX = w / 2 + (matrixState.offsetX / offsetRange) * (w / 2)
        local pointY = h / 2 - (matrixState.height / heightRange) * (h / 2)
        
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 80)
        surface.DrawLine(pointX, 0, pointX, h)
        surface.DrawLine(0, pointY, w, pointY)
        
        local pointSize = 12
        draw.RoundedBox(pointSize / 2, pointX - pointSize / 2, pointY - pointSize / 2, pointSize, pointSize, colorGridPoint)
        draw.RoundedBox(3, pointX - 4, pointY - 4, 8, 8, colorOutLine)
        
        if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = self:CursorPos()
            
            matrixState.offsetX = ((mx / w) - 0.5) * 2 * offsetRange
            matrixState.height = (0.5 - (my / h)) * 2 * heightRange
            
            matrixState.offsetX = math.Clamp(matrixState.offsetX, -offsetRange, offsetRange)
            matrixState.height = math.Clamp(matrixState.height, -heightRange / 2, heightRange / 2)
            
            RunConsoleCommand("lotm_thirdperson_offset", tostring(math.Round(matrixState.offsetX)))
            RunConsoleCommand("lotm_thirdperson_height", tostring(math.Round(matrixState.height)))
        end
        
        draw_border(w, h, colorOutLine, 2)
        
        local labelY = dbtPaint and dbtPaint.HightSource(30) or 30
        draw.SimpleText("СМЕЩЕНИЕ / ВЫСОТА", "Comfortaa Bold X20", w / 2, -labelY, colorOutLine, TEXT_ALIGN_CENTER)
        draw.SimpleText("Влево", "Comfortaa Light X14", 10, h / 2, colorTextDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вправо", "Comfortaa Light X14", w - 10, h / 2, colorTextDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вверх", "Comfortaa Light X14", w / 2, 10, colorTextDim, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вниз", "Comfortaa Light X14", w / 2, h - 10, colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
    
    -- Значения под матрицей
    local labelPanelH = dbtPaint and dbtPaint.HightSource(50) or 50
    local offsetLabel = vgui.Create("DPanel", frame)
    offsetLabel:SetPos(scrw / 2 - matrixSize - (dbtPaint and dbtPaint.WidthSource(100) or 100), matrixY + matrixSize + 10)
    offsetLabel:SetSize(matrixSize, labelPanelH)
    offsetLabel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText("Смещение: " .. math.Round(matrixState.offsetX), "Comfortaa Light X22", 20, h / 2, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Высота: " .. math.Round(matrixState.height), "Comfortaa Light X22", w - 20, h / 2, colorText, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Вертикальная полоса для дистанции
    local distanceBarW = dbtPaint and dbtPaint.WidthSource(80) or 80
    local distanceBarH = matrixSize
    
    local distanceMatrix = vgui.Create("DPanel", frame)
    distanceMatrix:SetPos(scrw / 2 + (dbtPaint and dbtPaint.WidthSource(20) or 20), matrixY)
    distanceMatrix:SetSize(distanceBarW, distanceBarH)
    
    distanceMatrix.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, colorGridBg)
        
        local gridLines = 10
        local cellH = h / gridLines
        
        surface.SetDrawColor(colorGridLine)
        for i = 1, gridLines - 1 do
            surface.DrawLine(0, i * cellH, w, i * cellH)
        end
        
        local minDist, maxDist = 50, 200
        local distRange = maxDist - minDist
        local pointY = h - ((matrixState.distance - minDist) / distRange) * h
        
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        surface.DrawRect(0, pointY, w, h - pointY)
        
        surface.SetDrawColor(colorGridPoint)
        surface.DrawRect(0, pointY - 3, w, 6)
        
        if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = self:CursorPos()
            
            matrixState.distance = maxDist - (my / h) * distRange
            matrixState.distance = math.Clamp(matrixState.distance, minDist, maxDist)
            
            RunConsoleCommand("lotm_thirdperson_distance", tostring(math.Round(matrixState.distance)))
        end
        
        draw_border(w, h, colorOutLine, 2)
        
        local labelY = dbtPaint and dbtPaint.HightSource(30) or 30
        draw.SimpleText("ДИСТАНЦИЯ", "Comfortaa Bold X16", w / 2, -labelY, colorOutLine, TEXT_ALIGN_CENTER)
        draw.SimpleText("Близко", "Comfortaa Light X12", w / 2, h - 5, colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText("Далеко", "Comfortaa Light X12", w / 2, 5, colorTextDim, TEXT_ALIGN_CENTER)
    end
    
    -- Значение дистанции
    local distLabel = vgui.Create("DPanel", frame)
    distLabel:SetPos(scrw / 2 + (dbtPaint and dbtPaint.WidthSource(20) or 20), matrixY + matrixSize + 10)
    distLabel:SetSize(distanceBarW, labelPanelH)
    distLabel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText(tostring(math.Round(matrixState.distance)), "Comfortaa Bold X25", w / 2, h / 2, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Превью игрока
    local previewSize = dbtPaint and dbtPaint.WidthSource(300) or 300
    local previewPanel = vgui.Create("DModelPanel", frame)
    previewPanel:SetPos(scrw / 2 + (dbtPaint and dbtPaint.WidthSource(130) or 130), matrixY)
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
    previewLabel:SetPos(scrw / 2 + (dbtPaint and dbtPaint.WidthSource(130) or 130), matrixY + matrixSize + 10)
    previewLabel:SetSize(previewSize, labelPanelH)
    previewLabel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText("Предпросмотр персонажа", "Comfortaa Light X20", w / 2, h / 2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Дополнительные настройки
    local settingsY = matrixY + matrixSize + (dbtPaint and dbtPaint.HightSource(80) or 80)
    local settingsW = dbtPaint and dbtPaint.WidthSource(600) or 600
    local settingsX = scrw / 2 - settingsW / 2
    local btnH = dbtPaint and dbtPaint.HightSource(50) or 50
    
    -- Переключатель третьего лица
    local toggleBtn = vgui.Create("DButton", frame)
    toggleBtn:SetPos(settingsX, settingsY)
    toggleBtn:SetSize(settingsW, btnH)
    toggleBtn:SetText("")
    
    toggleBtn.Paint = function(self, w, h)
        local enabled = GetConVar("lotm_thirdperson_enabled"):GetBool()
        local hovered = self:IsHovered()
        
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorSettingsPanel)
        draw.RoundedBox(0, 0, 0, 10, h, enabled and Color(100, 255, 100) or Color(255, 100, 100))
        
        draw.SimpleText("Третье лицо", "Comfortaa Light X25", 30, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(enabled and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО", "Comfortaa Bold X25", w - 30, h / 2, enabled and Color(100, 255, 100) or Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    toggleBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        LOTM.ThirdPerson.Toggle()
    end
    toggleBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Переключатель коллизии
    local collisionBtn = vgui.Create("DButton", frame)
    collisionBtn:SetPos(settingsX, settingsY + 60)
    collisionBtn:SetSize(settingsW, btnH)
    collisionBtn:SetText("")
    
    collisionBtn.Paint = function(self, w, h)
        local enabled = GetConVar("lotm_thirdperson_collision"):GetBool()
        local hovered = self:IsHovered()
        
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorSettingsPanel)
        draw.RoundedBox(0, 0, 0, 10, h, hovered and colorSettingsPanelActive or colorOutLine)
        
        draw.SimpleText("Коллизия с миром", "Comfortaa Light X25", 30, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(enabled and "ВКЛ" or "ВЫКЛ", "Comfortaa Bold X25", w - 30, h / 2, enabled and Color(100, 255, 100) or Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    collisionBtn.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local current = GetConVar("lotm_thirdperson_collision"):GetBool()
        RunConsoleCommand("lotm_thirdperson_collision", current and "0" or "1")
    end
    collisionBtn.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Кнопка сброса
    local resetBtn = vgui.Create("DButton", frame)
    resetBtn:SetPos(settingsX, settingsY + 120)
    resetBtn:SetSize(settingsW, btnH)
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
    backButton:SetPos(dbtPaint and dbtPaint.WidthSource(48) or 48, dbtPaint and dbtPaint.HightSource(984) or (scrh - 70))
    backButton:SetSize(dbtPaint and dbtPaint.WidthSource(199) or 199, dbtPaint and dbtPaint.HightSource(55) or 55)
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

LOTM.ThirdPerson.OpenMatrixSettings = LOTM.ThirdPerson.OpenSettings

concommand.Add("lotm_thirdperson_toggle", function()
    LOTM.ThirdPerson.Toggle()
end)

concommand.Add("lotm_thirdperson_settings", function()
    LOTM.ThirdPerson.OpenSettings()
end)

print("[LOTM] Third person camera system loaded (Matrix UI)")
