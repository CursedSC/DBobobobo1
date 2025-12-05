local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

netstream.Hook("dbt/admin/maplist", function(listMaps)
    if !IsValid(mapListPanel2) then return end
    for i = 1, table.Count(listMaps) do
        local mapName = listMaps[i]
    	local ListItem = mapListPanel2:Add( "DButton" )
    	ListItem:SetSize( weight_source(330), hight_source(400) )
        ListItem:SetText( "" )
        files, d = file.Find("maps/thumb/*", "GAME")
        ListItem.Lerp = 0
        ListItem.icon = file.Exists("maps/thumb/" .. mapName .. ".png", "GAME") and Material("maps/thumb/" .. mapName.. ".png") or nil

        ListItem.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(143, 37, 156, 120))
            local isHovered = self:IsHovered()
            self.Lerp = Lerp(FrameTime() * 10, self.Lerp or 0, isHovered and 1 or 0)
            if self.icon then 
                surface.SetMaterial(self.icon)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRectRotated(w / 2, h / 2, w + 30 * ListItem.Lerp, h + 30 * ListItem.Lerp, 0)
            else 
                draw.SimpleText("Нет Картинки", "RobotoLight_43", w * 0.5, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            draw.RoundedBox(0, 0, h * 0.8, w, h * 0.2, Color(0,0,0, 230))
            draw.SimpleText(mapName, "RobotoLight_23", w * 0.5, h * 0.9, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        ListItem.DoClick = function()
            RunConsoleCommand("sg", "map", mapName)
        end
    end
    mapListPanel2:Layout()
end)

dbt.AdminFunc["map"] = {
    name = "Карты",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        -- Create scrollable panel for all settings
        local scrollPanel = vgui.Create("DScrollPanel", frame)
        scrollPanel:SetPos(weight_source(45, 1920), hight_source(82, 1080))
        scrollPanel:SetSize(weight_source(1153, 1920), hight_source(1000, 1080))
        
        local sbar = scrollPanel:GetVBar()
        function sbar:Paint(w, h) end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)
        end

        mapListPanel2 = vgui.Create( "DIconLayout", scrollPanel )
        mapListPanel2:SetSpaceY( 5 ) 
        mapListPanel2:SetSpaceX( 5 ) 
        mapListPanel2:SetSize(weight_source(1053, 1920), hight_source(1000, 1080))

        netstream.Start("dbt/admin/maplist")
    end,
    
    PaintAdv = function(self, w, h)
        draw.DrawText("Выбор карты", "RobotoLight_43", w / 2, hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER)
    end
}