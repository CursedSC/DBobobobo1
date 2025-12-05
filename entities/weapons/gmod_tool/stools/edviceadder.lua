
TOOL.Category		= "DBT Tools"
TOOL.Name			= "Улика"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.curtime = CurTime()
--TOOL.ClientConVar[ "steerspeed" ] = 8
--TOOL.ClientConVar[ "fadespeed" ] = 535

if CLIENT then


end

ico_materials = {}
for i = 1, 14 do
    list.Add( "twf_list", "icons/dbt_icons/dbt_"..i..".png" )
end


local files = file.Find( "materials/icons/*", "GAME" )

for i = 1, #files do
    list.Add( "twf_list", "icons/"..files[i] )
end

function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	if self.curtime >= CurTime() then return end
	self.curtime = CurTime() + 1
	if CLIENT then 

		local dsata = {
	      name = ev_name,
	      desc = ev_desc,
	      rank = ev_rank,
	      medic = ev_medic,
	      img = ev_img,
		location = ev_location,
	      icon = GetConVar("thw_evidice"):GetString(),
	      img_info = {
			x = wide_x_img,
			y = wide_y_img,
			}
    	}
        net.Start("dbt.Evidence") 
          net.WriteTable(dsata)
        net.SendToServer()

	end
	
	
	return true
end

function TOOL:RightClick( trace )
	-- Ничего не делаем на ПКМ, чтобы избежать ошибок
	return false
end

function TOOL:Think()

end

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	--
end

local function DeleteDir(path, just_clear)
	-- Рекурсивно очищает каталог в DATA
	local files, dirs = file.Find(path .."/*", "DATA")

	for _, f in ipairs(files or {}) do
		file.Delete(path .."/".. f)
	end

	for _, d in ipairs(dirs or {}) do
		DeleteDir(path .."/".. d, just_clear)
	end

	-- ГаррисМод не умеет удалять директории напрямую, оставим пустую папку
end


function TOOL.BuildCPanel( panel )
	-- Гарантируем наличие базовой папки для улик
	file.CreateDir("dbt/evidence")
	path_current = nil
    local DetailLabel = vgui.Create("DLabel")
    panel:AddPanel(DetailLabel)
    DetailLabel:SetDark(true)
    DetailLabel:SetWrap(true)
    DetailLabel:SetAutoStretchVertical(true)
    DetailLabel:SetText("Сохраненные улики:")
	local browser = vgui.Create("DFileBrowser")
	panel:AddPanel(browser)
	browser:SetSize(panel:GetWide(),205)
	-- Используем DATA и отдельную папку для улик
	browser:SetPath( "DATA" ) 
	browser:SetBaseFolder( "dbt/evidence" ) 
	browser:SetOpen( true )
	function browser:OnSelect( path, pnl ) -- Нажатие по файлу
		-- Приводим путь к относительному в DATA
		local rel = path:gsub("^data/", "")
		local json = file.Read(rel, "DATA")
		if not json then return end
		local data = util.JSONToTable(json) or {}
		path_current = rel
		-- Восстанавливаем значения
		ev_name = data.name or ""
		if IsValid(name_ev) then name_ev:SetValue(ev_name) end
		ev_desc = data.desc or ""
		if IsValid(desc_ev) then desc_ev:SetValue(ev_desc) end
		ev_rank = tonumber(data.rank) or 1
		if IsValid(lvl) then lvl:SetValue(ev_rank) end
		ev_medic = tobool(data.medic)
		if IsValid(medic) then medic:SetValue(ev_medic) end
		ev_location = data.location or ""
		if IsValid(location_ev) then location_ev:SetValue(ev_location) end
		ev_img = data.img or ""
		if IsValid(img_ev) then img_ev:SetValue(ev_img) end
		if data.icon then GetConVar("thw_evidice"):SetString(tostring(data.icon)) end
	end
    local DetailLabel = vgui.Create("DLabel")
    panel:AddPanel(DetailLabel)
    DetailLabel:SetDark(true)
    DetailLabel:SetWrap(true)
    DetailLabel:SetAutoStretchVertical(true)
    DetailLabel:SetText("Название улики:")

	name_ev = vgui.Create( "DTextEntry") -- create the form as a child of frame
	name_ev:SetUpdateOnType(true)
	name_ev.OnTextChanged = function( self )
		GetConVar("name_evidice"):SetString(self:GetValue())
		ev_name = self:GetValue()
	end
	panel:AddPanel(name_ev)


	local AlphaDesc = vgui.Create("DLabel")
    AlphaDesc:SetText("Локация")
    AlphaDesc:SetWrap(true)
    AlphaDesc:SetAutoStretchVertical(true)
    AlphaDesc:SetTextColor(Color(153,50,204))
    panel:AddPanel(AlphaDesc)

	ev_location = ev_location or ""
	location_ev = vgui.Create( "DTextEntry") -- create the form as a child of frame
	location_ev:SetUpdateOnType(true)
	location_ev.OnTextChanged = function( self )
		ev_location = self:GetValue()
	end
	panel:AddPanel(location_ev)

	local DetailLabel = vgui.Create("DLabel")
    panel:AddPanel(DetailLabel)
    DetailLabel:SetDark(true)
    DetailLabel:SetWrap(true)
    DetailLabel:SetAutoStretchVertical(true)
    DetailLabel:SetText("Описание улики:")
	desc_ev = vgui.Create( "DTextEntry") -- create the form as a child of frame
	desc_ev:SetMultiline(true)
	desc_ev:SetSize(panel:GetWide(),205)
	desc_ev:SetUpdateOnType(true)
	desc_ev.OnTextChanged = function( self )
		GetConVar("desc_evidice"):SetString(self:GetValue())
		ev_desc = self:GetValue() 
	end  
	panel:AddPanel(desc_ev)
    local DetailLabel = vgui.Create("DLabel")
    panel:AddPanel(DetailLabel)
    DetailLabel:SetDark(true)
    DetailLabel:SetWrap(true)
    DetailLabel:SetAutoStretchVertical(true)
    DetailLabel:SetText("Ссылка на фото (по необходимости):")


    local AlphaDesc = vgui.Create("DLabel")
    AlphaDesc:SetText("Ссылка на фото обязательно должна быть прямая и должна кончаться расширением фото (доступно только .png и .jpg)")
    AlphaDesc:SetWrap(true)
    AlphaDesc:SetAutoStretchVertical(true)
    AlphaDesc:SetTextColor(Color(153,50,204))
    panel:AddPanel(AlphaDesc)

	ev_img = ev_img or ""
	img_ev = vgui.Create( "DTextEntry") -- create the form as a child of frame
	img_ev:SetUpdateOnType(true)
	img_ev.OnTextChanged = function( self )
		ev_img = self:GetValue()
	end
	panel:AddPanel(img_ev)

	local BGPanel = vgui.Create( "DPanel" )
	BGPanel:SetSize( 300, 130 )
	BGPanel:Center()
	BGPanel.Paint = function(self,w,h)
		if ev_img ~= "" and (string.StartWith( ev_img, "https://" ) or string.StartWith( ev_img, "http://" )) then  
		    local mat = HTTP_IMG(ev_img)
		    surface.SetDrawColor(255, 255, 255)
		    mat:Draw(0,0,w,h)
		 end
	end
	panel:AddPanel(BGPanel)
	ev_rank = 1

	lvl = panel:AddControl( "slider", {type 	= "int", min = 1, max = 5, label = 'Заметность'})
	lvl:SetValue(1)
	lvl.OnValueChanged = function( self, value )
		ev_rank = math.Round( value )
	end

	ev_medic = false
	medic = vgui.Create( "DCheckBoxLabel" ) 
	medic:SetPos( panel:GetWide(), 50 )						
	medic:SetText("Улику видит только Микан(Медик)")							
	medic:SetValue( false )				
	medic:SizeToContents()	 
	medic:SetDark(true)	
	function medic:OnChange( val )
		ev_medic = val  
	end 
	panel:AddPanel(medic)

    local save_butt = vgui.Create( "DButton") 
    save_butt:SetText( "Сохранить" )							
	save_butt.DoClick = function()			--browser:GetCurrentFolder()
			Derma_StringRequest(
				"Сохранение улики", 
				"Введите название улики(ENG)",
				"",
				function(text) 

					local tbl_to_save = {
						name = ev_name or "",
						desc = ev_desc or "",
						rank = ev_rank or 1,
						medic = ev_medic or false,
						location = ev_location or "",
						icon = GetConVar("thw_evidice"):GetString() or "",
						img = ev_img or "",
					}
					local curFolder = browser:GetCurrentFolder() or "data/dbt/evidence"
					local relFolder = curFolder:gsub("^data/", "")
					file.CreateDir(relFolder)
					local fileName = string.gsub(text or "new_evidence", "[^%w%-_]", "_") .. ".json"
					file.Write( relFolder.."/"..fileName, util.TableToJSON(tbl_to_save, true))

					browser:Setup() 
				end,
				function(text) end
			)		

	end
	panel:AddPanel(save_butt)

    local save_butt = vgui.Create( "DButton") 
    save_butt:SetText( "Создать папку" )							
	save_butt.DoClick = function()		
		Derma_StringRequest(
			"Создание папки", 
			"Введите название папки(ENG)",
			"",
			function(text) 
				local curFolder = browser:GetCurrentFolder() or "data/dbt/evidence"
				local relFolder = curFolder:gsub("^data/", "")
				local newDir = relFolder .. "/" .. (string.gsub(text or "new_folder", "[^%w%-_]", "_"))
				file.CreateDir(newDir)
				browser:Setup() 
			end,
			function(text)  end
		)		
	end
	panel:AddPanel(save_butt)

    local remove_butt = vgui.Create( "DButton") 
    remove_butt:SetText( "Удалить улику" )							
	remove_butt.DoClick = function()		
		if path_current then file.Delete(path_current) end
		browser:Setup() 
	end
	panel:AddPanel(remove_butt)

    local remove_dir_butt = vgui.Create( "DButton") 
    remove_dir_butt:SetText( "Удалить папку" )							
	remove_dir_butt.DoClick = function()		
		local curFolder = browser:GetCurrentFolder() or "data/dbt/evidence"
		local relFolder = curFolder:gsub("^data/", "")
		DeleteDir(relFolder)
		browser:Setup() 
	end
	panel:AddPanel(remove_dir_butt)

	local matlist = panel:MatSelect( "thw_evidice", list.Get( "twf_list" ), true, 0.25, 0.25 )

end
