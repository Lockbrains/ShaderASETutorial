Shader "TAPro/TAShaderBurning"
{
    //材质参数 ShaderLab
    Properties
    {
       _MainTex ("_MainTex", 2D) = "white" {}
       _NoiseTex ("NoiseTex", 2D) = "white" {}
//        [Space(50)]
//       _DissoveValue("Dissove Value",Float) = 0
        
        /*
        _Color("Color",Color) = (0,1,1,0)
        [HDR]_HDRColor("HDR Color",Color) = (0,1,1,0)
        _Value("Value",Float) = 0.5
        _RangeValue("Range Value",Range(0,1)) = 0.5
        _Vec("Vec",Vector)=(1,1,0,0)
        _Alpha("Alpha",Range(0,1)) = 1
        _Mip("Mip",Float) = 0
        */
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        //半透明= 队列为3000 + Blend
//        Tags { "RenderType"="Opaque" "Queue"="Transparent" }

        Pass
        {
            
//            Blend One One
//            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            
            //编译指令
            #pragma vertex vert
            #pragma fragment frag
                        
            //头文件
            #include "UnityCG.cginc"
            
            //CPU发送个VS的数据 
            struct MeshData
            {
                float4 posOS    : POSITION;
                float2 uv       : TEXCOORD0;
                float2 uv2      : TEXCOORD1;
                float4 normalOS : NORMAL;
            };

            //VS发送给PS的数据
            struct VS2PSData
            {
                float4 posCS    : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float2 uv2      : TEXCOORD1;
                float3 posOS    : TEXCOORD2;
                float3 posWS    : TEXCOORD3;
                float3 normalOS : TEXCOORD4;
                float3 normalWS : TEXCOORD5;
            };

            //申明变量 局部变量
            sampler2D _MainTex;
            float4 _MainTex_ST;//scale offset

            sampler2D _NoiseTex;
            float _DissoveValue;
            float _DissoveWidth;
            float _DissoveRange;
            float4 _DissoveColor;
            float4 _DissoveRangeColor;

            float _DissovedPercent;
            float4 _DissovedColor; 

            /*

            float _Alpha;

            //全局变量
            float _DissoveValue;
            float _Mip;
            */
                
            //vs 传给 ps 的数据是 VS2PSData
            VS2PSData vert (MeshData input)
            {
                VS2PSData output;
                //位置 局部坐标 ->裁剪坐标
                output.uv    = input.uv;
                output.uv2   = input.uv2;
                output.normalOS = input.normalOS;
                output.normalWS = UnityObjectToWorldNormal(input.normalOS);
                output.posOS    = input.posOS;
                output.posWS    = mul(unity_ObjectToWorld,input.posOS);
                output.posCS    = UnityObjectToClipPos(input.posOS);
                // float4 col = tex2Dlod(_MainTex, float4(input.uv2,_Mip,_Mip));
                // input.posOS.y += col.r;
                // float3 posWS = output.posWS;
                // posWS.y += col.r * sin(posWS.x+ posWS.z + _Time.y)*0.2;
                // output.posCS  =  mul(UNITY_MATRIX_VP, float4(posWS,1));
                
                return output;
            }
            
            float4 frag (VS2PSData input) : SV_Target 
            {
                float3 N = normalize(input.normalWS.xyz);
                float3 V = normalize( UnityWorldSpaceViewDir(input.posWS));//_WorldSpaceCameraPos.xyz - worldPos;
                float3 L = normalize( UnityWorldSpaceLightDir(input.posWS.xyz));//_WorldSpaceLightPos0.xyz
                // float4 col = tex2Dlod(_MainTex, float4(input.uv2,_Mip,_Mip));
                // return step(col.r,_RangeValue);
                float2 uv = input.uv2;
                float4 BaseMap = tex2D(_MainTex,uv);
                float4 NoiseMap = tex2D(_NoiseTex,uv);
                float yPos = input.posWS.y;

                // clip(yPos- _DissoveValue - NoiseMap.r);
                // =>
                // if(yPos- _DissoveValue - NoiseMap.r<0)
                    // discard;
                float test = yPos- _DissoveValue - NoiseMap.r;
                clip(test);
                //Dissove之后的颜色
                if(test<_DissoveWidth*saturate(_DissovedPercent))
                    return BaseMap*_DissovedColor;
                
                //Dissove的颜色
                if(test<_DissoveWidth)
                    return _DissoveColor;
                //过渡区域的颜色
                float dissoveRange = smoothstep(_DissoveRange,0,test);
                return lerp(BaseMap ,_DissoveRangeColor,dissoveRange);
                // float4 rangeColor =*_DissoveRangeColor;
                // return BaseMap + rangeColor;
            }
            
            ENDCG
        }
        
    }
}
