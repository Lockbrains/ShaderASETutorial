Shader "TAPRo/Geo_Learning"
{
    Properties
    {
        _Length("Length",Float) = 1
        _NoiseTex ("_NoiseTex", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            //cpu 传到 vs
            struct appdata
            {
                float4 posOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };

            //vs 传到 gs
            struct v2g
            {
                float4 posOS    : TEXCOORD0;
                float2 uv       : TEXCOORD1;
                float3 normalOS : TEXCOORD2;
            };

            //gs 传到 fs
            struct g2f
            {
                float4 posCS    : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 posWS    : TEXCOORD2;
                float  dis      : TEXCOORD3;
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _Length;

            v2g vert (appdata input)
            {
                v2g output;
                output.uv = input.uv;
                output.normalOS = input.normalOS;
                output.posOS = input.posOS;

                return output;
            }

            //最大的顶点数
            [maxvertexcount(9)]
            void geom (triangle v2g input[3],inout TriangleStream<g2f> triStream)
            {
                g2f center;
                center.uv = (input[0].uv + input[1].uv + input[2].uv)/3.0;
                float3 centerNormalOS = (input[0].normalOS + input[1].normalOS + input[2].normalOS)/3.0;
                center.normalWS = UnityObjectToWorldNormal(centerNormalOS );
                float3 centerPosOS = (input[0].posOS + input[1].posOS + input[2].posOS)/3.0;
                float noise = tex2Dlod(_NoiseTex, float4(center.uv*_NoiseTex_ST.xy + float2(1,0) * _Time.y*0.1 ,0,0));
                centerPosOS = centerPosOS + centerNormalOS *noise*_Length;
                
                center.posWS = mul(unity_ObjectToWorld, centerPosOS );
                center.posCS = UnityObjectToClipPos(centerPosOS);
                center.dis = noise;
        
                g2f output[3];
                for(int i=0;i<3;i++)
                {
                    g2f p0;
                    p0.uv = input[i].uv;
                    p0.normalWS = UnityObjectToWorldNormal( input[i].normalOS);
                    p0.posWS = mul(unity_ObjectToWorld, input[i].posOS);
                    p0.posCS = UnityObjectToClipPos(input[i].posOS );
                    p0.dis = 0;
                    output[i] = p0;
                }

                triStream.Append(output[1]);
                triStream.Append(center);
                triStream.Append(output[0]);
                triStream.RestartStrip();

                triStream.Append(output[2]);
                triStream.Append(center);
                triStream.Append(output[1]);
                triStream.RestartStrip();

                triStream.Append(output[0]);
                triStream.Append(center);
                triStream.Append(output[2]);
                triStream.RestartStrip();
                                
                // for(int i=0;i<3;i++)
                // {
                //     g2f p0;
                //     p0.uv = input[i].uv;
                //     p0.normalWS = UnityObjectToWorldNormal( input[i].normalOS);
                //     p0.posWS = mul(unity_ObjectToWorld, input[i].posOS);
                //     p0.posCS = UnityObjectToClipPos(input[i].posOS );
                //
                //     int nextIndex = (i+1)%3;
                //     g2f p1;
                //     p1.uv = input[nextIndex].uv;
                //     p1.normalWS = UnityObjectToWorldNormal( input[nextIndex].normalOS);
                //     p1.posWS = mul(unity_ObjectToWorld, input[nextIndex].posOS);
                //     p1.posCS = UnityObjectToClipPos(input[nextIndex].posOS);
                //     
                //     triStream.Append(p1);
                //     triStream.Append(center);
                //     triStream.Append(p0);
                //     triStream.RestartStrip();
                // }
            }
            
            float4 frag (g2f i) : SV_Target
            {
                return i.dis;
                return float4(i.uv,0,0);
            }
            ENDCG
        }
    }
}
