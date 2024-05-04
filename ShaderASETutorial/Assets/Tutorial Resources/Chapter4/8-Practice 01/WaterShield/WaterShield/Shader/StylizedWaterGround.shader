// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/StylizedWaterGround"
{
	Properties
	{
		_normal_map_opengl("normal_map_opengl", 2D) = "bump" {}
		_render_map("render_map", 2D) = "white" {}
		_MainTexUVScale("MainTexUVScale", Float) = 1
		_Depth("Depth", Float) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseUVSpeed("NoiseUVSpeed", Vector) = (1,0,0,0)
		_Distort("Distort", Float) = 0
		_UVScale("UVScale", Float) = 10
		[HDR]_Color0("Color 0", Color) = (0.5997304,1,0.8859957,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
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
			#include "UnityStandardBRDF.cginc"
			#include "UnityShaderVariables.cginc"
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _normal_map_opengl;
			uniform float4 _normal_map_opengl_ST;
			uniform sampler2D _render_map;
			uniform float _MainTexUVScale;
			uniform float _Depth;
			uniform sampler2D _Noise;
			uniform float2 _NoiseUVSpeed;
			uniform float4 _Noise_ST;
			uniform float _Distort;
			uniform float4 _Color0;
			uniform sampler2D _TextureSample0;
			uniform float _UVScale;

			
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
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 uv_normal_map_opengl = i.ase_texcoord1.xy * _normal_map_opengl_ST.xy + _normal_map_opengl_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal7 = UnpackNormal( tex2D( _normal_map_opengl, uv_normal_map_opengl ) );
				float3 worldNormal7 = float3(dot(tanToWorld0,tanNormal7), dot(tanToWorld1,tanNormal7), dot(tanToWorld2,tanNormal7));
				float3 temp_output_5_0 = ( WorldPosition * _MainTexUVScale );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float2 temp_output_23_0 = (( temp_output_5_0 + ( -ase_worldViewDir * _Depth ) )).xz;
				float2 panner24 = ( 1.0 * _Time.y * _NoiseUVSpeed + ( (WorldPosition).xz * (_Noise_ST).xy ));
				float4 Ground11 = ( saturate( worldNormal7.y ) * tex2D( _render_map, ( float4( temp_output_23_0, 0.0 , 0.0 ) + ( tex2D( _Noise, panner24 ) * _Distort ) ).rg ) );
				float4 WaterBase43 = ( _Color0 * pow( tex2D( _TextureSample0, ( temp_output_23_0 * _UVScale ) ).r , 2.0 ) );
				float4 lerpResult42 = lerp( Ground11 , WaterBase43 , 0.75);
				
				
				finalColor = lerpResult42;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
94.85715;917.7144;1998.857;755.0001;1304.391;945.2404;1.320698;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-1174.164,-10.21071;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;20;-979.1647,29.78927;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1328.653,-207.9562;Inherit;False;Property;_MainTexUVScale;MainTexUVScale;3;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1003.365,119.1893;Inherit;False;Property;_Depth;Depth;4;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;18;-1318.84,-442.4765;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;34;-1472.919,363.0832;Inherit;False;Global;_Noise_ST;_Noise_ST;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;36;-1469.082,200.4672;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;35;-1257.02,359.4833;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;37;-1247.763,238.1383;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-816.1647,31.78927;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1043.524,-332.2607;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;25;-1032.135,386.248;Inherit;False;Property;_NoiseUVSpeed;NoiseUVSpeed;6;0;Create;True;0;0;0;False;0;False;1,0;0.1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-992.0203,258.2832;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-569.1647,-167.2107;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;24;-761.1213,289.0835;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-575.7102,771.9838;Inherit;False;Property;_UVScale;UVScale;9;0;Create;True;0;0;0;False;0;False;10;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;-443.1646,-171.2107;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-365.4209,420.6833;Inherit;False;Property;_Distort;Distort;7;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-514.8208,228.4834;Inherit;True;Property;_Noise;Noise;5;0;Create;True;0;0;0;False;0;False;-1;None;db083c5fd718f1c46aed88e1c8a08dcc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-439.3745,671.8602;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-38.37451,826.0031;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-393.2069,-481.0016;Inherit;True;Property;_normal_map_opengl;normal_map_opengl;0;0;Create;True;0;0;0;False;0;False;-1;d6bdec8d39ffae8418e28e6033c7c646;c0b61027ec303c94ca73a815bceec471;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-121.4209,170.6833;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;58;-263.3745,542.8602;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;df7f183d78894a94da0c978c0e1fdf05;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-44.61506,-131.369;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;56;202.6255,809.0031;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;7;23.85706,-457.7858;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;50;61.41875,417.9679;Inherit;False;Property;_Color0;Color 0;10;1;[HDR];Create;True;0;0;0;False;0;False;0.5997304,1,0.8859957,0;0.3631184,0.7053242,0.6107674,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;9;261.8571,-453.7858;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;122.8571,-185.7857;Inherit;True;Property;_render_map;render_map;2;0;Create;True;0;0;0;False;0;False;-1;53c8aa8a20ef7bd41b86923579e15645;8594ae486843fe146bab578273a50edf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;432.6255,704.0031;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;643.5629,714.8934;Inherit;False;WaterBase;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;421.8571,-366.7858;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;646.1504,-15.02213;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;0.75;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;594.5629,-114.1066;Inherit;False;43;WaterBase;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;625.9469,-363.728;Inherit;False;Ground;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;47;-887.5009,-399.3195;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;46;701.9495,154.2156;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-678.1372,-358.5466;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;45;448.9495,143.2156;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;906.4579,-286.212;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;42;888.1235,-170.0844;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-399.1429,-764.7858;Inherit;True;Property;_color_map;color_map;1;0;Create;True;0;0;0;False;0;False;-1;8569e28678f85fc4aacbc10827aeb345;8569e28678f85fc4aacbc10827aeb345;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-197.3745,944.0031;Inherit;False;Property;_WhiteRange;WhiteRange;8;0;Create;True;0;0;0;False;0;False;0;0.24;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-652.7102,632.9838;Inherit;False;39;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1147,-375;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/StylizedWaterGround;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;20;0;13;0
WireConnection;35;0;34;0
WireConnection;37;0;36;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;5;0;18;0
WireConnection;5;1;6;0
WireConnection;32;0;37;0
WireConnection;32;1;35;0
WireConnection;19;0;5;0
WireConnection;19;1;21;0
WireConnection;24;0;32;0
WireConnection;24;2;25;0
WireConnection;23;0;19;0
WireConnection;26;1;24;0
WireConnection;59;0;23;0
WireConnection;59;1;41;0
WireConnection;27;0;26;0
WireConnection;27;1;28;0
WireConnection;58;1;59;0
WireConnection;29;0;23;0
WireConnection;29;1;27;0
WireConnection;56;0;58;1
WireConnection;56;1;57;0
WireConnection;7;0;1;0
WireConnection;9;0;7;2
WireConnection;3;1;29;0
WireConnection;54;0;50;0
WireConnection;54;1;56;0
WireConnection;43;0;54;0
WireConnection;10;0;9;0
WireConnection;10;1;3;0
WireConnection;11;0;10;0
WireConnection;47;0;5;0
WireConnection;46;0;45;0
WireConnection;39;0;47;0
WireConnection;60;0;11;0
WireConnection;42;0;11;0
WireConnection;42;1;44;0
WireConnection;42;2;48;0
WireConnection;0;0;42;0
ASEEND*/
//CHKSM=7A197118D7CACACF583A8A5777B4BDD929EBD882