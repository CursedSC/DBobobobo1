
util.AddNetworkString("anim.Start")
util.AddNetworkString("anim.End")
util.AddNetworkString("sv.Update.charactersInGame")
util.AddNetworkString("dbt.GetTable")
util.AddNetworkString("dbt.GetInfo")
util.AddNetworkString("admin.SetChar")
util.AddNetworkString("admin.SetAlive")
util.AddNetworkString("admin.SetAliveChr")
util.AddNetworkString("admin.AddInGame")
util.AddNetworkString("dbt.Charactrs")
util.AddNetworkString("dbt.StartGame")
util.AddNetworkString("dbt.ShowScreen")
util.AddNetworkString("dbt/classtrial/update/mnualy")
util.AddNetworkString("dbt.EndGame")
util.AddNetworkString("dbt.EndClassTrial")
util.AddNetworkString("investigation.St")
util.AddNetworkString("dbt/inventory/update")
util.AddNetworkString("dbt.ShowScreenDeath")
util.AddNetworkString("Noise.Start")

net.Receive("admin.SetChar", function(len, admin)
    if not IsValid(admin) or not admin:IsAdmin() then return end
    local target = net.ReadEntity()
    local chr = net.ReadString()
    if not IsValid(target) then return end
    dbt.setchr(target, chr)
end)

function HandleAdminSetAlive(adm, plyTarget, alive)
    if not IsValid(plyTarget) then return end

    if IsValid(plyTarget.deadico) then
        plyTarget.deadico:Remove()
    end

    local chr = plyTarget:GetNWString("dbt.CHR")

    if charactersInGame[chr] then
        plyTarget:SetNWBool("InGame", alive)
        charactersInGame[chr].alive = alive

        net.Start("dbt.Charactrs")
        net.WriteTable(charactersInGame)
        net.Broadcast()
        return
    end

    if #Spots < 17 then
        AddInGame(plyTarget)

        if InGame(plyTarget) and not IsMono(plyTarget:Pers()) then
            Spots[#Spots + 1] = {
                char = plyTarget:Pers(),
                emote = 1,
                pos = ct.pos[game.GetMap()][#Spots + 1].vec
            }
            plyTarget:SetNWInt("Index", #Spots)
            plyTarget.brokenleft = false
            plyTarget.brokenright = false
        end

        net.Start("dbt.GetTable")
        net.WriteTable(Spots)
        net.Broadcast()
        return
    end

    if IsValid(adm) then
        adm:ChatPrint("Таблица переполнена!")
    end
end

net.Receive("admin.SetAlive", function(len, adm)
    if not IsValid(adm) or not adm:IsAdmin() then return end

    local plyTarget = net.ReadEntity()
    local alive = net.ReadBool()

    HandleAdminSetAlive(adm, plyTarget, alive)
end)

net.Receive("admin.SetAliveChr", function(len, adm)
    if not IsValid(adm) or not adm:IsAdmin() then return end
    local character = net.ReadString()
    local alive = net.ReadBool()
    local info = charactersInGame and charactersInGame[character]
    if not info then return end

    local plyTarget = player.GetBySteamID(info.steamID)
    if IsValid(plyTarget) and IsValid(plyTarget.deadico) then plyTarget.deadico:Remove() end
    if IsValid(plyTarget) then
        plyTarget:SetNWBool("InGame", alive)
    end

    info.alive = alive

    net.Start("dbt.Charactrs")
        net.WriteTable(charactersInGame)
    net.Broadcast()
end)

net.Receive("admin.AddInGame", function(len, adm)
    if not IsValid(adm) or not adm:IsAdmin() then return end
    local plyTarget = net.ReadEntity()
    if not IsValid(plyTarget) then return end
    if IsValid(plyTarget.deadico) then plyTarget.deadico:Remove() end
    AddInGame(plyTarget)

    Spots[#Spots + 1] = {
        char = plyTarget:Pers(),
        emote = 1,
        pos = ct.pos[game.GetMap()][#Spots + 1].vec
    }

    plyTarget:SetNWInt("Index", #Spots)

    net.Start("dbt.GetTable")
        net.WriteTable(Spots)
    net.Broadcast()
end)




Spots = {}
net.Receive("dbt.GetInfo", function(len, ply)
    net.Start("dbt.GetTable")
        net.WriteTable(Spots)
    net.Send(ply)

    net.Start("dbt.Charactrs")
        net.WriteTable(charactersInGame)
    net.Send(ply)
    for character, data in pairs(charactersInGame) do 
        if data.steamID == ply:SteamID() then 
            local current_index = 0
            for i = 1, #Spots do 
                if Spots[i].char == character then 
                    current_index = i
                end
            end
            ply:SetNWInt("Index", current_index)
            ply:SetNWBool("InGame", data.alive) 
        end
    end
end)

net.Receive("sv.Update.charactersInGame", function(len, admin)
    if not IsValid(admin) or not admin:IsAdmin() then return end
    charactersInGame = net.ReadTable()
end)


-- removed unused animations and RunAnimationStand

specpos = {}
SetGlobalInt("PhaseStartGame", 0) 

netstream.Hook("dbt/characters/admin/list", function(ply)
    netstream.Start(ply, "dbt/characters/admin/list", charactersInGame)
end)

netstream.Hook("dbt/characters/admin/switchchar", function(admin, char, target) 
    if not IsValid(admin) or not admin:IsAdmin() then return end
    charactersInGame[char].steamID = target:SteamID()
    if IsValid(charactersInGame[char].playerEnt) then 
        charactersInGame[char].playerEnt:SetNWBool("InGame", false) 
    end

    local idMonopad = dbt.monopads.FindByCharacter(char)
    if idMonopad then dbt.monopads.list[idMonopad] = nil end
    local idMonopad = dbt.monopads.FindByCharacter(target:Pers())
    if idMonopad then dbt.monopads.list[idMonopad] = nil end

    target:SetNWBool("InGame", true)
    charactersInGame[char].playerEnt = target

    charactersInGame[target:Pers()] = table.Copy(charactersInGame[char])


    Spots[charactersInGame[char].spotId].char = target:Pers()
    charactersInGame[target:Pers()].spotId = charactersInGame[char].spotId

    target.sign_count = 5
    target:SetNWInt("Index", charactersInGame[target:Pers()].spotId)
    target.brokenleft, target.brokenright = false, false
    target:InitializeInformation()
    target.FirstDamage, target.items = true, {}

    netstream.Start(target, "dbt/inventory/info", {}, {})
    dbt.inventory.SendUpdate(target)

    for _, stat in ipairs({"hunger", "sleep", "Stamina", "water"}) do
        target:SetNWInt(stat, 100)
    end

    local id = dbt.monopads.New(target:Pers())
    dbt.inventory.additem(target, 1, { owner = target:Pers(), id = id })
    dbt.inventory.additem(target, 2, { owner = target:Pers() })
    dbt.initCustom(target)
    dbt.resetWounds(target)

    charactersInGame[char] = nil

    net.Start("dbt.Charactrs")
        net.WriteTable(charactersInGame)
    net.Broadcast() 

    net.Start("dbt.GetTable")
    net.WriteTable(Spots)
    net.Broadcast()
end)


local function initializePlayer(v, spotIndex)

        local spotPos = teleportpos[spotIndex]
        v:SetPos(spotPos)
        Spots[spotIndex] = { char = v:Pers(), emote = 1, pos = Vector(0, 0, 0) }

        v.sign_count = 5
        v:SetNWInt("Index", spotIndex)
        v.brokenleft, v.brokenright = false, false
        v:InitializeInformation()
        v.FirstDamage, v.items = true, {}

    netstream.Start(v, "dbt/inventory/info", {}, {})
    dbt.inventory.SendUpdate(v)

        for _, stat in ipairs({"hunger", "sleep", "Stamina", "water"}) do
            v:SetNWInt(stat, 100)
        end
        charactersInGame[v:Pers()].spotId = spotIndex
        local id = dbt.monopads.New(v:Pers())
        dbt.inventory.additem(v, 1, { owner = v:Pers(), id = id })
        dbt.inventory.additem(v, 2, { owner = v:Pers() })
        dbt.initCustom(v)
        dbt.resetWounds(v)
        local weapons = dbt.chr[v:Pers()] and dbt.chr[v:Pers()].weapon
        if weapons then
            v.spawned = true
            for _, weapon in ipairs(weapons) do
                v:Give(weapon)
            end
            v.spawned = false
        end
    end

local function initBeds()
    if game.GetMap() == "drp_hopespeak" then
           local bedsData = util.JSONToTable(file.Read("beds.json", "DATA") or "{}")
           for _, info in pairs(bedsData) do
               local bed = ents.Create("prop_vehicle_prisoner_pod")
               bed:SetPos(info.pos)
               bed:SetModel("models/vehicles/prisoner_pod_inner.mdl")
               bed:SetAngles(info.angle)

               bed:Spawn()
               bed:SetMoveType(MOVETYPE_NONE)
               bed:SetCollisionGroup(COLLISION_GROUP_WORLD)
               bed:SetColor(Color(255, 255, 255, 0))
               bed:SetRenderMode(RENDERMODE_TRANSCOLOR)
        end
    end
end

net.Receive("dbt.StartGame", function(len, admin)
    if not IsValid(admin) or not admin:IsAdmin() then return end
    if #teleportpos < 17 then return end

    dbt.monopads = dbt.monopads or {}
    dbt.monopads.list = {}
    dbt.monopads.allchat = {}
    dbt.monopads.groups = {}
    dbt.monopads.groupSeq = 0
    if dbt.monopads.ResetChats then
        dbt.monopads.ResetChats(true)
    end
    SetGameStatus("game")
    SetGlobalInt("round", 0)

    classtrialpos, charactersInGame, Spots = {}, {}, {}
    Spots[1] = { char = "Монокума", emote = 1, pos = Vector(0, 0, 0) }

    LockAllDoors()

    for _, player in ipairs(player.GetAll()) do
        AddInGame(player)
        if InGame(player) and not IsMono(player:Pers()) then
            initializePlayer(player, #Spots + 1)
        end
        if IsMono(player:Pers()) then 
            player.FirstDamage, player.items = true, {}
            netstream.Start(player, "dbt/inventory/info", {}, {})
            dbt.inventory.SendUpdate(player)
            local id = dbt.monopads.New(player:Pers())
            dbt.inventory.additem(player, 1, { owner = player:Pers(), id = id })
        end
    end

    net.Start("dbt.GetTable")
    net.WriteTable(Spots)
    net.Broadcast()

    net.Start("dbt.ShowScreen")
    net.Broadcast()

    net.Start("dbt/classtrial/update/mnualy")
    net.WriteTable(GPS_POS)
    net.WriteTable(normal_camera_position)
    net.Broadcast()

    initBeds()

    -- Установка глобального состояния игры
    SetGlobalInt("PhaseStartGame", 1)
end)

local standAnims = {
    "stand_up1",
    "stand_up2",
    "stand_up3",
}
netstream.Hook("dbt/game/start/phase2", function()
    local standAnims = {
        "stand_up1",
        "stand_up2",
        "stand_up3",
    }
    for _, v in pairs(player.GetAll()) do
        if not InGame(v) then continue end
        local anim = standAnims[math.random(#standAnims)]
        netstream.Start(nil, "dbt/game/start/standup", v, anim)
    end
end)

net.Receive("dbt.EndGame", function(len, admin)
    if not IsValid(admin) or not admin:IsAdmin() then return end
    SetGameStatus("preparation")
    for k, v in pairs(player.GetAll()) do
        DropFromGame(v, "sdfsd")
    end
    for k, i in pairs(GLOVAL_TABLE_OF_DEATHICO) do 
        if IsValid(i) then i:Remove() end
    end
end)

net.Receive("dbt.EndClassTrial", function(len, admin)
    if not IsValid(admin) or not admin:IsAdmin() then return end
    local d = net.ReadString()
    net.Start("dbt.ShowScreenDeath")
    net.Broadcast()
end)--

hook.Add( "EntityTakeDamage", "EntityDamageExample", function( target, dmginfo )
    if IsLobby() then
        dmginfo:ScaleDamage( 0 ) 
    end
end )

local charapter_img1 = {
    [0] = "prolog",
    [1] = "stage_1",
    [2] = "stage_2",
    [3] = "stage_3",
    [4] = "stage_4",
    [5] = "stage_5",
    [6] = "stage_6",
    [7] = "stage_7",
    [8] = "epilog",
}

netstream.Hook("dbt/change/lvl", function(ply, newGameStatus)
   SetGlobalInt("round", newGameStatus)
    -- Store chapter image as a string global
    SetGlobalString("gameStatus_mono", charapter_img1[newGameStatus] or "prolog")
end)

concommand.Add("SetAllStats", function(ply)
    if not ply:IsAdmin() then return end 

    for k, v in pairs(player.GetAll()) do
        v:SetNWInt("hunger", 100)
        v:SetNWInt("sleep", 100)
        v:SetNWInt("Stamina", 100)
        v:SetNWInt("water", 100)
    end
end)

concommand.Add("startInve", function(ply)
    if not ply:IsAdmin() then return end 
    net.Start("investigation.St")
    net.Broadcast()
    dbt.music.Play("investigation")
end)

ListOfCorpse = ListOfCorpse or {}
function dbt.AddCorpse(ent)
    ent.sees = {}
    timer.Create("corpseCheck"..ent:EntIndex(), 0, 0, function()
        for k, v in pairs( player.GetAll() ) do
	    	local tr = util.TraceLine( util.GetPlayerTrace( v ) )
	    	local entt = tr.Entity
	    	if entt == ent then
                ent.sees = ent.sees or {}
                if not InGame(v) or IsMono(v:Pers()) or ent.sees[v] then 
                    continue
                end
                
                ent.sees[v] = true
                local ran = math.random(1, 3)
                net.Start("Noise.Start")
				    net.WriteFloat(ran)
				net.Send(v) 
				netstream.Start(v, "dbt.music.death", ran)
            end
        end
        if table.Count(ent.sees) >= 3 then
		    ent.adverted = true
		    timer.Simple(18, function()
		    	dbt.music.Play("investigation")
		    	net.Start("investigation.St")
		    	net.Broadcast()
		    end)
            timer.Remove("corpseCheck"..ent:EntIndex())
	    end

    end)
end


--[[	for k, v in pairs( player.GetAll() ) do
		local tr = util.TraceLine( util.GetPlayerTrace( v ) )
		local ent = tr.Entity
		if ent == self then
			if v == self.keller or self.sees[v] or not InGame(v) or IsMono(v:Pers()) then return end
			self.sees[v] = true
			self.see = self.see + 1
				local ran = math.random(1, 3)
				net.Start("dbt.music.death")
				net.WriteFloat(ran)
				net.Send(v)
				net.Start("Noise.Start")
				net.WriteFloat(ran)
				net.Send(v)
		end
	end]]