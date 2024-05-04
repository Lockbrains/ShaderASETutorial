Shader "TAPro/Geo_Point"
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
//            Cull Off
            
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
                float dis     : TEXCOORD1;
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
            
            [maxvertexcount(2)]
            // void geom(triangle v2g input[3],inout LineStream<g2f> triStream)
            // void geom(triangle v2g input[3],inout PointStream<g2f> triStream)
            // void geom(triangle v2g input[3],inout TriangleStream<g2f> triStream)
            void geom(point v2g input[1],inout PointStream<g2f> pointStream)   
            // void geom(point v2g input[1],inout LineStream<g2f> triStream)   
            {
                g2f output;
                output.uv = input[0].uv;
                output.posCS = UnityObjectToClipPos(input[0].posOS);
                output.dis = 0;
                
                g2f output2;
                output2.uv = input[0].uv;

                // float noise = hash(output2.uv*10 + _Time.y*0.1);
                float2 centerUV = (input[0].uv) ;
                float noise = tex2Dlod(_NoiseTex,float4(centerUV*_NoiseTex_ST.xy + _Time.y*0.1,0,0));
                
                output2.posCS = UnityObjectToClipPos(input[0].posOS + 0.01*noise*input[0].normalOS);
                output2.dis = noise;
                
                // pointStream.Append(output);
                pointStream.Append(output2);
            }
            
            float4 frag (g2f i) : SV_Target
            {
                return 1;
                // return i.dis;
                // return i.posOS.y;
                return i.dis;
                // return float4(i.uv,0,0);
                // fixed4 col = tex2D(_MainTex, i.uv);
                // return col;
            }
            ENDCG
        }
    }
}