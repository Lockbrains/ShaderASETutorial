// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/OpalStone"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_bp("bp", Vector) = (1,1,0,0)
		_Vec_UVScale_Depth_Pow_Scale("Vec_UVScale_Depth_Pow_Scale", Vector) = (0,0,0,0)
		_CubeMap("CubeMap", CUBE) = "black" {}
		_CubeMap2("CubeMap2", CUBE) = "black" {}
		_F1_BSP("F1_BSP", Vector) = (0,1,5,0)
		_F2_BSP("F2_BSP", Vector) = (0,1,5,0)
		_PointLightVec("PointLightVec", Vector) = (0,0,0,2)
		_PointLightVec2("PointLightVec2", Vector) = (0,0,0,2)
		[HDR]_PointLightColor("PointLightColor", Color) = (1,0.8710451,0.3261455,0)
		[HDR]_PointLightColor2("PointLightColor2", Color) = (1,0.8710451,0.3261455,0)
		_CubeMapLevel("CubeMapLevel", Float) = 0
		_CubeMapLevel2("CubeMapLevel2", Float) = 0
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
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Vec_UVScale_Depth_Pow_Scale;
			uniform float2 _bp;
			uniform samplerCUBE _CubeMap;
			uniform float _CubeMapLevel2;
			uniform samplerCUBE _CubeMap2;
			uniform float _CubeMapLevel;
			uniform float3 _F1_BSP;
			uniform float3 _F2_BSP;
			uniform float4 _PointLightVec;
			uniform float4 _PointLightColor;
			uniform float4 _PointLightVec2;
			uniform float4 _PointLightColor2;
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
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_texcoord3 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
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
				float2 uv_MainTex = i.ase_texcoord1.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float dotResult111 = dot( normalizedWorldNormal , worldSpaceLightDir );
				float4 _Vector0 = float4(-1,1,-1,1);
				float temp_output_112_0 = (_Vector0.z + (dotResult111 - _Vector0.x) * (_Vector0.w - _Vector0.z) / (_Vector0.y - _Vector0.x));
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float4 break9_g25 = _Vec_UVScale_Depth_Pow_Scale;
				float simplePerlin3D1_g25 = snoise( ( WorldPosition + ( -ase_worldViewDir * break9_g25.y ) )*break9_g25.x );
				simplePerlin3D1_g25 = simplePerlin3D1_g25*0.5 + 0.5;
				float3 normalizeResult6_g26 = normalize( ( worldSpaceLightDir + ase_worldViewDir ) );
				float dotResult8_g26 = dot( normalizeResult6_g26 , normalizedWorldNormal );
				float3 temp_output_53_0 = reflect( -ase_worldViewDir , normalizedWorldNormal );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV56 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode56 = ( _F1_BSP.x + _F1_BSP.y * pow( max( 1.0 - fresnelNdotV56 , 0.0001 ), _F1_BSP.z ) );
				float4 lerpResult65 = lerp( texCUBElod( _CubeMap, float4( temp_output_53_0, _CubeMapLevel2) ) , texCUBElod( _CubeMap2, float4( temp_output_53_0, _CubeMapLevel) ) , saturate( fresnelNode56 ));
				float fresnelNdotV63 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode63 = ( _F2_BSP.x + _F2_BSP.y * pow( max( 1.0 - fresnelNdotV63 , 0.0001 ), _F2_BSP.z ) );
				float4 lerpResult58 = lerp( ( ( ( tex2DNode1 * temp_output_112_0 ) + ( tex2DNode1 * ( pow( simplePerlin3D1_g25 , break9_g25.z ) * break9_g25.w ) * saturate( temp_output_112_0 ) ) ) + max( ( pow( saturate( dotResult8_g26 ) , ( _bp.x * 256.0 ) ) * _bp.y ) , 0.0 ) ) , lerpResult65 , saturate( fresnelNode63 ));
				float4 BaseMap84 = tex2DNode1;
				float luminance86 = Luminance(BaseMap84.rgb);
				float4 PointLight82 = ( exp( ( distance( i.ase_texcoord3.xyz , (_PointLightVec).xyz ) * -_PointLightVec.w ) ) * _PointLightColor * luminance86 );
				float luminance98 = Luminance(BaseMap84.rgb);
				float4 PointLight296 = ( exp( ( distance( i.ase_texcoord3.xyz , (_PointLightVec2).xyz ) * -_PointLightVec2.w ) ) * _PointLightColor2 * luminance98 );
				
				
				finalColor = ( ( lerpResult58 + PointLight82 + PointLight296 ) + BaseMap84.b );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
309.1429;544;2194.286;1167.572;1240.742;-286.483;1.17334;True;False
Node;AmplifyShaderEditor.CommentaryNode;101;-153.6735,2188.971;Inherit;False;1575.599;712.1284;PointLight2;12;87;92;88;90;89;97;93;94;98;95;91;96;PointLight2;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;100;-96.60276,1417.068;Inherit;False;1494.599;703.4601;PointLight;12;67;76;70;69;79;78;72;86;73;81;85;82;PointLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;87;-103.6734,2443.411;Inherit;False;Property;_PointLightVec2;PointLightVec2;8;0;Create;True;0;0;0;False;0;False;0,0,0,2;0,0,0,1.17;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;67;-46.60278,1671.508;Inherit;False;Property;_PointLightVec;PointLightVec;7;0;Create;True;0;0;0;False;0;False;0,0,0,2;0,0,5,1.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;109;-766.2207,-917.0944;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;110;-772.2207,-759.0944;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;117;-165.1029,1502.395;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;111;-521.2207,-886.0944;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-953.7136,-346.9571;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;044b6515cac3fe44f81b161268f20acb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;114;-502.2207,-754.0944;Inherit;False;Constant;_Vector0;Vector 0;11;0;Create;True;0;0;0;False;0;False;-1,1,-1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;92;157.3265,2452.411;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;70;214.3971,1680.508;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;118;-210.8013,2246.835;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;52;-596.3323,473.6155;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-584.9929,-382.8585;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;90;315.3264,2249.411;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;69;372.3971,1477.508;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;89;204.5694,2566.971;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;79;261.6401,1795.068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;36;-1028.299,29.25449;Inherit;False;Property;_Vec_UVScale_Depth_Pow_Scale;Vec_UVScale_Depth_Pow_Scale;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;20,0.1,48.9,200;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;112;-260.2207,-820.0944;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;35;-692.2986,35.25449;Inherit;False;RayNoise3D;-1;;25;738cbb90907399f4f9a0b01cc558f607;0;1;8;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;32;-514.347,187.2256;Inherit;False;Property;_bp;bp;1;0;Create;True;0;0;0;False;0;False;1,1;32.28,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;34;-513.3472,315.2256;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;0;False;0;False;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;60;-216.6365,720.2049;Inherit;False;Property;_F1_BSP;F1_BSP;5;0;Create;True;0;0;0;False;0;False;0,1,5;0,2.13,2.36;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;484.5692,2396.971;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;423.6306,2786.385;Inherit;False;84;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;116;-249.0683,-145.5171;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;51;-507.3323,679.6155;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;54;-392.3323,489.6155;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;409.9035,2005.814;Inherit;False;84;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;541.6401,1625.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;56;11.36346,668.2049;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LuminanceNode;98;603.6306,2788.385;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-302.3476,218.2256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-300.8961,972.887;Inherit;False;Property;_CubeMapLevel;CubeMapLevel;11;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-130.1526,175.9865;Inherit;False;299.4286;182.4286;闪烁点;1;31;闪烁点;1,1,1,1;0;0
Node;AmplifyShaderEditor.LuminanceNode;86;624.7014,2009.483;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;72;452.4919,1830.543;Inherit;False;Property;_PointLightColor;PointLightColor;9;1;[HDR];Create;True;0;0;0;False;0;False;1,0.8710451,0.3261455,0;766.9961,405.5843,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ExpOpNode;73;702.1932,1559.044;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;53;-237.3323,493.6155;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;62;-227.5155,1119.012;Inherit;False;Property;_F2_BSP;F2_BSP;6;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,2.09;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-75.38617,-396.2209;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-40.95239,-10.6571;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-272.7358,396.777;Inherit;False;Property;_CubeMapLevel2;CubeMapLevel2;12;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;95;645.1224,2330.947;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;94;395.4213,2602.446;Inherit;False;Property;_PointLightColor2;PointLightColor2;10;1;[HDR];Create;True;0;0;0;False;0;False;1,0.8710451,0.3261455,0;1.005989,3.20166,23.3264,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;20.25944,900.4105;Inherit;True;Property;_CubeMap2;CubeMap2;4;0;Create;True;0;0;0;False;0;False;-1;None;87a24d06dddee9f42a59b0451d8dd207;True;0;False;black;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;860.4968,2363.068;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;103;502.3635,851.1041;Inherit;False;215.1428;159.7143;CubeMap2;1;64;CubeMap2;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;102;536.2954,517.3408;Inherit;False;232.5714;205.1428;Comment;1;65;CubeMap1;1,1,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;63;10.68739,1104.813;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;61;329.4635,658.3054;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;917.5675,1591.165;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;109.0238,-184.1841;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;31;-80.15255,225.9865;Inherit;False;BlinPhongSpcular;-1;;26;b68a7be45a1b57946bbc715cf04de998;0;2;1;FLOAT;100;False;12;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;28.85105,424.5632;Inherit;True;Property;_CubeMap;CubeMap;3;0;Create;True;0;0;0;False;0;False;-1;None;2ce065a2eefa2d94d9931945376a8303;True;0;False;black;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;65;586.2954,567.3408;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;1174.568,1574.165;Inherit;False;PointLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;318.3392,-67.64565;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;64;552.3635,901.1041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;1198.497,2332.068;Inherit;False;PointLight2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;1275.023,1117.057;Inherit;False;96;PointLight2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;1252.705,1011.349;Inherit;False;82;PointLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;1626.175,1072.295;Inherit;False;84;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;58;1316.805,779.5349;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;1591.073,837.1176;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;107;1827.175,1050.295;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WorldPosInputsNode;88;17.56947,2238.971;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;119;1994.202,1150.062;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;108;1957.175,892.2949;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;76;74.64014,1467.068;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;18;2253.838,956.2802;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/OpalStone;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;111;0;109;0
WireConnection;111;1;110;0
WireConnection;92;0;87;0
WireConnection;70;0;67;0
WireConnection;84;0;1;0
WireConnection;90;0;118;0
WireConnection;90;1;92;0
WireConnection;69;0;117;0
WireConnection;69;1;70;0
WireConnection;89;0;87;4
WireConnection;79;0;67;4
WireConnection;112;0;111;0
WireConnection;112;1;114;1
WireConnection;112;2;114;2
WireConnection;112;3;114;3
WireConnection;112;4;114;4
WireConnection;35;8;36;0
WireConnection;93;0;90;0
WireConnection;93;1;89;0
WireConnection;116;0;112;0
WireConnection;54;0;52;0
WireConnection;78;0;69;0
WireConnection;78;1;79;0
WireConnection;56;1;60;1
WireConnection;56;2;60;2
WireConnection;56;3;60;3
WireConnection;98;0;97;0
WireConnection;33;0;32;1
WireConnection;33;1;34;0
WireConnection;86;0;85;0
WireConnection;73;0;78;0
WireConnection;53;0;54;0
WireConnection;53;1;51;0
WireConnection;115;0;1;0
WireConnection;115;1;112;0
WireConnection;13;0;1;0
WireConnection;13;1;35;0
WireConnection;13;2;116;0
WireConnection;95;0;93;0
WireConnection;59;1;53;0
WireConnection;59;2;120;0
WireConnection;91;0;95;0
WireConnection;91;1;94;0
WireConnection;91;2;98;0
WireConnection;63;1;62;1
WireConnection;63;2;62;2
WireConnection;63;3;62;3
WireConnection;61;0;56;0
WireConnection;81;0;73;0
WireConnection;81;1;72;0
WireConnection;81;2;86;0
WireConnection;19;0;115;0
WireConnection;19;1;13;0
WireConnection;31;1;33;0
WireConnection;31;12;32;2
WireConnection;50;1;53;0
WireConnection;50;2;121;0
WireConnection;65;0;50;0
WireConnection;65;1;59;0
WireConnection;65;2;61;0
WireConnection;82;0;81;0
WireConnection;23;0;19;0
WireConnection;23;1;31;0
WireConnection;64;0;63;0
WireConnection;96;0;91;0
WireConnection;58;0;23;0
WireConnection;58;1;65;0
WireConnection;58;2;64;0
WireConnection;80;0;58;0
WireConnection;80;1;83;0
WireConnection;80;2;99;0
WireConnection;107;0;105;0
WireConnection;108;0;80;0
WireConnection;108;1;107;2
WireConnection;18;0;108;0
ASEEND*/
//CHKSM=EA77CC2677524EF9E4012F12E4CFD08EBD4CEAE8