local timeforsleep = 47 * 2

local meta = FindMetaTable("Player")

function meta:newWaterrData()
    self:SetNWInt("water", 100)
end

function meta:WaterUpdate()
    if not IsGame() or not InGame(self) or self:Pers() == "K1-B0" or not GetGlobalString("WaterStatus") or not dbt.chr[self:Pers()].starving then return end
    local sleep = self:GetNWInt("water")

        if sleep <= 5 then  if self:Health() > 10 then self:TakeDamage(1)  end return end

    local food = dbt.chr[self:Pers()].water or 1
    self:SetNWInt("water", sleep - 1 * food)
end


local function WT_Think()
    for _, v in ipairs(player.GetAll()) do
        if not v:Alive() then continue end
        v:WaterUpdate()
    end
end


local function WT_PlayerSpawn(ply)
    ply:SetNWInt("water", 100)
end

local function WT_PlayerInitialSpawn(ply)
    ply:newWaterrData()
end

timer.Create("Check(WTThink)", 60, 0, function()
    if not timer.Exists("WTThink") then 
        timer.Create("WTThink", 42, 0, WT_Think)
    end
end)

timer.Create("WTThink", 42, 0, WT_Think)

hook.Add("PlayerSpawn", "WT_PlayerSpawn", WT_PlayerSpawn)
hook.Add("PlayerSpawn", "WT_PlayerInitialSpawn", WT_PlayerInitialSpawn)

