local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

local colorOutLine = Color(211,25, 202)
local colorButtonInactive = Color(0,0,0,100)
local colorButtonActive = Color(0,0,0,200)
local colorBG = Color(255, 255, 255, 60)
local colorBG2 = Color(255, 255, 255, 150)
local colorBlack = Color(0, 0, 0, 230)
local colorBlack2 = Color(49, 0, 54, 40)
local colorText = Color(255,255,255,100)
local colorButtonExit = Color(250, 250, 250, 1)

woundstbl_properties = woundstbl_properties or {}

netstream.Hook("dbt/woundsystem/getwounds_properties_return", function(data)

	woundstbl_properties = data or {}
end)

function buildCharacterDerma(menu, char)
    local characterData = charactersInGame[char]
    local characterInfo = dbt.chr and dbt.chr[char]
    local playerCharacter = player.GetBySteamID(characterData.steamID)
    local option = menu:AddOption(characterData.steamID, function()
        SetClipboardText(characterData.steamID)
    end)
    option:SetIcon("icon16/attach.png")
    local name = playerCharacter and playerCharacter:Name() or "Вне сети"
    local option = menu:AddOption(name, function()
        SetClipboardText(name)
    end)
    local icon = IsValid(playerCharacter) and "icon16/status_online.png" or "icon16/status_offline.png"
    option:SetIcon(icon)
    menu:AddSpacer()
    local option = menu:AddOption(characterInfo.name)
    local key = characterInfo.season .. "_" .. characterInfo.char
    option:SetIcon("dbt/characters"..characterInfo.season.."/char"..characterInfo.char.."/char_ico_1.png")

    local a, option = menu:AddSubMenu("Подемена игрока")
    option:SetIcon("icons/123.png")
    for k, i in pairs(player.GetAll()) do 
        if InGame(i) then continue end
        a:AddOption( i:Name(), function()
            netstream.Start("dbt/characters/admin/switchchar", char, i)
        end)
    end

    
    if IsValid(playerCharacter) then 
        netstream.Start("dbt/woundsystem/getwounds_properties", playerCharacter)
        local a, option = menu:AddSubMenu("Игрок")
        option:SetIcon("icon16/user_gray.png")
        local b, c = a:AddSubMenu("Выдать предмет")
        for k,i in pairs(dbt.inventory.items) do
            if k > 2 then
                if i.name then
                    b:AddOption( i.name, function()
                        netstream.Start("dbt/characters/admin/giveitem", playerCharacter, k)
                    end)
                end
            end
        end
        local submenu, c = a:AddSubMenu("Повреждения")

        local op = submenu:AddOption( 'Убрать все ранения' )
		op.DoClick = function(opself)
			for k, v in pairs(woundstbl_properties) do
				for m, n in pairs(v) do
					for a, b in pairs(n) do
                        netstream.Start("dbt/woundsystem/setwound", playerCharacter, b, k, true)
					end
				end
			end
		end

        local op = a:AddOption( 'Убрать все яды' )
        op:SetIcon("icons/150.png")
		op.DoClick = function(opself)
			netstream.Start("dbt/poison/disableall", playerCharacter)
		end

        local op = a:AddOption( 'Востановить всё' )
        op:SetIcon("icons/151.png")
		op.DoClick = function(opself)
			netstream.Start("dbt/players/restorechars", playerCharacter)
		end

        menu:AddSpacer()
        local hp, maxhp = playerCharacter:Health(), playerCharacter:GetMaxHealth()
        local op = menu:AddOption( 'Здоровье: ' .. hp .. '/' .. maxhp, function()
            Derma_StringRequest("Изменить здоровье", "Введите новое значение здоровья:", hp, function(text)
                local newhp = tonumber(text)
                if newhp and newhp > 0 then
                    netstream.Start("dbt/characters/admin/sethealth", playerCharacter, newhp)
                end
            end)
        end )
        op:SetIcon("icons/42.png")

        local armor, maxarmor = playerCharacter:Armor(), playerCharacter:GetMaxArmor()
        local op = menu:AddOption( 'Броня: ' .. armor .. '/' .. maxarmor, function()
            Derma_StringRequest("Изменить броню", "Введите новое значение брони:", armor, function(text)
                local newarmor = tonumber(text)
                if newarmor and newarmor > 0 then
                    netstream.Start("dbt/characters/admin/setarmor", playerCharacter, newarmor)
                end
            end)
        end )
        op:SetIcon("icons/clothes_armor.png")

        local hunger = playerCharacter:GetNWInt("hunger", 100)
        local op = menu:AddOption( 'Сытость: ' .. hunger .. '/' .. 100, function()
            Derma_StringRequest("Изменить сытость", "Введите новое значение сытости:", hunger, function(text)
                local newhunger = tonumber(text)
                if newhunger and newhunger > 0 then
                    netstream.Start("dbt/characters/admin/setstat", playerCharacter, "hunger", newhunger)
                end
            end)
        end )
        op:SetIcon("icons/44.png")

        local thirst = playerCharacter:GetNWInt("water", 100)
        local op = menu:AddOption( 'Жажда: ' .. thirst .. '/' .. 100, function()
            Derma_StringRequest("Изменить жажду", "Введите новое значение жажды:", thirst, function(text)
                local newthirst = tonumber(text)
                if newthirst and newthirst > 0 then
                    netstream.Start("dbt/characters/admin/setstat", playerCharacter, "water", newthirst)
                end
            end)
        end )
        op:SetIcon("icons/2.png")

        local sleep = playerCharacter:GetNWInt("sleep", 100)
        local op = menu:AddOption( 'Сон: ' .. sleep .. '/' .. 100, function()
            Derma_StringRequest("Изменить сон", "Введите новое значение сна:", sleep, function(text)
                local newsleep = tonumber(text)
                if newsleep and newsleep > 0 then
                    netstream.Start("dbt/characters/admin/setstat", playerCharacter, "sleep", newsleep)
                end
            end)
        end )
        op:SetIcon("icons/51.png")


        menu:AddSpacer()

        local newsubmenu, c = menu:AddSubMenu("Перемещение")
        c:SetIcon("icons/145.png")
        local op = newsubmenu:AddOption( 'К нему', function()
            RunConsoleCommand("sg", "goto", playerCharacter:Nick())
        end )
        op:SetIcon("icons/109.png")
        local op = newsubmenu:AddOption("К себе", function()
            RunConsoleCommand("sg", "bring", playerCharacter:Nick())
        end)
        op:SetIcon("icons/84.png")
        local op = newsubmenu:AddOption("Вернуть", function()
            RunConsoleCommand("sg", "return", playerCharacter:Nick())
        end)
        op:SetIcon("icons/ui_update.png")
        local op = menu:AddOption("Вернуть после смерти", function()
            netstream.Start("dbt/admin/telepor/die", playerCharacter)
        end)
        op:SetIcon("icons/death.png")
    end
end


dbt.AdminFunc["charingame"] = {
    name = "Таблица персонажей",
    build = function(frame)
        MonopadListLoad = true
        local w,h = frame:GetWide(), frame:GetTall()
            local abc = vgui.Create("DPanel", frame)
        abc:SetPos( 0, 30)
        abc:SetSize(w,h - 30)
        abc.Paint = function(self, w, h)
            if MonopadListLoad then draw.DrawText( "Загрузка списка персонажей", "RobotoLight_53", w / 2, h * 0.01, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) end
        end
        MonopadListFrame = abc
        netstream.Start("dbt/characters/admin/list")
    end,
}

    netstream.Hook("dbt/characters/admin/list", function(listt)
        charactersInGame = listt
        MonopadListLoad = false

        if IsValid(MonopadListFrame.Scroll) then MonopadListFrame.Scroll:Remove() end

        local DScrollPanel = vgui.Create("DScrollPanel", MonopadListFrame)
        DScrollPanel:Dock(FILL)
        MonopadListFrame.Scroll = DScrollPanel

        local sbar = DScrollPanel:GetVBar()
        function sbar:Paint(w,h) draw.RoundedBox(0, w-4, 0, 4, h, Color(175,19,186,40)) end
        function sbar.btnUp:Paint() end
        function sbar.btnDown:Paint() end
        function sbar.btnGrip:Paint(w,h) draw.RoundedBox(2, w-6, 0, 6, h, Color(175,19,186,180)) end

    local rowH = dbtPaint.HightSource(50) -- ещё тоньше (~50px)
        local rowW = dbtPaint.WidthSource(1100)
        local marginX = dbtPaint.WidthSource(40)
        local yPos = 0
        local matCache = {}

        for characterName, data in pairs(listt) do
            local row = DScrollPanel:Add("DButton")
            row:SetText("")
            row:SetSize(rowW, rowH)
            row:SetPos(marginX, yPos)

            local charTbl = dbt.chr and dbt.chr[characterName]
            local portrait
            if charTbl and charTbl.season and charTbl.char then
                local key = charTbl.season .. "_" .. charTbl.char
                if not matCache[key] then
                    matCache[key] = Material("dbt/characters"..charTbl.season.."/char"..charTbl.char.."/char_ico_1.png", "smooth")
                end
                portrait = matCache[key]
            end

            local plyName = "Отсутствует"
            if data.steamID and player.GetBySteamID then
                local ply = player.GetBySteamID(data.steamID)
                if IsValid(ply) then plyName = ply:Name() end
            end

            row.Paint = function(self, w, h)
                local liveData = charactersInGame and charactersInGame[characterName] or data
                -- background
                surface.SetDrawColor(30, 10, 34, 180)
                surface.DrawRect(0, 0, w, h)
                -- outline bottom divider
                surface.SetDrawColor(175,19,186,80)
                surface.DrawRect(0, h-1, w, 1)

                if portrait then
                    surface.SetDrawColor(255,255,255,255)
                    surface.SetMaterial(portrait)
                    surface.DrawTexturedRect(4, 4, h-8, h-8)
                else
                    draw.RoundedBox(4,4,4,h-8,h-8,Color(60,20,70,120))
                    draw.SimpleText("?", "Comfortaa Light X30", 4+(h-8)/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local textX = h + 6
                local aliveCol = liveData and liveData.alive and Color(120,255,120) or Color(255,120,120)
                local aliveTxt = liveData and liveData.alive and "В игре" or "Не в игре"
                local displayName = characterName .. " (" .. plyName .. ")"
                draw.SimpleText(displayName, "Comfortaa Light X30", textX, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(aliveTxt, "Comfortaa Light X24", textX, h*0.52, aliveCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            -- Контекстное меню ПКМ
            function row:DoRightClick()
                local m = DermaMenu()
                local liveData = charactersInGame and charactersInGame[characterName] or data
                buildCharacterDerma(m, characterName)

                if liveData.alive then
                    m:AddOption("Вывести из игры", function()
                        net.Start("admin.SetAliveChr")
                        net.WriteString(characterName)
                        net.WriteBool(false)
                        net.SendToServer()
                    end)
                else
                    m:AddOption("Ввести в игру", function()
                        net.Start("admin.SetAliveChr")
                        net.WriteString(characterName)
                        net.WriteBool(true)
                        net.SendToServer()
                    end)
                end
                m:Open()
            end

            -- ЛКМ быстрый toggle alive
            row.DoClick = function()
                local m = DermaMenu()
                local liveData = charactersInGame and charactersInGame[characterName] or data
                buildCharacterDerma(m, characterName)

                if liveData.alive then
                    m:AddOption("Вывести из игры", function()
                        net.Start("admin.SetAliveChr")
                        net.WriteString(characterName)
                        net.WriteBool(false)
                        net.SendToServer()
                    end)
                else
                    m:AddOption("Ввести в игру", function()
                        net.Start("admin.SetAliveChr")
                        net.WriteString(characterName)
                        net.WriteBool(true)
                        net.SendToServer()
                    end)
                end
                m:Open()
            end

            yPos = yPos + rowH
        end
    end)

local miniCharList
local function BuildMiniCharList()
    if IsValid(miniCharList) then miniCharList:Remove() end
    miniCharList = vgui.Create("DPanel")
    local w = math.min(ScrW()*0.28, 420)
    local rowH = 26
    local count = table.Count(charactersInGame or {})
    local maxRows = math.floor(ScrH()*0.35 / rowH)
    local rows = math.min(count, maxRows)
    local h = rows*rowH + 8
    miniCharList:SetSize(w, h)
    miniCharList:SetPos(8, ScrH()-h-8)
    miniCharList:MakePopup()
    miniCharList.Paint = function(self, pw, ph)
        surface.SetDrawColor(20,8,24,210)
        surface.DrawRect(0,0,pw,ph)
        surface.SetDrawColor(175,19,186,140)
        surface.DrawOutlinedRect(0,0,pw,ph,1)
    end
    local scroll = vgui.Create("DScrollPanel", miniCharList)
    scroll:SetPos(4,4)
    scroll:SetSize(w-8, h-8)
    local sbar = scroll:GetVBar()
    function sbar:Paint(w,h) end
    function sbar.btnUp:Paint() end
    function sbar.btnDown:Paint() end
    function sbar.btnGrip:Paint(w,h) surface.SetDrawColor(175,19,186,160) surface.DrawRect(0,0,w,h) end
    local y = 0
    local sorted = {}
    for k in pairs(charactersInGame or {}) do sorted[#sorted+1]=k end
    table.sort(sorted, function(a,b) return tostring(a)<tostring(b) end)
    for _, characterName in ipairs(sorted) do
        local data = charactersInGame[characterName]
        local liveData = charactersInGame and charactersInGame[characterName] or data
        local btn = scroll:Add("DButton")
        btn:SetText("")
        btn:SetPos(0,y)
        btn:SetSize(scroll:GetWide(), rowH)
        btn.Paint = function(self,w2,h2)
            local alive = data and data.alive
            surface.SetDrawColor(175,19,186,60)
            surface.DrawRect(0,h2-1,w2,1)
            local liveData = charactersInGame and charactersInGame[characterName] or data
            local inGame = liveData.alive and "В игре" or "Вне игры"
            draw.SimpleText(characterName .. " ["..inGame.."]", "Comfortaa Light X24", 6, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        btn.DoRightClick = function()
                            local m = DermaMenu()
                local liveData = charactersInGame and charactersInGame[characterName] or data
                buildCharacterDerma(m, characterName)

                if liveData.alive then
                    m:AddOption("Вывести из игры", function()
                        net.Start("admin.SetAliveChr")
                        net.WriteString(characterName)
                        net.WriteBool(false)
                        net.SendToServer()
                    end)
                else
                    m:AddOption("Ввести в игру", function()
                        net.Start("admin.SetAliveChr")
                        net.WriteString(characterName)
                        net.WriteBool(true)
                        net.SendToServer()
                    end)
                end
                m:Open()
        end
        y = y + rowH
    end
end

hook.Add("OnContextMenuOpen","dbt_charMini_open", function()
    if not LocalPlayer():IsAdmin() then return end
    if not charactersInGame then netstream.Start("dbt/characters/admin/list") end
    BuildMiniCharList()
end)

hook.Add("OnContextMenuClose","dbt_charMini_close", function()  
    if IsValid(miniCharList) then miniCharList:Remove() end
end)

