local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()
local MatCLose = Material("dbt/d542c202ca4c957c.png")
local MatAdd = Material("dbt/123123212.png", "smooth")
surface.CreateFont("cook_font1", {
  font = "Comfortaa Light Light",
  size = weight_source(30),
  weight = 800,
  antialias = true
})

surface.CreateFont("cook_font_inf1", {
  font = "Comfortaa Light Light",
  size = ScrW() / 100,
  weight = 800,
  antialias = true
})
hpperc = 0
food_timer = 5
local function start_pick(time, information)
	if cooking_food == information.name then
		hook.Remove("HUDPaint", "TakeFood")
		timer.Remove("TakeFood")
		timer.Remove("TimerFood_NewPanel")
		cooking_food = nil
		food_timer = 5

		return
	end

    cooking_food = information.name
	if LocalPlayer():Pers() == 'Кируми Тоджо' or LocalPlayer():Pers() == 'Тэрутэру Ханамура' then time = time * 0.5 end
	food_timer = time
	timer.Create("TakeFood", time, 1, function()
		information.food = information.food or 0
		information.water = information.water or 0
		hook.Remove("HUDPaint", "TakeFood")
		netstream.Start("dbt/food/spawn", information.mdl, information.food, information.id, information.water)
        cooking_food = nil
	end)

	timer.Create("TimerFood_NewPanel", 1, time,function ()
		if food_timer == 0 then timer.Remove("TimerFood_NewPanel") return end

		food_timer = food_timer - 1
	end)

	hook.Add("HUDPaint", "TakeFood", function()
		hpperc = math.Clamp( timer.TimeLeft("TakeFood") / time, 0, 1 )

        if util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) ).Entity:GetPos():Distance(LocalPlayer():GetPos()) >= 90 then
        	hook.Remove("HUDPaint", "TakeFood")
        	timer.Remove("TakeFood")
			timer.Remove("TimerFood_NewPanel")
            cooking_food = nil
        end
	end)

end

	/*
    local frameW, frameH, animTime, animDelay, animEase = ScrW() * 0.3 - 13, ScrH() * 0.6 - 10, 1.8, 0, .1
    Oprndesc = vgui.Create("DFrame")
   	Oprndesc:SetTitle("")
   	Oprndesc:MakePopup()
    Oprndesc:SetSize(0, ScrH() * 0.5)
    Oprndesc:ShowCloseButton(false)
    Oprndesc:SetPos(ScrW() / 2 - ScrW() * 0.3 / 2, ScrH() / 2 - ScrH() * 0.6 / 2)
    local isAnimating = true
    Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false

    end)
    Oprndesc.Paint = function(self,w,h)

        surface.SetDrawColor(51, 43, 54, 255)
        surface.DrawRect(0, 0, w,h)

        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, 0, w, h * 0.07)

       	draw.DrawText("Холодильник", "Comfortaa Light X30", 10, h * 0.01, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    end


    local DScrollPanel = vgui.Create( "DScrollPanel", Oprndesc )
    DScrollPanel:SetPos(0, ScrH() * 0.05)
    DScrollPanel:SetSize(ScrW() * 0.295, ScrH() * 0.6 - ScrH() * 0.07)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)
    end
    function sbar.btnUp:Paint(w, h)
    end
    function sbar.btnDown:Paint(w, h)
    end
    function sbar.btnGrip:Paint(w, h)
    end

	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	end

   	y = 0
    for k,i in pairs(_folig) do
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetPos(10, y)
        DButton:SetSize(ScrW() * 0.295, ScrH() / 17.14)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor(41, 33, 44, 255)
            surface.DrawRect(0, 0, w, h)


            if cooking_food == i.name then
                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w - w * hpperc, h)
            end

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  i.icon  )
            surface.DrawTexturedRect( w / 60, h / 10, ScrH() / 20, ScrH() / 22.5 )


            draw.DrawText( i.name, "Comfortaa Light X30", w / 20 + ScrH() / 23, 0, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( "Время: "..dbt.inventory.items[i.id].time.." секунд", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.67, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( (cooking_food == i.name) and "Взятие..." or "Взять", "Comfortaa Light X30", w * 0.78, h * 0.25, (cooking_food == i.name) and Color(186, 85, 211) or color_white, TEXT_ALIGN_LEFT )

			if i.id == 9 then
				draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].food.." голода и "..dbt.inventory.items[i.id].water.." жажды", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
			elseif i.food and i.id ~= 9 then
            	draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].food.." голода", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
            else
                draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].water.." жажды", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
            end
        end
        DButton.DoClick = function()
        	start_pick(dbt.inventory.items[i.id].time, i)
        end
        y = y + ScrH() / 17.14 + 10
    end

        local DButton = Oprndesc:Add( "DButton" )
        DButton:SetPos(ScrW() * 0.3 - (ScrW() * 0.017 + 20), 7 )
        DButton:SetSize(ScrW() * 0.017, ScrW() * 0.017)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  Material("icons/ui_cancel.png")  )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        DButton.DoClick = function(self)
            self:GetParent():Close()
            hook.Remove("HUDPaint", "TakeFood")
            timer.Remove("TakeFood")
            cooking_food = nil
        end

*/
	--cooking_newpanel('ПОЛКА С ЕДОЙ', _polka, true)
	/*
    local frameW, frameH, animTime, animDelay, animEase = ScrW() * 0.3, ScrH() * 0.6, 1.8, 0, .1
    Oprndesc = vgui.Create("DFrame")
    Oprndesc:SetTitle("")
    Oprndesc:MakePopup()
    Oprndesc:SetSize(0, ScrH() * 0.5)
    Oprndesc:ShowCloseButton(false)
    Oprndesc:SetPos(ScrW() / 2 - ScrW() * 0.3 / 2, ScrH() / 2 - ScrH() * 0.6 / 2)
    local isAnimating = true
    Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false

    end)
    Oprndesc.Paint = function(self,w,h)

        surface.SetDrawColor(51, 43, 54, 255)
        surface.DrawRect(0, 0, w,h)

        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, 0, w, h * 0.07)

        draw.DrawText("Взять", "Comfortaa Light X30", 10, h * 0.01, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    end


    local DScrollPanel = vgui.Create( "DScrollPanel", Oprndesc )
    DScrollPanel:SetPos(0, ScrH() * 0.05)
    DScrollPanel:SetSize(ScrW() * 0.295, ScrH() * 0.6 - ScrH() * 0.07)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)
    end
    function sbar.btnUp:Paint(w, h)
    end
    function sbar.btnDown:Paint(w, h)
    end
    function sbar.btnGrip:Paint(w, h)
    end

    y = 0
	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	end

    for k,i in pairs(_polka) do
		if i.id == 13 then continue end
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetPos(10, y)
        DButton:SetSize(ScrW() * 0.295, ScrH() / 17.14)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor(41, 33, 44, 255)
            surface.DrawRect(0, 0, w, h)


            if cooking_food == i.name then
                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w - w * hpperc, h)
            end

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  i.icon  )
            surface.DrawTexturedRect( w / 60, h / 10, ScrH() / 20, ScrH() / 22.5 )


            draw.DrawText( i.name, "Comfortaa Light X30", w / 20 + ScrH() / 23, 0, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( "Время: "..dbt.inventory.items[i.id].time.." секунд", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.67, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( (cooking_food == i.name) and "Взятие..." or "Взять", "Comfortaa Light X30", w * 0.78, h * 0.25, (cooking_food == i.name) and Color(186, 85, 211) or color_white, TEXT_ALIGN_LEFT )

            if i.food then
                draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].food.." голода", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
            else
                draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].water.." жажды", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
            end
        end
        DButton.DoClick = function()
            start_pick(dbt.inventory.items[i.id].time, i)
        end
        y = y + ScrH() / 17.14 + 10
    end

        local DButton = Oprndesc:Add( "DButton" )
        DButton:SetPos(ScrW() * 0.3 - (ScrW() * 0.017 + 10), 7 )
        DButton:SetSize(ScrW() * 0.017, ScrW() * 0.017)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  Material("icons/ui_cancel.png")  )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        DButton.DoClick = function(self)
            self:GetParent():Close()
            hook.Remove("HUDPaint", "TakeFood")
            timer.Remove("TakeFood")
            cooking_food = nil
        end

*/

local function start_pick_pech(time, information, ent)
	information.cost = information.cost or 1
    if ent:GetNWInt("Cock_amout") < information.cost then return end
	if cooking_food == information.name then
		hook.Remove("HUDPaint", "TakeFood")
		timer.Remove("TakeFood")
		cooking_food = nil
		food_timer = 5
		return
	end
    cooking_food = information.name
	if LocalPlayer():Pers() == 'Кируми Тоджо' or LocalPlayer():Pers() == 'Тэрутэру Ханамура' then time = time * 0.5 end

	food_timer = time
	timer.Create("TimerFood_NewPanel", 1, time,function ()
		if food_timer == 0 then timer.Remove("TimerFood_NewPanel") return end

		food_timer = food_timer - 1
	end)

    timer.Create("TakeFood", time, 1, function()
        if ent:GetNWInt("Cock_amout") < information.cost then return end
        hook.Remove("HUDPaint", "TakeFood")
        netstream.Start("dbt/food/spawn", information.mdl, information.food, information.id, information.water)
        netstream.Start("dbt/pech/rem", ent, information.cost)
        cooking_food = nil
    end)

    hook.Add("HUDPaint", "TakeFood", function()
        hpperc = math.Clamp( timer.TimeLeft("TakeFood") / time, 0, 1 )

        if util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) ).Entity:GetPos():Distance(LocalPlayer():GetPos()) >= 90 then
            hook.Remove("HUDPaint", "TakeFood")
            timer.Remove("TakeFood")
            cooking_food = nil
        end
    end)
end


netstream.Hook("dbt/food/furngug", function(ent, name, items)
	pech_newpanel(name, items, true, ent)
	/*
    local frameW, frameH, animTime, animDelay, animEase = ScrW() * 0.3, ScrH() * 0.6, 1.8, 0, .1
    Oprndesc = vgui.Create("DFrame")
    Oprndesc:SetTitle("")
    Oprndesc:MakePopup()
    Oprndesc:SetSize(0, ScrH() * 0.5)
    Oprndesc:ShowCloseButton(false)
    Oprndesc:SetPos(ScrW() / 2 - ScrW() * 0.3 / 2, ScrH() / 2 - ScrH() * 0.6 / 2)
    local isAnimating = true
    Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false

    end)
    Oprndesc.Paint = function(self,w,h)

        surface.SetDrawColor(51, 43, 54, 255)
        surface.DrawRect(0, 0, w,h)

        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, 0, w, h * 0.07)

        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, h - h * 0.09, w, h * 0.09)

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( Material("icons/food_bag_flour.png", "mips")  )
        surface.DrawTexturedRect( w * 0.006, h - h * 0.09, h * 0.09, h * 0.09 )

        draw.DrawText(ent:GetNWInt("Cock_amout").."/10", "Comfortaa Light X30",  w * 0.11, h - h * 0.07, Color(255,255,255,255), TEXT_ALIGN_LEFT)

        draw.DrawText("Печь", "Comfortaa Light X30", 10, h * 0.01, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    end


    local DScrollPanel = vgui.Create( "DScrollPanel", Oprndesc )
    DScrollPanel:SetPos(0, ScrH() * 0.05)
    DScrollPanel:SetSize(ScrW() * 0.295, ScrH() * 0.6 - ScrH() * 0.07)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)
    end
    function sbar.btnUp:Paint(w, h)
    end
    function sbar.btnDown:Paint(w, h)
    end
    function sbar.btnGrip:Paint(w, h)
    end

	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	end

    y = 0
    for k,i in pairs(_furngug) do
		if i.name == "Куриная ножка" then i.cost = 3 end
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetPos(10, y)
        DButton:SetSize(ScrW() * 0.295, ScrH() / 17.14)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor(41, 33, 44, 255)
            surface.DrawRect(0, 0, w, h)


            if cooking_food == i.name then
                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w - w * hpperc, h)
            end

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  i.icon  )
            surface.DrawTexturedRect( w / 60, h / 10, ScrH() / 20, ScrH() / 22.5 )

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material("icons/food_bag_flour.png", "mips")  )
            surface.DrawTexturedRect( w - ScrH() / 20 - 5, h / 5, ScrH() / 29, ScrH() / 29 )
            draw.DrawText( i.cost, "Comfortaa Light X30", w - ScrH() / 20 - 10, h / 4, color_white, TEXT_ALIGN_RIGHT )

            draw.DrawText( i.name, "Comfortaa Light X30", w / 20 + ScrH() / 23, 0, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( "Время: "..dbt.inventory.items[i.id].time.." секунд", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.67, color_white, TEXT_ALIGN_LEFT )
            if i.food then
                draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].food.." голода", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.39, color_white, TEXT_ALIGN_LEFT )
            else
                draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].water.." жажды", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.39, color_white, TEXT_ALIGN_LEFT )
            end
        end
        DButton.DoClick = function()
            if ent:GetNWInt("Cock_amout") < i.cost then return end
            start_pick_pech(dbt.inventory.items[i.id].time, i, ent)
        end
        y = y + ScrH() / 17.14 + 10
    end

        local DButton = Oprndesc:Add( "DButton" )
        DButton:SetPos(ScrW() * 0.3 - (ScrW() * 0.017 + 10), 7 )
        DButton:SetSize(ScrW() * 0.017, ScrW() * 0.017)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  Material("icons/ui_cancel.png")  )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        DButton.DoClick = function(self)
            self:GetParent():Close()
            hook.Remove("HUDPaint", "TakeFood")
            timer.Remove("TakeFood")
            cooking_food = nil
        end

*/
end)

	/*
    local frameW, frameH, animTime, animDelay, animEase = ScrW() * 0.3 - 13, ScrH() * 0.6 - 10, 1.8, 0, .1
    Oprndesc = vgui.Create("DFrame")
   	Oprndesc:SetTitle("")
   	Oprndesc:MakePopup()
    Oprndesc:SetSize(0, ScrH() * 0.5)
    Oprndesc:ShowCloseButton(false)
    Oprndesc:SetPos(ScrW() / 2 - ScrW() * 0.3 / 2, ScrH() / 2 - ScrH() * 0.6 / 2)
    local isAnimating = true
    Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false

    end)
    Oprndesc.Paint = function(self,w,h)

        surface.SetDrawColor(51, 43, 54, 255)
        surface.DrawRect(0, 0, w,h)

        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, 0, w, h * 0.07)

       	draw.DrawText("Чайник", "Comfortaa Light X30", 10, h * 0.01, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    end


    local DScrollPanel = vgui.Create( "DScrollPanel", Oprndesc )
    DScrollPanel:SetPos(0, ScrH() * 0.05)
    DScrollPanel:SetSize(ScrW() * 0.295, ScrH() * 0.6 - ScrH() * 0.07)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)
    end
    function sbar.btnUp:Paint(w, h)
    end
    function sbar.btnDown:Paint(w, h)
    end
    function sbar.btnGrip:Paint(w, h)
    end

	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	end

   	y = 0
    for k,i in pairs(_teapot) do
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetPos(10, y)
        DButton:SetSize(ScrW() * 0.295 - 25 , ScrH() / 17.14)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor(41, 33, 44, 255)
            surface.DrawRect(0, 0, w, h)


            if cooking_food == i.name then
                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w - w * hpperc, h)
            end

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  i.icon  )
            surface.DrawTexturedRect( w / 60, h / 10, ScrH() / 20, ScrH() / 22.5 )


            draw.DrawText( i.name, "Comfortaa Light X30", w / 20 + ScrH() / 23, 0, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( "Время: "..dbt.inventory.items[i.id].time.." секунд", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.67, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( (cooking_food == i.name) and "Готовка..." or "Сделать", "Comfortaa Light X30", w * 0.78, h * 0.25, (cooking_food == i.name) and Color(186, 85, 211) or color_white, TEXT_ALIGN_LEFT )

			if i.id == 13 then
				draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].water.." жажды и 20 бодрости раз в 40 мин.", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
            else
                draw.DrawText( "Восполняет: "..dbt.inventory.items[i.id].water.." жажды", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
            end
        end
        DButton.DoClick = function()
        	start_pick(dbt.inventory.items[i.id].time, i)
        end
        y = y + ScrH() / 17.14 + 10
    end

        local DButton = Oprndesc:Add( "DButton" )
        DButton:SetPos(ScrW() * 0.3 - (ScrW() * 0.017 + 20), 7 )
        DButton:SetSize(ScrW() * 0.017, ScrW() * 0.017)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  Material("icons/ui_cancel.png")  )
            surface.DrawTexturedRect( 0, 0, w, h )
        end
        DButton.DoClick = function(self)
            self:GetParent():Close()
            hook.Remove("HUDPaint", "TakeFood")
            timer.Remove("TakeFood")
            cooking_food = nil
        end

*/

local _medicine = {}
_medicine[#_medicine + 1] = {
	name = "Бинт",
	mdl = "models/props_everything/cheeseswiss.mdl",
	icon = Material("icons/medical_plaster.png", "smooth"),
	time = 5,
	food = 0,
	id = 31,
	description = "Используется для лечения легких ранений."
}

_medicine[#_medicine + 1] = {
	name = "Набор для устранения переломов",
	mdl = "models/props_everything/tomato.mdl",
	icon = Material("icons/151.png", "smooth"),
	time = 5,
	food = 0,
	id = 32,
	description = "Используется для лечения перелома."
}

_medicine[#_medicine + 1] = {
	name = "Мазь",
	mdl = "models/props_everything/watermelonslice.mdl",
	icon = Material("icons/medical_antiseptic_cream.png", "smooth"),
	time = 5,
	food = 0,
	id = 33,
	description = "Используется для лечения ушибов."
}

_medicine[#_medicine + 1] = {
	name = "Хирургический набор",
	mdl = "models/props_everything/watermelonslice.mdl",
	icon = Material("icons/medical_chest.png", "smooth"),
	time = 5,
	food = 0,
	id = 34,
	description = "Используется для лечения тяжелых ранений."
}

_medicine[#_medicine + 1] = {
    name = "Аптечка",
    mdl = "models/items/healthkit.mdl",
    icon = Material("icons/medical_chest.png", "smooth"),
    time = 5,
    medicine = "Аптечка",
    id = 37,
	description = "Для базового восстановления общего состояния здоровья."
}

netstream.Hook("dbt/woundsystem/medicalshelf", function()
	new_medicinepanel({31, 32, 33, 34, 37})
end)

function medicinepanel()
	local frameW, frameH, animTime, animDelay, animEase = ScrW() * 0.3 - 13, ScrH() * 0.6 - 10, 1.8, 0, .1
    Oprndesc = vgui.Create("DFrame")
   	Oprndesc:SetTitle("")
   	Oprndesc:MakePopup()
    Oprndesc:SetSize(0, ScrH() * 0.5)
    Oprndesc:ShowCloseButton(false)
    Oprndesc:SetPos(ScrW() / 2 - ScrW() * 0.3 / 2, ScrH() / 2 - ScrH() * 0.6 / 2)
    local isAnimating = true
    Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false

    end)
    Oprndesc.Paint = function(self,w,h)

        surface.SetDrawColor(51, 43, 54, 255)
        surface.DrawRect(0, 0, w,h)

        surface.SetDrawColor(68, 52, 74, 255)
        surface.DrawRect(0, 0, w, h * 0.07)

       	draw.DrawText("Медицинский отдел", "Comfortaa Light X30", 10, h * 0.01, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    end


    local DScrollPanel = vgui.Create( "DScrollPanel", Oprndesc )
    DScrollPanel:SetPos(0, ScrH() * 0.05)
    DScrollPanel:SetSize(ScrW() * 0.295, ScrH() * 0.6 - ScrH() * 0.07)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)
    end
    function sbar.btnUp:Paint(w, h)
    end
    function sbar.btnDown:Paint(w, h)
    end
    function sbar.btnGrip:Paint(w, h)
    end

	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	end

   	y = 0
    for k,i in pairs(_medicine) do
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetPos(10, y)
        DButton:SetSize(ScrW() * 0.295 - 25, ScrH() / 17.14)
        DButton:SetText("")
        DButton.Paint = function(self, w, h)
            surface.SetDrawColor(41, 33, 44, 255)
            surface.DrawRect(0, 0, w, h)


            if cooking_food == i.name then
                surface.SetDrawColor(68, 52, 74, 255)
                surface.DrawRect(0, 0, w - w * hpperc, h)
            end

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial(  i.icon  )
            surface.DrawTexturedRect( w / 60, h / 10, ScrH() / 20, ScrH() / 22.5 )


            draw.DrawText( i.name, "Comfortaa Light X28", w / 20 + ScrH() / 23, 0, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( "Время: "..i.time.." секунд", "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.67, color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( (cooking_food == i.name) and "Взятие..." or "Взять", "Comfortaa Light X30", w * 0.8, h * 0.25, (cooking_food == i.name) and Color(186, 85, 211) or color_white, TEXT_ALIGN_LEFT )
            draw.DrawText( i.description, "Comfortaa Light X20", w / 20 + ScrH() / 23, h * 0.4, color_white, TEXT_ALIGN_LEFT )
        end
        DButton.DoClick = function()
        	start_pick(dbt.inventory.items[i.id].time, i)
        end
        y = y + ScrH() / 17.14 + 10
    end

    local DButton = Oprndesc:Add( "DButton" )
    DButton:SetPos(ScrW() * 0.3 - (ScrW() * 0.017 + 20), 7 )
    DButton:SetSize(ScrW() * 0.017, ScrW() * 0.017)
    DButton:SetText("")
    DButton.Paint = function(self, w, h)
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial(  Material("icons/ui_cancel.png")  )
        surface.DrawTexturedRect( 0, 0, w, h )
    end
    DButton.DoClick = function(self)
        self:GetParent():Close()
        hook.Remove("HUDPaint", "TakeFood")
        timer.Remove("TakeFood")
        cooking_food = nil
    end
end

local lineformenu = Material("dbt/qmenu/qmenu_underline_name.png")
local lineformenumatw, lineformenumath = lineformenu:Width(), lineformenu:Height()

function new_medicinepanel(items_id)
	if Oprndesc then Oprndesc:Remove() end
	Oprndesc = vgui.Create("DFrame")
	--default settings
	local ischanging = false
	local itembuttons = {}
	local items = {}
	local menuonstart

	for k, v in pairs(items_id) do
		items[#items + 1] = dbt.inventory.items[v]
	end
	Oprndesc:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(680))
	Oprndesc:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(290), ScreenHeight*0.5 - dbtPaint.HightSource(340))
	Oprndesc:SetTitle("")
   	Oprndesc:MakePopup()
	Oprndesc:SetDraggable(false)
	Oprndesc:ShowCloseButton(false)

	--can voice
	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
		if Oprndesc_AddItemMenu then Oprndesc_AddItemMenu:Remove() Oprndesc_AddItemMenu = nil end
	end

	--design
	surface.SetFont('Comfortaa Light X35')
	local widthname, heightname = surface.GetTextSize('МЕДИЦИНСКИЙ ОТДЕЛ')

	Oprndesc.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h) -- main

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(lineformenu)
		surface.DrawTexturedRect(dbtPaint.WidthSource(0), dbtPaint.HightSource(33), dbtPaint.WidthSource(lineformenumatw) + dbtPaint.WidthSource(138), dbtPaint.HightSource(lineformenumath))

		surface.SetFont('Comfortaa Light X35')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w*0.5 - widthname*0.5, heightname*0.05)
		surface.DrawText('МЕДИЦИНСКИЙ ОТДЕЛ')
	end

	--items btns
	local y = 0
	local List

	if items then
		List = Oprndesc:Add("DScrollPanel")
		List:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(605))
		List:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(75))
		local sbar = List:GetVBar()
		sbar:SetSize(0, 0)

		local polygon = {
			[1] = {x = dbtPaint.WidthSource(470), y = dbtPaint.HightSource(5)},
			[2] = {x = dbtPaint.WidthSource(470), y = dbtPaint.HightSource(50)},
			[5] = {x = dbtPaint.WidthSource(470), y = dbtPaint.HightSource(50)},
		}
		for k, v in pairs(items) do
			local itembtn = List:Add('DButton')
			local isneedtorotate = false
			local isneedtochange = false
			local btncolor = Color(0, 0, 0, 100)
			local fonttime = 'Comfortaa Light X35'
			itembtn:SetSize(dbtPaint.WidthSource(560), dbtPaint.HightSource(55))
			itembtn:SetPos(dbtPaint.WidthSource(10),  dbtPaint.HightSource(62)*y)
			itembtn:SetText('')
			itembtn.data = v

			surface.SetFont('Comfortaa Light X30')
			local stringsizew, stringsizeh = surface.GetTextSize(v.name)

			itembtn.Paint = function(self, w, h)
				btncolor.a = isneedtochange and Lerp(FrameTime()*5, btncolor.a, 160) or Lerp(FrameTime()*5, btncolor.a, 120)
				surface.SetDrawColor(btncolor)
				surface.DrawRect(0, 0, w, h)

				surface.SetFont('Comfortaa Light X30')
				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(dbtPaint.WidthSource(64), dbtPaint.HightSource(3))
				surface.DrawText(v.name)

				surface.SetFont('Comfortaa Light X20')
				surface.SetTextPos(dbtPaint.WidthSource(65), stringsizeh - dbtPaint.HightSource(3))
				local textdesc = '???'
				for i, m in pairs(_medicine) do
					if m.id == v.id then
						textdesc = m.description
						break
					end
				end
				surface.DrawText(textdesc)

				if cooking_food == v.name then
	                surface.SetDrawColor(106, 8, 122, 62)
					polygon[3] = {x = math.Clamp(dbtPaint.WidthSource(560) - dbtPaint.WidthSource(80*hpperc), 0, dbtPaint.WidthSource(550)), y = dbtPaint.HightSource(5)}
					polygon[4] = {x = math.Clamp(dbtPaint.WidthSource(550) - dbtPaint.WidthSource(80*hpperc), dbtPaint.WidthSource(470), dbtPaint.WidthSource(550)), y = dbtPaint.HightSource(50)}
					draw.NoTexture()
	                surface.DrawPoly(polygon)

					surface.SetFont('Comfortaa Light X27')
					local timestringw, timestringh = surface.GetTextSize(ischanging and 'Удалить' or tostring(food_timer)..' сек...')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(495) - timestringw*0.25, timestringh*0.25)
					surface.DrawText(ischanging and 'Удалить' or tostring(food_timer)..' сек...')
					surface.SetFont('Comfortaa Light X15')
					local timestringw2, timestringh2 = surface.GetTextSize('Отмена')
					surface.SetTextPos(dbtPaint.WidthSource(498) - timestringw2*0.25, timestringh)
					surface.DrawText('Отмена')
	            else
					surface.SetFont(ischanging and 'Comfortaa Light X25' or fonttime)
					local timestringw, timestringh = surface.GetTextSize(ischanging and 'Удалить' or tostring(v.time)..' сек')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(495) - (ischanging and timestringw*0.27 or timestringw*0.25), (ischanging and timestringh*0.5 or timestringh*0.25))
					surface.DrawText(ischanging and 'Удалить' or tostring(v.time)..' сек')
				end

				surface.SetDrawColor(106, 8, 122, 62)
				surface.DrawOutlinedRect(dbtPaint.WidthSource(470), dbtPaint.HightSource(5), dbtPaint.WidthSource(80), dbtPaint.HightSource(45), 1)
				surface.SetDrawColor(106, 8, 122, 62)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			itembtn.OnCursorEntered = function(self)
				isneedtorotate = true
				isneedtochange = true
			end
			itembtn.OnCursorExited = function(self)
				isneedtorotate = false
				isneedtochange = false
			end

			itembtn.DoClick = function(self)
				if ischanging then
					y = 0
					for k, v in pairs(itembuttons) do
						if v == self then itembuttons[k] = nil continue end
						v:SetPos(dbtPaint.WidthSource(10),   dbtPaint.HightSource(62)*y)
						y = y + 1
					end

					self:Remove()
					return
				end
				PrintTable(dbt.inventory.items[v.id])
				start_pick(v.time, dbt.inventory.items[v.id])
			end

			itembuttons[#itembuttons + 1] = itembtn

			local icon = itembtn:Add( "DModelPanel" )
	        icon:SetSize( dbtPaint.WidthSource(50), dbtPaint.HightSource(50) )
			icon:SetPos( dbtPaint.WidthSource(2), dbtPaint.HightSource(2) )
	        if v.mdl then
				icon:SetModel( v.mdl )
				if IsValid(icon.Entity) then
					local mn, mx = icon.Entity:GetRenderBounds()
					local size = 0
					size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
					size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
					size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

					icon:SetFOV( 45 )
					icon:SetCamPos( Vector( size, size, size ) )
					icon:SetLookAt( (mn + mx) * 0.5 )
				end
	        end

			local rotation = 0
			icon.LayoutEntity = function(self, ent)
				if isneedtorotate then
					rotation = rotation + 0.25
					ent:SetAngles(Angle(0, rotation, 0))
				end
			end
			icon.OnCursorEntered = itembtn.OnCursorEntered
			icon.OnCursorExited = itembtn.OnCursorExited

			y = y + 1
		end

		local closebtn = Oprndesc:Add("DButton")
		closebtn:SetPos(dbtPaint.WidthSource(550), dbtPaint.HightSource(7))
		closebtn:SetSize(dbtPaint.WidthSource(25), dbtPaint.HightSource(25))
		closebtn:SetText('')

		closebtn.DoClick = function(self)
			self:GetParent():Close()
			hook.Remove("HUDPaint", "TakeFood")
			timer.Remove("TimerFood_NewPanel")
			timer.Remove("TakeFood")
			cooking_food = nil
		end

		surface.SetFont('Comfortaa Light X50')
		local wx, hx = surface.GetTextSize('x')

		closebtn.Paint = function(self, w, h)
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(wx*0.3, hx* -0.35)
			surface.SetFont('Comfortaa Light X50')
			surface.DrawText('x')
		end
	end
end

local function cooking_newpanel_addmenu(mainent, itembuttons, name, ispech)
	if Oprndesc_AddItemMenu then Oprndesc_AddItemMenu:Remove() Oprndesc_AddItemMenu = nil return end

	Oprndesc_AddItemMenu = vgui.Create("DFrame")

	--default settings
	Oprndesc_AddItemMenu:SetSize(dbtPaint.WidthSource(290), Oprndesc:GetTall())
	Oprndesc_AddItemMenu:SetPos(ScreenWidth*0.5 - Oprndesc:GetWide() - dbtPaint.WidthSource(5), ScreenHeight*0.5 - dbtPaint.HightSource(340))
	Oprndesc_AddItemMenu:SetTitle("")
   	Oprndesc_AddItemMenu:MakePopup()
	Oprndesc_AddItemMenu:SetDraggable(false)
	Oprndesc_AddItemMenu:ShowCloseButton(false)
	Oprndesc_AddItemMenu:SetKeyboardInputEnabled(false)

	surface.SetFont('Comfortaa Light X35')
	local textw, texth = surface.GetTextSize('Добавление')

	Oprndesc_AddItemMenu.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 196)
		surface.DrawRect(0, 0, w, h)

		surface.SetFont('Comfortaa Light X35')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w*0.5 - textw*0.5, 0)
		surface.DrawText('Добавление')
	end

	local List = vgui.Create('DScrollPanel', Oprndesc_AddItemMenu)
	List:SetSize(dbtPaint.WidthSource(290), Oprndesc:GetTall() - dbtPaint.HightSource(45))
	List:SetPos(0, dbtPaint.HightSource(45))
	local sbar = List:GetVBar()
	sbar:SetSize(0, 0)

	local y = 0
	for k, v in pairs(dbt.inventory.items) do
		local itembyid = dbt.inventory.items[k]
		if !itembyid.food and !itembyid.water then continue end

		local DButton = List:Add('DButton')
		DButton.id = v.id
		DButton:SetSize(dbtPaint.WidthSource(280), dbtPaint.HightSource(45))
		DButton:SetPos(dbtPaint.WidthSource(5), dbtPaint.HightSource(50)*y)
		DButton:SetText('')

		surface.SetFont('Comfortaa Light X25')
		local stringsizew, stringsizeh = surface.GetTextSize(itembyid.name)
		local foodsizew, foodsizeh, watersizew, watersizeh, stringfood, stringwater = 0, 0, 0, 0, false, false

		if itembyid.food and itembyid.water then
			stringfood = itembyid.food..' голода'
			stringwater = itembyid.water..' жажды'
			surface.SetFont('Comfortaa Light X22')
			foodsizew, foodsizeh = surface.GetTextSize(stringfood)
			watersizew, watersizeh = surface.GetTextSize(stringwater)
		elseif itembyid.food then
			stringfood = itembyid.food..' голода'
			surface.SetFont('Comfortaa Light X22')
			foodsizew, foodsizeh = surface.GetTextSize(stringfood)
		elseif itembyid.water then
			stringwater = itembyid.water..' жажды'
			surface.SetFont('Comfortaa Light X22')
			watersizew, watersizeh = surface.GetTextSize(stringwater)
		end

		DButton.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 120)
			surface.DrawRect(0, 0, w, h)

			surface.SetFont('Comfortaa Light X25')
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(dbtPaint.WidthSource(110) - stringsizew*0.5, stringsizeh*0.5 - 3)
			surface.DrawText(itembyid.name)

			surface.SetFont('Comfortaa Light X22')
			if stringfood and stringwater then
				surface.SetTextColor(255, 184, 130, 255)
				surface.SetTextPos(dbtPaint.WidthSource(210) - foodsizew*0.5, dbtPaint.HightSource(0))
				surface.DrawText(stringfood)

				surface.SetTextColor(129, 203, 255, 255)
				surface.SetTextPos(dbtPaint.WidthSource(210) - watersizew*0.5, foodsizeh)
				surface.DrawText(stringwater)
			elseif stringfood then
				surface.SetTextPos(dbtPaint.WidthSource(210) - foodsizew*0.5, foodsizeh*0.5)
				surface.SetTextColor(255, 184, 130, 255)
				surface.DrawText(stringfood)
			elseif stringwater then
				surface.SetTextPos(dbtPaint.WidthSource(210) - watersizew*0.5, watersizeh*0.5)
				surface.SetTextColor(129, 203, 255, 255)
				surface.DrawText(stringwater)
			end

			surface.SetDrawColor(106, 8, 122, 62)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		DButton.DoClick = function(self)
			local tabletosend = {}
			for k, v in pairs(itembuttons) do
				if !v.data then continue end

				tabletosend[#tabletosend + 1] = {id = v.data.id, current = -1, max = -1}
			end
			tabletosend[#tabletosend + 1] = {id = self.id, current = -1, max = -1}
			netstream.Start("dbt/food/entity_settings", mainent, name, tabletosend)
			Oprndesc:Remove()
			if ispech then
				pech_newpanel(name, tabletosend, true, mainent)
			else
				cooking_newpanel(name, tabletosend, true, mainent)
			end
		end

		local icon = DButton:Add( "DModelPanel" )
		icon:SetSize( dbtPaint.WidthSource(45), dbtPaint.HightSource(45) )
		if itembyid.mdl then
			icon:SetModel( itembyid.mdl )
			if IsValid(icon.Entity) then
				local mn, mx = icon.Entity:GetRenderBounds()
				local size = 0
				size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
				size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
				size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

				icon:SetFOV( 45 )
				icon:SetCamPos( Vector( size, size, size ) )
				icon:SetLookAt( (mn + mx) * 0.5 )
			end
		end

		local rotation = 0
		icon.LayoutEntity = function(self, ent) end

		y = y + 1
	end
end

function cooking_newpanel(name, items_id, iscanchange, entity)
	if Oprndesc then Oprndesc:Remove() end
	Oprndesc = vgui.Create("DFrame")
	--default settings
	local ischanging = false
	local itembuttons = {}
	local items = {}
	local menuonstart

	for k, v in pairs(items_id) do
		items[#items + 1] = dbt.inventory.items[v.id]
	end
	Oprndesc:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(690))
	Oprndesc:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(290), ScreenHeight*0.5 - dbtPaint.HightSource(345))
	Oprndesc:SetTitle("")
   	Oprndesc:MakePopup()
	Oprndesc:SetDraggable(false)
	Oprndesc:ShowCloseButton(false)

	--can voice
	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
		if Oprndesc_AddItemMenu then Oprndesc_AddItemMenu:Remove() Oprndesc_AddItemMenu = nil end
	end

	--design
	surface.SetFont('Comfortaa Light X70')
	local widthname, heightname = surface.GetTextSize(name)

	Oprndesc.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h) -- main

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(lineformenu)
		surface.DrawTexturedRect(dbtPaint.WidthSource(0), dbtPaint.HightSource(29), dbtPaint.WidthSource(lineformenumatw) + dbtPaint.WidthSource(138), dbtPaint.HightSource(lineformenumath))

		surface.SetFont('Comfortaa Light X35')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w*0.5 - widthname*0.25, heightname*0.05)
		--surface.DrawText(name)

		surface.SetFont('Comfortaa Light X27')
		surface.SetTextPos(dbtPaint.WidthSource(25), dbtPaint.HightSource(45))
		surface.DrawText('Вид')
		surface.SetTextPos(dbtPaint.WidthSource(160), dbtPaint.HightSource(45))
		surface.DrawText('Имя')
		surface.SetTextPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(45))
		surface.DrawText('Восполнение')
		surface.SetTextPos(dbtPaint.WidthSource(490), dbtPaint.HightSource(45))
		surface.DrawText('Время')
	end

	local DTextEntry = vgui.Create('DTextEntry', Oprndesc)
	DTextEntry:SetValue(name)
	DTextEntry:SetSize(dbtPaint.WidthSource(500), dbtPaint.HightSource(40))
	DTextEntry:SetPos(dbtPaint.WidthSource(40), dbtPaint.HightSource(0))

	DTextEntry.Paint = function(self, w, h)
		surface.SetFont('Comfortaa Light X35')
		widthname, heightname = surface.GetTextSize(self:GetValue())
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w*0.5 - widthname*0.5, heightname*0)
		surface.DrawText(self:GetValue())

		if ischanging then
			--surface.SetDrawColor(255, 255, 255, 255)
			--surface.DrawLine(w*0.5 - widthname*0.5, heightname - dbtPaint.HightSource(5), (w*0.5 - widthname*0.5) + widthname, heightname - dbtPaint.HightSource(5))
		end
	end

	--items btns
	local y = 0
	local List

	if items then
		List = Oprndesc:Add("DScrollPanel")
		List:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(605))
		List:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(75))
		local sbar = List:GetVBar()
		sbar:SetSize(0, 0)

		local polygon = {
			[1] = {x = dbtPaint.WidthSource(465), y = dbtPaint.HightSource(10)},
			[2] = {x = dbtPaint.WidthSource(465), y = dbtPaint.HightSource(55)},
			[5] = {x = dbtPaint.WidthSource(465), y = dbtPaint.HightSource(55)},
		}
		for k, v in pairs(items) do
			local itembtn = List:Add('DButton')
			local isneedtorotate = false
			local isneedtochange = false
			local btncolor = Color(0, 0, 0, 100)
			local fonttime = 'Comfortaa Light X30'
			itembtn:SetSize(dbtPaint.WidthSource(560), dbtPaint.HightSource(65))
			itembtn:SetPos(dbtPaint.WidthSource(10),  dbtPaint.HightSource(72)*y)
			itembtn:SetText('')
			itembtn.data = v

			surface.SetFont('Comfortaa Light X60')
			local stringsizew, stringsizeh = surface.GetTextSize(v.name)
			local foodsizew, foodsizeh, watersizew, watersizeh, stringfood, stringwater = 0, 0, 0, 0, false, false

			if v.food and v.water then
				stringfood = v.food..' голода'
				stringwater = v.water..' жажды'
				surface.SetFont('Comfortaa Light X40')
				foodsizew, foodsizeh = surface.GetTextSize(stringfood)
				watersizew, watersizeh = surface.GetTextSize(stringwater)
			elseif v.food then
				stringfood = v.food..' голода'
				surface.SetFont('Comfortaa Light X40')
				foodsizew, foodsizeh = surface.GetTextSize(stringfood)
			elseif v.water then
				stringwater = v.water..' жажды'
				surface.SetFont('Comfortaa Light X40')
				watersizew, watersizeh = surface.GetTextSize(stringwater)
			end

			itembtn.Paint = function(self, w, h)
				btncolor.a = isneedtochange and Lerp(FrameTime()*5, btncolor.a, 160) or Lerp(FrameTime()*5, btncolor.a, 120)
				surface.SetDrawColor(btncolor)
				surface.DrawRect(0, 0, w, h)

				surface.SetFont('Comfortaa Regular X30')
				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(dbtPaint.WidthSource(167) - stringsizew*0.25, dbtPaint.HightSource(27.5) - stringsizeh*0.2)
				surface.DrawText(v.name)

				surface.SetFont('Comfortaa Light X25')
				if stringfood and stringwater then
					surface.SetTextColor(255, 184, 130, 255)
					surface.SetTextPos(dbtPaint.WidthSource(340) - foodsizew*0.25, dbtPaint.HightSource(8))
					surface.DrawText(stringfood)

					surface.SetTextColor(129, 203, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(340) - watersizew*0.25, dbtPaint.HightSource(28))
					surface.DrawText(stringwater)
				elseif stringfood then
					surface.SetTextPos(dbtPaint.WidthSource(340) - foodsizew*0.25, dbtPaint.HightSource(22) - foodsizeh*0.1)
					surface.SetTextColor(255, 184, 130, 255)
					surface.DrawText(stringfood)
				elseif stringwater then
					surface.SetTextPos(dbtPaint.WidthSource(340) - watersizew*0.25, dbtPaint.HightSource(22) - watersizeh*0.1)
					surface.SetTextColor(129, 203, 255, 255)
					surface.DrawText(stringwater)
				end

				if cooking_food == v.name then
	                surface.SetDrawColor(106, 8, 122, 62)
					polygon[3] = {x = math.Clamp(dbtPaint.WidthSource(560) - dbtPaint.WidthSource(80*hpperc), 0, dbtPaint.WidthSource(550)), y = dbtPaint.HightSource(10)}
					polygon[4] = {x = math.Clamp(dbtPaint.WidthSource(550) - dbtPaint.WidthSource(80*hpperc), dbtPaint.WidthSource(470), dbtPaint.WidthSource(550)), y = dbtPaint.HightSource(55)}
					draw.NoTexture()
	                surface.DrawPoly(polygon)

					surface.SetFont('Comfortaa Light X27')
					local timestringw, timestringh = surface.GetTextSize(ischanging and 'Удалить' or tostring(food_timer)..' сек...')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(495) - timestringw*0.25, timestringh*0.25 + dbtPaint.HightSource(5))
					surface.DrawText(ischanging and 'Удалить' or tostring(food_timer)..' сек...')
					surface.SetFont('Comfortaa Light X15')
					local timestringw2, timestringh2 = surface.GetTextSize('Отмена')
					surface.SetTextPos(dbtPaint.WidthSource(498) - timestringw2*0.25, timestringh + dbtPaint.HightSource(5))
					surface.DrawText('Отмена')
	            else
					surface.SetFont(ischanging and 'Comfortaa Light X25' or fonttime)
					local timestringw, timestringh = surface.GetTextSize(ischanging and 'Удалить' or tostring(v.time)..' сек')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(492.5) - (ischanging and timestringw*0.27 or timestringw*0.25), (ischanging and timestringh*0.5 or timestringh*0.35) + dbtPaint.HightSource(5))
					surface.DrawText(ischanging and 'Удалить' or tostring(v.time)..' сек')
				end

				surface.SetDrawColor(106, 8, 122, 62)
				surface.DrawOutlinedRect(dbtPaint.WidthSource(465), dbtPaint.HightSource(10), dbtPaint.WidthSource(85), dbtPaint.HightSource(45), 1)
				surface.SetDrawColor(106, 8, 122, 62)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			itembtn.OnCursorEntered = function(self)
				isneedtorotate = true
				isneedtochange = true
			end
			itembtn.OnCursorExited = function(self)
				isneedtorotate = false
				isneedtochange = false
			end

			itembtn.DoClick = function(self)
				if ischanging then
					y = 0
					for k, v in pairs(itembuttons) do
						if v == self then itembuttons[k] = nil continue end
						v:SetPos(dbtPaint.WidthSource(10),   dbtPaint.HightSource(62)*y)
						y = y + 1
					end

					self:Remove()
					return
				end
				start_pick(v.time, v)
			end

			itembuttons[#itembuttons + 1] = itembtn

			local icon = itembtn:Add( "DModelPanel" )
	        icon:SetSize( dbtPaint.WidthSource(50), dbtPaint.HightSource(50) )
			icon:SetPos( dbtPaint.WidthSource(2), dbtPaint.HightSource(7) )
	        if v.mdl then
				icon:SetModel( v.mdl )
				if IsValid(icon.Entity) then
					local mn, mx = icon.Entity:GetRenderBounds()
					local size = 0
					size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
					size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
					size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

					icon:SetFOV( 45 )
					icon:SetCamPos( Vector( size, size, size ) )
					icon:SetLookAt( (mn + mx) * 0.5 )
				end
	        end

			local rotation = 0
			icon.LayoutEntity = function(self, ent)
				if isneedtorotate then
					rotation = rotation + 0.25
					ent:SetAngles(Angle(0, rotation, 0))
				end
			end
			icon.OnCursorEntered = itembtn.OnCursorEntered
			icon.OnCursorExited = itembtn.OnCursorExited

			y = y + 1
		end
	end

	-- admin-change
	if iscanchange then
		if LocalPlayer():IsAdmin() then
			Oprndesc:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(710))
			local changebtn = Oprndesc:Add("DButton")
			local isneedtochange = false
			changebtn:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(30))
			changebtn:SetPos(0, dbtPaint.HightSource(680))
			changebtn:SetFont('Comfortaa Regular X25')
			changebtn:SetTextColor(Color(255, 255, 255, 255))
			changebtn:SetText('Редактировать')

			changebtn.Paint = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 0)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(160, 33, 183, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			changebtn.DoClick = function(self)
				-- Add Food Button
				local addbtn = List:Add("DButton")
				menuonstart = itembuttons
				DTextEntry:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(250), ScreenHeight*0.5 - dbtPaint.HightSource(345))
				DTextEntry:MakePopup()
				DTextEntry.Think = function(self) self:MoveToFront() end

				ischanging = true

				addbtn:SetSize(dbtPaint.WidthSource(560), dbtPaint.HightSource(65))
				addbtn:SetPos(dbtPaint.WidthSource(10), dbtPaint.HightSource(72)*y)
				addbtn:SetFont('_Comfortaa Regular X16')
				addbtn:SetTextColor(Color(255, 255, 255, 255))
				addbtn:SetText("")
				addbtn.text = "Добавить"

				addbtn.Paint = function(self, w, h)
				--MatAdd
					surface.SetDrawColor(0, 0, 0, 120)
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(106, 8, 122, 62)
					surface.DrawOutlinedRect(0, 0, w, h, 1)
					dbtPaint.DrawRectR(MatAdd, w * 0.4, h / 2, dbtPaint.WidthSource(25), dbtPaint.HightSource(25), 0)
					draw.SimpleText(self.text, "_Comfortaa Regular X18", w / 2 + dbtPaint.WidthSource(20), h * 0.23, color_white, TEXT_ALIGN_CENTER)
				end

				addbtn.OnCursorEntered = function()
					isneedtochange = true
				end

				addbtn.OnCursorExited = function()
					isneedtochange = false
				end

				addbtn.DoClick = function(self)
					self.text = self.text == 'Добавить' and 'Отмена' or 'Добавить'

					cooking_newpanel_addmenu(entity, itembuttons, name)
				end

				local DPanel = vgui.Create('DPanel')
				DPanel:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(35))
				DPanel:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(290), ScreenHeight*0.5 - dbtPaint.HightSource(345) - dbtPaint.HightSource(35))
				Oprndesc.OnRemove = function()
					netstream.Start("dbt.cookingdisablemove", LocalPlayer())
					if Oprndesc_AddItemMenu then Oprndesc_AddItemMenu:Remove() Oprndesc_AddItemMenu = nil end
					DPanel:Remove()
				end
				surface.SetFont('Comfortaa Regular X25')
				local width1, height1 = surface.GetTextSize('Режим редактирования')
				DPanel.Paint = function(self, w, h)
					surface.SetDrawColor(85, 8, 122, 140)
					surface.DrawRect(0, 0, w, h)

					surface.SetFont('Comfortaa Regular X25')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(w*0.5 - width1*0.5 + dbtPaint.WidthSource(3), h*0.1)
					surface.DrawText('Режим редактирования')
				end
				--Oprndesc:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(690))
				--Oprndesc:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(290), ScreenHeight*0.5 - dbtPaint.HightSource(345))

				itembuttons[#itembuttons + 1] = addbtn

				hook.Remove("HUDPaint", "TakeFood")
				timer.Remove("TimerFood_NewPanel")
				timer.Remove("TakeFood")
				cooking_food = nil

				-- New buttons(Save, Default, Cancel)
				self:Remove()
				local buttonchange_save = Oprndesc:Add("DButton")
				buttonchange_save:SetFont('Comfortaa Regular X25')
				buttonchange_save:SetTextColor(Color(255, 255, 255, 255))
				buttonchange_save:SetText('Сохранить')
				buttonchange_save:SetSize(dbtPaint.WidthSource(194), dbtPaint.HightSource(30))
				buttonchange_save:SetPos(0, dbtPaint.HightSource(680))

				local buttonchange_default = Oprndesc:Add("DButton")
				buttonchange_default:SetFont('Comfortaa Regular X25')
				buttonchange_default:SetTextColor(Color(255, 255, 255, 255))
				buttonchange_default:SetText('По умолчанию')
				buttonchange_default:SetSize(dbtPaint.WidthSource(194), dbtPaint.HightSource(30))
				buttonchange_default:SetPos(dbtPaint.WidthSource(194), dbtPaint.HightSource(680))

				local buttonchange_cancel = Oprndesc:Add("DButton")
				buttonchange_cancel:SetFont('Comfortaa Regular X25')
				buttonchange_cancel:SetTextColor(Color(255, 255, 255, 255))
				buttonchange_cancel:SetText('Отменить')
				buttonchange_cancel:SetSize(dbtPaint.WidthSource(194), dbtPaint.HightSource(30))
				buttonchange_cancel:SetPos(dbtPaint.WidthSource(386), dbtPaint.HightSource(680))

				buttonchange_cancel.Paint = function(self, w, h)
					surface.SetDrawColor(0, 0, 0, 0)
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(160, 33, 183, 255)
					surface.DrawOutlinedRect(0, 0, w, h, 1)
				end

				buttonchange_save.Paint = buttonchange_cancel.Paint
				buttonchange_default.Paint = buttonchange_cancel.Paint

				buttonchange_default.DoClick = function(self)
					Oprndesc:Remove()
					if entity:GetClass() == 'folige' then
						netstream.Start("dbt/food/entity_settings", entity, 'ХОЛОДИЛЬНИК', default_setting_folig)
						cooking_newpanel('ХОЛОДИЛЬНИК', default_setting_folig, iscanchange, entity)
					elseif entity:GetClass() == 'polka' then
						netstream.Start("dbt/food/entity_settings", entity, 'ПОЛКА С ЕДОЙ', default_setting_polka)
						cooking_newpanel('ПОЛКА С ЕДОЙ', default_setting_polka, iscanchange, entity)
					elseif entity:GetClass() == 'teapot' then
						netstream.Start("dbt/food/entity_settings", entity, 'ЧАЙНИК', default_setting_teapot)
						cooking_newpanel('ЧАЙНИК', default_setting_teapot, iscanchange, entity)
					end
				end
				buttonchange_save.DoClick = function(self)
					local tabletosend = {}
					for k, v in pairs(itembuttons) do
						if !v.data then continue end

						tabletosend[#tabletosend + 1] = {id = v.data.id, current = -1, max = -1}
					end
					netstream.Start("dbt/food/entity_settings", entity, DTextEntry:GetValue(), tabletosend)
					Oprndesc:Remove()
					cooking_newpanel(DTextEntry:GetValue(), tabletosend, iscanchange, entity)
				end
				buttonchange_cancel.DoClick = function(self)
					Oprndesc:Remove()
					cooking_newpanel(name, items_id, iscanchange, entity)
				end
			end
		end
	end

	--close btn
	local closebtn = Oprndesc:Add("DButton")
	closebtn:SetPos(dbtPaint.WidthSource(550), dbtPaint.HightSource(7))
	closebtn:SetSize(dbtPaint.WidthSource(25), dbtPaint.HightSource(25))
	closebtn:SetText('')

	closebtn.DoClick = function(self)
		self:GetParent():Close()
		hook.Remove("HUDPaint", "TakeFood")
		timer.Remove("TimerFood_NewPanel")
		timer.Remove("TakeFood")
		cooking_food = nil
	end

	surface.SetFont('Comfortaa Light X50')
	local wx, hx = surface.GetTextSize('x')

	closebtn.Paint = function(self, w, h)
		dbtPaint.DrawRectR(MatCLose, w / 2, h / 2, w * 0.6, h * 0.6, 0)
	end
end

netstream.Hook("dbt/food/activate_foodpanel_editing", function(name, items_id, entity)
	name = name or '???'
	cooking_newpanel(name , items_id, true, entity)
end)

function pech_newpanel(name, items_id, iscanchange, entity)
	if Oprndesc then Oprndesc:Remove() end
	Oprndesc = vgui.Create("DFrame")
	--default settings
	local ischanging = false
	local itembuttons = {}
	local items = {}
	local menuonstart

	for k, v in pairs(items_id) do
		items[#items + 1] = dbt.inventory.items[v.id]
	end
	Oprndesc:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(680))
	Oprndesc:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(290), ScreenHeight*0.5 - dbtPaint.HightSource(340))
	Oprndesc:SetTitle("")
   	Oprndesc:MakePopup()
	Oprndesc:SetDraggable(false)
	Oprndesc:ShowCloseButton(false)

	--can voice
	netstream.Start("dbt.cookingdisablemove", LocalPlayer())
	Oprndesc:SetKeyboardInputEnabled(false)

	Oprndesc.OnRemove = function(self)
		netstream.Start("dbt.cookingdisablemove", LocalPlayer())
		if Oprndesc_AddItemMenu then Oprndesc_AddItemMenu:Remove() Oprndesc_AddItemMenu = nil end
	end

	--design
	surface.SetFont('Comfortaa Light X70')
	local widthname, heightname = surface.GetTextSize(name)
	local textwhave, texthhave = surface.GetTextSize(entity:GetNWInt('Cock_amout')..'/10')

	Oprndesc.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h) -- main

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(lineformenu)
		surface.DrawTexturedRect(dbtPaint.WidthSource(0), dbtPaint.HightSource(33), dbtPaint.WidthSource(lineformenumatw) + dbtPaint.WidthSource(138), dbtPaint.HightSource(lineformenumath))

		surface.SetFont('Comfortaa Light X35')
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w*0.5 - widthname*0.25, heightname*0.05)
		--surface.DrawText(name)

		surface.SetFont('Comfortaa Light X27')
		surface.SetTextPos(dbtPaint.WidthSource(25), dbtPaint.HightSource(45))
		surface.DrawText('Вид')
		surface.SetTextPos(dbtPaint.WidthSource(160), dbtPaint.HightSource(45))
		surface.DrawText('Имя')
		surface.SetTextPos(dbtPaint.WidthSource(300), dbtPaint.HightSource(45))
		surface.DrawText('Восполнение')
		surface.SetTextPos(dbtPaint.WidthSource(490), dbtPaint.HightSource(45))
		surface.DrawText('Время')

		surface.SetDrawColor(183, 75, 215, 30)
		surface.DrawRect(0, dbtPaint.HightSource(630), dbtPaint.WidthSource(580), dbtPaint.HightSource(50))
		surface.SetFont('Comfortaa Light X40')
		textwhave, texthhave = surface.GetTextSize(entity:GetNWInt('Cock_amout')..'/10')
		surface.DrawMulticolorText(dbtPaint.WidthSource(290) - textwhave*0.5, dbtPaint.HightSource(633), 'Comfortaa Light X40', {Color(213, 27, 255, 255), tostring(entity:GetNWInt('Cock_amout')), color_white, '/10'})
	end

	local icon = vgui.Create('DModelPanel', Oprndesc)
	icon:SetSize( dbtPaint.WidthSource(50), dbtPaint.HightSource(50) )
	icon:SetPos( dbtPaint.WidthSource(290) - textwhave, dbtPaint.HightSource(628) )
	icon:SetModel( 'models/props_junk/garbage_bag001a.mdl' )
	if IsValid(icon.Entity) then
		local mn, mx = icon.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
		size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
		size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

		icon:SetFOV( 45 )
		icon:SetCamPos( Vector( size, size, size ) )
		icon:SetLookAt( (mn + mx) * 0.5 )
	end

	icon.LayoutEntity = function(self, ent)	end

	local DTextEntry = vgui.Create('DTextEntry', Oprndesc)
	DTextEntry:SetValue(name)
	DTextEntry:SetSize(dbtPaint.WidthSource(500), dbtPaint.HightSource(40))
	DTextEntry:SetPos(dbtPaint.WidthSource(40), dbtPaint.HightSource(2))

	DTextEntry.Paint = function(self, w, h)
		surface.SetFont('Comfortaa Light X35')
		widthname, heightname = surface.GetTextSize(self:GetValue())
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w*0.5 - widthname*0.5, heightname*0)
		surface.DrawText(self:GetValue())

		if ischanging then
			--surface.SetDrawColor(255, 255, 255, 255)
			--surface.DrawLine(w*0.5 - widthname*0.5, heightname - dbtPaint.HightSource(5), (w*0.5 - widthname*0.5) + widthname, heightname - dbtPaint.HightSource(5))
		end
	end

	--items btns
	local y = 0
	local List

	if items then
		List = Oprndesc:Add("DScrollPanel")
		List:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(555))
		List:SetPos(dbtPaint.WidthSource(0), dbtPaint.HightSource(75))
		local sbar = List:GetVBar()
		sbar:SetSize(0, 0)

		local polygon = {
			[1] = {x = dbtPaint.WidthSource(470), y = dbtPaint.HightSource(5)},
			[2] = {x = dbtPaint.WidthSource(470), y = dbtPaint.HightSource(50)},
			[5] = {x = dbtPaint.WidthSource(470), y = dbtPaint.HightSource(50)},
		}
		for k, v in pairs(items) do
			local itembtn = List:Add('DButton')
			local isneedtorotate = false
			local isneedtochange = false
			local cost = v.cost or 1
			local btncolor = Color(0, 0, 0, 100)
			local fonttime = 'Comfortaa Light X35'
			itembtn:SetSize(dbtPaint.WidthSource(560), dbtPaint.HightSource(75))
			itembtn:SetPos(dbtPaint.WidthSource(10), dbtPaint.HightSource(82)*y)
			itembtn:SetText('')
			itembtn.data = v

			surface.SetFont('Comfortaa Light X60')
			local stringsizew, stringsizeh = surface.GetTextSize(v.name)
			local foodsizew, foodsizeh, watersizew, watersizeh, stringfood, stringwater = 0, 0, 0, 0, false, false

			if v.food and v.water then
				stringfood = v.food..' голода'
				stringwater = v.water..' жажды'
				surface.SetFont('Comfortaa Light X40')
				foodsizew, foodsizeh = surface.GetTextSize(stringfood)
				watersizew, watersizeh = surface.GetTextSize(stringwater)
			elseif v.food then
				stringfood = v.food..' голода'
				surface.SetFont('Comfortaa Light X40')
				foodsizew, foodsizeh = surface.GetTextSize(stringfood)
			elseif v.water then
				stringwater = v.water..' жажды'
				surface.SetFont('Comfortaa Light X40')
				watersizew, watersizeh = surface.GetTextSize(stringwater)
			end

			surface.SetFont('Comfortaa Light X25')
			local costsizew, costsizeh = surface.GetTextSize('Цена: '..cost)

			itembtn.Paint = function(self, w, h)
				btncolor.a = isneedtochange and Lerp(FrameTime()*5, btncolor.a, 190) or Lerp(FrameTime()*5, btncolor.a, 120)
				surface.SetDrawColor(btncolor)
				surface.DrawRect(0, 0, w, h)

				surface.SetFont('Comfortaa Light X30')
				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(dbtPaint.WidthSource(167) - stringsizew*0.25, dbtPaint.HightSource(22.5) - stringsizeh*0.2)
				surface.DrawText(v.name)

				surface.SetFont('Comfortaa Light X25')
				if stringfood and stringwater then
					surface.SetTextColor(255, 184, 130, 255)
					surface.SetTextPos(dbtPaint.WidthSource(340) - foodsizew*0.25, dbtPaint.HightSource(3))
					surface.DrawText(stringfood)

					surface.SetTextColor(129, 203, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(340) - watersizew*0.25, dbtPaint.HightSource(23))
					surface.DrawText(stringwater)
				elseif stringfood then
					surface.SetTextPos(dbtPaint.WidthSource(340) - foodsizew*0.25, dbtPaint.HightSource(17) - foodsizeh*0.1)
					surface.SetTextColor(255, 184, 130, 255)
					surface.DrawText(stringfood)
				elseif stringwater then
					surface.SetTextPos(dbtPaint.WidthSource(340) - watersizew*0.25, dbtPaint.HightSource(17) - watersizeh*0.1)
					surface.SetTextColor(129, 203, 255, 255)
					surface.DrawText(stringwater)
				end

				if cooking_food == v.name then
	                surface.SetDrawColor(106, 8, 122, 62)
					polygon[3] = {x = math.Clamp(dbtPaint.WidthSource(560) - dbtPaint.WidthSource(80*hpperc), 0, dbtPaint.WidthSource(550)), y = dbtPaint.HightSource(5)}
					polygon[4] = {x = math.Clamp(dbtPaint.WidthSource(550) - dbtPaint.WidthSource(80*hpperc), dbtPaint.WidthSource(470), dbtPaint.WidthSource(550)), y = dbtPaint.HightSource(50)}
					draw.NoTexture()
	                surface.DrawPoly(polygon)

					surface.SetFont('Comfortaa Light X27')
					local timestringw, timestringh = surface.GetTextSize(ischanging and 'Удалить' or tostring(food_timer)..' сек...')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(495) - timestringw*0.25, timestringh*0.25)
					surface.DrawText(ischanging and 'Удалить' or tostring(food_timer)..' сек...')
					surface.SetFont('Comfortaa Light X15')
					local timestringw2, timestringh2 = surface.GetTextSize('Отмена')
					surface.SetTextPos(dbtPaint.WidthSource(498) - timestringw2*0.25, timestringh)
					surface.DrawText('Отмена')
	            else
					surface.SetFont(ischanging and 'Comfortaa Light X25' or fonttime)
					local timestringw, timestringh = surface.GetTextSize(ischanging and 'Удалить' or tostring(v.time)..' сек')
					surface.SetTextColor(255, 255, 255, 255)
					surface.SetTextPos(dbtPaint.WidthSource(495) - (ischanging and timestringw*0.27 or timestringw*0.25), (ischanging and timestringh*0.5 or timestringh*0.25))
					surface.DrawText(ischanging and 'Удалить' or tostring(v.time)..' сек')
				end

				surface.SetDrawColor(183, 75, 215, 30)
				surface.DrawRect(0, h - sizebyheight(20), w, sizebyheight(20))

				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(dbtPaint.WidthSource(280) - costsizew*0.5, dbtPaint.HightSource(50))
				surface.SetFont('Comfortaa Light X25')
				surface.DrawText('Цена: '..cost)

				surface.SetDrawColor(106, 8, 122, 62)
				surface.DrawOutlinedRect(dbtPaint.WidthSource(470), dbtPaint.HightSource(5), dbtPaint.WidthSource(80), dbtPaint.HightSource(45), 1)
				surface.SetDrawColor(106, 8, 122, 62)
				surface.DrawOutlinedRect(0, 0, w, h - sizebyheight(20), 1)
			end

			itembtn.OnCursorEntered = function(self)
				isneedtorotate = true
				isneedtochange = true
			end
			itembtn.OnCursorExited = function(self)
				isneedtorotate = false
				isneedtochange = false
			end

			itembtn.DoClick = function(self)
				if ischanging then
					y = 0
					for k, v in pairs(itembuttons) do
						if v == self then itembuttons[k] = nil continue end
						v:SetPos(dbtPaint.WidthSource(10), dbtPaint.HightSource(86)*y)
						y = y + 1
					end

					self:Remove()
					return
				end
				start_pick_pech(v.time, v, entity)
			end

			itembuttons[#itembuttons + 1] = itembtn

			local icon = itembtn:Add( "DModelPanel" )
	        icon:SetSize( dbtPaint.WidthSource(50), dbtPaint.HightSource(50) )
			icon:SetPos( dbtPaint.WidthSource(2), dbtPaint.HightSource(2) )
	        if v.mdl then
				icon:SetModel( v.mdl )
				if IsValid(icon.Entity) then
					local mn, mx = icon.Entity:GetRenderBounds()
					local size = 0
					size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
					size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
					size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

					icon:SetFOV( 45 )
					icon:SetCamPos( Vector( size, size, size ) )
					icon:SetLookAt( (mn + mx) * 0.5 )
				end
	        end

			local rotation = 0
			icon.LayoutEntity = function(self, ent)
				if isneedtorotate then
					rotation = rotation + 0.25
					ent:SetAngles(Angle(0, rotation, 0))
				end
			end
			icon.OnCursorEntered = itembtn.OnCursorEntered
			icon.OnCursorExited = itembtn.OnCursorExited

			y = y + 1
		end
	end

	-- admin-change
	if iscanchange then
		if LocalPlayer():IsAdmin() then
			Oprndesc:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(710))
			local changebtn = Oprndesc:Add("DButton")
			local isneedtochange = false
			changebtn:SetSize(dbtPaint.WidthSource(580), dbtPaint.HightSource(30))
			changebtn:SetPos(0, dbtPaint.HightSource(680))
			changebtn:SetFont('Comfortaa Light X25')
			changebtn:SetTextColor(Color(255, 255, 255, 255))
			changebtn:SetText('Редактировать')

			changebtn.Paint = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 0)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(160, 33, 183, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end

			changebtn.DoClick = function(self)
				-- Add Food Button
				local addbtn = List:Add("DButton")
				menuonstart = itembuttons
				DTextEntry:SetPos(ScreenWidth*0.5 - dbtPaint.WidthSource(250), ScreenHeight*0.5 - dbtPaint.HightSource(338))
				DTextEntry:MakePopup()
				DTextEntry.Think = function(self) self:MoveToFront() end

				ischanging = true

				addbtn:SetSize(dbtPaint.WidthSource(560), dbtPaint.HightSource(50))
				addbtn:SetPos(dbtPaint.WidthSource(10), dbtPaint.HightSource(86)*y)
				addbtn:SetFont('Comfortaa Light X35')
				addbtn:SetTextColor(Color(255, 255, 255, 255))
				addbtn:SetText('')
				addbtn.text = "Добавить"
				addbtn.Paint = function(self, w, h)
					surface.SetDrawColor(0, 0, 0, 120)
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(106, 8, 122, 62)
					surface.DrawOutlinedRect(0, 0, w, h, 1)


					dbtPaint.DrawRectR(MatAdd, w * 0.4, h / 2, dbtPaint.WidthSource(25), dbtPaint.HightSource(25), 0)
					draw.SimpleText(self.text, "_Comfortaa Regular X18", w / 2 + dbtPaint.WidthSource(20), h * 0.23, color_white, TEXT_ALIGN_CENTER)

				end

				addbtn.OnCursorEntered = function()
					isneedtochange = true
				end

				addbtn.OnCursorExited = function()
					isneedtochange = false
				end

				addbtn.DoClick = function(self)
					self.text = self.text == 'Добавить' and 'Отмена' or 'Добавить'

					cooking_newpanel_addmenu(entity, itembuttons, name, true)
				end

				itembuttons[#itembuttons + 1] = addbtn

				hook.Remove("HUDPaint", "TakeFood")
				timer.Remove("TimerFood_NewPanel")
				timer.Remove("TakeFood")
				cooking_food = nil

				-- New buttons(Save, Default, Cancel)
				self:Remove()
				local buttonchange_save = Oprndesc:Add("DButton")
				buttonchange_save:SetFont('Comfortaa Light X25')
				buttonchange_save:SetTextColor(Color(255, 255, 255, 255))
				buttonchange_save:SetText('Сохранить')
				buttonchange_save:SetSize(dbtPaint.WidthSource(194), dbtPaint.HightSource(30))
				buttonchange_save:SetPos(0, dbtPaint.HightSource(680))

				local buttonchange_default = Oprndesc:Add("DButton")
				buttonchange_default:SetFont('Comfortaa Light X25')
				buttonchange_default:SetTextColor(Color(255, 255, 255, 255))
				buttonchange_default:SetText('По умолчанию')
				buttonchange_default:SetSize(dbtPaint.WidthSource(194), dbtPaint.HightSource(30))
				buttonchange_default:SetPos(dbtPaint.WidthSource(194), dbtPaint.HightSource(680))

				local buttonchange_cancel = Oprndesc:Add("DButton")
				buttonchange_cancel:SetFont('Comfortaa Light X25')
				buttonchange_cancel:SetTextColor(Color(255, 255, 255, 255))
				buttonchange_cancel:SetText('Отменить')
				buttonchange_cancel:SetSize(dbtPaint.WidthSource(194), dbtPaint.HightSource(30))
				buttonchange_cancel:SetPos(dbtPaint.WidthSource(386), dbtPaint.HightSource(680))

				buttonchange_cancel.Paint = function(self, w, h)
					surface.SetDrawColor(0, 0, 0, 0)
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(160, 33, 183, 255)
					surface.DrawOutlinedRect(0, 0, w, h, 1)
				end

				buttonchange_save.Paint = buttonchange_cancel.Paint
				buttonchange_default.Paint = buttonchange_cancel.Paint

				buttonchange_default.DoClick = function(self)
					Oprndesc:Remove()
					pech_newpanel('КУХОННАЯ ПЛИТА', default_setting_pech, iscanchange, entity)
				end
				buttonchange_save.DoClick = function(self)
					local tabletosend = {}
					for k, v in pairs(itembuttons) do
						if !v.data then continue end

						tabletosend[#tabletosend + 1] = {id = v.data.id, current = -1, max = -1}
					end
					netstream.Start("dbt/food/entity_settings", entity, DTextEntry:GetValue(), tabletosend)
					Oprndesc:Remove()
					pech_newpanel(DTextEntry:GetValue(), tabletosend, iscanchange, entity)
				end
				buttonchange_cancel.DoClick = function(self)
					Oprndesc:Remove()
					pech_newpanel(name, items_id, iscanchange, entity)
				end
			end
		end
	end

	--close btn
	local closebtn = Oprndesc:Add("DButton")
	closebtn:SetPos(dbtPaint.WidthSource(550), dbtPaint.HightSource(7))
	closebtn:SetSize(dbtPaint.WidthSource(25), dbtPaint.HightSource(25))
	closebtn:SetText('')

	closebtn.DoClick = function(self)
		self:GetParent():Close()
		hook.Remove("HUDPaint", "TakeFood")
		timer.Remove("TimerFood_NewPanel")
		timer.Remove("TakeFood")
		cooking_food = nil
	end

	surface.SetFont('Comfortaa Light X50')
	local wx, hx = surface.GetTextSize('x')

	closebtn.Paint = function(self, w, h)
		dbtPaint.DrawRectR(MatCLose, w / 2, h / 2, w * 0.6, h * 0.6, 0)
	end
end
