parameter = {}
local cache = {}

if SERVER then 
	function parameter.Register(name)
		cache[name] = cache[name] or 0
		netstream.Start("parameter/register", name, 0)
	end

	function parameter.Set(name, value)
		if not cache[name] then return 0 end
		cache[name] = value
		netstream.Start("parameter/set", name, value)
	end

	local function Sync(ply)
		netstream.Start("parameter/sync", cache)
	end
	hook.Add("PlayerInitialSpawn", "parameter/PlayerInitialSpawn/sync", Sync)
end
if CLIENT then 
	netstream.Hook("parameter/register", function(name)
		cache[name] = 0
	end)
	netstream.Hook("parameter/set", function(name, value)
		cache[name] = value
	end)
	netstream.Hook("parameter/sync", function(NewCache)
		cache = NewCache
	end)
end

function parameter.Get(name)
	return cache[name] or 0 
end