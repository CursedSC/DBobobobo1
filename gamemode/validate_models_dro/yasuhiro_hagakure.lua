player_manager.AddValidModel( "Yasuhiro Hagakure", "models/dro/player/characters1/char15/char15.mdl" );
player_manager.AddValidHands( "Yasuhiro Hagakure", "models/dro/player/characters1/char15/c_arms/char15_arms.mdl", 0, "00000000" )

--View hands code credits: https://steamcommunity.com/id/libertyforce/
if CLIENT then
 
    local function Viewmodel( vm, ply, weapon )
        if CLIENT then
            if ply:GetModel() == "models/dro/player/characters1/char15/char15.mdl" then
                local skin = ply:GetSkin()
                local hands = ply:GetHands()
                local hand_acc = ply:GetBodygroup( 4 ) -- Use the ID of the playermodel's bodygroup
                if ( weapon.UseHands or !weapon:IsScripted() ) then
                    if ( IsValid( hands ) ) then
                        hands:DrawModel()
                        hands:SetSkin( skin ) -- In case you want to change skin too
                        hands:SetBodygroup( 1 , hand_acc ) -- Use the ID of the c_hands bodygroup
                    end
                end
            end
        end
    end
    hook.Add( "PostDrawViewModel", "danganronpa_yasuhiro_hagakure", Viewmodel )
end

 