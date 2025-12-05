local rangs = {
    ["helper"] = true,
    ["admin"] = true,
    ["founder"] = true,
    ["superadmin"] = true,
    ["gm"] = true, 
}--
-- 
local live_room_idx = {
    ["*68"] = true,
    ["*67"] = true,
    ["*70"] = true, 
    ["*72"] = true, 
    ["*74"] = true,
}

live_room_id = {
    ["*76"] = true,
    ["*67"] = true,
    ["*64"] = true,
    ["*68"] = true,
    ["*65"] = true,
    ["*70"] = true,
    ["*62"] = true,
    ["*72"] = true,
    ["*60"] = true,
    ["*74"] = true,
    ["*59"] = true,
    ["*57"] = true,
    ["*78"] = true,
    ["*80"] = true,
    ["*82"] = true,
    ["*222"] = true,
}

local frameColor = Color(47, 54, 64)
local frameColorRed = Color(200, 0, 0)
local frameColorDarkRed = Color(200, 150, 150)
local buttonColor = Color(47, 54, 64)

local frameColor1 = Color(135, 35, 82)
local buttonColor1 = Color(47, 54, 64)


function DoorMenu()

    if not rangs[LocalPlayer():GetUserGroup()] then return end
    local door_menu = vgui.Create( "DFrame" )
    door_menu:SetSize( 330, 400 )
    door_menu:Center()
    door_menu:SetTitle("")
    door_menu:MakePopup()
    door_menu.Paint = function(me, w, h)
        surface.SetDrawColor(frameColor)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(frameColor1)
        surface.DrawRect(0,0,w,h * 0.06)
    end

    local DPanel = vgui.Create( "DPanel",door_menu )
    DPanel:SetPos( 20, 50 ) 
    DPanel:SetSize( 290, 300)
    DPanel.Paint = function(me, w, h)
        surface.SetDrawColor(frameColor1)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(frameColor)
        surface.DrawRect(2,2,w - 4,h - 4)
    end

    local DScrollPanel = vgui.Create( "DScrollPanel", DPanel )
    DScrollPanel:SetPos( 2, 2 ) 
    DScrollPanel:SetSize( 301, 300 - 4)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)

    end
    function sbar.btnDown:Paint(w, h)

    end
    function sbar.btnGrip:Paint(w, h)
    end

    y__ = 2
    for k,v in pairs(player.GetAll()) do
        local DButton = DScrollPanel:Add( "DButton" )
        DButton:SetText( "" )
        DButton:SetPos( 2, y__ ) 
        DButton:SetSize( 280, 50)
        local s = dbt.chr[v:Pers()].season
        local ch = dbt.chr[v:Pers()].char
        DButton.prs = CreateMaterial( ch.."cool."..s, "UnlitGeneric", {
                ["$basetexture"] = "dbt/characters"..s.."/char"..ch.."/pixel_ico.vtf",
                ["$alphatest"] = 1,
                ["$vertexalpha"] = 1,
                ["$vertexcolor"] = 1,
                ["$smooth"] = 0,

                ["$allowalphatocoverage"] = 1,
                ["$alphatestreference "] = 0.8,
        } )

        DButton.Paint = function(me, w, h)
            surface.SetDrawColor(frameColor1)
            surface.DrawRect(2,2,w,h)
            surface.SetDrawColor(frameColor)
            surface.DrawRect(4,4,w - 8,h - 8)

            surface.SetDrawColor( 255, 255, 255, 255 ) 
            surface.SetMaterial( me.prs ) 
            surface.DrawTexturedRect( -5, -5, w * 0.15 + 20, h + 10) 

            draw.DrawText( v:Pers(), "DASS", w * 0.15 + 5, h * 0.25, color_white, TEXT_ALIGN_LEFT )
        end
        DButton.DoClick = function()               
            net.Start("OwnerGroup")
                net.WriteString(v:Pers())
            net.SendToServer()
            door_menu:Close()
        end
        y__ = y__ + 52
    end
end

net.Receive("OpenDoorMenu", DoorMenu)


local function LiveRooms()
	dbt.liverooms = net.ReadTable()
end

maxRoomDoorDistance = 2000--


net.Receive("dbt.ClientRoomss", LiveRooms)

hook.Add( "InitPostEntity", "Ready", function()
    net.Start("dbt.ClientRoomss")
    net.SendToServer()
end )


function GetSpriteDoor( char )


    local s = dbt.chr[char].season
    local ch = dbt.chr[char].char

    local material = CreateMaterial( s.."_"..ch.."_", "UnlitGeneric", {
        ["$basetexture"] = "dbt/characters"..s.."/char"..ch.."/pixel_sprite.vtf",
        ["$alphatest"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1,
        ["$smooth"] = 1,

        ["$allowalphatocoverage"] = 1,
        ["$alphatestreference "] = 0.8,
    } )
--
    return material
end

--
local function DrawOnRoomDoor(roomDoor, ownerName, ownerRole, dist, point, side)


        local ownerCharacter = roomDoor:GetDoorOwner() or nil
        
        if side == FORWARD then
            if ownerCharacter != "Гость" and ownerCharacter != "" then 
                surface.SetDrawColor( 133, 0, 0, 255 ) -- Set the drawing color
    			surface.SetMaterial( GetSpriteDoor( ownerCharacter )  ) -- Use our cached material
    			surface.DrawTexturedRect( -100, -300, 200, 200 ) -- Actually draw the rectangle
            end
        end
end


hook.Add("PostDrawOpaqueRenderables", "dbt.drawRoomDoor", function()
    local localPlayer = LocalPlayer()
    
    local shootPosition = localPlayer:GetShootPos()
    local aimVector = localPlayer:GetAimVector()

    local entities = ents.FindInSphere(shootPosition, maxRoomDoorDistance)
    
    table.Add(entities, roomDoors)

    local countEntities = #entities

    for entityIndex = 1, countEntities do
        local entity = entities[entityIndex]

        if live_room_id[entity:GetModel()] then

        local entityPosition = entity:GetPos()
        local distance = entityPosition:Distance(shootPosition)

        local owner = "dsfsde"
        local dist = (maxRoomDoorDistance - distance) / maxRoomDoorDistance
        local entityOBBCenter = entity:OBBCenter()

        entityOBBCenter:Rotate(entity:GetAngles())

        local entityForward = entityOBBCenter:Angle():Right()

        if roomDoorsWithWrongForwardDirect and table.HasValue(roomDoorsWithWrongForwardDirect, entity:GetCreationID()) then
            entityForward = -entityForward
        end

        local angle = (-entityForward:Angle():Right()):Angle()
        
        local ownerName = "Не занята"
        local ownerRole = "Её уже никто не займет"

        if live_room_id[entity:GetModel()] then
            if GetGameStatus() == "preparation" then
                ownerRole = "Возможно кто-то её займет"
            end
        else
            ownerName = ""
            ownerRole = ""
        end

        angle:RotateAroundAxis(angle:Forward(), 90)

        local front = entityPosition + entityOBBCenter + entityForward * 2.75
        local behind = entityPosition + entityOBBCenter - entityForward * 2.75

        if not live_room_idx[entity:GetModel()] then
            local point = util.IntersectRayWithPlane(shootPosition, aimVector, front, angle:Up())

            if point then
                point = WorldToLocal(point, Angle(), front, angle) * -10
                
                point.x = -point.x
            end

            cam.Start3D2D(front, angle, 0.1)
                DrawOnRoomDoor(entity, ownerName, ownerRole, dist, point, FORWARD)
            cam.End3D2D()
        else
            angle:RotateAroundAxis(angle:Right(), 180)

            local point = util.IntersectRayWithPlane(shootPosition, aimVector, behind, angle:Up())

            if point then
                point = WorldToLocal(point, Angle(), behind, angle) * -10
                
                point.x = -point.x
            end

            cam.Start3D2D(behind, angle, 0.1)
                DrawOnRoomDoor(entity, ownerName, ownerRole, dist, point, BEHIND)
            cam.End3D2D()
        end
    end

    end
end)
