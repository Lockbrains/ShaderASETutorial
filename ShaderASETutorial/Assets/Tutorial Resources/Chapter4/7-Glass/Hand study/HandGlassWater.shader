Shader "TAPro/HandGlassWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaterHeight("Water Height",Float) = 0
        _RotateCenter("RotateCenter",Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 posOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 posCS : SV_POSITION;
                float3 posOS: TEXCOORD1;
                float3 posWS: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _WaterHeight;
            float4 _RotateCenter;

            float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}

            float4 _GlassCenter;
            float4 _GlassAxis;
            
            v2f vert(appdata input)
            {
                v2f o;

                float3 posWS = mul(unity_ObjectToWorld,input.posOS).xyz;
                // float3 axisOS = mul(unity_WorldToObject,float4(normalize(_GlassAxis.xyz),0));
                // float3 centerOS = mul(unity_WorldToObject,float4(_GlassCenter.xyz,1));
                //旋转
                 // posWS = RotateAroundAxis(_GlassCenter.xyz,posWS,normalize(_GlassAxis.xyz),_Time.y);
                // v.vertex.xyz = RotateAroundAxis(centerOS.xyz,v.vertex.xyz,axisOS,_Time.y);
                o.posCS = mul(UNITY_MATRIX_VP, float4(posWS, 1.0));
                // o.vertex = mul(unity_MatrixVP,float4(posWS,1));
                o.uv = input.uv;    
                o.posOS = input.posOS.xyz;
                return o;
            }

            float4 frag(v2f i, half isFront : VFACE) : SV_Target
            {
                // return _GlassCenter;
                // return 1;
                // // if (i.posOS.y > _WaterHeight) discard;
                // //
                // float3 objPosWS = mul( unity_ObjectToWorld,float4(0,0,0,1));
                // // float3 delta = i.posWS - objPosWS;
                //
                
                if(i.posOS.y > _WaterHeight) discard;
                                
                return isFront;;

                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}