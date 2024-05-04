// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Susanoo"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Fresnel_BSP("Fresnel_BSP", Vector) = (0,1,5,0)
		[HDR]_FresnelColor("FresnelColor", Color) = (0.712938,0.8723131,1,0)
		_EnergySpeed("EnergySpeed", Float) = 0.1
		_Energy_Power_Scale("Energy_Power_Scale", Vector) = (0,0,0,0)
		_EnergyScale("EnergyScale", Vector) = (0,0,0,0)
		_Star_Power_Scale("Star_Power_Scale", Vector) = (0,0,0,0)
		_StarScale("StarScale", Vector) = (0,0,0,0)
		_StarSpeed("StarSpeed", Float) = 0.1
		_StarDepth("StarDepth", Float) = 1
		[HDR]_EnergyColor("EnergyColor", Color) = (1,1,1,0)
		[HDR]_StarColor("StarColor", Color) = (1,1,1,0)
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float3 _Fresnel_BSP;
			uniform float4 _FresnelColor;
			uniform float3 _EnergyScale;
			uniform float _EnergySpeed;
			uniform float2 _Energy_Power_Scale;
			uniform float4 _EnergyColor;
			uniform float _StarDepth;
			uniform float3 _StarScale;
			uniform float _StarSpeed;
			uniform float2 _Star_Power_Scale;
			uniform float4 _StarColor;
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
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV3 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode3 = ( _Fresnel_BSP.x + _Fresnel_BSP.y * pow( max( 1.0 - fresnelNdotV3 , 0.0001 ), _Fresnel_BSP.z ) );
				float4 Fresnel9 = ( saturate( fresnelNode3 ) * _FresnelColor );
				float mulTime19 = _Time.y * _EnergySpeed;
				float simplePerlin3D22 = snoise( ( ( WorldPosition * _EnergyScale ) + ( mulTime19 * float3(0,-1,0) ) ) );
				simplePerlin3D22 = simplePerlin3D22*0.5 + 0.5;
				float4 Energy24 = ( pow( simplePerlin3D22 , _Energy_Power_Scale.x ) * _Energy_Power_Scale.y * _EnergyColor );
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float mulTime48 = _Time.y * _StarSpeed;
				float simplePerlin3D52 = snoise( ( ( ( WorldPosition + ( -ase_worldViewDir * _StarDepth ) ) * _StarScale ) + ( mulTime48 * float3(0,-1,0) ) ) );
				simplePerlin3D52 = simplePerlin3D52*0.5 + 0.5;
				float4 Star56 = ( pow( simplePerlin3D52 , _Star_Power_Scale.x ) * _Star_Power_Scale.y * _StarColor );
				
				
				finalColor = ( tex2D( _MainTex, uv_MainTex ) + Fresnel9 + Energy24 + Star56 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
437.1429;308;1736;728.7143;2141.468;-1227.36;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;43;-3222.06,1182.065;Inherit;False;2640.563;732.8572;Energy;21;63;58;56;55;54;52;53;51;49;50;47;45;48;62;46;60;44;61;59;65;67;Energy;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-3134.959,1373.637;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;63;-2871.959,1414.351;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;42;-2500.512,387.038;Inherit;False;1864.563;659.8572;Energy;15;27;32;17;21;19;20;33;18;30;22;28;29;24;64;66;Energy;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2591.959,1561.637;Inherit;False;Property;_StarDepth;StarDepth;9;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2396.06,1601.309;Inherit;False;Property;_StarSpeed;StarSpeed;8;0;Create;True;0;0;0;False;0;False;0.1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2391.959,1387.637;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;65;-2905.562,1231.749;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;27;-2450.512,805.2823;Inherit;False;Property;_EnergySpeed;EnergySpeed;3;0;Create;True;0;0;0;False;0;False;0.1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;47;-2166.543,1439.133;Inherit;False;Property;_StarScale;StarScale;7;0;Create;True;0;0;0;False;0;False;0,0,0;20,20,20;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;45;-2097.533,1659.065;Inherit;False;Constant;_Vector1;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;48;-2123.533,1581.065;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-2253.959,1287.637;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;19;-2177.985,786.038;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;32;-2220.995,644.1063;Inherit;False;Property;_EnergyScale;EnergyScale;5;0;Create;True;0;0;0;False;0;False;0,0,0;5,2,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;64;-2433.426,470.0746;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;21;-2150.985,864.038;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,-1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1875.995,565.9634;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1921.985,767.038;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1821.543,1360.99;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;11;-1767.422,-175.1478;Inherit;False;1132.68;412.5711;Fresnel;6;4;3;5;7;6;9;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1867.533,1562.065;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-1689.533,1404.065;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-1743.985,609.038;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;4;-1717.422,-89.14794;Inherit;False;Property;_Fresnel_BSP;Fresnel_BSP;1;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;22;-1495.985,584.038;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;52;-1441.533,1379.065;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;30;-1470.512,855.2823;Inherit;False;Property;_Energy_Power_Scale;Energy_Power_Scale;4;0;Create;True;0;0;0;False;0;False;0,0;7,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;53;-1416.06,1650.309;Inherit;False;Property;_Star_Power_Scale;Star_Power_Scale;6;0;Create;True;0;0;0;False;0;False;0,0;40,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FresnelNode;3;-1526.423,-124.1479;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;5;-1291.423,-110.1479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;54;-1139.06,1406.309;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;67;-1136.468,1692.36;Inherit;False;Property;_StarColor;StarColor;11;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-1334.423,31.85182;Inherit;False;Property;_FresnelColor;FresnelColor;2;1;[HDR];Create;True;0;0;0;False;0;False;0.712938,0.8723131,1,0;0.1995173,0,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;28;-1193.512,611.2823;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;66;-1177.265,835.3044;Inherit;False;Property;_EnergyColor;EnergyColor;10;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1036.512,618.2823;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1100.423,-125.1479;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-982.0604,1413.309;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-853.1712,-122.1279;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-859.3774,615.3317;Inherit;False;Energy;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-806.9257,1410.358;Inherit;False;Star;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-17.99524,-94.43536;Inherit;False;9;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-135.1428,-305.7857;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;af5b2f3f673a27d4aa7bca219a6b4ced;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;57;-12.79376,98.6465;Inherit;False;56;Star;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-28.09692,7.206482;Inherit;False;24;Energy;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;46;-2631.533,1243.065;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;17;-2184.985,437.038;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;8;261.8572,-295.7857;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;59;-2651.959,1387.637;Inherit;False;World;Object;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;497,-303;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Susanoo;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;63;0;58;0
WireConnection;60;0;63;0
WireConnection;60;1;61;0
WireConnection;48;0;44;0
WireConnection;62;0;65;0
WireConnection;62;1;60;0
WireConnection;19;0;27;0
WireConnection;33;0;64;0
WireConnection;33;1;32;0
WireConnection;20;0;19;0
WireConnection;20;1;21;0
WireConnection;49;0;62;0
WireConnection;49;1;47;0
WireConnection;50;0;48;0
WireConnection;50;1;45;0
WireConnection;51;0;49;0
WireConnection;51;1;50;0
WireConnection;18;0;33;0
WireConnection;18;1;20;0
WireConnection;22;0;18;0
WireConnection;52;0;51;0
WireConnection;3;1;4;1
WireConnection;3;2;4;2
WireConnection;3;3;4;3
WireConnection;5;0;3;0
WireConnection;54;0;52;0
WireConnection;54;1;53;1
WireConnection;28;0;22;0
WireConnection;28;1;30;1
WireConnection;29;0;28;0
WireConnection;29;1;30;2
WireConnection;29;2;66;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;55;0;54;0
WireConnection;55;1;53;2
WireConnection;55;2;67;0
WireConnection;9;0;6;0
WireConnection;24;0;29;0
WireConnection;56;0;55;0
WireConnection;8;0;1;0
WireConnection;8;1;10;0
WireConnection;8;2;25;0
WireConnection;8;3;57;0
WireConnection;59;0;63;0
WireConnection;2;0;8;0
ASEEND*/
//CHKSM=1C3C60D92E5D9E219A3D634C7559F70BB86C03F7