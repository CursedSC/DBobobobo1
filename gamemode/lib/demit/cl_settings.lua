
settings = settings or {}
settings.hooks = settings.hooks or {}
local configPath = "dbt/settings.json"
local function saveConfig(data)
    file.CreateDir("dbt")
    local jsonData = util.TableToJSON(data, true)
    file.Write(configPath, jsonData) 
end
  
 
local function loadConfig()
    file.CreateDir("dbt")
    if not file.Exists(configPath, "DATA") then
        return {} 
    end

    local jsonData = file.Read(configPath, "DATA")
    local data = util.JSONToTable(jsonData)
    return data or {} 
end 

config = loadConfig() 

settings.OnValueHook = function(name, settingsName, func)
    settings.hooks[settingsName] =  settings.hooks[settingsName] or {}
    settings.hooks[settingsName][name] =  settings.hooks[settingsName][name] or {}
    settings.hooks[settingsName][name] = func
end

settings.OnValueEdited = function(name, value)
    settings.hooks[name] = settings.hooks[name] or {}
    for k, i in pairs(settings.hooks[name]) do 
        i(value)
    end
end

settings.Set = function(key, value)
    config[key] = value
    settings.OnValueEdited(key, value) 
    saveConfig(config)
end

settings.Get = function(key, defaultValue)
    local value = config[key]
    if value ~= nil then
        return value
    end

    return defaultValue
end
 

function GetConfig()
    return config
end
