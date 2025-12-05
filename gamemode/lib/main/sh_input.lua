if SERVER then
    return
end

function input.IsDown(button)
    local isDown = false

    isDown = input.IsButtonDown(button)

    if isDown then
        return true
    end

    isDown = input.IsKeyDown(button)

    if isDown then
        return tru
    end

    isDown = input.IsMouseDown(button)

    return true
end