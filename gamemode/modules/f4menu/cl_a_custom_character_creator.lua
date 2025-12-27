-- Custom Character Creator UI
-- UI создания кастомного персонажа с выбором путей LOTM
-- Стилизация под оригинальное F4 меню с улучшениями

local bg_creator = Material("dbt/f4/f4_charselect_bg.png")
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorBG = Color(255, 255, 255, 60)
local colorButtonExit = Color(250, 250, 250, 1)
local colorOutLine = Color(211, 25, 202)
local colorButtonInactive = Color(0, 0, 0, 100)
local colorButtonActive = Color(0, 0, 0, 200)
local colorText = Color(255, 255, 255, 200)
local colorGold = Color(255, 215, 0)
local colorDarkPurple = Color(75, 0, 130)

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
    
    -- Характеристики (генерируются рандомно)
    maxHealth = 100,
    maxHungry = 100,
    maxThird = 100,
    maxSleep = 100,
    runSpeed = 195,
    fistsDamage = "5-10",
    maxKG = 20,
    maxInventory = 8,
}

-- Лор-описания путей LOTM
local PathwayDescriptions = {
    [1] = { -- Fool
        short = "Путь обмана и возможностей",
        lore = "Глупец видит то, что скрыто от других. Путь полон загадок, тайн и невероятных возможностей. Каждый шаг - это шанс переписать судьбу, каждая карта - новая реальность. Вы станете кукловодом судеб, мастером иллюзий и повелителем вероятностей."
    },
    [2] = { -- Door
        short = "Путь пространства и перемещений",
        lore = "Дверь открывает пути между мирами. Мастера этого пути способны путешествовать сквозь пространство, создавать порталы и манипулировать измерениями. Весь мир становится вашим домом, когда каждая дверь ведёт туда, куда вы пожелаете."
    },
    [3] = { -- Wheel of Fortune
        short = "Путь удачи и вероятности",
        lore = "Колесо Фортуны вращается вечно. Удача и несчастье, победа и поражение - всё подвластно тем, кто идёт этим путём. Вы научитесь видеть нити судьбы и дёргать за них, превращая невозможное в неизбежное."
    },
    [4] = { -- Justiciar
        short = "Путь правосудия и порядка",
        lore = "Справедливость должна восторжествовать. Этот путь даёт силу вершить правосудие, карать виновных и защищать невинных. Ваше слово станет законом, а ваш приговор - неизбежным. Баланс должен быть восстановлен любой ценой."
    },
    [5] = { -- Hanged Man
        short = "Путь тайных знаний",
        lore = "Повешенный видит мир с другой стороны. Путь исследователей древних тайн, хранителей забытых знаний и мастеров оккультизма. Вы узнаете то, что было скрыто от человечества веками, и обретёте власть над неизведанным."
    },
    [6] = { -- Sun
        short = "Путь света и справедливости",
        lore = "Солнце освещает тьму и изгоняет зло. Путь священников, целителей и воинов света. Ваша сила будет очищать скверну, исцелять раны и озарять путь заблудшим. Тьма отступит перед вашим сиянием."
    },
    [7] = { -- Visionary
        short = "Путь сновидений и иллюзий",
        lore = "Провидец живёт между реальностью и сном. Этот путь открывает двери в мир грёз, где возможно всё. Манипуляция сознанием, создание иллюзий, путешествия по снам других - всё это станет вашей силой."
    },
    [8] = { -- Sailor
        short = "Путь моря и приключений",
        lore = "Моряк покоряет стихии. Бури, ураганы, молнии - всё подчинится вашей воле. Вы станете повелителем погоды, укротителем океанов и мастером навигации. Ни одна буря не остановит того, кто идёт по этому пути."
    },
    [9] = { -- Reader
        short = "Путь знаний и магии",
        lore = "Читатель постигает суть вещей. Древние книги откроют вам свои секреты, запретные знания станут доступны. Магия рун, заклинаний и ритуалов - ваше оружие. Знание - это истинная сила."
    },
    [10] = { -- Mystery Pryer
        short = "Путь детективов и провидцев",
        lore = "Исследователь Тайн раскрывает сокрытое. Ни одна загадка не устоит перед вами, ни одна ложь не останется незамеченной. Вы увидите правду там, где другие видят лишь поверхность. Прошлое, настоящее и будущее откроются перед вами."
    },
    [11] = { -- Apprentice
        short = "Путь ремесленников и творцов",
        lore = "Подмастерье создаёт чудеса своими руками. Артефакты, зелья, магические предметы - всё это станет вашим ремеслом. Вы превратите обычное в необычное, создадите то, чего не существовало."
    },
    [12] = { -- Marauder
        short = "Путь разрушения и хаоса",
        lore = "Мародёр несёт разрушение. Сила, скорость, ярость - ваше оружие. Вы станете воплощением хаоса на поле боя, неудержимой силой, сметающей всё на своём пути. Враги будут бежать от одного вашего имени."
    },
    [13] = { -- Seer
        short = "Путь прорицания и судьбы",
        lore = "Провидец знает, что будет. Нити судьбы открываются вашему взору, будущее становится ясным как день. Вы увидите то, что грядёт, и сможете изменить ход событий. Судьба - ваш инструмент."
    },
    [14] = { -- Hunter
        short = "Путь охотников и следопытов",
        lore = "Охотник никогда не упускает добычу. Обострённые чувства, непревзойдённая меткость, инстинкты хищника - всё это ваше. Вы выследите любого, настигнете врага даже на краю света. Побег невозможен."
    },
    [15] = { -- Lawyer
        short = "Путь законов и договоров",
        lore = "Юрист управляет правилами. Контракты, законы, соглашения - ваше оружие. Вы свяжете врагов невидимыми цепями обязательств, создадите законы из ничего. Нарушить договор с вами - значит обречь себя."
    },
    [16] = { -- Bard
        short = "Путь искусства и вдохновения",
        lore = "Бард вдохновляет и очаровывает. Музыка, слова, искусство - ваша магия. Вы поднимете дух союзников, сломите волю врагов, очаруете сердца. Ваше искусство изменит мир."
    },
    [17] = { -- Red Priest
        short = "Путь войны и завоеваний",
        lore = "Красный Жрец ведёт за собой армии. Стратегия, тактика, вдохновение воинов - ваш дар. Вы превратите толпу в непобедимую армию, слабых в героев. Война - ваша стихия, победа - ваша судьба."
    },
    [18] = { -- Demoness
        short = "Путь соблазна и манипуляций",
        lore = "Демоница плетёт интриги. Соблазн, обман, манипуляция - ваши инструменты. Вы проникнете в сердца врагов, узнаете их секреты, заставите служить вашим целям. Красота и хитрость - ваше оружие."
    },
    [19] = { -- Planter
        short = "Путь природы и жизни",
        lore = "Сеятель взращивает жизнь. Растения, природа, сама земля подчинятся вашей воле. Вы создадите райские сады или смертоносные джунгли. Жизненная сила течёт через вас, позволяя творить чудеса природы."
    },
    [20] = { -- Black Emperor
        short = "Путь абсолютной власти",
        lore = "Чёрный Император правит всем. Абсолютная власть, непоколебимая воля, безграничная амбиция. Вы создадите империю, подчините народы, установите свои законы. Весь мир склонится перед вашим величием."
    },
    [21] = { -- Hermit
        short = "Путь отшельничества и знаний",
        lore = "Отшельник познаёт истину в уединении. Концентрация, медитация, постижение тайн мироздания. Вы обретёте силу, недоступную обычным людям, поймёте суть вещей. Одиночество - ваша сила."
    },
    [22] = { -- Paragon
        short = "Путь совершенства",
        lore = "Образец стремится к идеалу. Совершенное тело, совершенный разум, совершенная душа. Вы превзойдёте пределы человеческого, станете воплощением совершенства. Недостатки будут устранены, слабости преодолены."
    },
}

-- Этапы создания
local CreatorStage = {
    PATHWAY_SELECT = 1,  -- Выбор пути
    SEQUENCE_SELECT = 2, -- Выбор последовательности
    INFO_INPUT = 3,      -- Ввод имени и таланта
    STATS_CONFIG = 4,    -- Рандом характеристик
}

local CurrentStage = CreatorStage.PATHWAY_SELECT
local CurrentBG_Creator = nil
local SelectedPathwayHover = nil

-- Функция генерации случайных характеристик (DnD стиль)
local function GenerateRandomStats()
    -- Генерация с небольшим разбросом для баланса
    CharCreatorData.maxHealth = math.random(80, 120)
    CharCreatorData.maxHungry = math.random(80, 120)
    CharCreatorData.maxThird = math.random(80, 120)
    CharCreatorData.maxSleep = math.random(80, 120)
    CharCreatorData.runSpeed = math.random(180, 210)
    CharCreatorData.maxKG = math.random(15, 25)
    CharCreatorData.maxInventory = math.random(6, 10)
    
    -- Урон от кулаков зависит от физических характеристик
    local minDmg = math.random(3, 7)
    local maxDmg = minDmg + math.random(3, 8)
    CharCreatorData.fistsDamage = minDmg .. "-" .. maxDmg
    
    surface.PlaySound('ui/button_click.mp3')
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
            CurrentStage = CreatorStage.PATHWAY_SELECT
            openseasonselect()
            return true
        end
    end
    
    dbt.f4.Paint = function(self, w, h)
        BlurScreen(24)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack)
        draw.RoundedBox(0, 0, 0, w, h, colorBlack2)
        dbtPaint.DrawRect(CurrentBG_Creator, 0, 0, w, h, colorBG)
        dbtPaint.DrawRect(bg_creator, 0, 0, w, h)
        
        -- Заголовок в зависимости от этапа
        local title = "СОЗДАНИЕ ПЕРСОНАЖА"
        local subtitle = ""
        
        if CurrentStage == CreatorStage.PATHWAY_SELECT then
            title = "ВЫБЕРИТЕ СВОЙ ПУТЬ"
            subtitle = "Каждый путь определит вашу судьбу и силы"
        elseif CurrentStage == CreatorStage.SEQUENCE_SELECT then
            title = "ПОСЛЕДОВАТЕЛЬНОСТЬ"
            subtitle = "Выберите вашу начальную силу"
        elseif CurrentStage == CreatorStage.INFO_INPUT then
            title = "ЛИЧНОСТЬ"
            subtitle = "Определите имя и талант вашего персонажа"
        elseif CurrentStage == CreatorStage.STATS_CONFIG then
            title = "ХАРАКТЕРИСТИКИ"
            subtitle = "Судьба определит ваши параметры"
        end
        
        -- Красивый заголовок с подложкой
        draw.RoundedBox(0, 0, 0, w, dbtPaint.HightSource(130), Color(0, 0, 0, 150))
        draw.RoundedBox(0, 0, dbtPaint.HightSource(128), w, 2, colorOutLine)
        
        draw.SimpleText(title, "Comfortaa Bold X60", w / 2, dbtPaint.HightSource(35), color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText(subtitle, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(90), colorText, TEXT_ALIGN_CENTER)
    end
    
    -- Создание контента в зависимости от этапа
    CreateStageContent(dbt.f4)
    
    -- Кнопка назад
    local backButton = vgui.Create("DButton", dbt.f4)
    backButton:SetText("")
    backButton:SetPos(dbtPaint.WidthSource(48), dbtPaint.HightSource(984))
    backButton:SetSize(dbtPaint.WidthSource(199), dbtPaint.HightSource(55))
    backButton.DoClick = function()
        surface.PlaySound('ui/button_back.mp3')
        if CurrentStage == CreatorStage.PATHWAY_SELECT then
            dbt.f4:Close()
            openseasonselect()
        else
            -- Вернуться на предыдущий этап
            CurrentStage = CurrentStage - 1
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
    backButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    backButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorButtonExit.r, colorButtonExit.g, colorButtonExit.b, 50) or colorButtonExit)
        draw.SimpleText("НАЗАД", "Comfortaa Light X40", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER)
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
    elseif CurrentStage == CreatorStage.STATS_CONFIG then
        CreateStatsConfig(parent)
    end
end

-- ЭТАП 1: Выбор пути LOTM
function CreatePathwaySelection(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Скролл панель для путей
    local scrollPanel = vgui.Create("DScrollPanel", parent)
    scrollPanel:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(150))
    scrollPanel:SetSize(dbtPaint.WidthSource(1100), dbtPaint.HightSource(820))
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(dbtPaint.WidthSource(8))
    sbar.Paint = function(self, w, h) 
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    sbar.btnGrip.Paint = function(self, w, h) 
        draw.RoundedBox(0, 0, 0, w, h, colorOutLine) 
    end
    
    -- Панель превью пути справа
    local previewPanel = vgui.Create("DPanel", parent)
    previewPanel:SetPos(dbtPaint.WidthSource(1170), dbtPaint.HightSource(150))
    previewPanel:SetSize(dbtPaint.WidthSource(700), dbtPaint.HightSource(820))
    previewPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.RoundedBox(0, 0, 0, w, 3, colorOutLine)
        
        if SelectedPathwayHover then
            local pathway = LOTM.PathwaysList[SelectedPathwayHover]
            local desc = PathwayDescriptions[SelectedPathwayHover]
            
            if pathway and desc then
                -- Название пути
                draw.SimpleText(pathway.name, "Comfortaa Bold X50", w / 2, dbtPaint.HightSource(40), pathway.color, TEXT_ALIGN_CENTER)
                draw.SimpleText(pathway.nameEn, "Comfortaa Light X30", w / 2, dbtPaint.HightSource(100), Color(colorText.r, colorText.g, colorText.b, 180), TEXT_ALIGN_CENTER)
                
                -- Линия разделитель
                draw.RoundedBox(0, dbtPaint.WidthSource(50), dbtPaint.HightSource(140), w - dbtPaint.WidthSource(100), 2, pathway.color)
                
                -- Краткое описание
                draw.SimpleText(desc.short, "Comfortaa Bold X25", w / 2, dbtPaint.HightSource(180), colorGold, TEXT_ALIGN_CENTER)
                
                -- Лор-описание с переносом
                local wrappedLore = dbtPaint.WrapText(desc.lore, "Comfortaa Light X22", w - dbtPaint.WidthSource(80))
                local yOffset = dbtPaint.HightSource(240)
                for i, line in ipairs(wrappedLore) do
                    draw.SimpleText(line, "Comfortaa Light X22", w / 2, yOffset, color_white, TEXT_ALIGN_CENTER)
                    yOffset = yOffset + dbtPaint.HightSource(32)
                end
                
                -- Информация о последовательностях
                local seq9 = LOTM.GetSequenceName(SelectedPathwayHover, 9)
                local seq0 = LOTM.GetSequenceName(SelectedPathwayHover, 0)
                
                draw.RoundedBox(0, dbtPaint.WidthSource(50), dbtPaint.HightSource(650), w - dbtPaint.WidthSource(100), 2, Color(pathway.color.r, pathway.color.g, pathway.color.b, 100))
                
                draw.SimpleText("ЭВОЛЮЦИЯ СИЛЫ", "Comfortaa Bold X20", w / 2, dbtPaint.HightSource(680), colorGold, TEXT_ALIGN_CENTER)
                draw.SimpleText("Sequence 9: " .. seq9, "Comfortaa Light X20", w / 2, dbtPaint.HightSource(720), color_white, TEXT_ALIGN_CENTER)
                draw.SimpleText("↓", "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(750), pathway.color, TEXT_ALIGN_CENTER)
                draw.SimpleText("Sequence 0: " .. seq0, "Comfortaa Light X20", w / 2, dbtPaint.HightSource(780), pathway.color, TEXT_ALIGN_CENTER)
            end
        else
            -- Подсказка когда ничего не выбрано
            draw.SimpleText("Наведите курсор на путь", "Comfortaa Bold X35", w / 2, h / 2 - dbtPaint.HightSource(30), colorText, TEXT_ALIGN_CENTER)
            draw.SimpleText("чтобы узнать подробности", "Comfortaa Light X25", w / 2, h / 2 + dbtPaint.HightSource(10), Color(colorText.r, colorText.g, colorText.b, 120), TEXT_ALIGN_CENTER)
        end
    end
    
    -- Создание карточек путей (2 в ряд для лучшей читаемости)
    local pathways = LOTM.GetAvailablePathways()
    local cardWidth = dbtPaint.WidthSource(530)
    local cardHeight = dbtPaint.HightSource(100)
    local spacing = dbtPaint.WidthSource(20)
    
    for i = 1, #pathways do
        local pathway = pathways[i]
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        
        local xPos = col * (cardWidth + spacing)
        local yPos = row * (cardHeight + spacing)
        
        -- Карточка пути (горизонтальная)
        local pathwayCard = vgui.Create("DButton", scrollPanel)
        pathwayCard:SetPos(xPos, yPos)
        pathwayCard:SetSize(cardWidth, cardHeight)
        pathwayCard:SetText("")
        
        pathwayCard.ColorBorder = Color(pathway.color.r, pathway.color.g, pathway.color.b)
        pathwayCard.ColorBorder.a = 150
        pathwayCard.glowAlpha = 0
        
        pathwayCard.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            
            -- Анимация свечения
            if hovered then
                self.glowAlpha = Lerp(FrameTime() * 10, self.glowAlpha, 100)
                self.ColorBorder.a = Lerp(FrameTime() * 10, self.ColorBorder.a, 255)
            else
                self.glowAlpha = Lerp(FrameTime() * 10, self.glowAlpha, 0)
                self.ColorBorder.a = Lerp(FrameTime() * 10, self.ColorBorder.a, 150)
            end
            
            -- Фон
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
            
            -- Вертикальная полоса слева с цветом пути
            draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(8), h, pathway.color)
            
            -- Свечение при наведении
            if self.glowAlpha > 0 then
                draw.RoundedBox(0, 0, 0, w, h, Color(pathway.color.r, pathway.color.g, pathway.color.b, self.glowAlpha / 4))
            end
            
            -- Граница
            local borderSize = hovered and 3 or 1
            draw.RoundedBox(0, 0, 0, w, borderSize, self.ColorBorder)
            draw.RoundedBox(0, 0, h - borderSize, w, borderSize, self.ColorBorder)
            draw.RoundedBox(0, w - borderSize, 0, borderSize, h, self.ColorBorder)
            
            -- Название пути
            draw.SimpleText(pathway.name, "Comfortaa Bold X30", dbtPaint.WidthSource(25), dbtPaint.HightSource(20), pathway.color, TEXT_ALIGN_LEFT)
            draw.SimpleText(pathway.nameEn, "Comfortaa Light X20", dbtPaint.WidthSource(25), dbtPaint.HightSource(60), Color(colorText.r, colorText.g, colorText.b, 150), TEXT_ALIGN_LEFT)
            
            -- Стрелка выбора справа
            if hovered then
                draw.SimpleText("►", "Comfortaa Bold X40", w - dbtPaint.WidthSource(30), h / 2, pathway.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        pathwayCard.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
            SelectedPathwayHover = pathway.id
        end
        
        pathwayCard.OnCursorExited = function()
            SelectedPathwayHover = nil
        end
        
        pathwayCard.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            CharCreatorData.pathway = pathway.id
            CurrentStage = CreatorStage.SEQUENCE_SELECT
            dbt.f4:Close()
            open_custom_character_creator()
        end
    end
end

-- ЭТАП 2: Выбор последовательности
function CreateSequenceSelection(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    if not CharCreatorData.pathway then
        CurrentStage = CreatorStage.PATHWAY_SELECT
        dbt.f4:Close()
        open_custom_character_creator()
        return
    end
    
    local pathway = LOTM.PathwaysList[CharCreatorData.pathway]
    
    -- Информация о выбранном пути
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(dbtPaint.WidthSource(100), dbtPaint.HightSource(150))
    infoPanel:SetSize(dbtPaint.WidthSource(1720), dbtPaint.HightSource(120))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.RoundedBox(0, 0, 0, w, 3, pathway.color)
        draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(8), h, pathway.color)
        
        draw.SimpleText("Выбран путь: " .. pathway.name, "Comfortaa Bold X40", w / 2, dbtPaint.HightSource(35), pathway.color, TEXT_ALIGN_CENTER)
        draw.SimpleText(pathway.nameEn, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(80), colorText, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопки выбора последовательности (9-0)
    local buttonWidth = dbtPaint.WidthSource(160)
    local buttonHeight = dbtPaint.HightSource(200)
    local spacing = dbtPaint.WidthSource(15)
    local startX = dbtPaint.WidthSource(100)
    local startY = dbtPaint.HightSource(300)
    
    for seq = 9, 0, -1 do
        local col = 9 - seq
        local xPos = startX + col * (buttonWidth + spacing)
        
        local seqButton = vgui.Create("DButton", parent)
        seqButton:SetPos(xPos, startY)
        seqButton:SetSize(buttonWidth, buttonHeight)
        seqButton:SetText("")
        seqButton.glowAlpha = 0
        
        local seqName = LOTM.GetSequenceName(CharCreatorData.pathway, seq)
        
        seqButton.Paint = function(self, w, h)
            local hovered = self:IsHovered()
            local selected = CharCreatorData.sequence == seq
            
            if hovered or selected then
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 80)
            else
                self.glowAlpha = Lerp(FrameTime() * 8, self.glowAlpha, 0)
            end
            
            -- Фон
            if selected then
                draw.RoundedBox(0, 0, 0, w, h, Color(pathway.color.r, pathway.color.g, pathway.color.b, 120))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
            end
            
            -- Свечение
            if self.glowAlpha > 0 then
                draw.RoundedBox(0, 0, 0, w, h, Color(pathway.color.r, pathway.color.g, pathway.color.b, self.glowAlpha / 3))
            end
            
            -- Граница
            local borderSize = (selected or hovered) and 3 or 1
            local borderColor = selected and pathway.color or (hovered and pathway.color or Color(255, 255, 255, 100))
            
            draw.RoundedBox(0, 0, 0, w, borderSize, borderColor)
            draw.RoundedBox(0, 0, h - borderSize, w, borderSize, borderColor)
            draw.RoundedBox(0, 0, 0, borderSize, h, borderColor)
            draw.RoundedBox(0, w - borderSize, 0, borderSize, h, borderColor)
            
            -- Вертикальная полоса
            draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, pathway.color)
            
            -- Номер последовательности
            draw.SimpleText("Seq " .. seq, "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(25), pathway.color, TEXT_ALIGN_CENTER)
            
            -- Название последовательности (многострочное)
            local wrappedText = dbtPaint.WrapText(seqName, "Comfortaa Light X18", w - dbtPaint.WidthSource(15))
            local yOffset = dbtPaint.HightSource(75)
            for i, line in ipairs(wrappedText) do
                draw.SimpleText(line, "Comfortaa Light X18", w / 2, yOffset, color_white, TEXT_ALIGN_CENTER)
                yOffset = yOffset + dbtPaint.HightSource(24)
            end
            
            -- Индикатор выбора
            if selected then
                draw.SimpleText("✓", "Comfortaa Bold X40", w / 2, h - dbtPaint.HightSource(35), pathway.color, TEXT_ALIGN_CENTER)
            end
        end
        
        seqButton.DoClick = function()
            surface.PlaySound('ui/button_click.mp3')
            CharCreatorData.sequence = seq
        end
        
        seqButton.OnCursorEntered = function()
            surface.PlaySound('ui/ui_but/ui_hover.wav')
        end
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(900))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200) or colorButtonInactive)
        draw.RoundedBox(0, 0, 0, w, 3, colorOutLine)
        draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X40", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    continueButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        CurrentStage = CreatorStage.INFO_INPUT
        dbt.f4:Close()
        open_custom_character_creator()
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 3: Ввод информации о персонаже
function CreateInfoInput(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Центральная панель
    local centerPanel = vgui.Create("DPanel", parent)
    centerPanel:SetPos(dbtPaint.WidthSource(400), dbtPaint.HightSource(250))
    centerPanel:SetSize(dbtPaint.WidthSource(1120), dbtPaint.HightSource(600))
    centerPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.RoundedBox(0, 0, 0, w, 3, colorOutLine)
        draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(8), h, colorOutLine)
    end
    
    -- Поле ввода имени
    local nameLabel = vgui.Create("DLabel", centerPanel)
    nameLabel:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(50))
    nameLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    nameLabel:SetFont("Comfortaa Bold X35")
    nameLabel:SetText("Имя персонажа")
    nameLabel:SetTextColor(colorGold)
    
    local nameEntry = vgui.Create("DTextEntry", centerPanel)
    nameEntry:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(100))
    nameEntry:SetSize(dbtPaint.WidthSource(1020), dbtPaint.HightSource(60))
    nameEntry:SetFont("Comfortaa Light X30")
    nameEntry:SetText(CharCreatorData.name)
    nameEntry:SetPlaceholderText("Введите имя вашего персонажа")
    nameEntry.OnChange = function(self)
        CharCreatorData.name = self:GetValue()
    end
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 220))
        draw.RoundedBox(0, 0, 0, w, 2, colorOutLine)
        draw.RoundedBox(0, 0, h - 2, w, 2, colorOutLine)
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Поле ввода таланта
    local talentLabel = vgui.Create("DLabel", centerPanel)
    talentLabel:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(200))
    talentLabel:SetSize(dbtPaint.WidthSource(300), dbtPaint.HightSource(40))
    talentLabel:SetFont("Comfortaa Bold X35")
    talentLabel:SetText("Абсолютный Талант")
    talentLabel:SetTextColor(colorGold)
    
    local talentEntry = vgui.Create("DTextEntry", centerPanel)
    talentEntry:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(250))
    talentEntry:SetSize(dbtPaint.WidthSource(1020), dbtPaint.HightSource(60))
    talentEntry:SetFont("Comfortaa Light X30")
    talentEntry:SetText(CharCreatorData.talent)
    talentEntry:SetPlaceholderText("Опишите уникальный талант персонажа")
    talentEntry.OnChange = function(self)
        CharCreatorData.talent = self:GetValue()
    end
    talentEntry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 220))
        draw.RoundedBox(0, 0, w, 2, colorOutLine)
        draw.RoundedBox(0, 0, h - 2, w, 2, colorOutLine)
        self:DrawTextEntryText(color_white, colorOutLine, color_white)
    end
    
    -- Информация о выбранном пути
    local pathway = LOTM.PathwaysList[CharCreatorData.pathway]
    local seqName = LOTM.GetSequenceName(CharCreatorData.pathway, CharCreatorData.sequence)
    
    local infoPanel = vgui.Create("DPanel", centerPanel)
    infoPanel:SetPos(dbtPaint.WidthSource(50), dbtPaint.HightSource(360))
    infoPanel:SetSize(dbtPaint.WidthSource(1020), dbtPaint.HightSource(200))
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
        draw.RoundedBox(0, 0, 0, w, 2, pathway.color)
        
        draw.SimpleText("ВАША СИЛА", "Comfortaa Bold X25", w / 2, dbtPaint.HightSource(20), colorGold, TEXT_ALIGN_CENTER)
        draw.SimpleText("Путь: " .. pathway.name, "Comfortaa Bold X30", w / 2, dbtPaint.HightSource(70), pathway.color, TEXT_ALIGN_CENTER)
        draw.SimpleText("Последовательность " .. CharCreatorData.sequence .. ": " .. seqName, "Comfortaa Light X25", w / 2, dbtPaint.HightSource(120), color_white, TEXT_ALIGN_CENTER)
        
        draw.SimpleText("Характеристики будут определены случайно на следующем шаге", "Comfortaa Light X20", w / 2, dbtPaint.HightSource(165), colorText, TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка продолжить
    local continueButton = vgui.Create("DButton", parent)
    continueButton:SetPos(dbtPaint.WidthSource(760), dbtPaint.HightSource(900))
    continueButton:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(70))
    continueButton:SetText("")
    continueButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local canContinue = CharCreatorData.name ~= "" and CharCreatorData.talent ~= ""
        
        if not canContinue then
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))
            draw.SimpleText("ЗАПОЛНИТЕ ВСЕ ПОЛЯ", "Comfortaa Bold X30", w / 2, h / 2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 200) or colorButtonInactive)
            draw.RoundedBox(0, 0, 0, w, 3, colorOutLine)
            draw.SimpleText("ПРОДОЛЖИТЬ", "Comfortaa Bold X40", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    continueButton.DoClick = function()
        if CharCreatorData.name ~= "" and CharCreatorData.talent ~= "" then
            surface.PlaySound('ui/button_click.mp3')
            -- Генерируем характеристики при переходе
            GenerateRandomStats()
            CurrentStage = CreatorStage.STATS_CONFIG
            dbt.f4:Close()
            open_custom_character_creator()
        else
            surface.PlaySound('ui/item_info_close.wav')
        end
    end
    continueButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
end

-- ЭТАП 4: Просмотр и рерол характеристик (DnD стиль)
function CreateStatsConfig(parent)
    local scrw, scrh = ScrW(), ScrH()
    
    -- Центральная панель со статами
    local statsPanel = vgui.Create("DPanel", parent)
    statsPanel:SetPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(200))
    statsPanel:SetSize(dbtPaint.WidthSource(1320), dbtPaint.HightSource(650))
    statsPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
        draw.RoundedBox(0, 0, 0, w, 3, colorOutLine)
        draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(8), h, colorOutLine)
        
        draw.SimpleText("ХАРАКТЕРИСТИКИ ПЕРСОНАЖА", "Comfortaa Bold X35", w / 2, dbtPaint.HightSource(30), colorGold, TEXT_ALIGN_CENTER)
        draw.SimpleText("Судьба определила ваши параметры", "Comfortaa Light X22", w / 2, dbtPaint.HightSource(70), colorText, TEXT_ALIGN_CENTER)
    end
    
    local stats = {
        {name = "Здоровье", key = "maxHealth", icon = "❤"},
        {name = "Голод", key = "maxHungry", icon = "🍖"},
        {name = "Жажда", key = "maxThird", icon = "💧"},
        {name = "Сон", key = "maxSleep", icon = "💤"},
        {name = "Скорость бега", key = "runSpeed", icon = "⚡"},
        {name = "Урон кулаками", key = "fistsDamage", icon = "👊"},
        {name = "Макс. вес (кг)", key = "maxKG", icon = "📦"},
        {name = "Слотов инвентаря", key = "maxInventory", icon = "🎒"},
    }
    
    local yPos = dbtPaint.HightSource(120)
    local columnWidth = dbtPaint.WidthSource(630)
    
    for i, stat in ipairs(stats) do
        local isLeftColumn = (i - 1) % 2 == 0
        local xPos = isLeftColumn and dbtPaint.WidthSource(50) or (dbtPaint.WidthSource(50) + columnWidth + dbtPaint.WidthSource(20))
        local rowYPos = yPos + math.floor((i - 1) / 2) * dbtPaint.HightSource(65)
        
        -- Панель стата
        local statPanel = vgui.Create("DPanel", statsPanel)
        statPanel:SetPos(xPos, rowYPos)
        statPanel:SetSize(columnWidth, dbtPaint.HightSource(55))
        statPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 120))
            draw.RoundedBox(0, 0, 0, dbtPaint.WidthSource(5), h, colorOutLine)
            
            -- Иконка
            draw.SimpleText(stat.icon, "Comfortaa Bold X30", dbtPaint.WidthSource(20), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Название
            draw.SimpleText(stat.name, "Comfortaa Bold X25", dbtPaint.WidthSource(60), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Значение
            local value = tostring(CharCreatorData[stat.key])
            draw.SimpleText(value, "Comfortaa Bold X30", w - dbtPaint.WidthSource(20), h / 2, colorGold, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Кнопка рероллa характеристик
    local rerollButton = vgui.Create("DButton", parent)
    rerollButton:SetPos(dbtPaint.WidthSource(450), dbtPaint.HightSource(900))
    rerollButton:SetSize(dbtPaint.WidthSource(350), dbtPaint.HightSource(70))
    rerollButton:SetText("")
    rerollButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorGold.r, colorGold.g, colorGold.b, 150) or Color(colorGold.r, colorGold.g, colorGold.b, 80))
        draw.RoundedBox(0, 0, 0, w, 3, colorGold)
        draw.SimpleText("🎲 ПЕРЕБРОСИТЬ", "Comfortaa Bold X35", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    rerollButton.DoClick = function()
        GenerateRandomStats()
        -- Обновляем интерфейс
        dbt.f4:Close()
        open_custom_character_creator()
    end
    rerollButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
    
    -- Кнопка создать персонажа
    local createButton = vgui.Create("DButton", parent)
    createButton:SetPos(dbtPaint.WidthSource(850), dbtPaint.HightSource(900))
    createButton:SetSize(dbtPaint.WidthSource(550), dbtPaint.HightSource(70))
    createButton:SetText("")
    createButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0, 0, 0, w, h, hovered and Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 220) or Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 120))
        draw.RoundedBox(0, 0, 0, w, 3, colorOutLine)
        draw.SimpleText("✓ СОЗДАТЬ ПЕРСОНАЖА", "Comfortaa Bold X40", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createButton.DoClick = function()
        surface.PlaySound('ui/button_click.mp3')
        
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
    createButton.OnCursorEntered = function() surface.PlaySound('ui/ui_but/ui_hover.wav') end
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

print("[Custom Character Creator] UI загружен с DnD системой и лор-описаниями")