-- LOTM Potion System - Client
-- Клиентская логика системы зелий

if not CLIENT then return end
if not LOTM then return end

LOTM.ClientData = LOTM.ClientData or {
    CurrentPotion = nil,
    DigestionProgress = 0,
    AbilityCooldowns = {}
}

-- Получение данных клиента
net.Receive("LOTM_SyncPlayerData", function()
    local data = net.ReadTable()
    LOTM.ClientData = data
end)

-- Уведомления
net.Receive("LOTM_Notification", function()
    local message = net.ReadString()
    local color = net.ReadColor()
    
    chat.AddText(Color(100, 255, 100), "[LOTM] ", color, message)
end)

-- Активация способности через клавиши
hook.Add("PlayerButtonDown", "LOTM_AbilityActivation", function(ply, button)
    if not IsFirstTimePredicted() then return end
    if ply ~= LocalPlayer() then return end
    
    local slot = nil
    
    -- Привязка клавиш к слотам (KEY_1, KEY_2, KEY_3, KEY_4)
    if button == KEY_1 then slot = 1
    elseif button == KEY_2 then slot = 2
    elseif button == KEY_3 then slot = 3
    elseif button == KEY_4 then slot = 4
    end
    
    if slot then
        net.Start("LOTM_ActivateAbility")
            net.WriteUInt(slot, 8)
        net.SendToServer()
    end
end)

-- Простой HUD для отображения энергии и способностей
hook.Add("HUDPaint", "LOTM_SimpleHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local energy = ply:GetNWFloat("LOTM_Energy", 0)
    
    -- Энергия
    local energyBarW = 300
    local energyBarH = 25
    local energyBarX = ScrW() / 2 - energyBarW / 2
    local energyBarY = ScrH() - 100
    
    surface.SetDrawColor(30, 30, 30, 200)
    surface.DrawRect(energyBarX, energyBarY, energyBarW, energyBarH)
    
    surface.SetDrawColor(100, 150, 255, 255)
    surface.DrawRect(energyBarX + 2, energyBarY + 2, (energyBarW - 4) * (energy / 100), energyBarH - 4)
    
    draw.SimpleText("Energy: " .. math.floor(energy) .. "/100", "DermaDefault", energyBarX + energyBarW / 2, energyBarY + energyBarH / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Информация о зелье
    if LOTM.ClientData.CurrentPotion then
        local potion = LOTM.GetPotion(LOTM.ClientData.CurrentPotion)
        
        if potion then
            local text = potion.Name .. " - " .. LOTM.SEQUENCES[potion.Sequence]
            draw.SimpleText(text, "DermaDefault", ScrW() / 2, energyBarY - 30, Color(100, 255, 100), TEXT_ALIGN_CENTER)
            
            local digestText = "Digestion: " .. math.floor(LOTM.ClientData.DigestionProgress * 100) .. "%"
            draw.SimpleText(digestText, "DermaDefault", ScrW() / 2, energyBarY - 15, Color(255, 200, 100), TEXT_ALIGN_CENTER)
        end
    end
    
    -- Отображение слотов способностей
    local slotSize = 50
    local slotSpacing = 10
    local totalWidth = (slotSize * 4) + (slotSpacing * 3)
    local startX = ScrW() / 2 - totalWidth / 2
    local slotY = energyBarY + energyBarH + 10
    
    for i = 1, 4 do
        local x = startX + (i - 1) * (slotSize + slotSpacing)
        
        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(x, slotY, slotSize, slotSize)
        
        draw.SimpleText(tostring(i), "DermaLarge", x + slotSize / 2, slotY + slotSize / 2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Client-side potion system loaded\n")