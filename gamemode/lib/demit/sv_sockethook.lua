sockethook = sockethook or {}

local debug_info 	= debug.getinfo
local isstring 		= isstring
local isfunction 	= isfunction
local IsValid 		= IsValid

local hook_callbacks = {}
local hook_mapping   = {}

function sockethook.Add(name, id, callback)
	if isfunction(id) then
		callback = id
		id = debug_info(callback).short_src
	end

	if (not callback) then
		return 
	end

	local callbacks, mapping = hook_callbacks[name], hook_mapping[name] 
	if (callbacks == nil) then
		callbacks = {[0] = 0}
		hook_callbacks[name] = callbacks

		if (mapping == nil) then
			mapping = {}
			hook_mapping[name] = mapping
		end
	end

	local index = mapping[id]
	if (index ~= nil) then
		callbacks[index] = callback
	else
		index = callbacks[0] + 1
		callbacks[index], mapping[id], mapping[index], callbacks[0] = callback, index, id, index
	end
end

function sockethook.Call(name, ...)
	local callbacks = hook_callbacks[name]

	if (callbacks ~= nil) then

		local i = 1

		::runhook::
		local v = callbacks[i]
		if (v ~= nil) then
			local a, b, c, d, e, f = v(...)
			if (a ~= nil) then
				return a, b, c, d, e, f
			end
			i = i + 1
			goto runhook
		end
	end 
end


sockethook.Add("allowuser", "Socket/allowuser", function(data)
	allowed[data] = true
	print("[Кардинал]", "Пользователь по steamid", data, "добавлен на сервер")
end)

sockethook.Add("removeuser", "Socket/removeuser", function(data)
	allowed[data] = false
	print("[Кардинал]", "Пользователь по steamid", data, "убран с сервера")
end)

sockethook.Add("allowusers", "Socket/allowusers", function(data)
    local users = string.Split(data, ";") 
    for k, i in pairs(users) do 
        allowed[i] = true 
    end
	print("[Кардинал]", "Массив пользователей по steamid", data, "добавлен на сервер")
	PrintTable(allowed)
end)

sockethook.Add("whitelist_refresh", "Socket/whitelist_refresh", function(data)
    local users = util.JSONToTable(data)
    for k, i in pairs(users) do 
        allowed[k] = true
    end
	print("[Кардинал]", "Получен список сохраненых steamid получен")
end)
 

sockethook.Add("clearusers", "Socket/clearusers", function(data)
    allowed = {}
	print("[Кардинал]", "Очищен список сохраненых steamid")
    for k, i in pairs(player.GetAll()) do 
        i:Kick("Автоматический рестарт после очистки списка")
    end
    RunConsoleCommand("changelevel", game.GetMap());
end) 

list_req = {}
sockethook.Add("warns_read", "Socket/warns_read", function(data)
    local WarnsTable = util.JSONToTable(data)
    local ply = list_req[1] 
    netstream.Start(ply, "dbt/warns/list", WarnsTable)
    table.remove(list_req, 1)
end)


sockethook.Add("setrole", "Socket/setrole", function(data)
    local ar = util.JSONToTable(data)
    ar.name = string.Replace(ar.name, "|_|", " ")
    local rankData = serverguard.ranks:GetRank(ar.role);
    if not rankData then return end
    local target = util.FindPlayer(ar.name, NULL, true);
    serverguard.player:SetRank(target, rankData.unique, tonumber(ar.time));
    serverguard.player:SetImmunity(target, rankData.immunity);
    serverguard.player:SetTargetableRank(target, rankData.targetable)
    serverguard.player:SetBanLimit(target, rankData.banlimit)
end)  

function sockethook.RunCommand(cmd)
    socket:write(cmd)
end

require("gwsockets")
socket = GWSockets.createWebSocket("ws://193.23.219.44:1400")
list_req = {}
SetGlobalBool("IsConnectedCoordinal", false)

function socket:onMessage(txt)
	print(txt)
    local OldText = txt  
    local args = string.Split(txt, " ")
    local data = string.TrimLeft(OldText, args[1].." ")
    sockethook.Call(args[1], data)
end
    timer.Create("ConnecTrying", 5, 0, function()

    end)   
function socket:onError(txt)
    print("[Кардинал]", "Ошибка подключения к кардинал...")
    SetGlobalBool("IsConnectedCoordinal", false)
    timer.Create("ConnecTrying", 5, 1, function()
        socket:open()
    end)  
end 

function socket:onConnected()
    print("[Кардинал]", "Успешное подключение к кардинал")
    SetGlobalBool("IsConnectedCoordinal", true)
    socket:write("writenewconnect "..CONFIG.ServerCode)
    timer.Simple(1, function()
        socket:write("whitelist require")
    end)
end 

function socket:onDisconnected()
    SetGlobalBool("IsConnectedCoordinal", false)
    print("[Кардинал]", "Координал отключен, попытка подключения...")
   	timer.Create("ConnecTrying", 5, 1, function()
   		socket:open()
   	end)
end
concommand.Add("wsretry", function()
	socket:open()
end)
--	socket:open()

