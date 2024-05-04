Shader "TAPro/Geo_Line"
{
    Properties
    {
        _NoiseTex ("Texture", 2D) = "white" {}
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

            struct appdata
            {
                float4 posOS    : POSITION;
                float2 uv       : TEXCOORD0;
                float4 normalOS :NORMAL;
            };

            struct v2g
            {
                float4 posOS    : POSITION;
                float2 uv       : TEXCOORD0;
                float4 normalOS :TEXCOORD1;

            };

            struct g2f
            {
                float2 uv       : TEXCOORD0;
                float4 posCS    : SV_POSITION;
                float index     : TEXCOORD1;
                // float3 normalWS : TEXCOORD2;
                float3 posOS    : TEXCOORD3;
                float  dis      : TEXCOORD4;
            };

            float hash(float2 p)
            {
	            return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            v2g vert (appdata input)
            {
                v2g output;
                output.posOS = input.posOS;
                output.uv = input.uv;
                output.normalOS = input.normalOS;
                return output;
            }
            
            [maxvertexcount(4)]
            // void geom(triangle v2g input[3],inout LineStream<g2f> triStream)
            // void geom(triangle v2g input[3],inout PointStream<g2f> triStream)
            // void geom(triangle v2g input[3],inout TriangleStream<g2f> triStream)
            // void geom(point v2g input[1],inout TriangleStream<g2f> triStream)   
            void geom(point v2g input[1],inout LineStream<g2f> triStream)   
            {
                g2f output;
                output.uv = input[0].uv;
                output.posOS = (input[0].posOS);
                output.posCS = UnityObjectToClipPos(output.posOS);
                output.index = 0;
                output.dis   =0;
                
                g2f output2;
                output2.uv = input[0].uv;

                // float noise = hash(output2.uv + _Time.x);
                float2 centerUV = (input[0].uv) ;
                float noise = tex2Dlod(_NoiseTex,float4(centerUV*_NoiseTex_ST.xy + _Time.y*0.1,0,0));
                
                output2.dis  =noise;

                output2.posOS = input[0].posOS + input[0].normalOS.xyz*noise;
                
                output2.posCS = UnityObjectToClipPos(output2.posOS);
                output2.index = 1;
                
                triStream.Append(output);
                triStream.Append(output2);
            }

            float4 frag (g2f i) : SV_Target
            {
                return i.dis;
            }
            ENDCG
        }
    }
}
