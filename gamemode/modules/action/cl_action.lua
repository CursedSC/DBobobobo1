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

MedicationMenu = MedicationMenu or {}
MedicationMenu.CurrentStage = 1
MedicationMenu.SelectedMedication = nil
MedicationMenu.TargetPlayer = nil

local BODY_PARTS = {
    {name = "Голова", hitgroup = "Голова"},
    {name = "Туловище", hitgroup = "Туловище"},
    {name = "Левая рука", hitgroup = "Леваярука"},
    {name = "Правая рука", hitgroup = "Праваярука"},
    {name = "Левая нога", hitgroup = "Леваянога"},
    {name = "Правая нога", hitgroup = "Праваянога"}
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
        name = "Специальные препараты",
        items = {42, 43},
        icon = Material("icons/medical_poison.png")
    }
}

local function GetPlayerMedications(ply)
    local meds = {}
    local inv = ply:GetInventory()
    
    if not inv then return meds end
    
    for _, item in pairs(inv) do
        if item and item.id and dbt.inventory.items[item.id] and dbt.inventory.items[item.id].medicine then
            table.insert(meds, {
                id = item.id,
                data = dbt.inventory.items[item.id],
                meta = item.meta,
                position = item.position
            })
        end
    end
    
    return meds
end

local function CreateMedicationFrame()
    if IsValid(MedicationMenu.Frame) then
        MedicationMenu.Frame:Remove()
    end
    
    local frameW, frameH = 600, 500
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:SetDraggable(false)
    
    frame.Paint = function(self, w, h)
        surface.SetDrawColor(49, 57, 61, 255)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, 0, w, 35)
        
        local title = "Медикаменты"
        if MedicationMenu.CurrentStage == 2 then
            title = "Выбор препарата"
        elseif MedicationMenu.CurrentStage == 3 then
            title = "Выбор части тела"
        end
        
        draw.DrawText(title, "DermaLarge", w * 0.5, 8, color_white, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(100, 100, 100, 100)
        surface.DrawRect(10, h - 50, w - 20, 1)
    end
    
    local backBtn = vgui.Create("DButton", frame)
    backBtn:SetPos(10, frameH - 40)
    backBtn:SetSize(100, 30)
    backBtn:SetText("")
    backBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 80, 80, 255) or Color(60, 60, 60, 255)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h)
        draw.DrawText("Назад", "DermaDefault", w * 0.5, h * 0.3, color_white, TEXT_ALIGN_CENTER)
    end
    backBtn.DoClick = function()
        if MedicationMenu.CurrentStage == 1 then
            frame:Close()
            MedicationMenu.TargetPlayer = nil
        elseif MedicationMenu.CurrentStage == 2 then
            MedicationMenu.CurrentStage = 1
            CreateMedicationFrame()
        elseif MedicationMenu.CurrentStage == 3 then
            MedicationMenu.CurrentStage = 2
            CreateMedicationFrame()
        end
    end
    
    MedicationMenu.Frame = frame
    return frame
end

local function CreateStage1_Categories(frame)
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 45)
    scroll:SetSize(580, 400)
    
    local yPos = 5
    
    for catIdx, category in ipairs(MEDICATION_CATEGORIES) do
        local playerMeds = GetPlayerMedications(LocalPlayer())
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
            local catBtn = vgui.Create("DButton", scroll)
            catBtn:SetPos(10, yPos)
            catBtn:SetSize(560, 80)
            catBtn:SetText("")
            
            catBtn.Paint = function(self, w, h)
                local col = self:IsHovered() and Color(70, 70, 80, 255) or Color(55, 60, 65, 255)
                surface.SetDrawColor(col)
                surface.DrawRect(0, 0, w, h)
                
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(category.icon)
                surface.DrawTexturedRect(10, 10, 60, 60)
                
                draw.DrawText(category.name, "DermaLarge", 85, 15, color_white, TEXT_ALIGN_LEFT)
                
                local itemCount = 0
                for _, itemId in ipairs(category.items) do
                    for _, med in ipairs(playerMeds) do
                        if med.id == itemId then itemCount = itemCount + 1 end
                    end
                end
                draw.DrawText("Доступно: " .. itemCount, "DermaDefault", 85, 45, Color(200, 200, 200), TEXT_ALIGN_LEFT)
            end
            
            catBtn.DoClick = function()
                MedicationMenu.SelectedCategory = category
                MedicationMenu.CurrentStage = 2
                CreateMedicationFrame()
                CreateStage2_Medications(MedicationMenu.Frame)
            end
            
            yPos = yPos + 90
        end
    end
end

local function CreateStage2_Medications(frame)
    if not MedicationMenu.SelectedCategory then return end
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 45)
    scroll:SetSize(580, 400)
    
    local playerMeds = GetPlayerMedications(LocalPlayer())
    local yPos = 5
    
    for _, itemId in ipairs(MedicationMenu.SelectedCategory.items) do
        for _, med in ipairs(playerMeds) do
            if med.id == itemId then
                local medBtn = vgui.Create("DButton", scroll)
                medBtn:SetPos(10, yPos)
                medBtn:SetSize(560, 100)
                medBtn:SetText("")
                
                medBtn.Paint = function(self, w, h)
                    local col = self:IsHovered() and Color(70, 70, 80, 255) or Color(55, 60, 65, 255)
                    surface.SetDrawColor(col)
                    surface.DrawRect(0, 0, w, h)
                    
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(med.data.icon)
                    surface.DrawTexturedRect(10, 10, 80, 80)
                    
                    draw.DrawText(med.data.name, "DermaLarge", 105, 15, color_white, TEXT_ALIGN_LEFT)
                    
                    local desc = med.data:GetDescription()
                    if desc and desc[2] then
                        local descText = desc[2]
                        if string.len(descText) > 60 then
                            descText = string.sub(descText, 1, 60) .. "..."
                        end
                        draw.DrawText(descText, "DermaDefault", 105, 45, Color(200, 200, 200), TEXT_ALIGN_LEFT)
                    end
                    
                    draw.DrawText("Время: " .. (med.data.time or 0) .. "с", "DermaDefault", 105, 70, Color(150, 150, 150), TEXT_ALIGN_LEFT)
                end
                
                medBtn.DoClick = function()
                    MedicationMenu.SelectedMedication = med
                    MedicationMenu.CurrentStage = 3
                    CreateMedicationFrame()
                    CreateStage3_BodyParts(MedicationMenu.Frame)
                end
                
                yPos = yPos + 110
            end
        end
    end
end

local function CreateStage3_BodyParts(frame)
    if not MedicationMenu.SelectedMedication then return end
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 45)
    scroll:SetSize(580, 400)
    
    local yPos = 5
    
    for _, bodyPart in ipairs(BODY_PARTS) do
        local partBtn = vgui.Create("DButton", scroll)
        partBtn:SetPos(10, yPos)
        partBtn:SetSize(560, 70)
        partBtn:SetText("")
        
        partBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(70, 70, 80, 255) or Color(55, 60, 65, 255)
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)
            
            draw.DrawText(bodyPart.name, "DermaLarge", 20, 20, color_white, TEXT_ALIGN_LEFT)
        end
        
        partBtn.DoClick = function()
            local target = MedicationMenu.TargetPlayer or LocalPlayer()
            
            net.Start("dbt.ApplyMedication")
                net.WriteEntity(target)
                net.WriteUInt(MedicationMenu.SelectedMedication.id, 16)
                net.WriteString(bodyPart.hitgroup)
                net.WriteUInt(MedicationMenu.SelectedMedication.position or 0, 16)
            net.SendToServer()
            
            frame:Close()
            MedicationMenu.CurrentStage = 1
            MedicationMenu.SelectedMedication = nil
            MedicationMenu.TargetPlayer = nil
        end
        
        yPos = yPos + 80
    end
end

function OpenMedicationMenu(targetPlayer)
    MedicationMenu.TargetPlayer = targetPlayer
    MedicationMenu.CurrentStage = 1
    
    local frame = CreateMedicationFrame()
    CreateStage1_Categories(frame)
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