// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/04/TAProLighting"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Wrap("_Wrap", Range( 0 , 1)) = 0.5
		_CheapSSS_Lerp_Pow_Scale("CheapSSS_Lerp_Pow_Scale", Vector) = (0.5,1,1,0)
		_Vector1("Vector 1", Vector) = (0,0,0,0)
		_SpecularColorLerp("SpecularColorLerp", Range( 0 , 1)) = 0.5
		_AmbientColor("AmbientColor", Color) = (0,0,0,0)

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
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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

			//This is a late directive
			
			uniform sampler2D _MainTex;
			uniform float _Wrap;
			uniform float4 _CheapSSS_Lerp_Pow_Scale;
			uniform float2 _Vector1;
			uniform float _SpecularColorLerp;
			uniform float4 _AmbientColor;

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord1.xy;
				
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
				float2 texCoord2 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 BaseMap47 = tex2D( _MainTex, texCoord2 );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float dotResult34 = dot( normalizedWorldNormal , worldSpaceLightDir );
				float WrapLight30 = saturate( ( ( dotResult34 + _Wrap ) / ( _Wrap + 1.0 ) ) );
				float3 N71 = normalizedWorldNormal;
				float3 L72 = worldSpaceLightDir;
				float3 normalizeResult96 = normalize( -( ( N71 * _CheapSSS_Lerp_Pow_Scale.x ) + L72 ) );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 V73 = ase_worldViewDir;
				float dotResult98 = dot( normalizeResult96 , V73 );
				float CheapSSS100 = saturate( ( pow( dotResult98 , _CheapSSS_Lerp_Pow_Scale.y ) * _CheapSSS_Lerp_Pow_Scale.z ) );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 normalizeResult149 = normalize( ( V73 + L72 ) );
				float3 H150 = normalizeResult149;
				float dotResult138 = dot( N71 , H150 );
				float BlinPhong144 = ( pow( saturate( dotResult138 ) , ( _Vector1.x * 100.0 ) ) * _Vector1.y );
				float4 lerpResult158 = lerp( float4( float3(1,1,1) , 0.0 ) , BaseMap47 , _SpecularColorLerp);
				float4 Ambient166 = ( _AmbientColor * BaseMap47 );
				
				
				finalColor = ( ( BaseMap47 * ( WrapLight30 + CheapSSS100 ) * ase_lightColor ) + ( BlinPhong144 * lerpResult158 ) + Ambient166 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
96.00001;334.8571;1926.857;836.1429;-129.5822;-445.0037;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;118;-3982.732,2298.498;Inherit;False;1080.478;1330.428;NLV;17;124;121;122;120;119;72;69;123;71;73;68;70;145;146;147;149;150;NLV;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;68;-3451.732,2354.053;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;70;-3447.965,2691.069;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-3256.683,2348.498;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2710.31,2277.138;Inherit;False;1678.43;573.0134;CheapSSS;12;89;92;94;90;93;95;97;96;98;99;100;154;CheapSSS;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;69;-3486.732,2511.053;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;92;-2660.31,2456.437;Inherit;False;Property;_CheapSSS_Lerp_Pow_Scale;CheapSSS_Lerp_Pow_Scale;4;0;Create;True;0;0;0;False;0;False;0.5,1,1,0;2,1,5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;89;-2582.456,2327.138;Inherit;False;71;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-3266.683,2688.498;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-3249.683,2510.498;Inherit;False;L;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-3742.131,3306.875;Inherit;False;73;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-2324.257,2344.438;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-2636.31,2735.437;Inherit;False;72;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-3743.062,3415.932;Inherit;False;72;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-3538.096,3335.903;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2508.097,1389.738;Inherit;False;1494.522;552.4629;WrapLight;10;32;31;40;34;38;37;41;39;44;30;WrapLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-2161.31,2341.437;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;32;-2458.097,1596.738;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;31;-2423.097,1439.738;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;95;-1981.309,2363.437;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;149;-3377.096,3336.903;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;151;-2236.51,3441.431;Inherit;False;1197.427;489.8914;BlinPhong;9;136;137;138;143;139;141;140;142;144;BlinPhong;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2049.2,1774.487;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1843.309,2454.437;Inherit;False;73;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;34;-2173.006,1492.949;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;96;-1824.309,2357.437;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2197.195,1674.486;Inherit;False;Property;_Wrap;_Wrap;2;0;Create;True;0;0;0;False;0;False;0.5;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;-3177.096,3338.903;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-2185.51,3592.431;Inherit;False;150;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;98;-1653.309,2358.437;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1846.2,1691.486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-784.4286,-70.78574;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;137;-2186.51,3491.431;Inherit;False;71;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1850.2,1520.486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1998.882,3816.608;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;138;-1961.508,3521.431;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;139;-2006.508,3664.431;Inherit;False;Property;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;1;-474.4286,-99.78574;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;7bb9f7571bfbc7d48b0dcd5fa41095b4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;39;-1631.2,1569.486;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;99;-1548.309,2466.437;Inherit;False;PowerScale;-1;;2;5ba70760a40e0a6499195a0590fd2e74;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1830.882,3620.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;154;-1344.571,2483.194;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-1445.619,1587.217;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;141;-1780.882,3539.608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-107.359,-94.30132;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-385.6033,1455.605;Inherit;False;47;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;163;-418.6033,1275.506;Inherit;False;Property;_AmbientColor;AmbientColor;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8584906,0.7335351,0.7335351,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-1192.309,2464.437;Inherit;False;CheapSSS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1240.137,1567.159;Inherit;False;WrapLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;142;-1541.508,3545.431;Inherit;False;PowerScale;-1;;5;5ba70760a40e0a6499195a0590fd2e74;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;519.4766,507.0803;Inherit;False;30;WrapLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;160;525.9961,885.1818;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;-156.6035,1290.605;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;161;510.9961,1145.182;Inherit;False;Property;_SpecularColorLerp;SpecularColorLerp;7;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;533.9961,1036.182;Inherit;False;47;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-1262.509,3551.431;Inherit;False;BlinPhong;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;511.2345,706.3042;Inherit;False;100;CheapSSS;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;158;881.0035,907.4946;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;16.39642,1300.605;Inherit;False;Ambient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;168;545.5239,3.917969;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;153;844.5601,509.0744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;528.641,159.6987;Inherit;False;47;BaseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;523.9368,789.9072;Inherit;False;144;BlinPhong;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1023.42,311.9946;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;1130.996,789.1818;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;135;-2236.125,2879.111;Inherit;False;1202.428;496.8916;Phong;9;126;125;127;129;133;132;128;134;130;Phong;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;870.3891,1260.526;Inherit;False;166;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1939.83,1089.546;Inherit;False;924.9539;289.7136;Lut;3;24;23;27;Lut;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2022.724,685.8344;Inherit;False;1005.522;384.8571;HalfLambert;8;15;13;12;11;16;17;18;50;HalfLambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2259.431,1964.962;Inherit;False;1241.043;281.0576;BandedLight;7;51;52;56;57;58;55;59;BandedLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;9;-2015.59,249.6723;Inherit;False;1005.522;384.8571;Lambert;5;4;3;5;7;6;Lambert;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-466.493,681.5677;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1238.305,1139.546;Inherit;False;Lut;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;1281.473,1008.926;Inherit;False;130;Phong;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-1341.344,844.4401;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;523.758,286.7386;Inherit;False;6;Lambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-1247.126,2993.111;Inherit;False;Phong;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;128;-1548.125,2990.111;Inherit;False;PowerScale;-1;;6;5ba70760a40e0a6499195a0590fd2e74;0;3;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1837.499,3065.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-1461.279,2025.304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2005.499,3261.288;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;127;-1968.125,2966.111;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;129;-2013.125,3109.111;Inherit;False;Property;_Phong;Phong;5;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;126;-2186.125,3035.111;Inherit;False;123;R;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-2186.125,2929.111;Inherit;False;73;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-3139.114,3006.722;Inherit;False;R;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;124;-3383.114,3004.722;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;121;-3578.183,3004.665;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;120;-3756.183,3001.665;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-3899.114,3111.722;Inherit;False;71;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-3923.183,2995.665;Inherit;False;72;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;132;-1787.499,2984.288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;20;-458.6773,407.3557;Inherit;False;0;3;2;0,0,0,0;0.1845633,0.6698113,0.1426283,0.4882429;0.9433962,0.1572059,0,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-1622.497,379.8832;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;56;-1806.279,2018.304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-453.9263,235.6042;Inherit;False;15;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1215.344,946.0507;Inherit;False;NL01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;514.8275,622.5687;Inherit;False;59;BandedLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2209.431,2014.962;Inherit;False;50;NL01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-1930.59,299.6721;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;7;-1462.497,391.8832;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-463.0386,151.813;Inherit;False;6;Lambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;11;-1972.724,892.8344;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;13;-1687.631,789.0457;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1212.631,832.0457;Inherit;False;HalfLambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;21;-67.67738,395.3557;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;22;-465.6774,570.3552;Inherit;False;15;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2185.278,2131.304;Inherit;False;Property;_StepNum;StepNum;3;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;-1657.279,2028.304;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1645.344,914.4401;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;155;1399.637,787.7794;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1889.83,1200.959;Inherit;False;15;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-1241.817,2030.916;Inherit;False;BandedLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-1937.724,735.8344;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;23;-1638.571,1149.259;Inherit;True;Property;_Lut;Lut;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1963.279,2026.304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-1270.497,383.8832;Inherit;False;Lambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1481.344,825.4401;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;519.1689,384.7156;Inherit;False;15;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;4;-1965.59,456.6721;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1650.963,817.3954;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/04/TAProLighting;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;71;0;68;0
WireConnection;73;0;70;0
WireConnection;72;0;69;0
WireConnection;90;0;89;0
WireConnection;90;1;92;1
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;93;0;90;0
WireConnection;93;1;94;0
WireConnection;95;0;93;0
WireConnection;149;0;147;0
WireConnection;34;0;31;0
WireConnection;34;1;32;0
WireConnection;96;0;95;0
WireConnection;150;0;149;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;41;0;38;0
WireConnection;41;1;40;0
WireConnection;37;0;34;0
WireConnection;37;1;38;0
WireConnection;138;0;137;0
WireConnection;138;1;136;0
WireConnection;1;1;2;0
WireConnection;39;0;37;0
WireConnection;39;1;41;0
WireConnection;99;1;98;0
WireConnection;99;2;92;2
WireConnection;99;3;92;3
WireConnection;140;0;139;1
WireConnection;140;1;143;0
WireConnection;154;0;99;0
WireConnection;44;0;39;0
WireConnection;141;0;138;0
WireConnection;47;0;1;0
WireConnection;100;0;154;0
WireConnection;30;0;44;0
WireConnection;142;1;141;0
WireConnection;142;2;140;0
WireConnection;142;3;139;2
WireConnection;164;0;163;0
WireConnection;164;1;165;0
WireConnection;144;0;142;0
WireConnection;158;0;160;0
WireConnection;158;1;159;0
WireConnection;158;2;161;0
WireConnection;166;0;164;0
WireConnection;153;0;46;0
WireConnection;153;1;87;0
WireConnection;49;0;48;0
WireConnection;49;1;153;0
WireConnection;49;2;168;0
WireConnection;162;0;131;0
WireConnection;162;1;158;0
WireConnection;27;0;23;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;130;0;128;0
WireConnection;128;1;132;0
WireConnection;128;2;133;0
WireConnection;128;3;129;2
WireConnection;133;0;129;1
WireConnection;133;1;134;0
WireConnection;58;0;57;0
WireConnection;127;0;125;0
WireConnection;127;1;126;0
WireConnection;123;0;124;0
WireConnection;124;0;121;0
WireConnection;121;0;120;0
WireConnection;121;1;122;0
WireConnection;120;0;119;0
WireConnection;132;0;127;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;56;0;52;0
WireConnection;50;0;18;0
WireConnection;7;0;5;0
WireConnection;13;0;12;0
WireConnection;13;1;11;0
WireConnection;15;0;18;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;155;0;49;0
WireConnection;155;1;162;0
WireConnection;155;2;167;0
WireConnection;59;0;58;0
WireConnection;23;1;24;0
WireConnection;52;0;51;0
WireConnection;52;1;55;0
WireConnection;6;0;7;0
WireConnection;16;0;13;0
WireConnection;16;1;17;0
WireConnection;0;0;155;0
ASEEND*/
//CHKSM=1FE73371F38A0C429A8B8B3F49567407DCEA1922