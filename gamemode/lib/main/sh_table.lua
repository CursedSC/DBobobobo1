function table.merge(t1, t2)
    local key

    repeat
        key = next(t2, key)
        if key == nil then break end

        local value = t2[key]

        if type(value) == "table" and type(t1[key] or false) == "table" then
            table.merge(t1[key], value)
        else
            t1[key] = value
        end

    until false

    return t1
end

function table.LastKey(tbl)
    local key

    repeat
        local oldKey = key

        key = next(tbl, key)

        if key == nil then
            return oldKey or 0
        end

    until false
end

function table.Stack(tbl)
    local stackedTbl = { }

    for _, value in SortedPairs(tbl) do
        stackedTbl[#stackedTbl + 1] = value
    end

    table.Empty(tbl)

    local count = #stackedTbl

    for i = 1, count do
        tbl[i] = stackedTbl[i]
    end

    return tbl
end

function table.Shift(tbl)
    if table.IsEmpty(tbl) then
        return tbl
    end

    table.Stack(tbl)

    local countElements = #tbl - 1

    local result = tbl[1]

    tbl[1] = nil

    for elementIndex = 1, countElements do
        tbl[elementIndex] = tbl[elementIndex + 1]
    end

    tbl[countElements + 1] = nil

    return result
end

function table.Unshift(tbl, ...)
    table.Stack(tbl)

    local elements = { ... }
    local elementsCount = #elements
    local tblElementsCount = #tbl

    local index = tblElementsCount

    while index > 0 do
        tbl[index + elementsCount] = tbl[index]

        index = index - 1
    end

    index = 1

    while index <= elementsCount do
        tbl[index] = elements[index]

        index = index + 1
    end

    return tbl
end

function table.IsEmpty(tbl)
    return next(tbl, nil) == nil
end

function table.Equal(tbl1, tbl2)
    if #table.GetKeys(tbl1) ~= #table.GetKeys(tbl2) then
        return false
    end

    local key

    repeat
        key = next(tbl1, key)
        if key == nil then break end

        local value1 = tbl1[key]
        local value2 = tbl2[key]

        if TypeID(value1) == TYPE_TABLE and TypeID(value2) == TYPE_TABLE then
            if not table.Equals(value1, value2) then
                return false
            end
        else
            if value1 ~= value2 then
                return false
            end
        end
    until false

    return true
end

function table.FirstExistedValue(tbl)
    return tbl[next(tbl, nil) or 0]
end

function table.Push(t, v)
    if  TypeID(t) ~= TYPE_TABLE or
        TypeID(v) == TYPE_NIL
    then
        return
    end

    table.Stack(t)

    local p = #t + 1

    t[p] = v

    return p
end

function table.Pop(t, p)
    if TypeID(t) ~= TYPE_TABLE then
        return
    end

    table.Stack(t)

    if  TypeID(p) ~= TYPE_NUMBER or
        p >= #t
    then
        local result = t[#t]

        t[#t] = nil

        return result
    end

    p = math.max(p, 1)

    local result = t[p]
    local count = #t

    for index = p, count - 1 do
        t[index] = t[index + 1]
    end

    return result
end

function table.ForEach(tbl, callback)
    if  TypeID(tbl) ~= TYPE_TABLE or
        TypeID(callback) ~= TYPE_FUNCTION
    then
        return
    end

    local key

    repeat
        key = next(tbl, key)
        if key == nil then break end

        local value = tbl[key]

        if callback(key, value) == false then
            break
        end
    until false
end

function table.IndexOf(tbl, needValue)
    if TypeID(tbl) ~= TYPE_TABLE then
        return
    end

    local key

    repeat
        key = next(tbl, key)
        if key == nil then break end

        local value = tbl[key]

        if needValue == value then
            return key
        end
    until false

    return
end

function table.GetByPosition(tbl, position)
    if TypeID(tbl) ~= TYPE_TABLE then
        return
    end

    local key

    repeat
        if position == 0 then
            return key
        end

        key = next(tbl, key)
        if key == nil then break end

        position = position - 1
    until false

    return
end

function table.RemoveIntersection(tbl1, tbl2)
    for _, tbl2Value in pairs(tbl2) do
        while true do
            local key

            for tbl1Key, tbl1Value in pairs(tbl1) do
                if util.Equal(tbl1Value, tbl2Value) then
                    key = tbl1Key
                end
            end

            if not key then
                break
            end

            tbl1[key] = nil
        end
    end

    return tbl1
end

function table.Slice(tbl, begin, stop)
    local elementsCount = #tbl

    if  TypeID(stop) ~= TYPE_NUMBER or
        stop == 0 or
        stop > elementsCount
    then
        stop = elementsCount
    else
        while stop < 0 do
            stop = stop + elementsCount
        end
    end

    if TypeID(begin) ~= TYPE_NUMBER then
        begin = 1
    else
        begin = math.Clamp(begin, 1, elementsCount)
    end

    if begin > stop then
        return { }
    end

    local result = { }
    local count = 1

    for index = begin, stop do
        if index > elementsCount then
            break
        end

        result[count] = tbl[index]

        count = count + 1
    end

    return result
end