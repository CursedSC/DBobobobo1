if SERVER then
	AddCSLuaFile()
	return
end

local PANEL = {}

AccessorFunc(PANEL, "m_strSteamID", "PlayerSteamID", FORCE_STRING)
AccessorFunc(PANEL, "m_bLoadingAvatar", "LoadingAvatar", FORCE_BOOL)
AccessorFunc(PANEL, "m_bTryLoad", "TryLoad", FORCE_BOOL)
AccessorFunc(PANEL, "m_iLoadAttempts", "LoadAttempts", FORCE_NUMBER)

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
	self:SetText("")

	self:SetPlayerSteamID("0")
	self:SetLoadingAvatar(false)
	self:SetTryLoad(false)
	self:SetLoadAttempts(0)

	self:LoadAvatar()
end

function PANEL:SetPlayerSteamID(SteamID64)
	self.m_strSteamID = tostring(SteamID64)
	self:LoadAvatar()
end

function PANEL:SetPlayer(ply)
	if not IsValid(ply) then return end
	self:SetPlayerSteamID(ply:SteamID64())
end

function PANEL:SetSteamID(SteamID)
    local SteamIDTest = util.SteamIDFrom64(SteamID)
    if SteamIDTest != "0" then 
        self:SetPlayerSteamID(SteamID64)
        return
    end
	local SteamID64 = util.SteamIDTo64(SteamID)
	if SteamID64 == "0" then
		error("Invalid SteamID in SetSteamID")
	end
end

function PANEL:SetSteamID64(SteamID64)
	local SteamID = util.SteamIDFrom64(SteamID64)
	local SteamIDTest = util.SteamIDTo64(SteamID)
	if SteamIDTest ~= SteamID64 then
		error("Invalid SteamID in SetSteamID64")
	end
	self:SetPlayerSteamID(SteamID64)
end


function PANEL:CreateHTML()
	local html = vgui.Create("DHTML", self)
	html:SetPaintedManually(false)
	html:Dock(FILL)

	html:SetHTML([[
		<html>
			<head>
				<style>
					html, body {
						margin: 0;
						padding: 0;
						background: transparent;
						overflow: hidden;
						width: 100%;
						height: 100%;
					}
					img {
						position: absolute;
						top: 0;
						left: 0;
						width: 100%;
						height: 100%;
						object-fit: cover;
					}
				</style>
			</head>
			<body></body>
		</html>
	]])

	return html
end

function PANEL:EnsureHTML()
	if not IsValid(self.HTML) then
		self.HTML = self:CreateHTML()
	end
	return self.HTML
end

function PANEL:TryLoad()
	self:SetTryLoad(false)
	self:SetLoadAttempts(self:GetLoadAttempts() + 1)

	if self:GetLoadAttempts() > 4 then
		self:SetLoadingAvatar(false)
		self:SetTryLoad(false)
		return
	end

	local SteamID64 = self:GetPlayerSteamID()

	steam.FetchAvatar(SteamID64, function(AvatarURL)
		if not IsValid(self) or not AvatarURL then
			if IsValid(self) then self:SetTryLoad(true) end
			return
		end

		steam.FetchAvatarFrame(SteamID64, function(FrameURL)
			if not IsValid(self) then return end

			local HTML = self:EnsureHTML()

			local html = [[
				<html>
					<head>
						<style>
							html, body {
								margin: 0;
								padding: 0;
								background: transparent;
								overflow: hidden;
								width: 100%;
								height: 100%;
							}
							#avatar, #frame {
								position: absolute;
								top: 0;
								left: 0;
								width: 100%;
								height: 100%;
								object-fit: cover;
							}
							#frame {
								image-rendering: auto;
								transform: scale(1.2);
								transform-origin: center;
							}
						</style>
					</head>
					<body>
						<img id="avatar" src="]] .. AvatarURL .. [[" />
			]]

			if FrameURL then
				html = html .. [[
						<img id="frame" src="]] .. FrameURL .. [[" />
				]]
			end

			html = html .. [[
					</body>
				</html>
			]]

			HTML:SetHTML(html)

			self:SetLoadingAvatar(false)
			self:SetTryLoad(false)
		end)
	end)
end

function PANEL:Think()
	if self:GetLoadingAvatar() and self:GetTryLoad() then
		self:TryLoad()
	end
end

function PANEL:LoadAvatar()
	local HTML = self:EnsureHTML()

	HTML:SetHTML([[
		<html>
			<body style="margin:0;padding:0;background:transparent;">
				<img src="]] .. steam.GetDefaultAvatar() .. [[" style="width:100%;height:100%;object-fit:cover;">
			</body>
		</html>
	]])

	if self:GetPlayerSteamID() ~= "0" then
		self:SetLoadAttempts(0)
		self:SetLoadingAvatar(true)
		self:SetTryLoad(true)
	end
end

vgui.Register("AvatarImage", PANEL, "EditablePanel")
