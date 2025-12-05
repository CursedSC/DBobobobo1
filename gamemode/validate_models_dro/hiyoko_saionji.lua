player_manager.AddValidModel( "Hiyoko Saionji", "models/dro/player/characters2/char12/char12.mdl" );
player_manager.AddValidHands( "Hiyoko Saionji", "models/dro/player/characters2/char12/c_arms/char12_arms.mdl", 0, "00000000" )

--View hands code credits: https://steamcommunity.com/id/libertyforce/
if CLIENT then
 
    local function Viewmodel( vm, ply, weapon )
        if CLIENT then
            if ply:GetModel() == "models/dro/player/characters2/char12/char12.mdl" then
                local skin = ply:GetSkin()
                local hands = ply:GetHands()
                if ( weapon.UseHands or !weapon:IsScripted() ) then
                    if ( IsValid( hands ) ) then
                        hands:DrawModel()
                        hands:SetSkin( skin ) -- In case you want to change skin too
                    end
                end
            end
        end
    end
    hook.Add( "PostDrawViewModel", "hiyoko_saionji", Viewmodel )
end

local Category = "Danganronpa Online"