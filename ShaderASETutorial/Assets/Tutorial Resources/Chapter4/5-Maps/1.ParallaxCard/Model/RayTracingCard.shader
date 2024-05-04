Shader "TAPro/RayTracingCard"
{
    Properties
    {
        [Space(50)]
        [HDR]_FrameTint("_FrameTint ",Color)= (1,1,1,1)
        _Frame("Frame",2D) = "Black"{}
        
        [Space(50)]
        [HDR]_ParallaxMapTint("_ParallaxMapTint ",Color)= (1,1,1,1)
        _ParallaxMap("Parallax Map",2D) = "Black"{}
        _Depth("Depth",Float) = 0
        
        [Space(50)]
        [HDR]_ParallaxMap2Tint("_ParallaxMap2Tint ",Color)= (1,1,1,1)
        _ParallaxMap2("Parallax Map 2",2D) = "Black"{}
        _Depth2("Depth 2",Float) = 0
        
        [Space(50)]
        [HDR]_P2NoiseTint("_P2NoiseTint ",Color)= (1,1,1,1)
        _P2NoiseMap("_P2NoiseMap",2D) = "White"{}
        _P2NoiseMapVec(" _P2NoiseMapVec",Vector) = (1,1,1,1)
        
        [Space(50)]
        [HDR]_BackgroundTint("_Background Tint",Color)= (1,1,1,1)
        _BackgroundMap("_Background Map",2D) = "Black"{}
//      _BackgroundDepth("_BackgroundDepth",Float) = 0
        
        [Toggle] _EnableColorfulBackground("开启彩色",Float) = 0
        [HDR]_RainbowMapTint("_RainbowMapTint Tint",Color)= (1,1,1,1)
        _RainbowMap("RainbowMap Map",2D) = "White"{}
    } 
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "LightMode"="ForwardBase" "Queue" = "Geometry"
        }
        
        Pass
        {
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CloudTex;

            sampler2D _ParallaxMap,_HeightMap;float4 _ParallaxMap_ST;float _Depth;
            sampler2D _ParallaxMap2,_HeightMap2;float4 _ParallaxMap2_ST;float _Depth2;

            sampler2D _Frame;float4 _Frame_ST;
            
            float _UVScale;
            float4 _ParallaxMapTint,_ParallaxMap2Tint,_FrameTint;


            //背景层流光
            float4 _P2NoiseTint,_P2NoiseMapVec;
            sampler2D _P2NoiseMap;

            //背面层
            sampler2D  _BackgroundMap;
            float4 _BackgroundTint;
            float4 _BackgroundMap_ST;
            float _EnableColorfulBackground;

            float4 _RainbowMapTint,_RainbowMap_ST;
            sampler2D _RainbowMap;

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
                float3 posWS : TEXCOORD4;
                float3 localPosition : TEXCOORD5;
                float3 localNormal : TEXCOORD6;
                float4 vertexColor : TEXCOORD7;
                float2 uv2 : TEXCOORD8;
            };

            V2FData vert(MeshData v)
            {
                V2FData o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.localPosition = v.vertex.xyz;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                o.localNormal = v.normal;
                o.vertexColor = v.vertexColor;

                return o;
            }

            float4 ParallaxMapping(sampler2D ParallaxMap, float depth , float2 uv, float4 ParallaxMap_ST, float3 viewTS)
            {
                uv = uv*ParallaxMap_ST.xy + ParallaxMap_ST.zw;
                
                float cosTheta = dot(viewTS,float3(0,0,1));
                float viewTSLength = depth / cosTheta;
                float3 startPoint = float3(uv,0);
                float3 endPoint = startPoint + viewTS*viewTSLength;
                float4 parallax = tex2D(ParallaxMap,saturate( endPoint.xy));
                return parallax;
            }

            float4 ParallaxMappingOutUV(sampler2D ParallaxMap, float depth , float2 uv, float4 ParallaxMap_ST, float3 viewTS,out float2 ParallaxUV)
            {
                uv = uv*ParallaxMap_ST.xy + ParallaxMap_ST.zw;
                
                float cosTheta = dot(viewTS,float3(0,0,1));
                float viewTSLength = depth / cosTheta;
                float3 startPoint = float3(uv,0);
                float3 endPoint = startPoint + viewTS*viewTSLength;
                float4 parallax = tex2D(ParallaxMap,saturate( endPoint.xy));
                ParallaxUV= endPoint.xy;
                return parallax;
            }
            
            float3 HsvToRgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            //VFace 是背面的关键字
            //用法：bool backFace:VFace
            float4 frag(V2FData input,float backFace:VFace) : SV_Target
            {
                float3 T = normalize(input.tangent);
                float3 N = normalize(input.normal);
                //float3 B = normalize( cross(N,T));
                float3 B = normalize(input.bitangent);
                float3 L = normalize(UnityWorldSpaceLightDir(input.posWS.xyz));
                float3 V = normalize(UnityWorldSpaceViewDir(input.posWS.xyz));
                float2 uv = input.uv;

                //非0为真
                
                //背面层
                if(backFace<0)
                {
                    float2 revertUV = float2(1-uv.x,uv.y);
                    float2 backMapUV = revertUV*_BackgroundMap_ST.xy + _BackgroundMap_ST.zw;
                    float4 backMap = tex2D(_BackgroundMap,backMapUV)*_BackgroundTint;
                    float4 back = backMap;
                    
                    if(_EnableColorfulBackground)
                    {
                        //反面的法线翻转一下
                        N = -N;
                        float3 H = normalize(V + L *0.2 + V + T*0.3);
                        // float3 H = normalize( V + L );
                        float nh = saturate( dot(N,H) );

                        float4 rainbow2 = HsvToRgb(float3(uv.y*5.5 + nh*5,1,1)).xyzz;

                        float4 rainbow = tex2D(_RainbowMap,uv*_RainbowMap_ST.xy+_RainbowMap_ST.zw)*2 + rainbow2;
                        
                        float lum = Luminance(backMap);
                        float mask = abs(sin(nh*10*3.14));
                        
                        back = backMap + mask * pow(nh,300) *128*rainbow*lum ;
                        
                        // return nh;
                    }
                    return back;
                }
             
                
                //TBN:将世界空间转到切线空间
                float3x3 TBN = float3x3(T,B,N);
                
                //将V转到深度空间
                float3 viewTS = mul(TBN,V);

                //计算图片1 的深度坐标
                float4 p1 = ParallaxMapping(_ParallaxMap, _Depth,uv,_ParallaxMap_ST,viewTS) *_ParallaxMapTint;
                
                //计算图片2 的深度坐标
                float2 parallaxUVP2;
                float4 p2 = ParallaxMappingOutUV(_ParallaxMap2, _Depth2,uv,_ParallaxMap2_ST,viewTS,parallaxUVP2) ;
                
                //p2流光
                float noise = tex2D(_P2NoiseMap,parallaxUVP2 + float2(0,_Time.x*0.8) );
                float noise2 = tex2D(_P2NoiseMap,parallaxUVP2.yx - float2(_Time.x,_Time.x*0.9) );
                
                noise = pow(noise*noise2,_P2NoiseMapVec.x) * _P2NoiseMapVec.y;
                //可优化
                p2 = p2 *(1+ noise * ( Luminance(p2) > (2.0 / 256.0) ) ) * _ParallaxMap2Tint;
                
                //采样画框,不需要计算出视差
                float4 frame = tex2D(_Frame,uv*_Frame_ST.xy+_Frame_ST.zw);
                
                //画框流光
                frame = frame + ( frame)* pow(sin( uv.y + _Time.y*0.5),4) *0.5;
                
                //通过Alpah蒙版进行融合,图片1 在 图片2的上面
                float4 color = lerp(p2,p1,p1.a);

                //通过Alpah蒙版进行融合,相框在最碗面
                float alpha = Luminance(frame.rgb);
                
                color = lerp(color,frame*_FrameTint,alpha);
                // color = color + frame*10;
                
                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}

// p2 -> p1 -> frame