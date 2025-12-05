netstream.Hook("gift/up", function(bool)
    LERP_GIFT = 1

    in_progress = bool

    if bool then timer.Create("gift/up", 3, 1, function() in_progress = false end) end
end)

hook.Add( "HUDPaint", "dsf", function()

  if in_progress then
    local w,h = ScrW(),ScrH()


    surface.SetDrawColor( 200, 200, 200, 255 )
    surface.DrawRect( w / 2 - (w * .3 / 2) , h / 2, w * .3 * timer.TimeLeft("gift/up") / 3, h * 0.02 )
  end
end )
