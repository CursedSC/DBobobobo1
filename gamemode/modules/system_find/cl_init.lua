local color_red = Color( 0, 0, 255 )
local color_one = Color( 255, 0, 255 )
local color_two = Color( 255, 255, 255 )
local ulika = Color( 65, 92, 143, 255  )

local matColor = Material( "pp/colour" )
matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
matColor:SetFloat( "$pp_colour_addr", 0.5 )
matColor:SetFloat( "$pp_colour_addg", 0.5 )
matColor:SetFloat( "$pp_colour_addb", 0.5 )
matColor:SetFloat( "$pp_colour_contrast", 0.5 )
matColor:SetFloat( "$pp_colour_colour", 0.9 )
matColor:SetFloat( "$pp_colour_brightness", -0.5 )

