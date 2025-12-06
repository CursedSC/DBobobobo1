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

local WoundTypesRu = {
    ["Ушиб"] = "Ушиб",
    ["Ранение"] = "Лёгкое ранение",
    ["Тяжелое ранение"] = "Тяжелое ранение",
    ["Пулевое ранение"] = "Пулевое ранение",
    ["Перелом"] = "Перелом",
    ["Парализован"] = "Парализован"
}

DBT_WoundsSettings = DBT_WoundsSettings or {
    ["Ушиб"] = true,
    ["Ранение"] = true,
    ["Тяжелое ранение"] = true,
    ["Пулевое ранение"] = true,
    ["Перелом"] = true,
    ["Парализован"] = true
}

netstream.Hook("dbt/wounds/settings_sync", function(settings)
    DBT_WoundsSettings = settings
end)

dbt.AdminFunc["wounds_manage"] = {
    name = "Управление ранениями",
    build = function(frame)
        local w, h = frame:GetWide(), frame:GetTall()
        
        local mainPanel = vgui.Create("DPanel", frame)
        mainPanel:SetPos(weight_source(45, 1920), hight_source(77, 1080))
        mainPanel:SetSize(weight_source(1350, 1920), hight_source(520, 1080))
        mainPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, monobuttons_1)
        end
        
        local yPos = hight_source(20, 1080)
        local checkboxHeight = hight_source(55, 1080)
        
        for woundKey, woundName in pairs(WoundTypesRu) do
            local woundPanel = vgui.Create("DPanel", mainPanel)
            woundPanel:SetPos(weight_source(20, 1920), yPos)
            woundPanel:SetSize(weight_source(1310, 1920), checkboxHeight)
            woundPanel.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 100))
                
                local textColor = DBT_WoundsSettings[woundKey] and Color(100, 255, 100) or Color(255, 100, 100)
                draw.DrawText(woundName, "RobotoLight_32", w * 0.02, h * 0.25, textColor, TEXT_ALIGN_LEFT)
                
                local statusText = DBT_WoundsSettings[woundKey] and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО"
                local statusColor = DBT_WoundsSettings[woundKey] and Color(100, 255, 100) or Color(255, 100, 100)
                draw.DrawText(statusText, "DermaLarge", w * 0.7, h * 0.3, statusColor, TEXT_ALIGN_LEFT)
            end
            
            local toggleBtn = vgui.Create("DButton", woundPanel)
            toggleBtn:SetPos(weight_source(1050, 1920), hight_source(7.5, 1080))
            toggleBtn:SetSize(weight_source(240, 1920), hight_source(40, 1080))
            toggleBtn:SetText("")
            toggleBtn.Paint = function(self, w, h)
                local isEnabled = DBT_WoundsSettings[woundKey]
                local baseColor = isEnabled and Color(50, 150, 50) or Color(150, 50, 50)
                local hoverColor = isEnabled and Color(70, 180, 70) or Color(180, 70, 70)
                local col = self:IsHovered() and hoverColor or baseColor
                
                draw.RoundedBox(6, 0, 0, w, h, col)
                
                local btnText = isEnabled and "ВЫКЛЮЧИТЬ" or "ВКЛЮЧИТЬ"
                draw.DrawText(btnText, "DermaDefault", w / 2, h * 0.25, color_white, TEXT_ALIGN_CENTER)
            end
            toggleBtn.DoClick = function()
                DBT_WoundsSettings[woundKey] = not DBT_WoundsSettings[woundKey]
                
                net.Start("admin.ToggleWound")
                    net.WriteString(woundKey)
                    net.WriteBool(DBT_WoundsSettings[woundKey])
                net.SendToServer()
            end
            
            yPos = yPos + checkboxHeight + hight_source(10, 1080)
        end
        
        local infoLabel = vgui.Create("DLabel", mainPanel)
        infoLabel:SetPos(weight_source(20, 1920), yPos + hight_source(20, 1080))
        infoLabel:SetSize(weight_source(1310, 1920), hight_source(50, 1080))
        infoLabel:SetFont("DermaDefault")
        infoLabel:SetTextColor(Color(200, 200, 200))
        infoLabel:SetText("Выключенные типы ранений не будут применяться к игрокам при получении урона.")
        infoLabel:SetWrap(true)
    end,
    PaintAdv = function(self, w, h)
        draw.DrawText("Настройки ранений", "RobotoLight_43", w / 2, hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
}