-- LOTM Skills Core System
-- Ядро системы скиллов с keybind поддержкой

LOTM = LOTM or {}
LOTM.Skills = LOTM.Skills or {}
LOTM.PlayerSkills = LOTM.PlayerSkills or {}

-- Структура скилла
--[[
{
    id = "unique_skill_id",
    name = "Название скилла",
    description = "Описание",
    pathway = "Hunter", -- Путь LOTM
    sequence = 9, -- Последовательность (9 = самая низкая)
    
    energyCost = 50,
    cooldown = 10,
    
    areaType = LOTM.AreaShapes.Types.SPHERE,
    areaData = { radius = 100 },
    
    damageType = LOTM.DamageTypes.PHYSICAL,
    damage = 50,
    
    onUse = function(ply, skillData) end,
}
]]

-- Регистрация скилла
function LOTM.RegisterSkill(skillData)
    if not skillData.id then
        ErrorNoHalt("[LOTM] Попытка регистрации скилла без ID!\n")
        return
    end
    
    LOTM.Skills[skillData.id] = skillData
    print("[LOTM] Зарегистрирован скилл: " .. skillData.id)
end

-- Получить скилл по ID
function LOTM.GetSkill(skillID)
    return LOTM.Skills[skillID]
end

-- Получить все скиллы пути
function LOTM.GetPathwaySkills(pathway, sequence)
    local skills = {}
    
    for id, skill in pairs(LOTM.Skills) do
        if skill.pathway == pathway then
            if not sequence or skill.sequence == sequence then
                table.insert(skills, skill)
            end
        end
    end
    
    return skills
end

if SERVER then
    util.AddNetworkString("LOTM.UseSkill")
    util.AddNetworkString("LOTM.SkillCooldown")
    util.AddNetworkString("LOTM.LearnSkill")
    util.AddNetworkString("LOTM.SyncSkills")
    
    -- Инициализация скиллов игрока
    function LOTM.InitPlayerSkills(ply)
        ply.LOTMSkills = ply.LOTMSkills or {}
        ply.LOTMSkillCooldowns = ply.LOTMSkillCooldowns or {}
    end
    
    -- Выучить скилл
    function LOTM.LearnSkill(ply, skillID)
        if not LOTM.Skills[skillID] then
            ErrorNoHalt("[LOTM] Попытка выучить несуществующий скилл: " .. tostring(skillID) .. "\n")
            return false
        end
        
        if not ply.LOTMSkills then LOTM.InitPlayerSkills(ply) end
        
        if not table.HasValue(ply.LOTMSkills, skillID) then
            table.insert(ply.LOTMSkills, skillID)
            
            net.Start("LOTM.SyncSkills")
            net.WriteTable(ply.LOTMSkills)
            net.Send(ply)
            
            return true
        end
        
        return false
    end
    
    -- Проверка кулдауна
    function LOTM.IsSkillOnCooldown(ply, skillID)
        if not ply.LOTMSkillCooldowns then return false end
        local cooldownEnd = ply.LOTMSkillCooldowns[skillID] or 0
        return CurTime() < cooldownEnd
    end
    
    -- Установить кулдаун
    function LOTM.SetSkillCooldown(ply, skillID, duration)
        if not ply.LOTMSkillCooldowns then ply.LOTMSkillCooldowns = {} end
        ply.LOTMSkillCooldowns[skillID] = CurTime() + duration
        
        net.Start("LOTM.SkillCooldown")
        net.WriteString(skillID)
        net.WriteFloat(duration)
        net.Send(ply)
    end
    
    -- Использование скилла
    function LOTM.UseSkill(ply, skillID)
        if not IsValid(ply) or not ply:Alive() then return false end
        if not ply.LOTMSkills or not table.HasValue(ply.LOTMSkills, skillID) then return false end
        
        local skill = LOTM.GetSkill(skillID)
        if not skill then return false end
        
        -- Проверка кулдауна
        if LOTM.IsSkillOnCooldown(ply, skillID) then
            ply:ChatPrint("Скилл на перезарядке!")
            return false
        end
        
        -- Проверка энергии
        if ply.GetEnergy and ply:GetEnergy() < (skill.energyCost or 0) then
            ply:ChatPrint("Недостаточно энергии!")
            return false
        end
        
        -- Снять энергию
        if skill.energyCost and skill.energyCost > 0 and ply.AddEnergy then
            ply:AddEnergy(-skill.energyCost)
        end
        
        -- Установить кулдаун
        if skill.cooldown and skill.cooldown > 0 then
            LOTM.SetSkillCooldown(ply, skillID, skill.cooldown)
        end
        
        -- Выполнить скилл
        if skill.onUse then
            skill.onUse(ply, skill)
        end
        
        return true
    end
    
    -- Сетевой обработчик использования скилла
    net.Receive("LOTM.UseSkill", function(len, ply)
        local skillID = net.ReadString()
        LOTM.UseSkill(ply, skillID)
    end)
    
    hook.Add("PlayerInitialSpawn", "LOTM.InitSkills", function(ply)
        LOTM.InitPlayerSkills(ply)
    end)
end

if CLIENT then
    LOTM.ClientSkills = LOTM.ClientSkills or {}
    LOTM.SkillCooldowns = LOTM.SkillCooldowns or {}
    
    -- Использовать скилл (клиент)
    function LOTM.ClientUseSkill(skillID)
        net.Start("LOTM.UseSkill")
        net.WriteString(skillID)
        net.SendToServer()
    end
    
    -- Получение кулдауна
    net.Receive("LOTM.SkillCooldown", function()
        local skillID = net.ReadString()
        local duration = net.ReadFloat()
        LOTM.SkillCooldowns[skillID] = CurTime() + duration
    end)
    
    -- Синхронизация скиллов
    net.Receive("LOTM.SyncSkills", function()
        LOTM.ClientSkills = net.ReadTable()
    end)
    
    -- Проверка кулдауна (клиент)
    function LOTM.GetSkillCooldown(skillID)
        local cooldownEnd = LOTM.SkillCooldowns[skillID] or 0
        local remaining = math.max(0, cooldownEnd - CurTime())
        return remaining
    end
end

print("[LOTM] Ядро системы скиллов загружено")