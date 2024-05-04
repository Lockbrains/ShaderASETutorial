// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Holo01"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		[HDR]_FracColor("FracColor", Color) = (0.4678838,0.6840086,0.9433962,0)
		_AlphaPowScale("AlphaPowScale", Vector) = (1,1,0,0)
		_TriggerValue("TriggerValue", Range( 0 , 1)) = 0
		[Toggle]_EnableAutoAnim("EnableAutoAnim", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
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

			uniform float _EnableAutoAnim;
			uniform float _TriggerValue;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _FracColor;
			uniform float2 _AlphaPowScale;
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
				float mulTime67 = _Time.y * 0.1;
				float2 temp_cast_0 = (( floor( ( ase_worldPos.y * 2.0 ) ) + frac( mulTime67 ) )).xx;
				float simpleNoise77 = SimpleNoise( temp_cast_0*100.0 );
				float3 VertexAnim98 = ( simpleNoise77 * float3(1,0,0) * 0.01 * 0.5 );
				float3 _Vector2 = float3(0,-0.03,0);
				float2 texCoord107 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g9 = dot( frac( texCoord107 ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g9 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g9 ) * 43758.55 ) ));
				float2 _Vector5 = float2(0,7);
				float2 _Vector6 = float2(0.5,0);
				float mulTime171 = _Time.y * 0.2;
				float temp_output_176_0 = ( frac( mulTime171 ) * 5.0 );
				float smoothstepResult179 = smoothstep( _Vector6.x , _Vector6.y , temp_output_176_0);
				float2 _Vector7 = float2(3,3.5);
				float smoothstepResult180 = smoothstep( _Vector7.x , _Vector7.y , temp_output_176_0);
				float lerpResult185 = lerp( smoothstepResult179 , smoothstepResult180 , step( 3.0 , temp_output_176_0 ));
				float TriggerValue137 = (( _EnableAutoAnim )?( lerpResult185 ):( _TriggerValue ));
				float lerpResult133 = lerp( _Vector5.x , _Vector5.y , TriggerValue137);
				float3 lerpResult112 = lerp( ( VertexAnim98 + v.vertex.xyz ) , _Vector2 , saturate( ( lerpResult10_g9 * lerpResult133 ) ));
				float3 FinalVertexAnim208 = lerpResult112;
				
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
				vertexValue = FinalVertexAnim208;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV5 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode5 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV5 , 0.0001 ), 5.0 ) );
				float3 hsvTorgb194 = HSVToRGB( float3(WorldPosition.x,1.0,1.0) );
				float2 texCoord23 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float dotResult4_g4 = dot( frac( ( texCoord23 + ( float2( 0,1 ) * _Time.y ) ) ) , float2( 12.9898,78.233 ) );
				float lerpResult10_g4 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g4 ) * 43758.55 ) ));
				float temp_output_25_0 = lerpResult10_g4;
				float4 FinalColor10 = ( float4( ( (tex2DNode1).rgb + ( saturate( fresnelNode5 ) * ( hsvTorgb194 * 10.0 ) ) ) , 0.0 ) + ( frac( ( ( WorldPosition.y * 2.0 ) + _Time.y ) ) * _FracColor * temp_output_25_0 ) );
				float4 BaseMap139 = tex2DNode1;
				float3 hsvTorgb145 = HSVToRGB( float3(frac( ( WorldPosition.y * 0.25 ) ),0.5,1.0) );
				float2 _Vector6 = float2(0.5,0);
				float mulTime171 = _Time.y * 0.2;
				float temp_output_176_0 = ( frac( mulTime171 ) * 5.0 );
				float smoothstepResult179 = smoothstep( _Vector6.x , _Vector6.y , temp_output_176_0);
				float2 _Vector7 = float2(3,3.5);
				float smoothstepResult180 = smoothstep( _Vector7.x , _Vector7.y , temp_output_176_0);
				float lerpResult185 = lerp( smoothstepResult179 , smoothstepResult180 , step( 3.0 , temp_output_176_0 ));
				float TriggerValue137 = (( _EnableAutoAnim )?( lerpResult185 ):( _TriggerValue ));
				float smoothstepResult142 = smoothstep( 0.0 , 0.2 , TriggerValue137);
				float4 lerpResult141 = lerp( FinalColor10 , ( BaseMap139 * float4( ( hsvTorgb145 * 5.0 ) , 0.0 ) ) , smoothstepResult142);
				float4 _Vector1 = float4(-3,4,0,0);
				float RandomNoise156 = temp_output_25_0;
				float Alpha100 = ( pow( saturate( (0.0 + (( i.ase_texcoord3.xyz.y * 100.0 ) - _Vector1.x) * (1.0 - 0.0) / (_Vector1.y - _Vector1.x)) ) , _AlphaPowScale.x ) * _AlphaPowScale.y * RandomNoise156 );
				float smoothstepResult202 = smoothstep( 0.0 , 1.0 , TriggerValue137);
				float lerpResult203 = lerp( Alpha100 , 0.1 , smoothstepResult202);
				float4 appendResult3 = (float4(lerpResult141.rgb , lerpResult203));
				float4 Color64 = appendResult3;
				float3 _Vector2 = float3(0,-0.03,0);
				float ClipDistance210 = distance( i.ase_texcoord3.xyz , _Vector2 );
				float2 _Vector4 = float2(0,7);
				float lerpResult135 = lerp( _Vector4.x , _Vector4.y , TriggerValue137);
				float Dissove214 = ( ClipDistance210 - ( lerpResult135 * 0.01 ) );
				clip( Dissove214 );
				
				
				finalColor = Color64;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;0;2194.286;1173.286;-269.2437;-1680.574;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;213;-1257.272,2752.065;Inherit;False;2020.741;860.0054;自动播放动画;15;188;189;207;183;171;175;178;184;187;182;176;186;136;185;190;自动播放动画;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;103;-1189.222,-146.9286;Inherit;False;1966.508;1549.385;FinalColor;31;10;19;139;17;8;6;4;18;156;14;1;15;25;11;199;16;195;5;20;30;194;26;191;193;192;13;21;23;29;28;27;FinalColor 颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-1207.272,2983.356;Inherit;False;Constant;_Float19;Float 19;7;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;27;-891.9424,1182.401;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;28;-923.9424,1312.401;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-705.9424,1181.401;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-949.6425,1013.301;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;104;-731.5907,1433.345;Inherit;False;1501.87;478.597;Alpha;11;86;91;85;90;92;96;94;95;84;100;157;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;171;-1025.374,2999.443;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-831.374,3116.443;Inherit;False;Constant;_Float18;Float 18;7;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-720.8712,1948.398;Inherit;False;1486.049;774.3147;VertexAnim;15;77;75;55;60;67;59;56;80;76;78;43;42;54;40;98;VertexAnim顶点动画;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-784.1849,722.508;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;13;-834.0869,562.5356;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;192;-1056.703,490.9158;Inherit;False;Constant;_Float15;Float 15;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;193;-1092.62,258.449;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;191;-1058.106,407.0032;Inherit;False;Constant;_Float16;Float 16;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;175;-824.374,2993.443;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-588.243,1032.602;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;84;-697.853,1511.393;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;86;-594.3194,1672.371;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-623.3738,3001.443;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;55;-670.8712,1998.398;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;182;-623.3738,3116.443;Inherit;False;Constant;_Vector6;Vector 6;7;0;Create;True;0;0;0;False;0;False;0.5,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.HSVToRGBNode;194;-825.5751,291.5813;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;217;822.1036,-143.3219;Inherit;False;2061.917;896.9708;最终颜色合成;24;148;147;146;150;145;155;152;138;143;142;9;151;141;140;144;149;200;201;101;204;202;203;3;64;最终颜色合成;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;189;-441.3737,3188.443;Inherit;False;239.1428;205.1428;Comment;1;180;回;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-541.2725,3497.356;Inherit;False;Constant;_Float20;Float 20;7;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;188;-430.3737,2877.443;Inherit;False;239.1428;205.1428;Comment;1;179;出;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;30;-399.9426,1039.401;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;5;-849.3171,110.9573;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;91;-438.3194,1706.371;Inherit;False;Constant;_Vector1;Vector 1;4;0;Create;True;0;0;0;False;0;False;-3,4,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;184;-631.2726,3277.356;Inherit;False;Constant;_Vector7;Vector 7;7;0;Create;True;0;0;0;False;0;False;3,3.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;195;-752.2484,437.8925;Inherit;False;Constant;_Float17;Float 17;7;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;16;-649.1281,800.9547;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-422.3194,1563.371;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-635.1335,2177.451;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-653.8829,2290.501;Inherit;False;Constant;_Float8;Float 8;4;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-606.53,645.8166;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-637.1429,-96.92859;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;8a93a81534b55164b904ca99971a774b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;186;-328.2724,3435.356;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;180;-391.3736,3238.443;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;144;872.1036,-41.97099;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;11;-527.3171,122.9573;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;885.1036,92.02917;Inherit;False;Constant;_Float12;Float 12;7;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;-532.607,272.9189;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-428.128,677.9547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;179;-380.3736,2927.443;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;90;-194.3193,1522.371;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;67;-479.3306,2274.538;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-470.6327,2041.051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;25;-212.9424,1032.401;Inherit;False;Random Range;-1;;4;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;1037.271,5.707068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-234.4718,105.9961;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;4;-311.1429,10.07141;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;18;-254.1278,782.9547;Inherit;False;Property;_FracColor;FracColor;1;1;[HDR];Create;True;0;0;0;False;0;False;0.4678838,0.6840086,0.9433962,0;0.4678838,0.6840086,0.9433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;185;-152.2726,3155.356;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-103.7166,2802.065;Inherit;False;Property;_TriggerValue;TriggerValue;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;14;-227.0869,641.5356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;96;12.90675,1616.296;Inherit;False;Property;_AlphaPowScale;AlphaPowScale;2;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FloorOpNode;56;-326.4127,2044.181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;80;-286.2853,2258.806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;92;36.68018,1505.371;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;11.20167,1040.087;Inherit;False;RandomNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-161.0408,2072.687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;43.81589,-32.18889;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;147;1189.104,6.02909;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;152.1018,1733.209;Inherit;False;156;RandomNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;94;202.9066,1505.296;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-287.9928,2388.597;Inherit;False;Constant;_Float6;Float 6;3;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;207;440.0403,2940.89;Inherit;False;273.4285;164.7144;自动播放动画;1;137;自动播放动画;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;190;197.9575,2988.827;Inherit;False;Property;_EnableAutoAnim;EnableAutoAnim;4;0;Create;True;0;0;0;False;0;False;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;1152.93,210.6863;Inherit;False;Constant;_Float11;Float 11;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;1151.527,84.37172;Inherit;False;Constant;_Float13;Float 13;7;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;216;830.0306,805.4103;Inherit;False;1363.339;939.9509;FinalVertexAnim;16;107;109;110;111;99;116;117;114;112;133;134;158;120;125;210;208;出现与消失 FinalVertexAnim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;67.87218,642.9547;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;32.83917,2499.824;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;880.0306,1359.981;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;77;40.10725,2056.697;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;367.9065,1507.296;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;54;-49.60209,2310.36;Inherit;False;Constant;_Vector3;Vector 3;3;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;43;95.09101,2607.997;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;212;833.629,1802.731;Inherit;False;968.509;472.5156;距离裁剪;8;211;129;130;127;135;159;132;214;距离裁剪;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;267.4503,-39.07381;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-301.637,-91.5361;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;145;1375.097,-11.72321;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;111;1223.917,1026.411;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;155;1430.733,134.6448;Inherit;False;Constant;_Float14;Float 14;7;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;120;1242.084,1185.297;Inherit;False;Constant;_Vector2;Vector 2;5;0;Create;True;0;0;0;False;0;False;0,-0.03,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;490.04,2990.89;Inherit;False;TriggerValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;1743.701,544.8901;Inherit;False;137;TriggerValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;985.5098,1630.648;Inherit;False;137;TriggerValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;109;1103.732,1365.081;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;134;1018.083,1497.516;Inherit;False;Constant;_Vector5;Vector 5;6;0;Create;True;0;0;0;False;0;False;0,7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;159;883.6289,2140.44;Inherit;False;137;TriggerValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;132;966.9955,1961.019;Inherit;False;Constant;_Vector4;Vector 4;6;0;Create;True;0;0;0;False;0;False;0,7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;143;1414.8,379.1013;Inherit;False;Constant;_Float10;Float 10;7;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;125;1657.614,1134.786;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;1606.571,62.89245;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;393.4726,2165.298;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;1344.37,267.0573;Inherit;False;137;TriggerValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;476.7698,-46.73002;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;200;1785.131,638.934;Inherit;False;Constant;_Float22;Float 22;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;549.8505,1514.345;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;1686.398,-33.81766;Inherit;False;139;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;133;1271.555,1511.879;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;142;1601.8,274.1025;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;1841.878,350.5721;Inherit;False;100;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;541.7488,2168.502;Inherit;False;VertexAnim;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;1852.227,1121.855;Inherit;False;ClipDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;1906.746,-93.32191;Inherit;False;10;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;1955.954,-1.600297;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;110;1257.732,1354.081;Inherit;False;Random Range;-1;;9;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;202;1946.131,545.9353;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;1120.996,2135.02;Inherit;False;Constant;_Float9;Float 9;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;1770.987,442.5864;Inherit;False;Constant;_Float23;Float 23;8;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;135;1136.996,1976.018;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;1466.917,1390.411;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;1275.997,2072.017;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;203;2122.987,374.5866;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;1159.522,1852.731;Inherit;False;210;ClipDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;141;2123.397,-4.817702;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;1210.329,898.3854;Inherit;False;98;VertexAnim;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;1535.204,895.2992;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;127;1436.958,1917.008;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;117;1621.917,1392.411;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;2421.353,1.794843;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;112;1737.917,908.4103;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;1598.458,1920.372;Inherit;False;Dissove;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;2660.591,6.716598;Inherit;False;Color;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;1960.228,897.8537;Inherit;False;FinalVertexAnim;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;1057.997,2451.675;Inherit;False;214;Dissove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;1060.311,2378.346;Inherit;False;64;Color;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClipNode;126;1306.9,2377.946;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;1295.366,2505.924;Inherit;False;208;FinalVertexAnim;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1584.78,2379.146;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Holo01;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;0;1;True;False;;False;0
WireConnection;29;0;27;0
WireConnection;29;1;28;0
WireConnection;171;0;183;0
WireConnection;175;0;171;0
WireConnection;26;0;23;0
WireConnection;26;1;29;0
WireConnection;176;0;175;0
WireConnection;176;1;178;0
WireConnection;194;0;193;1
WireConnection;194;1;191;0
WireConnection;194;2;192;0
WireConnection;30;0;26;0
WireConnection;85;0;84;2
WireConnection;85;1;86;0
WireConnection;20;0;13;2
WireConnection;20;1;21;0
WireConnection;186;0;187;0
WireConnection;186;1;176;0
WireConnection;180;0;176;0
WireConnection;180;1;184;1
WireConnection;180;2;184;2
WireConnection;11;0;5;0
WireConnection;199;0;194;0
WireConnection;199;1;195;0
WireConnection;15;0;20;0
WireConnection;15;1;16;0
WireConnection;179;0;176;0
WireConnection;179;1;182;1
WireConnection;179;2;182;2
WireConnection;90;0;85;0
WireConnection;90;1;91;1
WireConnection;90;2;91;2
WireConnection;67;0;75;0
WireConnection;59;0;55;2
WireConnection;59;1;60;0
WireConnection;25;1;30;0
WireConnection;148;0;144;2
WireConnection;148;1;149;0
WireConnection;6;0;11;0
WireConnection;6;1;199;0
WireConnection;4;0;1;0
WireConnection;185;0;179;0
WireConnection;185;1;180;0
WireConnection;185;2;186;0
WireConnection;14;0;15;0
WireConnection;56;0;59;0
WireConnection;80;0;67;0
WireConnection;92;0;90;0
WireConnection;156;0;25;0
WireConnection;76;0;56;0
WireConnection;76;1;80;0
WireConnection;8;0;4;0
WireConnection;8;1;6;0
WireConnection;147;0;148;0
WireConnection;94;0;92;0
WireConnection;94;1;96;1
WireConnection;190;0;136;0
WireConnection;190;1;185;0
WireConnection;17;0;14;0
WireConnection;17;1;18;0
WireConnection;17;2;25;0
WireConnection;77;0;76;0
WireConnection;77;1;78;0
WireConnection;95;0;94;0
WireConnection;95;1;96;2
WireConnection;95;2;157;0
WireConnection;19;0;8;0
WireConnection;19;1;17;0
WireConnection;139;0;1;0
WireConnection;145;0;147;0
WireConnection;145;1;150;0
WireConnection;145;2;146;0
WireConnection;137;0;190;0
WireConnection;109;0;107;0
WireConnection;125;0;111;0
WireConnection;125;1;120;0
WireConnection;152;0;145;0
WireConnection;152;1;155;0
WireConnection;40;0;77;0
WireConnection;40;1;54;0
WireConnection;40;2;42;0
WireConnection;40;3;43;0
WireConnection;10;0;19;0
WireConnection;100;0;95;0
WireConnection;133;0;134;1
WireConnection;133;1;134;2
WireConnection;133;2;158;0
WireConnection;142;0;138;0
WireConnection;142;2;143;0
WireConnection;98;0;40;0
WireConnection;210;0;125;0
WireConnection;151;0;140;0
WireConnection;151;1;152;0
WireConnection;110;1;109;0
WireConnection;202;0;201;0
WireConnection;202;2;200;0
WireConnection;135;0;132;1
WireConnection;135;1;132;2
WireConnection;135;2;159;0
WireConnection;116;0;110;0
WireConnection;116;1;133;0
WireConnection;129;0;135;0
WireConnection;129;1;130;0
WireConnection;203;0;101;0
WireConnection;203;1;204;0
WireConnection;203;2;202;0
WireConnection;141;0;9;0
WireConnection;141;1;151;0
WireConnection;141;2;142;0
WireConnection;114;0;99;0
WireConnection;114;1;111;0
WireConnection;127;0;211;0
WireConnection;127;1;129;0
WireConnection;117;0;116;0
WireConnection;3;0;141;0
WireConnection;3;3;203;0
WireConnection;112;0;114;0
WireConnection;112;1;120;0
WireConnection;112;2;117;0
WireConnection;214;0;127;0
WireConnection;64;0;3;0
WireConnection;208;0;112;0
WireConnection;126;0;65;0
WireConnection;126;1;215;0
WireConnection;0;0;126;0
WireConnection;0;1;209;0
ASEEND*/
//CHKSM=EBA5AB5BBC731AEB7A5098C18303C0AA538A73F7