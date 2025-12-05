local function weight_source(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hight_source(x, custom)
    local a = custom or 1920
    return ScrH() / a  * x
end

dbt = dbt or {}
dbt.AdminStats = dbt.AdminStats or {}
dbt.AdminVoteHistory = dbt.AdminVoteHistory or {}

dbt.AdminFunc["statisticks"] = {
    name = "Статистика",
    build = function(frame)
        EidctsCount = "???"
        netstream.Start("dbt/getinfo/edicts")
        local w,h = frame:GetWide(), frame:GetTall()

        local header = vgui.Create("DPanel", frame)
        header:Dock(TOP)
        header:SetTall(hight_source(220, 1080))
        header.Paint = function(self, pw, ph)
            draw.DrawText("Статистика", "RobotoLight_53", pw / 2, hight_source(28, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.DrawText("Итоги голосований", "RobotoLight_32", weight_source(40, 1920), hight_source(120, 1080), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.DrawText("Кол-во объектов на карте: "..(EidctsCount or "???").."/8064", "RobotoLight_26", weight_source(40, 1920), ph - hight_source(60, 1080), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(weight_source(40, 1920), 0, weight_source(40, 1920), weight_source(40, 1920))

        local function buildVoteList()
            if not IsValid(scroll) then return end

            scroll:Clear()
            local voteHistory = dbt.AdminVoteHistory or {}

            if #voteHistory == 0 then
                local empty = vgui.Create("DPanel", scroll)
                empty:Dock(TOP)
                empty:SetTall(hight_source(120, 1080))
                empty.Paint = function(_, pw, ph)
                    draw.RoundedBox(8, 0, 0, pw, ph, Color(0, 0, 0, 120))
                    draw.SimpleText("Данные о голосованиях отсутствуют.", "RobotoLight_26", pw / 2, ph / 2 - hight_source(16, 1080), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                return
            end

            for _, entry in ipairs(voteHistory) do
                local votesCount = #entry.votes
                local panelHeight = hight_source(110, 1080) + votesCount * hight_source(28, 1080)

                local votePanel = vgui.Create("DPanel", scroll)
                votePanel:Dock(TOP)
                votePanel:DockMargin(0, 0, 0, hight_source(16, 1080))
                votePanel:SetTall(panelHeight)
                votePanel.Paint = function(_, pw, ph)
                    draw.RoundedBox(12, 0, 0, pw, ph, Color(0, 0, 0, 150))
                    draw.SimpleText("Время: "..(entry.time or "—"), "RobotoLight_26", weight_source(18, 1920), hight_source(18, 1080), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Победитель: "..(entry.winner or "—"), "RobotoLight_26", weight_source(18, 1920), hight_source(52, 1080), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                    local offsetY = hight_source(88, 1080)
                    for _, vote in ipairs(entry.votes) do
                        local line = vote.voter.." → "..(vote.choice or "—")
                        draw.SimpleText(line, "RobotoLight_24", weight_source(18, 1920), offsetY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        offsetY = offsetY + hight_source(28, 1080)
                    end
                end
            end
        end

        dbt.AdminStats.RebuildVoteList = buildVoteList
        buildVoteList()


    end,
}