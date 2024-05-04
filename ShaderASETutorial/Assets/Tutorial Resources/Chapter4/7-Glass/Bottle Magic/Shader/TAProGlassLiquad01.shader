//1.RayMarching 光线步进
//2.光线追踪-射线与平面求交
//3.可以先不用学 Trick

Shader "TAPro/GlassLiquad01"
{
    Properties
    {
        _UVCut("UVCut", Range( 0 , 1)) = 0.585
        _LiquadHeight("Liquad Height",Float) = 0
        _Color1("Color 1",Color) = (1,1,1,1)
        _Color2("Color 2",Color) = (1,1,1,1)
        _TopColor("Top Color",Color) = (1,1,1,1)
        _TransColor("Trans Color",Color) = (1,1,1,1)
        _DeepColor("Deep Color",Color) = (1,1,1,1)
        [HDR]_LightColor("Light Color",Color) = (1,1,1,1)
        [Space(10)]
        _MainTex ("Texture", 2D) = "black" {}
        _BaseIntensity("Base Intensity", Range( 0 , 1)) = 1
        
        [Space(10)]
        _TestValue("Test Value",Vector)=(0,0,0,0)
        _TestValu2("Test Value2",Vector)=(0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
//            ZWrite Off
            Cull Off
//           Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Noise.cginc"

            struct appdata
            {
                float4 posOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normalOS:TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 posCS : SV_POSITION;
                float3 posOS : TEXCOORD1;
                float3 posWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _UVCut,_LiquadHeight;

            float4 _Color1,_Color2,_TopColor,_TransColor,_DeepColor,_LightColor;
            
            float _BaseIntensity;
            float4 _TestValue,_TestValu2;
            
            v2f vert (appdata input)
            {
                v2f o;
                // v.posOS.xyz +=normalize(v.normalOS.xyz)*  -0.04;
                o.posCS = UnityObjectToClipPos(input.posOS);
                o.uv = input.uv;
                o.posOS = input.posOS.xyz;
                o.posWS = mul(unity_ObjectToWorld,input.posOS);
                o.normalWS = UnityObjectToWorldNormal(input.normalOS);
                return o;
            }

            bool intersectPlane( float3 n,  float3 p0,  float3 rayPos,  float3 rayDir,out float t)
            {
                // assuming vectors are all normalized
                float denom = dot(n, rayDir);
                if (denom > 1e-6)
                {
                    float3 difference = p0 - rayPos;
                    t = dot(difference, n) / denom; 
                    return (t >= 0);
                }

                return false;
            }

            //射线与球的求交
            bool intersectSphere(float3 rayPos,  float3 rayDir,float3 center, float radius, out float2 distance)
            {
                float3 oc = rayPos - center;
                float b = dot(oc, rayDir);
                float c = dot(oc, oc) - radius * radius;
                float h = b * b - c;
                if (h < 0.0) return false; // no intersection
                h = sqrt(h);
                distance = float2(-b - h, -b + h);
                
                return true;
            }

            float3 HSVToRGB( float3 c )
		    {
			    float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			    float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			    return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		    }

            float3 Star(float3 pos,float speed =0)
            {
                float3 xyz = pos*40;
                xyz += float3(0,1,0)*speed*_Time.y;
                float noise = snoise(xyz)*0.5+0.5;
                float star = pow(noise,50)*50;
                return min(star,10);
            }

            float3 FlowStar(float3 pos,float3 Ray,float speed =0)
            {
                float3 color = HSVToRGB(float3(pos.y*10,1,1));
                pos =pos + Ray *0.5;
                float3 xyz = pos*40;
                xyz += float3(0,1,0)*speed*_Time.y;
                float noise = snoise(xyz)*0.5+0.5;
                float star = pow(noise,50)*50;
                return min(star,10)*color;
            }
            
            float3 Caustic(float3 pos)
            {
                float uvScale = 12;
                float3 speed = float3(1,0,1)*_Time.y;
                float caustic = Voronoi3D(pos*uvScale +float3(0.2,0,0.2) - speed);
                float caustic2 = Voronoi3D(pos*uvScale +float3(0.1,0,0.1) - speed);
                float caustic3 = Voronoi3D(pos*uvScale - float3(0.1,0,0.1)- speed);
                float3 c = float3(caustic,caustic2,caustic3);
                c = pow(c,5);
                return c;
            }
            
            float4 frag (v2f input,float isFront:VFACE) : SV_Target
            {
                float2 uv = input.uv;
                //裁剪掉内部瓶子
                clip(0.585-uv.y);

                //只适用于瓶子模型
                float hmin = 3.89f;
                float hmax = 1.78f;
                
                float v = step(input.posOS.z,_TestValu2.x);
                
                float h01 = 1-saturate((input.posOS.z - hmin)/(hmax-hmin));
                float3 color = lerp(_Color1,_Color2,h01);
                
                float3 V =  normalize(UnityWorldSpaceViewDir(input.posWS));
                float3 camPosOS = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos.xyz,1));
                
                float3 topColor =_TopColor;
                float t =0;
                
                float3 n = float3(0,-1,0);
                // float3 p0 = float3(0,4,0);
                float3 targetPos = float3(0,0,_LiquadHeight);
                float3 p0 = mul(unity_ObjectToWorld,float4(targetPos,1));
                float3 spherePos = p0;

                float dis =0 ;
                if(isFront==-1 && intersectPlane(-n,p0,input.posWS,V,t))
                {
                    // float3 hitPos = input.posWS.xyz + V *t;
                    float3 hitPos = input.posWS + V *t;
                    dis = distance(hitPos,p0);
                    dis =1- saturate(dis/_TestValue.x);
                    // return  saturate(dis/_TestValue.x)<_TestValue.y;
                }
                
                //模拟波浪
                p0.y += sin( input.posWS.x*10+input.posWS.z*10 + _Time.y*5 + cos( input.posWS.x + input.posWS.z +input.posWS.y*5))*0.02;
                
                float heightCutValue = p0.y - input.posOS.z;
                clip( heightCutValue);

                float3 posWS = input.posWS;

                //背面
                if(isFront==-1 && intersectPlane(-n,p0,input.posWS,V,t))
                {
                    float3 hitPos = input.posWS + V *t;
                    float3 base =  tex2D(_MainTex,hitPos.xz*_MainTex_ST.xy + _MainTex_ST.zw);
                    
                    topColor = lerp(_TopColor,base*0.5,_BaseIntensity);
                                        
                    topColor = lerp(topColor,_DeepColor,exp(-t));
                    
                    topColor += (( t<0.1))*_TopColor;
                    
                    topColor += Star(input.posWS)*0.25;
                    posWS = hitPos;
                    // return float4(topColor,0.9) ;
                }
                /*
                p0.y -=0.03;
                //正面
                if(isFront==1 && intersectPlane(n,p0,input.posWS,-V,t))
                {
                   // return float4(1,0,0,1);
                    // float3 hitPos = input.posWS.xyz + V *t;
                    float3 hitPos = input.posWS - V *t;
                    // float3 base =  tex2D(_MainTex,hitPos.xz*_MainTex_ST.xy + _MainTex_ST.zw);
                    // topColor = lerp(_TopColor,base,_BaseIntensity);
                    topColor += (( t<0.1))*_TopColor;
                    // dis = distance(hitPos,p0);
                    // dis =1- saturate(dis/_TestValue.x);
                    // topColor += dis*float3(10,0,1);
                    posWS = hitPos;
                    // return 1;
                    // return float4(topColor,0.9) ;
                }
                */

                //吃水线颜色
                if(heightCutValue <0.02)
                {
                    color = _TopColor;
                }

                //透射颜色
                float trans01 = 1- saturate( heightCutValue / 0.3);
                color += trans01*_TransColor;
                // color = lerp(color,_TransColor, trans01);


                color += FlowStar(input.posWS,-V,-1)*0.5;
                    // return color.xyzz;

                //体积光 光线步进
                //1.射线与球求交
                //2.RayMarching
                //3.建议学完体积云的效果之后在来看这个地方的代码
                
                float2 hit;
                spherePos = p0 + float3(0,_TestValue.x,0);
                float radius = 1;
                float3 rayDir = -V;
                float3 rayPos = posWS;
                float3 lightColor = (float3)0;
                if(intersectSphere(rayPos,rayDir, spherePos, radius,hit))
                {
                    float3 hitPos = rayPos +rayDir*hit.x;//入射点
                    float maxDis = hit.y - hit.x;//最大距离
                    float samples = 32;
                    float step = 1.0/samples;
                    float3 rayPos = hitPos;
                    float totalDistance =0;
                    float sum = 0;
                    for (int i=0;i<samples;i++)
                    {
                        float3 pos = rayPos + i*step*rayDir;
                        float density = distance(pos,spherePos)/radius;
                        sum += density;
                        if(totalDistance >= maxDis) break;
                        // if(sum>=1) break; 
                    }
                    
                    float3 light = exp(-sum*step*_TestValue.z)*_TestValue.w;
                    lightColor = light*_LightColor;
                    // return float4(1,0,0,1);
                }

                topColor = lerp(topColor,lightColor,0.3);
                color = lerp(color,lightColor,0.2);

                
                float3 finalColor = lerp(topColor ,color,isFront==1);
                
                float3 caustic = Caustic(input.posWS- V*0.1);
                finalColor += caustic*0.1;
                
                return float4(finalColor ,1);
                
            }
            ENDCG
        }
    }
}
