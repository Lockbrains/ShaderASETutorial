// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/CyberBoy-AnimFX02"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		[Toggle(_REVERTV_ON)] _RevertV("RevertV", Float) = 0

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
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#pragma shader_feature_local _REVERTV_ON


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

			uniform float4 _Global_VertexParam1;
			uniform sampler2D _MainTex;

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 _Vector2 = float3(0,0,0);
				float3 appendResult235 = (float3(_Vector2.x , ( _Vector2.y + ( 0.01 * 2.5 ) ) , _Vector2.z));
				float3 Center238 = appendResult235;
				float2 center45_g2 = Center238.xy;
				float2 delta6_g2 = ( (v.vertex.xyz).xy - center45_g2 );
				float4 VecParam226 = _Global_VertexParam1;
				float4 break231 = VecParam226;
				float RotStrength236 = break231.y;
				float Trigger237 = saturate( break231.x );
				float lerpResult148 = lerp( 0.0 , RotStrength236 , Trigger237);
				float angle10_g2 = ( length( delta6_g2 ) * lerpResult148 );
				float x23_g2 = ( ( cos( angle10_g2 ) * delta6_g2.x ) - ( sin( angle10_g2 ) * delta6_g2.y ) );
				float2 break40_g2 = center45_g2;
				float2 break41_g2 = float2( 0,0 );
				float y35_g2 = ( ( sin( angle10_g2 ) * delta6_g2.x ) + ( cos( angle10_g2 ) * delta6_g2.y ) );
				float2 appendResult44_g2 = (float2(( x23_g2 + break40_g2.x + break41_g2.x ) , ( break40_g2.y + break41_g2.y + y35_g2 )));
				float2 break137 = appendResult44_g2;
				float4 appendResult138 = (float4(break137.x , break137.y , v.vertex.xyz.z , 0.0));
				float4 TwirlPos215 = appendResult138;
				float4 lerpResult156 = lerp( float4( v.vertex.xyz , 0.0 ) , TwirlPos215 , Trigger237);
				float4 VertexAnim209 = lerpResult156;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = VertexAnim209.xyz;
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
				float2 texCoord7 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult9 = (float2(texCoord7.x , ( 1.0 - texCoord7.y )));
				#ifdef _REVERTV_ON
				float2 staticSwitch10 = appendResult9;
				#else
				float2 staticSwitch10 = texCoord7;
				#endif
				float4 color183 = IsGammaSpace() ? float4(0,5.2864,10.08297,0) : float4(0,38.98989,161.3967,0);
				float3 _Vector2 = float3(0,0,0);
				float3 appendResult235 = (float3(_Vector2.x , ( _Vector2.y + ( 0.01 * 2.5 ) ) , _Vector2.z));
				float3 Center238 = appendResult235;
				float2 center45_g2 = Center238.xy;
				float2 delta6_g2 = ( (i.ase_texcoord2.xyz).xy - center45_g2 );
				float4 VecParam226 = _Global_VertexParam1;
				float4 break231 = VecParam226;
				float RotStrength236 = break231.y;
				float Trigger237 = saturate( break231.x );
				float lerpResult148 = lerp( 0.0 , RotStrength236 , Trigger237);
				float angle10_g2 = ( length( delta6_g2 ) * lerpResult148 );
				float x23_g2 = ( ( cos( angle10_g2 ) * delta6_g2.x ) - ( sin( angle10_g2 ) * delta6_g2.y ) );
				float2 break40_g2 = center45_g2;
				float2 break41_g2 = float2( 0,0 );
				float y35_g2 = ( ( sin( angle10_g2 ) * delta6_g2.x ) + ( cos( angle10_g2 ) * delta6_g2.y ) );
				float2 appendResult44_g2 = (float2(( x23_g2 + break40_g2.x + break41_g2.x ) , ( break40_g2.y + break41_g2.y + y35_g2 )));
				float2 break137 = appendResult44_g2;
				float4 appendResult138 = (float4(break137.x , break137.y , i.ase_texcoord2.xyz.z , 0.0));
				float4 TwirlPos215 = appendResult138;
				float temp_output_173_0 = ( 1.0 - saturate( ( distance( float4( Center238 , 0.0 ) , TwirlPos215 ) / ( 7.0 * 0.01 ) ) ) );
				float Dis01207 = temp_output_173_0;
				float4 Emission205 = ( color183 * step( Dis01207 , ( Trigger237 + ( 0.5 * 0.01 ) ) ) );
				clip( temp_output_173_0 - Trigger237);
				float4 FinalEmission212 = Emission205;
				
				
				finalColor = ( tex2D( _MainTex, staticSwitch10 ) + FinalEmission212 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
-76;270.2857;2194.286;1173.286;2623.47;-2790.533;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;224;-1660.912,1546.474;Inherit;False;955.0511;969.8478;Comment;14;238;237;236;235;234;233;232;231;230;229;228;227;226;225;Param;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;225;-1158.496,1596.474;Inherit;False;Global;_Global_VertexParam1;_Global_VertexParam;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;226;-929.2898,1598.859;Inherit;False;VecParam;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-1516.758,2342.777;Inherit;False;226;VecParam;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-1599.463,2075.442;Inherit;False;Constant;_Float9;Float 8;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-1578.463,2172.442;Inherit;False;Constant;_Float10;Float 9;6;0;Create;True;0;0;0;False;0;False;2.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;230;-1610.912,1883.691;Inherit;False;Constant;_Vector2;Vector 1;6;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;231;-1318.584,2338.464;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;232;-1390.464,2046.442;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;233;-1137.356,2271.052;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;234;-1257.464,1984.441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;218;-1829.84,2741.756;Inherit;False;1280.363;522.1599;TwirlPos;11;133;203;198;185;147;148;126;137;139;138;215;TwirlPos;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;235;-1118.464,1921.439;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;237;-987.0728,2275.463;Inherit;False;Trigger;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;-1121.381,2397.867;Inherit;False;RotStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;-942.4643,1917.439;Inherit;False;Center;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;133;-1777.634,2791.756;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1778.148,3026.522;Inherit;False;236;RotStrength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-1779.84,3109.118;Inherit;False;237;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;148;-1564.672,3008.149;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;147;-1598.18,2792.315;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-1569.131,2891.263;Inherit;False;238;Center;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;126;-1312.453,2847.1;Inherit;True;Twirl;-1;;2;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;137;-1052.034,2848.657;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PosVertexDataNode;139;-1226.406,3065.231;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;138;-912.9337,2879.658;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-754.2104,2877.353;Inherit;False;TwirlPos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;220;-366.0956,1477.773;Inherit;False;1968.886;522.1478;FinalEmission;14;174;164;170;204;216;175;171;172;173;207;200;165;206;212;FinalEmission;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-269.7346,1527.773;Inherit;False;238;Center;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-316.0956,1708.072;Inherit;False;215;TwirlPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;170;28.84249,1802.135;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;17.46755,1885.207;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;164;15.96749,1671.826;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;200.4817,1822.216;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;171;308.1559,1679.961;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;172;442.1418,1678.7;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;219;-1826.343,3377.291;Inherit;False;1220.427;632.6294;Emission;10;178;180;179;201;208;181;183;177;182;205;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-1722.343,3807.206;Inherit;False;Constant;_Float7;Float 7;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;173;569.9077,1679.618;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-1776.343,3895.206;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-1763.661,3684.542;Inherit;False;237;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;783.9777,1740.386;Inherit;False;Dis01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-1565.343,3799.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-1293.603,3710.457;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-1508,3608.289;Inherit;False;207;Dis01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;177;-1138.603,3669.457;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;183;-1393.408,3427.291;Inherit;False;Constant;_Color0;Color 0;6;1;[HDR];Create;True;0;0;0;False;0;False;0,5.2864,10.08297,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-1022.831,3593.354;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-829.3452,3586.474;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;2094.995,1705.813;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;8;2307.996,1791.813;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;882.2518,1855.168;Inherit;False;237;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;846.3144,1633.549;Inherit;False;205;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;221;378.2221,2162.544;Inherit;False;877.2336;475.4619;VertexAnim;5;156;217;199;155;209;VertexAnim;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClipNode;165;1185.449,1657.19;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;2469.996,1752.813;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;440.9062,2523.291;Inherit;False;237;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;155;428.2221,2212.544;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;217;430.9093,2353.04;Inherit;False;215;TwirlPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;156;835.1041,2289.291;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;10;2627.996,1698.813;Inherit;False;Property;_RevertV;RevertV;4;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;1379.362,1676.942;Inherit;False;FinalEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;3388.281,1992.778;Inherit;False;212;FinalEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;3040.996,1540.813;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;8a93a81534b55164b904ca99971a774b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;1008.026,2279.292;Inherit;False;VertexAnim;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-1110.232,2578.494;Inherit;False;207;Dis01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;223;3659.519,1837.818;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;3000.996,2213.813;Inherit;True;Property;_MetallicMap;MetallicMap;2;0;Create;True;0;0;0;False;0;False;-1;None;cf5e40297f7fd1e4f970841d79f82a8f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;3013.476,2672.752;Inherit;True;Property;_AoMap;AoMap;5;0;Create;True;0;0;0;False;0;False;-1;None;65ec035b7eea9784e83efb65531221f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;3016.996,1749.813;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;5b0446ebf0b55ce4ea41fabbb45c4025;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;3003.506,2426.157;Inherit;True;Property;_RoughnessMap;RoughnessMap;3;0;Create;True;0;0;0;False;0;False;-1;None;efd264697f4972c4480d69da0f3dfe6c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;210;4032.032,2189.426;Inherit;False;209;VertexAnim;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;222;4301.75,2002.745;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/CyberBoy-AnimFX02;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;226;0;225;0
WireConnection;231;0;227;0
WireConnection;232;0;228;0
WireConnection;232;1;229;0
WireConnection;233;0;231;0
WireConnection;234;0;230;2
WireConnection;234;1;232;0
WireConnection;235;0;230;1
WireConnection;235;1;234;0
WireConnection;235;2;230;3
WireConnection;237;0;233;0
WireConnection;236;0;231;1
WireConnection;238;0;235;0
WireConnection;148;1;203;0
WireConnection;148;2;198;0
WireConnection;147;0;133;0
WireConnection;126;1;147;0
WireConnection;126;2;185;0
WireConnection;126;3;148;0
WireConnection;137;0;126;0
WireConnection;138;0;137;0
WireConnection;138;1;137;1
WireConnection;138;2;139;3
WireConnection;215;0;138;0
WireConnection;164;0;204;0
WireConnection;164;1;216;0
WireConnection;175;0;170;0
WireConnection;175;1;174;0
WireConnection;171;0;164;0
WireConnection;171;1;175;0
WireConnection;172;0;171;0
WireConnection;173;0;172;0
WireConnection;207;0;173;0
WireConnection;179;0;180;0
WireConnection;179;1;178;0
WireConnection;181;0;201;0
WireConnection;181;1;179;0
WireConnection;177;0;208;0
WireConnection;177;1;181;0
WireConnection;182;0;183;0
WireConnection;182;1;177;0
WireConnection;205;0;182;0
WireConnection;8;0;7;2
WireConnection;165;0;206;0
WireConnection;165;1;173;0
WireConnection;165;2;200;0
WireConnection;9;0;7;1
WireConnection;9;1;8;0
WireConnection;156;0;155;0
WireConnection;156;1;217;0
WireConnection;156;2;199;0
WireConnection;10;1;7;0
WireConnection;10;0;9;0
WireConnection;212;0;165;0
WireConnection;1;1;10;0
WireConnection;209;0;156;0
WireConnection;223;0;1;0
WireConnection;223;1;213;0
WireConnection;4;1;10;0
WireConnection;2;1;10;0
WireConnection;5;1;10;0
WireConnection;222;0;223;0
WireConnection;222;1;210;0
ASEEND*/
//CHKSM=F64ADAA377A5697E4E1672BD01850D71B6CABDD3