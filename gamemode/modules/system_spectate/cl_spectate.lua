AddCSLuaFile()
local tblhalospectate = {}
local currentspectateply
local currentnumspectate = 1
local mapp, mclamp = math.Approach, math.Clamp

function dbt.SpectateForUsers(ply)
	if InGame(ply, true) then notifications_new(3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'Уведомление', titlecolor = Color(222, 193, 49), notiftext = 'Наблюдать могут только мёртвые. Но мы же не торопимся на тот свет, верно?'}) return end
	for k,i in pairs(hook.GetTable().CalcView ) do
		hook.Remove("CalcView", k)
	end

	local allplayers = player.GetAll()
	local cooldown = CurTime()
	local beginnum = 1
	local isnothing = false
	while allplayers[beginnum] == LocalPlayer() or IsMono(allplayers[beginnum]) or not InGame(allplayers[beginnum]) do
		if beginnum == #allplayers then
			isnothing = true
			break
		end
		beginnum = beginnum + 1
	end
	if isnothing then return end
	netstream.Start('dbt/systemspectate/startspectate', LocalPlayer(), allplayers[beginnum])

	ply.IsSpectate = true
	currentspectateply = allplayers[beginnum]

	hook.Add( "Think", "dbt/systemspectate/positionchange", function()
		if !isnothing then
			if input.IsMouseDown(MOUSE_LEFT) and !currentspectateply and cooldown < CurTime() then
				currentnumspectate = beginnum
				while allplayers[currentnumspectate] == LocalPlayer() or IsMono(allplayers[currentnumspectate]) or not InGame(allplayers[currentnumspectate]) do
					currentnumspectate = currentnumspectate + 1
				end
				if allplayers[currentnumspectate] then
					currentspectateply = allplayers[currentnumspectate]
				else
					return
				end
				cooldown = CurTime() + 0.5
			elseif input.IsMouseDown(MOUSE_LEFT) and cooldown < CurTime() then
				currentnumspectate = currentnumspectate + 1
				while IsValid(allplayers[currentnumspectate]) and (allplayers[currentnumspectate] == LocalPlayer() or IsMono(allplayers[currentnumspectate]) or not InGame(allplayers[currentnumspectate])) do
					currentnumspectate = currentnumspectate + 1
				end
				if allplayers[currentnumspectate] then
					currentspectateply = allplayers[currentnumspectate]
				else
					currentnumspectate = beginnum
					currentspectateply = allplayers[currentnumspectate]
				end
				cooldown = CurTime() + 0.25
			elseif input.IsMouseDown(MOUSE_RIGHT) and cooldown < CurTime() then
				currentnumspectate = currentnumspectate - 1
				while IsValid(allplayers[currentnumspectate]) and (allplayers[currentnumspectate] == LocalPlayer() or IsMono(allplayers[currentnumspectate]) or not InGame(allplayers[currentnumspectate])) do
					currentnumspectate = currentnumspectate - 1
				end
				if allplayers[currentnumspectate] then
					currentspectateply = allplayers[currentnumspectate]
				else
					currentnumspectate = #allplayers
					if not InGame(allplayers[currentnumspectate]) then currentnumspectate = beginnum end
					while not InGame(allplayers[currentnumspectate]) do
						currentnumspectate = currentnumspectate + 1
					end
					currentspectateply = allplayers[currentnumspectate]
				end
				cooldown = CurTime() + 0.25
			end
		end

		if input.IsKeyDown(KEY_SPACE) then
			ply.IsSpectate = false
			hook.Remove( "Think", "dbt/systemspectate/positionchange" )
			netstream.Start('dbt/systemspectate/stopspectate')
		end
	end)
end

hook.Add("HUDPaint","dbt/systemspectate/menu",function ()
	local ply = LocalPlayer()
	if ply.IsSpectate then
		surface.SetFont("Comfortaa X30")
		local textwjump, texthjump = surface.GetTextSize("Нажмите SPACE чтобы выйти из Spectate-режима.")
		surface.DrawMulticolorText(scrw - textwjump - 5, scrh - texthjump - 5, "Comfortaa X30", {color_white, "Нажмите "..input.LookupBinding("+jump").." чтобы выйти из Spectate-режима."}, scrw)

		surface.SetFont("Comfortaa X50")
		if currentspectateply and currentspectateply:IsValid() then
			if IsValid(LocalPlayer():GetObserverTarget()) then
				local textw, texth = surface.GetTextSize(LocalPlayer():GetObserverTarget():Pers())
				surface.DrawMulticolorText(scrw*0.5 - textw*0.5, texth - scrh*0.05, "Comfortaa X50", {color_white, LocalPlayer():GetObserverTarget():Pers()}, scrw)
			end

			surface.SetFont("Comfortaa X30")
			local textwreload, texthreload = surface.GetTextSize("Используйте ЛКМ и ПКМ для переключения игроков во время слежки.")
			surface.DrawMulticolorText(scrw - textwreload - 5, scrh - texthjump - texthreload - 5, "Comfortaa X30", {color_white, "Используйте ЛКМ и ПКМ для переключения игроков во время слежки."}, scrw)
		else
			local textw, texth = surface.GetTextSize("Нет слежки")
			surface.DrawMulticolorText(scrw*0.5 - textw*0.5, texth - scrh*0.05, "Comfortaa X50", {color_white, "Нет слежки"}, scrw)
		end
	end
end)

hook.Add( "PreDrawHalos", "dbt/systemspectate/halos", function()
	if LocalPlayer().IsSpectate then
		for _, playergame in pairs(player.GetAll()) do
			tblhalospectate[playergame:EntIndex()] = playergame
		end

		halo.Add( tblhalospectate, Color(255, 0, 0), 0, 0, 1, true, true )
	end
end )
