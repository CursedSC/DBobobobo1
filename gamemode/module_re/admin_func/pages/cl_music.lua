local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a * x
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
local col0 = Color(143, 37, 156, 255)
local col1 = Color(143,37,156, (255 / 100) * 60)
local col2 = Color(126, 78, 148)
local col3 = Color(32, 32, 32, 200)
local col4 = Color(126, 78, 148)

albumListPanels = {}
local function createMusicButton(id_album, id, song, y_button, panel, isCustom)
    local button = vgui.Create("DButton", panel)
    button:SetText("")
    button:SetPos(weight_source(30, 1920), y_button)
    button:SetSize(weight_source(880, 1920), hight_source(30, 1080))
    
    button.Paint = function(self, w, h)
        local isPlaying = dbt.music.CurrentSong and dbt.music.CurrentSong.song.path == song.path
        local bgColor = isPlaying and Color(148, 21, 150, 60) or Color(60, 60, 60, 60)
        local textColor = isPlaying and Color(255, 255, 255) or Color(230, 230, 230)
        
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        if isPlaying then
            draw.RoundedBox(0, 0, 0, 4, h, Color(148, 21, 150, 255))
        end
        
        draw.SimpleText(song.name, "RobotoLight_24", 10, h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        if self:IsHovered() then
            draw.RoundedBox(0, 0, h-1, w, 1, Color(148, 21, 150, 100))
        end
    end
    
    button.DoClick = function()
        netstream.Start("dbt/music/start/admin", id_album, id, isCustom)
    end
    
    return button
end

local function FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", math.Round(minutes), math.Round(secs))
end

local function createAlbumPanel(albumId, albumData, y_pos, panel, isCustom)
    local albumPanel = vgui.Create("DPanel", panel)
    albumPanel:SetPos(weight_source(20, 1920), y_pos)
    albumPanel:SetSize(weight_source(1000, 1920), hight_source(40, 1080))
    albumPanel.Paint = function(self, w, h)
        local borderColor = self.expanded and Color(148, 21, 150, 100) or Color(80, 80, 80, 100)
        draw.RoundedBoxEx(6, 0, 0, w, h, Color(30, 30, 30, 200), true, true, false, false)
        draw.RoundedBox(0, 0, h-1, w, 1, borderColor)
    
        if  albumPanel.contentPanel then
            local x_pos, y_pos = self:GetPos()
            albumPanel.contentPanel:SetPos(weight_source(20, 1920), y_pos + hight_source(40, 1080))
        end
    end
    albumPanel.MoveChilders = function(panel, y_move)

    end

    local albumButton = vgui.Create("DButton", albumPanel)
    albumButton:SetText("")
    albumButton:SetSize(weight_source(1000, 1920), hight_source(40, 1080))
    albumButton.Paint = function(self, w, h)
        local songCount = table.Count(albumData.songs)
        local arrow = self:GetParent().expanded and "▼" or "►"
        
        draw.SimpleText(arrow, "RobotoMedium_24", 10, h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(albumData.name, "RobotoMedium_28", 35, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(songCount .. " трек" .. (songCount == 1 and "" or "ов"), "RobotoLight_20", w - 15, h/2, Color(200, 200, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    local contentPanel = vgui.Create("DPanel", panel)
    contentPanel:SetPos(weight_source(20, 1920), y_pos + hight_source(40, 1080))
    contentPanel:SetSize(weight_source(1000, 1920), 0)
    contentPanel.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, Color(40, 40, 40, 150), false, false, true, true)
        local x_pos, y_pos = albumPanel:GetPos()
        self:SetPos(weight_source(20, 1920), y_pos + hight_source(40, 1080))
    end
    contentPanel:SetVisible(false)
    
    albumPanel.contentPanel = contentPanel
    albumPanel.songButtons = {}
    albumPanel.expanded = false
    
    albumButton.DoClick = function(panel)
        albumPanel.expanded = not albumPanel.expanded
        local evidiceY = table.Count(albumData.songs) * dbtPaint.HightSource(35)
        if albumPanel.expanded then
            contentPanel:SetVisible(true)
            local totalHeight = 0
            
            for id, song in pairs(albumData.songs) do
                local button = createMusicButton(albumId, id, song, totalHeight + hight_source(5, 1080), contentPanel, isCustom)
                table.insert(albumPanel.songButtons, button)
                button:SetParent(contentPanel)
                totalHeight = totalHeight + hight_source(35, 1080)
            end
            contentPanel:SizeTo(weight_source(1000, 1920), totalHeight + hight_source(10, 1080), 0.2, 0, -1)
        
            for id = albumPanel.id + 1, table.Count(albumListPanels) do
                local glavButton = albumListPanels[id]
                glavButton.MoveChilders(glavButton, evidiceY)
                local x_pos, y_pos = glavButton:GetPos()
                glavButton:MoveTo( 20, y_pos + evidiceY, 0.1, 0, -1, function()
                end)    
            end
        else
            for id = albumPanel.id + 1, table.Count(albumListPanels) do
                local glavButton = albumListPanels[id]
                local x_pos, y_pos = glavButton:GetPos()
                glavButton.MoveChilders(glavButton, -1 * evidiceY)
                glavButton:MoveTo( 20, y_pos - evidiceY, 0.1, 0, -1, function()
                end)
            end

            contentPanel:SizeTo(weight_source(1000, 1920), 0, 0.2, 0, -1, function()
                contentPanel:SetVisible(false)
                for _, button in pairs(albumPanel.songButtons) do
                    if IsValid(button) then button:Remove() end
                end
                albumPanel.songButtons = {}
            end)
        end
    end
    
    return albumPanel, hight_source(45, 1080) + (albumPanel.expanded and contentPanel:GetTall() or 0)
end

dbt.AdminFunc["music"] = {
    name = "Музыка",
    build = function(frame)
        albumListPanels = {}
        local w, h = frame:GetWide(), frame:GetTall()
        
        local topPanel = vgui.Create("DPanel", frame)
        topPanel:SetPos(0, 0)
        topPanel:SetSize(w, hight_source(80, 1080))
        topPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 150))
            draw.RoundedBox(0, 0, h-1, w, 1, Color(60, 60, 60, 100))
            draw.SimpleText("Управление музыкой", "RobotoMedium_32", 20, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        local stopButton = vgui.Create("DButton", topPanel)
        stopButton:SetText("")
        stopButton:SetPos(weight_source(350, 1920), hight_source(20, 1080))
        stopButton:SetSize(weight_source(180, 1920), hight_source(40, 1080))
        stopButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(200, 40, 40, 150) or Color(180, 20, 20, 100)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            draw.SimpleText("Остановить", "RobotoLight_24", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        stopButton.DoClick = function()
            net.Start("dbt.music.Off")
            net.SendToServer()
        end
        
        local loopCheckbox = build_checkbox(weight_source(550, 1920), hight_source(20, 1080), w * 0.3, hight_source(40, 1080), "Бесконечный повтор", topPanel)
        loopCheckbox.Paint = function(self, w, h)
            draw.SimpleText("Бесконечный повтор", "RobotoLight_24", hight_source(50, 1080), h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local loopCheck = loopCheckbox.check_b
        loopCheck.checked = GetGlobalBool("LoopMisuc")
        loopCheck.OnEdit = function(bool)
            net.Start("GV.Change")
            net.WriteBool(bool)
            net.WriteString("LoopMisuc")
            net.SendToServer()
        end
        
        local mergeCheckbox = build_checkbox(weight_source(805, 1920), hight_source(20, 1080), w * 0.3, hight_source(40, 1080), "Совмещенный режим", topPanel)
        mergeCheckbox.Paint = function(self, w, h)
            draw.SimpleText("Совмещенный режим", "RobotoLight_24", hight_source(50, 1080), h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local mergeCheck = mergeCheckbox.check_b
        mergeCheck.checked = GetGlobalBool("MusicMultyMod")
        mergeCheck.OnEdit = function(bool)
            net.Start("GV.Change")
            net.WriteBool(bool)
            net.WriteString("MusicMultyMod")
            net.SendToServer()
            ButtonsListAdmin[1].DoClick(ButtonsListAdmin[1])
            timer.Simple(0.3, function()
                ButtonsListAdmin["music"].DoClick(ButtonsListAdmin["music"])
            end)
        end
        
        local bottomPanel = vgui.Create("DPanel", frame)
        bottomPanel:SetPos(0, h - hight_source(60, 1080))
        bottomPanel:SetSize(w, hight_source(60, 1080))
        bottomPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 150))
            draw.RoundedBox(0, 0, 0, w, 1, Color(60, 60, 60, 100))
        end
        
        local progressPanel = vgui.Create("EditablePanel", bottomPanel)
        progressPanel:SetSize(weight_source(900, 1920), hight_source(30, 1080))
        progressPanel:SetPos(weight_source(20, 1920), hight_source(15, 1080))
        progressPanel.NeedUpdate = false
        progressPanel.Paint = function(self, w, h)
            if !IsValid(PlayingSong) then
                draw.SimpleText("Нет воспроизводимого трека", "RobotoLight_24", w/2, h/2, Color(200, 200, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return
            end
            
            local timeEnd = PlayingSong:GetTime()
            local timeS = PlayingSong:GetLength()
            local percentage = (timeEnd / timeS)
            
            draw.RoundedBox(4, 0, h/2 - hight_source(3, 1080), w, hight_source(6, 1080), Color(60, 60, 60, 150))
            draw.RoundedBox(4, 0, h/2 - hight_source(3, 1080), w * percentage, hight_source(6, 1080), Color(148, 21, 150, 255))
            
            draw.SimpleText(FormatTime(timeEnd), "RobotoLight_20", 0, h/2, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(FormatTime(timeS), "RobotoLight_20", w, h/2, Color(230, 230, 230), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            
            if self:IsHovered() then
                local x, y = self:CursorPos()
                local hoverPct = x / w
                draw.RoundedBox(4, x - hight_source(3, 1080), h/2 - hight_source(8, 1080), hight_source(6, 1080), hight_source(16, 1080), Color(255, 255, 255, 150))
                
                if input.IsMouseDown(MOUSE_LEFT) then
                    local newTime = timeS * hoverPct
                    progressPanel.NeedUpdate = newTime
                    PlayingSong:SetTime(newTime)
                end
            end
            
            if progressPanel.NeedUpdate and !input.IsMouseDown(MOUSE_LEFT) then
                netstream.Start("dbt/music/time", progressPanel.NeedUpdate)
                progressPanel.NeedUpdate = false
            end
        end
        
        local scrollPanel = vgui.Create("DScrollPanel", frame)
        scrollPanel:SetPos(0, hight_source(80, 1080))
        scrollPanel:SetSize(w, h - hight_source(140, 1080))
        
        local scrollBar = scrollPanel:GetVBar()
        scrollBar:SetWide(weight_source(8, 1920))
        function scrollBar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        end
        function scrollBar.btnGrip:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150, 80))
            if self.Hovered then
                draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200, 50))
            end
            if self.Depressed then
                draw.RoundedBox(4, 0, 0, w, h, Color(148, 21, 150, 100))
            end
        end
        function scrollBar.btnUp:Paint(w, h) end
        function scrollBar.btnDown:Paint(w, h) end
        
        local y_pos = hight_source(10, 1080)
        local isMulty = GetGlobalBool("MusicMultyMod")
        
        for albumId, albumData in pairs(AlbumList) do
            if not albumData.name then continue end
            if isMulty and AlbumListCustom[albumId] then albumData = AlbumListCustom[albumId] end
            
            local albumPanel, height = createAlbumPanel(albumId, albumData, y_pos, scrollPanel, false)
            local id = table.insert(albumListPanels, albumPanel)
            albumPanel.id = id
            y_pos = y_pos + height + hight_source(5, 1080)
        end
        
        if not isMulty then
            for albumId, albumData in pairs(AlbumListCustom) do
                if not albumData.name then continue end
                
                local albumPanel, height = createAlbumPanel(albumId, albumData, y_pos, scrollPanel, true)
                local id = table.insert(albumListPanels, albumPanel)
                albumPanel.id = id
                y_pos = y_pos + height + hight_source(5, 1080)
            end
        end
    end,
    
    PaintAdv = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 25, 100))
        
        local songTitle = "Нет активного трека"
        if dbt.music.CurrentSong then
            songTitle = dbt.music.CurrentSong.song.name
        end
        
    end
}
