// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Colorful02"
{
	Properties
	{
		_Wrap1("_Wrap", Range( 0 , 1)) = 0.5
		_MainTex("_MainTex", 2D) = "white" {}
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_Float8("Float 8", Float) = 50
		_Float12("Float 12", Float) = 50
		_Float14("Float 14", Float) = 50
		_Vector1("Vector 1", Vector) = (0,0,0,0)
		_d1("d1", Float) = 0.1
		_d2("d2", Float) = 0.1
		_d3("d3", Float) = 0.1
		_o1("o1", Vector) = (0,0,0,0)
		_Vector2("Vector 2", Vector) = (0,0,0,0)
		_Cube("Cube", CUBE) = "white" {}
		_Vector3("Vector 3", Vector) = (0,0,0,0)
		_CubeLevel("CubeLevel", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
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
			float hash(float x) { return frac(x + 1.3215 * 1.8152); }              float hash3(float3 a) { return frac((hash(a.z * 42.8883) + hash(a.y * 36.9125) + hash(a.x * 65.4321)) * 291.1257); }              float3 rehash3(float x) { return float3(hash(((x + 0.5283) * 59.3829) * 274.3487), hash(((x + 0.8192) * 83.6621) * 345.3871), hash(((x + 0.2157f) * 36.6521f) * 458.3971f)); }              float sqr(float x) {return x*x;}             float fastdist(float3 a, float3 b) { return sqr(b.x - a.x) + sqr(b.y - a.y) + sqr(b.z - a.z); }              float2 Voronoi3D(float3 xyz)             {                 float x = xyz.x;                 float y = xyz.y;                 float z = xyz.z;                 float4 p[27];                 for (int _x = -1; _x < 2; _x++) for (int _y = -1; _y < 2; _y++) for(int _z = -1; _z < 2; _z++) {                     float3 _p = float3(floor(x), floor(y), floor(z)) + float3(_x, _y, _z);                     float h = hash3(_p);                     p[(_x + 1) + ((_y + 1) * 3) + ((_z + 1) * 3 * 3)] = float4((rehash3(h) + _p).xyz, h);                 }                 float m = 9999.9999, w = 0.0;                 for (int i = 0; i < 27; i++) {                     float d = fastdist(float3(x, y, z), p[i].xyz);                     if(d < m) { m = d; w = p[i].w; }                 }                 return float2(m, w);             }
			float3 pal( in float t, in float3 a, in float3 b, in float3 c, in float3 d )  {     return a + b*cos( 6.28318*(c*t+d) ); }  float3 spectrum(float n)  {     return pal( n, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.33,0.67) ); }


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

			//This is a late directive
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Wrap1;
			uniform float3 _o1;
			uniform float _Float8;
			uniform float _d1;
			uniform float3 _Vector2;
			uniform float _Float12;
			uniform float _d2;
			uniform float3 _Vector3;
			uniform float _Float14;
			uniform float _d3;
			uniform float4 _Vector1;
			uniform samplerCUBE _Cube;
			uniform float _CubeLevel;
			uniform float _Alpha;
			float2 MyCustomExpression3_g13( float3 pos )
			{
				return Voronoi3D(pos);
			}
			
			float2 MyCustomExpression3_g12( float3 pos )
			{
				return Voronoi3D(pos);
			}
			
			float2 MyCustomExpression3_g14( float3 pos )
			{
				return Voronoi3D(pos);
			}
			
			float3 MyCustomExpression2_g19( float value01 )
			{
				return spectrum(value01);  
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
				float4 tex2DNode46 = tex2D( _MainTex, uv_MainTex );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float dotResult28_g20 = dot( normalizedWorldNormal , worldSpaceLightDir );
				float WrapLight47_g20 = saturate( ( ( dotResult28_g20 + _Wrap1 ) / ( _Wrap1 + 1.0 ) ) );
				float4 temp_output_41_0 = ( tex2DNode46 * WrapLight47_g20 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 pos3_g13 = ( ( ( WorldPosition + _o1 ) * _Float8 ) + ( -ase_worldViewDir * _d1 ) );
				float2 localMyCustomExpression3_g13 = MyCustomExpression3_g13( pos3_g13 );
				float2 break5_g13 = localMyCustomExpression3_g13;
				float3 pos3_g12 = ( ( ( WorldPosition + _Vector2 ) * _Float12 ) + ( -ase_worldViewDir * _d2 ) );
				float2 localMyCustomExpression3_g12 = MyCustomExpression3_g12( pos3_g12 );
				float2 break5_g12 = localMyCustomExpression3_g12;
				float3 pos3_g14 = ( ( ( WorldPosition + _Vector3 ) * _Float14 ) + ( -ase_worldViewDir * _d3 ) );
				float2 localMyCustomExpression3_g14 = MyCustomExpression3_g14( pos3_g14 );
				float2 break5_g14 = localMyCustomExpression3_g14;
				float temp_output_71_0 = ( max( max( break5_g13.y , break5_g12.y ) , break5_g14.y ) + 0.0 );
				float temp_output_75_0 = ( pow( temp_output_71_0 , _Vector1.x ) * _Vector1.y );
				float temp_output_119_0 = frac( temp_output_75_0 );
				float value012_g19 = temp_output_119_0;
				float3 localMyCustomExpression2_g19 = MyCustomExpression2_g19( value012_g19 );
				float4 appendResult126 = (float4((( temp_output_41_0 + float4( ( temp_output_75_0 * localMyCustomExpression2_g19 * 10.0 ) , 0.0 ) + texCUBElod( _Cube, float4( reflect( -ase_worldViewDir , normalizedWorldNormal ), _CubeLevel) ) )).rgb , saturate( ( temp_output_75_0 + _Alpha ) )));
				
				
				finalColor = appendResult126;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
-4;364.5714;1884;905.8572;-236.0998;-1946.652;1;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;91;-1512.376,2590.118;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;115;-1579.165,2440.13;Inherit;False;Property;_Vector2;Vector 2;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;113;-1559.05,2288.057;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;111;-1310.815,1783.242;Inherit;False;Property;_o1;o1;13;0;Create;True;0;0;0;False;0;False;0,0,0;1.53,0.67,1.99;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;83;-1290.7,1631.169;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;85;-1485.5,2047.768;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;69;-1111.701,1958.297;Inherit;False;Property;_Float8;Float 8;6;0;Create;True;0;0;0;False;0;False;50;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;100;-1644.977,3129.616;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;116;-1775.05,2815.057;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1088.815,1721.242;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1312.376,2734.12;Inherit;False;Property;_d2;d2;11;0;Create;True;0;0;0;False;0;False;0.1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;92;-1334.376,2618.119;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1209.5,2182.77;Inherit;False;Property;_d1;d1;10;0;Create;True;0;0;0;False;0;False;0.1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;118;-1795.165,2967.13;Inherit;False;Property;_Vector3;Vector 3;16;0;Create;True;0;0;0;False;0;False;0,0,0;-1.16,1.35,1.65;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;98;-1214.578,2509.647;Inherit;False;Property;_Float12;Float 12;7;0;Create;True;0;0;0;False;0;False;50;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;86;-1231.5,2066.769;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-1357.165,2378.13;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-951.3779,2489.118;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1347.179,3049.145;Inherit;False;Property;_Float14;Float 14;8;0;Create;True;0;0;0;False;0;False;50;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-1444.977,3273.618;Inherit;False;Property;_d3;d3;12;0;Create;True;0;0;0;False;0;False;0.1;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;101;-1466.977,3157.617;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1190.376,2608.118;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1087.5,2056.768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-1573.165,2905.13;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-848.5007,1937.768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1322.977,3147.616;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1083.979,3028.616;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-697.5007,1984.768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-800.3779,2536.118;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;96;-659.3779,2541.118;Inherit;False;Voronoi3D;-1;;12;df8de70fb04c9b448bd226b0974e00e4;0;1;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;106;-932.9785,3075.616;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;81;-556.5007,1989.768;Inherit;False;Voronoi3D;-1;;13;df8de70fb04c9b448bd226b0974e00e4;0;1;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;109;-349.6813,2084.781;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;105;-791.9786,3080.616;Inherit;False;Voronoi3D;-1;;14;df8de70fb04c9b448bd226b0974e00e4;0;1;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;110;-204.6813,2126.781;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-108.901,2329.198;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;79;173.193,1778.14;Inherit;False;Property;_Vector1;Vector 1;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;500,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;131;266.6074,2741.421;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;75;421.7634,1856.913;Inherit;False;PowerScale;-1;;15;5ba70760a40e0a6499195a0590fd2e74;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;132;457.6074,2761.421;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;119;535.3728,2101.352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;134;415.6074,2901.421;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;46;-290.7059,793.6165;Inherit;True;Property;_MainTex;_MainTex;4;0;Create;True;0;0;0;False;0;False;-1;None;af5a9195f18c63940a1466ed0c970181;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;136;664.6074,2920.421;Inherit;False;Property;_CubeLevel;CubeLevel;18;0;Create;True;0;0;0;False;0;False;0;7.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;794.3728,2455.352;Inherit;False;Constant;_Float10;Float 10;16;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;140;445.1559,2296.894;Inherit;False;Spectrum;-1;;19;9861418a7d5878e47bc200122ef6217e;0;1;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;40;-307.6746,1436.196;Inherit;False;BlinPhongWrapDuffuse;1;;20;fcddb8cdfae5cee469ab8fef7b043990;0;0;2;FLOAT;0;FLOAT;93
Node;AmplifyShaderEditor.ReflectOpNode;133;694.6074,2754.421;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;958.1721,2061.04;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;135;917.6074,2707.421;Inherit;True;Property;_Cube;Cube;15;0;Create;True;0;0;0;False;0;False;-1;None;2ce065a2eefa2d94d9931945376a8303;True;0;False;white;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;293.291,917.6631;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;1016.823,2269.776;Inherit;False;Property;_Alpha;Alpha;5;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;1277.477,2114.275;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;1163.699,1798.864;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;130;1312.477,1817.275;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;129;1454.477,2141.275;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;5;-134.4283,336.95;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;14;-577.6879,731.0383;Inherit;True;Property;_New_Graph_output;New_Graph_output;17;0;Create;True;0;0;0;False;0;False;-1;ced377b925ea0da478a552cfd5729bae;fd7ff4f2aef30e84f88cac91d1c7e58f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-780.355,219.1767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;137;895.0283,2543.51;Inherit;False;Schlick;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;904.0413,1871.63;Inherit;False;Constant;_Float11;Float 11;16;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1201.143,139.6428;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;25;-1618.504,608.5792;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.HSVToRGBNode;77;655.2004,2182.893;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;49;52.70383,984.4904;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1541.372,835.6891;Inherit;False;Constant;_Float5;Float 5;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;106.1855,2183.386;Inherit;False;Constant;_Float9;Float 9;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;884.0413,1795.63;Inherit;False;-1;;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;190.4708,1256.776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;63;-1008.989,632.8446;Inherit;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-553.3547,307.0339;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;331.6455,412.4321;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;446.9329,2466.781;Inherit;False;FakeNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-761.9888,774.8446;Inherit;False;Constant;_Float6;Float 6;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;335.193,2002.14;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-770.9888,593.8446;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;20;-1301.823,525.2552;Inherit;True;Random Range;-1;;22;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1054.355,393.1768;Inherit;False;Property;_Float2;Float 2;0;0;Create;True;0;0;0;False;0;False;0;1.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;61;565.7139,1227.546;Inherit;True;Screen;True;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-984.355,241.1767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;141;200.9329,2396.781;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;126;1720.477,2053.275;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-71.70092,1572.895;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;139;1169.818,2561.728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;34;2011.244,2004.194;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Colorful02;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;112;0;83;0
WireConnection;112;1;111;0
WireConnection;92;0;91;0
WireConnection;86;0;85;0
WireConnection;114;0;113;0
WireConnection;114;1;115;0
WireConnection;95;0;114;0
WireConnection;95;1;98;0
WireConnection;101;0;100;0
WireConnection;94;0;92;0
WireConnection;94;1;93;0
WireConnection;87;0;86;0
WireConnection;87;1;88;0
WireConnection;117;0;116;0
WireConnection;117;1;118;0
WireConnection;84;0;112;0
WireConnection;84;1;69;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;104;0;117;0
WireConnection;104;1;107;0
WireConnection;89;0;84;0
WireConnection;89;1;87;0
WireConnection;97;0;95;0
WireConnection;97;1;94;0
WireConnection;96;2;97;0
WireConnection;106;0;104;0
WireConnection;106;1;103;0
WireConnection;81;2;89;0
WireConnection;109;0;81;4
WireConnection;109;1;96;4
WireConnection;105;2;106;0
WireConnection;110;0;109;0
WireConnection;110;1;105;4
WireConnection;71;0;110;0
WireConnection;75;1;71;0
WireConnection;75;2;79;1
WireConnection;75;3;79;2
WireConnection;132;0;131;0
WireConnection;119;0;75;0
WireConnection;140;1;119;0
WireConnection;133;0;132;0
WireConnection;133;1;134;0
WireConnection;120;0;75;0
WireConnection;120;1;140;0
WireConnection;120;2;121;0
WireConnection;135;1;133;0
WireConnection;135;2;136;0
WireConnection;41;0;46;0
WireConnection;41;1;40;0
WireConnection;128;0;75;0
WireConnection;128;1;62;0
WireConnection;122;0;41;0
WireConnection;122;1;120;0
WireConnection;122;2;135;0
WireConnection;130;0;122;0
WireConnection;129;0;128;0
WireConnection;5;0;13;0
WireConnection;9;0;11;0
WireConnection;9;1;10;0
WireConnection;77;0;119;0
WireConnection;77;1;78;0
WireConnection;77;2;78;0
WireConnection;49;0;46;0
WireConnection;45;0;40;93
WireConnection;45;1;43;0
WireConnection;15;0;5;0
WireConnection;15;1;14;1
WireConnection;142;0;141;0
WireConnection;80;0;79;3
WireConnection;80;1;71;0
WireConnection;64;0;63;1
WireConnection;64;1;63;2
WireConnection;64;2;63;3
WireConnection;61;0;41;0
WireConnection;61;1;45;0
WireConnection;11;0;6;1
WireConnection;141;0;71;0
WireConnection;126;0;130;0
WireConnection;126;3;129;0
WireConnection;139;0;137;0
WireConnection;34;0;126;0
ASEEND*/
//CHKSM=4912511A01B6DEC9C0368187873C69F5BC2FCC06