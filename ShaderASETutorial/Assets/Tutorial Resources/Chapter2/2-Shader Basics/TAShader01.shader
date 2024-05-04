Shader "TAPro/TAShader01"
{
    //材质参数 ShaderLab
    Properties
    {
        [NoScaleOffset]_MainTex ("_MainTex", 2D) = "white" {}
//        _MainTex2 ("_MainTex", 2D) = "grey" {}
//        _MainTex3 ("_MainTex", 2D) = "black" {}
//        _MainTex4 ("_MainTex", 2D) = "bump" {} //(0,0,0.5,0)
        _Color("Color",Color) = (0,1,1,0)
        [HDR]_HDRColor("HDR Color",Color) = (0,1,1,0)
        _Value("Value",Float) = 0.5
        _RangeValue("Range Value",Range(0,1)) = 0.5
        _Vec("Vec",Vector)=(1,1,0,0)
        _Alpha("Alpha",Range(0,1)) = 1
        _Mip("Mip",Float) = 0
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

            float _Alpha;

            //全局变量
            float _DissoveValue;
            float _Mip;
            struct Data
            {
                float4 Red;
                float4 Green;
                float4 Color;
            };

            void SetValue()
            {
                
            }

            void SetOutputValue_inout(inout  Data data)
            {
                data.Red = float4(1,0,0,1);
                data.Green = float4(0,1,0,1);
                data.Color = float4(0,1,1,1);
            }

            void SetOutputValue2(float4 value)
            {
                value = float4(0,1,0,1);
            }

            void SetOutputValue3_out(out float4 value)
            {
                value = float4(0,1,0,1);
            }

            
            float4 GetValue()
            {
                return float4(1,0,0,1);
            }
            
            Data GetData(float color)
            {
                Data data;
                data.Color = color*10;
                data.Red = float4(1,0,0,1);
                data.Green = float4(0,1,0,1);
                return data;
            }
                
            //vs 传给 ps 的数据是 VS2PSData
            VS2PSData vert (MeshData input)
            {
                VS2PSData output;
                //位置 局部坐标 ->裁剪坐标
                // output.posCS =  mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(input.posOS.xyz, 1.0)));
                output.uv    = input.uv;
                output.uv2   = input.uv2;
                output.normalOS = input.normalOS;
                output.normalWS = UnityObjectToWorldNormal(input.normalOS);
                output.posOS    = input.posOS;
                output.posWS    = mul(unity_ObjectToWorld,input.posOS);

                float4 col = tex2Dlod(_MainTex, float4(input.uv2,_Mip,_Mip));
                // input.posOS.y += col.r;
                float3 posWS = output.posWS;
                // posWS.y += col.r * sin(posWS.x+ posWS.z + _Time.y)*0.2;
                output.posCS  =  mul(UNITY_MATRIX_VP, float4(posWS,1));
                // output.posCS = UnityObjectToClipPos(input.posOS);

                /*
                //没处理非均匀变换
                float3 normalWS = mul(unity_ObjectToWorld,float4(input.normalOS.xyz,0));
                //处理非均匀变换
                //逆转
                // float3 normalWSRight = mul(float4(input.normalOS.xyz,0),unity_WorldToObject);
                float3 normalWSRight = normalize( mul(input.normalOS.xyz,(float3x3)unity_WorldToObject));
                output.normalWS = normalWSRight;
                */
                
                return output;
            }
            

            #define RED float4(1,0,0,1)
            #define ADD233(a,b) a+b
            float _RangeValue;

            // struct FinalData
            // {
            //     float4 FinalColor : SV_Target ;
            // };

            float4 frag (VS2PSData input) : SV_Target 
            {
                float3 N = normalize(input.normalWS.xyz);
                float3 V = normalize( UnityWorldSpaceViewDir(input.posWS));//_WorldSpaceCameraPos.xyz - worldPos;
                float3 L = normalize( UnityWorldSpaceLightDir(input.posWS.xyz));//_WorldSpaceLightPos0.xyz
                float4 col = tex2Dlod(_MainTex, float4(input.uv2,_Mip,_Mip));
                return step(col.r,_RangeValue);
                return lerp( col,float4(1,1,1,1), saturate( N.y) );
                
                /*
                float4 red = float4(1,0,0,1);
                float4 green = float4(0,1,0,1);
                // return RED;
                Data data =(Data)0;
                SetOutputValue_inout(data);
                return data.Color;
                
                float4 col = tex2D(_MainTex, input.uv2*_MainTex_ST.xy +_MainTex_ST.zw*_Time.y*0.1);
                return col;
                */
            }
            
            ENDCG
        }
        
    }
}
