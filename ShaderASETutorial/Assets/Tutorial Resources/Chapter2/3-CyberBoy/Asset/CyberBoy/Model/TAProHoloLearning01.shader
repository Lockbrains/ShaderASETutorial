// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/HoloLearning01"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_FracColor("FracColor", Color) = (0.4865229,0.9017716,1,0)
		_TriggerValue1("TriggerValue", Range( 0 , 1)) = 0
		[Toggle]_EnableAutoAnim1("EnableAutoAnim", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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

			uniform float _EnableAutoAnim1;
			uniform float _TriggerValue1;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _FracColor;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 _TargetPos = float3(-11.001,0.29,-0.133);
				float2 texCoord102 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g8 = dot( texCoord102 , float2( 12.9898,78.233 ) );
				float lerpResult10_g8 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g8 ) * 43758.55 ) ));
				float2 _Vector2 = float2(0,10);
				float2 _Vector7 = float2(0.5,0);
				float mulTime146 = _Time.y * 0.2;
				float temp_output_149_0 = ( frac( mulTime146 ) * 5.0 );
				float smoothstepResult150 = smoothstep( _Vector7.x , _Vector7.y , temp_output_149_0);
				float2 _Vector8 = float2(3,3.5);
				float smoothstepResult155 = smoothstep( _Vector8.x , _Vector8.y , temp_output_149_0);
				float lerpResult156 = lerp( smoothstepResult150 , smoothstepResult155 , step( 3.0 , temp_output_149_0 ));
				float Trigger119 = (( _EnableAutoAnim1 )?( lerpResult156 ):( _TriggerValue1 ));
				float lerpResult123 = lerp( _Vector2.x , _Vector2.y , Trigger119);
				float3 lerpResult96 = lerp( ase_worldPos , _TargetPos , saturate( ( lerpResult10_g8 * lerpResult123 ) ));
				float3 worldToObj100 = mul( unity_WorldToObject, float4( lerpResult96, 1 ) ).xyz;
				float3 VertexAnim299 = worldToObj100;
				
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
				vertexValue = VertexAnim299;
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
				float4 BaseMap5 = tex2D( _MainTex, uv_MainTex );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV6 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode6 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV6 , 0.0001 ), 5.0 ) );
				float2 _Vector7 = float2(0.5,0);
				float mulTime146 = _Time.y * 0.2;
				float temp_output_149_0 = ( frac( mulTime146 ) * 5.0 );
				float smoothstepResult150 = smoothstep( _Vector7.x , _Vector7.y , temp_output_149_0);
				float2 _Vector8 = float2(3,3.5);
				float smoothstepResult155 = smoothstep( _Vector8.x , _Vector8.y , temp_output_149_0);
				float lerpResult156 = lerp( smoothstepResult150 , smoothstepResult155 , step( 3.0 , temp_output_149_0 ));
				float Trigger119 = (( _EnableAutoAnim1 )?( lerpResult156 ):( _TriggerValue1 ));
				float smoothstepResult133 = smoothstep( 0.0 , 0.1 , Trigger119);
				float SmothTriggerValue136 = smoothstepResult133;
				float lerpResult138 = lerp( 1.0 , 0.5 , SmothTriggerValue136);
				float3 hsvTorgb15 = HSVToRGB( float3(frac( ( WorldPosition.x * 0.8 ) ),lerpResult138,1.0) );
				float3 RainbowColor22 = hsvTorgb15;
				float4 Color10 = ( BaseMap5 + float4( ( saturate( fresnelNode6 ) * ( RainbowColor22 * 10.0 ) ) , 0.0 ) + ( frac( ( ( WorldPosition.y * 2.0 ) + _Time.y ) ) * _FracColor ) );
				float4 lerpResult132 = lerp( Color10 , ( BaseMap5 * float4( RainbowColor22 , 0.0 ) ) , smoothstepResult133);
				float2 texCoord42 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime45 = _Time.y * 0.02;
				float dotResult4_g1 = dot( frac( ( texCoord42 + mulTime45 ) ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Noise47 = lerpResult10_g1;
				float4 appendResult2 = (float4((lerpResult132).rgb , Noise47));
				float2 _Vector1 = float2(20,0);
				float lerpResult120 = lerp( _Vector1.x , _Vector1.y , Trigger119);
				float3 _TargetPos = float3(-11.001,0.29,-0.133);
				float ClipDistance109 = distance( WorldPosition , _TargetPos );
				float DiscardDistance116 = ( lerpResult120 - ClipDistance109 );
				clip( DiscardDistance116 );
				
				
				finalColor = appendResult2;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
206.2857;556.5715;1926.857;676.7143;4586.55;-3138.161;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;144;-5420.134,3418.809;Inherit;False;Constant;_Float20;Float 19;7;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;146;-5256.235,3432.896;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;147;-5073.235,3415.896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-5081.235,3522.896;Inherit;False;Constant;_Float19;Float 18;7;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;143;-4682.235,3638.896;Inherit;False;239.1428;205.1428;Comment;1;155;回;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;142;-4673.235,3313.896;Inherit;False;239.1428;205.1428;Comment;1;150;出;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;151;-4871.345,3528.951;Inherit;False;Constant;_Vector7;Vector 6;7;0;Create;True;0;0;0;False;0;False;0.5,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-4885.235,3431.896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;152;-4866.134,3702.809;Inherit;False;Constant;_Vector8;Vector 7;7;0;Create;True;0;0;0;False;0;False;3,3.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;154;-4750.134,3926.809;Inherit;False;Constant;_Float21;Float 20;7;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;155;-4633.29,3678.346;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;150;-4619.235,3372.896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;153;-4584.683,3878.37;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;156;-4392.134,3593.809;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-4331.347,3266.33;Inherit;False;Property;_TriggerValue1;TriggerValue;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;157;-3961.904,3443.28;Inherit;False;Property;_EnableAutoAnim1;EnableAutoAnim;4;0;Create;True;0;0;0;False;0;False;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-3563.163,3380.61;Inherit;False;Trigger;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-264.3292,124.0619;Inherit;False;Constant;_Float12;Float 12;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-311.1731,-57.51045;Inherit;False;119;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-268.3292,28.06186;Inherit;False;Constant;_Float13;Float 13;4;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;133;27.67079,-35.93811;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-3929.735,-496.0807;Inherit;False;1240.559;412.4044;RainbowColor;7;22;21;27;26;20;15;28;RainbowColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-3816.732,-273.0803;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;21;-3879.734,-448.6615;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;270.3297,-44.78461;Inherit;False;SmothTriggerValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-3660.611,-21.24431;Inherit;False;Constant;_Float14;Float 14;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-3660.61,-132.4767;Inherit;False;Constant;_Float15;Float 15;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-3767.646,67.95138;Inherit;False;136;SmothTriggerValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-3581.731,-379.0805;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;138;-3426.604,-36.98505;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-3355.993,-371.4732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-3414.001,-198.3904;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;31;-2544.001,-486.833;Inherit;False;1537.743;1493.363;Color;21;9;10;14;13;37;8;7;24;5;33;38;23;25;4;34;6;39;35;36;40;32;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;32;-2484.483,530.0862;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.HSVToRGBNode;15;-3165.875,-348.8586;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;36;-2440.483,787.0862;Inherit;False;Constant;_Float4;Float 4;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2439.222,682.07;Inherit;False;Constant;_Float5;Float 5;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2222.222,603.07;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;35;-2296.483,748.0862;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-2912.6,-346.5094;Inherit;False;RainbowColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;6;-2494.001,-74.8331;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2031.483,659.0862;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2244.729,376.2593;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-2289.562,274.2593;Inherit;False;22;RainbowColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;4;-1974.314,-435.2658;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;8a93a81534b55164b904ca99971a774b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;59;-2469.036,1056.309;Inherit;False;1460.419;375.3453;Noise;7;46;45;42;44;57;41;47;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;38;-1973.483,775.0862;Inherit;False;Property;_FracColor;FracColor;1;0;Create;True;0;0;0;False;0;False;0.4865229,0.9017716,1,0;0.2279656,0.5008879,0.5188676,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-2043.562,279.2593;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;7;-2218.001,-65.8331;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;33;-1873.483,587.0862;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2419.036,1288.309;Inherit;False;Constant;_Float6;Float 6;2;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-1236.533,-418.2833;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1693.483,594.0862;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1754.001,27.16689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;98;-2816.571,2462.911;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;95;-2827.289,2617.115;Inherit;False;Constant;_TargetPos;TargetPos;2;0;Create;True;0;0;0;False;0;False;-11.001,0.29,-0.133;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;124;-3204.446,3137.377;Inherit;False;119;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-3230.708,2799.483;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;45;-2230.036,1296.309;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;122;-3206.446,3004.377;Inherit;False;Constant;_Vector2;Vector 2;5;0;Create;True;0;0;0;False;0;False;0,10;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1797.001,-147.8331;Inherit;False;5;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-2288.036,1106.309;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;108;-2367.987,2446.227;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;104;-2958.875,2789.114;Inherit;True;Random Range;-1;;8;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1524.001,24.16689;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-1985.036,1176.309;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;123;-2919.446,3035.377;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-2046.233,2427.544;Inherit;False;ClipDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-3187.734,3552.906;Inherit;False;119;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;115;-3145.979,3383.27;Inherit;False;Constant;_Vector1;Vector 1;4;0;Create;True;0;0;0;False;0;False;20,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;57;-1755.254,1173.742;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-2645.351,2831.885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-1188.314,-31.82851;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-287.6353,-283.1775;Inherit;False;22;RainbowColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-243.6354,-376.1774;Inherit;False;5;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-2690.979,3557.27;Inherit;False;109;ClipDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;120;-2932.734,3397.906;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;19.33351,-350.5668;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;13.56749,-462.2966;Inherit;False;10;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;41;-1561.203,1178.94;Inherit;True;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;-2505.351,2811.885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;-2441.976,3447.27;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1232.045,1178.606;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;96;-2255.289,2562.115;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;132;345.2794,-339.9042;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;658.104,-149.4327;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-2173.32,3435.543;Inherit;False;DiscardDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;12;705.557,-298.7857;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;100;-2039.835,2553.485;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-1699.677,2574.94;Inherit;False;VertexAnim2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;964.752,-44.3425;Inherit;False;116;DiscardDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;94;-3231.12,1487.858;Inherit;False;2232.806;727.2832;VertexAnimH;17;75;81;80;79;76;74;88;93;87;92;78;64;63;66;62;65;67;VertexAnimH;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;967.5575,-321.7857;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FloorOpNode;76;-2847.12,1849.062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-3963.163,3285.61;Inherit;False;Property;_TriggerValue;TriggerValue;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2069.452,2100.426;Inherit;False;Constant;_Float7;Float 7;2;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;110;1278.171,-189.4076;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;62;-2041.063,1537.858;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;66;-1515.596,1614.447;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;81;-3157.589,1917.03;Inherit;False;Constant;_Float9;Float 9;2;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1805.709,1542.519;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-3432.396,-283.1775;Inherit;False;Constant;_Float10;Float 10;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;1054.846,270.6498;Inherit;False;99;VertexAnim2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;75;-3181.12,1777.062;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1221.742,1619.219;Inherit;False;VertexAnimH;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-2472.66,2037.043;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;-5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;74;-3021.786,1680.543;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;64;-2140.592,1921.924;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;141;-300.7213,-197.1222;Inherit;False;Constant;_Float16;Float 2;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-2718.188,1817.161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-2216.001,22.16689;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;0.4064486,0.9056604,0.8498753,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2983.354,1850.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;92;-2274.66,1868.044;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;87;-2588.821,1802.119;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-3175.025,1678.895;Inherit;False;Constant;_Float8;Float 8;2;0;Create;True;0;0;0;False;0;False;1.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1899.591,1784.923;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1623.137,-159.4385;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/HoloLearning01;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;LightMode=ForwardBase;Queue=Transparent=Queue=0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;0;1;True;False;;False;0
WireConnection;146;0;144;0
WireConnection;147;0;146;0
WireConnection;149;0;147;0
WireConnection;149;1;148;0
WireConnection;155;0;149;0
WireConnection;155;1;152;1
WireConnection;155;2;152;2
WireConnection;150;0;149;0
WireConnection;150;1;151;1
WireConnection;150;2;151;2
WireConnection;153;0;154;0
WireConnection;153;1;149;0
WireConnection;156;0;150;0
WireConnection;156;1;155;0
WireConnection;156;2;153;0
WireConnection;157;0;145;0
WireConnection;157;1;156;0
WireConnection;119;0;157;0
WireConnection;133;0;126;0
WireConnection;133;1;134;0
WireConnection;133;2;135;0
WireConnection;136;0;133;0
WireConnection;26;0;21;1
WireConnection;26;1;27;0
WireConnection;138;0;140;0
WireConnection;138;1;139;0
WireConnection;138;2;137;0
WireConnection;28;0;26;0
WireConnection;15;0;28;0
WireConnection;15;1;138;0
WireConnection;15;2;20;0
WireConnection;39;0;32;2
WireConnection;39;1;40;0
WireConnection;35;0;36;0
WireConnection;22;0;15;0
WireConnection;34;0;39;0
WireConnection;34;1;35;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;7;0;6;0
WireConnection;33;0;34;0
WireConnection;5;0;4;0
WireConnection;37;0;33;0
WireConnection;37;1;38;0
WireConnection;8;0;7;0
WireConnection;8;1;24;0
WireConnection;45;0;46;0
WireConnection;108;0;98;0
WireConnection;108;1;95;0
WireConnection;104;1;102;0
WireConnection;14;0;13;0
WireConnection;14;1;8;0
WireConnection;14;2;37;0
WireConnection;44;0;42;0
WireConnection;44;1;45;0
WireConnection;123;0;122;1
WireConnection;123;1;122;2
WireConnection;123;2;124;0
WireConnection;109;0;108;0
WireConnection;57;0;44;0
WireConnection;105;0;104;0
WireConnection;105;1;123;0
WireConnection;10;0;14;0
WireConnection;120;0;115;1
WireConnection;120;1;115;2
WireConnection;120;2;121;0
WireConnection;129;0;128;0
WireConnection;129;1;127;0
WireConnection;41;1;57;0
WireConnection;107;0;105;0
WireConnection;112;0;120;0
WireConnection;112;1;111;0
WireConnection;47;0;41;0
WireConnection;96;0;98;0
WireConnection;96;1;95;0
WireConnection;96;2;107;0
WireConnection;132;0;11;0
WireConnection;132;1;129;0
WireConnection;132;2;133;0
WireConnection;116;0;112;0
WireConnection;12;0;132;0
WireConnection;100;0;96;0
WireConnection;99;0;100;0
WireConnection;2;0;12;0
WireConnection;2;3;52;0
WireConnection;76;0;80;0
WireConnection;110;0;2;0
WireConnection;110;1;117;0
WireConnection;66;0;65;0
WireConnection;65;0;62;0
WireConnection;65;1;63;0
WireConnection;67;0;66;0
WireConnection;74;0;79;0
WireConnection;88;0;74;0
WireConnection;88;1;76;0
WireConnection;80;0;75;2
WireConnection;80;1;81;0
WireConnection;92;0;87;0
WireConnection;92;1;93;0
WireConnection;87;0;88;0
WireConnection;63;0;92;0
WireConnection;63;1;64;0
WireConnection;63;2;78;0
WireConnection;0;0;110;0
WireConnection;0;1;68;0
ASEEND*/
//CHKSM=54BC04E8F1CD09860957161C117037BF0F4B57B1