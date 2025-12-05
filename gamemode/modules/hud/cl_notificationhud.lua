AddCSLuaFile()
local scrw = ScreenWidth or ScrW()
local scrh = ScreenHeight or ScrH()
local l_SetDrawColor = surface.SetDrawColor
local l_SetMaterial = surface.SetMaterial
local l_DrawTexturedRect = surface.DrawTexturedRect
local MSG_ALPHA = 0
local MSG_CAN_LERP = false
MonopadMessege = Material("icons/monopad_message.png")
local notifmatsecond = http.Material('https://cdn-icons-png.flaticon.com/512/4297/4297329.png', 'smooth')
local notifmatthird = http.Material('https://cdn-icons-png.flaticon.com/512/4297/4297341.png', 'smooth')

-- notifications_new
local notifications = {}
local zetposition
local mat_circile = CreateMaterial( "circle", "UnlitGeneric", {
    ["$basetexture"] = "dbt/dbt_circle.vtf",
    ["$alphatest"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$smooth"] = 1,
    ["$mips"] = 1,
    ["$allowalphatocoverage"] = 1,
    ["$alphatestreference "] = 0.8,
} )
local mat_podlojka = CreateMaterial( "podlojkatest", "UnlitGeneric", {
    ["$basetexture"] = "dbt/dbt_pr.vtf",
    ["$alphatest"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$smooth"] = 1,
    ["$mips"] = 1,
    ["$allowalphatocoverage"] = 1,
    ["$alphatestreference "] = 0.8,
} )
/*
	wound type data: {woundpos = *, wound = *}
	example(server):
	netstream.Start(activator, 'dbt/NewNotification', 2, {woundpos = 'Левая нога', wound = 'перелом'})

	item type data: {itemdata = *}
	example(server):
	netstream.Start(activator, 'dbt/NewNotification', 2, {itemdata = 17})

	system type data: {icon = *, title = *, titlecolor = *, notiftext = *};
	example(server):
	netstream.Start(activator, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'Уведомление', titlecolor = Color(222, 193, 49), notiftext = 'Вы не можете это использовать, у вас нет ранений.'})

	monopad type data: {icon = *, title = *, time = *, notiftext = *}
	example(server):
	netstream.Start(activator, 'dbt/NewNotification', 2, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'Общий чат', time = '14:48', notiftext = 'Hello, world!'})
*/
netstream.Hook("dbt/NewNotification", function(notiftype, data)
	local isneed = true
	if !isnumber(data) then
		for k, v in pairs(notifications) do
			if v.notiftext and data.notiftext then
				if v.notiftext == data.notiftext then
					isneed = false
					break
				end
			end
		end
	end
	if isneed then
		notifications_new(notiftype, data)
	end
end)
function notifications_new(notiftype, data)
	if !notiftype then return end
	if data.icon then
		data.icon = Material(data.icon, "smooth")
	end

	if notiftype == 1 then
		local num = #notifications + 1
		notifications[num] = {notifictype = notiftype, woundpos = data.woundpos, wound = data.wound, lerp = 0, isplus = true}
		timer.Simple(5,function ()
			timer.Create('notification1_'..num, 0, 0,function ()
				if !notifications[num] then timer.Remove('notification1_'..num) return end
				if notifications[num].lerp <= 0 then timer.Remove('notification1_'..num) notifications[num].icon = nil notifications[num] = nil end
				if notifications[num] then
					notifications[num].lerp = notifications[num].lerp - 0.02
				end
			end)
		end)
	elseif notiftype == 2 then
		surface.PlaySound('inv_collected.mp3')
		local num = #notifications + 1
		notifications[num] = {notifictype = notiftype, itemdata = dbt.inventory.items[math.floor(data[1])], lerp = 0, isplus = true, position = sizebyheight(470)}

		timer.Simple(5,function ()
			timer.Create('notification2_'..num, 0, 0,function ()
				if !notifications[num] then timer.Remove('notification2_'..num) return end
				if notifications[num].lerp <= 0 then timer.Remove('notification2_'..num) notifications[num] = nil end
				if notifications[num] then
					notifications[num].lerp = notifications[num].lerp - 0.05
				end
			end)
		end)
	elseif notiftype == 3 then
		local num = #notifications + 1
		notifications[num] = {notifictype = notiftype, icon = data.icon, title = data.title, titlecolor = data.titlecolor, notiftext = data.notiftext, position = sizebyheight(1080), lerp = 1, timer = 5}

		timer.Create('notification3_timer_'..num, 0, 0,function ()
			if !notifications[num] then timer.Remove('notification3_timer_'..num) return end
			notifications[num].timer = notifications[num].timer - 0.03
			if notifications[num].timer < 0 then
				timer.Remove('notification3_timer_'..num)
			end
		end)

		timer.Simple(2,function ()
			timer.Create('notification3_'..num, 0, 0,function ()
				if !notifications[num] then timer.Remove('notification3_'..num) return end
				if notifications[num].timer >= 0.2 then return end
				if notifications[num].lerp <= 0 then timer.Remove('notification3_'..num) notifications[num] = nil end
				if notifications[num] then
					notifications[num].lerp = notifications[num].lerp - 0.035
				end
			end)
		end)

	elseif notiftype == 4 then
		local num = #notifications + 1
		if string.len(data.notiftext) > 72 then
			data.notiftext = utf8.sub(data.notiftext, 1, 70)
			data.notiftext = data.notiftext..'...'
		end
		notifications[num] = {notifictype = notiftype, icon = data.icon, title = data.title, time = data.time, notiftext = data.notiftext, position = sizebyheight(1080), lerp = 1, timer = 5}
		zetposition = zetposition or sizebyheight(1080)

		timer.Create('notification4_timer_'..num, 0, 0,function ()
			if !notifications[num] then timer.Remove('notification4_timer_'..num) return end
			notifications[num].timer = notifications[num].timer - 0.03
			if notifications[num].timer < 0 then
				timer.Remove('notification4_timer_'..num)
			end
		end)

		timer.Simple(2,function ()
			timer.Create('notification4_'..num, 0, 0,function ()
				if !notifications[num] then timer.Remove('notification4_'..num) return end
				if notifications[num].timer >= 0.2 then return end
				if notifications[num].lerp <= 0 then timer.Remove('notification4_'..num) notifications[num] = nil end
				if notifications[num] then
					notifications[num].lerp = notifications[num].lerp - 0.035
				end
			end)
		end)
	end
end

local cooldown = CurTime()
local materialitems = Material('materials/dbt/notifications/notifications_itemsbackground.png')
local testmaterial = Material('materials/dbt/notifications/notifications_podlojka.png')
hook.Add("HUDPaint", 'dbt/notifications/draw',function ()
	if see_r then
		notifications_new(3, {icon = 'materials/dbt/notifications/notifications_rules.png', title = 'Изменения в правилах', titlecolor = Color(222, 193, 49), notiftext = 'В правилах произошли изменения. Обязательно ознакомьтесь!'})
		see_r = false
	end
	local y1 = -1
	local y2 = -1
	local y3 = -1
	local y4 = -1
	local isfirst = true
	if input.IsKeyDown(KEY_Z) and cooldown < CurTime() then
		for k, v in pairs(notifications) do
			if v.notifictype == 4 then
				notifications[k] = nil
			end
		end
		cooldown = CurTime() + 1
	end

	for k, v in pairs(notifications) do
		if v.notifictype == 1 then
			y1 = y1 + 1
		elseif v.notifictype == 2 then
			y2 = y2 + 1
		elseif v.notifictype == 3 then
			y3 = y3 + 1
		elseif v.notifictype == 4 then
			y4 = y4 + 1
		end
	end

	for k, v in pairs(notifications) do
		if v.notifictype == 1 then
			if v.isplus then
				v.lerp = v.lerp + 0.01
				if v.lerp >= 1 then
					v.isplus = false
				end
			end
			surface.SetFont('Comfortaa X28')
			local x, y = surface.GetTextSize(v.woundpos..' '..v.wound)
			surface.DrawMulticolorText(sizebywidth(960) - x*0.5, sizebyheight(540) + sizebyheight(20)*y1, 'Comfortaa X28', {Color(234, 30, 33, 255*v.lerp), v.woundpos..' ', Color(255, 255, 255, 255*v.lerp), v.wound})
			y1 = y1 - 1
		elseif v.notifictype == 2 then
			v.position = Lerp(RealFrameTime()*7, v.position, sizebyheight(500) + sizebyheight(50) * y2)
			local name = v.itemdata.name
			if v.isplus then
				v.lerp = v.lerp + 0.03
				if v.lerp >= 1 then
					v.isplus = false
				end
			end

			if utf8.len(name) > 14 then name = utf8.sub(name, 1, 14) .. '...' end

			surface.SetFont('Comfortaa X27')
			local x, y = surface.GetTextSize(name)

			surface.SetDrawColor(0, 0, 0, 255*v.lerp)
			surface.SetMaterial(materialitems)
			surface.DrawTexturedRect(sizebywidth(20), v.position, sizebywidth(334), sizebyheight(42))

			if !v.icon then
				v.icon = vgui.Create( "DModelPanel" )
				v.icon:SetSize(hight_source(35), hight_source(35) )
				v.icon:SetPos(weight_source(20), hight_source(v.position))

				function v.icon:LayoutEntity( Entity )
					v.icon:SetPos(weight_source(20), hight_source(v.position))
					v.icon:SetAlpha(255*v.lerp)
					if v.lerp <= 0.1 and self.canDelete then v.icon:Remove() end
					return
				end
				v.icon:SetModel(v.itemdata.mdl)
				local mn, mx = v.icon.Entity:GetRenderBounds()
				local size = 0
				size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
				size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
				size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

				v.icon:SetFOV( 40 )
				v.icon:SetCamPos( Vector( size, size, size ) )
				v.icon:SetLookAt( (mn + mx) * 0.5 )
				timer.Simple(1, function() v.icon.canDelete = true end)
			end

			surface.DrawMulticolorText(sizebywidth(60), v.position + y*0.2, 'Comfortaa X27', {Color(255, 255, 255, 255*v.lerp), name}, sizebywidth(274))
			y2 = y2 - 1
		elseif v.notifictype == 3 then
			v.position = Lerp(RealFrameTime()*5, v.position, sizebyheight(980) - sizebyheight(90) * y3)
			draw.RoundedBox(20, sizebywidth(20), v.position, sizebywidth(444), sizebyheight(80), Color(0, 0, 0, 178.5*v.lerp))
			surface.DrawMulticolorText(sizebywidth(97), v.position, 'Comfortaa Bold X27', {Color(v.titlecolor.r, v.titlecolor.g, v.titlecolor.b, v.titlecolor.a * v.lerp), v.title}, sizebywidth(350))
			surface.SetFont('Comfortaa X27')
			local x, y = surface.GetTextSize(v.title)
			surface.DrawMulticolorText(sizebywidth(97), v.position + y, 'Comfortaa X23', {Color(170, 170, 170, 255*v.lerp), v.notiftext}, sizebywidth(350))
			dbtPaint.StartStencil()
				surface.SetDrawColor( 255,255,255,255*v.lerp)
				surface.SetMaterial( mat_podlojka )
				surface.DrawTexturedRect(sizebywidth(20), v.position, sizebywidth(419), sizebyheight(80))
			dbtPaint.ApllyStencil()
				surface.SetDrawColor(v.titlecolor.r, v.titlecolor.g, v.titlecolor.b, 200 * v.lerp)
				surface.DrawRect(sizebywidth(20), sizebyheight(v.position + sizebyheight(78)), sizebywidth(444)*(v.timer/5), sizebyheight(2))
			render.SetStencilEnable( false )

			if v.icon then
				surface.SetDrawColor(255, 255, 255, 255 * v.lerp)
				surface.SetMaterial(v.icon)
				surface.DrawTexturedRect(sizebywidth(35), v.position + sizebyheight(15), sizebywidth(50), sizebyheight(50))
			end

			y3 = y3 - 1
		elseif v.notifictype == 4 then
			if isfirst then
				zetposition = Lerp(RealFrameTime()*7, zetposition, sizebyheight(950) - sizebyheight(90) * y4)
				surface.DrawMulticolorText(sizebywidth(1650), zetposition, 'Comfortaa Bold X27', {Color(202, 10, 255, 255*v.lerp), 'Z'}, sizebywidth(360))
				surface.SetFont('Comfortaa Bold X27')
				local width1, height1 = surface.GetTextSize('Z')
				surface.DrawMulticolorText(sizebywidth(1650) + width1, zetposition, 'Comfortaa X27', {Color(255, 255, 255, 255*v.lerp), ' - свернуть уведомления'}, sizebywidth(360))
				isfirst = false
			end
			v.position = Lerp(RealFrameTime()*5, v.position, sizebyheight(980) - sizebyheight(90) * y4)
			draw.RoundedBox(20, sizebywidth(1456), v.position, sizebywidth(444), sizebyheight(80), Color(0, 0, 0, 200 * v.lerp))
			surface.DrawMulticolorText(sizebywidth(1546), v.position + sizebyheight(4), 'Comfortaa Bold X27', {Color(255, 255, 255, 255*v.lerp), v.title, Color(170, 170, 170, 255*v.lerp)}, sizebywidth(360))
			surface.SetFont('Comfortaa Bold X27')
			local x, y = surface.GetTextSize(v.title)
			surface.DrawMulticolorText(sizebywidth(1546) + x, v.position + sizebyheight(4), 'Comfortaa X25', {Color(170, 170, 170, 255*v.lerp), ' • '.. v.time}, sizebywidth(360) - x)
			surface.DrawMulticolorText(sizebywidth(1546), v.position + y + sizebyheight(2), 'Comfortaa X23', {Color(170, 170, 170, 255*v.lerp), v.notiftext}, sizebywidth(360))
			dbtPaint.StartStencil()
				surface.SetDrawColor( 255,255,255,255*v.lerp)
				surface.SetMaterial( mat_podlojka )
				surface.DrawTexturedRect( sizebywidth(1456), v.position, sizebywidth(444), sizebyheight(80))
			dbtPaint.ApllyStencil()
				surface.SetDrawColor(255, 255, 255, 255*v.lerp)
				surface.DrawRect(sizebywidth(1456), sizebyheight(v.position + sizebyheight(78)), sizebywidth(444)*(v.timer/5), sizebyheight(2))
			render.SetStencilEnable( false )

			if v.icon and v.title != 'Общий чат' then
				dbtPaint.StartStencil()
	                surface.SetDrawColor( 255,255,255,255*v.lerp)
		            surface.SetMaterial( mat_circile )
		            surface.DrawTexturedRect( dbtPaint.WidthSource(1471), v.position + sizebyheight(5), sizebywidth(65), sizebyheight(65))
	            --char_ico_1
	            dbtPaint.ApllyStencil()
		            surface.SetDrawColor( 255, 255, 255, 255*v.lerp )
		            surface.SetMaterial( v.icon )
		            surface.DrawTexturedRect( dbtPaint.WidthSource(1471), v.position + sizebyheight(5), sizebywidth(65), sizebyheight(65))
	            render.SetStencilEnable( false )
			else
				surface.SetDrawColor(255, 255, 255, 255 * v.lerp)
				surface.SetMaterial(v.icon)
				surface.DrawTexturedRect(sizebywidth(1481), v.position + sizebyheight(15), sizebywidth(48), sizebyheight(48))
			end

			y4 = y4 - 1
		end
	end
end)

hook.Add( "PlayerBindPress", "CanUndo", function( ply, bind )
	if ply == LocalPlayer() and bind == "gmod_undo" and #notifications > 1 then
		return true
	end
end )
