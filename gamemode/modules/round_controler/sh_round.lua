gameStatuses = {"preparation", "game", "classtrial"}
round = 0
SetGlobalInt("round", 0)
SetGlobalString("gameStatus_mono", "prolog")
SetGlobalString("gameStage_mono", "freetime")
function GetRound()
    return round or 0
end
 
if SERVER then 
    concommand.Add("NextRound", function(ply)
        if not ply:IsAdmin() then return end
        round = round + 1
        SetGlobalString("gameStatus_mono", "stage_"..round)
        netstream.Start(nil, "dbt/new/round") 
        timer.Simple(22, function() dbt.music.Play("despair") SetGlobalInt("round", round) end)
    end)
end

function AddGameStatus(statusName)
    gameStatuses[statusName] = { }
    print("[Контроллер Раундов]", "Добавлен новый статус", statusName)
    return gameStatuses[statusName]
end

function SetGameStatus(newGameStatus)
    oldGameStatus = gameStatus

    gameStatus = newGameStatus

    SetGlobalString("gameStatus", gameStatus)
    print("[Контроллер Раундов]", "Выставлен новый статус раунда", newGameStatus)
    if gameStatus == "game" then
        charactersInGame_Last = charactersInGame
    elseif gameStatus == "preparation" then
        round = 0
        print("[Контроллер Раундов]", "Сервер перешел в режим лоби!", newGameStatus)
        SetGlobalInt("round", round)
    end

end

function GetGameStatus()
    return gameStatus or "preparation"
end

function GetOldGameStatus()
    return oldGameStatus or "preparation"
end

function GetCharactersInGame()
    return charactersInGame
end

function IsLobby()

    local round = GetGlobalString("gameStatus")

    if round == "preparation" then
        return true
    else 
        return false
    end
    
end

function IsGame()

    local round = GetGlobalString("gameStatus")

    if round == "game" then
        return true
    else 
        return false
    end
    
end

function IsClassTrial()

    local round = GetGlobalString("gameStatus")

    if round == "classtrial" then
        return true
    else 
        return false
    end
    
end

