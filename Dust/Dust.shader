Shader "Unlit/Dust"
{
    Properties
    {
        _Opacity("Opacity", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Blend One One

        Pass
        {
            CGPROGRAM
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
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Opacity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calculations for circle fading
                float dist_std = distance(i.uv, float2(0.5, 0.5)) / 0.5;
                float main_glow_frac = lerp(1.0, 0.0, dist_std) * _Opacity;

                float4 col = float4(main_glow_frac*i.color*i.color.w);
                clip(col);
                return col;
            }
            ENDCG
        }
    }
}
