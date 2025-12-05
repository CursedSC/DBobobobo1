netstream.Hook("dbt/sync/wl.in-game", function(list, list_file)
	allowed = list
	list_file = list_file
end)

function ReqList()
	netstream.Start("dbt/sync/wl.in-game")
end

surface.CreateFont( "AdminESPFont", {
	font = "Roboto",
	size = 17,
	extended = true,
	weight = 100,
} )

local function createText(data, x, y, col, y2)
	draw.SimpleText(data, "AdminESPFont", x, y + y2 - 1, Color(0, 0, 0), TEXT_ALIGN_LEFT)
	draw.SimpleText(data, "AdminESPFont", x, y + y2 + 1, Color(0, 0, 0), TEXT_ALIGN_LEFT)
	draw.SimpleText(data, "AdminESPFont", x - 1, y + y2, Color(0, 0, 0), TEXT_ALIGN_LEFT)
	draw.SimpleText(data, "AdminESPFont", x + 1, y + y2, Color(0, 0, 0), TEXT_ALIGN_LEFT)
	draw.SimpleText(data, "AdminESPFont", x, y + y2, col, TEXT_ALIGN_LEFT)
end
ESP = ESP or {}
ESP.playerinfo = {}
ESP.entityinfo = {}
if CLIENT then
    ESP.mat = ESP.mat or CreateMaterial("deznutz", "VertexLitGeneric", {
        ["$basetexture"] = "models/debug/debugwhite",
        ["$model"] = 1,
        ["$ignorez"] = 1
    })
end

ESP.settings = ESP.settings or {}
ESP.settings.player = ESP.settings.player or {}
ESP.settings.entity = ESP.settings.entity or {}


function ESP:ToggleFeature(type, index)
    if type == "player" then
        settings.Set("dbt_esp_player_" .. index, not self.settings.player[index])
        self.settings.player[index] = not self.settings.player[index]
    elseif type == "entity" then
        settings.Set("dbt_esp_entity_" .. index, not self.settings.entity[index])
        self.settings.entity[index] = not self.settings.entity[index]
    end
end


local function addLang(name, index, data) 

end

function ESP:AddPlayerESPCustomization(index, data)
    if !index then return end
    if !data then return end

    data.index = index
    self.playerinfo[#self.playerinfo + 1] = data

    addLang("Player", index, data)
end

function ESP:AddEntityESPCustomization(index, data)
    if !index then return end
    if !data then return end

    data.index = index
    self.entityinfo[#self.entityinfo + 1] = data

    addLang("Entity", index, data)
end

function ESP:DistanceFits(vec1, vec2, dist)
    if dist == 0 then return true end

    return vec1:Distance(vec2) <= dist
end

local function addStructure(entity, dist, data, settings)
    if isfunction(data) and ESP:DistanceFits(LocalPlayer():GetPos(), entity:GetPos(), dist) then
    	data = data(entity)
    end

    return {data, dist, entity:GetClass()}
end


local metaPl = FindMetaTable("Player")
function metaPl:ESPInfo()
    local data = {}

    for k, v in SortedPairs(ESP.playerinfo) do
        if ESP.settings.player[v.index] == false then continue end
        data[#data + 1] = addStructure(self, v.dist, v.data, v.config)
    end

    return data
end

local metaEn = FindMetaTable("Entity")
function metaEn:ESPInfo()
    local data = {}

    for k, v in SortedPairs(ESP.entityinfo) do
        if ESP.settings.entity[v.index] == false then continue end
        data[#data + 1] = addStructure(self, v.dist, v.data, v.config)
    end

    return data
end


ESP:AddPlayerESPCustomization("name_pl", {
    dist = 0,
    config = {
        name = "Имя персонажа",
        desc = "Включить показатель имени персонажа"
    },
    data = function(entity)
        return entity:Name()
    end
})


ESP:AddPlayerESPCustomization("faction_pl", {
    dist = 1500,
    config = {
        name = "Персонаж игрока",
        desc = "Включить показатель фракции игрока"
    },
    data = function(entity)
        return entity:Pers()
    end
})

ESP:AddPlayerESPCustomization("hp_armor_pl", {
    dist = 1000,
    config = {
        name = "Состояние игрока",
        desc = "Включить показатель состояния игрока"
    },
    data = function(entity)
        return entity:Health() .. "/" .. entity:Armor()
    end
})

ESP:AddPlayerESPCustomization("weapon_pl", {
    dist = 1000,
    config = {
        name = "Оружие игрока",
        desc = "Включить показатель информации о оружии игрока"
    },
    data = function(entity)
        local weapon = entity:GetActiveWeapon()
        if weapon and IsValid(weapon) then
            return weapon:GetPrintName() .. "[" .. weapon:GetClass() .. "] — " .. weapon:Clip1() .. "/" .. entity:GetAmmoCount(weapon:GetPrimaryAmmoType())
        end
    end
})

ESP:AddPlayerESPCustomization("dist_pl", {
    dist = 0,
    config = {
        name = "Дистанция игрока",
        desc = "Включить показатель дистанции игрока"
    },
    data = function(entity)
        return math.Round(LocalPlayer():GetPos():Distance(entity:GetPos()), 1)
    end
})

ESP:AddPlayerESPCustomization("chams_pl", {
    dist = 1000,
    config = {
        name = "Обводка игрока",
        desc = "Включить чамсы игроков"
    },
    data = function(entity)
        local col = dbt.chr[entity:Pers()].color

        cam.Start3D(EyePos(), EyeAngles())
            render.SuppressEngineLighting(true)
            render.MaterialOverride(ESP.mat)
            render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
            entity:DrawModel()
            render.MaterialOverride()
            render.SuppressEngineLighting(false)
        cam.End3D()
    end
})

ESP:AddPlayerESPCustomization("trace_pl", {
    dist = 1000,
    config = {
        name = "Прицел игрока",
        desc = "Показывать куда смотрит игрок"
    },
    data = function(entity)
        local col = dbt.chr[entity:Pers()].color

        local tr = {}
        tr.start = entity:EyePos()
        tr.endpos = (entity:GetAimVector() * 99999)
        tr.filter = {entity}

        local trace = util.TraceLine(tr).HitPos

        surface.SetDrawColor(col)
        if trace:ToScreen().visible and entity:EyePos():ToScreen().visible then
            surface.DrawLine(entity:EyePos():ToScreen().x, entity:EyePos():ToScreen().y, trace:ToScreen().x, trace:ToScreen().y)
        end
        surface.DrawRect(trace:ToScreen().x - 2.5, trace:ToScreen().y - 2.5, 5, 5)
    end
})

ESP:AddPlayerESPCustomization("observer_pl", {
    dist = 0,
    config = {
        name = "Статус NoClip",
        desc = "Включить показатель состояния ОбСервера игрока"
    },
    data = function(entity)
        if entity:GetMoveType() == MOVETYPE_NOCLIP then
            return "[NoClip]"
        end
    end
})

--[[
    Entity
]]--
ESP:AddEntityESPCustomization("name_en", {
    dist = 6000,
    config = {
        name = "Название энтити",
        desc = "Включить показатель названия энтити"
    },
    data = function(entity)
        return scripted_ents.Get(entity:GetClass()) and scripted_ents.Get(entity:GetClass()).PrintName or entity:GetClass()
    end
})

ESP:AddEntityESPCustomization("chams_en", {
    dist = 1000,
    config = {
        name = "Обводка энтити",
        desc = "Включить чамсы энтити"
    },
    data = function(entity)
        local col = ESP.entslist[entity:GetClass()] or Color(255, 255, 255)
 
        cam.Start3D(EyePos(), EyeAngles())
            render.SuppressEngineLighting(true)
            render.MaterialOverride(ESP.mat)
            render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255) 
            entity:DrawModel()
            render.MaterialOverride() 
            render.SuppressEngineLighting(false)
        cam.End3D()
    end
})

ESP:AddEntityESPCustomization("signame", { 
    dist = 1000,
    config = {
        name = "Заголовок энтити",
        desc = "Включить показатель энтити" 
    }, 
    data = function(entity)
        if not entity:GetNWString("Title", false) then return "Заголовок: Отсуствует" end
        return "Заголовок: "..entity:GetNWString("Title")
    end
})

for _, custom in pairs(ESP.playerinfo) do
    ESP.settings.player[custom.index] = settings.Get("dbt_esp_player_" .. custom.index)
end

for _, custom in pairs(ESP.entityinfo) do
    ESP.settings.entity[custom.index] = settings.Get("dbt_esp_entity_" .. custom.index)
end


ESP.entslist = {
    ["diskcard_800"] = Color(157, 111, 210),
    ["storage_box8"] = Color(157, 111, 210),
    ["med"] = Color(157, 111, 210),
    ["re_microphone"] = Color(157, 111, 210),
    ["decoder"] = Color(157, 111, 210),
    ["furngug"] = Color(157, 111, 210),
    ["gmt_instrument_piano"] = Color(157, 111, 210),
    ["polka"] = Color(157, 111, 210),
    ["shit"] = Color(157, 111, 210),
    ["folige"] = Color(157, 111, 210),
    ["food"] = Color(157, 111, 210),
    ["item"] = Color(157, 111, 210),
    ["water"] = Color(157, 111, 210),
    ["sign"] = Color(157, 111, 210),
    ["teapot"] = Color(157, 111, 210),
    ["prop_ragdoll"] = Color(210, 131, 111),
}

hook.Add("HUDPaint", "ESP-HUD",function()

	local client = LocalPlayer()

	if not client:Alive() then return end
	--if client:GetMoveType() != MOVETYPE_NOCLIP then return end
    if not client:GetNWBool("ESPMODE") then return end
	for k, v in pairs(player.GetAll()) do
		if v == LocalPlayer() then continue end
		if !v:Alive() then continue end    
		local _y = 0
		local info = v:ESPInfo()
		for k2, v2 in pairs(info) do
			if v2[1] and ESP:DistanceFits(LocalPlayer():GetPos(), v:GetPos(), v2[2]) then
				local pos = v:GetPos()
				local head = Vector(pos.x, pos.y, pos.z + 60)
				local headPos = head:ToScreen()
				local distance = LocalPlayer():GetPos():Distance(v:GetPos())
				local x, y = headPos.x, headPos.y 
				local f = math.abs(350 / distance)
				local size = 52 * f
				local col = dbt.chr[v:Pers()].color
 
				createText(tostring(v2[1]), (x - size / 2) + size, y - size / 2, col, _y)

				_y = _y + 15
			end
		end

	end 
 
	for k, v in pairs(ents.GetAll()) do
		if !ESP.entslist[v:GetClass()] then continue end
            

		local _y = 0
		local info = v:ESPInfo()
		for k2, v2 in pairs(info) do
			if v2[1] and ESP:DistanceFits(LocalPlayer():GetPos(), v:GetPos(), v2[2]) then
				local pos = v:GetPos()
				local head = Vector(pos.x, pos.y, pos.z)
				local headPos = head:ToScreen()
				local distance = LocalPlayer():GetPos():Distance(v:GetPos())
				local x, y = headPos.x, headPos.y
				local f = math.abs(350 / distance)
				local size = 52 * f
				local col = ESP.entslist[v:GetClass()] or color_white

				createText(tostring(v2[1]), (x - size / 2) + size, y - size / 2, col, _y)

				_y = _y + 15
			end
		end
	end
end)



concommand.Add("dbtload", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local file_id = args[1]
    local pon_str = file.Read("dbt-mapping/"..file_id..".txt")
    local tbl_send = pon.decode(pon_str)
    PrintTable(tbl_send)
    net.Start( "dbt/mapping" )
        net.WriteStream(pon_str, function()
        end)
    net.SendToServer() 
end)