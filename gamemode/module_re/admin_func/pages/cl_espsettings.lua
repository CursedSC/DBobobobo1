local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end
dbt.AdminFunc["esp_settings"] = {
    name = "Настройки ESP",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        -- Create scrollable panel for all settings
        local scrollPanel = vgui.Create("DScrollPanel", frame)
        scrollPanel:SetPos(weight_source(45, 1920), hight_source(82, 1080))
        scrollPanel:SetSize(weight_source(1053, 1920), hight_source(613, 1080))
        
        local sbar = scrollPanel:GetVBar()
        function sbar:Paint(w, h) end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)
            draw.RoundedBox(0, w / 2 - 2, 0, 2, h, borderColor)
        end
        
        -- Create header labels
        local headerPlayer = vgui.Create("DLabel", scrollPanel)
        headerPlayer:SetPos(weight_source(10, 1920), hight_source(10, 1080))
        headerPlayer:SetText("Настройки ESP для игроков")
        headerPlayer:SetFont("RobotoLight_43")
        headerPlayer:SetTextColor(color_white)
        headerPlayer:SizeToContents()
        
        -- Create player ESP settings
        local yPosPlayer = hight_source(70, 1080)
        for k, custom in SortedPairsByMemberValue(ESP.playerinfo, "dist") do
            local checkbox = build_checkbox(
                weight_source(20, 1920), 
                yPosPlayer, 
                weight_source(450, 1920), 
                hight_source(40, 1080), 
                custom.config.name, 
                scrollPanel
            )
            
            local checkButton = checkbox.check_b
            checkButton.checked = settings.Get("dbt_esp_player_" .. custom.index)
            checkButton.OnEdit = function(bool)
                ESP:ToggleFeature("player", custom.index)
            end
            
            -- Add tooltip with description
            checkbox:SetTooltip(custom.config.desc)
            
            yPosPlayer = yPosPlayer + hight_source(50, 1080)
        end
        
        -- Create entity ESP header 
        local headerEntity = vgui.Create("DLabel", scrollPanel)
        headerEntity:SetPos(weight_source(510, 1920), hight_source(10, 1080))
        headerEntity:SetText("Настройки ESP для объектов")
        headerEntity:SetFont("RobotoLight_43")
        headerEntity:SetTextColor(color_white)
        headerEntity:SizeToContents()
        
        -- Create entity ESP settings
        local yPosEntity = hight_source(70, 1080)
        for k, custom in SortedPairsByMemberValue(ESP.entityinfo, "dist") do
            local checkbox = build_checkbox(
                weight_source(520, 1920), 
                yPosEntity, 
                weight_source(450, 1920), 
                hight_source(40, 1080), 
                custom.config.name, 
                scrollPanel
            )
            
            local checkButton = checkbox.check_b
            checkButton.checked = settings.Get("dbt_esp_entity_" .. custom.index)
            checkButton.OnEdit = function(bool)
                ESP:ToggleFeature("entity", custom.index)
            end
            
            -- Add tooltip with description
            checkbox:SetTooltip(custom.config.desc)
            
            yPosEntity = yPosEntity + hight_source(50, 1080)
        end
        
        -- Add master toggle buttons
        CrateMonoButton(weight_source(45, 1920), hight_source(700, 1080), weight_source(220, 1920), hight_source(45, 1080), frame, "Включить всё", function()
            for _, custom in pairs(ESP.playerinfo) do
                ESP.settings.player[custom.index] = true
                settings.Set("dbt_esp_player_" .. custom.index, true)
            end
            
            for _, custom in pairs(ESP.entityinfo) do
                ESP.settings.entity[custom.index] = true
                settings.Set("dbt_esp_entity_" .. custom.index, true)
            end
        end, true)
        
        CrateMonoButton(weight_source(290, 1920), hight_source(700, 1080), weight_source(220, 1920), hight_source(45, 1080), frame, "Отключить всё", function()
            for _, custom in pairs(ESP.playerinfo) do
                ESP.settings.player[custom.index] = false
                settings.Set("dbt_esp_player_" .. custom.index, false)
            end
            
            for _, custom in pairs(ESP.entityinfo) do
                ESP.settings.entity[custom.index] = false
                settings.Set("dbt_esp_entity_" .. custom.index, false)
            end
            
        end, true)
        
    end,
    
    PaintAdv = function(self, w, h)
        draw.DrawText("Настройка ESP функций", "RobotoLight_43", w / 2, hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER)
    end
}