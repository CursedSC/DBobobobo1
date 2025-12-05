local doing = true
local questionFallback = Color(255, 235, 130)
local noDataFallback = Color(220, 120, 120)
local positiveFallback = Color(150, 235, 150)

local function drawPlayerWounds(player, drawColor, baseY)
  if not dbt or not dbt.GetFormattedPublicWounds then return end

  local alpha = drawColor.a or 255
  local palette = dbt.WoundDisplayColors or {}
  local questionColor = ColorAlpha(palette.question or questionFallback, alpha)
  local noDataColor = ColorAlpha(palette.noData or noDataFallback, alpha)
  local positiveColor = ColorAlpha(palette.positive or positiveFallback, alpha)

  local infoFont = "dbt/font/200"
  local questionFont = "dbt/font/250"

  surface.SetFont(infoFont)
  local _, infoHeight = surface.GetTextSize("Ранение")
  surface.SetFont(questionFont)
  local _, questionHeight = surface.GetTextSize("?")
  local state, lines = dbt.GetFormattedPublicWounds(player)
  local isFocused = rawget(_G, "GDown") == true
  if !lines then return  0 end
  if not isFocused and #lines != 0 then
    draw.SimpleText("?", questionFont, 0, baseY, questionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    return baseY + questionHeight
  end

  if #lines == 0 then
    return 0
  end


  local offset = 900
  for _, text in ipairs(lines) do
    draw.SimpleText(text, infoFont, 700, baseY + offset, ColorAlpha(drawColor, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    offset = offset + infoHeight
  end

  return baseY + offset
end

hook.Add("PostPlayerDraw", "dbt.drawNicks", function(player)

  local localPlayer = LocalPlayer()

  local distance = player:GetPos():Distance(localPlayer:GetPos())

  if  --player == LocalPlayer() or
    player:HasNoClip() or
    spectator.IsSpectator(player) or
    not player:Alive()  or
    distance >= 100
  then
    return
  end

  local alpha = math.max((100 - distance) / 100, 0) * 255
  local drawColor = Color(255, 255, 255, alpha)

  local boneNumber = player:LookupBone("ValveBiped.Bip01_Head1")

  if not boneNumber then
    return
  end
  if IsMono(localPlayer:Pers()) or
    not InGame(localPlayer)
  then
    cam.Start3D2D(player:GetBonePosition(boneNumber) + Vector(0, 0, 15), Angle(0, RenderAngles().y - 90, 90), 0.01)
      local RPNickW, RPNickH = ui.GetTextSize(player:Pers(), "dbt/font/250")

      draw.SimpleText(CharacterNameOnName(player:Pers())  , "dbt/font/250", 0, 0, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText(player:Name(), "dbt/font/200", 0, RPNickH * 0.6, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

      local infoBaseY = RPNickH * 1.4
      drawPlayerWounds(player, drawColor, infoBaseY)

      if player:GetNWBool("Player.Chating") or player:IsSpeaking() or player:GetNWBool("Player.doing") then
        if player:GetNWBool("Player.doing") then
          draw.SimpleText("Действует...", "dbt/font/250", 0, -RPNickH * 1.25, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText("Говорит...", "dbt/font/250", 0, -RPNickH * 1.25, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    cam.End3D2D()
  else
    cam.Start3D2D(player:GetBonePosition(boneNumber) + Vector(0, 0, 20), Angle(0, RenderAngles().y - 90, 90), 0.01)
      local RPNickW, RPNickH = ui.GetTextSize(player:Pers(), "RPnickHUD")

      local infoBaseY = RPNickH * 0.6
      drawPlayerWounds(player, drawColor, infoBaseY)

      if player:GetNWBool("Player.Chating") or player:IsSpeaking() or player:GetNWBool("Player.doing") then
        if player:GetNWBool("Player.doing") then
          draw.SimpleText("Действует...", "dbt/font/250", 0, -RPNickH * 1.25, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText("Говорит...", "dbt/font/250", 0, -RPNickH * 1.25, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    cam.End3D2D()
  end

end)

hook.Add("ChatTextChanged", "Player.chatCheker", function(text)
  if  string.StartWith(text, "/me") or
    string.StartWith(text, "/try") or
    string.StartWith(text, "/do")
  then
    if not doing then
      doing = true

      net.Start("Player.doing")
        net.WriteBool(true)
      net.SendToServer()
    end
  else
    if doing then
      doing = false

      net.Start("Player.doing")
        net.WriteBool(false)
      net.SendToServer()
    end
  end
end)

hook.Add("FinishChat", "Player.chatCheker", function(text)
    net.Start("Player.doing")
      net.WriteBool(false)
    net.SendToServer()
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
