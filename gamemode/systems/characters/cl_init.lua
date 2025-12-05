DEAD_MATS = {}

netstream.Hook("dbt.Sync.CHR", function(tbl)
	dbt.chr = tbl
	sortCharacters()
	for k, i in pairs(tbl) do 
		local mat = CreateMaterial( "deadicon_"..i.season.."_"..i.char, "VertexLitGeneric", {
		    ["$basetexture"] = "dbt/characters"..i.season.."/char"..i.char.."/dead.vtf",
		    ["$alphatest"] = 1,
		    ["$vertexalpha"] = 1,
		    ["$vertexcolor"] = 1,
		    ["$smooth"] = 1,
		    ["$allowalphatocoverage"] = 1,
		    ["$alphatestreference "] = 0.8,
		} )
	end
end)
netstream.Start("dbt.Sync.CHR")
local chace_name = {}
function dbt.GetRealName(char)
	if chace_name[char] then return chace_name[char] end

	for k, i in pairs(dbt.chr) do 
		if i.name == char then 
			chace_name[char] = k
			return k
		end
	end 
end
if dbt.chr then 
	for k, i in pairs(dbt.chr) do 
		local mat = CreateMaterial( "deadicon_"..i.season.."_"..i.char, "VertexLitGeneric", {
		    ["$basetexture"] = "dbt/characters"..i.season.."/char"..i.char.."/dead.vtf",
		    ["$alphatest"] = 1,
		    ["$vertexalpha"] = 1,
		    ["$vertexcolor"] = 1,
		    ["$smooth"] = 1,
		    ["$allowalphatocoverage"] = 1,
		    ["$alphatestreference "] = 0.8,
		} )
		 
	end
end


function saveCharacters(presetName)
	file.CreateDir("dbt")
	file.CreateDir("dbt/characters")
	file.CreateDir("dbt/characters/presets")
	local saveData = {
		data = dbt.chr,
		name = presetName,
	}
	file.Write("dbt/characters/presets/"..presetName..".txt", pon.encode(saveData))
end

function loadCharacters(presetName)
	local s = file.Read("dbt/characterpresets/"..presetName..".txt")
	local tableCharacters = pon.decode(s)
	netstream.Start("dbt/charcaters/load", tableCharacters)
end


concommand.Add("loadCharacters", function(arguments)
	loadCharacters("test")
end)
concommand.Add("saveCharacters", function(arguments)
	saveCharacters("test")
end)