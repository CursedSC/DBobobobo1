local function ws(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

local function hs(x, custom)
    local a = custom or 1080
    return ScrH() / a  * x
end

monopad = monopad or {}

local getTime = function()
    local globaltime = GetGlobalInt("Time")
    local    s = globaltime % 60
    local    tmp = math.floor( globaltime / 60 )
    local    m = tmp % 60
    local    tmp = math.floor( tmp / 60 )
    local    h = tmp % 24

    local    days = math.floor( tmp / 24 )

    return string.format( "%02i:%02i", h, m), h, math.floor(days)
end

local time_type = {}
time_type["freetime"] = "Свободное время"
time_type["classtrial"] = "Классный суд"
time_type["find"] = "Расследование"

local glav_type = {}
glav_type["prolog"] = "Пролог"
glav_type["epilog"] = "Епилог"

for i = 1,6 do
    glav_type["stage_"..i] = "Глава "..i
end

local mat_bg1 = Material("dbt/monopad/dbt_monoframes.png")
local mat_bg2 = Material("dbt/monopad/bg.png")
local mat_borders = Material("dbt/monopad/borders.png")
local mat_monoframes3 = Material("dbt/monopad/dbt_monoframes3.png")
local mat_monoframes31 = Material("dbt/monopad/monopad_lines2.png")
local mat_effect = Material("dbt/monopad/monopad_lines1.png")
local mat_energy = Material("dbt/monopad/energy.png")

local mat_ev = Material("dbt/monopad/Evidence_Big.png")
local mat_msg = Material("dbt/monopad/Messages_Big.png")
local mat_notes = Material("dbt/monopad/Notes_Big.png")
local mat_char = Material("dbt/monopad/Char_Big.png")
local mat_rules = Material("dbt/monopad/Rules_Big.png")
local mat_rules2 = Material("dbt/monopad/monokuma_eye.png")
local prikol = Color(255,255,255, (255/100) * 1)

local function DrawFilledSprite(material, color, w)

	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	-- render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	-- render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	-- Enable stencils
	render.SetStencilEnable( true )
	-- Set everything up everything draws to the stencil buffer instead of the screen
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
    local color = Color(color.r, color.g, color.b, 100)
	-- Draw a weird shape to the stencil buffer
	dbtPaint.DrawRectR(material, (w / 2) - AnimateSprite, -50 + (ws(1633) / 2), ws(816), ws(1633), 0)

	-- Only draw things that are in the stencil buffer
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilFailOperation( STENCIL_KEEP )

	-- Draw our clipped text
	draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), color)

	-- Let everything render normally again
	render.SetStencilEnable( false )
end
local canShow = false
local isfirst = true
monopadChat = nil
monopadIsOpen = false
AnimateSprite = 0
monopad.Alpha = 0
monopad.MainColor = Color(255,255,255)



function openMonopad()
	if LocalPlayer():GetNWInt("IsSleep", 0) == 1 then return end
    if IsValid(monopad.Frame) then monopad.Frame:Close() end
	surface.PlaySound(isfirst and 'ui/monopad_open_first.wav' or 'ui/monopad_open.mp3')
	netstream.Start('dbt/openmonopad/setInMonopad')
	monopadIsOpen = true
    monopad.Frame = vgui.Create("DFrame")
    monopad.EffectPosition = 0
    local mp = monopad.Frame
    mp:SetSize(ws(1577), hs(923))
    mp:SetPos(ScrW() / 2 - ws(1577 / 2), ScrH() - hs(600))
    mp:SetTitle("")
    mp:MakePopup()
    mp:SetKeyBoardInputEnabled(true)
    mp:ShowCloseButton(false)
    dbt.inventory.info.monopad.meta.signs = dbt.inventory.info.monopad.meta.signs or {}
	mp:MoveTo(ScrW() / 2 - mp:GetWide() / 2, ScrH() / 2 - mp:GetTall() / 2, 0.3, 0, -1, function()
	end)
    local pers = LocalPlayer():GetMonopadOwner()
    local nameCharacter = CharacterNameOnName(pers)
    local char_tbl = dbt.chr[pers]
    AnimateSprite = 0
    local material = CreateMaterial( char_tbl.season.."_"..char_tbl.char.."_1", "UnlitGeneric", {
        ["$basetexture"] = "dbt/characters"..char_tbl.season.."/char"..char_tbl.char.."/ct_sprite_1.vtf",
        ["$alphatest"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1,
        ["$smooth"] = 1,
        ["$mips"] = 1,
        ["$allowalphatocoverage"] = 1,
        ["$alphatestreference "] = 0.8,
    } )

    local animtionLerp = -1
    canShow = false
    local alphaLerp = dbtPaint.CreateLerp(0.3)
    local showLerp = dbtPaint.CreateLerp(isfirst and 1.6 or 0.6, function()
        animtionLerp = dbtPaint.CreateLerp(0.3, function() canShow = true end)
    end)
    isfirst = false
    monopad.Alpha = 0
    local draw_color = dbt.chr[pers].color
    local strTime = time_type[GetGlobalString("gameStage_mono")]
    local strRound = glav_type[GetGlobalString("gameStatus_mono")]
    local strDay = "Дневное время"
    monopad.MainColorC = draw_color
	monopad.Frame.OnRemove = function() surface.PlaySound('ui/monopad_close.mp3') netstream.Start('dbt/openmonopad/setInMonopad') end
    mp.Paint = function(self, w, h)

        monopad.MainColor.a = monopad.Alpha
        monopad.Alpha = dbtPaint.GetLerp(alphaLerp or "") * 255

        if dbtPaint.LerpExist(animtionLerp) then
            local x = dbtPaint.GetLerp(animtionLerp)

            AnimateSprite = ws(400)  * x
        end



        dbtPaint.DrawRect(mat_bg2, ws(31), hs(36), ws(1516), hs(853), monopad.MainColor)
        -- Эффект
        local _w, _h = ws(1516) * 3, hs(853) * 3

        dbtPaint.DrawRect(mat_effect, ws(31) + (-1 * (_w * 0.5)) + monopad.EffectPosition, hs(36) + (-1 * (_h * 0.5)) + monopad.EffectPosition, _w, _h, prikol)
        dbtPaint.DrawRect(mat_borders, ws(31), hs(36), ws(1516), hs(853))



        DrawFilledSprite(material, draw_color, w)

        dbtPaint.DrawRect(mat_monoframes31, ws(31 + 14), hs(36 + 13), ws(1488), hs(829), draw_color)
        dbtPaint.DrawRect(mat_bg1, 0, 2, w, h, monopad.MainColor)

        if dbtPaint.LerpExist(showLerp) then
            draw.SimpleText("Добро пожаловать,", "Comfortaa X60", w / 2, h /2, monopad.MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(nameCharacter, "Comfortaa X60", w / 2, h /2 + hs(60), monopad.MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        if canShow then
            local t, h, d = getTime()
            if h > 22 or h < 6 then strDay = "Ночное время" else strDay = "Дневное время" end

            draw.SimpleText("MONOPAD - BT24", "Comfortaa Light X30", w / 2, dbtPaint.HightSource(53), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)

            draw.SimpleText("День "..d, "Comfortaa Light X30", dbtPaint.HightSource(65), dbtPaint.HightSource(53), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            dbtPaint.DrawRect(mat_energy, ws(1460), hs(60), ws(50), hs(22))
            draw.SimpleText(nameCharacter, "Comfortaa Light X70", w / 2, dbtPaint.HightSource(300), draw_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            draw.SimpleText(char_tbl.absl, "Comfortaa Light X40", w / 2 + dbtPaint.WidthSource(3), dbtPaint.HightSource(365), monopad.MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

            draw.SimpleText(t, "Comfortaa Light X70", w / 2, dbtPaint.HightSource(450), draw_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            draw.SimpleText("| "..strDay, "Comfortaa Light X40", w / 2 + dbtPaint.WidthSource(3), dbtPaint.HightSource(505), monopad.MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT) --"| "..strTime
            draw.SimpleText("| "..strRound, "Comfortaa Light X40", w / 2 + dbtPaint.WidthSource(3), dbtPaint.HightSource(540), monopad.MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            draw.SimpleText("| "..strTime, "Comfortaa Light X40", w / 2 + dbtPaint.WidthSource(3), dbtPaint.HightSource(575), monopad.MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end
        monopad.EffectPosition = monopad.EffectPosition + 0.05
        if math.Round(monopad.EffectPosition, 1) >= 830 then monopad.EffectPosition = 0 end



        local isEsc = input.IsKeyDown( KEY_ESCAPE )
        local isMonopadBuilded = IsValid(mp)
		if input.IsKeyDown(KEY_C) and canShow and not IsValid(monopadChat) and not IsValid(monopadSigns) then
			monopad.Frame:Close()
			monopadIsOpen = false
	        gui.HideGameUI()
		end
        if !isEsc or !isMonopadBuilded then return end
        if IsValid(monopad.Frame) then monopad.Frame:Close() end
		monopadIsOpen = false
        gui.HideGameUI()
    end

    workPlace = vgui.Create("EditablePanel", mp)
    workPlace:SetSize(ws(1500), hs(845))
    workPlace:SetPos(ws(37), hs(41))


    local buttonEv = vgui.Create("DButton", workPlace)
    buttonEv:SetSize(ws(57), hs(56))
    buttonEv:SetPos(ws(589), hs(772))
    buttonEv:SetText("")
    buttonEv.Paint = function(self, w, h)
        dbtPaint.DrawRect(mat_ev, 0, 0, w, h, color_white)
    end
    buttonEv.DoClick = function()
        if IsValid(monopadEv) then monopadEv:Close() return end
		surface.PlaySound('monopad_app_open.mp3')
        monopadEv = vgui.Create("EvidenceFrame", workPlace)
		monopadEv.OnRemove = function() surface.PlaySound('monopad_app_close.mp3') end
        monopadEv:SetTitle("")
        monopadEv:SetSize(dbtPaint.WidthSource(605), dbtPaint.HightSource(652))
        monopadEv:Center()
    end


    local buttonMsg = vgui.Create("DButton", workPlace)
    buttonMsg:SetSize(ws(65), hs(54))
    buttonMsg:SetPos(ws(652), hs(772))
    buttonMsg:SetText("")
    buttonMsg.Paint = function(self, w, h)
        dbtPaint.DrawRect(mat_msg, 0, 0, w, h, color_white)
    end
    buttonMsg.DoClick = function()

        if IsValid(monopadChat) then monopadChat:Close() return end
		surface.PlaySound('monopad_app_open.mp3')
        netstream.Start("dbt/monopad/request/chats", dbt.inventory.info.monopad.meta.id)
        monopadChat = vgui.Create("MonopadFrame", workPlace)
        monopadChat:SetTitle("")
        monopadChat:SetSize(dbtPaint.WidthSource(597), dbtPaint.HightSource(652))
        monopadChat:Center()
		monopadChat.OnRemove = function() surface.PlaySound('monopad_app_close.mp3') end
        if monopadChat.ActiveChatId then
            monopadChat:RequestMessagesFor(monopadChat.ActiveChatId)
        end
        monopadChat.TextEntry:RequestFocus()
    end

    local buttonSigns = vgui.Create("EditablePanel", workPlace)
    buttonSigns:SetSize(ws(58), hs(56))
    buttonSigns:SetPos(ws(807), hs(772))
    buttonSigns:SetText("")
    buttonSigns.Paint = function(self, w, h)
        dbtPaint.DrawRect(mat_char, 0, 0, w, h, color_white)
    end


    local buttonSigns = vgui.Create("DButton", workPlace)
    buttonSigns:SetSize(ws(48), hs(56))
    buttonSigns:SetPos(ws(878), hs(772))
    buttonSigns:SetText("")
    buttonSigns.Paint = function(self, w, h)
        dbtPaint.DrawRect(mat_notes, 0, 0, w, h, color_white)
    end
    buttonSigns.DoClick = function()

        if IsValid(monopadSigns) then monopadSigns:Close() return end
		surface.PlaySound('monopad_app_open.mp3')
        monopadSigns = vgui.Create("SignFrame", workPlace)
        monopadSigns:SetTitle("")
		monopadSigns.OnRemove = function() surface.PlaySound('monopad_app_close.mp3') end
        monopadSigns:SetSize(dbtPaint.WidthSource(597), dbtPaint.HightSource(652))
        monopadSigns:Center()
    end

    local buttonRules = vgui.Create("DButton", workPlace)
    buttonRules:SetSize(ws(69), hs(60))
    buttonRules:SetPos(ws(727), hs(768))
    buttonRules:SetText("")
    buttonRules.Paint = function(self, w, h)
        dbtPaint.DrawRectR(mat_rules, w / 2, h / 2, ws(48), hs(57), 0, color_white)
        dbtPaint.DrawRectR(mat_rules2, w / 2, h * 0.38, ws(69), hs(48), 0, monopad.MainColorC)
    end
    buttonRules.DoClick = function()
        if IsValid(monopadRules) then monopadRules:Close() return end
		surface.PlaySound('monopad_app_open.mp3')
        monopadRules = vgui.Create("RulesFrame", workPlace)
		monopadRules.OnRemove = function() surface.PlaySound('monopad_app_close.mp3') end
        monopadRules:SetTitle("")
        monopadRules:SetSize(dbtPaint.WidthSource(844), dbtPaint.HightSource(519))
        monopadRules:Center()
    end




end

function CanOpenMonopad()
    return dbt.inventory.info.monopad.meta and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "hands"
end

hook.Add("OnContextMenuOpen", "dbt.MonoPad", function()


    if CanOpenMonopad() then openMonopad() return false end
    if !LocalPlayer():IsAdmin() then return false end

end)


concommand.Add("openMonopad", openMonopad)

AnimationSWEP = {}
    AnimationSWEP.GestureAngles = {}

    local function applyAnimation(ply, targetValue, class)
        if not IsValid(ply) then return end
        if ply.animationSWEPAngle == targetValue then return end
        if ply.animationSWEPAngle ~= targetValue then
            ply.animationSWEPAngle = Lerp(FrameTime() * 5, ply.animationSWEPAngle, targetValue)
        end

       if AnimationSWEP.GestureAngles[class] then
        for boneName, angle in pairs(AnimationSWEP.GestureAngles[class]) do
            local bone = ply:LookupBone(boneName)

            if bone then
                ply:ManipulateBoneAngles( bone, angle * ply.animationSWEPAngle)
            end
        end
      end
    end

    AnimationSWEP.GestureAngles["monopad"] = {
          ["ValveBiped.Bip01_R_UpperArm"] = Angle(10,-20),
          ["ValveBiped.Bip01_R_Hand"] = Angle(0,1,50),
          ["ValveBiped.Bip01_Head1"] = Angle(0,-30,-20),
          ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-65,39.8863),
      }

    hook.Add("Think", "AnimationSWEP.Think", function ()
        for _, ply in pairs( player.GetHumans() ) do
            local animationClass = ply:GetNWString("animationClass")
            if animationClass ~= "" then
                if not ply.animationSWEPAngle then
                    ply.animationSWEPAngle = 0
                end
                if ply:GetNWBool("animationStatus") and ply:GetNWBool("InMonopad") then
                    applyAnimation(ply, 1, animationClass)
                else
                    applyAnimation(ply, 0, animationClass)
                end
            end
      end
  end)

local model = ClientsideModel( "models/dbt/ahesam/monopad.mdl" )
model:SetNoDraw( true )
hook.Add( "PostPlayerDraw" , "manual_model_draw_examplesss" , function( ply )
  if not IsValid(ply) or not ply:Alive() or not ply:GetNWBool("InMonopad") then return end


  local pos, ang = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_R_Hand" ) )

  model:SetModelScale(0.7, 0)
  pos = pos + (ang:Forward() * 2.5)
  pos = pos + (ang:Right() * 1.8)
  ang:RotateAroundAxis(ang:Right(), 90)
  ang:RotateAroundAxis(ang:Up(), -90)
  ang:RotateAroundAxis(ang:Forward(), 0
    )
  model:SetPos(pos)
  model:SetAngles(ang)

  model:SetRenderOrigin(pos)
  model:SetRenderAngles(ang)
  model:SetupBones()
  model:DrawModel()
  model:SetRenderOrigin()
  model:SetRenderAngles()

end )
