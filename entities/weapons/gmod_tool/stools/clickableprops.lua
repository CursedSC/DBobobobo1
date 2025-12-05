TOOL.Category      = "DBT Tools"
TOOL.Name          = "Кликабельность пропов"
TOOL.Command       = nil
TOOL.ConfigName    = ""
TOOL.curtime       = CurTime()

-- Client convars are networked automatically and readable on server via self:GetClientInfo
TOOL.ClientConVar = {
	name_clickable = "",
	text_clickable = "",
	view_all       = "0"
}

if SERVER then
	dbt = dbt or {}
	dbt.clickablepropslist = dbt.clickablepropslist or {}

	local function CopyBodygroups(from, to)
		if not (IsValid(from) and IsValid(to)) then return end
		for k = 0, (from:GetNumBodyGroups() or 0) - 1 do
			to:SetBodygroup(k, from:GetBodygroup(k) or 0)
		end
	end

	function SpawnClickableFromEntity(ply, srcEnt, title, text)
		if not IsValid(srcEnt) then return end

		-- Create clickableprop at srcEnt's transform
		local newEnt = ents.Create("clickableprop")
		if not IsValid(newEnt) then return end

		local mdl = srcEnt:GetModel()
		if mdl and mdl ~= "" then newEnt:SetModel(mdl) end
		newEnt:SetPos(srcEnt:GetPos())
		newEnt:SetAngles(srcEnt:GetAngles())

		-- Preserve render/material/skin/bodygroups/colors
		newEnt:SetSkin(srcEnt:GetSkin() or 0)
		newEnt:SetMaterial(srcEnt:GetMaterial() or "")
		newEnt:SetColor(srcEnt:GetColor() or color_white)
		newEnt:SetRenderMode(srcEnt:GetRenderMode() or RENDERMODE_NORMAL)

		newEnt:Spawn()
		newEnt:Activate()

		CopyBodygroups(srcEnt, newEnt)

		-- Preserve physics motion state if possible
		local srcPhys = srcEnt:GetPhysicsObject()
		local newPhys = newEnt:GetPhysicsObject()
		if IsValid(srcPhys) and IsValid(newPhys) then
			if not srcPhys:IsMotionEnabled() then
				newPhys:EnableMotion(false)
			end
			newPhys:Wake()
		end

		-- Auto-assign content (title/text) without netstream
		-- Assuming clickableprop uses same fields as before
		newEnt.texttitle = title or ""
		newEnt.text      = text or ""

		-- Make it permanent via PermaProps if available
		if PermaProps then
			-- Reserve explicit ID so we can delete by ID later
			local max = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;"))
			local nextId = max and (max + 1) or 1

			-- Mark entity as perma-like (some addons expect these)
			newEnt.PermaProps = true
			newEnt.PermaProps_ID = nextId

			local content = PermaProps.PPGetEntTable(newEnt, true)
			if content then
				PermaProps.SQL.Query("INSERT INTO permaprops (id, map, content) VALUES(" ..
					nextId .. ", " .. sql.SQLStr(game.GetMap()) .. ", " .. sql.SQLStr(util.TableToJSON(content)) .. ");")
			end

			-- Cosmetic: small effect on original prop
			PermaProps.SparksEffect(srcEnt)
		end

		-- Track it internally
		dbt.clickablepropslist[newEnt:EntIndex()] = newEnt

		-- Remove original entity
		SafeRemoveEntity(srcEnt)

		return newEnt
	end

	-- Optional: console command to remove all clickable props without netstream
	concommand.Add("dbt_clickableprops_remove_all", function(ply)
		if not IsValid(ply) then return end
		if PermaProps and not PermaProps.HasPermission(ply, "Save") then return end

		for k, v in pairs(dbt.clickablepropslist) do
			if IsValid(v) then
				if PermaProps and v.PermaProps_ID then
					PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = " .. v.PermaProps_ID .. ";")
				end
				v:Remove()
			end
			dbt.clickablepropslist[k] = nil
		end
	end)
end

function TOOL:LeftClick(trace)
	if self.curtime >= CurTime() then return false end
	self.curtime = CurTime() + 0.5

	if CLIENT then return true end

	local ply = self:GetOwner()
	local ent = trace.Entity

	if not IsValid(ent) then if IsValid(ply) then ply:ChatPrint("Это не валидная сущность!") end return false end
	if ent:IsPlayer() then if IsValid(ply) then ply:ChatPrint("Это игрок!") end return false end

	-- If you require PermaProps permission, keep this
	if PermaProps and not PermaProps.HasPermission(ply, "Save") then return false end

	-- Read parameters automatically from client convars (they are networked)
	local title = self:GetClientInfo("name_clickable") or ""
	local text  = self:GetClientInfo("text_clickable") or ""

	-- Spawn clickableprop and replace the original
	local newEnt = SpawnClickableFromEntity(ply, ent, title, text)
	if not IsValid(newEnt) then return false end

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end
	local ent = trace.Entity
	local ply = self:GetOwner()

	if not IsValid(ent) then return false end

	if table.HasValue(dbt.clickablepropslist, ent) then
		dbt.clickablepropslist[ent:EntIndex()] = nil
		if PermaProps and ent.PermaProps_ID then
			PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = " .. ent.PermaProps_ID .. ";")
		end
		ent:Remove()
	end

	return true
end

function TOOL:Think()
end

function TOOL:Reload(trace)
	return false
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "Кликабельность", Description = "Делает пропы кликабельными" })

	local btnRemoveAll = vgui.Create("DButton")
	btnRemoveAll:SetText("Удалить кликабельность у всех пропов")
	btnRemoveAll.DoClick = function()
		RunConsoleCommand("dbt_clickableprops_remove_all")
	end
	panel:AddPanel(btnRemoveAll)

	panel:CheckBox("Видеть все кликабельные пропы", "clickableprops_view_all")

	panel:ControlHelp("Заголовок:")
	panel:TextEntry("", "clickableprops_name_clickable")

	panel:ControlHelp("Основной текст:")
	-- ControlPanel:TextEntry is single-line; create a multi-line entry bound to convar
	local desc = vgui.Create("DTextEntry")
	desc:SetMultiline(true)
	desc:SetTall(200)
	desc:SetUpdateOnType(true)
	-- Bind to our tool convar manually
	local cvarName = "clickableprops_text_clickable"
	desc:SetText(GetConVar(cvarName) and GetConVar(cvarName):GetString() or "")
	function desc:OnTextChanged()
		local cv = GetConVar(cvarName)
		if cv then cv:SetString(self:GetText()) end
	end
	panel:AddPanel(desc)
end

hook.Add("EntityRemoved", "clickablepropsentityremove", function(ent)
	if SERVER and ent and ent.EntIndex then
		dbt = dbt or {}
		if dbt.clickablepropslist then
			dbt.clickablepropslist[ent:EntIndex()] = nil
		end
	end
end)

if CLIENT then

	local calculatePosition = function(ent)
		local entPos = ent:GetPos() + ent:OBBCenter()
		local screentable = entPos:ToScreen()
		local screen_x, screen_y = screentable.x, screentable.y
		LINE_CLICK_X, LINE_CLICK_Y = screen_x, screen_y
		local w, h = ScrW(), ScrH()
		local cw, ch = w * 0.5, h * 0.5

		local isUpRight = (cw < screen_x and ch > screen_y)
		local isUpLeft  = (cw > screen_x and ch > screen_y)
		local isDownRight = (cw < screen_x and ch < screen_y)
		local isDownLeft = (cw > screen_x and ch < screen_y)


		if isUpRight then return cw - (w * 0.3), ch - (h * 0.2), true end
		if isUpLeft then return cw + (w * 0.1), ch - (h * 0.1), false end
		if isDownRight then return cw - (w * 0.3), ch - (h * 0.2), true end
		if isDownLeft then return cw + (w * 0.1), ch - (h * 0.2), false end
	end
	LINE_CLICK_X, LINE_CLICK_Y = 0, 0
	LINE_CLICK_X_TARGET, LINE_CLICK_Y_TARGET = 0, 0
	if IsValid(Oprndesc) then Oprndesc:Close() end
	hook.Add("HUDPaint", "drawSimpleLine", function()
		if !IsValid(Oprndesc) or !IsValid(ClicableProp) then return  end
		local x, y = Oprndesc:GetPos()
		local entPos = ClicableProp:GetPos() + ClicableProp:OBBCenter()
		local screentable = entPos:ToScreen()
		local screen_x, screen_y = screentable.x, screentable.y
		Oprndesc.headerh = Oprndesc.headerh or 1
		y = y + 1
		if Oprndesc.bf then 
			x = x + Oprndesc.frameW
		end

		if Oprndesc.isAnimating then 
			LINE_CLICK_X = Lerp(FrameTime() * 10, LINE_CLICK_X, LINE_CLICK_X_TARGET+ (Oprndesc.bf and Oprndesc.frameW or 0)) 
			LINE_CLICK_Y = Lerp(FrameTime() * 10, LINE_CLICK_Y, LINE_CLICK_Y_TARGET)
		else 
			LINE_CLICK_X = x
			LINE_CLICK_Y = y
		end
		
		surface.SetDrawColor( 255, 255, 255)
		surface.DrawLine( LINE_CLICK_X, LINE_CLICK_Y, screen_x, screen_y )
	end)
	local MatCLose = Material("dbt/d542c202ca4c957c.png")
	netstream.Hook("dbt/tools/clickableprops", function(ent, title, maintext)

 

		
		local frameW, frameH, animTime, animDelay, animEase = ScrW() * 0.2 - 13, ScrH() * 0.5, 1.8, 0, .1
	    Oprndesc = vgui.Create("DFrame")
		ClicableProp = ent
	   	Oprndesc:SetTitle("")
		Oprndesc.frameW = frameW
	   	Oprndesc:MakePopup()
	    Oprndesc:SetSize(frameW, 0)
	    Oprndesc:ShowCloseButton(false)
		Oprndesc:SetDraggable(false)
	    Oprndesc:SetPos(ScrW() / 2 - ScrW() * 0.3 / 2, ScrH() / 2 - ScrH() * 0.6 / 2)

		local x, y, bf = calculatePosition(ent)
		LINE_CLICK_X_TARGET, LINE_CLICK_Y_TARGET = x, y
		Oprndesc:SetPos(x, y)
		Oprndesc.bf = bf
	    Oprndesc.isAnimating = true
	    timer.Simple(0.3, function()
			Oprndesc:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
	        	Oprndesc.isAnimating = false
				Oprndesc:SetDraggable(true)
	    	end)
		end) 
	    Oprndesc.Paint = function(self,w,h)

	        surface.SetDrawColor(0, 0, 0, 147)
	        surface.DrawRect(0, 0, w,h)

	        surface.SetDrawColor(106, 8, 122, 122)
	        surface.DrawRect(0, 0, w, h * 0.06)
			self.headerh = h * 0.06
	       	draw.DrawText(title or " ", "Comfortaa X30", 10, 0, Color(255,255,255,255), TEXT_ALIGN_LEFT)

			surface.DrawMulticolorText(5, frameH*0.06, "Comfortaa X30", {color_white, maintext or " "}, frameW)
	    end

		local DButton = Oprndesc:Add( "DButton" )
	    DButton:SetPos(frameW - (ScrW() * 0.017 + 3), 0)
	    DButton:SetSize(ScrW() * 0.017, ScrW() * 0.017)
	    DButton:SetText("")
	    DButton.Paint = function(self, w, h)
	        dbtPaint.DrawRectR(MatCLose, w / 2, h / 2, w * 0.5, h * 0.5, 0)
	    end
	    DButton.DoClick = function(self)
	        self:GetParent():Close()
	    end
	end)
end

