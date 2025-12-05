player_manager.AddValidModel( "Kaede Akamatsu (V3)", 				"models/someguy/kaede_akamatsu/kaede_akamatsu_p.mdl" )
list.Set( "PlayerOptionsModel",  "Kaede Akamatsu (V3)",				"models/someguy/kaede_akamatsu/kaede_akamatsu_p.mdl" )
player_manager.AddValidHands( "Kaede Akamatsu (V3)", 				"models/someguy/kaede_akamatsu/kaede_akamatsu_arms.mdl", 0, "00000000")

local Category = "Danganronpa"

local NPC =
{
	Name = "Kaede Akamatsu (V3, Friendly)",
	Class = "npc_citizen",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Model = "models/someguy/kaede_akamatsu/kaede_akamatsu_f.mdl",
	Category = Category
}

list.Set( "NPC", "kaede_v3_f", NPC )

local NPC =
{
	Name = "Kaede Akamatsu (V3, Enemy)",
	Class = "npc_combine_s",
	Health = "100",
	Numgrenades = "4",
	Model = "models/someguy/kaede_akamatsu/kaede_akamatsu_f.mdl",
	Category = Category
}

list.Set( "NPC", "kaede_v3_e", NPC )