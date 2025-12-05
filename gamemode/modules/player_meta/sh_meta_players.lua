EMETA = FindMetaTable("Entity")
PMETA = FindMetaTable("Player")
local vectorLength2D = FindMetaTable("Vector").Length2D
function PMETA:IsRunning()
    return vectorLength2D(self:GetVelocity()) > (self:GetWalkSpeed() + 40) and self:GetMoveType() != MOVETYPE_NOCLIP
end

local time_type = {}
time_type["freetime"] = "Свободное время"
time_type["game"] = "Свободное время"
time_type["classtrial"] = "Классный суд"
time_type["find"] = "Расследование"
time_type["preparation"] = "Подготовка"

local glav_type = {}
glav_type["prolog"] = "Пролог"
glav_type["epilog"] = "Епилог"

for i = 1,6 do
    glav_type["stage_"..i] = "Глава "..i
end
 
if CLIENT then 
    if file.Find("lua/bin/gmcl_gdiscord_*.dll", "GAME")[1] == nil then return end
    require("gdiscord")
     
    local image_fallback = "default" 
    local discord_id = "890611162641756262"
    local refresh_time = 10
      
    local discord_start = discord_start or -1
    local gameStatuses = {["preparation"] = "Лобби", ["game"] = "Свободное время", ["classtrial"] = "Классный суд"}
     
    function DiscordUpdate()
        if !IsValid(LocalPlayer()) then return end
        local round = GetGlobalString("gameStatus")
        if not gameStatuses[round] then 
            round = "preparation"
        end

        local rpc_data = {}
        local strTime = time_type[GetGlobalString("gameStatus")] or "???"
        local strRound = glav_type[GetGlobalString("gameStatus_mono")] or "???"
        --rpc_data["state"] = 


        rpc_data["partySize"] = player.GetCount() 
        rpc_data["partyMax"] = game.MaxPlayers()


        -- Handle map stuff
        -- See the config
        rpc_data["smallImageKey"] = "https://imgur.com/faAD9Ie.png"
        rpc_data["smallImageText"] = GetHostName( )
        local pers = LocalPlayer():GetNWString("dbt.CHR")
        local img = dbt.chr[pers].discord or "https://imgur.com/ZeqFZum.png"
        rpc_data["largeImageKey"] = img
        rpc_data["largeImageText"] = pers
        rpc_data["details"] = strRound..", "..strTime
        rpc_data["startTimestamp"] = discord_start


        rpc_data["buttonPrimaryLabel"] = "Как играть"
        rpc_data["buttonPrimaryUrl"] = "https://wiki.dbt-play.ru/"
        rpc_data["buttonSecondaryLabel"] = "Присоединиться"
        rpc_data["buttonSecondaryUrl"] = "https://discord.gg/uWDZtzYqg2"
        DiscordUpdateRPC(rpc_data)
    end

    hook.Add("Initialize", "UpdateDiscordStatus", function()
        discord_start = os.time()
        DiscordRPCInitialize(discord_id)
        DiscordUpdate()

        timer.Create("DiscordRPCTimer", refresh_time, 0, DiscordUpdate)
    end)

    hook.Add("InitPostEntity", "UpdateInitPostEntity", function()
        discord_start = os.time()
        DiscordRPCInitialize(discord_id)
        DiscordUpdate()

        timer.Create("DiscordRPCTimer", refresh_time, 0, DiscordUpdate)
    end) 
        discord_start = os.time()
        DiscordRPCInitialize(discord_id)
        DiscordUpdate()

        timer.Create("DiscordRPCTimer", refresh_time, 0, DiscordUpdate)
end