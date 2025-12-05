util.AddNetworkString("dbt/characters/preset/upload")
util.AddNetworkString("dbt/characters/single/upload")
util.AddNetworkString("dbt/characters/preset/download")
util.AddNetworkString("dbt/characters/single/download")
file.CreateDir("dbt/characters")
file.CreateDir("dbt/characters/presets")
file.CreateDir("dbt/characters/single")

local function filter(v, depth)
	if depth > 6 then return nil end
	local t = type(v)
	if t == "number" or t == "string" or t == "boolean" or v == nil then return v end
	if t == "table" then
		local out = {}
		for k,i in pairs(v) do
			local tk = type(k)
			if tk == "number" or tk == "string" then
				local fv = filter(i, depth + 1)
				if fv ~= nil then out[k] = fv end
			end
		end
		return out
	end
	return nil
end

local function buildSnapshot(list)
	local filterSet
	if istable(list) then
		filterSet = {}
		for key, value in pairs(list) do
			if isstring(key) and value then
				filterSet[key] = true
			elseif isstring(value) then
				filterSet[value] = true
			end
		end
		if next(filterSet) == nil then
			filterSet = nil
		end
	end
	local out = {}
	for name, character in pairs(dbt.chr) do
		if filterSet and not filterSet[name] then continue end
		local backupRef = character.backup
		character.backup = nil
		out[name] = filter(character, 0)
		character.backup = backupRef
	end
	return out
end

netstream.Hook("dbt/characters/preset/save", function(ply, name, names)
	if not ply:IsAdmin() then return end
	name = tostring(name or "noname")
	local id = string.lower(string.gsub(name, "[^%w_%-]", "_"))
	if id == "" then id = "preset"..os.time() end
	local data = {Name = name, Characters = buildSnapshot(names)}
	file.Write("dbt/characters/presets/"..id..".json", util.TableToJSON(data, true))
	netstream.Start(ply, "dbt/characters/preset/saved", id)
end)

netstream.Hook("dbt/characters/single/save", function(ply, char)
	if not ply:IsAdmin() then return end
	if not dbt.chr[char] then return end	
	local data = filter(dbt.chr[char], 0)
	file.Write("dbt/characters/single/"..char..".json", util.TableToJSON({Character = char, Data = data}, true))
	netstream.Start(ply, "dbt/characters/single/saved", char)
end)

netstream.Hook("dbt/characters/preset/list", function(ply)
	if not ply:IsAdmin() then return end
	local files = file.Find("dbt/characters/presets/*.json", "DATA")
	local out = {}
	for _,f in ipairs(files) do
		local id = string.StripExtension(f)
		out[#out+1] = id
	end
	netstream.Start(ply, "dbt/characters/preset/list", out)
end)

netstream.Hook("dbt/characters/single/list", function(ply)
	if not ply:IsAdmin() then return end
	local files = file.Find("dbt/characters/single/*.json", "DATA")
	local out = {}
	for _,f in ipairs(files) do out[#out+1] = string.StripExtension(f) end
	netstream.Start(ply, "dbt/characters/single/list", out)
end)

netstream.Hook("dbt/characters/preset/load", function(ply, id, mode)
	if not ply:IsAdmin() then return end
	id = tostring(id or "")
	if id == "" then return end
	local raw = file.Read("dbt/characters/presets/"..id..".json", "DATA") or ""
	if raw == "" then return end
	local tab = util.JSONToTable(raw) or {}
	local chars = tab.Characters or {}
	if mode == "replace" then
		dbt.chr = {}
	end
	for name, data in pairs(chars) do
		local snapshot = istable(data) and table.Copy(data) or {}
		local character = dbt.chr[name]
		if character then
			character:Update(snapshot)
		else
			character = dbt.CreateCharacter(name, snapshot)
		end

		if snapshot.isCustom ~= nil then
			character.isCustom = snapshot.isCustom
		else
			local loweredName = string.lower(tostring(name or ""))
			character.isCustom = character.isCustom or string.StartWith(loweredName, "customcharacter")
		end

		if snapshot.name then
			character.name = snapshot.name
		end

		if not character.backup then
			character.backup = table.Copy(snapshot)
		elseif character.isCustom and snapshot.isCustom then
			character.backup = table.Copy(snapshot)
		end
	end
	netstream.Start(ply, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'System', titlecolor = Color(255, 0, 255), notiftext = 'Пресет '.. (tab.Name or id) .. ' загружен', time = 5})
	netstream.Start(ply, "dbt/characters/preset/loaded", id)
	if sortCharacters then
		sortCharacters()
	end
	if istable(DBT_CHAR_SORTED) then
		for idx, charName in ipairs(DBT_CHAR_SORTED) do
			local character = dbt.chr[charName]
			if character then
				character.index = idx
			end
		end
	end
	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
end) 

netstream.Hook("dbt/characters/single/load", function(ply, char)
	if not ply:IsAdmin() then return end
	local raw = file.Read("dbt/characters/single/"..char..".json", "DATA") or ""
	if raw == "" then return end
	local tab = util.JSONToTable(raw) or {}
	if tab.Data then dbt.chr[tab.Character or char] = tab.Data end
	netstream.Start(ply, "dbt/characters/single/loaded", char)
	netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
end)

net.Receive("dbt/characters/preset/upload", function(len, ply)
	net.ReadStream(ply, function(data)
		if not ply:IsAdmin() then return end
		local t = util.JSONToTable(data) or pon.decode(data) or {}
		if t.Characters and istable(t.Characters) then
			local name = t.Name or ("upload_"..os.time())
			local id = string.lower(string.gsub(name, "[^%w_%-]", "_"))
			if id == "" then id = "preset"..os.time() end
			file.Write("dbt/characters/presets/"..id..".json", util.TableToJSON({Name = name, Characters = t.Characters}, true))
			netstream.Start(ply, "dbt/characters/preset/saved", id)
		end
	end)
end)

net.Receive("dbt/characters/single/upload", function(len, ply)
	net.ReadStream(ply, function(data)
		if not ply:IsAdmin() then return end
		local t = util.JSONToTable(data) or pon.decode(data) or {}
		if t.Character and t.Data then
			local id = tostring(t.Character)
			file.Write("dbt/characters/single/"..id..".json", util.TableToJSON({Character = id, Data = t.Data}, true))
			netstream.Start(ply, "dbt/characters/single/saved", id)
		end
	end)
end)

netstream.Hook("dbt/characters/preset/download", function(ply, id)
	if not ply:IsAdmin() then return end
	local raw = file.Read("dbt/characters/presets/"..id..".json", "DATA") or ""
	if raw == "" then return end
	net.Start("dbt/characters/preset/download")
	net.WriteString(id)
	net.WriteStream(raw)
	net.Send(ply)
end)

netstream.Hook("dbt/characters/single/download", function(ply, id)
	if not ply:IsAdmin() then return end
	local raw = file.Read("dbt/characters/single/"..id..".json", "DATA") or ""
	if raw == "" then return end
	net.Start("dbt/characters/single/download")
	net.WriteString(id)
	net.WriteStream(raw)
	net.Send(ply)
end)