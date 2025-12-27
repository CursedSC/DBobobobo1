-- LOTM Skills Keybind System
-- Система привязки скиллов к кнопкам

LOTM = LOTM or {}
LOTM.Keybinds = LOTM.Keybinds or {}

-- Сохраненные привязки (сохраняются между сессиями)
LOTM.Keybinds.Saved = LOTM.Keybinds.Saved or {}

-- Слоты для привязки (можно расширить)
LOTM.Keybinds.Slots = {
    [1] = {key = KEY_1, skillID = nil},
    [2] = {key = KEY_2, skillID = nil},
    [3] = {key = KEY_3, skillID = nil},
    [4] = {key = KEY_4, skillID = nil},
    [5] = {key = KEY_5, skillID = nil},
    [6] = {key = KEY_6, skillID = nil},
    [7] = {key = KEY_7, skillID = nil},
    [8] = {key = KEY_8, skillID = nil},
    [9] = {key = KEY_9, skillID = nil},
    [10] = {key = KEY_0, skillID = nil},
}

-- Привязать скилл к слоту
function LOTM.Keybinds.BindSkill(slot, skillID)
    if not LOTM.Keybinds.Slots[slot] then
        ErrorNoHalt("[LOTM] Неверный слот: " .. tostring(slot) .. "\n")
        return false
    end
    
    LOTM.Keybinds.Slots[slot].skillID = skillID
    LOTM.Keybinds.SaveBinds()
    
    return true
end

-- Отвязать скилл от слота
function LOTM.Keybinds.UnbindSkill(slot)
    if not LOTM.Keybinds.Slots[slot] then return false end
    
    LOTM.Keybinds.Slots[slot].skillID = nil
    LOTM.Keybinds.SaveBinds()
    
    return true
end

-- Получить привязку по слоту
function LOTM.Keybinds.GetBinding(slot)
    return LOTM.Keybinds.Slots[slot]
end

-- Получить слот по скиллу
function LOTM.Keybinds.GetSlotBySkill(skillID)
    for slot, data in pairs(LOTM.Keybinds.Slots) do
        if data.skillID == skillID then
            return slot
        end
    end
    return nil
end

-- Сохранить привязки
function LOTM.Keybinds.SaveBinds()
    local saveData = {}
    
    for slot, data in pairs(LOTM.Keybinds.Slots) do
        if data.skillID then
            saveData[slot] = data.skillID
        end
    end
    
    file.Write("lotm_keybinds.txt", util.TableToJSON(saveData))
end

-- Загрузить привязки
function LOTM.Keybinds.LoadBinds()
    if file.Exists("lotm_keybinds.txt", "DATA") then
        local data = file.Read("lotm_keybinds.txt", "DATA")
        local saveData = util.JSONToTable(data)
        
        if saveData then
            for slot, skillID in pairs(saveData) do
                slot = tonumber(slot)
                if LOTM.Keybinds.Slots[slot] then
                    LOTM.Keybinds.Slots[slot].skillID = skillID
                end
            end
        end
    end
end

-- Обработка нажатий клавиш
hook.Add("PlayerButtonDown", "LOTM.KeybindHandler", function(ply, button)
    if ply ~= LocalPlayer() then return end
    
    for slot, data in pairs(LOTM.Keybinds.Slots) do
        if data.key == button and data.skillID then
            -- Использовать скилл
            LOTM.ClientUseSkill(data.skillID)
            return
        end
    end
end)

-- Отрисовка панели быстрого доступа к скиллам
hook.Add("HUDPaint", "LOTM.DrawSkillBar", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local slotSize = 50
    local spacing = 5
    local totalWidth = (#LOTM.Keybinds.Slots * slotSize) + ((#LOTM.Keybinds.Slots - 1) * spacing)
    local startX = (scrW - totalWidth) / 2
    local startY = scrH - 100
    
    for slot = 1, #LOTM.Keybinds.Slots do
        local data = LOTM.Keybinds.Slots[slot]
        local x = startX + (slot - 1) * (slotSize + spacing)
        local y = startY
        
        -- Фон слота
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(x, y, slotSize, slotSize)
        
        -- Граница
        surface.SetDrawColor(100, 100, 100, 255)
        surface.DrawOutlinedRect(x, y, slotSize, slotSize)
        
        -- Номер слота
        draw.SimpleText(tostring(slot % 10), "DermaDefault", x + 5, y + 5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        -- Если скилл привязан
        if data.skillID then
            local skill = LOTM.GetSkill(data.skillID)
            if skill then
                -- Иконка скилла (можно добавить материалы)
                draw.SimpleText(string.sub(skill.name, 1, 1), "DermaLarge", x + slotSize / 2, y + slotSize / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Кулдаун
                local cooldown = LOTM.GetSkillCooldown(data.skillID)
                if cooldown > 0 then
                    -- Затемнение
                    surface.SetDrawColor(0, 0, 0, 150)
                    surface.DrawRect(x, y, slotSize, slotSize)
                    
                    -- Текст кулдауна
                    draw.SimpleText(string.format("%.1f", cooldown), "DermaDefault", x + slotSize / 2, y + slotSize / 2, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end)

-- Команда для открытия меню привязок
concommand.Add("lotm_keybinds", function()
    -- Здесь будет открываться меню привязок (можно интегрировать с существующим)
    chat.AddText(Color(0, 255, 0), "[LOTM] ", color_white, "Откройте F4 меню для настройки привязок скиллов")
end)

-- Загрузка привязок при инициализации
hook.Add("Initialize", "LOTM.LoadKeybinds", function()
    LOTM.Keybinds.LoadBinds()
end)

print("[LOTM] Система привязки скиллов к клавишам загружена")