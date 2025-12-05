openobserve = {}
openobserve.endpoint = "https://metric.dbt-play.ru"
openobserve.org = "default"
openobserve.stream = "gmod"
openobserve.token = "ZGVtaW5tNzJAZ21haWwuY29tOkFyMkczc0ZtUmc4V1BzeUo="

--- Установить настройки подключения
function openobserve.Setup(endpoint, org, stream, token)
    openobserve.endpoint = endpoint
    openobserve.org = org or "default"
    openobserve.stream = stream or "gmod"
    openobserve.token = token
end

--- Отправить лог (таблица будет преобразована в JSON)
function openobserve.Log(data)
    if not istable(data) then
        print("[OpenObserve] Error: data must be a table")
        return
    end

    local json = util.TableToJSON({
        timestamp = os.time(),
        server = GetHostName(), 
        map = game.GetMap(),
        data = data
    })
    HTTP({
        method = "POST",
        url = string.format("%s/api/%s/%s/_json", openobserve.endpoint, openobserve.org, openobserve.stream),
        body = json,
        headers = {
            ["Authorization"] = "Basic " .. openobserve.token,
            ["Content-Type"] = "application/json"
        },
        failed = function( reason )

        end,
        success = function( code, body, headers )

        end,
    })

end

hook.Add("PlayerInitialSpawn", "OO_LogSpawn", function(ply)
    openobserve.Log({
        event = "player_join",
        name = ply:Nick(),
        steamid = ply:SteamID(),
        userid = ply:UserID(),
        ip = ply:IPAddress()
    })
end)

hook.Add("PlayerDisconnected", "OO_LogDisconnect", function(ply)
    openobserve.Log({
        event = "player_leave",
        name = ply:Nick(),
        steamid = ply:SteamID(),
        userid = ply:UserID(),
        ip = ply:IPAddress()
    })
end)