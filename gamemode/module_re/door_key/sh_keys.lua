local door_groups = door_groups or {}


if SERVER then 
    netstream.Hook("update.Groups", function(ply, grp)
        door_groups = grp
        netstream.Start(nil, "update.Groups", door_groups)
    end)
    netstream.Hook("door.CreateKey", function(ply, key, name)
    end)
else 
    function UpdateGroups()
        netstream.Start("update.Groups", door_groups)
    end
            netstream.Hook("update.Groups", function(grp)
            door_groups = grp
        end)
end

properties.Add( "crategroup", {
    MenuLabel = "Создать группу",
    Order = 2,
    MenuIcon = "icon16/shield_add.png", 

    Filter = function( self, ent, ply )
        return IsValid(ent) and not ent:IsPlayer() and ent:isDoor() and not live_room_id[ent:GetModel()]
    end,

    SetOwner = function( self, door, chr )

        self:MsgStart()
            net.WriteEntity( door )
            net.WriteString( chr )
        self:MsgEnd()

    end,

    Action = function( self, ent )

        Derma_StringRequest(
            "Установка группы", 
            "Введите название группы",
            "",
            function(text) 
                door_groups[text] = true
                self:MsgStart()
                    net.WriteEntity( ent )
                    net.WriteString( text )
                self:MsgEnd()
                UpdateGroups()

            end,
            function(text) end
        )

    end,

    Receive = function( self, length, ply )

        local door = net.ReadEntity()
        local name = net.ReadString()
        door:SetNWString("Owner", name)
    end

} )

properties.Add( "setgroup", {
    MenuLabel = "Установить группу",
    Order = 4,
    MenuIcon = "icon16/user_add.png", 

    Filter = function( self, ent, ply )
        return IsValid(ent) and not ent:IsPlayer() and ent:isDoor() and not live_room_id[ent:GetModel()]
    end,

    MenuOpen = function( self, option, ent, tr )

        local target = ent


        local submenu = option:AddSubMenu()
        for k,i in pairs(door_groups) do  
            submenu:AddOption( k, function()  
                self:MsgStart()
                    net.WriteEntity( ent )
                    net.WriteString( k )
                self:MsgEnd()

            end )
        end
        
    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )

        local door = net.ReadEntity()
        local name = net.ReadString()
        door:SetNWString("Owner", name)
    end

} )

properties.Add( "removegroup", {
    MenuLabel = "Удалить группу",
    Order = 5,
    MenuIcon = "icon16/cross.png", 

    Filter = function( self, ent, ply )
        return IsValid(ent) and not ent:IsPlayer() and ent:isDoor() and not live_room_id[ent:GetModel()]
    end,

    MenuOpen = function( self, option, ent, tr )

        local target = ent


        local submenu = option:AddSubMenu()
        for k,i in pairs(door_groups) do  
            submenu:AddOption( k, function()  
                self:MsgStart()
                    net.WriteEntity( ent )
                self:MsgEnd()
                door_groups[k] = nil
                UpdateGroups()

            end )
        end
        --option:GetMenu():AddSpacer()
        
    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )

        local door = net.ReadEntity()
        door:SetNWString("Owner", "")
    end

} )

properties.Add( "2131231", {
    MenuLabel = "-----------",
    Order = 6,
    --MenuIcon = "", 

    Filter = function( self, ent, ply )
        return IsValid(ent) and not ent:IsPlayer() and ent:isDoor() and not live_room_id[ent:GetModel()]
    end,

    MenuOpen = function( self, option, ent, tr )

        
    end,

    Action = function( self, ent )

    end,

    Receive = function( self, length, ply )
    end
})

properties.Add( "getgroup", {
    MenuLabel = "Удалить группу",
    Order = 1,
    MenuIcon = "icon16/information.png", 

    Filter = function( self, ent, ply )
        local b = IsValid(ent) and not ent:IsPlayer() and ent:isDoor() and not live_room_id[ent:GetModel()]
        if b then 
            self.MenuLabel = "Группа двери: "..ent:GetNWString("Owner")
        end
        return b
    end,

    MenuOpen = function( self, option, ent, tr ) 
    end,

    Action = function( self, ent )
        
    end,

    Receive = function( self, length, ply )

    end

} )


properties.Add( "create_key_door", {
    MenuLabel = "Создать ключ",
    Order = 3,
    MenuIcon = "icon16/key_add.png", 

    Filter = function( self, ent, ply )
        local b = IsValid(ent) and not ent:IsPlayer() and ent:isDoor() and not live_room_id[ent:GetModel()]
        return b
    end,

    MenuOpen = function( self, option, ent, tr ) 
    end,

    Action = function( self, ent )
        Derma_StringRequest(
            "Укажите название ключа", 
            "",
            "",
            function(text) 
                netstream.Start("dbt/create/key", ent:GetNWString("Owner"), text)
            end,
            function(text) end
        )

        
    end,

    Receive = function( self, length, ply )

    end

} )

properties.Add( "toggle_lockpick", {
    MenuLabel = "Разрешить отмычку",
    Order = 7,
    MenuIcon = "icon16/lock.png",

    Filter = function( self, ent, ply )
        local allowed = IsValid(ent) and not ent:IsPlayer() and ent:isDoor()
        if allowed then
            if ent:GetNWBool("dbt.NoLockpick") then
                self.MenuLabel = "Запретить отмычку"
                self.MenuIcon = "icon16/lock_open.png"
            else
                self.MenuLabel = "Разрешить отмычку"
                self.MenuIcon = "icon16/lock.png"
            end
        end
        return allowed
    end,

    MenuOpen = function( self, option, ent, tr )
    end,

    Action = function( self, ent )
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function( self, length, ply )
        local door = net.ReadEntity()
        if not IsValid(door) or not door:isDoor() then return end
        local current = door:GetNWBool("dbt.NoLockpick")
        door:SetNWBool("dbt.NoLockpick", not current)
    end

} )