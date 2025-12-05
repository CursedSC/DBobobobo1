local matColor = Material( "pp/colour" )
matColor:SetTexture( "$fbtexture", render.GetScreenEffectTexture() )
matColor:SetFloat( "$pp_colour_addr", 0.5 )
matColor:SetFloat( "$pp_colour_addg", 0.5 )
matColor:SetFloat( "$pp_colour_addb", 0.5 )
matColor:SetFloat( "$pp_colour_contrast", 0.5 )
matColor:SetFloat( "$pp_colour_colour", 0.9 )
matColor:SetFloat( "$pp_colour_brightness", -0.5 )

local mapp, mclamp = math.Approach, math.Clamp
hook.Add( "RenderScreenspaceEffects", "MotionBlurEffect", function()
	if GDown then
		DrawMotionBlur( 0.5, 1, 0.01 )
        render.SetMaterial( matColor )
        render.DrawScreenQuad()
	end
end )

WL_Wep = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
}

local headBoneName = "ValveBiped.Bip01_Head1"

local function GetDeathRagdollView(ragdoll)
    if not IsValid(ragdoll) then return end

    local attachmentIndex = ragdoll:LookupAttachment("eyes")
    if attachmentIndex and attachmentIndex > 0 then
        local attachment = ragdoll:GetAttachment(attachmentIndex)
        if attachment then
            return attachment.Pos, attachment.Ang
        end
    end

    local boneIndex = ragdoll:LookupBone(headBoneName)
    if boneIndex then
        local pos, ang = ragdoll:GetBonePosition(boneIndex)
        if pos and ang then
            return pos, ang
        end
    end

    return ragdoll:WorldSpaceCenter() + ragdoll:GetUp() * 4, ragdoll:GetAngles()
end

fn_fraction = 0 
hook.Add( "CalcView", "dbt.CalcView.self", function( ply, pos, angles, fov )
    if IsValid(RAGGDOLL_WOUNDS_ENT) then return end
    local deathRagdoll = ply:GetNWEntity("DeathRagdoll")
    if not ply:Alive() then
        if IsValid(deathRagdoll) then
            local origin, ang = GetDeathRagdollView(deathRagdoll)
            if origin and ang then
                CurView = nil
                return {
                    origin = origin,
                    angles = ang,
                    fov = fov,
                    drawviewer = false
                }
            end
        end

        CurView = nil
        return
    end

    if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and WL_Wep[ply:GetActiveWeapon():GetClass()] then CurView = angles return end
    if fp_enb then
        eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))
        local view = {
            origin = eyeAtt.Pos,
            angles = eyeAtt.Ang,
            fov = fov,
            drawviewer = true
        }

        return view
    elseif IsValid(ply:GetActiveWeapon()) then
        local view = {}
        eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))
        FT = FrameTime()
        cof_cam = 0.01
        if ply:IsRunning() then 
            cof_cam = 0.2
        end 
        
        if not CurView then
            CurView = angles
        else
            CurView = LerpAngle(mclamp(FT * (35 * (1 - mclamp(0.1, 0, 0.8))), 0, 1), CurView, angles + Angle(eyeAtt.Ang.p * cof_cam, 0, eyeAtt.Ang.r * 0.1))
        end
        
        if GDown then 
            fov = fov - 10
        end

        view.origin = pos
        view.angles = CurView
        view.fov = fov
        view.znear = mclamp(0.4, 0.1, 1)
        view.drawviewer = false
                
        return view
    end

end )



local tab = {

    [ "$pp_colour_addr" ] = 0,

    [ "$pp_colour_addg" ] = 0,

    [ "$pp_colour_addb" ] = 0.15,

    [ "$pp_colour_brightness" ] = -0.3,

    [ "$pp_colour_contrast" ] = 1.5,

    [ "$pp_colour_colour" ] = 0.75,

    [ "$pp_colour_mulr" ] = 0,

    [ "$pp_colour_mulg" ] = 0,

    [ "$pp_colour_mulb" ] = 0.5

}



local tab2 = {

    [ "$pp_colour_addr" ] = 0,

    [ "$pp_colour_addg" ] = 0,

    [ "$pp_colour_addb" ] = 0,

    [ "$pp_colour_brightness" ] = 0,

    [ "$pp_colour_contrast" ] = 1,

    [ "$pp_colour_colour" ] = 1,

    [ "$pp_colour_mulr" ] = 0,

    [ "$pp_colour_mulg" ] = 0,

    [ "$pp_colour_mulb" ] = 0

}





local mat = Material("pp/texturize/plain.png")



local blurMat2 = Material("pp/blurscreen")
local blurPasses = 10
local blurAlpha = 55
local blurScale = 0.45
local blurMaxStrength = 9



function BlurScreen(amount)
   // if not amount or amount <= 0 then return end
//
   // local scrw, scrh = ScrW(), ScrH()
   // local strength = math.Clamp(amount * blurScale, 0, blurMaxStrength)
   // if strength <= 0 then return end
//
   // surface.SetDrawColor(255, 255, 255, blurAlpha)
   // surface.SetMaterial(blurMat2)
//
   // for i = 1, blurPasses do
   //     local passStrength = strength * (i / blurPasses)
   //     blurMat2:SetFloat("$blur", passStrength)
   //     blurMat2:Recompute()
   //     render.UpdateScreenEffectTexture()
   //     surface.DrawTexturedRect(0, 0, scrw, scrh)
   // end
end



hook.Add("RenderScreenspaceEffects","BloomEffect-dbt",function()

    if LocalPlayer():Alive() then

        if IsValid(dbt_emote.wheel) then BlurScreen(24) end

        local hp = LocalPlayer():Health()
        
        
        if hp <= 30 then 
            tab2["$pp_colour_colour"] = hp / 100
            DrawColorModify(tab2)
        end
        if hp <= 20 then 
            BlurScreen(10)
        end
    end

end)



