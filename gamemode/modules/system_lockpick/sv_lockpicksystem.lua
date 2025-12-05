AddCSLuaFile()

netstream.Hook("dbt/lockpick/success_lockpick", function(ply, ent)
	if ent:IsValid() then
		if ent:GetNWBool("dbt.NoLockpick") then return end
		ent:Fire("Unlock")
	end
end)

netstream.Hook("dbt/deletelockpick", function(ply, slot)
	if ply:IsValid() then
		dbt.inventory.removeitem(ply, slot)
	end
end)

netstream.Hook("dbt/systemspectate/startspectate", function(ply, ent, test)
	if ply:IsValid() then
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity( test )
	end
	ply.IsSpectate = true
	ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
	hook.Add("Think", "dbt/systemspectate/checkspectate"..ply:SteamID(),function ()
		if ply and not InGame(ply:GetObserverTarget()) then
			for k, v in pairs(player.GetAll()) do
				if InGame(v) and not IsMono(v) then
					ply:SpectateEntity(v)

					ply.IsSpectate = true
				end
			end
		end
	end)
end)

netstream.Hook("dbt/systemspectate/stopspectate", function(ply)
	if ply:IsValid() then
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		timer.Simple(0.1,function ()
			ply:KillSilent()
			ply:Spawn()
		end)
		hook.Remove("Think", "dbt/systemspectate/checkspectate"..ply:SteamID())
		ply.IsSpectate = false
	end
end)
