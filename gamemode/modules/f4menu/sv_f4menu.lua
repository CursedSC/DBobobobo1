
util.AddNetworkString("dbt.f4menu")
util.AddNetworkString("dbt.SetChar")
hook.Add( "ShowSpare2", "dbt.f4menu", function(ply)
    net.Start("dbt.f4menu")
    net.Send(ply)
end )
util.AddNetworkString("dbt.CreateCharacter")

net.Receive("dbt.CreateCharacter", function(len, ply)
    local firstName = net.ReadString()
    local lastName = net.ReadString()
    local height = net.ReadFloat()
    local description = net.ReadString()
    
    -- Валидация
    if firstName == "" or lastName == "" then return end
    if height < 0.7 or height > 1.3 then height = 1.0 end
    
    -- Сохранение данных персонажа
    ply.CharacterData = {
        firstName = firstName,
        lastName = lastName,
        height = height,
        description = description,
        fullName = firstName .. " " .. lastName
    }
    
    -- Применение роста
    ply:SetModelScale(height, 0)
    
    -- Сохранение в базу данных (добавьте свою систему)
    -- Например: sql.Query("INSERT INTO characters...")
    
    ply:ChatPrint("Персонаж создан: " .. ply.CharacterData.fullName)
end)

net.Receive("dbt.SetChar", function(len,ply)
    local chr = net.ReadString()
    dbt.setchr(ply, chr)
end)