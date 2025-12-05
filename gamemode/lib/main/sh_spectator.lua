local GetAllPlayers = player.GetAll

spectator = spectator or { }

function spectator.IsSpectator(player)
    if  TypeID(player) ~= TYPE_ENTITY or
        not player:IsValid() or
        not player:IsPlayer()
    then
        if SERVER then
            return false
        end

        player = LocalPlayer()
    end

    return player:GetObserverMode() ~= OBS_MODE_NONE or false
end

function spectator.GetTarget(player)
    if  TypeID(player) ~= TYPE_ENTITY or
        not player:IsPlayer()
    then
        if SERVER then
            return false
        end

        player = LocalPlayer()
    end

    return player:GetObserverTarget()
end

function spectator.Spectators(player)
    local spectators = { }

    local players = GetAllPlayers()
    local countPlayers = #players

    for playerIndex = 1, countPlayers do
        if spectator.GetTarget(players[playerIndex]) == player then
            table.insert(spectators, players[playerIndex])
        end
    end

    return spectators
end



if SERVER then
    local spectators = { }

    function spectator.Spectate(player, ent, mode)
        if  not (TypeID(player) == TYPE_ENTITY and player:IsPlayer()) or
            not (IsEntity(ent) and ent:IsValid()) or
            player:GetMoveType() == MOVETYPE_NOCLIP
        then
            return
        end

        if TypeID(mode) ~= TYPE_NUMBER then
            mode = OBS_MODE_CHASE
        end

        if not spectators[player] then
            local weaponsOfPlayer = player:GetWeapons()

            for i = 1, table.Count(weaponsOfPlayer) do
                if weaponsOfPlayer[i] then
                    weaponsOfPlayer[i] = {
                        className = weaponsOfPlayer[i]:GetClass(),
                        primaryAmmoCount = player:GetAmmoCount(weaponsOfPlayer[i]:GetPrimaryAmmoType()),
                        secondaryAmmoCount = player:GetAmmoCount(weaponsOfPlayer[i]:GetSecondaryAmmoType())
                    }
                end
            end

            spectators[player] = {
                pos = player:GetPos(),
                eye = player:EyeAngles(),
                weapons = weaponsOfPlayer,
                activeWeapon = player:GetActiveWeapon():IsValid() and player:GetActiveWeapon():GetClass() or ""
            }
        end

        player:Spectate(mode)
        player:StripWeapons()
        player:StripAmmo()
        player:SpectateEntity(ent)
        player.player_index = 1
    end

    function spectator.UnSpectate(player)
        if  TypeID(player) ~= TYPE_ENTITY or
            not player:IsPlayer()
        then
            return
        end

        if not spectators[player] then
            if spectator.IsSpectator(player) then
                player:Spectate(OBS_MODE_NONE)
                player:UnSpectate()
            end

            return
        end

        local spectator = spectators[player]
        local activeWeapon

        spectators[player] = nil

        player:Spectate(OBS_MODE_NONE)
        player:SetPos(spectator.pos)
        player:UnSpectate()
        player:Spawn()
        player:StripWeapons()
        player:StripAmmo()

        player:SetNoDraw(false)

        player:DrawViewModel(true)
        player:DrawWorldModel(true)

        player:SetPos(spectator.pos)
        player:SetEyeAngles(spectator.eye)

        for _, weapon in pairs(spectator.weapons) do
            if weapon and weapon.className then
                local _weapon = player:Give(weapon.className, true)

                if _weapon.GetPrimaryAmmoType then
                    player:SetAmmo(weapon.primaryAmmoCount, _weapon:GetPrimaryAmmoType())
                end

                if _weapon.GetSecondaryAmmoType then
                    player:SetAmmo(weapon.secondaryAmmoCount, _weapon:GetSecondaryAmmoType())
                end

                if weapon.className == spectator.activeWeapon then
                    activeWeapon = _weapon
                end
            end
        end

        if activeWeapon then
            player:SetActiveWeapon(activeWeapon)
        end
    end

    function spectator.UnSpectateAll()
        local players, playerIndex = player.GetAll(), nil

        repeat
            playerIndex = next(players, playerIndex)
            if playerIndex == nil then break end

            local player = players[playerIndex]

            spectator.UnSpectate(player)

        until false
    end

    hook.Add("Think", "spectator.watchOnTheEntity", function()
        for player, spectate in pairs(spectators) do
            if spectator.IsSpectator(player) then
                if player:GetObserverTarget():IsValid() then
                    player:SetPos(player:GetObserverTarget():GetPos())
                end

                player:SetNoDraw(true)
            else
                spectators[player] = nil
            end
        end
    end)

    hook.Add("PlayerNoClip", "spectator.noclip", function(player, desiredState)
        if spectator.IsSpectator(player) and not desiredState then
            return false
        end
    end)

    hook.Add("ShouldCollide", "spectator.collide", function(ent1, ent2)
        if spectator.IsSpectator(ent1) or spectator.IsSpectator(ent2) then
            return false
        end
    end)
end