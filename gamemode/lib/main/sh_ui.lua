ui = { }


function ui.Scale(w, h, wMax, hMax, out)
    local k = (h / w * wMax > hMax) == not not out and wMax / w or hMax / h

    return w * k, h * k
end

function ui.InBox(x, y, x0, y0, w, h)
    return x >= x0 and x <= x0 + w and y >= y0 and y <= y0 + h
end

function ui.RotateVector2(x, y, ang, offsetX, offsetY)
    offsetX = TypeID(offsetX) == TYPE_NUMBER and offsetX or 0
    offsetY = TypeID(offsetY) == TYPE_NUMBER and offsetY or 0

    x = x - offsetX
    y = y - offsetY

    ang = math.rad(ang)

    local cos, sin = math.cos(ang), math.sin(ang)

    return offsetX + cos * x + sin * y, offsetY - sin * x + cos * y
end

function ui.RotateVector2ByCosAndSin(x, y, cos, sin, clockwise)
    if not isnumber(cos) and not isnumber(sin) then
        return 0, 0
    end

    cos = math.abs(cos or math.sqrt(1 - sin ^ 2))
    sin = math.abs(sin or math.sqrt(1 - cos ^ 2))

    if clockwise then
        return cos * x + sin * y, -sin * x + cos * y
    else
        return cos * x - sin * y, sin * x + cos * y
    end
end

function ui.LerpColor(ratio, startColor, endColor)
    return Color(
            startColor.r + (endColor.r - startColor.r) * ratio,
            startColor.g + (endColor.g - startColor.g) * ratio,
            startColor.b + (endColor.b - startColor.b) * ratio,
            startColor.a + (endColor.a - startColor.a) * ratio
        )
end

function ui.BtnMouseInputThink(btnData, btnX, btnY, btnW, btnH, onHovered, onPressed, onReleased)
    local cursorX, cursorY = input.GetCursorPos()
    local leftMouseKeyDown = input.IsMouseDown(MOUSE_LEFT)
    local hoveredPanel = vgui.GetHoveredPanel()

    if hoveredPanel and btnData.parent and hoveredPanel ~= btnData.parent then
        btnData.hovered = false
        btnData.pressed = false

        return
    end

    if  btnData.enabled and ui.InBox(cursorX, cursorY, btnX, btnY, btnW, btnH) and not (leftMouseKeyDown and not btnData.hovered) or
        btnData.pressed
    then
        if not btnData.hovered then
            if TypeID(onHovered) == TYPE_FUNCTION then
                onHovered(btnData)
            end
        end

        btnData.hovered = true

        if leftMouseKeyDown then
            if not btnData.pressed then
                if TypeID(onPressed) == TYPE_FUNCTION then
                    onPressed(btnData)
                end
            end

            btnData.pressed = true
        else
            if btnData.pressed then
                if TypeID(onReleased) == TYPE_FUNCTION then
                    onReleased(btnData)
                end
            end

            btnData.pressed = false
        end
    elseif not btnData.pressed then
        btnData.hovered = false
    end
end

if SERVER then
    util.AddNetworkString("ui.soundPlaySingle")

    function ui.SoundPlaySingle(player, path, pitch, volume)
        net.Start("ui.soundPlaySingle")
            net.WriteTable({
                path = path,
                pitch = pitch,
                volume = volume
            })
        net.Send(player)
    end

    function ui.SoundPlaySingleAll(path, pitch, volume)
        net.Start("ui.soundPlaySingle")
            net.WriteTable({
                path = path,
                pitch = pitch,
                volume = volume
            })
        net.Broadcast()
    end
else
    function ui.GetTextSize(text, font)
        if TypeID(font) ~= TYPE_STRING then
            font = "DermaDefault"
        end

        surface.SetFont(font)

        return surface.GetTextSize(text)
    end

    function ui.GetTextWidth(text, font)
        if TypeID(font) ~= TYPE_STRING then
            font = "DermaDefault"
        end

        surface.SetFont(font)

        local sizeW, sizeH = surface.GetTextSize(text)

        return sizeW
    end

    function ui.GetTextHeight(text, font)
        if TypeID(font) ~= TYPE_STRING then
            font = "DermaDefault"
        end

        surface.SetFont(font)

        local sizeW, sizeH = surface.GetTextSize(text)

        return sizeH
    end

    function ui.GetFontHeight(font)
        if TypeID(font) ~= TYPE_STRING then
            font = "DermaDefault"
        end

        surface.SetFont(font)

        local sizeW, sizeH = surface.GetTextSize("M")

        return sizeH
    end

    function ui.FrameText(text, font, width)
        if TypeID(font) ~= TYPE_STRING then
            font = "DermaDefault"
        end

        surface.SetFont(font)

        local framedText = ""
        local lines = string.Split(text, "\n")
        local linesCount = #lines

        local spaceWidth = surface.GetTextSize(" ")

        for lineIndex = 1, linesCount do
            local line = lines[lineIndex]
            local lineWidth = surface.GetTextSize(line)

            if lineWidth > width then
                local divisions = string.Split(line, " ")
                local divisionsCount = #divisions

                local currentLineWidth = 0

                for divisionIndex = 1, divisionsCount do
                    local division = divisions[divisionIndex]
                    local divisionWidth = surface.GetTextSize(division)

                    if currentLineWidth + divisionWidth + spaceWidth > width then
                        if currentLineWidth ~= 0 then
                            framedText = framedText .. "\n"
                            currentLineWidth = 0
                        end

                        if divisionWidth > width then
                            for startPosition, code in utf8.codes(division) do
                                local divisionChar = string.sub(division, startPosition, startPosition + (code > 0xFF and 1 or 0))
                                local divisionCharWidth = surface.GetTextSize(divisionChar)

                                if currentLineWidth + divisionCharWidth > width then
                                    framedText = framedText .. "\n"
                                    currentLineWidth = 0
                                end

                                framedText = framedText .. divisionChar
                                currentLineWidth = currentLineWidth + divisionCharWidth
                            end
                        else
                            framedText = framedText .. division
                            currentLineWidth = divisionWidth
                        end
                    else
                        framedText = framedText .. division
                        currentLineWidth = currentLineWidth + divisionWidth
                    end

                    framedText = framedText .. " "
                    currentLineWidth = currentLineWidth + spaceWidth
                end
            else
                framedText = framedText .. line
            end

            framedText = framedText .. "\n"
        end

        return string.sub(framedText, 1, string.len(framedText) - 1)
    end

    function ui.SoundPlaySingle(path, pitch, volume)
        LocalPlayer():EmitSound(path, 75, math.Clamp(pitch or 100, 0, 255), math.Clamp(volume or 1, 0, 1), CHAN_AUTO)
    end

    net.Receive("ui.soundPlaySingle", function(length)
        local data = net.ReadTable()

        if data.volume == nil then
            data.volume = settings.GetParameter("soundVolume")
        end

        ui.SoundPlaySingle(data.path, data.pitch, data.volume)
    end)
end