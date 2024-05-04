Shader "TA102/ParallaxCard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value ("_Value",Float) =1
        _RangeValue("_RangeValue",Range(0,1)) = 0.5
        _Color ("_Color",Color) = (0.5,0.3,0.2,1)
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode("Src Blend Mode", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode("Dst Blend Mode", Float) = 10

        _CloudTex("Cloud Tex",2D) = "Black"{}
        _ParallaxMap("Parallax Map",2D) = "Black"{}
        _HeightMap("Height Map",2D) = "Black"{}
        
        _UVScale("UV Scale",Float) = 1
        _Dpeth("Depth",Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue" = "Geometry"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CloudTex;
            float _Dpeth;

            sampler2D _ParallaxMap,_HeightMap;
            float4 _ParallaxMap_ST;
            float _UVScale;

              //直线与平面相交
            bool Intersect(float3 rayPos,float3 rayDir,float3 planePos,float3 planeNormal, inout float t0)
            {
                float3 p0 = planePos - rayPos;
                float dotDN= dot(rayDir,planeNormal);
                //平行
                if (abs(dotDN) <=0.001 )
                {
                    return false;
                }
                t0 = dot(p0,planeNormal) / dotDN;
                return t0 > 0;
            }

            float GetCloud(float2 uv)
            {
                float cloud = 1- (tex2D(_CloudTex, uv).r<0.1);
                return cloud;
            }

            float GetGodRay(float3 pos,float3 toLightDir)
            {
                float t0;
                const float3 planeNormal = float3(0,1,0);
                const float3 planePos = float3(0,0,0);

                float3 rayPos = pos;
                float3 rayDir = toLightDir;

                bool isHit =  Intersect(rayPos,rayDir,planePos,planeNormal, t0);
                if(isHit)
                {
                    float3 hitPoint = rayPos + rayDir*t0;
                    return GetCloud(hitPoint.xz);
                }

                return 0;
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 tangent :TANGENT;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
            };

            struct V2FData
            {
                float4 pos : SV_POSITION; // 必须命名为pos ，因为 TRANSFER_VERTEX_TO_FRAGMENT 是这么命名的，为了正确地获取到Shadow
                float2 uv : TEXCOORD0;
                float3 tangent : TEXCOORD1;
                float3 bitangent : TEXCOORD2;
                float3 normal : TEXCOORD3;
                float3 posWS : TEXCOORD4;
                float3 localPosition : TEXCOORD5;
                float3 localNormal : TEXCOORD6;
                float4 vertexColor : TEXCOORD7;
                float2 uv2 : TEXCOORD8;
            };

            V2FData vert(MeshData v)
            {
                V2FData o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.localPosition = v.vertex.xyz;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                o.localNormal = v.normal;
                o.vertexColor = v.vertexColor;

                return o;
            }

            float4 frag(V2FData input) : SV_Target
            {
                float3 T = normalize(input.tangent);
                float3 N = normalize(input.normal);
                //float3 B = normalize( cross(N,T));
                float3 B = normalize(input.bitangent);
                float3 L = normalize(UnityWorldSpaceLightDir(input.posWS.xyz));
                float3 V = normalize(UnityWorldSpaceViewDir(input.posWS.xyz));
                float3 H = normalize(V + L);
                float2 uv = input.uv*_ParallaxMap_ST.x + _ParallaxMap_ST.zw;
                float2 uv2 = input.uv2;

                // return float4(uv2,0,0);
                float4 vertexColor = input.vertexColor;
                // return vertexColor.xyzz;
                float HV = dot(H, V);
                float NV = dot(N, V);
                float NL = dot(N, L);
                float NH = dot(N, H);

                float4 FinalColor = 0;

                float3 rayPos = input.posWS;
                float3 rayDir = -V;

                float3x3 TBN = float3x3(T,B,N);
                float3 viewTS = mul(TBN,V);

                float HeightMap = tex2D(_HeightMap,uv);

                float depth  = _Dpeth*HeightMap;
                
                float cosTheta = dot(viewTS,float3(0,0,1));
                float viewTSLength = depth / cosTheta;
                float3 startPoint = float3(uv,0);
                float3 endPoint = startPoint + viewTS*viewTSLength;

                float4 palallax = tex2D(_ParallaxMap,saturate( endPoint.xy));
                
                return palallax;
 
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}