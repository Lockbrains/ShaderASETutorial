// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Colorful01"
{
	Properties
	{
		_Float2("Float 2", Float) = 0
		_Wrap1("_Wrap", Range( 0 , 1)) = 0.5
		_BP_Pow_Scale("BP_Pow_Scale", Vector) = (0,0,0,0)
		_Float3("Float 3", Float) = 0
		_MainTex("_MainTex", 2D) = "white" {}
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_New_Graph_output("New_Graph_output", 2D) = "white" {}
		_Cube1("Cube", CUBE) = "white" {}
		_CubeLevel1("CubeLevel", Float) = 0
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
			uniform float2 _BP_Pow_Scale;
			uniform float _Float3;
			uniform float _Float2;
			uniform sampler2D _New_Graph_output;
			uniform float4 _New_Graph_output_ST;
			uniform float _Alpha;
			uniform samplerCUBE _Cube1;
			uniform float _CubeLevel1;
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
			
			float3 MyCustomExpression2_g17( float value01 )
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
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float dotResult28_g18 = dot( normalizedWorldNormal , worldSpaceLightDir );
				float WrapLight47_g18 = saturate( ( ( dotResult28_g18 + _Wrap1 ) / ( _Wrap1 + 1.0 ) ) );
				float3 N7_g18 = normalizedWorldNormal;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 V12_g18 = ase_worldViewDir;
				float3 L13_g18 = worldSpaceLightDir;
				float3 normalizeResult24_g18 = normalize( ( V12_g18 + L13_g18 ) );
				float3 H31_g18 = normalizeResult24_g18;
				float dotResult38_g18 = dot( N7_g18 , H31_g18 );
				float BlinPhong49_g18 = ( pow( saturate( dotResult38_g18 ) , ( _BP_Pow_Scale.x * 1200.0 ) ) * _BP_Pow_Scale.y );
				float2 texCoord6 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord35 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_26_0 = ( floor( ( texCoord35 * 50.0 ) ) / 50.0 );
				float simplePerlin3D27 = snoise( float3( temp_output_26_0 ,  0.0 )*10.0 );
				simplePerlin3D27 = simplePerlin3D27*0.5 + 0.5;
				float dotResult4_g14 = dot( temp_output_26_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g14 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g14 ) * 43758.55 ) ));
				float dotResult55 = dot( ase_worldViewDir , normalizedWorldNormal );
				float NV56 = dotResult55;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float value012_g17 = ( ( ( texCoord6.x * _Float3 ) + _Float2 ) + simplePerlin3D27 + lerpResult10_g14 + NV56 + ( ( ase_worldViewDir.x + ase_worldViewDir.y + ase_worldViewDir.z ) * 0.1 ) );
				float3 localMyCustomExpression2_g17 = MyCustomExpression2_g17( value012_g17 );
				float3 temp_output_67_0 = localMyCustomExpression2_g17;
				float2 uv_New_Graph_output = i.ase_texcoord1.xyz.xy * _New_Graph_output_ST.xy + _New_Graph_output_ST.zw;
				float3 ColorMask36 = ( temp_output_67_0 * tex2D( _New_Graph_output, uv_New_Graph_output ).r );
				float4 blendOpSrc61 = ( tex2D( _MainTex, uv_MainTex ) * WrapLight47_g18 );
				float4 blendOpDest61 = float4( ( BlinPhong49_g18 * ColorMask36 ) , 0.0 );
				float4 lerpBlendMode61 = lerp(blendOpDest61,( 1.0 - ( 1.0 - blendOpSrc61 ) * ( 1.0 - blendOpDest61 ) ),_Alpha);
				
				
				finalColor = ( ( saturate( lerpBlendMode61 )) + ( texCUBElod( _Cube1, float4( reflect( -ase_worldViewDir , normalizedWorldNormal ), _CubeLevel1) ) * 0.4 ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;273.1429;1884;900.1429;396.8843;-1590.643;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;24;-1905.504,721.5792;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1994.568,463.4698;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;53;-662.4255,1432.404;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;54;-658.4255,1583.404;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1753.504,606.5792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;25;-1618.504,608.5792;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;63;-1008.989,632.8446;Inherit;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1201.143,139.6428;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;55;-436.4255,1485.404;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1170.355,283.1767;Inherit;False;Property;_Float3;Float 3;4;0;Create;True;0;0;0;False;0;False;0;1.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1054.355,393.1768;Inherit;False;Property;_Float2;Float 2;0;0;Create;True;0;0;0;False;0;False;0;1.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1541.372,835.6891;Inherit;False;Constant;_Float5;Float 5;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;26;-1505.504,613.5792;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-761.9888,774.8446;Inherit;False;Constant;_Float6;Float 6;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-984.355,241.1767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-770.9888,593.8446;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-258.5103,1658.407;Inherit;False;NV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-648.9888,600.8446;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-780.355,219.1767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;27;-1312.865,801.7878;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;20;-1301.823,525.2552;Inherit;True;Random Range;-1;;14;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-840.0642,525.9175;Inherit;False;56;NV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-553.3547,307.0339;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-577.6879,731.0383;Inherit;True;Property;_New_Graph_output;New_Graph_output;7;0;Create;True;0;0;0;False;0;False;-1;ced377b925ea0da478a552cfd5729bae;fd7ff4f2aef30e84f88cac91d1c7e58f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;67;-152.4236,184.8359;Inherit;False;Spectrum;-1;;17;9861418a7d5878e47bc200122ef6217e;0;1;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;331.6455,412.4321;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;68;-59.3605,2147.245;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;539.5383,414.5945;Inherit;False;ColorMask;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;69;131.6395,2167.245;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;70;31.82899,2336.291;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;46;-301.5929,1270.071;Inherit;True;Property;_MainTex;_MainTex;5;0;Create;True;0;0;0;False;0;False;-1;None;af5a9195f18c63940a1466ed0c970181;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;43;-39.588,1986.349;Inherit;False;36;ColorMask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;40;-275.5616,1849.65;Inherit;False;BlinPhongWrapDuffuse;1;;18;fcddb8cdfae5cee469ab8fef7b043990;0;0;2;FLOAT;0;FLOAT;93
Node;AmplifyShaderEditor.ReflectOpNode;71;368.6395,2160.245;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;338.6395,2326.245;Inherit;False;Property;_CubeLevel1;CubeLevel;9;0;Create;True;0;0;0;False;0;False;0;7.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;73;591.6395,2113.245;Inherit;True;Property;_Cube1;Cube;8;0;Create;True;0;0;0;False;0;False;-1;None;2ce065a2eefa2d94d9931945376a8303;True;0;False;white;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;222.5837,1670.23;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;325.404,1331.117;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;288.9365,1872.23;Inherit;False;Property;_Alpha;Alpha;6;0;Create;True;0;0;0;False;0;False;0;0.366;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;756.1157,2317.643;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;61;597.8268,1641;Inherit;True;Screen;True;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;913.1157,2134.643;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;1123.554,1941.438;Inherit;False;75;Spec;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;973.707,1746.831;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;171.3505,190.8405;Inherit;False;Spec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;79;1357.554,1959.438;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;34;1485.358,1716.582;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Colorful01;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;23;0;35;0
WireConnection;23;1;24;0
WireConnection;25;0;23;0
WireConnection;55;0;53;0
WireConnection;55;1;54;0
WireConnection;26;0;25;0
WireConnection;26;1;24;0
WireConnection;11;0;6;1
WireConnection;11;1;12;0
WireConnection;64;0;63;1
WireConnection;64;1;63;2
WireConnection;64;2;63;3
WireConnection;56;0;55;0
WireConnection;65;0;64;0
WireConnection;65;1;66;0
WireConnection;9;0;11;0
WireConnection;9;1;10;0
WireConnection;27;0;26;0
WireConnection;27;1;29;0
WireConnection;20;1;26;0
WireConnection;13;0;9;0
WireConnection;13;1;27;0
WireConnection;13;2;20;0
WireConnection;13;3;57;0
WireConnection;13;4;65;0
WireConnection;67;1;13;0
WireConnection;15;0;67;0
WireConnection;15;1;14;1
WireConnection;36;0;15;0
WireConnection;69;0;68;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;73;1;71;0
WireConnection;73;2;72;0
WireConnection;45;0;40;93
WireConnection;45;1;43;0
WireConnection;41;0;46;0
WireConnection;41;1;40;0
WireConnection;61;0;41;0
WireConnection;61;1;45;0
WireConnection;61;2;62;0
WireConnection;80;0;73;0
WireConnection;80;1;81;0
WireConnection;74;0;61;0
WireConnection;74;1;80;0
WireConnection;75;0;67;0
WireConnection;79;0;78;0
WireConnection;34;0;74;0
ASEEND*/
//CHKSM=9E71EC1A8D7FC582CF1A335CE6B8AA04A664188F