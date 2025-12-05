--
local dumb = {}

hook.Add("PlayerDisconnected", "dbt/exit/check", function( ply )
	local bval = InGame(ply)
	if not bval then return end 
	dumb[ply:Name()] = {}

	dumb[ply:Name()].inventory = ply.items or {}
	dumb[ply:Name()].info = ply.info or {}
	dumb[ply:Name()].pos = ply:GetPos()
	dumb[ply:Name()].chr = ply:Pers()

	local weapon = {}
	for k, wep in pairs(ply:GetWeapons()) do 
		weapon[#weapon + 1] = wep:GetClass()
	end

	dumb[ply:Name()].wep = weapon
end)

hook.Add( "PlayerInitialSpawn", "dbt/exit/return", function( ply )
	netstream.Start(ply, "dbt.Sync.CHR", dbt.chr)
	timer.Simple(5, function()
		if dumb[ply:Name()] then 
			ply.spawned = true
			local chach = dumb[ply:Name()]
			dbt.setchr(ply, chach.chr)
			ply.items = chach.inventory
			ply.info = chach.info
			ply:SetPos(chach.pos)
			for k, i in pairs(chach.wep) do 
				ply:Give(i)
			end
			AddInGame(ply)

			if ply.info.monopad and ply.info.monopad.meta then 
				ply:SetNWString("MonoOwner", ply.info.monopad.meta.owner)
			end
			if ply.info.keys and ply.info.keys.meta then 
				ply:SetNWString("KeyOwner", ply.info.keys.meta.owner)
			end

			netstream.Start(ply, "dbt/inventory/info", ply.info)

			dbt.inventory.SendUpdate(ply)
			ply:SetPos(chach.pos)

			timer.Simple(5, function()
				for i = 1, #chach.wep do 
					ply:Give(chach.wep[i])
				end
			end)
			ply.spawned = false

			if IsClassTrial() then
				ply:Freeze(true)
        		ply:SetRenderMode( RENDERMODE_NONE)

        		net.Start("dbt.GetTable")
		            net.WriteTable(Spots)
		        net.Send(ply)
		        net.Start("dbt/classtrial/update/mnualy")
		            net.WriteTable(GPS_POS)
		            net.WriteTable(normal_camera_position)
		        net.Send(ply)
		        netstream.Start(ply, "dbt.InCT")
        	end



		end
	end)
end)