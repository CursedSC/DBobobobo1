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
    ["Тяжелое ранение"] = "Тяжёлое ранение",
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

local woundOrder = {
    "Ушиб",
    "Ранение",
    "Тяжелое ранение",
    "Пулевое ранение",
    "Перелом",
    "Парализован"
}

dbt.AdminFunc["wounds_manage"] = {
    name = "Управление ранениями",
    build = function(frame)
        local yPos = hight_source(82, 1080)
        local checkboxHeight = hight_source(48, 1080)
        local spacing = hight_source(63, 1080)
        
        for _, woundKey in ipairs(woundOrder) do
            local woundName = WoundTypesRu[woundKey]
            
            local container = vgui.Create("EditablePanel", frame)
            container:SetPos(weight_source(20, 1920), yPos)
            container:SetSize(weight_source(1310, 1920), checkboxHeight)
            
            container.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
                draw.SimpleText(woundName, "RobotoLight_32", h + 15, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            local check_b = vgui.Create("DButton", container)
            check_b:SetPos(0, 0)
            check_b:SetSize(checkboxHeight, checkboxHeight)
            check_b:SetText("")
            check_b.checked = DBT_WoundsSettings[woundKey]
            
            check_b.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, monobuttons_1)
                
                if self.checked then
                    surface.SetDrawColor(255, 255, 255, 255)
                    local checkSize = h * 0.6
                    local margin = (h - checkSize) / 2
                    
                    draw.RoundedBox(2, margin, margin, checkSize, checkSize, Color(143, 37, 156, 180))
                    
                    surface.SetDrawColor(255, 255, 255, 255)
                    local x1, y1 = margin + checkSize * 0.2, margin + checkSize * 0.5
                    local x2, y2 = margin + checkSize * 0.4, margin + checkSize * 0.7
                    local x3, y3 = margin + checkSize * 0.8, margin + checkSize * 0.3
                    
                    surface.DrawLine(x1, y1, x2, y2)
                    surface.DrawLine(x2, y2, x3, y3)
                end
            end
            
            check_b.DoClick = function(self)
                self.checked = not self.checked
                DBT_WoundsSettings[woundKey] = self.checked
                
                net.Start("admin.ToggleWound")
                    net.WriteString(woundKey)
                    net.WriteBool(self.checked)
                net.SendToServer()
            end
            
            yPos = yPos + spacing
        end
        
        local infoLabel = vgui.Create("DLabel", frame)
        infoLabel:SetPos(weight_source(20, 1920), yPos + hight_source(20, 1080))
        infoLabel:SetSize(weight_source(1310, 1920), hight_source(100, 1080))
        infoLabel:SetFont("RobotoLight_26")
        infoLabel:SetTextColor(Color(200, 200, 200))
        infoLabel:SetText("Выключенные типы ранений не будут применяться \nк игрокам при получении урона.")
        infoLabel:SetWrap(true)
    end,
    PaintAdv = function(self, w, h)
        draw.DrawText("Настройки ранений", "RobotoLight_43", w / 2, hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
}