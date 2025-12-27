-- LOTM Potion System - Client
-- Клиентская логика системы зелий (без HUD энергии)

if not CLIENT then return end

LOTM = LOTM or {}
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

-- Примечание: HUD теперь в cl_ability_hud.lua без полоски энергии

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Client-side potion system loaded (no energy HUD)\n")
