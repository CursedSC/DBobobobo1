local micro_alpha = 0
local micro_x = 200
local MaterialMic = Material("microphone.png")
local microphone_light = Material("microphone_light.png")
local l_SetDrawColor = surface.SetDrawColor
local l_SetMaterial = surface.SetMaterial
local l_DrawTexturedRect = surface.DrawTexturedRect

hook.Add("HUDPaint", "dbt.Micro", function()
    local ply = LocalPlayer()
    if ply:IsSpeaking() then
        micro_alpha = Lerp(FrameTime() * 5, micro_alpha, 255)
        micro_x = Lerp(FrameTime() * 10, micro_x, 0)
    else
        micro_alpha = Lerp(FrameTime() * 5, micro_alpha, 0)
        micro_x = Lerp(FrameTime() * 10, micro_x, 200)
    end

    if  QMENU then
        q_alpha = Lerp(FrameTime() * 5, q_alpha, 255)
        q_aplha_plates = Lerp(FrameTime() * 5, q_aplha_plates, 37)
        q_aplha_platesd = Lerp(FrameTime() * 5, q_aplha_platesd, 0)
    else
        q_alpha = Lerp(FrameTime() * 5, q_alpha, 0)
        q_aplha_plates = Lerp(FrameTime() * 5, q_aplha_plates, 0)
        q_aplha_platesd = Lerp(FrameTime() * 5, q_aplha_platesd, 0)
    end
    if !ply:IsTyping() then
        local c = math.abs(math.cos(CurTime()))

        local cos = math.Clamp(c, 0.2, 1)
        local na = cos * micro_alpha
        l_SetDrawColor( 255, 255, 255, na)
        l_SetMaterial( microphone_light )
        l_DrawTexturedRect( 0, 0, ScreenWidth, ScreenHeight + micro_x )

        l_SetDrawColor( 255, 255, 255, micro_alpha )
        l_SetMaterial( MaterialMic )
        l_DrawTexturedRect( 0, 0, ScreenWidth, ScreenHeight + micro_x )
    end

end)
