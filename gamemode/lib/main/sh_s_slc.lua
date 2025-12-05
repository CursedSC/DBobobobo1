local classes = { }

local types = { 
    [TYPE_INVALID] = "none",
    [TYPE_NIL] = "null",
    [TYPE_BOOL] = "bool",
    [TYPE_LIGHTUSERDATA] = "lightuserdata",
    [TYPE_NUMBER] = "number",
    [TYPE_STRING] = "string",
    [TYPE_TABLE] = "table",
    [TYPE_FUNCTION] = "func",
    [TYPE_USERDATA] = "userdata",
    [TYPE_THREAD] = "thread",
    [TYPE_ENTITY] = "entity",
    [TYPE_VECTOR] = "vector",
    [TYPE_ANGLE] = "angle",
    [TYPE_PHYSOBJ] = "physobj",
    [TYPE_SAVE] = "save",
    [TYPE_RESTORE] = "restore",
    [TYPE_DAMAGEINFO] = "damageinfo",
    [TYPE_EFFECTDATA] = "effectdata",
    [TYPE_MOVEDATA] = "movedata",
    [TYPE_RECIPIENTFILTER] = "recipientfilter",
    [TYPE_USERCMD] = "usercmd",
    [TYPE_MATERIAL] = "material",
    [TYPE_PANEL] = "panel",
    [TYPE_PARTICLE] = "particle",
    [TYPE_PARTICLEEMITTER] = "particleemitter",
    [TYPE_TEXTURE] = "texture",
    [TYPE_USERMSG] = "usermsg",
    [TYPE_CONVAR] = "convar",
    [TYPE_IMESH] = "mesh",
    [TYPE_MATRIX] = "matrix",
    [TYPE_SOUND] = "sound",
    [TYPE_PIXELVISHANDLE] = "pixelvishandle",
    [TYPE_DLIGHT] = "dlight",
    [TYPE_VIDEO] = "video",
    [TYPE_FILE] = "file",
    [TYPE_LOCOMOTION] = "locomotion",
    [TYPE_PATH] = "path",
    [TYPE_NAVAREA] = "navarea",
    [TYPE_SOUNDHANDLE] = "soundhandle",
    [TYPE_NAVLADDER] = "navladder",
    [TYPE_PARTICLESYSTEM] = "particlesystem",
    [TYPE_PROJECTEDTEXTURE] = "physcollide",
    [TYPE_SURFACEINFO] = "surfaceinfo",
    [TYPE_COLOR] = "color"
}

local function VariableType(variable)
    return types[IsColor(variable) and TYPE_COLOR or TypeID(variable)]
end

oop = { }

function oop.CreateClass(className, baseClass)
    local class = { }

    if TypeID(className) ~= TYPE_STRING then
        return
    end

    if TypeID(baseClass) == TYPE_STRING then
        baseClass = oop.GetClass(baseClass)
    end

    if TypeID(baseClass) == TYPE_TABLE then
        oop.ExtendClass(class, baseClass)
    end

    classes[className] = class

    return class
end

function oop.ExtendClass(class, baseClass)
    if TypeID(class) == TYPE_STRING then
        class = oop.GetClass(class)
    end

    if TypeID(class) ~= TYPE_TABLE then
        return
    end
    
    if TypeID(baseClass) == TYPE_STRING then
        baseClass = oop.GetClass(baseClass)
    end

    if TypeID(baseClass) ~= TYPE_TABLE then
        return
    end

    function class:Super(...)
        baseClass.Construct(self, ...)
    end

    setmetatable(class, { __index = baseClass })
end

function oop.GetClass(className)
    return classes[className]
end

function oop.GetClasses()
    return classes
end

function oop.GetBaseClass(class)
    if TypeID(class) == TYPE_STRING then
        class = oop.GetClass(class)
    end

    if TypeID(class) ~= TYPE_TABLE then
        return
    end

    return getmetatable(class).__index
end

function oop.NewInstance(class, ...)
    local instance = { }

    if TypeID(class) == TYPE_STRING then
        class = oop.GetClass(class)
    end

    if TypeID(class) ~= TYPE_TABLE then
        return
    end

    setmetatable(instance, { __index = class })

    instance:Construct(...)

    return instance
end

function oop.InstanceOf(classInstance, baseClass)
    if TypeID(baseClass) == TYPE_STRING then
        baseClass = oop.GetClass(baseClass)
    end

    if TypeID(baseClass) ~= TYPE_TABLE then
        return
    end

    local instanceBaseClass = oop.GetBaseClass(classInstance)

    return instanceBaseClass == baseClass
end

function oop.CreateOverload()
    local signatures = { }

    local overloadMeta = { }

    function overloadMeta:__call(...)
        local arguments = { ... }
        local argumentsCount = #arguments

        local current = signatures

        for argumentIndex = 1, argumentsCount do
            local argument = arguments[argumentIndex]
            
            current = current[VariableType(argument)]

            if not current then
                return
            end
        end

        if TypeID(current.call) ~= TYPE_FUNCTION then
            return
        end

        return current.call(...)
    end

    function overloadMeta:__newindex(key, value)
        signatures[key] = signatures[key] or { }
        signatures[key].call = value
    end
    
    function overloadMeta:__index(key)
        local signature = { }

        local function __newindex(self, key, value)
            signature[#signature + 1] = key

            local current = signatures
            local signatureKeysCount = #signature

            for signatureKeyIndex = 1, signatureKeysCount do
                local signatureKey = signature[signatureKeyIndex]

                current[signatureKey] = current[signatureKey] or { }
                current = current[signatureKey]
            end

            current.call = value
        end

        local function __index(self, key)
            signature[#signature + 1] = key

            return setmetatable({ }, {
                __index = __index,
                __newindex = __newindex
            })
        end

        return __index(self, key)
    end

    return setmetatable({ }, overloadMeta)
end
