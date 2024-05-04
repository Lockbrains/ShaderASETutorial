// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA102/CyberBoy"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_MetallicMap("MetallicMap", 2D) = "white" {}
		_RoughnessMap("RoughnessMap", 2D) = "white" {}
		[Toggle(_REVERTV_ON)] _RevertV("RevertV", Float) = 0
		_AoMap("AoMap", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _REVERTV_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _Global_MaxHeight;
		uniform float _Global_DissoveValue;
		uniform float4 _Global_DissoveDir;
		uniform sampler2D _NormalMap;
		uniform sampler2D _MainTex;
		uniform float _Global_HighlightRange;
		uniform sampler2D _MetallicMap;
		uniform sampler2D _RoughnessMap;
		uniform sampler2D _AoMap;
		uniform float4 _AoMap_ST;


		float GetHighlightRange43( float ypos, float baseHeight, float range )
		{
			if(ypos>baseHeight-range*0.5&&ypos<baseHeight+range*0.5)
			    return 1;
			return 0;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float temp_output_18_0 = ( _Global_DissoveValue * 0.1 );
			float lerpResult23 = lerp( _Global_MaxHeight , 0.0 , step( ase_vertex3Pos.y , temp_output_18_0 ));
			float3 temp_output_25_0 = ( lerpResult23 * (_Global_DissoveDir).xyz );
			v.vertex.xyz += temp_output_25_0;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult9 = (float2(i.uv_texcoord.x , ( 1.0 - i.uv_texcoord.y )));
			#ifdef _REVERTV_ON
				float2 staticSwitch10 = appendResult9;
			#else
				float2 staticSwitch10 = i.uv_texcoord;
			#endif
			o.Normal = UnpackNormal( tex2D( _NormalMap, staticSwitch10 ) );
			o.Albedo = tex2D( _MainTex, staticSwitch10 ).rgb;
			float4 color34 = IsGammaSpace() ? float4(0,0.3624921,1,0) : float4(0,0.1080812,1,0);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float ypos43 = ase_vertex3Pos.y;
			float temp_output_18_0 = ( _Global_DissoveValue * 0.1 );
			float baseHeight43 = temp_output_18_0;
			float range43 = _Global_HighlightRange;
			float localGetHighlightRange43 = GetHighlightRange43( ypos43 , baseHeight43 , range43 );
			o.Emission = ( color34 * 10.0 * localGetHighlightRange43 ).rgb;
			o.Metallic = tex2D( _MetallicMap, staticSwitch10 ).r;
			o.Smoothness = tex2D( _RoughnessMap, staticSwitch10 ).r;
			float2 uv_AoMap = i.uv_texcoord * _AoMap_ST.xy + _AoMap_ST.zw;
			o.Occlusion = tex2D( _AoMap, uv_AoMap ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
38.85714;317.1429;1737.714;856.1429;905.719;-977.4095;1.757188;True;True
Node;AmplifyShaderEditor.RangedFloatNode;17;-832.8768,1873.123;Inherit;False;Global;_Global_DissoveValue;_Global_DissoveValue;9;0;Create;True;0;0;0;False;0;False;0;0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-746.8768,1947.123;Inherit;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1548.429,122.0714;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;8;-1335.429,208.0714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;15;-691.8768,1648.123;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-591.8768,1880.123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-694.6754,1438.134;Inherit;False;Global;_Global_HighlightRange;_Global_HighlightRange;9;0;Create;True;0;0;0;False;0;False;0;0.002;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;91.88481,1530.099;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;50.24928,1370.135;Inherit;False;Global;_Global_MaxHeight;_Global_MaxHeight;9;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;32;124.4144,1825.72;Inherit;False;Global;_Global_DissoveDir;_Global_DissoveDir;9;0;Create;True;0;0;0;False;0;False;0,1,0,0;0,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;9;-1173.429,169.0714;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;16;-275.6873,1847.223;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;264.5769,868.5749;Inherit;False;Constant;_Color0;Color 0;9;1;[HDR];Create;True;0;0;0;False;0;False;0,0.3624921,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;43;-306.4915,1351.522;Inherit;False;if(ypos>baseHeight-range*0.5&&ypos<baseHeight+range*0.5)$    return 1@$return 0@;1;False;3;True;ypos;FLOAT;0;In;;Inherit;False;True;baseHeight;FLOAT;0;In;;Inherit;False;True;range;FLOAT;0;In;;Inherit;False;GetHighlightRange;True;False;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;215.9899,1037.486;Inherit;False;Constant;_Float3;Float 3;9;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;296.9581,1556.868;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;33;374.2492,1768.135;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;10;-1015.429,115.0714;Inherit;False;Property;_RevertV;RevertV;4;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-602.4286,-42.92859;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;c53cbe87c1f7e6d4285efc482695ef6f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-642.4286,630.0714;Inherit;True;Property;_MetallicMap;MetallicMap;2;0;Create;True;0;0;0;False;0;False;-1;None;791af0cb35761774db719bcb83cd17de;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;67;621.9161,2069.808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;65;435.9161,1999.808;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-629.9485,1089.011;Inherit;True;Property;_AoMap;AoMap;5;0;Create;True;0;0;0;False;0;False;-1;None;0af9167f43a2fd14b9e292579c75575d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;69;752.9161,1989.808;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;5;-639.9184,842.416;Inherit;True;Property;_RoughnessMap;RoughnessMap;3;0;Create;True;0;0;0;False;0;False;-1;None;116af217fa68e3b459a2e74f192308b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;64;951.9161,2002.808;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;570.2148,1002.962;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;66;601.9161,2278.808;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-626.4286,166.0714;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;c7b784fc2cb0e5243a3a88b87264c362;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;162.7339,2214.432;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;574.9579,1320.868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;76;1231.005,2163.193;Inherit;True;RandomNoiseWithTime;-1;;1;89dbdb40ebccca846ad1944d230cfa63;0;2;1;FLOAT2;1,0;False;15;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;63;972.8538,1822.899;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;1029.304,2255.283;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;1023.207,2361.536;Inherit;False;Constant;_Float6;Float 6;6;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;68;432.9161,2200.808;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;843.0052,2178.193;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;313.0052,2258.193;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;163.0052,2319.193;Inherit;False;Constant;_Float7;Float 7;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;1295.588,1909.15;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;1186.564,1414.075;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1458.544,986.0164;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TA102/CyberBoy;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;7;2
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;9;0;7;1
WireConnection;9;1;8;0
WireConnection;16;0;15;2
WireConnection;16;1;18;0
WireConnection;43;0;15;2
WireConnection;43;1;18;0
WireConnection;43;2;38;0
WireConnection;23;0;30;0
WireConnection;23;1;28;0
WireConnection;23;2;16;0
WireConnection;33;0;32;0
WireConnection;10;1;7;0
WireConnection;10;0;9;0
WireConnection;1;1;10;0
WireConnection;4;1;10;0
WireConnection;67;0;65;2
WireConnection;67;1;68;0
WireConnection;69;0;65;1
WireConnection;69;1;67;0
WireConnection;69;2;65;3
WireConnection;5;1;10;0
WireConnection;64;0;69;0
WireConnection;64;1;66;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;35;2;43;0
WireConnection;2;1;10;0
WireConnection;25;0;23;0
WireConnection;25;1;33;0
WireConnection;76;1;77;0
WireConnection;76;15;68;0
WireConnection;68;0;74;0
WireConnection;74;0;72;0
WireConnection;74;1;75;0
WireConnection;70;0;63;0
WireConnection;70;1;76;0
WireConnection;70;2;71;0
WireConnection;70;3;73;0
WireConnection;78;0;25;0
WireConnection;0;0;1;0
WireConnection;0;1;2;0
WireConnection;0;2;35;0
WireConnection;0;3;4;1
WireConnection;0;4;5;1
WireConnection;0;5;14;1
WireConnection;0;11;25;0
ASEEND*/
//CHKSM=0EA51434D0DE2FD131B522BE2FE1A07316D01ED8