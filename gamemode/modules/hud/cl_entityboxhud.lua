local EntityInteraction = {}
EntityInteraction.__index = EntityInteraction
seeentitynow = false
function EntityInteraction:Initialize()
    self.screenWidth = ScrW()
    self.screenHeight = ScrH()
    self.activeEntity = nil
    self.lastEntity = nil
    self.isInteracting = false
    self.currentOption = 1
    self.poisonOption = 1
    self.cooldown = 0.5
    self.lastInteractionTime = 0
    self.themeColor = Color(139, 12, 161)

    self.interactionTypes = {}

    self:RegisterInteractionType("medicine", {
        name = "Лечение",
        priority = 10,
        condition = function(entity, itemData) return itemData.medicine end
    })
    
    self:RegisterInteractionType("food", {
        name = "Съесть",
        priority = 20,
        condition = function(entity, itemData) return itemData.food end
    })
    
    self:RegisterInteractionType("water", {
        name = "Выпить",
        priority = 30,
        condition = function(entity, itemData) return itemData.water end
    })
    
    self:RegisterInteractionType("take", {
        name = "Взять",
        priority = 1,
        condition = function(entity)
            return not entity:GetNWBool("dbt_storage_id", false)
        end
    })
    
    self:RegisterInteractionType("open_storage", {
        name = "Осмотреть",
        priority = 5,
        condition = function(entity)
            return entity:GetNWBool("dbt_storage_id", false)
        end
    })
    
    self:RegisterInteractionType("use", {
        name = "Использовать",
        priority = 2,
        condition = function(entity, itemData) return entity:GetClass() == "decoder" end
    })

    self:RegisterInteractionType("poison", {
        name = "Отравить",
        priority = 50,
        condition = function(entity, itemData)
            local itemId = entity:GetNWInt("id_")
            local canPoison = l_HasItem(26) or l_HasItem(27)
            return canPoison and itemId ~= 26 and itemId ~= 27 and 
                   not entity:GetNWBool('PoisonedBy' .. LocalPlayer():SteamID64()) and (itemData.food or itemData.water)
        end,
        disabled = function(entity)
            return entity:GetNWBool('PoisonedBy' .. LocalPlayer():SteamID64())
        end,
        disabledText = "Отравлен"
    })

    self.lootablePrompts = {
        folige = {color_white, "Нажмите ", self.themeColor, "USE", color_white, " чтобы открыть"},
        polka = {color_white, "Нажмите ", self.themeColor, "USE", color_white, " чтобы открыть"},
        teapot = {color_white, "Нажмите ", self.themeColor, "USE", color_white, " чтобы открыть"},
        furngug = {color_white, "Нажмите ", self.themeColor, "USE", color_white, " чтобы открыть"},
        medicalshelf = {color_white, "Нажмите ", self.themeColor, "USE", color_white, " чтобы открыть"},
        defaulttext = {color_white, "Нажмите ", self.themeColor, "USE", color_white, " чтобы открыть"}
    }
    
    self:RegisterHooks()
    self:RegisterNetworkHandlers()
    
    local player = LocalPlayer()
    if player.lootSystem and player.lootSystem.useKey then
        self:UpdateKeyBindings(player.lootSystem.useKey)
    end
    
    return self
end

function EntityInteraction:RegisterInteractionType(id, options)
    self.interactionTypes[id] = {
        name = options.name or "Взаимодействие",
        priority = options.priority or 999,
        condition = options.condition or function() return true end,
        disabled = options.disabled or function() return false end,
        disabledText = options.disabledText or "Недоступно",
        callback = options.callback,
        icon = options.icon,
        color = options.color or Color(255, 255, 255)
    }
end

function EntityInteraction:UnregisterInteractionType(id)
    self.interactionTypes[id] = nil
end

function EntityInteraction:GetAvailableInteractions(entity, itemData)
    local available = {}
    
    for id, interactionType in pairs(self.interactionTypes) do
        if interactionType.condition(entity, itemData) then
            table.insert(available, {
                id = id,
                name = interactionType.name,
                priority = interactionType.priority,
                disabled = interactionType.disabled(entity),
                disabledText = interactionType.disabledText,
                callback = interactionType.callback,
                icon = interactionType.icon,
                color = interactionType.color
            })
        end
    end
    
    table.sort(available, function(a, b)
        return a.priority < b.priority
    end)
    
    return available
end

function EntityInteraction:UpdateKeyBindings(useKey)
    for _, prompt in pairs(self.lootablePrompts) do
        if prompt[4] then
            prompt[4] = string.upper(useKey)
        end
    end
end

function EntityInteraction:CalculateBoundingBox(entity)
    if not IsValid(entity) then return nil end
    
    local points = {
        Vector(entity:OBBMaxs().x, entity:OBBMaxs().y, entity:OBBMaxs().z),
        Vector(entity:OBBMaxs().x, entity:OBBMaxs().y, entity:OBBMins().z),
        Vector(entity:OBBMaxs().x, entity:OBBMins().y, entity:OBBMins().z),
        Vector(entity:OBBMaxs().x, entity:OBBMins().y, entity:OBBMaxs().z),
        Vector(entity:OBBMins().x, entity:OBBMins().y, entity:OBBMins().z),
        Vector(entity:OBBMins().x, entity:OBBMins().y, entity:OBBMaxs().z),
        Vector(entity:OBBMins().x, entity:OBBMaxs().y, entity:OBBMins().z),
        Vector(entity:OBBMins().x, entity:OBBMaxs().y, entity:OBBMaxs().z)
    }
    
    local maxX, maxY, minX, minY
    local corners = {}
    local isVisible
    
    for _, point in pairs(points) do
        local screenPos = entity:LocalToWorld(point):ToScreen()
        isVisible = screenPos.visible
        
        if maxX then
            maxX = math.max(maxX, screenPos.x)
            maxY = math.max(maxY, screenPos.y)
            minX = math.min(minX, screenPos.x)
            minY = math.min(minY, screenPos.y)
        else
            maxX, maxY, minX, minY = screenPos.x, screenPos.y, screenPos.x, screenPos.y
        end
        
        table.insert(corners, screenPos)
    end
    
    return {
        maxX = maxX,
        maxY = maxY,
        minX = minX,
        minY = minY,
        corners = corners,
        isVisible = isVisible
    }
end

function EntityInteraction:DrawInteractionBox(entity)
    local player = LocalPlayer()
    local AdvencedUse = entity:GetNWInt("AdvencedUse", false) or (entity.IsTFAWeapon) or entity:GetNWBool("dbt_storage_id", false)
    if not IsValid(entity) or not AdvencedUse then
        self.isInteracting = false
        return false
    end
    
    if entity:GetPos():Distance(player:GetPos()) >= 100 then
        self.isInteracting = false
        return false
    end
    
    if self.lastEntity ~= entity and self.lastInteractionTime < CurTime() then
        self.lastInteractionTime = CurTime() + self.cooldown
        self.currentOption = 1
        self.poisonOption = 1
        self:UpdateServerValues()
    end
    
    local box = self:CalculateBoundingBox(entity)
    if not box then return false end
    
    self:DrawBoundingBox(box)
    self:DrawInteractionMenu(entity, box)
    
    self.isInteracting = true
    self.lastEntity = entity
    return true
end

function EntityInteraction:DrawBoundingBox(box)
    surface.SetDrawColor(self.themeColor.r, self.themeColor.g, self.themeColor.b, 155)
    local xLen, yLen = box.maxX - box.minX, box.maxY - box.minY
    
    surface.DrawLine(box.maxX, box.maxY, box.minX + xLen * 0.7, box.maxY)
    surface.DrawLine(box.minX, box.maxY, box.minX + xLen * 0.3, box.maxY)
    
    surface.DrawLine(box.maxX, box.maxY, box.maxX, box.minY + yLen * 0.75)
    surface.DrawLine(box.maxX, box.minY, box.maxX, box.minY + yLen * 0.25)

    surface.DrawLine(box.minX, box.minY, box.maxX - xLen * 0.7, box.minY)
    surface.DrawLine(box.maxX, box.minY, box.maxX - xLen * 0.3, box.minY)

    surface.DrawLine(box.minX, box.minY, box.minX, box.maxY - yLen * 0.75)
    surface.DrawLine(box.minX, box.maxY, box.minX, box.maxY - yLen * 0.25)
end

function EntityInteraction:DrawInteractionMenu(entity, box)
    local itemId = entity:GetNWInt("id_")
    local itemData = dbt.inventory.items[itemId] or {}

    local interactions = self:GetAvailableInteractions(entity, itemData)
    self.maxOptions = #interactions

    local isPoisonSelected = self.currentOption == 3 and interactions[3] and interactions[3].id == "poison"
    if isPoisonSelected then
        self:DrawPoisonSubmenu(box)
    end
    entity.leinghtbox = entity.leinghtbox or 100
    draw.RoundedBox(0, box.maxX + 3, box.minY + 21 * (self.currentOption - 1), entity.leinghtbox, 20, 
                   Color(self.themeColor.r, self.themeColor.g, self.themeColor.b, 100))
    
    local id = entity:GetNWInt("id_", false)
    local name = id and dbt.inventory.items[id].name or entity.PrintName or entity:GetNWString("dbt_storage_name", "Неизвестно")
    draw.SimpleText(name, "Comfortaa X24", box.minX, box.minY - 23, color_white, TEXT_ALIGN_LEFT)

    for i, interaction in ipairs(interactions) do
        local y = box.minY + 21 * (i - 1)
        local bgColor = interaction.disabled and Color(74, 74, 74, 120) or Color(0, 0, 0, 150)
        
        
        local text = interaction.disabled and interaction.disabledText or interaction.name
        surface.SetFont("Comfortaa X24")
        local textWidth = surface.GetTextSize(text)
        entity.leinghtbox = math.max(entity.leinghtbox, textWidth + 10)
        draw.RoundedBox(0, box.maxX + 3, y, entity.leinghtbox, 20, bgColor)
        draw.DrawText(text, "Comfortaa X24", box.maxX + 7, y - 4, color_white, TEXT_ALIGN_LEFT)
        
    end
end

function EntityInteraction:DrawPoisonSubmenu(box)
    local poisonOptions = {}
    
    if l_HasItem(26) then
        table.insert(poisonOptions, {id = 26, name = "KCN"})
    end
    
    if l_HasItem(27) then
        table.insert(poisonOptions, {id = 27, name = "Метанол"})
    end
    
    self.maxPoisonOptions = #poisonOptions
    
    local highlightY = box.minY + 42 + 21 * (self.poisonOption - 1)
    draw.RoundedBox(0, box.maxX + 106, highlightY, 100, 20, 
                   Color(self.themeColor.r, self.themeColor.g, self.themeColor.b, 100))
    
    for i, option in ipairs(poisonOptions) do
        local y = box.minY + 42 + 21 * (i - 1)
        draw.RoundedBox(0, box.maxX + 106, y, 100, 20, Color(0, 0, 0, 150))
        draw.DrawText(option.name, "Comfortaa X23", box.maxX + 110, y - 4, color_white, TEXT_ALIGN_LEFT)
    end
end

function EntityInteraction:DrawLootablePrompt(entity)
    local player = LocalPlayer()
    
    if not IsValid(entity) then return false end
    if entity:GetPos():Distance(player:GetPos()) > 140 then return false end
    if IsValid(Oprndesc) then return false end
    
    local promptKey = entity:GetClass()
    
    if entity:GetModel() == "models/drp_props/furniture2.mdl" then
        promptKey = "defaulttext"
    end
    
    if not self.lootablePrompts[promptKey] and promptKey ~= "defaulttext" then return false end
    
    if player.lootSystem and player.lootSystem.useKey and
       self.lootablePrompts[promptKey][4] ~= string.upper(player.lootSystem.useKey) then
        self:UpdateKeyBindings(player.lootSystem.useKey)
    end
    
    NotShowCross = true
    surface.DrawMulticolorText(
        self.screenWidth * 0.425,
        self.screenHeight * 0.4855,
        "Comfortaa X30",
        self.lootablePrompts[promptKey] or self.lootablePrompts["defaulttext"],
        1000
    )
    
    return true
end

function EntityInteraction:HandleNavigation(bind, pressed)
    if not self.isInteracting or not pressed then return false end
    
    local interactions = self:GetAvailableInteractions(self.lastEntity, dbt.inventory.items[self.lastEntity:GetNWInt("id_")] or {})
    
    if bind == "invnext" then
        if self.currentOption == 3 and interactions[3] and interactions[3].id == "poison" and self.poisonOption < (self.maxPoisonOptions or 1) then
            self.poisonOption = self.poisonOption + 1
            self:UpdateServerValues("INTERACTIONOOPOISON", self.poisonOption)
            return true
        end
        
        if self.currentOption < self.maxOptions then
            self.currentOption = self.currentOption + 1
            local interactionType = interactions[self.currentOption] and interactions[self.currentOption].id or "unknown"
            self:UpdateServerValues("INTERACTIONOO", interactionType)
            return true
        end
        
        return true
    end
    
    if bind == "invprev" then
        if self.currentOption == 3 and interactions[3] and interactions[3].id == "poison" and self.poisonOption > 1 then
            self.poisonOption = self.poisonOption - 1
            self:UpdateServerValues("INTERACTIONOOPOISON", self.poisonOption)
            return true
        end
        
        if self.currentOption > 1 then
            self.currentOption = self.currentOption - 1
            local interactionType = interactions[self.currentOption] and interactions[self.currentOption].id or "unknown"
            self:UpdateServerValues("INTERACTIONOO", interactionType)
            return true
        end
        
        return true
    end
end

function EntityInteraction:UpdateServerValues(varName, value)
    if varName then
        netstream.Start("dbt/change/nwint", varName, value)
    else
        netstream.Start("dbt/change/nwint", "INTERACTIONOO", "take")
        netstream.Start("dbt/change/nwint", "INTERACTIONOOPOISON", self.poisonOption)
    end
end

function EntityInteraction:RegisterHooks()
    hook.Add("PlayerBindPress", "dbt.EntityInteraction2", function(player, bind, pressed)
        if self.isInteracting then return self:HandleNavigation(bind, pressed) end
    end)
    
    hook.Add("HUDPaint", "dbt.EntityInteractionHUD", function()
        local player = LocalPlayer()
        local trace = util.TraceLine(util.GetPlayerTrace(player))
        
        if self:DrawInteractionBox(trace.Entity) then
            NotShowCross = true
        elseif not self.isInteracting then
            if self:DrawLootablePrompt(trace.Entity) then
                NotShowCross = true
            else
                NotShowCross = false
            end
        end
    end)
end

function EntityInteraction:RegisterNetworkHandlers()
    netstream.Hook("dbt/interactionchange", function()
        self.maxOptions = 2
        self.currentOption = 2
        self.poisonOption = 1
        self:UpdateServerValues()
    end)
    
    netstream.Hook("dbt/poisonuse/anim", function()
        netstream.Start("dbt/change/sq/anim", "llama", true)
    end)
end

function EntityInteraction:AddCustomInteractionType(id, name, priority, condition, callback)
    self:RegisterInteractionType(id, {
        name = name,
        priority = priority,
        condition = condition,
        callback = callback
    })
end

INTERACTION = EntityInteraction:Initialize()

dbt = dbt or {}
dbt.interactions = {
    register = function(id, options)
        INTERACTION:RegisterInteractionType(id, options)
    end,
    
    unregister = function(id)
        INTERACTION:UnregisterInteractionType(id)
    end,
    
    addQuickInteraction = function(id, name, priority, condition, callback)
        INTERACTION:AddCustomInteractionType(id, name, priority, condition, callback)
    end
}

INTERACTIONOO = 1
INTERACTIONOOMAX = 2
INTERACTIONOOPOISON = 1
INTERACTIONOOPOISONMAX = 2