dbtPaint = dbtPaint or {}
local standartColor = Color(255,255,255)

// Fonts

dbtPaint.DrawRect = function(mat, x, y, w, h, col)
    local col = col or standartColor
    surface.SetDrawColor( col )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect(x, y, w, h)
end

dbtPaint.DrawRectR = function(mat, x, y, w, h, r, col)
    local col = col or standartColor
    surface.SetDrawColor( col )
    surface.SetMaterial( mat )
    surface.DrawTexturedRectRotated(x, y, w, h, r)
end

function dbtPaint.WidthSource(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

function dbtPaint.HightSource(x, custom)
    local a = custom or 1080
    return ScrH() / a  * x
end

function dbtPaint.Color(r, g, b, a)
    r = r < 90 and (0.916 * r + 7.8252) or r
    g = g < 90 and (0.916 * g + 7.8252) or g
    b = b < 90 and (0.916 * b + 7.8252) or b
    return Color(r, g, b, a)
end

for k = 1, 128 do
	surface.CreateFont( "Comfortaa X"..k, {
		font = "Comfortaa Light",
		extended = true,
		size =  dbtPaint.WidthSource(k),
		weight = dbtPaint.WidthSource(400),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "Comfortaa Light X"..k, {
		font = "Comfortaa Light",
		extended = true,
		size =  dbtPaint.WidthSource(k),
		weight = dbtPaint.WidthSource(300),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "Comfortaa Bold X"..k, {
		font = "Comfortaa Bold",
		extended = true,
		size =  dbtPaint.WidthSource(k),
		weight = dbtPaint.WidthSource(300),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "Comfortaa Regular X"..k, {
		font = "Comfortaa Regular",
		extended = true,
		size =  dbtPaint.WidthSource(k),
		weight = dbtPaint.WidthSource(400),
	} )
end

-- WORKER 0.625

for k = 1, 128 do
	surface.CreateFont( "_Comfortaa X"..k, {
		font = "Comfortaa Light",
		extended = true,
		size =  math.floor(dbtPaint.WidthSource(k) * 1.625),
		weight = dbtPaint.WidthSource(400),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "_Comfortaa Light X"..k, {
		font = "Comfortaa Light",
		extended = true,
		size =  math.floor(dbtPaint.WidthSource(k) * 1.625),
		weight = dbtPaint.WidthSource(300),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "_Comfortaa Bold X"..k, {
		font = "Comfortaa Bold",
		extended = true,
		size =  math.floor(dbtPaint.WidthSource(k) * 1.625),
		weight = dbtPaint.WidthSource(300),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "_Comfortaa Regular X"..k, {
		font = "Comfortaa Regular",
		extended = true,
		size =  math.floor(dbtPaint.WidthSource(k) * 1.625),
		weight = dbtPaint.WidthSource(400),
	} )
end

local lerpCounter = 0
local timerList = {}
dbtPaint.CreateLerp = function(time, callback)
    lerpCounter = lerpCounter + 1
    timerList[lerpCounter] = {
        timeEnd = time + CurTime(),
        time = time,
        callback = callback
    }
    PrintTable(timerList)
    return lerpCounter
end

dbtPaint.GetLerp = function(id)
    if !timerList[id] then return 1 end
    local info = timerList[id]
    local timeLeft = info.timeEnd - CurTime()
    local x = timeLeft / info.time
    return 1 - x
end

dbtPaint.LerpExist = function(id)
    return timerList[id]
end

dbtPaint.StartStencil = function()
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()


	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
end

dbtPaint.ApllyStencil = function()
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilFailOperation( STENCIL_KEEP )
end


local listOfCircles = {}
function dbtPaint.Circle( x, y, radius, seg, bNotUseList )
    local uid = x.."_"..y.."_"..radius.."_"..seg
    local cir = {}
    if listOfCircles[uid] and !bNotUseList then 
        cir = listOfCircles[uid]
    else
	    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	    for i = 0, seg do
	    	local a = math.rad( ( i / seg ) * -360 )
	    	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	    end

	    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

        listOfCircles[uid] = cir
    end
	surface.DrawPoly( cir )
end

hook.Add("HUDPaint", "dbtPaint.lerp", function()
    for k, i in pairs(timerList) do
        if CurTime() > i.timeEnd then  if i.callback then i.callback() end timerList[k] = nil end
    end
end)
--[[
local old_Material = Material
local chacheMats = {}
function Material(path, pngParameters)
	pngParameters = pngParameters or ""
	if chacheMats[path.."_"..pngParameters] then return chacheMats[path.."_"..pngParameters] end 
	chacheMats[path.."_"..pngParameters] = old_Material(path, pngParameters)
	return chacheMats[path.."_"..pngParameters]
end]]

