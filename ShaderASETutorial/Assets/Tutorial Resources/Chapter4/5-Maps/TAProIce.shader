Shader "TAPro/05/TAProIce"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ParallaxMap ("ParallaxMap", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
//        _Value ("_Value",Float) =1
//        _RangeValue("_RangeValue",Range(0,1)) = 0.5
//        _Color ("_Color",Color) = (0.5,0.3,0.2,1)
//        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode("Src Blend Mode", Float) = 5
//		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode("Dst Blend Mode", Float) = 10
        
        _SpecularRange("_SpecularRange",Range(0,1)) = 0.5
        _SpecularIntensity ("_SpecularIntensity",Float) =1
        
        [Space(50)]
        _ParallaxCount ("Parallax Count",Float) = 16
        _ParallaxDis ("Parallax Dis",Range(0,1)) = 0.1
        _ParallaxLerp("Parallax Lerp",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue" = "Geometry"
        }
        //"LightMode"="ForwardBase" ForwardBase 让Shader接受主光源影响

        /*
        //Transparent Setup
         Tags { "Queue"="Transparent"  "RenderType"="Transparent" "LightMode"="ForwardBase"}
         Blend [_SrcBlendMode][_DstBlendMode]
        */
        //CGINCLUDE
        //float _SrcBlendMode;
        //float _DstBlendMode;
        //ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityGlobalIllumination.cginc"
            #include "AutoLight.cginc"
	    
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 tangentOS :TANGENT;
                float3 normalOS : NORMAL;
                float4 vertexColor : COLOR;
            };

            struct V2FData
            {
                float4 pos : SV_POSITION; // 必须命名为pos ，因为 TRANSFER_VERTEX_TO_FRAGMENT 是这么命名的，为了正确地获取到Shadow
                float2 uv : TEXCOORD0;
                float3 tangentWS : TEXCOORD1;
                float3 bitangentWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 posWS : TEXCOORD4;
                float3 posOS : TEXCOORD5;
                float3 normalOS : TEXCOORD6;
                float4 vertexColor : TEXCOORD7;
                float2 uv2 : TEXCOORD8;
            };

            V2FData vert(MeshData input)
            {
                V2FData output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.uv;
                output.uv2 = input.uv2;
                output.normalWS = normalize(UnityObjectToWorldNormal(input.normalOS));
                output.posWS = mul(unity_ObjectToWorld, input.vertex);
                output.posOS = input.vertex.xyz;
                output.tangentWS = normalize(UnityObjectToWorldDir(input.tangentOS));
                //乘上input.tangentOS.w 是unity引擎的bug,有的模型是 1 有的模型是 -1，必须这么写
                //TBN=> T = BXN => N = TXB => B =>NXT
                output.bitangentWS = cross(output.normalWS, output.tangentWS) * input.tangentOS.w;
                output.normalOS = input.normalOS;
                output.vertexColor = input.vertexColor;

                return output;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float _SpecularRange,_SpecularIntensity;

            sampler2D _ParallaxMap;

            float _ParallaxCount,_ParallaxDis,_ParallaxLerp;

            float4 frag(V2FData input) : SV_Target
            {
                float3 T = normalize(input.tangentWS);
                float3 N = normalize(input.normalWS);
                float3 B = normalize(input.bitangentWS);
                float3 L = normalize(UnityWorldSpaceLightDir(input.posWS.xyz));
                float3 V = normalize(UnityWorldSpaceViewDir(input.posWS.xyz));
                float3 H = normalize(V + L);
                float2 uv = input.uv;
                float2 uv2 = input.uv2;
                
                // return vertexColor.xyzz;
                float HV = dot(H, V);
                float NV = dot(N, V);
                float NL = dot(N, L);
                float NH = dot(N, H);

                float4 FinalColor = 0;
                float4 BaseMap = tex2D(_MainTex, uv);

                float3 NormalMap = UnpackNormal( tex2D(_NormalMap,uv));
                // NormalMap = float3(1,1,1);
                float3x3 TBN = float3x3(T,B,N);
                float3 normal = mul(NormalMap,TBN);

                float Lambert = dot(normal,L);

                // float4 Diffuse = Lambert*BaseMap*_LightColor0;

                float4 Specular = BaseMap* pow(saturate(dot(normal,H)),_SpecularRange*1000)*_SpecularIntensity*_LightColor0;

                float4 Fresnel = pow( 1-saturate(dot(normal,V)),4 )*2 *float4(0.2,0.2,0,0);

                //视差
                // float2 parallaxUV = uv + (viewTS.xy/viewTS.z) * depth;
                
                //TBN 从世界空间变换到切线空间
                float3 viewTS = mul(TBN,V);

                //float3 viewTS;float _ParallaxDis,_ParallaxCount,_ParallaxLerp;float2 uv;sampler2d _ParallaxMap;
                
                // #define MAXCOUNT 16
                float delta  = -_ParallaxDis/_ParallaxCount;
                
                float2 viewUV = viewTS.xy/viewTS.z;
                float4 sumMap = (float4)0;
                
                for (int k=0;k<_ParallaxCount;k++)
                {
                    float2 parallaxUV = viewUV*delta*k + uv;
                    sumMap += pow(tex2D(_ParallaxMap,parallaxUV),2);
                }
                
                float4 BaseColor = lerp(BaseMap*BaseMap, sumMap/_ParallaxCount,_ParallaxLerp)*2;

                float4 Diffuse = Lambert*BaseColor*_LightColor0;
                
                return Diffuse + Specular;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
