-- LOTM Minimal HUD
-- Минимальный HUD - только уклонение и валюта

LOTM = LOTM or {}
LOTM.StatusHUD = {}

local colorOutLine = Color(211, 25, 202)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(150, 150, 150)
local colorGold = Color(255, 215, 0)
local colorSilver = Color(192, 192, 192)
local colorCopper = Color(184, 115, 51)

-- =============================================
-- HUD: ИНДИКАТОР УКЛОНЕНИЯ
-- =============================================

hook.Add("HUDPaint", "LOTM.Dodge.HUD", function()
    if not LOTM.Dodge then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local scrw, scrh = ScrW(), ScrH()
    
    -- Кулдаун уклонения
    local remaining = (LOTM.Dodge.LastUse or 0) - CurTime()
    local isReady = remaining <= 0
    
    -- Позиция (слева внизу)
    local x = 20
    local y = scrh - 90
    local size = 40
    
    -- Фон
    draw.RoundedBox(4, x, y, size, size, Color(0, 0, 0, 180))
    
    if isReady then
        -- Готов
        draw.RoundedBox(4, x + 2, y + 2, size - 4, size - 4, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 150))
        draw.SimpleText("⚡", "DermaDefaultBold", x + size/2, y + size/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        -- КД
        local progress = 1 - (remaining / LOTM.Dodge.Config.cooldown)
        local fillH = (size - 4) * progress
        draw.RoundedBox(0, x + 2, y + size - 2 - fillH, size - 4, fillH, Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, 100))
        draw.SimpleText(string.format("%.1f", remaining), "DermaDefault", x + size/2, y + size/2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Рамка
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, isReady and 200 or 80)
    surface.DrawOutlinedRect(x, y, size, size, 1)
    
    -- Подпись
    draw.SimpleText("ALT", "DermaDefault", x + size/2, y + size + 3, colorTextDim, TEXT_ALIGN_CENTER)
end)

-- =============================================
-- HUD: ВАЛЮТА (минимальный)
-- =============================================

hook.Add("HUDPaint", "LOTM.Currency.HUD.Min", function()
    if not LOTM.Currency then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local pounds = LOTM.Currency.Get(ply, "pound") or 0
    local pence = LOTM.Currency.Get(ply, "pence") or 0
    local soli = LOTM.Currency.Get(ply, "soli") or 0
    
    -- Не показываем если нет денег
    if pounds == 0 and pence == 0 and soli == 0 then return end
    
    local scrw, scrh = ScrW(), ScrH()
    local x = scrw - 150
    local y = 15
    
    -- Простое отображение в одну строку
    local text = ""
    if pounds > 0 then text = text .. pounds .. "£ " end
    if pence > 0 then text = text .. pence .. "p " end
    text = text .. soli .. "s"
    
    -- Фон
    surface.SetFont("DermaDefaultBold")
    local tw = surface.GetTextSize(text)
    draw.RoundedBox(4, x - 5, y - 2, tw + 15, 22, Color(0, 0, 0, 150))
    
    -- Текст
    draw.SimpleText(text, "DermaDefaultBold", x, y, colorGold, TEXT_ALIGN_LEFT)
end)

MsgC(Color(100, 255, 100), "[LOTM] ", colorText, "Minimal HUD loaded\n")
