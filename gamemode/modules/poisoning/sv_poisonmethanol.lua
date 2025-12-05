AddCSLuaFile()

local POISON_METHANOL = {
	InitialDelay = 5,
	LastStageDelay = 180,
	TickInterval = 1.5,
	WaterDrain = 20,
	HungerDrain = 10,
	HealthLockTick = 1,
	DeathStageWarmup = 5,
	DeathTick = 1,
	DeathFraction = 0.20,
}

local function TName(ply, suffix)
	return string.format("methanol_%s_%s", ply:SteamID64() or ply:UserID(), suffix)
end

local function ClearTimers(ply)
	if not IsValid(ply) then return end
	for _, suf in ipairs({"init","laststage","tick","healthlock","death"}) do
		timer.Remove(TName(ply, suf))
	end
end

local function ResetMethanolState(ply)
	if not IsValid(ply) then return end
	ClearTimers(ply)
	ply:SetNWBool("PoisonedMethanol", false)
	ply:SetNWBool("PoisonedMethanolUseFood", false)
	ply:SetNWBool("PoisonedMethanolLastEffect", false)
	ply:SetNWBool("KilledByPoison", false)
	ply:Freeze(false)
end

function PoisonMethanolIsActive(ply)
	return ply:GetNWBool("PoisonedMethanol")
end

function PoisonMethanolCure(ply)
	if not PoisonMethanolIsActive(ply) then return false end
	hook.Run("PoisonMethanolCured", ply)
	ResetMethanolState(ply)
	return true
end

local function StartFirstEffects(ply)
	if not IsValid(ply) or not PoisonMethanolIsActive(ply) then return end
	if ply:GetNWBool("PoisonedKCN") then return end

	ply:SetNWBool("PoisonedMethanolUseFood", true)
	ply.lasthp = ply:Health()

	timer.Create(TName(ply, "healthlock"), POISON_METHANOL.HealthLockTick, 0, function()
		if not IsValid(ply) or not ply:Alive() or not PoisonMethanolIsActive(ply) then
			timer.Remove(TName(ply, "healthlock"))
			return
		end
		local lasthp = ply.lasthp or ply:Health()
		if ply:Health() > lasthp then
			ply:SetHealth(lasthp)
		else
			ply.lasthp = ply:Health()
		end
	end)

	timer.Create(TName(ply, "tick"), POISON_METHANOL.TickInterval, 0, function()
		if not IsValid(ply) or not ply:Alive() or not PoisonMethanolIsActive(ply) then
			timer.Remove(TName(ply, "tick"))
			return
		end
		local water = ply:GetNWInt("water")
		local hunger = ply:GetNWInt("hunger")
		if water > 0 then
			ply:SetNWInt("water", math.max(0, water - POISON_METHANOL.WaterDrain))
		end
		if hunger > 0 then
			ply:SetNWInt("hunger", math.max(0, hunger - POISON_METHANOL.HungerDrain))
		end
	end)

	netstream.Start(ply, 'dbt/NewNotification', 3, {
		icon = 'materials/dbt/notifications/notifications_heart.png',
		title = 'Плохое самочувствие',
		titlecolor = Color(215, 63, 66),
		notiftext = 'Вы чувствуете себя ужасно от употребленного.'
	})
	hook.Run("PoisonMethanolFirstEffects", ply)
end

local function StartLastStage(ply)
	if not IsValid(ply) or not PoisonMethanolIsActive(ply) then return end
	ply:SetNWBool("PoisonedMethanolLastEffect", true)
	ply:Freeze(true)

	netstream.Start(ply, 'dbt/NewNotification', 3, {
		icon = 'materials/dbt/notifications/notifications_heart.png',
		title = 'Плохое самочувствие',
		titlecolor = Color(215, 63, 66),
		notiftext = 'Ваши ноги и руки не слушаются вас. Неужели это конец?'
	})
	hook.Run("PoisonMethanolLastStage", ply)

	timer.Simple(POISON_METHANOL.DeathStageWarmup, function()
		if not IsValid(ply) or not PoisonMethanolIsActive(ply) then return end
		timer.Create(TName(ply, "death"), POISON_METHANOL.DeathTick, 0, function()
			if not IsValid(ply) or not ply:Alive() or not PoisonMethanolIsActive(ply) then
				timer.Remove(TName(ply, "death"))
				return
			end
			local dmg = math.max(1, math.floor(ply:GetMaxHealth() * POISON_METHANOL.DeathFraction))
			ply:SetHealth(math.max(0, ply:Health() - dmg))
			ply:SetNWBool("KilledByPoison", true)
			if ply:Health() <= 0 then
				timer.Remove(TName(ply, "death"))
				ply:SetNWBool("KilledByPoison", true)
				if ply:Alive() then ply:Kill() end
			end
		end)
	end)
end

function PoisonMethanolActivate(ply, poisonedby)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if ply:GetNWBool("PoisonedKCN") then return false end

	if PoisonMethanolIsActive(ply) then
		ply.PoisonMethanolStart = CurTime()
		timer.Adjust(TName(ply, "laststage"), POISON_METHANOL.LastStageDelay, 1, function() StartLastStage(ply) end)
		hook.Run("PoisonMethanolRefreshed", ply, poisonedby)
		return true
	end

	ply.PoisonMethanolStart = CurTime()
	ply:SetNWBool("PoisonedMethanol", true)
	hook.Run("PoisonMethanolActivatedHook", ply, poisonedby)

	timer.Create(TName(ply, "init"), POISON_METHANOL.InitialDelay, 1, function()
		StartFirstEffects(ply)
	end)

	timer.Create(TName(ply, "laststage"), POISON_METHANOL.LastStageDelay, 1, function()
		StartLastStage(ply)
	end)
	return true
end

hook.Add("PlayerDeath", "MethanolPoison_ResetOnDeath", function(ply)
	if PoisonMethanolIsActive(ply) then
		ResetMethanolState(ply)
	else
		ply:SetNWBool("PoisonedMethanolUseFood", false)
		ply:SetNWBool("PoisonedMethanolLastEffect", false)
	end
end)

hook.Add("PlayerUse", "MethanolPoison_BlockUse", function(ply)
	if ply:GetNWBool("PoisonedMethanolLastEffect") or ply:GetNWBool("PoisonedKCN") then
		return false
	end
end)

hook.Add("PlayerDisconnected", "MethanolPoison_Cleanup", function(ply)
	ClearTimers(ply)
end)

concommand.Add("dbt_methanol_cure", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local target = ply
	if args[1] then
		for _, v in ipairs(player.GetAll()) do
			if string.find(string.lower(v:Name()), string.lower(args[1]), 1, true) then
				target = v
				break
			end
		end
	end
	if IsValid(target) then
		if PoisonMethanolCure(target) then
			if IsValid(ply) then ply:ChatPrint("[Methanol] Снято с "..target:Name()) end
		else
			if IsValid(ply) then ply:ChatPrint("[Methanol] Игрок не отравлен") end
		end
	end
end)
