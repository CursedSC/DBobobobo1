-- LOTM Effect Templates System
-- Система шаблонов эффектов для способностей
-- Позволяет добавлять эффекты одной строкой

LOTM = LOTM or {}
LOTM.Effects = LOTM.Effects or {}
LOTM.Effects.Templates = LOTM.Effects.Templates or {}
LOTM.Effects.ActiveEffects = LOTM.Effects.ActiveEffects or {}

-- =============================================
-- Типы эффектов
-- =============================================
LOTM.Effects.Types = {
    BUFF = "buff",           -- Положительный эффект
    DEBUFF = "debuff",       -- Отрицательный эффект
    AURA = "aura",           -- Аура вокруг игрока
    DOT = "dot",             -- Урон со временем
    HOT = "hot",             -- Лечение со временем
    TRANSFORM = "transform", -- Трансформация
    SHIELD = "shield",       -- Щит
    STEALTH = "stealth",     -- Невидимость
    STUN = "stun",           -- Оглушение
    SLOW = "slow",           -- Замедление
    HASTE = "haste",         -- Ускорение
    EMPOWER = "empower",     -- Усиление урона
    WEAKEN = "weaken",       -- Ослабление
}

-- =============================================
-- Базовые шаблоны эффектов
-- =============================================

-- Регистрация шаблона эффекта
function LOTM.Effects.RegisterTemplate(templateId, templateData)
    if not templateId then
        ErrorNoHalt("[LOTM Effects] Ошибка: отсутствует templateId\n")
        return false
    end
    
    templateData.id = templateId
    templateData.name = templateData.name or "Неизвестный эффект"
    templateData.description = templateData.description or ""
    templateData.duration = templateData.duration or 5
    templateData.type = templateData.type or LOTM.Effects.Types.BUFF
    templateData.icon = templateData.icon or "lotm/effects/default.png"
    templateData.stackable = templateData.stackable or false
    templateData.maxStacks = templateData.maxStacks or 1
    templateData.tickRate = templateData.tickRate or 1 -- Как часто тикает эффект
    
    LOTM.Effects.Templates[templateId] = templateData
    
    MsgC(Color(100, 200, 255), "[LOTM Effects] ", Color(255, 255, 255), 
         "Шаблон зарегистрирован: " .. templateData.name .. "\n")
    
    return true
end

-- Получить шаблон
function LOTM.Effects.GetTemplate(templateId)
    return LOTM.Effects.Templates[templateId]
end

-- =============================================
-- Применение эффектов
-- =============================================

-- Применить эффект к игроку
function LOTM.Effects.Apply(ply, templateId, params)
    if not IsValid(ply) then return false end
    
    local template = LOTM.Effects.GetTemplate(templateId)
    if not template then
        ErrorNoHalt("[LOTM Effects] Шаблон не найден: " .. tostring(templateId) .. "\n")
        return false
    end
    
    params = params or {}
    local duration = params.duration or template.duration
    local stacks = params.stacks or 1
    local source = params.source or nil
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    if not LOTM.Effects.ActiveEffects[pid] then
        LOTM.Effects.ActiveEffects[pid] = {}
    end
    
    local existingEffect = LOTM.Effects.ActiveEffects[pid][templateId]
    
    if existingEffect then
        if template.stackable then
            existingEffect.stacks = math.min(existingEffect.stacks + stacks, template.maxStacks)
            existingEffect.endTime = CurTime() + duration
        else
            -- Обновляем время
            existingEffect.endTime = CurTime() + duration
        end
    else
        -- Создаём новый эффект
        local effectData = {
            id = templateId,
            template = template,
            startTime = CurTime(),
            endTime = CurTime() + duration,
            stacks = stacks,
            source = source,
            lastTick = CurTime(),
            params = params,
        }
        
        LOTM.Effects.ActiveEffects[pid][templateId] = effectData
        
        -- Вызываем onApply
        if template.onApply then
            template.onApply(ply, effectData)
        end
    end
    
    -- Синхронизация с клиентом
    if SERVER then
        LOTM.Effects.SyncToClient(ply, templateId, LOTM.Effects.ActiveEffects[pid][templateId])
    end
    
    return true
end

-- Удалить эффект
function LOTM.Effects.Remove(ply, templateId)
    if not IsValid(ply) then return false end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    if not LOTM.Effects.ActiveEffects[pid] then return false end
    if not LOTM.Effects.ActiveEffects[pid][templateId] then return false end
    
    local effectData = LOTM.Effects.ActiveEffects[pid][templateId]
    local template = effectData.template
    
    -- Вызываем onRemove
    if template and template.onRemove then
        template.onRemove(ply, effectData)
    end
    
    LOTM.Effects.ActiveEffects[pid][templateId] = nil
    
    -- Синхронизация с клиентом
    if SERVER then
        LOTM.Effects.SyncRemoveToClient(ply, templateId)
    end
    
    return true
end

-- Проверить наличие эффекта
function LOTM.Effects.Has(ply, templateId)
    if not IsValid(ply) then return false end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    if not LOTM.Effects.ActiveEffects[pid] then return false end
    
    local effect = LOTM.Effects.ActiveEffects[pid][templateId]
    if not effect then return false end
    
    return effect.endTime > CurTime()
end

-- Получить данные эффекта
function LOTM.Effects.Get(ply, templateId)
    if not IsValid(ply) then return nil end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    if not LOTM.Effects.ActiveEffects[pid] then return nil end
    
    return LOTM.Effects.ActiveEffects[pid][templateId]
end

-- Получить все активные эффекты игрока
function LOTM.Effects.GetAll(ply)
    if not IsValid(ply) then return {} end
    
    local pid = ply:SteamID64() or ply:UniqueID()
    
    return LOTM.Effects.ActiveEffects[pid] or {}
end

-- =============================================
-- Обработка эффектов
-- =============================================

-- Тик эффектов
hook.Add("Think", "LOTM.Effects.Tick", function()
    local curTime = CurTime()
    
    for pid, effects in pairs(LOTM.Effects.ActiveEffects) do
        local ply = nil
        
        -- Находим игрока по ID
        for _, p in ipairs(player.GetAll()) do
            if (p:SteamID64() or p:UniqueID()) == pid then
                ply = p
                break
            end
        end
        
        if not IsValid(ply) then
            LOTM.Effects.ActiveEffects[pid] = nil
            continue
        end
        
        for templateId, effectData in pairs(effects) do
            -- Проверяем истечение
            if curTime > effectData.endTime then
                LOTM.Effects.Remove(ply, templateId)
                continue
            end
            
            -- Тик эффекта
            local template = effectData.template
            if template and template.onTick then
                local tickRate = template.tickRate or 1
                if curTime - effectData.lastTick >= tickRate then
                    template.onTick(ply, effectData)
                    effectData.lastTick = curTime
                end
            end
        end
    end
end)

-- =============================================
-- Сетевое взаимодействие
-- =============================================

if SERVER then
    util.AddNetworkString("LOTM.Effects.Sync")
    util.AddNetworkString("LOTM.Effects.Remove")
    util.AddNetworkString("LOTM.Effects.SyncAll")
    
    function LOTM.Effects.SyncToClient(ply, templateId, effectData)
        net.Start("LOTM.Effects.Sync")
        net.WriteString(templateId)
        net.WriteFloat(effectData.endTime - CurTime())
        net.WriteUInt(effectData.stacks, 8)
        net.Send(ply)
    end
    
    function LOTM.Effects.SyncRemoveToClient(ply, templateId)
        net.Start("LOTM.Effects.Remove")
        net.WriteString(templateId)
        net.Send(ply)
    end
end

if CLIENT then
    net.Receive("LOTM.Effects.Sync", function()
        local templateId = net.ReadString()
        local duration = net.ReadFloat()
        local stacks = net.ReadUInt(8)
        
        local template = LOTM.Effects.GetTemplate(templateId)
        if not template then return end
        
        local pid = LocalPlayer():SteamID64() or LocalPlayer():UniqueID()
        
        if not LOTM.Effects.ActiveEffects[pid] then
            LOTM.Effects.ActiveEffects[pid] = {}
        end
        
        LOTM.Effects.ActiveEffects[pid][templateId] = {
            id = templateId,
            template = template,
            startTime = CurTime(),
            endTime = CurTime() + duration,
            stacks = stacks,
            lastTick = CurTime(),
        }
    end)
    
    net.Receive("LOTM.Effects.Remove", function()
        local templateId = net.ReadString()
        local pid = LocalPlayer():SteamID64() or LocalPlayer():UniqueID()
        
        if LOTM.Effects.ActiveEffects[pid] then
            LOTM.Effects.ActiveEffects[pid][templateId] = nil
        end
    end)
end

-- =============================================
-- Быстрое применение эффектов (одной строкой)
-- =============================================

-- Применить эффект одной строкой
-- Пример: LOTM.Effects.Quick(ply, "burning", 5, {damage = 10})
function LOTM.Effects.Quick(ply, templateId, duration, params)
    params = params or {}
    params.duration = duration
    return LOTM.Effects.Apply(ply, templateId, params)
end

-- =============================================
-- Предустановленные шаблоны эффектов
-- =============================================

-- Горение
LOTM.Effects.RegisterTemplate("burning", {
    name = "Горение",
    description = "Получает урон от огня каждую секунду",
    type = LOTM.Effects.Types.DOT,
    duration = 5,
    icon = "lotm/effects/burning.png",
    tickRate = 1,
    
    onApply = function(ply, data)
        if SERVER then
            ply:Ignite(data.template.duration)
        end
    end,
    
    onTick = function(ply, data)
        if SERVER then
            local damage = data.params.damage or 5
            ply:TakeDamage(damage * data.stacks, data.source, data.source)
        end
    end,
    
    onRemove = function(ply, data)
        if SERVER then
            ply:Extinguish()
        end
    end,
})

-- Замедление
LOTM.Effects.RegisterTemplate("slowed", {
    name = "Замедление",
    description = "Скорость передвижения снижена",
    type = LOTM.Effects.Types.SLOW,
    duration = 3,
    icon = "lotm/effects/slowed.png",
    
    onApply = function(ply, data)
        if SERVER then
            local slowPercent = data.params.percent or 0.5
            ply.LOTMOriginalSpeed = ply:GetWalkSpeed()
            ply.LOTMOriginalRunSpeed = ply:GetRunSpeed()
            ply:SetWalkSpeed(ply.LOTMOriginalSpeed * slowPercent)
            ply:SetRunSpeed(ply.LOTMOriginalRunSpeed * slowPercent)
        end
    end,
    
    onRemove = function(ply, data)
        if SERVER and ply.LOTMOriginalSpeed then
            ply:SetWalkSpeed(ply.LOTMOriginalSpeed)
            ply:SetRunSpeed(ply.LOTMOriginalRunSpeed)
            ply.LOTMOriginalSpeed = nil
            ply.LOTMOriginalRunSpeed = nil
        end
    end,
})

-- Ускорение
LOTM.Effects.RegisterTemplate("haste", {
    name = "Ускорение",
    description = "Скорость передвижения увеличена",
    type = LOTM.Effects.Types.HASTE,
    duration = 5,
    icon = "lotm/effects/haste.png",
    
    onApply = function(ply, data)
        if SERVER then
            local hastePercent = data.params.percent or 1.5
            ply.LOTMOriginalSpeed = ply.LOTMOriginalSpeed or ply:GetWalkSpeed()
            ply.LOTMOriginalRunSpeed = ply.LOTMOriginalRunSpeed or ply:GetRunSpeed()
            ply:SetWalkSpeed(ply.LOTMOriginalSpeed * hastePercent)
            ply:SetRunSpeed(ply.LOTMOriginalRunSpeed * hastePercent)
        end
    end,
    
    onRemove = function(ply, data)
        if SERVER and ply.LOTMOriginalSpeed then
            ply:SetWalkSpeed(ply.LOTMOriginalSpeed)
            ply:SetRunSpeed(ply.LOTMOriginalRunSpeed)
            ply.LOTMOriginalSpeed = nil
            ply.LOTMOriginalRunSpeed = nil
        end
    end,
})

-- Усиление урона
LOTM.Effects.RegisterTemplate("empowered", {
    name = "Усиление",
    description = "Урон увеличен",
    type = LOTM.Effects.Types.EMPOWER,
    duration = 10,
    icon = "lotm/effects/empowered.png",
    stackable = true,
    maxStacks = 5,
})

-- Ослабление
LOTM.Effects.RegisterTemplate("weakened", {
    name = "Ослабление",
    description = "Урон снижен",
    type = LOTM.Effects.Types.WEAKEN,
    duration = 8,
    icon = "lotm/effects/weakened.png",
})

-- Щит
LOTM.Effects.RegisterTemplate("shielded", {
    name = "Щит",
    description = "Поглощает входящий урон",
    type = LOTM.Effects.Types.SHIELD,
    duration = 10,
    icon = "lotm/effects/shield.png",
    
    onApply = function(ply, data)
        if SERVER then
            data.shieldAmount = data.params.amount or 50
            ply:SetNWInt("LOTM_Shield", data.shieldAmount)
        end
    end,
    
    onRemove = function(ply, data)
        if SERVER then
            ply:SetNWInt("LOTM_Shield", 0)
        end
    end,
})

-- Регенерация
LOTM.Effects.RegisterTemplate("regeneration", {
    name = "Регенерация",
    description = "Восстанавливает здоровье со временем",
    type = LOTM.Effects.Types.HOT,
    duration = 10,
    icon = "lotm/effects/regeneration.png",
    tickRate = 1,
    
    onTick = function(ply, data)
        if SERVER then
            local heal = data.params.heal or 5
            ply:SetHealth(math.min(ply:Health() + heal * data.stacks, ply:GetMaxHealth()))
        end
    end,
})

-- Отравление
LOTM.Effects.RegisterTemplate("poisoned", {
    name = "Отравление",
    description = "Получает урон от яда",
    type = LOTM.Effects.Types.DOT,
    duration = 8,
    icon = "lotm/effects/poisoned.png",
    tickRate = 2,
    stackable = true,
    maxStacks = 3,
    
    onTick = function(ply, data)
        if SERVER then
            local damage = (data.params.damage or 3) * data.stacks
            ply:TakeDamage(damage, data.source, data.source)
        end
    end,
})

-- Оглушение
LOTM.Effects.RegisterTemplate("stunned", {
    name = "Оглушение",
    description = "Не может двигаться или атаковать",
    type = LOTM.Effects.Types.STUN,
    duration = 2,
    icon = "lotm/effects/stunned.png",
    
    onApply = function(ply, data)
        if SERVER then
            ply:Freeze(true)
        end
    end,
    
    onRemove = function(ply, data)
        if SERVER then
            ply:Freeze(false)
        end
    end,
})

-- Невидимость
LOTM.Effects.RegisterTemplate("invisible", {
    name = "Невидимость",
    description = "Невидим для врагов",
    type = LOTM.Effects.Types.STEALTH,
    duration = 15,
    icon = "lotm/effects/invisible.png",
    
    onApply = function(ply, data)
        if SERVER then
            ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
            ply:SetColor(Color(255, 255, 255, 30))
        end
    end,
    
    onRemove = function(ply, data)
        if SERVER then
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply:SetColor(color_white)
        end
    end,
})

-- Духовное усиление
LOTM.Effects.RegisterTemplate("spiritual_power", {
    name = "Духовная Сила",
    description = "Усиливает духовные способности",
    type = LOTM.Effects.Types.BUFF,
    duration = 20,
    icon = "lotm/effects/spiritual_power.png",
    stackable = true,
    maxStacks = 3,
})

-- Защита от стихий
LOTM.Effects.RegisterTemplate("elemental_protection", {
    name = "Стихийная Защита",
    description = "Снижает получаемый стихийный урон",
    type = LOTM.Effects.Types.BUFF,
    duration = 30,
    icon = "lotm/effects/elemental_protection.png",
})

print("[LOTM] Effect Templates system loaded")

