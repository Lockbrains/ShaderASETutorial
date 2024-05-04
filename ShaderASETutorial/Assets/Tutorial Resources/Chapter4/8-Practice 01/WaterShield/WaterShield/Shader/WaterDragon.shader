// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/WaterDragon"
{
	Properties
	{
		_UVScale("UVScale", Vector) = (0,0,0,0)
		_Color0("Color 0", Color) = (0,0,0,0)
		_Color1("Color 1", Color) = (0,0,0,0)
		_Noise3DPowScale("Noise3DPowScale", Vector) = (0,0,0,0)
		_Noise3DSpeed("Noise3DSpeed", Float) = 0.2
		_Noise3DUVScale("Noise3DUVScale", Vector) = (0,0,0,0)
		[HDR]_Noise3DColor("Noise3DColor", Color) = (0,1,0.9034529,0)
		_DistanceFade("DistanceFade", Float) = 0
		_Fresnel_BSP("Fresnel_BSP", Vector) = (0,0,0,0)
		_DistanceColor("DistanceColor", Color) = (0,0,0,0)
		_DistanceOffset("DistanceOffset", Vector) = (0,0,0,0)
		[HDR]_FresnelColor("FresnelColor", Color) = (1,1,1,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Mask("Mask", 2D) = "black" {}
		[HDR]_EyeColor("EyeColor", Color) = (1,1,1,0)
		_ViewLight("ViewLight", Color) = (0,0,0,0)
		_CubeMap("CubeMap", CUBE) = "white" {}
		_CubeMap2("CubeMap2", CUBE) = "white" {}
		_ReflectionIntensity2("ReflectionIntensity2", Range( 0 , 1)) = 0
		_ReflectionIntensity("ReflectionIntensity", Range( 0 , 1)) = 0
		_CubeMaprotSpeed("CubeMaprotSpeed", Float) = 0.1
		_NormalMapScale("NormalMapScale", Range( 0 , 1)) = 0
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
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color0;
			uniform float4 _Color1;
			uniform float2 _UVScale;
			uniform float3 _DistanceOffset;
			uniform float _DistanceFade;
			uniform float4 _DistanceColor;
			uniform float3 _Noise3DUVScale;
			uniform float _Noise3DSpeed;
			uniform float2 _Noise3DPowScale;
			uniform float4 _Noise3DColor;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _NormalMapScale;
			uniform float3 _Fresnel_BSP;
			uniform float4 _FresnelColor;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			uniform float4 _EyeColor;
			uniform float4 _ViewLight;
			uniform samplerCUBE _CubeMap;
			uniform float _CubeMaprotSpeed;
			uniform float _ReflectionIntensity;
			uniform samplerCUBE _CubeMap2;
			uniform float _ReflectionIntensity2;
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
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
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
				float2 texCoord69 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float simpleNoise67 = SimpleNoise( ( texCoord69 * _UVScale ) );
				float4 lerpResult73 = lerp( _Color0 , _Color1 , simpleNoise67);
				float4 BaseColor108 = lerpResult73;
				float3 temp_output_113_0 = ( i.ase_texcoord2.xyz - _DistanceOffset );
				float4 DistanceColor104 = ( exp( ( length( temp_output_113_0 ) * _DistanceFade ) ) * _DistanceColor );
				float mulTime85 = _Time.y * _Noise3DSpeed;
				float simplePerlin3D82 = snoise( ( ( WorldPosition * _Noise3DUVScale ) + ( mulTime85 * float3(0,-1,0) ) ) );
				simplePerlin3D82 = simplePerlin3D82*0.5 + 0.5;
				float4 Noise3DColor105 = ( ( pow( simplePerlin3D82 , _Noise3DPowScale.x ) * _Noise3DPowScale.y ) * _Noise3DColor );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 uv_NormalMap = i.ase_texcoord1.xyz.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldNormal = i.ase_texcoord4.xyz;
				float3 ase_worldBitangent = i.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal125 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalMapScale );
				float3 worldNormal125 = normalize( float3(dot(tanToWorld0,tanNormal125), dot(tanToWorld1,tanNormal125), dot(tanToWorld2,tanNormal125)) );
				float fresnelNdotV116 = dot( normalize( worldNormal125 ), ase_worldViewDir );
				float fresnelNode116 = ( _Fresnel_BSP.x + _Fresnel_BSP.y * pow( max( 1.0 - fresnelNdotV116 , 0.0001 ), _Fresnel_BSP.z ) );
				float4 Fresnel120 = ( saturate( fresnelNode116 ) * _FresnelColor );
				float2 uv_Mask = i.ase_texcoord1.xyz.xy * _Mask_ST.xy + _Mask_ST.zw;
				float3 DisVec122 = temp_output_113_0;
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 worldToObjDir131 = normalize( mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz );
				float dotResult132 = dot( DisVec122 , worldToObjDir131 );
				float4 ViewLight136 = ( saturate( dotResult132 ) * _ViewLight );
				float mulTime156 = _Time.y * _CubeMaprotSpeed;
				float3 rotatedValue154 = RotateAroundAxis( float3( 0,0,0 ), ase_worldViewDir, float3(0,1,0), mulTime156 );
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 temp_output_144_0 = reflect( -rotatedValue154 , normalizedWorldNormal );
				float4 Reflection145 = ( texCUBE( _CubeMap, temp_output_144_0 ) * _ReflectionIntensity );
				float4 Reflection2152 = ( texCUBE( _CubeMap2, temp_output_144_0 ) * _ReflectionIntensity2 );
				
				
				finalColor = ( BaseColor108 + DistanceColor104 + Noise3DColor105 + Fresnel120 + ( tex2D( _Mask, uv_Mask ) * _EyeColor ) + ViewLight136 + Reflection145 + Reflection2152 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;24;2194.286;1149.286;3616.373;-900.1924;1.907177;True;False
Node;AmplifyShaderEditor.CommentaryNode;111;-1447.388,-136.2095;Inherit;False;1799.566;675.8571;Noise3DColor;15;88;94;87;85;83;92;86;84;82;91;90;95;96;89;105;Noise3DColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;112;-1350.335,640.4554;Inherit;False;1697.429;429.5712;DistanceColor;11;97;104;102;100;103;99;101;98;113;114;122;DistanceColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;158;-1812.686,2203.107;Inherit;False;2134.637;785.1904;Reflection;16;157;156;142;155;154;143;141;144;140;149;147;150;151;146;152;145;Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1397.388,264.7901;Inherit;False;Property;_Noise3DSpeed;Noise3DSpeed;4;0;Create;True;0;0;0;False;0;False;0.2;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;97;-1281.335,675.4554;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;114;-1264.181,846.3306;Inherit;False;Property;_DistanceOffset;DistanceOffset;10;0;Create;True;0;0;0;False;0;False;0,0,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;85;-1203.388,267.7901;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;87;-1191.388,356.79;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;94;-1359.388,59.79041;Inherit;False;Property;_Noise3DUVScale;Noise3DUVScale;5;0;Create;True;0;0;0;False;0;False;0,0,0;5,0.01,20;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;126;-1814.824,1145.178;Inherit;False;2154.767;531.0532;Fresnel;9;120;119;117;118;116;125;115;124;165;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;83;-1356.388,-83.20953;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;157;-1790.686,2492.895;Inherit;False;Property;_CubeMaprotSpeed;CubeMaprotSpeed;20;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-982.1807,734.3306;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;142;-1560.41,2656.017;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;155;-1544.686,2326.895;Inherit;False;Constant;_Vector1;Vector 1;20;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;139;-1226.495,1697.469;Inherit;False;1565.429;456.0126;ViewLight;8;130;131;123;132;133;135;134;136;ViewLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;156;-1564.686,2513.895;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-1732.93,1298.166;Inherit;False;Property;_NormalMapScale;NormalMapScale;21;0;Create;True;0;0;0;False;0;False;0;0.782;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1020.388,276.7901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1120.388,-45.2095;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-779.6855,933.3511;Inherit;False;DisVec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-839.3892,-9.209534;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;110;-1014.072,-943.7405;Inherit;False;1360.332;746.8826;BaseColor;8;69;72;71;67;74;75;73;108;BaseColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;130;-1108.495,1863.91;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;154;-1327.686,2406.895;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;124;-1344.824,1196.178;Inherit;True;Property;_NormalMap;NormalMap;12;0;Create;True;0;0;0;False;0;False;-1;a236ea5775b7148489342319d82e145b;a236ea5775b7148489342319d82e145b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;141;-994.5023,2495.629;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;123;-1110.369,1744.469;Inherit;False;122;DisVec;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;72;-890.0723,-357.0007;Inherit;False;Property;_UVScale;UVScale;0;0;Create;True;0;0;0;False;0;False;0,0;22.4,32.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-925.0723,-495.0008;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;98;-696.3354,710.4554;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;82;-687.4047,0.2153931;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;125;-1006.218,1212.512;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;101;-701.3354,831.455;Inherit;False;Property;_DistanceFade;DistanceFade;7;0;Create;True;0;0;0;False;0;False;0;-2.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;143;-968.7213,2364.649;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;115;-858.5283,1347.686;Inherit;False;Property;_Fresnel_BSP;Fresnel_BSP;8;0;Create;True;0;0;0;False;0;False;0,0,0;0,1,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;91;-609.3897,237.7902;Inherit;False;Property;_Noise3DPowScale;Noise3DPowScale;3;0;Create;True;0;0;0;False;0;False;0,0;10,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TransformDirectionNode;131;-921.493,1864.91;Inherit;False;World;Object;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;116;-634.1464,1254.65;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;144;-747.0588,2360.212;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;132;-666.4931,1805.91;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;89;-397.3897,19.79041;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-661.0724,-443.0007;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-497.3356,712.4554;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;150;-525.1395,2619.248;Inherit;True;Property;_CubeMap2;CubeMap2;17;0;Create;True;0;0;0;False;0;False;-1;None;8a0fa569f2ff04d43bc7199c8660020c;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;103;-363.3355,833.455;Inherit;False;Property;_DistanceColor;DistanceColor;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,1,0.2270269,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;117;-360.7059,1257.639;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-408.3076,2456.442;Inherit;False;Property;_ReflectionIntensity;ReflectionIntensity;19;0;Create;True;0;0;0;False;0;False;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;118;-384.2611,1440.66;Inherit;False;Property;_FresnelColor;FresnelColor;11;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0.8623601,1.128156,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;140;-537.6345,2255.107;Inherit;True;Property;_CubeMap;CubeMap;16;0;Create;True;0;0;0;False;0;False;-1;None;92fc13719fa562e47b315e5d924097a6;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;75;-482.5024,-640.8167;Inherit;False;Property;_Color1;Color 1;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2745093,0.4737422,0.8392157,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;74;-464.5024,-847.8167;Inherit;False;Property;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.2544517,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;133;-486.4931,1784.91;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;100;-307.3356,719.4554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-228.3898,28.79041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;96;-295.3897,184.7903;Inherit;False;Property;_Noise3DColor;Noise3DColor;6;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.9034529,0;0,2.640778,5.041486,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;67;-492.7024,-459.8171;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-522.8124,2873.583;Inherit;False;Property;_ReflectionIntensity2;ReflectionIntensity2;18;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;135;-387.4932,1878.91;Inherit;False;Property;_ViewLight;ViewLight;15;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.7529412,6.133435E-08,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-78.38965,33.79041;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-96.02462,2323.652;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-137.5296,2742.793;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-120.7145,1266.639;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;73;-83.50237,-509.7405;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-117.3354,718.4554;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-105.4935,1779.91;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;129;729.6869,840.1948;Inherit;False;Property;_EyeColor;EyeColor;14;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;23.96863,4.643137,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;95.5228,2309.901;Inherit;False;Reflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;57.01787,2723.042;Inherit;False;Reflection2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;116.5139,1280.493;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;109.4025,723.2861;Inherit;False;DistanceColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;116.8307,-514.0521;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;128.7483,74.8356;Inherit;False;Noise3DColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;127;663.8641,649.4518;Inherit;True;Property;_Mask;Mask;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;94.50661,1784.91;Inherit;False;ViewLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;1051.89,972.149;Inherit;False;152;Reflection2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;1041.178,434.6943;Inherit;False;105;Noise3DColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;1046.178,353.6943;Inherit;False;104;DistanceColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;1037.908,541.2032;Inherit;False;120;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1013.178,246.6943;Inherit;False;108;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;1057.224,869.7109;Inherit;False;145;Reflection;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;1053.687,653.1948;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;1050.414,791.5466;Inherit;False;136;ViewLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;1414.845,462.006;Inherit;False;8;8;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1615.824,526.7128;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/WaterDragon;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;85;0;88;0
WireConnection;113;0;97;0
WireConnection;113;1;114;0
WireConnection;156;0;157;0
WireConnection;86;0;85;0
WireConnection;86;1;87;0
WireConnection;92;0;83;0
WireConnection;92;1;94;0
WireConnection;122;0;113;0
WireConnection;84;0;92;0
WireConnection;84;1;86;0
WireConnection;154;0;155;0
WireConnection;154;1;156;0
WireConnection;154;3;142;0
WireConnection;124;5;165;0
WireConnection;98;0;113;0
WireConnection;82;0;84;0
WireConnection;125;0;124;0
WireConnection;143;0;154;0
WireConnection;131;0;130;0
WireConnection;116;0;125;0
WireConnection;116;1;115;1
WireConnection;116;2;115;2
WireConnection;116;3;115;3
WireConnection;144;0;143;0
WireConnection;144;1;141;0
WireConnection;132;0;123;0
WireConnection;132;1;131;0
WireConnection;89;0;82;0
WireConnection;89;1;91;1
WireConnection;71;0;69;0
WireConnection;71;1;72;0
WireConnection;99;0;98;0
WireConnection;99;1;101;0
WireConnection;150;1;144;0
WireConnection;117;0;116;0
WireConnection;140;1;144;0
WireConnection;133;0;132;0
WireConnection;100;0;99;0
WireConnection;90;0;89;0
WireConnection;90;1;91;2
WireConnection;67;0;71;0
WireConnection;95;0;90;0
WireConnection;95;1;96;0
WireConnection;146;0;140;0
WireConnection;146;1;147;0
WireConnection;151;0;150;0
WireConnection;151;1;149;0
WireConnection;119;0;117;0
WireConnection;119;1;118;0
WireConnection;73;0;74;0
WireConnection;73;1;75;0
WireConnection;73;2;67;0
WireConnection;102;0;100;0
WireConnection;102;1;103;0
WireConnection;134;0;133;0
WireConnection;134;1;135;0
WireConnection;145;0;146;0
WireConnection;152;0;151;0
WireConnection;120;0;119;0
WireConnection;104;0;102;0
WireConnection;108;0;73;0
WireConnection;105;0;95;0
WireConnection;136;0;134;0
WireConnection;128;0;127;0
WireConnection;128;1;129;0
WireConnection;76;0;109;0
WireConnection;76;1;106;0
WireConnection;76;2;107;0
WireConnection;76;3;121;0
WireConnection;76;4;128;0
WireConnection;76;5;137;0
WireConnection;76;6;148;0
WireConnection;76;7;153;0
WireConnection;0;0;76;0
ASEEND*/
//CHKSM=3C516F5716393F3D6AE5D78E4DED4C1625B7AC09