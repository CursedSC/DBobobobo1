RAGGDOLL_WOUNDS = RAGGDOLL_WOUNDS or {}
RAGGDOLL_WOUNDS_ENT = RAGGDOLL_WOUNDS_ENT or {}

local function BuildTruePostions(tbl)

    for k, i in pairs(tbl) do 
        for id, w in pairs(i) do 
            local data_pos = w[2]
            local bonePos, boneAng = RAGGDOLL_WOUNDS_ENT:GetBonePosition(data_pos.bone)
            local pos = bonePos + data_pos.localOffset
            local tr = util.TraceLine( {
                start = pos,
                endpos = bonePos,
                filter = function( ent ) return true end
            } )
            tbl[k][id].RenderPos = tr.HitPos
            
        end
	end

    return tbl
end

netstream.Hook("send/wounds/1", function(ply, corpse, data)
    RAGGDOLL_WOUNDS_ENT = corpse
    RAGGDOLL_WOUNDS = BuildTruePostions(data)

    RunConsoleCommand("cl_ec_enabled", 0)
    gui.EnableScreenClicker(true)
end)

local function GetHovered( eyepos, eyevec )

	local ply = LocalPlayer()
	local filter = ply:GetViewEntity()

	local trace = util.TraceLine( {
		start = eyepos,
		endpos = eyepos + eyevec * 1024,
		filter = filter
	} )

    debugoverlay.Line( eyepos, eyepos + eyevec * 1024 )

	return trace.HitPos, trace

end

local function off_osmotr()
    RAGGDOLL_WOUNDS_ENT = nil
    RAGGDOLL_WOUNDS = nil
    RunConsoleCommand("cl_ec_enabled", 1)
    gui.EnableScreenClicker(false)
end

hook.Add( "PlayerButtonDown", "off_osmotr", function( ply, button )
    if not IsValid(RAGGDOLL_WOUNDS_ENT) then return end
    if !IsFirstTimePredicted() then return end
	if button == KEY_SPACE then off_osmotr() end
    if button == MOUSE_RIGHT then gui.EnableScreenClicker(false) end
end)

hook.Add( "PlayerButtonUp", "off_osmotr", function( ply, button )
    if not IsValid(RAGGDOLL_WOUNDS_ENT) then return end
    if !IsFirstTimePredicted() then return end
    if button == MOUSE_RIGHT then gui.EnableScreenClicker(true) end
end)

hook.Add( "PostDrawTranslucentRenderables", "Stencil Tutorial Example", function()

 
end)

hook.Add("RenderScreenspaceEffects", "BlurScreenExceptEntity", function()
    if not IsValid(RAGGDOLL_WOUNDS_ENT) then return end
    if IsValid(RAGGDOLL_WOUNDS_ENT) then
        BlurScreen(24)


        cam.Start3D()
        RAGGDOLL_WOUNDS_ENT:SetRenderMode(RENDERMODE_TRANSCOLOR)
        RAGGDOLL_WOUNDS_ENT:DrawModel()

        local posSearch = GetHovered( EyePos(), gui.ScreenToVector(gui.MousePos()) )
        render.DrawSphere( posSearch, 3, 30, 30, Color( 0, 255, 255, 52) )


        for k, i in pairs(RAGGDOLL_WOUNDS) do 
            for id, w in pairs(i) do 
                local data_pos = w[2]
    
                local bonePos, boneAng = RAGGDOLL_WOUNDS_ENT:GetBonePosition(data_pos.bone)
                local pos = bonePos + data_pos.localOffset
    
                local tr = util.TraceLine( {
                    start = pos,
                    endpos = bonePos,
                    filter = function( ent ) return true end
                } )

                render.SetColorMaterial()
                render.DrawSphere( tr.HitPos, 1, 30, 30, Color( 143, 15, 15, 100) )
                
                cam.Start2D()
                    local dist = posSearch:Distance(tr.HitPos)

                    local data2D = posSearch:ToScreen() 


                    if dist < 3 then 
                        local percent = dist / 1
                        if dist <= 1 then percent = 1 end
                        surface.DrawCircle( data2D.x, data2D.y, 20 * (percent), Color( 128, 0, 124) )

                    end

                cam.End2D()
            end
        end

        cam.End3D()
    end
end)

local minDistance = 35  -- Минимальное расстояние от камеры до энтити

-- Функция для установки камеры
hook.Add("CalcView", "EntityCameraView", function(ply, pos, angles, fov)
    if not IsValid(RAGGDOLL_WOUNDS_ENT) then return end
    local targetEntity = RAGGDOLL_WOUNDS_ENT
    if not IsValid(targetEntity) then return end

    local entityPos = targetEntity:GetPos()
    local view = {}

    -- Вычисляем желаемую позицию камеры, отступив назад на минимальную дистанцию
    local cameraPos = entityPos - (angles:Forward() * minDistance)

    -- Выполняем трассировку, чтобы проверить, не заходит ли камера в стену
    local traceData = {
        start = entityPos,
        endpos = cameraPos,
        filter = {targetEntity, ply}
    }
    local traceResult = util.TraceLine(traceData)

    -- Если трассировка столкнулась с препятствием, перемещаем камеру ближе к энтити
    if traceResult.Hit then
        cameraPos = traceResult.HitPos + traceResult.HitNormal * 5  -- Отступаем немного от препятствия
    end
    g_cameraPos = cameraPos
    g_AnglesCamera = (entityPos - cameraPos):Angle()
    -- Устанавливаем параметры вида камеры
    view.origin = cameraPos
    view.angles = (entityPos - cameraPos):Angle()  -- Направляем камеру на энтити
    view.fov = fov
    view.drawviewer = false
    return view
end)




hook.Add( "PostDrawTranslucentRenderables", "test", function()
    if 1 then return end
	for k, i in pairs(RAGGDOLL_WOUNDS) do 
        for id, w in pairs(i) do 
            local data_pos = w[2]

            local bonePos, boneAng = RAGGDOLL_WOUNDS_ENT:GetBonePosition(data_pos.bone)
            local pos = bonePos + data_pos.localOffset

            render.SetColorMaterial()
            render.DrawSphere( pos, 1, 30, 30, Color( 0, 175, 175, 100 ) )

            local tr = util.TraceLine( {
                start = pos,
                endpos = bonePos,
                filter = function( ent ) return true end
            } )
            

            render.SetColorMaterial()
            render.DrawSphere( tr.HitPos, 1, 30, 30, Color( 175, 0, 29, 100) )
        end
    end

end )

hook.Add( "HUDPaint", "RAGGDOLL_WOUNDS", function()
    if 1 then return end
	for k, i in pairs(RAGGDOLL_WOUNDS) do 
        for id, w in pairs(i) do 
            local data_pos = w[2]
            local bonePos, boneAng = RAGGDOLL_WOUNDS_ENT:GetBonePosition(data_pos.bone)
            local pos = bonePos + data_pos.localOffset
        
		    local data2D = pos:ToScreen() 

		    -- Draw a simple text over where the prop is
		    draw.SimpleText( data_pos.bone, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            local tr = util.TraceLine( {
                start = pos,
                endpos = bonePos,
                filter = function( ent ) return true end
            } )
            local data2D = tr.HitPos:ToScreen() 

            draw.SimpleText( data_pos.bone, "Default", data2D.x, data2D.y, Color( 249, 77, 77), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        end
	end


    for k = 1, RAGGDOLL_WOUNDS_ENT:GetBoneCount() do 
      
            local pos = RAGGDOLL_WOUNDS_ENT:GetBonePosition(k)
            if not pos then continue end
		    local data2D = pos:ToScreen() 
		    -- Draw a simple text over where the prop is
		    draw.SimpleText( k, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    
	end


end )