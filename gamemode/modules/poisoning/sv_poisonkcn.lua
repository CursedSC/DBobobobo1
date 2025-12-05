AddCSLuaFile()

local KCN = {InitialDelay = 5, HealthLockTick = 1, DamageTick = 1, DamageFraction = 0.20}

local function KCN_TName(ply, suffix) return string.format("kcn_%s_%s", ply:SteamID64() or ply:UserID(), suffix) end
local function KCN_ClearTimers(ply) if not IsValid(ply) then return end for _, suf in ipairs({"init","lock","dmg"}) do timer.Remove(KCN_TName(ply, suf)) end end
local function KCN_Reset(ply) if not IsValid(ply) then return end KCN_ClearTimers(ply) ply:SetNWBool("PoisonedKCN", false) ply:SetNWBool("PoisonedMethanolUseFood", false) end
function PoisonKCNIsActive(ply) return ply:GetNWBool("PoisonedKCN") end
function PoisonKCNCure(ply) if not PoisonKCNIsActive(ply) then return false end hook.Run("PoisonKCNCured", ply) KCN_Reset(ply) return true end
local function KCN_StartEffects(ply)
	if not IsValid(ply) or not PoisonKCNIsActive(ply) then return end
	ply.lasthp = ply:Health()
	timer.Create(KCN_TName(ply, "lock"), KCN.HealthLockTick, 0, function()
		if not IsValid(ply) or not ply:Alive() or not PoisonKCNIsActive(ply) then timer.Remove(KCN_TName(ply, "lock")) return end
		local lasthp = ply.lasthp or ply:Health()
		if ply:Health() > lasthp then ply:SetHealth(lasthp) else ply.lasthp = ply:Health() end
	end)
	timer.Create(KCN_TName(ply, "dmg"), KCN.DamageTick, 0, function()
		if not IsValid(ply) or not ply:Alive() or not PoisonKCNIsActive(ply) then timer.Remove(KCN_TName(ply, "dmg")) return end
		local dmg = math.max(1, math.floor(ply:GetMaxHealth() * KCN.DamageFraction))
		ply:SetHealth(math.max(0, ply:Health() - dmg))
		ply:SetNWBool("KilledByPoison", true)
		if ply:Health() <= 0 then
			timer.Remove(KCN_TName(ply, "dmg"))
			if ply:Alive() then ply:Kill() end
		end
	end)
end
function PoisonKCNActivate(ply, poisonedby)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if PoisonKCNIsActive(ply) then return false end
	if ply:GetNWBool("PoisonedMethanol") and PoisonMethanolCure then PoisonMethanolCure(ply) end
	ply:SetNWBool("PoisonedMethanolUseFood", true)
	hook.Run("PoisonKCNActivate", ply, poisonedby)
	timer.Create(KCN_TName(ply, "init"), KCN.InitialDelay, 1, function()
		if not IsValid(ply) then return end
		ply:SetNWBool("PoisonedKCN", true)
		KCN_StartEffects(ply)
	end)
	return true
end
hook.Add("PlayerDeath", "KCN_ResetOnDeath", function(ply) if PoisonKCNIsActive(ply) then KCN_Reset(ply) end end)
hook.Add("PlayerDisconnected", "KCN_ClearOnLeave", function(ply) KCN_ClearTimers(ply) end)
hook.Add("PoisonKCNActivate", "PoisonKCN_DefaultNotify", function(ply) if not IsValid(ply) then return end netstream.Start(ply, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_heart.png', title = 'Плохое самочувствие', titlecolor = Color(215, 63, 66), notiftext = 'Вы чувствуете себя ужасно от употребленного.'}) end)
