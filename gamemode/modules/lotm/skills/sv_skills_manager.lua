-- LOTM Skills Server Manager v3.0
-- Серверная логика скиллов

if not SERVER then return end

LOTM = LOTM or {}
LOTM.Skills = LOTM.Skills or {}

-- Network strings
util.AddNetworkString("LOTM.Skills.Unlock")
util.AddNetworkString("LOTM.Skills.Sync")
util.AddNetworkString("LOTM.Skills.Notify")
util.AddNetworkString("LOTM.Skills.Use")

-- =============================================
-- БАЗА ДАННЫХ
-- =============================================

function LOTM.Skills.InitDatabase()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_player_skills (
            steamid TEXT PRIMARY KEY,
            skill_points INTEGER DEFAULT 0,
            unlocked_skills TEXT,
            equipped_skills TEXT
        )
    ]])
end

LOTM.Skills.InitDatabase()

-- Сохранение данных игрока
function LOTM.Skills.SavePlayer(ply)
    if not IsValid(ply) then return end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    local data = LOTM.Skills.PlayerData[pid]
    if not data then return end
    
    local unlockedJson = util.TableToJSON(data.unlocked or {})
    local equippedJson = util.TableToJSON(data.equipped or {})
    
    sql.Query(string.format(
        "INSERT OR REPLACE INTO lotm_player_skills (steamid, skill_points, unlocked_skills, equipped_skills) VALUES (%s, %d, %s, %s)",
        sql.SQLStr(pid),
        data.skillPoints or 0,
        sql.SQLStr(unlockedJson),
        sql.SQLStr(equippedJson)
    ))
end

-- Загрузка данных игрока
function LOTM.Skills.LoadPlayer(ply)
    if not IsValid(ply) then return end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    local result = sql.Query(string.format(
        "SELECT * FROM lotm_player_skills WHERE steamid = %s",
        sql.SQLStr(pid)
    ))
    
    LOTM.Skills.PlayerData[pid] = {
        unlocked = {},
        equipped = {},
        skillPoints = 3, -- Начальные очки
        totalSpent = 0,
    }
    
    if result and result[1] then
        local row = result[1]
        LOTM.Skills.PlayerData[pid].skillPoints = tonumber(row.skill_points) or 3
        
        if row.unlocked_skills then
            local unlocked = util.JSONToTable(row.unlocked_skills)
            if unlocked then
                LOTM.Skills.PlayerData[pid].unlocked = unlocked
            end
        end
        
        if row.equipped_skills then
            local equipped = util.JSONToTable(row.equipped_skills)
            if equipped then
                LOTM.Skills.PlayerData[pid].equipped = equipped
            end
        end
    end
    
    -- Применяем пассивные бонусы
    LOTM.Skills.ApplyPassiveBonuses(ply)
    
    -- Синхронизируем с клиентом
    LOTM.Skills.SyncToClient(ply)
end

-- =============================================
-- ПРИМЕНЕНИЕ ПАССИВНЫХ БОНУСОВ
-- =============================================

function LOTM.Skills.ApplyPassiveBonuses(ply)
    if not IsValid(ply) then return end
    
    local data = LOTM.Skills.GetPlayerData(ply)
    if not data then return end
    
    -- Сбрасываем все бонусы
    for _, skill in pairs(LOTM.Skills.Registry) do
        if skill.bonuses then
            for stat, _ in pairs(skill.bonuses) do
                ply:SetNWFloat("LOTM_Bonus_" .. stat, 0)
            end
        end
    end
    
    -- Применяем бонусы от разблокированных пассивок
    for skillId, unlocked in pairs(data.unlocked) do
        if unlocked then
            local skill = LOTM.Skills.Get(skillId)
            if skill and skill.skillType == LOTM.Skills.Types.PASSIVE and skill.bonuses then
                for stat, value in pairs(skill.bonuses) do
                    local current = ply:GetNWFloat("LOTM_Bonus_" .. stat, 0)
                    ply:SetNWFloat("LOTM_Bonus_" .. stat, current + value)
                end
                
                -- Вызываем callback
                if skill.onApply then
                    skill.onApply(ply, skill)
                end
            end
        end
    end
end

-- =============================================
-- СИНХРОНИЗАЦИЯ
-- =============================================

function LOTM.Skills.SyncToClient(ply)
    if not IsValid(ply) then return end
    
    local data = LOTM.Skills.GetPlayerData(ply)
    if not data then return end
    
    local unlockedList = {}
    for skillId, unlocked in pairs(data.unlocked) do
        if unlocked then
            table.insert(unlockedList, skillId)
        end
    end
    
    net.Start("LOTM.Skills.Sync")
    net.WriteUInt(data.skillPoints or 0, 16)
    net.WriteUInt(#unlockedList, 16)
    for _, skillId in ipairs(unlockedList) do
        net.WriteString(skillId)
    end
    net.Send(ply)
end

function LOTM.Skills.Notify(ply, message, color)
    net.Start("LOTM.Skills.Notify")
    net.WriteString(message)
    net.WriteColor(color or Color(255, 255, 255))
    net.Send(ply)
end

-- =============================================
-- ОБРАБОТКА ЗАПРОСОВ
-- =============================================

net.Receive("LOTM.Skills.Unlock", function(len, ply)
    local skillId = net.ReadString()
    
    local success, reason = LOTM.Skills.Unlock(ply, skillId)
    
    if success then
        local skill = LOTM.Skills.Get(skillId)
        LOTM.Skills.Notify(ply, "Изучено: " .. (skill and skill.name or skillId), Color(100, 255, 100))
        LOTM.Skills.SavePlayer(ply)
        LOTM.Skills.SyncToClient(ply)
        LOTM.Skills.ApplyPassiveBonuses(ply)
    else
        LOTM.Skills.Notify(ply, reason or "Не удалось изучить скилл", Color(255, 100, 100))
    end
end)

net.Receive("LOTM.Skills.Use", function(len, ply)
    local skillId = net.ReadString()
    
    LOTM.Skills.UseSkill(ply, skillId)
end)

-- =============================================
-- ИСПОЛЬЗОВАНИЕ СКИЛЛА
-- =============================================

LOTM.Skills.Cooldowns = LOTM.Skills.Cooldowns or {}
LOTM.Skills.Charges = LOTM.Skills.Charges or {}

function LOTM.Skills.UseSkill(ply, skillId)
    if not IsValid(ply) or not ply:Alive() then return end
    
    local skill = LOTM.Skills.Get(skillId)
    if not skill then
        LOTM.Skills.Notify(ply, "Скилл не найден", Color(255, 100, 100))
        return
    end
    
    -- Проверка разблокировки
    if not LOTM.Skills.IsUnlocked(ply, skillId) then
        LOTM.Skills.Notify(ply, "Скилл не изучен!", Color(255, 100, 100))
        return
    end
    
    -- Только активные скиллы
    if skill.skillType ~= LOTM.Skills.Types.ACTIVE then
        return
    end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    -- Проверка кулдауна/зарядов
    if skill.maxCharges and skill.maxCharges > 1 then
        LOTM.Skills.Charges[pid] = LOTM.Skills.Charges[pid] or {}
        if LOTM.Skills.Charges[pid][skillId] == nil then
            LOTM.Skills.Charges[pid][skillId] = skill.maxCharges
        end
        
        if LOTM.Skills.Charges[pid][skillId] <= 0 then
            LOTM.Skills.Notify(ply, "Нет зарядов!", Color(255, 200, 100))
            return
        end
        
        LOTM.Skills.Charges[pid][skillId] = LOTM.Skills.Charges[pid][skillId] - 1
        
        -- Запускаем восстановление заряда
        local timerName = "LOTM_ChargeRegen_" .. pid .. "_" .. skillId
        if not timer.Exists(timerName) then
            timer.Create(timerName, skill.chargeRegenTime or 5, 0, function()
                if not IsValid(ply) then
                    timer.Remove(timerName)
                    return
                end
                
                LOTM.Skills.Charges[pid][skillId] = (LOTM.Skills.Charges[pid][skillId] or 0) + 1
                
                if LOTM.Skills.Charges[pid][skillId] >= skill.maxCharges then
                    LOTM.Skills.Charges[pid][skillId] = skill.maxCharges
                    timer.Remove(timerName)
                end
            end)
        end
    else
        LOTM.Skills.Cooldowns[pid] = LOTM.Skills.Cooldowns[pid] or {}
        local cdEnd = LOTM.Skills.Cooldowns[pid][skillId] or 0
        
        if CurTime() < cdEnd then
            local remaining = math.ceil(cdEnd - CurTime())
            LOTM.Skills.Notify(ply, "Кулдаун: " .. remaining .. " сек", Color(255, 200, 100))
            return
        end
        
        if skill.cooldown and skill.cooldown > 0 then
            LOTM.Skills.Cooldowns[pid][skillId] = CurTime() + skill.cooldown
        end
    end
    
    -- Звук
    if skill.visuals and skill.visuals.castSound then
        ply:EmitSound(skill.visuals.castSound)
    end
    
    -- Анимация
    if skill.animation and skill.animation.gesture then
        ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, skill.animation.gesture)
    end
    
    -- Кастомная логика
    if skill.onCast then
        skill.onCast(ply, skill)
    end
    
    -- Урон
    if skill.damage and skill.damage.enabled then
        LOTM.Skills.ApplyDamage(ply, skill)
    end
    
    -- Уведомление
    LOTM.Skills.Notify(ply, "Активировано: " .. skill.name, Color(100, 200, 255))
end

function LOTM.Skills.ApplyDamage(ply, skill)
    local dmgData = skill.damage
    local range = dmgData.range or 200
    local radius = dmgData.radius or 0
    
    if radius > 0 then
        for _, target in ipairs(ents.FindInSphere(ply:GetPos(), radius)) do
            if target:IsPlayer() and target ~= ply and target:Alive() then
                local dmg = DamageInfo()
                dmg:SetDamage(dmgData.amount or 10)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(ply)
                target:TakeDamageInfo(dmg)
                
                if skill.onHit then
                    skill.onHit(ply, target, skill)
                end
            end
        end
    else
        local tr = ply:GetEyeTrace()
        if IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity ~= ply then
            if tr.HitPos:Distance(ply:GetPos()) <= range then
                local dmg = DamageInfo()
                dmg:SetDamage(dmgData.amount or 10)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(ply)
                tr.Entity:TakeDamageInfo(dmg)
                
                if skill.onHit then
                    skill.onHit(ply, tr.Entity, skill)
                end
            end
        end
    end
end

-- =============================================
-- ХУКИ
-- =============================================

hook.Add("PlayerInitialSpawn", "LOTM.Skills.Load", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            LOTM.Skills.LoadPlayer(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "LOTM.Skills.Save", function(ply)
    LOTM.Skills.SavePlayer(ply)
end)

-- Команда для выдачи очков скиллов (админ)
concommand.Add("lotm_giveskillpoints", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local target = args[1] and Player(tonumber(args[1])) or ply
    local amount = tonumber(args[2]) or 1
    
    if IsValid(target) then
        LOTM.Skills.AddPoints(target, amount)
        LOTM.Skills.SyncToClient(target)
        LOTM.Skills.SavePlayer(target)
        
        ply:ChatPrint("[LOTM] Выдано " .. amount .. " очков скиллов игроку " .. target:Name())
    end
end)

-- Команда для сброса скиллов (админ)
concommand.Add("lotm_resetskills", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local target = args[1] and Player(tonumber(args[1])) or ply
    
    if IsValid(target) then
        local pid = target:SteamID64() or target:UniqueID()
        local data = LOTM.Skills.PlayerData[pid]
        
        if data then
            -- Возвращаем очки
            local refund = 0
            for skillId, unlocked in pairs(data.unlocked) do
                if unlocked then refund = refund + 1 end
            end
            
            data.unlocked = {}
            data.skillPoints = data.skillPoints + refund
            
            LOTM.Skills.ApplyPassiveBonuses(target)
            LOTM.Skills.SyncToClient(target)
            LOTM.Skills.SavePlayer(target)
            
            ply:ChatPrint("[LOTM] Скиллы сброшены для " .. target:Name() .. ". Возвращено " .. refund .. " очков.")
        end
    end
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Skills Server Manager v3.0 loaded\n")
