// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/WaterShield"
{
	Properties
	{
		_BaseColor("BaseColor", Color) = (0.3813253,0.7826313,0.8679245,0)
		_Alpha("Alpha", Range( 0 , 1)) = 0.25
		_Fresnel_BSP("Fresnel_BSP", Vector) = (0,0,0,0)
		[HDR]_FresnelColor("FresnelColor", Color) = (1,1,1,0)
		_ViewLight_PS("ViewLight_PS", Vector) = (0,0,0,0)
		[HDR]_ViewLightColor("ViewLightColor", Color) = (0,0,0,0)
		_Float0("Float 0", Float) = 0.51

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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

			uniform float4 _BaseColor;
			uniform float3 _Fresnel_BSP;
			uniform float4 _FresnelColor;
			uniform float2 _ViewLight_PS;
			uniform float4 _ViewLightColor;
			uniform float _Float0;
			uniform float _Alpha;

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
				float fresnelNdotV24 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode24 = ( _Fresnel_BSP.x + _Fresnel_BSP.y * pow( max( 1.0 - fresnelNdotV24 , 0.0001 ), _Fresnel_BSP.z ) );
				float4 Fresnel28 = ( saturate( fresnelNode24 ) * _FresnelColor );
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float dotResult34 = dot( normalizedWorldNormal , ase_worldViewDir );
				float4 ViewLight42 = ( ( pow( saturate( dotResult34 ) , _ViewLight_PS.x ) * _ViewLight_PS.y ) * _ViewLightColor );
				clip( i.ase_texcoord2.xyz.y );
				float4 appendResult22 = (float4(( _BaseColor + Fresnel28 + ViewLight42 + ( 4.0 * step( i.ase_texcoord2.xyz.y , _Float0 ) ) ).rgb , _Alpha));
				
				
				finalColor = appendResult22;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;0;2194.286;1173.286;709.4058;821.5656;1.278673;True;False
Node;AmplifyShaderEditor.CommentaryNode;49;-707.1899,1201.442;Inherit;False;1360.429;425.5717;ViewLight;10;33;32;34;35;39;36;37;41;40;42;ViewLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;32;-657.1899,1251.442;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;33;-630.1899,1411.442;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;50;-430.0266,736.6007;Inherit;False;1083.703;429.5931;Fresnel;6;30;24;25;26;27;28;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;34;-408.1899,1286.442;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;39;-306.1899,1370.442;Inherit;False;Property;_ViewLight_PS;ViewLight_PS;4;0;Create;True;0;0;0;False;0;False;0,0;2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;35;-288.1899,1288.442;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;30;-380.0266,794.6481;Inherit;False;Property;_Fresnel_BSP;Fresnel_BSP;2;0;Create;True;0;0;0;False;0;False;0,0,0;0,1.45,13.49;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;36;-111.1899,1275.442;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;24;-144.6446,788.6124;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;51;-528.6213,166.7205;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;26;48.24007,947.6224;Inherit;False;Property;_FresnelColor;FresnelColor;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;3.031433,3.031433,3.031433,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;25;100.7954,786.6008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-18.18991,1411.442;Inherit;False;Property;_ViewLightColor;ViewLightColor;5;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0.4417119,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;53.81009,1288.442;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-475.7461,437.316;Inherit;False;Property;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.51;0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-215.0331,93.83572;Inherit;False;Constant;_Float4;Float 4;10;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;52;-225.0174,295.1603;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;214.8101,1287.442;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;269.787,786.601;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;430.248,797.6895;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-34.45133,135.8438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;429.8101,1289.442;Inherit;False;ViewLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;55;159.4138,192.6044;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;243.1958,-83.9441;Inherit;False;28;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;257.1205,50.79274;Inherit;False;42;ViewLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;14;212.7578,-288.9554;Inherit;False;Property;_BaseColor;BaseColor;0;0;Create;True;0;0;0;False;0;False;0.3813253,0.7826313,0.8679245,0;0.09291529,0.3579536,0.5943396,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;19;693.5586,-163.8322;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;23;835.5865,76.64809;Inherit;False;Property;_Alpha;Alpha;1;0;Create;True;0;0;0;False;0;False;0.25;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;1290.271,-68.88118;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1499.388,-99.17268;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/WaterShield;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;35;0;34;0
WireConnection;36;0;35;0
WireConnection;36;1;39;1
WireConnection;24;1;30;1
WireConnection;24;2;30;2
WireConnection;24;3;30;3
WireConnection;25;0;24;0
WireConnection;37;0;36;0
WireConnection;37;1;39;2
WireConnection;52;0;51;2
WireConnection;52;1;58;0
WireConnection;40;0;37;0
WireConnection;40;1;41;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;28;0;27;0
WireConnection;57;0;56;0
WireConnection;57;1;52;0
WireConnection;42;0;40;0
WireConnection;55;0;57;0
WireConnection;55;1;51;2
WireConnection;19;0;14;0
WireConnection;19;1;31;0
WireConnection;19;2;43;0
WireConnection;19;3;55;0
WireConnection;22;0;19;0
WireConnection;22;3;23;0
WireConnection;0;0;22;0
ASEEND*/
//CHKSM=6282758C5693F5CB28A46AAB60DB42DA2DAE0928