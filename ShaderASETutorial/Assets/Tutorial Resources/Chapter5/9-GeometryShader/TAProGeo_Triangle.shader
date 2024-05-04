Shader "TAPro/Geo_Triangle"
{
    Properties
    {
        _NoiseTex ("Texture", 2D) = "white" {}
        _MatcapTex ("_MatcapTex", 2D) = "white" {}
        _Matcap1Mip ("_Matcap1Mip", Range(0,11)) = 0
        _Matcap1Intensity ("_Matcap1Intensity", Range(0,5)) = 1
        
        [Space(50)]
        _Matcap2Tex ("_Matcap2Tex", 2D) = "white" {}
        _Matcap2Mip ("_Matcap2Mip", Range(0,11)) = 0
        _Matcap2Intensity ("_Matcap2Intensity", Range(0,5)) = 1
        
        
        [Space(50)]
        _CubeMapTex ("_CubeMapTex", Cube) = "black" {}
        _CubeMapMip ("_CubeMapMip", Range(0,11)) = 0
        _CubeMapIntensity ("_CubeMapIntensity", Range(0,5)) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
                
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
                // float3 posOS    : TEXCOORD3;
                float  dis      : TEXCOORD4;
                float3 normalWS : TEXCOORD5;
                float3 posWS    : TEXCOORD3;
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
            
            [maxvertexcount(3)]
            void geom(triangle v2g input[3],inout TriangleStream<g2f> triStream)
            // void geom(triangle v2g input[3],inout PointStream<g2f> triStream)
            // void geom(triangle v2g input[3],inout TriangleStream<g2f> triStream)
            // void geom(point v2g input[1],inout TriangleStream<g2f> triStream)   
            // void geom(point v2g input[1],inout LineStream<g2f> triStream)   
            {
                // float speed = floor(_Time.y*5)/5;
                // float speed =  frac(_Time.x*0.01);
                // float noise = hash(input[0].uv + speed)*2-1;
                float2 centerUV = (input[0].uv + input[1].uv + input[2].uv)/3 ;
                // float2 centerUV = (input[0].uv);
                float noise = tex2Dlod(_NoiseTex,float4(centerUV*_NoiseTex_ST.xy + _Time.y*0.1,0,0));
                
                // float3 centerOS = (input[0].posOS + input[1].posOS + input[2].posOS)/3 + float3(0,1,0);
                // float centerUV = (input[0].uv + input[1].uv + input[2].uv)/3 + frac( centerOS.x + centerOS.y + centerOS.z)*2;
                // float noise = hash(centerUV + speed);
                
                g2f outputVetex[4];
                for (int i=0;i<3;i++)
                {
                    g2f output;
                    output.uv = input[i].uv;
                    float eachNoise = tex2Dlod(_NoiseTex,float4(input[i].uv*_NoiseTex_ST.xy + _Time.y*0.1,0,0));
                    output.posCS = UnityObjectToClipPos(input[i].posOS + 2*(noise + eachNoise*0.5-0.5 )*input[i].normalOS);
                    output.index = i;
                    output.dis = noise;
                    output.normalWS = UnityObjectToWorldNormal(input[i].normalOS);
                    output.posWS = mul(unity_ObjectToWorld,input[i].posOS);
                    outputVetex[i] = output;
                }
                
                triStream.Append(outputVetex[0]);
                triStream.Append(outputVetex[1]);
                triStream.Append(outputVetex[2]);
            }


            sampler2D _MatcapTex;
            sampler2D _Matcap2Tex;

            float _Matcap1Mip,_Matcap1Intensity;
            float _Matcap2Mip,_Matcap2Intensity;

            samplerCUBE _CubeMapTex;
            float _CubeMapMip,_CubeMapIntensity;

            float4 frag (g2f i) : SV_Target
            {
                float3 N = normalize(i.normalWS.xyz);
                float3 normalVS = mul(unity_WorldToCamera,float4(N,0));
                float2 matcapUV = normalVS.xy*0.5+0.5;
                float4 matcap1 = tex2Dlod(_MatcapTex,float4(matcapUV,_Matcap1Mip,_Matcap1Mip))*_Matcap1Intensity;
                float4 matcap2 = tex2Dlod(_Matcap2Tex,float4(matcapUV,_Matcap2Mip,_Matcap2Mip))*_Matcap2Intensity;

                float3 V = normalize(UnityWorldSpaceViewDir(i.posWS));
                float3 R = reflect(-V,N);
                float4 cubeMap = texCUBElod(_CubeMapTex,float4(R,_CubeMapMip))*_CubeMapIntensity;
                
                return lerp(matcap1,matcap2,i.dis) + cubeMap;
                
                return i.dis;
            }
            ENDCG
        }
    }
    CustomEditor "ASEMaterialInspector"
}
