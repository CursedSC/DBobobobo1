dbt.moves = {
    ["light"] = { walk = 80, run = 195, jump = 200 },
    ["normal"] = { walk = 80, run = 195, jump = 200 },
    ["height"] = { walk = 80, run = 195, jump = 200 },
    ["none"] = { walk = 40, run = 100, jump = 0 },
    ["ex"] = { walk = 80, run = 160, jump = 200 },
    ["fracture"] = { walk = 50, run = 50, jump = 0 },
    ["disable"] = { walk = 0, run = 0, jump = 0 },
}

SetGlobalBool("NagitoStatus", true)

function dbt.movement(type, ply)
    local moveData = dbt.moves[type] or dbt.moves["normal"]
    local hp = ply:Health()

    if ply.FirstDamage and hp <= 20 then
        ply:SetNWBool("Adrenaline", true)
        ply.FirstDamage = false

        timer.Simple(5, function()
            ply:SetNWBool("Adrenaline", false)
            ply:ConCommand("-speed")
        end)

        ply:SetWalkSpeed(moveData.walk)
        ply:SetRunSpeed(moveData.run + 40)
        ply:SetJumpPower(moveData.jump)
        return
    end

    ply.fast_multy = ply.fast_multy or 1
    local runSpeed = dbt.chr[ply:Pers()].runSpeed or 195
    ply:SetWalkSpeed(moveData.walk)
    ply:SetJumpPower(moveData.jump)
    ply:SetSlowWalkSpeed(moveData.walk)
    if type == "fracture" then
        ply:SetRunSpeed(50)
    elseif type == "disable" then
        ply:SetRunSpeed(2)
        ply:SetWalkSpeed(2)
        ply:SetJumpPower(0)
    elseif type == "none" then
        ply:SetWalkSpeed(moveData.walk)
        ply:SetRunSpeed(moveData.run)
        ply:SetJumpPower(moveData.jump)
    else
        ply:SetRunSpeed(runSpeed + (runSpeed / 100 * ply.fast_multy))
    end
end

function dbt.adjustStamina(ply, amount)
    local amount = amount or 0
    local currentStamina = currentStamina or 0
    if ply:Pers() == "K1-B0" then return end
    local char = dbt.chr[ply:Pers()] 
    local maxstamina = char.maxStamina or 100
    local currentStamina = ply:GetNWInt("Stamina")
    local newStamina = math.Clamp(currentStamina + amount, 0, maxstamina)
    ply:SetNWInt("Stamina", newStamina)
end

function dbt.handleMovementLogic(ply)
    local char = dbt.chr[ply:Pers()]
    if ply.isCooking then
        dbt.movement("disable", ply)
    elseif dbt.hasWoundOnpos(ply, "Перелом", "Правая нога") or dbt.hasWoundOnpos(ply, "Перелом", "Левая нога") then
        dbt.movement("fracture", ply)
    elseif ply.info.kg > (char.maxKG) and ply.info.kg <= (char.maxKG + 5) then 
        dbt.movement("none", ply)
    elseif ply.info.kg > (char.maxKG + 5)  then 
        dbt.movement("disable", ply)
    elseif ply:GetNWInt("Stamina") <= 5 or ply:GetNWInt("VerySleepy") == 1 then
        dbt.movement("none", ply) 
        ply:ConCommand("-speed")
    elseif ply:Pers() == "Нагито Комаэда" and GetGlobalBool("NagitoStatus") then
        dbt.movement("ex", ply)
    elseif ply:GetNWInt("Stamina") >= 20 then
        dbt.movement("normal", ply)
    end
end

local function CreateTimer()
    timer.Create("dbt/stamina/tick", 0.1, 0, function() 
        for _, ply in ipairs(player.GetHumans()) do
            if not IsValid(ply) or not IsGame() or not InGame(ply) then
                continue
            end
            local staminaChange = 0
            if ply:IsRunning() then
                staminaChange = ply:Pers() == "Нагито Комаэда" and GetGlobalBool("NagitoStatus") and -2 or -0.6
            elseif ply:GetVelocity():LengthSqr() == 0 then
    			staminaChange = ply:Pers() == "Нагито Комаэда" and GetGlobalBool("NagitoStatus") and 1 or 1
    		else
                staminaChange = ply:Pers() == "Нагито Комаэда" and GetGlobalBool("NagitoStatus") and 0.5 or 0.5
            end

            dbt.adjustStamina(ply, staminaChange)
            dbt.handleMovementLogic(ply)
        end
    end)
end
CreateTimer()
-- Крутая проверка на лоха
timer.Create("Check(dbt/stamina/tick)", 60, 0, function()
    if not timer.Exists("dbt/stamina/tick") then 
        CreateTimer()
    end
end)

hook.Add("EntityTakeDamage", "dbt.EntityDamageHandler", function(target, dmginfo)
    if target:IsPlayer() and target:Health() <= 20 then
        dbt.movement("normal", target)
    end
end)

netstream.Hook("dbt.cookingdisablemove", function(ply)
    ply.isCooking = not ply.isCooking
end)

hook.Add("PlayerUse", "dbt.preventCookingUse", function(ply)
    if ply.isCooking then return false end
end)

hook.Add("OnPlayerJump", "dbt.staminaonjump",function (ply)
    if not IsValid(ply) or not IsGame() or not InGame(ply) or ply.isSpectating then
        return
    end
	dbt.adjustStamina(ply, -10)
end)

hook.Add("dbt.OnPlayerAttack_melee", "dbt.staminaonattack",function (ply, stamina)
    if not IsValid(ply) or not IsGame() or not InGame(ply) or ply.isSpectating then
        return
    end
	dbt.adjustStamina(ply, stamina)
end)
