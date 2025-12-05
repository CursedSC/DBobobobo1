-- Новая структура заметки: { name = string, text = string, editable = bool }
-- Обратная совместимость: если пришёл старый формат (id,text) – name генерируется автоматически.

local function ensureMeta(ply)
    ply.info.monopad.meta = ply.info.monopad.meta or {}
    ply.info.monopad.meta.signs = ply.info.monopad.meta.signs or {}
    return ply.info.monopad.meta.signs
end

netstream.Hook("dbt/monopad/notes/add", function(ply, id, name, text, editable)
    local signs = ensureMeta(ply)
    if text == nil and editable == nil and type(name) == "string" then
        text = name
        name = "Заметка " .. tostring(id)
        editable = true
    end
    if type(name) ~= "string" then name = "Заметка " .. tostring(id) end
    if type(text) ~= "string" then text = "" end
    if type(editable) ~= "boolean" then editable = true end
    signs[id] = { name = name, text = text, editable = editable }
end)

netstream.Hook("dbt/monopad/notes/edit", function(ply, id, newText)
    local signs = ensureMeta(ply)
    local note = signs[id]
    if not note then
        signs[id] = { name = "Заметка " .. tostring(id), text = tostring(newText or ""), editable = true }
        return
    end
    if note.editable ~= false and type(newText) == "string" then
        note.text = newText
    end
end)

rules_akkad = {
    {color_white,
    "Ученики могут свободно исследовать территорию школы (с минимальными ограничениями)"},
    {color_white,
    "Насилие в отношении директора школы (Монокумы) строго запрещено."},
    {color_white,
    "С 22:00 до 07:00 – официальное «ночное время». В это время некоторые локации школы могут быть закрыты по желанию директора школы.(Столовая, Спорт Зал)"},
    {color_white,
    "Сон вне общежития приравнивается ко сну на уроках и наказывается соответствующе."},
    {color_white,
    "Игрок, совершивший убийство, становится «очерненным». Очерненный выпускается из школы, если не будет раскрыт."},
    {color_white,
    "После обнаружения трупа игрокам дается некоторое время на расследование, после чего начинается школьный суд. Участие в  суде строго обязательно для всех оставшихся в живых игроков."},
    {color_white,
    "Если по итогам школьного суда очерненный определен игроками верно, то наказанию подвергается только он один."},
    {color_white,
    "Если по итогам школьного суда очерненный остается нераскрытым, то он выпускается из школы. Все остальные будут казнены"},
    {color_white,
    "Один игрок может совершить не более двух убийств."},
    {color_white,
    "Если два и более убийства были совершены разными игроками одновременно или с достаточно коротким промежутком времени между ними, то школьный суд проводится по поводу убийства того игрока, чье тело было обнаружено первым. Остальные убийства остаются безнаказанными."},
    {color_white,
    "Взламывать школьные двери строго запрещено. Исключение – двери в общежитии."},
    {color_white,
    "Дополнительные правила могут быть введены по желанию директора школы в любой момент."},
}
rules_akkadStandart = {
    {color_white,
    "Ученики могут свободно исследовать территорию школы (с минимальными ограничениями)"},
    {color_white,
    "Насилие в отношении директора школы (Монокумы) строго запрещено."},
    {color_white,
    "С 22:00 до 07:00 – официальное «ночное время». В это время некоторые локации школы могут быть закрыты по желанию директора школы.(Столовая, Спорт Зал)"},
    {color_white,
    "Сон вне общежития приравнивается ко сну на уроках и наказывается соответствующе."},
    {color_white,
    "Игрок, совершивший убийство, становится «очерненным». Очерненный выпускается из школы, если не будет раскрыт."},
    {color_white,
    "После обнаружения трупа игрокам дается некоторое время на расследование, после чего начинается школьный суд. Участие в  суде строго обязательно для всех оставшихся в живых игроков."},
    {color_white,
    "Если по итогам школьного суда очерненный определен игроками верно, то наказанию подвергается только он один."},
    {color_white,
    "Если по итогам школьного суда очерненный остается нераскрытым, то он выпускается из школы. Все остальные будут казнены"},
    {color_white,
    "Один игрок может совершить не более двух убийств."},
    {color_white,
    "Если два и более убийства были совершены разными игроками одновременно или с достаточно коротким промежутком времени между ними, то школьный суд проводится по поводу убийства того игрока, чье тело было обнаружено первым. Остальные убийства остаются безнаказанными."},
    {color_white,
    "Взламывать школьные двери строго запрещено. Исключение – двери в общежитии."},
    {color_white,
    "Дополнительные правила могут быть введены по желанию директора школы в любой момент."},
}

netstream.Hook("dbt/rules/update", function(ply, newRules)
    rules_akkad = newRules
    netstream.Start(nil, "dbt/rules/update", rules_akkad)
    netstream.Start(nil, 'dbt/NewNotification', 3, {icon = 'materials/dbt/notifications/notifications_main.png', title = 'Уведомление', titlecolor = Color(255, 10, 10), notiftext = 'Правила в монопаде обновились.'})
end)

netstream.Hook("dbt/rules/reset", function(ply, newRules)
    rules_akkad = rules_akkadStandart
    netstream.Start(nil, "dbt/rules/update", rules_akkadStandart)
end)

netstream.Hook('dbt/openmonopad/setInMonopad', function(ply)
	ply:SetNWBool("InMonopad", !ply:GetNWBool("InMonopad", false))
	ply:SetNWString("animationClass", 'monopad')
	ply:SetNWBool("animationStatus", ply:GetNWBool('InMonopad'))
end)
