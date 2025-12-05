BleedingEntities = {}
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

local bonenames = {
	["ValveBiped.Bip01_Head1"] = "Голову",
	["ValveBiped.Bip01_Spine"] = "Живот",
	["ValveBiped.Bip01_Spine1"] = "Кишки",
	["ValveBiped.Bip01_Spine2"] = "Грудь",
	["ValveBiped.Bip01_Spine4"] = "Грудь",
	["ValveBiped.Bip01_Pelvis"] = "Живот",
	["ValveBiped.Bip01_R_Hand"] = "Правую руку",
	["ValveBiped.Bip01_R_Forearm"] = "Голову",
	["ValveBiped.Bip01_R_Foot"] = "Правую ногу",
	["ValveBiped.Bip01_R_Thigh"] = "Правое бедро",
	["ValveBiped.Bip01_R_Calf"] = "Правую голень",
	["ValveBiped.Bip01_R_Shoulder"] = "Правое плечо",
	["ValveBiped.Bip01_R_Elbow"] = "Правый локоть",
	["ValveBiped.Bip01_L_Hand"] = "Левую руку",
	["ValveBiped.Bip01_L_Forearm"] = "Голову",
	["ValveBiped.Bip01_L_Foot"] = "Левую ногу",
	["ValveBiped.Bip01_L_Thigh"] = "Левое бедро",
	["ValveBiped.Bip01_L_Calf"] = "Левую голень",
	["ValveBiped.Bip01_L_Shoulder"] = "Левое плечо",
	["ValveBiped.Bip01_L_Elbow"] = "Левый локоть"
}


local rightwep = {

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

local leftwep = {

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

--Хитгруппы костей
local bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = 1,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Forearm"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 4,
	["ValveBiped.Bip01_L_Forearm"] = 4,
	["ValveBiped.Bip01_L_Hand"] = 4,
	["ValveBiped.Bip01_Pelvis"] = 3,
	["ValveBiped.Bip01_Spine2"] = 2,
	["ValveBiped.Bip01_L_Thigh"] = 6, 
	["ValveBiped.Bip01_L_Calf"] = 6,
	["ValveBiped.Bip01_L_Foot"] = 6,
	["ValveBiped.Bip01_R_Thigh"] = 7,
	["ValveBiped.Bip01_R_Calf"] = 7,
	["ValveBiped.Bip01_R_Foot"] = 7
}

local dmg_type = {
	[4] = "LeftArm",
	[5] = "RightArm", 
	[6] = "LeftLeg",
	[7] = "RightLeg", 
}



hook.Add( "PlayerSwitchWeapon", "CheckRightArm", function( player, oldWeapon, newWeapon )
	if not player:GetNWBool("RightArm") and rightwep[newWeapon:GetClass()]  then
		--return true
	end
	if not player:GetNWBool("LeftArm") and leftwep[newWeapon:GetClass()]  then
		--return true
	end
	return false 
end )


hook.Add( "PlayerDeath", "GlobalDeath", function( data, inflictor, attacker )
    data:SetNWBool("LeftArm",true)
    data:SetNWBool("RightArm",true)
end )
