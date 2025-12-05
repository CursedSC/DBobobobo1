---

netstream.Hook("player/start/work", function(workshop)
	local addons = {}
	for i,addon in pairs(workshop) do
		if addon.mounted then
			table.insert(addons, addon.wsid)
		end
	end
	local pl_addons = {}
	for i,addon in pairs(engine.GetAddons()) do
		if addon.mounted then
			table.insert(pl_addons, addon.wsid)
		end
	end

	for i = 1, #addons do 
		if table.HasValue(pl_addons, addons[i]) then 
		else 
			steamworks.FileInfo( addons[i], function( result ) 
				chat.AddText( Color( 255, 0, 0 ), "[Danganronpa Broken Timeline]", Color( 255, 255, 255 ), " Отсуствует нужный аддон - ".. result.title )
			end)
		end
	end

end)

