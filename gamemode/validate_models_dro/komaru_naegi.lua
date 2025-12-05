player_manager.AddValidModel( "Komaru Naegi", "models/dro/player/characters4/char1/char1.mdl" );
player_manager.AddValidHands( "Komaru Naegi", "models/dro/player/characters4/char1/c_arms/char1_arms.mdl", 0, "00000000" );

--View hands code credits: https://steamcommunity.com/id/libertyforce/
if CLIENT then
 
    local function Viewmodel( vm, ply, weapon )
        if CLIENT then
            if ply:GetModel() == "models/dro/player/characters4/char1/char1.mdl" then
                local skin = ply:GetSkin()
                local hands = ply:GetHands()
                local bracelet = ply:GetBodygroup( 2 ) -- Use the ID of the playermodel's bodygroup
                if ( weapon.UseHands or !weapon:IsScripted() ) then
                    if ( IsValid( hands ) ) then
                        hands:DrawModel()
                        hands:SetSkin( skin ) -- In case you want to change skin too
                        hands:SetBodygroup( 1 , bracelet ) -- Use the ID of the c_hands bodygroup
                    end
                end
            end
        end
    end
    hook.Add( "PostDrawViewModel", "danganronpa_komaru_naegi", Viewmodel )
end

 