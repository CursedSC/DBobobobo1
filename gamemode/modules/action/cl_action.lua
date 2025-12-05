surface.CreateFont( "dbt.Action", {
font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
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
	--[[
	[4] = {
		name = "Взять на руки",
		mat = http.Material("https://media.discordapp.net/attachments/881430976926973952/1137736777596153886/massobiskf.png"),
		func = function() 
	

			dbt.ShowTimerTarget(1, "Поднимаем...", TargetPlayer, function()
				
				netstream.Start("dbt/entire", TargetPlayer, true) TargetPlayer = nil
			end)
			
		end,
	},]]
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