-- LOTM Artifact Equipment Slots System
-- Система слотов для экипировки артефактов разных типов

LOTM = LOTM or {}
LOTM.ArtifactSlots = LOTM.ArtifactSlots or {}

-- Типы слотов для артефактов
LOTM.ArtifactSlots.Types = {
    HEAD = "head",           -- Головной убор, маска
    NECK = "neck",           -- Амулет, ожерелье
    RING_LEFT = "ring_left", -- Кольцо левой руки
    RING_RIGHT = "ring_right", -- Кольцо правой руки
    WEAPON = "weapon",       -- Оружейный артефакт
    ARMOR = "armor",         -- Броня, одежда
    ACCESSORY = "accessory", -- Аксессуар
}

-- Названия слотов
LOTM.ArtifactSlots.Names = {
    [LOTM.ArtifactSlots.Types.HEAD] = "Голова",
    [LOTM.ArtifactSlots.Types.NECK] = "Шея",
    [LOTM.ArtifactSlots.Types.RING_LEFT] = "Левое кольцо",
    [LOTM.ArtifactSlots.Types.RING_RIGHT] = "Правое кольцо",
    [LOTM.ArtifactSlots.Types.WEAPON] = "Оружие",
    [LOTM.ArtifactSlots.Types.ARMOR] = "Броня",
    [LOTM.ArtifactSlots.Types.ACCESSORY] = "Аксессуар",
}

-- Иконки слотов
LOTM.ArtifactSlots.Icons = {
    [LOTM.ArtifactSlots.Types.HEAD] = "lotm/slots/head.png",
    [LOTM.ArtifactSlots.Types.NECK] = "lotm/slots/neck.png",
    [LOTM.ArtifactSlots.Types.RING_LEFT] = "lotm/slots/ring.png",
    [LOTM.ArtifactSlots.Types.RING_RIGHT] = "lotm/slots/ring.png",
    [LOTM.ArtifactSlots.Types.WEAPON] = "lotm/slots/weapon.png",
    [LOTM.ArtifactSlots.Types.ARMOR] = "lotm/slots/armor.png",
    [LOTM.ArtifactSlots.Types.ACCESSORY] = "lotm/slots/accessory.png",
}

-- Экипированные артефакты по слотам
-- Структура: EquippedSlots[SteamID][slotType] = artifactId
LOTM.ArtifactSlots.EquippedSlots = LOTM.ArtifactSlots.EquippedSlots or {}

-- =============================================
-- Управление слотами
-- =============================================

local function GetPlayerID(ply)
    return ply:SteamID64() or ply:UniqueID()
end

-- Получить все слоты игрока
function LOTM.ArtifactSlots.GetPlayerSlots(ply)
    local pid = GetPlayerID(ply)
    if not LOTM.ArtifactSlots.EquippedSlots[pid] then
        LOTM.ArtifactSlots.EquippedSlots[pid] = {}
    end
    return LOTM.ArtifactSlots.EquippedSlots[pid]
end

-- Получить артефакт в слоте
function LOTM.ArtifactSlots.GetSlot(ply, slotType)
    local slots = LOTM.ArtifactSlots.GetPlayerSlots(ply)
    local artifactId = slots[slotType]
    
    if artifactId then
        return LOTM.Artifacts.Get(artifactId)
    end
    
    return nil
end

-- Проверить совместимость артефакта со слотом
function LOTM.ArtifactSlots.CanEquipInSlot(artifactId, slotType)
    local artifact = LOTM.Artifacts.Get(artifactId)
    if not artifact then return false end
    
    -- Если у артефакта указан конкретный слот
    if artifact.slotType then
        return artifact.slotType == slotType
    end
    
    -- Автоопределение по типу артефакта
    local slotMapping = {
        ["ring"] = {LOTM.ArtifactSlots.Types.RING_LEFT, LOTM.ArtifactSlots.Types.RING_RIGHT},
        ["amulet"] = {LOTM.ArtifactSlots.Types.NECK},
        ["mask"] = {LOTM.ArtifactSlots.Types.HEAD},
        ["weapon"] = {LOTM.ArtifactSlots.Types.WEAPON},
        ["armor"] = {LOTM.ArtifactSlots.Types.ARMOR},
        ["accessory"] = {LOTM.ArtifactSlots.Types.ACCESSORY},
    }
    
    local artifactType = artifact.artifactType or "accessory"
    local allowedSlots = slotMapping[artifactType] or {LOTM.ArtifactSlots.Types.ACCESSORY}
    
    for _, allowedSlot in ipairs(allowedSlots) do
        if allowedSlot == slotType then
            return true
        end
    end
    
    return false
end

-- Экипировать артефакт в слот
function LOTM.ArtifactSlots.Equip(ply, artifactId, slotType)
    if not IsValid(ply) then return false, "Игрок не найден" end
    
    local artifact = LOTM.Artifacts.Get(artifactId)
    if not artifact then return false, "Артефакт не найден" end
    
    -- Проверка совместимости
    if not LOTM.ArtifactSlots.CanEquipInSlot(artifactId, slotType) then
        return false, "Артефакт не подходит для этого слота"
    end
    
    -- Проверка требований
    if LOTM.Artifacts.MeetsRequirements then
        local meetsReqs, reason = LOTM.Artifacts.MeetsRequirements(ply, artifactId)
        if not meetsReqs then
            return false, reason
        end
    end
    
    local pid = GetPlayerID(ply)
    local slots = LOTM.ArtifactSlots.GetPlayerSlots(ply)
    
    -- Снимаем старый артефакт из слота
    local oldArtifactId = slots[slotType]
    if oldArtifactId then
        LOTM.ArtifactSlots.Unequip(ply, slotType)
    end
    
    -- Экипируем новый
    slots[slotType] = artifactId
    
    if SERVER then
        -- Применяем эффекты
        LOTM.ArtifactSlots.ApplyArtifactEffects(ply, artifact)
        
        -- Анимация экипировки
        if artifact.equipAnimation then
            ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, artifact.equipAnimation)
        end
        
        -- Звук
        if artifact.equipSound then
            ply:EmitSound(artifact.equipSound)
        else
            ply:EmitSound("items/ammopickup.wav")
        end
        
        -- Callback
        if artifact.onEquip then
            artifact.onEquip(ply, artifact)
        end
        
        -- Синхронизация
        LOTM.ArtifactSlots.SyncToClient(ply)
        
        -- Сохранение в БД
        LOTM.ArtifactSlots.SaveToDatabase(ply)
    end
    
    return true
end

-- Снять артефакт из слота
function LOTM.ArtifactSlots.Unequip(ply, slotType)
    if not IsValid(ply) then return false end
    
    local pid = GetPlayerID(ply)
    local slots = LOTM.ArtifactSlots.GetPlayerSlots(ply)
    
    local artifactId = slots[slotType]
    if not artifactId then return false end
    
    local artifact = LOTM.Artifacts.Get(artifactId)
    
    if SERVER and artifact then
        -- Убираем эффекты
        LOTM.ArtifactSlots.RemoveArtifactEffects(ply, artifact)
        
        -- Callback
        if artifact.onUnequip then
            artifact.onUnequip(ply, artifact)
        end
        
        ply:EmitSound("items/ammo_pickup.wav")
    end
    
    slots[slotType] = nil
    
    if SERVER then
        LOTM.ArtifactSlots.SyncToClient(ply)
        LOTM.ArtifactSlots.SaveToDatabase(ply)
    end
    
    return true
end

-- Получить все экипированные артефакты
function LOTM.ArtifactSlots.GetAllEquipped(ply)
    local slots = LOTM.ArtifactSlots.GetPlayerSlots(ply)
    local equipped = {}
    
    for slotType, artifactId in pairs(slots) do
        local artifact = LOTM.Artifacts.Get(artifactId)
        if artifact then
            equipped[slotType] = artifact
        end
    end
    
    return equipped
end

-- =============================================
-- Применение эффектов артефактов
-- =============================================

function LOTM.ArtifactSlots.ApplyArtifactEffects(ply, artifact)
    if not SERVER then return end
    
    -- Баффы
    if artifact.buffs then
        for stat, value in pairs(artifact.buffs) do
            LOTM.Artifacts.ApplyBuff(ply, stat, value)
        end
    end
    
    -- Дебаффы
    if artifact.debuffs then
        for stat, value in pairs(artifact.debuffs) do
            LOTM.Artifacts.ApplyDebuff(ply, stat, value)
        end
    end
end

function LOTM.ArtifactSlots.RemoveArtifactEffects(ply, artifact)
    if not SERVER then return end
    
    -- Убираем баффы
    if artifact.buffs then
        for stat, value in pairs(artifact.buffs) do
            LOTM.Artifacts.RemoveBuff(ply, stat, value)
        end
    end
    
    -- Убираем дебаффы
    if artifact.debuffs then
        for stat, value in pairs(artifact.debuffs) do
            LOTM.Artifacts.RemoveDebuff(ply, stat, value)
        end
    end
end

-- =============================================
-- База данных
-- =============================================

function LOTM.ArtifactSlots.InitDatabase()
    if not SERVER then return end
    
    sql.Query([[
        CREATE TABLE IF NOT EXISTS lotm_artifact_slots (
            steamid TEXT PRIMARY KEY,
            slots TEXT
        )
    ]])
end

function LOTM.ArtifactSlots.SaveToDatabase(ply)
    if not SERVER then return end
    if not IsValid(ply) then return end
    
    local pid = ply:SteamID64()
    local slots = LOTM.ArtifactSlots.EquippedSlots[pid] or {}
    local jsonData = util.TableToJSON(slots)
    
    sql.Query(string.format(
        "INSERT OR REPLACE INTO lotm_artifact_slots (steamid, slots) VALUES (%s, %s)",
        sql.SQLStr(pid),
        sql.SQLStr(jsonData)
    ))
end

function LOTM.ArtifactSlots.LoadFromDatabase(ply)
    if not SERVER then return end
    if not IsValid(ply) then return end
    
    local pid = ply:SteamID64()
    
    local result = sql.Query(string.format(
        "SELECT slots FROM lotm_artifact_slots WHERE steamid = %s",
        sql.SQLStr(pid)
    ))
    
    if result and result[1] then
        local slots = util.JSONToTable(result[1].slots)
        if slots then
            LOTM.ArtifactSlots.EquippedSlots[pid] = slots
            
            -- Применяем эффекты загруженных артефактов
            for slotType, artifactId in pairs(slots) do
                local artifact = LOTM.Artifacts.Get(artifactId)
                if artifact then
                    LOTM.ArtifactSlots.ApplyArtifactEffects(ply, artifact)
                end
            end
        end
    end
end

-- =============================================
-- Сетевое взаимодействие
-- =============================================

if SERVER then
    util.AddNetworkString("LOTM.ArtifactSlots.Sync")
    util.AddNetworkString("LOTM.ArtifactSlots.Equip")
    util.AddNetworkString("LOTM.ArtifactSlots.Unequip")
    
    LOTM.ArtifactSlots.InitDatabase()
    
    function LOTM.ArtifactSlots.SyncToClient(ply)
        local slots = LOTM.ArtifactSlots.GetPlayerSlots(ply)
        
        net.Start("LOTM.ArtifactSlots.Sync")
        net.WriteTable(slots)
        net.Send(ply)
    end
    
    net.Receive("LOTM.ArtifactSlots.Equip", function(len, ply)
        local artifactId = net.ReadString()
        local slotType = net.ReadString()
        
        LOTM.ArtifactSlots.Equip(ply, artifactId, slotType)
    end)
    
    net.Receive("LOTM.ArtifactSlots.Unequip", function(len, ply)
        local slotType = net.ReadString()
        
        LOTM.ArtifactSlots.Unequip(ply, slotType)
    end)
    
    hook.Add("PlayerInitialSpawn", "LOTM.ArtifactSlots.Load", function(ply)
        timer.Simple(2, function()
            if IsValid(ply) then
                LOTM.ArtifactSlots.LoadFromDatabase(ply)
                LOTM.ArtifactSlots.SyncToClient(ply)
            end
        end)
    end)
    
    hook.Add("PlayerDisconnected", "LOTM.ArtifactSlots.Save", function(ply)
        LOTM.ArtifactSlots.SaveToDatabase(ply)
    end)
end

if CLIENT then
    net.Receive("LOTM.ArtifactSlots.Sync", function()
        local slots = net.ReadTable()
        local pid = GetPlayerID(LocalPlayer())
        LOTM.ArtifactSlots.EquippedSlots[pid] = slots
    end)
    
    function LOTM.ArtifactSlots.RequestEquip(artifactId, slotType)
        net.Start("LOTM.ArtifactSlots.Equip")
        net.WriteString(artifactId)
        net.WriteString(slotType)
        net.SendToServer()
    end
    
    function LOTM.ArtifactSlots.RequestUnequip(slotType)
        net.Start("LOTM.ArtifactSlots.Unequip")
        net.WriteString(slotType)
        net.SendToServer()
    end
end

MsgC(Color(100, 255, 100), "[LOTM] ", Color(255, 255, 255), "Artifact slots system loaded\n")

