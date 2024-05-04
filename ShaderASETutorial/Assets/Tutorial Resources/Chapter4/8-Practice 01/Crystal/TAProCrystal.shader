// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Crystal"
{
	Properties
	{
		_Float0("Float 0", Float) = 1
		_PointVec("PointVec", Vector) = (0,0,0,0)
		_MatCapScale1("MatCapScale", Float) = 1
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", CUBE) = "white" {}
		_TextureSample1("Texture Sample 1", CUBE) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_TextureSample3("Texture Sample 3", 2D) = "white" {}
		_Float5("Float 5", Float) = 1
		_Float6("Float 6", Float) = 1
		_Float8("Float 8", Float) = 1
		_MainTex("_MainTex", 2D) = "black" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 0
		_M("M", Range( 0 , 1)) = 0
		_S("S", Range( 0 , 1)) = 0
		_MainTex_Scale("_MainTex_Scale", Range( 0 , 1)) = 1
		_Height_Min("Height_Min", Range( 0 , 1)) = 0
		_Height_Max("Height_Max", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		float hash(float x) { return frac(x + 1.3215 * 1.8152); }              float hash3(float3 a) { return frac((hash(a.z * 42.8883) + hash(a.y * 36.9125) + hash(a.x * 65.4321)) * 291.1257); }              float3 rehash3(float x) { return float3(hash(((x + 0.5283) * 59.3829) * 274.3487), hash(((x + 0.8192) * 83.6621) * 345.3871), hash(((x + 0.2157f) * 36.6521f) * 458.3971f)); }              float sqr(float x) {return x*x;}             float fastdist(float3 a, float3 b) { return sqr(b.x - a.x) + sqr(b.y - a.y) + sqr(b.z - a.z); }              float2 Voronoi3D(float3 xyz)             {                 float x = xyz.x;                 float y = xyz.y;                 float z = xyz.z;                 float4 p[27];                 for (int _x = -1; _x < 2; _x++) for (int _y = -1; _y < 2; _y++) for(int _z = -1; _z < 2; _z++) {                     float3 _p = float3(floor(x), floor(y), floor(z)) + float3(_x, _y, _z);                     float h = hash3(_p);                     p[(_x + 1) + ((_y + 1) * 3) + ((_z + 1) * 3 * 3)] = float4((rehash3(h) + _p).xyz, h);                 }                 float m = 9999.9999, w = 0.0;                 for (int i = 0; i < 27; i++) {                     float d = fastdist(float3(x, y, z), p[i].xyz);                     if(d < m) { m = d; w = p[i].w; }                 }                 return float2(m, w);             }
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _NormalScale;
		uniform samplerCUBE _TextureSample1;
		uniform samplerCUBE _TextureSample0;
		uniform float _Float0;
		uniform float _Float8;
		uniform sampler2D _TextureSample2;
		uniform float _MatCapScale1;
		uniform float _Float6;
		uniform sampler2D _TextureSample3;
		uniform float _Float5;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _MainTex_Scale;
		uniform float _Height_Min;
		uniform float _Height_Max;
		uniform float4 _PointVec;
		uniform float4 _Color0;
		uniform float _M;
		uniform float _S;


		float2 MyCustomExpression3_g1( float3 pos )
		{
			return Voronoi3D(pos);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 pos3_g1 = ( ( ( -ase_worldViewDir * 0.1 ) + ase_worldPos ) * _Float0 );
			float2 localMyCustomExpression3_g1 = MyCustomExpression3_g1( pos3_g1 );
			float2 break5_g1 = localMyCustomExpression3_g1;
			float temp_output_1_4 = break5_g1.y;
			float2 temp_cast_0 = (temp_output_1_4).xx;
			float dotResult4_g14 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
			float lerpResult10_g14 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g14 ) * 43758.55 ) ));
			float2 temp_cast_1 = (( temp_output_1_4 + 10.0 )).xx;
			float dotResult4_g13 = dot( temp_cast_1 , float2( 12.9898,78.233 ) );
			float lerpResult10_g13 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g13 ) * 43758.55 ) ));
			float2 temp_cast_2 = (( temp_output_1_4 * 17.0 )).xx;
			float dotResult4_g11 = dot( temp_cast_2 , float2( 12.9898,78.233 ) );
			float lerpResult10_g11 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g11 ) * 43758.55 ) ));
			float3 appendResult64 = (float3(lerpResult10_g14 , lerpResult10_g13 , lerpResult10_g11));
			float3 FakeWorldNormal67 = (WorldNormalVector( i , appendResult64 ));
			float3 temp_output_73_0 = reflect( -ase_worldViewDir , FakeWorldNormal67 );
			float3 normalizeResult10_g18 = normalize( normalize( (WorldNormalVector( i , temp_output_73_0 )) ) );
			float3 worldToViewDir3_g18 = normalize( mul( UNITY_MATRIX_V, float4( normalizeResult10_g18, 0 ) ).xyz );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 normalizeResult10_g17 = normalize( ase_normWorldNormal );
			float3 worldToViewDir3_g17 = normalize( mul( UNITY_MATRIX_V, float4( normalizeResult10_g17, 0 ) ).xyz );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode102 = tex2D( _MainTex, uv_MainTex );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float Height01141 = saturate( ( ( ( ase_vertex3Pos.y * 100.0 ) - -0.66 ) / ( 1.22 - -0.66 ) ) );
			float smoothstepResult143 = smoothstep( _Height_Min , _Height_Max , Height01141);
			float4 lerpResult125 = lerp( ( ( texCUBE( _TextureSample1, (texCUBE( _TextureSample0, temp_output_73_0 )*2.0 + -1.0).rgb ) * _Float8 ) + ( tex2D( _TextureSample2, (( ( ( worldToViewDir3_g18 * _MatCapScale1 ) * 0.5 ) + 0.5 )).xy ) * _Float6 ) + ( tex2D( _TextureSample3, (( ( ( worldToViewDir3_g17 * _MatCapScale1 ) * 0.5 ) + 0.5 )).xy ) * _Float5 ) + ( tex2DNode102 * _MainTex_Scale ) ) , tex2DNode102 , smoothstepResult143);
			o.Albedo = lerpResult125.rgb;
			o.Emission = ( exp( ( distance( float4( ase_vertex3Pos , 0.0 ) , ( 0.01 * _PointVec ) ) * -_PointVec.w ) ) * _Color0 * tex2DNode102 ).rgb;
			o.Metallic = _M;
			o.Smoothness = _S;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
449.7143;17.14286;1443.429;1156.143;-1285.21;1142.649;2.635191;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;-2479.654,-302.9585;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;85;-2305.654,-312.9585;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2323.654,-199.9585;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-2163.543,-106.3503;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-2157.654,-259.9585;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1862.4,49.4355;Inherit;False;Property;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-1864.654,-161.9585;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1710.542,-58.35027;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1;-1572.243,-72.65029;Inherit;False;Voronoi3D;-1;;1;df8de70fb04c9b448bd226b0974e00e4;0;1;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-1286.051,64.76373;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;0;False;0;False;17;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1278.852,-56.43627;Inherit;False;Constant;_Float7;Float 7;7;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1100.051,12.76373;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1061.051,-162.2363;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;59;-876.0511,7.763733;Inherit;True;Random Range;-1;;11;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;58;-885.0511,-222.2363;Inherit;True;Random Range;-1;;13;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;57;-919.0511,-459.2363;Inherit;True;Random Range;-1;;14;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;-528.0511,-148.2363;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;65;-333.4456,-85.64636;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;140;1917.482,2084.142;Inherit;False;Constant;_Float14;Float 14;19;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;126;1876.628,1909.903;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-102.4456,-183.6464;Inherit;False;FakeWorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;70;-141.4456,177.3536;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;69;42.55444,547.3536;Inherit;False;67;FakeWorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;134;2065.728,2289.514;Inherit;False;Constant;_Float13;Float 13;19;0;Create;True;0;0;0;False;0;False;1.22;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;2123.482,1975.142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;2055.728,2181.515;Inherit;False;Constant;_Float12;Float 12;19;0;Create;True;0;0;0;False;0;False;-0.66;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;71;98.55444,181.3536;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;136;2501.729,2255.514;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;135;2311.729,2139.515;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;73;434.5544,257.3536;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;2666.729,2099.515;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1383.554,276.3536;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;75;1210.554,-46.64636;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;db5d9ec0a45e4c048aa0d548acd257d2;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;130;2188.224,1283.689;Inherit;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1384.554,166.3536;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;81;1156.872,517.8952;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;94;1263.105,887.7242;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;118;2119.248,1369.954;Inherit;False;Property;_PointVec;PointVec;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,-2.46,0,1.3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;138;2834.729,2034.515;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;80;1388.763,519.389;Inherit;False;MatCapUV;2;;18;a07b4960ad27487488108c0f4ec350bb;0;1;1;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;95;1494.996,889.218;Inherit;False;MatCapUV;2;;17;a07b4960ad27487488108c0f4ec350bb;0;1;1;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;117;2198.248,1096.954;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;77;1608.554,11.35364;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;2356.224,1291.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;97;1985.783,1048.282;Inherit;False;Property;_Float5;Float 5;9;0;Create;True;0;0;0;False;0;False;1;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;120;2512.81,1347.854;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;1848.554,40.35364;Inherit;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;0;False;0;False;-1;None;db5d9ec0a45e4c048aa0d548acd257d2;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;119;2555.248,1145.954;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;1927.23,360.2651;Inherit;False;Property;_Float8;Float 8;11;0;Create;True;0;0;0;False;0;False;1;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;1840,720;Inherit;False;Property;_Float6;Float 6;10;0;Create;True;0;0;0;False;0;False;1;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;2337.485,595.9127;Inherit;True;Property;_MainTex;_MainTex;12;0;Create;True;0;0;0;False;0;False;-1;None;5b40fc89036e78346802ec1a117f2268;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;82;1717.298,475.9589;Inherit;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;0;False;0;False;-1;None;e973c0bca68ab43418e13361fb46a97b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;116;2507.921,899.524;Inherit;False;Property;_MainTex_Scale;_MainTex_Scale;17;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;3008.085,2024.843;Inherit;False;Height01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;93;1823.531,845.7878;Inherit;True;Property;_TextureSample3;Texture Sample 3;8;0;Create;True;0;0;0;False;0;False;-1;None;1596a888bc1d13543801a95ec303a327;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;2849.631,997.2538;Inherit;False;Property;_Height_Max;Height_Max;19;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;2771.67,618.5182;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;144;2829.631,918.2538;Inherit;False;Property;_Height_Min;Height_Min;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;2119.23,216.2651;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;2175.783,911.2816;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;2840.631,824.2538;Inherit;False;141;Height01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;2696.248,1231.954;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;2032,576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;143;3120.631,813.2538;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;2709.682,184.0193;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;3259.432,431.1629;Inherit;False;0;109;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;123;2903.248,1353.954;Inherit;False;Property;_Color0;Color 0;4;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;178.9082,14.05038,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ExpOpNode;122;2927.248,1197.954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;3239.432,566.1628;Inherit;False;Property;_NormalScale;NormalScale;14;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;3223.248,1162.954;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;114;4266.085,367.0465;Inherit;False;Property;_S;S;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;109;3535.432,411.1629;Inherit;True;Property;_NormalMap;NormalMap;13;0;Create;True;0;0;0;False;0;False;-1;None;0139fb8fcf1996f4a879f2601e44be71;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;125;2918.815,270.1131;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-262.4456,-362.6464;Inherit;False;FakeNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;105;2870.326,-142.3496;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;4269.085,263.0465;Inherit;False;Property;_M;M;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;3219.326,151.6504;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;104;2625.326,-47.34961;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;103;2598.127,-193.2146;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;74;430.5544,473.3536;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;54.55444,400.3536;Inherit;False;66;FakeNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;106;3041.326,-137.3496;Inherit;False;Remap01;-1;;19;e576bd475d0540a489f939c914d7a50f;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;108;4743.931,65.34575;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TAPro/Crystal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;85;0;84;0
WireConnection;87;0;85;0
WireConnection;87;1;88;0
WireConnection;86;0;87;0
WireConnection;86;1;2;0
WireConnection;3;0;86;0
WireConnection;3;1;4;0
WireConnection;1;2;3;0
WireConnection;62;0;1;4
WireConnection;62;1;63;0
WireConnection;60;0;1;4
WireConnection;60;1;61;0
WireConnection;59;1;62;0
WireConnection;58;1;60;0
WireConnection;57;1;1;4
WireConnection;64;0;57;0
WireConnection;64;1;58;0
WireConnection;64;2;59;0
WireConnection;65;0;64;0
WireConnection;67;0;65;0
WireConnection;139;0;126;2
WireConnection;139;1;140;0
WireConnection;71;0;70;0
WireConnection;136;0;134;0
WireConnection;136;1;133;0
WireConnection;135;0;139;0
WireConnection;135;1;133;0
WireConnection;73;0;71;0
WireConnection;73;1;69;0
WireConnection;137;0;135;0
WireConnection;137;1;136;0
WireConnection;75;1;73;0
WireConnection;81;0;73;0
WireConnection;138;0;137;0
WireConnection;80;1;81;0
WireConnection;95;1;94;0
WireConnection;77;0;75;0
WireConnection;77;1;78;0
WireConnection;77;2;79;0
WireConnection;129;0;130;0
WireConnection;129;1;118;0
WireConnection;120;0;118;4
WireConnection;76;1;77;0
WireConnection;119;0;117;0
WireConnection;119;1;129;0
WireConnection;82;1;80;0
WireConnection;141;0;138;0
WireConnection;93;1;95;0
WireConnection;115;0;102;0
WireConnection;115;1;116;0
WireConnection;100;0;76;0
WireConnection;100;1;101;0
WireConnection;96;0;93;0
WireConnection;96;1;97;0
WireConnection;121;0;119;0
WireConnection;121;1;120;0
WireConnection;98;0;82;0
WireConnection;98;1;99;0
WireConnection;143;0;142;0
WireConnection;143;1;144;0
WireConnection;143;2;145;0
WireConnection;83;0;100;0
WireConnection;83;1;98;0
WireConnection;83;2;96;0
WireConnection;83;3;115;0
WireConnection;122;0;121;0
WireConnection;124;0;122;0
WireConnection;124;1;123;0
WireConnection;124;2;102;0
WireConnection;109;1;111;0
WireConnection;109;5;112;0
WireConnection;125;0;83;0
WireConnection;125;1;102;0
WireConnection;125;2;143;0
WireConnection;66;0;64;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;107;0;105;0
WireConnection;107;1;125;0
WireConnection;106;1;105;0
WireConnection;108;0;125;0
WireConnection;108;1;109;0
WireConnection;108;2;124;0
WireConnection;108;3;113;0
WireConnection;108;4;114;0
ASEEND*/
//CHKSM=D094803DD5C54E31D21C648FB31BF1131B9D56D5