local P = FindMetaTable("Player")
local default = "Гость"
function P:GetCharacterName()
    return dbt.chr[self:Pers()].name
end
dbt.chr = dbt.chr or {}

function dbt.GetCharacter(chr)
    return dbt.chr[chr]
end
function TextFunc(a, b)
    if a == "Гость" then 
        return true 
    elseif b == "Гость" then  
        return false
    elseif string.StartWith(b, "custom") then 
        return false 
    elseif string.StartWith(a, "custom") then 
        return true  
    elseif string.StartWith(b, "Моно") then 
        return false 
    elseif string.StartWith(a, "Моно") then 
        return true  
    else
        return a < b
    end
end

function sortCharacters()
    DBT_CHAR_EZ = {}
    DBT_CHAR_SORTED = {}
    for k,i in pairs(dbt.chr) do
        if not DBT_CHAR_EZ[i.season] then DBT_CHAR_EZ[i.season] = {} end
        table.insert(DBT_CHAR_EZ[i.season], k)
        DBT_CHAR_SORTED[#DBT_CHAR_SORTED+1] = k
    end
    table.sort(DBT_CHAR_SORTED, function(a, b)
        return TextFunc(a, b)
    end)


    for k,i in pairs(DBT_CHAR_EZ) do
        table.sort(DBT_CHAR_EZ[k], function(a, b)
            return a < b
        end)
    end

    table.sort(dbt.chr, function(a, b)
        return a < b
    end)
end
sortCharacters()
timer.Simple(5, function() 
    sortCharacters()
end)

