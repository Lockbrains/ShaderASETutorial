// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/05/CubeMatCap"
{
	Properties
	{
		_CubeMap("CubeMap", CUBE) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_MainTex("_MainTex", 2D) = "white" {}
		_F_BSP("F_BSP", Vector) = (0,1,5,0)
		_CubeMapMip("CubeMapMip", Range( 0 , 12)) = 0
		_MatCap("MatCap", 2D) = "white" {}
		_MatCapScale("MatCapScale", Float) = 1
		_SSSScale("SSSScale", Float) = 1
		_SSSMap("SSSMap", 2D) = "black" {}
		_Base2SSSLerp("Base2SSSLerp", Range( 0 , 1)) = 0.5
		_SpecularRange("SpecularRange", Range( 0 , 1)) = 0.5
		_SpecularIntensity("SpecularIntensity", Range( 0 , 10)) = 1
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
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _SSSMap;
			uniform float4 _SSSMap_ST;
			uniform float _Base2SSSLerp;
			uniform samplerCUBE _CubeMap;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _CubeMapMip;
			uniform float3 _F_BSP;
			uniform sampler2D _MatCap;
			uniform float _MatCapScale;
			uniform float _SSSScale;
			uniform float _SpecularRange;
			uniform float _SpecularIntensity;

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				float3 normalizeWorldNormal = normalize( UnityObjectToWorldNormal(v.ase_normal) );
				o.ase_texcoord5.xyz = normalizeWorldNormal;
				
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
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
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float dotResult13 = dot( normalizedWorldNormal , worldSpaceLightDir );
				float4 _Vector0 = float4(-1,1,0.2,1.2);
				float2 uv_MainTex = i.ase_texcoord2.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode9 = tex2D( _MainTex, uv_MainTex );
				float2 uv_SSSMap = i.ase_texcoord2.xyz.xy * _SSSMap_ST.xy + _SSSMap_ST.zw;
				float4 tex2DNode42 = tex2D( _SSSMap, uv_SSSMap );
				float4 SSSMap45 = tex2DNode42;
				float4 lerpResult48 = lerp( tex2DNode9 , SSSMap45 , _Base2SSSLerp);
				float4 Diffuse25 = ( (_Vector0.z + (dotResult13 - _Vector0.x) * (_Vector0.w - _Vector0.z) / (_Vector0.y - _Vector0.x)) * lerpResult48 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float2 uv_NormalMap = i.ase_texcoord2.xyz.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal5 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
				float3 worldNormal5 = normalize( float3(dot(tanToWorld0,tanNormal5), dot(tanToWorld1,tanNormal5), dot(tanToWorld2,tanNormal5)) );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeWorldNormal = i.ase_texcoord5.xyz;
				float fresnelNdotV19 = dot( normalizeWorldNormal, ase_worldViewDir );
				float fresnelNode19 = ( _F_BSP.x + _F_BSP.y * pow( max( 1.0 - fresnelNdotV19 , 0.0001 ), _F_BSP.z ) );
				float4 CubeMapReflection24 = ( texCUBElod( _CubeMap, float4( reflect( -ase_worldViewDir , worldNormal5 ), _CubeMapMip) ) * saturate( fresnelNode19 ) );
				float3 worldToViewDir31 = mul( UNITY_MATRIX_V, float4( normalizedWorldNormal, 0 ) ).xyz;
				float4 MatCap36 = tex2D( _MatCap, ( ( worldToViewDir31 * 0.5 ) + 0.5 ).xy );
				float3 Normal51 = worldNormal5;
				float3 normalizeResult56 = normalize( ( ase_worldViewDir + worldSpaceLightDir ) );
				float dotResult57 = dot( Normal51 , normalizeResult56 );
				float Specular66 = ( pow( saturate( dotResult57 ) , ( _SpecularRange * 1200.0 ) ) * _SpecularIntensity );
				
				
				finalColor = ( Diffuse25 + CubeMapReflection24 + ( MatCap36 * _MatCapScale ) + ( tex2DNode42 * _SSSScale ) + Specular66 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
245.1429;827.4286;1926.857;1476.714;481.663;282.9194;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;29;-1726.7,-28.50003;Inherit;False;1847.016;643.0159;CubeMapReflection;13;4;8;7;22;5;6;19;23;1;20;21;24;51;CubeMapReflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-1502.012,1173.761;Inherit;False;1677.429;559.7142;Specular;14;53;54;55;52;56;57;64;62;63;58;60;65;61;66;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;8;-1676.7,235.3636;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;03b8f939c72ba8e45946e7dc13573d56;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;54;-1388.012,1367.761;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;53;-1452.012,1523.761;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;5;-1381.675,244.4825;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;50;-1354.096,690.2873;Inherit;False;1473.006;333.7142;MatCap;7;30;31;34;32;33;35;36;MatCap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1144.43,278.6318;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;30;-1304.096,750.1765;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1209.012,1416.761;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;56;-1055.012,1414.761;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-1345.429,21.49997;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;42;251.5553,577.4377;Inherit;True;Property;_SSSMap;SSSMap;8;0;Create;True;0;0;0;False;0;False;-1;None;f57cfca5ce3b16b4c83acb626f814602;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;31;-1058.832,740.2873;Inherit;False;World;View;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1092.013,1223.761;Inherit;False;51;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1230.798,-728.3752;Inherit;False;1322.168;651.3923;Diffuse;11;12;11;17;13;9;16;18;25;40;48;46;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1027.832,909.2872;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;22;-1062.74,431.6588;Inherit;False;Property;_F_BSP;F_BSP;3;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,1.31;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;621.5553,519.4377;Inherit;False;SSSMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;11;-1154.608,-678.3752;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;57;-858.0121,1286.761;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;7;-1162.429,51.49997;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-835.0121,1610.761;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;1200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-882.0121,1498.761;Inherit;False;Property;_SpecularRange;SpecularRange;10;0;Create;True;0;0;0;False;0;False;0.5;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;12;-1145.608,-502.3751;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-825.8327,748.2873;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;13;-903.6082,-629.3752;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-1018.008,-140.8246;Inherit;False;45;SSSMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;58;-715.012,1298.761;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-824.0078,-112.8246;Inherit;False;Property;_Base2SSSLerp;Base2SSSLerp;9;0;Create;True;0;0;0;False;0;False;0.5;0.297;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-621.0118,1500.761;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;17;-854.3966,-524.8839;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;-1,1,0.2,1.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ReflectOpNode;6;-938.4287,148.5;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-654.8327,780.2873;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1402.227,410.2025;Inherit;False;Property;_CubeMapMip;CubeMapMip;4;0;Create;True;0;0;0;False;0;False;0;5.8;0;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;19;-818.969,411.1824;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-1187.798,-343.9829;Inherit;True;Property;_MainTex;_MainTex;2;0;Create;True;0;0;0;False;0;False;-1;None;24caf6f25db36814cafe07a1b48642ca;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-732.5198,139.3184;Inherit;True;Property;_CubeMap;CubeMap;0;0;Create;True;0;0;0;False;0;False;-1;None;fe393d7833ef5a340ad24c634a4336c0;True;0;False;white;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;65;-529.0115,1618.761;Inherit;False;Property;_SpecularIntensity;SpecularIntensity;11;0;Create;True;0;0;0;False;0;False;1;0.7;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;60;-504.0114,1286.761;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;20;-518.969,392.1824;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-712.0078,-273.8246;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;16;-627.3966,-517.8837;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-487.7439,743.9096;Inherit;True;Property;_MatCap;MatCap;5;0;Create;True;0;0;0;False;0;False;-1;None;f3cae1b4c7c8d3d44a5c0d332bcaf33c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-104.5187,759.3334;Inherit;False;MatCap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-355.969,193.1824;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-224.0115,1280.761;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-343.3624,-432.7383;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;39;253.3237,119.6273;Inherit;False;Property;_MatCapScale;MatCapScale;6;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-132.0576,-456.5009;Inherit;False;Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-48.01152,1280.761;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;360.5553,802.4377;Inherit;False;Property;_SSSScale;SSSScale;7;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;290.3237,28.62726;Inherit;False;36;MatCap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-129.9703,198.5026;Inherit;False;CubeMapReflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;730.3237,-16.37274;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;482.8398,-110.9243;Inherit;False;24;CubeMapReflection;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;641.5511,846.5085;Inherit;False;66;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;632.5553,654.4377;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;465.8397,-226.9243;Inherit;False;25;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;966.1304,0.7151642;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-422.8392,-287.8754;Inherit;False;BaseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;72;243.337,305.0806;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;69;463.6354,177.7346;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;74;712.337,218.0806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;253.337,196.0806;Inherit;False;51;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;73;578.337,220.0806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1128.511,-128.9142;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/05/CubeMatCap;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;5;0;8;0
WireConnection;51;0;5;0
WireConnection;55;0;54;0
WireConnection;55;1;53;0
WireConnection;56;0;55;0
WireConnection;31;0;30;0
WireConnection;45;0;42;0
WireConnection;57;0;52;0
WireConnection;57;1;56;0
WireConnection;7;0;4;0
WireConnection;32;0;31;0
WireConnection;32;1;34;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;58;0;57;0
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;6;0;7;0
WireConnection;6;1;5;0
WireConnection;33;0;32;0
WireConnection;33;1;34;0
WireConnection;19;1;22;1
WireConnection;19;2;22;2
WireConnection;19;3;22;3
WireConnection;1;1;6;0
WireConnection;1;2;23;0
WireConnection;60;0;58;0
WireConnection;60;1;63;0
WireConnection;20;0;19;0
WireConnection;48;0;9;0
WireConnection;48;1;46;0
WireConnection;48;2;49;0
WireConnection;16;0;13;0
WireConnection;16;1;17;1
WireConnection;16;2;17;2
WireConnection;16;3;17;3
WireConnection;16;4;17;4
WireConnection;35;1;33;0
WireConnection;36;0;35;0
WireConnection;21;0;1;0
WireConnection;21;1;20;0
WireConnection;61;0;60;0
WireConnection;61;1;65;0
WireConnection;18;0;16;0
WireConnection;18;1;48;0
WireConnection;25;0;18;0
WireConnection;66;0;61;0
WireConnection;24;0;21;0
WireConnection;38;0;37;0
WireConnection;38;1;39;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;10;0;26;0
WireConnection;10;1;27;0
WireConnection;10;2;38;0
WireConnection;10;3;44;0
WireConnection;10;4;67;0
WireConnection;40;0;9;0
WireConnection;69;0;70;0
WireConnection;69;1;72;0
WireConnection;74;0;73;0
WireConnection;73;0;69;0
WireConnection;0;0;10;0
ASEEND*/
//CHKSM=895EC1CF4C7C5D9196B1920A545DE56241607CD7