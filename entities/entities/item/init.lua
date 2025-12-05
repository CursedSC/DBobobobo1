AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box004a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
    
    self.kkk = false
    self.add = 10
    self.interactionHandlers = {}
    
    -- Register default interaction handlers
    self:RegisterInteractionHandlers()
end

function ENT:SetInfo(id, meta)
    self.id = id
    self.meta = meta or {}
    self:SetNWInt("id_", id)
    
    local itemData = dbt.inventory.items[self.id]
    if itemData then
        self:SetNWInt("AdvencedUse", true)
        
        -- Store available interactions
        self.availableInteractions = {}
        if itemData.medicine then table.insert(self.availableInteractions, "medicine") end
        if itemData.food then table.insert(self.availableInteractions, "food") end
        if itemData.water then table.insert(self.availableInteractions, "water") end
        table.insert(self.availableInteractions, "take") -- Always available
    end
    
    -- Handle poison metadata
    if (self.meta.poisonedKCN or self.meta.poisonedMETHANOL) and self.meta.poisonedsteamid then
        self:SetNWBool('PoisonedBy'..self.meta.poisonedsteamid, true)
    end

    -- Special handling for poison items
    if self.id == 26 then
        self.meta.poisonedKCN = true
        self.meta.poisonedsteamid = "Poison"
        self.meta.poisonedby = "Изначально ядовитый"
    elseif self.id == 27 then
        self.meta.poisonedMETHANOL = true
        self.meta.poisonedsteamid = "Poison"
        self.meta.poisonedby = "Изначально ядовитый"
    end

    -- Initialize spoil time for edible items if not present
    if itemData and (itemData.food or itemData.water) and GetGlobalBool("dbt_spoil_enabled", true) then
        local minutes = itemData.spoil_time or itemData.time or 30
        if not self.meta.spoilAt then
            self.meta.spoilAt = CurTime() + (minutes * 60)
        end
    end
end

function ENT:RegisterInteractionHandlers()
    -- Handler for medicine interaction
    self.interactionHandlers["medicine"] = function(self, activator)
        local itemData = dbt.inventory.items[self.id]
        if self.id == 40 then
            self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), "Это нельзя использовать.")
            return false
        end
        
        -- Poison items special handling
        if self.id == 26 then
            PoisonKCNActivate(activator, self.meta.poisonedby)
            self:Remove()
            return true
        elseif self.id == 27 then
            PoisonMethanolActivate(activator, self.meta.poisonedby)
            self:Remove()
            return true
        end

        -- Regular medicine items
        if itemData.medicine then
            if dbt.CanUseMedicaments(activator, itemData.medicine) then
                netstream.Start(activator, "dbt/woundsystem/progressuse", activator, itemData.medicine)
                return true
            else
                self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), 
                                  "Вы не можете это использовать, у вас нет ранений.")
                return false
            end
        end
        
        return false
    end
    
    -- Handler for food interaction
    self.interactionHandlers["food"] = function(self, activator)
        local itemData = dbt.inventory.items[self.id] or {}
        if self.id == 40 then
            self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), "Это нельзя есть.")
            return false
        end
        
        if activator:GetNWBool("PoisonedMethanolUseFood") then
            self:NotifyPlayer(activator, "heart", "Уведомление", Color(215, 63, 65), 
                             "Вас тошнит от вида еды и напитков. Вы не можете это съесть.")
            return false
        end
        
        if itemData.food then
            if activator:GetNWInt("hunger") >= 100 then 
                self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), 
                             "Вы не можете это съесть, вы не голодны.")
                return false
            end

            return self:StartWorldConsume(activator, "food")
        end
        
        return false
    end
    
    -- Handler for water interaction
    self.interactionHandlers["water"] = function(self, activator)
        local itemData = dbt.inventory.items[self.id] or {}
        if self.id == 40 then
            self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), "Это нельзя пить.")
            return false
        end
        
        if itemData.water then
            if activator:GetNWInt("water") >= 100 then 
                self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), 
                                 "Вы не можете это выпить, вы не хотите пить.")
                return false
            end
            return self:StartWorldConsume(activator, "water")
        end
        
        return false
    end
    
    -- Handler for take interaction
    self.interactionHandlers["take"] = function(self, activator)
        local maxInventorySize = 25
        
        if self.consumeInProgress and self.consumeInProgress ~= activator then
            self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), "Предмет сейчас используется другим игроком.")
            return false
        end
		
        if self.consumeInProgress == activator then
            self:CancelWorldConsume(activator)
        end
		local characterInventory = dbt.chr[activator:Pers()].maxInventory or 10
        if #activator.items >= characterInventory then
            netstream.Start(activator, "dbt/inventory/error", "Недостаточно места в инвентаре!")
            return false
        end
        
        dbt.inventory.additem(activator, self.id, self.meta)
        self:Remove()
        return true
    end
    
    -- Handler for poison interaction
    self.interactionHandlers["poison"] = function(self, activator)
        local poisonType = activator:GetNWInt("INTERACTIONOOPOISON", 1)
        local poisonIds = {26, 27} -- KCN and methanol IDs
        local poisonId = poisonIds[poisonType]
        
        if not poisonId then return false end
        
        -- Find poison in inventory
        for k, v in pairs(activator.items) do
            if tonumber(v.id) == poisonId then
                dbt.inventory.removeitem(activator, k)
                
                -- Apply poison metadata
                if poisonId == 26 then
                    self.meta.poisonedKCN = true
                else
                    self.meta.poisonedMETHANOL = true
                end
                
                self.meta.poisonedby = activator:Pers()
                self.meta.poisonedsteamid = activator:SteamID64()
                self:SetNWBool('PoisonedBy'..activator:SteamID64(), true)

                -- Notify client
                netstream.Start(activator, "dbt/interactionchange")
                netstream.Start(activator, "dbt/poisonuse/anim", true)
                return true
            end
        end
        
        -- Poison not found in inventory
        self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), 
                         "У вас нет выбранного яда в инвентаре.")
        return false
    end
end

local WORLD_CONSUME_DISTANCE_SQR = (110 * 110)

function ENT:GetWorldConsumeId()
    return self.id or self:GetNWInt("id_")
end

function ENT:GetWorldConsumeDuration()
    local data = dbt.inventory.items[self:GetWorldConsumeId()] or {}
    if data.time then
        return 5
    end
    return 1
end

function ENT:ClearWorldConsumeState(player, suppressSound)
    if IsValid(player) then
        if not suppressSound then
            player:StopSound("inv_use.mp3")
        end
        player._dbtWorldConsume = nil
    end
    self.consumeInProgress = nil
    self.consumeStart = nil
    self.consumeDuration = nil
    self.consumeType = nil
end

function ENT:CancelWorldConsume(player, suppressSound)
    if self.consumeInProgress ~= player then return end
    self:ClearWorldConsumeState(player, suppressSound)
end

function ENT:StartWorldConsume(activator, consumeType)
    if not IsValid(activator) then return false end
    if activator._dbtWorldConsume and activator._dbtWorldConsume.entity ~= self then
        self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), "Вы уже чем-то заняты.")
        return false
    end
    if self.consumeInProgress and self.consumeInProgress ~= activator then
        self:NotifyPlayer(activator, "main", "Уведомление", Color(222, 193, 49), "Кто-то уже взаимодействует с этим предметом.")
        return false
    end
    if self.consumeInProgress == activator then
        return true
    end

    local duration = self:GetWorldConsumeDuration()
    self.consumeInProgress = activator
    self.consumeStart = CurTime()
    self.consumeDuration = duration
    self.consumeType = consumeType

    activator._dbtWorldConsume = {
        entity = self,
        type = consumeType,
        start = self.consumeStart,
        duration = duration
    }

    local label = (consumeType == "water") and "Пьём..." or "Употребляем..."
    netstream.Start(activator, "dbt/inventory/world_consume/start", {
        ent = self,
        seconds = duration,
        label = label
    })

    return true
end

function ENT:HandleWorldConsumeCancel(player)
    self:CancelWorldConsume(player)
end

function ENT:HandleWorldConsumeFinish(player)
    if self.consumeInProgress ~= player then return end
    local info = player._dbtWorldConsume
    if not info or info.entity ~= self then
        self:ClearWorldConsumeState(player, true)
        return
    end

    local duration = self.consumeDuration or info.duration or 0
    local startTime = self.consumeStart or info.start or 0
    if CurTime() - startTime < math.max(duration - 0.05, 0) then return end
    if player:GetPos():DistToSqr(self:GetPos()) > WORLD_CONSUME_DISTANCE_SQR then
        self:CancelWorldConsume(player)
        return
    end

    self:ApplyWorldConsumeEffect(player)
end

function ENT:ApplyWorldConsumeEffect(player)
    local consumeType = self.consumeType
    local id = self:GetWorldConsumeId()
    local itemData = dbt.inventory.items[id]
    self:ClearWorldConsumeState(player)

    if not itemData then
        if IsValid(self) then self:Remove() end
        return
    end

    self.meta = self.meta or {}

    if consumeType == "food" then
        if self.meta.poisonedKCN then
            PoisonKCNActivate(player, self.meta.poisonedby)
            if IsValid(self) then self:Remove() end
            return
        end
        if self.meta.poisonedMETHANOL then
            PoisonMethanolActivate(player, self.meta.poisonedby)
            if IsValid(self) then self:Remove() end
            return
        end

        local gain = itemData.food or 0
        player:SetNWInt("hunger", math.min(100, player:GetNWInt("hunger") + gain))
        if IsValid(self) then self:Remove() end
        return
    elseif consumeType == "water" then
        if self.meta.poisonedKCN then
            PoisonKCNActivate(player, self.meta.poisonedby)
            if IsValid(self) then self:Remove() end
            return
        end
        if self.meta.poisonedMETHANOL then
            PoisonMethanolActivate(player, self.meta.poisonedby)
            if IsValid(self) then self:Remove() end
            return
        end

        if id == 13 and not timer.Exists("can'tcofee"..player:Name()) then
            player:SetNWInt("sleep", math.min(100, player:GetNWInt("sleep") + 20))
            timer.Create("can'tcofee"..player:Name(), 2400, 1, function() end)
        end

        local gain = itemData.water or 0
        player:SetNWInt("water", math.min(100, player:GetNWInt("water") + gain))
        if IsValid(self) then self:Remove() end
        return
    end

    if IsValid(self) then
        self:Remove()
    end
end

-- Helper function for consistent notifications
function ENT:NotifyPlayer(player, icon, title, titleColor, message)
    netstream.Start(player, 'dbt/NewNotification', 3, {
        icon = 'materials/dbt/notifications/notifications_' .. icon .. '.png',
        title = title,
        titlecolor = titleColor,
        notiftext = message
    })
end

-- Add a custom interaction handler
function ENT:AddInteractionHandler(interactionType, handler)
    self.interactionHandlers[interactionType] = handler
end

function ENT:Use(activator)
    if self.kkk then return end
    
    -- Simple use case (no interaction menu)
    if not self:GetNWInt("AdvencedUse", false) then
        return self.interactionHandlers["take"](self, activator)
    end
    
    -- Store reference to last interacted entity for the player
    activator.lastInteractionEntity = self
    
    -- Get the interaction type from player
    local interactionType = activator:GetNWString("INTERACTIONOO", "take")
    
    -- Execute the interaction handler if available
    if self.interactionHandlers[interactionType] then
        return self.interactionHandlers[interactionType](self, activator)
    else
        -- If interaction type not supported, default to take
        return self.interactionHandlers["take"](self, activator)
    end
end

function ENT:OnRemove()
    if IsValid(self.consumeInProgress) then
        self:ClearWorldConsumeState(self.consumeInProgress)
    end
end

-- Lazy Think-based spoilage for world items (no timers)
function ENT:Think()
    -- Only run on server
    if CLIENT then return end
    if self.consumeInProgress then
        local ply = self.consumeInProgress
        if not IsValid(ply) then
            self:ClearWorldConsumeState(ply)
        else
            local info = ply._dbtWorldConsume
            if not info or info.entity ~= self then
                self:ClearWorldConsumeState(ply)
            end
        end
    end
    -- Early out if feature disabled
    if not GetGlobalBool("dbt_spoil_enabled", true) then return end
    local id = self.id or self:GetNWInt("id_")
    local data = dbt.inventory.items[id]
    if not data then return end
    if id == 40 then return end
    if not (data.food or data.water) then return end
    self._nextSpoilCheck = self._nextSpoilCheck or 0
    local now = CurTime()
    if now < self._nextSpoilCheck then return end
    self._nextSpoilCheck = now + 5
    self.meta = self.meta or {}
    local spoilAt = self.meta.spoilAt
    if not spoilAt then
        local minutes = data.spoil_time or data.time or 30
        self.meta.spoilAt = now + (minutes * 60)
        return
    end
    if now >= spoilAt then
        -- Convert entity into rotten item entity (ID 40)
        local pos, ang = self:GetPos(), self:GetAngles()
        local rotten = ents.Create("item")
        if not IsValid(rotten) then return end
        rotten:SetPos(pos)
        rotten:SetAngles(ang)
        rotten:SetInfo(40, {spoiled = true})
        rotten:Spawn()
        local cfg = dbt.inventory.items[40]
        if cfg and cfg.mdl then rotten:SetModel(cfg.mdl) end
        self:Remove()
    end
end

netstream.Hook("dbt/inventory/world_consume/finish", function(ply, ent)
    if not IsValid(ply) then return end
    if not IsValid(ent) or ent:GetClass() ~= "item" then return end
    if ent.HandleWorldConsumeFinish then
        ent:HandleWorldConsumeFinish(ply)
    end
end)

netstream.Hook("dbt/inventory/world_consume/cancel", function(ply, ent)
    if not IsValid(ply) then return end
    if not IsValid(ent) or ent:GetClass() ~= "item" then return end
    if ent.HandleWorldConsumeCancel then
        ent:HandleWorldConsumeCancel(ply)
    end
end)