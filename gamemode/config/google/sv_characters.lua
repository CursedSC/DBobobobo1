local dataLoad = dataLoad or {}
local api_key = "AIzaSyBsZ1_9A0U-zU7B-P2swBRm9Lfqk6wQJB0"


dataLoad.chache = {} 

dataLoad.LoadTable = function()
    local dip = "B69:R127" 
    http.Fetch( "https://sheets.googleapis.com/v4/spreadsheets/1q2vSo6R64cDwAVDNnlPMu3yXHgr_yjia9ys_bnx0mJg/values/'main'!"..dip.."?key=".. api_key,
    
	    -- onSuccess function
	    function( body, length, headers, code ) 
	    	local result = util.JSONToTable(body) 
	    	local values = result.values 
	    	for k, i in pairs(values) do   
	    		local name = i[1] 
                if dbt.chr[name] then 
                    dataLoad.ChangeCharacter(i, name)
                end
	    	end
            netstream.Start(nil, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'System', titlecolor = Color(255, 0, 255), notiftext = 'Персонажи успешно перезагружены'})
            netstream.Start(nil, "dbt.Sync.CHR", dbt.chr)
	    end,

	    -- onFailure function
	    function( message )

	    end,

	    -- header example
	    { 
	    	["accept-encoding"] = "gzip, deflate",
	    	["accept-language"] = "fr" 
	    }
    )
end
 


dataLoad.ChangeCharacter = function(newData, character)
    dbt.chr[character].maxHealth = tonumber(newData[3])
    dbt.chr[character].maxStamina = tonumber(newData[4])
    dbt.chr[character].maxHungry = tonumber(newData[5])
    dbt.chr[character].maxThird = tonumber(newData[6])
    dbt.chr[character].maxSleep = tonumber(newData[7])
    dbt.chr[character].runSpeed = tonumber(newData[8])

    local damageTable = string.Split(newData[9], "-")
    dbt.chr[character].fistsDamageString = newData[9]
    dbt.chr[character].fistsDamage = {min = tonumber(damageTable[1]), max = tonumber(damageTable[2])}

    dbt.chr[character].maxKG = tonumber(newData[10])
    dbt.chr[character].maxInventory = tonumber(newData[11]) 
    dbt.chr[character].attentiveness = tonumber(newData[12]) 
    dbt.chr[character].food = tonumber(newData[13])
    dbt.chr[character].water = tonumber(newData[14])
    dbt.chr[character].sleep = tonumber(newData[15])

    local itemsList = string.Explode( ",", newData[16]) 
    dbt.chr[character].customItems = {}
    dbt.chr[character].customWeapons = {}
    for k, i in pairs(itemsList) do
        local tryToNumber = tonumber(i) 
        if tryToNumber then 
            table.insert(dbt.chr[character].customItems, tryToNumber)
        elseif i then 
            table.insert(dbt.chr[character].customWeapons, i)
        end
    end


    dbt.chr[character].absl = newData[17]
    dbt.chr[character].backup = dbt.chr[character]
end

concommand.Add("loadCharacter", function()
    dataLoad.LoadTable()
end)
dataLoad.LoadTable()
Loadneed = Loadneed or true
hook.Add( "PlayerInitialSpawn", "Loadneed/Load", function( ply )
    if !Loadneed then return end
	dataLoad.LoadTable()
    Loadneed = false
end )
hook.Add( "PlayerConnect", "LoadneedLoadTable", function( name, ip )
    if !Loadneed then return end
	dataLoad.LoadTable()
    Loadneed = false
end )
