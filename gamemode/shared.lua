GM.Team = ""
GM.Name = "Danganronpa Broken Timeline"
GM.Author = "Demit"
dbt = dbt or {}
dbt.music = dbt.music or {} 
dbt.rangs = {
    ['Founder'] = true,
    ['founder'] = true,
    ['admin'] = true,
    ['Admin'] = true,
    ['gamemaster'] = true,
    ['gm'] = true,
}
dbt.woundstypes = {
	bruises = "Ушиб",
	wound = "Ранение",
	hardwound = "Тяжелое ранение",
	bulletwound = "Пулевое ранение",
	fracture = "Перелом"
}

dbt.woundsposition = {
	head = "Голова",
	chest = "Туловище",
	leftarm = "Левая рука",
	rightarm = "Правая рука",
	leftleg = "Левая нога",
	rightleg = "Правая нога"
}

--[[
originalSendToServer = originalSendToServer or net.SendToServer
originalSend = originalSend or net.Send
originalBroadcast = originalBroadcast or net.Broadcast
originalReceive = originalReceive or net.Receive
originalStart = originalStart or net.Start

local current_message_name = "none"
function net.Start(message_name, ...)
    current_message_name = message_name
    return originalStart(message_name, ...)
end

if CLIENT then
    function net.SendToServer()
        local bytes = net.BytesWritten()

        print(string.format("[NetLogger] Sent to server: %s (%d bytes)", current_message_name, bytes))

        return originalSendToServer()
    end
end

if SERVER then
    function net.Send(ply)
        local bytes = net.BytesWritten()
        local target = IsEntity(ply) and ply:Nick() or "Multiple Players"

        print(string.format("[NetLogger] Sent to %s: %s (%d bytes)", target, current_message_name, bytes - 3))

        return originalSend(ply)
    end

    function net.Broadcast()
        local bytes = net.BytesWritten()

        print(string.format("[NetLogger] Broadcast: %s (%d bytes)", current_message_name, bytes - 3))

        return originalBroadcast()
    end
end

function net.Receive(message_name, callback)
    local wrapped_callback
    if callback then
        wrapped_callback = function(bits, ply)
            local sender = SERVER and (IsValid(ply) and ply:Nick() or "Unknown") or "Server"
            local bytes = math.ceil(bits / 8)
            print(string.format("[NetLogger] Received from %s: %s (%d bytes)", sender, message_name, bytes))

            return callback(bits, ply)
        end
    end

    return originalReceive(message_name, wrapped_callback or callback)
end]]

DeriveGamemode("sandbox")
EMETA = FindMetaTable("Entity")
PMETA = FindMetaTable("Player")
function PMETA:Pers()
    return self:GetNWString("dbt.CHR")
end

include_sv = (SERVER) and include or function() end
include_cl = (SERVER) and AddCSLuaFile or include or nil
include_sh = function(f)
    include_sv(f)
    include_cl(f)
end

cloud_reload = function(path, filename)
    local reload = string.lower(string.sub(filename, 1, 2 ))

    if reload == "sv" or reload == "init" then
        include_sv(path)
        MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Danganronpa Broken Timeline", Color(255, 55, 50), "] ", color_white, "Прогрузка ", Color(100, 100, 250), "SERVER", color_white, " filename: " .. filename .. "\n")
    elseif reload == "cl" or reload == "cl_init" then
        include_cl(path)
        MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Danganronpa Broken Timeline", Color(255, 55, 50), "] ", color_white, "Прогрузка ", Color(255, 136, 0), "CLIENT", color_white, " filename: " .. filename .. "\n")
    elseif reload == "sh" or reload == "shared" then
        include_sh(path)
        MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Danganronpa Broken Timeline", Color(255, 55, 50), "] ",  color_white, "Прогрузка ", Color(120, 225, 100), "SHARED", color_white, " filename: " .. filename .. "\n")
    else
        include_sh(path)
        MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Danganronpa Broken Timeline", Color(255, 55, 50), "] ",  color_white, "Прогрузка ", Color(120, 225, 100), "SHARED", color_white, " filename: " .. filename .. "\n")
    end
end

lib_reload = function(path, filename)
    local reload = string.lower(string.sub(filename, 1, 2 ))
    include_sv(path)
    --MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Danganronpa Broken Timeline", Color(255, 55, 50), "] ", color_white, "Прогрузка ", Color(100, 100, 250), "SERVER", color_white, " filename: " .. filename .. "\n")
    include_cl(path)
    include_sh(path)
end

function GetFilesSortedByRealm(path)
    local not_sorted, folders = file.Find(path.."/*", "LUA")
    local sorted = {}

    for key, val in pairs(not_sorted) do
        val = string.lower(val)

        if string.find(val, "sh_") then
            sorted[table.Count(sorted) + 1] = val
            not_sorted[key] = nil
        end
    end

    for key, val in pairs(not_sorted) do
        val = string.lower(val)

        if string.find(val, "sv_") then
            sorted[table.Count(sorted) + 1] = val
            not_sorted[key] = nil
        end
    end

    for key, val in pairs(not_sorted) do
        sorted[table.Count(sorted) + 1] = val
    end

    return sorted, folders
end

local fold = GM.FolderName.."/gamemode/"
function dbt.LoadFolder(path)
    local files, folders = file.Find(fold.."/"..path.."/*", "LUA")

    for _,v in pairs(files) do
        cloud_reload(fold..path.."/"..v, v)
    end

    for _,v in pairs(folders) do
       dbt.LoadFolder(path.."/"..v)
    end


end

dbt.LoadFolder("enums")
dbt.LoadFolder("validate_models_dro")
dbt.LoadFolder("lib")

-- Загрузка LOTM и кастомных персонажей
dbt.LoadFolder("modules/lotm")
dbt.LoadFolder("modules/custom_characters")

dbt.LoadFolder("modules")
dbt.LoadFolder("systems")
dbt.LoadFolder("module_re")

dbt.LoadFolder("downloading_files")

dbt.LoadFolder("config")
hook.Run("dbt.ConfigLoaded")
SetGameStatus("preparation")


PMETA.old_IsTyping = PMETA.old_IsTyping or PMETA.IsTyping
function PMETA:IsTyping()
    return self:GetNWBool("DBT_TYPING", false)
end

function PMETA:IsAdmin()
    return dbt.rangs[self:GetUserGroup()]
end

function PMETA:IsSuperAdmin()
    return dbt.rangs[self:GetUserGroup()]
end

function PMETA:SelfData()
    return dbt.chr[self:GetNWString("dbt.CHR")]
end

-- Player --
local playerMeta = FindMetaTable("Player")

function playerMeta:HasNoClip()
    return self:GetMoveType() == MOVETYPE_NOCLIP
end

if SERVER then
    -- Vars --
    local noclips = { }

    -- Funcs --
    local function MakeInvisible(player, invisible)
        player:SetNoDraw(invisible)
        player:SetNotSolid(invisible)

        local activeWeapon = player:GetActiveWeapon()

        if activeWeapon:IsValid() then
            activeWeapon:SetRenderMode(RENDERMODE_TRANSALPHA)

            if invisible then
                activeWeapon:SetColor(Color(0, 0, 0, 0))
            else
                activeWeapon:SetColor(Color(255, 255, 255))
            end
        end

        player:DrawViewModel(not invisible)
        player:DrawWorldModel(not invisible)
    end

    -- Событийная система вместо перекадрового Think: реагируем на вход/выход noclip и спавн
    local function UpdateNoclipState(ply)
        if not IsValid(ply) then return end
        local desired = ply:HasNoClip() and not ply:InVehicle()
        if noclips[ply] == desired then return end
        noclips[ply] = desired
        MakeInvisible(ply, desired)
    end

    hook.Remove("Think","noclip.invisible") -- на случай повторной загрузки

    hook.Add("PlayerNoClip","dbt.noclip.state", function(ply, desired)
        -- desired: true если входит в noclip, false если выходит
        timer.Simple(0, function() UpdateNoclipState(ply) end) -- после смены MoveType
    end)

    hook.Add("PlayerSpawn","dbt.noclip.spawnreset", function(ply)
        if noclips[ply] then
            noclips[ply] = nil
            MakeInvisible(ply, false)
        end
    end)

    hook.Add("PlayerDisconnected","dbt.noclip.cleanup", function(ply)
        noclips[ply] = nil
    end)

    -- Редкая страховочная проверка раз в 2 секунды (минимум нагрузка)
    timer.Create("dbt.noclip.audit", 2, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                local desired = ply:HasNoClip() and not ply:InVehicle()
                if noclips[ply] ~= desired then
                    UpdateNoclipState(ply)
                end
            end
        end
    end)
end

local names = {
    [0] = "Гость",
    [1] = "Danganronpa: Trigger Happy Havoc",
    [2] = "Danganronpa 2: Goodbye Despair",
    [3] = "Danganronpa V3: Killing Harmony",
    [4] = "Danganronpa Another Episode: Ultra Despair Girls",
    [5] = "Danganronpa: Zero",
    [6] = "Кастомные персонажи",
    [9] = "Маскоты",
    [10] = "Монокумы",
}

local live_room_id = {
    ["*76"] = true,
    ["*67"] = true,
    ["*64"] = true,
    ["*68"] = true,
    ["*65"] = true,
    ["*70"] = true,
    ["*62"] = true,
    ["*72"] = true,
    ["*60"] = true,
    ["*74"] = true,
    ["*59"] = true,
    ["*57"] = true,
    ["*78"] = true,
    ["*80"] = true,
    ["*82"] = true,
    ["*222"] = true,
}

--[[
self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()
]]

properties.Add( "refilnotes", {
    MenuLabel = "Восполнить записки",
    Order = 1,
    MenuIcon = "icon16/lock_add.png",

    Filter = function( self, ent, ply )
        return ent:GetModel() == "models/drp_props/furniture2.mdl"
    end,

    MenuOpen = function( self, option, ent, tr )

    end,

    Action = function( self, ent )
        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()
    end,

    Receive = function( self, length, ply )

        local tr = net.ReadEntity()
        tr.sign_count = 5

    end

} )

properties.Add( "setreactdeath", {
    MenuLabel = "Сделать трупом",
    Order = 1,
    MenuIcon = "icon16/lock_add.png",

    Filter = function( self, ent, ply )
        return ent:IsRagdoll()
    end,

    MenuOpen = function( self, option, ent, tr )

    end,

    Action = function( self, ent )
        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()
    end,

    Receive = function( self, length, ply )

        local tr = net.ReadEntity()
        dbt.AddCorpse(tr)

    end

} )

properties.Add( "addowner", {
    MenuLabel = "Выставить владельца",
    Order = 1,
    MenuIcon = "icon16/lock_add.png",

    Filter = function( self, ent, ply )
        return live_room_id[ent:GetModel()]
    end,

    MenuOpen = function( self, option, ent, tr )

        local target = ent

        local submenu = option:AddSubMenu()

        for k, i in pairs(DBT_CHAR_EZ) do
            local option = submenu:AddOption( names[k] or "???", function()  end )
            local submenu_t = option:AddSubMenu()
            for k, i in pairs(i) do
                local option = submenu_t:AddOption( i, function()
                    self:SetOwner(ent, i)
                end )
                local char_tbl = dbt.chr[i]
                option:SetIcon("dbt/characters"..char_tbl.season.."/char"..char_tbl.char.."/char_ico_1.png")
            end
        end
    end,


    SetOwner = function( self, door, chr )

        self:MsgStart()
            net.WriteEntity( door )
            net.WriteString( chr )
        self:MsgEnd()

    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )

        local door = net.ReadEntity()
        local chr = net.ReadString()
        door:SetNWString("Owner", chr)

    end

} )

properties.Add( "setchr", {
    MenuLabel = "Выставить персонажа",
    Order = 999,
    --MenuIcon = "icons/151.png",

    Filter = function( self, ent, ply )
        return ent:IsPlayer()
    end,

    MenuOpen = function( self, option, ent, tr )

        local target = ent

        local submenu = option:AddSubMenu()

        for k, i in pairs(DBT_CHAR_EZ) do
            local option = submenu:AddOption( names[k] or "???", function()  end )
            local submenu_t = option:AddSubMenu()
            for k, i in pairs(i) do
                local option = submenu_t:AddOption( i, function()
                    self:SetCHR(ent, i)
                end )
            end
        end
    end,


    SetCHR = function( self, pl, chr )

        self:MsgStart()
            net.WriteEntity( pl )
            net.WriteString( chr )
        self:MsgEnd()

    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )

        local pl = net.ReadEntity()
        local chr = net.ReadString()
        dbt.setchr(pl, chr)

    end

} )

local h_wep = {}

for k, i in pairs(weapons.GetList()) do
    if i.Category == "Оружие" then
        h_wep[#h_wep + 1] = {
            name = i.PrintName,
            wep = i.ClassName,
        }
    end
end
table.sort(h_wep, function(a, b)
    return a.name < b.name
end)

local g_wep = {}

for k, i in pairs(weapons.GetList()) do
    if i.Category == "Оружие Огнестрельное" then
        g_wep[#g_wep + 1] = {
            name = i.PrintName,
            wep = i.ClassName,
        }
    end
end
table.sort(g_wep, function(a, b)
    return a.name < b.name
end)


properties.Add( "give_item", {
    MenuLabel = "Выдать предмет",
    Order = 999,
    --MenuIcon = "icons/151.png",

    Filter = function( self, ent, ply )
        return ent:IsPlayer()
    end,

    MenuOpen = function( self, option, ent, tr )

        local target = ent


        local submenu = option:AddSubMenu()
        for k,i in pairs(dbt.inventory.items) do
            if k > 2 then
                if i.name then submenu:AddOption( i.name, function() self:GiveItem(ent, k) end ) end
            end
        end

    end,


    GiveItem = function( self, pl, item )

        self:MsgStart()
            net.WriteEntity( pl )
            net.WriteFloat( item )
        self:MsgEnd()

    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )

        local pl = net.ReadEntity()
        local item = net.ReadFloat()
        dbt.inventory.additem(pl, item, {})
    end

} )

properties.Add( "use_with", {
    MenuLabel = "Взаимодействие",
    Order = 999,
    --MenuIcon = "icons/151.png",

    Filter = function( self, ent, ply )
        return ent:IsPlayer()
    end,

    MenuOpen = function( self, option, ent, tr )

        local target = ent


        local submenu = option:AddSubMenu()
        submenu:AddOption( "Восполнить Показатели", function() self:StatsNew(ent) end )

    end,


    StatsNew = function( self, pl)

        self:MsgStart()
            net.WriteEntity( pl )
        self:MsgEnd()

    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )
        local ply = net.ReadEntity()
        ply:SetNWInt("hunger", 100)
        ply:SetNWInt("sleep", 100)
        ply:SetNWInt("Stamina", 100)
        ply:SetNWInt("water", 100)
    end

} )

// Позитив, хз нафига ты это вызываешь при прогрузке сриптов на сервак, и что это вообще нахуй откуда ent я не понимаю нихуя не работает. positive: я сам ва хуе

woundstbl_properties = woundstbl_properties or {}

netstream.Hook("dbt/woundsystem/getwounds_properties_return", function(data)
	woundstbl_properties = data or {}
end)

properties.Add( "add_wound", {
    MenuLabel = "Управление ранениями",
    Order = 999,
    --MenuIcon = "icons/151.png",

    Filter = function( self, ent, ply )

        return ent:IsPlayer()
    end,

    MenuOpen = function( self, option, ent, tr )
		netstream.Start("dbt/woundsystem/getwounds_properties", ent)
        local target = ent

        local submenu = option:AddSubMenu()

		for k, v in pairs(dbt.woundsposition) do
			local option_h = submenu:AddOption( v, function()  end )
	        local submenu_h_t = option_h:AddSubMenu()

	        for _, i in pairs(dbt.woundstypes) do
	            local op = submenu_h_t:AddOption( i )

				op.DoClick = function(opself)
					self:SetWound(target, i, v, opself:GetChecked())
				end
				op.Think = function(opself)
					if woundstbl_properties[v] then
						for a, b in pairs(woundstbl_properties[v]) do
							if table.HasValue(b, i) then
								op:SetChecked(true)
							end
						end
					end
				end
	        end
		end

		local op = submenu:AddOption( 'Убрать все ранения' )
		op.DoClick = function(opself)
			for k, v in pairs(woundstbl_properties) do
				for m, n in pairs(v) do
					for a, b in pairs(n) do
						self:SetWound(target, b, k, true)
					end
				end
			end
		end


    end,


    SetWound = function( self, pl, wound, pos, isremove)

        self:MsgStart()
            net.WriteEntity( pl )
			net.WriteString(wound)
			net.WriteString(pos)
			net.WriteBool(isremove)
        self:MsgEnd()

    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )
        local pl = net.ReadEntity()
		local wound = net.ReadString()
		local woundpos = net.ReadString()
		local isremove = net.ReadBool() and dbt.removeWound(pl, wound, woundpos) or dbt.setWound(pl, wound, woundpos)
    end

} )

for k,i in pairs(dbt.chr) do
    if string.EndsWith(i.model, "default_p.mdl") then
        player_manager.AddValidModel( k, i.model )
        player_manager.AddValidHands( k, string.TrimRight(i.model, "default_p.mdl").. "c_arms/default_p.mdl", 0, "0000000" )
    end
end

player_manager.AddValidModel( "", "" )
player_manager.AddValidHands( "", "", 0, "0000000" )

player_manager.AddValidModel( "kazuichi_soda", "models/bratplat/kazuichi_soda/kazuichi_soda.mdl" )
player_manager.AddValidHands( "kazuichi_soda", "models/bratplat/kazuichi_soda/c_arms/kazuichi_soda.mdl", 0, "0000000" )

player_manager.AddValidModel( "byakuya_togami", "models/custom/byakuya_togami.mdl" )
player_manager.AddValidHands( "byakuya_togami", "models/custom/byakuya_togami_viewarms.mdl", 0, "0000000" )

player_manager.AddValidModel( "aoi", "models/danganronpa_nk/aoi/aoi.mdl" )
player_manager.AddValidHands( "aoi", "models/danganronpa_nk/aoi/aoi_arm.mdl", 0, "0000000" )

player_manager.AddValidModel( "kyoko", "models/danganronpa_nk/kyoko/kyoko.mdl" )
player_manager.AddValidHands( "kyoko", "models/danganronpa_nk/kyoko/kyoko_arm.mdl", 0, "0000000" )

player_manager.AddValidModel( "komaru", "models/hcteam/playermodels/komaru.mdl" )
player_manager.AddValidHands( "komaru", "models/hcteam/playermodels/komaru_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "chisa_player", "models/pacagma/dangaronpa/chisa/chisa_player.mdl" )
player_manager.AddValidHands( "chisa_player", "models/pacagma/dangaronpa/chisa/chisa_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "ryoko_player", "models/pacagma/dangaronpa/ryoko/ryoko_player.mdl" )
player_manager.AddValidHands( "ryoko_player", "models/pacagma/dangaronpa/ryoko/ryoko_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "jataro", "models/player/jataro.mdl" )
player_manager.AddValidHands( "jataro", "models/player/arms/jataro_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "masaru_p", "models/player/masaru_p.mdl" )
player_manager.AddValidHands( "masaru_p", "models/player/masaru_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "kotoko_p", "models/player/kotoko/kotoko_p.mdl" )
player_manager.AddValidHands( "kotoko_p", "models/player/kotoko/kotoko_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "nagisa_p", "models/player/nagisa/nagisa_p.mdl" )
player_manager.AddValidHands( "nagisa_p", "models/player/nagisa/nagisa_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "monaca_p", "models/player/someguy/monaca_p.mdl" )
player_manager.AddValidHands( "monaca_p", "models/player/someguy/monaca_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "akane_owari", "models/player/yourtoast4/danganronpa/akane_owari.mdl" )
player_manager.AddValidHands( "akane_owari", "models/player/yourtoast4/danganronpa/c_arms/akane_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "hifumi_yamada", "models/player/yourtoast4/danganronpa/hifumi_yamada.mdl" )
player_manager.AddValidHands( "hifumi_yamada", "models/player/yourtoast4/danganronpa/c_arms/hifumi_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "leon_kuwata", "models/player/yourtoast4/danganronpa/leon_kuwata.mdl" )
player_manager.AddValidHands( "leon_kuwata", "models/player/yourtoast4/danganronpa/c_arms/leon_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "makoto_naegi", "models/player/yourtoast4/danganronpa/makoto_naegi.mdl" )
player_manager.AddValidHands( "makoto_naegi", "models/player/yourtoast4/danganronpa/c_arms/makoto_arms.mdl", 0, "0000000" )

player_manager.AddValidModel( "player_kokichiouma", "models/player_kokichioumaultimate_notrack.mdl" )
player_manager.AddValidHands( "player_kokichiouma", "models/arms_kokichiouma.mdl", 0, "0000000" )

player_manager.AddValidModel( "teruteru_hanamura", "models/player/yourtoast4/danganronpa/teruteru_hanamura.mdl" )
player_manager.AddValidHands( "teruteru_hanamura", "models/player/yourtoast4/danganronpa/c_arms/teruteru_arms.mdl", 0, "0000000"  )

player_manager.AddValidModel( "player_kiibo", "models/player_kiibo.mdl" )
player_manager.AddValidHands( "player_kiibo", "models/kiibo_arms.mdl", 0, "0000000"  )

player_manager.AddValidModel( "monokuma", "models/player/yourtoast4/danganronpa/monokuma.mdl" )
player_manager.AddValidHands( "monokuma", "models/player/yourtoast4/danganronpa/c_arms/monokuma_arms.mdl", 0, "0000000"  )

if CLIENT then
    local function Chat(um)
        local ply = um:ReadString()
        local mode = um:ReadString()
        local id = um:ReadString()
        if not IsLobby() and not LocalPlayer():IsAdmin() then return end
        if mode == "1" then
            chat.AddText( Color( 139, 12, 161 ), "[#DBT]", Color( 100, 255, 100 ), " Игрок "..ply.." начал подключение на сервер" )
        elseif mode == "2" then
            chat.AddText( Color( 139, 12, 161 ), "[#DBT]", Color( 100, 255, 100 ), " Игрок "..ply.." прогрузился на сервер" )
        elseif mode == "3" then
            chat.AddText( Color( 139, 12, 161 ), "[#DBT]", Color( 100, 255, 100 ), " Игрок "..ply.." покинул сервер" )
        end
    end
    usermessage.Hook("DispatchChatJoin", Chat)
end

local function PlyJoined( name, ip )
    if SERVER then
        local a = {type  = "enter", text = "`["..CONFIG.ServerName.."]` Игрок **"..name.."** начал подключение на сервер"}
        sockethook.RunCommand("logs "..util.TableToJSON(a) )
        for k,v in pairs(player.GetAll()) do
            SendUserMessage("DispatchChatJoin", v, name, "1")
        end
    end
end
hook.Add( "PlayerConnect", "PlyJoined", PlyJoined )

local function PlyLoaded( ply )
    if SERVER then
        timer.Simple(5, function() --Let the player load you noodle!
            local a = {type  = "enter", text = "`["..CONFIG.ServerName.."]` Игрок **"..ply:Name().."** загрузился на сервер"}
            sockethook.RunCommand("logs "..util.TableToJSON(a) )
            if ply:IsValid() then
                for k,v in pairs(player.GetAll()) do
                    SendUserMessage("DispatchChatJoin", v, ply:GetName(), "2", ply:SteamID())
                end
            end
        end)
    end
end
hook.Add( "PlayerInitialSpawn", "PlyLoaded", PlyLoaded )
 
function PlyLeft( ply )
    if SERVER then
        local a = {type  = "enter", text = "`["..CONFIG.ServerName.."]` Игрок **"..ply:Name().."** вышел с сервера"}
        sockethook.RunCommand("logs "..util.TableToJSON(a) )
        for k,v in pairs(player.GetAll()) do
            SendUserMessage("DispatchChatJoin", v, ply:GetName(), "3", ply:SteamID())
        end
    end
end
hook.Add( "PlayerDisconnected", "PlyLeft", PlyLeft )


BUILD = "DBT | build 3.1 | 05.10.2025"
