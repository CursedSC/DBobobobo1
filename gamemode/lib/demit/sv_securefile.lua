if not file or _G.__dbtSecureFileWrapped then return end
_G.__dbtSecureFileWrapped = true

local oldFile = table.Copy(file)
local gamemodeName = string.lower(engine.ActiveGamemode() or "")

local function isGamemodePath(path, gamePath)
    if not path then return false end
    path = string.lower(path)
    gamePath = string.lower(gamePath or "")

    if string.find(path, "gamemodes/" .. gamemodeName .. "/") then
        return true
    end

    if string.find(path, "^lua/") and gamePath == "gamemodes/" .. gamemodeName then
        return true
    end

    return false
end

local function warn(action, path)
    ErrorNoHalt(string.format("[SECURITY] file.%s заблокировал доступ к файлам гейммода: %s\n", action, tostring(path)))
end

function file.Read(path, gamePath)
    if isGamemodePath(path, gamePath) then
        warn("Read", path)
        return nil
    end
    return oldFile.Read(path, gamePath)
end

function file.Exists(path, gamePath)
    if isGamemodePath(path, gamePath) then
        warn("Exists", path)
        return false
    end
    return oldFile.Exists(path, gamePath)
end

function file.Find(path, gamePath)
    if isGamemodePath(path, gamePath) then
        warn("Find", path)
        return {}, {}
    end
    return oldFile.Find(path, gamePath)
end

function file.Open(path, mode, gamePath)
    if isGamemodePath(path, gamePath) then
        warn("Open", path)
        return nil
    end
    return oldFile.Open(path, mode, gamePath)
end

function file.Size(path, gamePath)
    if isGamemodePath(path, gamePath) then
        warn("Size", path)
        return -1
    end
    return oldFile.Size(path, gamePath)
end

function file.IsDir(path, gamePath)
    if isGamemodePath(path, gamePath) then
        warn("IsDir", path)
        return false
    end
    return oldFile.IsDir(path, gamePath) 
end

setmetatable(file, {
    __newindex = function(_, k, v)
        ErrorNoHalt("[SECURITY] Попытка изменить file." .. tostring(k) .. "\n")
    end,
})

