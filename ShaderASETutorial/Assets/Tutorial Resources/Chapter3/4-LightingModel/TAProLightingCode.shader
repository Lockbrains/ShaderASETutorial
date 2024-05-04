Shader "TAPro/TAProLightingCode"
{
    //材质参数 ShaderLab
    Properties
    {
        [NoScaleOffset]_MainTex ("_MainTex", 2D) = "white" {}
//        _MainTex2 ("_MainTex", 2D) = "grey" {}
//        _MainTex3 ("_MainTex", 2D) = "black" {}
//        _MainTex4 ("_MainTex", 2D) = "bump" {} //(0,0,0.5,0)
//        _Color("Color",Color) = (0,1,1,0)
//        [HDR]_HDRColor("HDR Color",Color) = (0,1,1,0)
//        _Value("Value",Float) = 0.5
        _Wrap("_Wrap",Range(0,1)) = 0.5
//        _Vec("Vec",Vector)=(1,1,0,0)
//        _Alpha("Alpha",Range(0,1)) = 1
//        _Mip("Mip",Float) = 0
        
        _CheapSSS_Lerp_Pow_Scale("_CheapSSS_Lerp_Pow_Scale",Vector) = (0,1,1,0)
        
        _Phong_Pow_Scale("_Phong_Pow_Scale",Vector) = (1,1,0,0)
        _BlinPhong_Pow_Scale("_BlinPhong_Pow_Scale",Vector) = (1,1,0,0)
        _AmbientColor("Ambient",Color) = (0.5,0.5,0.5,0.5)
        
        _VirtualLightPos("Virtual Light Pos",Vector)=(0,0,0,0)
        _VirtualLightFade("Virtual Light Fade",Float) = 0
        [HDR]_VirtualLightColor("Virtual Light Color",Color) = (1,1,1,1)
        
        [HDR]_RimColor("Rim Color",Color) = (1,1,1,1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            
            CGPROGRAM
            
            //编译指令
            #pragma vertex vert
            #pragma fragment frag
                        
            //头文件
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
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
                float gouraud   : TEXCOORD6;
            };

            //申明变量 局部变量
            sampler2D _MainTex;
            float4 _MainTex_ST;//scale offset
            float _Wrap;
            float4 _CheapSSS_Lerp_Pow_Scale;
            float4 _Phong_Pow_Scale;
            float4 _BlinPhong_Pow_Scale;
            float4 _AmbientColor;

            //点光
            float4 _PointLightColorAndRange;
            float4 _PointLightPos;
            
            float _DiffuseWrap;

            //聚光光
            float4 _SpotLightColorAndRange;
            float4 _SpotLightDirAndAngle;
            float4 _SpotLightPos;

            // float _Segments[4];

            //局部虚拟光
            float4 _VirtualLightPos,_VirtualLightColor;
            float _VirtualLightFade;

            //全局虚拟光
            float4 _Global_VirtualLightPosAndFade,_Global_VirtualLightColor;

            float4 _RimColor;

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
                output.posCS    = UnityObjectToClipPos(input.posOS);

                float3 N =  output.normalWS;
                float3 V = normalize( UnityWorldSpaceViewDir(output.posWS));//_WorldSpaceCameraPos.xyz - worldPos;
                float3 L = normalize( UnityWorldSpaceLightDir(output.posWS.xyz));//_WorldSpaceLightPos0.xyz
                float3 RL = reflect(-L,N);

                float gouraud = pow(dot(V,RL),100)*10;
                output.gouraud = gouraud;
                
                return output;
            }

            float Diffuse_Wrap(float3 N,float3 L,float Wrap=0.5)
            {
                float NL = dot(N,L);
                float WrapLight = saturate((NL +Wrap)/(1.0+Wrap));
                return WrapLight;
            }

            float Specular_BlinPhong(float3 N,float3 L,float3 V,float2 BPPowScale)
            {
                float3 H = normalize(L+V);
                float BlinPhong = pow(saturate(dot(N,H)),BPPowScale.x*100)*BPPowScale.y;
                return BlinPhong;
            }

            float Lighting(float3 N,float3 L,float3 V,float2 BPPowScale,float Wrap=0.5)
            {
                float Diffuse = Diffuse_Wrap(N,L,Wrap);
                float Specular = Specular_BlinPhong(N,L,V,BPPowScale);
                return Diffuse+Specular;
            }
            
            float4 frag (VS2PSData input) : SV_Target 
            {
                float3 N = normalize(input.normalWS.xyz);
                float3 V = normalize( UnityWorldSpaceViewDir(input.posWS));//_WorldSpaceCameraPos.xyz - worldPos;
                float3 L = normalize( UnityWorldSpaceLightDir(input.posWS.xyz));//_WorldSpaceLightPos0.xyz
                float3 ReflectL = reflect(-L,N);
                float3 H = normalize(L+V);
                float4 BaseMap = tex2D(_MainTex, input.uv2);

                /*
                Lambert = NL
                HalfLambert = NL*0.5+0.5
                WrapLight =saturate( (NL+_Wrap)/(1+_Wrap))
                BandedLight = floor((NL*0.5+0.5)*StripNum)/StripNum;
                CheapSSS = pow( dot(V,normalize(-(N*b+L))) ,e )*s;
                Phong=pow(VR,e)*s
                BlinPhong=pow(NH,e)*s
                Gouraud=pow(VR,e)*s      (VertexShader)
                */

                float4 FinalColor = (float4)0;
                float3 Diffuse = (float4)0;
                float3 Specular = (float4)0;

                float NL = dot(N,L);
                float NL01 = NL*0.5+0.5;
                float Lambert = saturate(NL);
                float HalfLambert = NL01;

                float WrapLight = saturate((NL +_Wrap)/(1.0+_Wrap));

                float CheapSSS = pow( saturate( dot(V, -normalize((N*max(1,_CheapSSS_Lerp_Pow_Scale.x)+L)))) , _CheapSSS_Lerp_Pow_Scale.y)*_CheapSSS_Lerp_Pow_Scale.z;

                float Phong = pow(dot(V,ReflectL),_Phong_Pow_Scale.x*100)*_Phong_Pow_Scale.y;
                float BlinPhong = pow(saturate(dot(N,H)),_BlinPhong_Pow_Scale.x*100)*_BlinPhong_Pow_Scale.y;

                float4 RimLight = pow(1-dot(N,V),2)*2 * BaseMap*_RimColor;
                
                Diffuse = WrapLight*BaseMap;
                Specular = BlinPhong*BaseMap;
                float4 Ambient = _AmbientColor*BaseMap;
               
                
                FinalColor = (Diffuse.xyzz + Specular.xyzz)* _LightColor0.xyzz + Ambient + RimLight +CheapSSS;

                // float dis = distance(_PointLightPos.xyz,input.posWS);
                // float atten = 1.0/( dis*dis);
                // float3 dir = normalize(_PointLightPos.xyz-input.posWS);
                // return BaseMap*atten;


         // float4 _SpotLightColorAndAngle;
         //    float4 _SpotLightDirAndAngle;
         //    float4 _SpotLightPos;

                //Point Lighting
                {
                    // float4 _PointLightColorAndRange;
                    // float4 _PointLightPos;
                    float3 pointVec = _PointLightPos.xyz - input.posWS;
                    float pointDis = length(pointVec);
                    float3 pointDir = normalize(pointVec);

                    float pointLightTrans = 1.0-saturate( pointDis/_PointLightColorAndRange.w);

                    float pointAtten = 1.0/(pointDis*pointDis);
                    float smooth = smoothstep(0.1,1,pointLightTrans);

                    // float4 PointDiffuse = saturate(dot(N,pointDir));
                    
                    float4 PointDiffuse = Diffuse_Wrap(N,pointDir,_DiffuseWrap);
                    float4 PointSpecular = Specular_BlinPhong(N,pointDir,V,_Phong_Pow_Scale.xy);
                    float4 PointLighting =(float4)0;

                    if(_PointLightPos.w ==0)
                    {
                        PointLighting = PointDiffuse+PointSpecular;
                    }
                    else if(_PointLightPos.w ==1)
                    {
                        PointLighting =  PointDiffuse;
                    }
                    else
                    {
                        PointLighting =  PointSpecular;
                    }
                    
                    FinalColor += BaseMap* pointAtten*_PointLightColorAndRange*smooth*PointLighting;
                }

                //Spot Lighting
                {                
                    float3 spotDir = normalize(_SpotLightPos.xyz - input.posWS);
                    
                    float theta = dot(spotDir,normalize(- _SpotLightDirAndAngle.xyz));
                    // float delta = cos(_SpotLightDirAndAngle.w);
                    float maxAngle = cos(_SpotLightDirAndAngle.w);
                    
                    if(maxAngle<theta)
                    {
                        float dis = distance(_SpotLightPos.xyz ,input.posWS);
                        float att =1.0/(dis*dis);
                        // float isInRange = step(dis,_SpotLightColorAndRange.w);
                        float isInRange = 1.0-saturate(dis/_SpotLightColorAndRange.w);
                        isInRange = smoothstep(0.1,1,isInRange);//软边
                        
                        float softness = 0.2;
                        float smooth = (theta-maxAngle)/(maxAngle*softness);

                        float4 spotAtten = att*_SpotLightColorAndRange.rgbb*isInRange*smooth;

                        float4 spotPointDiffuse = Diffuse_Wrap(N,spotDir,_DiffuseWrap);
                        float4 spotPointSpecular = Specular_BlinPhong(N,spotDir,V,_Phong_Pow_Scale.xy);
                        float4 spotPointLighting =(float4)0;

                        if(_SpotLightPos.w ==0)
                        {
                            spotPointLighting = spotPointDiffuse+spotPointSpecular;
                        }
                        else if(_SpotLightPos.w ==1)
                        {
                            spotPointLighting =  spotPointDiffuse;
                        }
                        else
                        {
                            spotPointLighting =  spotPointSpecular;
                        }
                        
                        FinalColor += BaseMap*spotPointLighting*spotAtten;
                    }
                }

                //Local Virtual Light
                {
                     //虚拟光
            // float4 _VirtualLightPos,_VirtualLightColor;
            // float _VirtualLightFade;
                    // float virtualLightDis = distance(_VirtualLightPos.xyz,input.posWS);
                    float virtualLightDis = distance(_VirtualLightPos.xyz*0.01,input.posOS);
                    float4 virtualLight = exp(-_VirtualLightFade*virtualLightDis)*_VirtualLightColor;
                    FinalColor += virtualLight*BaseMap;
                }

                //Global Virtual Light
                {
                     // float4 _Global_VirtualLightPosAndFade,_Global_VirtualLightColor;
                    float gloabalVirtualLightDis = distance(_Global_VirtualLightPosAndFade.xyz,input.posWS);
                    float4 glocalVirtualLight = exp(-_Global_VirtualLightPosAndFade.w*gloabalVirtualLightDis)*_Global_VirtualLightColor;
                    FinalColor += glocalVirtualLight*BaseMap;
                }
                
                return FinalColor.xyzz;
                
            }
            
            ENDCG
        }
        
    }
}
