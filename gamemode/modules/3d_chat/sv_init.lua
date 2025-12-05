util.AddNetworkString("rp.Chat.Command")
util.AddNetworkString("Chat_say")
util.AddNetworkString("advert.Start")


local function CreateRay(startPos, endPos, filter)
    local trace = {}
    trace.start = startPos
    trace.endpos = endPos
    trace.filter = function(ent)
      if !ent:IsPlayer() then  end
      if filter[1] == ent then return false end
      if filter[2] == ent then return true end
      if ent:IsWeapon() and filter[2] == ent.Owner then return true end
      if "func_door_rotating" == ent:GetClass() and string.StartsWith(ent:GetModel(), "*") then  return true end
      if "func_door" == ent:GetClass() and string.StartsWith(ent:GetModel(), "*") then return true end
    end
    local r = util.TraceLine(trace)
    return r
end
ray1 = false
ray2 = false
cdTrace = 0 
function CanHear(player1, player2)
    if player1 == player2 then return true end
    numRays = 20
    local filter = {player1, player2}
    local player1Pos = player1:EyePos() 
    local player2Pos = player2:EyePos() - Vector(0,0,10)
    
    local player1ToPlayer2 = player2Pos - player1Pos
    local player2ToPlayer1 = player1Pos - player2Pos
    
    local step = 360 / numRays
    local result = true
    local tblSend = {}
    for i = 0, 360, 10 do
        ray1 = nil
        ray2 = nil
        local ang = player1:GetAngles()
        local ang = Angle(0, ang.y, ang.r)
        ang:RotateAroundAxis(ang:Up(), i)
        
        local endPos = player1Pos + ang:Forward() * 300
        local ray1 = CreateRay(player1Pos, endPos, filter)
        local ray2 = CreateRay(ray1.HitPos or endPos, player2Pos, filter) 

        if ray2 and ray2.Hit and IsValid(ray2.Entity) and ray2.Entity:IsPlayer() then 
            return true 
        end
    end
    
    return false
end

hook.Add( "PlayerCanHearPlayersVoice", "rp.Voice", function( listener, talker )
    if spectator.IsSpectator(talker) then return false end
    if IsClassTrial()  then 
        if InGame(talker) then 
            return true
        end
        if IsMono(talker:Pers()) then 
            return true
        end
        return false
    end

    --spectator.GetTarget(player)

    if listener:GetPos():Distance( talker:GetPos() ) < 45 and talker:KeyDown(IN_WALK) then
        if CanHear(talker, listener) or listener:GetMoveType() == MOVETYPE_NOCLIP or spectator.IsSpectator(listener) then return true,true end
    elseif talker:KeyDown(IN_WALK) then 
        return false 
    end

    if listener:GetPos():Distance( talker:GetPos() ) < 700 and talker:KeyDown(IN_SPEED) then
        if CanHear(talker, listener) or listener:GetMoveType() == MOVETYPE_NOCLIP or spectator.IsSpectator(listener) then return true,true end
    elseif listener:GetPos():Distance( talker:GetPos() ) < 300 then 
        if CanHear(talker, listener) or listener:GetMoveType() == MOVETYPE_NOCLIP or spectator.IsSpectator(listener) then return true,true end
    else 
        return false
    end

    return false 
end )

function chat_say(ply,text)

    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
        if v:IsPlayer() then
            net.Start("Chat_say")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end

end


function dbt.PlayerSay(ply, text)
    local text_s = string.Split( text, " " )
    local commandText = string.lower(text_s[1])
    local text = string.lower(text)
    if RP.chat.commands[commandText] then 
        openobserve.Log({
            event = "chat_command",
            name = ply:Nick(),
            steamid = ply:SteamID(),
            userid = ply:UserID(),
            ip = ply:IPAddress(),
            command = command,
            message = text
        })
        RP.chat.commands[commandText].server(ply, text)
        return ""
    end

    local a,e = cats.config.triggerText(ply, text) 
    if a then   
        cats:DispatchMessage(ply, ply:SteamID(),e)
        openobserve.Log({
            event = "open_report",
            name = ply:Nick(),
            steamid = ply:SteamID(),
            userid = ply:UserID(),
            ip = ply:IPAddress(),
            message = text
        })

        return''
    end 

    openobserve.Log({
        event = "chat_message",
        name = ply:Nick(),
        steamid = ply:SteamID(),
        userid = ply:UserID(),
        ip = ply:IPAddress(),
        message = text
    })

    chat_say(ply,text)
    return ""
end

hook.Add("PlayerSay", "dbt.Chat.Say", function( ply, text )
    return dbt.PlayerSay(ply, text)
end)

