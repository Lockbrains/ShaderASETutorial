// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Susanoo02"
{
	Properties
	{
		_F_BSP("F_BSP", Vector) = (0,1,5,0)
		[HDR]_Fresnel_Color("Fresnel_Color", Color) = (1,1,1,0)
		_MainTex("_MainTex", 2D) = "black" {}
		[HDR]_StarColor("StarColor", Color) = (1,1,1,0)
		_Star_UVScale_Pow_Scale("Star_UVScale_Pow_Scale", Vector) = (10,1,1,0)
		[Toggle(_ENABLESTARCOLORFUL_ON)] _EnableStarColorful("EnableStarColorful", Float) = 0
		_StarSpeed("StarSpeed", Range( 0 , 1)) = 0
		_StarDepth("StarDepth", Float) = 0
		[HDR]_CloudColor("CloudColor", Color) = (1,1,1,0)
		_Cloud_UVScale_Pow_Scale("Cloud_UVScale_Pow_Scale", Vector) = (10,1,1,0)
		[Toggle(_ENABLECLOUDCOLORFUL_ON)] _EnableCloudColorful("EnableCloudColorful", Float) = 0
		_CloudSpeed("CloudSpeed", Range( 0 , 1)) = 0
		_CloudDepth("CloudDepth", Float) = 0
		_CloudUVScaleXYZ("CloudUVScaleXYZ", Vector) = (1,1,1,0)
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
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLESTARCOLORFUL_ON
			#pragma shader_feature_local _ENABLECLOUDCOLORFUL_ON


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
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

			uniform float3 _F_BSP;
			uniform float4 _Fresnel_Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _StarSpeed;
			uniform float _StarDepth;
			uniform float4 _Star_UVScale_Pow_Scale;
			uniform float4 _StarColor;
			uniform float3 _CloudUVScaleXYZ;
			uniform float _CloudSpeed;
			uniform float _CloudDepth;
			uniform float4 _Cloud_UVScale_Pow_Scale;
			uniform float4 _CloudColor;
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

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
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
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode1 = ( _F_BSP.x + _F_BSP.y * pow( max( 1.0 - fresnelNdotV1 , 0.0001 ), _F_BSP.z ) );
				float4 Fresnel6 = ( saturate( fresnelNode1 ) * _Fresnel_Color );
				float2 uv_MainTex = i.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Base10 = tex2D( _MainTex, uv_MainTex );
				float mulTime35 = _Time.y * _StarSpeed;
				float3 temp_output_36_0 = ( WorldPosition + ( float3(0,-1,0) * mulTime35 ) );
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float simplePerlin3D14 = snoise( ( temp_output_36_0 + ( -ase_worldViewDir * _StarDepth ) )*_Star_UVScale_Pow_Scale.x );
				simplePerlin3D14 = simplePerlin3D14*0.5 + 0.5;
				float3 MovePos39 = temp_output_36_0;
				float3 hsvTorgb38 = HSVToRGB( float3(( MovePos39.y * 10.0 ),1.0,1.0) );
				#ifdef _ENABLESTARCOLORFUL_ON
				float4 staticSwitch45 = float4( hsvTorgb38 , 0.0 );
				#else
				float4 staticSwitch45 = _StarColor;
				#endif
				float4 temp_cast_1 = (10.0).xxxx;
				float4 Star26 = min( ( ( pow( simplePerlin3D14 , _Star_UVScale_Pow_Scale.y ) * _Star_UVScale_Pow_Scale.z ) * staticSwitch45 ) , temp_cast_1 );
				float mulTime48 = _Time.y * _CloudSpeed;
				float simplePerlin3D60 = snoise( ( ( ( WorldPosition * _CloudUVScaleXYZ ) + ( float3(0,-1,0) * mulTime48 ) ) + ( -ase_worldViewDir * _CloudDepth ) ) );
				simplePerlin3D60 = simplePerlin3D60*0.5 + 0.5;
				float3 hsvTorgb71 = HSVToRGB( float3(( MovePos39.y * 10.0 ),1.0,1.0) );
				#ifdef _ENABLECLOUDCOLORFUL_ON
				float4 staticSwitch65 = float4( hsvTorgb71 , 0.0 );
				#else
				float4 staticSwitch65 = _CloudColor;
				#endif
				float4 temp_cast_3 = (10.0).xxxx;
				float4 Cloud63 = min( ( pow( simplePerlin3D60 , _Cloud_UVScale_Pow_Scale.y ) * _Cloud_UVScale_Pow_Scale.z * staticSwitch65 ) , temp_cast_3 );
				
				
				finalColor = ( Fresnel6 + Base10 + Star26 + Cloud63 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
115.4286;976.5715;1866.286;764.7143;4099.716;-420.1577;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;46;-3331.027,-247.1919;Inherit;False;2733.135;1076.414;Star;28;37;35;33;34;17;28;36;31;29;39;30;32;19;14;20;23;45;21;25;22;24;26;40;44;41;43;42;38;Star;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3281.027,95.8;Inherit;False;Property;_StarSpeed;StarSpeed;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;33;-2901.027,-59.20002;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;35;-2921.027,92.8;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;17;-2881.028,-197.1919;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2684.027,-43.20003;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-2563.027,-118.2001;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;28;-2679.518,172.0515;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;47;-3227.677,1304.989;Inherit;False;Property;_CloudSpeed;CloudSpeed;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;29;-2483.518,181.0515;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2520.027,284.7998;Inherit;False;Property;_StarDepth;StarDepth;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-2330.98,-102.4927;Inherit;False;MovePos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;76;-3050.716,1033.158;Inherit;False;Property;_CloudUVScaleXYZ;CloudUVScaleXYZ;13;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;51;-3000.678,849.9969;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;52;-2626.168,1381.24;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;49;-2864.677,1153.989;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;48;-2867.677,1301.989;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2354.027,179.8002;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2755.716,930.1577;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2337.98,497.5076;Inherit;False;39;MovePos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2630.677,1165.989;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2468.677,1493.989;Inherit;False;Property;_CloudDepth;CloudDepth;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;55;-2430.168,1390.24;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2449.619,1811.899;Inherit;False;39;MovePos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;68;-2261.619,1809.899;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-2509.677,1090.989;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-2300.677,1388.989;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-2286.619,1949.899;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;41;-2149.98,495.5075;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector4Node;19;-2143.028,216.8081;Inherit;False;Property;_Star_UVScale_Pow_Scale;Star_UVScale_Pow_Scale;4;0;Create;True;0;0;0;False;0;False;10,1,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-2206.028,74.79989;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2174.98,635.5077;Inherit;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1978.981,526.5076;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;14;-1905.772,79.35948;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2129.62,2028.899;Inherit;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2090.62,1840.899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;8;-1967.467,-757.0114;Inherit;False;1262.429;457.5714;Fresnel;6;2;1;3;4;5;6;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2017.981,714.5077;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-2152.678,1283.989;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;23;-1742.084,337.0999;Inherit;False;Property;_StarColor;StarColor;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;2;-1917.467,-678.0113;Inherit;False;Property;_F_BSP;F_BSP;0;0;Create;True;0;0;0;False;0;False;0,1,5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;60;-1852.422,1288.548;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;72;-1855.723,1652.491;Inherit;False;Property;_CloudColor;CloudColor;8;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;59;-2178.677,1443.997;Inherit;False;Property;_Cloud_UVScale_Pow_Scale;Cloud_UVScale_Pow_Scale;9;0;Create;True;0;0;0;False;0;False;10,1,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;20;-1676.231,78.47236;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;38;-1735,561.1452;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.HSVToRGBNode;71;-1846.639,1875.537;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;61;-1622.88,1287.661;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;65;-1613.62,1692.899;Inherit;False;Property;_EnableCloudColorful;EnableCloudColorful;10;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;1;-1654.467,-707.0114;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1458.23,85.47243;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;45;-1486.981,373.507;Inherit;False;Property;_EnableStarColorful;EnableStarColorful;5;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1256.083,83.10005;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1228.083,213.1002;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;3;-1363.467,-687.0113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;11;-1359.092,-1084.396;Inherit;False;654.4286;280;Base;2;9;10;Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1298.437,1452.857;Inherit;False;Constant;_Float5;Float 5;5;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1404.88,1294.661;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;5;-1569.467,-505.0113;Inherit;False;Property;_Fresnel_Color;Fresnel_Color;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;73;-1125.437,1324.857;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1158.467,-658.0114;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;24;-1055.083,85.10009;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-1309.092,-1034.397;Inherit;True;Property;_MainTex;_MainTex;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-918.9557,1294.254;Inherit;False;Cloud;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-821.3207,100.586;Inherit;False;Star;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-928.468,-664.0114;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-928.0932,-1004.397;Inherit;False;Base;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;59.23193,110.8286;Inherit;False;10;Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;76.61951,223.9408;Inherit;False;26;Star;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;9.522461,341.5691;Inherit;False;63;Cloud;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;74.85718,30.21426;Inherit;False;6;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;333.2319,78.82861;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;547,73;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Susanoo02;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;35;0;37;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;36;0;17;0
WireConnection;36;1;34;0
WireConnection;29;0;28;0
WireConnection;39;0;36;0
WireConnection;48;0;47;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;75;0;51;0
WireConnection;75;1;76;0
WireConnection;50;0;49;0
WireConnection;50;1;48;0
WireConnection;55;0;52;0
WireConnection;68;0;66;0
WireConnection;53;0;75;0
WireConnection;53;1;50;0
WireConnection;57;0;55;0
WireConnection;57;1;54;0
WireConnection;41;0;40;0
WireConnection;32;0;36;0
WireConnection;32;1;30;0
WireConnection;43;0;41;1
WireConnection;43;1;44;0
WireConnection;14;0;32;0
WireConnection;14;1;19;1
WireConnection;69;0;68;1
WireConnection;69;1;67;0
WireConnection;58;0;53;0
WireConnection;58;1;57;0
WireConnection;60;0;58;0
WireConnection;20;0;14;0
WireConnection;20;1;19;2
WireConnection;38;0;43;0
WireConnection;38;1;42;0
WireConnection;38;2;42;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;71;2;70;0
WireConnection;61;0;60;0
WireConnection;61;1;59;2
WireConnection;65;1;72;0
WireConnection;65;0;71;0
WireConnection;1;1;2;1
WireConnection;1;2;2;2
WireConnection;1;3;2;3
WireConnection;21;0;20;0
WireConnection;21;1;19;3
WireConnection;45;1;23;0
WireConnection;45;0;38;0
WireConnection;22;0;21;0
WireConnection;22;1;45;0
WireConnection;3;0;1;0
WireConnection;62;0;61;0
WireConnection;62;1;59;3
WireConnection;62;2;65;0
WireConnection;73;0;62;0
WireConnection;73;1;74;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;24;0;22;0
WireConnection;24;1;25;0
WireConnection;63;0;73;0
WireConnection;26;0;24;0
WireConnection;6;0;4;0
WireConnection;10;0;9;0
WireConnection;13;0;7;0
WireConnection;13;1;12;0
WireConnection;13;2;27;0
WireConnection;13;3;64;0
WireConnection;0;0;13;0
ASEEND*/
//CHKSM=610C3A13F1218BF17F8883A87D444E6361EE4680