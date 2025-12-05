steam = steam or {}

local ApiKey = "https://api.steampowered.com/IsteamUser/GetPlayerSummaries/v0002/"

local function ParseJson(json, ...)
    local tbl = util.JSONToTable(json)
    if tbl == nil then return end

    local args = {...}

    for _, key in pairs(args) do
        if tbl[key] then
            tbl = tbl[key]
        end
    end

    return tbl
end

function steam.Info(sid, callback)
    HTTP({
        method = "get",
        url = ApiKey,
        parameters = {
            key = "AA2E25CABE9DB67123A2394B20F3046A",
            steamids = sid
        },
        failed = function(error)
            MsgC(Red, "steam Avatar API HTTP Error:", White, error, "\n")
        end,
        success = function(code, response)
           local name = ParseJson(response, "response", "players", 1, "personaname")
           callback(util.JSONToTable(response))
        end
    })
end
