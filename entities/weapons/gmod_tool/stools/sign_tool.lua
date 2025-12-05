
TOOL.Category		= "DBT Tools"
TOOL.Name			= "Записка"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.curtime = CurTime()
--TOOL.ClientConVar[ "steerspeed" ] = 8
--TOOL.ClientConVar[ "fadespeed" ] = 535

if CLIENT then


end


function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	if self.curtime >= CurTime() then return end
	self.curtime = CurTime() + 1
	if CLIENT then 

		local dsata = {
	      name = newname,
	      desc = newdesc,
    	}
        net.Start("dbt.Sig.Create")
          net.WriteTable(dsata)
        net.SendToServer()

	end
	
	
	return true
end

function TOOL:RightClick( trace )
	local ply = self:GetOwner()
	
	if not simfphys.IsCar( ent ) then return false end
	
	if CLIENT then return true end

	
	return true
end

function TOOL:Think()

end

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	--
end


function TOOL.BuildCPanel( panel )

	panel:AddControl( "Header", { Text = "Создание записки", Description = "Создает/сохраняет записку" } )

	-- Убедимся, что базовая папка существует
	file.CreateDir("dbt/notes")

	local DetailLabel = vgui.Create("DLabel")
	panel:AddPanel(DetailLabel)
	DetailLabel:SetDark(true)
	DetailLabel:SetWrap(true)
	DetailLabel:SetAutoStretchVertical(true)
	DetailLabel:SetText("Сохраненные записки:")
	local browser = vgui.Create("DFileBrowser")
	panel:AddPanel(browser)
	browser:SetSize(panel:GetWide(),205)
	browser:SetPath( "DATA" ) 
	browser:SetBaseFolder( "dbt/notes" ) 
	browser:SetOpen( true )
	browser.OnSelect = function(self, path)
		local rel = path:gsub("^data/", "")
		local json = file.Read(rel, "DATA")
		if not json then return end
		local data = util.JSONToTable(json) or {}
		path_current_sign = rel
		newname = data.name or ""
		if IsValid(name_sign) then name_sign:SetValue(newname) end
		newdesc = data.desc or ""
		if IsValid(desc_sign) then desc_sign:SetValue(newdesc) end
	end
	
	name_sign = vgui.Create( "DTextEntry") -- create the form as a child of frame
	name_sign:SetMultiline(false)
	name_sign:SetUpdateOnType(true)
	name_sign.OnEnter = function( self )
		newname = self:GetValue()
		GetConVar("name_sign"):SetString(self:GetValue())
	end
	name_sign.OnTextChanged = function( self )
		newname = self:GetValue()
		GetConVar("name_sign"):SetString(self:GetValue())
	end
	panel:AddPanel(name_sign)

	desc_sign = vgui.Create( "DTextEntry") -- create the form as a child of frame
	desc_sign:SetMultiline(true)
	desc_sign:SetSize(panel:GetWide(),205)
	desc_sign:SetUpdateOnType(true)
	desc_sign.OnEnter = function( self )
		newdesc = self:GetValue()
		GetConVar("text_sign"):SetString(self:GetValue())
	end
	desc_sign.OnTextChanged = function( self )
		newdesc = self:GetValue()
		GetConVar("text_sign"):SetString(self:GetValue())
	end
	panel:AddPanel(desc_sign)

	local saveNote = vgui.Create( "DButton")
	saveNote:SetText( "Сохранить записку" )
	saveNote.DoClick = function()
		Derma_StringRequest(
			"Сохранение записки",
			"Введите название файла (ENG)",
			"",
			function(text)
				local data = { name = newname or "", desc = newdesc or "" }
				local curFolder = browser:GetCurrentFolder() or "data/dbt/notes"
				local relFolder = curFolder:gsub("^data/", "")
				file.CreateDir(relFolder)
				local fileName = string.gsub(text or "new_note", "[^%w%-_]", "_") .. ".json"
				file.Write(relFolder .. "/" .. fileName, util.TableToJSON(data, true))
				browser:Setup()
			end
		)
	end
	panel:AddPanel(saveNote)

	local createDirBtn = vgui.Create( "DButton")
	createDirBtn:SetText( "Создать папку" )
	createDirBtn.DoClick = function()
		Derma_StringRequest(
			"Создание папки",
			"Введите название папки (ENG)",
			"",
			function(text)
				local curFolder = browser:GetCurrentFolder() or "data/dbt/notes"
				local relFolder = curFolder:gsub("^data/", "")
				local newDir = relFolder .. "/" .. (string.gsub(text or "new_folder", "[^%w%-_]", "_"))
				file.CreateDir(newDir)
				browser:Setup()
			end
		)
	end
	panel:AddPanel(createDirBtn)

	local deleteNote = vgui.Create( "DButton")
	deleteNote:SetText( "Удалить записку" )
	deleteNote.DoClick = function()
		if path_current_sign then file.Delete(path_current_sign) end
		browser:Setup()
	end
	panel:AddPanel(deleteNote)

	local function DeleteDir(path)
		local files, dirs = file.Find(path .."/*", "DATA")
		for _, f in ipairs(files or {}) do file.Delete(path .."/".. f) end
		for _, d in ipairs(dirs or {}) do DeleteDir(path .."/".. d) end
	end

	local deleteDirBtn = vgui.Create( "DButton")
	deleteDirBtn:SetText( "Удалить папку" )
	deleteDirBtn.DoClick = function()
		local curFolder = browser:GetCurrentFolder() or "data/dbt/notes"
		local relFolder = curFolder:gsub("^data/", "")
		DeleteDir(relFolder)
		browser:Setup()
	end
	panel:AddPanel(deleteDirBtn)

	
end
