local MedicationProgress = {
    active = false,
    startTime = 0,
    duration = 5,
    callback = nil,
    medicationData = nil,
    cancelled = false
}

local function weight_source(x)
    return ScrW() / 1920 * x
end

local function hight_source(x)
    return ScrH() / 1080 * x
end

function MedicationProgress:Start(duration, rounds, callback, medData)
    self.active = true
    self.startTime = CurTime()
    self.duration = duration or 5
    self.callback = callback
    self.medicationData = medData
    self.cancelled = false
    
    surface.PlaySound("ambient/levels/labs/equipment_beep_loop2.wav")
    
    gui.EnableScreenClicker(false)
end

function MedicationProgress:Stop(success)
    self.active = false
    
    LocalPlayer():StopSound("ambient/levels/labs/equipment_beep_loop2.wav")
    
    if success then
        surface.PlaySound("buttons/button14.wav")
    else
        surface.PlaySound("buttons/button10.wav")
    end
    
    if self.callback then
        self.callback(success, 1, 1, 0)
    end
end

function MedicationProgress:Cancel()
    if self.active then
        self.cancelled = true
        self:Stop(false)
    end
end

hook.Add("Think", "MedicationProgress.Think", function()
    if not MedicationProgress.active then return end
    
    local elapsed = CurTime() - MedicationProgress.startTime
    if elapsed >= MedicationProgress.duration then
        MedicationProgress:Stop(true)
        return
    end
end)

hook.Add("HUDPaint", "MedicationProgress.Draw", function()
    if not MedicationProgress.active then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW / 2, scrH / 2
    
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, scrW, scrH)
    
    local elapsed = CurTime() - MedicationProgress.startTime
    local timeLeft = math.max(0, MedicationProgress.duration - elapsed)
    local progress = math.Clamp(elapsed / MedicationProgress.duration, 0, 1)
    
    draw.SimpleText("Лечение...", "Comfortaa X40", centerX, centerY - hight_source(150), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("Осталось: %.1f сек", timeLeft), "Comfortaa X28", centerX, centerY - hight_source(100), Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    local barWidth = weight_source(800)
    local barHeight = hight_source(60)
    local barX = centerX - barWidth / 2
    local barY = centerY - barHeight / 2
    
    surface.SetDrawColor(30, 30, 30, 255)
    draw.RoundedBox(8, barX, barY, barWidth, barHeight, Color(30, 30, 30, 255))
    
    local fillWidth = barWidth * progress
    local pulseAlpha = math.abs(math.sin(CurTime() * 3)) * 50 + 150
    surface.SetDrawColor(82, 204, 117, pulseAlpha)
    draw.RoundedBox(6, barX + hight_source(5), barY + hight_source(5), fillWidth - hight_source(10), barHeight - hight_source(10), Color(82, 204, 117, pulseAlpha))
    
    draw.SimpleText(string.format("Прогресс: %.0f%%", progress * 100), "Comfortaa X28", centerX, centerY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    draw.SimpleText("Не двигайтесь до завершения процедуры", "Comfortaa X28", centerX, centerY + hight_source(100), Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

hook.Add("PlayerButtonDown", "MedicationProgress.Input", function(ply, button)
    if not MedicationProgress.active then return end
    
    if button == KEY_ESCAPE then
        MedicationProgress:Cancel()
    end
end)

function OpenMedicationMinigame(duration, rounds, callback, medData)
    MedicationProgress:Start(duration, rounds, callback, medData)
end

function IsMedicationMinigameActive()
    return MedicationProgress.active
end