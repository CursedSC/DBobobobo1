RP = {}
RP.chat = {}
RP.chat.commands = {}
if CLIENT then
    local ScreenWidth = ScreenWidth or ScrW()
    local ScreenHeight = ScreenHeight or ScrH()

    local function weight_source(x)
        return ScreenWidth / 1920  * x
    end

    local function hight_source(x)
        return ScreenHeight / 1080  * x
    end

    local function Alpha(pr)
        return (255 / 100) * pr
    end
end
function RP.chat.register( command, func, func_c )
    RP.chat.commands[command] = {
        server = func,
        client = func_c,
    }
end

local function s_func(ply,text)
    local try = math.random( 1, 2 )
    local text = string.TrimLeft(text, "/try")

    if try == 1 then
        a = true
    else
        a = false
    end

    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
                net.WriteString("/try")
                net.WriteString(text)
                net.WriteEntity(ply)
                net.WriteBool(a)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local bool = net.ReadBool()
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)

    if bool then
        dbt:AddPlayerSay(playerr, {color_white, data}, " УДАЧНО выполняет действие:", false, false)
    else
        dbt:AddPlayerSay(playerr, {color_white, data}, " НЕУДАЧНО выполняет действие:", false, false)

    end
end



RP.chat.register( "/try", s_func, c_func )

local function s_func(ply,text)

    local text = string.TrimLeft(text, "/w")


    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 150) ) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
                net.WriteString("/w")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
    dbt:AddPlayerSay(playerr, {COLOR_WHITE_DEM, data}, " говорит шепетом:")

end

RP.chat.register( "/w", s_func, c_func )


local function s_func(ply,text)

    local text = string.TrimLeft(text, "/y")


    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 600) ) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
                net.WriteString("/y")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)

    dbt:AddPlayerSay(playerr, {COLOR_WHITE_DEM, data}, " кричит:")

end

RP.chat.register( "/y", s_func, c_func )

local function s_func(ply,text)

    local text = string.TrimLeft(text, "/me ")

    local a = {type  = "rp", text = "`["..CONFIG.ServerName.."]` **[/me]**\n[ "..ply:Name().." | "..ply:Pers().." | "..ply:SteamID().." ]\n\n>>> "..text}
    sockethook.RunCommand("logs "..util.TableToJSON(a) )

    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/me")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()

    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
    if LocalPlayer():InFov(playerr, 88) or playerr == LocalPlayer() then
        dbt:AddPlayerSay(playerr, {color_white, data}, " действует:")
    else
        dbt:AddPlayerSay(playerr, {color_white, data}, " действует:", true)
    end


end



RP.chat.register( "/me", s_func, c_func )

local function s_func(ply,text)
    local text = string.TrimLeft(text, "//")

    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("//")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    dbt:AddPlayerSay(playerr, {color_white, data}, " пишет:", false, true)
end



RP.chat.register( "//", s_func, c_func )


local function s_func(ply,text)

    local text = string.TrimLeft(text, "/roll")

    if ply:Pers() == "Нагито Комаэда" then


        local lucky_roll = math.random(90,100)
        local bad_roll = math.random(1, 10)
        local change = math.random(1, 2)

        for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
            if v:IsPlayer() then
                net.Start("rp.Chat.Command")
                    net.WriteString("/roll")
                    net.WriteEntity(ply)
                    if change == 1 then
                        net.WriteFloat(lucky_roll)
                        CURRENT_ROLL = lucky_roll
                    else
                        net.WriteFloat(bad_roll)
                        CURRENT_ROLL = bad_roll
                    end
                net.Send(v)
            end
        end
        local a = {type  = "rp", text = "`["..CONFIG.ServerName.."]` **[/roll]**\n[ "..ply:Name().." | "..ply:Pers().." | "..ply:SteamID().." ]\n\n>>> "..CURRENT_ROLL}
        sockethook.RunCommand("logs "..util.TableToJSON(a) )

    else

        local roll = math.random(1,100)
        globalroll = roll
        local a = {type  = "rp", text = "`["..CONFIG.ServerName.."]` **[/roll]**\n[ "..ply:Name().." | "..ply:Pers().." | "..ply:SteamID().." ]\n\n>>> "..roll}
        sockethook.RunCommand("logs "..util.TableToJSON(a) )
        for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
            if v:IsPlayer() then
                net.Start("rp.Chat.Command")
                    net.WriteString("/roll")
                    net.WriteEntity(ply)
                    net.WriteFloat(roll)
                net.Send(v)
            end
        end

    end
end

local function c_func()
    local playerr = net.ReadEntity()
    local roll = net.ReadFloat()
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
    dbt:AddPlayerSay(playerr, {color_white, "Число на кубиках - ", color, tostring(roll)}, " кидает кубики:", false, false, function(self, w, h, i, alphapercent)
        if not self.RollNum then self.RollNum = 0 end
        self.RollNum = Lerp(FrameTime() * 10, self.RollNum, roll)
        local ww, hh = surface.GetTextSize(i.ply:Pers())
        draw.SimpleText( CharacterNameOnName(i.ply:Pers()), "Comfortaa X24", weight_source(5), 0, Color(color.r, color.g, color.b, color.a * alphapercent) )
        draw.SimpleText( i.action, "Comfortaa X24", weight_source(5) + ww, 0, Color(COLOR_WHITE_DEM.r, COLOR_WHITE_DEM.g, COLOR_WHITE_DEM.b, COLOR_WHITE_DEM.a * alphapercent) )

        local x, y =  surface.DrawMulticolorText(weight_source(5), weight_source(25), "Comfortaa X24", {COLOR_WHITE_DEM, "Число на кубиках - ", Color(color.r, color.g, color.b, color.a * alphapercent), tostring(math.Round(self.RollNum))}, 700)
    end)

end

RP.chat.register( "/roll", s_func, c_func )


local function s_func(ply,text)
    local text = string.TrimLeft(text, "/do ")
    local a = {type  = "rp", text = "`["..CONFIG.ServerName.."]` **[/do]**\n[ "..ply:Name().." | "..ply:Pers().." | "..ply:SteamID().." ]\n\n>>> "..text}
    sockethook.RunCommand("logs "..util.TableToJSON(a) )
    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/do")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
    for k, v in ipairs( player.GetAll() ) do
        if IsMono(v:Pers()) then
            netstream.Start(v, "dbt/sendgm/do", text, ply)
       end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
    chat.AddText( Color(139, 12, 161), "[ОКРУЖЕНИЕ] ", color_white, data)
end

netstream.Hook("dbt/sendgm/do", function(data, playerr)
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
    chat.AddTextClick(function()
        netstream.Start("telepormeto", playerr)
    end,Color( 255, 255, 255), "["..playerr:Pers().."]", Color( 255, 255, 255), "[Окружение]",Color( 89, 255, 6), data)
end)
if SERVER then
    netstream.Hook("telepormeto", function(player, target)
        local position = serverguard:playerSend(player, target, true);

        if (position) then
            player:SetPos(position);
            player:SetEyeAngles(Angle(target:EyeAngles().pitch, target:EyeAngles().yaw, 0));

            return true;
        else
            if (serverguard.player:HasPermission(player, "Noclip")) then
                player:SetMoveType(MOVETYPE_NOCLIP);
                position = serverguard:playerSend(player, target, true);

                player:SetPos(position);
                player:SetEyeAngles(Angle(target:EyeAngles().pitch, target:EyeAngles().yaw, 0));

                return true;
            end;
        end;
    end)
end
RP.chat.register( "/do", s_func, c_func )


local function s_func(ply,text)
    local text = string.TrimLeft(text, "/gm")

    for k, v in ipairs( player.GetAll() ) do
        if v:GetUserGroup() == "gm" then
            net.Start("rp.Chat.Command")
            net.WriteString("/gm")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
    chat.AddText( Color( 255, 0, 0), "[СООБЩЕНИЕ ОТ ИГРОКА "..playerr:Nick().."]",Color( 255, 255, 255), data)
end

RP.chat.register( "/gm", s_func, c_func )

--[[
local function s_func(ply,text)
    local wep = ply:GetActiveWeapon()
    if wep:GetClass() == "hands" then return end
    local tr = util.TraceLine( {
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 15,
        filter = function( ent ) return ent != ply end
    } )

    local ent = ents.Create( "weapon_drop" )
    ent:SetModel( wep:GetWeaponWorldModel() )
    ent:SetPos( tr.HitPos )
    ent:Spawn()
    ent:SetNWString("Weapon", wep:GetClass())
    ent:SetNWString("LastUser", ply:Pers() )
    ent:SetModel( wep:GetWeaponWorldModel() )
    ply:StripWeapon(wep:GetClass())
end

local function c_func()

end

RP.chat.register( "/drop", s_func, c_func )]]


local function s_func(ply,text)
    if !ply:IsAdmin() then return end

    ply:SetNWBool("ESPMODE", !ply:GetNWBool("ESPMODE"))
end

local function c_func()

end

RP.chat.register( "/espmode", s_func, c_func )


local function s_func(ply,text)
    if !ply:IsAdmin() then return end
    local text = string.TrimLeft(text, "/addrule")
    net.Start("dbt/mono/rules/update")
    net.WriteString(text)
    net.Broadcast()
end

local function c_func()

end

RP.chat.register( "/addrule", s_func, c_func )

local function s_func(ply,text)
    if !ply:IsAdmin() then return end
    net.Start("dbt/mono/rules/clearall")
    net.Broadcast()
end

local function c_func()

end

RP.chat.register( "/clearrule", s_func, c_func )


local function s_func(ply,text)
    if !ply:IsAdmin() then return end
    local text = string.TrimLeft(text, "/item")
    local args = string.Split(text, " ")
    local player = util.FindPlayer(args[3])
    if not player then return end
	if tonumber(args[2]) == 26 then
		dbt.inventory.additem(player, tonumber(args[2]), {owner = player:Pers(), poisonedKCN = true})
	elseif tonumber(args[2]) == 27 then
		dbt.inventory.additem(player, tonumber(args[2]), {owner = player:Pers(), poisonedMETHANOL = true})
	else
        if tonumber(args[2]) == 1 then
            local id = dbt.monopads.New(player:Pers())
    	   dbt.inventory.additem(player, tonumber(args[2]), {owner = player:Pers(), id = id})
        else
             dbt.inventory.additem(player, tonumber(args[2]), {owner = player:Pers()})
        end
	end
end

local function c_func()

end

RP.chat.register( "/item", s_func, c_func )


local function s_func(ply,text)
    if !ply:IsAdmin() then return end
    ply:ChatPrint(curtimesys)
end

local function c_func()

end

RP.chat.register( "/time", s_func, c_func )


local function s_func(ply,text)
    local text = string.TrimLeft(text, "!pm ")
    local args = util.ExplodeByTags(text, " ", "\"", "\"", true);
    local target = util.FindPlayer(args[1], ply);
    if not IsValid(target) then ply:ChatPrint("Игрок отсуствует!") return end
    local text = table.concat( args, " " )
    local text = string.TrimLeft(text, args[1].." ")
    net.Start("rp.Chat.Command")
        net.WriteString("!pm")
        net.WriteString(text)
        net.WriteEntity(ply)
        net.WriteEntity(target)
        net.WriteBool(true)
    net.Send(target)
    net.Start("rp.Chat.Command")
        net.WriteString("!pm")
        net.WriteString(text)
        net.WriteEntity(ply)
        net.WriteEntity(target)
        net.WriteBool(false)
    net.Send(ply)


    local a = {type  = "pm", text = "ㅤ\n`["..CONFIG.ServerName.."]`\n**От:** [ "..ply:Name().." | "..ply:Pers().." | "..ply:SteamID().." ]\n**Для**: [ "..target:Name().." | "..target:Pers().." | "..target:SteamID().." ]\n>>> "..text}
    sockethook.RunCommand("logs "..util.TableToJSON(a) )

end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local player_target = net.ReadEntity()
    local b = net.ReadBool()
    if not b then
        local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
        dbt:AddPlayerSay(playerr, {color_red, data}, " пишет личное сообщение для "..player_target:Nick()..":", false, false, false, true, true)
    else
        local color = dbt.chr[playerr:Pers()].color  or Color( 89, 255, 6)
        if settings.Get("pmsound", false) then 
            surface.PlaySound("delivered-message-sound.mp3")
        end
        dbt:AddPlayerSay(playerr, {color_red, data}, " пишет вам личное сообщение:", false, false, false, true, true)
    end
end



RP.chat.register( "!pm", s_func, c_func )




local function s_func(ply,text)

    net.Start("rp.Chat.Command")
    net.WriteString("maxwell")
    net.Send(ply)

end


local function c_func()
    chat.AddText(color_white,"Вы нашли кота maxwell!")
    sound.PlayFile(  "sound/sex.mp3" , "noblock", function( CurrentSong, ErrorID, ErrorName )
        if not CurrentSong then return end
        CurrentSong:SetVolume( 0.5 )
        if IsValid(PlayingSong) then PlayingSong:Stop() end
    end)
    MAXWELLPOS = nil
    local sexmat = http.Material("https://imgur.com/4sZ2GVP.png")
    dbt:AddPlayerSay(playerr, {color_white, "пишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщениепишет вам личное сообщение"}, " ", false, false, function(self, w, h, i)
        if not MAXWELLPOS then MAXWELLPOS = w / 3 end
        surface.SetDrawColor(255, 255, 255, 255 * APLHA_PERCENT)
        sexmat:DrawR(MAXWELLPOS * math.cos(CurTime()) + w / 2, h / 2, w / 3, h, 0)
    end)
end

RP.chat.register( "maxwell", s_func, c_func )
