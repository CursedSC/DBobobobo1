local tableans = {
	"Что-бы проснуться нажмите E",
}

timer.Create("ChangeFastAns", 10, 0, function()
	fastans = tableans[math.random(1,#tableans)]
end)
local meta = FindMetaTable("Player")

function meta:GetPlayerSleep()
	return self:GetNWInt("sleep")
end


local function SleepStart()
	local ply = LocalPlayer()
	hook.Remove("HUDPaint", "Sleep")
	hook.Remove("HUDPaint", "SleepUP")	
	local fraction = 0
    local lerptime = 0.3
    hook.Add( "HUDPaint", "Sleep", function()
		fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
	    if fraction == 0 then return end
	    local alpha = Lerp(fraction, 0, 255)
		surface.SetDrawColor( 0, 0, 0, alpha )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )	

		draw.DrawText( "Сон: "..ply:GetNWInt("sleep"), "DermaLarge", ScrW() * 0.5, ScrH() * 0.1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER )
		draw.DrawText( "Подсказка: " ..fastans, "DermaLarge", ScrW() * 0.5, ScrH() * 0.9, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER )
    end)
end

local function SleepEnd()
	local ply = LocalPlayer()
	hook.Remove("HUDPaint", "Sleep")
	hook.Remove("HUDPaint", "SleepUP")	
	local fraction = 0
    local lerptime = 0.3
    hook.Add( "HUDPaint", "SleepUP", function()
		fraction = math.Clamp(fraction + FrameTime()/lerptime, 0, 1)
	    if fraction == 0 then return end
	    local alpha = Lerp(fraction, 255, 0)
		surface.SetDrawColor( 0, 0, 0, alpha )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
		draw.DrawText( "Вы просыпаетесь...", "DermaLarge", ScrW() * 0.5, ScrH() * 0.1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER ) 	    
    end)
end

net.Receive("Sleep", SleepStart)
net.Receive("SleepUP", SleepEnd)
lerptime = 0.1
ffraction = 0
hook.Add( "HUDPaint", "Sleep", function()
	if LocalPlayer():GetNWInt("VerySleepy") == 1 then
		ffraction = math.Clamp(ffraction + FrameTime()/lerptime, 0, 1)
		if ffraction == 0 then return end
		local alpha = Lerp(ffraction, 0, 150)
		surface.SetDrawColor( 0, 0, 0, alpha )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	else
		alpha = 0
		ffraction = 0
	end	
end)