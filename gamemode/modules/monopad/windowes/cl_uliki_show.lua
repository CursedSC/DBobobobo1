local PANEL = {}
local minimumMessageY = dbtPaint.HightSource(50)
local bgColor = Color(29,29,29,255)
local extraColor = Color(152,49,184,255)
local bgColor2 = Color(48,48,48,255)
local borderColor = Color(73,73,73)
local textColor = Color(160,160,160)
local textColor2 = Color(160,160,160, 200)
local contactColor = Color(37,37,37)
local msgColor = Color(37,37,37, 200)
local msgColor2 = Color(47,47,47, 200)
local textEntryColor = Color(40,40,40)
local placeHolderColor = Color(160,160,160, 100)
local selectedColor = Color(145,0,190, 255)
local utfLenToSub = 11
local checkboxColor = Color(46, 46, 46, 255)

local photoMat = Material("dbt/monopad/Photo.png")
local xMat = Material("dbt/monopad/X.png")
local msgMat = Material("dbt/monopad/Evidence.png")
local paternMat = Material("dbt/monopad/bguliki.png")
local evd_show = Material("dbt/monopad/evd_show.png")
local sizeEvBox = 106
local getTimeFrom = function(int)
    local globaltime = int
    local    s = globaltime % 60
    local    tmp = math.floor( globaltime / 60 )
    local    m = tmp % 60
    local    tmp = math.floor( tmp / 60 )
    local    h = tmp % 24

    local    days = math.floor( tmp / 24 )

    return string.format( "%02i:%02i", h, m), h, math.floor(days)
end

function PANEL:Init()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2)
    self.ActiveChat = "chat"
    self.NameToID = {}
	self:SetFocusTopLevel( true )

	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetScreenLock( true )
	self:SetDeleteOnClose( true )

	self:SetMinWidth( 50 )
	self:SetMinHeight( 50 )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
    self:ShowCloseButton(false)
	self.m_fCreateTime = SysTime()

	self.CloseB = vgui.Create( "DButton", self )
	self.CloseB:SetText( "" )
    self.CloseB:SetSize(dbtPaint.WidthSource(41), dbtPaint.HightSource(21))
    self.CloseB:SetPos(dbtPaint.WidthSource(279 - 41), 0)
	self.CloseB.DoClick = function ( button ) self:Close() end
	self.CloseB.Paint = function( panel, w, h )
        draw.RoundedBox(0,0,0,w,h,borderColor)
        draw.RoundedBox(0,1,1,w-2,h-2,bgColor2)
        dbtPaint.DrawRect(xMat, w / 2 - 5.5, h / 2 - 5.5, 11, 11, color_white)
    end

    self.EvDesc = vgui.Create( "DScrollPanel", self )
    self.EvDesc:SetSize(dbtPaint.WidthSource(275), dbtPaint.HightSource(198))
    self.EvDesc:SetPos(dbtPaint.WidthSource(1), dbtPaint.HightSource(107))

    local sbar = self.EvDesc:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0,w / 2,0,2,h,borderColor)
    end



end

function PANEL:OnClose()
    self.patentEx.TableOfOpennedEv[self.evidiceMeta.id_ev] = nil
end
--img

function PANEL:SetInfo(evidiceMeta)
    PrintTable(evidiceMeta)
    self.evidiceMeta = evidiceMeta
    local x, y = surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(115), "Comfortaa Light X24", {textColor, "Локация: ", true, textColor, "Неизвестно", true, true, textColor, "Описание:", true, self.evidiceMeta.desc}, dbtPaint.WidthSource(250))

    self.EvDescPanel = vgui.Create( "EditablePanel", self.EvDesc )
    self.EvDescPanel:SetSize(dbtPaint.WidthSource(268), y)
    self.EvDescPanel:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(0))
    self.EvDescPanel.Paint = function(panel, w, h)
        surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(10), "Comfortaa Light X24", {monopad.MainColorC, "Локация: ", true, textColor, self.evidiceMeta.locate or "Неизвестно", true, true, monopad.MainColorC, "Описание:", true, textColor, self.evidiceMeta.desc}, dbtPaint.WidthSource(250))
    end
	local location = self.evidiceMeta.locate or "Неизвестно"
    if self.evidiceMeta.img and self.evidiceMeta.img != "" then
        self.ShowImg = vgui.Create( "DButton", self )
	    self.ShowImg:SetText( "" )
        self.ShowImg:SetAlpha(200)
        self.ShowImg:SetSize(dbtPaint.WidthSource(276), dbtPaint.HightSource(20))
        self.ShowImg:SetPos(dbtPaint.WidthSource(2), dbtPaint.HightSource(300))
	    self.ShowImg.DoClick = function ( button )
            local imgPanel = vgui.Create("EvidenceVPhotoFrame", workPlace)
			surface.PlaySound('monopad_click.mp3')
            imgPanel:SetTitle("")
            imgPanel:SetSize(dbtPaint.WidthSource(279), dbtPaint.HightSource(322))
            imgPanel:Center()
            imgPanel:SetImg(self.evidiceMeta.img)
            imgPanel.name = self.evidiceMeta.name
        end
	    self.ShowImg.Paint = function( panel, w, h )
            draw.RoundedBox(0,0,0,w,h,bgColor2)
            dbtPaint.DrawRect(photoMat, w / 2 - dbtPaint.WidthSource(75), dbtPaint.HightSource(4), dbtPaint.WidthSource(16), dbtPaint.HightSource(14), color_white)
            draw.SimpleText("Посмотреть фото", "Comfortaa Light X21", w / 2 + dbtPaint.WidthSource(16), -3, textColor, TEXT_ALIGN_CENTER)
        end
    end

    if IsClassTrial() then
        self:SetTall(self:GetTall() + dbtPaint.HightSource(22))
        self.Show = vgui.Create( "DButton", self )
	    self.Show:SetText( "" )
        self.Show:SetAlpha(200)
        self.Show:SetSize(dbtPaint.WidthSource(276), dbtPaint.HightSource(20))
        self.Show:SetPos(dbtPaint.WidthSource(2), dbtPaint.HightSource(321))
	    self.Show.DoClick = function ( button )
            if dbt.inventory.info.monopad.meta.edv[self.glav][evidiceMeta.evidiceId].IsShowed then return end
            dbt.inventory.info.monopad.meta.edv[self.glav][evidiceMeta.evidiceId].IsShowed = true
            netstream.Start("dbt/classtrial/evidence_toall", dbt.inventory.info.monopad.meta.edv[self.glav][evidiceMeta.evidiceId], location)
        end
	    self.Show.Paint = function( panel, w, h )
            draw.RoundedBox(0,0,0,w,h,monopad.MainColorC)
            dbtPaint.DrawRect(evd_show, w / 2 - dbtPaint.WidthSource(90), dbtPaint.HightSource(0), dbtPaint.WidthSource(20), dbtPaint.HightSource(20), color_white)
            draw.SimpleText("Предоставить на суде", "Comfortaa Light X21", w / 2 + dbtPaint.WidthSource(16), -3, color_white, TEXT_ALIGN_CENTER)
        end
    end
    --surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(115), "Comfortaa Light X24", {textColor, "Локация: ", true, textColor, "Неизвестно", true, true, textColor, "Описание:", true, self.evidiceMeta.desc}, dbtPaint.WidthSource(250))
end

function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,borderColor)
    draw.RoundedBox(0,1,1,w-2,h-2,bgColor)
    dbtPaint.DrawRect(paternMat, dbtPaint.WidthSource(1), dbtPaint.HightSource(18), dbtPaint.WidthSource(276), dbtPaint.HightSource(303), color_white)
    draw.RoundedBox(0, 1, 1, w - 2, dbtPaint.HightSource(20) - 1, bgColor2)
    draw.RoundedBox(0,0,dbtPaint.HightSource(105), w, 1, borderColor)
    draw.RoundedBox(0,0,dbtPaint.HightSource(20), w, 1, borderColor)

    if self.Dragging then self:RequestFocus() self.IsDragged = true end
    if self.evidiceMeta then
        if self.evidiceMeta.icon and isstring(self.evidiceMeta.icon) then  self.evidiceMeta.icon = Material(self.evidiceMeta.icon) end
        surface.DrawMulticolorText(dbtPaint.WidthSource(95), dbtPaint.HightSource(35), "Comfortaa Light X24", {textColor, self.evidiceMeta.name}, dbtPaint.WidthSource(150))
        if self.evidiceMeta.icon then
            dbtPaint.DrawRect(self.evidiceMeta.icon, dbtPaint.WidthSource(13), dbtPaint.HightSource(30), dbtPaint.WidthSource(62), dbtPaint.HightSource(62), color_white)
        end


    end

end



vgui.Register("EvidenceVFrame", PANEL, "DFrame")
local PANEL = {}

function PANEL:Init()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2)
    self.name = "???"
    self:SetFocusTopLevel(true)
    
    -- Улучшенная система масштабирования
    self.zoomFactor = 1.0 -- Начинаем со 100% размера
    self.minZoom = 0.25   -- Минимальный уровень масштаба (25%)
    self.maxZoom = 4.0    -- Максимальный уровень масштаба (400%)
    self.zoomStep = 0.1   -- Шаг изменения масштаба на одно деление колёсика
    
    -- Улучшенная система панорамирования
    self.panX = 0
    self.panY = 0
    self.isPanning = false
    self.lastMouseX = 0
    self.lastMouseY = 0
    
    -- Сохраняем исходный размер окна (уменьшаем для удобства)
    self.baseWidth = dbtPaint.WidthSource(500)
    self.baseHeight = dbtPaint.HightSource(400)

    self:SetDraggable(true)
    self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
    self:SetMinWidth(300)
    self:SetMinHeight(300)

    -- Отключаем стандартную отрисовку
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
    self:ShowCloseButton(false)
    self.m_fCreateTime = SysTime()

    -- Создаём окно фиксированного размера
    self:SetSize(self.baseWidth, self.baseHeight)
    
    -- Кнопка закрытия
    self.CloseB = vgui.Create("DButton", self)
    self.CloseB:SetText("")
    self.CloseB:SetSize(dbtPaint.WidthSource(41), dbtPaint.HightSource(21))
    self.CloseB:SetPos(self.baseWidth - dbtPaint.WidthSource(41), 0)
    self.CloseB.DoClick = function(button) self:Close() end
    self.CloseB.Paint = function(panel, w, h)
        draw.RoundedBox(0, 0, 0, w, h, borderColor)
        draw.RoundedBox(0, 1, 1, w-2, h-2, bgColor2)
        dbtPaint.DrawRect(xMat, w / 2 - 5.5, h / 2 - 5.5, 11, 11, color_white)
    end
    
    -- Кнопка сброса масштаба
    self.ResetZoomB = vgui.Create("DButton", self)
    self.ResetZoomB:SetText("")
    self.ResetZoomB:SetSize(dbtPaint.WidthSource(80), dbtPaint.HightSource(21))
    self.ResetZoomB:SetPos(self.baseWidth - dbtPaint.WidthSource(125), 0)
    self.ResetZoomB.DoClick = function(button)
        self.zoomFactor = 1.0
        self.panX = 0
        self.panY = 0
        self:CenterImage()
        surface.PlaySound('monopad_click.mp3')
    end
    self.ResetZoomB.Paint = function(panel, w, h)
        draw.RoundedBox(0, 0, 0, w, h, borderColor)
        draw.RoundedBox(0, 1, 1, w-2, h-2, bgColor2)
        draw.SimpleText("Сбросить", "Comfortaa X14", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Панель для отображения содержимого
    self.ContentPanel = vgui.Create("DPanel", self)
    self.ContentPanel:SetPos(1, dbtPaint.HightSource(21))
    self.ContentPanel:SetSize(self.baseWidth - 2, self.baseHeight - dbtPaint.HightSource(22))
    self.ContentPanel.Paint = function(panel, w, h) 
        -- Фон панели
        draw.RoundedBox(0, 0, 0, w, h, bgColor)
        
        -- Отрисовка изображения с текущим масштабом и позицией
        local mat = HTTP_IMG(self.img)
        if not mat or not mat:GetMaterial() then return end
        
        local imgWidth = mat:GetMaterial():Width() * self.zoomFactor
        local imgHeight = mat:GetMaterial():Height() * self.zoomFactor
        
        -- Центрирование изображения, если оно меньше области просмотра
        local xPos = self.panX
        local yPos = self.panY
        
        if imgWidth < w and not self.isPanning then
            xPos = (w - imgWidth) / 2
        end
        
        if imgHeight < h and not self.isPanning then
            yPos = (h - imgHeight) / 2
        end
        
        -- Отрисовка изображения
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat.material)
        surface.DrawTexturedRect(xPos - dbtPaint.WidthSource(60), yPos, imgWidth, imgHeight)
        
        -- Отображение рамки для понимания границ при большом масштабе
        if self.zoomFactor > 1.0 then
            surface.SetDrawColor(255, 255, 255, 20)
            surface.DrawOutlinedRect(xPos, yPos, imgWidth, imgHeight)
        end
    end
    
    -- Обработчики ввода мыши для панорамирования
    self.ContentPanel.OnMousePressed = function(panel, keyCode)
        if keyCode == MOUSE_LEFT then
            self.isPanning = true
            self.lastMouseX, self.lastMouseY = input.GetCursorPos()
            panel:SetCursor("sizeall")
        end
    end
    
    self.ContentPanel.OnMouseReleased = function(panel, keyCode)
        if keyCode == MOUSE_LEFT then
            self.isPanning = false
            panel:SetCursor("arrow")
            
            -- Проверка, чтобы хотя бы часть изображения оставалась видимой
            self:EnsureImageVisible()
        end
    end
    
    self.ContentPanel.Think = function(panel)
        if self.isPanning then
            local x, y = input.GetCursorPos()
            local dx = x - self.lastMouseX
            local dy = y - self.lastMouseY
            
            -- Перемещение изображения без ограничений
            self.panX = self.panX + dx
            self.panY = self.panY + dy
            
            self.lastMouseX = x
            self.lastMouseY = y
        end
    end
    
    -- Эффект подсказки при наведении
    self.ContentPanel.OnCursorEntered = function(panel)
        panel:SetCursor("hand")
    end
    
    self.ContentPanel.OnCursorExited = function(panel)
        if not self.isPanning then
            panel:SetCursor("arrow")
        end
    end
end

-- Центрирование изображения в области просмотра
function PANEL:CenterImage()
    local mat = HTTP_IMG(self.img)
    if not mat or not mat:GetMaterial() then return end
    
    local w, h = self.ContentPanel:GetSize()
    local imgWidth = mat:GetMaterial():Width() * self.zoomFactor
    local imgHeight = mat:GetMaterial():Height() * self.zoomFactor
    
    self.panX = (w - imgWidth) / 2
    self.panY = (h - imgHeight) / 2
end

-- Проверка, что хотя бы часть изображения видна после перетаскивания
function PANEL:EnsureImageVisible()
    local mat = HTTP_IMG(self.img)
    if not mat or not mat:GetMaterial() then return end
    
    local w, h = self.ContentPanel:GetSize()
    local imgWidth = mat:GetMaterial():Width() * self.zoomFactor
    local imgHeight = mat:GetMaterial():Height() * self.zoomFactor
    
    -- Убедимся, что хотя бы 10% изображения всегда видно
    local minVisibleWidth = imgWidth * 0.1
    local minVisibleHeight = imgHeight * 0.1
    
    -- Проверка границ по X
    if self.panX + imgWidth < minVisibleWidth then
        self.panX = minVisibleWidth - imgWidth
    elseif self.panX > w - minVisibleWidth then
        self.panX = w - minVisibleWidth
    end
    
    -- Проверка границ по Y
    if self.panY + imgHeight < minVisibleHeight then
        self.panY = minVisibleHeight - imgHeight
    elseif self.panY > h - minVisibleHeight then
        self.panY = h - minVisibleHeight
    end
    
    -- Если изображение меньше области просмотра, центрируем его
    if imgWidth < w then
        self.panX = (w - imgWidth) / 2
    end
    
    if imgHeight < h then
        self.panY = (h - imgHeight) / 2
    end
end

function PANEL:SetImg(img)
    self.img = img
    self.panX = 0
    self.panY = 0
    
    -- Авто-подстройка размера изображения при первой загрузке
    timer.Simple(0.1, function()
        if not IsValid(self) then return end
        
        local mat = HTTP_IMG(self.img)
        if mat and mat:GetMaterial() then
            local imgWidth = mat:GetMaterial():Width()
            local imgHeight = mat:GetMaterial():Height()
            self:SetSize(self.baseWidth, math.Clamp(imgHeight, 0, 400))
            -- Если изображение больше базового размера окна, начинаем с масштаба,
            -- который позволит увидеть всё изображение целиком
            local panelWidth = self.baseWidth - 2
            local panelHeight = self.baseHeight - dbtPaint.HightSource(22)
            
            if imgWidth > panelWidth or imgHeight > panelHeight then
                local scaleX = panelWidth / imgWidth
                local scaleY = panelHeight / imgHeight
                self.zoomFactor = math.min(scaleX, scaleY) * 0.95 -- 5% отступ
            else
                -- Если изображение мелкое, увеличиваем его до более комфортного размера
                local scaleX = panelWidth / imgWidth * 0.8
                local scaleY = panelHeight / imgHeight * 0.8
                self.zoomFactor = math.min(scaleX, scaleY)
            end
            
            -- Ограничиваем начальный масштаб для очень больших или очень маленьких изображений
            self.zoomFactor = math.Clamp(self.zoomFactor, self.minZoom, 1.5)
            
            -- Центрируем изображение
            self:CenterImage()
        end
    end)
end

-- Обработка масштабирования колёсиком мыши
function PANEL:OnMouseWheeled(delta)
    local oldZoom = self.zoomFactor
    
    -- Подстраиваем масштаб в зависимости от направления колёсика
    self.zoomFactor = math.Clamp(self.zoomFactor + (delta * self.zoomStep), self.minZoom, self.maxZoom)
    
    -- Обновляем только если масштаб действительно изменился
    if oldZoom ~= self.zoomFactor then
        -- Получаем позицию курсора относительно изображения
        local cursorX, cursorY = self.ContentPanel:CursorPos()
        
        -- Рассчитываем новую позицию панорамирования для масштабирования к курсору
        local mat = HTTP_IMG(self.img)
        if mat and mat:GetMaterial() then
            local oldWidth = mat:GetMaterial():Width() * oldZoom
            local oldHeight = mat:GetMaterial():Height() * oldZoom
            local newWidth = mat:GetMaterial():Width() * self.zoomFactor
            local newHeight = mat:GetMaterial():Height() * self.zoomFactor
            
            -- Вычисляем точку относительно которой масштабируем (в процентах от изображения)
            local relX, relY = 0.5, 0.5 -- По умолчанию центр изображения
            
            -- Если курсор над изображением, берём его позицию
            if cursorX >= self.panX and cursorX <= self.panX + oldWidth and
               cursorY >= self.panY and cursorY <= self.panY + oldHeight then
                relX = (cursorX - self.panX) / oldWidth
                relY = (cursorY - self.panY) / oldHeight
            end
            
            -- Применяем новую позицию с учётом сохранения точки под курсором
            self.panX = self.panX - (newWidth - oldWidth) * relX
            self.panY = self.panY - (newHeight - oldHeight) * relY
            
            -- Проверяем видимость изображения
            self:EnsureImageVisible()
        end
    end
    
    return true -- Поглощаем событие
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, borderColor)
    draw.RoundedBox(0, 1, 1, w-2, h-2, bgColor)
    draw.RoundedBox(0, 1, 1, w-2, dbtPaint.HightSource(20)-1, bgColor2)
    draw.RoundedBox(0, 0, dbtPaint.HightSource(20), w, 1, borderColor)

    -- Показываем процент масштабирования в заголовке
    local zoomPercent = math.Round(self.zoomFactor * 100)
    draw.SimpleText(
        "Фото ("..self.name..") - "..zoomPercent.."%", 
        "Comfortaa X20", 
        dbtPaint.WidthSource(5), 
        -1, 
        textColor, 
        TEXT_ALIGN_LEFT
    )

end

vgui.Register("EvidenceVPhotoFrame", PANEL, "DFrame")