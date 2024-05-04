// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAProGlassGirl"
{
	Properties
	{
		_Fresnel_BSP("Fresnel_BSP", Vector) = (0,1,5,0)
		[HDR]_Fresnel("Fresnel", Color) = (1,0.8733153,0.8733153,0)
		_StarTex("StarTex", 2D) = "white" {}
		[HDR]_StarTint("StarTint", Color) = (1,1,1,0)
		[HDR]_FlowNoiseTint("FlowNoiseTint", Color) = (1,1,1,0)
		_FlowNoise("FlowNoise", 2D) = "black" {}
		_FlowNoise_P_S("FlowNoise_P_S", Vector) = (1,1,0,0)
		_FlowNoiseUVSpeed("FlowNoiseUVSpeed", Vector) = (1,0,0,0)
		_DistortNoise("DistortNoise", 2D) = "black" {}
		_DistortUVSpeed("DistortUVSpeed", Vector) = (1,0,0,0)
		_DistortIntensity("DistortIntensity", Range( 0 , 1)) = 0
		_DistortIntensity2("DistortIntensity2", Range( 0 , 1)) = 1
		_CubeMap("CubeMap", CUBE) = "black" {}
		_Min("Min", Range( 0 , 1)) = 0
		_Max("Max", Range( 0 , 1)) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalMapScale("NormalMapScale", Range( 0 , 1)) = 0
		_CubeMapIntensity("CubeMapIntensity", Range( 0 , 1)) = 0
		_CubeMapMip("CubeMapMip", Range( 0 , 11)) = 0
		_FlowStar_UVScale_Pow_Intensity("FlowStar_UVScale_Pow_Intensity", Vector) = (10,1,1,0)
		_FlowStarDepth("FlowStarDepth", Range( 0 , 2)) = 0.1
		[HDR]_FlowStarColor("FlowStarColor", Color) = (0,0,0,0)
		_StarBlinkSpeed("StarBlinkSpeed", Range( 0 , 5)) = 1
		_ModelHeight("ModelHeight", Float) = 0
		[HDR]_HeightColor0("HeightColor 0", Color) = (1,1,1,0)
		[HDR]_HeightColor1("HeightColor 1", Color) = (0,0,0,0)
		_CubeMap2("CubeMap2", CUBE) = "black" {}
		_CubeMapIntensity2("CubeMapIntensity2", Range( 0 , 1)) = 0
		_CubeMapMip2("CubeMapMip2", Range( 0 , 11)) = 0
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

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _NormalMapScale;
			uniform float3 _Fresnel_BSP;
			uniform float4 _Fresnel;
			uniform sampler2D _StarTex;
			uniform sampler2D _DistortNoise;
			uniform float2 _DistortUVSpeed;
			uniform float4 _DistortNoise_ST;
			uniform float _DistortIntensity2;
			uniform float4 _StarTex_ST;
			uniform float4 _StarTint;
			uniform sampler2D _FlowNoise;
			uniform float2 _FlowNoiseUVSpeed;
			uniform float4 _FlowNoise_ST;
			uniform float _DistortIntensity;
			uniform float4 _FlowNoise_P_S;
			uniform float4 _FlowNoiseTint;
			uniform samplerCUBE _CubeMap;
			uniform float _CubeMapMip;
			uniform float _CubeMapIntensity;
			uniform float _Min;
			uniform float _Max;
			uniform float _ModelHeight;
			uniform float _FlowStarDepth;
			uniform float4 _FlowStar_UVScale_Pow_Intensity;
			uniform float4 _FlowStarColor;
			uniform float _StarBlinkSpeed;
			uniform float4 _HeightColor0;
			uniform float4 _HeightColor1;
			uniform samplerCUBE _CubeMap2;
			uniform float _CubeMapMip2;
			uniform float _CubeMapIntensity2;
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
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_texcoord6 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 uv_NormalMap = i.ase_texcoord1.xyz.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal65 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalMapScale );
				float3 worldNormal65 = normalize( float3(dot(tanToWorld0,tanNormal65), dot(tanToWorld1,tanNormal65), dot(tanToWorld2,tanNormal65)) );
				float fresnelNdotV7 = dot( normalize( worldNormal65 ), ase_worldViewDir );
				float fresnelNode7 = ( _Fresnel_BSP.x + _Fresnel_BSP.y * pow( max( 1.0 - fresnelNdotV7 , 0.0001 ), _Fresnel_BSP.z ) );
				float4 Fresnel11 = ( saturate( fresnelNode7 ) * _Fresnel );
				float4 screenPos = i.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 uv_DistortNoise = i.ase_texcoord1.xyz.xy * _DistortNoise_ST.xy + _DistortNoise_ST.zw;
				float2 panner35 = ( 1.0 * _Time.y * _DistortUVSpeed + uv_DistortNoise);
				float4 tex2DNode36 = tex2D( _DistortNoise, panner35 );
				float DistortStar49 = ( (-1.0 + (tex2DNode36.r - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * _DistortIntensity2 );
				float4 Star17 = ( tex2D( _StarTex, (( ase_screenPosNorm + DistortStar49 )*float4( (_StarTex_ST).xy, 0.0 , 0.0 ) + float4( (_StarTex_ST).zw, 0.0 , 0.0 )).xy ) * _StarTint );
				float2 uv_FlowNoise = i.ase_texcoord1.xyz.xy * _FlowNoise_ST.xy + _FlowNoise_ST.zw;
				float2 panner23 = ( 1.0 * _Time.y * _FlowNoiseUVSpeed + uv_FlowNoise);
				float4 temp_cast_5 = (_FlowNoise_P_S.x).xxxx;
				float4 FlowNoise26 = ( ( pow( tex2D( _FlowNoise, ( float4( panner23, 0.0 , 0.0 ) + ( tex2DNode36 * _DistortIntensity ) ).rg ) , temp_cast_5 ) * _FlowNoise_P_S.y ) * _FlowNoiseTint );
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float Height01119 = saturate( ( i.ase_texcoord6.xyz.y / _ModelHeight ) );
				float smoothstepResult115 = smoothstep( _Min , _Max , Height01119);
				float4 Reflection59 = ( ( texCUBElod( _CubeMap, float4( reflect( -ase_worldViewDir , normalizedWorldNormal ), _CubeMapMip) ) * _CubeMapIntensity ) * smoothstepResult115 );
				float simplePerlin3D76 = snoise( ( ( -ase_worldViewDir * _FlowStarDepth ) + WorldPosition + ( float3(0,-0.1,0) * _Time.y ) )*_FlowStar_UVScale_Pow_Intensity.x );
				simplePerlin3D76 = simplePerlin3D76*0.5 + 0.5;
				float mulTime98 = _Time.y * _StarBlinkSpeed;
				float simplePerlin3D95 = snoise( ( WorldPosition + ( float3(0,-2,0) * mulTime98 ) )*0.5 );
				simplePerlin3D95 = simplePerlin3D95*0.5 + 0.5;
				float3 hsvTorgb142 = HSVToRGB( float3(WorldPosition.y,0.5,1.0) );
				float4 FlowStarColor91 = ( ( pow( simplePerlin3D76 , _FlowStar_UVScale_Pow_Intensity.y ) * _FlowStar_UVScale_Pow_Intensity.z ) * _FlowStarColor * Star17 * pow( simplePerlin3D95 , 5.0 ) * float4( hsvTorgb142 , 0.0 ) );
				float4 lerpResult125 = lerp( _HeightColor0 , _HeightColor1 , Height01119);
				float4 HeightColor126 = lerpResult125;
				float4 CubeMap2139 = ( texCUBElod( _CubeMap2, float4( reflect( -ase_worldViewDir , normalizedWorldNormal ), _CubeMapMip2) ) * 1.0 * _CubeMapIntensity2 );
				
				
				finalColor = ( Fresnel11 + Star17 + FlowNoise26 + Reflection59 + FlowStarColor91 + HeightColor126 + CubeMap2139 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
404;256.5714;2148.572;1181.286;790.1331;-1272.401;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;53;-3179.745,875.2916;Inherit;False;2587.101;900.1285;FlowNoise;21;34;33;35;36;47;24;22;39;46;23;38;49;37;25;32;30;31;29;28;26;129;FlowNoise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;33;-3056.745,1473.26;Inherit;False;Property;_DistortUVSpeed;DistortUVSpeed;9;0;Create;True;0;0;0;False;0;False;1,0;0,-0.015;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-3102.745,1324.26;Inherit;False;0;36;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;35;-2807.745,1330.26;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;36;-2588.745,1302.26;Inherit;True;Property;_DistortNoise;DistortNoise;8;0;Create;True;0;0;0;False;0;False;-1;None;cf84868fc13684f4eb3e293b0e5ad72e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-2259.05,1587.434;Inherit;False;Property;_DistortIntensity2;DistortIntensity2;11;0;Create;True;0;0;0;False;0;False;1;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;129;-2183.04,1391.36;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1945.866,1407.707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-1637.497,1396.764;Inherit;False;DistortStar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;103;-2980.516,2535.205;Inherit;False;2373;1131.78;FlowStarColor;32;91;88;90;86;93;101;95;85;102;76;97;100;94;83;87;99;80;96;82;98;108;104;107;106;81;78;77;143;142;141;144;153;FlowStarColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2134.632,307.1417;Inherit;False;1542.356;531.881;Star;11;50;40;15;43;45;48;44;20;16;18;17;Star;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;40;-2076.632,550.0027;Inherit;False;Global;_StarTex_ST;_StarTex_ST;12;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;77;-2725.416,2655.205;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenPosInputsNode;15;-2070.704,365.1417;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;50;-2107.446,742.3083;Inherit;False;49;DistortStar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-4480.127,1424.611;Inherit;False;994.6542;915.7151;模型的高度;10;126;125;124;122;123;119;113;112;109;111;模型的高度;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1791.155,385.5948;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;107;-2754.13,3188.894;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;78;-2471.415,2671.205;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;45;-1824.632,650.0027;Inherit;False;False;False;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;106;-2738.13,3012.894;Inherit;False;Constant;_Vector1;Vector 1;20;0;Create;True;0;0;0;False;0;False;0,-0.1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;104;-2734.329,3500.592;Inherit;False;Property;_StarBlinkSpeed;StarBlinkSpeed;22;0;Create;True;0;0;0;False;0;False;1;1.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-2556.869,2773.152;Inherit;False;Property;_FlowStarDepth;FlowStarDepth;20;0;Create;True;0;0;0;False;0;False;0.1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-4258.127,1636.933;Inherit;False;Property;_ModelHeight;ModelHeight;23;0;Create;True;0;0;0;False;0;False;0;14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;109;-4304.127,1477.933;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;24;-2697.072,1070.292;Inherit;False;Property;_FlowNoiseUVSpeed;FlowNoiseUVSpeed;7;0;Create;True;0;0;0;False;0;False;1,0;0,-0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;75;-3438.928,1845.515;Inherit;False;2836.505;679.7701;Reflection;20;69;63;61;62;64;70;54;74;71;73;58;57;55;56;115;118;59;120;116;117;Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2608.596,-174.6957;Inherit;False;2015.359;434.3724;Fresnel;10;67;11;9;10;14;7;65;8;66;72;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;43;-1827.632,530.0027;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-2770.072,925.2916;Inherit;False;0;25;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-2566.495,1503.51;Inherit;False;Property;_DistortIntensity;DistortIntensity;10;0;Create;True;0;0;0;False;0;False;0;0.287;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2542.972,-84.93659;Inherit;False;Property;_NormalMapScale;NormalMapScale;16;0;Create;True;0;0;0;False;0;False;0;0.226;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;23;-2448.072,927.2916;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2259.495,1263.51;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;82;-2549.676,2883.887;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;96;-2428.338,3343.844;Inherit;False;Constant;_Vector0;Vector 0;20;0;Create;True;0;0;0;False;0;False;0,-2,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;98;-2450.47,3519.844;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;44;-1568.632,414.0028;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;1,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-2562.13,3044.894;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2259.866,2694.152;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;145;-2264.738,3694.68;Inherit;False;1658.078;603.9644;CubeMap2 模拟高光点;10;130;131;132;133;134;135;138;137;136;139;CubeMap2 模拟高光点;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;112;-4032.125,1509.933;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;56;-3021.264,1889.926;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;20;-1261.704,549.1415;Inherit;False;Property;_StarTint;StarTint;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.9622642,0.6951126,0.6951126,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;94;-2412.331,3171.56;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;87;-2183.866,2910.152;Inherit;False;Property;_FlowStar_UVScale_Pow_Intensity;FlowStar_UVScale_Pow_Intensity;19;0;Create;True;0;0;0;False;0;False;10,1,1,0;5,50,7500,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;57;-2843.261,1909.858;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-2252.338,3375.844;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;55;-2879.154,2025.868;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;16;-1307.704,358.1417;Inherit;True;Property;_StarTex;StarTex;2;0;Create;True;0;0;0;False;0;False;-1;None;ec72cc085decafc4eab253a26f9a3b2d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-2120.495,944.5107;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;66;-2246.749,-126.6304;Inherit;True;Property;_NormalMap;NormalMap;15;0;Create;True;0;0;0;False;0;False;-1;None;587380661d367ba45b40878cba18c099;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-2050.865,2720.152;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;130;-2214.738,3771.93;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;113;-3892.125,1502.933;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-1982.072,914.2916;Inherit;True;Property;_FlowNoise;FlowNoise;5;0;Create;True;0;0;0;False;0;False;-1;None;d84f1ab42f297414faf42ee8f3032a9b;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;8;-1706.143,-84.00269;Inherit;False;Property;_Fresnel_BSP;Fresnel_BSP;0;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,4;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;132;-2012.738,3776.93;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;131;-2058.738,3856.93;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;65;-1935.749,-115.6304;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;32;-1788.298,1104.859;Inherit;False;Property;_FlowNoise_P_S;FlowNoise_P_S;6;0;Create;True;0;0;0;False;0;False;1,1,0,0;5,2,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-966.704,361.1418;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-3710.125,1489.933;Inherit;False;Height01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-2140.34,3199.844;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2074.334,3369.56;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2836.974,2316.993;Inherit;False;Property;_CubeMapMip;CubeMapMip;18;0;Create;True;0;0;0;False;0;False;0;1.2;0;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;58;-2591.154,1945.868;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;76;-1833.863,2705.152;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-815.704,357.1418;Inherit;False;Star;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;54;-2257.12,1910.978;Inherit;True;Property;_CubeMap;CubeMap;12;0;Create;True;0;0;0;False;0;False;-1;None;db5d9ec0a45e4c048aa0d548acd257d2;True;0;False;black;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;117;-1714.826,2271.222;Inherit;False;Property;_Max;Max;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1706.826,2202.221;Inherit;False;Property;_Min;Min;13;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-1797.916,3430.963;Inherit;False;Constant;_Float2;Float 2;20;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1324.761,3560.933;Inherit;False;Constant;_Float4;Float 4;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;141;-1350.024,3345.821;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;85;-1562.863,2706.152;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-1335.185,3483.592;Inherit;False;Constant;_Float5;Float 5;29;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;133;-1770.738,3776.93;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1969.138,4063.286;Inherit;False;Property;_CubeMapMip2;CubeMapMip2;28;0;Create;True;0;0;0;False;0;False;0;5.58;0;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-1697.412,2114.3;Inherit;False;119;Height01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;95;-1909.333,3187.56;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;-1568.298,946.8596;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2048,2352;Inherit;False;Property;_CubeMapIntensity;CubeMapIntensity;17;0;Create;True;0;0;0;False;0;False;0;0.365;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;7;-1521.143,-110.0027;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;142;-1158.833,3414.927;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;90;-1475.863,2839.152;Inherit;False;Property;_FlowStarColor;FlowStarColor;21;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1450.237,3027.724;Inherit;False;17;Star;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;122;-4304.111,1821.632;Inherit;False;Property;_HeightColor0;HeightColor 0;24;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1381.863,2722.152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1760,1952;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;115;-1394.69,2170.01;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-1321.738,3962.93;Inherit;False;Constant;_Float3;Float 3;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-4279.111,2201.632;Inherit;False;119;Height01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;101;-1569.505,3217.434;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;-1257.479,-97.2939;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-1412.298,1158.859;Inherit;False;Property;_FlowNoiseTint;FlowNoiseTint;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.203504,0.6158076,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;138;-1457.738,4046.93;Inherit;False;Property;_CubeMapIntensity2;CubeMapIntensity2;27;0;Create;True;0;0;0;False;0;False;0;0.01;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-1277.143,9.997228;Inherit;False;Property;_Fresnel;Fresnel;1;1;[HDR];Create;True;0;0;0;False;0;False;1,0.8733153,0.8733153,0;0.775957,1.28386,2.690468,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;135;-1485.738,3750.93;Inherit;True;Property;_CubeMap2;CubeMap2;26;0;Create;True;0;0;0;False;0;False;-1;None;ed154dc496d7ee047a6f800e00642933;True;0;False;black;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1355.298,946.8596;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;123;-4301.111,2010.632;Inherit;False;Property;_HeightColor1;HeightColor 1;25;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0.0654169,0.06603771,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-952.8121,2853.044;Inherit;False;5;5;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1038.738,3750.93;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;125;-3936.111,1977.632;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1182.69,1961.01;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-997.298,998.8595;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-990.143,-95.0027;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-802.1302,2848.447;Inherit;False;FlowStarColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-816.0534,1975.142;Inherit;False;Reflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-854.089,3756.68;Inherit;False;CubeMap2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-816.0719,985.2916;Inherit;False;FlowNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-816.6651,-124.6957;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-3732.111,1989.632;Inherit;False;HeightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-78.3558,1360.328;Inherit;False;11;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-65.67289,1771.95;Inherit;False;91;FlowStarColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-63.50179,1864.736;Inherit;False;126;HeightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-69.3558,1461.328;Inherit;False;17;Star;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-49.51839,1667.773;Inherit;False;59;Reflection;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-63.33849,1563.514;Inherit;False;26;FlowNoise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-68.63679,1954.744;Inherit;False;139;CubeMap2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2032,2144;Inherit;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;69;-2051.144,2249.313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1718.749,108.3695;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;424.2643,1568.569;Inherit;False;7;7;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;63;-2221.454,2232.757;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-1438.622,3092.132;Inherit;False;Constant;_Float6;Float 6;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;62;-2455.454,2336.757;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;61;-2423.454,2184.757;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;64;-2898.453,2223.757;Inherit;False;67;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;607.8362,1548.836;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAProGlassGirl;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;35;0;34;0
WireConnection;35;2;33;0
WireConnection;36;1;35;0
WireConnection;129;0;36;1
WireConnection;46;0;129;0
WireConnection;46;1;47;0
WireConnection;49;0;46;0
WireConnection;48;0;15;0
WireConnection;48;1;50;0
WireConnection;78;0;77;0
WireConnection;45;0;40;0
WireConnection;43;0;40;0
WireConnection;23;0;22;0
WireConnection;23;2;24;0
WireConnection;38;0;36;0
WireConnection;38;1;39;0
WireConnection;98;0;104;0
WireConnection;44;0;48;0
WireConnection;44;1;43;0
WireConnection;44;2;45;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;80;0;78;0
WireConnection;80;1;81;0
WireConnection;112;0;109;2
WireConnection;112;1;111;0
WireConnection;57;0;56;0
WireConnection;99;0;96;0
WireConnection;99;1;98;0
WireConnection;16;1;44;0
WireConnection;37;0;23;0
WireConnection;37;1;38;0
WireConnection;66;5;72;0
WireConnection;83;0;80;0
WireConnection;83;1;82;0
WireConnection;83;2;108;0
WireConnection;113;0;112;0
WireConnection;25;1;37;0
WireConnection;132;0;130;0
WireConnection;65;0;66;0
WireConnection;18;0;16;0
WireConnection;18;1;20;0
WireConnection;119;0;113;0
WireConnection;97;0;94;0
WireConnection;97;1;99;0
WireConnection;58;0;57;0
WireConnection;58;1;55;0
WireConnection;76;0;83;0
WireConnection;76;1;87;1
WireConnection;17;0;18;0
WireConnection;54;1;58;0
WireConnection;54;2;73;0
WireConnection;85;0;76;0
WireConnection;85;1;87;2
WireConnection;133;0;132;0
WireConnection;133;1;131;0
WireConnection;95;0;97;0
WireConnection;95;1;100;0
WireConnection;30;0;25;0
WireConnection;30;1;32;1
WireConnection;7;0;65;0
WireConnection;7;1;8;1
WireConnection;7;2;8;2
WireConnection;7;3;8;3
WireConnection;142;0;141;2
WireConnection;142;1;144;0
WireConnection;142;2;143;0
WireConnection;86;0;85;0
WireConnection;86;1;87;3
WireConnection;70;0;54;0
WireConnection;70;1;71;0
WireConnection;115;0;120;0
WireConnection;115;1;116;0
WireConnection;115;2;117;0
WireConnection;101;0;95;0
WireConnection;101;1;102;0
WireConnection;14;0;7;0
WireConnection;135;1;133;0
WireConnection;135;2;134;0
WireConnection;31;0;30;0
WireConnection;31;1;32;2
WireConnection;88;0;86;0
WireConnection;88;1;90;0
WireConnection;88;2;93;0
WireConnection;88;3;101;0
WireConnection;88;4;142;0
WireConnection;136;0;135;0
WireConnection;136;1;137;0
WireConnection;136;2;138;0
WireConnection;125;0;122;0
WireConnection;125;1;123;0
WireConnection;125;2;124;0
WireConnection;118;0;70;0
WireConnection;118;1;115;0
WireConnection;28;0;31;0
WireConnection;28;1;29;0
WireConnection;9;0;14;0
WireConnection;9;1;10;0
WireConnection;91;0;88;0
WireConnection;59;0;118;0
WireConnection;139;0;136;0
WireConnection;26;0;28;0
WireConnection;11;0;9;0
WireConnection;126;0;125;0
WireConnection;69;0;63;0
WireConnection;67;0;65;0
WireConnection;21;0;12;0
WireConnection;21;1;13;0
WireConnection;21;2;27;0
WireConnection;21;3;60;0
WireConnection;21;4;92;0
WireConnection;21;5;127;0
WireConnection;21;6;140;0
WireConnection;63;0;61;0
WireConnection;63;1;62;0
WireConnection;0;0;21;0
ASEEND*/
//CHKSM=11646018E3C279F0AA44B34956611B4CEB407F76