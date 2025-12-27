-- LOTM Notes System v3.0
-- Система записок зелий с эффектом бумаги
-- Полностью в стиле DBT F4 меню

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.Notes = LOTM.Notes or {}

-- Цвета в стиле DBT F4
local colorOutLine = Color(211, 25, 202)
local colorBG = Color(20, 20, 25, 240)
local colorBGLight = Color(35, 35, 45, 220)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(180, 180, 180)
local colorTextMuted = Color(120, 120, 130)

-- Цвета бумаги (улучшенные)
local colorPaper = Color(248, 240, 228)
local colorPaperDark = Color(210, 200, 185)
local colorInk = Color(35, 30, 25)
local colorInkFaded = Color(90, 80, 70)
local colorSeal = Color(180, 50, 50, 180)

-- Рисование границы
local function draw_border(x, y, w, h, color)
    surface.SetDrawColor(color)
    surface.DrawRect(x, y, w, 1)
    surface.DrawRect(x, y, 1, h)
    surface.DrawRect(x, y + h - 1, w, 1)
    surface.DrawRect(x + w - 1, y, 1, h)
end

-- Данные записок
LOTM.Notes.Data = {
    -- Путь 1 - Fool
    {
        id = "note_fool_seq9",
        title = "Записка о Пути Глупца",
        pathway = 1,
        sequence = 9,
        content = [[
══════════════════════════════════
    ЗЕЛЬЕ ПРОВИДЦА (Seq 9)
    Путь Глупца
══════════════════════════════════

Ингредиенты:
• Кровь Лунной Бабочки
• Пыль Звёздного Камня  
• Эссенция Тумана

Метод приготовления:
Смешать ингредиенты в серебряной
чаше под светом полной луны.
Дать настояться 3 часа.

ПРЕДУПРЕЖДЕНИЕ:
Первый шаг на пути безумия.
Дар предвидения - тяжкое бремя.
══════════════════════════════════
        ]],
    },
    {
        id = "note_fool_seq8",
        title = "Таинственная Записка",
        pathway = 1,
        sequence = 8,
        content = [[
══════════════════════════════════
    ЗЕЛЬЕ КЛОУНА (Seq 8)
    Путь Глупца
══════════════════════════════════

Ингредиенты:
• Сердце Теневой Твари
• Слёзы Лунатика
• Пепел Сожжённых Воспоминаний

Способности:
- Видение сквозь иллюзии
- Контроль эмоций окружающих
- Маскировка ауры

"Улыбка - лучшая маска.
 За ней можно спрятать всё."
══════════════════════════════════
        ]],
    },
    -- Путь 2 - Red Priest
    {
        id = "note_priest_seq9",
        title = "Древний Свиток Жреца",
        pathway = 2,
        sequence = 9,
        content = [[
══════════════════════════════════
    ЗЕЛЬЕ АКОЛИТА (Seq 9)
    Путь Красного Жреца
══════════════════════════════════

Ингредиенты:
• Капля Святой Крови
• Семя Огненного Цветка
• Пепел Феникса

Ритуал:
Проведите ингредиенты над
священным пламенем, произнося
молитву Вечному Огню.

ДАРЫ:
• Исцеление ран
• Чувство зла
• Благословение

"Огонь очищает. Огонь возрождает."
══════════════════════════════════
        ]],
    },
    -- Путь 3 - Warrior
    {
        id = "note_warrior_seq9",
        title = "Боевой Кодекс",
        pathway = 3,
        sequence = 9,
        content = [[
══════════════════════════════════
    ЗЕЛЬЕ ВОИНА (Seq 9)
    Путь Воина
══════════════════════════════════

Ингредиенты:
• Кровь Берсерка
• Железная Эссенция
• Кость Древнего Воина

Приготовление:
Смешать на наковальне во время
ковки оружия. Закалить сталью.

УСИЛЕНИЯ:
• +50% к физической силе
• +30% к выносливости
• Боевые инстинкты

"Клинок - продолжение руки.
 Враг - путь к совершенству."
══════════════════════════════════
        ]],
    },
    -- Универсальные записки
    {
        id = "note_general_warning",
        title = "Предупреждение Магистра",
        pathway = 0,
        sequence = 0,
        content = [[
══════════════════════════════════
    ВАЖНОЕ ПРЕДУПРЕЖДЕНИЕ
══════════════════════════════════

Кто бы ты ни был, читающий это -
запомни главные правила:

1. НИКОГДА не пей зелье прошлой
   последовательности. Это путь
   к безумию и смерти.

2. НЕЛЬЗЯ пропускать более одной
   последовательности. Твоё тело
   не выдержит такого скачка.

3. ПЕРЕВАРИВАНИЕ зелья занимает
   время. Поспешность = гибель.

4. Выбрав ПУТЬ - следуй ему.
   Смена пути невозможна.

══════════════════════════════════
     Будь осторожен, Бейонд.
══════════════════════════════════
        ]],
    },
    {
        id = "note_digestion",
        title = "О Переваривании",
        pathway = 0,
        sequence = 0,
        content = [[
══════════════════════════════════
    ПРОЦЕСС ПЕРЕВАРИВАНИЯ
══════════════════════════════════

После принятия зелья начинается
важнейший этап - Переваривание.

Зелье - это не просто напиток.
Это сущность, которую нужно
УСВОИТЬ и сделать частью себя.

СПОСОБЫ УСКОРЕНИЯ:
• Использование способностей
• Ролевая игра персонажа
• Медитация

ПРИЗНАКИ ЗАВЕРШЕНИЯ:
• Полный контроль над силами
• Отсутствие побочных эффектов
• Чувство единства с путём

НЕ ПРИНИМАЙ НОВОЕ ЗЕЛЬЕ
пока не переварил предыдущее!

══════════════════════════════════
        ]],
    },
}

-- Открыть панель записок
function LOTM.Notes.OpenNotesPanel()
    if IsValid(LOTM.Notes.Frame) then
        LOTM.Notes.Frame:Remove()
        return
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH = 400, 550
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    LOTM.Notes.Frame = frame
    
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.startTime or RealTime())
        draw.RoundedBox(0, 0, 0, w, h, colorBG)
        draw.RoundedBox(0, 0, 0, w, h, colorBG2)
        draw_border(0, 0, w, h, colorOutLine)
        draw.SimpleText("📜 ЗАПИСКИ О ЗЕЛЬЯХ", "Comfortaa Bold X25", w/2, 30, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    frame.startTime = RealTime()
    
    -- Кнопка закрытия
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - 40, 10)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(255, 100, 100) or colorTextDim
        draw.SimpleText("✕", "Comfortaa Bold X20", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
        surface.PlaySound("ui/button_back.mp3")
    end
    
    -- Скролл с записками
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 60)
    scroll:SetSize(frameW - 20, frameH - 80)
    
    -- Получаем путь игрока
    local ply = LocalPlayer()
    local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
    local playerSequence = ply:GetNWInt("LOTM_Sequence", 9)
    
    for _, noteData in ipairs(LOTM.Notes.Data) do
        local noteBtn = vgui.Create("DButton", scroll)
        noteBtn:Dock(TOP)
        noteBtn:DockMargin(0, 0, 0, 5)
        noteBtn:SetTall(60)
        noteBtn:SetText("")
        
        -- Проверка доступности
        local available = true
        local lockReason = ""
        
        if noteData.pathway > 0 and playerPathway > 0 and noteData.pathway ~= playerPathway then
            available = false
            lockReason = "Другой путь"
        end
        
        if noteData.sequence > 0 and noteData.sequence < playerSequence then
            available = false
            lockReason = "Будущая Seq"
        end
        
        local pathwayName = "Универсальная"
        if noteData.pathway > 0 and LOTM.PathwaysList and LOTM.PathwaysList[noteData.pathway] then
            pathwayName = LOTM.PathwaysList[noteData.pathway].name or ("Путь " .. noteData.pathway)
        end
        
        noteBtn.Paint = function(self, w, h)
            local bgColor = available and Color(50, 45, 40, 200) or Color(40, 40, 45, 150)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            if self:IsHovered() then
                draw_border(0, 0, w, h, colorOutLine)
            end
            
            -- Иконка свитка
            draw.SimpleText("📜", "Comfortaa Bold X25", 25, h/2, available and colorPaper or colorTextDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Название
            draw.SimpleText(noteData.title, "DermaDefaultBold", 55, 12, available and colorText or colorTextDim, TEXT_ALIGN_LEFT)
            
            -- Инфо
            local infoText = "Seq " .. (noteData.sequence > 0 and noteData.sequence or "—") .. " | " .. pathwayName
            draw.SimpleText(infoText, "DermaDefault", 55, 30, colorOutLine, TEXT_ALIGN_LEFT)
            
            if not available then
                draw.SimpleText("🔒 " .. lockReason, "DermaDefault", w - 10, h/2, Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        noteBtn.DoClick = function()
            if available then
                LOTM.Notes.OpenNote(noteData)
                surface.PlaySound("ui/button_click.mp3")
            else
                surface.PlaySound("buttons/button10.wav")
            end
        end
        
        noteBtn.OnCursorEntered = function()
            if available then
                surface.PlaySound("ui/ui_but/ui_hover.wav")
            end
        end
    end
    
    -- Закрытие по ESC
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            self:Remove()
            return true
        end
    end
end

-- Открыть конкретную записку с эффектом бумаги
function LOTM.Notes.OpenNote(noteData)
    if IsValid(LOTM.Notes.NoteFrame) then
        LOTM.Notes.NoteFrame:Remove()
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local noteW, noteH = 550, 700
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(noteW, noteH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    LOTM.Notes.NoteFrame = frame
    
    -- Анимация появления
    frame.openProgress = 0
    frame.targetY = frame:GetY()
    frame:SetY(scrh + 50)
    
    -- Эффект бумаги
    frame.paperRotation = math.random(-2, 2)
    frame.shadowOffset = 8
    
    frame.Paint = function(self, w, h)
        -- Анимация
        if self.openProgress < 1 then
            self.openProgress = math.min(1, self.openProgress + FrameTime() * 3)
            local newY = Lerp(self.openProgress, scrh + 50, self.targetY)
            self:SetY(newY)
        end
        
        local rot = self.paperRotation
        
        -- Тень
        draw.RoundedBox(0, self.shadowOffset, self.shadowOffset, w, h, Color(0, 0, 0, 100))
        
        -- Основа бумаги
        draw.RoundedBox(0, 0, 0, w, h, colorPaper)
        
        -- Текстура бумаги (шум)
        for i = 1, 50 do
            local x = math.random(0, w)
            local y = math.random(0, h)
            local size = math.random(1, 3)
            surface.SetDrawColor(colorPaperDark.r, colorPaperDark.g, colorPaperDark.b, math.random(10, 30))
            surface.DrawRect(x, y, size, size)
        end
        
        -- Потёртые края
        surface.SetDrawColor(colorPaperDark)
        for i = 1, 20 do
            local x = math.random(0, w)
            surface.DrawRect(x, 0, math.random(2, 8), math.random(2, 5))
            surface.DrawRect(x, h - math.random(2, 5), math.random(2, 8), math.random(2, 5))
        end
        
        -- Линии бумаги
        surface.SetDrawColor(colorPaperDark.r, colorPaperDark.g, colorPaperDark.b, 30)
        for y = 60, h - 40, 25 do
            surface.DrawRect(40, y, w - 80, 1)
        end
        
        -- Заголовок
        draw.SimpleText(noteData.title, "Comfortaa Bold X25", w/2, 30, colorInk, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Декоративная линия
        surface.SetDrawColor(colorInk.r, colorInk.g, colorInk.b, 100)
        surface.DrawRect(40, 55, w - 80, 2)
        
        -- Печать/штамп
        local stampX, stampY = w - 60, h - 60
        surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100)
        for i = 0, 31 do
            local a1 = (i / 32) * math.pi * 2
            local a2 = ((i+1) / 32) * math.pi * 2
            surface.DrawLine(
                stampX + math.cos(a1) * 25, stampY + math.sin(a1) * 25,
                stampX + math.cos(a2) * 25, stampY + math.sin(a2) * 25
            )
        end
        draw.SimpleText("LOTM", "DermaDefaultBold", stampX, stampY, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Текст записки
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(30, 70)
    scroll:SetSize(noteW - 60, noteH - 140)
    scroll.Paint = function() end
    
    local contentLabel = vgui.Create("DLabel", scroll)
    contentLabel:Dock(TOP)
    contentLabel:SetText(noteData.content)
    contentLabel:SetFont("Comfortaa Light X16")
    contentLabel:SetTextColor(colorInk)
    contentLabel:SetWrap(true)
    contentLabel:SetAutoStretchVertical(true)
    
    -- Кнопка закрытия (крестик в углу)
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(noteW - 35, 5)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(15, 0, 0, w, h, Color(200, 100, 100, 100))
        end
        draw.SimpleText("✕", "Comfortaa Bold X20", w/2, h/2, self:IsHovered() and Color(150, 50, 50) or colorInkFaded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        -- Анимация закрытия
        frame.closeAnim = true
        frame:MoveTo(frame:GetX(), scrh + 100, 0.3, 0, 0.5, function()
            if IsValid(frame) then frame:Remove() end
        end)
        surface.PlaySound("ui/button_back.mp3")
    end
    
    -- Закрытие по ESC
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            self.closeAnim = true
            self:MoveTo(self:GetX(), scrh + 100, 0.3, 0, 0.5, function()
                if IsValid(self) then self:Remove() end
            end)
            surface.PlaySound("ui/button_back.mp3")
            return true
        end
    end
    
    surface.PlaySound("physics/cardboard/cardboard_box_impact_soft1.wav")
end

-- Консольная команда для теста
concommand.Add("lotm_notes", function()
    LOTM.Notes.OpenNotesPanel()
end)

print("[LOTM] Notes System loaded (paper effect)")




