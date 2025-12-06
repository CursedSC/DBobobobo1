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
        local info = GetParalyzedPlayerInfo(ent)
        if info then
            net.Start("dbt.ShowParalyzedInfo")
                net.WriteString(info.name)
                net.WriteBool(info.isParalyzed)
                net.WriteString(info.drug)
                net.WriteString(info.drugType)
                net.WriteString(info.bodyPart)
                net.WriteString(info.timeRemaining)
                net.WriteString(info.status)
            net.Send(ply)
            return true
        end
    end
end)

net.Receive("dbt.InspectParalyzedPlayer", function(len, ply)
    local target = net.ReadEntity()
    
    if not IsValid(ply) or not IsValid(target) then return end
    
    local distance = ply:GetPos():Distance(target:GetPos())
    if distance > 150 then
        netstream.Start(ply, 'dbt/NewNotification', 3, {
            icon = 'materials/dbt/notifications/notifications_main.png', 
            title = 'Уведомление', 
            titlecolor = Color(222, 193, 49), 
            notiftext = 'Цель слишком далеко!'
        })
        return
    end
    
    local info = GetParalyzedPlayerInfo(target)
    if info then
        net.Start("dbt.ShowParalyzedInfo")
            net.WriteString(info.name)
            net.WriteBool(info.isParalyzed)
            net.WriteString(info.drug)
            net.WriteString(info.drugType)
            net.WriteString(info.bodyPart)
            net.WriteString(info.timeRemaining)
            net.WriteString(info.status)
        net.Send(ply)
    else
        netstream.Start(ply, 'dbt/NewNotification', 3, {
            icon = 'materials/dbt/notifications/notifications_main.png', 
            title = 'Осмотр', 
            titlecolor = Color(82, 204, 117), 
            notiftext = 'Игрок ' .. target:Nick() .. ' не парализован.'
        })
    end
end)