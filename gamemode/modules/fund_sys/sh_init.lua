local meta = FindMetaTable("Player")

function meta:IsFinding()
    local GDown = input.IsKeyDown(KEY_G)

    if GDown then
        return true
    else
        return false
    end
end