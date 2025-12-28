-- LOTM Currency HUD v1.0
-- Отображение валюты на экране

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.CurrencyHUD = LOTM.CurrencyHUD or {}

-- =============================================
-- НАСТРОЙКИ
-- =============================================
LOTM.CurrencyHUD.Enabled = true
LOTM.CurrencyHUD.Position = "top_right" -- top_right, top_left, bottom_right, bottom_left
LOTM.CurrencyHUD.AnimAlpha = 0
LOTM.CurrencyHUD.ShowTime = 0
LOTM.CurrencyHUD.SHOW_DURATION = 5.0 -- Показывать X секунд после изменения

-- Цвета
local colorBG = Color(15, 15, 20, 200)
local colorOutLine = Color(211, 25, 202)
local colorGold = Color(255, 215, 0)
local colorSilver = Color(192, 192, 192)
local colorCopper = Color(184, 115, 51)
local colorText = Color(255, 255, 255)

-- Кэш значений для отслеживания изменений
local cachedPounds = 0
local cachedPence = 0
local cachedSoli = 0

-- =============================================
-- ОТРИСОВКА
-- =============================================
hook.Add("HUDPaint", "LOTM.CurrencyHUD.Draw", function()
    if not LOTM.CurrencyHUD.Enabled then return end
    if not LOTM.Currency then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Получаем текущие значения
    local pounds = LOTM.Currency.Get(ply, "pound") or 0
    local pence = LOTM.Currency.Get(ply, "pence") or 0
    local soli = LOTM.Currency.Get(ply, "soli") or 0
    
    -- Проверяем изменения
    if pounds ~= cachedPounds or pence ~= cachedPence or soli ~= cachedSoli then
        LOTM.CurrencyHUD.ShowTime = CurTime()
        cachedPounds = pounds
        cachedPence = pence
        cachedSoli = soli
    end
    
    -- Показываем только если недавно было изменение или открыто меню
    local shouldShow = (CurTime() - LOTM.CurrencyHUD.ShowTime < LOTM.CurrencyHUD.SHOW_DURATION)
        or input.IsKeyDown(KEY_TAB)
        or IsValid(LOTM.TradeUI and LOTM.TradeUI.Frame)
    
    -- Плавная анимация
    local targetAlpha = shouldShow and 1 or 0
    LOTM.CurrencyHUD.AnimAlpha = Lerp(FrameTime() * 5, LOTM.CurrencyHUD.AnimAlpha, targetAlpha)
    
    if LOTM.CurrencyHUD.AnimAlpha < 0.01 then return end
    
    local alpha = LOTM.CurrencyHUD.AnimAlpha * 255
    local scrw, scrh = ScrW(), ScrH()
    
    -- Позиция
    local panelW = 180
    local panelH = 90
    local padding = 15
    local x, y
    
    if LOTM.CurrencyHUD.Position == "top_right" then
        x = scrw - panelW - padding
        y = padding
    elseif LOTM.CurrencyHUD.Position == "top_left" then
        x = padding
        y = padding
    elseif LOTM.CurrencyHUD.Position == "bottom_right" then
        x = scrw - panelW - padding
        y = scrh - panelH - padding
    else
        x = padding
        y = scrh - panelH - padding
    end
    
    -- Фон
    draw.RoundedBox(8, x, y, panelW, panelH, Color(colorBG.r, colorBG.g, colorBG.b, alpha * 0.9))
    
    -- Рамка
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.8)
    surface.DrawOutlinedRect(x, y, panelW, panelH, 1)
    
    -- Заголовок
    draw.SimpleText("💰 КОШЕЛЁК", "DermaDefaultBold", x + panelW/2, y + 12, 
        Color(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Разделитель
    surface.SetDrawColor(colorOutLine.r, colorOutLine.g, colorOutLine.b, alpha * 0.3)
    surface.DrawRect(x + 10, y + 25, panelW - 20, 1)
    
    -- Валюты
    local currY = y + 38
    local lineH = 18
    
    -- Фунты (золото)
    draw.SimpleText("£", "DermaDefaultBold", x + 20, currY, 
        Color(colorGold.r, colorGold.g, colorGold.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Фунты:", "DermaDefault", x + 40, currY, 
        Color(colorText.r, colorText.g, colorText.b, alpha * 0.7), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(tostring(pounds), "DermaDefaultBold", x + panelW - 15, currY, 
        Color(colorGold.r, colorGold.g, colorGold.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    
    currY = currY + lineH
    
    -- Пенсы (серебро)
    draw.SimpleText("p", "DermaDefaultBold", x + 20, currY, 
        Color(colorSilver.r, colorSilver.g, colorSilver.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Пенсы:", "DermaDefault", x + 40, currY, 
        Color(colorText.r, colorText.g, colorText.b, alpha * 0.7), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(tostring(pence), "DermaDefaultBold", x + panelW - 15, currY, 
        Color(colorSilver.r, colorSilver.g, colorSilver.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    
    currY = currY + lineH
    
    -- Соли (медь)
    draw.SimpleText("s", "DermaDefaultBold", x + 20, currY, 
        Color(colorCopper.r, colorCopper.g, colorCopper.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Соли:", "DermaDefault", x + 40, currY, 
        Color(colorText.r, colorText.g, colorText.b, alpha * 0.7), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(tostring(soli), "DermaDefaultBold", x + panelW - 15, currY, 
        Color(colorCopper.r, colorCopper.g, colorCopper.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end)

-- =============================================
-- КОМАНДЫ
-- =============================================
concommand.Add("lotm_wallet", function()
    LOTM.CurrencyHUD.ShowTime = CurTime()
end)

concommand.Add("lotm_currency_hud", function()
    LOTM.CurrencyHUD.Enabled = not LOTM.CurrencyHUD.Enabled
    LocalPlayer():ChatPrint("[LOTM] Currency HUD " .. (LOTM.CurrencyHUD.Enabled and "включен" or "выключен"))
end)

concommand.Add("lotm_currency_position", function(ply, cmd, args)
    local pos = args[1] or "top_right"
    if table.HasValue({"top_right", "top_left", "bottom_right", "bottom_left"}, pos) then
        LOTM.CurrencyHUD.Position = pos
        LocalPlayer():ChatPrint("[LOTM] Currency HUD position: " .. pos)
    end
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Currency HUD v1.0 loaded\n")

