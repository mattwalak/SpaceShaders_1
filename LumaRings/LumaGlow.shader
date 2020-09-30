Shader "Unlit/LumaGlow"
{
    Properties
    {
        _RingSpeed ("Ring Speed", Float) = 2.0
        _RingFreq("Ring Frequency", Float) = 1.5
        _Opacity("Opacity", Float) = 0.15
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend One One

        Pass
        {
            CGPROGRAM
            static const float PI = 3.14159265f;

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Credit: https://www.chilliant.com/rgb2hsv.html
            float3 HUEtoRGB(in float H)
            {
                float R = abs(H * 6 - 3) - 1;
                float G = 2 - abs(H * 6 - 2);
                float B = 2 - abs(H * 6 - 4);
                return saturate(float3(R,G,B));
            }

            // Credit: https://www.chilliant.com/rgb2hsv.html
            float3 HSVtoRGB(in float3 HSV)
            {
                float3 RGB = HUEtoRGB(HSV.x);
                return ((RGB - 1) * HSV.y + 1) * HSV.z;
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _RingSpeed;
            float _RingFreq;
            float _Opacity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist_std = distance(i.uv, float2(0.5, 0.5)) / 0.5;
                float main_glow_frac = smoothstep(1.0, 0.0, dist_std);
                float local_time = _Time.y - dist_std*_RingSpeed;
                float sin_glow_frac = sin((1.0/_RingFreq)*2.0*PI*local_time);
                sin_glow_frac = (sin_glow_frac + 1.0)/2.0;
                float hue = fmod(local_time/_RingFreq, 1.0);
                float3 tint = HSVtoRGB(float3(hue, 0.2, 1.0));

                float sum_glow_frac = _Opacity * main_glow_frac * sin_glow_frac;
                fixed4 col = {sum_glow_frac*tint.x, sum_glow_frac*tint.y, sum_glow_frac*tint.z, 1.0};
                clip(col);
                return col;
            }

            ENDCG
        }
    }
}
