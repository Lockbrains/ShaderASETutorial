Shader "TAPro/Geo_Learning03"
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
            [maxvertexcount(2)]
            void geom (point v2g input[1],inout LineStream<g2f> stream)
            {
                g2f p0;
                p0.uv = input[0].uv;
                float3 nomalOS =  input[0].normalOS;
                p0.normalWS = UnityObjectToWorldNormal( input[0].normalOS );
                float3 p0PosOS = input[0].posOS;
                float noise = tex2Dlod(_NoiseTex, float4(p0.uv*_NoiseTex_ST.xy + float2(1,0) * _Time.y*0.1 ,0,0));
                // p0PosOS = p0PosOS + p0.normalWS *noise*_Length;
                
                p0.posWS = mul(unity_ObjectToWorld, p0PosOS );
                p0.posCS = UnityObjectToClipPos(p0PosOS);
                p0.dis = noise;
                //1
                // if(noise>0.5)
               
                stream.Append(p0);
          
                //2
                // if(noise>0.75)
                p0PosOS = p0PosOS + nomalOS *noise*_Length;
                p0.posWS = mul(unity_ObjectToWorld, p0PosOS );
                p0.posCS = UnityObjectToClipPos(p0PosOS);
                stream.Append(p0);
                stream.RestartStrip();

                /*
                if(noise<0.5) return;
                
                //3
                {
                    p0PosOS = p0PosOS + nomalOS *noise*_Length;
                    p0.posWS = mul(unity_ObjectToWorld, p0PosOS );
                    p0.posCS = UnityObjectToClipPos(p0PosOS);
                    lineStream.Append(p0);
                    lineStream.RestartStrip();
                }
                //4
                {
                p0PosOS = p0PosOS + nomalOS *noise*_Length;
                p0.posWS = mul(unity_ObjectToWorld, p0PosOS );
                p0.posCS = UnityObjectToClipPos(p0PosOS);
                lineStream.Append(p0);
                lineStream.RestartStrip();

                }
                */

            }

            float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
            
            float4 frag (g2f i) : SV_Target
            {
                return i.dis;
                return 1;
                float3 posOS = mul(unity_WorldToObject,float4(i.posWS.xyz,1));
                return HSVToRGB(float3( length(posOS)*0.1,0.2,1)).xyzz;
                return 0.25;
                return i.dis;
                return float4(i.uv,0,0);
            }
            ENDCG
        }
    }
}
