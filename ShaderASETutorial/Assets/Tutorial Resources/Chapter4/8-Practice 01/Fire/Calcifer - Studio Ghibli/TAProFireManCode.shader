Shader "TAPro/FireManCode"
{
    Properties
    {
        [Header(BaseColor)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [HDR]_FireColor("Fire Color",Color)=(1,1,1,1)
        _FireTex ("_FireTex", 2D) = "black" {}
        _NoiseTex ("Distort Noise Tex", 2D) = "black" {}
        _Distort("_Distort",Float) = 0.1
        _FireSpeed("_FireSpeed",Float) = 1
        _DistortSpeed("_DistortSpeed",Float) = 1
        
        [Space(20)]
        [HDR]_FresnelColor("Fresnel Color",Color)=(1,1,1,1)
        _Fresnel_Pow_Scale("Fresnel_Pow_Scale",Vector)=(4,1,1,1)

        [Space(50)]
        [HDR]_OutlineColor("_OutlineColor",Color) = (0,0,0,0)
        _OutlineHeight("_OutlineHeight",Range(0,1)) = 0.2
        
        
        [Space(50)]
        [HDR]_SparkColor("Spark Color",Color) = (0,0,0,0)
        _SparkHeight("Spark Height",Range(0,5)) = 0.2
               
        _SparkSpeed("SparkSpeed",Float) = 1
        _SparkClipValue("Spark Clip Value",Range(0,1)) = 0.2
        _SparkTex ("_SparkTex", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        //基础色
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 posOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 posOS : SV_POSITION;
                float3 posWS: TEXCOORD1;
                float3 normalWS: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D  _FireTex,_NoiseTex;
            float4 _FireTex_ST,_NoiseTex_ST;
            float4 _FireColor;
            float _Distort;
            float _FireSpeed,_DistortSpeed;
            float4 _FresnelColor,_Fresnel_Pow_Scale;

            v2f vert (appdata input)
            {
                v2f o;
                o.posOS = UnityObjectToClipPos(input.posOS);
                o.uv = input.uv;
                o.posWS = mul(unity_ObjectToWorld,input.posOS);
                o.normalWS = UnityObjectToWorldNormal(input.normalOS);
                return o;
            }
            
            float4 frag (v2f input) : SV_Target
            {
                float2 uv = input.uv;
                float4 finalColor =(float4)0;
                float4 baseMap = tex2D(_MainTex, input.uv);
            
                float4 noise = tex2D(_NoiseTex,uv*_NoiseTex_ST.xy + float2(0,1)*_Time.y*_DistortSpeed*1.5);
                noise = noise*2-1;
                
                float4 noise2 = tex2D(_NoiseTex,uv*_NoiseTex_ST.xy + float2(0,1)*_Time.y*_DistortSpeed + noise.xy *_Distort*0.5);
                noise2 = noise2*2-1;
                
                float2 fireUV = uv*_FireTex_ST.xy + float2(0,1)*  _Time.y*_FireSpeed + noise2.xy *_Distort;
                float4 flowFire = _FireColor*tex2D(_FireTex,fireUV );
                

                float3 V = normalize(UnityWorldSpaceViewDir(input.posWS.xyz));
                float3 N = normalize(input.normalWS.xyz);

                float4 fresnel =  _FresnelColor * pow(1- saturate( dot(N,V)), _Fresnel_Pow_Scale.x)*_Fresnel_Pow_Scale.y;
                

                finalColor = flowFire + baseMap + fresnel;

                return finalColor;
            }
            ENDCG
        }
        
        //描边
        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 posOS : POSITION;
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 posOS : SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineHeight;

            v2f vert (appdata input)
            {
                v2f o;
                input.posOS.xyz += input.normalOS.xyz *_OutlineHeight;
                o.posOS = UnityObjectToClipPos(input.posOS);
                return o;
            }
            
            float4 frag (v2f input) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
        
        //火花
        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 posOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 posOS : SV_POSITION;
                float3 posWS: TEXCOORD1;
                float3 normalWS: TEXCOORD2;
            };

            float4 _SparkColor;
            float _SparkHeight;
            float _SparkSpeed,_SparkClipValue;
            sampler2D _SparkTex;
            float4 _SparkTex_ST;

            v2f vert (appdata input)
            {
                v2f o;

                float4 noise = tex2Dlod(_SparkTex,float4(input.uv*_SparkTex_ST.xy + float2(0,1)*_Time.y*1.5*_SparkSpeed,0,0 ));
                // input.posOS.xyz += input.normalOS.xyz *_SparkHeight*noise.r;
                input.posOS.xyz += float3(0,1,0) *_SparkHeight*noise.r;
                
                o.posOS = UnityObjectToClipPos(input.posOS);
                o.uv = input.uv;
                o.posWS = mul(unity_ObjectToWorld,input.posOS);
                o.normalWS = UnityObjectToWorldNormal(input.normalOS);
                return o;
            }
            
            float4 frag (v2f input) : SV_Target
            {
                float2 uv = input.uv;
                
                float4 noise = tex2D(_SparkTex,uv*_SparkTex_ST.xy + float2(0,1)*_Time.y*1.5*_SparkSpeed);
                clip(noise.r - _SparkClipValue);

                float3 V = normalize(UnityWorldSpaceViewDir(input.posWS.xyz));
                float3 N = normalize(input.normalWS.xyz);

                if(dot(N,V)>0) discard;
                

                return _SparkColor;

            }
            ENDCG
        }
    }
}
