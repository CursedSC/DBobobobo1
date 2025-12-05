-- Отображение значения лоби
local frame1 = Material("staff/frame1.png")
local frame2 = Material("staff/frame2.png") 

local function LerpColor(ratio, startColor, endColor)
    return Color(
            startColor.r + (endColor.r - startColor.r) * ratio,
            startColor.g + (endColor.g - startColor.g) * ratio,
            startColor.b + (endColor.b - startColor.b) * ratio,
            startColor.a + (endColor.a - startColor.a) * ratio
        )
end 
 

function dbt.StartGameScreen()
    curframe = frame1
    screen_fr = 0 
    screen_mn = 0 
    count_life = table.Count(charactersInGame) 
    already_death = {}

end

net.Receive("dbt.ShowScreen", dbt.StartGameScreen)

net.Receive("anim.Start", function()
    hook.Add("PrePlayerDraw", "PrePlayerDraw", IFPP_PrePlayerDraw)
    hook.Add("Think", "IFPP_Think", IFPP_Think)
    hook.Add("CreateMove", "IFPP_SetupMove", IFPP_SetupMove)
end)

net.Receive("anim.End", function()
        hook.Remove("PrePlayerDraw", "PrePlayerDraw")
        hook.Remove("Think", "IFPP_Think")
        hook.Remove("CreateMove", "IFPP_SetupMove")
end)


hook.Add( "InitPostEntity", "dbt.GetInfo", function()
    net.Start( "dbt.GetInfo" )
    net.SendToServer()
end ) 
