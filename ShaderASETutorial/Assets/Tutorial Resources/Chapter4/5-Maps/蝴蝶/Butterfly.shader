// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Butterfly"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_PivotPoint("PivotPoint", Vector) = (0,0,0,0)
		_Mask("Mask", 2D) = "white" {}
		_Vec_UVScale_Depth_Pow_Scale("Vec_UVScale_Depth_Pow_Scale", Vector) = (0,0,0,0)
		_Cloud_Pow_Scale("Cloud_Pow_Scale", Vector) = (0,0,0,0)
		[Toggle]_ChangeColor("ChangeColor", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct V2FData
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float3 _PivotPoint;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			uniform float _ChangeColor;
			uniform float4 _Vec_UVScale_Depth_Pow_Scale;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float2 _Cloud_Pow_Scale;
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			
			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float mulTime7 = _Time.y * 5.0;
				float3 objToWorld124 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
				float lerpResult19 = lerp( -1.0 , 1.0 , step( 0.0 , v.vertex.xyz.x ));
				float3 rotatedValue5 = RotateAroundAxis( _PivotPoint, v.vertex.xyz, float3(0,0,1), ( sin( ( mulTime7 + ( ( objToWorld124.x + objToWorld124.y + objToWorld124.z ) * 100.0 ) ) ) * 0.2 * lerpResult19 ) );
				float2 uv_Mask = v.ase_texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode12 = tex2Dlod( _Mask, float4( uv_Mask, 0, 0.0) );
				float3 lerpResult13 = lerp( v.vertex.xyz , rotatedValue5 , tex2DNode12.r);
				float3 VertexAnim25 = lerpResult13;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = VertexAnim25;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (V2FData i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float4 break41 = _Vec_UVScale_Depth_Pow_Scale;
				float simplePerlin3D37 = snoise( ( -ase_worldViewDir * break41.y )*break41.x );
				simplePerlin3D37 = simplePerlin3D37*0.5 + 0.5;
				float2 uv_Mask = i.ase_texcoord1.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode12 = tex2D( _Mask, uv_Mask );
				float WingMask47 = tex2DNode12.r;
				float2 texCoord52 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float simpleNoise51 = SimpleNoise( ( texCoord52 + ( float2( 1,0 ) * _Time.y * 0.4 ) )*20.0 );
				float3 break155 = abs( i.ase_texcoord2.xyz );
				float3 hsvTorgb73 = HSVToRGB( float3(( ( break155.x + break155.y + break155.z ) * 5.0 ),1.0,1.0) );
				float3 Star49 = ( min( ( pow( simplePerlin3D37 , break41.z ) * break41.w * WingMask47 * pow( simpleNoise51 , 8.0 ) ) , 100.0 ) * hsvTorgb73 );
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 BaseMap94 = tex2D( _MainTex, uv_MainTex );
				float mulTime84 = _Time.y * 0.5;
				float simplePerlin3D104 = snoise( ( WorldPosition + ( float3(0,1,0) * mulTime84 * 0.4 ) )*2.0 );
				simplePerlin3D104 = simplePerlin3D104*0.5 + 0.5;
				float4 Cloud92 = ( pow( simplePerlin3D104 , _Cloud_Pow_Scale.x ) * _Cloud_Pow_Scale.y * BaseMap94 * WingMask47 );
				float4 Color111 = ( float4( Star49 , 0.0 ) + ( BaseMap94 * 0.5 ) + Cloud92 );
				float mulTime116 = _Time.y * 0.1;
				float3 hsvTorgb114 = RGBToHSV( Color111.rgb );
				float3 objToWorld121 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 hsvTorgb113 = HSVToRGB( float3(frac( ( mulTime116 + hsvTorgb114.x + ( objToWorld121.x + objToWorld121.y + objToWorld121.z ) ) ),hsvTorgb114.y,hsvTorgb114.z) );
				
				
				finalColor = (( _ChangeColor )?( float4( hsvTorgb113 , 0.0 ) ):( Color111 ));
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
89.71429;374.8571;2046.286;1051.572;1180.624;161.5554;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;109;-4350.687,-2717.908;Inherit;False;2439.029;1345.068;Star;31;34;29;55;41;58;57;35;56;52;33;53;54;61;37;51;63;60;48;76;72;39;75;74;73;31;77;49;152;154;155;156;Star;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;29;-4247.978,-2304.362;Inherit;False;Property;_Vec_UVScale_Depth_Pow_Scale;Vec_UVScale_Depth_Pow_Scale;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;700,0.2,50,10000;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;55;-4231.685,-1865.433;Inherit;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;57;-4277.688,-1740.434;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;34;-4013.093,-2496.358;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;58;-4255.212,-1629.369;Inherit;False;Constant;_Float6;Float 6;5;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;35;-3832.292,-2479.058;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;107;-4197.475,-1133.026;Inherit;False;1998.003;825.1478;Cloud;13;80;97;96;98;84;82;106;86;105;100;104;92;110;Cloud;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-4054.685,-1846.434;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-4235.801,-592.7908;Inherit;False;Constant;_Float11;Float 11;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;72;-3959.65,-1655.983;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;41;-3851.292,-2298.425;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-4125.684,-2016.433;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;27;-4217.919,-87.16209;Inherit;False;2816.356;952.9941;VertexAnim;20;25;13;14;5;6;15;9;24;8;16;123;7;126;125;22;23;127;124;47;12;VertexAnim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;84;-4083.519,-627.9158;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;154;-3769.875,-1656.291;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;12;-2332.882,347.8376;Inherit;True;Property;_Mask;Mask;2;0;Create;True;0;0;0;False;0;False;-1;9ae2f733c0d0b4243beccea3002e16f5;9ae2f733c0d0b4243beccea3002e16f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-4038.047,-525.8515;Inherit;False;Constant;_Float10;Float 10;5;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-3856.685,-1997.433;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-3863.685,-1820.434;Inherit;False;Constant;_Float5;Float 5;5;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3663.292,-2475.425;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;106;-4138.993,-836.4996;Inherit;False;Constant;_Vector2;Vector 2;5;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1950.354,400.4843;Inherit;False;WingMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;37;-3472.366,-2464.889;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;51;-3531.585,-1972.133;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;110;-3913.309,-951.9968;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;61;-3257.386,-1834.633;Inherit;False;Constant;_Float7;Float 7;5;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-3837.518,-742.9158;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;131;-1146.506,-1067.193;Inherit;False;590.782;280;BaseMap;2;1;94;BaseMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;155;-3643.875,-1654.291;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;76;-3493.611,-1518.613;Inherit;False;Constant;_Float8;Float 8;4;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-3659.57,-898.9627;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-1095.506,-1017.193;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;82657161fac17bc42a5874503b7c95e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-3464.875,-1647.291;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-3665.801,-698.7908;Inherit;False;Constant;_Float9;Float 9;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;60;-3106.386,-1927.633;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-3235.739,-2034.65;Inherit;False;47;WingMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;63;-3082.918,-2291.799;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-3217.634,-1553.976;Inherit;False;Constant;_Float4;Float 4;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;100;-3454.592,-700.7108;Inherit;False;Property;_Cloud_Pow_Scale;Cloud_Pow_Scale;4;0;Create;True;0;0;0;False;0;False;0,0;2,8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-759.3899,-1000.425;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2846.495,-2066.184;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;104;-3480.373,-922.9646;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-3296.611,-1685.613;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-3090.314,-673.6834;Inherit;False;94;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;80;-3121.549,-927.0414;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;73;-3019.65,-1674.983;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;97;-3112.996,-558.6429;Inherit;False;47;WingMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;31;-2601.785,-2033.274;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2695.653,-824.5682;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-2461.78,-2018.553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;132;-1207.396,-708.2714;Inherit;False;878.3113;470.9376;Color;7;95;102;99;50;101;30;111;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-2432.211,-859.9462;Inherit;False;Cloud;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-2198.087,-2037.776;Inherit;False;Star;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-1143.226,-470.4156;Inherit;False;Constant;_Float12;Float 12;5;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-1149.396,-547.8828;Inherit;False;94;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;124;-4155.044,176.8234;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;99;-985.0911,-391.0481;Inherit;False;92;Cloud;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1000.347,-641.2714;Inherit;False;49;Star;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-965.2263,-523.4156;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3930.909,76.64513;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-3901.418,329.0462;Inherit;False;Constant;_Float14;Float 14;6;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-3903.961,205.7691;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;23;-3919.923,426.1915;Inherit;False;661.5658;431.6407;判断翅膀左右;5;4;17;20;21;19;判断翅膀左右;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-3737.384,78.07942;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-3733.267,194.9819;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;4;-3861.924,672.9749;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-758.6733,-570.0927;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;17;-3645.929,696.1915;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-599.5138,-563.3048;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-3538.308,89.1329;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-3704.93,564.1915;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-3703.93,476.1916;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3367.93,231.192;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1045.521,534.8849;Inherit;False;111;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;19;-3440.93,498.1915;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-1015.619,177.3136;Inherit;False;Constant;_Float13;Float 13;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;8;-3326.924,141.9755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;121;-1081.654,327.1862;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;24;-2810.032,459.2061;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;6;-2800.415,16.16777;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;9;-2800.728,267.913;Inherit;False;Property;_PivotPoint;PivotPoint;1;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.2,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3170.93,165.192;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;114;-876.5216,519.8849;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;116;-822.341,182.2841;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-791.3464,351.033;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;5;-2416.882,125.9807;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;14;-2132.882,-37.1621;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-560.5217,249.8845;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;13;-1806.881,95.83792;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;117;-417.5217,251.8846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-166.0664,130.8438;Inherit;False;111;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;113;-227.5216,369.8849;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1623.998,83.50433;Inherit;False;VertexAnim;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;171;-2507.104,1347.72;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-3098.307,1193.264;Inherit;False;Constant;_Float17;Float 17;6;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;164;-2786.629,934.0707;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;-2615.312,987.8732;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;119;60.27544,138.5755;Inherit;False;Property;_ChangeColor;ChangeColor;5;0;Create;True;0;0;0;False;0;False;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-2869.156,1078.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;97.30383,295.3411;Inherit;False;25;VertexAnim;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-3096.85,1047.987;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;182;-3331.933,1013.041;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;176;-3018.727,919.6544;Inherit;False;Constant;_Float16;Float 16;7;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-2452.959,1049.731;Inherit;False;Constant;_Float15;Float 15;7;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;167;-2433.959,968.7312;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;161;-1430.88,1111.879;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;170;-2745.104,1323.72;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;173;-2495.416,1202.148;Inherit;False;Constant;_Vector5;Vector 5;7;0;Create;True;0;0;0;False;0;False;-1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-3655.596,-1527.493;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;166;-1875.959,1241.731;Inherit;False;Property;_Vector4;Vector 4;6;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.2,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-2257.959,967.7312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-2039.416,1075.148;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;172;-2298.416,1198.148;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-2396.727,1440.654;Inherit;False;47;WingMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;165;-1745.629,1358.071;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;163;-1787.629,954.0707;Inherit;False;Constant;_Vector3;Vector 3;6;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;162;-1287.629,966.0707;Inherit;False;111;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;421.336,151.2133;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Butterfly;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;0;1;True;False;;False;0
WireConnection;35;0;34;0
WireConnection;56;0;55;0
WireConnection;56;1;57;0
WireConnection;56;2;58;0
WireConnection;41;0;29;0
WireConnection;84;0;160;0
WireConnection;154;0;72;0
WireConnection;54;0;52;0
WireConnection;54;1;56;0
WireConnection;33;0;35;0
WireConnection;33;1;41;1
WireConnection;47;0;12;1
WireConnection;37;0;33;0
WireConnection;37;1;41;0
WireConnection;51;0;54;0
WireConnection;51;1;53;0
WireConnection;86;0;106;0
WireConnection;86;1;84;0
WireConnection;86;2;82;0
WireConnection;155;0;154;0
WireConnection;105;0;110;0
WireConnection;105;1;86;0
WireConnection;152;0;155;0
WireConnection;152;1;155;1
WireConnection;152;2;155;2
WireConnection;60;0;51;0
WireConnection;60;1;61;0
WireConnection;63;0;37;0
WireConnection;63;1;41;2
WireConnection;94;0;1;0
WireConnection;39;0;63;0
WireConnection;39;1;41;3
WireConnection;39;2;48;0
WireConnection;39;3;60;0
WireConnection;104;0;105;0
WireConnection;104;1;159;0
WireConnection;75;0;152;0
WireConnection;75;1;76;0
WireConnection;80;0;104;0
WireConnection;80;1;100;1
WireConnection;73;0;75;0
WireConnection;73;1;74;0
WireConnection;73;2;74;0
WireConnection;31;0;39;0
WireConnection;98;0;80;0
WireConnection;98;1;100;2
WireConnection;98;2;96;0
WireConnection;98;3;97;0
WireConnection;77;0;31;0
WireConnection;77;1;73;0
WireConnection;92;0;98;0
WireConnection;49;0;77;0
WireConnection;101;0;95;0
WireConnection;101;1;102;0
WireConnection;125;0;124;1
WireConnection;125;1;124;2
WireConnection;125;2;124;3
WireConnection;7;0;22;0
WireConnection;126;0;125;0
WireConnection;126;1;127;0
WireConnection;30;0;50;0
WireConnection;30;1;101;0
WireConnection;30;2;99;0
WireConnection;17;1;4;1
WireConnection;111;0;30;0
WireConnection;123;0;7;0
WireConnection;123;1;126;0
WireConnection;19;0;20;0
WireConnection;19;1;21;0
WireConnection;19;2;17;0
WireConnection;8;0;123;0
WireConnection;15;0;8;0
WireConnection;15;1;16;0
WireConnection;15;2;19;0
WireConnection;114;0;112;0
WireConnection;116;0;118;0
WireConnection;122;0;121;1
WireConnection;122;1;121;2
WireConnection;122;2;121;3
WireConnection;5;0;6;0
WireConnection;5;1;15;0
WireConnection;5;2;9;0
WireConnection;5;3;24;0
WireConnection;115;0;116;0
WireConnection;115;1;114;1
WireConnection;115;2;122;0
WireConnection;13;0;14;0
WireConnection;13;1;5;0
WireConnection;13;2;12;1
WireConnection;117;0;115;0
WireConnection;113;0;117;0
WireConnection;113;1;114;2
WireConnection;113;2;114;3
WireConnection;25;0;13;0
WireConnection;171;0;170;1
WireConnection;164;0;176;0
WireConnection;178;0;164;0
WireConnection;178;1;180;0
WireConnection;119;0;120;0
WireConnection;119;1;113;0
WireConnection;180;0;181;0
WireConnection;180;1;179;0
WireConnection;181;0;182;1
WireConnection;181;1;182;2
WireConnection;181;2;182;3
WireConnection;167;0;178;0
WireConnection;161;0;163;0
WireConnection;161;1;174;0
WireConnection;161;2;166;0
WireConnection;161;3;165;0
WireConnection;156;0;72;1
WireConnection;156;1;72;2
WireConnection;156;2;72;3
WireConnection;168;0;167;0
WireConnection;168;1;169;0
WireConnection;174;0;168;0
WireConnection;174;1;172;0
WireConnection;174;2;177;0
WireConnection;172;0;173;1
WireConnection;172;1;173;2
WireConnection;172;2;171;0
WireConnection;0;0;119;0
WireConnection;0;1;190;0
ASEEND*/
//CHKSM=6F3E2017C3CC455ED102DB260CA6EAE32745F927