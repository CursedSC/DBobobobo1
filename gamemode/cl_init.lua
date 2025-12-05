include("shared.lua")--
CreateClientConVar("thw_evidice", "icons/1.png", true, false, "")
CreateClientConVar("name_evidice", "icons/1.png", true, false, "")
CreateClientConVar("desc_evidice", "icons/1.png", true, false, "")
CreateClientConVar("name_sign", " ", true, false, "")
CreateClientConVar("text_sign", " ", true, false, "")
CreateClientConVar("showcroshair", 0, true, false, "")
CreateClientConVar("text_clickable", " ", true, false, "")
CreateClientConVar("name_clickable", " ", true, false, "")

RunConsoleCommand("cl_showhints", 0) 

ScreenWidth = ScrW()
ScreenHeight = ScrH()
charactersInGame = {}

hook.Add( 'OnScreenSizeChanged', 'local', function()
 
    ScreenWidth = ScrW()
    ScreenHeight = ScrH()

end )


netstream.Hook("dbt/config/init", function(id)
    config[id].init()
end)

local _folig = {}
_folig[#_folig + 1] = {
  name = "Сыр",
  mdl = "models/props_everything/cheeseswiss.mdl",
  icon = Material("icons/food_cheese.png", "smooth"),
  food = 15,
  time = 5,
  id = 7
}

_folig[#_folig + 1] = {
  name = "Помидор",
  mdl = "models/props_everything/tomato.mdl",
  icon = Material("icons/food_tomato.png", "smooth"),
  food = 10,
  time = 5,
  id = 8
}

_folig[#_folig + 1] = {
  name = "Арбуз",
  mdl = "models/props_everything/watermelonslice.mdl",
  icon = Material("icons/food_watermelon.png", "smooth"),
  food = 20,
  time = 8,
  id = 9
}


_folig[#_folig + 1] = {
    name = "Коктейль",
    mdl = "models/props_everything/cocktail.mdl",
    icon = Material("icons/drink_cocktail.png", "smooth"),
    water = 35,
    time = 4,
    id = 10
}

_folig[#_folig + 1] = {
    name = "Газировка",
    mdl = "models/props_everything/cansoda.mdl",
    icon = Material("icons/drink_energy.png", "smooth"),
    water = 35,
    time = 4,
    id = 11
}

_folig[#_folig + 1] = {
    name = "Вода",
    mdl = "models/props_everything/waterbottle.mdl",
    icon = Material("icons/drink_water.png", "smooth"),
    water = 45,
    time = 5,
    id = 12
}

_folig[#_folig + 1] = {
    name = "Молоко",
    mdl = "models/props_everything/milk.mdl",
    icon = Material("icons/drink_milk.png", "smooth"),
    water = 50,
    time = 6,
    id = 14
}

_folig[#_folig + 1] = {
    name = "Панта",
    mdl = "models/player/dewobedil/danganronpa/monokubs/props/panta.mdl",
    icon = Material("icons/panta.png", "smooth"),
    water = 40,
    time = 5,
    id = 15
}



_polka = {}
_polka[#_polka + 1] = {
    name = "Яблоко",
    mdl = "models/props_everything/applered.mdl",
    icon = Material("icons/food_apple.png", "smooth"),
    food = 15,
    time = 5,
    id = 17
}
_polka[#_polka + 1] = {
    name = "Печенье",
    mdl = "models/props_everything/cookie.mdl",
    icon = Material("icons/food_cookie.png", "smooth"),
    food = 10,
    time = 5,
    id = 18
}
_polka[#_polka + 1] = {
    name = "Кукуруза",
    mdl = "models/props_everything/corn.mdl",
    icon = Material("icons/food_corn.png", "smooth"),
    food = 20,
    time = 6,
    id = 19
}
_polka[#_polka + 1] = {
    name = "Пончик",
    mdl = "models/props_everything/donutsprinkles.mdl",
    icon = Material("icons/food_donut.png", "smooth"),
    food = 15,
    time = 5,
    id = 20
}
_polka[#_polka + 1] = {
    name = "Кофе",
    mdl = "models/props_everything/coffee.mdl",
    icon = Material("icons/drink_coffee2.png", "smooth"),
    water = 50,
    time = 6,
    id = 13
}

_polka[#_polka + 1] = {
    name = "Вино",
    mdl = "models/props_everything/winebottle.mdl",
    icon = Material("icons/drink_bottle.png", "smooth"),
    water = 100,
    time = 25,
    id = 16
}

_furngug = {}
_furngug[#_furngug + 1] = {
    name = "Кусочек пиццы",
    mdl = "models/props_everything/pizzaslice.mdl",
    icon = Material("icons/food_pizza.png", "smooth"),
    food = 40,
    cost = 1,
    time = 8,
    id = 21
}
_furngug[#_furngug + 1] = {
    name = "Бургер",
    mdl = "models/props_everything/hamburger.mdl",
    icon = Material("icons/food_sandwich.png", "smooth"),
    food = 60,
    cost = 2,
    time = 10,
    id = 22
}
_furngug[#_furngug + 1] = {
    name = "Куриная ножка",
    mdl = "models/props_everything/chickendrumstick.mdl",
    icon = Material("icons/food_turkey.png", "smooth"),
    food = 50,
    cost = 2,
    time = 6,
    id = 23
}
_furngug[#_furngug + 1] = {
    name = "Стейк",
    mdl = "models/props_everything/steak.mdl",
    icon = Material("icons/food_steak2.png", "smooth"),
    food = 80,
    cost = 4,
    time = 12,
    id = 24
}
_furngug[#_furngug + 1] = {
    name = "Пирог",
    mdl = "models/props_everything/applepie.mdl",
    icon = Material("icons/food_pie2.png", "smooth"),
    food = 70,
    cost = 3,
    time = 10,
    id = 5
}

_furngug[#_furngug + 1] = {
    name = "Торт",
    mdl = "models/props_everything/cake.mdl",
    icon = Material("icons/food_cake.png", "smooth"),
    food = 85,
    cost = 4,
    time = 15,
    id = 6
}

hook.Add( "PopulateEntities", "AddEntityContent", function( pnlContent, tree, node )
  local Categorised = {}

  -- Add this list into the tormoil
  local SpawnableEntities = list.Get( "SpawnableEntities" )
  if ( SpawnableEntities ) then
    for k, v in pairs( SpawnableEntities ) do

      local Category = v.Category or "Other"
      if ( !isstring( Category ) ) then Category = tostring( Category ) end
      Categorised[ Category ] = Categorised[ Category ] or {}

      v.SpawnName = k
      table.insert( Categorised[ Category ], v )

    end
  end

  --
  -- Add a tree node for each category
  --
  for CategoryName, v in SortedPairs( Categorised ) do

    standrtdbtcat = (CategoryName == "DBT - Entity")
    local node = tree:AddNode( CategoryName, "icon16/bricks.png" )
    if CategoryName == "DBT - Entity" then
      FoodDBTCategory = tree:AddNode( "DBT - Food", "icon16/bricks.png" )
      TrueCatForPos = node
    end

      -- When we click on the node - populate it using this function
    node.DoPopulate = function( self )

      -- If we've already populated it - forget it.
      if ( self.PropPanel ) then return end

      -- Create the container panel
      self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
      self.PropPanel:SetVisible( false )
      self.PropPanel:SetTriggerSpawnlistChange( false )

      for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do

        spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "entity", self.PropPanel, {
          nicename  = ent.PrintName or ent.ClassName,
          spawnname = ent.SpawnName,
          material  = ent.IconOverride or "entities/" .. ent.SpawnName .. ".png",
          admin   = ent.AdminOnly
        } )

      end
      if TrueCatForPos == self then
        local ent = dbt.inventory.items[26]
        local a = spawnmenu.CreateContentIcon( "entity", self.PropPanel, {
          nicename  = ent.name,
          spawnname = "asdasdas",
          material  = "",
          admin   = false
        } )
        a.DoClick = function()
          netstream.Start("dbt/food/spawn", ent.mdl, ent.food, ent.id, ent.water)
        end
        local ent = dbt.inventory.items[27]
        local a = spawnmenu.CreateContentIcon( "entity", self.PropPanel, {
          nicename  = ent.name,
          spawnname = "asdasdas",
          material  = "",
          admin   = false
        } )
        a.DoClick = function()
          netstream.Start("dbt/food/spawn", ent.mdl, ent.food, ent.id, ent.water)
        end
      end




    end

    -- If we click on the node populate it and switch to it.
    node.DoClick = function( self )

      self:DoPopulate()
      pnlContent:SwitchPanel( self.PropPanel )

    end

  end



  -- Select the first node
  local FirstNode = tree:Root():GetChildNode( 0 )
  if ( IsValid( FirstNode ) ) then
    FirstNode:InternalDoClick()
  end


    FoodDBTCategory.DoPopulate = function( self )



      -- Create the container panel
      self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
      self.PropPanel:SetVisible( true )
      self.PropPanel:SetTriggerSpawnlistChange( false )

      for k, ent in SortedPairsByMemberValue( _folig, "PrintName" ) do

       local a = spawnmenu.CreateContentIcon( "entity", self.PropPanel, {
          nicename  = ent.name,
          spawnname = "asdasdas",
          material  = "",
          admin   = false
        } )
       a.DoClick = function()
        netstream.Start("dbt/food/spawn", ent.mdl, ent.food, ent.id, ent.water)
        end

      end
      for k, ent in SortedPairsByMemberValue( _polka, "PrintName" ) do

       local a = spawnmenu.CreateContentIcon( "entity", self.PropPanel, {
          nicename  = ent.name,
          spawnname = "asdasdas",
          material  = "",
          admin   = false
        } )
        a.DoClick = function()
          netstream.Start("dbt/food/spawn", ent.mdl, ent.food, ent.id, ent.water)
        end

      end
      for k, ent in SortedPairsByMemberValue( _furngug, "PrintName" ) do

       local a = spawnmenu.CreateContentIcon( "entity", self.PropPanel, {
          nicename  = ent.name,
          spawnname = "asdasdas",
          material  = "",
          admin   = false
        } )

       a.DoClick = function()
        netstream.Start("dbt/food/spawn", ent.mdl, ent.food, ent.id, ent.water)
        end
      end

    end

    FoodDBTCategory.DoClick = function( self )

      self:DoPopulate()
      pnlContent:SwitchPanel( self.PropPanel )

    end
end)


local INVENTORY_CATEGORY_ORDER = {
  "Еда",
  "Вода",
  "Медицина",
  "Оружие",
  "Патроны",
  "Остальное",
}

local INVENTORY_CATEGORY_ICONS = {
  ["Еда"] = "icon16/cake.png",
  ["Вода"] = "icon16/cup.png",
  ["Медицина"] = "icon16/heart.png",
  ["Оружие"] = "icon16/gun.png",
  ["Патроны"] = "icon16/bullet_black.png",
  ["Остальное"] = "icon16/box.png",
}

if not dbtInventoryFontsCreated then
  surface.CreateFont("DBTInventory_NameLarge", {
    font = "Trebuchet MS",
    size = 18,
    weight = 600,
    antialias = true,
  })

  surface.CreateFont("DBTInventory_NameSmall", {
    font = "Trebuchet MS",
    size = 10,
    weight = 600,
    antialias = true,
  })

  dbtInventoryFontsCreated = true
end

local function DetectInventoryCategory(itemData)
  if itemData.ammo then return "Патроны" end
  if itemData.weapon then return "Оружие" end
  if itemData.medicine then return "Медицина" end
  if itemData.food then return "Еда" end
  if itemData.water then return "Вода" end
  return "Остальное"
end

local function GatherInventoryItems()
  local categorized = {}
  for _, name in ipairs(INVENTORY_CATEGORY_ORDER) do
    categorized[name] = {}
  end

  for id, data in pairs(dbt.inventory.items or {}) do
    if istable(data) and data.mdl and data.mdl ~= "" then
      local category = DetectInventoryCategory(data)
      table.insert(categorized[category], { id = id, data = data })
    end
  end

  return categorized
end

local function CreateInventoryContentPanel()
  local root = vgui.Create("DPanel")
  root:SetPaintBackground(false)

  local tree = root:Add("DTree")
  tree:Dock(LEFT)
  tree:SetWidth(220)
  tree:DockMargin(0, 0, 8, 0)

  local contentScroll = root:Add("DScrollPanel")
  contentScroll:Dock(FILL)

  local iconSize = dbtPaint.WidthSource(100)
  local nameHeight = 22
  local spacing = 6
  local currentGrid
  local activeCategory
  local activeEntries = {}
  local repopulating = false

  local function clearGrid()
    if not IsValid(currentGrid) then return end
    currentGrid:Remove()
    currentGrid = nil
  end

  local function computeColumns()
    local available = contentScroll:GetWide()
    if available <= 0 then
      available = root:GetWide() - tree:GetWide() - 16
    end
    available = math.max(available, iconSize)
    local cols = math.floor((available + spacing) / (iconSize + spacing))
    return math.max(cols, 1)
  end

  local function populateCategory(categoryName, entries, fromResize)
    if repopulating then return end
    repopulating = true

    if not fromResize then
      activeCategory = categoryName
      activeEntries = entries
    end

    clearGrid()

    currentGrid = contentScroll:Add("DGrid")
    currentGrid:Dock(TOP)
    currentGrid:SetColWide(iconSize)
    currentGrid:SetRowHeight(iconSize + nameHeight)

    local columns = computeColumns()
    currentGrid:SetCols(columns)

    for _, entry in ipairs(entries) do
      local itemData = entry.data
      local itemPanel = vgui.Create("DPanel")
      itemPanel:SetSize(iconSize, iconSize + nameHeight)
      itemPanel.Paint = nil

      local icon = vgui.Create("DModelPanel", itemPanel)
      icon:SetSize(iconSize, iconSize)
      icon:SetPos(0, 0)
      icon:SetModel(itemData.mdl)
      icon:SetTooltip(itemData.name or "")
      icon.LayoutEntity = function() return end

      if IsValid(icon.Entity) then
        local mn, mx = icon.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

        icon:SetFOV(45)
        icon:SetCamPos(Vector(size, size, size))
        icon:SetLookAt((mn + mx) * 0.5)
      end

      local button = vgui.Create("DButton", icon)
      button:SetSize(iconSize, iconSize)
      button:SetText("")
      button:SetToolTip(itemData.name or "")
      button.DoClick = function()
        RunConsoleCommand("AddItemn__", entry.id)
      end
      button.DoRightClick = function()
        local menu = DermaMenu()
        menu:AddOption("Копировать", function()
          SetClipboardText(entry.id)
        end)
        menu:Open()
      end
      button.Paint = nil

      local displayName = tostring(itemData.name or "")
      local label = vgui.Create("DPanel", itemPanel)
      label:SetSize(iconSize, nameHeight)
      label:SetPos(0, iconSize)
      label:SetPaintBackground(false)
      label.Paint = function(_, w, _)
        local length = utf8.len(displayName) or string.len(displayName)
        local fontToUse = (length > 10) and "Comfortaa X12" or "Comfortaa X18"
        draw.DrawText(displayName, fontToUse, w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)
      end

      currentGrid:AddItem(itemPanel)
    end

    local colsForHeight = currentGrid:GetCols() or 1
    local rows = math.ceil(#entries / math.max(colsForHeight, 1))
    currentGrid:SetTall(rows * (iconSize + nameHeight + spacing))

    contentScroll:GetCanvas():InvalidateLayout(true)
    contentScroll:InvalidateLayout(true)

    repopulating = false
  end

  contentScroll.OnSizeChanged = function()
    if not activeCategory or repopulating then return end
    timer.Simple(0, function()
      if not IsValid(contentScroll) then return end
      if not activeCategory or not activeEntries then return end
      populateCategory(activeCategory, activeEntries, true)
    end)
  end

  local firstNode

  for _, categoryName in ipairs(INVENTORY_CATEGORY_ORDER) do
    local node = tree:AddNode(categoryName, INVENTORY_CATEGORY_ICONS[categoryName] or "icon16/box.png")

    node.DoClick = function()
      local categorized = GatherInventoryItems()
      populateCategory(categoryName, categorized[categoryName] or {})
    end

    if not firstNode then
      firstNode = node
    end
  end

  if IsValid(firstNode) then
    firstNode:InternalDoClick()
  end

  return root
end

spawnmenu.AddCreationTab("Предметы", CreateInventoryContentPanel, "icon16/application_view_tile.png", 4)
