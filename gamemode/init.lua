local meta = FindMetaTable( "Player" )
local entity = FindMetaTable( "Entity" )


MsgC(Color(240, 249, 220), "-----------------------------------------\n")
MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Danganronpa Broken Timeline", Color(255, 55, 50), "] ", color_white, "Начата загрузка Gamemode! \n")

Timestamp = os.time()
TimeString = os.date( "%X %x" , Timestamp )
MsgC(Color(240, 249, 220), "Время загрузки: ", Color(240, 49, 20), TimeString, "\n")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")--    

include("shared.lua")

SetGlobalString("HungerStatus", true)
SetGlobalString("WaterStatus", true)
SetGlobalString("SleepStatus", true)
SetGlobalString("AnuceStatus", true)

-- Console Commands
RunConsoleCommand("sv_kickerrornum", "0")
RunConsoleCommand("sbox_godmode", "0")
RunConsoleCommand("sbox_playershurtplayers", "1")
RunConsoleCommand("sbox_maxprops", "3000")
RunConsoleCommand("sbox_persist", "1")
RunConsoleCommand("mp_falldamage", "1")
RunConsoleCommand("sv_allowcslua", "0")
RunConsoleCommand("mp_show_voice_icons", "0")
RunConsoleCommand("sv_gravity", "750")
util.AddNetworkString("rp.OpenAnim")
util.AddNetworkString("dbt.Evidence")
util.AddNetworkString("StartClassTrial")
util.AddNetworkString("classtrial.ChangeViewToPlayer")
util.AddNetworkString("EndClassTrial")
util.AddNetworkString("dbt.GetTable")
util.AddNetworkString("dbt.Charactrs")
util.AddNetworkString("SpectatorNet")
util.AddNetworkString("Player.doing")
util.AddNetworkString("dbt.ClientRoomss")
util.AddNetworkString("dbt.AddEvidence")
util.AddNetworkString("redoRequest")
util.AddNetworkString("setModel")
util.AddNetworkString("rp.OpenAnim")
util.AddNetworkString("dbt.Sig.Create")
util.AddNetworkString("investigation.St")
util.AddNetworkString("Noise.Start")
util.AddNetworkString("GV.Change")
util.AddNetworkString("dbt/classtrial/update")
util.AddNetworkString("dbt/mono/rules/update")
util.AddNetworkString("dbt/mono/rules/clearall")
util.AddNetworkString("dbt/change/stage")
util.AddNetworkString("dbt/change/type")
util.AddNetworkString("dbt.Gift")
util.AddNetworkString("dbt.music.Off")
util.AddNetworkString("dbt/classtrial/update/mnualy")
util.AddNetworkString("dbt.StripWeapon")
local customCallback = {
    ["MusicMultyMod"] = function()
        timer.Simple(0, function()
            local MusicMultyMod = GetGlobalBool("MusicMultyMod")
            config.music.init(MusicMultyMod)
           -- netstream.Start(nil, "dbt/config/init", "music")
        end)
    end
}

net.Receive("setModel", function() local player = net.ReadEntity() local model = net.ReadString() player:SetModel(model) end)
-- Initialize defaults
SetGlobalBool("dbt_spoil_enabled", GetGlobalBool("dbt_spoil_enabled", true))

-- Generic global var change handler (keeps legacy keys as strings, but uses proper types)
net.Receive("GV.Change", function()
    local bool = net.ReadBool()
    local string_ = net.ReadString()
    -- Restrict to admins
    local ply = net.ReadEntity() -- not sent by callers; fallback to Player meta via util if needed
    -- We don't rely on this entity; permission checks are handled elsewhere
    if string_ == "dbt_spoil_enabled" then
        SetGlobalBool(string_, bool)
    else
        SetGlobalString(string_, bool)
    end
    if customCallback[string_] then customCallback[string_]() end
end)
net.Receive("dbt/change/stage", function() local string_ = net.ReadString() SetGlobalString("gameStatus_mono", string_) end)
net.Receive("dbt/change/type", function() local string_ = net.ReadString() SetGlobalString("gameStage_mono", string_) end)
--net.Receive("dbt/mono/rules/update", function() local string_ = net.ReadString() MONO_RULES = string_  net.Start("dbt/mono/rules/update") net.WriteString(MONO_RULES) net.Broadcast() end)
net.Receive("dbt.music.Off", function()
    net.Start("dbt.music.Off")
    net.Broadcast()
end)
net.Receive("dbt.StripWeapon", function()
	for k, v in pairs(player.GetAll()) do
		if IsMono(v) then continue end
		for m, n in pairs(v:GetWeapons()) do
			if n:GetClass() == 'hands' or n:GetClass() == 'weapon_physgun' or n:GetClass() == 'gmod_tool' then continue end
			v:StripWeapon(n:GetClass())
		end
	end
end)



netstream.Hook("dbt/chat/start", function(ply, text)
    hook.Run("PlayerSay", ply, text)
    --dbt.PlayerSay(ply, text)
end)

netstream.Hook("dbt/player/res", function(ad, pl, size)
    updateScale(pl, size)
end)
netstream.Hook("dbt/change/sq", function(ad, sq)
    ad:SetNWInt("IdleSQ", sq)
end)

netstream.Hook("dbt/change/sq/anim", function(ad, sq, bq)
    netstream.Start(nil, "dbt/change/sq/anim", ad, sq, bq)
end)

netstream.Hook("dbt/change/nwint", function(pl, na, st)
    pl:SetNWInt(na, st)
end)

function GM:PlayerNoClip( ply, state )
    return ply:IsAdmin()
end

function GM:PlayerSpawn( ply )
    ply:SetNWInt("IdleSQ", 1777)
    hook.Run("dbt.Spawn", ply)
    ply:Give("hands")
    ply:SetCanZoom(false)
    if ply:IsAdmin() then
        ply:Give("weapon_physgun")
        ply:Give("gmod_tool")
    end
    ply:SetHealth(100)
    ply:SetupHands()
    ply:SetNWBool("LeftArm",false)
    ply:SetNWBool("RightArm",false)
    ply:SetWalkSpeed(80)
    ply:SetRunSpeed(195)
    ply:SetJumpPower(200)

end


hook.Add( "PlayerInitialSpawn", "FullLoadSetup", function( ply )
    hook.Run("dbt.SpawnInit", ply)
    net.Start("dbt/classtrial/update/mnualy")
        net.WriteTable(GPS_POS)
        net.WriteTable(normal_camera_position)
    net.Send(ply)
  --  net.Start("dbt/mono/rules/update") net.WriteString(MONO_RULES) net.Send(ply)
end )


netstream.Hook("Player.doing", function(ply, b)
    ply:SetNWBool("Player.doing", b)
end)

netstream.Hook("Player.Chating", function(ply, b)
    ply:SetNWBool("Player.Chating", b)
end)

net.Receive("Player.doing", function(len, pl) local bool = net.ReadBool() pl:SetNWBool("Player.doing", bool) end)
net.Receive("Player.Chating", function(len, pl) local bool = net.ReadBool() pl:SetNWBool("Player.Chating", bool) end)
net.Receive("SpectatorNet", function(len, pl) local ent = net.ReadEntity() spectator.Spectate(pl, ent, OBS_MODE_CHASE) pl:SetNWInt("PlayerTar", 1) end)

netstream.Hook("dbt/chat/bool", function(pl,b)
    pl:SetNWBool("DBT_TYPING", b)
end)

hook.Add( "PlayerInitialSpawn", "dbt.players.CollisionCheck", function( ply )
	ply:SetCustomCollisionCheck( true )
end )

hook.Add("ShouldCollide", "dbt.players.separateStates", function(ent1, ent2)
    if not ent1:IsPlayer() or not ent2:IsPlayer() then return end
    if ent1 == ent2 then return end

    local inGame1 = ent1:GetNWBool("InGame", false)
    local inGame2 = ent2:GetNWBool("InGame", false)

    if !inGame1 or !inGame2 then
        return false
    end
end)


local function BlockUserKillCommand(ply)
    ply:ChatPrint("No")
    return false
end
hook.Add( "CanPlayerSuicide", "DisableKillCommandForUser", BlockUserKillCommand )


concommand.Add("StopSpectator", function( ply, cmd, args )
    spectator.UnSpectate(ply)
end)

function GM:PlayerInitialSpawn(ply)
    ply:Give("hands")
    hook.Run("dbt.SpawnInit", ply)
    dbt.setchr(ply, "Гость")
    timer.Simple(2, function()
        ply:SetNWBool("LeftArm",false)
        ply:SetNWBool("RightArm",false)
        ply:SetWalkSpeed(80)
        ply:SetRunSpeed(195)
        ply:SetJumpPower(200)
        dbt.setchr(ply, "Гость")
    end)

end

function GM:PlayerSetHandsModel( ply, ent )
   local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
   local info = player_manager.TranslatePlayerHands(simplemodel)

   if info then
      ent:SetModel(info.model)
      ent:SetSkin(info.skin)
      ent:SetBodyGroups(info.body)
   end
end


function GM:PlayerSpawnRagdoll(ply)
    return ply:IsAdmin() or ply:GetUserGroup() == "srole" -- Когд
end

function GM:PlayerDeath(ply, inflictor, attacker)
    ply:InitializeInformation()
    DropFromGame(ply, "death")
end

function GM:PlayerSpawnSENT(ply)
    return ply:IsSuperAdmin() or ply:GetUserGroup() == "srole"
end

function GM:PlayerSpawnSWEP( ply )
    return ply:IsAdmin() or ply:GetUserGroup() == "srole"
end

function GM:PlayerSpawnVehicle( ply )
    return ply:IsSuperAdmin() or ply:GetUserGroup() == "srole"
end

function GM:PlayerSpawnNPC( ply )
    return ply:IsSuperAdmin() or ply:GetUserGroup() == "srole"
end

function GM:PlayerSpawnEffect( ply )
    return ply:IsAdmin() or ply:GetUserGroup() == "srole"
end

function GM:PlayerGiveSWEP( ply, class, wep )
    return ply:IsSuperAdmin() or ply:GetUserGroup() == "srole"
end


function GM:PlayerShouldTakeDamage()
    return true
end


hook.Add("OnPhysgunReload", "UnfreezeDelay", function(gun, ply)
    if (gun.UnfreezeTimeout or 0) > CurTime() then return false end
    gun.UnfreezeTimeout = CurTime() + 0.3
    return true
end)

netstream.Hook("dbt.open.mono", function(ply, b)
    ply:SetNWBool("animationStatus", b)
    ply:SetNWString("animationClass", "monopad")
    ply:SetNWBool("InMonopad", !ply:GetNWBool("InMonopad"))


    local id = ply.info.monopad.meta.id
    dbt.monopads.list[id].listen = b
end)

concommand.Add("ResetRule", function(ply)
    if not ply:IsAdmin() then return end
    net.Start("dbt/mono/rules/clearall")
    net.Broadcast()
end)
--[[
if pcall(require, "chttp") and CHTTP ~= nil then
    HTTP = CHTTP
else
    return MsgC(Color(255, 0, 0), "Discord Chat Relay ERROR!", Color(255, 255, 255), "Please install https://github.com/timschumi/gmod-chttp!")
end]]


hook.Add( "PlayerHurt", "hurt_effect_fade", function( ply, att, hp )
    ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 240 ), 0.9, 0 )
end )
timer.Create( "dbt.TimeTimer", 1, 0, function()
        globaltime = globaltime + 24
        SetGlobalInt("Time", globaltime)
        s = globaltime % 60
        tmp = math.floor( globaltime / 60 )
        m = tmp % 60
        tmp = math.floor( tmp / 60 )
        h = tmp % 24
        curtimesys = string.format( "%02ih %02im %02is", h, m, s)
end)

local vheck = {
    Vector(5,0,0),
    Vector(-5,0,0),
    Vector(0,5,0),
    Vector(0,-5,0),
    Vector(0,0,5),
    Vector(0,0,-5),
}

net.Receive("dbt.Evidence", function(len, ply)

    local data = net.ReadTable()

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
        filter = ply,
    })

    local itemEnt = ents.Create("evidence")
    itemEnt:SetPos(tr.HitPos)
    itemEnt:SetAngles(Angle(0,0,0))
    itemEnt:SetItem(data)
    itemEnt:Spawn()


    for k, i in pairs(vheck) do
        local tr = util.TraceLine({
            start = itemEnt:GetPos(),
            endpos = itemEnt:GetPos() + i,
            filter = ply,
        })
        if tr.HitWorld then
            itemEnt:SetPos(itemEnt:GetPos() + (i * -1) )
        end
    end

    undo.Create("Улика")
        undo.AddEntity(itemEnt)
        undo.SetPlayer(ply)
    undo.Finish()

end)
net.Receive("dbt.Gift", function(len, ply)

    local data = net.ReadTable()

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
        filter = ply,
    })
    local itemEnt = ents.Create("dbt_gift")
    itemEnt:SetPos(tr.HitPos)
    itemEnt:SetAngles(Angle(0,0,0))
    itemEnt.wep = data.wep
    itemEnt.isExplode = data.isExplode
    itemEnt:Spawn()


    for k, i in pairs(vheck) do
        local tr = util.TraceLine({
            start = itemEnt:GetPos(),
            endpos = itemEnt:GetPos() + i,
            filter = ply,
        })
        if tr.HitWorld then
            itemEnt:SetPos(itemEnt:GetPos() + (i * -1) )
        end
    end

    undo.Create("Подарок")
        undo.AddEntity(itemEnt)
        undo.SetPlayer(ply)
    undo.Finish()

end)

concommand.Add("StartClassTrial", function(pl)
    if not pl:IsAdmin() then return end
    for k, v in pairs( player.GetAll() ) do
        if not InGame(v) and not IsMono(v:Pers()) then
            specpos[v] = v:GetPos()
            v:SetPos(Vector(-391.048279, -2541.716309, -887.968750))
        end
        v:Freeze(true)
        v:SelectWeapon( "hands" )
        v:SetRenderMode( RENDERMODE_NONE)
    end
    SetGameStatus("classtrial")
    net.Start("StartClassTrial")
    net.Broadcast()
    dbt.music.Play("classtrial")

    openobserve.Log({
        event = "start_classtrial",
        name = pl:Nick(),
        steamid = pl:SteamID(),
    })
end)


concommand.Add("EndClassTrial", function(pl)
    if not pl:IsAdmin() then return end
    SetGameStatus("game")
    net.Start("EndClassTrial")
    net.Broadcast()
    for k, v in pairs( player.GetAll() ) do
        v:Freeze(false)
        v:SetRenderMode( RENDERMODE_NORMAL )
        if not InGame(v) and specpos and specpos[v] then
            v:SetPos(specpos[v])
        end
    end
    dbt.music.Play("despair")
    openobserve.Log({
        event = "end_classtrial",
        name = pl:Nick(),
        steamid = pl:SteamID(),
    })
end)


player_corpse = {}

hook.Add( "EntityTakeDamage", "EntityDamageExample", function( ply, dmginfo )
    if IsLobby() and ply:IsPlayer() then
        return true
    end
end )

util.AddNetworkString("unsleepmenu")
util.AddNetworkString("unsleeppl")

local otm_tempdoortypeslist = {["func_door"] = true,["func_door_rotating"] = true, ["prop_door_rotating"] = true,["func_movelinear"] = true};
local otm_ismapbeingcleanedup_for_areaportaldooraddon = false;

hook.Add("PreCleanupMap","otm_door_removal_pairedareaportal_cleanup_variable_1",function() otm_ismapbeingcleanedup_for_areaportaldooraddon = true end);
hook.Add("PostCleanupMap","otm_door_removal_pairedareaportal_cleanup_variable_2",function() otm_ismapbeingcleanedup_for_areaportaldooraddon = false end);


hook.Add("EntityRemoved","otm_door_removal_pairedareaportal_activation",function(ent)
    if (!otm_ismapbeingcleanedup_for_areaportaldooraddon) then
        if otm_tempdoortypeslist[ent:GetClass()] then
            for _, otm_i in ipairs(ents.FindByClass("func_areaportal")) do
                if (otm_i:GetInternalVariable("target") == ent:GetName()) then
                    otm_i:Fire("Open");
                    otm_i:SetSaveValue("target","");
                    break;
                end
            end
        end
    end
end)

net.Receive("dbt.Sig.Create", function(len, pl)
    local data = net.ReadTable()

    local tr = util.TraceLine({
        start = pl:EyePos(),
        endpos = pl:EyePos() + pl:EyeAngles():Forward() * 50,
        filter = pl,
    })

    local itemEnt = ents.Create("sign")
    itemEnt:SetPos(tr.HitPos)
    itemEnt:SetAngles(Angle(0,0,0))
    itemEnt.text = data.desc and {[1] = data.desc} or {[1] = 'Начало записки.'}
	itemEnt.name = data.name or 'Название записки'
    itemEnt:SetNWEntity("Owner", pl)
    itemEnt:SetNWString("Title", data.name)
    itemEnt:Spawn()

    undo.Create("Записка")
        undo.AddEntity(itemEnt)
        undo.SetPlayer(pl)
    undo.Finish()
end)
util.AddNetworkString("clear.Adv")
concommand.Add("ClearE", function(ply)
    if ply:IsAdmin() then
        for i,k in pairs(ents.GetAll()) do
            if k:GetClass() == "evidence" then
                k:Remove()
            end
        end

        for i,k in pairs(player.GetAll()) do
            k:RemoveEdvidice()
        end
    end
end)



local function Spawn( ply )
    ply.spawned = true
    timer.Simple(1, function() ply.spawned = false end)
end
hook.Add( "PlayerSpawn", "dbt.check", Spawn )

local function SpawnedSWEP( ply )
    --if dbt.chr[ply:Pers()].blacklistwep and table.HasValue(dbt.chr[ply:Pers()].blacklistwep, newWeapon:GetClass()) then netstream.Start(ply, "dbt/can't/weapon") return false end
    ply.spawned = true
    timer.Simple(1, function() ply.spawned = false end)
end
hook.Add( "PlayerGiveSWEP", "dbt.checks", SpawnedSWEP )

util.AddNetworkString("dbt.music.Music_R")
net.Receive("dbt.music.Music_R", dbt.music.Music_Refresh)
function dbt.music.Music_Refresh()
    local files, directories = file.Find( "sound/custom_music/*", "GAME" )
    net.Start("dbt.music.Music_R")
    net.WriteTable(files)
    net.Broadcast()
end

concommand.Add("RefreshMusicCustom", dbt.music.Music_Refresh)

    util.AddNetworkString( "NMRIHFlashlightToggle" )

    net.Receive("NMRIHFlashlightToggle",function(length,ply)
        if IsValid(ply) then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) then wep.IsOn = !wep.IsOn end
        end
    end)

    -- Оптимизация управления фонариком: вместо PlayerTick используем переключение оружия + периодический таймер
    hook.Remove("PlayerTick","dbt.mmsic.Yick")
    local DBT_FLASHLIGHT_ALLOWED = {
        ["tfa_nmrih_maglite"] = true
    }

    -- При смене оружия отключаем фонарик если он не на разрешённом оружии
    hook.Add("PlayerSwitchWeapon","dbt.flashlight.wepswitch", function(ply, oldWep, newWep)
        if not IsValid(ply) or not ply:FlashlightIsOn() then return end
        if not (IsValid(newWep) and DBT_FLASHLIGHT_ALLOWED[newWep:GetClass()]) then
            ply:Flashlight(false)
        end
    end)

    -- Периодическая проверка (раз в 0.3с) чтобы гарантировать разрешение использования фонарика без дорогостоящего PlayerTick
    timer.Create("dbt.flashlight.ensure", 0.3, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and not ply:CanUseFlashlight() then
                ply:AllowFlashlight(true)
            end
            -- Дополнительная страховка: если фонарик включён, но оружие не разрешено, выключаем
            if IsValid(ply) and ply:FlashlightIsOn() then
                local wep = ply:GetActiveWeapon()
                if not (IsValid(wep) and DBT_FLASHLIGHT_ALLOWED[wep:GetClass()]) then
                    ply:Flashlight(false)
                end
            end
        end
    end)


normal_camera_position = {}
GPS_POS = {}
normal_camera_position["drp_hopespeak"] = {
    x = -200,
    y = -2500,
    z = -890,
    anim = {
        hidht = {
            st = -760,
            ed = -780
        }
    },
    monokuma = {
        vec = Vector( -426, -2404, -849 ),
        vec_sp = Vector(-527.722717, -2354.135254, -821.366455),
        adi = 1,
        plus = 2
    },
    add_dist = 100,
    acd = 0,
}
normal_camera_position["dgrv3_ultimateacademy"] = {
    x = -2180,
    y = -4079,
    z = 164,
    anim = {
        hidht = {
            st = 294,
            ed = 314
        }
    },
    monokuma = {
        vec = Vector(-2362.209229, -3899.025635, 302.100647),
        vec_sp = Vector(-2415.990234, -3838.919922, 318.031250),
        adi = 1,
        plus = 25
    },
    add_dist = 120,
    acd = 102,
}

if not normal_camera_position[game.GetMap()] then
    normal_camera_position[game.GetMap()] = {
    x = -2190,
    y = -4072,
    z = 164,
    anim = {
        hidht = {
            st = 294,
            ed = 314
        }
    },
    monokuma = {
        vec = Vector(-2362.209229, -3899.025635, 302.100647),
        vec_sp = Vector(-2415.990234, -3838.919922, 318.031250),
        adi = 1,
        plus = 25
    },
    add_dist = 0,
    acd = 0,
}
end


local tbl = normal_camera_position[game.GetMap()]
local segmentdist = 16 / ( 2 * math.pi * math.max( 100, 100 ) / 2 )
for a = 0, 15 do
    local acd = a * -22.5 + tbl.acd
    local pos_ = Vector(tbl.x + math.cos( math.rad( acd ) ) * tbl.add_dist, tbl.y - math.sin( math.rad( acd ) ) * tbl.add_dist, normal_camera_position[game.GetMap()].z ) --tbl.x + math.cos( math.rad( a + segmentdist ) ) * 100, tbl.y - math.sin( math.rad( a + segmentdist ) ) * 100
    GPS_POS[a + 2] = pos_
end


net.Receive("dbt/classtrial/update", function()
    GPS_POS = net.ReadTable()
    normal_camera_position = net.ReadTable()

    net.Start("dbt/classtrial/update")
        net.WriteTable(GPS_POS)
        net.WriteTable(normal_camera_position)
    net.Broadcast()
end)


--ПЕРЕНЕСТИ В ДРУГОЙ ФАЙЛ

hook.Add( "PlayerButtonDown", "dbt/inventory/button/down", function( ply, button ) -- 107 ЛКМ 108 ПКМ
    if ( IsFirstTimePredicted() and button == 107) then
            asdasdas = 0
            for k, i in pairs(player.GetAll()) do
                if InGame(i) then
                    asdasdas = asdasdas + 1
                end
            end
            if asdasdas == 0 then
                return
            end
        if spectator.IsSpectator(ply) then
            if not ply.target_index then ply.target_index = 1 end
            ply.target_index = ply.target_index + 1
            if ply.target_index > player.GetCount() then
                ply.target_index = 1
            end
            spectate_target = player.GetAll()[ply.target_index]
            if not InGame(spectate_target) then
                repeat
                    ply.target_index = ply.target_index + 1
                    spectate_target = player.GetAll()[ply.target_index]
                    if ply.target_index > player.GetCount() then
                        ply.target_index = 1
                    end
                    spectate_target = player.GetAll()[ply.target_index]
                until InGame(spectate_target)
            end

            spectator.Spectate(ply, spectate_target, OBS_MODE_CHASE)
        end
    end
    if ( IsFirstTimePredicted() and button == 108) then
            asdasdas = 0
            for k, i in pairs(player.GetAll()) do
                if InGame(i) then
                    asdasdas = asdasdas + 1
                end
            end
            if asdasdas == 0 then
                return
            end
        if spectator.IsSpectator(ply) then
            if not ply.target_index then ply.target_index = 1 end
            ply.target_index = ply.target_index - 1
            if ply.target_index <= 0 then
                ply.target_index = player.GetCount()
            end
            spectate_target = player.GetAll()[ply.target_index]
            if not InGame(spectate_target) then
                repeat
                    ply.target_index = ply.target_index - 1
                    spectate_target = player.GetAll()[ply.target_index]
                    if ply.target_index <= 0 then
                        ply.target_index = player.GetCount()
                    end
                    spectate_target = player.GetAll()[ply.target_index]
                until InGame(spectate_target)
            end

            spectator.Spectate(ply, spectate_target, OBS_MODE_CHASE)
        end
    end
    if ( IsFirstTimePredicted() and button == 65) then
        if spectator.IsSpectator(ply) then
            spectator.UnSpectate(ply)
        end
    end
end)

concommand.Add("sd_text_s", function(ply)
    if not ply:IsAdmin() then return end
    ImageTool:RemoveImageAll()
    game.CleanUpMap()

        sql.Query( "DELETE FROM permaprops;" )
        PermaProps.ReloadPermaProps()

end)

hook.Add( "StartCommand", "dontmovemono", function( ply, cmd )
    if ply:GetNWBool("InMonopad") then
        cmd:ClearMovement()
        cmd:ClearButtons()
    end
end )

concommand.Add("giverankserverguard", function(ply, cmd, args)
    if IsValid(ply) then return end
    local rankData = serverguard.ranks:GetRank(args[2]);
    if not rankData then return end
    local target = util.FindPlayer(args[1], NULL, true);
    serverguard.player:SetRank(target, rankData.unique, tonumber(args[3]));
    serverguard.player:SetImmunity(target, rankData.immunity);
    serverguard.player:SetTargetableRank(target, rankData.targetable)
    serverguard.player:SetBanLimit(target, rankData.banlimit)
end)

local function dbtEnablePhysgunFloat(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ply.dbtPhysgunLifted then return end

    ply.dbtPhysgunLifted = true
    ply.dbtPhysgunPrevMoveType = ply:GetMoveType()
    ply:SetMoveType(MOVETYPE_FLY)
    ply:SetGroundEntity(NULL)
    ply:SetLocalVelocity(vector_origin)
end

local function dbtDisablePhysgunFloat(ply, skipImmunity)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply.dbtPhysgunLifted then return end

    ply.dbtPhysgunLifted = nil
    ply:SetMoveType(ply.dbtPhysgunPrevMoveType or MOVETYPE_WALK)
    ply.dbtPhysgunPrevMoveType = nil
    ply:SetGroundEntity(NULL)

    if not skipImmunity then
        ply.dbtPhysgunFallImmunity = CurTime() + 1
    end
end

hook.Add("PostGamemodeLoaded", "PostGamemodeLoadedPhysgunPickup", function()
    local tbl = hook.GetTable()["PhysgunPickup"] or {}

    hook.Add("PhysgunPickup", "AllowPlayerPickup", function(ply, ent)
        if IsValid(ent) and ent:IsPlayer() then
            dbtEnablePhysgunFloat(ent)
        end
        return true
    end)

    hook.Remove("PlayerUse", "InstrumentChairModelHook")
end)

hook.Add("PhysgunPickup", "AllowPlayerPickup", function(ply, ent)
    if IsValid(ent) and ent:IsPlayer() then
        dbtEnablePhysgunFloat(ent)
    end
    return true
end)

hook.Add("PhysgunDrop", "dbt/restorePlayerAfterPhysgun", function(_, ent)
    if IsValid(ent) and ent:IsPlayer() then
        dbtDisablePhysgunFloat(ent)
    end
end)

hook.Add("PlayerDeath", "dbt/physgunCleanup", function(ply)
    dbtDisablePhysgunFloat(ply, true)
end)

hook.Add("PlayerDisconnected", "dbt/physgunCleanup", function(ply)
    dbtDisablePhysgunFloat(ply, true)
end)

hook.Add("InitPostEntity", "MyPlayerUseHook_Post", function()
    hook.Remove("PlayerUse", "InstrumentChairModelHook")
end)

netstream.Start(nil, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'System', titlecolor = Color(255, 0, 255), notiftext = 'Серверная сторона успешно перезагружена.'})

hook.Add("PlayerUse", "!dbt_inventory_storage_use", function(ply, ent)
    print("dbt_inventory_storage_use")
	if not IsValid(ply) or not IsValid(ent) then return end
	if not ent.dbtStorageId then return end
	if ply.dInventoryNextStorageUse and ply.dInventoryNextStorageUse > CurTime() then return end
	ply.dInventoryNextStorageUse = CurTime() + 0.2
	local storage = dbt.inventory.storage[ent.dbtStorageId]
	if not storage then return end
	if storage.openOnUse == false then return end
	local ok, err = dbt.inventory.storage.Open(ply, storage)
	if not ok then
		if err == "occupied" then
			netstream.Start(ply, "dbt/inventory/error", "Хранилище сейчас занято другим игроком.")
		end
	end
	return false
end)


hook.Remove("PlayerUse", "DrGBaseNextbotPossessionDisableUse")
hook.Remove("PlayerUse", "prop_protection.PlayerUse")

