util.AddNetworkString("dbt.ClientRooms")
util.AddNetworkString("OwnerGroup")
util.AddNetworkString("OpenDoorMenu")

dbt.liverooms = {}--
--
local meta = FindMetaTable("Entity")
local plyMeta = FindMetaTable("Player")
--
local live_room_id = {
	["*76"] = true,
	["*67"] = true,
	["*64"] = true,
	["*68"] = true,
	["*65"] = true,
	["*70"] = true,
	["*62"] = true,
	["*72"] = true,
	["*60"] = true,
	["*74"] = true,
	["*59"] = true,
	["*57"] = true,
	["*78"] = true,
	["*80"] = true,
	["*82"] = true,
	["*222"] = true,
}

local doors = {
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true,
    ["prop_dynamic"] = true
}

function meta:isDoor()
    local class = self:GetClass()

    if doors[class] then
        return true
    end

    return false
end

function LockAllDoors()
	for i, v in ipairs( ents.GetAll() ) do
		if live_room_id[v:GetModel()] then
		   	v:Fire("Lock")
		end
	end
end

for i, v in ipairs( ents.GetAll() ) do
	if live_room_id[v:GetModel()] then
	   	dbt.liverooms[#dbt.liverooms + 1] = v
	   	v:SetNWString("Owner", "Гость")
	end
end

for i, v in ipairs( ents.GetAll() ) do
	if doors[v:GetClass()] then
	   	v:SetNWString("Owner", "Гость")
	end
end



net.Start("dbt.ClientRooms")
	net.WriteTable(dbt.liverooms)
net.Broadcast()

net.Receive("dbt.ClientRooms", function()
	for i, v in ipairs( ents.GetAll() ) do
	if live_room_id[v:GetModel()] then
	   	dbt.liverooms[#dbt.liverooms + 1] = v
	   	v:SetNWString("Owner", "Гость")
	end
	end

	net.Start("dbt.ClientRooms")
		net.WriteTable(live_room_id)
	net.Broadcast()
end)

net.Receive("OwnerGroup", function(len,ply)
	local chr = net.ReadString()
	local tr = util.TraceLine(util.GetPlayerTrace( ply ))
	local door = tr.Entity
		net.Start("dbt.ClientRooms")
		net.WriteTable(live_room_id)
	net.Broadcast()

	door:SetNWString("Owner", chr)

end)

hook.Add("dbt.SpawnInit", "GetDoors", function(ply)
	net.Start("dbt.ClientRooms")
		net.WriteTable(live_room_id)
	net.Broadcast()
end)


local function AngleBetwwen(x1,y1, x2, y2)
  return math.deg(math.acos((x1*x2+y1*y2)/(((x1^2+y1^2)^0.5)*((x2^2+y2^2)^0.5))))
end
turret_target = nil
TurretEntity = nil
hook.Add("Think", "dbt/Think/turel", function()
	if !TurretEntity and not IsValid(TurretEntity) then 
		TurretEntity = ents.GetMapCreatedEntity( 3358 ) 
		if IsValid(TurretEntity) then 
			TurretEntity:SetPos(TurretEntity:GetPos() + Vector(0, 0, 1)) 
		end
	end
	if IsValid(turret_target) and IsValid(TurretEntity) then
		local pos1, pos2 = TurretEntity:GetPos(), turret_target:GetPos() + Vector(0, 0, 40)
		local angle_new = ( pos1 - pos2 ):Angle()
		angle_new.p = angle_new.p + 180
		angle_new.r = angle_new.r + 180
		TurretEntity:SetAngles(angle_new)
	end
end)
--AngleBetwwen
concommand.Add("GetMapCreationId", function(ply)
	local tr = util.TraceLine(util.GetPlayerTrace( ply ))
	local ent = tr.Entity
end)

-- Женская = 3448, Мужская = 3410 пулемет 3358
hook.Add( "PlayerUse", "dbt/PlayerUse/Nus", function( ply, ent )
 	if not ply.cd_use then ply.cd_use = CurTime() end
 	if "models/drp_props/furniture2.mdl" == ent:GetModel() and ply.cd_use < CurTime() then
 	  if not ply.sign_count then ply.sign_count = 5 end
 	  ply.cd_use = CurTime() + 1
 	  netstream.Start(ply,"dbt/start/write", ent, ply.sign_count)
 	end
	if ent:MapCreationID() == 3410 or ent:MapCreationID() == 3533 then
		if ply.info and ply.info.monopad and ply.info.monopad.meta and ply.info.monopad.meta.owner then
			local chr = ply.info.monopad.meta.owner
			local male = dbt.chr[ply.info.monopad.meta.owner].male
				if male then
					return true
				else

				if not timer.Exists("door_msg"..ply:Name()) then
					--ply:SetNWBool("HasNoMALEDoor", true)
					netstream.Start(ply, "dbt/NewNotification", 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = "Уведомление", titlecolor = Color(222, 193, 49), notiftext = "Вы не можете открыть дверь в мужскую раздевалку."})
					turret_target = ply
					if TurretEntity and IsValid(TurretEntity) then TurretEntity:EmitSound("npc/turret_floor/active.wav") end
					timer.Create("door_msg"..ply:Name(), 3, 1, function()
						--ply:SetNWBool("HasNoMALEDoor", false)
						turret_target = nil
					end)
				end

				return false
			end
		else

			if not timer.Exists("door_msg"..ply:Name()) then
				timer.Create("door_msg"..ply:Name(), 3, 1, function()

				end)
			end
			return false
		end
	elseif ent:MapCreationID() == 3448 or ent:MapCreationID() == 3534 then
		if ply.info and ply.info.monopad and ply.info.monopad.meta and ply.info.monopad.meta.owner then
			local chr = ply.info.monopad.meta.owner
			local male = dbt.chr[ply.info.monopad.meta.owner].male
			if !male then
				return true
			else

				if not timer.Exists("door_msg"..ply:Name()) then
					--ply:SetNWBool("HasNoFEMALEDoor", true)
					netstream.Start(ply, "dbt/NewNotification", 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = "Уведомление", titlecolor = Color(222, 193, 49), notiftext = "Вы не можете открыть дверь в женскую раздевалку."})
					turret_target = ply
					if TurretEntity and IsValid(TurretEntity) then TurretEntity:EmitSound("npc/turret_floor/active.wav") end
					timer.Create("door_msg"..ply:Name(), 3, 1, function()
						--ply:SetNWBool("HasNoFEMALEDoor", false)
						turret_target = false
					end)
				end

				return false
			end
		else

			if not timer.Exists("door_msg"..ply:Name()) then
				--ply:SetNWBool("HasNoMonoDoor", true)
				netstream.Start(ply, "dbt/NewNotification", 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = "Уведомление", titlecolor = Color(222, 193, 49), notiftext = "Вы не можете открыть дверь без монопада."})
				timer.Create("door_msg"..ply:Name(), 3, 1, function()
					--ply:SetNWBool("HasNoMonoDoor", false)
				end)
			end
			return false
		end
	end
end )

-- 3507 3508
local function removeDoors()
	local door1 = ents.GetMapCreatedEntity(2709)
	local door2 = ents.GetMapCreatedEntity(2710)
	if IsValid(door1) then door1:Remove() end
	if IsValid(door2) then door2:Remove() end
	local door1 = ents.GetMapCreatedEntity(2711)
	local door2 = ents.GetMapCreatedEntity(2713)
	if IsValid(door1) then door1:Remove() end
	if IsValid(door2) then door2:Remove() end
end

hook.Add("PostCleanupMap", "removeDoors", function()
	removeDoors()
end)
removeDoors()

local ents_to_remove = {}
ents_to_remove["prop_dynamic"] = true
ents_to_remove["prop_physics"] = true

netstream.Hook("dbt/map/clearallprops", function(ply)
	local st_removes = {}
	for k, i in pairs(ents.GetAll()) do
		if i:MapCreationID() != -1 and ents_to_remove[i:GetClass()] and not string.find( i:GetModel(), "tree" ) then --tree

			st_removes[i:GetClass()] = st_removes[i:GetClass()] or 0
			st_removes[i:GetClass()] = st_removes[i:GetClass()] + 1
			i:Remove()
		end
	end
end)
