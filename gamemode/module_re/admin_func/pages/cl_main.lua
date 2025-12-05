local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end
mono_bunttons = {}
mono_bunttons[#mono_bunttons + 1] = {
    name = "Начать игру",
    func = function()
		net.Start("dbt.StripWeapon")
		net.SendToServer()
        net.Start("dbt.StartGame")
        net.SendToServer()
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Игра начата." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Закончить игру",
    func = function()
            net.Start("dbt.EndGame")
            net.SendToServer()

            chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Игра закончена." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "След. Глава",
    func = function()
        RunConsoleCommand("NextRound")
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Начать суд",
    func = function()
        RunConsoleCommand("StartClassTrial")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Суд начат." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Закончить суд",
    func = function()
        Derma_Query(
            "Не хотите сменить главу?",
            "Решение",
            "Да",
            function() RunConsoleCommand("NextRound") end,
        	"Нет",
        	function()  end
        )

        RunConsoleCommand("EndClassTrial")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Суд закончен." )
    end
}


mono_bunttons[#mono_bunttons + 1] = {
    name = "ESP MODE",
    func = function()
        RunConsoleCommand("say", "/espmode")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " ESP мод включен." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Расследование",
    func = function()
        RunConsoleCommand("startInve")
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Удал. Улик",
    func = function()
        RunConsoleCommand("ClearE")
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Ред. Правила", 
    func = function()
        RunConsoleCommand("open_rules_editor")
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Полная очистка",
    func = function()
        RunConsoleCommand("sd_text_s")

        net.Start("pp_info_send")
            net.WriteTable({CMD = "CLR_MAP"})
        net.SendToServer()
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Вост. статы",
    func = function()
        RunConsoleCommand("SetAllStats")
        chat.AddText( Color( 116, 40, 151 ), "[DBT]", Color( 255, 255, 255 ), " Все статы игроков востоновлены!." )
    end
}

mono_bunttons[#mono_bunttons + 1] = {
    name = "Создать ключ",
    func = function()
        Derma_StringRequest(
            "Введите название",
            "Введите название группы(БЕЗ пробелов, Английскими буквами)",
            "",
            function(text)
                NAME_GRP = text
                Derma_StringRequest(
                    "Введите название ключа",
                    "Введите название ключа",
                    "",
                    function(text)
                        key_name = text
                        netstream.Start("dbt/create/key", NAME_GRP, key_name)
                    end,
                    function(text) end
                )
            end,
            function(text) end
        )
    end
}


dbt.AdminFunc[1] = {
    name = "Основные возможности",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        
        -- Game control buttons
        local gameButtons = {
            {name = "Начать игру", func = function() mono_bunttons[1].func() end},
            {name = "Закончить игру", func = function() mono_bunttons[2].func() end},
            {name = "Следующая глава", func = function() mono_bunttons[3].func() end},
            {name = "Выбор главы", func = function()
                local m = DermaMenu()
                for k, i in pairs(charapter_img) do
                    m:AddOption(i, function() netstream.Start("dbt/change/lvl", k) end)
                end
                m:Open()
            end, nocheck = true}
        }
        
        -- Other features buttons
        local otherButtons = {
            {name = "ESP мод", func = function()
                RunConsoleCommand("say", "/espmode")
                chat.AddText(Color(116, 40, 151), "[DBT]", Color(255, 255, 255), " ESP мод включен.")
            end},
            {name = "Редактировать правила", func = function() RunConsoleCommand("open_rules_editor") end},
            {name = "Полная очистка карты", func = function()
                RunConsoleCommand("sd_text_s")
                net.Start("pp_info_send")
                    net.WriteTable({CMD = "CLR_MAP"})
                net.SendToServer()
            end},
            {name = "Создать ключ", func = function()
                Derma_StringRequest(
                    "Введите название",
                    "Введите название группы(БЕЗ пробелов, Английскими буквами)",
                    "",
                    function(text)
                        NAME_GRP = text
                        Derma_StringRequest(
                            "Введите название ключа",
                            "Введите название ключа",
                            "",
                            function(text) netstream.Start("dbt/create/key", NAME_GRP, text) end,
                            function() end
                        )
                    end,
                    function() end
                )
            end},
            {name = "Пустая карта", func = function() netstream.Start("dbt/map/clearallprops") end},
            {name = "Расследование", func = function() RunConsoleCommand("startInve") end}
        }
        
        -- Setting toggles
        local settingsToggles = {
            {name = "Восстановить статы", func = function() RunConsoleCommand("SetAllStats") end, isButton = true},
            {name = "Вкл/выкл расследование", var = "AnuceStatus"},
            {name = "Вкл/выкл трату сна", var = "SleepStatus"},
            {name = "Вкл/выкл трату голода", var = "HungerStatus"},
            {name = "Вкл/выкл трату жажды", var = "WaterStatus"},
            {name = "Вкл/выкл стамина Нагито", var = "NagitoStatus"},
            {name = "Вкл/выкл сист. ранений", var = "Wounds"},
            {name = "Вкл/выкл порчу еды", var = "dbt_spoil_enabled"}
        }
        
        -- Trial buttons
        local trialButtons = {
            {name = "Начать Суд", func = function()
                RunConsoleCommand("StartClassTrial")
                chat.AddText(Color(116, 40, 151), "[DBT]", Color(255, 255, 255), " Суд начат.")
            end},
            {name = "Закончить суд", func = function()
                RunConsoleCommand("EndClassTrial")
                Derma_Query(
                    "Не хотите сменить главу?",
                    "Решение",
                    "Да",
                    function() RunConsoleCommand("NextRound") end,
                	"Нет",
                	function()  end
                )

                chat.AddText(Color(116, 40, 151), "[DBT]", Color(255, 255, 255), " Суд закончен.")
            end},
            {name = "Удаление улик", func = function() RunConsoleCommand("ClearE") end},
            {name = "Начать голосование", func = function() LocalPlayer():ConCommand('dbt/classtrial/startvoting') end}
        }
        
        -- Create game buttons
        for i, btn in ipairs(gameButtons) do
            CrateMonoButton(
                weight_source(20, 1920),
                hight_source(82 + (i-1)*63, 1080),
                weight_source(355, 1920),
                hight_source(48, 1080),
                frame,
                btn.name,
                btn.func,
                btn.nocheck
            )
        end
        
        -- Create other feature buttons
        for i, btn in ipairs(otherButtons) do
            CrateMonoButton(
                weight_source(399, 1920),
                hight_source(82 + (i-1)*63, 1080),
                weight_source(355, 1920),
                hight_source(48, 1080),
                frame,
                btn.name,
                btn.func
            )
        end
        
        -- Create settings toggles
        local settingsX = weight_source(399 + 22 + 355, 1920)
        for i, setting in ipairs(settingsToggles) do
            local y = hight_source(82 + (i-1)*63, 1080)
            
            if setting.isButton then
                CrateMonoButton(settingsX, y, weight_source(355, 1920), hight_source(48, 1080), frame, setting.name, setting.func)
            else
                local container = build_checkbox(settingsX, y, weight_source(355, 1920), hight_source(48, 1080), setting.name)
                local checkbox = container.check_b
                checkbox.checked = GetGlobalBool(setting.var)
                checkbox.OnEdit = function(bool)
                    net.Start("GV.Change")
                    net.WriteBool(bool)
                    net.WriteString(setting.var)
                    net.SendToServer()
                end
            end
        end
        
        -- Create trial buttons
        for i, btn in ipairs(trialButtons) do
            CrateMonoButton(
                weight_source(20, 1920),
                hight_source(82 + 380 + (i-1)*63, 1080),
                weight_source(355, 1920),
                hight_source(48, 1080),
                frame,
                btn.name,
                btn.func
            )
        end
    end,
    
    PaintAdv = function(self, w, h)
        -- Draw section headers
        draw.DrawText("Игра", "RobotoLight_43", weight_source(200, 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.DrawText("Другое", "RobotoLight_43", weight_source(579, 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.DrawText("Настройки", "RobotoLight_43", weight_source(959, 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.DrawText("Суд", "RobotoLight_43", weight_source(200, 1920), hight_source(400, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Show current chapter
        draw.DrawText("Сейчас: ", "RobotoLight_35", weight_source(20, 1920), hight_source(271 + 53, 1080), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.DrawText(charapter_img[GetGlobalInt("round")], "RobotoLight_35", weight_source(130, 1920), hight_source(271 + 53, 1080), Color(116, 36, 146), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
}