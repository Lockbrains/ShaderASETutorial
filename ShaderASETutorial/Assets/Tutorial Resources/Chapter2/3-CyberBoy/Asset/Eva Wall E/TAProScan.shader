// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/TAProScan"
{
	Properties
	{
		[HDR]_FracColor("FracColor", Color) = (0.4678838,0.6840086,0.9433962,0)
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_EdgeWidth("EdgeWidth", Float) = 0.1
		_EdgeIntensity("EdgeIntensity", Float) = 0

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
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" "Queue"="Transparent" }
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

			uniform float4 _FracColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _EdgeWidth;
			uniform float4 _EdgeColor;
			uniform float _EdgeIntensity;
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
			
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			
			float3 InvertDepthDir72_g8( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
				return result;
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 texCoord27 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime29 = _Time.y * 0.2;
				float simpleNoise26 = SimpleNoise( ( texCoord27 + ( mulTime29 * float2( -1,0 ) ) )*10.0 );
				float2 texCoord11 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g7 = dot( frac( ( texCoord11 + ( float2( 0,1 ) * _Time.y ) ) ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g7 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g7 ) * 43758.55 ) ));
				float temp_output_17_0 = lerpResult10_g7;
				float2 texCoord1 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime4 = _Time.y * -0.5;
				float2 texCoord53 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV22_g9 = ase_screenPosNorm.xy;
				float2 localUnStereo22_g9 = UnStereo( UV22_g9 );
				float2 break64_g8 = localUnStereo22_g9;
				float clampDepth69_g8 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g8 = ( 1.0 - clampDepth69_g8 );
				#else
				float staticSwitch38_g8 = clampDepth69_g8;
				#endif
				float3 appendResult39_g8 = (float3(break64_g8.x , break64_g8.y , staticSwitch38_g8));
				float4 appendResult42_g8 = (float4((appendResult39_g8*2.0 + -1.0) , 1.0));
				float4 temp_output_43_0_g8 = mul( unity_CameraInvProjection, appendResult42_g8 );
				float3 temp_output_46_0_g8 = ( (temp_output_43_0_g8).xyz / (temp_output_43_0_g8).w );
				float3 In72_g8 = temp_output_46_0_g8;
				float3 localInvertDepthDir72_g8 = InvertDepthDir72_g8( In72_g8 );
				float4 appendResult49_g8 = (float4(localInvertDepthDir72_g8 , 1.0));
				float4 Edge74 = ( step( distance( mul( unity_CameraToWorld, appendResult49_g8 ) , float4( WorldPosition , 0.0 ) ) , _EdgeWidth ) * _EdgeColor * _EdgeIntensity );
				float4 FinalColor19 = ( ( simpleNoise26 * _FracColor * temp_output_17_0 * frac( ( ( texCoord1.x * 10.0 ) + mulTime4 ) ) * ( 1.0 - texCoord53.x ) ) + Edge74 );
				float Noise23 = temp_output_17_0;
				float4 appendResult18 = (float4((FinalColor19).rgb , ( 0.1 * Noise23 )));
				
				
				finalColor = appendResult18;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
110.2857;422.8571;1907.429;459;1396.128;-237.061;1;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;13;-1748.731,1135.003;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;12;-1716.731,1007.003;Inherit;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;33;-1960.072,-128.5176;Inherit;False;Constant;_Float4;Float 4;1;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;62;-930.2405,1083.972;Inherit;False;Reconstruct World Position From Depth;-1;;8;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;63;-776.2405,1176.972;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1524.731,1007.003;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1764.731,831.0031;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1540.143,109.7857;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;30;-1794.072,-59.51758;Inherit;False;Constant;_Vector2;Vector 2;1;0;Create;True;0;0;0;False;0;False;-1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;29;-1814.072,-125.5176;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1512.731,278.0031;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1528.731,373.0031;Inherit;False;Constant;_Float10;Float 10;6;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-482.8109,1260.254;Inherit;False;Property;_EdgeWidth;EdgeWidth;2;0;Create;True;0;0;0;False;0;False;0.1;1.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;64;-552.2405,1092.972;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;79;-340.7648,1101.254;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1348.731,355.0031;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1718.072,-250.5176;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;73;-291.817,1287.767;Inherit;False;Property;_EdgeColor;EdgeColor;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;2,1.005236,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1300.731,195.0031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1638.072,-123.5176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-1412.731,847.0031;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-232.2161,1538.325;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;3;0;Create;True;0;0;0;False;0;False;0;6.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1375.072,-136.5176;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-1124.731,227.0031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1360.072,-247.5176;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;16;-1220.731,863.0031;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-8.309152,1111.568;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-1222.338,606.7942;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-1029.731,363.0031;Inherit;False;Property;_FracColor;FracColor;0;1;[HDR];Create;True;0;0;0;False;0;False;0.4678838,0.6840086,0.9433962,0;19.36664,28.1326,38.93715,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;8;-929.0724,221.2796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;54;-992.766,636.9688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;174.9633,1107.664;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;17;-1003.199,857.6017;Inherit;False;Random Range;-1;;7;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;26;-1171.072,-225.5176;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-616.7314,227.0031;Inherit;False;5;5;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-605.7806,454.0715;Inherit;False;74;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-385.5334,223.9086;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-151.4202,221.3952;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-727.0724,890.4824;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;322.9276,431.4824;Inherit;False;23;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;315.6267,219.6902;Inherit;False;19;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;315.6267,338.6902;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;497.6267,220.6902;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;501.9276,356.4825;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;739.6267,262.6902;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1110.2,427;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/TAProScan;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;LightMode=ForwardBase;Queue=Transparent=Queue=0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;0;1;True;False;;False;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;29;0;33;0
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;79;0;64;0
WireConnection;79;1;80;0
WireConnection;4;0;10;0
WireConnection;5;0;1;1
WireConnection;5;1;3;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;15;0;11;0
WireConnection;15;1;14;0
WireConnection;6;0;5;0
WireConnection;6;1;4;0
WireConnection;28;0;27;0
WireConnection;28;1;31;0
WireConnection;16;0;15;0
WireConnection;70;0;79;0
WireConnection;70;1;73;0
WireConnection;70;2;81;0
WireConnection;8;0;6;0
WireConnection;54;0;53;1
WireConnection;74;0;70;0
WireConnection;17;1;16;0
WireConnection;26;0;28;0
WireConnection;26;1;32;0
WireConnection;9;0;26;0
WireConnection;9;1;7;0
WireConnection;9;2;17;0
WireConnection;9;3;8;0
WireConnection;9;4;54;0
WireConnection;45;0;9;0
WireConnection;45;1;75;0
WireConnection;19;0;45;0
WireConnection;23;0;17;0
WireConnection;22;0;20;0
WireConnection;25;0;21;0
WireConnection;25;1;24;0
WireConnection;18;0;22;0
WireConnection;18;3;25;0
WireConnection;0;0;18;0
ASEEND*/
//CHKSM=6851EB2AF54D3E53B915C3995142584311C679F2