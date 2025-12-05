util.AddNetworkString("OpenActionMenu")
util.AddNetworkString("PushPlayer")
util.AddNetworkString("SearchPlayer")
util.AddNetworkString("UNSearchPlayer")
util.AddNetworkString("dbt.TakePlayer")


hook.Add("KeyPress","CheckOpenMenu",function(ply,key)
      if ( key == IN_USE && ply:GetEyeTrace().Entity && ply:GetEyeTrace().Entity:IsPlayer() ) then
        if ply:GetPos():Distance(ply:GetEyeTrace().Entity:GetPos()) <= 50 then 
              net.Start("OpenActionMenu")
                net.WriteEntity(ply:GetEyeTrace().Entity)
              net.Send(ply)
        end
      end
end)

net.Receive("PushPlayer",function(len,pl)
  local data = net.ReadEntity()

  data:SetVelocity((data:GetPos() - pl:GetPos()) * 7)
  data:EmitSound(PushSound[math.random(1, 4)])--
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

-- Времено перенесено к дверям
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
--gesture_item_place
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

    local a = demit_sit(ent, muzzle.Pos + ply:GetRight() * 20 + ply:GetForward() * -2 + ply:GetUp() * -18, muzzle.Ang + Angle(0,0,135), ply, 26, nil, true)  --- muzzle.Ang:Up() * 20 - muzzle.Ang:Right() * 20 - muzzle.Ang:Forward() * 5
    a:SetParent(ply, obj)
    ply.ssss = a
    --timer.Simple(1, function() ply.ssss:SetPos(ply.ssss:GetPos() + ply:GetUp() * 35) end)
    ply:GetActiveWeapon():SetHoldType("duel")
    ply:SetNWBool("HavePlayerArms", true)
end)

