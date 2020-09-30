Shader "Unlit/RadialPerlinColor"
{
    Properties
    {
        _RPS ("RPS", Float) = 0.01
        _Opacity ("Opacity", Float) = 0.75
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend One One

        Pass
        {
            CGPROGRAM
            static const float PI = 3.14159265;
            static const uint BASE_NUM = 2;
            static const uint REPEATS = 8;

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

            float wrapAngle(float angle){
                return angle - 2.0*PI*floor(angle/(2.0*PI));
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

            float _PerlinDataA[1000];
            float _PerlinDataB[1000];
            float _ColorDataA[1000];
            float _ColorDataB[1000];
            float _RPS;
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
                // Calculate angle
                float2 direction = normalize(i.uv - float2(0.5, 0.5));
                float angle = acos(dot(direction, float2(1.0, 0.0)));
                if(i.uv.y < 0.5)
                    angle = 2.0*PI - angle;

                // Apply evolution
                float angle_A = angle + _Time.y*_RPS*2.0*PI;
                angle_A = wrapAngle(angle_A);
                float angle_B = angle -_Time.y*_RPS*2.0*PI;
                angle_B = wrapAngle(angle_B); //fmod(angle_B/(2.0*PI), 1.0);

                float3 finalSample = float3(0.0, 0.0, 0.0);
                float maxSample = 0.0;
                for(uint n = 0; n < REPEATS; n++){
                    uint base = BASE_NUM*pow(2, n);

                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // Calculate sample locations (A)
                    uint sample_loc_1A = (uint)(base*angle_A);
                    uint sample_loc_2A = (sample_loc_1A + 1) % base;

                    // Do the perlin noise thing (A)
                    float sample_1A = _PerlinDataA[sample_loc_1A];
                    float sample_2A = _PerlinDataA[sample_loc_2A];
                    float between_A = (angle_A*base) - sample_loc_1A;
                    float sample_A = lerp(sample_1A*between_A, -sample_2A*(1.0-between_A), between_A);
                    sample_A = (sample_A + 1.0)/2.0;

                    // Sample for color (A)
                    float sample_color_1A = _ColorDataA[sample_loc_1A];
                    float sample_color_2A = _ColorDataA[sample_loc_2A];
                    float sample_color_A = lerp(sample_color_1A*between_A, -sample_color_2A*(1.0-between_A), between_A);
                    sample_color_A = (sample_color_A + 1.0)/2.0;
                    float3 color_A = HSVtoRGB(float3(sample_color_A, 0.2, 1.0));

                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // Calculate sample locations (B)
                    uint sample_loc_1B = (uint)(base*angle_B);
                    uint sample_loc_2B = (sample_loc_1B + 1) % base;

                    // Do the perlin noise thing (B)
                    float sample_1B = _PerlinDataB[sample_loc_1B];
                    float sample_2B = _PerlinDataB[sample_loc_2B];
                    float between_B = (angle_B*base) - sample_loc_1B;
                    float sample_B = lerp(sample_1B*between_B, -sample_2B*(1.0-between_B), between_B);
                    sample_B = (sample_B + 1.0)/2.0;

                    // Sample for color (B)
                    float sample_color_1B = _ColorDataB[sample_loc_1B];
                    float sample_color_2B = _ColorDataB[sample_loc_2B];
                    float sample_color_B = lerp(sample_color_1B*between_B, -sample_color_2B*(1.0-between_B), between_B);
                    sample_color_B = (sample_color_B + 1.0)/2.0;
                    float3 color_B = HSVtoRGB(float3(sample_color_B, 0.2, 1.0));


                    float3 sum_sample = (sample_A*color_A + sample_B*color_B)/2.0;//(sample_A + sample_B) / 2.0;
                    finalSample = finalSample + sum_sample/pow(2, n+1);
                    maxSample = maxSample + 1.0/pow(2, n+1);
                }
                finalSample = finalSample/maxSample;


                // Calculations for circle fading
                float dist_std = distance(i.uv, float2(0.5, 0.5)) / 0.5;
                float main_glow_frac = smoothstep(1.0, 0.0, dist_std) * _Opacity;

                float4 col = float4(main_glow_frac*finalSample, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
