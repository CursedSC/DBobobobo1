steam = steam or {}

steam.ProfileURL = "https://steamcommunity.com/profiles/%s/"
steam.DefaultAvatar = "https://avatars.fastly.steamstatic.com/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg"
steam.PatternDecor = [[<div class="playerAvatarAutoSizeInner".-<img%s+src="(https://[^"]-)"%s*>%s*</div>%s*</div>]] 
steam.PatternAvatar = [[<div class="playerAvatarAutoSizeInner".-<img%s+src="(https://[^"]-)"%s*>%s*</div>]]
steam.PatternFrame = [[<div class="profile_avatar_frame".-<img%s+src="(https://[^"]-)"%s*>%s*</div>]]

function steam.FetchProfile(steamID64, Callback)
	local ProfileURL = Format(steam.ProfileURL, steamID64)

	http.Fetch(
		ProfileURL,

		function(Body, Size, Headers, Code)
			if Code ~= 200 then
				Callback(nil)
				return
			end

			Callback(Body)
		end,

		function(Error)
			Callback(nil)
		end,

		{
			["accept"] = "text/html",
			["accept-language"] = "en"
		}
	)
end

steam._storeAvatare = steam._storeAvatare or {}
steam._storeFrame = steam._storeFrame or {}


function steam.FetchAvatar(steamID64, Callback)
    if steam._storeAvatare[steamID64] then return Callback(steam._storeAvatare[steamID64]) end
	steam.FetchProfile(steamID64, function(Data)
		if not isstring(Data) or string.len(Data) < 1 then
			Callback(nil)
			return
		end

		local AvatarURL = string.match(Data, steam.PatternDecor)
		AvatarURL = AvatarURL or string.match(Data, steam.PatternAvatar)
        steam._storeAvatare[steamID64] = AvatarURL
		Callback(AvatarURL)
	end)
end

function steam.FetchAvatarFrame(steamID64, Callback)
    if steam._storeFrame[steamID64] then return Callback(steam._storeFrame[steamID64]) end
	steam.FetchProfile(steamID64, function(Data)
		if not isstring(Data) or string.len(Data) < 1 then
			Callback(nil)
			return
		end

		local FrameURL = string.match(Data, steam.PatternFrame)
        steam._storeFrame[steamID64] = FrameURL
		Callback(FrameURL)
	end)
end

--- Returns the default ? avatar
--- @return string
function steam.GetDefaultAvatar()
	return steam.DefaultAvatar
end

