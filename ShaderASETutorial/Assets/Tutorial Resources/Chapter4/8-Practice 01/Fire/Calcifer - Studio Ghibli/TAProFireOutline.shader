Shader "TAPro/TAProFireOutline"
{
    Properties
    {
        _NoiseTex ("_NoiseTex", 2D) = "white" {}
        _NoiseTex2 ("_NoiseTex2", 2D) = "white" {}
        _OutlineScale("Outline Scale",Float)  =0 
        _OutlineHeight("Outline Height",Float)  =0 
        [HDR]_Color("Color",Color) = (1,1,1,1)
        _ClipValue("Clip Value",Range(0,1)) = 0
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
                float4 posCS : SV_POSITION;
                float3 posWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };

            sampler2D _NoiseTex,_NoiseTex2;
            float4 _NoiseTex_ST,_NoiseTex2_ST;
            float _OutlineScale,_OutlineHeight;
            float4 _Color;
            float _ClipValue;
            
            v2f vert (appdata input)
            {
                v2f o;
                float4 col = tex2Dlod(_NoiseTex, float4(input.uv.xy*_NoiseTex_ST.xy + _Time.y*float2(0.2,0),0,0));
                input.vertex.xyz += input.normal.xyz * _OutlineHeight*col.r*input.normal.y;
                o.posCS = UnityObjectToClipPos(input.vertex);
                o.uv = input.uv;

                o.posCS.z += _OutlineScale;

                o.posWS = mul(unity_ObjectToWorld,input.vertex);
                o.normalWS = UnityObjectToWorldNormal(input.normal);
                
                return o;
            }

            float4 frag (v2f input) : SV_Target
            {
                float2 uv = input.uv;
                // float col = tex2D(_NoiseTex, uv*_NoiseTex_ST.xy + _Time.y*float2(0.2,0));
                float noise = tex2D(_NoiseTex2, uv*_NoiseTex2_ST.xy + _Time.y*float2(0.4,0));
                
                float V = UnityObjectToWorldDir(input.posWS);
                float3 N = normalize(input.normalWS);

                if(dot(N,V)>0) discard;
                
                clip(noise -_ClipValue);
                return noise *_Color;
            }
            ENDCG
        }
    }
}
