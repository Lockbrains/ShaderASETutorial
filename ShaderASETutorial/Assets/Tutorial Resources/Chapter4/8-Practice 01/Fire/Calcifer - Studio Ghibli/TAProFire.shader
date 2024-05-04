// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/FireBoy"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_F1("F1", 2D) = "white" {}
		_F2("F2", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,1,0,0)
		_Speed2("Speed2", Vector) = (0,1,0,0)
		[HDR]_Color0("Color 0", Color) = (1,0.7346639,0.19407,0)
		_Distort("Distort", Range( 0 , 1)) = 0
		_F_BSP("F_BSP", Vector) = (0,1,5,0)
		[HDR]_FresnelColor("FresnelColor", Color) = (1,0.9668399,0.7601078,0)
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
			uniform sampler2D _F1;
			uniform float2 _Speed;
			uniform float4 _F1_ST;
			uniform sampler2D _F2;
			uniform float2 _Speed2;
			uniform float _Distort;
			uniform float4 _Color0;
			uniform float3 _F_BSP;
			uniform float4 _FresnelColor;

			
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
				float2 uv_F1 = i.ase_texcoord1.xy * _F1_ST.xy + _F1_ST.zw;
				float2 panner4 = ( 1.0 * _Time.y * _Speed + uv_F1);
				float2 panner23 = ( 1.0 * _Time.y * _Speed2 + uv_F1);
				float4 Fire8 = ( tex2D( _F1, ( float4( panner4, 0.0 , 0.0 ) + ( tex2D( _F2, panner23 ) * _Distort ) ).rg ) * _Color0 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV27 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode27 = ( _F_BSP.x + _F_BSP.y * pow( max( 1.0 - fresnelNdotV27 , 0.0001 ), _F_BSP.z ) );
				float4 Fresnel31 = ( saturate( fresnelNode27 ) * _FresnelColor );
				
				
				finalColor = ( tex2D( _MainTex, uv_MainTex ) + Fire8 + Fresnel31 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;0;2194.286;1173.286;291.8927;-104.5394;1;True;False
Node;AmplifyShaderEditor.Vector2Node;22;-1617.303,269.8456;Inherit;False;Property;_Speed2;Speed2;4;0;Create;True;0;0;0;False;0;False;0,1;0,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-1673.405,135.5456;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;23;-1394.303,156.8454;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;18;-1191.303,127.8455;Inherit;True;Property;_F2;F2;2;0;Create;True;0;0;0;False;0;False;-1;204234db0461926498b7e7a5bb427c4a;a7352af7756e7ae44a5129d97b4de8bd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;6;-1099.318,-18.71818;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;0;False;0;False;0,1;0,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1171.391,-144.2683;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1170.833,325.9079;Inherit;False;Property;_Distort;Distort;6;0;Create;True;0;0;0;False;0;False;0;0.24;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;4;-876.3184,-131.7182;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-861.5776,125.5586;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;28;-784.9091,771.571;Inherit;False;Property;_F_BSP;F_BSP;7;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;27;-573.6554,758.142;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-642.5654,-119.6307;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;30;-366.9091,937.571;Inherit;False;Property;_FresnelColor;FresnelColor;8;1;[HDR];Create;True;0;0;0;False;0;False;1,0.9668399,0.7601078,0;2.996078,1.410895,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-429.0977,97.61988;Inherit;False;Property;_Color0;Color 0;5;1;[HDR];Create;True;0;0;0;False;0;False;1,0.7346639,0.19407,0;5.992157,0.8784314,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;33;-306.2754,799.8881;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-505.7525,-122.0495;Inherit;True;Property;_F1;F1;1;0;Create;True;0;0;0;False;0;False;-1;204234db0461926498b7e7a5bb427c4a;204234db0461926498b7e7a5bb427c4a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-55.90906,791.571;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-127.298,-109.2476;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;142.8838,797.4321;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;137.2276,-113.1409;Inherit;False;Fire;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;1016.655,610.1682;Inherit;False;8;Fire;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;1025.514,694.3718;Inherit;False;31;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;901.3484,393.1072;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;c4b950a06066aa54abf604b4e80c28e9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;568.2171,620.306;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;1305.655,548.1683;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1523.795,568.2336;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/FireBoy;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;23;0;20;0
WireConnection;23;2;22;0
WireConnection;18;1;23;0
WireConnection;4;0;5;0
WireConnection;4;2;6;0
WireConnection;25;0;18;0
WireConnection;25;1;26;0
WireConnection;27;1;28;1
WireConnection;27;2;28;2
WireConnection;27;3;28;3
WireConnection;24;0;4;0
WireConnection;24;1;25;0
WireConnection;33;0;27;0
WireConnection;3;1;24;0
WireConnection;29;0;33;0
WireConnection;29;1;30;0
WireConnection;16;0;3;0
WireConnection;16;1;17;0
WireConnection;31;0;29;0
WireConnection;8;0;16;0
WireConnection;9;0;1;0
WireConnection;9;1;10;0
WireConnection;9;2;32;0
WireConnection;0;0;9;0
ASEEND*/
//CHKSM=812388FC8072993F6F91ADA5529581FAEDC8169E