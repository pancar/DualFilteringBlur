Shader "Hidden/DualFilteringBlur"
{
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

    float _BlurScale;

    float4 DownsamplePass(Varyings input) : SV_Target0
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        float4 color = float4(0, 0, 0, 0);
        float2 halfpixel = _BlitTexture_TexelSize.xy * 0.5;
        float2 offset = float2(1.0 + _BlurScale, 1.0 + _BlurScale);

        color = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, input.texcoord, _BlitMipLevel) * 4.0;
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, input.texcoord - halfpixel*offset,
                                        _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp, input.texcoord + halfpixel*offset,
                                        _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                                                                    input.texcoord + float2(halfpixel.x,-halfpixel.y) *
                                                                    offset,
                                                                    _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
     input.texcoord - float2(halfpixel.x,-halfpixel.y)*offset, _BlitMipLevel);
        return color / 8.0;
    }

    float4 UpsamplePass(Varyings input) : SV_Target0
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        float4 color = float4(0, 0, 0, 0);
        float2 halfpixel = _BlitTexture_TexelSize.xy * 0.5;
        float2 offset = float2(1.0 + _BlurScale, 1.0 + _BlurScale);


        color = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                        input.texcoord + float2(-halfpixel.x * 2,0) * offset,
                        _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                               input.texcoord + float2(-halfpixel.x ,halfpixel.y) *
                               offset, _BlitMipLevel) * 2.0;
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                        input.texcoord + float2(0.0 ,halfpixel.y*2.0) *
                        offset,
                        _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
            input.texcoord + float2(halfpixel.x ,halfpixel.y) *
            offset,
            _BlitMipLevel) * 2.0;
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                                       input.texcoord + float2(halfpixel.x*2.0 ,0) *
                                       offset,
                                       _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                                          input.texcoord + float2(halfpixel.x ,-
                                              halfpixel
                                              .y) * offset,
                                          _BlitMipLevel) * 2.0;
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                       input.texcoord + float2(0 ,-halfpixel.y*
                           2.0) * offset,
                       _BlitMipLevel);
        color += SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_LinearClamp,
                                                                       input.texcoord + float2(-halfpixel.x ,-
                                                                           halfpixel.y)*offset,
                                                                       _BlitMipLevel) * 2.0;

        color /= 12.0;
        return color;
    }
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "BlurUpsamplePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment UpsamplePass
            ENDHLSL
        }

        Pass
        {
            Name "BlurDownsamplePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment DownsamplePass
            ENDHLSL
        }
    }
}