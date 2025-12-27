-- LOTM Artifact Slots UI
-- Упрощённый UI слота артефакта для инвентаря

if not CLIENT then return end

LOTM = LOTM or {}
LOTM.ArtifactSlotsUI = {}

local colorOutLine = Color(211, 25, 202)
local colorSlot = Color(40, 40, 50, 200)
local colorSlotFilled = Color(60, 30, 80, 220)
local colorText = Color(255, 255, 255)
local colorTextDim = Color(180, 180, 180)

-- Создать панель слота артефакта для интеграции в инвентарь
function LOTM.ArtifactSlotsUI.CreateSlotPanel(parent, size)
    size = size or 60
    
    local slotBtn = vgui.Create("DButton", parent)
    slotBtn:SetSize(size, size)
    slotBtn:SetText("")
    
    slotBtn.Paint = function(self, w, h)
        local equipped = nil
        if LOTM.Artifacts and LOTM.Artifacts.GetEquipped then
            equipped = LOTM.Artifacts.GetEquipped(LocalPlayer())
        end
        
        local bgColor = equipped and colorSlotFilled or colorSlot
        if self:IsHovered() then bgColor = Color(80, 40, 100) end
        
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        surface.SetDrawColor(equipped and colorOutLine or Color(80, 80, 90))
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        if equipped then
            -- Показываем первые 3 буквы названия
            local shortName = string.sub(equipped.name or "ART", 1, 3)
            draw.SimpleText(shortName, "DermaDefaultBold", w/2, h/2 - 8, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("💎", "DermaDefault", w/2, h/2 + 8, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("💎", "DermaDefaultBold", w/2, h/2, Color(80, 80, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    slotBtn.DoClick = function()
        local equipped = nil
        if LOTM.Artifacts and LOTM.Artifacts.GetEquipped then
            equipped = LOTM.Artifacts.GetEquipped(LocalPlayer())
        end
        
        if equipped then
            -- Снять артефакт
            net.Start("LOTM.Artifacts.Unequip")
            net.SendToServer()
            surface.PlaySound("items/ammopickup.wav")
        else
            -- Открыть меню предметов
            if LOTM.UnifiedMenu and LOTM.UnifiedMenu.Open then
                LOTM.UnifiedMenu.Open()
            end
        end
    end
    
    slotBtn.Think = function(self)
        local equipped = nil
        if LOTM.Artifacts and LOTM.Artifacts.GetEquipped then
            equipped = LOTM.Artifacts.GetEquipped(LocalPlayer())
        end
        
        if equipped then
            self:SetTooltip("Артефакт: " .. equipped.name .. "\n\nНажмите, чтобы снять")
        else
            self:SetTooltip("Слот артефакта\n\nПусто - нажмите для выбора")
        end
    end
    
    return slotBtn
end

-- Получить информацию об экипированном артефакте для HUD
function LOTM.ArtifactSlotsUI.GetEquippedInfo()
    if not LOTM.Artifacts or not LOTM.Artifacts.GetEquipped then
        return nil
    end
    
    return LOTM.Artifacts.GetEquipped(LocalPlayer())
end

-- Минималистичный HUD индикатор артефакта
hook.Add("HUDPaint", "LOTM.ArtifactSlots.HUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local equipped = LOTM.ArtifactSlotsUI.GetEquippedInfo()
    if not equipped then return end
    
    local scrw, scrh = ScrW(), ScrH()
    local x = scrw - 80
    local y = scrh - 80
    local size = 50
    
    -- Фон слота
    draw.RoundedBox(4, x, y, size, size, Color(0, 0, 0, 150))
    surface.SetDrawColor(colorOutLine)
    surface.DrawOutlinedRect(x, y, size, size, 1)
    
    -- Иконка
    draw.SimpleText("💎", "DermaDefaultBold", x + size/2, y + size/2 - 5, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Кулдаун
    if LOTM.Artifacts.GetCooldownRemaining then
        local cd = LOTM.Artifacts.GetCooldownRemaining(ply)
        if cd > 0 then
            draw.SimpleText(math.ceil(cd), "DermaDefault", x + size/2, y + size/2 + 10, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)

print("[LOTM] Artifact Slots UI loaded")
