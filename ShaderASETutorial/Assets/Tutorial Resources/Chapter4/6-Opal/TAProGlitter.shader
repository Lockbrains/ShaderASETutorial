Shader "TAPro/06/TAProGlitter"
{
    Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseSizeCoeff("_NoiseSizeCoeff (Bigger => larger glitter spots)", Float) = 0.61
		_NoiseDensity("NoiseDensity (Bigger => larger glitter spots)", Float) = 53.0

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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 posOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};


			float3 mod289(float3 x) {
			  return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			float4 mod289(float4 x) {
			  return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			float4 permute(float4 x) {
			     return mod289(((x*34.0)+1.0)*x);
			}

			float4 taylorInvSqrt(float4 r)
			{
			  return 1.79284291400159 - 0.85373472095314 * r;
			}


			//FIXME: make as parameter
			float _NoiseSizeCoeff; // Bigger => larger glitter spots
			float _NoiseDensity;  // Bigger => larger glitter spots



			static const float2  C = float2(1.0/6.0, 1.0/3.0) ;
			static const float4  D = float4(0.0, 0.5, 1.0, 2.0);
			float snoise(float3 v)
			  { 

			  // First corner
			  float3 i  = floor(v + dot(v, C.yyy) );
			  float3 x0 =   v - i + dot(i, C.xxx) ;

			  // Other corners
			  float3 g = step(x0.yzx, x0.xyz);
			  float3 l = 1.0 - g;
			  float3 i1 = min( g.xyz, l.zxy );
			  float3 i2 = max( g.xyz, l.zxy );

			  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
			  //   x1 = x0 - i1  + 1.0 * C.xxx;
			  //   x2 = x0 - i2  + 2.0 * C.xxx;
			  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
			  float3 x1 = x0 - i1 + C.xxx;
			  float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
			  float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

			  // Permutations
			  i = mod289(i); 
			  float4 p = permute( permute( permute( 
			             i.z + float4(0.0, i1.z, i2.z, 1.0 ))
			           + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
			           + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

			  // Gradients: 7x7 points over a square, mapped onto an octahedron.
			  // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
			  float n_ = 0.142857142857; // 1.0/7.0
			  float3  ns = n_ * D.wyz - D.xzx;

			  float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

			  float4 x_ = floor(j * ns.z);
			  float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

			  float4 x = x_ *ns.x + ns.yyyy;
			  float4 y = y_ *ns.x + ns.yyyy;
			  float4 h = 1.0 - abs(x) - abs(y);

			  float4 b0 = float4( x.xy, y.xy );
			  float4 b1 = float4( x.zw, y.zw );

			  float4 s0 = floor(b0)*2.0 + 1.0;
			  float4 s1 = floor(b1)*2.0 + 1.0;
			  float4 sh = -step(h, (float4)(0.0));

			  float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
			  float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

			  float3 p0 = float3(a0.xy,h.x);
			  float3 p1 = float3(a0.zw,h.y);
			  float3 p2 = float3(a1.xy,h.z);
			  float3 p3 = float3(a1.zw,h.w);

			  // Normalise gradients
			  float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
			  p0 *= norm.x;
			  p1 *= norm.y;
			  p2 *= norm.z;
			  p3 *= norm.w;

			  // Mix final noise value
			  float4 m = max(_NoiseSizeCoeff - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
			  m = m * m;
			  return _NoiseDensity * dot( m*m, float4( dot(p0,x0), dot(p1,x1), 
			                                dot(p2,x2), dot(p3,x3) ) );
			}

			
			float3 linearLight( float3 s, float3 d )
			{
				return 2.0 * s + d - 1.0;
			}


			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.posOS);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float4 col = tex2D(_MainTex, i.uv)*0.5;
				
				float3 pos =  float3(i.uv * float2( 3. , 1.) - float2(0., _Time.y * .00005), _Time.y * .006);   
    			float n =  smoothstep(.50, 1.0, snoise(pos * 80.)) * 8.;
	
				float3 noiseGreyShifted = min(((float3)(n) + 1.) / 3. + .3, (float3)(1.)) * .91;
				
				col = float4(linearLight(noiseGreyShifted, col), 1.0);
				return col;
			}
			ENDCG
		}
	}
}
