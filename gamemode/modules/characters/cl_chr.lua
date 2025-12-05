net.Receive("dbt.Charactrs", function()
  charactersInGame = net.ReadTable()
  GPS_POS = {}
  if normal_camera_position[game.GetMap()] then
    local tbl = normal_camera_position[game.GetMap()]
    local segmentdist = 16 / ( 2 * math.pi * math.max( 100, 100 ) / 2 )
    for a = 0, 15 do
        local acd = a * -22.5 + tbl.acd
        local pos_ = Vector(tbl.x + math.cos( math.rad( acd ) ) * tbl.add_dist, tbl.y - math.sin( math.rad( acd ) ) * tbl.add_dist, normal_camera_position[game.GetMap()].z ) --tbl.x + math.cos( math.rad( a + segmentdist ) ) * 100, tbl.y - math.sin( math.rad( a + segmentdist ) ) * 100
        GPS_POS[a + 2] = pos_
    end
  end
end)

net.Receive("dbt/characters/preset/download", function()
  local id = net.ReadString()
  net.ReadStream(LocalPlayer(), function(data)
    file.CreateDir("dbt/characters_client/presets")
    file.Write("dbt/characters_client/presets/"..id..".json", data)
  end)
end)

net.Receive("dbt/characters/single/download", function()
  local id = net.ReadString()
  net.ReadStream(LocalPlayer(), function(data)
    file.CreateDir("dbt/characters_client/single")
    file.Write("dbt/characters_client/single/"..id..".json", data)
  end)
end)

function DBT_SaveCharactersPresetClient(name, list)
  if not LocalPlayer():IsAdmin() then return end
  local f = {}
  if istable(list) then for k,v in pairs(list) do if dbt.chr[v] then f[v] = dbt.chr[v] end end else f = dbt.chr end
  local data = util.TableToJSON({Name = name or "local", Characters = f}, true)
  net.Start("dbt/characters/preset/upload")
  net.WriteStream(data, function() end)
  net.SendToServer()
end

function DBT_SaveSingleCharacterClient(char)
  if not LocalPlayer():IsAdmin() then return end
  if not dbt.chr[char] then return end
  local data = util.TableToJSON({Character = char, Data = dbt.chr[char]}, true)
  net.Start("dbt/characters/single/upload")
  net.WriteStream(data, function() end)
  net.SendToServer()
end
