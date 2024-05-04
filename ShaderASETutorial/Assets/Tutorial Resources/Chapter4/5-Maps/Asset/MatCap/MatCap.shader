Shader "Unlit/MatCap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
        
        _NormalMapScale("Normal Map Scale",Vector) =(1,1,1,1)
        
//       _MatCap ("Mat Map", 2D) = "white" {} //如果要用代码传入贴图，那么把这个property注释掉
        [Toggle]_ShowMatCap("Show Mat Cap",Float) =0
        
        [Header(BlinPhong)]
        [Space(15)]
         _PowerValue("_PowerValue",Float) = 4 
        _PowerScale("_PowerScale",Float) = 1
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fullforwardshadows
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

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
                float3 worldPosition : TEXCOORD4;
                float3 localPosition : TEXCOORD5;
                float3 localNormal : TEXCOORD6;
                float4 vertexColor : TEXCOORD7;
                float2 uv2 : TEXCOORD8;
                float testValue:TEXCOORD9;
            };

            V2FData vert(MeshData v)
            {
                V2FData o;
                o.pos           = UnityObjectToClipPos(v.vertex);
                o.uv            = v.uv;
                o.uv2           = v.uv2;
                o.normal        = UnityObjectToWorldNormal(v.normal);
                o.tangent       = UnityObjectToWorldDir(v.tangent);
                // o.bitangent  = cross(o.normal, o.tangent);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.localPosition = v.vertex.xyz;
                o.localNormal   = v.normal;
                o.vertexColor   = v.vertexColor;
                o.testValue     = v.tangent.w;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMapScale;

            sampler2D _MatCap;
            
            float _PowerValue ,_PowerScale;
            float _ShowMatCap;
            
            float4 frag(V2FData i) : SV_Target
            {
                //Variable
                float3 T = normalize(i.tangent);
                float3 N = normalize(i.normal);
                float3 B = normalize( cross(N,T));
                // float3 B = normalize( i.bitangent);
                float3 L = normalize( UnityWorldSpaceLightDir(i.worldPosition.xyz));
                float3 V = normalize( UnityWorldSpaceViewDir(i.worldPosition.xyz));
                float3 H = normalize(V+L);
                float2 uv = i.uv;

                float4 BaseMap = tex2D(_MainTex,i.uv);
                
//================== Normal Map  ============================================== //
                float3 NormalMap = UnpackNormal(tex2D(_NormalMap,uv));
                 NormalMap = lerp(float3(0,0,1),NormalMap,_NormalMapScale.w);
		        //TBN矩阵:将世界坐标转到Tangent坐标
		        //TBN是正交矩阵，正交矩阵的逆等于其转置
                float3x3 TBN = float3x3(T,B,N);
                NormalMap *= _NormalMapScale;
                // NormalMap = normalize(NormalMap);
                // NormalMap.y = -NormalMap.y;
                
                N = normalize( mul (NormalMap,TBN));
            
                float4 Diffuse  = dot(N,L) ;

                float4 Specular = pow(dot(N,H),_PowerValue*128)*_PowerScale;      

                Diffuse = max(Diffuse,0);
                Specular = max(Specular,0);

                Diffuse *= BaseMap;

                if(_ShowMatCap)
                {
                    return tex2D(_MatCap,uv);
                }

                // float3 N_ViewSpace2 = mul(unity_WorldToCamera,N);
                float3 N_ViewSpace = mul(unity_MatrixV,N);

                float3 N01_ViewSpace = N_ViewSpace*0.5+0.5;
                float3 MatCap = tex2D(_MatCap,N01_ViewSpace.xy);
                //
                // return N01_ViewSpace.xyzz;
                return MatCap.xyzz;
                return N_ViewSpace.xyzz;

                // return N_ViewSpace.xyzz - N_ViewSpace2.xyzz;
                
                return Diffuse + Specular;
                
            }
            ENDCG
        }
    }
}