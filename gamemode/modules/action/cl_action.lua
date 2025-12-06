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
                
                net.Start("dbt.ApplyMedication")
                    net.WriteEntity(target)
                    net.WriteUInt(MedicationState.SelectedMedication.id, 16)
                    net.WriteString(bodyPart.hitgroup)
                    net.WriteUInt(MedicationState.SelectedMedication.position or 0, 16)
                net.SendToServer()
                
                MedicationState.SelectedMedication = nil
                MedicationState.TargetPlayer = nil
            end
        }
    end
    
    NewWheel(bodyPartsTable)
end

function BuildMedicationsWheel()
    if not MedicationState.SelectedCategory then return end
    
    local playerMeds = GetPlayerMedications(LocalPlayer())
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
    local playerMeds = GetPlayerMedications(LocalPlayer())
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