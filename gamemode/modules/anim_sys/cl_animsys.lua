AnimationSWEP = {}
AnimationSWEP.GestureAngles = {}

netstream.Hook("dbt/change/sq/anim", function(ad, sq, bq)
    ad:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ad:LookupSequence(sq), 0, bq)
end)

local function OpenAnim(len,ply)
    local ply = net.ReadEntity()
    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
end
net.Receive("rp.OpenAnim", OpenAnim)

net.Receive("OpenBodyMenu",function()
  local data = net.ReadTable()
  CreateInfoFrameF(data.name, data.title, data.time, data.type, data.pos, data.player)
end)

hook.Add("TranslateActivity", "dbt.sq1", function(pl,sq)
  if pl:GetNWBool("HavePlayerArms") and sq == ACT_MP_STAND_IDLE then return 1847 end
  if IsValid(pl) and IsValid(pl:GetActiveWeapon()) and not pl:GetActiveWeapon():GetClass() == "hands" then return end
  if IsValid(pl) and IsValid(pl:GetActiveWeapon()) and pl:GetNWInt("IdleSQ") != "" and not pl:GetNWBool("InMonopad") and sq == ACT_MP_STAND_IDLE and pl:GetActiveWeapon():GetClass() == "hands" and pl:GetActiveWeapon().HandsStatusIs and pl:GetActiveWeapon():HandsStatusIs("hands") then
    return pl:GetNWInt("IdleSQ")
  end
  if IsValid(pl) and ACT_MP_RUN == sq and 2027 == pl:GetNWInt("IdleSQ") then  -- 1683
    return 1624
  end
  if IsValid(pl) and pl:GetNWBool("InMonopad") and not pl:KeyDown(IN_FORWARD) then
    return 1777
  end
end)

local function applyAnimation(ply, targetValue, class)
	if not IsValid(ply) then return end
	if ply.animationSWEPAngle == targetValue then return end
	if ply.animationSWEPAngle ~= targetValue then
		ply.animationSWEPAngle = Lerp(FrameTime() * 5, ply.animationSWEPAngle, targetValue)
	end

   if AnimationSWEP.GestureAngles[class] then
	for boneName, angle in pairs(AnimationSWEP.GestureAngles[class]) do
		local bone = ply:LookupBone(boneName)

		if bone then
			ply:ManipulateBoneAngles( bone, angle * ply.animationSWEPAngle)
		end
	end
  end
end

AnimationSWEP.GestureAngles["monopad"] = {
	  ["ValveBiped.Bip01_R_UpperArm"] = Angle(10,-20),
	  ["ValveBiped.Bip01_R_Hand"] = Angle(0,1,50),
	  ["ValveBiped.Bip01_Head1"] = Angle(0,-30,-20),
	  ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-65,39.8863),
  }

hook.Add("Think", "AnimationSWEP.Think", function ()
	for _, ply in pairs( player.GetHumans() ) do
		local animationClass = ply:GetNWString("animationClass")

		if animationClass ~= "" then
			if not ply.animationSWEPAngle then
				ply.animationSWEPAngle = 0
			end
			if ply:GetNWBool("animationStatus") and ply:GetNWBool("InMonopad") then
				applyAnimation(ply, 1, animationClass)
			else
				applyAnimation(ply, 0, animationClass)
			end
		end


  end
end)
