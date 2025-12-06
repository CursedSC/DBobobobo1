local m_pad_wounds = {}
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/bg/bg.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/bg/lines_new.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/bg/icon_cat_2.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/button/un_hovered/Knopka_1_neaktiv.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/button/un_hovered/Knopka_2_neaktiv.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/button/un_hovered/Knopka_3_neaktiv.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/button/un_hovered/Knopka_4_neaktiv.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/button/un_hovered/Knopka_5_neaktiv.png")
m_pad_wounds[#m_pad_wounds + 1] = Material("dbt/monopad/button/un_hovered/Knopka_6_neaktiv.png")

local woundPositions = {
    {name = "Голова", key = "Голова"},
    {name = "Туловище", key = "Туловище"},
    {name = "Левая рука", key = "Левая рука"},
    {name = "Правая рука", key = "Правая рука"},
    {name = "Левая нога", key = "Левая нога"},
    {name = "Правая нога", key = "Правая нога"}
}

local woundTypes = {
    {name = "Ушиб", key = "Ушиб"},
    {name = "Ранение", key = "Ранение"},
    {name = "Тяжелое ранение", key = "Тяжелое ранение"},
    {name = "Пулевое ранение", key = "Пулевое ранение"},
    {name = "Перелом", key = "Перелом"},
    {name = "Парализован", key = "Парализован"}
}

function WoundToggleMenu()
    if not LocalPlayer():IsAdmin() then 
        LocalPlayer():ChatPrint("У вас нет прав для использования этой функции!")
        return 
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local button_tbl = {}
    
    if IsValid(monopad) then
        monopad:Close()
    end
    
    local mp_owner = LocalPlayer():GetMonopadOwner()
    monopad = vgui.Create("DFrame")
    monopad:SetSize(ScrW(), ScrH())
    monopad:SetTitle("")
    monopad:SetDraggable(false)
    monopad:ShowCloseButton(false)
    monopad:MakePopup()
    
    text_poss = text_poss or 0
    
    monopad.Paint = function(self, w, h)
        for k, i in pairs(m_pad_wounds) do
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(i)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        end
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Material("dbt/characters"..dbt.chr[mp_owner].season.."/char"..dbt.chr[mp_owner].char.."/icon_monopad.png"))
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Material("dbt/monopad/bg/lines_new.png"))
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        
        for k, i in pairs(button_tbl) do
            if i:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material("dbt/monopad/button/un_hovered/Knopka_"..k.."_neaktiv.png"))
                surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            end
        end
        
        if text_poss > ScrW() * 0.781 then
            text_poss = ScrW() * 0.5 * -1
        end
        
        text_poss = text_poss + 0.5
        render.SetScissorRect(ScrW() * 0.112, 0, ScrW() * 0.793, ScrH(), true)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material("dbt/monopad/bg/run_texts.png"))
            surface.DrawTexturedRect(0 + text_poss, 0, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)
    end
    
    local titleLabel = vgui.Create("DLabel", monopad)
    titleLabel:SetPos(ScrW() * 0.3, ScrH() * 0.05)
    titleLabel:SetSize(ScrW() * 0.4, ScrH() * 0.05)
    titleLabel:SetFont("mono_pix")
    titleLabel:SetText("Управление ранениями")
    titleLabel:SetTextColor(color_white)
    titleLabel:SetContentAlignment(5)
    
    local infoLabel = vgui.Create("DLabel", monopad)
    infoLabel:SetPos(ScrW() * 0.2, ScrH() * 0.1)
    infoLabel:SetSize(ScrW() * 0.6, ScrH() * 0.05)
    infoLabel:SetFont("mono_pix")
    infoLabel:SetText("Выберите часть тела и тип ранения для отключения")
    infoLabel:SetTextColor(Color(200, 200, 200))
    infoLabel:SetContentAlignment(5)
    
    local positionPanel = vgui.Create("DPanel", monopad)
    positionPanel:SetPos(ScrW() * 0.15, ScrH() * 0.2)
    positionPanel:SetSize(ScrW() * 0.3, ScrH() * 0.65)
    positionPanel.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
        draw.RoundedBox(2, 0, 0, w, 2, Color(255, 255, 255))
        draw.RoundedBox(2, 0, h - 2, w, 2, Color(255, 255, 255))
        draw.RoundedBox(2, 0, 0, 2, h, Color(255, 255, 255))
        draw.RoundedBox(2, w - 2, 0, 2, h, Color(255, 255, 255))
    end
    
    local posTitle = vgui.Create("DLabel", positionPanel)
    posTitle:SetPos(0, 10)
    posTitle:SetSize(positionPanel:GetWide(), 30)
    posTitle:SetFont("mono_pix")
    posTitle:SetText("Части тела:")
    posTitle:SetTextColor(color_white)
    posTitle:SetContentAlignment(5)
    
    local selectedPosition = nil
    local posButtons = {}
    
    for i, pos in ipairs(woundPositions) do
        local btn = vgui.Create("DButton", positionPanel)
        btn:SetPos(10, 50 + (i - 1) * 70)
        btn:SetSize(positionPanel:GetWide() - 20, 60)
        btn:SetText("")
        btn.Paint = function(self, w, h)
            local col = Color(0, 0, 0, 200)
            if selectedPosition == pos.key then
                col = Color(50, 150, 200, 200)
            elseif self:IsHovered() then
                col = Color(30, 30, 30, 220)
            end
            
            draw.RoundedBox(5, 0, 0, w, h, col)
            draw.RoundedBox(2, 0, 0, w, 2, Color(255, 255, 255))
            draw.RoundedBox(2, 0, h - 2, w, 2, Color(255, 255, 255))
            draw.RoundedBox(2, 0, 0, 2, h, Color(255, 255, 255))
            draw.RoundedBox(2, w - 2, 0, 2, h, Color(255, 255, 255))
            
            draw.DrawText(pos.name, "mono_pix", w / 2, h / 2 - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            selectedPosition = pos.key
            surface.PlaySound("ui/monopad_choose.mp3")
        end
        posButtons[i] = btn
    end
    
    local woundPanel = vgui.Create("DPanel", monopad)
    woundPanel:SetPos(ScrW() * 0.55, ScrH() * 0.2)
    woundPanel:SetSize(ScrW() * 0.3, ScrH() * 0.65)
    woundPanel.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
        draw.RoundedBox(2, 0, 0, w, 2, Color(255, 255, 255))
        draw.RoundedBox(2, 0, h - 2, w, 2, Color(255, 255, 255))
        draw.RoundedBox(2, 0, 0, 2, h, Color(255, 255, 255))
        draw.RoundedBox(2, w - 2, 0, 2, h, Color(255, 255, 255))
    end
    
    local woundTitle = vgui.Create("DLabel", woundPanel)
    woundTitle:SetPos(0, 10)
    woundTitle:SetSize(woundPanel:GetWide(), 30)
    woundTitle:SetFont("mono_pix")
    woundTitle:SetText("Типы ранений:")
    woundTitle:SetTextColor(color_white)
    woundTitle:SetContentAlignment(5)
    
    for i, wound in ipairs(woundTypes) do
        local btn = vgui.Create("DButton", woundPanel)
        btn:SetPos(10, 50 + (i - 1) * 70)
        btn:SetSize(woundPanel:GetWide() - 20, 60)
        btn:SetText("")
        btn.Paint = function(self, w, h)
            local col = Color(0, 0, 0, 200)
            if self:IsHovered() then
                col = Color(30, 30, 30, 220)
            end
            
            draw.RoundedBox(5, 0, 0, w, h, col)
            draw.RoundedBox(2, 0, 0, w, 2, Color(255, 255, 255))
            draw.RoundedBox(2, 0, h - 2, w, 2, Color(255, 255, 255))
            draw.RoundedBox(2, 0, 0, 2, h, Color(255, 255, 255))
            draw.RoundedBox(2, w - 2, 0, 2, h, Color(255, 255, 255))
            
            draw.DrawText(wound.name, "mono_pix", w / 2, h / 2 - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            if not selectedPosition then
                LocalPlayer():ChatPrint("Сначала выберите часть тела!")
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            surface.PlaySound("ui/monopad_click.mp3")
            netstream.Start("dbt/woundsystem/remove_wound_admin", LocalPlayer(), wound.key, selectedPosition)
            LocalPlayer():ChatPrint("Убрано ранение: " .. wound.name .. " с части тела: " .. selectedPosition)
        end
    end
    
    for i = 0, 5 do
        button_tbl[i + 1] = vgui.Create("DButton", monopad)
        button_tbl[i + 1]:SetText("")
        button_tbl[i + 1]:SetPos(ScrW() * 0.01, ScrH() * 0.015 + (ScrH() * 0.155 + ScrH() * 0.01) * i)
        button_tbl[i + 1]:SetSize(ScrW() * 0.085, ScrH() * 0.155)
        button_tbl[i + 1].DoClick = function()
            but_pres(i)
        end
        button_tbl[i + 1].Paint = function(self, w, h)
        end
        local sss = button_tbl[i + 1]
        function sss:OnCursorEntered()
            surface.PlaySound("ui/monopad_choose.mp3")
        end
    end
end