net.Receive("dbt.ShowParalyzedInfo", function()
    local playerName = net.ReadString()
    local isParalyzed = net.ReadBool()
    local drug = net.ReadString()
    local drugType = net.ReadString()
    local bodyPart = net.ReadString()
    local timeRemaining = net.ReadString()
    local status = net.ReadString()
    
    if not isParalyzed then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 350)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:Center()
    frame:MakePopup()
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.3, 0)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 35, 250))
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(45, 45, 50, 255))
        
        draw.SimpleText("Осмотр парализованного игрока", "DermaLarge", w/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText(playerName, "DermaLarge", w/2, 55, Color(255, 200, 50), TEXT_ALIGN_CENTER)
    end
    
    local infoPanel = vgui.Create("DPanel", frame)
    infoPanel:SetPos(20, 100)
    infoPanel:SetSize(460, 180)
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 200))
    end
    
    local yPos = 15
    local lineHeight = 30
    
    local statusLabel = vgui.Create("DLabel", infoPanel)
    statusLabel:SetPos(15, yPos)
    statusLabel:SetSize(430, 25)
    statusLabel:SetFont("DermaDefault")
    statusLabel:SetTextColor(Color(255, 100, 100))
    statusLabel:SetText("⚠️ Статус: " .. status)
    
    yPos = yPos + lineHeight
    
    local drugLabel = vgui.Create("DLabel", infoPanel)
    drugLabel:SetPos(15, yPos)
    drugLabel:SetSize(430, 25)
    drugLabel:SetFont("DermaDefault")
    drugLabel:SetTextColor(Color(180, 180, 255))
    drugLabel:SetText("💉 Препарат: " .. drug)
    
    yPos = yPos + lineHeight
    
    local strengthLabel = vgui.Create("DLabel", infoPanel)
    strengthLabel:SetPos(15, yPos)
    strengthLabel:SetSize(430, 25)
    strengthLabel:SetFont("DermaDefault")
    
    local strengthColor = drugType == "weak" and Color(100, 255, 100) or Color(255, 50, 50)
    local strengthText = drugType == "weak" and "Слабый" or "Сильный"
    strengthLabel:SetTextColor(strengthColor)
    strengthLabel:SetText("💪 Сила действия: " .. strengthText)
    
    yPos = yPos + lineHeight
    
    local bodyPartLabel = vgui.Create("DLabel", infoPanel)
    bodyPartLabel:SetPos(15, yPos)
    bodyPartLabel:SetSize(430, 25)
    bodyPartLabel:SetFont("DermaDefault")
    bodyPartLabel:SetTextColor(Color(255, 200, 100))
    bodyPartLabel:SetText("🎯 Место инъекции: " .. bodyPart)
    
    yPos = yPos + lineHeight
    
    local timeLabel = vgui.Create("DLabel", infoPanel)
    timeLabel:SetPos(15, yPos)
    timeLabel:SetSize(430, 25)
    timeLabel:SetFont("DermaDefault")
    timeLabel:SetTextColor(Color(150, 255, 150))
    timeLabel:SetText("⏱️ Осталось: " .. timeRemaining)
    
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetPos(175, 295)
    closeButton:SetSize(150, 40)
    closeButton:SetText("Закрыть")
    closeButton:SetFont("DermaLarge")
    closeButton:SetTextColor(Color(255, 255, 255))
    closeButton.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(70, 130, 180) or Color(50, 100, 150)
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    closeButton.DoClick = function()
        frame:AlphaTo(0, 0.2, 0, function()
            frame:Remove()
        end)
    end
    
    timer.Simple(15, function()
        if IsValid(frame) then
            frame:AlphaTo(0, 0.3, 0, function()
                if IsValid(frame) then
                    frame:Remove()
                end
            end)
        end
    end)
end)

hook.Add("HUDPaint", "dbt.ParalyzedPlayerCrosshairHint", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local trace = ply:GetEyeTrace()
    if not trace.Entity or not IsValid(trace.Entity) or not trace.Entity:IsPlayer() then return end
    
    local target = trace.Entity
    local distance = ply:GetPos():Distance(target:GetPos())
    
    if distance > 150 then return end
    
    if dbt.hasWound and dbt.hasWound(target, "Парализован") then
        local scrW, scrH = ScrW(), ScrH()
        local text = "Нажмите [E] чтобы осмотреть"
        
        draw.SimpleTextOutlined(text, "DermaDefault", scrW/2, scrH/2 + 30, Color(255, 200, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200))
        
        local statusText = "⚠️ ПАРАЛИЗОВАН"
        draw.SimpleTextOutlined(statusText, "DermaLarge", scrW/2, scrH/2 + 50, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 220))
    end
end)