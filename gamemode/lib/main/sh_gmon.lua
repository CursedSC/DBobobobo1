local function findCharacter(str, char)
    local strLength = string.len(str)

    for charIndex = 1, strLength do
        if string.sub(str, charIndex, charIndex) == char then
            return charIndex
        end
    end
end

local function DecimalTo(data, length, characters)
    if TypeID(characters) ~= TYPE_STRING then
        characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz !?#$%&@+-*/^><=\\,:;'()[]"
    end

    local base = string.len(characters)

    local result = ""

    while data > 0 do
        local characterIndex = math.mod(data, base) + 1

        data = math.floor(data / base)

        result = string.sub(characters, characterIndex, characterIndex) .. result
    end

    if TypeID(length) == TYPE_NUMBER then
        return string.rep(string.sub(characters, 1, 1), length - string.len(result)) .. result
    else
        return result
    end
end

local function ToDecimal(data, characters)
    if TypeID(characters) ~= TYPE_STRING then
        characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz !?#$%&@+-*/^><=\\,:;'()[]"
    end

    if TypeID(data) ~= TYPE_STRING then
        return
    end

    local dataLength = string.len(data)
    local base = #characters

    local result = 0

    for characterIndex = 1, dataLength do
        result = result + findCharacter(characters, string.sub(data, characterIndex, characterIndex)) - 1

        if characterIndex ~= dataLength then
            result = result * base
        end
    end

    return result
end

gmon = { }

gmon.types = {
    [TYPE_STRING]   = "s",
    [TYPE_NUMBER]   = "n",
    [TYPE_TABLE]    = "t",
    [TYPE_BOOL]     = "b",
    [TYPE_ENTITY]   = "e",
    [TYPE_VECTOR]   = "v",
    [TYPE_ANGLE]    = "a",
    [TYPE_MATRIX]   = "m",
    [TYPE_COLOR]    = "c"
}

gmon.encoders = {
    [TYPE_STRING] = function(data)
        return data
    end,

    [TYPE_NUMBER] = function(data)
        return tostring(data)
    end,

    [TYPE_TABLE] = function(data)
        local encoded = ""

        for key, value in pairs(data) do
            encoded = encoded .. gmon.Encode(key) .. gmon.Encode(value)
        end

        return encoded
    end,

    [TYPE_BOOL] = function(data)
        return data and "1" or ""
    end,

    [TYPE_ENTITY] = function(data)
        local entityIndex = 0x10000

        if data:IsValid() then
            entityIndex = data:EntIndex()
        end

        return DecimalTo(entityIndex, 3)
    end,

    [TYPE_VECTOR] = function(data)
        return data.x .. " " .. data.y .. " " .. data.z
    end,

    [TYPE_ANGLE] = function(data)
        return data.pitch .. " " .. data.yaw .. " " .. data.roll
    end,
    
    [TYPE_MATRIX] = function(data)
        return gmon.Encode(data:ToTable())
    end,

    [TYPE_COLOR] = function(data)
        return bit.tohex(data.r, 2) .. bit.tohex(data.g, 2) .. bit.tohex(data.g, 2) .. bit.tohex(data.b, 2)
    end
}

gmon.dbtoders = {
    [TYPE_STRING] = function(data)
        return data
    end,

    [TYPE_NUMBER] = function(data)
        return tonumber(data)
    end,

    [TYPE_TABLE] = function(data)
        local dbtoded = { }

        while string.len(data) > 0 do
            local key, encodedKeyLength = gmon.Decode(data)

            data = string.sub(data, encodedKeyLength + 1)

            local value, encodedValueLength = gmon.Decode(data)

            data = string.sub(data, encodedValueLength + 1)

            dbtoded[key] = value
        end

        return dbtoded
    end,

    [TYPE_BOOL] = function(data)
        return data == "1"
    end,

    [TYPE_ENTITY] = function(data)
        local entityIndex = ToDecimal(data)

        if entityIndex == 0x10000 then
            return NULL
        end

        return Entity(entityIndex)
    end,

    [TYPE_VECTOR] = function(data)
        return Vector(data)
    end,

    [TYPE_ANGLE] = function(data)
        return Angle(data)
    end,

    [TYPE_MATRIX] = function(data)
        return Matrix(gmon.Decode(data))
    end,

    [TYPE_COLOR] = function(data)
        return Color(
            tonumber(string.sub(data, 1, 2), 16),
            tonumber(string.sub(data, 3, 4), 16),
            tonumber(string.sub(data, 5, 6), 16),
            tonumber(string.sub(data, 7, 8), 16)
        )
    end
}


function gmon.TypeNameByID(typeID)
    return gmon.types[typeID] or ""
end

function gmon.TypeIDByName(typeName)
    return table.KeyFromValue(gmon.types, typeName) or 0
end

function gmon.Encode(data)
    local dataTypeID = IsColor(data) and TYPE_COLOR or TypeID(data)

    local encoder = gmon.encoders[dataTypeID]

    if not encoder then
        return
    end

    local dataTypeName = gmon.TypeNameByID(dataTypeID)
    local encodedData = encoder(data)
    local encodedDataLength = DecimalTo(string.len(encodedData), 4)
    
    return dataTypeName .. encodedDataLength .. encodedData
end

function gmon.Decode(data)
    if TypeID(data) ~= TYPE_STRING then
        return
    end

    local dataTypeID = gmon.TypeIDByName(string.sub(data, 1, 1))
    
    local dbtoder = gmon.dbtoders[dataTypeID]

    if not dbtoder then
        return
    end

    local encodedDataLength = ToDecimal(string.sub(data, 2, 5))
    local encodedData = string.sub(data, 6, encodedDataLength + 5)

    return dbtoder(encodedData), encodedDataLength + 5
end