// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAProRainbow"
{
	Properties
	{
		_New_Graph_output_1("New_Graph_output_1", 2D) = "white" {}
		_New_Graph_output("New_Graph_output", 2D) = "white" {}
		_New_Graph_output_2("New_Graph_output_2", 2D) = "white" {}
		_New_Graph_output_3("New_Graph_output_3", 2D) = "white" {}
		_New_Graph_output_4("New_Graph_output_4", 2D) = "white" {}
		_Noise1("Noise1", 2D) = "white" {}
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
			float3 pal( in float t, in float3 a, in float3 b, in float3 c, in float3 d )  {     return a + b*cos( 6.28318*(c*t+d) ); }  float3 spectrum(float n)  {     return pal( n, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.33,0.67) ); }


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _New_Graph_output_1;
			uniform float4 _New_Graph_output_1_ST;
			uniform sampler2D _New_Graph_output;
			uniform float4 _New_Graph_output_ST;
			uniform sampler2D _New_Graph_output_2;
			uniform float4 _New_Graph_output_2_ST;
			uniform sampler2D _New_Graph_output_3;
			uniform float4 _New_Graph_output_3_ST;
			uniform sampler2D _New_Graph_output_4;
			uniform float4 _New_Graph_output_4_ST;
			uniform sampler2D _Noise1;
			uniform float4 _Noise1_ST;

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

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
				float2 uv_New_Graph_output_1 = i.ase_texcoord1.xy * _New_Graph_output_1_ST.xy + _New_Graph_output_1_ST.zw;
				float2 uv_New_Graph_output = i.ase_texcoord1.xy * _New_Graph_output_ST.xy + _New_Graph_output_ST.zw;
				float2 uv_New_Graph_output_2 = i.ase_texcoord1.xy * _New_Graph_output_2_ST.xy + _New_Graph_output_2_ST.zw;
				float4 appendResult17 = (float4(tex2D( _New_Graph_output_1, uv_New_Graph_output_1 ).r , tex2D( _New_Graph_output, uv_New_Graph_output ).g , tex2D( _New_Graph_output_2, uv_New_Graph_output_2 ).b , 0.0));
				float2 uv_New_Graph_output_3 = i.ase_texcoord1.xy * _New_Graph_output_3_ST.xy + _New_Graph_output_3_ST.zw;
				float2 uv_New_Graph_output_4 = i.ase_texcoord1.xy * _New_Graph_output_4_ST.xy + _New_Graph_output_4_ST.zw;
				float2 uv_Noise1 = i.ase_texcoord1.xy * _Noise1_ST.xy + _Noise1_ST.zw;
				
				
				finalColor = ( appendResult17 + ( float4( ( 1.0 - float3(1,0,0) ) , 0.0 ) * tex2D( _New_Graph_output_3, uv_New_Graph_output_3 ) ) + ( float4( ( 1.0 - float3(1,0,0) ) , 0.0 ) * tex2D( _New_Graph_output_4, uv_New_Graph_output_4 ) ) + ( float4( ( 1.0 - float3(1,0,0) ) , 0.0 ) * tex2D( _Noise1, uv_Noise1 ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
2196.952;797.3333;2193.333;756.3334;816.0858;-1083.966;1.43444;True;False
Node;AmplifyShaderEditor.Vector3Node;33;-516.1395,1952.616;Inherit;False;Constant;_Vector2;Vector 2;6;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;30;-553.2737,1557.551;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;18;-563.1594,1153.454;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;14;-648.6874,1719.338;Inherit;True;Property;_New_Graph_output_4;New_Graph_output_4;4;0;Create;True;0;0;0;False;0;False;-1;f9150adb31b2e84418619b5f1a3771e4;f9150adb31b2e84418619b5f1a3771e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-712.8389,629.7422;Inherit;True;Property;_New_Graph_output;New_Graph_output;1;0;Create;True;0;0;0;False;0;False;-1;ced377b925ea0da478a552cfd5729bae;ced377b925ea0da478a552cfd5729bae;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;32;-326.1394,1983.616;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;29;-363.2737,1588.551;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;10;-722.3428,399.7107;Inherit;True;Property;_New_Graph_output_1;New_Graph_output_1;0;0;Create;True;0;0;0;False;0;False;-1;fd7ff4f2aef30e84f88cac91d1c7e58f;fd7ff4f2aef30e84f88cac91d1c7e58f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-718.3428,833.7107;Inherit;True;Property;_New_Graph_output_2;New_Graph_output_2;2;0;Create;True;0;0;0;False;0;False;-1;b54de772c34bfcd4aa73a507abe2b247;b54de772c34bfcd4aa73a507abe2b247;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-669.6874,1360.338;Inherit;True;Property;_New_Graph_output_3;New_Graph_output_3;3;0;Create;True;0;0;0;False;0;False;-1;4950aaafd14859f418c3be482daf6b19;4950aaafd14859f418c3be482daf6b19;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;21;-373.1594,1184.454;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;15;-635.6874,2097.338;Inherit;True;Property;_Noise1;Noise1;5;0;Create;True;0;0;0;False;0;False;-1;5ee3819fcd34c214384a5039ad522270;5ee3819fcd34c214384a5039ad522270;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-177.1594,1234.454;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;17;-183.3428,792.7107;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-167.274,1638.551;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-130.1394,2033.616;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-632.1429,-63.35715;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;8;188.3679,-210.3374;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;9;-74.63208,134.6626;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;2;-183.1429,-150.3571;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;6;-50.63208,-305.3374;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-199.6321,-243.3374;Inherit;False;Constant;_Float2;Float 2;0;0;Create;True;0;0;0;False;0;False;2.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;5;-297.1429,-357.3571;Inherit;False;Spectrum;-1;;1;9861418a7d5878e47bc200122ef6217e;0;1;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-523.1429,211.6429;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-506.1429,92.64285;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;154.4794,1739.297;Inherit;True;4;4;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;481.5927,1775.675;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAProRainbow;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;32;0;33;0
WireConnection;29;0;30;0
WireConnection;21;0;18;0
WireConnection;27;0;21;0
WireConnection;27;1;13;0
WireConnection;17;0;10;1
WireConnection;17;1;11;2
WireConnection;17;2;12;3
WireConnection;28;0;29;0
WireConnection;28;1;14;0
WireConnection;31;0;32;0
WireConnection;31;1;15;0
WireConnection;8;0;6;0
WireConnection;8;1;2;0
WireConnection;8;2;9;0
WireConnection;9;0;1;2
WireConnection;2;0;1;1
WireConnection;2;1;3;0
WireConnection;2;2;4;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;5;1;1;1
WireConnection;34;0;17;0
WireConnection;34;1;27;0
WireConnection;34;2;28;0
WireConnection;34;3;31;0
WireConnection;0;0;34;0
ASEEND*/
//CHKSM=A8CD1FAA4FF870DDF2B4A79E7BC7710A88043A15