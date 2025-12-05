util.AddNetworkString("dbt.SetChr")
util.AddNetworkString("dbt.StartGame")
util.AddNetworkString("dbt.EndGame")
util.AddNetworkString("dbt.ShowScreen")
util.AddNetworkString("dbt.EndClassTrial")
util.AddNetworkString("dbt.ShowScreenDeath")
util.AddNetworkString("dbt.AddToGame")

net.Receive("dbt.SetChr", function(len, admin)
    local chr = net.ReadString()
    local ply = net.ReadEntity()

    dbt.setchr(ply, chr)
end)
net.Receive("dbt.AddToGame", function(len, admin)
    for k, v in pairs(player.GetAll()) do
        AddInGame(v)
    end
    SetGameStatus("game")
end)

for i,addon in pairs(engine.GetAddons()) do
    if addon.mounted then
        resource.AddWorkshop( addon.wsid )
    end
end

hook.Add( "PlayerInitialSpawn", "check_addons", function( ply )
    netstream.Start( ply, "player/start/work", engine.GetAddons())
end)


