-- LOTM Brewing Altar - Server
-- Алтарь зельеварения с механикой размещения ингредиентов в кругах

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/breenglobe.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(200)
    end
    
    -- Слоты для ингредиентов
    -- Формат: {[slotIndex] = {id = ingredientId, entity = itemEntity}}
    self.IngredientSlots = {}
    self.CurrentRecipe = nil
    self.BrewingInProgress = false
    
    -- Синхронизируем слоты
    self:SetNWInt("LOTM_SlotCount", 0)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if self.BrewingInProgress then
        activator:ChatPrint("[LOTM] Алтарь занят созданием зелья...")
        return
    end
    
    -- Открываем UI у игрока
    net.Start("LOTM.BrewingAltar.OpenUI")
    net.WriteEntity(self)
    net.WriteTable(self:GetSlotsData())
    net.WriteInt(activator:GetNWInt("LOTM_Pathway", 0), 8)
    net.WriteInt(activator:GetNWInt("LOTM_Sequence", 9), 8)
    net.Send(activator)
end

-- Получить данные слотов для синхронизации
function ENT:GetSlotsData()
    local data = {}
    for slotIndex, slotData in pairs(self.IngredientSlots) do
        data[slotIndex] = {
            id = slotData.id,
            name = slotData.name,
            rarity = slotData.rarity,
        }
    end
    return data
end

-- Добавить ингредиент в слот
function ENT:AddIngredientToSlot(ply, ingredientId, slotIndex)
    if not slotIndex or slotIndex < 1 or slotIndex > self.MAX_INGREDIENT_SLOTS then
        return false, "Неверный слот"
    end
    
    if self.IngredientSlots[slotIndex] then
        return false, "Слот уже занят"
    end
    
    -- Получаем данные ингредиента
    local ingData = nil
    if LOTM and LOTM.Ingredients and LOTM.Ingredients.Get then
        ingData = LOTM.Ingredients.Get(ingredientId)
    end
    
    if not ingData then
        return false, "Неизвестный ингредиент"
    end
    
    -- Проверяем наличие ингредиента у игрока в инвентаре
    local foundItem = nil
    local foundIndex = nil
    
    if ply.items then
        for k, v in pairs(ply.items) do
            local itemData = dbt.inventory.items[v.id]
            if itemData and itemData.ingredient and itemData.ingredientId == ingredientId then
                foundItem = v
                foundIndex = k
                break
            end
        end
    end
    
    if not foundItem then
        return false, "У вас нет этого ингредиента"
    end
    
    -- Забираем ингредиент из инвентаря
    if dbt.inventory.removeitem then
        dbt.inventory.removeitem(ply, foundIndex)
    end
    
    -- Добавляем в слот
    self.IngredientSlots[slotIndex] = {
        id = ingredientId,
        name = ingData.name,
        rarity = ingData.rarity or 1,
        addedBy = ply:SteamID64(),
    }
    
    -- Создаём визуальный entity ингредиента в слоте
    self:SpawnSlotVisual(slotIndex, ingData)
    
    -- Синхронизация
    self:SyncSlots()
    
    ply:EmitSound("items/ammopickup.wav")
    
    return true
end

-- Создать визуальный entity ингредиента
function ENT:SpawnSlotVisual(slotIndex, ingData)
    local pos = self:GetSlotWorldPos(slotIndex)
    
    -- Создаём prop для визуализации
    local visual = ents.Create("prop_physics")
    if not IsValid(visual) then return end
    
    visual:SetModel(ingData.model or "models/props_junk/garbage_takeoutcarton001a.mdl")
    visual:SetPos(pos + Vector(0, 0, 10))
    visual:SetAngles(Angle(0, math.random(0, 360), 0))
    visual:Spawn()
    visual:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    
    local phys = visual:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    
    -- Сохраняем ссылку
    if self.IngredientSlots[slotIndex] then
        self.IngredientSlots[slotIndex].visual = visual
    end
end

-- Удалить ингредиент из слота
function ENT:RemoveIngredientFromSlot(ply, slotIndex)
    local slot = self.IngredientSlots[slotIndex]
    if not slot then return false, "Слот пуст" end
    
    -- Возвращаем ингредиент игроку
    local ingData = LOTM and LOTM.Ingredients and LOTM.Ingredients.Get(slot.id)
    if ingData then
        -- Находим ID предмета в инвентаре
        for itemId, itemData in pairs(dbt.inventory.items or {}) do
            if itemData.ingredient and itemData.ingredientId == slot.id then
                if dbt.inventory.additem then
                    dbt.inventory.additem(ply, itemId, {})
                end
                break
            end
        end
    end
    
    -- Удаляем визуал
    if IsValid(slot.visual) then
        slot.visual:Remove()
    end
    
    self.IngredientSlots[slotIndex] = nil
    self:SyncSlots()
    
    ply:EmitSound("items/ammopickup.wav")
    
    return true
end

-- Очистить алтарь
function ENT:ClearAltar(ply)
    for i = 1, self.MAX_INGREDIENT_SLOTS do
        if self.IngredientSlots[i] then
            self:RemoveIngredientFromSlot(ply, i)
        end
    end
end

-- Синхронизация слотов
function ENT:SyncSlots()
    local count = 0
    for _ in pairs(self.IngredientSlots) do count = count + 1 end
    self:SetNWInt("LOTM_SlotCount", count)
    
    net.Start("LOTM.BrewingAltar.SyncSlots")
    net.WriteEntity(self)
    net.WriteTable(self:GetSlotsData())
    net.Broadcast()
end

-- Получить список ингредиентов
function ENT:GetIngredientList()
    local list = {}
    for slotIndex, slotData in pairs(self.IngredientSlots) do
        table.insert(list, slotData.id)
    end
    table.sort(list)
    return list
end

-- Поиск подходящего рецепта
function ENT:FindMatchingRecipe()
    if not LOTM or not LOTM.Recipes then return nil end
    
    local ingredientIds = self:GetIngredientList()
    if #ingredientIds == 0 then return nil end
    
    for recipeId, recipe in pairs(LOTM.Recipes) do
        if not recipe.ingredients then continue end
        
        local recipeIngredients = table.Copy(recipe.ingredients)
        table.sort(recipeIngredients)
        
        if #ingredientIds == #recipeIngredients then
            local match = true
            for i, ing in ipairs(ingredientIds) do
                if ing ~= recipeIngredients[i] then
                    match = false
                    break
                end
            end
            
            if match then
                return recipe
            end
        end
    end
    
    return nil
end

-- Проверка возможности выпить зелье
function ENT:CanPlayerDrinkPotion(ply, recipe)
    local playerSeq = ply:GetNWInt("LOTM_Sequence", 9)
    local playerPathway = ply:GetNWInt("LOTM_Pathway", 0)
    
    -- Проверка пути
    if recipe.pathway then
        -- Первое зелье - устанавливает путь
        if playerPathway == 0 then
            -- OK, можно выпить первое зелье любого пути
        elseif recipe.pathway ~= playerPathway then
            return false, "Это зелье другого пути! Ваш путь: " .. playerPathway .. ", зелье: " .. recipe.pathway
        end
    end
    
    -- Проверка последовательности
    if recipe.sequence then
        local seqDiff = playerSeq - recipe.sequence
        
        -- Нельзя пить зелье прошлой последовательности (понижать себя)
        if seqDiff < 0 then
            return false, "Это зелье прошлой последовательности (Seq " .. recipe.sequence .. "). Вы уже на Seq " .. playerSeq
        end
        
        -- Нельзя пропустить более 1 последовательности
        if seqDiff > 1 then
            return false, "Слишком высокая последовательность! Вы на Seq " .. playerSeq .. ", а зелье Seq " .. recipe.sequence .. ". Пропуск более 1 последовательности невозможен."
        end
        
        -- Нельзя пить зелье своей же последовательности если уже выпил
        if seqDiff == 0 and playerPathway ~= 0 then
            -- Проверяем, переварилось ли предыдущее зелье
            local digestionProgress = ply:GetNWFloat("LOTM_Digestion", 0)
            if digestionProgress < 1.0 then
                return false, "Вы ещё не переварили текущее зелье! Прогресс: " .. math.floor(digestionProgress * 100) .. "%"
            end
        end
    end
    
    return true
end

-- Попытка создать зелье
function ENT:AttemptBrew(ply)
    if self.BrewingInProgress then
        return false, "Алтарь занят"
    end
    
    local ingredientCount = 0
    for _ in pairs(self.IngredientSlots) do ingredientCount = ingredientCount + 1 end
    
    if ingredientCount == 0 then
        return false, "Добавьте ингредиенты в круги вокруг алтаря"
    end
    
    -- Проверяем рецепты
    local recipe = self:FindMatchingRecipe()
    if not recipe then
        return false, "Рецепт не найден. Попробуйте другую комбинацию ингредиентов."
    end
    
    -- Проверяем может ли игрок выпить
    local canDrink, reason = self:CanPlayerDrinkPotion(ply, recipe)
    if not canDrink then
        return false, reason
    end
    
    -- Начинаем процесс варки
    self.BrewingInProgress = true
    self.CurrentRecipe = recipe
    
    -- Эффект варки
    self:EmitSound("ambient/fire/mtov_flame2.wav")
    
    -- Создаём зелье через 3 секунды
    timer.Simple(3, function()
        if not IsValid(self) then return end
        if not IsValid(ply) then
            self.BrewingInProgress = false
            return
        end
        
        self:CompleteBrewing(ply, recipe)
    end)
    
    -- Уведомляем клиента о начале варки
    net.Start("LOTM.BrewingAltar.BrewingStarted")
    net.WriteEntity(self)
    net.WriteFloat(3) -- Длительность
    net.Send(ply)
    
    return true, "Алтарь начал создание зелья..."
end

-- Завершение создания зелья
function ENT:CompleteBrewing(ply, recipe)
    self.BrewingInProgress = false
    
    -- Удаляем визуалы ингредиентов
    for slotIndex, slotData in pairs(self.IngredientSlots) do
        if IsValid(slotData.visual) then
            slotData.visual:Remove()
        end
    end
    
    -- Очищаем слоты
    self.IngredientSlots = {}
    self:SyncSlots()
    
    -- Устанавливаем путь если первое зелье
    local currentPathway = ply:GetNWInt("LOTM_Pathway", 0)
    if currentPathway == 0 and recipe.pathway then
        ply:SetNWInt("LOTM_Pathway", recipe.pathway)
    end
    
    -- Устанавливаем последовательность
    local oldSeq = ply:GetNWInt("LOTM_Sequence", 9)
    if recipe.sequence then
        ply:SetNWInt("LOTM_Sequence", recipe.sequence)
    end
    
    -- Устанавливаем прогресс переваривания
    ply:SetNWFloat("LOTM_Digestion", 0)
    
    -- Даём способности
    if recipe.result and recipe.result.abilities then
        -- Очищаем старые слоты
        for i = 1, (LOTM.Abilities and LOTM.Abilities.MAX_SLOTS or 7) do
            ply:SetNWString("LOTM_AbilitySlot_" .. i, "")
        end
        
        -- Назначаем новые способности
        local slot = 1
        for _, abilityId in ipairs(recipe.result.abilities) do
            if LOTM and LOTM.Abilities and LOTM.Abilities.SetSlot then
                LOTM.Abilities.SetSlot(ply, slot, abilityId)
            end
            ply:SetNWString("LOTM_AbilitySlot_" .. slot, abilityId)
            slot = slot + 1
        end
    end
    
    -- Применяем статы
    if recipe.result and recipe.result.stats then
        for stat, value in pairs(recipe.result.stats) do
            local current = ply:GetNWInt("LOTM_Stat_" .. stat, 0)
            ply:SetNWInt("LOTM_Stat_" .. stat, current + value)
        end
    end
    
    -- Сохраняем в БД
    if LOTM and LOTM.Database and LOTM.Database.SavePlayerData then
        local data = LOTM.Database.GetPlayerData(ply) or {}
        data.pathway = ply:GetNWInt("LOTM_Pathway", 0)
        data.sequence = ply:GetNWInt("LOTM_Sequence", 9)
        data.abilities = recipe.result and recipe.result.abilities or {}
        LOTM.Database.SavePlayerData(ply, data)
    end
    
    -- Эффекты
    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos() + Vector(0, 0, 50))
    util.Effect("cball_explode", effectData)
    
    self:EmitSound("ambient/energy/whiteflash.wav")
    
    -- Уведомление
    local pathwayName = ""
    if LOTM and LOTM.PathwaysList and recipe.pathway then
        local pw = LOTM.PathwaysList[recipe.pathway]
        pathwayName = pw and pw.name or ""
    end
    
    ply:ChatPrint("")
    ply:ChatPrint("══════════════════════════════════")
    ply:ChatPrint("[LOTM] ЗЕЛЬЕ СОЗДАНО!")
    ply:ChatPrint("Название: " .. recipe.name)
    ply:ChatPrint("Последовательность: " .. (recipe.sequence or "?"))
    if pathwayName ~= "" then
        ply:ChatPrint("Путь: " .. pathwayName)
    end
    ply:ChatPrint("══════════════════════════════════")
    ply:ChatPrint("")
    
    -- Хук
    hook.Run("LOTM_PotionBrewed", ply, recipe, oldSeq, recipe.sequence)
    
    -- Уведомляем клиента
    net.Start("LOTM.BrewingAltar.BrewingComplete")
    net.WriteEntity(self)
    net.WriteString(recipe.name)
    net.WriteInt(recipe.sequence or 9, 8)
    net.WriteString(pathwayName)
    net.Send(ply)
end

-- Обработка размещения item entity рядом с алтарём
hook.Add("PlayerDroppedItem", "LOTM.BrewingAltar.CheckDrop", function(ply, itemEnt)
    if not IsValid(itemEnt) then return end
    
    -- Ищем ближайший алтарь
    local nearestAltar = nil
    local nearestDist = math.huge
    
    for _, ent in ipairs(ents.FindByClass("lotm_brewing_altar")) do
        local dist = ent:GetPos():Distance(itemEnt:GetPos())
        if dist < 200 and dist < nearestDist then
            nearestDist = dist
            nearestAltar = ent
        end
    end
    
    if not nearestAltar then return end
    
    -- Проверяем, это ингредиент?
    local itemId = itemEnt.id or itemEnt:GetNWInt("id_")
    local itemData = dbt.inventory.items[itemId]
    
    if not itemData or not itemData.ingredient then return end
    
    -- Проверяем ближайший слот
    local slotIndex, slotDist = nearestAltar:GetNearestSlot(itemEnt:GetPos())
    
    if slotIndex and not nearestAltar.IngredientSlots[slotIndex] then
        -- Добавляем ингредиент в слот
        local ingData = LOTM and LOTM.Ingredients and LOTM.Ingredients.Get(itemData.ingredientId)
        if ingData then
            nearestAltar.IngredientSlots[slotIndex] = {
                id = itemData.ingredientId,
                name = ingData.name,
                rarity = ingData.rarity or 1,
                addedBy = ply:SteamID64(),
                visual = itemEnt, -- Используем сам предмет как визуал
            }
            
            -- Фиксируем предмет на месте
            local slotPos = nearestAltar:GetSlotWorldPos(slotIndex)
            itemEnt:SetPos(slotPos + Vector(0, 0, 10))
            local phys = itemEnt:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end
            
            nearestAltar:SyncSlots()
            ply:EmitSound("items/ammopickup.wav")
            ply:ChatPrint("[LOTM] Ингредиент добавлен в слот " .. slotIndex)
        end
    end
end)

-- Сетевые сообщения
util.AddNetworkString("LOTM.BrewingAltar.OpenUI")
util.AddNetworkString("LOTM.BrewingAltar.SyncSlots")
util.AddNetworkString("LOTM.BrewingAltar.AddIngredient")
util.AddNetworkString("LOTM.BrewingAltar.RemoveIngredient")
util.AddNetworkString("LOTM.BrewingAltar.Brew")
util.AddNetworkString("LOTM.BrewingAltar.Clear")
util.AddNetworkString("LOTM.BrewingAltar.BrewingStarted")
util.AddNetworkString("LOTM.BrewingAltar.BrewingComplete")

net.Receive("LOTM.BrewingAltar.AddIngredient", function(len, ply)
    local altar = net.ReadEntity()
    local ingredientId = net.ReadString()
    local slotIndex = net.ReadUInt(8)
    
    if not IsValid(altar) or altar:GetClass() ~= "lotm_brewing_altar" then return end
    if altar:GetPos():Distance(ply:GetPos()) > altar.INTERACTION_DISTANCE then return end
    
    local success, reason = altar:AddIngredientToSlot(ply, ingredientId, slotIndex)
    if not success then
        ply:ChatPrint("[LOTM] " .. reason)
    end
end)

net.Receive("LOTM.BrewingAltar.RemoveIngredient", function(len, ply)
    local altar = net.ReadEntity()
    local slotIndex = net.ReadUInt(8)
    
    if not IsValid(altar) or altar:GetClass() ~= "lotm_brewing_altar" then return end
    if altar:GetPos():Distance(ply:GetPos()) > altar.INTERACTION_DISTANCE then return end
    
    altar:RemoveIngredientFromSlot(ply, slotIndex)
end)

net.Receive("LOTM.BrewingAltar.Brew", function(len, ply)
    local altar = net.ReadEntity()
    
    if not IsValid(altar) or altar:GetClass() ~= "lotm_brewing_altar" then return end
    if altar:GetPos():Distance(ply:GetPos()) > altar.INTERACTION_DISTANCE then return end
    
    local success, message = altar:AttemptBrew(ply)
    if message then
        ply:ChatPrint("[LOTM] " .. message)
    end
end)

net.Receive("LOTM.BrewingAltar.Clear", function(len, ply)
    local altar = net.ReadEntity()
    
    if not IsValid(altar) or altar:GetClass() ~= "lotm_brewing_altar" then return end
    if altar:GetPos():Distance(ply:GetPos()) > altar.INTERACTION_DISTANCE then return end
    
    altar:ClearAltar(ply)
end)

-- Удаление визуалов при удалении алтаря
function ENT:OnRemove()
    for slotIndex, slotData in pairs(self.IngredientSlots or {}) do
        if IsValid(slotData.visual) then
            slotData.visual:Remove()
        end
    end
end
