// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Holo2_BodyOpaque"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		[HDR]_FracColor("FracColor", Color) = (0.4678838,0.6840086,0.9433962,0)
		_Noise("Noise", 2D) = "black" {}
		[Toggle]_DisableAnim("DisableAnim", Float) = 1
		[HDR]_Tint("Tint", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
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
			#define ASE_NEEDS_VERT_POSITION
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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _DisableAnim;
			uniform float4 _Global_TargetPos;
			uniform sampler2D _Noise;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _FracColor;
			uniform float4 _Tint;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float4 normalizeResult62 = normalize( ( float4( ase_worldPos , 0.0 ) - _Global_TargetPos ) );
				float2 texCoord91 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner90 = ( 1.0 * _Time.y * float2( 1,0 ) + texCoord91);
				float3 worldToObj59 = mul( unity_WorldToObject, float4( ( float4( ase_worldPos , 0.0 ) + ( normalizeResult62 * tex2Dlod( _Noise, float4( panner90, 0, 0.0) ) * 0.1 ) ).xyz, 1 ) ).xyz;
				float3 VertexAnim60 = worldToObj59;
				
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = (( _DisableAnim )?( v.vertex.xyz ):( VertexAnim60 ));
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
				float4 tex2DNode26 = tex2D( _MainTex, uv_MainTex );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV24 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode24 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV24 , 0.0001 ), 5.0 ) );
				float3 hsvTorgb103 = HSVToRGB( float3(WorldPosition.x,1.0,1.0) );
				float2 texCoord17 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g4 = dot( frac( ( texCoord17 + ( float2( 0,1 ) * _Time.y ) ) ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g4 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g4 ) * 43758.55 ) ));
				float temp_output_32_0 = lerpResult10_g4;
				float4 BaseColor40 = ( float4( ( (tex2DNode26).rgb + ( saturate( fresnelNode24 ) * ( hsvTorgb103 * 10.0 ) ) ) , 0.0 ) + ( frac( ( ( WorldPosition.y * 2.0 ) + _Time.y ) ) * _FracColor * temp_output_32_0 ) );
				float4 screenPos = i.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 ditherCustomScreenPos122 = ase_screenPosNorm;
				float2 clipScreen122 = ditherCustomScreenPos122.xy * _ScreenParams.xy;
				float dither122 = Dither8x8Bayer( fmod(clipScreen122.x, 8), fmod(clipScreen122.y, 8) );
				clip( ( dither122 - 0.7 ) );
				float4 FinalColor66 = BaseColor40;
				
				
				finalColor = ( FinalColor66 * _Tint );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;5.714286;2194.286;1167.572;-496.0883;741.494;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;2;-2681.878,-1045.095;Inherit;False;2624.514;1680.937;FinalColor;45;100;98;113;105;109;111;107;108;112;110;96;119;106;36;28;40;38;123;35;37;34;30;33;31;32;29;26;27;104;25;23;24;22;103;102;21;17;20;99;101;19;97;18;16;15;FinalColor 颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-1740.927,479.0078;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-1708.927,349.0078;Inherit;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;97;-2649.686,-379.818;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;99;-2338.859,-139.1609;Inherit;False;Constant;_Float11;Float 11;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;20;-1651.072,-270.8577;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1522.927,348.0078;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-1766.627,179.9078;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;101;-2340.262,-265.4759;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1578.514,-96.57672;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-1466.112,-32.43866;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;103;-2124.692,-367.5711;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1405.227,199.2079;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2061.055,-215.2025;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1423.514,-187.5767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;24;-1708.793,-699.0947;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;125;-2187.809,1262.178;Inherit;False;2037.323;766.0029;VertexAnim;14;91;95;92;61;90;62;94;89;93;68;69;59;60;56;VertexAnim;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;95;-2064.755,1462.675;Inherit;False;Global;_Global_TargetPos;_Global_TargetPos;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;18.36735,0.98,5.817314,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;29;-1216.927,206.0078;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;26;-1471.793,-995.0947;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;8a93a81534b55164b904ca99971a774b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;27;-1406.793,-700.0947;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-1245.112,-155.4387;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-2137.809,1722.248;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;92;-2104.809,1834.248;Inherit;False;Constant;_Vector3;Vector 3;6;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;56;-1912.8,1313.864;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1765.087,-450.867;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;30;-1097.793,-928.0947;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;90;-1871.809,1740.248;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-1705.958,1419.09;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;32;-1029.927,199.0078;Inherit;False;Random Range;-1;;4;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-1071.112,-50.43866;Inherit;False;Property;_FracColor;FracColor;2;1;[HDR];Create;True;0;0;0;False;0;False;0.4678838,0.6840086,0.9433962,0;0.4678838,0.6840086,0.9433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1181.793,-700.0947;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;33;-1044.072,-191.8577;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-749.1124,-190.4387;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;123;-495.0667,-224.9677;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-845.7928,-944.0947;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1444.364,1913.467;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;62;-1561.958,1414.09;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;89;-1588.809,1705.248;Inherit;True;Property;_Noise;Noise;4;0;Create;True;0;0;0;False;0;False;-1;None;7fecbba2d4465a84db893198a4f9a084;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;124;5.481811,-402.2345;Inherit;False;217.3333;182.4286;Ditther半透明;1;121;Ditther半透明;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-97.01212,-151.0247;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;122;-263.0945,-318.0519;Inherit;False;1;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;68;-1158.382,1312.178;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1188.808,1540.248;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-490.1124,-766.4385;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-885.3825,1463.179;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;121;54.4818,-352.2345;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-248.7928,-801.0947;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;59;-675.9137,1416.694;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClipNode;120;262.3203,-527.1747;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-373.9139,1410.694;Inherit;False;VertexAnim;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;516.5609,-527.8136;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;1612.397,-212.3072;Inherit;False;66;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;1328.289,143.1996;Inherit;False;60;VertexAnim;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;127;1548.088,-107.494;Inherit;False;Property;_Tint;Tint;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;118;1323.095,234.8601;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;3;-1558.012,646.2589;Inherit;False;1501.87;478.597;Alpha;11;14;13;12;11;10;9;8;7;6;5;4;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;111;-2249.287,89.52097;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;1790.088,-155.494;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-2285.461,294.178;Inherit;False;Constant;_Float8;Float 8;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;41;196.2843,-703.2542;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-2394.136,96.18236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2436.36,-422.3546;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;100;-2299.892,-426.2225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-674.3199,946.1228;Inherit;False;36;RandomNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;-1472.793,-535.0947;Inherit;False;Property;_FColor;FColor;1;1;[HDR];Create;True;0;0;0;False;0;False;0.4678838,0.6840086,0.9433962,0;0.5867553,8.124358,17.4149,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;113;-2567.288,198.5207;Inherit;False;Constant;_Float12;Float 12;7;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;107;-2596.288,53.52097;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1020.741,735.2849;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1420.741,885.2849;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;10;-789.7415,718.2849;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;4;-1524.275,724.3069;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-2286.864,167.8631;Inherit;False;Constant;_Float13;Float 13;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;116;1591.394,136.9229;Inherit;False;Property;_DisableAnim;DisableAnim;5;0;Create;True;0;0;0;False;0;False;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.HSVToRGBNode;109;-2071.294,65.76785;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;9;-813.515,829.2098;Inherit;False;Property;_AlphaPowScale;AlphaPowScale;3;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;108;-2007.657,218.1365;Inherit;False;Constant;_Float7;Float 7;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;6;-1264.741,919.2849;Inherit;False;Constant;_Vector2;Vector 2;4;0;Create;True;0;0;0;False;0;False;-3,4,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1711.689,-17.52805;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2620.686,-234.8183;Inherit;False;Constant;_Float9;Float 9;7;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-1115.287,-1047.702;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-276.5711,727.2589;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-384.4595,-472.0138;Inherit;False;36;RandomNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-458.5151,720.2098;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1248.741,776.2849;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;11;-623.5151,718.2098;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-811.3199,211.1228;Inherit;False;RandomNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2005.488,-185.3097;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Holo2_BodyOpaque;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;0;1;True;False;;False;0
WireConnection;19;0;16;0
WireConnection;19;1;15;0
WireConnection;103;0;97;1
WireConnection;103;1;101;0
WireConnection;103;2;99;0
WireConnection;23;0;17;0
WireConnection;23;1;19;0
WireConnection;21;0;20;2
WireConnection;21;1;18;0
WireConnection;29;0;23;0
WireConnection;27;0;24;0
WireConnection;25;0;21;0
WireConnection;25;1;22;0
WireConnection;104;0;103;0
WireConnection;104;1;102;0
WireConnection;30;0;26;0
WireConnection;90;0;91;0
WireConnection;90;2;92;0
WireConnection;61;0;56;0
WireConnection;61;1;95;0
WireConnection;32;1;29;0
WireConnection;34;0;27;0
WireConnection;34;1;104;0
WireConnection;33;0;25;0
WireConnection;37;0;33;0
WireConnection;37;1;31;0
WireConnection;37;2;32;0
WireConnection;35;0;30;0
WireConnection;35;1;34;0
WireConnection;62;0;61;0
WireConnection;89;1;90;0
WireConnection;122;2;123;0
WireConnection;93;0;62;0
WireConnection;93;1;89;0
WireConnection;93;2;94;0
WireConnection;38;0;35;0
WireConnection;38;1;37;0
WireConnection;69;0;68;0
WireConnection;69;1;93;0
WireConnection;121;0;122;0
WireConnection;121;1;42;0
WireConnection;40;0;38;0
WireConnection;59;0;69;0
WireConnection;120;0;40;0
WireConnection;120;1;121;0
WireConnection;60;0;59;0
WireConnection;66;0;120;0
WireConnection;111;0;112;0
WireConnection;126;0;67;0
WireConnection;126;1;127;0
WireConnection;41;0;40;0
WireConnection;41;3;42;0
WireConnection;112;0;107;1
WireConnection;112;1;113;0
WireConnection;98;0;97;1
WireConnection;98;1;96;0
WireConnection;100;0;98;0
WireConnection;8;0;7;0
WireConnection;8;1;6;1
WireConnection;8;2;6;2
WireConnection;10;0;8;0
WireConnection;116;0;65;0
WireConnection;116;1;118;0
WireConnection;109;0;111;0
WireConnection;109;1;105;0
WireConnection;109;2;106;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;39;0;26;0
WireConnection;14;0;13;0
WireConnection;13;0;11;0
WireConnection;13;1;9;2
WireConnection;13;2;12;0
WireConnection;7;0;4;2
WireConnection;7;1;5;0
WireConnection;11;0;10;0
WireConnection;11;1;9;1
WireConnection;36;0;32;0
WireConnection;0;0;126;0
WireConnection;0;1;116;0
ASEEND*/
//CHKSM=AB602CD6E0CF609D5C656167FE59AEBC9A4CDD40