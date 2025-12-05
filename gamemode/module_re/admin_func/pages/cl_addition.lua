local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end
local col0 = Color(143, 37, 156, 255)
local col1 = Color(143,37,156, (255 / 100) * 60)
local col2 = Color(126, 78, 148)
local col3 = Color(32, 32, 32, 200)
local col4 = Color(126, 78, 148)

dbt.AdminFunc["addition"] = {
    name = "Доступ на сервер",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        
        -- Create the whitelist table panel
        local whitelistPanel = vgui.Create("DPanel", frame)
        whitelistPanel:SetPos(weight_source(45, 1920), hight_source(82, 1080))
        whitelistPanel:SetSize(weight_source(650, 1920), hight_source(560, 1080))
        whitelistPanel.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, monobuttons_1)
            draw.SimpleText("Список SteamID", "RobotoLight_32", w/2, hight_source(15, 1080), Color(160, 160, 160), TEXT_ALIGN_CENTER)
        end
        
        -- Create the whitelist list
        local whitelistScroll = vgui.Create("DScrollPanel", whitelistPanel)
        whitelistScroll:SetPos(weight_source(15, 1920), hight_source(50, 1080))
        whitelistScroll:SetSize(weight_source(620, 1920), hight_source(495, 1080))
        
        local sbar = whitelistScroll:GetVBar()
        function sbar:Paint(w, h) end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)
            draw.RoundedBox(0, w / 2 - 2, 0, 2, h, Color(126, 78, 148))
        end
        
        -- Function to refresh the whitelist
        local function RefreshWhitelist()
            whitelistScroll:Clear()
            netstream.Start("dbt/whitelist/request")
        end
        
        -- Panel for adding new SteamIDs
        local addPanel = vgui.Create("DPanel", frame)
        addPanel:SetPos(weight_source(715, 1920), hight_source(82, 1080))
        addPanel:SetSize(weight_source(380, 1920), hight_source(280, 1080))
        addPanel.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, monobuttons_1)
            draw.SimpleText("Добавить игрока", "RobotoLight_32", w/2, hight_source(15, 1080), Color(160, 160, 160), TEXT_ALIGN_CENTER)
        end
        
        -- SteamID input field
        local steamIDLabel = vgui.Create("DLabel", addPanel)
        steamIDLabel:SetPos(weight_source(20, 1920), hight_source(60, 1080))
        steamIDLabel:SetText("SteamID:")
        steamIDLabel:SetFont("RobotoLight_24")
        steamIDLabel:SetTextColor(Color(220, 220, 220))
        steamIDLabel:SizeToContents()
        
        local steamIDEntry = vgui.Create("DTextEntry", addPanel)
        steamIDEntry:SetPos(weight_source(20, 1920), hight_source(90, 1080))
        steamIDEntry:SetSize(weight_source(340, 1920), hight_source(40, 1080))
        steamIDEntry:SetFont("RobotoLight_24")
        steamIDEntry:SetPlaceholderText("STEAM_0:0:123456789")
        
        -- Add SteamID button
        CrateMonoButton(
            weight_source(20, 1920), 
            hight_source(150, 1080), 
            weight_source(340, 1920), 
            hight_source(45, 1080), 
            addPanel, 
            "Добавить игрока", 
            function()
                local steamid = steamIDEntry:GetValue()
                if steamid and steamid:match("STEAM_%d:%d:%d+") then
                    netstream.Start("dbt/whitelist/add", steamid)
                    steamIDEntry:SetValue("")
                    timer.Simple(0.5, RefreshWhitelist)
                else
                    Derma_Message("Неверный формат SteamID!", "Ошибка", "OK")
                end
            end,
            true
        )
        
        -- Clear all button
        CrateMonoButton(
            weight_source(20, 1920), 
            hight_source(205, 1080), 
            weight_source(340, 1920), 
            hight_source(45, 1080), 
            addPanel, 
            "Очистить весь список", 
            function()
                Derma_Query(
                    "Вы уверены, что хотите удалить ВСЕ разрешенные SteamID?\nВСЕ игроки будут отключены от сервера!",
                    "Подтверждение",
                    "Да, очистить список",
                    function()
                        netstream.Start("dbt/whitelist/clear")
                        timer.Simple(0.5, RefreshWhitelist)
                    end,
                    "Отмена",
                    function() end
                )
            end
        )
        

        RefreshWhitelist()

        -- Add networked hooks to handle whitelist data
        netstream.Hook("dbt/whitelist/list", function(allowed)
            whitelistScroll:Clear()
            local yPos = 0
            
            for steamid, _ in pairs(allowed) do
                local whitelistItem = vgui.Create( "DButton", whitelistScroll )
                whitelistItem:SetText( "" )
                whitelistItem:SetPos( 0, yPos )
                whitelistItem:SetSize(weight_source(600, 1920), hight_source(40, 1080))
                whitelistItem.Name = "Загрузка..."
                GetName(util.SteamIDTo64(steamid), function(name)
                   whitelistItem.Name = name
                end)
                whitelistItem.Paint = function(self, w, h)
                    if self:IsHovered() then
                        draw.RoundedBox(0, 0, 0, w, h, col0)
                    else
                        draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, (255 / 100) * 70))
                    end
                    local ply = player.GetBySteamID(steamid)
                    if IsValid(ply) then
                        draw.DrawText( ply:Name() .." ["..steamid.."]", "RobotoLight_22", w * 0.1, h * 0.25, Color(126, 200, 126), TEXT_ALIGN_LEFT )
                    else
                        draw.DrawText( self.Name .." ["..steamid.."]", "RobotoLight_22", w * 0.1, h * 0.25, Color(220, 220, 220), TEXT_ALIGN_LEFT )
                    end
    
                end
                whitelistItem.DoClick = function()
                    netstream.Start("dbt/whitelist/remove", steamid)
                    timer.Simple(0.5, RefreshWhitelist)
                end
                avatar = vgui.Create( "AvatarImage", whitelistItem )
                avatar:SetPos( weight_source(10, 1920), hight_source(5, 1080) )
                avatar:SetSize( hight_source(30, 1080), hight_source(30, 1080) )
                avatar:SetSteamID( util.SteamIDTo64(steamid), 32 )
                
                yPos = yPos + hight_source(45, 1080)
            end
        end)
        
        -- Refresh buttons
        CrateMonoButton(
            weight_source(45, 1920), 
            hight_source(652, 1080), 
            weight_source(250, 1920), 
            hight_source(45, 1080), 
            frame, 
            "Обновить список", 
            RefreshWhitelist, 
            true
        )
        
        
        -- Import/Export buttons
        CrateMonoButton(
            weight_source(45 + 270, 1920), 
            hight_source(652, 1080), 
            weight_source(200, 1920), 
            hight_source(45, 1080), 
            frame, 
            "Импорт списка", 
            function()
                Derma_StringRequest(
                    "Импорт списка SteamID",
                    "Вставьте список SteamID (разделенные запятой или новой строкой)",
                    "",
                    function(text)
                        -- Parse the input for SteamIDs
                        local steamids = {}
                        for steamid in string.gmatch(text, "STEAM_[%d:]+") do
                            table.insert(steamids, steamid)
                        end
                        
                        if #steamids > 0 then
                            netstream.Start("dbt/whitelist/import", steamids)
                            timer.Simple(0.5, RefreshWhitelist)
                        else
                            Derma_Message("Не найдено ни одного SteamID!", "Ошибка", "OK")
                        end
                    end
                )
            end, 
            true
        )

    end,
    PaintAdv = function(self, w, h)
        draw.DrawText("Управление доступом на сервер", "RobotoLight_43", w / 2, hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER)
    end
}