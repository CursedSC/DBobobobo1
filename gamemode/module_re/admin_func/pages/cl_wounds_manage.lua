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
    ["Лёгкоеранение"] = "Лёгкое ранение",
    ["Среднееранение"] = "Среднее ранение",
    ["Тяжёлоеранение"] = "Тяжёлое ранение",
    ["Пулевоеранение"] = "Пулевое ранение",
    ["Перелом"] = "Перелом",
    ["Ушиб"] = "Ушиб",
    ["Парализован"] = "Парализован"
}

local BodyPartsRu = {
    ["Голова"] = "Голова",
    ["Туловище"] = "Туловище",
    ["ЛеваяРука"] = "Левая Рука",
    ["ПраваяРука"] = "Правая Рука",
    ["ЛеваяНога"] = "Левая Нога",
    ["ПраваяНога"] = "Правая Нога"
}

local function BuildListPlayer(tbl)
    local y = hight_source(9, 1080)
    for k, i in pairs(tbl) do
        local bb = vgui.Create("DButton", PlayerListScroll)
        bb:SetText("")
        bb:SetPos(weight_source(10, 1920), y)
        bb:SetSize(weight_source(462, 1920), hight_source(45, 1080))
        bb.Paint = function(self, w, h)
            if self:IsHovered() or CURRENT_PLAYER == i then
                draw.RoundedBox(0, 0, 0, w, h, col0)
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, (255 / 100) * 70))
            end
            draw.DrawText(i:Name(), "DermaLarge", w * 0.02, h * 0.15, color_white, TEXT_ALIGN_LEFT)
        end
        bb.DoClick = function(self)
            CURRENT_PLAYER = i
            if WoundsListScroll and IsValid(WoundsListScroll) then
                BuildWoundsList()
            end
        end
        y = y + hight_source(8 + 45, 1080)
    end
end

function BuildWoundsList()
    if not WoundsListScroll or not IsValid(WoundsListScroll) then return end
    if not CURRENT_PLAYER or not IsValid(CURRENT_PLAYER) then return end
    
    WoundsListScroll:GetCanvas():Clear()
    
    local wounds = CURRENT_PLAYER:GetWounds()
    if not wounds then return end
    
    local y = hight_source(9, 1080)
    local hasWounds = false
    
    for woundType, bodyParts in pairs(wounds) do
        for bodyPart, data in pairs(bodyParts) do
            hasWounds = true
            local woundName = WoundTypesRu[woundType] or woundType
            local bodyName = BodyPartsRu[bodyPart] or bodyPart
            
            local woundPanel = vgui.Create("DPanel", WoundsListScroll)
            woundPanel:SetPos(weight_source(10, 1920), y)
            woundPanel:SetSize(weight_source(820, 1920), hight_source(55, 1080))
            woundPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0,0,0, (255 / 100) * 70))
                draw.DrawText(woundName, "DermaLarge", w * 0.02, h * 0.15, Color(255, 100, 100), TEXT_ALIGN_LEFT)
                draw.DrawText(bodyName, "DermaDefault", w * 0.35, h * 0.25, Color(200, 200, 200), TEXT_ALIGN_LEFT)
            end
            
            local removeBtn = vgui.Create("DButton", woundPanel)
            removeBtn:SetPos(weight_source(680, 1920), hight_source(7.5, 1080))
            removeBtn:SetSize(weight_source(130, 1920), hight_source(40, 1080))
            removeBtn:SetText("")
            removeBtn.Paint = function(self, w, h)
                local col = self:IsHovered() and Color(200, 50, 50) or Color(150, 30, 30)
                draw.RoundedBox(4, 0, 0, w, h, col)
                draw.DrawText("Удалить", "DermaDefault", w / 2, h * 0.25, color_white, TEXT_ALIGN_CENTER)
            end
            removeBtn.DoClick = function()
                net.Start("admin.RemoveWound")
                    net.WriteEntity(CURRENT_PLAYER)
                    net.WriteString(woundType)
                    net.WriteString(bodyPart)
                net.SendToServer()
                
                timer.Simple(0.1, function()
                    if CURRENT_PLAYER and IsValid(CURRENT_PLAYER) then
                        BuildWoundsList()
                    end
                end)
            end
            
            y = y + hight_source(63, 1080)
        end
    end
    
    if not hasWounds then
        local noWoundsLabel = vgui.Create("DLabel", WoundsListScroll)
        noWoundsLabel:SetPos(weight_source(10, 1920), hight_source(9, 1080))
        noWoundsLabel:SetSize(weight_source(820, 1920), hight_source(45, 1080))
        noWoundsLabel:SetFont("DermaLarge")
        noWoundsLabel:SetTextColor(Color(150, 150, 150))
        noWoundsLabel:SetText("У игрока нет ранений")
    end
end

dbt.AdminFunc["wounds_manage"] = {
    name = "Управление ранениями",
    build = function(frame)
        CURRENT_PLAYER = nil
        local w, h = frame:GetWide(), frame:GetTall()
        
        local player_list_base = vgui.Create("DPanel", frame)
        player_list_base:SetPos(weight_source(45, 1920), hight_source(128, 1080))
        player_list_base:SetSize(weight_source(480, 1920), hight_source(387, 1080))
        player_list_base.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
        end
        
        local player_list_search_base = vgui.Create("DTextEntry", frame)
        player_list_search_base:SetPos(weight_source(45, 1920), hight_source(77, 1080))
        player_list_search_base:SetSize(weight_source(480, 1920), hight_source(41, 1080))
        player_list_search_base.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
        end
        
        local player_list_search = vgui.Create("DTextEntry", player_list_search_base)
        player_list_search:SetPos(0, 0)
        player_list_search:SetSize(weight_source(480, 1920), hight_source(41, 1080))
        player_list_search:SetFont("RobotoLight_32")
        player_list_search:SetPlaceholderColor(Color(200, 200, 200, 100))
        player_list_search:SetPaintBackground(false)
        player_list_search:SetTextColor(color_white)
        player_list_search:SetPlaceholderText("Поиск...")
        player_list_search.OnEnter = function(self)
            PlayerListScroll:GetCanvas():Clear()
            local text_f = string.lower(self:GetValue())
            local build_table = {}
            for id, pl in pairs(player.GetAll()) do
                local heckStart, heckEnd = string.find(string.lower(pl:Name()), string.lower(text_f))
                if heckStart then
                    build_table[id] = pl
                end
            end
            BuildListPlayer(build_table)
        end
        
        PlayerListScroll = vgui.Create("DScrollPanel", player_list_base)
        PlayerListScroll:SetPos(0, 0)
        PlayerListScroll:SetSize(weight_source(480, 1920), hight_source(387, 1080))
        PlayerListScroll.Paint = function(self, w, h) end
        
        local sbar = PlayerListScroll:GetVBar()
        function sbar:Paint(w, h) end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h) end
        
        BuildListPlayer(player.GetAll())
        
        local wounds_list_base = vgui.Create("DPanel", frame)
        wounds_list_base:SetPos(weight_source(545, 1920), hight_source(128, 1080))
        wounds_list_base:SetSize(weight_source(850, 1920), hight_source(387, 1080))
        wounds_list_base.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
        end
        
        local wounds_label_base = vgui.Create("DPanel", frame)
        wounds_label_base:SetPos(weight_source(545, 1920), hight_source(77, 1080))
        wounds_label_base:SetSize(weight_source(850, 1920), hight_source(41, 1080))
        wounds_label_base.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, monobuttons_1)
            draw.DrawText("Ранения игрока", "RobotoLight_32", w / 2, h * 0.2, color_white, TEXT_ALIGN_CENTER)
        end
        
        WoundsListScroll = vgui.Create("DScrollPanel", wounds_list_base)
        WoundsListScroll:SetPos(0, 0)
        WoundsListScroll:SetSize(weight_source(850, 1920), hight_source(387, 1080))
        WoundsListScroll.Paint = function(self, w, h) end
        
        local sbar2 = WoundsListScroll:GetVBar()
        function sbar2:Paint(w, h) end
        function sbar2.btnUp:Paint(w, h) end
        function sbar2.btnDown:Paint(w, h) end
        function sbar2.btnGrip:Paint(w, h) end
        
        CrateMonoButton(weight_source(545, 1920), hight_source(535, 1080), weight_source(410, 1920), hight_source(45, 1080), frame, "Удалить все ранения", function()
            if not CURRENT_PLAYER or not IsValid(CURRENT_PLAYER) then return end
            
            net.Start("admin.ClearAllWounds")
                net.WriteEntity(CURRENT_PLAYER)
            net.SendToServer()
            
            timer.Simple(0.1, function()
                if CURRENT_PLAYER and IsValid(CURRENT_PLAYER) then
                    BuildWoundsList()
                end
            end)
        end, true)
        
        CrateMonoButton(weight_source(985, 1920), hight_source(535, 1080), weight_source(410, 1920), hight_source(45, 1080), frame, "Обновить список", function()
            if CURRENT_PLAYER and IsValid(CURRENT_PLAYER) then
                BuildWoundsList()
            end
        end, true)
    end,
    PaintAdv = function(self, w, h)
        draw.DrawText("Игроки", "RobotoLight_43", weight_source(280, 1920), hight_source(25, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
}