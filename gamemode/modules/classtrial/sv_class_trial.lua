--[[util.AddNetworkString("classtrial.ItsArgue")
util.AddNetworkString("classtrial.ChangeViewToPlayer")
util.AddNetworkString("classtrial.Disclaimer")
util.AddNetworkString("classtrial.+voicerecord_ply")
util.AddNetworkString("classtrial.-voicerecord_ply")
util.AddNetworkString("cclasstrial.NetRandom")
util.AddNetworkString("ChangeSprite")

net.Receive("ChangeSprite", function(len, ply)
	local index = net.ReadFloat()
	if IsMono(ply:Pers()) then
		Spots[1].emote = index
		net.Start("dbt.GetTable")
			net.WriteTable(Spots)
		net.Broadcast()
	else
		Spots[ply:GetNWInt("Index")].emote = index
		net.Start("dbt.GetTable")
			net.WriteTable(Spots)
		net.Broadcast()
	end
end)


local CanChangeArgue = true
canchagecam = true
cd_last_ch = 0
net.Receive("classtrial.+voicerecord_ply", function()
	local localplayer = net.ReadEntity()
	if localplayer:IsTyping() then return end
	if not InGame(localplayer) and not IsMono(localplayer:Pers()) then return end
	if not canchagecam and not IsMono(localplayer:Pers()) or cd_last_ch > CurTime() then return end
	cd_last_ch = CurTime() + 2
	canchagecam = false
	net.Start("classtrial.ItsArgue")
		net.WriteFloat(0)
	net.Broadcast()
	local rval = math.random(2, 20)
    net.Start("cclasstrial.NetRandom")
		net.WriteFloat(math.random(2, 20))
	net.Broadcast()
	net.Start("classtrial.ChangeViewToPlayer")
		net.WriteEntity(localplayer)
	net.Broadcast()
end)

net.Receive("classtrial.-voicerecord_ply", function()

	if CanChangeArgue then canchagecam = true end
end)

net.Receive("classtrial.Disclaimer", function()
	local localplayer = net.ReadEntity()
	if localplayer:IsTyping() then return end
	if not InGame(localplayer) and not IsMono(localplayer:Pers()) then return end
	canchagecam = false
	if CanChangeArgue or IsMono(localplayer:Pers()) then
	net.Start("classtrial.ItsArgue")
		net.WriteFloat(1)
	net.Broadcast()
	net.Start("classtrial.ChangeViewToPlayer")
		net.WriteEntity(localplayer)
	net.Broadcast()
	CanChangeArgue = false
		timer.Create("ArgueCollDown", 15, 1, function()
	        CanChangeArgue = true
	    end)
	    timer.Create("ArgueCollDownSS", 15, 1, function()
	        canchagecam = true
	    end)
	end
end)

local glav_type = {}
glav_type["prolog"] = 1

for i = 1,6 do
    glav_type["stage_"..i] = i+1
end

glav_type["epilog"] = table.Count(glav_type)

netstream.Hook("dbt/classtrial/evidence_toall", function(ply, evidence, location)
	if evidence.IsActivated then return end

	for k, v in pairs(player.GetAll()) do
		netstream.Start(v, "dbt/classtrial/evidence_toall/design", evidence, ply:Pers(), location)
		local ishas
		if not v.info.monopad or not v.info.monopad.meta then netstream.Start(v, "dbt/inventory/error", "У вас нет монопада!") continue end
		local round = GetGlobalString("gameStatus_mono")
		if not v.info.monopad.meta.edv then
			v.info.monopad.meta.edv = {}
		end
		]]
		--[[
		if not v.info.monopad.meta.edv[glav_type[round]] --[[then
			v.info.monopad.meta.edv[glav_type[round]] --[[= {}
		end

		for a, b in pairs(v.info.monopad.meta.edv[glav_type[round]]--[[) do
			if evidence.whouse[v] then
				ishas = true
				break
			end
		end

		if ishas then continue end
		if v == ply then continue end
		if !InGame(v) then continue end

		evidence.whouse[v] = true
		v.info.monopad.meta.edv[glav_type[round--[[ = v.info.monopad.meta.edv[glav_type[round]] --[[or {}
		table.insert(v.info.monopad.meta.edv[glav_type[round]]--[[, evidence)

		netstream.Start(v, "dbt/inventory/info", v.info)

		net.Start("dbt.AddEvidence")
			net.WriteTable(evidence)
		net.Send(v)
	end
end)
]]

util.AddNetworkString("classtrial.ItsArgue")
util.AddNetworkString("classtrial.ChangeViewToPlayer")
util.AddNetworkString("classtrial.Disclaimer")
util.AddNetworkString("classtrial.+voicerecord_ply")
util.AddNetworkString("classtrial.-voicerecord_ply")
util.AddNetworkString("cclasstrial.NetRandom")
util.AddNetworkString("ChangeSprite")

-- Improved variable naming for clarity
local canChangeArgue = true
local canChangeCam = true
local cooldownLastChange = 0

-- Helper function to update emotes
local function UpdatePlayerEmote(player, emoteIndex)
    local spotIndex = IsMono(player:Pers()) and 1 or player:GetNWInt("Index")
    Spots[spotIndex].emote = emoteIndex
    
    net.Start("dbt.GetTable")
        net.WriteTable(Spots)
    net.Broadcast()
end

-- Helper function to check if player can participate
local function CanParticipate(player)
    if player:IsTyping() then return false end
    if not InGame(player) and not IsMono(player:Pers()) then return false end
    return true
end

-- Helper function to change view to player
local function ChangeViewToPlayer(player, argueType)
    net.Start("classtrial.ItsArgue")
        net.WriteFloat(argueType)
    net.Broadcast()
    
    net.Start("classtrial.ChangeViewToPlayer")
        net.WriteEntity(player)
    net.Broadcast()
end

net.Receive("ChangeSprite", function(len, player)
    local emoteIndex = net.ReadFloat()
    UpdatePlayerEmote(player, emoteIndex)
end)

net.Receive("classtrial.+voicerecord_ply", function()
    local player = net.ReadEntity()
    if not CanParticipate(player) then return end
    
    -- Check cooldown and permissions
    if (not canChangeCam and not IsMono(player:Pers())) or cooldownLastChange > CurTime() then return end
    
    cooldownLastChange = CurTime() + 2
    canChangeCam = false
    
    ChangeViewToPlayer(player, 0)
    
    -- Send random value for animation
    net.Start("cclasstrial.NetRandom")
        net.WriteFloat(math.random(2, 20))
    net.Broadcast()
end)

net.Receive("classtrial.-voicerecord_ply", function()
    if canChangeArgue then canChangeCam = true end
end)

net.Receive("classtrial.Disclaimer", function()
    local player = net.ReadEntity()
    if not CanParticipate(player) then return end
    
    canChangeCam = false
    
    if canChangeArgue or IsMono(player:Pers()) then
        ChangeViewToPlayer(player, 1)
        
        canChangeArgue = false
        
        -- Set timers for cooldowns
        timer.Create("ArgueCollDown", 15, 1, function()
            canChangeArgue = true
        end)
        
        timer.Create("ArgueCollDownCam", 15, 1, function()
            canChangeCam = true
        end)

        openobserve.Log({
			event = "disclaimer",
			name = ply:Nick(),
			steamid = ply:SteamID(),
            character = ply:Pers(),
		})
    end
end)

-- Chapter type mapping
local chapterType = {}
chapterType["prolog"] = 1

for i = 1, 6 do
    chapterType["stage_"..i] = i + 1
end

chapterType["epilog"] = table.Count(chapterType)

-- Evidence handling
netstream.Hook("dbt/classtrial/evidence_toall", function(player_, evidence, location)
    if evidence.IsActivated then return end

    for _, targetPlayer in pairs(player.GetAll()) do
        netstream.Start(targetPlayer, "dbt/classtrial/evidence_toall/design", evidence, player_:Pers(), location)
        
        -- Check if player has monopad
        if not targetPlayer.info.monopad or not targetPlayer.info.monopad.meta then 
            netstream.Start(targetPlayer, "dbt/inventory/error", "У вас нет монопада!") 
            continue 
        end
        
        local round = GetGlobalString("gameStatus_mono")
        
        -- Initialize evidence storage if needed
        if not targetPlayer.info.monopad.meta.edv then
            targetPlayer.info.monopad.meta.edv = {}
        end
        
        local chapterIndex = chapterType[round]
        if not targetPlayer.info.monopad.meta.edv[chapterIndex] then
            targetPlayer.info.monopad.meta.edv[chapterIndex] = {}
        end

        -- Check if player already has this evidence
        local hasEvidence = false
        for _, existingEvidence in pairs(targetPlayer.info.monopad.meta.edv[chapterIndex]) do
            if evidence.whouse[targetPlayer] then
                hasEvidence = true
                break
            end
        end

        -- Skip if player already has evidence, is the sender, or not in game
        if hasEvidence or targetPlayer == player or not InGame(targetPlayer) then continue end

        -- Add evidence to player's monopad
        evidence.whouse[targetPlayer] = true
        targetPlayer.info.monopad.meta.edv[chapterIndex] = targetPlayer.info.monopad.meta.edv[chapterIndex] or {}
        table.insert(targetPlayer.info.monopad.meta.edv[chapterIndex], evidence)

        -- Notify player
        netstream.Start(targetPlayer, "dbt/inventory/info", targetPlayer.info)
        net.Start("dbt.AddEvidence")
            net.WriteTable(evidence)
        net.Send(targetPlayer)
    end
end)