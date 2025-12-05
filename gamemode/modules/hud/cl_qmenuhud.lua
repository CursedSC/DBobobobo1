--local HealMat = Material("menu/stats/heal.png")
--local HungerMat = Material("menu/stats/hunger.png")
--local SleepMat = Material("menu/stats/sleep.png")
--local ArmorMat = Material("menu/stats/armor.png")
--local WaterMat = Material("menu/stats/water.png")
--local MenuBg = Material("menu/bg.png")
--local bg = Material("qmenu/background.png")
--local MenuShadow = Material("menu/shadow.png")
--local MenuFrame = Material("menu/frame_a.png")
--local MenuFrame_c = Material("menu/frmae_c.png")
--local MenuFrame_d = Material("menu/frame_d.png")
--local MenuFrame_b = Material("menu/frame_b.png")
--local Inventory_bg = Material("dbt/qmenu_inv/dbt_inventory.png")
local l_SetDrawColor = surface.SetDrawColor
local l_SetMaterial = surface.SetMaterial
local l_SetFont = surface.SetFont
local l_DrawTexturedRect = surface.DrawTexturedRect
local l_DrawRect = surface.DrawRect
local l_GetTextSize = surface.GetTextSize
local l_DrawText = draw.DrawText
local l_NoTexture = draw.NoTexture

local linefornamemat = Material("dbt/qmenu/qmenu_underline_name.png")
local characterstatustitle = Material("dbt/qmenu/qmenu_stats.png", "smooth")
--local qmenubg = Material("dbt/qmenu/qmenubg.png", "smooth")
--local stats = Material("dbt/qmenu/qmenuicons.png", "smooth")
local backgroundqmenu = Material("dbt/qmenu/qmenu_bg.png", "smooth")
local qmenufood = Material("dbt/qmenu/qmenu_food.png", "smooth")
local qmenusleep = Material("dbt/qmenu/qmenu_sleep.png", "smooth")
local qmenuwater = Material("dbt/qmenu/qmenu_water.png", "smooth")
local qmenuhp = Material("dbt/qmenu/qmenu_hp.png", "smooth")
local qmenushield = Material("dbt/qmenu/qmenu_shield.png", "smooth")

local linefornamematw, linefornamemath = linefornamemat:Width(), linefornamemat:Height()
local characterstatustitlew, characterstatustitleh = characterstatustitle:Width(), characterstatustitle:Height()
local iconsqmenuw, iconsqmenuh = qmenufood:Width(), qmenufood:Height()
local iconDrawW, iconDrawH = iconsqmenuw * 0.09, iconsqmenuh * 0.09

q_alpha = 0
q_aplha_plates = 0
q_aplha_platesd = 0
CurrentQAlphaBlur = 0

local circles = include("dbt/gamemode/lib/demit/cl_circles.lua")
local characterArtCache = {}
local statCircles = {}

local circleRadius = 50
local circleOutlineWidth = 9
local circleLayout = {
	health = {x = 0.9637, y = 0.28},
	water = {x = 0.9637, y = 0.42, armorShift = true},
	food = {x = 0.9637, y = 0.56, armorShift = true},
	sleep = {x = 0.9637, y = 0.7, armorShift = true},
	armor = {x = 0.9637, y = 0.42},
}

local circleOrder = {"health", "water", "food", "sleep"}

local iconLayout = {
	{material = qmenuhp, x = 0.952, y = 0.259},
	{material = qmenuwater, x = 0.952, y = 0.399, armorShift = true},
	{material = qmenufood, x = 0.952, y = 0.539, armorShift = true},
	{material = qmenusleep, x = 0.952, y = 0.679, armorShift = true},
}

local armorIcon = {material = qmenushield, x = 0.952, y = 0.399}

local colorWhite = Color(255, 255, 255)
local colorWhiteSoft = Color(255, 255, 255)
local colorBlackOverlay = Color(0, 0, 0)
local colorBlackFill = Color(0, 0, 0)
local colorStat = Color(117, 30, 132)
local colorArmor = Color(130, 130, 130)
local colorArt = Color(255, 255, 255)

local textSegments = {colorWhite, ""}
local woundSegments = {colorWhite, ""}

local lastScrW, lastScrH

local drawRectR = dbtPaint.DrawRectR
local widthSource = dbtPaint.WidthSource
local heightSource = dbtPaint.HightSource

local function ensureCircles(scrw, scrh)
	if lastScrW == scrw and lastScrH == scrh then return end

	lastScrW, lastScrH = scrw, scrh

	for id, cfg in pairs(circleLayout) do
		local baseX = scrw * cfg.x
		local baseY = scrh * cfg.y
		local circlePair = statCircles[id]

		if circlePair then
			circlePair.outline:SetPos(baseX, baseY)
			circlePair.fill:SetPos(baseX, baseY)
		else
			circlePair = {
				outline = circles.New(CIRCLE_OUTLINED, circleRadius, baseX, baseY, circleOutlineWidth),
				fill = circles.New(CIRCLE_FILLED, circleRadius, baseX, baseY),
			}
			circlePair.outline:SetRotation(270)
			statCircles[id] = circlePair
		end

		circlePair.baseX = baseX
		circlePair.baseY = baseY
	end
end

local function saturate(value)
	if value <= 0 then return 0 end
	if value >= 1 then return 1 end
	return value
end

local statValueFuncs = {
	health = function(ply)
		local maxHealth = ply:GetMaxHealth()
		if maxHealth <= 0 then return 0 end
		return saturate(ply:Health() / maxHealth)
	end,
	water = function(ply)
		return saturate(ply:GetNWInt("water", 0) * 0.01)
	end,
	food = function(ply)
		return saturate(ply:GetNWInt("hunger", 0) * 0.01)
	end,
	sleep = function(ply)
		return saturate(ply:GetNWInt("sleep", 0) * 0.01)
	end,
}

hook.Add("HUDPaint", "dbt/hud/inventory", function()
	if q_alpha < 1 or IsClassTrial() then return end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local persId = ply:Pers()
	if not persId then return end

	local characters = dbt.chr
	local char_tbl = characters and characters[persId]
	if not char_tbl then return end

	local scrw = ScrW()
	local scrh = ScrH()

	ensureCircles(scrw, scrh)

	local qAlphaFull = q_alpha > 255 and 255 or q_alpha
	local qAlphaOverlay = qAlphaFull > 75 and 75 or qAlphaFull
	local qAlphaFill = qAlphaFull > 125 and 125 or qAlphaFull
	local qAlphaSoft = qAlphaFull > 190 and 190 or qAlphaFull
	local qAlphaArt = qAlphaFull > 15 and 15 or qAlphaFull

	colorWhite.a = qAlphaFull
	colorWhiteSoft.a = qAlphaSoft
	colorBlackOverlay.a = qAlphaOverlay
	colorBlackFill.a = qAlphaFill
	colorStat.a = qAlphaFull
	colorArmor.a = qAlphaFull
	colorArt.a = qAlphaArt

	local hasArmor = ply:Armor() > 0
	local armorOffset = hasArmor and scrh * 0.14 or 0

	for _, id in ipairs(circleOrder) do
		local cfg = circleLayout[id]
		local pair = statCircles[id]
		if pair then
			local targetY = pair.baseY + (cfg.armorShift and armorOffset or 0)
			pair.outline:SetY(targetY)
			pair.fill:SetY(targetY)
		end
	end

	local armorPair = statCircles.armor
	if armorPair then
		armorPair.outline:SetY(armorPair.baseY)
		armorPair.fill:SetY(armorPair.baseY)
	end

	BlurScreen(24 * (qAlphaFull / 255))

	l_SetDrawColor(colorBlackOverlay)
	l_DrawRect(0, 0, scrw, scrh)

	l_SetDrawColor(colorWhite)
	l_SetMaterial(backgroundqmenu)
	l_DrawTexturedRect(0, 0, scrw, scrh)

	l_SetFont("Comfortaa X68")
	local rightPadding = scrw * 0.015
	local charName = char_tbl.name or ""
	textSegments[1] = colorWhite
	textSegments[2] = charName
	local nameWidth = l_GetTextSize(charName)
	surface.DrawMulticolorText(scrw - nameWidth - rightPadding, -5, "Comfortaa X68", textSegments, scrw)

	local scrhstatus = scrh * 0.02
	local wounds = woundstbl
	if wounds then
		l_SetFont("Comfortaa X37")
		for woundType, entries in pairs(wounds) do
			for _, entry in pairs(entries) do
				local woundName = entry and entry[1] or ""
				woundSegments[1] = colorWhite
				woundSegments[2] = "• " .. woundName .. ": " .. woundType
				surface.DrawMulticolorText(scrw * 0.039, scrhstatus, "Comfortaa X37", woundSegments, scrw)
				scrhstatus = scrhstatus + scrh * 0.035
			end
		end
	end

	l_SetFont("Comfortaa X35")
	local ability = char_tbl.absl or ""
	textSegments[2] = ability
	local abilityWidth = l_GetTextSize(ability)
	surface.DrawMulticolorText(scrw - abilityWidth - rightPadding, scrh * 0.08, "Comfortaa X35", textSegments, scrw)

	l_SetDrawColor(colorWhiteSoft)
	l_SetMaterial(linefornamemat)
	l_DrawTexturedRect(scrw * 0.76, scrh * 0.06, linefornamematw, linefornamemath)

	l_SetDrawColor(colorBlackFill)
	l_NoTexture()
	for _, id in ipairs(circleOrder) do
		local pair = statCircles[id]
		if pair then
			pair.fill()
		end
	end
	if hasArmor and armorPair then
		armorPair.fill()
	end

	local season = char_tbl.season
	local charId = char_tbl.char
	local art
	if season and charId then
		local artKey = tostring(season) .. ":" .. tostring(charId)
		art = characterArtCache[artKey]
		if not art then
			art = Material("dbt/characters" .. season .. "/char" .. charId .. "/char_art.png", "smooth")
			characterArtCache[artKey] = art
		end
	end

	if art then
		local xCustom = (persId == "Кёко Киригири") and widthSource(500) or widthSource(300)
		drawRectR(art, xCustom, scrh * 0.6, widthSource(975) * 1.3, heightSource(989) * 1.3, 0, colorArt)
	end

	l_SetDrawColor(colorWhiteSoft)
	l_SetMaterial(characterstatustitle)
	l_DrawTexturedRect(scrw * 0.007, 5, characterstatustitlew * 0.52, characterstatustitleh * 0.52)

	l_SetDrawColor(colorWhite)
	for _, icon in ipairs(iconLayout) do
		local iconY = scrh * icon.y + (icon.armorShift and armorOffset or 0)
		l_SetMaterial(icon.material)
		l_DrawTexturedRect(scrw * icon.x, iconY, iconDrawW, iconDrawH)
	end
	if hasArmor then
		l_SetMaterial(armorIcon.material)
		l_DrawTexturedRect(scrw * armorIcon.x, scrh * armorIcon.y, iconDrawW, iconDrawH)
	end

	l_SetDrawColor(colorStat)
	l_NoTexture()
	for _, id in ipairs(circleOrder) do
		local pair = statCircles[id]
		local valueFunc = statValueFuncs[id]
		if pair and valueFunc then
			pair.outline:SetEndAngle(valueFunc(ply) * 360)
			pair.outline()
		end
	end

	if hasArmor and armorPair then
		local maxArmor = ply:GetMaxArmor()
		local armorFraction = (maxArmor and maxArmor > 0) and saturate(ply:Armor() / maxArmor) or 0
		l_SetDrawColor(colorArmor)
		l_NoTexture()
		armorPair.outline:SetEndAngle(armorFraction * 360)
		armorPair.outline()
	end

	local inventoryInfo = dbt.inventory.info
	local monopad = inventoryInfo and inventoryInfo.monopad
	if monopad and monopad.id then
		local totalSeconds = GetGlobalInt("Time", 0)
		local minutes = math.floor(totalSeconds / 60)
		local hours = math.floor(totalSeconds / 3600)
		local timeText = string.format("%02d:%02d", hours % 24, minutes % 60)
		l_DrawText(timeText, "Comfortaa X70", scrw * 0.01, scrh * 0.93, colorWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	end
end)
