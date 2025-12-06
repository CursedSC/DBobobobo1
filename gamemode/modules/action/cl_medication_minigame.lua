local MedicationMinigame = {
    active = false,
    startTime = 0,
    duration = 10,
    currentRound = 0,
    totalRounds = 4,
    hits = 0,
    misses = 0,
    
    indicatorPos = 0,
    indicatorSpeed = 0.03,
    indicatorDirection = 1,
    
    targetZoneStart = 0.4,
    targetZoneEnd = 0.6,
    
    lastHitTime = 0,
    feedback = "",
    feedbackAlpha = 0,
    
    shakeAmount = 0,
    
    callback = nil,
    medicationData = nil
}

local function weight_source(x)
    return ScrW() / 1920 * x
end

local function hight_source(x)
    return ScrH() / 1080 * x
end

function MedicationMinigame:Start(duration, rounds, callback, medData)
    self.active = true
    self.startTime = CurTime()
    self.duration = duration or 10
    self.totalRounds = rounds or 4
    self.currentRound = 1
    self.hits = 0
    self.misses = 0
    self.indicatorPos = 0
    self.indicatorDirection = 1
    self.indicatorSpeed = 0.03
    self.callback = callback
    self.medicationData = medData
    self.lastHitTime = 0
    self.feedback = ""
    self.feedbackAlpha = 0
    self.shakeAmount = 0
    
    surface.PlaySound("player/heartbeat1.wav")
    
    gui.EnableScreenClicker(true)
end

function MedicationMinigame:Stop(success)
    self.active = false
    gui.EnableScreenClicker(false)
    
    LocalPlayer():StopSound("player/heartbeat1.wav")
    
    if self.callback then
        local effectiveness = self.hits / self.totalRounds
        self.callback(success, effectiveness, self.hits, self.misses)
    end
end

function MedicationMinigame:CheckHit()
    if not self.active then return end
    if self.currentRound > self.totalRounds then return end
    if CurTime() - self.lastHitTime < 0.3 then return end
    
    if self.indicatorPos >= self.targetZoneStart and self.indicatorPos <= self.targetZoneEnd then
        self.hits = self.hits + 1
        self.currentRound = self.currentRound + 1
        self.lastHitTime = CurTime()
        self.feedback = "ОТЛИЧНО!"
        self.feedbackAlpha = 1
        self.indicatorSpeed = self.indicatorSpeed + 0.005
        
        surface.PlaySound("buttons/button14.wav")
        
        if self.currentRound > self.totalRounds then
            timer.Simple(0.5, function()
                if self.active then
                    self:Stop(true)
                end
            end)
        end
    else
        self.misses = self.misses + 1
        self.currentRound = self.currentRound + 1
        self.lastHitTime = CurTime()
        self.feedback = "ПРОМАХ!"
        self.feedbackAlpha = 1
        self.shakeAmount = 10
        
        surface.PlaySound("buttons/button10.wav")
        
        if self.currentRound > self.totalRounds then
            timer.Simple(0.5, function()
                if self.active then
                    local success = self.hits >= 2
                    self:Stop(success)
                end
            end)
        end
    end
end

local heartbeatMat = Material("icon16/heart.png")
local matGradient = Material("gui/gradient")

hook.Add("Think", "MedicationMinigame.Think", function()
    if not MedicationMinigame.active then return end
    
    local elapsed = CurTime() - MedicationMinigame.startTime
    if elapsed >= MedicationMinigame.duration then
        local success = MedicationMinigame.hits >= 2
        MedicationMinigame:Stop(success)
        return
    end
    
    MedicationMinigame.indicatorPos = MedicationMinigame.indicatorPos + (MedicationMinigame.indicatorSpeed * MedicationMinigame.indicatorDirection)
    
    if MedicationMinigame.indicatorPos >= 1 then
        MedicationMinigame.indicatorPos = 1
        MedicationMinigame.indicatorDirection = -1
    elseif MedicationMinigame.indicatorPos <= 0 then
        MedicationMinigame.indicatorPos = 0
        MedicationMinigame.indicatorDirection = 1
    end
    
    if MedicationMinigame.feedbackAlpha > 0 then
        MedicationMinigame.feedbackAlpha = MedicationMinigame.feedbackAlpha - FrameTime() * 2
    end
    
    if MedicationMinigame.shakeAmount > 0 then
        MedicationMinigame.shakeAmount = Lerp(FrameTime() * 10, MedicationMinigame.shakeAmount, 0)
    end
end)

hook.Add("HUDPaint", "MedicationMinigame.Draw", function()
    if not MedicationMinigame.active then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW / 2, scrH / 2
    
    local shakeX = math.random(-MedicationMinigame.shakeAmount, MedicationMinigame.shakeAmount)
    local shakeY = math.random(-MedicationMinigame.shakeAmount, MedicationMinigame.shakeAmount)
    
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, scrW, scrH)
    
    local elapsed = CurTime() - MedicationMinigame.startTime
    local timeLeft = math.max(0, MedicationMinigame.duration - elapsed)
    
    draw.SimpleText("Стабилизация", "Comfortaa X40", centerX + shakeX, centerY - hight_source(200) + shakeY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("Попадание: %d/%d", MedicationMinigame.currentRound - 1, MedicationMinigame.totalRounds), "Comfortaa X28", centerX + shakeX, centerY - hight_source(150) + shakeY, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("Время: %.1f сек", timeLeft), "Comfortaa X28", centerX + shakeX, centerY - hight_source(120) + shakeY, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    local barWidth = weight_source(800)
    local barHeight = hight_source(60)
    local barX = centerX - barWidth / 2 + shakeX
    local barY = centerY - barHeight / 2 + shakeY
    
    surface.SetDrawColor(30, 30, 30, 255)
    draw.RoundedBox(8, barX, barY, barWidth, barHeight, Color(30, 30, 30, 255))
    
    local zoneStartX = barX + (barWidth * MedicationMinigame.targetZoneStart)
    local zoneWidth = barWidth * (MedicationMinigame.targetZoneEnd - MedicationMinigame.targetZoneStart)
    
    local pulseAlpha = math.abs(math.sin(CurTime() * 3)) * 100 + 100
    surface.SetDrawColor(82, 204, 117, pulseAlpha)
    draw.RoundedBox(6, zoneStartX, barY + hight_source(5), zoneWidth, barHeight - hight_source(10), Color(82, 204, 117, pulseAlpha))
    
    local indicatorX = barX + (barWidth * MedicationMinigame.indicatorPos)
    local indicatorWidth = weight_source(8)
    
    surface.SetDrawColor(255, 50, 50, 255)
    draw.RoundedBox(4, indicatorX - indicatorWidth / 2, barY - hight_source(10), indicatorWidth, barHeight + hight_source(20), Color(255, 50, 50, 255))
    
    draw.SimpleText("Нажмите [ПРОБЕЛ] в зелёной зоне!", "Comfortaa X28", centerX + shakeX, centerY + hight_source(100) + shakeY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    if MedicationMinigame.feedbackAlpha > 0 then
        local feedbackColor = MedicationMinigame.feedback == "ОТЛИЧНО!" and Color(82, 204, 117, 255 * MedicationMinigame.feedbackAlpha) or Color(234, 30, 33, 255 * MedicationMinigame.feedbackAlpha)
        draw.SimpleText(MedicationMinigame.feedback, "Comfortaa Bold X40", centerX, centerY + hight_source(150), feedbackColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local successRate = MedicationMinigame.hits / math.max(1, MedicationMinigame.currentRound - 1)
    local rateColor = Color(255, 255, 255, 255)
    if successRate >= 0.75 then
        rateColor = Color(82, 204, 117, 255)
    elseif successRate >= 0.5 then
        rateColor = Color(222, 193, 49, 255)
    else
        rateColor = Color(234, 30, 33, 255)
    end
    
    if MedicationMinigame.currentRound > 1 then
        draw.SimpleText(string.format("Точность: %.0f%%", successRate * 100), "Comfortaa X28", centerX + shakeX, centerY + hight_source(200) + shakeY, rateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

hook.Add("PlayerButtonDown", "MedicationMinigame.Input", function(ply, button)
    if not MedicationMinigame.active then return end
    
    if button == KEY_SPACE or button == MOUSE_LEFT then
        MedicationMinigame:CheckHit()
    end
end)

function OpenMedicationMinigame(duration, rounds, callback, medData)
    MedicationMinigame:Start(duration, rounds, callback, medData)
end

function IsMedicationMinigameActive()
    return MedicationMinigame.active
end