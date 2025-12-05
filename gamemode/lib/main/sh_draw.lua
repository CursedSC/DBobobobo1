if SERVER then
    return
end

local blur = Material("pp/blurscreen")
local whiteMaterial = Material("vgui/white")

local function GetVertexsCircleSegment(x, y, radius, sa, a, segmentCount)
    if radius == 0 then
        if segmentCount then
            local result = {
                {
                    x = x,
                    y = y
                }
            }

            for i = 2, segmentCount do
                result[i] = result[1]
            end

            return result
        else
            return {
                {
                    x = x,
                    y = y
                }
            }
        end
    end

    if not segmentCount then
        segmentCount = math.floor(radius * 2)
    end

    local circleSegment = { }
    local aOffset = a / (segmentCount - 1)

    for i = 0, segmentCount - 1 do
        local a = math.rad(sa + aOffset * i)
        local sina, cosa = math.sin(a), math.cos(a)

        circleSegment[i + 1] = { x = x + sina * radius, y = y - cosa * radius }
    end

    return circleSegment
end

function draw.DrawBlur(amount, x, y)
    if amount == 0 then
        return
    elseif not amount then
        amount = 1
    end

    local scrW, scrH = ScrW(), ScrH()

    x = x == nil and 0 or x
    y = y == nil and 0 or y

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * amount)
        blur:Recompute()

        render.UpdateScreenEffectTexture()

        surface.DrawTexturedRect(x, y, scrW, scrH)
    end
end

function draw.TexturedRectRotated(x, y, w, h, material, rotation, color, offsetX, offsetY)
    if IsColor(color) then
        surface.SetDrawColor(color)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end

    offsetX = offsetX or 0
    offsetY = offsetY or 0

    surface.SetMaterial(material)

    if offsetX == 0 and offsetY == 0 then
        surface.DrawTexturedRectRotated(x, y, w, h, rotation)
    else
        local rad = math.rad(rotation)
        local cos = math.cos(rad)
        local sin = math.sin(rad)

        surface.DrawTexturedRectRotated(x - offsetX * cos - offsetY * sin, y + offsetX * sin - offsetY * cos, w, h, rotation)
    end
end

function draw.TexturedRect(x, y, w, h, material, color)
    if IsColor(color) then
        surface.SetDrawColor(color)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end

    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
end

function draw.TexturedRectCenter(x, y, w, h, material, color)
    if TypeID(material) ~= TYPE_MATERIAL then
        return
    end

    if IsColor(color) then
        surface.SetDrawColor(color)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end

    surface.SetMaterial(material)
    surface.DrawTexturedRect(x - w / 2, y - h / 2, w, h)
end

function draw.RoundedBox2(r, x, y, w, h, color)
    color = color or Color(255, 255, 255)

    local v1 = GetVertexsCircleSegment(x + w - r, y + r, r, 0, 90)
    local v2 = GetVertexsCircleSegment(x + w - r, y + h - r, r, 90, 90)
    local v3 = GetVertexsCircleSegment(x + r, y + h - r, r, 180, 90)
    local v4 = GetVertexsCircleSegment(x + r, y + r, r, 270, 90)

    table.Add(v1, v2)
    table.Add(v1, v3)
    table.Add(v1, v4)

    surface.SetDrawColor(color.r, color.g, color.b, color.a)

    draw.NoTexture()

    surface.DrawPoly(v1)
end

function draw.RoundedBox3(r1, r2, r3, r4, x, y, w, h, color)
    color = IsColor(color) and color or Color(255, 255, 255)

    local v1 = GetVertexsCircleSegment(x + w - r1, y + r1, r1, 0, 90)
    local v2 = GetVertexsCircleSegment(x + w - r2, y + h - r2, r2, 90, 90)
    local v3 = GetVertexsCircleSegment(x + r3, y + h - r3, r3, 180, 90)
    local v4 = GetVertexsCircleSegment(x + r4, y + r4, r4, 270, 90)

    table.Add(v1, v2)
    table.Add(v1, v3)
    table.Add(v1, v4)

    surface.SetDrawColor(color.r, color.g, color.b, color.a)

    draw.NoTexture()

    surface.DrawPoly(v1)
end

function draw.CentreRoundedBox(r, x, y, w, h, color)
    draw.RoundedBox(r, x - w / 2, y - h / 2, w, h, color)
end

function draw.CentreRoundedBox2(r, x, y, w, h, color)
    draw.RoundedBox2(r, x - w / 2, y - h / 2, w, h, color)
end

function draw.OutFillMask(drawMask, drawFunc)
    render.ClearStencil()
    render.SetStencilEnable(true)

        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)

        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        render.SetStencilPassOperation(STENCIL_ZERO)
        render.SetStencilReferenceValue(1)

            drawMask()

        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        render.SetStencilReferenceValue(1)

            drawFunc()

    render.SetStencilEnable(false)
    render.ClearStencil()
end

function draw.FillMask(drawMask, drawFunc)
    render.ClearStencil()
    render.SetStencilEnable(true)

        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)

        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        render.SetStencilPassOperation(STENCIL_ZERO)
        render.SetStencilReferenceValue(1)

            drawMask()

        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilReferenceValue(1)

            drawFunc()

    render.SetStencilEnable(false)
    render.ClearStencil()
end

function draw.CircleSegment(x, y, radius, sa, a, color)
    local circleSegment = {}
    local seg = radius

    for i = seg * sa / 360, seg * ((sa + a) / 360) do
        local a = math.rad((i / seg) * -360)

        local sina, cosa, count = math.sin(a), math.cos(a), #circleSegment + 1

        circleSegment[count] = { x = x - sina * radius, y = y - cosa * radius }
    end

    surface.SetDrawColor(color.r, color.g, color.b, color.a)

    draw.NoTexture()

    surface.DrawPoly(circleSegment)
end

function draw.RotatedBox(x, y, w, h, ang, color)
    if TypeID(color) ~= TYPE_TABLE then
        color = Color(255, 255, 255)
    end

    ang = math.rad(ang)

    local cos1, sin1 = math.cos(ang), math.sin(ang)

    ang = ang - math.rad(90)

    local cos2, sin2 = math.cos(ang), math.sin(ang)

    local x01, y01 = cos1 * w / 2, sin1 * w / 2
    local x02, y02 = -x01, -y01

    local x11, y11 = cos2 * h / 2, sin2 * h / 2

    local x1, y1 = x01 + x11 + x, y01 + y11 + y
    local x2, y2 = x01 - x11 + x, y01 - y11 + y
    local x3, y3 = x02 + x11 + x, y02 + y11 + y
    local x4, y4 = x02 - x11 + x, y02 - y11 + y

    draw.NoTexture()

    surface.SetDrawColor(color.r, color.g, color.b, color.a)

    surface.DrawPoly({ { x = x1, y = y1 }, { x = x2, y = y2 }, { x = x3, y = y3 } })
    surface.DrawPoly({ { x = x2, y = y2 }, { x = x4, y = y4 }, { x = x3, y = y3 } })
end

function draw.OutlineBox(x, y, w, h, borderSize, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)

    surface.DrawRect(x, y, w, borderSize)
    surface.DrawRect(x + w - borderSize, y, borderSize, h)
    surface.DrawRect(x, y + h - borderSize, w, borderSize)
    surface.DrawRect(x, y, borderSize, h)
end

function draw.DrawTextBox(text, width, font, x, y, color, xAlign)
    if TypeID(font) ~= TYPE_STRING then
        font = "DermaDefault"
    end

    draw.DrawText(ui.FrameText(text, font, width), font, x, y, color, xAlign)
end

function draw.DrawColorText(x, y, ...)
    local args = { ... }
    local count = #args / 3 - 1

    for index = 0, count do
        local text = args[index * 3 + 1]
        local font = args[index * 3 + 2]
        local color = args[index * 3 + 3]

        surface.SetFont(font)
        surface.SetTextColor(color.r, color.g, color.b, color.a)
        surface.SetTextPos(x, y)
        surface.DrawText(text)

        local textWidth, textHeight = surface.GetTextSize(text)
        local mWidth, mHeight = surface.GetTextSize("M")

        x = x + textWidth
        y = y + textHeight - mHeight
    end
end

function draw.DrawColorTextBox(width, font, x, y, ...)
    if TypeID(font) ~= TYPE_STRING then
        font = "DermaDefault"
    end

    surface.SetFont(font)
    surface.SetTextColor(255, 255, 255)

    local fontHeight = math.floor(ui.GetFontHeight(font) * 1.1)
    
    local arguments = { ... }
    local argumentsCount = #arguments

    local currentLine = ""
    local currentColor = Color(255, 255, 255)

    local drawX, drawY = x, y

    for argumentIndex = 1, argumentsCount do
        local argument = arguments[argumentIndex]

        if IsColor(argument) then
            currentColor = Color(argument.r, argument.g, argument.b, argument.a)

            surface.SetTextColor(currentColor)
        elseif TypeID(argument) == TYPE_STRING then
            local framedText = ui.FrameText(currentLine .. argument, font, width)

            framedText = string.sub(framedText, string.len(currentLine) + 1)

            local lines = string.Split(framedText, "\n")

            drawX = x + surface.GetTextSize(currentLine)

            for lineIndex, line in pairs(lines) do
                surface.SetTextPos(drawX, drawY)

                surface.DrawText(line)

                drawX = x
                drawY = drawY + fontHeight
            end

            drawY = drawY - fontHeight

            if #lines == 1 then
                currentLine = currentLine .. lines[#lines]
            else
                currentLine = lines[#lines]
            end
        end
    end
end

function draw.Shadow(points, t, startColor, endColor, closed)
    local shadowPoints = { }

    for i = 2, #points - 1 do
        local pastPoint = points[i - 1]
        local point = points[i]
        local nextPoint = points[i + 1]

        local toPastPoint = {
            x = pastPoint.x - point.x,
            y = pastPoint.y - point.y
        }

        local toNextPoint = {
            x = nextPoint.x - point.x,
            y = nextPoint.y - point.y
        }

        toPastPoint.length = math.sqrt(toPastPoint.x ^ 2 + toPastPoint.y ^ 2)
        toPastPoint.x = toPastPoint.x / toPastPoint.length
        toPastPoint.y = toPastPoint.y / toPastPoint.length

        toNextPoint.length = math.sqrt(toNextPoint.x ^ 2 + toNextPoint.y ^ 2)
        toNextPoint.x = toNextPoint.x / toNextPoint.length
        toNextPoint.y = toNextPoint.y / toNextPoint.length

        local shadowPoint = {
            x = (toPastPoint.x + toNextPoint.x) / 2,
            y = (toPastPoint.y + toNextPoint.y) / 2
        }

        shadowPoint.length = math.sqrt(shadowPoint.x ^ 2 + shadowPoint.y ^ 2)

        if shadowPoint.length == 0 then
            toNextPoint.x, toNextPoint.y = -toNextPoint.y, toNextPoint.x

            shadowPoint.x = point.x + toNextPoint.x * t
            shadowPoint.y = point.y + toNextPoint.y * t
        else
            local sin = math.sqrt(1 - math.sqrt((1 + toPastPoint.x * toNextPoint.x + toPastPoint.y * toNextPoint.y) / 2) ^ 2)

            toPastPoint.x = -toPastPoint.x
            toPastPoint.y = -toPastPoint.y

            local x

            if toPastPoint.x < 0 then
                x = toPastPoint.y * toNextPoint.x + math.sqrt(1 - toPastPoint.y ^ 2) * toNextPoint.y

            elseif toPastPoint.x == 0 then
                if toPastPoint.y > 0 then
                    x = toNextPoint.x
                else
                    x = -toNextPoint.x
                end
            else
                x = toPastPoint.y * toNextPoint.x - math.sqrt(1 - toPastPoint.y ^ 2) * toNextPoint.y
            end

            if x > 0 then
                sin = -sin
            end

            shadowPoint.x = point.x + shadowPoint.x / shadowPoint.length * t / sin
            shadowPoint.y = point.y + shadowPoint.y / shadowPoint.length * t / sin
        end

        shadowPoint.length = nil

        shadowPoints[i] = shadowPoint
    end

    if closed then
        local pastPoint = points[#points]
        local point = points[1]
        local nextPoint = points[2]

        local toPastPoint = {
            x = pastPoint.x - point.x,
            y = pastPoint.y - point.y
        }

        local toNextPoint = {
            x = nextPoint.x - point.x,
            y = nextPoint.y - point.y
        }

        toPastPoint.length = math.sqrt(toPastPoint.x ^ 2 + toPastPoint.y ^ 2)
        toPastPoint.x = toPastPoint.x / toPastPoint.length
        toPastPoint.y = toPastPoint.y / toPastPoint.length

        toNextPoint.length = math.sqrt(toNextPoint.x ^ 2 + toNextPoint.y ^ 2)
        toNextPoint.x = toNextPoint.x / toNextPoint.length
        toNextPoint.y = toNextPoint.y / toNextPoint.length

        local shadowPoint = {
            x = (toPastPoint.x + toNextPoint.x) / 2,
            y = (toPastPoint.y + toNextPoint.y) / 2
        }

        shadowPoint.length = math.sqrt(shadowPoint.x ^ 2 + shadowPoint.y ^ 2)

        if shadowPoint.length == 0 then
            toNextPoint.x, toNextPoint.y = -toNextPoint.y, toNextPoint.x

            shadowPoint.x = point.x + toNextPoint.x * t
            shadowPoint.y = point.y + toNextPoint.y * t
        else
            local sin = math.sqrt(1 - math.sqrt((1 + toPastPoint.x * toNextPoint.x + toPastPoint.y * toNextPoint.y) / 2) ^ 2)

            toPastPoint.x = -toPastPoint.x
            toPastPoint.y = -toPastPoint.y

            local x

            if toPastPoint.x < 0 then
                x = toPastPoint.y * toNextPoint.x + math.sqrt(1 - toPastPoint.y ^ 2) * toNextPoint.y

            elseif toPastPoint.x == 0 then
                if toPastPoint.y > 0 then
                    x = toNextPoint.x
                else
                    x = -toNextPoint.x
                end
            else
                x = toPastPoint.y * toNextPoint.x - math.sqrt(1 - toPastPoint.y ^ 2) * toNextPoint.y
            end

            if x > 0 then
                sin = -sin
            end

            shadowPoint.x = point.x + shadowPoint.x / shadowPoint.length * t / sin
            shadowPoint.y = point.y + shadowPoint.y / shadowPoint.length * t / sin
        end

        shadowPoint.length = nil

        shadowPoints[1] = shadowPoint

        pastPoint = points[#points - 1]
        point = points[#points]
        nextPoint = points[1]

        toPastPoint = {
            x = pastPoint.x - point.x,
            y = pastPoint.y - point.y
        }

        toNextPoint = {
            x = nextPoint.x - point.x,
            y = nextPoint.y - point.y
        }

        toPastPoint.length = math.sqrt(toPastPoint.x ^ 2 + toPastPoint.y ^ 2)
        toPastPoint.x = toPastPoint.x / toPastPoint.length
        toPastPoint.y = toPastPoint.y / toPastPoint.length

        toNextPoint.length = math.sqrt(toNextPoint.x ^ 2 + toNextPoint.y ^ 2)
        toNextPoint.x = toNextPoint.x / toNextPoint.length
        toNextPoint.y = toNextPoint.y / toNextPoint.length

        shadowPoint = {
            x = (toPastPoint.x + toNextPoint.x) / 2,
            y = (toPastPoint.y + toNextPoint.y) / 2
        }

        shadowPoint.length = math.sqrt(shadowPoint.x ^ 2 + shadowPoint.y ^ 2)

        if shadowPoint.length == 0 then
            toNextPoint.x, toNextPoint.y = -toNextPoint.y, toNextPoint.x

            shadowPoint.x = point.x + toNextPoint.x * t
            shadowPoint.y = point.y + toNextPoint.y * t
        else
            local sin = math.sqrt(1 - math.sqrt((1 + toPastPoint.x * toNextPoint.x + toPastPoint.y * toNextPoint.y) / 2) ^ 2)

            toPastPoint.x = -toPastPoint.x
            toPastPoint.y = -toPastPoint.y

            local x

            if toPastPoint.x < 0 then
                x = toPastPoint.y * toNextPoint.x + math.sqrt(1 - toPastPoint.y ^ 2) * toNextPoint.y

            elseif toPastPoint.x == 0 then
                if toPastPoint.y > 0 then
                    x = toNextPoint.x
                else
                    x = -toNextPoint.x
                end
            else
                x = toPastPoint.y * toNextPoint.x - math.sqrt(1 - toPastPoint.y ^ 2) * toNextPoint.y
            end

            if x > 0 then
                sin = -sin
            end

            shadowPoint.x = point.x + shadowPoint.x / shadowPoint.length * t / sin
            shadowPoint.y = point.y + shadowPoint.y / shadowPoint.length * t / sin
        end

        shadowPoint.length = nil

        shadowPoints[#points] = shadowPoint
    else
        local point = points[1]
        local nextPoint = points[2]

        local toNextPoint = {
            x = nextPoint.x - point.x,
            y = nextPoint.y - point.y
        }

        toNextPoint.length = math.sqrt(toNextPoint.x ^ 2 + toNextPoint.y ^ 2)
        toNextPoint.x, toNextPoint.y = -toNextPoint.y / toNextPoint.length, toNextPoint.x / toNextPoint.length

        shadowPoints[1] = {
            x = point.x + toNextPoint.x * t,
            y = point.y + toNextPoint.y * t
        }

        point = points[#points]
        local pastPoint = points[#points - 1]

        local toPastPoint = {
            x = pastPoint.x - point.x,
            y = pastPoint.y - point.y
        }

        toPastPoint.length = math.sqrt(toPastPoint.x ^ 2 + toPastPoint.y ^ 2)
        toPastPoint.x, toPastPoint.y = toPastPoint.y / toPastPoint.length, -toPastPoint.x / toPastPoint.length

        shadowPoints[#points] = {
            x = point.x + toPastPoint.x * t,
            y = point.y + toPastPoint.y * t
        }
    end

    render.SetMaterial(whiteMaterial)

    mesh.Begin(MATERIAL_QUADS, #points - (closed and 0 or 1))

    for i = 1, #points - 1 do
        local point = points[i]
        local nextPoint = points[i + 1]
        local shadowPoint = shadowPoints[i]
        local nextShadowPoint = shadowPoints[i + 1]

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(point.x, point.y))
        mesh.AdvanceVertex()

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(nextPoint.x, nextPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(nextShadowPoint.x, nextShadowPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(shadowPoint.x, shadowPoint.y))
        mesh.AdvanceVertex()
    end

    if closed then
        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(points[#points].x, points[#points].y))
        mesh.AdvanceVertex()

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(points[1].x, points[1].y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(shadowPoints[1].x, shadowPoints[1].y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(shadowPoints[#shadowPoints].x, shadowPoints[#shadowPoints].y))
        mesh.AdvanceVertex()
    end

    mesh.End()
end

function draw.OuterRoundedBoxShadow(r1, r2, r3, r4, x, y, w, h, t, startColor, endColor)
    x = x - t
    y = y - t
    w = w + t * 2
    h = h + t * 2

    r1 = r1 + t
    r2 = r2 + t
    r3 = r3 + t
    r4 = r4 + t

    local outerCorner1 = GetVertexsCircleSegment(x + w - r1, y + r1, r1, 0, 90)
    local outerCorner2 = GetVertexsCircleSegment(x + w - r2, y + h - r2, r2, 90, 90)
    local outerCorner3 = GetVertexsCircleSegment(x + r3, y + h - r3, r3, 180, 90)
    local outerCorner4 = GetVertexsCircleSegment(x + r4, y + r4, r4, 270, 90)

    local outerCorners = { }

    table.Add(outerCorners, outerCorner1)
    table.Add(outerCorners, outerCorner2)
    table.Add(outerCorners, outerCorner3)
    table.Add(outerCorners, outerCorner4)

    x = x + t
    y = y + t
    w = w - t * 2
    h = h - t * 2

    r1 = r1 - t
    r2 = r2 - t
    r3 = r3 - t
    r4 = r4 - t

    local corner1 = GetVertexsCircleSegment(x + w - r1, y + r1, r1, 0, 90, #outerCorner1)
    local corner2 = GetVertexsCircleSegment(x + w - r2, y + h - r2, r2, 90, 90, #outerCorner2)
    local corner3 = GetVertexsCircleSegment(x + r3, y + h - r3, r3, 180, 90, #outerCorner3)
    local corner4 = GetVertexsCircleSegment(x + r4, y + r4, r4, 270, 90, #outerCorner4)

    local corners = { }

    table.Add(corners, corner1)
    table.Add(corners, corner2)
    table.Add(corners, corner3)
    table.Add(corners, corner4)

    render.SetMaterial(whiteMaterial)

    mesh.Begin(MATERIAL_QUADS, #corners)

    for i = 1, #corners - 1 do
        local point = corners[i]
        local nextPoint = corners[i + 1]
        local outerPoint = outerCorners[i]
        local nextOuterPoint = outerCorners[i + 1]

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(outerPoint.x, outerPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(nextOuterPoint.x, nextOuterPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(nextPoint.x, nextPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(point.x, point.y))
        mesh.AdvanceVertex()
    end

    mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
    mesh.Position(Vector(outerCorners[#outerCorners].x, outerCorners[#outerCorners].y))
    mesh.AdvanceVertex()

    mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
    mesh.Position(Vector(outerCorners[1].x, outerCorners[1].y))
    mesh.AdvanceVertex()

    mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
    mesh.Position(Vector(corners[1].x, corners[1].y))
    mesh.AdvanceVertex()

    mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
    mesh.Position(Vector(corners[#corners].x, corners[#corners].y))
    mesh.AdvanceVertex()

    mesh.End()
end

function draw.InnerRoundedBoxShadow(r1, r2, r3, r4, x, y, w, h, t, startColor, endColor)
    local corner1 = GetVertexsCircleSegment(x + w - r1, y + r1, r1, 0, 90)
    local corner2 = GetVertexsCircleSegment(x + w - r2, y + h - r2, r2, 90, 90)
    local corner3 = GetVertexsCircleSegment(x + r3, y + h - r3, r3, 180, 90)
    local corner4 = GetVertexsCircleSegment(x + r4, y + r4, r4, 270, 90)

    local corners = { }

    table.Add(corners, corner1)
    table.Add(corners, corner2)
    table.Add(corners, corner3)
    table.Add(corners, corner4)

    x = x + t
    y = y + t
    w = w - t * 2
    h = h - t * 2

    r1 = math.max(0, r1 - t)
    r2 = math.max(0, r2 - t)
    r3 = math.max(0, r3 - t)
    r4 = math.max(0, r4 - t)

    local innerCorner1 = GetVertexsCircleSegment(x + w - r1, y + r1, r1, 0, 90, #corner1)
    local innerCorner2 = GetVertexsCircleSegment(x + w - r2, y + h - r2, r2, 90, 90, #corner2)
    local innerCorner3 = GetVertexsCircleSegment(x + r3, y + h - r3, r3, 180, 90, #corner3)
    local innerCorner4 = GetVertexsCircleSegment(x + r4, y + r4, r4, 270, 90, #corner4)

    local innerCorners = { }

    table.Add(innerCorners, innerCorner1)
    table.Add(innerCorners, innerCorner2)
    table.Add(innerCorners, innerCorner3)
    table.Add(innerCorners, innerCorner4)

    render.SetMaterial(whiteMaterial)

    mesh.Begin(MATERIAL_QUADS, #corners)

    for i = 1, #corners - 1 do
        local point = corners[i]
        local nextPoint = corners[i + 1]
        local innerPoint = innerCorners[i]
        local nextInnerPoint = innerCorners[i + 1]

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(point.x, point.y))
        mesh.AdvanceVertex()

        mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
        mesh.Position(Vector(nextPoint.x, nextPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(nextInnerPoint.x, nextInnerPoint.y))
        mesh.AdvanceVertex()

        mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
        mesh.Position(Vector(innerPoint.x, innerPoint.y))
        mesh.AdvanceVertex()
    end

    mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
    mesh.Position(Vector(corners[#corners].x, corners[#corners].y))
    mesh.AdvanceVertex()

    mesh.Color(startColor.r, startColor.g, startColor.b, startColor.a)
    mesh.Position(Vector(corners[1].x, corners[1].y))
    mesh.AdvanceVertex()

    mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
    mesh.Position(Vector(innerCorners[1].x, innerCorners[1].y))
    mesh.AdvanceVertex()

    mesh.Color(endColor.r, endColor.g, endColor.b, endColor.a)
    mesh.Position(Vector(innerCorners[#innerCorners].x, innerCorners[#innerCorners].y))
    mesh.AdvanceVertex()

    mesh.End()
end

function draw.SimpleLinearGradient(x, y, w, h, startColor, endColor, horizontal)
    draw.LinearGradient(x, y, w, h, { {offset = 0, color = startColor}, {offset = 1, color = endColor} }, horizontal)
end

function draw.LinearGradient(x, y, w, h, stops, horizontal)
    x = x == nil and 0 or x
    y = y == nil and 0 or y

    w = w == nil and 0 or w
    h = h == nil and 0 or h

    if TypeID(stops) ~= TYPE_TABLE or #stops == 0 then
        return
    elseif #stops == 1 then
        surface.SetDrawColor(stops[1].color)
        surface.DrawRect(x, y, w, h)

        return
    end

    table.SortByMember(stops, "offset", true)

    render.SetMaterial(whiteMaterial)

    mesh.Begin(MATERIAL_QUADS, #stops - 1)

    for i = 1, #stops - 1 do
        local offset1 = math.Clamp(stops[i].offset, 0, 1)
        local offset2 = math.Clamp(stops[i + 1].offset, 0, 1)
        if offset1 == offset2 then continue end

        local deltaX1, deltaY1, deltaX2, deltaY2

        local color1 = stops[i].color
        local color2 = stops[i + 1].color

        local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
        local r2, g2, b2, a2
        local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
        local r4, g4, b4, a4

        if horizontal then
            r2, g2, b2, a2 = r3, g3, b3, a3
            r4, g4, b4, a4 = r1, g1, b1, a1

            deltaX1 = offset1 * w
            deltaY1 = 0

            deltaX2 = offset2 * w
            deltaY2 = h
        else
            r2, g2, b2, a2 = r1, g1, b1, a1
            r4, g4, b4, a4 = r3, g3, b3, a3

            deltaX1 = 0
            deltaY1 = offset1 * h

            deltaX2 = w
            deltaY2 = offset2 * h
        end

        mesh.Color(r1, g1, b1, a1)
        mesh.Position(Vector(x + deltaX1, y + deltaY1))
        mesh.AdvanceVertex()

        mesh.Color(r2, g2, b2, a2)
        mesh.Position(Vector(x + deltaX2, y + deltaY1))
        mesh.AdvanceVertex()

        mesh.Color(r3, g3, b3, a3)
        mesh.Position(Vector(x + deltaX2, y + deltaY2))
        mesh.AdvanceVertex()

        mesh.Color(r4, g4, b4, a4)
        mesh.Position(Vector(x + deltaX1, y + deltaY2))
        mesh.AdvanceVertex()
    end

    mesh.End()
end

function draw.Line(fromX, fromY, toX, toY, color)
    draw.NoTexture()

    surface.SetDrawColor(color)
    surface.DrawLine(fromX, fromY, toX, toY)
end

function draw.Rect(x, y, width, height, color)
    if TypeID(color) == TYPE_TABLE then
        surface.SetDrawColor(color)
    else
        surface.SetDrawColor(255, 255, 255)
    end

    surface.DrawRect(x, y, width, height)
end

function draw.RectCenter(x, y, width, height, color)
    if TypeID(color) == TYPE_TABLE then
        surface.SetDrawColor(color)
    else
        surface.SetDrawColor(255, 255, 255)
    end

    surface.DrawRect(x - width / 2, y - height / 2, width, height)
end

function draw.Arc(cx, cy, radius, thickness, startang, endang, roughness, color)
    draw.NoTexture()

    surface.SetDrawColor(color)
    surface.DrawArc(surface.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
end

function draw.RoundedBoxCenter(cornerRadius, x, y, width, height, color)
    draw.RoundedBox(cornerRadius, x - width / 2, y - height / 2, width, height, color)
end

function surface.DrawArc(arc)
    for k, v in ipairs(arc) do
        surface.DrawPoly(v)
    end
end

function surface.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
    local cos, sin, abs, max, rad1, log, pow = math.cos, math.sin, math.abs, math.max, math.rad, math.log, math.pow
    local quadarc = { }

    local startang,endang = startang or 0, endang or 0

    local diff = abs(startang - endang)
    local smoothness = log(diff, 2) / 2
    local step = diff / (pow(2, smoothness))

    if startang > endang then
        step = abs(step) * -1
    end

    local inner = { }
    local outer = { }
    local ct = 1
    local r = radius - thickness

    for deg=startang, endang, step do
        local rad = rad1(deg)
        local cosrad, sinrad = cos(rad), sin(rad)

        local ox, oy = cx + (cosrad * r), cy + (-sinrad * r)

        inner[ct] = {
            x = ox,
            y = oy,
            u = (ox - cx) / radius + .5,
            v = (oy - cy) / radius + .5,
        }

        local ox2, oy2 = cx + (cosrad * radius), cy + (-sinrad * radius)

        outer[ct] = {
            x = ox2,
            y = oy2,
            u = (ox2 - cx) / radius + .5,
            v = (oy2 - cy) / radius + .5,
        }

        ct = ct + 1
    end

    for tri = 1,ct do
        local p1, p2, p3, p4
        local t = tri + 1

        p1 = outer[tri]
        p2 = outer[t]
        p3 = inner[t]
        p4 = inner[tri]

        quadarc[tri] = { p1, p2, p3, p4 }
    end

    return quadarc
end

function draw.PolyCircle(x, y, radius, segmentsCount, color)
    color = color or Color(255, 255, 255)

    local circle = { }

    table.insert(circle, { x = x, y = y, u = 0.5, v = 0.5 })

    for i = 0, segmentsCount do
        local a = math.rad((i / segmentsCount) * -360)

        table.insert(circle, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
    end

    local a = math.rad(0)

    table.insert(circle, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })

    surface.SetDrawColor(color)
    surface.DrawPoly(circle)
end
