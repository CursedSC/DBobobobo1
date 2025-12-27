-- LOTM Energy System
-- Система энергии для активации способностей

if not SERVER then return end
if not LOTM then return end

LOTM.Energy = LOTM.Energy or {}

-- Константы регенерации
local ENERGY_MAX = 100
local REGEN_BASE = 2
local REGEN_COMBAT = 0.5
local REGEN_OUT_COMBAT = 4
local COMBAT_TIMEOUT = 5 -- секунд без боя для выхода из боевого режима

-- Инициализация энергии для игрока
function LOTM.Energy.Initialize(ply)
    if not IsValid(ply) then return end
    
    ply:SetNWFloat("LOTM_Energy", ENERGY_MAX)
    ply:SetNWFloat("LOTM_LastCombat", 0)
end

-- Получить энергию игрока
function LOTM.Energy.Get(ply)
    if not IsValid(ply) then return 0 end
    return ply:GetNWFloat("LOTM_Energy", 0)
end

-- Установить энергию игрока
function LOTM.Energy.Set(ply, amount)
    if not IsValid(ply) then return end
    
    amount = math.Clamp(amount, 0, ENERGY_MAX)
    ply:SetNWFloat("LOTM_Energy", amount)
end

-- Добавить энергию
function LOTM.Energy.Add(ply, amount)
    if not IsValid(ply) then return end
    
    local current = LOTM.Energy.Get(ply)
    LOTM.Energy.Set(ply, current + amount)
end

-- Убрать энергию
function LOTM.Energy.Remove(ply, amount)
    if not IsValid(ply) then return false end
    
    local current = LOTM.Energy.Get(ply)
    if current < amount then
        return false
    end
    
    LOTM.Energy.Set(ply, current - amount)
    return true
end

-- Проверить, достаточно ли энергии
function LOTM.Energy.Has(ply, amount)
    if not IsValid(ply) then return false end
    return LOTM.Energy.Get(ply) >= amount
end

-- Отметить игрока в бою
function LOTM.Energy.SetCombat(ply)
    if not IsValid(ply) then return end
    ply:SetNWFloat("LOTM_LastCombat", CurTime())
end

-- Проверить, в бою ли игрок
function LOTM.Energy.IsInCombat(ply)
    if not IsValid(ply) then return false end
    
    local lastCombat = ply:GetNWFloat("LOTM_LastCombat", 0)
    return (CurTime() - lastCombat) < COMBAT_TIMEOUT
end

-- Регенерация энергии
timer.Create("LOTM_EnergyRegen", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local current = LOTM.Energy.Get(ply)
            
            if current < ENERGY_MAX then
                local regen = REGEN_BASE
                
                if LOTM.Energy.IsInCombat(ply) then
                    regen = REGEN_COMBAT
                else
                    regen = REGEN_OUT_COMBAT
                end
                
                LOTM.Energy.Add(ply, regen)
            end
        end
    end
end)

-- Хуки для боевого режима
hook.Add("EntityTakeDamage", "LOTM_CombatTracker", function(target, dmg)
    local attacker = dmg:GetAttacker()
    
    if IsValid(target) and target:IsPlayer() then
        LOTM.Energy.SetCombat(target)
    end
    
    if IsValid(attacker) and attacker:IsPlayer() then
        LOTM.Energy.SetCombat(attacker)
    end
end)

-- Инициализация при спавне
hook.Add("PlayerSpawn", "LOTM_EnergyInit", function(ply)
    LOTM.Energy.Initialize(ply)
end)

-- Инициализация при входе
hook.Add("PlayerInitialSpawn", "LOTM_EnergyInitialSpawn", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            LOTM.Energy.Initialize(ply)
        end
    end)
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Energy system loaded\n")