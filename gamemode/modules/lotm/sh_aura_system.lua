-- LOTM Aura System v2.0
-- Система аур с интеграцией wound системы

LOTM = LOTM or {}
LOTM.Auras = LOTM.Auras or {}
LOTM.Auras.Active = LOTM.Auras.Active or {}
LOTM.Auras.Registry = LOTM.Auras.Registry or {}

-- =============================================
-- РЕГИСТРАЦИЯ АУРЫ
-- =============================================

function LOTM.Auras.Register(data)
    if not data.id then
        ErrorNoHalt("[LOTM Auras] Ошибка: отсутствует id\n")
        return false
    end
    
    local aura = {
        id = data.id,
        name = data.name or "Неизвестная аура",
        description = data.description or "",
        icon = data.icon or "vgui/notices/generic",
        
        radius = data.radius or 300,
        tickRate = data.tickRate or 1,
        duration = data.duration or 0,
        
        affectSelf = data.affectSelf ~= false,
        affectAllies = data.affectAllies ~= false,
        affectEnemies = data.affectEnemies or false,
        
        effects = data.effects or {},
        enemyEffects = data.enemyEffects or {},
        
        -- Лечение ран
        healWounds = data.healWounds or false,
        woundTypes = data.woundTypes or {},
        
        visuals = data.visuals or {},
        
        onTick = data.onTick,
        onStart = data.onStart,
        onEnd = data.onEnd,
    }
    
    LOTM.Auras.Registry[aura.id] = aura
    
    return true
end

function LOTM.Auras.Get(auraId)
    return LOTM.Auras.Registry[auraId]
end

-- =============================================
-- УПРАВЛЕНИЕ АУРАМИ
-- =============================================

local function GetPlayerID(ply)
    return ply:SteamID64() or ply:UniqueID()
end

function LOTM.Auras.Activate(ply, auraId, customDuration)
    if not IsValid(ply) then return false end
    
    local aura = LOTM.Auras.Get(auraId)
    if not aura then return false, "Аура не найдена" end
    
    local pid = GetPlayerID(ply)
    if not LOTM.Auras.Active[pid] then
        LOTM.Auras.Active[pid] = {}
    end
    
    local duration = customDuration or aura.duration
    local endTime = duration > 0 and (CurTime() + duration) or 0
    
    LOTM.Auras.Active[pid][auraId] = {
        endTime = endTime,
        lastTick = 0,
        owner = ply,
    }
    
    if aura.onStart and SERVER then
        aura.onStart(ply, aura)
    end
    
    if SERVER then
        ply:SetNWString("LOTM_ActiveAura", auraId)
    end
    
    return true
end

function LOTM.Auras.Deactivate(ply, auraId)
    if not IsValid(ply) then return false end
    
    local pid = GetPlayerID(ply)
    if not LOTM.Auras.Active[pid] then return false end
    if not LOTM.Auras.Active[pid][auraId] then return false end
    
    local aura = LOTM.Auras.Get(auraId)
    
    if aura and aura.onEnd and SERVER then
        aura.onEnd(ply, aura)
    end
    
    LOTM.Auras.Active[pid][auraId] = nil
    
    if SERVER then
        ply:SetNWString("LOTM_ActiveAura", "")
    end
    
    return true
end

function LOTM.Auras.IsActive(ply, auraId)
    if not IsValid(ply) then return false end
    
    local pid = GetPlayerID(ply)
    if not LOTM.Auras.Active[pid] then return false end
    
    local auraData = LOTM.Auras.Active[pid][auraId]
    if not auraData then return false end
    
    if auraData.endTime > 0 and CurTime() > auraData.endTime then
        LOTM.Auras.Deactivate(ply, auraId)
        return false
    end
    
    return true
end

function LOTM.Auras.GetActive(ply)
    if not IsValid(ply) then return {} end
    
    local pid = GetPlayerID(ply)
    return LOTM.Auras.Active[pid] or {}
end

-- =============================================
-- ОБРАБОТКА АУР (SERVER)
-- =============================================

if SERVER then
    timer.Create("LOTM.Auras.ProcessTick", 0.5, 0, function()
        local curTime = CurTime()
        
        for pid, auras in pairs(LOTM.Auras.Active) do
            for auraId, auraData in pairs(auras) do
                local aura = LOTM.Auras.Get(auraId)
                if not aura then continue end
                
                local owner = auraData.owner
                if not IsValid(owner) then
                    auras[auraId] = nil
                    continue
                end
                
                -- Проверяем истечение
                if auraData.endTime > 0 and curTime > auraData.endTime then
                    LOTM.Auras.Deactivate(owner, auraId)
                    continue
                end
                
                -- Проверяем tickRate
                if curTime - auraData.lastTick < aura.tickRate then
                    continue
                end
                
                auraData.lastTick = curTime
                
                -- Находим цели в радиусе
                local ownerPos = owner:GetPos()
                local targets = ents.FindInSphere(ownerPos, aura.radius)
                
                for _, target in ipairs(targets) do
                    if not IsValid(target) or not target:IsPlayer() then continue end
                    if not target:Alive() then continue end
                    
                    local isOwner = (target == owner)
                    local isAlly = false -- TODO: система фракций
                    local isEnemy = not isOwner and not isAlly
                    
                    local shouldAffect = false
                    local effectsToApply = {}
                    
                    if isOwner and aura.affectSelf then
                        shouldAffect = true
                        effectsToApply = aura.effects
                    elseif isAlly and aura.affectAllies then
                        shouldAffect = true
                        effectsToApply = aura.effects
                    elseif isEnemy and aura.affectEnemies then
                        shouldAffect = true
                        effectsToApply = aura.enemyEffects
                    end
                    
                    if shouldAffect then
                        -- Лечение ран в ауре
                        if aura.healWounds and aura.woundTypes and dbt and dbt.hasWound and dbt.removeWound then
                            for _, woundType in ipairs(aura.woundTypes) do
                                if dbt.hasWound(target, woundType) then
                                    for _, position in pairs(dbt.woundsposition or {}) do
                                        if dbt.hasWoundOnpos and dbt.hasWoundOnpos(target, woundType, position) then
                                            dbt.removeWound(target, woundType, position)
                                            target:ChatPrint("[LOTM] Аура исцелила: " .. woundType)
                                            break
                                        end
                                    end
                                    break -- Лечим по одной ране за тик
                                end
                            end
                        end
                        
                        -- Кастомный callback
                        if aura.onTick then
                            aura.onTick(owner, target, aura)
                        end
                    end
                end
            end
        end
    end)
end

-- =============================================
-- КЛИЕНТСКАЯ ВИЗУАЛИЗАЦИЯ
-- =============================================

if CLIENT then
    hook.Add("PostDrawOpaqueRenderables", "LOTM.Auras.Render", function()
        for _, ply in ipairs(player.GetAll()) do
            local auraId = ply:GetNWString("LOTM_ActiveAura", "")
            if auraId == "" then continue end
            
            local aura = LOTM.Auras.Get(auraId)
            if not aura then continue end
            
            local pos = ply:GetPos() + Vector(0, 0, 5)
            local radius = aura.radius
            local color = aura.visuals.color or Color(100, 200, 255, 40)
            
            -- Пульсация
            local pulse = math.sin(CurTime() * 2) * 0.2 + 0.8
            local drawColor = Color(color.r, color.g, color.b, color.a * pulse)
            
            -- Рисуем круг ауры на земле
            render.SetColorMaterial()
            
            local segments = 48
            local angleStep = (math.pi * 2) / segments
            
            for i = 0, segments - 1 do
                local angle1 = i * angleStep
                local angle2 = (i + 1) * angleStep
                
                local x1 = pos.x + math.cos(angle1) * radius
                local y1 = pos.y + math.sin(angle1) * radius
                local x2 = pos.x + math.cos(angle2) * radius
                local y2 = pos.y + math.sin(angle2) * radius
                
                render.DrawLine(
                    Vector(x1, y1, pos.z),
                    Vector(x2, y2, pos.z),
                    drawColor
                )
            end
            
            -- Внутренний круг
            local innerRadius = radius * 0.3
            for i = 0, segments - 1 do
                local angle1 = i * angleStep + CurTime() * 0.5
                local angle2 = (i + 1) * angleStep + CurTime() * 0.5
                
                local x1 = pos.x + math.cos(angle1) * innerRadius
                local y1 = pos.y + math.sin(angle1) * innerRadius
                local x2 = pos.x + math.cos(angle2) * innerRadius
                local y2 = pos.y + math.sin(angle2) * innerRadius
                
                render.DrawLine(
                    Vector(x1, y1, pos.z + 10),
                    Vector(x2, y2, pos.z + 10),
                    Color(drawColor.r, drawColor.g, drawColor.b, drawColor.a * 0.5)
                )
            end
        end
    end)
end

-- =============================================
-- РЕГИСТРАЦИЯ АУР
-- =============================================

hook.Add("InitPostEntity", "LOTM.Auras.RegisterDefaults", function()
    
    -- Аура регенерации (лечит раны!)
    LOTM.Auras.Register({
        id = "aura_regeneration",
        name = "Аура Регенерации",
        description = "Исцеляет союзников в радиусе и лечит раны",
        icon = "lotm/auras/regeneration.png",
        
        radius = 250,
        tickRate = 2,
        duration = 30,
        
        affectSelf = true,
        affectAllies = true,
        affectEnemies = false,
        
        -- Лечение ран
        healWounds = true,
        woundTypes = {"Ушиб", "Ранение"},
        
        visuals = {
            color = Color(100, 255, 100, 40),
        },
        
        onTick = function(owner, target, aura)
            if target:Health() < target:GetMaxHealth() then
                target:SetHealth(math.min(target:Health() + 3, target:GetMaxHealth()))
            end
        end,
    })
    
    -- Аура страха
    LOTM.Auras.Register({
        id = "aura_fear",
        name = "Аура Страха",
        description = "Ослабляет и замедляет врагов в радиусе",
        icon = "lotm/auras/fear.png",
        
        radius = 300,
        tickRate = 1.5,
        duration = 20,
        
        affectSelf = false,
        affectAllies = false,
        affectEnemies = true,
        
        visuals = {
            color = Color(100, 0, 100, 50),
        },
        
        onTick = function(owner, target, aura)
            -- Замедление
            local currentSpeed = target:GetWalkSpeed()
            if currentSpeed > 100 then
                target:SetWalkSpeed(currentSpeed * 0.9)
            end
        end,
        
        onEnd = function(owner, aura)
            -- Восстанавливаем скорость всех затронутых
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(owner:GetPos()) < aura.radius then
                    ply:SetWalkSpeed(150) -- Дефолт
                end
            end
        end,
    })
    
    -- Аура ярости
    LOTM.Auras.Register({
        id = "aura_rage",
        name = "Аура Ярости",
        description = "Увеличивает урон союзников",
        icon = "lotm/auras/rage.png",
        
        radius = 200,
        tickRate = 3,
        duration = 15,
        
        affectSelf = true,
        affectAllies = true,
        affectEnemies = false,
        
        visuals = {
            color = Color(255, 100, 50, 40),
        },
        
        onTick = function(owner, target, aura)
            target:SetNWBool("LOTM_Empowered", true)
        end,
        
        onEnd = function(owner, aura)
            for _, ply in ipairs(player.GetAll()) do
                ply:SetNWBool("LOTM_Empowered", false)
            end
        end,
    })
    
    -- Аура защиты
    LOTM.Auras.Register({
        id = "aura_protection",
        name = "Аура Защиты",
        description = "Защищает союзников в радиусе",
        icon = "lotm/auras/protection.png",
        
        radius = 200,
        tickRate = 5,
        duration = 25,
        
        affectSelf = true,
        affectAllies = true,
        affectEnemies = false,
        
        visuals = {
            color = Color(100, 150, 255, 40),
        },
        
        onTick = function(owner, target, aura)
            target:SetNWBool("LOTM_Protected", true)
        end,
        
        onEnd = function(owner, aura)
            for _, ply in ipairs(player.GetAll()) do
                ply:SetNWBool("LOTM_Protected", false)
            end
        end,
    })
    
    -- Аура тьмы (Путь Тьмы) - лечит тяжёлые раны!
    LOTM.Auras.Register({
        id = "aura_darkness",
        name = "Аура Тьмы",
        description = "Окутывает область тьмой, лечит союзников и ослабляет врагов",
        icon = "lotm/auras/darkness.png",
        
        radius = 350,
        tickRate = 2,
        duration = 20,
        
        affectSelf = true,
        affectAllies = true,
        affectEnemies = true,
        
        -- Лечит даже тяжёлые раны
        healWounds = true,
        woundTypes = {"Ушиб", "Ранение", "Тяжелое ранение"},
        
        visuals = {
            color = Color(50, 0, 100, 60),
        },
        
        onStart = function(owner, aura)
            owner:EmitSound("ambient/atmosphere/ambience_base.wav")
        end,
        
        onTick = function(owner, target, aura)
            if target == owner or target:GetPos():Distance(owner:GetPos()) < 150 then
                -- Союзники - усиление
                target:SetNWBool("LOTM_DarkBlessing", true)
            else
                -- Враги - ослабление
                target:SetNWBool("LOTM_DarkCurse", true)
            end
        end,
        
        onEnd = function(owner, aura)
            for _, ply in ipairs(player.GetAll()) do
                ply:SetNWBool("LOTM_DarkBlessing", false)
                ply:SetNWBool("LOTM_DarkCurse", false)
            end
        end,
    })
    
    MsgC(Color(100, 255, 100), "[LOTM Auras] ", Color(255, 255, 255), 
         "Ауры зарегистрированы: " .. table.Count(LOTM.Auras.Registry) .. "\n")
end)

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Aura system v2.0 loaded\n")
