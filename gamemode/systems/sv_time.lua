
dbt = dbt or {}
dbt.time = dbt.time or {}


dbt.time.globalTime = 0
dbt.time.isRunning = true
dbt.time.speedMultiplier = 24 
SetGlobalInt("speedmultiplier", dbt.time.speedMultiplier)

function dbt.time.UpdateTimeDisplay()
    local globalTime = dbt.time.globalTime
    
    
    SetGlobalInt("Time", globalTime)
    
    
    local s = globalTime % 60
    local tmp = math.floor(globalTime / 60)
    local m = tmp % 60
    tmp = math.floor(tmp / 60)
    local h = tmp % 24
    local days = math.floor(tmp / 24)
    
    
    dbt.time.currentTimeFormatted = string.format("%02ih %02im %02is", h, m, s)

    SetGlobalInt("TimeHours", h)
    SetGlobalInt("TimeMinutes", m)
    SetGlobalInt("TimeSeconds", s)
    SetGlobalInt("TimeDays", days)
    
    
    return h, m, s, days
end


function dbt.time.Set(seconds)
    dbt.time.globalTime = seconds
    dbt.time.UpdateTimeDisplay()
    
    
    hook.Run("DBT_TimeChanged", dbt.time.globalTime)
    
    return dbt.time.globalTime
end


function dbt.time.Add(seconds)
    return dbt.time.Set(dbt.time.globalTime + seconds)
end


function dbt.time.Get()
    return dbt.time.globalTime
end


function dbt.time.GetFormatted()
    return dbt.time.currentTimeFormatted
end


function dbt.time.Start()
    if dbt.time.isRunning then return false end
    SetGlobalBool("TimeRunning", true)
    dbt.time.isRunning = true
    
    
    if not timer.Exists("dbt.TimeTimer.2") then
        timer.Create("dbt.TimeTimer.2", 1, 0, function()

            if dbt.time.isRunning then
                dbt.time.Add(dbt.time.speedMultiplier)
                dbt.time.UpdateTimeDisplay()
            end
        end)
    else
        timer.UnPause("dbt.TimeTimer.2")
    end

    hook.Run("DBT_TimeStateChanged", true)
    
    return true
end


function dbt.time.Stop()
    if not dbt.time.isRunning then return false end
    
    dbt.time.isRunning = false
    
    if timer.Exists("dbt.TimeTimer.2") then
        timer.Pause("dbt.TimeTimer.2")
    end
    
    
    print("[DBT Time] Time system stopped")
    SetGlobalBool("TimeRunning", false)
    hook.Run("DBT_TimeStateChanged", false)
    
    return true
end


function dbt.time.Toggle()
    if dbt.time.isRunning then
        return dbt.time.Stop()
    else
        return dbt.time.Start()
    end
end


function dbt.time.SetSpeed(multiplier)
    if multiplier <= 0 then
        print("[DBT Time] Error: Speed multiplier must be greater than 0")
        return false
    end
    
    dbt.time.speedMultiplier = multiplier
    SetGlobalInt("speedmultiplier", dbt.time.speedMultiplier)
    print("[DBT Time] Speed multiplier set to " .. multiplier)
    hook.Run("DBT_TimeSpeedChanged", multiplier)
    
    return true
end


function dbt.time.GetSpeed()
    return dbt.time.speedMultiplier
end


dbt.time.UpdateTimeDisplay()

print("[DBT Time] Initial time: " .. dbt.time.currentTimeFormatted)

timer.Create("dbt.TimeTimer.2", 1, 0, function()
    if dbt.time.isRunning then
        dbt.time.Add(dbt.time.speedMultiplier)
        dbt.time.UpdateTimeDisplay()
    end 
end) 


concommand.Add("dbt_time_set", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    local seconds = tonumber(args[1])
    if not seconds then
        print("[DBT Time] Usage: dbt_time_set <seconds>")
        return
    end
    
    dbt.time.Set(seconds)
    print("[DBT Time] Time set to " .. seconds .. " seconds")
end)

concommand.Add("dbt_time_add", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    local seconds = tonumber(args[1])
    if not seconds then
        print("[DBT Time] Usage: dbt_time_add <seconds>")
        return
    end
    
    dbt.time.Add(seconds)
    print("[DBT Time] Added " .. seconds .. " seconds")
end)

concommand.Add("dbt_time_speed", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    local speed = tonumber(args[1])
    if not speed then
        print("[DBT Time] Usage: dbt_time_speed <multiplier>")
        return
    end
    
    dbt.time.SetSpeed(speed)
end)

concommand.Add("dbt_time_toggle", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    if dbt.time.Toggle() then
        print("[DBT Time] Time system toggled to: " .. (dbt.time.isRunning and "Running" or "Stopped"))
    end
end)


globaltime = dbt.time.globalTime
curtimesys = dbt.time.currentTimeFormatted


netstream.Hook("dbt/time/start", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    dbt.time.Start()
    ply:ChatPrint("[DBT Time] Время запущено")
end)

netstream.Hook("dbt/time/stop", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    dbt.time.Stop()
    ply:ChatPrint("[DBT Time] Время остановлено")
end)

netstream.Hook("dbt/time/set", function(ply, seconds)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    dbt.time.Set(seconds)
    ply:ChatPrint("[DBT Time] Время установлено на " .. dbt.time.currentTimeFormatted)
end)

netstream.Hook("dbt/time/add", function(ply, seconds)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    dbt.time.Add(seconds)
    ply:ChatPrint("[DBT Time] Добавлено " .. seconds .. " секунд. Текущее время: " .. dbt.time.currentTimeFormatted)
end)

netstream.Hook("dbt/time/setspeed", function(ply, speed)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    dbt.time.SetSpeed(speed)
    ply:ChatPrint("[DBT Time] Скорость времени установлена на " .. speed .. "x")
end)