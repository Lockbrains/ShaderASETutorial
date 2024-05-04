// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/CyberBoy-AnimFX"
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
		Cull Off
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

		uniform float4 _Global_VertexParam;
		uniform sampler2D _NormalMap;
		uniform sampler2D _MainTex;
		uniform sampler2D _MetallicMap;
		uniform sampler2D _RoughnessMap;
		uniform sampler2D _AoMap;
		uniform float4 _AoMap_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 _Vector1 = float3(0,0,0);
			float3 appendResult190 = (float3(_Vector1.x , ( _Vector1.y + ( 0.01 * 2.5 ) ) , _Vector1.z));
			float3 Center184 = appendResult190;
			float2 center45_g2 = Center184.xy;
			float2 delta6_g2 = ( (ase_vertex3Pos).xy - center45_g2 );
			float4 VecParam129 = _Global_VertexParam;
			float4 break154 = VecParam129;
			float RotStrength202 = break154.y;
			float Trigger196 = saturate( break154.x );
			float lerpResult148 = lerp( 0.0 , RotStrength202 , Trigger196);
			float angle10_g2 = ( length( delta6_g2 ) * lerpResult148 );
			float x23_g2 = ( ( cos( angle10_g2 ) * delta6_g2.x ) - ( sin( angle10_g2 ) * delta6_g2.y ) );
			float2 break40_g2 = center45_g2;
			float2 break41_g2 = float2( 0,0 );
			float y35_g2 = ( ( sin( angle10_g2 ) * delta6_g2.x ) + ( cos( angle10_g2 ) * delta6_g2.y ) );
			float2 appendResult44_g2 = (float2(( x23_g2 + break40_g2.x + break41_g2.x ) , ( break40_g2.y + break41_g2.y + y35_g2 )));
			float2 break137 = appendResult44_g2;
			float4 appendResult138 = (float4(break137.x , break137.y , ase_vertex3Pos.z , 0.0));
			float4 TwirlPos215 = appendResult138;
			float4 lerpResult156 = lerp( float4( ase_vertex3Pos , 0.0 ) , TwirlPos215 , Trigger196);
			float4 VertexAnim209 = lerpResult156;
			v.vertex.xyz = VertexAnim209.xyz;
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
			float4 color183 = IsGammaSpace() ? float4(0,5.2864,10.08297,0) : float4(0,38.98989,161.3967,0);
			float3 _Vector1 = float3(0,0,0);
			float3 appendResult190 = (float3(_Vector1.x , ( _Vector1.y + ( 0.01 * 2.5 ) ) , _Vector1.z));
			float3 Center184 = appendResult190;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 center45_g2 = Center184.xy;
			float2 delta6_g2 = ( (ase_vertex3Pos).xy - center45_g2 );
			float4 VecParam129 = _Global_VertexParam;
			float4 break154 = VecParam129;
			float RotStrength202 = break154.y;
			float Trigger196 = saturate( break154.x );
			float lerpResult148 = lerp( 0.0 , RotStrength202 , Trigger196);
			float angle10_g2 = ( length( delta6_g2 ) * lerpResult148 );
			float x23_g2 = ( ( cos( angle10_g2 ) * delta6_g2.x ) - ( sin( angle10_g2 ) * delta6_g2.y ) );
			float2 break40_g2 = center45_g2;
			float2 break41_g2 = float2( 0,0 );
			float y35_g2 = ( ( sin( angle10_g2 ) * delta6_g2.x ) + ( cos( angle10_g2 ) * delta6_g2.y ) );
			float2 appendResult44_g2 = (float2(( x23_g2 + break40_g2.x + break41_g2.x ) , ( break40_g2.y + break41_g2.y + y35_g2 )));
			float2 break137 = appendResult44_g2;
			float4 appendResult138 = (float4(break137.x , break137.y , ase_vertex3Pos.z , 0.0));
			float4 TwirlPos215 = appendResult138;
			float temp_output_173_0 = ( 1.0 - saturate( ( distance( float4( Center184 , 0.0 ) , TwirlPos215 ) / ( 7.0 * 0.01 ) ) ) );
			float Dis01207 = temp_output_173_0;
			float4 Emission205 = ( color183 * step( Dis01207 , ( Trigger196 + ( 0.5 * 0.01 ) ) ) );
			clip( temp_output_173_0 - Trigger196);
			float4 FinalEmission212 = Emission205;
			o.Emission = FinalEmission212.rgb;
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
276;646.8572;1916;506.7143;4346.975;-1007.335;6.263462;True;False
Node;AmplifyShaderEditor.CommentaryNode;214;-1559.596,1639.076;Inherit;False;955.0511;969.8478;Comment;14;81;129;187;188;186;141;189;190;184;153;154;202;196;159;Param;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;81;-1057.18,1689.076;Inherit;False;Global;_Global_VertexParam;_Global_VertexParam;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;-0.09,618,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-827.9734,1691.462;Inherit;False;VecParam;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-1415.442,2435.38;Inherit;False;129;VecParam;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1498.147,2168.045;Inherit;False;Constant;_Float8;Float 8;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-1477.147,2265.045;Inherit;False;Constant;_Float9;Float 9;6;0;Create;True;0;0;0;False;0;False;2.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;141;-1509.596,1976.294;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;154;-1217.268,2431.067;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1289.148,2139.045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-1167.148,2082.044;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;159;-1036.04,2363.654;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;218;-1829.84,2741.756;Inherit;False;1280.363;522.1599;TwirlPos;11;133;203;198;185;147;148;126;137;139;138;215;TwirlPos;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;190;-1017.148,2014.042;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-1020.065,2490.47;Inherit;False;RotStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-885.7564,2368.066;Inherit;False;Trigger;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-1779.84,3109.118;Inherit;False;196;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;-841.1479,2010.042;Inherit;False;Center;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1778.148,3026.522;Inherit;False;202;RotStrength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;133;-1777.634,2791.756;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;147;-1598.18,2792.315;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-1569.131,2891.263;Inherit;False;184;Center;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;148;-1564.672,3008.149;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;126;-1312.453,2847.1;Inherit;True;Twirl;-1;;2;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;139;-1226.406,3065.231;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;137;-1052.034,2848.657;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;138;-912.9337,2879.658;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;220;-529.1722,1646.473;Inherit;False;1968.886;522.1478;FinalEmission;14;174;164;170;204;216;175;171;172;173;207;200;165;206;212;FinalEmission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-754.2104,2877.353;Inherit;False;TwirlPos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-134.2342,1970.835;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-145.6092,2053.907;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-432.8111,1696.473;Inherit;False;184;Center;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-479.1721,1876.772;Inherit;False;215;TwirlPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;37.405,1990.916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;164;-147.1092,1840.526;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;171;145.0792,1848.661;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;172;279.0653,1847.4;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;219;-1826.343,3377.291;Inherit;False;1220.427;632.6294;Emission;10;178;180;179;201;208;181;183;177;182;205;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-1722.343,3807.206;Inherit;False;Constant;_Float7;Float 7;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;173;406.8312,1848.318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-1776.343,3895.206;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-1763.661,3684.542;Inherit;False;196;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;620.9009,1909.086;Inherit;False;Dis01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-1565.343,3799.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-1508,3608.289;Inherit;False;207;Dis01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-1293.603,3710.457;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;177;-1138.603,3669.457;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;183;-1393.408,3427.291;Inherit;False;Constant;_Color0;Color 0;6;1;[HDR];Create;True;0;0;0;False;0;False;0,5.2864,10.08297,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-1022.831,3593.354;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-829.3452,3586.474;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;2103.565,2111.47;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;221;509.3606,2317.452;Inherit;False;877.2336;475.4619;VertexAnim;5;156;217;199;155;209;VertexAnim;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;8;2316.566,2197.47;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;683.2375,1802.249;Inherit;False;205;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;719.1749,2023.868;Inherit;False;196;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;155;559.3607,2367.452;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;199;572.0447,2678.199;Inherit;False;196;Trigger;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;562.0479,2507.948;Inherit;False;215;TwirlPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;2478.566,2158.47;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;156;966.2419,2444.199;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClipNode;165;1022.373,1825.89;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;1139.163,2434.2;Inherit;False;VertexAnim;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;1216.286,1845.642;Inherit;False;FinalEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;10;2636.566,2104.47;Inherit;False;Property;_RevertV;RevertV;4;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;3000.996,2213.813;Inherit;True;Property;_MetallicMap;MetallicMap;2;0;Create;True;0;0;0;False;0;False;-1;None;cf5e40297f7fd1e4f970841d79f82a8f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;210;4000.032,2442.426;Inherit;False;209;VertexAnim;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;14;3013.476,2672.752;Inherit;True;Property;_AoMap;AoMap;5;0;Create;True;0;0;0;False;0;False;-1;None;65ec035b7eea9784e83efb65531221f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;3003.506,2426.157;Inherit;True;Property;_RoughnessMap;RoughnessMap;3;0;Create;True;0;0;0;False;0;False;-1;None;efd264697f4972c4480d69da0f3dfe6c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;213;3940.867,2115.542;Inherit;False;212;FinalEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;3035.283,1766.493;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;8a93a81534b55164b904ca99971a774b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;3011.283,1975.493;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;5b0446ebf0b55ce4ea41fabbb45c4025;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4415.602,2049.893;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TAPro/CyberBoy-AnimFX;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;129;0;81;0
WireConnection;154;0;153;0
WireConnection;186;0;187;0
WireConnection;186;1;188;0
WireConnection;189;0;141;2
WireConnection;189;1;186;0
WireConnection;159;0;154;0
WireConnection;190;0;141;1
WireConnection;190;1;189;0
WireConnection;190;2;141;3
WireConnection;202;0;154;1
WireConnection;196;0;159;0
WireConnection;184;0;190;0
WireConnection;147;0;133;0
WireConnection;148;1;203;0
WireConnection;148;2;198;0
WireConnection;126;1;147;0
WireConnection;126;2;185;0
WireConnection;126;3;148;0
WireConnection;137;0;126;0
WireConnection;138;0;137;0
WireConnection;138;1;137;1
WireConnection;138;2;139;3
WireConnection;215;0;138;0
WireConnection;175;0;170;0
WireConnection;175;1;174;0
WireConnection;164;0;204;0
WireConnection;164;1;216;0
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
WireConnection;9;0;7;1
WireConnection;9;1;8;0
WireConnection;156;0;155;0
WireConnection;156;1;217;0
WireConnection;156;2;199;0
WireConnection;165;0;206;0
WireConnection;165;1;173;0
WireConnection;165;2;200;0
WireConnection;209;0;156;0
WireConnection;212;0;165;0
WireConnection;10;1;7;0
WireConnection;10;0;9;0
WireConnection;4;1;10;0
WireConnection;5;1;10;0
WireConnection;1;1;10;0
WireConnection;2;1;10;0
WireConnection;0;0;1;0
WireConnection;0;1;2;0
WireConnection;0;2;213;0
WireConnection;0;3;4;1
WireConnection;0;4;5;1
WireConnection;0;5;14;1
WireConnection;0;11;210;0
ASEEND*/
//CHKSM=00309DD3A12EF16143AC29E6FE43FF9B76293C40