--local plyent
local TargetOrigin
local CustomAngles			= nil
local PlayerLockAngles		= nil
local PlayerVecAngle		= Angle(0,0,0)
local PlayerCamVec 			= Vector(0,0,0)
local PlyHoldingCamKey		= false
local PlyAttackLerp			= 0
local CameraDistance 		= 60

local CameraCanScroll 				= true
local CameraSmoothFirstPerson		= false
local CameraTargetEnemies			= true
local CameraStopWhenEnemy			= true

EmoteCamera = false
hook.Add( "CalcView", "dbt/Camera/Emote", function( ply, pos, ang )
	if not EmoteCamera or not IsLobby() then return end
	plyent = ply
	if ply and ply:IsValid() and ply:Alive() and ply:GetViewEntity() == ply then
		local wep = ply:GetActiveWeapon()
		if wep and wep:IsValid() then
			if CustomAngles then
				TargetOrigin = pos - (CustomAngles:Forward() * CameraDistance) + (CustomAngles:Up() * ((CameraDistance-120)/8))

				if ply:KeyDown(IN_ATTACK2)  then
					PlayerCamVec = LerpVector(FrameTime()*10, PlayerCamVec, CustomAngles:Right() * 25)
				else
					PlayerCamVec = LerpVector(FrameTime()*10, PlayerCamVec, Vector(0,0,0))
				end

				TargetOrigin = TargetOrigin + PlayerCamVec

				local tr = util.TraceHull( { start = pos, endpos = TargetOrigin, mask = MASK_SOLID_BRUSHONLY, filter = player.GetAll(), mins = Vector( -8, -8, -8 ), maxs = Vector( 8, 8, 8 ) } )

				TargetOrigin = tr.HitPos + tr.HitNormal

				if CameraSmoothFirstPerson then
					return {
						angles = CustomAngles,
						drawviewer = false
					}
				end
				
				return {
					origin = TargetOrigin,
					angles = CustomAngles,
					drawviewer = true
				}
			end
		end
	end
end )

hook.Add( "CreateMove", "dbt/CreateMove/Emote", function( cmd )
		if not EmoteCamera or not IsLobby()  then return end
		local ply = plyent
		if ply and ply:IsValid() and ply:Alive() and ply:GetViewEntity() == ply then
		local wep = ply:GetActiveWeapon()
		if !wep or !wep:IsValid() then CustomAngles = ply:EyeAngles() PlayerLockAngles = ply:EyeAngles() return end

		if ( !ply:Alive() ) then on = false end

		if ( PlayerLockAngles == nil ) then
			CustomAngles = ply:EyeAngles() 
			PlayerLockAngles = CustomAngles * 1
		end

		if CameraCanScroll and cmd:KeyDown(IN_WALK) then
			CameraDistance	= math.Clamp(CameraDistance - cmd:GetMouseWheel() * 2, 40, 180)
		end
		
		CustomAngles.pitch	= math.Clamp(CustomAngles.pitch	+ cmd:GetMouseY() * 0.02, -90, 90)
		CustomAngles.yaw	= CustomAngles.yaw - cmd:GetMouseX() * 0.02

		local inkeys = { IN_ATTACK2, IN_USE } 

		local function CorrectCamera(custang, abs, lerp)
			local cang = (custang or Angle(0,0,0))
			local lerpval = lerp or 10
			local ang
			if abs then
				ang = cang
				if lerp then
					PlayerVecAngle = LerpAngle(FrameTime()*lerpval, PlayerVecAngle, ang)
				else
					PlayerVecAngle = ang
				end
			else
				ang = cang + CustomAngles
				PlayerVecAngle = LerpAngle(FrameTime()*lerpval, PlayerVecAngle, ang)
			end

			PlayerVecAngle.roll = 0
			cmd:SetViewAngles( PlayerVecAngle )
			PlayerLockAngles = PlayerVecAngle * 1
		end

		PlyHoldingCamKey = false
		for _, key in pairs(inkeys) do
			if cmd:KeyDown(key) or cmd:KeyDown(IN_ATTACK2) then
				PlyHoldingCamKey = true
				CorrectCamera()
			end
		end

		if cmd:KeyDown(IN_ATTACK) and !cmd:KeyDown(IN_ATTACK2) and wep:GetNextPrimaryFire() < CurTime() then
			PlyAttackLerp = 6
		else
			PlyAttackLerp = Lerp(FrameTime(), PlyAttackLerp, 0) 
		end

		if cmd:KeyDown(IN_ATTACK2) and PlyAttackLerp > 0 then
			PlyAttackLerp = 0
		end


		if cmd:KeyDown(IN_SPEED) and cmd:KeyDown(IN_ATTACK2) then
			ply:SetVelocity(Vector(0,0,5500))
		end
		 
		if CameraSmoothFirstPerson then
			CorrectCamera()
			return
		end

		if ply:GetMoveType() == MOVETYPE_WALK then
			if !PlyHoldingCamKey then
				if cmd:GetForwardMove() ~= 0 or cmd:GetSideMove() ~= 0 then
					CorrectCamera(Vector(cmd:GetForwardMove()/10000, cmd:GetSideMove()/-10000):Angle())
					cmd:SetSideMove(0)
					cmd:SetForwardMove(10000)
				else
					PlayerLockAngles.pitch = CustomAngles.pitch
					cmd:SetViewAngles( PlayerLockAngles )
				end
			end
		else
			CorrectCamera()
		end

		return true
	end
end)