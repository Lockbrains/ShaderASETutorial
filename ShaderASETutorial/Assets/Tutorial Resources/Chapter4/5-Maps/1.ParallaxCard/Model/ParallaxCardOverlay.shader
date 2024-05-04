Shader "TA102/ParallaxCardOverlay"
{
    Properties
    {
                
        [Space(50)]
        _Frame("Frame",2D) = "Black"{}
        
        [Space(50)]
        _ParallaxMap("Parallax Map",2D) = "Black"{}
        _Depth("Depth",Float) = 0
        
        [Space(50)]
        _ParallaxMap2("Parallax Map 2",2D) = "Black"{}
        _Depth2("Depth 2",Float) = 0
        
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CloudTex;

            sampler2D _ParallaxMap,_HeightMap;float4 _ParallaxMap_ST;float _Depth;
            sampler2D _ParallaxMap2,_HeightMap2;float4 _ParallaxMap2_ST;float _Depth2;

            sampler2D _Frame;float4 _Frame_ST;
            
            float _UVScale;

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

            float4 ParallaxMapping(sampler2D ParallaxMap,in float depth ,in float2 uv,in float4 ParallaxMap_ST,in float3 viewTS)
            {
                uv = uv*ParallaxMap_ST.xy + ParallaxMap_ST.zw;
                
                float cosTheta = dot(viewTS,float3(0,0,1));
                float viewTSLength = depth / cosTheta;
                float3 startPoint = float3(uv,0);
                float3 endPoint = startPoint + viewTS*viewTSLength;
                float4 parallax = tex2D(ParallaxMap,saturate( endPoint.xy));
                return parallax;
            }
            
            float4 frag(V2FData input) : SV_Target
            {
                float3 T = normalize(input.tangent);
                float3 N = normalize(input.normal);
                //float3 B = normalize( cross(N,T));
                float3 B = normalize(input.bitangent);
                float3 L = normalize(UnityWorldSpaceLightDir(input.posWS.xyz));
                float3 V = normalize(UnityWorldSpaceViewDir(input.posWS.xyz));
                float2 uv = input.uv;
                
                //TBN:将世界空间转到切线空间
                float3x3 TBN = float3x3(T,B,N);
                
                //将V转到深度空间
                float3 viewTS = mul(TBN,V);

                //计算图片1 的深度坐标
                float4 p1 = ParallaxMapping(_ParallaxMap, _Depth,uv,_ParallaxMap_ST,viewTS);
                //计算图片2 的深度坐标
                float4 p2 = ParallaxMapping(_ParallaxMap2, _Depth2,uv,_ParallaxMap2_ST,viewTS);

                //采样画框,不需要计算出视差
                float4 frame = tex2D(_Frame,uv*_Frame_ST.xy+_Frame_ST.zw);

                //通过Alpah蒙版进行融合,图片1 在 图片2的上面
                float4 color = lerp(p2,p1,p1.a);

                //通过Alpah蒙版进行融合,相框在最碗面
                color = lerp(color,frame,frame.a);

                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}