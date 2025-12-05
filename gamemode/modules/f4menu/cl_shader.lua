


--[[
	Credits: Akabenko&EskiDost
	https://steamcommunity.com/id/amede/
	https://steamcommunity.com/id/EskiDost

	Subpixel Morphological Anti-Aliasing (SMAA)
	https://github.com/iryoku/smaa/tree/master
]]

local shaderName = "SMAA"

local r_smaa = CreateClientConVar( "r_smaa", "0", false, false, "Enable/Disable SMAA.", 0, 1 )
local r_smaa_threshold = CreateClientConVar( "r_smaa_threshold", "0.1", true, false, "SMAA THRESHOLD.", 0, 0.5 )
local r_smaa_max_search_steps = CreateClientConVar( "r_smaa_max_search_steps", "32", true, false, "SMAA MAX SEARCH STEPS.", 0, 112 )
local r_smaa_max_search_steps_diag = CreateClientConVar( "r_smaa_max_search_steps_diag", "16", true, false, "SMAA MAX SEARCH STEPS DIAG.", 0, 20 )
local r_smaa_corner_rounding = CreateClientConVar( "r_smaa_corner_rounding", "25", true, false, "SMAA CORNER ROUNDING.", 0, 100 )
local r_smaa_debug = CreateClientConVar( "r_smaa_debug", "0", false, false, "SMAA DEBUG MODE.", 0, 2 )
local r_smaa_debug_show = CreateClientConVar( "r_smaa_debug_show", "0", false, false, "SMAA SHOW CHANGES.", 0, 1 )

local SMAAEdgeDetection = Material("shaders/SMAAEdgeDetection")
local SMAABlendingWeight = Material("shaders/SMAABlendingWeight")
local SMAANeighborhood = Material("shaders/SMAANeighborhood")

local rt = GetRenderTarget('_rt_SMAAEdgeDetection', ScrW(), ScrH())
local rt2 = GetRenderTarget('_rt_SMAABlendingWeight', ScrW(), ScrH())

local test_SMAAEdgeDetection = CreateMaterial("test_SMAAEdgeDetection", "UnlitGeneric", {
	["$basetexture"] = "_rt_SMAAEdgeDetection",
})

local test_SMAABlendingWeight = CreateMaterial("test_SMAABlendingWeight", "UnlitGeneric", {
	["$basetexture"] = "_rt_SMAABlendingWeight",
})

local screentexture = render.GetScreenEffectTexture()

local color_0_255_0 = Color( 0, 255, 0, 255 )
local color_0_255_255 = Color( 0, 255, 255, 255 )

local function SMAA()
    render.UpdateScreenEffectTexture()
    render.CopyRenderTargetToTexture(screentexture)

    render.PushRenderTarget(rt)
        render.Clear(0,0,0,0)
        render.SetMaterial(SMAAEdgeDetection)
        render.DrawScreenQuad()
    render.PopRenderTarget()

    render.PushRenderTarget(rt2)
        render.Clear(0,0,0,0)
        render.SetMaterial(SMAABlendingWeight)
        render.DrawScreenQuad()
    render.PopRenderTarget()

    render.SetMaterial(SMAANeighborhood)
    render.DrawScreenQuad()
end

cvars.AddChangeCallback( r_smaa:GetName(), function( convar_name, _, identifier )
	local activate = identifier == "1"

	if activate then
		hook.Add("RenderScreenspaceEffects", shaderName, SMAA)
	else
		hook.Remove("RenderScreenspaceEffects", shaderName)
	end
end, shaderName )

local function SMAASetFloat(key, value)
	SMAAEdgeDetection:SetFloat(key, value)
	SMAABlendingWeight:SetFloat(key, value)
	SMAANeighborhood:SetFloat(key, value)
end

cvars.AddChangeCallback( r_smaa_threshold:GetName(), function( convar_name, _, identifier )
	SMAASetFloat("$c0_x", identifier)
end, shaderName )

cvars.AddChangeCallback( r_smaa_max_search_steps:GetName(), function( convar_name, _, identifier )
	SMAASetFloat("$c0_y", identifier)
end, shaderName )

cvars.AddChangeCallback( r_smaa_max_search_steps_diag:GetName(), function( convar_name, _, identifier )
	SMAASetFloat("$c0_z", identifier)
end, shaderName )

cvars.AddChangeCallback( r_smaa_corner_rounding:GetName(), function( convar_name, _, identifier )
	SMAASetFloat("$c0_w", identifier)
end, shaderName )

local smaaPresets = {
    [1] = {
        ["r_smaa"] = "0",
        ["r_smaa_threshold"] = "0.1",
        ["r_smaa_max_search_steps"] = "32",
        ["r_smaa_max_search_steps_diag"] = "16",
        ["r_smaa_corner_rounding"] = "25",
    },
    [2] = {
        ["r_smaa"] = "1",
        ["r_smaa_threshold"] = "0.15",
        ["r_smaa_max_search_steps"] = "4",
        ["r_smaa_max_search_steps_diag"] = "16",
        ["r_smaa_corner_rounding"] = "25",
    },
    [3] = {
        ["r_smaa"] = "1",
        ["r_smaa_threshold"] = "0.1",
        ["r_smaa_max_search_steps"] = "8",
        ["r_smaa_max_search_steps_diag"] = "16",
        ["r_smaa_corner_rounding"] = "25",
    },
    [4] = {
        ["r_smaa"] = "1",
        ["r_smaa_threshold"] = "0.1",
        ["r_smaa_max_search_steps"] = "16",
        ["r_smaa_max_search_steps_diag"] = "8",
        ["r_smaa_corner_rounding"] = "25",
    },
    [5] = {
        ["r_smaa"] = "1",
        ["r_smaa_threshold"] = "0.05",
        ["r_smaa_max_search_steps"] = "32",
        ["r_smaa_max_search_steps_diag"] = "16",
        ["r_smaa_corner_rounding"] = "25",
    }
}

settings.OnValueHook("setting", "smaa", function( value )
    if value and smaaPresets[value] then
        for k, v in pairs(smaaPresets[value]) do
            RunConsoleCommand(k, v)
        end
    end
end)

settings.OnValueHook("setting", "ssao", function( value )
   if value then
        RunConsoleCommand("pp_ssao", "1")
        RunConsoleCommand("pp_ssao_debug", "0")
        RunConsoleCommand("pp_ssao_contrast", "1.17")
        RunConsoleCommand("pp_ssao_radius", "16")
        RunConsoleCommand("pp_ssao_luminfluence", "0")
        RunConsoleCommand("pp_ssao_bias", "0")
        RunConsoleCommand("pp_ssao_bias_offset", "0.06")
        RunConsoleCommand("pp_ssao_custom_depth", "1")
        RunConsoleCommand("pp_ssao_znear", "0.01")
        RunConsoleCommand("pp_ssao_zfar", "0.10")
        RunConsoleCommand("pp_ssao_quality", "32")
    else
        RunConsoleCommand("pp_ssao", "0")
    end
end)




-----------------


local shaderName = "SSAO"

local pp_ssao = CreateClientConVar( "pp_ssao", "0", false, false, "Enable/Disable screen space ambient occlusion.", 0, 1 )
local pp_ssao_contrast = CreateClientConVar( "pp_ssao_contrast", "1", true, false, "SSAO contrast.", 0, 5 )
local pp_ssao_radius = CreateClientConVar( "pp_ssao_radius", "16", true, false, "SSAO radius.", 1, 32 )
local pp_ssao_luminfluence = CreateClientConVar( "pp_ssao_luminfluence", "2.1", true, false, "SSAO luminfluence.", 0, 10 )
local pp_ssao_bias = CreateClientConVar( "pp_ssao_bias", "0.2", true, false, "SSAO bias.", 0, 2 )
local pp_ssao_bias_offset = CreateClientConVar( "pp_ssao_bias_offset", "0.0", true, false, "SSAO radius offset.", 0, 1 )
local pp_ssao_custom_depth = CreateClientConVar( "pp_ssao_custom_depth", "1", true, false, "Custom depth buffer have more bits but have no alphatest support.", 0, 1 )
local pp_ssao_znear = CreateClientConVar( "pp_ssao_znear", "1.0", true, false, "SSAO radius offset.", 0.01, 100 )
local pp_ssao_zfar = CreateClientConVar( "pp_ssao_zfar", "1.0", true, false, "SSAO radius offset.", 0.1, 1000 )
local pp_ssao_quality = CreateClientConVar( "pp_ssao_quality", "16", true, false, "SSAO quality. 32 - very hight, 16 - hight, 8 - normal, 4 - low", 1, 32 )


local dw = CreateMaterial("_DepthWrite"..math.random(1,1000000), "DepthWrite", {
    ["$no_fullbright"] = "1",
    ["$color_depth"] = "1",
    ["$model"] = "1",
})

local textureRT = GetRenderTargetEx("_rt_FullFrameDepth_Alt", 
    ScrW(), ScrH(), 
    RT_SIZE_NO_CHANGE,
    MATERIAL_RT_DEPTH_SHARED,
    bit.bor(2, 256),
    0,
    24 
)
local renderMat = CreateMaterial("_rt_depthpro_mat"..math.random(1,1000000), "UnlitGeneric", {
    ["$basetexture"] = textureRT:GetName();
})

bDrawDepth = false

local function getShadowColor()
	local shadowcontroller = ents.FindByClass("class C_ShadowControl")[1]

	if IsValid(shadowcontroller) then
		return shadowcontroller:GetColor()
	else
		local ambientColor = render.GetAmbientLightColor()
		return Color(ambientColor.r*255,ambientColor.g*255,ambientColor.b*255)
	end
end

local function RenderCustomDepth()
	bDrawDepth = true
	render.PushRenderTarget( textureRT )
	
    render.Clear(0,0,0,0)
    
    render.OverrideDepthEnable( true, true ) 
    render.MaterialOverride(dw)
    render.BrushMaterialOverride( dw )
    render.WorldMaterialOverride( dw )

    render.ModelMaterialOverride( dw )
    	local shadow_color = getShadowColor()

        render.SetShadowColor(255,255,255)
        render.RenderView()
        render.SetShadowColor(shadow_color.r,shadow_color.g,shadow_color.b)

    render.MaterialOverride(nil);
    render.BrushMaterialOverride( nil )
    render.WorldMaterialOverride( nil )
    render.ModelMaterialOverride( nil )

    render.OverrideDepthEnable( false, false ) 

	render.PopRenderTarget()
	bDrawDepth = false
end
 
RenderHalos = RenderHalos or hook.GetTable()["PostDrawEffects"]["RenderHalos"]

hook.Add( "PostDrawEffects", "RenderHalos", function()
    if bDrawDepth then return end
    RenderHalos()
end)

-- To Fix Skybox
local min = Vector(1,1,1)*16000;
local max = Vector(1,1,1)*16000;

local function DepthWriteSkybox()
	local rt = render.GetRenderTarget()
    if !rt or rt:GetName() != "_rt_fullframedepth_alt" then  
        return
    end
    local cViewSetup = render.GetViewSetup();

    render.SetMaterial( dw )
    render.SetColorMaterial()
    render.DrawScreenQuad();
end

local scale = 0.4;

local screentexture = render.GetScreenEffectTexture()

local ssao_mat = Material("pp/pp_ssao")
local ssao_rt = GetRenderTarget('_rt_SSAO', ScrW(), ScrH())
local ssao_blur_mat = Material("pp/pp_ssao_blur")

ssao_mat:SetTexture("$texture1", textureRT)
ssao_blur_mat:SetTexture("$texture1", ssao_rt)

hook.Add("NeedsDepthPass", shaderName, function()
	return true
end)


local function RenderSSAO()
	render.PushRenderTarget(ssao_rt)
		render.Clear(0,0,0,0,true,true)
		render.SetMaterial(ssao_mat)
	    render.DrawScreenQuad()
    render.PopRenderTarget()

    render.UpdateScreenEffectTexture()
	render.CopyRenderTargetToTexture(screentexture)
	render.SetMaterial(ssao_blur_mat)
	render.DrawScreenQuad()

end

cvars.AddChangeCallback( pp_ssao:GetName(), function( convar_name, _, identifier )
	local enabled = identifier == "1"

	if enabled then
		hook.Add("RenderScreenspaceEffects", shaderName, RenderSSAO)
		hook.Add( "RenderScene", "RenderDepthWrite", RenderCustomDepth)
		hook.Add("PostDraw2DSkyBox", "DepthWriteSkybox", DepthWriteSkybox)
	else
		hook.Remove("RenderScreenspaceEffects",shaderName)
		hook.Remove("HUDPaint", "debug_view")
		hook.Remove("RenderScene", "RenderDepthWrite")
		hook.Remove("PostDraw2DSkyBox", "DepthWriteSkybox", DepthWriteSkybox)
	end

end, shaderName )


cvars.AddChangeCallback( pp_ssao_contrast:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c0_z", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_radius:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c1_z", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_luminfluence:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c0_w", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_bias:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c1_x", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_bias_offset:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c1_y", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_custom_depth:GetName(), function( convar_name, _, identifier )
	local enabled = identifier == "1"
	if enabled then
		ssao_mat:SetTexture("$texture1", textureRT)
		hook.Add( "RenderScene", "RenderDepthWrite", RenderCustomDepth)
	else
		ssao_mat:SetTexture("$texture1", render.GetResolvedFullFrameDepth())
		hook.Remove( "RenderScene", "RenderDepthWrite")
	end
end, shaderName )

cvars.AddChangeCallback( pp_ssao_bias:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c1_x", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_bias_offset:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c1_y", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_znear:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c0_x", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_zfar:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c0_y", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_ssao_quality:GetName(), function( convar_name, _, identifier )
	ssao_mat:SetFloat("$c1_w", identifier)
end, shaderName )


