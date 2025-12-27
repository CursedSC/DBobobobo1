-- Custom Character Creator UI
-- UI создания кастомного персонажа с выбором путей LOTM
-- Полностью переработанный дизайн в стиле оригинального F4 меню

local bg_creator = Material("dbt/f4/f4_charselect_bg.png")
local logo = Material("dbt/f4/dbt_logo.png")
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorButtonExit = Color(250, 250, 250, 1)
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorText = Color(255, 255, 255, 100)
local colorPurple = Color(191, 30, 219)
local colorPurpleLight = Color(211, 25, 202)
local colorGold = Color(255, 215, 0)
local colorWhiteAlpha = Color(255, 255, 255, 200)

-- Локальные фоны для создателя персонажа
local tableBG_creator = {
    Material("dbt/f4/bg/f4_bg_1.png"),
    Material("dbt/f4/bg/f4_bg_2.png"),
    Material("dbt/f4/bg/f4_bg_3.png"),
}

-- Данные для создания персонажа
local CharCreatorData = {
    name = "",
    talent = "",
    pathway = nil,
    sequence = 9,
    
    -- Характеристики (генерируются рандомно как в D&D)
    maxHealth = 100,
    maxHungry = 100,
    maxThird = 100,
    maxSleep = 100,
    runSpeed = 195,
    fistsDamage = "5-10",
    maxKG = 20,
    maxInventory = 8,
}

-- Этапы создания
local CreatorStage = {
    PATHWAY_SELECT = 1,  -- Выбор пути
    SEQUENCE_SELECT = 2, -- Выбор последовательности
    INFO_INPUT = 3,      -- Ввод имени и таланта
    STATS_ROLL = 4,      -- Бросок характеристик
}

local CurrentStage = CreatorStage.PATHWAY_SELECT
local CurrentBG_Creator = nil
local SelectedPathwayHover = nil

-- Полные лор-описания всех 22 путей LOTM
local PathwayDescriptions = {
    [1] = { -- Fool
        short = "Путь обмана и судьбы",
        lore = "Глупец видит невидимое. Это путь прорицателей, пророков и манипуляторов судьбой. Вы обретёте силу предсказывать будущее, создавать невероятные совпадения и изменять вероятности. От простых фокусов до контроля над судьбами целых народов - ваш путь полон тайн."
    },
    [2] = { -- Door
        short = "Путь пространства и путешествий",
        lore = "Дверь открывает все пути. Мастера этого пути манипулируют пространством, создают порталы между мирами и путешествуют сквозь измерения. Нет места, куда бы вы не смогли попасть, нет двери, которую не смогли бы открыть."
    },
    [3] = { -- Wheel of Fortune
        short = "Путь удачи и вероятности",
        lore = "Колесо Фортуны вращается вечно. Удача благосклонна к тем, кто идёт этим путём. Вы научитесь видеть нити вероятности и дёргать за них, превращая невозможное в неизбежное. Ваши враги будут спотыкаться, а союзники - преуспевать."
    },
    [4] = { -- Justiciar
        short = "Путь правосудия и порядка",
        lore = "Справедливость должна восторжествовать. Этот путь даёт власть вершить правосудие, карать виновных и защищать невинных. Ваше слово станет законом, ваш приговор - неизбежным. Порядок восторжествует над хаосом."
    },
    [5] = { -- Hanged Man
        short = "Путь тайных знаний",
        lore = "Повешенный видит мир с другой стороны. Путь исследователей древних тайн, хранителей забытых знаний. Вы узнаете то, что скрыто от человечества, обретёте власть над оккультными силами и станете мастером ритуалов."
    },
    [6] = { -- Sun
        short = "Путь света и очищения",
        lore = "Солнце освещает тьму. Путь священников, целителей и воинов света. Ваша сила очищает скверну, исцеляет раны и изгоняет зло. Тьма отступит перед вашим сиянием, а зло сгорит в священном пламени."
    },
    [7] = { -- Visionary
        short = "Путь снов и иллюзий",
        lore = "Провидец живёт между реальностью и сном. Этот путь открывает двери в мир грёз. Манипуляция сознанием, создание совершенных иллюзий, путешествия по снам - всё это станет вашей силой. Реальность станет тем, чем вы её представите."
    },
    [8] = { -- Sailor
        short = "Путь моря и стихий",
        lore = "Моряк покоряет океаны и бури. Повелители погоды, укротители штормов, мастера навигации. Молнии, ураганы, цунами подчинятся вашей воле. Ни одна буря не остановит того, кто идёт по этому пути."
    },
    [9] = { -- Reader
        short = "Путь знаний и магии",
        lore = "Читатель постигает суть вещей через древние тексты. Запретные книги откроют свои секреты, магия рун и заклинаний станет доступна. Знание - это истинная сила, и вы овладеете им в совершенстве."
    },
    [10] = { -- Mystery Pryer
        short = "Путь раскрытия тайн",
        lore = "Исследователь Тайн не оставляет загадок нераскрытыми. Ни одна ложь не ускользнёт от вас, ни одна тайна не останется сокрытой. Вы увидите правду там, где другие видят обман. Прошлое и будущее откроются вашему взору."
    },
    [11] = { -- Apprentice
        short = "Путь творцов и ремесленников",
        lore = "Подмастерье создаёт чудеса своими руками. Артефакты, зелья, магические предметы - ваше ремесло. Вы превратите обычное в легендарное, создадите то, о чём другие даже не мечтали."
    },
    [12] = { -- Marauder
        short = "Путь разрушения и хаоса",
        lore = "Мародёр несёт разрушение врагам. Сила, скорость, ярость - ваше оружие. Вы станете воплощением хаоса на поле боя, неудержимой силой природы. Враги будут бежать, услышав ваше имя."
    },
    [13] = { -- Seer
        short = "Путь прорицания",
        lore = "Провидец знает, что будет. Нити судьбы открываются вашему взору, будущее становится ясным. Вы предскажете катастрофы, предотвратите беды, изменит ход истории одним предсказанием."
    },
    [14] = { -- Hunter
        short = "Путь охотников",
        lore = "Охотник никогда не упускает добычу. Обострённые чувства, непревзойдённая меткость, инстинкты хищника. Вы выследите любого, настигнете врага даже на краю света. От охотника не скрыться."
    },
    [15] = { -- Lawyer
        short = "Путь законов и договоров",
        lore = "Юрист управляет правилами реальности. Контракты, законы, соглашения - ваше оружие. Вы свяжете врагов невидимыми цепями обязательств, создадите законы из ничего. Нарушить договор с вами - значит обречь себя."
    },
    [16] = { -- Bard
        short = "Путь искусства и вдохновения",
        lore = "Бард вдохновляет и очаровывает. Музыка, поэзия, искусство - ваша магия. Вы поднимете дух союзников песней, сломите волю врагов мелодией, очаруете сердца словами. Искусство изменит мир."
    },
    [17] = { -- Red Priest
        short = "Путь войны и завоеваний",
        lore = "Красный Жрец ведёт армии к победе. Стратегия, тактика, вдохновение воинов - ваш дар. Вы превратите толпу в непобедимую армию, слабых в героев. Война - ваша стихия, победа - ваша судьба."
    },
    [18] = { -- Demoness
        short = "Путь соблазна и интриг",
        lore = "Демоница плетёт сети обмана. Соблазн, красота, манипуляция - ваши инструменты. Вы проникнете в сердца врагов, узнаете их секреты, заставите служить своим целям. Ваша красота смертоносна."
    },
    [19] = { -- Planter
        short = "Путь природы и жизни",
        lore = "Сеятель взращивает жизнь. Растения, животные, сама земля подчинятся вашей воле. Вы создадите райские сады или смертоносные джунгли. Жизненная сила течёт через вас, даря власть над природой."
    },
    [20] = { -- Black Emperor
        short = "Путь абсолютной власти",
        lore = "Чёрный Император правит всем. Абсолютная власть, непоколебимая воля, безграничная амбиция. Вы создадите империю, подчините народы, установите свои законы. Весь мир склонится перед вашим величием или сгорит."
    },
    [21] = { -- Hermit
        short = "Путь уединения и мудрости",
        lore = "Отшельник познаёт истину в уединении. Концентрация, медитация, постижение тайн мироздания. Вы обретёте силу, недоступную обычным людям, поймёте суть вещей. В одиночестве - великая сила."
    },
    [22] = { -- Paragon
        short = "Путь совершенства",
        lore = "Образец стремится к абсолютному идеалу. Совершенное тело, совершенный разум, совершенная душа. Вы превзойдёте все человеческие пределы, станете воплощением совершенства. Недостатки будут устранены, слабости преодолены."
    },
}

-- Функция генерации случайных характеристик (D&D стиль - бросок костей)
local function RollStats()
    local stats = {}
    
    -- Здоровье: 80-150 (бросок 8-15 кубиков по 10)
    stats.maxHealth = math.random(8, 15) * 10
    
    -- Голод: 80-150
    stats.maxHungry = math.random(8, 15) * 10
    
    -- Жажда: 80-150
    stats.maxThird = math.random(8, 15) * 10
    
    -- Сон: 80-150
    stats.maxSleep = math.random(8, 15) * 10
    
    -- Скорость: 180-230 (шаг 5)
    stats.runSpeed = math.random(36, 46) * 5
    
    -- Вес: 15-40 кг
    stats.maxKG = math.random(15, 40)
    
    -- Слоты инвентаря: 6-10
    stats.maxInventory = math.random(6, 10)
    
    -- Урон кулаками: случайный диапазон
    local minDmg = math.random(3, 8)
    local maxDmg = minDmg + math.random(5, 12)
    stats.fistsDamage = minDmg .. "-" .. maxDmg
    
    return stats
end

-- Функция отрисовки границы
local function draw_border(w, h, color, size)
    size = size or 1
    draw.RoundedBox(0, 0, 0, w, size, color)
    draw.RoundedBox(0, 0, 0, size, h, color)
    draw.RoundedBox(0, 0, h - size, w, size, color)
    draw.RoundedBox(0, w - size, 0, size, h, color)
end

-- Функция открытия создателя персонажа
function open_custom_character_creator()
    if IsValid(dbt.f4) then dbt.f4:Close() end
    
    local scrw, scrh = ScrW(), ScrH()
    local a = math.random(1, 3)
    CurrentBG_Creator = tableBG_creator[a]
    
    -- Сброс данных только при первом открытии
    if CurrentStage == CreatorStage.PATHWAY_SELECT then
        CharCreatorData = {
            name = "",
            talent = "",
            pathway = nil,
            sequence = 9,
            maxHealth = 100,
            maxHungry = 100,
            maxThird = 100,
            maxSleep = 100,
            runSpeed = 195,
            fistsDamage = "5-10",
            maxKG = 20,
            maxInventory = 8,
        }
        SelectedPathwayHover = nil
    end
    
    dbt.f4 = vgui.Create("DFrame")
    dbt.f4:SetSize(scrw, scrh)
    dbt.f4:SetTitle("")
    dbt.f4:SetDraggable(false)
    dbt.f4:ShowCloseButton(false)
    dbt.f4:MakePopup()
    
    -- Обработка ESC
    dbt.f4.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound('ui/button_back.mp3')
            if CurrentStage == CreatorStage.PATHWAY_SELECT then
                self:Close()
                CurrentStage = CreatorStage.PATHWAY_SELECT
                openseasonselect()
            else
                CurrentStage = CurrentStage - 1
                self:Close()
                open_custom_character_creator()
            end
            return true
        end
    end
    
    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG_Creator, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_creator, 0, 0, w, h)
        
        -- Логотип сверху
        dbtPaint.DrawRect(logo, w / 2 - dbtPaint.WidthSource(298), dbtPaint.HightSource(30), dbtPaint.WidthSource(596), dbtPaint.HightSource(241))
        
        -- Заголовок в зависимости от этапа
        local title = "СОЗДАНИЕ ПЕРСОНАЖА"
        local titleY = dbtPaint.HightSource(285)
        
        if CurrentStage == CreatorStage.PATHWAY_SELECT then
            title = "ВЫБЕРИТЕ ПУТЬ"
        elseif CurrentStage == CreatorStage.SEQUENCE_SELECT then
            title = "ВЫБЕРИТЕ ПОСЛЕДОВАТЕЛЬНОСТЬ"
        elseif CurrentStage == CreatorStage.INFO_INPUT then
            title = "ИНФОРМАЦИЯ О ПЕРСОНАЖЕ"
        elseif CurrentStage == CreatorStage.STATS_ROLL then
            title = "ХАРАКТЕРИСТИКИ"
        end
        
        -- Отрисовка заголовка с тенью
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2 + 2, titleY + 2, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2, titleY, colorPurpleLight, TEXT_ALIGN_CENTER)
    end
    
    -- Создание контента в зависимости от этапа
    CreateStageContent(dbt.f4)
    
    -- Кнопка назад
    local backButton = vgui.Create("DButton", dbt.f4)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.ColorBorder = colorOutLine
    backButton.ColorBorder.a = 0
    
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        if CurrentStage == CreatorStage.PATHWAY_SELECT then
            dbt.f4:Close()
            CurrentStage = CreatorStage.PATHWAY_SELECT
            openseasonselect()
        else
            CurrentStage = CurrentStage - 1
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
    
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    backButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
end

-- Создание контента для текущего этапа
function CreateStageContent(parent)
    if CurrentStage == CreatorStage.PATHWAY_SELECT then
        CreatePathwaySelection(parent)
    elseif CurrentStage == CreatorStage.SEQUENCE_SELECT then
        CreateSequenceSelection(parent)
    elseif CurrentStage == CreatorStage.INFO_INPUT then
        CreateInfoInput(parent)
    elseif CurrentStage == CreatorStage.STATS_ROLL then
        CreateStatsRoll(parent)
    end
end

-- ЭТАП 1: Выбор пути LOTM
function CreatePathwaySelection(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Панель с путями (левая сторона)
    local pathwaysPanel = vgui.Create("DScrollPanel", parent)
    pathwaysPanel:SetPos(dbtPaint.WidthSource(60), dbtPaint.HightSource(360))
    pathwaysPanel:SetSize(dbtPaint.WidthSource(450), dbtPaint.HightSource(560))
    
    local sbar = pathwaysPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(5))
    sbar.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, colorOutLine) end
    
    -- Панель описания пути (правая сторона)
    local descPanel = vgui.Create("DPanel", parent)
    descPanel:SetPos(dbtPaint.WidthSource(540), dbtPaint.HightSource(360))
    descPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(560))
    descPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        draw_border(w, h, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100), 2)
        
        if SelectedPathwayHover and PathwayDescriptions[SelectedPathwayHover] then
            local pathway = LOTM.PathwaysList[SelectedPathwayHover]
            local desc = PathwayDescriptions[SelectedPathwayHover]
            
            -- Заголовок
            draw.SimpleText(pathway.name, "Comfortaa Bold X50", w / 2, dbtPaint.HightSource(40), pathway.color, TEXT_ALIGN_CENTER)
            draw.SimpleText(pathway.nameEn, "Comfortaa Light X30", w / 2, dbtPaint.HightSource(100), colorText, TEXT_ALIGN_CENTER)
            
            -- Линия
            draw.RoundedBox(0, dbtPaint.WidthSource(100), dbtPaint.HightSource(140), w - dbtPaint.WidthSource(200), 2, pathway.color)
            
            -- Краткое описание
            draw.SimpleText(desc.short, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(170), colorGold, TEXT_ALIGN_CENTER)
            
            -- Полное описание (многострочное)
            local wrappedDesc = dbtPaint.WrapText(desc.lore, "Comfortaa Light X22", w - dbtPaint.WidthSource(120))
            local yOffset = dbtPaint.HightSource(220)
            for i, line in ipairs(wrappedDesc) do
                draw.SimpleText(line, "Comfortaa Light X22", w / 2, yOffset, colorWhiteAlpha, TEXT_ALIGN_CENTER)
                yOffset = yOffset + dbtPaint.HightSource(30)
            end
            
            -- Информация о последовательностях
            yOffset = dbtPaint.HightSource(h - 120)
            local seq9 = LOTM.GetSequenceName(pathway.id, 9)
            local seq0 = LOTM.GetSequenceName(pathway.id, 0)
            
            draw.RoundedBox(0, dbtPaint.WidthSource(100), yOffset - dbtPaint.HightSource(20), w - dbtPaint.WidthSource(200), 2, pathway.color)
            draw.SimpleText("Начало пути (Seq 9): " .. seq9, "Comfortaa Light X20", w / 2, yOffset, color_white, TEXT_ALIGN_CENTER)
            draw.SimpleText("Конец пути (Seq 0): " .. seq0, "Comfortaa Light X20", w / 2, yOffset + dbtPaint.HightSource(30), pathway.color, TEXT_ALIGN_CENTER)
        else
            -- Подсказка
            draw.SimpleText("Наведите на путь для просмотра описания", "Comfortaa Light X30", w / 2, h / 2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Создание кнопок путей
    local pathways = LOTM.GetAvailablePathways()
    local buttonHeight = dbtPaint.HightSource(65)
    local spacing = dbtPaint.HightSource(5)
    
    for i, pathway in ipairs(pathways) do
        local pathwayButton = vgui.Create("DButton", pathwaysPanel)
        pathwayButton:SetPos(0, (i - 1) * (buttonHeight + spacing))
        pathwayButton:SetSize(dbtPaint.WidthSource(430), buttonHeight)
        pathwayButton:SetText("")
        
        pathwayButton.ColorBorder = Color(pathway.color.r, pathway.color.g, pathway.color.b, 100)
        pathwayButton.ColorBorder.a = 100
        pathwayButton.glowAlpha = 0
        
        pathwayButton.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            
            -- Анимация
            if hovered then
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 60)
                self.ColorBorder.a = Lerp(FrameTime() * 8, self.ColorBorder.a, 255)
            else
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 0)
                self.ColorBorder.a = Lerp(FrameTime() * 8, self.ColorBorder.a, 100)
            end
            
            -- Фон
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
            
            -- Свечение
            if self.glowAlpha > 0 then
                draw.RoundedBox(0, 0, 0, w, h, Color(pathway.color.r, pathway.color.g, pathway.color.b, self.glowAlpha))
            end
            
            -- Граница
            draw_border(w, h, self.ColorBorder, 2)
            
            -- Акцентная полоса слева
            draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, self.ColorBorder)
            
            -- Текст
            draw.SimpleText(pathway.name, "Comfortaa Bold X30", dbtPaint.WidthSource(20), dbtPaint.HightSource(10), pathway.color, TEXT_ALIGN_LEFT)
            draw.SimpleText(pathway.nameEn, "Comfortaa Light X20", dbtPaint.WidthSource(20), dbtPaint.HightSource(40), colorText, TEXT_ALIGN_LEFT)
            
            -- Стрелка при наведении
            if hovered then
                draw.SimpleText("►", "Comfortaa Bold X35", w - dbtPaint.WidthSource(30), h / 2 - dbtPaint.HightSource(15), pathway.color, TEXT_ALIGN_RIGHT)
            end
        end
        
        pathwayButton.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
            SelectedPathwayHover = pathway.id
        end
        
        pathwayButton.OnCursorExited = function()
            SelectedPathwayHover = nil
        end
        
        pathwayButton.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            CharCreatorData.pathway = pathway.id
            -- Sequence фиксирован на 9 (начальный)
            CharCreatorData.sequence = 9
            CurrentStage = CreatorStage.INFO_INPUT
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
end

-- ЭТАП 2: Ввод информации о персонаже (без выбора последовательности)
function CreateInfoInput(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    local pathway = LOTM.PathwaysList[CharCreatorData.pathway]
    
    -- Информационная панель о выбранном пути
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(370))
    infoPanel:SetSize(dbtPaint.WidthSource(1120), dbtPaint.HightSource(120))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw_border(w, h, pathway.color, 3)
        
        draw.SimpleText("Выбран путь: " .. pathway.name, "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(30), pathway.color, TEXT_ALIGN_CENTER)
        draw.SimpleText("Последовательность 9: " .. LOTM.GetSequenceName(CharCreatorData.pathway, 9), "Comfortaa Light X25", w / 2, dbtPaint.HightSource(75), colorWhiteAlpha, TEXT_ALIGN_CENTER)
    end
    
    -- Поле ввода имени
    local nameLabel = vgui.Create("DLabel", parent)
    nameLabel:SetPos(dbtPaint.WidthSource(500), dbtPaint.HightSource(540))
    nameLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    nameLabel:SetFont("Comfortaa Light X35")
    nameLabel:SetText("Имя персонажа:")
    nameLabel:SetTextColor(color_white)
    
    local nameEntry = vgui.Create("DTextEntry", parent)
    nameEntry:SetPos(dbtPaint.WidthSource(850), dbtPaint.HightSource(535))
    nameEntry:SetSize(dbtPaint.WidthSource(500), dbtPaint.HightSource(50))
    nameEntry:SetFont("Comfortaa Light X30")
    nameEntry:SetText(CharCreatorData.name)
    nameEntry:SetPlaceholderText("Введите имя...")
    nameEntry.OnChange = function(self)
        CharCreatorData.name = self:GetValue()
    end
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        draw_border(w, h, colorOutLine, 2)
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Поле ввода таланта
    local talentLabel = vgui.Create("DLabel", parent)
    talentLabel:SetPos(dbtPaint.WidthSource(500), dbtPaint.HightSource(640))
    talentLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    talentLabel:SetFont("Comfortaa Light X35")
    talentLabel:SetText("Абсолютный талант:")
    talentLabel:SetTextColor(color_white)
    
    local talentEntry = vgui.Create("DTextEntry", parent)
    talentEntry:SetPos(dbtPaint.WidthSource(850), dbtPaint.HightSource(635))
    talentEntry:SetSize(dbtPaint.WidthSource(500), dbtPaint.HightSource(50))
    talentEntry:SetFont("Comfortaa Light X30")
    talentEntry:SetText(CharCreatorData.talent)
    talentEntry:SetPlaceholderText("Абсолютный Талант")
    talentEntry.OnChange = function(self)
        CharCreatorData.talent = self:GetValue()
    end
    talentEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        draw_border(w, h, colorOutLine, 2)
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Подсказка
    local hintPanel = vgui.Create("DPanel", parent)
    hintPanel:SetPos(dbtPaint.WidthSource(500), dbtPaint.HightSource(730))
    hintPanel:SetSize(dbtPaint.WidthSource(850), dbtPaint.HightSource(100))
    hintPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
        draw_border(w, h, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 80), 1)
        
        draw.SimpleText("Характеристики будут сгенерированы случайно на следующем шаге", "Comfortaa Light X22", w / 2, dbtPaint.HightSource(30), colorText, TEXT_ALIGN_CENTER)
        draw.SimpleText("как в настольных RPG (D&D стиль)", "Comfortaa Light X22", w / 2, dbtPaint.HightSource(60), colorText, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(870))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.ColorBorder = colorOutLine
    continueButton.ColorBorder.a = 0
    
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local canContinue = CharCreatorData.name ~= "" and CharCreatorData.talent ~= ""
        
        if not canContinue then
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))
            draw.SimpleText("ЗАПОЛНИТЕ ВСЕ ПОЛЯ", "Comfortaa Bold X30", w / 2, h / 2 - dbtPaint.HightSource(10), Color(150, 150, 150), TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
            
            if hovered then
                self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
                draw_border(w, h, self.ColorBorder)
            else
                self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
            end
            
            draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X40", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
        end
    end
    
    continueButton.DoClick = function()
        if CharCreatorData.name ~= "" and CharCreatorData.talent ~= "" then
            surface.PlaySound('ui/button_click.mp3')
            -- Генерируем характеристики
            local stats = RollStats()
            for k, v in pairs(stats) do
                CharCreatorData[k] = v
            end
            CurrentStage = CreatorStage.STATS_ROLL
            dbt.f4:Close()
            open_custom_character_creator()
        else
            surface.PlaySound('ui/item_info_close.wav')
        end
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 3: Отображение характеристик с возможностью рерола
function CreateStatsRoll(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Иконки характеристик
    local materialIconHealth = Material("dbt/f4/stats_icons/stat_hp.png")
    local materialIconFood = Material("dbt/f4/stats_icons/stat_food.png")
    local materialIconWater = Material("dbt/f4/stats_icons/stat_water.png")
    local materialIconSleep = Material("dbt/f4/stats_icons/stat_sleep.png")
    local materialIconSpeed = Material("dbt/f4/stats_icons/stat_speed.png")
    local materialIconPower = Material("dbt/f4/stats_icons/stat_power.png")
    local materialIconWeight = Material("dbt/f4/stats_icons/stat_weight.png")
    local materialIconSlots = Material("dbt/f4/stats_icons/stat_slots.png")
    
    local stats = {
        {name = "Здоровье", key = "maxHealth", icon = materialIconHealth},
        {name = "Голод", key = "maxHungry", icon = materialIconFood},
        {name = "Жажда", key = "maxThird", icon = materialIconWater},
        {name = "Сон", key = "maxSleep", icon = materialIconSleep},
        {name = "Скорость", key = "runSpeed", icon = materialIconSpeed},
        {name = "Урон кулаками", key = "fistsDamageString", icon = materialIconPower},
        {name = "Макс. вес (кг)", key = "maxKG", icon = materialIconWeight},
        {name = "Слотов инвентаря", key = "maxInventory", icon = materialIconSlots},
    }
    
    -- Панель с характеристиками
    local statsPanel = vgui.Create("DPanel", parent)
    statsPanel:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(370))
    statsPanel:SetSize(dbtPaint.WidthSource(1120), dbtPaint.HightSource(450))
    statsPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw_border(w, h, colorOutLine, 2)
        
        draw.SimpleText("РЕЗУЛЬТАТ БРОСКА", "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(20), colorPurpleLight, TEXT_ALIGN_CENTER)
        
        -- Отображение характеристик
        local yPos = dbtPaint.HightSource(80)
        local leftX = dbtPaint.WidthSource(100)
        local rightX = dbtPaint.WidthSource(600)
        
        for i, stat in ipairs(stats) do
            local xPos = (i <= 4) and leftX or rightX
            local currentY = yPos + ((i <= 4) and (i - 1) or (i - 5)) * dbtPaint.HightSource(85)
            
            -- Иконка
            if stat.icon then
                dbtPaint.DrawRectR(stat.icon, xPos, currentY + stat.icon:Height() / 2, stat.icon:Width(), stat.icon:Height(), 0)
            end
            
            -- Значение
            draw.SimpleText(CharCreatorData[stat.key], "Comfortaa Light X35", xPos + dbtPaint.WidthSource(50), currentY, color_white, TEXT_ALIGN_LEFT)
        end
    end
    
    -- Кнопка реролла
    local rerollButton = vgui.Create("DButton", parent)
    rerollButton:SetPos(dbtPaint.WidthSource(660), dbtPaint.HightSource(850))
    rerollButton:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(70))
    rerollButton:SetText("")
    rerollButton.ColorBorder = colorPurpleLight
    rerollButton.ColorBorder.a = 0
    
    rerollButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and colorButtonActive or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, self.ColorBorder)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("🎲 ПЕРЕБРОСИТЬ", "Comfortaa Bold X35", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
    
    rerollButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        local stats = RollStats()
        for k, v in pairs(stats) do
            CharCreatorData[k] = v
        end
        dbt.f4:Close()
        open_custom_character_creator()
    end
    rerollButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Кнопка принять
    local acceptButton = vgui.Create("DButton", parent)
    acceptButton:SetPos(dbtPaint.WidthSource(980), dbtPaint.HightSource(850))
    acceptButton:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(70))
    acceptButton:SetText("")
    acceptButton.ColorBorder = colorOutLine
    acceptButton.ColorBorder.a = 0
    
    acceptButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200) or colorButtonInactive)
        
        if hovered then
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 255)
            draw_border(w, h, Color(255, 255, 255, 255), 2)
        else
            self.ColorBorder.a = Lerp(FrameTime() * 5, self.ColorBorder.a, 0)
        end
        
        draw.SimpleText("СОЗДАТЬ ПЕРСОНАЖА", "Comfortaa Bold X30", w / 2, h / 2 - dbtPaint.HightSource(10), color_white, TEXT_ALIGN_CENTER)
    end
    
    acceptButton.DoClick = function()
        surface.PlaySound('ui/character_menu.mp3')
        
        -- Отправка данных на сервер
        net.Start("dbt.CustomChar.Create")
        net.WriteTable({
            name = CharCreatorData.name,
            absl = CharCreatorData.talent,
            lotm = {
                pathway = CharCreatorData.pathway,
                sequence = CharCreatorData.sequence,
            },
            maxHealth = CharCreatorData.maxHealth,
            maxHungry = CharCreatorData.maxHungry,
            maxThird = CharCreatorData.maxThird,
            maxSleep = CharCreatorData.maxSleep,
            runSpeed = CharCreatorData.runSpeed,
            fistsDamageString = CharCreatorData.fistsDamage,
            maxKG = CharCreatorData.maxKG,
            maxInventory = CharCreatorData.maxInventory,
        })
        net.SendToServer()
    end
    acceptButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- Вспомогательная функция для переноса текста
dbtPaint = dbtPaint or {}
function dbtPaint.WrapText(text, font, maxWidth)
    surface.SetFont(font)
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""
    
    for i, word in ipairs(words) do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
        local w, h = surface.GetTextSize(testLine)
        
        if w > maxWidth and currentLine ~= "" then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Обработка ответа от сервера
net.Receive("dbt.CustomChar.Create", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    
    if success then
        chat.AddText(Color(0, 255, 0), "[Кастомные персонажи] ", color_white, "Персонаж успешно создан!")
        if IsValid(dbt.f4) then
            dbt.f4:Close()
        end
        -- Сбрасываем этап для следующего создания
        CurrentStage = CreatorStage.PATHWAY_SELECT
        openseasonselect()
    else
        chat.AddText(Color(255, 0, 0), "[Ошибка] ", color_white, message)
    end
end)

print("[Custom Character Creator] UI загружен - ПОЛНЫЙ РЕДИЗАЙН v2.0 с D&D системой и всеми лор-описаниями LOTM")