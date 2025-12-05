scrw = ScrW()
scrh = ScrH()
local RPCommandsLogs = {}

function RPCommandsLogs:Paint()
	surface.SetAlphaMultiplier(0.8)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(scrw*0, scrh*0, scrw*0.2, scrh*0.5)

	surface.SetAlphaMultiplier(1)
end

vgui.Register("RPCommandsLogPanel", RPCommandsLogs, "EditablePanel")


net.Receive("OpenLogs",function()
	if IsValid(RPCommandsLogPanel) then return RPCommandsLogPanel:Remove() end
	logstbl = net.ReadTable()
	LogsOpenPanel(logstbl)
end)

function LogsOpenPanel(logcommands)
	RPCommandsLogPanel = vgui.Create("RPCommandsLogPanel")
	RPCommandsLogPanel:SetPos(scrw*0.8, scrh*0.25)
	RPCommandsLogPanel:SetSize(scrw*0.2, scrh*0.5)

	local messages = vgui.Create("RichText", RPCommandsLogPanel)
	messages:Dock(FILL)
	for k, v in ipairs(logcommands) do
		local colr = v[1]
		local r, g, b, a = colr["r"], colr["g"], colr["b"], colr["a"]
		messages:InsertColorChange(r, g, b, a)
		messages:AppendText(v[2])
	end

	function AddNewMessages(text, color)
		if not RPCommandsLogPanel:IsValid() then return end
		local r, g, b, a = color["r"], color["g"], color["b"], color["a"]
		messages:InsertColorChange(r, g, b, a)
		messages:AppendText(text)
	end

	net.Receive("NewRPCommandMessage",function ()
		local color = net.ReadColor()
		local newmessage = net.ReadString()
		AddNewMessages(newmessage, color)
	end)

	function messages:PerformLayout()
		self:SetFontInternal( "Comfortaa X25" )
	end
end
