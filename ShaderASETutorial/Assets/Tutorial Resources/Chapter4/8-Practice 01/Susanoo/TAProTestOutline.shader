Shader "TAPro/TAProTestOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineHeight("Outline Height",Range(0,1)) = 0.1
        [HDR]_OutlineColor("Outline Color",Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata input)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(input.vertex);
                o.uv = input.uv;
                return o;
            }
            
            float4 frag (v2f input) : SV_Target
            {
                float4 col = tex2D(_MainTex, input.uv);
                return col;
            }
            ENDCG
        }
        
        //Outline
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
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };


            float _OutlineHeight;
            float4 _OutlineColor;

            v2f vert (appdata input)
            {
                v2f o;
                input.vertex.xyz +=input.normalOS.xyz*_OutlineHeight*0.1;
                o.vertex = UnityObjectToClipPos(input.vertex);
                return o;
            }

            float4 frag (v2f input) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
