util.AddNetworkString("Sleep")
util.AddNetworkString("SleepUP")
util.AddNetworkString("SystemLoaded")

local sleeprem = 0.6

local timeforsleep = 50

local meta = FindMetaTable("Player")

local DefaultWalkSpeed = 80
local DefaultRunSpeed = 195

function meta:newSleepData()
    self:SetNWInt("sleep", 100)
end

function meta:sleepUpdate()
	if self:GetNWInt("IsSleep") == 1 then return end
    if not IsGame() or not InGame(self) then return end
    local sleep = self:GetNWInt("sleep")

    if sleep == 0 then return end

    if sleep <= 15 and self:GetNWInt("VerySleepy") == 0 then
    	self:SetNWInt("VerySleepy", 1)
    elseif self:GetNWInt("VerySleepy") == 1 then
    	self:SetNWInt("VerySleepy", 0)
    end

    if sleep <= 0 then return end
    local food = dbt.chr[self:Pers()].sleep or 1
    self:SetNWInt("sleep", math.Round(sleep - sleeprem * food))
end

function meta:sleepUpdateUP()
    if IsLobby() or IsClassTrial() then return end

    local sleep = self:GetNWInt("sleep")

    if sleep >= 100 then self:SetNWInt("sleep", 100) return end

    self:SetNWInt("sleep", sleep + 1)

end

local function SLThink()
    for _, v in ipairs(player.GetAll()) do
        if not v:Alive() then continue end
        v:sleepUpdate()
    end
end

local function SLUPTThink()
    for _, v in ipairs(player.GetAll()) do
        if v:GetNWInt("IsSleep") == 1 then v:sleepUpdateUP() end
    end
end

local function SLPlayerSpawn(ply)
    ply:SetNWInt("sleep", 100)
    ply:SetNWInt("IsSleep", 0)
end--

local function SLPlayerInitialSpawn(ply)
    MsgN( ply:Nick() .. " has spawned!" )
    ply:newSleepData()
    ply:SetNWInt("IsSleep", 0)
end

local function SLPlayerEnteredVehicle(ply, veh)
	if veh:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" then
		net.Start("Sleep")
		net.Send(ply)
		ply:SetNWInt("IsSleep", 1)
	end
end

local function SLPlayerLeaveVehicle(ply, veh)
	if veh:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" then
		net.Start("SleepUP")
		net.Send(ply)
		ply:SetNWInt("IsSleep", 0)
	end
end


timer.Create("Check(SLThink)", 60, 0, function()
    if not timer.Exists("SLThink") then 
        timer.Create("SLThink", timeforsleep, 0, SLThink)
    end
end)

timer.Create("Check(SLUPThink)", 60, 0, function()
    if not timer.Exists("SLUPThink") then 
        timer.Create("SLUPThink", 3, 0, SLUPTThink)
    end
end)

timer.Create("SLThink", timeforsleep, 0, SLThink)
timer.Create("SLUPThink", 3, 0, SLUPTThink)

hook.Add("PlayerSpawn", "SLPlayerSpawn", SLPlayerSpawn)
hook.Add("PlayerSpawn", "SLPlayerInitialSpawn", SLPlayerInitialSpawn)

hook.Add("PlayerEnteredVehicle", "SLPlayerEnteredVehicle", SLPlayerEnteredVehicle)
hook.Add("PlayerLeaveVehicle", "SLPlayerLeaveVehicle", SLPlayerLeaveVehicle)
--
net.Start("SystemLoaded")
    net.WriteBool(true)
    net.WriteString("Сон")
net.Broadcast()
