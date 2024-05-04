// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE_Burn-HomeWork"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_AlphaTest("AlphaTest", Float) = 0
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Global_BurningValue;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _AlphaTest;
			uniform float4 _Global_BurningColor;
			uniform float4 _Global_BurningColorRange;
			//https://www.shadertoy.com/view/XdXGW8
			float2 GradientNoiseDir( float2 x )
			{
				const float2 k = float2( 0.3183099, 0.3678794 );
				x = x * k + k.yx;
				return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
			}
			
			float GradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 i = floor( p );
				float2 f = frac( p );
				float2 u = f * f * ( 3.0 - 2.0 * f );
				return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
						dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
						lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
						dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
			}
			
			float BurnningFunction237( float noise, float burnValue, float width, float burningRange )
			{
				float test = noise-burnValue;
				//高亮的区域设置为1，不是的话设置为0
				//高亮区域
				if(test<width) return 1;
				//非高亮区域
				return 0;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			float4 BurnningFunction29( float noise, float burnValue, float width, float4 color, float burningRange, float4 colorRange )
			{
				float test = noise-burnValue;
				clip(test);
				float4 finalColor = (float4)0;
				//w,高亮的区域设置为1，不是的话设置为0
				//高亮区域
				if(test<width)
				{   
				  finalColor=float4(color.rgb,1);
				  return finalColor;
				}
				//非高亮区域
				finalColor = smoothstep(burningRange,0,test)*colorRange;
				finalColor.w=0;
				return finalColor;
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 texCoord4 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float gradientNoise3 = GradientNoise(texCoord4,_Global_BurningValue.z);
				gradientNoise3 = gradientNoise3*0.5 + 0.5;
				float noise37 = gradientNoise3;
				float burnValue37 = _Global_BurningValue.x;
				float width37 = _Global_BurningValue.y;
				float burningRange37 = _Global_BurningValue.w;
				float localBurnningFunction237 = BurnningFunction237( noise37 , burnValue37 , width37 , burningRange37 );
				float2 texCoord57 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float simplePerlin2D56 = snoise( texCoord57*20.0 );
				simplePerlin2D56 = simplePerlin2D56*0.5 + 0.5;
				float3 appendResult47 = (float3(v.ase_normal.x , 0.0 , 0.0));
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = ( localBurnningFunction237 * 0.01 * simplePerlin2D56 * appendResult47 * 2.0 );
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
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				clip( tex2DNode1.a - _AlphaTest);
				float2 texCoord4 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float gradientNoise3 = GradientNoise(texCoord4,_Global_BurningValue.z);
				gradientNoise3 = gradientNoise3*0.5 + 0.5;
				float noise29 = gradientNoise3;
				float burnValue29 = _Global_BurningValue.x;
				float width29 = _Global_BurningValue.y;
				float4 color29 = _Global_BurningColor;
				float burningRange29 = _Global_BurningValue.w;
				float4 colorRange29 = _Global_BurningColorRange;
				float4 localBurnningFunction29 = BurnningFunction29( noise29 , burnValue29 , width29 , color29 , burningRange29 , colorRange29 );
				
				
				finalColor = ( tex2DNode1 + localBurnningFunction29 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
224;360;1657.714;946.4286;919.3992;-737.4777;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1047.745,332.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;18;-1061.174,532.1976;Inherit;False;Global;_Global_BurningValue;_Global_BurningValue;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.49,0.00034,7.17,0.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-379.3386,1262.292;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-425.0659,-174.4102;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;a4abc12a4b709a54cbc16f284f0fe6e6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;26;-739.8901,707.891;Inherit;False;Global;_Global_BurningColor;_Global_BurningColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;119.4283,7.313888,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;48;-16.73624,1087.765;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;30;-796.1865,856.1207;Inherit;False;Global;_Global_BurningColorRange;_Global_BurningColorRange;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;1.059274,0.1053728,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;3;-753.7144,209.5;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;50;-199.0645,460.3278;Inherit;False;310.8571;227.8571;提取高亮区域;1;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-267.0659,47.58981;Inherit;False;Property;_AlphaTest;AlphaTest;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-352.3386,1411.292;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;56;-119.3386,1303.292;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;37;-159.0645,503.3271;Inherit;False;float test = noise-burnValue@$$//高亮的区域设置为1，不是的话设置为0$$//高亮区域$if(test<width) return 1@$$//非高亮区域$return 0@;1;False;4;False;noise;FLOAT;0;In;;Inherit;False;False;burnValue;FLOAT;0;In;;Inherit;False;False;width;FLOAT;0.1;In;;Inherit;False;False;burningRange;FLOAT;0.1;In;;Inherit;False;BurnningFunction2;True;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;4.364403,709.7352;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;47;176.9964,1106.005;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;46;244.2965,1252.305;Inherit;False;Constant;_Float4;Float 4;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;10;-30.06596,-147.4102;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;29;-163.5968,183.6943;Inherit;False;float test = noise-burnValue@$clip(test)@$float4 finalColor = (float4)0@$$//w,高亮的区域设置为1，不是的话设置为0$$//高亮区域$if(test<width)${   $  finalColor=float4(color.rgb,1)@$  return finalColor@$}$$//非高亮区域$finalColor = smoothstep(burningRange,0,test)*colorRange@$finalColor.w=0@$$return finalColor@;4;False;6;False;noise;FLOAT;0;In;;Inherit;False;False;burnValue;FLOAT;0;In;;Inherit;False;False;width;FLOAT;0.1;In;;Inherit;False;False;color;FLOAT4;5,0,0,0;In;;Inherit;False;False;burningRange;FLOAT;0.1;In;;Inherit;False;False;colorRange;FLOAT4;0,0,0,0;In;;Inherit;False;BurnningFunction;True;False;0;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT4;5,0,0,0;False;4;FLOAT;0.1;False;5;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-398.3386,959.2921;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;49;63.21686,846.3909;Inherit;True;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-159.3386,838.2921;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;287.0782,140.6632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;493.4596,656.1916;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VoronoiNode;54;-213.3386,1105.292;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-409.3361,795.0051;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;752.6635,243.9974;Float;False;True;-1;2;ASEMaterialInspector;100;1;ASE_Burn-HomeWork;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;3;0;4;0
WireConnection;3;1;18;3
WireConnection;56;0;57;0
WireConnection;56;1;58;0
WireConnection;37;0;3;0
WireConnection;37;1;18;1
WireConnection;37;2;18;2
WireConnection;37;3;18;4
WireConnection;47;0;48;1
WireConnection;10;0;1;0
WireConnection;10;1;1;4
WireConnection;10;2;11;0
WireConnection;29;0;3;0
WireConnection;29;1;18;1
WireConnection;29;2;18;2
WireConnection;29;3;26;0
WireConnection;29;4;18;4
WireConnection;29;5;30;0
WireConnection;49;1;52;0
WireConnection;52;0;39;0
WireConnection;52;1;53;0
WireConnection;27;0;10;0
WireConnection;27;1;29;0
WireConnection;35;0;37;0
WireConnection;35;1;42;0
WireConnection;35;2;56;0
WireConnection;35;3;47;0
WireConnection;35;4;46;0
WireConnection;0;0;27;0
WireConnection;0;1;35;0
ASEEND*/
//CHKSM=E3DBA62523C78CC3DE0C14538A5ED934805E8DF4