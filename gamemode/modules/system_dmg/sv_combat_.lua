local rightwep_d = {

	["tfa_nmrih_bow"] = true,
	["tfa_nmrih_tnt"] = true,
	["tfa_nmrih_fubar"] = true,
	["tfa_nmrih_asaw"] = true,
	["tfa_nmrih_bat"] = true,
	["tfa_nmrih_chainsaw"] = true,
	["tfa_nmrih_wrench"] = true,
	["tfa_nmrih_etool"] = true,
	["tfa_l4d2_kfkat"] = true,
	["tfa_nmrih_pickaxe"] = true,
	["tfa_nmrih_bcd"] = true,
	["tfa_nmrih_kknife"] = true,
	["tfa_nmrih_bcd"] = true,
	["tfa_nmrih_sledge"] = true,
	["tfa_nmrih_crowbar"] = true,
	["tfa_nmrih_spade"] = true,
	["tfa_nmrih_machete"] = true,
	["tfa_nmrih_molotov"] = true,
	["tfa_nmrih_fext"] = true,
	["tfa_nmrih_zippo"] = true,
	["tfa_nmrih_frag"] = true,
	["tfa_nmrih_fireaxe"] = true,
	["tfa_nmrih_flaregun"] = true,
	["tfa_nmrih_welder"] = true,
	["tfa_nmrih_lpipe"] = true,
	["tfa_nmrih_cleaver"] = true,
	["tfa_nmrih_hatchet"] = true,
	["tfa_l4d2_talaxe"] = true,
	["tfa_nmrih_m92fs"] = true,
	["tfa_nmrih_sv10"] = true,
	["tfa_nmrih_m16_ch"] = true,
	["tfa_nmrih_m16_rt"] = true,
	["tfa_nmrih_1911"] = true,
	["tfa_nmrih_cz"] = true,
	["tfa_nmrih_fal"] = true,
	["tfa_nmrih_g17"] = true,
	["tfa_nmrih_mp5"] = true,
	["tfa_nmrih_jae700"] = true,
	["tfa_nmrih_mac10"] = true,
	["tfa_nmrih_500a"] = true,
	["tfa_nmrih_870"] = true,
	["tfa_nmrih_rug1022"] = true,
	["tfa_nmrih_rug1022_25"] = true,
	["tfa_nmrih_mkiii"] = true,
	["tfa_nmrih_sako"] = true,
	["tfa_nmrih_sako_is"] = true,
	["tfa_nmrih_sks"] = true,
	["tfa_nmrih_sks_nb"] = true,
	["tfa_nmrih_sw686"] = true,
	["tfa_nmrih_1892"] = true,
	["tfa_nmrih_superx3"] = true,

}

local leftwep_d = {

	["tfa_nmrih_bat"] = true,
	["tfa_nmrih_fubar"] = true,
	["tfa_nmrih_asaw"] = true,
	["tfa_nmrih_chainsaw"] = true,
	["tfa_nmrih_etool"] = true,
	["tfa_l4d2_kfkat"] = true,
	["tfa_nmrih_pickaxe"] = true,
	["tfa_nmrih_sledge"] = true,
	["tfa_nmrih_spade"] = true,
	["tfa_nmrih_fext"] = true,
	["weapon_vfirethrower"] = true,
	["tfa_nmrih_fireaxe"] = true,
	["tfa_l4d2_talaxe"] = true,
	["tfa_nmrih_bow"] = true,
	["tfa_nmrih_sv10"] = true,
	["tfa_nmrih_m16_ch"] = true,
	["tfa_nmrih_m16_rt"] = true,
	["tfa_nmrih_cz"] = true,
	["tfa_nmrih_fal"] = true,
	["tfa_nmrih_mp5"] = true,
	["tfa_nmrih_jae700"] = true,
	["tfa_nmrih_500a"] = true,
	["tfa_nmrih_870"] = true,
	["tfa_nmrih_rug1022"] = true,
	["tfa_nmrih_rug1022_25"] = true,
	["tfa_nmrih_sako"] = true,
	["tfa_nmrih_sako_is"] = true,
	["tfa_nmrih_sks"] = true,
	["tfa_nmrih_sks_nb"] = true,
	["tfa_nmrih_1892"] = true,
	["tfa_nmrih_superx3"] = true,

}

local dmg_type = {
	[4] = "LeftArm",
	[5] = "RightArm", 
	[6] = "LeftLeg",
	[7] = "RightLeg", 
}

util.AddNetworkString("dbt.RegisterDMG.print")

net.Receive("dbt.RegisterDMG.print", function()
	local ent = net.ReadEntity()
	local hit_b = net.ReadFloat()

	if hit_b == 5 and ! ent:GetActiveWeapon():GetClass() == "hands" then --and ent:GetActiveWeapon():GetClass() != "hands"
		me_com(ent,"/me от боли в руки случайно выронил(а) оружие.")
		wep_com(ent,"1")
	end

	if dmg_type[hit_b] then 
		if hit_b == 4 then 
			ent.brokenleft = true
			timer.Simple(300, function() ent.brokenleft = false end)
		end
		if hit_b == 5 then 
			ent.brokenright = true
			timer.Simple(300, function() ent.brokenright = false end)
		end
	end
end)

hook.Add( "PlayerSwitchWeapon", "dbt.arm.dmg", function( player, oldWeapon, newWeapon )
	--[[
	if player.brokenright and rightwep[newWeapon:GetClass()]  then
		return true
	end
	if player.brokenleft and leftwep[newWeapon:GetClass()]  then
		return true
	end

 
	
 --[[
	if player.isswitching then 
		timer.Simple(1, function() player:SelectWeapon( newWeapon:GetClass() ) player.isswitching = true   end)
		player.isswitching  = false

		if not (newWeapon:GetClass() == "weapon_physgun" or newWeapon:GetClass() == "gmod_tool") then
			net.Start("rp.OpenAnim")
				net.WriteEntity(player)
			net.Send(player)
			return true
		end
	else
	end]]
end )
util.AddNetworkString("rp.OpenAnim")

concommand.Add("Repair", function()

	for k,i in pairs(player.GetAll()) do 
		i.brokenleft = false
		i.brokenright = false
	end

end)--