util.AddNetworkString("Hungred")

local timeforsleep = 40

local meta = FindMetaTable("Player")

function meta:newHungerData()
    self:SetNWInt("hunger", 100)
end

function meta:HungerUpdate()
    if not IsGame() or not InGame(self) or self:Pers() == "K1-B0" or not GetGlobalString("HungerStatus") or not dbt.chr[self:Pers()].hugred then return end

    local sleep = self:GetNWInt("hunger")

    if sleep == 10 then  
        net.Start("Hungred")
        net.Send(self)
    end

    if sleep <= 5 then  if self:Health() > 10 then self:TakeDamage(1)  end return end

    local food = dbt.chr[self:Pers()].food or 1
    self:SetNWInt("hunger", sleep - 1 * food)
end


local function SLThink()
    for _, v in ipairs(player.GetAll()) do
        if not v:Alive() then continue end
        v:HungerUpdate()
    end
end


local function SLPlayerSpawn(ply)
    ply:SetNWInt("hunger", 100)
end

local function SLPlayerInitialSpawn(ply)
    MsgN( ply:Nick() .. " has spawned!" )
    ply:newHungerData()
end

timer.Create("Check(HGThink)", 60, 0, function()
    if not timer.Exists("HGThink") then 
        timer.Create("HGThink", 30, 0, SLThink)
    end
end)


timer.Create("HGThink", 30, 0, SLThink)

hook.Add("PlayerSpawn", "HGPlayerSpawn", SLPlayerSpawn)
hook.Add("PlayerSpawn", "HGPlayerInitialSpawn", SLPlayerInitialSpawn)

