player_manager.AddValidModel( "Mondo Owada", "models/dro/player/characters1/char4/char4.mdl" );
player_manager.AddValidHands( "Mondo Owada", "models/dro/player/characters1/char4/c_arms/char4_arms.mdl", 0, "00000000" )

player_manager.AddValidModel( "Mondo Owada White", "models/dro/player/characters1/char4/char4_white.mdl" );
player_manager.AddValidHands( "Mondo Owada White", "models/dro/player/characters1/char4/c_arms/char4_white_arms.mdl", 0, "00000000" )


--View hands code credits: https://steamcommunity.com/id/libertyforce/
/*if CLIENT then
 
    local function Viewmodel( vm, ply, weapon )
        if CLIENT then
            if ply:GetModel() == "models/player/dewobedil/danganronpa/kiyotaka_ishimaru/default_p.mdl" then
                local skin = ply:GetSkin()
                local body = ply:GetBodygroup( 3 ) -- Use the ID of the playermodel's bodygroup
                local hands = ply:GetHands()
                if ( weapon.UseHands or !weapon:IsScripted() ) then
                    if ( IsValid( hands ) ) then
                        hands:DrawModel()
                        hands:SetSkin( skin ) -- In case you want to change skin too
                        hands:SetBodygroup( 0 , body ) -- Use the ID of the c_hands bodygroup
                    end
                end
            end
        end
    end
    hook.Add( "PostDrawViewModel", "kiyotaka_ishimaru", Viewmodel )
 
end*/

local Category = "Danganronpa Online"