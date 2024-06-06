Shader"Unlit/Fresne_Scanline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanlineTex ("Scanline Texture", 2D) = "white" {}
        _FresnelPower("Fresnel Power", float) = 2.0
        _FresnelBias("Fresnel Bias", float) = 0.2
        _FresnelScale("Fresnel Scale", float) = 1.0
        _RimColor("Color", color) = (1,1,1,1)
        _Speed("Scanline Speed", Vector) = (1,1,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 pos : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal: TEXCOORD1;
                float3 viewDir: TEXCOORD2;
                float2 worldPos: TEXCOORD4;
                float2 uvScanline: TEXCOORD5;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _ScanlineTex;
            float4 _MainTex_ST;
            fixed _FresnelPower;
            fixed _FresnelBias;
            fixed _FresnelScale;
            float3 _RimColor;
            fixed2 _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.pos);
                o.worldPos = mul(unity_ObjectToWorld, v.pos).xy;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.pos).xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvScanline = _Speed * _Time.y + o.worldPos;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed fresnel = saturate(_FresnelScale * pow(1 - dot(i.worldNormal, i.viewDir), _FresnelPower) + _FresnelBias);
                fixed4 scanline = tex2D(_ScanlineTex,  i.uvScanline);
                
                fixed4 col = tex2D(_MainTex, i.uv);
                
                col.a = fresnel;
                col.rgb = col.rgb * _RimColor;

                fixed4 finalCol = col + scanline;
                return finalCol;
            }
            ENDCG
        }
    }
}
