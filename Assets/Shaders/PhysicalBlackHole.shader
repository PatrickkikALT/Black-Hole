Shader "HDRP/PhysicalBlackHole"
{
    Properties
    {
        _BH_Mass("Mass", Float) = 0.03
        _BH_DiskInner("Disk Inner Radius", Float) = 0.065
        _BH_DiskOuter("Disk Outer Radius", Float) = 0.38
        [HDR] _BH_AccretionHotColor("Accretion Hot", Color) = (6, 3.4, 1.45, 1)
        [HDR] _BH_AccretionCoolColor("Accretion Cool", Color) = (1.35, 0.38, 0.09, 1)
        _BH_DiskDensity("Disk Density", Float) = 1.35
        _BH_Temperature("Temperature", Float) = 1.35
        _BH_StepCount("Raymarch Steps", Float) = 192
        _BH_EnableDoppler("Doppler", Float) = 1
        _BH_EnableRedshift("Gravitational Redshift", Float) = 1
        _BH_BoundRadius("Bound Radius", Float) = 0.5

        [HideInInspector][MainColor] _UnlitColor("Color", Color) = (0,0,0,1)
        [HideInInspector][MainTexture] _UnlitColorMap("ColorMap", 2D) = "white" {}
        [HideInInspector] _AlphaRemapMin("AlphaRemapMin", Float) = 0.0
        [HideInInspector] _AlphaRemapMax("AlphaRemapMax", Float) = 1.0
        [HideInInspector][HDR] _EmissiveColor("EmissiveColor", Color) = (0,0,0)
        [HideInInspector] _EmissiveColorMap("EmissiveColorMap", 2D) = "white" {}
        [HideInInspector] _EmissiveColorLDR("EmissiveColor LDR", Color) = (0,0,0)
        [HideInInspector] _AlbedoAffectEmissive("Albedo Affect Emissive", Float) = 0.0
        [HideInInspector] _EmissiveIntensityUnit("Emissive Mode", Int) = 0
        [HideInInspector] _UseEmissiveIntensity("Use Emissive Intensity", Int) = 0
        [HideInInspector] _EmissiveIntensity("Emissive Intensity", Float) = 1
        [HideInInspector] _EmissiveExposureWeight("Emissive Pre Exposure", Range(0.0, 1.0)) = 1.0
        [HideInInspector] _DistortionVectorMap("DistortionVectorMap", 2D) = "black" {}
        [HideInInspector] _DistortionEnable("Enable Distortion", Float) = 0.0
        [HideInInspector] _DistortionOnly("Distortion Only", Float) = 0.0
        [HideInInspector] _DistortionDepthTest("Distortion Depth Test Enable", Float) = 1.0
        [HideInInspector] _DistortionBlendMode("Distortion Blend Mode", Int) = 0
        [HideInInspector] _DistortionSrcBlend("Distortion Blend Src", Int) = 0
        [HideInInspector] _DistortionDstBlend("Distortion Blend Dst", Int) = 0
        [HideInInspector] _DistortionBlurSrcBlend("Distortion Blur Blend Src", Int) = 0
        [HideInInspector] _DistortionBlurDstBlend("Distortion Blur Blend Dst", Int) = 0
        [HideInInspector] _DistortionBlurBlendMode("Distortion Blur Blend Mode", Int) = 0
        [HideInInspector] _DistortionScale("Distortion Scale", Float) = 1
        [HideInInspector] _DistortionVectorScale("Distortion Vector Scale", Float) = 2
        [HideInInspector] _DistortionVectorBias("Distortion Vector Bias", Float) = -1
        [HideInInspector] _DistortionBlurScale("Distortion Blur Scale", Float) = 1
        [HideInInspector] _DistortionBlurRemapMin("DistortionBlurRemapMin", Float) = 0.0
        [HideInInspector] _DistortionBlurRemapMax("DistortionBlurRemapMax", Float) = 1.0
        [HideInInspector] _AlphaCutoffEnable("Alpha Cutoff Enable", Float) = 0.0
        [HideInInspector] _AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _TransparentSortPriority("_TransparentSortPriority", Float) = 0
        [HideInInspector] _SurfaceType("__surfacetype", Float) = 1.0
        [HideInInspector] _BlendMode("__blendmode", Float) = 4.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 6.0
        [HideInInspector] _AlphaSrcBlend("__alphaSrc", Float) = 1.0
        [HideInInspector] _AlphaDstBlend("__alphaDst", Float) = 6.0
        [HideInInspector] _ZWrite("__zw", Float) = 0.0
        [HideInInspector] _TransparentZWrite("_TransparentZWrite", Float) = 0.0
        [HideInInspector] _CullMode("__cullmode", Float) = 2.0
        [HideInInspector] _TransparentCullMode("_TransparentCullMode", Int) = 2
        [HideInInspector] _OpaqueCullMode("_OpaqueCullMode", Int) = 2
        [HideInInspector] _ZTestModeDistortion("_ZTestModeDistortion", Int) = 8
        [HideInInspector] _ZTestTransparent("Transparent ZTest", Int) = 4
        [HideInInspector] _ZTestDepthEqualForOpaque("_ZTestDepthEqualForOpaque", Int) = 4
        [HideInInspector] _EnableFogOnTransparent("Enable Fog", Float) = 0.0
        [HideInInspector] _DoubleSidedEnable("Double sided enable", Float) = 1.0
        [HideInInspector] _StencilRef("_StencilRef", Int) = 0
        [HideInInspector] _StencilWriteMask("_StencilWriteMask", Int) = 3
        [HideInInspector] _StencilRefDepth("_StencilRefDepth", Int) = 0
        [HideInInspector] _StencilWriteMaskDepth("_StencilWriteMaskDepth", Int) = 8
        [HideInInspector] _StencilRefMV("_StencilRefMV", Int) = 32
        [HideInInspector] _StencilWriteMaskMV("_StencilWriteMaskMV", Int) = 32
        [HideInInspector] _AddPrecomputedVelocity("AddPrecomputedVelocity", Float) = 0.0
        [HideInInspector] _StencilRefDistortionVec("_StencilRefDistortionVec", Int) = 2
        [HideInInspector] _StencilWriteMaskDistortionVec("_StencilWriteMaskDistortionVec", Int) = 2
        [HideInInspector] _EmissionColor("Color", Color) = (1,1,1)
        [HideInInspector] _IncludeIndirectLighting("_IncludeIndirectLighting", Float) = 1.0
        [HideInInspector] _MainTex("Albedo", 2D) = "white" {}
        [HideInInspector] _Color("Color", Color) = (0,0,0,1)
        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
    }

    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch switch2
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/UnlitProperties.hlsl"
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "HDRenderPipeline"
            "RenderType" = "HDUnlitShader"
            "Queue" = "Transparent+100"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }

            Cull Off
            ZWrite On

            HLSLPROGRAM
            #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch switch2
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #define SCENESELECTIONPASS
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/PickingSpaceTransforms.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/Unlit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/ShaderPass/UnlitDepthPass.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/UnlitData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation
            ENDHLSL
        }

        Pass
        {
            Name "ForwardOnly"
            Tags
            {
                "LightMode" = "ForwardOnly"
            }

            Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back
            ColorMask RGBA

            HLSLPROGRAM
            #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch switch2
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma multi_compile _ DEBUG_DISPLAY

            #define _SURFACE_TYPE_TRANSPARENT
            #define _DISABLE_DECALS
            #define REQUIRE_OPAQUE_TEXTURE
            #define ATTRIBUTES_NEED_NORMAL
            #define VARYINGS_NEED_POSITION_WS
            #define SHADERPASS SHADERPASS_FORWARD_UNLIT

            #ifdef DEBUG_DISPLAY
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #endif

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/Unlit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/ShaderPass/UnlitSharePass.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Sampling/SampleUVMapping.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Builtin/BuiltinData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "BlackHoleVolumetric.hlsl"

            void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput,
                                          out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                ZERO_BUILTIN_INITIALIZE(builtinData);

                float3 localPos = TransformWorldToObject(input.positionRWS);
                float3 localCam = TransformWorldToObject(GetCurrentViewPosition());
                float3 localRay = localPos - localCam;
                float rayLen = length(localRay);
                localRay = rayLen > 1e-8 ? localRay / rayLen : float3(0, 0, 1);

                float2 screenUV = input.positionSS.xy * _ScreenSize.zw;

                float4 bh;
                BlackHoleMarch(localCam, localRay, _BH_Mass, _BH_DiskInner, _BH_DiskOuter,
                               _BH_StepCount, screenUV, bh);

                surfaceData.color = 0;
                surfaceData.normalWS = float3(0, 0, 1);
                builtinData.opacity = bh.a;
                builtinData.emissiveColor = bh.rgb;
            }

            #include_with_pragmas "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"

            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
}