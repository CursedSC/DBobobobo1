charactersInGame = {}
charactersInGame_Last = {}
DefaultCharacter = "Гость"
MonokumaCharacter = "Монокума"
CharactersMono = {"Монокума", "Монотаро", "Моноске", "Монокид", "Монодам", "Монофани"}

function IsMonocuma(character)
    for name, tbl in pairs(CharactersMono) do
        if character == tbl then
          return true
        end
    end

    return false
end


function IsMono(character)

    if IsMonocuma(character) then
      return true
    else
      return false
    end
    
end

function GetPlayerInGame(character)
    local playerEnt = charactersInGame[character].playerEnt
    local playerSteamID = player.GetBySteamID(charactersInGame[character].steamID)
    return playerEnt or playerSteamID or nil
end

function GetPlayersInGame()
    local playersTable = {}

    for character, data in pairs(charactersInGame) do
        local playerEntity = GetPlayerInGame(character)
        if IsValid(playerEntity) then
            table.insert(playersTable, playerEntity)
        end
    end

    return playersTable 
end

function AddInGame(player)
    if TypeID(player) ~= TYPE_ENTITY or not player:IsPlayer() then
        return false
    end

    local character = player:GetNWString("dbt.CHR")

    if character == DefaultCharacter or IsMono(character) then
        return false
    end

    if IsValid(player.deadico) then
        player.deadico:Remove()
    end

    player:SetNWBool("InGame", true)

    charactersInGame[character] = {
        alive = true,
        round = 0,
        deathTime = 0,
        playerEnt = player,
        steamID = player:SteamID()
    }

    if SERVER then
        net.Start("dbt.Charactrs")
        net.WriteTable(charactersInGame)
        net.Broadcast()
    end

    return true
end


function InGame(player, test)
    if player:IsPlayer() then
        local playerCharacter = player:GetNWString("dbt.CHR")
        
        return player:GetNWBool("InGame") or charactersInGame[playerCharacter] and charactersInGame[playerCharacter].alive or false
    end

    return false
end

function InGameCHR(player)
    return charactersInGame[player] and charactersInGame[player].alive or false
end
GLOVAL_TABLE_OF_DEATHICO = {}
function DropFromGame(character, cause)
    if character:IsPlayer() then
        character = character:GetNWString("dbt.CHR")
    end
    
    if not charactersInGame[character] or not charactersInGame[character].alive then
        return
    end

    local characterInfo = charactersInGame[character]

    characterInfo.alive = false
    characterInfo.round = GetRound()
    characterInfo.deathTime = CurTime()
    characterInfo.cause = cause

    GetPlayerInGame(character):SetNWBool("InGame", false)

    local pl = player.GetBySteamID(characterInfo.steamID)
    local s, ch = pl:SelfData().season, pl:SelfData().char
    local button = ents.Create( "prop_physics" )
            button:SetPos( GPS_POS[pl:GetNWInt("Index")] - Vector(0, 0, 60) )
            button:SetModel("models/drp_props/portret1.mdl")
            button:Spawn()
            button:SetMoveType(MOVETYPE_NONE)
            button:SetSubMaterial(1, "!deadicon_"..s.."_"..ch)

            local tbl = normal_camera_position[game.GetMap()]
            local vec = GPS_POS[pl:GetNWInt("Index")]
            local cool = math.atan2(tbl.y - vec.y, tbl.x - vec.x) / math.pi * 180
            button:SetAngles(Angle(0,cool,0))
    pl.deadico = button
    GLOVAL_TABLE_OF_DEATHICO[#GLOVAL_TABLE_OF_DEATHICO + 1] = button
    hook.Run("dropFromGame", GetPlayerInGame(character), characterInfo.round, characterInfo.deathTime, cause)

    if SERVER then 
        net.Start("dbt.Charactrs")
            net.WriteTable(charactersInGame)
        net.Broadcast() 
    end
end

function RemoveAllFromGame()
    table.Empty(charactersInGame)
end
local playerMeta = FindMetaTable("Player")
function playerMeta:Pers() 
    return self:GetNWString("dbt.CHR")
end
function playerMeta:CharacterName() 
    return dbt.chr[self:Pers()].name
end
function CharacterNameOnName(char) 
    return dbt.chr[char].name
end

teleportpos = {}


function SetClassicPosSpawn()
    teleportpos[1] = Vector(-1108.0476074219, -3068.2390136719, -47.96875)
    teleportpos[2] = Vector(-1111.7631835938, -3196.1899414063, -47.96875)
    teleportpos[3] = Vector(-1111.7967529297, -3305.3298339844, -47.968746185303)
    teleportpos[4] = Vector(-1112.8403320313, -3406.1447753906, -47.96875)
    teleportpos[5] = Vector(-1240.7576904297, -3398.3837890625, -47.968746185303)
    teleportpos[6] = Vector(-1324.3031005859, -3397.2116699219, -47.96875)
    teleportpos[7] = Vector(-1426.9561767578, -3396.69140625, -47.96875)
    teleportpos[8] = Vector(-1513.1564941406, -3395.9821777344, -47.968746185303)
    teleportpos[9] = Vector(-1582.7152099609, -3394.4738769531, -47.96875)
    teleportpos[10] = Vector(-1685.9158935547, -3338.4028320313, -47.96875)
    teleportpos[11] = Vector(-1683.4331054688, -3232.3303222656, -47.96875)
    teleportpos[12] = Vector(-1690.5014648438, -3136.6452636719, -47.96875)
    teleportpos[13] = Vector(-1688.4368896484, -3066.0913085938, -47.968746185303)
    teleportpos[14] = Vector(-1550.7642822266, -3070.6162109375, -47.96875)
    teleportpos[15] = Vector(-1446.4514160156, -3077.7150878906, -47.96875)
    teleportpos[16] = Vector(-1346.4067382813, -3140.1748046875, -47.96875)
    teleportpos[17] = Vector(-1319.150024, -3309.702637, 16.031250)
end
SetClassicPosSpawn()


hook.Add( "PostDrawTranslucentRenderables", "dbt.PostDrawTranslucentRenderables.spawnpos", function()
    if LocalPlayer():GetTool() and LocalPlayer():GetTool().Name == "Начало Игры" then 
        render.SetColorMaterial()
        for k, i in pairs(teleportpos) do 
            render.DrawSphere( i, 20, 30, 30, Color( 0, 175, 175, 100 ) )
        end
    end
end )

hook.Add("HUDPaint", "dbt.HUDPaint.spawnpos", function()
    if LocalPlayer():GetTool() and LocalPlayer():GetTool().Name == "Начало Игры" then 
        local col = (#teleportpos < 17) and Color(255,0,0) or color_white
        for k, i in ipairs( teleportpos) do
            local data2D = i:ToScreen() 

            if ( not data2D.visible ) then continue end
            draw.SimpleText( k, "Comfortaa X30", data2D.x, data2D.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end      
    end
end)