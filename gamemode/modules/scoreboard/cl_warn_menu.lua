local frameColor = Color(46, 46, 46)
local frameColor2 = Color(32, 32, 32)
local frameColorUnder = Color(75, 75, 75)
local scrollColor = Color(35, 35, 35)
local textColor = Color(114, 114, 114)
local textColor2 = Color(179, 150, 7)
local textColor3 = Color(216, 180, 0)
local textColor4 = Color(153, 48, 65)

local closeMaterial = http.Material("https://imgur.com/KqoP4KA.png") 
local closeMaterial1 = http.Material("https://imgur.com/g1qeStG.png") 
local TriangleDown = http.Material("https://imgur.com/AafVNeX.png")
local TriangleUp = http.Material("https://imgur.com/Dqk4t3x.png")

function surface.DrawMulticolorText(x, y, font, text, maxW, ALPHA)
	local ALPHA = ALPHA and APLHA_PERCENT or 1
	surface.SetTextColor(255, 255, 255, 255 * ALPHA)
	surface.SetFont(font)
	surface.SetTextPos(x, y)

	local baseX = x
	local baseY = y
	local w, h = surface.GetTextSize("W")
	local lineHeight = h

	if maxW and x > 0 then
		maxW = maxW + x
	end

	for _, v in ipairs(text) do
		if isstring(v) then
			w, h = surface.GetTextSize(v)
			
			if maxW and x + w > maxW then
				v:gsub("(%s?[%S]+)", function(word)
					w, h = surface.GetTextSize(word)
					if x + w >= maxW then
						x, y = baseX, y + lineHeight
						word = word:gsub("^%s+", "")
						w, h = surface.GetTextSize(word)

						if x + w >= maxW then
							word:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", function(char)
								w, h = surface.GetTextSize(char)

								if x + w >= maxW then
									x, y = baseX, y + lineHeight
								end

								surface.SetTextPos(x, y)
								surface.DrawText(char)

								x = x + w
							end)

							return
						end
					end

					surface.SetTextPos(x, y)
					surface.DrawText(word)
					
					x = x + w

				end)
        	else
				
				surface.SetTextPos(x, y)
				surface.DrawText(v)

				x = x + w
			end
		elseif isbool(v) then 
        	x, y = baseX, y + lineHeight
       	elseif IsColor(v) then
			
			v.a = v.a or 255
			surface.SetTextColor(v.r, v.g, v.b, v.a * ALPHA)
		end
	end

	return x, y 
end




local function weight_source(x)
    return ScrW() / 1920  * x
end

local function hight_source(x)
    return ScrH() / 1080  * x 
end

local function Alpha(pr)
    return (255 / 100) * pr 
end




local warns = {}

warns["STEAM_0:1:95796521"] = {
	name = "Viarise",
	warns = {
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[С момента своего основания Crypto AG негласно сотрудничала с американским Агентством национальной безопасности в рамках джентльменского соглашения. В 1970 году Crypto AG в условиях секретности приобрели за 5,75 млн. долларов США две разведслужбы — американская ЦРУ и немецкая БНД, которые владели компанией с 1970 по 1993 год, а позже ЦРУ выкупила немецкую долю и оставалась владельцем Crypto AG до 2018 года. Сведения о владельце фирмы оставались в тайне даже от её менеджеров: право собственности подтверждалось акциями на предъявителя. Обвинения в связях с АНБ и иными западными спецслужбами компания отрицала. По итогам швейцарского парламентского расследования в 2020 году выяснилось, что спецслужбы Швейцарии были в курсе оказываемой Crypto AG помощи американским разведслужбам. Ресурсы Crypto AG использовались для взлома зашифрованной переписки высокопоставленных государственных лиц разных стран мира. Компанию обвиняли в продаже программных продуктов с бэкдорами, позволявшими американским, британским и немецким службам радиоэлектронной разведки перехватывать секретную информацию.]]
		},
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
	}	
}


warns["STEAM_0:1:188105562"] = {
	name = "Demit",
	warns = {
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
	}
}

warns["STEAM_1:0:509133729"] = {
	name = "Demit",
	warns = {
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
	}
}

warns["STEAM_0:1:188840336"] = {
	name = "Demit",
	warns = {
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
		{
			admin = {
				name = "Viarise",
				steamid = "STEAM_0:1:95796521"
			},
			timesnap = 1688674083,
			description = [[Подробности: Нарушение правила об оскорблении администрации. Человек не прекращал это делать после многочисленных предупреждений.]]
		},
	}
}


local true_wl = {
  ["STEAM_0:1:95796521"] = true,
  ["STEAM_0:1:216502433"] = true,
}

local function BuildDescription(parent, _warns)
	x, StartY = parent:GetPos()
	StartY = StartY + hight_source(52)
	TrueTall = 0
	for k, i in pairs(_warns) do 

    	x, y = surface.DrawMulticolorText(hight_source(5), hight_source(7) , "Comfortaa X20", {
			i.description
		}, weight_source(960))
    	local textY = y + hight_source(25)
		local YSize = hight_source(49) + y + hight_source(25)  
		local PlayerWarnPanel = vgui.Create( "EditablePanel", warn_scroll ) 
		PlayerWarnPanel:SetSize( weight_source(980), YSize )
		PlayerWarnPanel:SetPos( weight_source(5), StartY )
		PlayerWarnPanel:SetText("")

		local TimeString = os.date( "%d.%m.%Y" , i.timesnap )
		PlayerWarnPanel.Paint = function(self, w, h)
    	    surface.SetDrawColor(frameColorUnder)
    	    surface.DrawRect(0,0,w,h)
	
    	    surface.SetDrawColor(scrollColor)
    	    surface.DrawRect(1,1,w-2,h-2)

    	    draw.SimpleText( "[ ВАРН "..k.." ]", "Comfortaa X30", weight_source(10), hight_source(5), textColor3, TEXT_ALIGN_LEFT )

    	    draw.SimpleText( "Выдал: "..i.admin.name..", Дата: "..TimeString, "Comfortaa X30", weight_source(850), hight_source(5), textColor, TEXT_ALIGN_RIGHT )

    	    surface.SetDrawColor(frameColor2)
    	    surface.DrawRect(weight_source(10), hight_source(40), weight_source(960), textY)

    	    x, y = surface.DrawMulticolorText(weight_source(20), hight_source(45), "Comfortaa X20", {
				i.description
			}, weight_source(950))

		end

		local RemoveWarn = vgui.Create("DButton", PlayerWarnPanel)
		RemoveWarn:SetSize( weight_source(102), hight_source(25) )
		RemoveWarn:SetPos( weight_source(980 - 113), hight_source(8) )
		RemoveWarn:SetText("")
		RemoveWarn.Paint = function(self, w, h)
    	    surface.SetDrawColor(frameColorUnder)
    	    surface.DrawRect(0,0,w,h)
	
    	    surface.SetDrawColor(scrollColor)
    	    surface.DrawRect(1,1,w-2,h-2)

    	    draw.SimpleText( "Снять", "Comfortaa X20", w / 2, hight_source(1), textColor4, TEXT_ALIGN_CENTER )
  
		end
		RemoveWarn.DoClick = function(self)
			if LocalPlayer():SteamID() != i.admin.steamid and not true_wl[LocalPlayer():SteamID()] then return end
			netstream.Start("dbt/warn/remove", parent.steamid, k)
			WarnFrame:Close()
		end

		StartY = StartY + PlayerWarnPanel:GetTall()
		TrueTall = TrueTall + PlayerWarnPanel:GetTall()
		parent.Descriptions[#parent.Descriptions + 1] = PlayerWarnPanel
	end
	parent.YDescriptions = TrueTall
	for Index = parent.Index + 1, #WarnsPanels do 
		local x, y = WarnsPanels[Index]:GetPos()
		WarnsPanels[Index]:SetPos(weight_source(5), y + TrueTall )
		for k, i in pairs(WarnsPanels[Index].Descriptions) do 
			local x, y = i:GetPos()
			i:SetPos(weight_source(5), y + TrueTall)
		end
	end
end

local function RemoveDescription(parent)
	for k, i in pairs(parent.Descriptions) do 
		i:Remove()
	end
	parent.Descriptions = {}
	for Index = parent.Index + 1, #WarnsPanels do 
		local x, y = WarnsPanels[Index]:GetPos()
		local WarnPanel = WarnsPanels[Index]
		WarnPanel:SetPos(weight_source(5), y - parent.YDescriptions)
		for k, i in pairs(WarnPanel.Descriptions) do 
			local x, y = i:GetPos()
			i:SetPos(weight_source(5), y - parent.YDescriptions)
		end
	end
	parent.YDescriptions = 0
end

local function WarnMenu()
	WarnFrame = vgui.Create( "DFrame" )
    WarnFrame:SetSize( weight_source(1035), hight_source(705) )
    WarnFrame:Center()
    WarnFrame:SetTitle("")
    WarnFrame:MakePopup()
    WarnFrame:ShowCloseButton(false)
    WarnFrame.Paint = function(me, w, h)
        surface.SetDrawColor(frameColorUnder)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(frameColor)
        surface.DrawRect(1,1,w-2,h-2)

        draw.SimpleText( "Список варнов", "Comfortaa X50", w / 2, hight_source(1), textColor, TEXT_ALIGN_CENTER )

    end 
    local frame = WarnFrame
    warn_scroll = vgui.Create( "DScrollPanel", frame )
	warn_scroll:SetPos( weight_source(16), hight_source(60) )
	warn_scroll:SetSize( weight_source(1004), hight_source(591) )
	warn_scroll.Paint = function(self, w, h)
        surface.SetDrawColor(scrollColor)
        surface.DrawRect(0,0,w,h)
	end
	
	local sbar = warn_scroll:GetVBar()
	function sbar:Paint(w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
	end
	function sbar.btnUp:Paint(w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
	end
	function sbar.btnDown:Paint(w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
	end
	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w - 4, h, textColor)
	end

	local close = vgui.Create( "DButton", frame )
	close:SetSize( weight_source(35), hight_source(35) )
	close:SetPos( weight_source(980), hight_source(15) )
	close:SetText("")
	close.Paint = function(self, w, h)
        surface.SetDrawColor(255,255,255)
        closeMaterial:Draw(0,0,w,h)
	end
	close.DoClick = function(self)
		self:GetParent():Close()
	end 


	local createwarn = vgui.Create( "DButton", frame )
	createwarn:SetSize( weight_source(258), hight_source(40) )
	createwarn:SetPos( weight_source(16), hight_source(658) )
	createwarn:SetText("")
	createwarn.Paint = function(self, w, h)
        surface.SetDrawColor(frameColorUnder)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(scrollColor)
        surface.DrawRect(1,1,w-2,h-2)

        draw.SimpleText( "Выдать варн по steam_id", "Comfortaa X28", w / 2, hight_source(5), textColor, TEXT_ALIGN_CENTER )
	end
	createwarn.DoClick = function(self)
		AddWarnMenus()
	end
	WarnsPanels = {}
	Y = hight_source(5)
	for k, i in pairs(WARN_LIST) do 
		local PlayerWarnPanel = vgui.Create( "EditablePanel", warn_scroll )
		PlayerWarnPanel:SetSize( weight_source(980), hight_source(50) )
		PlayerWarnPanel:SetPos( weight_source(5), Y )
		PlayerWarnPanel:SetText("")
		PlayerWarnPanel.name = "Злостный нарушитель"
		PlayerWarnPanel.steamid = k
		PlayerWarnPanel.Paint = function(self, w, h)
    	    surface.SetDrawColor(frameColorUnder)
    	    surface.DrawRect(0,0,w,h)
	
    	    surface.SetDrawColor(scrollColor)
    	    surface.DrawRect(1,1,w-2,h-2)
    	    if self.avatar then 
        		surface.SetDrawColor(255,255,255)
        		self.avatar:Draw(1,1,hight_source(50), hight_source(48) )
        	end

        	x, y = surface.DrawMulticolorText(hight_source(65), hight_source(7) , "Comfortaa X32", {
				self.name,
				" | ",
				k, 
				" | ",
				textColor2, "Варны("..#i.warns.."/3)"
			}, maxW)

		end
		PlayerWarnPanel.Descriptions = {}
		PlayerWarnPanel.Index = #WarnsPanels+1
		WarnsPanels[#WarnsPanels+1] = PlayerWarnPanel
		steam.Info(util.SteamIDTo64(k), function(cl)
			PrintTable(cl.response.players[1])
			if IsValid(PlayerWarnPanel) then
				PlayerWarnPanel.avatar = http.Material(cl.response.players[1].avatarmedium)
				PlayerWarnPanel.name = cl.response.players[1].personaname
			end
		end)

		local OpenSteam = vgui.Create( "DButton", PlayerWarnPanel )
		OpenSteam:SetSize( weight_source(50), hight_source(48) )
		OpenSteam:SetPos( weight_source(1), hight_source(1) )
		OpenSteam:SetText("")
		OpenSteam.Paint = function(self, w, h)
    	
		end
		OpenSteam.DoClick = function(self)
			gui.OpenURL("https://steamcommunity.com/profiles/"..util.SteamIDTo64(k))	
		end

		local ShowWarns = vgui.Create("DButton", PlayerWarnPanel)
		ShowWarns:SetSize( weight_source(163), hight_source(40) )
		ShowWarns:SetPos( weight_source(970 - 163), hight_source(5) )
		ShowWarns:SetText("")
		ShowWarns.IsOpen = false
		ShowWarns.Paint = function(self, w, h)
    	    surface.SetDrawColor(frameColorUnder)
    	    surface.DrawRect(0,0,w,h)
	
    	    surface.SetDrawColor(scrollColor)
    	    surface.DrawRect(1,1,w-2,h-2)

    	    draw.SimpleText( "Подбронее", "Comfortaa X28", weight_source(5), hight_source(5), textColor, TEXT_ALIGN_LEFT )
    	    surface.SetDrawColor(255,255,255)
    	    if self.IsOpen then 
    	    	TriangleUp:Draw(w - weight_source(35), weight_source(15), weight_source(21), hight_source(13) )
    	    else
    	    	TriangleDown:Draw(w - weight_source(35), weight_source(15), weight_source(21), hight_source(13) )
    	    end
		end
		ShowWarns.DoClick = function(self)
			self.IsOpen = !self.IsOpen
			if self.IsOpen then 
				BuildDescription(PlayerWarnPanel, i.warns)
			else 
				RemoveDescription(PlayerWarnPanel)
			end
		end
		Y = Y + hight_source(55)
	end
end

--frameColor2
function AddWarnMenus()
	WarnFrameAdd = vgui.Create( "DFrame" )
    WarnFrameAdd:SetSize( weight_source(492), hight_source(450) )
    WarnFrameAdd:Center()
    WarnFrameAdd:SetTitle("")
    WarnFrameAdd:MakePopup()
    WarnFrameAdd:ShowCloseButton(false)
    WarnFrameAdd.Paint = function(me, w, h)
        surface.SetDrawColor(frameColorUnder)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(frameColor)
        surface.DrawRect(1,1,w-2,h-2)

        draw.SimpleText( "Варн по steam_id", "Comfortaa X50", w / 2, hight_source(0), textColor, TEXT_ALIGN_CENTER )


        draw.SimpleText( "Steam_id:", "Comfortaa X30", weight_source(20), hight_source(50), textColor, TEXT_ALIGN_LEFT )

        draw.SimpleText( "Подробная причина:", "Comfortaa X30", weight_source(20), hight_source(130), textColor, TEXT_ALIGN_LEFT )

        surface.SetDrawColor(frameColor2)
    	surface.DrawRect(weight_source(21), hight_source(88), weight_source(171), hight_source(28))
    	surface.DrawRect(weight_source(21), hight_source(163), weight_source(448), hight_source(230))
    end 

    EnterSteamId = vgui.Create( "DTextEntry", WarnFrameAdd ) 
	EnterSteamId:SetSize( weight_source(171), hight_source(28) )
	EnterSteamId:SetPos( weight_source(21), hight_source(88) )
	EnterSteamId:SetPaintBackground( false )
	EnterSteamId:SetFont("Comfortaa X30")
	EnterSteamId:SetTextColor( textColor )
	EnterSteamId.OnEnter = function( self )
		
	end

    EnterDesc= vgui.Create( "DTextEntry", WarnFrameAdd ) 
	EnterDesc:SetSize( weight_source(448), hight_source(230) )
	EnterDesc:SetPos( weight_source(21), hight_source(163) )
	EnterDesc:SetPaintBackground( false )
	EnterDesc:SetFont("Comfortaa X30")
	EnterDesc:SetTextColor( textColor )
	EnterDesc:SetMultiline(true)
	EnterDesc.OnEnter = function( self )
		
	end



	local SendWarn = vgui.Create("DButton", WarnFrameAdd)
	SendWarn:SetSize( weight_source(163), hight_source(40) )
	SendWarn:SetPos( weight_source((492 / 2) - (163 / 2)), hight_source(450 - 50) )
	SendWarn:SetText("")
	SendWarn.Paint = function(self, w, h)
        surface.SetDrawColor(frameColorUnder)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(scrollColor)
        surface.DrawRect(1,1,w-2,h-2)
        draw.SimpleText( "Выдать варн", "Comfortaa X28", w / 2, hight_source(5), textColor, TEXT_ALIGN_CENTER )
        surface.SetDrawColor(255,255,255)
	end
	SendWarn.DoClick = function(self)
		WarnFrameAdd:Close()
		if IsValid(WarnFrame) then 
			WarnFrame:Close()
		end
		netstream.Start("dbt/warn/add", EnterSteamId:GetValue(), EnterDesc:GetValue())
	end

	local close = vgui.Create( "DButton", WarnFrameAdd )
	close:SetSize( weight_source(29), hight_source(29) )
	close:SetPos( weight_source(492 - (29+11)), hight_source(11) )
	close:SetText("")
	close.Paint = function(self, w, h)
        surface.SetDrawColor(255,255,255)
        closeMaterial1:Draw(0,0,w,h)
	end
	close.DoClick = function(self)
		self:GetParent():Close()
	end 

end

netstream.Hook("dbt/warns/list", function(warn)
	WARN_LIST = warn
	WarnMenu()
end)

netstream.Hook("dbt/warn", function(admin, text)
	chat.AddText( Color( 255, 0, 0 ), "[WARN]", Color( 255, 255, 255 ), " Администратор ", Color( 116, 40, 151 ), admin:Name(), Color( 255, 255, 255 ), " выдал варн по причине: ", Color( 116, 40, 151 ), text )
end)