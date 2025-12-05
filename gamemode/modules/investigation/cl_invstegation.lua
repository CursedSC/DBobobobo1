investigation = {}

local line = Material("investigation/line.png")
local box1 = Material("investigation/box1.png")
local box2 = Material("investigation/box3.png")
local box3 = Material("investigation/box2.png")
local box4 = Material("investigation/box4.png")
net.Receive("investigation.St", function()
	investigation.Start()
end)
function investigation.Start()
	hs = 0
	start_anim = true
	timer.Simple(2.5, function() start_anim = false end)
	timer.Simple(3, function() hook.Remove("HUDPaint", "investigation.anim") end)
	x_f = -70
	alphabox1 = 0
	timer_box1 = true
	timer_box11 = false
	box1_s = ScrW() * 0.3
	timer.Simple(0.3, function() timer_box1 = false end)
	timer.Simple(0.1, function() timer_box11 = true end)


	alphabox2 = 0
	timer_box2 = true
	timer_box21 = false
	box2_s = ScrW() * 0.3
	timer.Simple(0.4, function() timer_box2 = false end)
	timer.Simple(0.2, function() timer_box21 = true end)

	alphabox3 = 0
	timer_box3 = true
	timer_box31 = false
	box3_s = ScrW() * 0.3
	timer.Simple(0.5, function() timer_box3 = false end)
	timer.Simple(0.3, function() timer_box31 = true end)


	alphabox4 = 0
	timer_box4 = true
	timer_box41 = false
	box4_s = ScrW() * 0.3
	timer.Simple(0.6, function() timer_box4 = false end)
	timer.Simple(0.4, function() timer_box41 = true end)








	alphaword1 = 0
	timer_word1 = true
	timer_word11 = false
	word1_s = ScrW() * 0.1
	timer.Simple(0.7, function() timer_word1 = false end)
	timer.Simple(0.5, function() timer_word11 = true end)

	alphaword2 = 0
	timer_word2 = true
	timer_word21 = false
	word2_s = ScrW() * 0.13
	timer.Simple(0.8, function() timer_word2 = false end)
	timer.Simple(0.6, function() timer_word21 = true end)

	alphaword3 = 0
	timer_word3 = true
	timer_word31 = false
	word3_s = ScrW() * 0.13
	timer.Simple(0.9, function() timer_word3 = false end)
	timer.Simple(0.7, function() timer_word31 = true end)

	alphaword4 = 0
	timer_word4 = true
	timer_word41 = false
	word4_s = ScrW() * 0.13
	timer.Simple(1, function() timer_word4 = false end)
	timer.Simple(0.8, function() timer_word41 = true end)

	alphaword5 = 0
	timer_word5 = true
	timer_word51 = false
	word5_s = ScrW() * 0.13
	timer.Simple(1.1, function() timer_word5 = false end)
	timer.Simple(0.9, function() timer_word51 = true end)

	alphaword6 = 0
	timer_word6 = true
	timer_word61 = false
	word6_s = ScrW() * 0.13
	timer.Simple(1.2, function() timer_word6 = false end)
	timer.Simple(1, function() timer_word61 = true end)

	alphaword7 = 0
	timer_word7 = true
	timer_word71 = false
	word7_s = ScrW() * 0.13
	timer.Simple(1.3, function() timer_word7 = false end)
	timer.Simple(1.1, function() timer_word71 = true end)
	surface.PlaySound("investigation_freetime.mp3")
	hook.Add("HUDPaint", "investigation.anim", function() 
		if start_anim then 
        	hs = Lerp(FrameTime() * 10, hs, ScrH())
        	x_f = Lerp(FrameTime() / 2, x_f, 100)
        else 
        	hs = Lerp(FrameTime() * 10, hs, 0)
        	x_f = Lerp(FrameTime() * 10, x_f, ScrW())
        end
        if timer_box11 then 
	        if timer_box1 then 
	        	box1_s = Lerp(FrameTime() * 20, box1_s, ScrW() * 0.1)
	        else 
	        	box1_s = Lerp(FrameTime() * 20, box1_s, ScrW() * 0.2)
	        end
	        alphabox1 = Lerp(FrameTime() * 10, alphabox1, 255)
        end

        if timer_box21 then 
	        if timer_box2 then 
	        	box2_s = Lerp(FrameTime() * 20, box2_s, ScrW() * 0.1)
	        else 
	        	box2_s = Lerp(FrameTime() * 20, box2_s, ScrW() * 0.2)
	        end
	        alphabox2 = Lerp(FrameTime() * 10, alphabox2, 255)
        end

        if timer_box31 then 
	        if timer_box3 then 
	        	box3_s = Lerp(FrameTime() * 20, box3_s, ScrW() * 0.1)
	        else 
	        	box3_s = Lerp(FrameTime() * 20, box3_s, ScrW() * 0.2)
	        end
	        alphabox3 = Lerp(FrameTime() * 10, alphabox3, 255)
        end

        if timer_box41 then 
	        if timer_box4 then 
	        	box4_s = Lerp(FrameTime() * 20, box4_s, ScrW() * 0.1)
	        else 
	        	box4_s = Lerp(FrameTime() * 20, box4_s, ScrW() * 0.2)
	        end
	        alphabox4 = Lerp(FrameTime() * 10, alphabox4, 255)
        end


		surface.SetDrawColor( 255, 255, 255, 255 ) 
		surface.SetMaterial( line ) 
		surface.DrawTexturedRectRotated( ScrW()/2, ScrH()/2, ScrW(), hs, 0 )

		surface.SetDrawColor( 255, 255, 255, alphaword4 ) 
		surface.SetMaterial( Material("investigation/k_2.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.5 + x_f, ScrH() * 0.45, word4_s * 2, word4_s * 2, 0 )	

		surface.SetDrawColor( 255, 255, 255, alphaword3 ) 
		surface.SetMaterial( Material("investigation/k_5.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.64 + x_f, ScrH() * 0.45, word3_s * 2, word3_s * 2, 0 )			

		surface.SetDrawColor( 255, 255, 255, alphaword1 ) 
		surface.SetMaterial( Material("investigation/k_2.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.3 + x_f, ScrH() * 0.53, word1_s * 2, word1_s * 2, 0 )		

		surface.SetDrawColor( 255, 255, 255, alphabox1 ) 
		surface.SetMaterial( box1 ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.35 + x_f, ScrH()/2, box1_s, box1_s, 0 )

		surface.SetDrawColor( 255, 255, 255, alphabox2 ) 
		surface.SetMaterial( box2 ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.465 + x_f, ScrH()/2, box2_s, box2_s, 0 )

		surface.SetDrawColor( 255, 255, 255, alphabox3 ) 
		surface.SetMaterial( box3 ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.555 + x_f, ScrH()/2, box3_s, box3_s, 0 )

		surface.SetDrawColor( 255, 255, 255, alphabox4 ) 
		surface.SetMaterial( box4 ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.65 + x_f, ScrH()/2, box4_s, box4_s, 0 )



		-- БУКВЫ


        if timer_word11 then 
	        if timer_word1 then 
	        	word1_s = Lerp(FrameTime() * 20, word1_s, ScrW() * 0.03)
	        else 
	        	word1_s = Lerp(FrameTime() * 20, word1_s, ScrW() * 0.08)
	        end
	        alphaword1 = Lerp(FrameTime() * 10, alphaword1, 255)
        end

        if timer_word21 then 
	        if timer_word2 then 
	        	word2_s = Lerp(FrameTime() * 20, word2_s, ScrW() * 0.05)
	        else 
	        	word2_s = Lerp(FrameTime() * 20, word2_s, ScrW() * 0.1)
	        end
	        alphaword2 = Lerp(FrameTime() * 10, alphaword2, 255)
        end

        if timer_word31 then 
	        if timer_word3 then 
	        	word3_s = Lerp(FrameTime() * 20, word3_s, ScrW() * 0.05)
	        else 
	        	word3_s = Lerp(FrameTime() * 20, word3_s, ScrW() * 0.1)
	        end
	        alphaword3 = Lerp(FrameTime() * 10, alphaword3, 255)
        end

        if timer_word41 then 
	        if timer_word4 then 
	        	word4_s = Lerp(FrameTime() * 20, word4_s, ScrW() * 0.05)
	        else 
	        	word4_s = Lerp(FrameTime() * 20, word4_s, ScrW() * 0.1)
	        end
	        alphaword4 = Lerp(FrameTime() * 10, alphaword4, 255)
        end

        if timer_word51 then 
	        if timer_word5 then 
	        	word5_s = Lerp(FrameTime() * 20, word5_s, ScrW() * 0.05)
	        else 
	        	word5_s = Lerp(FrameTime() * 20, word5_s, ScrW() * 0.1 * 1.2 )
	        end
	        alphaword5 = Lerp(FrameTime() * 10, alphaword5, 255)
        end

        if timer_word61 then 
	        if timer_word6 then 
	        	word6_s = Lerp(FrameTime() * 20, word6_s, ScrW() * 0.05)
	        else 
	        	word6_s = Lerp(FrameTime() * 20, word6_s, ScrW() * 0.1 * 1.1)
	        end
	        alphaword6 = Lerp(FrameTime() * 10, alphaword6, 255)
        end

        if timer_word71 then 
	        if timer_word7 then 
	        	word7_s = Lerp(FrameTime() * 20, word7_s, ScrW() * 0.05)
	        else 
	        	word7_s = Lerp(FrameTime() * 20, word7_s, ScrW() * 0.1 * 1.1)
	        end
	        alphaword7 = Lerp(FrameTime() * 10, alphaword7, 255)
        end

		surface.SetDrawColor( 255, 255, 255, alphaword1 ) 
		surface.SetMaterial( Material("investigation/k_1.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.33 + x_f, ScrH() * 0.44, word1_s * 2, word1_s * 2, 0 )	


		surface.SetDrawColor( 255, 255, 255, alphaword6 ) 
		surface.SetMaterial( Material("investigation/k_4.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.52 + x_f, ScrH() * 0.5, word6_s * 2, word6_s * 2, 0 )	




		surface.SetDrawColor( 255, 255, 255, alphaword1 ) 
		surface.SetMaterial( Material("investigation/na.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.33 + x_f, ScrH() * 0.437, word1_s, word1_s, 0 )	

		surface.SetDrawColor( 255, 255, 255, alphaword2 ) 
		surface.SetMaterial( Material("investigation/cha.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.332 + x_f, ScrH() * 0.55, word2_s, word2_s, 0 )	


		surface.SetDrawColor( 255, 255, 255, alphaword3 ) 
		surface.SetMaterial( Material("investigation/lo.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.41 + x_f, ScrH() * 0.51, word3_s, word3_s, 0 )	

		surface.SetDrawColor( 255, 255, 255, alphaword4 ) 
		surface.SetMaterial( Material("investigation/ras.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.5 + x_f, ScrH() * 0.45, word4_s, word4_s, 0 )	

		surface.SetDrawColor( 255, 255, 255, alphaword5 ) 
		surface.SetMaterial( Material("investigation/sle.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.62 + x_f, ScrH() * 0.45, word5_s * 1.2, word5_s * 1.2, 0 )	

		surface.SetDrawColor( 255, 255, 255, alphaword6 ) 
		surface.SetMaterial( Material("investigation/dov.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.52 + x_f, ScrH() * 0.53, word6_s * 1.1, word6_s * 1.1, -10 )	

		surface.SetDrawColor( 255, 255, 255, alphaword7 ) 
		surface.SetMaterial( Material("investigation/ania.png", "smooth") ) 
		surface.DrawTexturedRectRotated( ScrW() * 0.62 + x_f, ScrH() * 0.55, word7_s * 1.1, word7_s * 1.1, 20 )	

	end)


end

concommand.Add("Startinvestigation", investigation.Start)