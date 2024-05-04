// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/WaterShield02"
{
	Properties
	{
		_Distort("Distort", Float) = 1
		_Power("Power", Float) = 0
		_Speed_Line("Speed_Line", Vector) = (-0.01,0,0,0)
		_Speed_Distort("Speed_Distort", Vector) = (0.2,0,0,0)
		_UVScale("UVScale", Float) = 3
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Fresnel_BSP("Fresnel_BSP", Vector) = (0,0,0,0)
		_AlphaFresnel_BSP("AlphaFresnel_BSP", Vector) = (0,0,0,0)
		_Num("Num", Float) = 0
		[HDR]_FresnelColor("FresnelColor", Color) = (1,1,1,0)
		_Offset("Offset", Float) = 0
		_HeightWhite("HeightWhite", Float) = 0.51
		_Color0("Color 0", Color) = (0.531544,0.883347,0.9150943,0)
		_Color1("Color 1", Color) = (0.531544,0.883347,0.9150943,0)
		_Alpha("Alpha", Range( 0 , 1)) = 0

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
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color0;
			uniform float4 _Color1;
			uniform float2 _Speed_Line;
			uniform sampler2D _TextureSample1;
			uniform float2 _Speed_Distort;
			uniform float _UVScale;
			uniform float _Distort;
			uniform float _Num;
			uniform float _Offset;
			uniform float _Power;
			uniform float3 _Fresnel_BSP;
			uniform float4 _FresnelColor;
			uniform float _HeightWhite;
			uniform float _Alpha;
			uniform float3 _AlphaFresnel_BSP;

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.vertex;
				
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
				float2 texCoord33 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner135 = ( 1.0 * _Time.y * _Speed_Line + texCoord33);
				float2 texCoord43 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break55 = ( texCoord43 * _UVScale );
				float2 appendResult53 = (float2(break55.x , ( break55.x + break55.y )));
				float2 panner60 = ( 1.0 * _Time.y * _Speed_Distort + appendResult53);
				float FlowNoiseDistort196 = ( tex2D( _TextureSample1, panner60 ).r * ( _Distort * 0.01 ) );
				float2 break40 = ( panner135 + FlowNoiseDistort196 );
				float Strip199 = pow( saturate( sin( ( ( ( break40.x + break40.y ) * _Num ) + _Offset ) ) ) , _Power );
				float4 lerpResult137 = lerp( _Color0 , _Color1 , Strip199);
				float temp_output_117_0 = ( Strip199 - 0.1 );
				clip( temp_output_117_0 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV144 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode144 = ( _Fresnel_BSP.x + _Fresnel_BSP.y * pow( max( 1.0 - fresnelNdotV144 , 0.0001 ), _Fresnel_BSP.z ) );
				float4 Fresnel148 = ( saturate( fresnelNode144 ) * _FresnelColor );
				clip( i.ase_texcoord3.xyz.y );
				float fresnelNdotV163 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode163 = ( _AlphaFresnel_BSP.x + _AlphaFresnel_BSP.y * pow( max( 1.0 - fresnelNdotV163 , 0.0001 ), _AlphaFresnel_BSP.z ) );
				float Alpha204 = saturate( ( _Alpha - saturate( fresnelNode163 ) ) );
				float4 appendResult141 = (float4(( lerpResult137 + step( temp_output_117_0 , 0.1 ) + Fresnel148 + step( i.ase_texcoord3.xyz.y , _HeightWhite ) ).rgb , Alpha204));
				
				
				finalColor = appendResult141;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;0;2194.286;1173.286;3812.444;-90.72034;1.750071;True;False
Node;AmplifyShaderEditor.CommentaryNode;198;-3807.177,-547.61;Inherit;False;2066.152;510.8136;FlowNoiseDistort;14;43;51;50;55;52;53;61;48;60;140;139;105;47;196;FlowNoiseDistort;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3691.489,-351.3557;Inherit;False;Property;_UVScale;UVScale;4;0;Create;True;0;0;0;False;0;False;3;11.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-3757.177,-495.4384;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-3501.177,-479.4384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;55;-3339.177,-470.4384;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-3165.177,-411.4387;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-2941.177,-479.4384;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;61;-2990.318,-324.6951;Inherit;False;Property;_Speed_Distort;Speed_Distort;3;0;Create;True;0;0;0;False;0;False;0.2,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;60;-2756.177,-479.4384;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2579.177,-256.4385;Inherit;False;Property;_Distort;Distort;0;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-2602.802,-155.5107;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;105;-2556.177,-493.4384;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;fd5160c546c4f9449a5708faddd6591c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-2404.802,-249.5108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;201;-3859.235,22.23899;Inherit;False;2445.583;782.8401;Strip;16;35;106;113;41;40;136;135;33;197;34;107;114;119;77;36;199;Strip;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2161.535,-441.1006;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-3809.235,72.23899;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;136;-3799.783,193.1905;Inherit;False;Property;_Speed_Line;Speed_Line;2;0;Create;True;0;0;0;False;0;False;-0.01,0;-0.05,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-1975.026,-485.61;Inherit;False;FlowNoiseDistort;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-3492.273,321.5715;Inherit;False;196;FlowNoiseDistort;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;135;-3487.783,152.1905;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-3226.812,258.2765;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;40;-3066.813,251.2765;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;107;-2892.876,396.0765;Inherit;False;Property;_Num;Num;8;0;Create;True;0;0;0;False;0;False;0;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2886.813,263.2765;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-2682.679,319.2668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-2817.747,534.0707;Inherit;False;Property;_Offset;Offset;10;0;Create;True;0;0;0;False;0;False;0;28.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-2506.886,417.2847;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;206;-2755.316,1387.258;Inherit;False;1363.698;473.5347;Alpha;7;162;163;142;161;160;157;204;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;168;-2534.246,897.9424;Inherit;False;1085.194;429.5924;Fresnel;6;143;144;146;145;147;148;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;35;-2320.173,434.8883;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;162;-2705.316,1677.936;Inherit;False;Property;_AlphaFresnel_BSP;AlphaFresnel_BSP;7;0;Create;True;0;0;0;False;0;False;0,0,0;0,2,10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;77;-2134.095,617.3649;Inherit;False;Property;_Power;Power;1;0;Create;True;0;0;0;False;0;False;0;7.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;143;-2484.246,955.9893;Inherit;False;Property;_Fresnel_BSP;Fresnel_BSP;6;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;119;-2156.132,445.8719;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;144;-2248.864,949.9533;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-1935.305,477.2981;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;163;-2461.696,1659.934;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-1673.081,484.7357;Inherit;False;Strip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;146;-2097.979,1121.963;Inherit;False;Property;_FresnelColor;FresnelColor;9;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;145;-2003.424,947.9423;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-2482.6,1437.258;Inherit;False;Property;_Alpha;Alpha;14;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;161;-2223.495,1669.888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;165;-1030.793,428.347;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;109;-1045.08,-338.5485;Inherit;False;Property;_Color0;Color 0;12;0;Create;True;0;0;0;False;0;False;0.531544,0.883347,0.9150943,0;0.382749,0.925383,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;164;-982.4886,587.9827;Inherit;False;Property;_HeightWhite;HeightWhite;11;0;Create;True;0;0;0;False;0;False;0.51;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;138;-1048.503,-160.4853;Inherit;False;Property;_Color1;Color 1;13;0;Create;True;0;0;0;False;0;False;0.531544,0.883347,0.9150943,0;0.3999998,0.6470588,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;200;-1124.625,112.2518;Inherit;False;199;Strip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;160;-2085.462,1540.931;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-1834.432,947.9423;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-1103.823,210.4371;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;157;-1860.223,1453.532;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;137;-724.5034,-161.4853;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;-839.8228,134.4373;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-716.2111,256.3401;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;166;-743.065,443.2715;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-1672.482,963.0303;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-507.0847,297.9129;Inherit;False;148;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;120;-500.2107,123.3401;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;116;-540.8228,-63.56279;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;167;-510.8721,439.2068;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;-1615.047,1451.54;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-229.2108,90.3401;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;581.2667,209.8768;Inherit;False;204;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;808.2097,82.72358;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1047.617,75.26893;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/WaterShield02;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;50;0;43;0
WireConnection;50;1;51;0
WireConnection;55;0;50;0
WireConnection;52;0;55;0
WireConnection;52;1;55;1
WireConnection;53;0;55;0
WireConnection;53;1;52;0
WireConnection;60;0;53;0
WireConnection;60;2;61;0
WireConnection;105;1;60;0
WireConnection;139;0;48;0
WireConnection;139;1;140;0
WireConnection;47;0;105;1
WireConnection;47;1;139;0
WireConnection;196;0;47;0
WireConnection;135;0;33;0
WireConnection;135;2;136;0
WireConnection;41;0;135;0
WireConnection;41;1;197;0
WireConnection;40;0;41;0
WireConnection;34;0;40;0
WireConnection;34;1;40;1
WireConnection;106;0;34;0
WireConnection;106;1;107;0
WireConnection;113;0;106;0
WireConnection;113;1;114;0
WireConnection;35;0;113;0
WireConnection;119;0;35;0
WireConnection;144;1;143;1
WireConnection;144;2;143;2
WireConnection;144;3;143;3
WireConnection;36;0;119;0
WireConnection;36;1;77;0
WireConnection;163;1;162;1
WireConnection;163;2;162;2
WireConnection;163;3;162;3
WireConnection;199;0;36;0
WireConnection;145;0;144;0
WireConnection;161;0;163;0
WireConnection;160;0;142;0
WireConnection;160;1;161;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;157;0;160;0
WireConnection;137;0;109;0
WireConnection;137;1;138;0
WireConnection;137;2;200;0
WireConnection;117;0;200;0
WireConnection;117;1;118;0
WireConnection;166;0;165;2
WireConnection;166;1;164;0
WireConnection;148;0;147;0
WireConnection;120;0;117;0
WireConnection;120;1;121;0
WireConnection;116;0;137;0
WireConnection;116;1;117;0
WireConnection;167;0;166;0
WireConnection;167;1;165;2
WireConnection;204;0;157;0
WireConnection;122;0;116;0
WireConnection;122;1;120;0
WireConnection;122;2;149;0
WireConnection;122;3;167;0
WireConnection;141;0;122;0
WireConnection;141;3;205;0
WireConnection;0;0;141;0
ASEEND*/
//CHKSM=1EA71921F0431E817C700E8507A7F169E5353110