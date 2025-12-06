util.AddNetworkString("OpenActionMenu")
util.AddNetworkString("PushPlayer")
util.AddNetworkString("SearchPlayer")
util.AddNetworkString("UNSearchPlayer")
util.AddNetworkString("dbt.TakePlayer")
util.AddNetworkString("dbt.OpenMedicationMenu")
util.AddNetworkString("dbt.StartMedicationProcess")

hook.Add("KeyPress","CheckOpenMenu",function(ply,key)
      if ( key == IN_USE && ply:GetEyeTrace().Entity ) then
        local target = ply:GetEyeTrace().Entity
        if not IsValid(target) then return end
        
        if target:IsPlayer() and ply:GetPos():Distance(target:GetPos()) <= 50 then
            net.Start("OpenActionMenu")
              net.WriteEntity(target)
            net.Send(ply)
        end
      end
end)

net.Receive("PushPlayer",function(len,pl)
  local data = net.ReadEntity()

  data:SetVelocity((data:GetPos() - pl:GetPos()) * 7)
  data:EmitSound(PushSound[math.random(1, 4)])
end)

net.Receive("SearchPlayer",function(len,pl)
  local data = net.ReadEntity()
  pl:Freeze(true)
  timer.Create( "freezepl", 5, 1, function() pl:Freeze(false) end )
end)

net.Receive("UNSearchPlayer",function(len,pl)
  local data = net.ReadEntity()

  pl:Freeze(false)
end)

net.Receive("dbt.TakePlayer",function(len,pl)
  local data = net.ReadEntity()

  local matrix = pl:GetBoneMatrix(1)
  local ang = matrix:GetAngles() + Angle(-90,0,90)
  local pos = matrix:GetTranslation() + ang:Right() * 10 + ang:Up() * -5
 
  local button = ents.Create( "prop_vehicle_prisoner_pod" )
  button:SetModel("models/nova/airboat_seat.mdl")
  button:SetPos( pos )
  button:SetAngles( ang )
  button:SetParent(pl,1)
  button:SetNWBool("dbt.Seat")
  button:Spawn()

  button:PhysicsDestroy()

  button:SetMoveType( MOVETYPE_NONE )
  button:SetNotSolid( true )
  button:SetRenderMode( RENDERMODE_TRANSCOLOR )
  button:SetColor( Color( 255, 255, 255, 0 ) )

  data:EnterVehicle(button)

end)

hook.Add("PlayerEnteredVehicle", "dbt.Seats", function(ply,veh)
  if veh:GetNWBool("dbt.Seat") then 
    veh:Remove()
  end
end)

hook.Add( "PlayerUse", "dbt/PlayerUse/table", function( ply, ent )
  if not ply.cd_use then ply.cd_use = CurTime() end
  if "models/drp_props/furniture2.mdl" == ent:GetModel() and ply.cd_use < CurTime() then
    if not ply.sign_count then ply.sign_count = 5 end
    ply.cd_use = CurTime() + 1
    netstream.Start(ply,"dbt/start/write", ent, ent.sign_count or 5)
  end
end )

netstream.Hook("dbt/start/write", function(ply, ent, name, text)
    if not ent.sign_count then ent.sign_count = 5 end
    if ent.sign_count < 0 then return end
    ent.sign_count  = ent.sign_count - 1
    local itemEnt = ents.Create("sign") 
    itemEnt:SetPos(ent:GetPos() + Vector(0, 0, 50))
    itemEnt:SetAngles(Angle(0,0,0))
    itemEnt.text = text and {[1] = text} or {[1] = 'Начало записки.'}
    itemEnt.name = name or 'Название записки'
    itemEnt:SetNWString("Title", name)
    itemEnt:SetNWEntity("Owner", ply)
    itemEnt:Spawn()

end)

netstream.Hook("dbt/edit/sign", function(ply, ent, text)
    ent.text = text
end)


local COOL_TABLE_OF_SIGN_COUNT = {}
hook.Add( "PlayerDisconnected", "Playerleave", function(ply)
    if ply.sign_count then 
      COOL_TABLE_OF_SIGN_COUNT[ply:Name()] = ply.sign_count
    end
end )

hook.Add( "PlayerInitialSpawn", "FullLoadSetup", function( ply )
  if COOL_TABLE_OF_SIGN_COUNT[ply:Name()] then 
    ply.sign_count = COOL_TABLE_OF_SIGN_COUNT[ply:Name()]
  end
end )

netstream.Hook("dbt/finding/started", function(ply, ent)
    ply.FindEntity = ent
    netstream.Start(nil, "dbt/change/sq/anim", ply, "gesture_item_place")
    timer.Create("FindingAnim"..ply:Name(), 2, 2, function()
        netstream.Start(nil, "dbt/change/sq/anim", ply, "gesture_item_place")
    end)
    
    ply:EmitSound('actions/search/search.mp3')
end)


netstream.Hook("dbt/player/stopsound", function(ply)
    ply:StopSound('actions/search/search.mp3')
    timer.Remove("FindingAnim"..ply:Name())
end)

local niger_list = {
  ["hands"] = true,
  ["weapon_physgun"] = true,
  ["gmod_tool"] = true,
}

netstream.Hook("dbt/finding/ended", function(ply, ent, bMulty)

    if ply.FindEntity != ent then return end 

    local StrToSend = ""
    FindWeaponCounter = 0
    local weapons = ent:GetWeapons()
    for k, i in ipairs(weapons) do 
        if not niger_list[i:GetClass()] then 
          StrToSend = StrToSend..i:GetPrintName().."\n"
                FindWeaponCounter = FindWeaponCounter + 1
        end
    end
        if FindWeaponCounter == 0 then StrToSend = "Пусто" end

    if bMulty then 
        for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 150) ) do
          if v:IsPlayer() then
              netstream.Start(v, "dbt/player/text", Color(143, 37, 156), "[ Результаты обыска ] \n", Color(255,255,255), StrToSend)
          end
        end
    else 
       netstream.Start(ply, "dbt/player/text", Color(143, 37, 156), "[ Результаты обыска ] \n", Color(255,255,255), StrToSend)
    end
   
end)




netstream.Hook("dbt/entire", function(ply, ent)
    PrintTable(ply:GetAttachments())
    local obj = ply:LookupAttachment( "aoc_ValveBiped.Bip01_R_Hand" )
    local muzzle = ply:GetAttachment( obj )    

    local a = demit_sit(ent, muzzle.Pos + ply:GetRight() * 20 + ply:GetForward() * -2 + ply:GetUp() * -18, muzzle.Ang + Angle(0,0,135), ply, 26, nil, true)
    a:SetParent(ply, obj)
    ply.ssss = a
    ply:GetActiveWeapon():SetHoldType("duel")
    ply:SetNWBool("HavePlayerArms", true)
end)

function dbt.UseMedicaments(ply, medicineType, bodyPart, effectiveness)
    if not IsValid(ply) or not ply:Alive() then return false end
    
    effectiveness = effectiveness or 1
    bodyPart = bodyPart or "Туловище"
    
    if not dbt or not dbt.removeWound then
        return true
    end
    
    local wounds = nil
    if isfunction(ply.GetWounds) then
        wounds = ply:GetWounds()
    elseif istable(ply.wounds) then
        wounds = ply.wounds
    elseif dbt and dbt.getWounds then
        wounds = dbt.getWounds(ply)
    end
    
    if not wounds or not istable(wounds) then 
        return true
    end
    
    local healMap = {
        ["Бинт"] = {"Лёгкоеранение", "Среднееранение"},
        ["Хирургическийнабор"] = {"Тяжёлоеранение", "Пулевоеранение", "Среднееранение", "Лёгкоеранение"},
        ["Шинадляпереломов"] = {"Перелом"},
        ["Мазь"] = {"Ушиб"},
        ["СлабыйТранквилизатор"] = {},
        ["СильныйТранквилизатор"] = {},
        ["Аптечка"] = {}
    }
    
    local canHeal = healMap[medicineType]
    if not canHeal then return true end
    
    local healed = false
    
    effectiveness = math.Clamp(effectiveness, 0, 1)
    
    if effectiveness >= 0.75 then
        for woundType, _ in pairs(wounds) do
            if table.HasValue(canHeal, woundType) and wounds[woundType][bodyPart] then
                dbt.removeWound(ply, woundType, bodyPart)
                healed = true
                break
            end
        end
    elseif effectiveness >= 0.5 then
        if math.random() <= 0.75 then
            for woundType, _ in pairs(wounds) do
                if table.HasValue(canHeal, woundType) and wounds[woundType][bodyPart] then
                    dbt.removeWound(ply, woundType, bodyPart)
                    healed = true
                    break
                end
            end
        end
    elseif effectiveness >= 0.25 then
        if math.random() <= 0.5 then
            for woundType, _ in pairs(wounds) do
                if table.HasValue(canHeal, woundType) and wounds[woundType][bodyPart] then
                    dbt.removeWound(ply, woundType, bodyPart)
                    healed = true
                    break
                end
            end
        end
    end
    
    return healed or true
end

net.Receive("dbt.StartMedicationProcess", function(len, sender)
    local target = net.ReadEntity()
    local itemId = net.ReadUInt(16)
    local bodyPart = net.ReadString()
    local position = net.ReadUInt(16)
    
    if not IsValid(sender) or not sender:Alive() then return end
    if not IsValid(target) or not target:Alive() then return end
    
    local distance = sender:GetPos():Distance(target:GetPos())
    if distance > 150 then
        netstream.Start(sender, 'dbt/NewNotification', 3, {
            icon = 'materials/dbt/notifications/notifications_main.png', 
            title = 'Уведомление', 
            titlecolor = Color(222, 193, 49), 
            notiftext = 'Цель слишком далеко!'
        })
        return
    end
    
    if not sender.items or not sender.items[position] then
        netstream.Start(sender, 'dbt/NewNotification', 3, {
            icon = 'materials/dbt/notifications/notifications_main.png', 
            title = 'Ошибка', 
            titlecolor = Color(215, 63, 65), 
            notiftext = 'Предмет не найден!'
        })
        return
    end
    
    local item = sender.items[position]
    if item.id ~= itemId then
        netstream.Start(sender, 'dbt/NewNotification', 3, {
            icon = 'materials/dbt/notifications/notifications_main.png', 
            title = 'Ошибка', 
            titlecolor = Color(215, 63, 65), 
            notiftext = 'Несоответствие предмета!'
        })
        return
    end
    
    local itemData = dbt.inventory.items[itemId]
    if not itemData or not itemData.medicine then
        netstream.Start(sender, 'dbt/NewNotification', 3, {
            icon = 'materials/dbt/notifications/notifications_main.png', 
            title = 'Ошибка', 
            titlecolor = Color(215, 63, 65), 
            notiftext = 'Это не медикамент!'
        })
        return
    end
    
    sender:Freeze(true)
    sender.dbt_MedicationTarget = target
    sender.dbt_MedicationData = {
        itemId = itemId,
        bodyPart = bodyPart,
        position = position,
        itemData = itemData,
        item = item
    }
    
    netstream.Start(nil, "dbt/change/sq/anim", sender, "gesture_item_place")
    
    timer.Create("MedicationAnim_" .. sender:SteamID(), 2, 2, function()
        if IsValid(sender) and sender.dbt_MedicationTarget then
            netstream.Start(nil, "dbt/change/sq/anim", sender, "gesture_item_place")
        end
    end)
    
    sender:EmitSound('actions/search/search.mp3')
    
    timer.Create("dbt_MedicationProcess_" .. sender:SteamID(), 5, 1, function()
        if not IsValid(sender) or not sender.dbt_MedicationTarget then return end
        
        local currentTarget = sender.dbt_MedicationTarget
        local medData = sender.dbt_MedicationData
        
        sender:Freeze(false)
        sender:StopSound('actions/search/search.mp3')
        timer.Remove("MedicationAnim_" .. sender:SteamID())
        
        if not IsValid(currentTarget) or not currentTarget:Alive() then
            netstream.Start(sender, 'dbt/NewNotification', 3, {
                icon = 'materials/dbt/notifications/notifications_main.png', 
                title = 'Ошибка', 
                titlecolor = Color(215, 63, 65), 
                notiftext = 'Цель недоступна!'
            })
            sender.dbt_MedicationTarget = nil
            sender.dbt_MedicationData = nil
            return
        end
        
        local dist = sender:GetPos():Distance(currentTarget:GetPos())
        if dist > 150 then
            netstream.Start(sender, 'dbt/NewNotification', 3, {
                icon = 'materials/dbt/notifications/notifications_main.png', 
                title = 'Ошибка', 
                titlecolor = Color(215, 63, 65), 
                notiftext = 'Цель слишком далеко!'
            })
            sender.dbt_MedicationTarget = nil
            sender.dbt_MedicationData = nil
            return
        end
        
        dbt.inventory.removeitem(sender, medData.position)
        
        local effectiveness = math.Rand(0.5, 1.0)
        
        if effectiveness <= 0 then
            netstream.Start(sender, 'dbt/NewNotification', 3, {
                icon = 'materials/dbt/notifications/notifications_main.png', 
                title = 'Лечение', 
                titlecolor = Color(215, 63, 65), 
                notiftext = 'Процедура провалена! Медикамент потрачен.'
            })
            sender.dbt_MedicationTarget = nil
            sender.dbt_MedicationData = nil
            return
        end
        
        local success = false
        if medData.itemData.OnUse then
            medData.itemData.OnUse(currentTarget, medData.itemData, medData.item.meta or {}, {position = medData.position, bodyPart = medData.bodyPart, effectiveness = effectiveness})
            success = true
        elseif medData.itemData.medicine then
            success = dbt.UseMedicaments(currentTarget, medData.itemData.medicine, medData.bodyPart, effectiveness)
        end
        
        local resultMessage = ""
        local resultColor = Color(82, 204, 117)
        
        if success then
            if effectiveness >= 0.75 then
                resultMessage = medData.itemData.name .. ' применён отлично! (100%)'
                resultColor = Color(82, 204, 117)
            elseif effectiveness >= 0.5 then
                resultMessage = medData.itemData.name .. ' применён хорошо (75%)'
                resultColor = Color(222, 193, 49)
            else
                resultMessage = medData.itemData.name .. ' применён удовлетворительно (50%)'
                resultColor = Color(222, 193, 49)
            end
        else
            resultMessage = medData.itemData.name .. ' не помог! Повторите процедуру.'
            resultColor = Color(234, 30, 33)
        end
        
        netstream.Start(sender, 'dbt/NewNotification', 3, {
            icon = 'materials/icons/medical_chest.png', 
            title = 'Лечение', 
            titlecolor = resultColor, 
            notiftext = resultMessage
        })
        
        if currentTarget ~= sender then
            netstream.Start(currentTarget, 'dbt/NewNotification', 3, {
                icon = 'materials/icons/medical_chest.png', 
                title = 'Лечение', 
                titlecolor = resultColor, 
                notiftext = sender:Nick() .. ' применил: ' .. resultMessage
            })
        end
        
        if dbt and dbt.health and dbt.health.update then
            netstream.Start(currentTarget, "dbt.health.update")
        end
        
        if openobserve and openobserve.Log then
            openobserve.Log({
                event = "medication_use",
                name = sender:Nick(),
                steamid = sender:SteamID(),
                item = medData.itemData.name,
                target = currentTarget:Nick(),
                body_part = medData.bodyPart,
                effectiveness = effectiveness,
                success = success
            })
        end
        
        sender.dbt_MedicationTarget = nil
        sender.dbt_MedicationData = nil
    end)
end)

hook.Add("PlayerButtonDown", "dbt.MedicationMenuKey", function(ply, button)
    if button == KEY_M and ply:Alive() and not ply.isSpectating then
        net.Start("dbt.OpenMedicationMenu")
            net.WriteEntity(ply)
        net.Send(ply)
    end
end)

hook.Add("PlayerDisconnected", "dbt.CleanupMedication", function(ply)
    timer.Remove("dbt_MedicationProcess_" .. ply:SteamID())
    timer.Remove("MedicationAnim_" .. ply:SteamID())
end)

hook.Add("PlayerDeath", "dbt.CancelMedicationOnDeath", function(victim, inflictor, attacker)
    if victim.dbt_MedicationTarget then
        victim:StopSound('actions/search/search.mp3')
        timer.Remove("dbt_MedicationProcess_" .. victim:SteamID())
        timer.Remove("MedicationAnim_" .. victim:SteamID())
        victim.dbt_MedicationTarget = nil
        victim.dbt_MedicationData = nil
    end
end)