dbt.inventory = dbt.inventory or {}
dbt.inventory.items = {}
dbt.inventory.AMMO_PACK_SIZE = dbt.inventory.AMMO_PACK_SIZE or 12
dbt.inventory.ammoItems = {}
dbt.inventory.ammoTypes = {}

local function isTFAWeapon(weaponData)
    if not weaponData then return false end
    local class = weaponData.ClassName or ""
    local base = weaponData.Base or ""
    return string.StartWith(string.lower(class), "tfa_") or string.find(string.lower(base), "tfa", 1, true)
end

local function formatAmmoDisplayName(ammoName)
    if not isstring(ammoName) or ammoName == "" then return "Неизвестный боезапас" end
    return string.format("Патроны (%s)", string.upper(ammoName))
end

function dbt.inventory.RegisterAmmoItem(ammoName)
    if not isstring(ammoName) or ammoName == "" then return nil end
    if dbt.inventory.ammoItems[ammoName] then return dbt.inventory.ammoItems[ammoName] end
    local displayName = formatAmmoDisplayName(ammoName)
    local itemId = #dbt.inventory.items + 1

    dbt.inventory.items[itemId] = {
        name = displayName,
        ammo = true,
        ammoType = ammoName,
        mdl = "models/items/boxsrounds.mdl",
        icon = Material("icons/159.png"),
        kg = 0.25,
        notEditable = true,
        OnUse = function(ply, data, meta, c_data)
            ply:GiveAmmo(12, ammoName, true)
            return meta
        end,
        GetDescription = function(self)
            local text = {}
            text[#text+1] = color_white
            text[#text+1] = string.format("Пачка содержит %d патронов типа %s.", dbt.inventory.AMMO_PACK_SIZE, ammoName)
            return text
        end,
    }

    dbt.inventory.ammoItems[ammoName] = itemId
    dbt.inventory.ammoTypes[itemId] = ammoName

    return itemId
end



dbt.inventory.items[1] = {
	name = "Монопад",
	monopad = true,
	icon = Material("icons/77.png"),
	mdl = "models/dbt/ahesam/monopad.mdl",
    angle = Angle(-20,45,0),
    notEditable = true,
    descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Открывается на C"},
    OverPaint = function(self, x, y)
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

		dbtPaint.StartStencil()
			surface.SetDrawColor( 255,255,255,255)
			surface.SetMaterial( mat_circile )
			surface.DrawTexturedRect( x * 0.7, x * 0.7, x * 0.3, x * 0.3 )
		--char_ico_1
		dbtPaint.ApllyStencil()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material("dbt/characters"..dbt.chr[self.meta.owner].season.."/char"..dbt.chr[self.meta.owner].char.."/char_ico_1.png", "smooth") )
			surface.DrawTexturedRect( x * 0.7, x * 0.7, x * 0.3, x * 0.3 )
		render.SetStencilEnable( false )
        /*surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material("dbt/characters"..dbt.chr[self.meta.owner].season.."/char"..dbt.chr[self.meta.owner].char.."/icon_chat_monopad.png", "smooth mips") )
        surface.DrawTexturedRect( x * 0.6, x * 0.6, x * 0.4, x * 0.4)*/
    end,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Владелец монопада: "..self.meta.owner
        return text
    end
}

dbt.inventory.items[2] = {
	name = "Ключи",
	keys = true,
    notEditable = true,
    mdl = "models/scp860key/scp860key.mdl",
    fov = 15,
    kg = 0.1,
    angle = Angle(45,0,0),
    descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Открыть/закрыть вашу дверь на ПКМ с пустыми руками."},
	icon = Material("icons/75.png"),
    OverPaint = function(self, x, y)
        if !self.meta or !self.meta.owner or !dbt.chr[self.meta.owner] then return end
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
		dbtPaint.StartStencil()
			surface.SetDrawColor( 255,255,255,255)
			surface.SetMaterial( mat_circile )
			surface.DrawTexturedRect( x * 0.7, x * 0.7, x * 0.3, x * 0.3 )
		--char_ico_1
		dbtPaint.ApllyStencil()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material("dbt/characters"..dbt.chr[self.meta.owner].season.."/char"..dbt.chr[self.meta.owner].char.."/char_ico_1.png", "smooth") )
			surface.DrawTexturedRect( x * 0.7, x * 0.7, x * 0.3, x * 0.3 )
		render.SetStencilEnable( false )
        /*surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material("dbt/characters"..dbt.chr[self.meta.owner].season.."/char"..dbt.chr[self.meta.owner].char.."/icon_chat_monopad.png", "smooth mips") )
        surface.DrawTexturedRect( x * 0.6, x * 0.6, x * 0.4, x * 0.4)*/
    end,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Владелец ключей: "..self.meta.owner
        return text
    end
}

dbt.inventory.items[5] = {
	name = "Пирог",
	mdl = "models/props_everything/applepie.mdl",
	icon = Material("icons/food_pie2.png", "smooth"),
	food = 60,
	time = 15,
	id = 5,
    kg = 1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "фывфыфывфыв"
        return text
    end
}

dbt.inventory.items[6] = {
	name = "Торт",
	mdl = "models/props_everything/cake.mdl",
	icon = Material("icons/food_cake.png", "smooth"),
	food = 85,
    cost = 4,
	time = 20,
	id = 6,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Так и ждёт, чтобы его бросили в чьё-то лицо."
        return text
      end
}

dbt.inventory.items[7] = {
	name = "Сыр",
	mdl = "models/props_everything/cheeseswiss.mdl",
	icon = Material("icons/food_cheese.png", "smooth"),
	food = 15,
	time = 5,
	id = 7,
    kg = 0.3,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Жёлтый, вкусный и дырявый."
        return text
      end
}

dbt.inventory.items[8] = {
	name = "Помидор",
	mdl = "models/props_everything/tomato.mdl",
	icon = Material("icons/food_tomato.png", "smooth"),
	food = 15,
	time = 5,
	id = 8,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Так и ждёт, чтобы его бросили в чьё-то лицо."
        return text
      end
}

dbt.inventory.items[9] = {
	name = "Арбуз",
	mdl = "models/props_everything/watermelonslice.mdl",
	icon = Material("icons/food_watermelon.png", "smooth"),
	food = 15,
	water = 7,
	time = 8,
	id = 9,
    kg = 0.3,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Большой, спелый, сладкий, так бы и разбил его о чью-либо голову. «Купил Арбуз»"
        return text
      end
}

dbt.inventory.items[10] = {
    name = "Коктейль",
    mdl = "models/props_everything/cocktail.mdl",
    icon = Material("icons/drink_cocktail.png", "smooth"),
    water = 35,
    time = 4,
    id = 10,
    kg = 0.3,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Сладкий и со вкусом фруктов, а лёд никогда не растает."
        return text
      end
}

dbt.inventory.items[11] = {
    name = "Газировка",
    mdl = "models/props_everything/cansoda.mdl",
    icon = Material("icons/drink_energy.png", "smooth"),
    water = 20,
    time = 4,
    id = 11,
    kg = 0.5,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Как вода, но с крутым эффектом."
        return text
      end
}

dbt.inventory.items[12] = {
    name = "Вода",
    mdl = "models/props_everything/waterbottle.mdl",
    icon = Material("icons/drink_water.png", "smooth"),
    water = 50,
    time = 4,
    id = 12,
    kg = 0.6,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Сегодня - вода. Завтра - весь мир!"
        return text
      end
}

dbt.inventory.items[13] = {
    name = "Кофе",
    mdl = "models/props_everything/coffee.mdl",
    icon = Material("icons/drink_hot_chocolate.png", "smooth"),
    water = 25,
    time = 12,
    id = 13,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Так и ждёт, чтобы его бросили в чьё-то лицо."
        return text
      end
}

dbt.inventory.items[14] = {
    name = "Молоко",
    mdl = "models/props_everything/milk.mdl",
    icon = Material("icons/drink_milk.png", "smooth"),
    water = 45,
    time = 4,
    id = 14,
    kg = 1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Лактозники смотрят на него с опаской и обходят стороной."
        return text
      end
}

dbt.inventory.items[15] = {
    name = "Панта",
    mdl = "models/player/dewobedil/danganronpa/monokubs/props/panta.mdl",
    icon = Material("icons/panta.png", "smooth"),
    water = 40,
    time = 10,
    id = 15,
    kg = 0.5,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Подвид газировки, которую так любят в тайных организациях!"
        return text
      end
}

dbt.inventory.items[16] = {
    name = "Вино",
    mdl = "models/props_everything/winebottle.mdl",
    icon = Material("icons/drink_bottle.png", "smooth"),
    water = 30,
    time = 25,
    id = 16,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Так и ждёт, чтобы его бросили в чьё-то лицо."
        return text
      end
}

dbt.inventory.items[17] = {
    name = "Яблоко",
    mdl = "models/props_everything/applered.mdl",
    icon = Material("icons/food_apple.png", "smooth"),
    food = 5,
    time = 5,
    id = 17,
    kg = 0.3,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Разносторонний фрукт, любим как в «сыром» виде, так и в готовом."
        return text
      end
}
dbt.inventory.items[18] = {
    name = "Печенье",
    mdl = "models/props_everything/cookie.mdl",
    icon = Material("icons/food_cookie.png", "smooth"),
    food = 5,
    time = 5,
    id = 18,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Хвать тебя за ушко! Это печенюшка."
        return text
      end
}
dbt.inventory.items[19] = {
    name = "Кукуруза",
    mdl = "models/props_everything/corn.mdl",
    icon = Material("icons/food_corn.png", "smooth"),
    food = 10,
    time = 5,
    id = 19,
    kg = 0.3,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Единственный культурный представитель рода Corn. «Ожидание Кукуруза»"
        return text
      end
}
dbt.inventory.items[20] = {
    name = "Пончик",
    mdl = "models/props_everything/donutsprinkles.mdl",
    icon = Material("icons/food_donut.png", "smooth"),
    food = 6,
    time = 6,
    id = 20,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Круглый с дыркой, прям как стиральная машинка."
        return text
      end
}
dbt.inventory.items[21] = {
    name = "Кусочек пиццы",
    mdl = "models/props_everything/pizzaslice.mdl",
    icon = Material("icons/food_pizza.png", "smooth"),
    food = 20,
    cost = 1,
    time = 5,
    id = 21,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Почему только кусочек?"
        return text
      end
}
dbt.inventory.items[22] = {
    name = "Бургер",
    mdl = "models/props_everything/hamburger.mdl",
    icon = Material("icons/food_sandwich.png", "smooth"),
    food = 40,
    cost = 5,
    time = 10,
    id = 22,
    kg = 0.3,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Компактное комбо из различных нарезанных ингредиентов."
        return text
      end
}
dbt.inventory.items[23] = {
    name = "Куриная ножка",
    mdl = "models/props_everything/chickendrumstick.mdl",
    icon = Material("icons/food_turkey.png", "smooth"),
    food = 50,
    cost = 3,
    time = 15,
    id = 23,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Эксклюзивный куриный продукт создавший армию цыплят инвалидов."
        return text
      end
}
dbt.inventory.items[24] = {
    name = "Стейк",
    mdl = "models/props_everything/steak.mdl",
    icon = Material("icons/food_steak2.png", "smooth"),
    food = 100,
    cost = 4,
    time = 20,
    color = Color(94, 62, 7, 255),
    id = 24,
    kg = 1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Rare, Medium rare, Medium, Medium well, Well done!"
        return text
      end
}

dbt.inventory.items[25] = {
	name = "Мешок с различными полуфабрикатами",
	icon = Material("icons/food_bag_flour.png"),
    kg = 2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Верный товарищ повара, который помогает воплощать все его кулинарные изыскания."
        return text
    end,
    mdl = "models/props_junk/garbage_bag001a.mdl",
    descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Засунуть мешок в печь."},
    desc = {color_white, "@Demit. Welcome to the official EternityDev Games server! Make yourself at home. Go to ⁠Неизвестно and read all of them and make an introduction in ⁠Неизвестно to get access to the rest of the server."}
}

dbt.inventory.items[26] = {
    name = "Быстродействующий яд (KCN)",
	poison = true,
    mdl = "models/props_lab/jar01b.mdl",
    icon = Material("icons/142.png", "smooth"),
    time = 5,
    id = 26,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Идеально подходит для быстрой и не мучительной  смерти."
        return text
      end
}

dbt.inventory.items[27] = {
    name = "Долгодействующий яд (Метанол)",
	poison = true,
    mdl = "models/props_junk/glassjug01.mdl",
    icon = Material("icons/medical_poison.png", "smooth"),
    time = 5,
    id = 27,
    kg = 0.2,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Идеально не подходит для быстрой смерти. Эффект медленный, интересно когда он возьмёт своё."
        return text
      end
}

dbt.inventory.items[28] = {
    name = "Чай",
    mdl = "models/props_everything/coffee.mdl",
    icon = Material("icons/drink_tea2.png", "smooth"),
    water = 50,
    time = 15,
    id = 28,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Классика отдыха. Согревает тело, умиротворяет душу и иногда делает тебя философом."
        return text
      end
}

dbt.inventory.items[29] = {
    name = "Какао",
    mdl = "models/themask/scenebuildthemes/groceries/sm_coffee_cup_paper_02.mdl",
    icon = Material("icons/drink_bear3.png", "smooth"),
    water = 20,
    time = 10,
    id = 29,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Напиток детства и уютных вечеров. С каждой чашкой мир кажется чуть-чуть слаще."
        return text
      end
}

dbt.inventory.items[30] = {
    name = "Глинтвейн",
    mdl = "models/themask/scenebuildthemes/groceries/sm_coffee_cup_paper_02.mdl",
    icon = Material("icons/drink_tea.png", "smooth"),
    water = 60,
    time = 20,
    id = 30,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Теплый пряный аромат праздника. Дарит настроение, не забирая сознания."
        return text
      end
}

dbt.inventory.items[31] = {
	name = "Бинт",
	mdl = "models/zworld_health/bandages.mdl",
	icon = Material("icons/medical_plaster.png", "smooth"),
	time = 5,
	medicine = "Бинт",
	id = 31,
    kg = 0.1,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Простой и надёжный способ остановить кровь и закрыть рану."
        return text
    end,
    OnUse = function(ply, data, meta, c_data)
        dbt.UseMedicaments(ply, data.medicine, c_data.position)
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Используется для лечения ранений."},
}

dbt.inventory.items[32] = {
	name = "Набор для устранения переломов",
	mdl = "models/zworld_health/healkit.mdl",
	icon = Material("icons/151.png", "smooth"),
	time = 5,
	medicine = "Шинадляпереломов",
	id = 32,
    bNotDeleteOnUse = false,
    OnUse = function(ply, data, meta, c_data)
        dbt.UseMedicaments(ply, data.medicine, c_data.position)
        return meta
    end,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Набор для оказания первой медицинской помощи при переломе."
        return text
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Используется для лечения переломов."},
}

dbt.inventory.items[33] = {
	name = "Мазь",
	mdl = "models/props_rpd/medical_iv.mdl",
	icon = Material("icons/medical_antiseptic_cream.png", "smooth"),
	time = 5,
	medicine = "Мазь",
	id = 33,
    OnUse = function(ply, data, meta, c_data)
        dbt.UseMedicaments(ply, data.medicine, c_data.position)
    end,
	GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Специализированная мазь, помогающая быстро лечить ушибы."
        return text
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Используется для лечения ушибов."},
}

dbt.inventory.items[34] = {
    name = "Хирургический набор",
    mdl = "models/firstaid/item_firstaid.mdl",
    icon = Material("icons/medical_chest.png", "smooth"),
    time = 5,
    medicine = "Хирургическийнабор",
    id = 34,
    angle = Angle(0,180,0),
    OnUse = function(ply, data, meta, c_data)
        dbt.UseMedicaments(ply, data.medicine, c_data.position)
    end,
	GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Профессиональный набор инструментов для лечения тяжёлых ранений, например, пулевых. Спасает даже в критических ситуациях."
        return text
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Используется для лечения пулевых и тяжёлых ранений."},
}

dbt.inventory.items[35] = {
    name = "Катана",
    weapon = "tfa_l4d2_kfkat",
    mdl = "models/weapons/tfa_l4d2/w_kf2_katana.mdl",
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Острое и длинное лезвие данного инструмента идеально подходит чтобы использовать его по назначению."
        return text
    end
}

dbt.inventory.items[36] = {
	name = "Отмычка",
	icon = Material("icons/77.png"),
	mdl = "models/Items/CrossbowRounds.mdl",
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Для использования требуется подойти к нужной двери и нажать 'H'."
        return text
    end,
}

dbt.inventory.items[37] = {
    name = "Аптечка",
    mdl = "models/zworld_health/healthkit.mdl",
    icon = Material("icons/medical_chest.png", "smooth"),
    time = 5,
    medicine = "Аптечка",
    id = 37,
    angle = Angle(0,180,0),
    OnUse = function(ply, data, meta, c_data)
		ply:SetHealth(math.Clamp(ply:Health() + 25, 0, ply:GetMaxHealth()))
    end,
	GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Стандартная аптечка. Перелом не излечит, но общее состояние поднимет, как в видеоиграх."
        return text
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Лечит 25 хп."},
}


dbt.inventory.items[38] = {
    name = "Диск",
    mdl = "models/drp_props/item_disc.mdl",
    id = 38,
    kg = 0.1,
    notEditable = true,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Диск от ноутбука."
        text[#text+1] = true
        text[#text+1] = color_white
        text[#text+1] = "Название: "..self.meta.Author
        return text
    end
}

dbt.inventory.items[39] = {
    name = "Ноутбук",
    mdl = "models/macbookair_sg/macbookair_sg.mdl",
    id = 39,
    kg = 3,
    notEditable = true,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Ноутбук"
        return text
    end
}

dbt.inventory.items[40] = {
    name = "Тухлятина",
    mdl = "models/props_junk/garbage_takeoutcarton001a.mdl",
    icon = Material("icons/medical_poison.png", "smooth"),
    id = 40,
    kg = 0.1,
    rotten = true,
    notEditable = true,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Воняет. Есть нельзя."
        return text
    end
}

dbt.inventory.items[41] = {
    name = "Шприц",
    mdl = "models/themask/scenebuildthemes/medic/obj_medical_syringe_bigger.mdl",
    icon = Material("icons/medical_poison.png", "smooth"),
    id = 41,
    kg = 0.1,
    notEditable = true,
    GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Пустой шприц"
        return text
    end
}

dbt.inventory.items[42] = {
    name = "Шприц со слабым транквилизатором",
    mdl = "models/themask/scenebuildthemes/medic/obj_medical_syringe_bigger.mdl",
    icon = Material("icons/medical_poison.png", "smooth"),
    time = 5,
    medicine = "СлабыйТранквилизатор",
    id = 42,
	kg = 0.1,
	OnUse = function(ply, data, meta, c_data)
		if IsValid(ply) and ply:Alive() and !ply.isSpectating and !dbt.hasWound(ply, "Парализован") then
	        startRagdoll(ply)
			dbt.setWound(ply, "Парализован", "Туловище", Vector(0, 0, 0))
			
			ply.dbt_InjectionData = {
				type = "weak",
				drug = "Слабый транквилизатор",
				bodyPart = c_data.bodyPart or "Туловище",
				time = CurTime(),
				duration = 300
			}

			timer.Create(ply:SteamID().."/paralysed", 300, 1, function()
				if IsValid(ply) then
					dbt.removeWound(ply, "Парализован", "Туловище")
					ply.dbt_InjectionData = nil
					restoreFromRagdoll(ply, {
						setPosition = true,
					})
					ply:SelectWeapon("hands")
				end
			end)
	    end
    end,
	GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Парализует цель на 5 минут, превращая её в регдолл."
        return text
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Применить через меню взаимодействия (E)"},
}

dbt.inventory.items[43] = {
    name = "Шприц с сильным транквилизатором",
    mdl = "models/themask/scenebuildthemes/medic/obj_medical_syringe_bigger.mdl",
    icon = Material("icons/medical_poison.png", "smooth"),
    time = 5,
    medicine = "СильныйТранквилизатор",
    id = 43,
	kg = 0.1,
	OnUse = function(ply, data, meta, c_data)
		if IsValid(ply) and ply:Alive() and !ply.isSpectating and !dbt.hasWound(ply, "Парализован") then
	        startRagdoll(ply)
			dbt.setWound(ply, "Парализован", "Туловище", Vector(0, 0, 0))
			
			ply.dbt_InjectionData = {
				type = "strong",
				drug = "Сильный транквилизатор",
				bodyPart = c_data.bodyPart or "Туловище",
				time = CurTime(),
				duration = 1200
			}

			timer.Create(ply:SteamID().."/paralysed", 1200, 1, function()
				if IsValid(ply) then
					dbt.removeWound(ply, "Парализован", "Туловище")
					ply.dbt_InjectionData = nil
					restoreFromRagdoll(ply, {
						setPosition = true,
					})
					ply:SelectWeapon("hands")
				end
			end)
	    end
    end,
	GetDescription = function(self)
        local text = {}
        text[#text+1] = color_white
        text[#text+1] = "Парализует цель на 20 минут, превращая её в регдолл."
        return text
    end,
	descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Применить через меню взаимодействия (E)"},
}

for k, i in pairs(weapons.GetList()) do
    local class = i.ClassName
    if string.StartsWith(class, "tfa_nmrih") then
        dbt.inventory.items[#dbt.inventory.items+1] = {
            name = i.PrintName,
            weapon = class,
            mdl = i.WorldModel,
			kg = i.kg or 1,
            GetDescription = function(self)
                local text = {}
                text[#text+1] = color_white
                text[#text+1] = i.Desc or "Мы не знаем что это такое если бы мы знали что это такое."
                return text
            end,
			descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Оружие. Найди ему правильное применение"},
        }
    end
end

dbt.inventory.weaponsId = {}

for k, i in pairs(dbt.inventory.items) do
    if i.weapon then
        dbt.inventory.weaponsId[i.weapon] = k
    end
end

hook.Add("InitPostEntity", "spdsa", function()
    for k, i in pairs(weapons.GetList()) do
        local class = i.ClassName
        if string.StartsWith(class, "tfa_nmrih") then
            dbt.inventory.items[#dbt.inventory.items+1] = {
                name = i.PrintName,
                weapon = class,
                mdl = i.WorldModel,
				kg = i.kg or 1,
                GetDescription = function(self)
                    local text = {}
                    text[#text+1] = color_white
                    text[#text+1] = i.Desc or "Мы не знаем что это такое если бы мы знали что это такое."
                    return text
                end,
				descalt = {Color(175, 175, 175, 150), "Использование: ", true, "• Оружие. Найди ему правильное применение"},
            }
        end
    end
    dbt.inventory.weaponsId = {}

    for k, i in pairs(dbt.inventory.items) do
        if i.weapon then
            dbt.inventory.weaponsId[i.weapon] = k
        end
    end
end)

local typesAmmo = game.GetAmmoTypes()

for k, i in pairs(typesAmmo) do 
    print(k, i)
    local data = game.GetAmmoData(k)
    print(data.name)
    local o = dbt.inventory.RegisterAmmoItem(tostring(data.name))
    print(o)
end