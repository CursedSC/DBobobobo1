permasave = {}
util.AddNetworkString("dbt/mapping")



permasave.BlackList = {
	["phys_bone_follower"] = true, 
	["scene_manager"] = true, 
	["ai_network"] = true, 
	["bodyque"] = true, 
	["gmod_gamerules"] = true,  
	["player_manager"] = true, 
	["soundent"] = true, 
	["spotlight_end"] = true, 
	["beam"] = true, 
	["predicted_viewmodel"] = true, 
	["gmod_hands"] = true, 
	["ai_network"] = true, 
	["physgun_beam"] = true, 
	["info_camera_link"] = true, 
	["prop_door_rotating"] = true, 
	["func_door_rotating"] = true, 
}

netstream.Hook("dbt/getinfo/edicts", function(ply)
	netstream.Start(ply, "dbt/getinfo/edicts", ents.GetEdictCount())
end)

function permasave.PermaFunc(ply, ent)
	if not PermaProps then ply:ChatPrint( "ERROR: Lib not found" ) return end

	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if ent.PermaProps then ply:ChatPrint( "That entity is already permanent !" ) return end

	local content = PermaProps.PPGetEntTable(ent)
	if not content then return end

	local max = tonumber(sql.QueryValue("SELECT MAX(id) FROM PermaProps;"))
	if not max then max = 1 else max = max + 1 end

	local new_ent = PermaProps.PPEntityFromTable(content, max)
	if !new_ent or !new_ent:IsValid() then return end

	PermaProps.SparksEffect( ent )

	PermaProps.SQL.Query("INSERT INTO PermaProps (id, map, content) VALUES(NULL, ".. sql.SQLStr(game.GetMap()) ..", ".. sql.SQLStr(util.TableToJSON(content)) ..");")
	local a, b = ent:GetClass() or "_", ent:GetModel() or "_"
	ply:ChatPrint("You saved " .. a .. " with model ".. b .. " to the database.")

	ent:Remove()
end
 
function permasave.Save(ply)
	local all_ents = ents.GetAll()

	for k, i in pairs(all_ents) do 
		if i:CreatedByMap() then continue end
		if not IsEntity(i) then continue end
		if i:IsWeapon() then continue end
		if i:IsPlayer() then continue end
		if i.IsServer then continue end
		if permasave.BlackList[i:GetClass()] then continue end

		permasave.PermaFunc(ply, i)
	end
end

concommand.Add("PermaSaveAll", function(ply)
	permasave.Save(ply)
end)
saveload = {}


saveload.SpecialENTSSpawn = {}
saveload.SpecialENTSSpawn["gmod_lamp"] = function( ent, data)

	ent:SetFlashlightTexture( data["Texture"] )
	ent:SetLightFOV( data["fov"] )
	ent:SetColor( Color( data["r"], data["g"], data["b"], 255 ) )
	ent:SetDistance( data["distance"] )
	ent:SetBrightness( data["brightness"] )
	ent:Switch( true )

	ent:Spawn()

	ent.Texture = data["Texture"]
	ent.KeyDown = data["KeyDown"]
	ent.fov = data["fov"]
	ent.distance = data["distance"]
	ent.r = data["r"]
	ent.g = data["g"]
	ent.b = data["b"]
	ent.brightness = data["brightness"]

	return true

end

saveload.SpecialENTSSpawn["prop_vehicle_jeep"] = function( ent, data)

	if ( ent:GetModel() == "models/buggy.mdl" ) then ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jeep_test.txt" ) end
	if ( ent:GetModel() == "models/vehicle.mdl" ) then ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jalopy.txt" ) end

	if ( data["VehicleTable"] && data["VehicleTable"].KeyValues ) then
		for k, v in pairs( data["VehicleTable"].KeyValues ) do
			ent:SetKeyValue( k, v )
		end
	end

	ent:Spawn()
	ent:Activate()

	ent:SetVehicleClass( data["VehicleName"] )
	ent.VehicleName = data["VehicleName"]
	ent.VehicleTable = data["VehicleTable"]
	ent.ClassOverride = data["Class"]

	return true

end
saveload.SpecialENTSSpawn["prop_vehicle_jeep_old"] = saveload.SpecialENTSSpawn["prop_vehicle_jeep"]
saveload.SpecialENTSSpawn["prop_vehicle_airboat"] = saveload.SpecialENTSSpawn["prop_vehicle_jeep"]
saveload.SpecialENTSSpawn["prop_vehicle_prisoner_pod"] = saveload.SpecialENTSSpawn["prop_vehicle_jeep"]

saveload.SpecialENTSSpawn["prop_ragdoll"] = function( ent, data )

	if !data or !istable( data ) then return end

	ent:Spawn()
	ent:Activate()
	
	if data["Bones"] then

		for objectid, objectdata in pairs( data["Bones"] ) do

			local Phys = ent:GetPhysicsObjectNum( objectid )
			if !IsValid( Phys ) then continue end
		
			if ( isvector( objectdata.Pos ) && isangle( objectdata.Angle ) ) then

				local pos, ang = LocalToWorld( objectdata.Pos, objectdata.Angle, Vector(0, 0, 0), Angle(0, 0, 0) )
				Phys:SetPos( pos )
				Phys:SetAngles( ang )
				Phys:Wake()

				if objectdata.Frozen then
					Phys:EnableMotion( false )
				end

			end
		
		end

	end

	if data["BoneManip"] and ent:IsValid() then

		for k, v in pairs( data["BoneManip"] ) do

			if ( v.s ) then ent:ManipulateBoneScale( k, v.s ) end
			if ( v.a ) then ent:ManipulateBoneAngles( k, v.a ) end
			if ( v.p ) then ent:ManipulateBonePosition( k, v.p ) end

		end

	end

	if data["Flex"] and ent:IsValid() then

		for k, v in pairs( data["Flex"] ) do
			ent:SetFlexWeight( k, v )
		end

		if ( Scale ) then
			ent:SetFlexScale( Scale )
		end

	end

	return true

end

saveload.SpecialENTSSpawn["sammyservers_textscreen"] = function( ent, data )

	if !data or !istable( data ) then return end

	ent:Spawn()
	ent:Activate()
	
	if data["Lines"] then

		for k, v in pairs(data["Lines"] or {}) do

			ent:SetLine(k, v.text, Color(v.color.r, v.color.g, v.color.b, v.color.a), v.size, v.font)

		end

	end

	return true

end

saveload.SpecialENTSSpawn["NPC"] = function( ent, data )

	if data and istable( data ) then

		if data["Equipment"] then

			local valid = false
			for _, v in pairs( list.Get( "NPCUsableWeapons" ) ) do
				if v.class == data["Equipment"] then valid = true break end
			end

			if ( data["Equipment"] && data["Equipment"] != "none" && valid ) then
				ent:SetKeyValue( "additionalequipment", data["Equipment"] )
				ent.Equipment = data["Equipment"] 
			end

		end

	end

	ent:Spawn()
	ent:Activate()

	return true

end

if list.Get( "NPC" ) and istable(list.Get( "NPC" )) then

	for k, v in pairs(list.Get( "NPC" )) do
		
		saveload.SpecialENTSSpawn[k] = saveload.SpecialENTSSpawn["NPC"]

	end

end

saveload.SpecialENTSSpawn["item_ammo_crate"] = function( ent, data )

	if data and istable(data) and data["type"] then

		ent.type = data["type"]
		ent:SetKeyValue( "AmmoType", math.Clamp( data["type"], 0, 9 ) )

	end

	ent:Spawn()
	ent:Activate()
	
	return true

end


saveload.SpecialENTSSave = {}
saveload.SpecialENTSSave["gmod_lamp"] = function( ent )

	local content = {}
	content.Other = {}
	content.Other["Texture"] = ent.Texture
	content.Other["KeyDown"] = ent.KeyDown
	content.Other["fov"] = ent.fov
	content.Other["distance"] = ent.distance
	content.Other["r"] = ent.r
	content.Other["g"] = ent.g
	content.Other["b"] = ent.b
	content.Other["brightness"] = ent.brightness

	return content

end

saveload.SpecialENTSSave["prop_vehicle_jeep"] = function( ent )

	if not ent.VehicleTable then return false end

	local content = {}
	content.Other = {}
	content.Other["VehicleName"] = ent.VehicleName
	content.Other["VehicleTable"] = ent.VehicleTable
	content.Other["ClassOverride"] = ent.ClassOverride

	return content

end
saveload.SpecialENTSSave["prop_vehicle_jeep_old"] = saveload.SpecialENTSSave["prop_vehicle_jeep"]
saveload.SpecialENTSSave["prop_vehicle_airboat"] = saveload.SpecialENTSSave["prop_vehicle_jeep"]
saveload.SpecialENTSSave["prop_vehicle_prisoner_pod"] = saveload.SpecialENTSSave["prop_vehicle_jeep"]

saveload.SpecialENTSSave["prop_ragdoll"] = function( ent )

	local content = {}
	content.Other = {}
	content.Other["Bones"] = {}

	local num = ent:GetPhysicsObjectCount()
	for objectid = 0, num - 1 do

		local obj = ent:GetPhysicsObjectNum( objectid )
		if ( !obj:IsValid() ) then continue end

		content.Other["Bones"][ objectid ] = {}

		content.Other["Bones"][ objectid ].Pos = obj:GetPos()
		content.Other["Bones"][ objectid ].Angle = obj:GetAngles()
		content.Other["Bones"][ objectid ].Frozen = !obj:IsMoveable()
		if ( obj:IsAsleep() ) then content.Other["Bones"][ objectid ].Sleep = true end

		content.Other["Bones"][ objectid ].Pos, content.Other["Bones"][ objectid ].Angle = WorldToLocal( content.Other["Bones"][ objectid ].Pos, content.Other["Bones"][ objectid ].Angle, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )

	end

	if ( ent:HasBoneManipulations() ) then
	
		content.Other["BoneManip"] = {}

		for i = 0, ent:GetBoneCount() do
	
			local t = {}
		
			local s = ent:GetManipulateBoneScale( i )
			local a = ent:GetManipulateBoneAngles( i )
			local p = ent:GetManipulateBonePosition( i )
		
			if ( s != Vector( 1, 1, 1 ) ) then t[ 's' ] = s end -- scale
			if ( a != Angle( 0, 0, 0 ) ) then t[ 'a' ] = a end -- angle
			if ( p != Vector( 0, 0, 0 ) ) then t[ 'p' ] = p end -- position
	
			if ( table.Count( t ) > 0 ) then
				content.Other["BoneManip"][ i ] = t
			end
	
		end

	end

	content.Other["FlexScale"] = ent:GetFlexScale()
	for i = 0, ent:GetFlexNum() do

		local w = ent:GetFlexWeight( i )
		if ( w != 0 ) then
			content.Other["Flex"] = content.Other["Flex"] or {}
			content.Other["Flex"][ i ] = w
		end

	end

	return content

end

saveload.SpecialENTSSave["sammyservers_textscreen"] = function( ent )

	local content = {}
	content.Other = {}
	content.Other["Lines"] = ent.lines or {}

	return content

end

saveload.SpecialENTSSave["prop_effect"] = function( ent )

	local content = {}
	content.Class = "pp_prop_effect"
	content.Model = ent.AttachedEntity:GetModel()

	return content

end
saveload.SpecialENTSSave["pp_prop_effect"] = saveload.SpecialENTSSave["prop_effect"]

saveload.SpecialENTSSave["NPC"] = function( ent )

	if !ent.Equipment then return {} end

	local content = {}
	content.Other = {}
	content.Other["Equipment"] = ent.Equipment

	return content

end

if list.Get( "NPC" ) and istable(list.Get( "NPC" )) then

	for k, v in pairs(list.Get( "NPC" )) do
		
		saveload.SpecialENTSSave[k] = saveload.SpecialENTSSave["NPC"]

	end

end

saveload.SpecialENTSSave["item_ammo_crate"] = function( ent )

	local content = {}
	content.Other = {}
	content.Other["type"] = ent.type

	return content

end


function saveload.PPEntityFromTable( data )

	if not data or not istable(data) then return false end

	if data.Class == "prop_physics" and data.Frozen then
		data.Class = "prop_dynamic" 
	end


	local ent = ents.Create(data.Class)
	if !ent then return false end
	if !ent:IsVehicle() then if !ent:IsValid() then return false end end
	ent:SetPos( data.Pos or Vector(0, 0, 0) )
	ent:SetAngles( data.Angle or Angle(0, 0, 0) )
	ent:SetModel( data.Model or "models/error.mdl" )
	ent:SetSkin( data.Skin or 0 )
	//ent:SetCollisionBounds( ( data.Mins or 0 ), ( data.Maxs or 0 ) )
	ent:SetCollisionGroup( data.ColGroup or 0 )
	ent:SetName( data.Name or "" )
	ent:SetModelScale( data.ModelScale or 1 )
	ent:SetMaterial( data.Material or "" )
	ent:SetSolid( data.Solid or 6 )
	if saveload.SpecialENTSSpawn[data.Class] != nil and isfunction(saveload.SpecialENTSSpawn[data.Class]) then

		saveload.SpecialENTSSpawn[data.Class](ent, data.Other)

	else

		ent:Spawn()

	end

	ent:SetRenderMode( data.RenderMode or RENDERMODE_NORMAL )
	ent:SetColor( data.Color or Color(255, 255, 255, 255) )

	if data.EntityMods != nil and istable(data.EntityMods) then -- OLD DATA

		if data.EntityMods.material then
			ent:SetMaterial( data.EntityMods.material["MaterialOverride"] or "")
		end
		
		if data.EntityMods.colour then
			ent:SetColor( data.EntityMods.colour.Color or Color(255, 255, 255, 255))
		end

	end

	if data.DT then

		for k, v in pairs( data.DT ) do

			if ( data.DT[ k ] == nil ) then continue end
			if !isfunction(ent[ "Set" .. k ]) then continue end
			ent[ "Set" .. k ]( ent, data.DT[ k ] )

		end

	end

	if data.BodyG then

		for k, v in pairs( data.BodyG ) do

			ent:SetBodygroup( k, v )

		end

	end


	if data.SubMat then

		for k, v in pairs( data.SubMat ) do

			if type(k) != "number" or type(v) != "string" then continue end

			ent:SetSubMaterial( k-1, v )
			
		end

	end

	if data.Frozen != nil then
		
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(!data.Frozen)
		end

	end

	return ent

end

net.Receive( "dbt/mapping", function(len, ply)
	net.ReadStream(ply, function(data)
		for k, i in pairs(pon.decode(data)) do 
			saveload.PPEntityFromTable(i)
		end
	end)
end)