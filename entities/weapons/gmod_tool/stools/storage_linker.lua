AddCSLuaFile()

TOOL.Category = "DBT Tools"
TOOL.Name = "Хранилище"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar = TOOL.ClientConVar or {}
TOOL.ClientConVar["name"] = "Storage"
TOOL.ClientConVar["slots"] = "16"
TOOL.ClientConVar["weight"] = "0"
TOOL.ClientConVar["distance"] = "85"
TOOL.ClientConVar["spoilslow"] = "0"

local function IsAllowed(ply)
    return IsValid(ply) and ply:IsSuperAdmin()
end

local function SanitizePositiveNumber(value, fallback, minValue)
    local numberValue = tonumber(value) or fallback
    if numberValue and minValue then
        numberValue = math.max(numberValue, minValue)
    end
    return numberValue
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsAllowed(ply) then return false end

    local ent = trace.Entity
    if not IsValid(ent) or ent:IsPlayer() then return false end

    local config = {}
    local rawName = string.Trim(self:GetClientInfo("name") or "")
    if rawName ~= "" then
        config.name = string.sub(rawName, 1, 64)
    end

    config.maxSlots = SanitizePositiveNumber(self:GetClientNumber("slots"), 16, 1)

    local weight = tonumber(self:GetClientInfo("weight")) or 0
    if weight > 0 then
        config.maxWeight = weight
    else
        config.maxWeight = nil
    end

    config.autoCloseDistance = math.max(tonumber(self:GetClientInfo("distance")) or 0, 0)
    config.spoilSlowdown = self:GetClientNumber("spoilslow") >= 1

    config.openOnUse = true

    local storage = dbt.inventory.storage.Attach(ent, config)
    if not storage then
        ply:ChatPrint("[DBT] Не удалось привязать хранилище.")
        return false
    end

    ply:ChatPrint(string.format("[DBT] Хранилище привязано: слотов %d, вес %s.", storage.maxSlots or 0, storage.maxWeight and tostring(storage.maxWeight) or "без лимита"))
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsAllowed(ply) then return false end

    local ent = trace.Entity
    if not IsValid(ent) or not ent.dbtStorageId then
        ply:ChatPrint("[DBT] На объект не привязано хранилище.")
        return false
    end

    dbt.inventory.storage.Detach(ent)
    ply:ChatPrint("[DBT] Хранилище отвязано от объекта.")
    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsAllowed(ply) then return false end

    local ent = trace.Entity
    if not IsValid(ent) or not ent.dbtStorageId then return false end

    if dbt.inventory.storage.Clear(ent) then
        ply:ChatPrint("[DBT] Хранилище очищено.")
        return true
    end

    return false
end

if CLIENT then
    language.Add("tool.storage_linker.name", "Хранилище")
    language.Add("tool.storage_linker.desc", "Привязка хранилища к объекту")
    language.Add("tool.storage_linker.left", "Привязать хранилище")
    language.Add("tool.storage_linker.right", "Отвязать хранилище")
    language.Add("tool.storage_linker.reload", "Очистить содержимое")
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
        Text = "Настройка хранилища",
        Description = "Привязка и настройка вместимости для объекта"
    })

    panel:TextEntry("Название", "storage_linker_name")

    local slotsSlider = vgui.Create("DNumSlider")
    slotsSlider:SetText("Количество слотов")
    slotsSlider:SetMin(1)
    slotsSlider:SetMax(60)
    slotsSlider:SetDecimals(0)
    slotsSlider:SetConVar("storage_linker_slots")
    panel:AddPanel(slotsSlider)

    local weightSlider = vgui.Create("DNumSlider")
    weightSlider:SetText("Максимальный вес")
    weightSlider:SetMin(0)
    weightSlider:SetMax(200)
    weightSlider:SetDecimals(1)
    weightSlider:SetConVar("storage_linker_weight")
    panel:AddPanel(weightSlider)
    panel:Help("Макс. вес \"0\" - вес без ограничений")

    local distanceSlider = vgui.Create("DNumSlider")
    distanceSlider:SetText("Досягаемость")
    distanceSlider:SetMin(0)
    distanceSlider:SetMax(600)
    distanceSlider:SetDecimals(0)
    distanceSlider:SetConVar("storage_linker_distance")
    panel:AddPanel(distanceSlider)
    panel:Help("Досягаемость - на каком расстоянии инвентарь автоматически закрывается. Полезно, если проп очень большой.")

    local spoilCheck = vgui.Create("DCheckBoxLabel")
    spoilCheck:SetText("Уменьшение скорости гниения")
    spoilCheck:SetConVar("storage_linker_spoilslow")
    spoilCheck:SetValue(GetConVar("storage_linker_spoilslow") and GetConVar("storage_linker_spoilslow"):GetBool() and 1 or 0)
    spoilCheck:SetTooltip("Замедляет порчу еды в хранилище примерно вдвое.")
    panel:AddPanel(spoilCheck)

    panel:Help("ЛКМ — привязать / обновить хранилище. ПКМ — отвязать. Перезарядка — очистить содержимое.")
end
