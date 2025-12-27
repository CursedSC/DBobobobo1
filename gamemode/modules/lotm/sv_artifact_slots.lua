-- LOTM Artifact Slots - Server
-- Серверная логика экипировки артефактов

if not SERVER then return end

LOTM = LOTM or {}
LOTM.EquippedArtifacts = LOTM.EquippedArtifacts or {}

-- =============================================
-- NETWORK STRINGS
-- =============================================
util.AddNetworkString("LOTM.Artifacts.Equip")
util.AddNetworkString("LOTM.Artifacts.Unequip")
util.AddNetworkString("LOTM.Artifacts.Sync")

-- =============================================
-- ФУНКЦИИ
-- =============================================

function LOTM.GetEquipped(ply)
    if not IsValid(ply) then return {} end
    LOTM.EquippedArtifacts[ply] = LOTM.EquippedArtifacts[ply] or {}
    return LOTM.EquippedArtifacts[ply]
end

function LOTM.EquipArtifact(ply, slotId, invSlot)
    if not IsValid(ply) then return false end
    if not ply.items or not ply.items[invSlot] then return false end
    
    local item = ply.items[invSlot]
    local itemData = dbt.inventory.items[item.id]
    
    if not itemData or not itemData.lotmArtifact then
        return false, "Это не артефакт"
    end
    
    local artifactId = itemData.artifactId
    local artifactData = LOTM.Artifacts and LOTM.Artifacts.Registry and LOTM.Artifacts.Registry[artifactId]
    
    if not artifactData then
        return false, "Неизвестный артефакт"
    end
    
    -- Проверяем совместимость со слотом
    -- (можно добавить проверку slotType)
    
    -- Снимаем старый артефакт если есть
    local equipped = LOTM.GetEquipped(ply)
    if equipped[slotId] then
        LOTM.UnequipArtifact(ply, slotId)
    end
    
    -- Удаляем из инвентаря
    if dbt.inventory.removeitem then
        dbt.inventory.removeitem(ply, invSlot)
    end
    
    -- Экипируем
    equipped[slotId] = {
        id = artifactId,
        name = artifactData.name,
        data = artifactData,
        meta = item.meta,
    }
    
    -- Применяем бонусы
    if artifactData.buffs then
        for stat, value in pairs(artifactData.buffs) do
            local current = ply:GetNWInt("LOTM_ArtifactBuff_" .. stat, 0)
            ply:SetNWInt("LOTM_ArtifactBuff_" .. stat, current + value)
        end
    end
    
    -- Синхронизируем
    LOTM.SyncEquipped(ply)
    
    ply:ChatPrint("[Артефакты] Экипировано: " .. artifactData.name)
    
    return true
end

function LOTM.UnequipArtifact(ply, slotId)
    if not IsValid(ply) then return false end
    
    local equipped = LOTM.GetEquipped(ply)
    local artifact = equipped[slotId]
    
    if not artifact then return false end
    
    -- Снимаем бонусы
    if artifact.data and artifact.data.buffs then
        for stat, value in pairs(artifact.data.buffs) do
            local current = ply:GetNWInt("LOTM_ArtifactBuff_" .. stat, 0)
            ply:SetNWInt("LOTM_ArtifactBuff_" .. stat, current - value)
        end
    end
    
    -- Возвращаем в инвентарь
    if dbt.inventory.additem then
        -- Находим ID предмета
        for itemId, itemData in pairs(dbt.inventory.items) do
            if itemData.lotmArtifact and itemData.artifactId == artifact.id then
                dbt.inventory.additem(ply, itemId, artifact.meta or {})
                break
            end
        end
    end
    
    equipped[slotId] = nil
    
    LOTM.SyncEquipped(ply)
    
    ply:ChatPrint("[Артефакты] Снято: " .. artifact.name)
    
    return true
end

function LOTM.SyncEquipped(ply)
    if not IsValid(ply) then return end
    
    local equipped = LOTM.GetEquipped(ply)
    
    -- Упрощаем для отправки
    local data = {}
    for slotId, artifact in pairs(equipped) do
        data[slotId] = {
            id = artifact.id,
            name = artifact.name,
        }
    end
    
    net.Start("LOTM.Artifacts.Sync")
    net.WriteTable(data)
    net.Send(ply)
end

-- =============================================
-- СЕТЕВЫЕ ОБРАБОТЧИКИ
-- =============================================

net.Receive("LOTM.Artifacts.Equip", function(len, ply)
    local slotId = net.ReadString()
    local invSlot = net.ReadUInt(16)
    
    LOTM.EquipArtifact(ply, slotId, invSlot)
end)

net.Receive("LOTM.Artifacts.Unequip", function(len, ply)
    local slotId = net.ReadString()
    
    LOTM.UnequipArtifact(ply, slotId)
end)

-- Синхронизация при спавне
hook.Add("PlayerSpawn", "LOTM.Artifacts.OnSpawn", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            LOTM.SyncEquipped(ply)
        end
    end)
end)

-- Очистка при дисконнекте
hook.Add("PlayerDisconnected", "LOTM.Artifacts.OnDisconnect", function(ply)
    LOTM.EquippedArtifacts[ply] = nil
end)

print("[LOTM] Artifact Slots (Server) loaded")

