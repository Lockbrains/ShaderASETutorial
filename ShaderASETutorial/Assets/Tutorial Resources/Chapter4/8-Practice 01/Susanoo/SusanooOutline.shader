Shader "Unlit/SusanooOutline"
{
    Properties
    {
//        _MainTex ("Texture", 2D) = "white" {}
        _OutlineHeight("Outline Height",Float) = 1
        [HDR]_OutlineColor("Outline Color",Color) =(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // sampler2D _MainTex;

            float _OutlineHeight;
            float4 _OutlineColor;
            
            v2f vert (appdata input)
            {
                v2f o;
                input.vertex.xyz += input.normal.xyz*_OutlineHeight*0.1;
                o.vertex = UnityObjectToClipPos(input.vertex);
                o.uv = input.uv;
                return o;
            }

            float4 frag (v2f input) : SV_Target
            {
                return _OutlineColor;
                // float4 col = tex2D(_MainTex, i.uv);
                // return col;
            }
            ENDCG
        }
    }
}
