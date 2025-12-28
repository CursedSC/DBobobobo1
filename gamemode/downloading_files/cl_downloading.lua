local f3Pressed = false
local color_green = Color( 255, 255, 255 )

hook.Add("Think", "dbt.modules.fixes.f3Cursor", function()
    local f3PressedNow = input.IsKeyDown(KEY_F3)

    if f3PressedNow and not f3Pressed then
        f3Pressed = true

        gui.EnableScreenClicker(not vgui.CursorVisible())
    end

    if not f3PressedNow and f3Pressed then
        f3Pressed = false
    end
end)

function GM:PlayerStartVoice(ply) return end

hook.Add('ScoreboardHide', 'pScoreboard.ScoreboardHidSSSe', function()
    if IsClassTrial() then
      	gui.EnableScreenClicker(true)
    end
end)

hook.Add('ScoreboardShow', 'pScoreboard.ScoreboSSSSardHidSSSe', function()
    if IsClassTrial() then
		gui.EnableScreenClicker(true)
	end
end)

net.Receive("dbt.GetTable", function ()
  Spots = net.ReadTable()
end)

net.Receive("dbt.music.Off", function()
    timer.Remove( "AutoPlay" )
    if IsValid(PlayingSong) then
            PlayingSong:Stop()
    end
end)

hook.Add( "InitPostEntity", "some_unique_name", function()
  chat.AddText( Color( 139, 12, 161 ), "[LOTM: Zero Abyss]", Color( 100, 255, 100 ), " Установка x64 Версии Garry's mod значительно повысит производительность компьютера." )
end )

hook.Add("PlayerBindPress","dbt.misc.flash",function(ply,bind,pressed)

  if bind=="impulse 100" then
      if not IsValid(ply) then return true end
      if not IsValid(ply:GetActiveWeapon()) then return true end
      if ply:GetActiveWeapon():GetClass()!="tfa_nmrih_maglite" then
        --if ply:HasWeapon("tfa_nmrih_maglite") then
        --  ply:ConCommand("use tfa_nmrih_maglite")
       -- end
        return true
      end
      if pressed then
        net.Start("NMRIHFlashlightToggle")
        net.SendToServer()
      end
      return true
  end
end)

hook.Add("PlayerBindPress", "dbt/PlayerBindPress/CantRun", function(ply, bind, pressed)
  local ply = LocalPlayer()
  local hp = ply:Health()
  local hpMax = ply:GetMaxHealth()

  if bind == "+speed" and hp <= 20 and not ply:GetNWBool("Adrenaline") then
      return true
  end
end)
hook.Add( "PlayerSwitchWeapon", "dbt/PlayerSwitchWeapon/sound", function( ply, oldWeapon, newWeapon )
  if not IsFirstTimePredicted() then return end
  surface.PlaySound("player/suit_ct_"..math.random(1, 17)..".wav")
end )

netstream.Hook("dbt/player/text", function(...)
  chat.AddText(...)
end)

