--https://imgur.com/5RvzzJp.png
file.CreateDir("dbt-material")

local httpMaterial = {}
httpMaterial.__index = httpMaterial

function httpMaterial:Init(url, flags, ttl)
	ttl = ttl or 86400
	url = url:gsub("cdn.discordapp.com", "media.discordapp.net")
	local fname = url:match("([^/]+)$"):gsub("[&?]([^/%s]+)=([^/%s]+)", "")
	if fname:match("^.+(%..+)$") == nil then
		fname = fname ..".png"
	end

	local uid = util.CRC(url)  .."_".. fname
	local path = "dbt-material/".. uid

	if file.Exists(path, "DATA") and file.Time(path, "DATA") + ttl > os.time() then
		self.material = Material("data/".. path, flags)
	else
		self:Download(url, function(succ, result)
			if succ then
				file.Write(path, result)
				self.material = Material("data/".. path, flags)
			else
				--ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))

				url = "https://proxy.duckduckgo.com/iu/?u=".. url
				self:Download(url, function(succ, result)
					if succ then
						file.Write(path, result)
						self.material = Material("data/".. path, flags)
					else
						--ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))
						self.material = Material("error")
					end
				end)
			end
		end)
	end
end

function httpMaterial:Download(url, cback, retry)
	retry = retry or 3
	if retry <= 0 then return cback(false, "retry") end

	http.Fetch(url, function(raw, _, _, code)
		if not raw or raw == "" or code ~= 200 or raw:find("<!DOCTYPE HTML>", 1, true) then
			--self:Download(url, cback, retry - 1)
			return
		end

		cback(true, raw)
	end, function(err)
		cback(false, err)
	end)
end

function httpMaterial:GetMaterial()
	return self.material
end

function httpMaterial:Draw(x, y, w, h)
	if self.material == nil then return end
	surface.SetMaterial(self.material)
	surface.DrawTexturedRect(x, y, w, h)
end

function httpMaterial:DrawR(x, y, w, h, r)
	if self.material == nil then return end
	surface.SetMaterial(self.material)
	surface.DrawTexturedRectRotated(x, y, w, h, r)
end

setmetatable(httpMaterial, {
	__call = httpMaterial.Draw
})

function HTTP_IMG(url, flags)
	local instance = setmetatable({}, httpMaterial)
	instance:Init(url, flags)
	return instance
end


function surface.DrawMulticolorText2(x, y, font, text, maxW)
	surface.SetTextColor(255, 255, 255)
	surface.SetFont(font)
	surface.SetTextPos(x, y)
	local baseX = x
	local w, h = surface.GetTextSize("W")
	local lineHeight = h * 0.8

	if maxW and x > 0 then
		maxW = maxW + x
	end

	for _, v in ipairs(text) do
		if isstring(v) then
			w, h = surface.GetTextSize(v)

			if maxW and x + w > maxW then
				v:gsub("(%s?[%S]+)", function(word)
					w, h = surface.GetTextSize(word)

					if x + w >= maxW then
						x, y = baseX, y + (lineHeight)
						word = word:gsub("^%s+", "")
						w, h = surface.GetTextSize(word)

						if x + w >= maxW then
							word:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", function(char)
								w, h = surface.GetTextSize(char)

								if x + w >= maxW then
									x, y = baseX, y + lineHeight
								end

								surface.SetTextPos(x, y)
								surface.DrawText(char)

								x = x + w
							end)

							return
						end
					end

					surface.SetTextPos(x, y)
					surface.DrawText(word)

					x = x + w
				end)
			else
				surface.SetTextPos(x, y)
				surface.DrawText(v)

				x = x + w
			end
		else
			surface.SetTextColor(v.r, v.g, v.b, v.a)
		end
	end

	return x, y
end


local old_Material = Material
local chache = {}
function Material(path, args)
	local args = args or ""
	if chache[path.."_"..args] then return chache[path.."_"..args] end 
	chache[path.."_"..args] = old_Material(path, args)
	return chache[path.."_"..args]
end

http.Material = HTTP_IMG