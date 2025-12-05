dbt.monopads = dbt.monopads or {}
dbt.monopads.list = dbt.monopads.list or {}
dbt.monopads.allchat = dbt.monopads.allchat or {}
dbt.monopads.groups = dbt.monopads.groups or {}
dbt.monopads.groupSeq = dbt.monopads.groupSeq or 0

local MAX_MESSAGE_LENGTH = 600

local function sanitizedMessage(text)
	if not isstring(text) then return nil end
	text = string.Trim(text)
	if text == "" then return nil end
	if utf8.len(text) > MAX_MESSAGE_LENGTH then
		text = utf8.sub(text, 1, MAX_MESSAGE_LENGTH)
	end
	return text
end

local function sanitizeGroupName(name, fallbackIndex)
	if not isstring(name) then name = "" end
	name = string.Trim(name)
	if name == "" then
		name = string.format("Группа #%d", fallbackIndex or (dbt.monopads.groupSeq + 1))
	elseif utf8.len(name) > 40 then
		name = utf8.sub(name, 1, 40)
	end
	return name
end

local function getPlayerMonopadId(ply)
	if not IsValid(ply) then return nil end
	if ply.info and ply.info.monopad then
		local meta = ply.info.monopad.meta
		if istable(meta) and meta.id then
			return meta.id
		end
		if ply.info.monopad.id then
			return ply.info.monopad.id
		end
	end
	return nil
end

local function sortByKey(tbl, key)
	table.sort(tbl, function(a, b)
		local va = tostring(a[key] or "")
		local vb = tostring(b[key] or "")
		if va == vb then return tostring(a.id or "") < tostring(b.id or "") end
		return va < vb
	end)
end

local function resolveCharacterName(characterId)
	if not characterId then return "???" end
	if dbt and dbt.chr and dbt.chr[characterId] and dbt.chr[characterId].name then
		return dbt.chr[characterId].name
	end
	return tostring(characterId)
end

local function isMonokumaCharacter(name)
	if not name then return false end
	if type(IsMono) == "function" then
		local ok = IsMono(name)
		if ok ~= nil then return ok end
	end
	if istable(CharactersMono) then
		for _, tag in ipairs(CharactersMono) do
			if tag == name then return true end
		end
	end
	if MonokumaCharacter and name == MonokumaCharacter then
		return true
	end
	return false
end

local function isMonokumaMonopad(monopadId)
	local record = dbt.monopads.list[monopadId]
	if not record then return false end
	return isMonokumaCharacter(record.character)
end

local function forEachMonokumaMonopad(callback)
	if type(callback) ~= "function" then return end
	for id, record in pairs(dbt.monopads.list) do
		if isMonokumaMonopad(id) then
			callback(id, record)
		end
	end
end

local function buildGroupMemberList(group)
	local members = {}
	for memberId in pairs(group.members) do
		local ref = dbt.monopads.list[memberId]
		if ref then
			members[#members + 1] = {
				id = memberId,
				character = ref.character,
			}
		end
	end
	sortByKey(members, "character")
	return members
end

local function buildChatPayload(monopadId)
	local payload = {
		selfId = monopadId,
		direct = {},
		groups = {},
	}

	local observer = isMonokumaMonopad(monopadId)

	for id, info in pairs(dbt.monopads.list) do
		payload.direct[#payload.direct + 1] = {
			id = id,
			character = info.character,
		}
	end
	sortByKey(payload.direct, "character")

	for gid, group in pairs(dbt.monopads.groups) do
		local isMember = group.members[monopadId] and true or false
		if observer or isMember then
			payload.groups[#payload.groups + 1] = {
				id = gid,
				name = group.name,
				owner = group.owner,
				isOwner = group.owner == monopadId,
				isMember = isMember,
				members = buildGroupMemberList(group),
			}
		end
	end
	sortByKey(payload.groups, "name")

	return payload
end

function dbt.monopads.PushChatList(monopadId)
	local record = dbt.monopads.list[monopadId]
	if not record then return end
	local owner = record.nowowned
	if not IsValid(owner) then return end
	netstream.Start(owner, "dbt/monopad/request/chats", buildChatPayload(monopadId))
end

local function broadcastChatListToGroup(group)
	for memberId in pairs(group.members) do
		dbt.monopads.PushChatList(memberId)
	end
	forEachMonokumaMonopad(function(id)
		if not group.members[id] then
			dbt.monopads.PushChatList(id)
		end
	end)
end

local function resetMonopadChats(pushUpdates)
	dbt.monopads.allchat = {}
	dbt.monopads.groups = {}
	dbt.monopads.groupSeq = 0
	if pushUpdates then
		netstream.Start(nil, "dbt/monopad/chats/reset")
	end
	for id, record in pairs(dbt.monopads.list) do
		if istable(record) then
			record.chats = {}
			record.listen = nil
		end
		if pushUpdates and istable(record) then
			dbt.monopads.PushChatList(id)
		end
	end
end

function dbt.monopads.ResetChats(pushUpdates)
	resetMonopadChats(pushUpdates and true or false)
end

local function ensureGroupOwner(group)
	if group.owner and group.members[group.owner] then return end
	group.owner = nil
	for memberId in pairs(group.members) do
		group.owner = memberId
		break
	end
	if not group.owner then
		dbt.monopads.groups[group.id] = nil
	end
end

local function createGroup(ownerId, rawName, invited)
	dbt.monopads.groupSeq = dbt.monopads.groupSeq + 1
	local id = dbt.monopads.groupSeq
	local group = {
		id = id,
		owner = ownerId,
		name = sanitizeGroupName(rawName, id),
		members = {},
		messages = {},
	}
	group.members[ownerId] = true

	if istable(invited) then
		for _, rawId in ipairs(invited) do
			local targetId = tonumber(rawId)
			if targetId and targetId ~= ownerId and dbt.monopads.list[targetId] then
				group.members[targetId] = true
			end
		end
	end

	dbt.monopads.groups[id] = group
	return group
end

local function appendGroupMessage(group, authorId, text)
	local author = dbt.monopads.list[authorId]
	local entry = {
		message = text,
		own = author and author.character or "UNKNOWN",
		time = GetGlobalInt("Time")
	}
	group.messages[#group.messages + 1] = entry
	return entry
end

local function appendGroupSystemMessage(group, text, meta)
	local entry = {
		message = text,
		own = "__system",
		time = GetGlobalInt("Time"),
		system = true,
		meta = meta or {}
	}
	group.messages[#group.messages + 1] = entry
	return entry
end

local function notifyGroupMembers(group, chatId, messageData, excludeId)
	for memberId in pairs(group.members) do
		if memberId ~= excludeId then
			local member = dbt.monopads.list[memberId]
			if member and IsValid(member.nowowned) then
				netstream.Start(member.nowowned, "monopad/chat/add", chatId, messageData)
				if not messageData.system then
					netstream.Start(member.nowowned, "monopad/chat/show", chatId, messageData)
				end
			end
		end
	end
	forEachMonokumaMonopad(function(id, record)
		if group.members[id] then return end
		if id == excludeId then return end
		if IsValid(record.nowowned) then
			netstream.Start(record.nowowned, "monopad/chat/add", chatId, messageData)
			if not messageData.system then
				netstream.Start(record.nowowned, "monopad/chat/show", chatId, messageData)
			end
		end
	end)
end
 
function dbt.monopads.New(character)
	local id = #dbt.monopads.list + 1
	local monopad = {
		character = character,
		chats = {},
		isbreak = false,
		listen = nil,
		nowowned = nil,
	}
	dbt.monopads.list[id] = monopad
	return id
end

function dbt.monopads.FindByCharacter(character)
	for id, monopad in pairs(dbt.monopads.list) do
		if monopad.character == character then
			return id
		end
	end
	return nil
end

function dbt.monopads.Message(monopadid, monopadidFrom, message)
	local text = sanitizedMessage(message)
	if not text then return end
	local monopad = dbt.monopads.list[monopadid]
	local monopadFrom = dbt.monopads.list[monopadidFrom]
	if not monopad or not monopadFrom then return end

	monopad.chats[monopadidFrom] = monopad.chats[monopadidFrom] or {}
	monopad.chats[monopadidFrom][#monopad.chats[monopadidFrom] + 1] = {
		message = text,
		own = monopad.character,
		time = GetGlobalInt("Time")
	}
	monopadFrom.chats[monopadid] = monopadFrom.chats[monopadid] or {}
	monopadFrom.chats[monopadid][#monopadFrom.chats[monopadid] + 1] = {
		message = text,
		own = monopad.character,
		time = GetGlobalInt("Time")
	}

	if IsValid(monopadFrom.nowowned) then
		local chatId = "direct:" .. tostring(monopadid)
		local packet = {
			message = text,
			own = monopad.character,
			time = GetGlobalInt("Time")
		}
		netstream.Start(monopadFrom.nowowned, "monopad/chat/add", chatId, packet)
		netstream.Start(monopadFrom.nowowned, "monopad/chat/show", chatId, packet)
	end
end

netstream.Hook("monopad/listen", function(ply, IsListen)
	local id = ply.info.monopad.id
	dbt.monopads.list[id].listen = IsListen
end)

netstream.Hook("dbt/monopad/request/chats", function(ply)
	local monopadId = getPlayerMonopadId(ply)
	if not monopadId or not dbt.monopads.list[monopadId] then return end
	netstream.Start(ply, "dbt/monopad/request/chats", buildChatPayload(monopadId))
end)

netstream.Hook("dbt/monopad/request/dms", function(ply, _, descriptor)
	local monopadId = getPlayerMonopadId(ply)
	if not monopadId or not dbt.monopads.list[monopadId] then return end
	local observer = isMonokumaMonopad(monopadId)

	local resolved = descriptor
	if resolved == nil then resolved = "chat" end

	if istable(resolved) then
		if resolved.type == "group" then
			local groupId = tonumber(resolved.id)
			if not groupId then return end
			local group = dbt.monopads.groups[groupId]
			if not group or (not group.members[monopadId] and not observer) then return end
			dbt.monopads.list[monopadId].listen = "group:" .. groupId
			netstream.Start(ply, "dbt/monopad/request/dms", group.messages or {})
			return
		elseif resolved.type == "direct" then
			resolved = tonumber(resolved.id)
		elseif resolved.type == "global" then
			resolved = "chat"
		end
	end

	if resolved == "chat" then
		netstream.Start(ply, "dbt/monopad/request/dms", dbt.monopads.allchat or {})
		return
	end

	local directId
	if isnumber(resolved) then
		directId = resolved
	elseif isstring(resolved) and string.StartWith(resolved, "group:") then
		local groupId = tonumber(string.sub(resolved, 7))
		if not groupId then return end
		local group = dbt.monopads.groups[groupId]
		if not group or (not group.members[monopadId] and not observer) then return end
		dbt.monopads.list[monopadId].listen = "group:" .. groupId
		netstream.Start(ply, "dbt/monopad/request/dms", group.messages or {})
		return
	end

	if not directId then return end
	local holder = dbt.monopads.list[monopadId]
	if not holder then return end
	holder.listen = "direct:" .. directId
	local SendList = holder.chats[directId] or {}
	netstream.Start(ply, "dbt/monopad/request/dms", SendList)
end)


netstream.Hook("dbt/monopad/send/dms", function(ply, _, targetDescriptor, message, explicitTarget)
	local senderId = getPlayerMonopadId(ply)
	if not senderId or not dbt.monopads.list[senderId] then return end

	local text = sanitizedMessage(message)
	if not text then return end

	if targetDescriptor == "chat" or (istable(targetDescriptor) and targetDescriptor.type == "global") then
		local monopad = dbt.monopads.list[senderId]
		local payload = {
			message = text,
			own = monopad.character,
			time = GetGlobalInt("Time")
		}
		dbt.monopads.allchat[#dbt.monopads.allchat + 1] = payload
		netstream.Start(nil, "monopad/chat/add", "chat", payload)
		netstream.Start(nil, "monopad/chat/notiftoall", text, resolveCharacterName(monopad.character))
		return
	end

	local targetId = explicitTarget
	if istable(targetDescriptor) and targetDescriptor.type == "direct" then
		targetId = tonumber(targetDescriptor.id)
	elseif isnumber(targetDescriptor) and targetId == nil then
		targetId = targetDescriptor
	end
	local numericTarget = tonumber(targetId)
	if not numericTarget or not dbt.monopads.list[numericTarget] then return end
	if numericTarget == senderId then return end

	dbt.monopads.Message(senderId, numericTarget, text)
end)

netstream.Hook("dbt/monopad/admin/give", function(ply, id)
	if !ply:IsAdmin() then return end 
	local monopadTable = dbt.monopads.list[id]
	dbt.inventory.additem(ply, 1, {owner = monopadTable.character, id = id}) 
end)

netstream.Hook("dbt/monopad/admin/list", function(ply)
	if !ply:IsAdmin() then return end 
	local reforged = {}
	for k, i in pairs(dbt.monopads.list) do 
		reforged[k] = {
			character = i.character,
			isbreak = i.isbreak,
			listen = i.listen,
			nowowned = i.nowowned,		
		}
	end
	netstream.Start(ply, "dbt/monopad/admin/list", reforged)
end)

netstream.Hook("dbt/monopad/group/create", function(ply, _, groupName, invited)
	local ownerId = getPlayerMonopadId(ply)
	if not ownerId or not dbt.monopads.list[ownerId] then return end
	local group = createGroup(ownerId, groupName, istable(invited) and invited or {})
	broadcastChatListToGroup(group)
end)

netstream.Hook("dbt/monopad/group/invite", function(ply, _, groupId, targetId)
	local ownerId = getPlayerMonopadId(ply)
	local numericGroup = tonumber(groupId)
	local numericTarget = tonumber(targetId)
	if not ownerId or not numericGroup or not numericTarget then return end
	local group = dbt.monopads.groups[numericGroup]
	if not group or group.owner ~= ownerId then return end
	if not dbt.monopads.list[numericTarget] or group.members[numericTarget] then return end
	group.members[numericTarget] = true
	local ownerInfo = dbt.monopads.list[ownerId]
	local targetInfo = dbt.monopads.list[numericTarget]
	local actorChar = ownerInfo and ownerInfo.character or nil
	local targetChar = targetInfo and targetInfo.character or nil
	local message = string.format("%s пригласил %s", resolveCharacterName(actorChar), resolveCharacterName(targetChar))
	local entry = appendGroupSystemMessage(group, message, {
		event = "invite",
		actor = actorChar,
		target = targetChar
	})
	broadcastChatListToGroup(group)
	notifyGroupMembers(group, "group:" .. numericGroup, entry, nil)
	dbt.monopads.PushChatList(numericTarget)
end)

netstream.Hook("dbt/monopad/group/remove", function(ply, _, groupId, targetId)
	local actorId = getPlayerMonopadId(ply)
	local numericGroup = tonumber(groupId)
	local numericTarget = tonumber(targetId)
	if not actorId or not numericGroup or not numericTarget then return end
	local group = dbt.monopads.groups[numericGroup]
	if not group or not group.members[actorId] or not group.members[numericTarget] then return end
	if numericTarget ~= actorId and group.owner ~= actorId then return end
	group.members[numericTarget] = nil
	if numericTarget == group.owner then
		group.owner = nil
	end
	ensureGroupOwner(group)
	local existing = dbt.monopads.groups[numericGroup]
	if existing then
		local actorInfo = dbt.monopads.list[actorId]
		local targetInfo = dbt.monopads.list[numericTarget]
		local actorChar = actorInfo and actorInfo.character or nil
		local targetChar = targetInfo and targetInfo.character or nil
		local eventKey
		local message
		if numericTarget == actorId then
			eventKey = "leave"
			message = string.format("%s покинул группу", resolveCharacterName(targetChar))
		else
			eventKey = "kick"
			message = string.format("%s исключил %s", resolveCharacterName(actorChar), resolveCharacterName(targetChar))
		end
		local entry = appendGroupSystemMessage(existing, message, {
			event = eventKey,
			actor = actorChar,
			target = targetChar
		})
		broadcastChatListToGroup(existing)
		notifyGroupMembers(existing, "group:" .. numericGroup, entry, nil)
	end
	dbt.monopads.PushChatList(numericTarget)
	dbt.monopads.PushChatList(actorId)
end)

netstream.Hook("dbt/monopad/group/rename", function(ply, _, groupId, newName)
	local ownerId = getPlayerMonopadId(ply)
	local numericGroup = tonumber(groupId)
	if not ownerId or not numericGroup then return end
	local group = dbt.monopads.groups[numericGroup]
	if not group or group.owner ~= ownerId then return end
	group.name = sanitizeGroupName(newName, numericGroup)
	broadcastChatListToGroup(group)
end)

netstream.Hook("dbt/monopad/send/group", function(ply, _, groupId, message)
	local senderId = getPlayerMonopadId(ply)
	local numericGroup = tonumber(groupId)
	if not senderId or not numericGroup then return end
	local group = dbt.monopads.groups[numericGroup]
	if not group or not group.members[senderId] then return end
	local text = sanitizedMessage(message)
	if not text then return end
	local entry = appendGroupMessage(group, senderId, text)
	notifyGroupMembers(group, "group:" .. numericGroup, entry, senderId)
end)
