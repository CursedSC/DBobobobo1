local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a * x
end

local colors = {
    primary = Color(148, 21, 150),
    accent = Color(211, 25, 202),
    text = Color(255, 255, 255),
    textDim = Color(200, 200, 200),
    background = Color(30, 30, 30, 200),
    backgroundLight = Color(40, 40, 40, 150),
    buttonHover = Color(148, 21, 150, 80),
    divider = Color(60, 60, 60, 100)
}

dbt.AdminFunc["monopad"] = {
    name = "Монопады",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        
        
        local monopadContainer = vgui.Create("DPanel", frame)
        monopadContainer:SetPos(0, hight_source(10, 1080))
        monopadContainer:SetSize(w, h - hight_source(60, 1080))
        monopadContainer.Paint = function(self, w, h)
            if not listMonopads then
                draw.SimpleText("Загрузка списка монопадов...", "RobotoMedium_32", w/2, h/3, colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                local loadingSize = weight_source(40, 1920)
                local time = CurTime() * 3
                local x, y = w/2, h/2
                
                for i = 1, 8 do
                    local angle = math.rad(i * 45 - time * 30)
                    local radius = weight_source(30, 1920)
                    local dotSize = weight_source(8, 1920)
                    local alpha = 155 + 100 * math.sin(time + i)
                    
                    local dotX = x + math.cos(angle) * radius - dotSize/2
                    local dotY = y + math.sin(angle) * radius - dotSize/2
                    
                    draw.RoundedBox(dotSize/2, dotX, dotY, dotSize, dotSize, Color(colors.primary.r, colors.primary.g, colors.primary.b, alpha))
                end
            end
        end
        
        MonopadListFrame = monopadContainer
        netstream.Start("dbt/monopad/admin/list")
    end,
}

netstream.Hook("dbt/monopad/admin/list", function(listt)
    listMonopads = listt
    
    if not IsValid(MonopadListFrame) then return end
    
    local scrollPanel = vgui.Create("DScrollPanel", MonopadListFrame)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(weight_source(20, 1920), hight_source(20, 1080), weight_source(20, 1920), hight_source(20, 1080))
    
    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetWide(weight_source(8, 1920))
    function scrollBar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 30))
    end
    function scrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(148, 21, 150, 80))
        if self.Hovered then draw.RoundedBox(4, 0, 0, w, h, Color(148, 21, 150, 120)) end
        if self.Depressed then draw.RoundedBox(4, 1, 1, w-2, h-2, Color(160, 50, 170, 200)) end
    end
    function scrollBar.btnUp:Paint(w, h) end
    function scrollBar.btnDown:Paint(w, h) end
    
    local listLayout = vgui.Create("DListLayout", scrollPanel)
    listLayout:Dock(FILL)
    listLayout:DockMargin(0, 0, weight_source(10, 1920), 0)
    
    if table.Count(listt) == 0 then
        local noMonopadsLabel = vgui.Create("DLabel", listLayout)
        noMonopadsLabel:SetText("Нет доступных монопадов")
        noMonopadsLabel:SetFont("RobotoLight_32")
        noMonopadsLabel:SetTextColor(colors.textDim)
        noMonopadsLabel:SetContentAlignment(5)
        noMonopadsLabel:SetHeight(hight_source(100, 1080))
        noMonopadsLabel:Dock(TOP)
    end
    
    for k, i in pairs(listt) do
        local monopadPanel = vgui.Create("DButton", listLayout)
        monopadPanel:SetText("")
        monopadPanel:SetHeight(hight_source(90, 1080))
        monopadPanel:Dock(TOP)
        monopadPanel:DockMargin(0, 0, 0, hight_source(8, 1080))
        
        monopadPanel.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(50, 50, 50, 200) or Color(40, 40, 40, 180)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            
            if self:IsHovered() then
                draw.RoundedBoxEx(6, 0, 0, 4, h, colors.primary, true, false, false, true)
            end
            
            local charName = i.character or "Неизвестно"
            local ownerName = i.nowowned or "Отсутствует"
            local listenerName = i.listen or "Отсутствует" 
            
            draw.SimpleText("Монопад #" .. k, "RobotoMedium_28", 20, 20, colors.text, TEXT_ALIGN_LEFT)
            draw.SimpleText("Персонаж: " .. charName, "RobotoLight_24", 20, 55, colors.textDim, TEXT_ALIGN_LEFT)

            draw.SimpleText("Владелец: " ..(IsValid(ownerName) and ownerName:Name() or "Отсутствует"), "RobotoLight_24", w - 20, 20, colors.textDim, TEXT_ALIGN_RIGHT)

            draw.SimpleText("Слушает: " ..listenerName, "RobotoLight_24", w - 20, 55, colors.textDim, TEXT_ALIGN_RIGHT)
        end
        
        monopadPanel.Think = function(self)
            if self:IsHovered() then
                self.hoverAlpha = math.min((self.hoverAlpha or 0) + 5, 255)
            else
                self.hoverAlpha = math.max((self.hoverAlpha or 0) - 5, 0)
            end
        end
        
        monopadPanel.DoClick = function(self)
            local menu = DermaMenu()
            
            menu:AddOption("Взять монопад", function()
                netstream.Start("dbt/monopad/admin/give", k)
            end)
            
            menu:AddSpacer()
            
            menu:AddOption("Отмена", function() end)
            
            menu:Open()
        end
    end
end)