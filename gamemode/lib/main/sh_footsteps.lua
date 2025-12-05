-- ///////////////////////////////////////////////////////////////////////
-- //							Player Footsteps						//
-- //							Credit to daunknownman2010


AddCSLuaFile()

local NPC_Custom_RunFootstepLeft = {

	"player/suit_ct_01.wav",
	"player/suit_ct_02.wav",
	"player/suit_ct_03.wav",
	"player/suit_ct_04.wav",
	"player/suit_ct_05.wav",
	"player/suit_ct_06.wav",
	"player/suit_ct_07.wav",
	"player/suit_ct_08.wav"

}

local NPC_Custom_RunFootstepRight = {

	"player/suit_ct_09.wav",
	"player/suit_ct_11.wav",
	"player/suit_ct_13.wav",
	"player/suit_ct_15.wav",
	"player/suit_ct_17.wav",
	"player/suit_ct_19.wav",
	"player/suit_ct_20.wav",
	"player/suit_ct_21.wav",
	"player/suit_ct_23.wav"

}

function PLAYERFOOTSTEPS_Initialize()

	-- Show that the addon is ready to go (working/enabled).
	timer.Simple( 5, function() if ( SERVER ) then PrintMessage( HUD_PRINTTALK, "Loading Step Fumble.." ) end end )

end
hook.Add( "Initialize", "PLAYERFOOTSTEPS_Initialize", PLAYERFOOTSTEPS_Initialize )


function PLAYERFOOTSTEPS_PlayerInitialSpawn( ply )

	for k, v in pairs( NPC_Custom_RunFootstepLeft ) do
	
		ply:EmitSound( v, 75, 100, 0, CHAN_BODY )
	
	end

	for k, v in pairs( NPC_Custom_RunFootstepRight ) do
	
		ply:EmitSound( v, 75, 100, 0, CHAN_BODY )
	
	end
	
end
hook.Add( "PlayerInitialSpawn", "PLAYERFOOTSTEPS_PlayerInitialSpawn", PLAYERFOOTSTEPS_PlayerInitialSpawn )


function PLAYERFOOTSTEPS_Think()

	if ( SERVER ) then
	
		for _, ply in pairs( player.GetHumans() ) do
		
			if ( ply:IsValid() && ( ply:GetNWString( "PLAYERFOOTSTEPS_FootstepType" ) != ply:GetInfo( "cl_player_footsteps" ) ) ) then
			
				ply:SetNWString( "PLAYERFOOTSTEPS_FootstepType")
			
			end
		
		end
	
	end

end
hook.Add( "Think", "PLAYERFOOTSTEPS_Think", PLAYERFOOTSTEPS_Think )


function PLAYERFOOTSTEPS_PlayerFootstep( ply, pos, foot, sound, volume, filter )

	-- We're checking to see if the game is singleplayer or not singleplayer so prediction is properly done.
	if ( game.SinglePlayer() && CLIENT ) then return end
	if ( !game.SinglePlayer() && SERVER ) then return end
	if ( ply:IsBot() ) then return end

	if ( ply:GetNWString( "PLAYERFOOTSTEPS_FootstepType" )) then
	
		if ( foot == 0 ) then
					volume = volume * 1
			EmitSound( table.Random( NPC_Custom_RunFootstepLeft ), pos, ply:EntIndex(), CHAN_BODY, volume, 75, 0, math.random( 140, 160 ) )
		
		elseif ( foot == 1 ) then
					volume = volume * 1
			EmitSound( table.Random( NPC_Custom_RunFootstepRight ), pos, ply:EntIndex(), CHAN_BODY, volume, 75, 0, math.random( 120, 150 ) )
		
		end

end

end
hook.Add( "PlayerFootstep", "PLAYERFOOTSTEPS_PlayerFootstep", PLAYERFOOTSTEPS_PlayerFootstep )
