player_manager.AddValidModel( "Mukuro Ikusaba", "models/dro/player/characters1/char16/char16.mdl" );
player_manager.AddValidHands( "Mukuro Ikusaba", "models/dro/player/characters1/char16/c_arms/char16_arms.mdl", 0, "00000000" )

player_manager.AddValidModel( "Mukuro Ikusaba HP", "models/dro/player/characters1/char16/char16_uniformhp.mdl" );
player_manager.AddValidHands( "Mukuro Ikusaba HP", "models/dro/player/characters1/char16/c_arms/char16_uniform_hp_arms.mdl", 0, "00000000" )

--View hands code credits: https://steamcommunity.com/id/libertyforce/
if CLIENT then
 
    local function Viewmodel( vm, ply, weapon )
        if CLIENT then
            if ply:GetModel() == "models/dro/player/characters1/char16/char16.mdl" then
                local skin = ply:GetSkin()
                local hands = ply:GetHands()
                local tattoo = ply:GetBodygroup( 3 ) -- Use the ID of the playermodel's bodygroup
                if ( weapon.UseHands or !weapon:IsScripted() ) then
                    if ( IsValid( hands ) ) then
                        hands:DrawModel()
                        hands:SetSkin( skin ) -- In case you want to change skin too
                        hands:SetBodygroup( 1 , tattoo ) -- Use the ID of the c_hands bodygroup
                    end
                end
            end
        end
    end
    hook.Add( "PostDrawViewModel", "mukuro_ikusaba", Viewmodel )
end

--View hands code credits: https://steamcommunity.com/id/libertyforce/
if CLIENT then
 
    local function Viewmodel( vm, ply, weapon )
        if CLIENT then
            if ply:GetModel() == "models/dro/player/characters1/char16/char16_uniformhp.mdl" then
                local skin = ply:GetSkin()
                local hands = ply:GetHands()
                local tattoo = ply:GetBodygroup( 3 ) -- Use the ID of the playermodel's bodygroup
                if ( weapon.UseHands or !weapon:IsScripted() ) then
                    if ( IsValid( hands ) ) then
                        hands:DrawModel()
                        hands:SetSkin( skin ) -- In case you want to change skin too
                        hands:SetBodygroup( 1 , tattoo ) -- Use the ID of the c_hands bodygroup
                    end
                end
            end
        end
    end
    hook.Add( "PostDrawViewModel", "mukuro_ikusaba", Viewmodel )
end

 