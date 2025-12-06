util.AddNetworkString("dbt.InspectParalyzedPlayer")
util.AddNetworkString("dbt.ShowParalyzedInfo")

local BodyPartsRu = {
    ["Голова"] = "Голову",
    ["Туловище"] = "Туловище",
    ["ЛеваяРука"] = "Левую руку",
    ["ПраваяРука"] = "Правую руку",
    ["ЛеваяНога"] = "Левую ногу",
    ["ПраваяНога"] = "Правую ногу"
}

function GetTimeRemainingText(endTime)
    local remaining = math.max(0, endTime - CurTime())
    local minutes = math.floor(remaining / 60)
    local seconds = math.floor(remaining % 60)
    
    if minutes > 0 then
        return string.format("%d мин %02d сек", minutes, seconds)
    else
        return string.format("%d сек", seconds)
    end
end

function GetParalyzedPlayerInfo(target)
    if not IsValid(target) or not target:IsPlayer() then return nil end
    
    local hasWound = dbt.hasWound(target, "Парализован")
    if not hasWound then return nil end
    
    local injectionData = target.dbt_InjectionData
    if not injectionData then return nil end
    
    local endTime = injectionData.time + injectionData.duration
    local bodyPartRu = BodyPartsRu[injectionData.bodyPart] or "неизвестную область"
    
    return {
        name = target:Nick(),
        isParalyzed = true,
        drug = injectionData.drug,
        drugType = injectionData.type,
        bodyPart = bodyPartRu,
        timeRemaining = GetTimeRemainingText(endTime),
        status = "Парализован"
    }
end

hook.Add("PlayerUse", "dbt.InspectParalyzedPlayer", function(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    
    if ent:IsPlayer() then
        local distance = ply:GetPos():Distance(ent:GetPos())
        if distance > 150 then return end
        
        local info = GetParalyzedPlayerInfo(ent)
        if info then
            ply:ChatPrint("═══════════════════════════════════")
            ply:ChatPrint("Осмотр парализованного игрока")
            ply:ChatPrint("═══════════════════════════════════")
            ply:ChatPrint("Имя: " .. info.name)
            ply:ChatPrint("Статус: " .. info.status)
            ply:ChatPrint("Препарат: " .. info.drug)
            ply:ChatPrint("Часть тела: " .. info.bodyPart)
            ply:ChatPrint("Осталось времени: " .. info.timeRemaining)
            ply:ChatPrint("═══════════════════════════════════")
            return true
        end
    end
end)