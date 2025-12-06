surface.CreateFont( "dbt.Action", {
font = "Arial",
extended = false,
size = 24,
weight = 500,
blursize = 0,
scanlines = 0,
antialias = true,
underline = false,
italic = false,
strikeout = false,
symbol = false,
rotary = false,
shadow = false,
additive = false,
outline = false,
} )

net.Receive("unsleepmenu",function(len,pl)
		data = net.ReadEntity()
			local sw, sh = ScrW(), ScrH()
			local frameW, frameH, animTime, animDelay, animEase = 300, 200, 1.8, 0, .1
			SSactionmenu = vgui.Create( "DFrame")
			SSactionmenu:SetSize( 300, 0 )
			SSactionmenu:Center()
			SSactionmenu:SetTitle(data:GetNWString("dbt.CHR"))
			SSactionmenu:MakePopup()
			local isAnimating = true
		SSactionmenu:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
				isAnimating = false 
		end)
				SSactionmenu.Think = function(me)
				if isAnimating then
						me:Center()
				end
		end
					SSactionmenu.Paint = function(me,w,h)
		        surface.SetDrawColor(49,57,61)
		        surface.DrawRect(0, 0, w, h)
    		end

				local SBbut1 = vgui.Create( "XeninUI.ButtonV2", SSactionmenu )
				SBbut1:SetText( "" )
				SBbut1:SetPos( 0, 70 )
				SBbut1:SetSize(300, 20)
				SBbut1:SetSolidColor(Color(0, 0, 200, 255))
				SBbut1.DoClick = function()
					net.Start("unsleeppl")
						net.WriteEntity(data)
					net.SendToServer()
					SBbut1:GetParent():Close()
			end
							SBbut1.Paint = function(me,w,h)
			        surface.SetDrawColor(59,67,71)
			        surface.DrawRect(0, 0, w, h)
			        draw.DrawText( "Разбудить", "TargetID", w * 0.5, h * 0.1, color_white, TEXT_ALIGN_CENTER )
    			end

	end)

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

local function OpenMedicationMinigame(duration, rounds, callback, medData)
    MedicationMinigame:Start(duration, rounds, callback, medData)
end

local MedicationState = {
    TargetPlayer = nil,
    SelectedCategory = nil,
    SelectedMedication = nil
}

local BODY_PARTS = {
    {name = "Голова", hitgroup = "Голова"},
    {name = "Туловище", hitgroup = "Туловище"},
    {name = "Левая рука", hitgroup = "Леваярука"},
    {name = "Правая рука", hitgroup = "Праваярука"},
    {name = "Левая нога", hitgroup = "Леваянога"},
    {name = "Правая нога", hitgroup = "Праваянога"}
}

local function GetPlayerMedications()
    local meds = {}
    local inv = dbt.inventory.player or {}
    
    for k, item in pairs(inv) do
        if item and item.id and dbt.inventory.items[item.id] and dbt.inventory.items[item.id].medicine then
            table.insert(meds, {
                id = item.id,
                data = dbt.inventory.items[item.id],
                meta = item.meta,
                position = k,
                slot = item.slot
            })
        end
    end
    
    return meds
end

local function BuildBodyPartsWheel()
    local bodyPartsTable = {}
    bodyPartsTable[1] = {
        name = "Назад",
        mat = http.Material("https://imgur.com/lszTmGe.png"),
        func = function()
            BuildMedicationsWheel()
        end
    }
    
    for i, bodyPart in ipairs(BODY_PARTS) do
        bodyPartsTable[i + 1] = {
            name = bodyPart.name,
            mat = Material("icons/medical_plaster.png"),
            func = function()
                local target = MedicationState.TargetPlayer or LocalPlayer()
                local selectedMed = MedicationState.SelectedMedication
                
                OpenMedicationMinigame(10, 4, function(success, effectiveness, hits, misses)
                    if success then
                        net.Start("dbt.ApplyMedication")
                            net.WriteEntity(target)
                            net.WriteUInt(selectedMed.id, 16)
                            net.WriteString(bodyPart.hitgroup)
                            net.WriteUInt(selectedMed.position or 0, 16)
                            net.WriteFloat(effectiveness)
                        net.SendToServer()
                    else
                        chat.AddText(Color(234, 30, 33), "[Лечение] ", Color(255, 255, 255), "Процедура провалена! Медикамент потрачен впустую.")
                        
                        net.Start("dbt.ApplyMedication")
                            net.WriteEntity(target)
                            net.WriteUInt(selectedMed.id, 16)
                            net.WriteString(bodyPart.hitgroup)
                            net.WriteUInt(selectedMed.position or 0, 16)
                            net.WriteFloat(0)
                        net.SendToServer()
                    end
                end, selectedMed.data)
                
                MedicationState.SelectedMedication = nil
                MedicationState.TargetPlayer = nil
            end
        }
    end
    
    NewWheel(bodyPartsTable)
end

function BuildMedicationsWheel()
    if not MedicationState.SelectedCategory then return end
    
    local playerMeds = GetPlayerMedications()
    local medicationsTable = {}
    
    medicationsTable[1] = {
        name = "Назад",
        mat = http.Material("https://imgur.com/lszTmGe.png"),
        func = function()
            BuildMedicationCategoriesWheel()
        end
    }
    
    local idx = 2
    for _, itemId in ipairs(MedicationState.SelectedCategory.items) do
        for _, med in ipairs(playerMeds) do
            if med.id == itemId then
                medicationsTable[idx] = {
                    name = med.data.name,
                    mat = med.data.icon or Material("icons/medical_chest.png"),
                    func = function()
                        MedicationState.SelectedMedication = med
                        BuildBodyPartsWheel()
                    end
                }
                idx = idx + 1
            end
        end
    end
    
    NewWheel(medicationsTable)
end

function BuildMedicationCategoriesWheel()
    local playerMeds = GetPlayerMedications()
    local categoriesTable = {}
    
    categoriesTable[1] = {
        name = "Назад",
        mat = http.Material("https://imgur.com/lszTmGe.png"),
        func = function()
            NewWheel(UsePlayerOptions)
        end
    }
    
    local MEDICATION_CATEGORIES = {
        {
            name = "Лечение ранений",
            items = {31, 34, 37},
            icon = Material("icons/medical_plaster.png")
        },
        {
            name = "Лечение переломов",
            items = {32},
            icon = Material("icons/151.png")
        },
        {
            name = "Лечение ушибов",
            items = {33},
            icon = Material("icons/medical_antiseptic_cream.png")
        },
        {
            name = "Спецпрепараты",
            items = {42, 43},
            icon = Material("icons/medical_poison.png")
        }
    }
    
    local idx = 2
    for _, category in ipairs(MEDICATION_CATEGORIES) do
        local hasItems = false
        
        for _, itemId in ipairs(category.items) do
            for _, med in ipairs(playerMeds) do
                if med.id == itemId then
                    hasItems = true
                    break
                end
            end
            if hasItems then break end
        end
        
        if hasItems then
            categoriesTable[idx] = {
                name = category.name,
                mat = category.icon,
                func = function()
                    MedicationState.SelectedCategory = category
                    BuildMedicationsWheel()
                end
            }
            idx = idx + 1
        end
    end
    
    NewWheel(categoriesTable)
end

function OpenMedicationMenu(targetPlayer)
    MedicationState.TargetPlayer = targetPlayer
    BuildMedicationCategoriesWheel()
end

net.Receive("dbt.OpenMedicationMenu", function()
    local target = net.ReadEntity()
    OpenMedicationMenu(target)
end)

UsePlayerOptions = {
	[1] = {
		name = "Толкнуть",
		mat = http.Material("https://imgur.com/oRAepPx.png"),
		func = function()
			net.Start("PushPlayer")
				net.WriteEntity(TargetPlayer)
			net.SendToServer()
			TargetPlayer = nil
		end,
	},
	[2] = {
		name = "Обыскать",
		mat = http.Material("https://imgur.com/lbhKRs1.png"),
		func = function() 
			netstream.Start("dbt/finding/started", TargetPlayer)

			dbt.ShowTimerTarget(5, "Обыск...", TargetPlayer, function()
				
				netstream.Start("dbt/finding/ended", TargetPlayer) TargetPlayer = nil
			end)
		end,
	},
	[3] = {
		name = "Обыскать публично",
		mat = http.Material("https://imgur.com/jXy2xeP.png"),
		func = function() 
			netstream.Start("dbt/finding/started", TargetPlayer)

			dbt.ShowTimerTarget(5, "Обыск...", TargetPlayer, function()
				
				netstream.Start("dbt/finding/ended", TargetPlayer, true) TargetPlayer = nil
			end)
			
		end,
	},
	[4] = {
		name = "Применить медикамент",
		mat = Material("icons/medical_chest.png"),
		func = function()
			if IsValid(TargetPlayer) then
				OpenMedicationMenu(TargetPlayer)
			end
		end,
	},
}

net.Receive("OpenActionMenu",function(len,pl)
	TargetPlayer = net.ReadEntity()
	NewWheel(UsePlayerOptions)
end)

local function a(Oprndesc, ent)
	local frameW, frameH, animTime, animDelay, animEase = 500, 600, 1.8, 0, .1
	Oprndesc.isAnimating = true
   Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        Oprndesc.isAnimating = false
   end)
   	SIGN_NAME, SIGN_TEXT = "", ""
   	Oprndesc.TextEntryPH = vgui.Create( "DTextEntry", Oprndesc )
 	Oprndesc.TextEntryPH:SetPos( 5, 90 )					
	Oprndesc.TextEntryPH:SetSize( 490, 30 )	  	
	Oprndesc.TextEntryPH:SetUpdateOnType(true)
	Oprndesc.TextEntryPH.OnTextChanged = function( self )
		SIGN_NAME = self:GetValue() 
	end

   	Oprndesc.TextEntryED = vgui.Create( "DTextEntry", Oprndesc )
 	Oprndesc.TextEntryED:SetPos( 5, 170 )					
	Oprndesc.TextEntryED:SetSize( 490, 30 )
	Oprndesc.TextEntryED:SetMultiline(true)	  	
	Oprndesc.TextEntryED:SetUpdateOnType(true)
	Oprndesc.TextEntryED.OnTextChanged = function( self )
		SIGN_TEXT = self:GetValue() 
	end

	Oprndesc.Write = vgui.Create( "DButton", Oprndesc ) 
	Oprndesc.Write:SetText( "" )					
	Oprndesc.Write:SetPos( frameW / 2 - 75, frameH * 0.92 )					
	Oprndesc.Write:SetSize( 150, 30 )					
	Oprndesc.Write.DoClick = function()				
		netstream.Start("dbt/start/write", ent, SIGN_NAME, SIGN_TEXT)
		Oprndesc:Close()
	end
	Oprndesc.Write.Paint = function(self,w,h)
                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w, h)
        draw.DrawText("Создать записку", "TargetID", w * 0.5, h * 0.2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

netstream.Hook("dbt/start/write", function(ent, sign_count)	
			STATE_MENU_BOX = 1
			local frameW, frameH, animTime, animDelay, animEase = 300, 400, 1.8, 0, .1
            Oprndesc = vgui.Create("DFrame")
            Oprndesc:SetTitle("")
            Oprndesc:MakePopup()
            Oprndesc:SetSize(0, 400)
            Oprndesc:Center()
            Oprndesc.isAnimating = true
            Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
                Oprndesc.isAnimating = false
            end)
            Oprndesc.Paint = function(self,w,h)
            	if self.isAnimating then 
            		self:Center()
            	end
            	if self.TextEntryPH then 
            		Oprndesc.TextEntryPH:SetSize( w - 10, 30 )
            	end
            	if self.TextEntryED then 
            		Oprndesc.TextEntryED:SetSize( w - 10, h * 0.6 )
            	end
                surface.SetDrawColor(51, 43, 54, 255)
                surface.DrawRect(0, 0, w,h)

                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w, h * 0.07)


                if STATE_MENU_BOX == 1 then 
	                surface.SetDrawColor( 255, 255, 255, 255 ) 
	                surface.SetMaterial( Material( "icons/78.png" ) ) 
	                surface.DrawTexturedRect( 5, h * 0.07 + 5, 64, 64 ) 

	                draw.DrawText("Записка", "TargetID", 72, h * 0.09, Color(255,255,255,255), TEXT_ALIGN_LEFT)
	                draw.DrawText("Осталось: "..sign_count, "TargetID", 72, h * 0.13	, Color(255,255,255,255), TEXT_ALIGN_LEFT)
	            end
                if STATE_MENU_BOX == 2 then 


	                draw.DrawText("Название записки", "DermaLarge", w * 0.5, h * 0.09, Color(255,255,255,255), TEXT_ALIGN_CENTER)

	                draw.DrawText("Текст записки", "DermaLarge", w * 0.5, h * 0.225, Color(255,255,255,255), TEXT_ALIGN_CENTER)
	            end
            end

			local DermaButton = vgui.Create( "DButton", Oprndesc ) 
			DermaButton:SetText( "" )					
			DermaButton:SetPos( 73, 70 )					
			DermaButton:SetSize( 150, 30 )					
			DermaButton.DoClick = function()
				if sign_count <= 0 then return end				
				STATE_MENU_BOX = 2
				DermaButton:Remove()
				a(Oprndesc, ent)
			end
			DermaButton.Paint = function(self,w,h)
                draw.DrawText("Создать записку", "TargetID", 0, h * 0.2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

end)