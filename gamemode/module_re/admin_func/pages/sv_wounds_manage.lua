util.AddNetworkString("admin.RemoveWound")
util.AddNetworkString("admin.ClearAllWounds")

net.Receive("admin.RemoveWound", function(len, ply)
    if not ply:IsSuperAdmin() then return end
    
    local target = net.ReadEntity()
    local woundType = net.ReadString()
    local bodyPart = net.ReadString()
    
    if not IsValid(target) or not target:IsPlayer() then return end
    
    if dbt and dbt.removeWound then
        dbt.removeWound(target, woundType, bodyPart)
        
        ply:ChatPrint("Успешно удалено ранение '" .. woundType .. "' с части тела '" .. bodyPart .. "' у игрока " .. target:Nick())
    else
        ply:ChatPrint("Ошибка: Система ранений не найдена")
    end
end)

net.Receive("admin.ClearAllWounds", function(len, ply)
    if not ply:IsSuperAdmin() then return end
    
    local target = net.ReadEntity()
    
    if not IsValid(target) or not target:IsPlayer() then return end
    
    local wounds = target:GetWounds()
    if not wounds then 
        ply:ChatPrint("У игрока " .. target:Nick() .. " нет ранений")
        return 
    end
    
    local woundCount = 0
    
    if dbt and dbt.removeWound then
        for woundType, bodyParts in pairs(wounds) do
            for bodyPart, data in pairs(bodyParts) do
                dbt.removeWound(target, woundType, bodyPart)
                woundCount = woundCount + 1
            end
        end
        
        ply:ChatPrint("Успешно удалено " .. woundCount .. " ранений у игрока " .. target:Nick())
    else
        ply:ChatPrint("Ошибка: Система ранений не найдена")
    end
end)