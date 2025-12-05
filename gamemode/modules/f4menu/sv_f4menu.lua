
util.AddNetworkString("dbt.f4menu")
util.AddNetworkString("dbt.SetChar")
hook.Add( "ShowSpare2", "dbt.f4menu", function(ply)
    net.Start("dbt.f4menu")
    net.Send(ply)
end )

net.Receive("dbt.SetChar", function(len,ply)
    local chr = net.ReadString()
    dbt.setchr(ply, chr)
end)