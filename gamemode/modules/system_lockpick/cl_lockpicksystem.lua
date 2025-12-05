AddCSLuaFile()
local lockpickmat = Material("dbt/lockpick_system/lockpick_main.png", 'smooth')
local thundermat = Material("dbt/lockpick_system/lockpick_thunder.png", 'smooth')
local helpmat = Material("dbt/lockpick_system/lockpick_help.png")
local linemat = Material("dbt/lockpick_system/lockpick_line.png")
local alphacol = 0
local lockpick_ismissed = false
local arrr = Material('materials/dbt/arrr.png', 'smooth')
local MatCLose = Material("dbt/d542c202ca4c957c.png")
local function DrawLockpickMiss()
	local alphacol = 0
	lockpick_ismissed = true
	hook.Add("HUDPaint", 'lockpick_miss',function ()
		alphacol = Lerp(RealFrameTime(), alphacol, 55)
		surface.SetDrawColor(212, 0, 0, alphacol)
		surface.DrawRect(0, 0, dbtPaint.WidthSource(1920), dbtPaint.HightSource(1080))
	end)

	timer.Simple(0.5,function ()
		hook.Remove("HUDPaint", 'lockpick_miss')
		hook.Add("HUDPaint", 'lockpick_miss',function ()
			alphacol = Lerp(RealFrameTime()*3, alphacol, 0)
			surface.SetDrawColor(212, 0, 0, alphacol)
			surface.DrawRect(0, 0, dbtPaint.WidthSource(1920), dbtPaint.HightSource(1080))
		end)
	end)

	timer.Simple(0.7,function ()
		lockpick_ismissed = false
	end)

	timer.Simple(1.3,function ()
		hook.Remove("HUDPaint", 'lockpick_miss')
	end)
end

hook.Add("PlayerButtonDown", 'dbt/lockpick/use',function (ply, btn)
	
	if btn == KEY_H and IsFirstTimePredicted() then
		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:GetAimVector()*50,
			filter = ply,
		})
		if IsValid(tr.Entity) then
			if !tr.Entity:GetNWBool("dbt.NoLockpick", false) then
				chat.AddText(Color(200, 75, 75), "Эту дверь нельзя взломать.")
				return
			end
			if( tr.Entity:GetClass() == "func_door_rotating") and l_HasItem(36) then
				local slot = l_HasItem(36)
				local pers = dbt.GetCharacter(ply:Pers())
				if !pers.lock then return end

				dbt.LockPickMenu(pers.lock, tr.Entity)
			end
		end
	end
end)

local function DrawLockpickRect(startx)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawLine(dbtPaint.WidthSource(startx), dbtPaint.HightSource(400), dbtPaint.WidthSource(startx), dbtPaint.HightSource(648))
	surface.DrawLine(dbtPaint.WidthSource(startx), dbtPaint.HightSource(400), dbtPaint.WidthSource(startx + 44), dbtPaint.HightSource(400))
	surface.DrawLine(dbtPaint.WidthSource(startx + 44), dbtPaint.HightSource(400), dbtPaint.WidthSource(startx + 44), dbtPaint.HightSource(648))
end

function dbt.LockPickMenu(difficulty, door)
	if lockpick_panel then lockpick_panel:Remove() lockpick_panel = nil end
	local positionoflockpick = 810
	local heightoflockpick = 660
	local isplus = true
	local clicked = false
	local clicked2 = false
	local attempts = 3
	local issuccess = false
	local cooldown = CurTime()
	local isanim = false
	local tableschtifts = {}
	local colortitle = Color(163, 216, 164, 255)
	local ispkm = false
	local speed = 50
	netstream.Start("Player.doing", true)
	local firstschtift = {need = 1, isthunder = false, isunknown = false, heightpos = 524}
	local secondschtift = {need = 1, isthunder = false, isunknown = false, heightpos = 524}
	local thirdschtift = {need = 1, isthunder = false, isunknown = false, heightpos = 524}
	local fourthschtift = {need = 1, isthunder = false, isunknown = false, heightpos = 524}
	local fifthschtift = {need = 1, isthunder = false, isunknown = false, heightpos = 524}

	tableschtifts[#tableschtifts + 1] = firstschtift
	tableschtifts[#tableschtifts + 1] = secondschtift
	tableschtifts[#tableschtifts + 1] = thirdschtift
	tableschtifts[#tableschtifts + 1] = fourthschtift
	tableschtifts[#tableschtifts + 1] = fifthschtift

	if difficulty == 'Лёгкий замок' then
		local firstnum = math.random(1, 5)
		local secondnum = math.random(1, 5)
		while secondnum == firstnum do secondnum = math.random(1, 5) end

		tableschtifts[firstnum].need = math.random(2, 6)
		tableschtifts[secondnum].need = math.random(2, 6)
		colortitle = Color(163, 216, 164, 255)
		speed = 300
	elseif difficulty == 'Средний замок' then
		local firstnum = math.random(1, 5)
		local secondnum = math.random(1, 5)
		local thirdnum = math.random(1, 5)
		while secondnum == firstnum do secondnum = math.random(1, 5) end
		while (thirdnum == secondnum) or (thirdnum == firstnum) do thirdnum = math.random(1, 5) end

		tableschtifts[firstnum].need = math.random(2, 6)
		tableschtifts[secondnum].need = math.random(2, 6)
		tableschtifts[thirdnum].need = math.random(2, 6)

		firstnum = math.random(1, 5)
		secondnum = math.random(1, 5)
		while secondnum == firstnum do secondnum = math.random(1, 5) end
		tableschtifts[firstnum].isthunder = true
		tableschtifts[secondnum].isthunder = true

		colortitle = Color(255, 218, 145, 255)
		speed = 400
	elseif difficulty == 'Тяжёлый замок' then
		for k, v in pairs(tableschtifts) do
			v.need = math.random(2, 6)
		end
		local firstnum = math.random(1, 5)
		tableschtifts[firstnum].isunknown = true
		local secondnum = math.random(1, 5)
		local thirdnum = math.random(1, 5)
		while thirdnum == secondnum do thirdnum = math.random(1, 5) end
		tableschtifts[firstnum].isthunder = true
		tableschtifts[thirdnum].isthunder = true
		tableschtifts[secondnum].isthunder = true

		colortitle = Color(255, 145, 147, 255)
		speed = 500
	end

	firstschtift.begin = firstschtift.need
	secondschtift.begin = secondschtift.need
	thirdschtift.begin = thirdschtift.need
	fourthschtift.begin = fourthschtift.need
	fifthschtift.begin = fifthschtift.need

	lockpick_panel = vgui.Create('DPanel')
	lockpick_panel:MakePopup()

	lockpick_panel:SetSize(scrw, scrh)

	surface.SetFont('Comfortaa X27')
	local textw, texth = surface.GetTextSize('Осталось попыток: 3')

	surface.SetFont('Comfortaa X40')
	local textw2, texth2 = surface.GetTextSize(difficulty)

	surface.SetFont('Comfortaa X35')
	local textw3, texth3 = surface.GetTextSize('ЛКМ - легко поддеть штифт')
	local textw4, texth4 = surface.GetTextSize('ПКМ - с силой поддеть штифт')
	local textw5, texth5 = surface.GetTextSize('Пробел - выйти')
	surface.SetFont('Comfortaa X50')
	local textw6, texth6 = surface.GetTextSize('ПРОМАХ')

	lockpick_panel.Paint = function(self, w , h)
		BlurScreen(10)

		surface.SetDrawColor(0, 0, 0, 255*0.83)
		surface.DrawRect(dbtPaint.WidthSource(780), dbtPaint.HightSource(380), dbtPaint.WidthSource(360), dbtPaint.HightSource(320))
		surface.DrawRect(dbtPaint.WidthSource(780), dbtPaint.HightSource(335), dbtPaint.WidthSource(360), dbtPaint.HightSource(40))
		surface.DrawRect(dbtPaint.WidthSource(780), dbtPaint.HightSource(300), dbtPaint.WidthSource(360), dbtPaint.HightSource(30))

		surface.DrawMulticolorText(dbtPaint.WidthSource(960) - dbtPaint.WidthSource(textw*0.5), dbtPaint.HightSource(300), 'Comfortaa X27', {Color(164, 164, 164, 255), 'Осталось попыток: ', Color(138, 43, 226, 255), tostring(attempts)}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(960) - dbtPaint.WidthSource(textw2*0.5), dbtPaint.HightSource(335), 'Comfortaa X40', {colortitle, difficulty}, dbtPaint.WidthSource(500))

		surface.SetDrawColor(137, 43, 225, 255*0.63)
		surface.DrawRect(dbtPaint.WidthSource(814), dbtPaint.HightSource(firstschtift.heightpos), dbtPaint.WidthSource(38), dbtPaint.HightSource(124))
		surface.DrawRect(dbtPaint.WidthSource(878), dbtPaint.HightSource(secondschtift.heightpos), dbtPaint.WidthSource(38), dbtPaint.HightSource(124))
		surface.DrawRect(dbtPaint.WidthSource(942), dbtPaint.HightSource(thirdschtift.heightpos), dbtPaint.WidthSource(38), dbtPaint.HightSource(124))
		surface.DrawRect(dbtPaint.WidthSource(1006), dbtPaint.HightSource(fourthschtift.heightpos), dbtPaint.WidthSource(38), dbtPaint.HightSource(124))
		surface.DrawRect(dbtPaint.WidthSource(1070), dbtPaint.HightSource(fifthschtift.heightpos), dbtPaint.WidthSource(38), dbtPaint.HightSource(124))

		surface.SetDrawColor(255, 255, 255, 255)
		if firstschtift.isthunder then
			surface.SetMaterial(thundermat)
			surface.DrawTexturedRect(dbtPaint.WidthSource(804), dbtPaint.HightSource(firstschtift.heightpos + 30), dbtPaint.WidthSource(60), dbtPaint.HightSource(60))
		end
		if secondschtift.isthunder then
			surface.SetMaterial(thundermat)
			surface.DrawTexturedRect(dbtPaint.WidthSource(868), dbtPaint.HightSource(secondschtift.heightpos + 30), dbtPaint.WidthSource(60), dbtPaint.HightSource(60))
		end
		if thirdschtift.isthunder then
			surface.SetMaterial(thundermat)
			surface.DrawTexturedRect(dbtPaint.WidthSource(932), dbtPaint.HightSource(thirdschtift.heightpos + 30), dbtPaint.WidthSource(60), dbtPaint.HightSource(60))
		end
		if fourthschtift.isthunder then
			surface.SetMaterial(thundermat)
			surface.DrawTexturedRect(dbtPaint.WidthSource(996), dbtPaint.HightSource(fourthschtift.heightpos + 30), dbtPaint.WidthSource(60), dbtPaint.HightSource(60))
		end
		if fifthschtift.isthunder then
			surface.SetMaterial(thundermat)
			surface.DrawTexturedRect(dbtPaint.WidthSource(1060), dbtPaint.HightSource(fifthschtift.heightpos + 30), dbtPaint.WidthSource(60), dbtPaint.HightSource(60))
		end

		surface.DrawMulticolorText(dbtPaint.WidthSource(824), dbtPaint.HightSource(firstschtift.heightpos + 86), 'Comfortaa X40', {color_white, !firstschtift.isunknown and (firstschtift.need > 1 and tostring(firstschtift.need) or '') or '?'}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(888), dbtPaint.HightSource(secondschtift.heightpos + 86), 'Comfortaa X40', {color_white, !secondschtift.isunknown and (secondschtift.need > 1 and tostring(secondschtift.need) or '') or '?'}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(952), dbtPaint.HightSource(thirdschtift.heightpos + 86), 'Comfortaa X40', {color_white, !thirdschtift.isunknown and (thirdschtift.need > 1 and tostring(thirdschtift.need) or '') or '?'}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(1016), dbtPaint.HightSource(fourthschtift.heightpos + 86), 'Comfortaa X40', {color_white, !fourthschtift.isunknown and (fourthschtift.need > 1 and tostring(fourthschtift.need) or '') or '?'}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(1080), dbtPaint.HightSource(fifthschtift.heightpos + 86), 'Comfortaa X40', {color_white, !fifthschtift.isunknown and (fifthschtift.need > 1 and tostring(fifthschtift.need) or '') or '?'}, dbtPaint.WidthSource(500))

		DrawLockpickRect(810)
		DrawLockpickRect(874)
		DrawLockpickRect(938)
		DrawLockpickRect(1002)
		DrawLockpickRect(1066)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(lockpickmat)
		surface.DrawTexturedRect(dbtPaint.WidthSource(positionoflockpick), dbtPaint.HightSource(heightoflockpick), dbtPaint.WidthSource(520), dbtPaint.HightSource(35))

		surface.DrawMulticolorText(dbtPaint.WidthSource(960) - dbtPaint.WidthSource(textw3*0.5), dbtPaint.HightSource(950), 'Comfortaa X35', {Color(138, 43, 226, 255), 'ЛКМ', color_white, ' - легко поддеть штифт'}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(960) - dbtPaint.WidthSource(textw4*0.5), dbtPaint.HightSource(980), 'Comfortaa X35', {Color(138, 43, 226, 255), 'ПКМ', color_white, ' - с силой поддеть штифт'}, dbtPaint.WidthSource(500))
		surface.DrawMulticolorText(dbtPaint.WidthSource(960) - dbtPaint.WidthSource(textw5*0.5), dbtPaint.HightSource(1034), 'Comfortaa X35', {Color(138, 43, 226, 255), 'Пробел', color_white, ' - выйти'}, dbtPaint.WidthSource(500))
		if lockpick_ismissed then
			surface.DrawMulticolorText(dbtPaint.WidthSource(960) - dbtPaint.WidthSource(textw6*0.5), dbtPaint.HightSource(700), 'Comfortaa X50', {Color(255, 0, 0, 255), 'ПРОМАХ'}, dbtPaint.WidthSource(500))
		end
	end
	lockpick_panel.OnRemove = function()
		netstream.Start("Player.doing", false)
	end
	local isneedtomiss = false
	lockpick_panel.Think = function(self)
		if attempts == 0 then self:Remove() lockpick_panel = nil netstream.Start('dbt/deletelockpick', l_HasItem(36)) end
		local allneeds = firstschtift.need + secondschtift.need + thirdschtift.need + fourthschtift.need + fifthschtift.need
		if allneeds == 0 then self:Remove() lockpick_panel = nil netstream.Start("dbt/lockpick/success_lockpick", door) end

		if clicked then
			local isfirst = false
			local issecond = false
			local isthird = false
			local isfourth = false
			local isfifth = false

			if positionoflockpick + 10 > dbtPaint.WidthSource(811) and positionoflockpick < dbtPaint.WidthSource(851) then
				if firstschtift.need ~= 0 then
					if firstschtift.isthunder then
						if ispkm then
							isfirst = true
							issuccess = true
						end
					else
						if !ispkm then
							isfirst = true
							issuccess = true
						end
					end
				end
			end

			if positionoflockpick + 10 > dbtPaint.WidthSource(878) and positionoflockpick < dbtPaint.WidthSource(915) then
				if secondschtift.need ~= 0 then
					if secondschtift.isthunder then
						if ispkm then
							issecond = true
							issuccess = true
						end
					else
						if !ispkm then
							issecond = true
							issuccess = true
						end
					end
				end
			end

			if positionoflockpick + 10 > dbtPaint.WidthSource(942) and positionoflockpick < dbtPaint.WidthSource(979) then
				if thirdschtift.need ~= 0 then
					if thirdschtift.isthunder then
						if ispkm then
							isthird = true
							issuccess = true
						end
					else
						if !ispkm then
							isthird = true
							issuccess = true
						end
					end
				end
			end

			if positionoflockpick + 10 > dbtPaint.WidthSource(1006) and positionoflockpick < dbtPaint.WidthSource(1043) then
				if fourthschtift.need ~= 0 then
					if fourthschtift.isthunder then
						if ispkm then
							isfourth = true
							issuccess = true
						end
					else
						if !ispkm then
							isfourth = true
							issuccess = true
						end
					end
				end
			end

			if positionoflockpick + 10 > dbtPaint.WidthSource(1070) and positionoflockpick < dbtPaint.WidthSource(1107) then
				if fifthschtift.need ~= 0 then
					if fifthschtift.isthunder then
						if ispkm then
							isfifth = true
							issuccess = true
						end
					else
						if !ispkm then
							isfifth = true
							issuccess = true
						end
					end
				end
			end

			if heightoflockpick == 630 or clicked2 then
				heightoflockpick = math.Clamp(heightoflockpick + 0.5, 630, 661)
				clicked2 = true
			elseif !clicked2 then
				heightoflockpick = math.Clamp(heightoflockpick - 0.5, 630, 660)
			end

			if isfirst then
				if heightoflockpick <= 650 then
					firstschtift.heightpos = Lerp(RealFrameTime()*5, firstschtift.heightpos, 430)
					isanim = true
				else
					isanim = false
				end
			elseif issecond then
				if heightoflockpick <= 650 then
					secondschtift.heightpos = Lerp(RealFrameTime()*5, secondschtift.heightpos, 430)
					isanim = true
				else
					isanim = false
				end
			elseif isthird then
				if heightoflockpick <= 650 then
					thirdschtift.heightpos = Lerp(RealFrameTime()*5, thirdschtift.heightpos, 430)
					isanim = true
				else
					isanim = false
				end
			elseif isfourth then
				if heightoflockpick <= 650 then
					fourthschtift.heightpos = Lerp(RealFrameTime()*5, fourthschtift.heightpos, 430)
					isanim = true
				else
					isanim = false
				end
			elseif isfifth then
				if heightoflockpick <= 650 then
					fifthschtift.heightpos = Lerp(RealFrameTime()*5, fifthschtift.heightpos, 430)
					isanim = true
				else
					isanim = false
				end
			end

			if heightoflockpick == 661 then
				attempts = issuccess and attempts or attempts - 1
				clicked = false
				clicked2 = false
				issuccess = false
				ispkm = false
				isneedtomiss = false

				if isfirst then firstschtift.need = math.Clamp(firstschtift.need - 1, 0, 999) end
				if issecond then secondschtift.need = math.Clamp(secondschtift.need - 1, 0, 999) end
				if isthird then thirdschtift.need = math.Clamp(thirdschtift.need - 1, 0, 999) end
				if isfourth then fourthschtift.need = math.Clamp(fourthschtift.need - 1, 0, 999) end
				if isfifth then fifthschtift.need = math.Clamp(fifthschtift.need - 1, 0, 999) end
			end

			if heightoflockpick <= 650 and !isneedtomiss then
				if !issuccess then DrawLockpickMiss() end

				isneedtomiss = true
			end

			return
		end

		if firstschtift.heightpos ~= 524 and !isanim and !(firstschtift.need == 0) then
			firstschtift.heightpos = Lerp(RealFrameTime()*7, firstschtift.heightpos, 524)
		end
		if secondschtift.heightpos ~= 524 and !isanim and !(secondschtift.need == 0) then
			secondschtift.heightpos = Lerp(RealFrameTime()*7, secondschtift.heightpos, 524)
		end
		if thirdschtift.heightpos ~= 524 and !isanim and !(thirdschtift.need == 0) then
			thirdschtift.heightpos = Lerp(RealFrameTime()*7, thirdschtift.heightpos, 524)
		end
		if fourthschtift.heightpos ~= 524 and !isanim and !(fourthschtift.need == 0) then
			fourthschtift.heightpos = Lerp(RealFrameTime()*7, fourthschtift.heightpos, 524)
		end
		if fifthschtift.heightpos ~= 524 and !isanim and !(fifthschtift.need == 0) then
			fifthschtift.heightpos = Lerp(RealFrameTime()*7, fifthschtift.heightpos, 524)
		end

		if cooldown < CurTime() then
			if input.IsMouseDown(MOUSE_LEFT) then cooldown = CurTime() + 1 clicked = true end
			if input.IsMouseDown(MOUSE_RIGHT) then cooldown = CurTime() + 1 clicked = true ispkm = true end

			if input.IsKeyDown(KEY_SPACE) then self:Remove() lockpick_panel = nil if attempts != 3 then netstream.Start('dbt/deletelockpick', l_HasItem(36)) end end
		end

		if positionoflockpick >= 1220 then isplus = false end
		if positionoflockpick <= 700 then isplus = true end

		local deltaTime = FrameTime()

		positionoflockpick = isplus and math.Clamp(positionoflockpick + (speed * deltaTime), 700, 1220) or math.Clamp(positionoflockpick - (speed * deltaTime), 700, 1220)
	end

	local lockpick_button = vgui.Create('DButton', lockpick_panel)
	lockpick_button:SetSize(dbtPaint.WidthSource(180), dbtPaint.HightSource(40))
	lockpick_button:SetPos(dbtPaint.WidthSource(5), dbtPaint.HightSource(5))
	lockpick_button:SetText('')

	lockpick_button.Paint = function(self, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(helpmat)
		surface.DrawTexturedRect(dbtPaint.WidthSource(-10), dbtPaint.HightSource(-10), dbtPaint.WidthSource(69), dbtPaint.HightSource(69))

		surface.DrawMulticolorText(dbtPaint.WidthSource(42), dbtPaint.HightSource(7.5), 'Comfortaa X30', {color_white, 'Инструкция'}, scrw)
	end

	lockpick_button.OnCursorEntered = function()
		cooldown = CurTime() + 999
	end

	lockpick_button.OnCursorExited = function()
		cooldown = CurTime()
	end

	lockpick_button.DoClick = function(self)
		lockpick_button:SetSize(0, 0)

		local lockpick_helppanel = vgui.Create('DPanel', lockpick_panel)
		lockpick_helppanel:SetSize(dbtPaint.WidthSource(365), dbtPaint.HightSource(500))
		lockpick_helppanel:SetPos(dbtPaint.WidthSource(13), dbtPaint.HightSource(13))

		surface.SetFont('Comfortaa X35')
		local strw1, strh1 = surface.GetTextSize('Взлом замков')
		surface.SetFont('Comfortaa X35')
		local strw2, strh2 = surface.GetTextSize('Удачного взлома!')

		lockpick_helppanel.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 255*0.72)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(linemat)
			surface.DrawTexturedRect(dbtPaint.WidthSource(-5), dbtPaint.HightSource(15), w*1.05, h*0.1)

			surface.DrawMulticolorText(dbtPaint.WidthSource(w*0.5) - dbtPaint.WidthSource(strw1*0.5), 0, 'Comfortaa X35', {color_white, 'Взлом замков'})
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(50), 'Comfortaa X27', {color_white, 'Для взлома замков нужно поддевать штифты', Color(138, 43, 226, 255), ' в нужный момент', color_white, ', пока отмычка двигается.'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(140), 'Comfortaa X27', {color_white, 'Обозначения:'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(170), 'Comfortaa X27', {Color(138, 43, 226, 255), 'Число'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(195), 'Comfortaa X27', {color_white, 'Означает то кол-во раз, сколько нужно его поддеть.'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(255), 'Comfortaa X27', {Color(138, 43, 226, 255), 'Молния'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(280), 'Comfortaa X27', {color_white, 'Означает то, что штифт нужно поддевать с силой на ПКМ.'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(340), 'Comfortaa X27', {Color(138, 43, 226, 255), 'Вопрос'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(10), dbtPaint.HightSource(365), 'Comfortaa X27', {color_white, 'Означает то, что неизвестно то кол-во раз, сколько нужно его поддеть.'}, dbtPaint.WidthSource(350))
			surface.DrawMulticolorText(dbtPaint.WidthSource(w*0.5) - dbtPaint.WidthSource(strw2*0.5), dbtPaint.HightSource(450), 'Comfortaa X35', {color_white, 'Удачного взлома!'})
		end

		local DButton = vgui.Create('DButton', lockpick_helppanel)
		DButton:SetFont('Comfortaa X30')
		DButton:SetTextColor(Color(255, 255, 255, 255))
		DButton:SetText('X')
		DButton:SetSize(dbtPaint.WidthSource(30), dbtPaint.HightSource(30))
		DButton:SetPos(dbtPaint.WidthSource(325), dbtPaint.HightSource(4))

		DButton.Paint = function(self, w, h) end
		DButton.DoClick = function(self)
			lockpick_helppanel:Remove()
			lockpick_button:SetSize(dbtPaint.WidthSource(180), dbtPaint.HightSource(40))
		end
		DButton.OnCursorEntered = function()
			cooldown = CurTime() + 999
		end
		DButton.OnCursorExited = function()
			cooldown = CurTime()
		end
		DButton.OnRemove = function()
			cooldown = CurTime() + 1
		end
	end
end
local rightbutton_material = Material('materials/dbt/notes/rightbutton.png', 'smooth')
local leftbutton_material = Material('materials/dbt/notes/leftbutton.png', 'smooth')

cdOpenMono = 0
function dbt_newnote(title, page, ent, isredact)
	local mainpanel = vgui.Create('DFrame')
	local currentpage = 1
	local startpage = {}
	local a = LocalPlayer() == ent:GetNWEntity('Owner') or IsMono(LocalPlayer():Pers())
	mainpanel:SetSize(dbtPaint.WidthSource(430), a and dbtPaint.HightSource(620) or dbtPaint.HightSource(595))
	mainpanel:SetPos(dbtPaint.WidthSource(745), dbtPaint.HightSource(230))
	mainpanel:SetDraggable(true)
	mainpanel:SetTitle('')
	mainpanel:MakePopup()
	mainpanel:ShowCloseButton(false)
	mainpanel:SetKeyboardInputEnabled( true )
	local DTextEntry = vgui.Create('DTextEntry', mainpanel)
	DTextEntry:SetPos(dbtPaint.WidthSource(15), dbtPaint.HightSource(55))
	DTextEntry:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(490))
	DTextEntry:SetValue(page[currentpage])
	DTextEntry:SetEditable(false)
	DTextEntry:SetMultiline(true)
	DTextEntry:SetFont('Comfortaa X27')
	DTextEntry:SetTextColor(Color(255, 255, 255, 255))
	DTextEntry:SetDrawLanguageID(false)
	DTextEntry:SetPaintBackground(false)
	DTextEntry:SetCursorColor(Color(255, 255, 255, 255))

	DTextEntry.OnChange = function(self)
		local x, y = surface.DrawMulticolorText(0, 0, 'Comfortaa X27', {color_white, self:GetValue()}, dbtPaint.WidthSource(400))
		if y > dbtPaint.HightSource(432) then
			local text = string.sub(self:GetValue(), 1, string.len(self:GetValue()) - 1)
			self:SetText(text)
		end
		page[currentpage] = self:GetValue()
	end

	local DTextEntry_title = vgui.Create('DTextEntry', mainpanel)
	DTextEntry_title:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(0))
	DTextEntry_title:SetSize(dbtPaint.WidthSource(400), dbtPaint.HightSource(40))
	DTextEntry_title:SetValue(title)
	DTextEntry_title:SetEditable(false)
	DTextEntry_title.Paint = function(self, w, h)
		surface.SetFont('Comfortaa X30')
		local textw1, texth1 = surface.GetTextSize(title)

		surface.DrawMulticolorText(dbtPaint.WidthSource(215) - textw1*0.5, dbtPaint.HightSource(5), 'Comfortaa X30', {color_white, self:GetValue()}, dbtPaint.WidthSource(9999999999))
	end

	DTextEntry_title.OnChange = function(self)
		title = self:GetValue()
	end

	mainpanel.Paint = function(self, w, h)
		surface.SetFont('Comfortaa X27')
		local textw, texth = surface.GetTextSize(''..currentpage..'/'..#page)
		surface.SetDrawColor(0, 0, 0, 255*0.77)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(linemat)
		surface.DrawTexturedRect(dbtPaint.WidthSource(-5), dbtPaint.HightSource(15), w*1.05, h*0.1)

		surface.DrawMulticolorText(dbtPaint.WidthSource(215) - textw*0.5, dbtPaint.HightSource(550), 'Comfortaa X27', {Color(144, 0, 169, 255), ''..currentpage, color_white, '/'..#page}, dbtPaint.WidthSource(400))
		if input.IsButtonDown(KEY_C) and cdOpenMono < CurTime() and !IsValid(monopad.Frame) and CanOpenMonopad() then 
			cdOpenMono = CurTime() + 2.5
			openMonopad()
		elseif input.IsButtonDown(KEY_C) and cdOpenMono < CurTime() and IsValid(monopad.Frame) then 
			cdOpenMono = CurTime() + 2.5
			monopad.Frame:Close()
			monopadIsOpen = false
		end
	end

	local rightbtn = vgui.Create('DButton', mainpanel)
	rightbtn:SetText('')
	rightbtn:SetSize(dbtPaint.WidthSource(46), dbtPaint.HightSource(46))
	rightbtn:SetPos(dbtPaint.WidthSource(380), dbtPaint.HightSource(540))
	rightbtn.Paint = function(self, w, h)
		surface.SetDrawColor(255, 255, 255, currentpage != #page and 255 or 50)
		surface.SetMaterial(arrr)
		surface.DrawTexturedRectRotated(w / 2, h / 2, dbtPaint.WidthSource(15), dbtPaint.HightSource(25), 0)
	end

	rightbtn.DoClick = function(self)
		currentpage = currentpage == #page and currentpage or currentpage + 1
		DTextEntry:SetValue(page[currentpage])
	end

	local leftbtn = vgui.Create('DButton', mainpanel)
	leftbtn:SetText('')
	leftbtn:SetSize(dbtPaint.WidthSource(46), dbtPaint.HightSource(46))
	leftbtn:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(540))
	leftbtn.Paint = function(self, w, h)
		surface.SetDrawColor(255, 255, 255, currentpage > 1 and 255 or 50)
		surface.SetMaterial(arrr)
		surface.DrawTexturedRectRotated(w / 2, h / 2, dbtPaint.WidthSource(15), dbtPaint.HightSource(25), 180)
	end

	leftbtn.DoClick = function(self)
		currentpage = currentpage > 1 and currentpage - 1 or currentpage
		DTextEntry:SetValue(page[currentpage])
	end


	local function NoteAlreadyExists(name, pages)
		local signs = dbt.inventory and dbt.inventory.info and dbt.inventory.info.monopad and dbt.inventory.info.monopad.meta and dbt.inventory.info.monopad.meta.signs
		if not signs then return false end
		local fullTxt = table.concat(pages, "\n\n")
		for _, v in pairs(signs) do
			if v.name == name and v.text == fullTxt then return true end
		end
		return false
	end
	local canCreateSaveBtn = not NoteAlreadyExists(title, page)
	if canCreateSaveBtn and table.Count(dbt.inventory.info.monopad) > 0 then
		local saveToMonopad = vgui.Create('DButton', mainpanel)
		saveToMonopad:SetFont('Comfortaa X23')
		saveToMonopad:SetText('В монопад')
		saveToMonopad:SetTextColor(color_white)
		saveToMonopad:SetSize(dbtPaint.WidthSource(120), dbtPaint.HightSource(32))
		saveToMonopad:SetPos(dbtPaint.WidthSource(10), dbtPaint.HightSource(5))
		saveToMonopad.Paint = function(self,w,h)
			surface.SetDrawColor(144,0,169,255)
			surface.DrawOutlinedRect(0,0,w,h,1)
		end
		saveToMonopad.DoClick = function()
			local fullText = table.concat(page, "\n\n")
			if NoteAlreadyExists(title, page) then
				return
			end
			netstream.Start('dbt/monopad/notes/add', 0, title, fullText, false)
			surface.PlaySound('monopad_click.mp3')
			dbt.inventory = dbt.inventory or { info = { monopad = { meta = { signs = {} } } } }
			dbt.inventory.info.monopad.meta.signs = dbt.inventory.info.monopad.meta.signs or {}
			local signs = dbt.inventory.info.monopad.meta.signs or {}
			local nid = 1 while signs[nid] ~= nil do nid = nid + 1 end
			signs[nid] = { name = title, text = fullText, editable = false }
			saveToMonopad:Remove()
		end
	end

	if LocalPlayer() == ent:GetNWEntity('Owner') or IsMono(LocalPlayer():Pers()) then

		local redactbtn = vgui.Create('DButton', mainpanel)
		redactbtn:SetFont('Comfortaa X27')
		redactbtn:SetText('Редактировать')
		redactbtn:SetTextColor(color_white)
		redactbtn:SetSize(dbtPaint.WidthSource(430), dbtPaint.HightSource(32))
		redactbtn:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(588))
		redactbtn.Paint = function(self, w, h)
			surface.SetDrawColor(144, 0, 169, 255)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		redactbtn.DoClick = function(self)
			for k, v in pairs(page) do
				startpage[k] = v
			end
			local starttitle = title
			isredact = true
			DTextEntry:SetEditable(true)
			DTextEntry_title:SetEditable(true)
			self:Remove()
			local savebtn = vgui.Create('DButton', mainpanel)
			savebtn:SetFont('Comfortaa X23')
			savebtn:SetText('Сохранить')
			savebtn:SetTextColor(color_white)
			savebtn:SetSize(dbtPaint.WidthSource(215), dbtPaint.HightSource(32))
			savebtn:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(588))
			savebtn.Paint = function(self, w, h)
				surface.SetDrawColor(144, 0, 169, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			savebtn.DoClick = function(self)
				isredact = false
				mainpanel:Remove()
				netstream.Start('dbt/newnotes/savebtn', ent, title, page)
				dbt_newnote(title, page, ent, isredact)
			end

			local cancelbtn = vgui.Create('DButton', mainpanel)
			cancelbtn:SetFont('Comfortaa X23')
			cancelbtn:SetText('Отменить')
			cancelbtn:SetTextColor(color_white)
			cancelbtn:SetSize(dbtPaint.WidthSource(215), dbtPaint.HightSource(32))
			cancelbtn:SetPos(dbtPaint.WidthSource(215), dbtPaint.HightSource(588))
			cancelbtn.Paint = function(self, w, h)
				surface.SetDrawColor(144, 0, 169, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			cancelbtn.DoClick = function(self)
				isredact = false
				mainpanel:Remove()
				dbt_newnote(starttitle, startpage, ent, isredact)
			end

			local addpage = vgui.Create('DButton', mainpanel)
			addpage:SetSize(dbtPaint.WidthSource(30), dbtPaint.HightSource(30))
			addpage:SetPos(dbtPaint.WidthSource(232), dbtPaint.HightSource(547))
			addpage:SetFont('Comfortaa X55')
			addpage:SetText('+')
			addpage:SetTextColor(Color(255, 255, 255, 255))

			addpage.DoClick = function(self)
				currentpage = #page + 1
				page[#page + 1] = 'Новая страница'
				DTextEntry:SetValue(page[currentpage])
			end

			addpage.Paint = function(self, w, h) end

			local removepage = vgui.Create('DButton', mainpanel)
			removepage:SetSize(dbtPaint.WidthSource(30), dbtPaint.HightSource(30))
			removepage:SetPos(dbtPaint.WidthSource(170), dbtPaint.HightSource(543))
			removepage:SetFont('Comfortaa X55')
			removepage:SetText('-')
			removepage:SetTextColor(Color(255, 255, 255, 255))

			removepage.DoClick = function(self)
				if #page == 1 then return end
				if currentpage == #page then
					currentpage = currentpage - 1
					DTextEntry:SetValue(page[currentpage])
				end

				page[#page] = nil
			end

			removepage.Paint = function(self, w, h) end
		end
	end

	local closebtn = vgui.Create('DButton', mainpanel)
	closebtn:SetSize(dbtPaint.WidthSource(30), dbtPaint.HightSource(30))
	closebtn:SetPos(dbtPaint.WidthSource(398), dbtPaint.HightSource(7))
	closebtn:SetText('')
	closebtn:SetFont('Comfortaa X35')
	closebtn:SetTextColor(Color(255, 255, 255))
	closebtn.Paint = function(self, w, h) dbtPaint.DrawRectR(MatCLose, w / 2, h / 2, w * 0.5, h * 0.5, 0) end

	closebtn.DoClick = function(self)
		mainpanel:Remove()
	end
end

netstream.Hook('dbt/newnotes', function(name, pages, entity)
	dbt_newnote(name, pages, entity, false)
end)
