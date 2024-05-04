// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Iridescence"
{
	Properties
	{
		_IridescenceLut("IridescenceLut", 2D) = "white" {}
		_MatCap("MatCap", 2D) = "white" {}
		_IrriIntensity("IrriIntensity", Float) = 2
		_MatCapScale("MatCapScale", Float) = 1
		_CubeMap("CubeMap", CUBE) = "white" {}
		_EnvCubeMap("EnvCubeMap", CUBE) = "white" {}
		_Roughness("Roughness", Range( 0 , 1)) = 0.5
		_Fresnel_BSP("Fresnel_BSP", Vector) = (0,0,0,0)
		_IrrSinVec("IrrSinVec", Vector) = (1,1,1,1)
		_EnvCubeLevel("EnvCubeLevel", Range( 0 , 11)) = 0
		_EnvCubeIntensity("EnvCubeIntensity", Range( 0 , 10)) = 0
		_AlphaOffset("AlphaOffset", Range( -1 , 1)) = 0
		_RotateAngle("RotateAngle", Float) = 0
		_RotateAxis("RotateAxis", Vector) = (0,1,0,0)
		_Mask("Mask", 2D) = "white" {}
		[Toggle(_ENABLEMASK_ON)] _EnableMask("EnableMask", Float) = 0
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
			#pragma shader_feature_local _ENABLEMASK_ON


			struct MeshData
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
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

			//This is a late directive
			
			uniform sampler2D _IridescenceLut;
			uniform float _IrriIntensity;
			uniform float _Roughness;
			uniform samplerCUBE _EnvCubeMap;
			uniform float3 _RotateAxis;
			uniform float _RotateAngle;
			uniform float4 _IrrSinVec;
			uniform float _EnvCubeLevel;
			uniform float _EnvCubeIntensity;
			uniform sampler2D _MatCap;
			uniform float _MatCapScale;
			uniform samplerCUBE _CubeMap;
			uniform float3 _Fresnel_BSP;
			uniform float _AlphaOffset;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			struct Gradient
			{
				int type;
				int colorsLength;
				int alphasLength;
				float4 colors[8];
				float2 alphas[8];
			};
			
			Gradient NewGradient(int type, int colorsLength, int alphasLength, 
			float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
			float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
			{
				Gradient g;
				g.type = type;
				g.colorsLength = colorsLength;
				g.alphasLength = alphasLength;
				g.colors[ 0 ] = colors0;
				g.colors[ 1 ] = colors1;
				g.colors[ 2 ] = colors2;
				g.colors[ 3 ] = colors3;
				g.colors[ 4 ] = colors4;
				g.colors[ 5 ] = colors5;
				g.colors[ 6 ] = colors6;
				g.colors[ 7 ] = colors7;
				g.alphas[ 0 ] = alphas0;
				g.alphas[ 1 ] = alphas1;
				g.alphas[ 2 ] = alphas2;
				g.alphas[ 3 ] = alphas3;
				g.alphas[ 4 ] = alphas4;
				g.alphas[ 5 ] = alphas5;
				g.alphas[ 6 ] = alphas6;
				g.alphas[ 7 ] = alphas7;
				return g;
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 WorldNormal85 = normalizedWorldNormal;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float dotResult15 = dot( reflect( worldSpaceLightDir , WorldNormal85 ) , ase_worldViewDir );
				float temp_output_158_0 = (0.0 + (dotResult15 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
				float3 normalizeResult162 = normalize( ( worldSpaceLightDir + ase_worldViewDir ) );
				float dotResult40 = dot( WorldNormal85 , normalizeResult162 );
				float2 appendResult18 = (float2(frac( ( temp_output_158_0 + 0.3156 + ( dotResult40 * 0.1 ) ) ) , 0.5));
				Gradient gradient25 = NewGradient( 0, 5, 2, float4( 0, 0, 0, 0 ), float4( 0, 0, 0, 0.6470588 ), float4( 0.9390263, 0.9390263, 0.9390263, 0.720592 ), float4( 0.04321859, 0.04321859, 0.04321859, 0.8 ), float4( 0, 0, 0, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float dotResult22 = dot( WorldNormal85 , ase_worldViewDir );
				float4 Iridescence44 = ( tex2D( _IridescenceLut, appendResult18 ) * SampleGradient( gradient25, dotResult22 ) * _IrriIntensity * temp_output_158_0 );
				float temp_output_4_0_g17 = _Roughness;
				float clampResult24_g18 = clamp( temp_output_4_0_g17 , 0.01 , 0.99 );
				float temp_output_5_0_g18 = ( clampResult24_g18 * clampResult24_g18 );
				float3 temp_output_3_0_g17 = normalizedWorldNormal;
				float3 normalizeResult5_g17 = normalize( temp_output_3_0_g17 );
				float3 normalizeResult27_g18 = normalize( normalizeResult5_g17 );
				float3 temp_output_2_0_g17 = worldSpaceLightDir;
				float3 normalizeResult6_g17 = normalize( temp_output_2_0_g17 );
				float3 temp_output_1_0_g17 = ase_worldViewDir;
				float3 normalizeResult7_g17 = normalize( temp_output_1_0_g17 );
				float3 normalizeResult13_g17 = normalize( ( normalizeResult6_g17 + normalizeResult7_g17 ) );
				float3 normalizeResult28_g18 = normalize( normalizeResult13_g17 );
				float dotResult6_g18 = dot( normalizeResult27_g18 , normalizeResult28_g18 );
				float temp_output_8_0_g18 = saturate( dotResult6_g18 );
				float temp_output_15_0_g18 = ( ( ( temp_output_8_0_g18 * temp_output_8_0_g18 ) * ( temp_output_5_0_g18 - 1.0 ) ) + 1.0 );
				float3 normalizeResult14_g19 = normalize( temp_output_3_0_g17 );
				float3 normalizeResult15_g19 = normalize( normalizeResult7_g17 );
				float dotResult3_g19 = dot( normalizeResult14_g19 , normalizeResult15_g19 );
				float Specular68 = ( ( temp_output_5_0_g18 / max( ( temp_output_15_0_g18 * temp_output_15_0_g18 * UNITY_PI ) , 0.0001 ) ) * ( ( pow( ( 1.0 - saturate( dotResult3_g19 ) ) , 5.0 ) * ( 1.0 - 0.04 ) ) + 0.04 ) );
				float3 normalizeResult148 = normalize( _RotateAxis );
				float3 rotatedValue145 = RotateAroundAxis( float3( 0,0,0 ), ase_worldViewDir, normalizeResult148, _RotateAngle );
				float4 Env135 = ( texCUBElod( _EnvCubeMap, float4( ( sin( ( float4( ( rotatedValue145 + normalizedWorldNormal ) , 0.0 ) * _IrrSinVec ) ) * _IrrSinVec.w ).xyz, _EnvCubeLevel) ) * _EnvCubeIntensity );
				float3 worldToViewDir104 = normalize( mul( UNITY_MATRIX_V, float4( normalizedWorldNormal, 0 ) ).xyz );
				float4 Base113 = tex2D( _MatCap, (( ( ( worldToViewDir104 * _MatCapScale ) * 0.5 ) + 0.5 )).xy );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV60 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode60 = ( _Fresnel_BSP.x + _Fresnel_BSP.y * pow( max( 1.0 - fresnelNdotV60 , 0.0001 ), _Fresnel_BSP.z ) );
				float4 Glass62 = ( texCUBE( _CubeMap, reflect( -ase_worldViewDir , WorldNormal85 ) ) * saturate( fresnelNode60 ) );
				float4 temp_output_64_0 = ( Iridescence44 + Specular68 + Env135 + Base113 + Glass62 );
				float luminance139 = Luminance(temp_output_64_0.rgb);
				float4 appendResult140 = (float4(temp_output_64_0.rgb , saturate( ( luminance139 + _AlphaOffset ) )));
				float2 uv_Mask = i.ase_texcoord2.xyz.xy * _Mask_ST.xy + _Mask_ST.zw;
				clip( tex2D( _Mask, uv_Mask ).r - 0.1);
				#ifdef _ENABLEMASK_ON
				float4 staticSwitch151 = appendResult140;
				#else
				float4 staticSwitch151 = appendResult140;
				#endif
				
				
				finalColor = staticSwitch151;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
354.2857;362.2857;1775.429;787.5715;-1311.894;-824.8325;1.226532;True;False
Node;AmplifyShaderEditor.CommentaryNode;100;-636.1259,834.4324;Inherit;False;1741.136;856.9761;Glass;12;85;86;155;53;52;62;144;58;61;60;49;115;Glass;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;86;-370.4241,1363.854;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;99;-1508.058,-219.8161;Inherit;False;2619.285;998.9199;Iridescence;28;33;91;14;34;93;15;43;40;42;36;35;23;37;19;92;25;22;18;26;17;31;27;44;158;161;162;160;159;Iridescence;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;153;-1623.098,2756.225;Inherit;False;2712.482;516.561;Env;16;130;146;138;135;137;134;133;119;117;131;129;125;145;148;147;116;Env;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;159;-1486.808,396.8586;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;160;-1430.269,548.9298;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-148.5145,1366.744;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-1406.058,-15.57751;Inherit;False;85;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;33;-1433.171,-162.8161;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;161;-1256.539,468.8943;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;146;-1507.948,2840.483;Inherit;False;Property;_RotateAxis;RotateAxis;13;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;147;-1344.116,2952.819;Inherit;False;Property;_RotateAngle;RotateAngle;12;0;Create;True;0;0;0;False;0;False;0;25.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1285.058,257.4226;Inherit;False;85;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;148;-1292.116,2849.819;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;116;-1326.27,3051.88;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;34;-1056.171,-128.8161;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;102;-1075.53,2376.373;Inherit;False;2165.744;329.9048;Base;10;110;109;108;106;107;104;105;103;113;112;Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;162;-1126.539,457.8943;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;14;-1044.632,-22.74455;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;15;-807.6331,-101.1445;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;119;-996.0602,3045.646;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;43;-894.1069,420.3363;Inherit;False;Constant;_Float4;Float 4;1;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;40;-1009.107,268.3363;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;145;-1090.246,2863.649;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;103;-913.379,2466.5;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;36;-697.7313,77.76842;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;0;False;0;False;0.3156;0.3156;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;158;-650.2686,-143.3514;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;104;-713.9243,2467.083;Inherit;False;World;View;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-667.4797,2892.491;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;130;-630.5372,3082.65;Inherit;False;Property;_IrrSinVec;IrrSinVec;8;0;Create;True;0;0;0;False;0;False;1,1,1,1;2,2,2,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-644.1073,245.3362;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-676.7604,2609.858;Inherit;False;Property;_MatCapScale;MatCapScale;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-419.9485,2613.115;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-438.8658,2490.4;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;52;-508.1703,947.8973;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-412.5854,44.55943;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-462.5477,2950.003;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FractNode;37;-249.5855,42.33238;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-239.9487,2477.115;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-483.0528,1112.345;Inherit;False;85;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;129;-249.5479,2928.003;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-301.0428,209.4719;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;23;-574.9235,559.2465;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;53;-324.1693,956.8973;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;115;119.302,1180.62;Inherit;False;Property;_Fresnel_BSP;Fresnel_BSP;7;0;Create;True;0;0;0;False;0;False;0,0,0;0,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;92;-611.0589,457.4226;Inherit;False;85;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;22;-351.9234,455.2467;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;60;339.4325,1157.579;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-136.3273,3070.358;Inherit;False;Property;_EnvCubeLevel;EnvCubeLevel;9;0;Create;True;0;0;0;False;0;False;0;6.12;0;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;49;-121.296,953.2358;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GradientNode;25;-395.9885,355.3951;Inherit;False;0;5;2;0,0,0,0;0,0,0,0.6470588;0.9390263,0.9390263,0.9390263,0.720592;0.04321859,0.04321859,0.04321859,0.8;0,0,0,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.CommentaryNode;101;-1424.113,1720.154;Inherit;False;2515.617;634.1882;Specular;20;180;68;175;174;179;173;177;169;176;178;168;172;170;167;171;84;79;82;83;95;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-75.94864,2488.115;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-49.13384,93.70279;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-95.54781,2937.003;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;17;170.8662,-150.8702;Inherit;True;Property;_IridescenceLut;IridescenceLut;0;0;Create;True;0;0;0;False;0;False;-1;None;3e6b5eeb954695149808a2fc7b79a212;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;61;638.6292,1103.017;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;26;-115.9885,361.3951;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;133;281.6405,2911.726;Inherit;True;Property;_EnvCubeMap;EnvCubeMap;5;0;Create;True;0;0;0;False;0;False;-1;None;db5d9ec0a45e4c048aa0d548acd257d2;True;0;False;white;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;145.6205,2238.625;Inherit;False;Property;_Roughness;Roughness;6;0;Create;True;0;0;0;False;0;False;0.5;0.028;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;266.3436,384.8557;Inherit;False;Property;_IrriIntensity;IrriIntensity;2;0;Create;True;0;0;0;False;0;False;2;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;95;219.6183,1770.154;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;83;200.5039,1922.051;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;110;63.05135,2494.115;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;58;251.6557,917.0962;Inherit;True;Property;_CubeMap;CubeMap;4;0;Create;True;0;0;0;False;0;False;-1;None;c58015095c9859343b3c0a6f9540e0b8;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;138;304.5844,3109.332;Inherit;False;Property;_EnvCubeIntensity;EnvCubeIntensity;10;0;Create;True;0;0;0;False;0;False;0;0.91;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;225.5038,2070.05;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;738.7695,920.0803;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;717.6068,2927.31;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;82;541.504,1801.052;Inherit;False;GGX;-1;;17;192e3c292e812304aab2b4364d8121be;0;4;3;FLOAT3;0,0,1;False;2;FLOAT3;0,0,1;False;1;FLOAT3;0,0,1;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;112;311.2047,2463.917;Inherit;True;Property;_MatCap;MatCap;1;0;Create;True;0;0;0;False;0;False;-1;None;b50425a06e1957449a10eb4ead4fd4e2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;669.2822,45.76502;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;899.3057,915.8197;Inherit;False;Glass;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;872.356,41.44277;Inherit;False;Iridescence;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;881.4136,2913.862;Inherit;False;Env;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;674.7533,2465.822;Inherit;False;Base;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;859.0751,1821.603;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;1413.457,956.7181;Inherit;False;44;Iridescence;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;1407.852,1311.001;Inherit;False;135;Env;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;1419.795,1073.52;Inherit;False;62;Glass;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;1399.443,1209.01;Inherit;False;68;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;1410.034,1427.577;Inherit;False;113;Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;1704.796,1039.52;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LuminanceNode;139;1884.341,1164.663;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;1768.565,1253.59;Inherit;False;Property;_AlphaOffset;AlphaOffset;11;0;Create;True;0;0;0;False;0;False;0;0.35;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;2087.564,1200.59;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;143;2210.564,1201.447;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;140;2368.341,1059.663;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;150;2176.378,1358.784;Inherit;True;Property;_Mask;Mask;14;0;Create;True;0;0;0;False;0;False;-1;None;b7a3dbfb04d259646b46d4cf6c14d4c9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;152;2311.378,1614.784;Inherit;False;Constant;_Float7;Float 7;17;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;149;2567.378,1360.784;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;1406.464,1595.517;Inherit;False;44;Iridescence;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-760.8885,1944.613;Inherit;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;0;False;0;False;1200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-1142.437,1802.302;Inherit;False;85;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;167;-1287.647,2093.81;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;174;-492.8888,1811.613;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;1289.388,1143.067;Inherit;False;180;SpecularBP;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;169;-866.4838,1813.216;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-573.8887,1955.613;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;1623.552,1634.621;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;-1113.917,2013.774;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-835.8886,2077.613;Inherit;False;Property;_SpeuclarRange;SpeuclarRange;16;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-569.8888,2149.613;Inherit;False;Property;_SpeuclarIntensity;SpeuclarIntensity;17;0;Create;True;0;0;0;False;0;False;0;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-320.8886,1813.613;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;-155.5824,1818.984;Inherit;False;SpecularBP;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;171;-1344.186,1941.738;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;173;-689.196,1817.902;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;172;-983.9169,2002.774;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;1448.552,1695.621;Inherit;False;135;Env;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;151;2809.739,1063.025;Inherit;False;Property;_EnableMask;EnableMask;15;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3183.624,1059.958;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Iridescence;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;85;0;86;0
WireConnection;161;0;159;0
WireConnection;161;1;160;0
WireConnection;148;0;146;0
WireConnection;34;0;33;0
WireConnection;34;1;91;0
WireConnection;162;0;161;0
WireConnection;15;0;34;0
WireConnection;15;1;14;0
WireConnection;40;0;93;0
WireConnection;40;1;162;0
WireConnection;145;0;148;0
WireConnection;145;1;147;0
WireConnection;145;3;116;0
WireConnection;158;0;15;0
WireConnection;104;0;103;0
WireConnection;117;0;145;0
WireConnection;117;1;119;0
WireConnection;42;0;40;0
WireConnection;42;1;43;0
WireConnection;107;0;104;0
WireConnection;107;1;105;0
WireConnection;35;0;158;0
WireConnection;35;1;36;0
WireConnection;35;2;42;0
WireConnection;125;0;117;0
WireConnection;125;1;130;0
WireConnection;37;0;35;0
WireConnection;108;0;107;0
WireConnection;108;1;106;0
WireConnection;129;0;125;0
WireConnection;53;0;52;0
WireConnection;22;0;92;0
WireConnection;22;1;23;0
WireConnection;60;1;115;1
WireConnection;60;2;115;2
WireConnection;60;3;115;3
WireConnection;49;0;53;0
WireConnection;49;1;155;0
WireConnection;109;0;108;0
WireConnection;109;1;106;0
WireConnection;18;0;37;0
WireConnection;18;1;19;0
WireConnection;131;0;129;0
WireConnection;131;1;130;4
WireConnection;17;1;18;0
WireConnection;61;0;60;0
WireConnection;26;0;25;0
WireConnection;26;1;22;0
WireConnection;133;1;131;0
WireConnection;133;2;134;0
WireConnection;110;0;109;0
WireConnection;58;1;49;0
WireConnection;144;0;58;0
WireConnection;144;1;61;0
WireConnection;137;0;133;0
WireConnection;137;1;138;0
WireConnection;82;3;95;0
WireConnection;82;2;83;0
WireConnection;82;1;84;0
WireConnection;82;4;79;0
WireConnection;112;1;110;0
WireConnection;27;0;17;0
WireConnection;27;1;26;0
WireConnection;27;2;31;0
WireConnection;27;3;158;0
WireConnection;62;0;144;0
WireConnection;44;0;27;0
WireConnection;135;0;137;0
WireConnection;113;0;112;0
WireConnection;68;0;82;0
WireConnection;64;0;46;0
WireConnection;64;1;69;0
WireConnection;64;2;136;0
WireConnection;64;3;114;0
WireConnection;64;4;63;0
WireConnection;139;0;64;0
WireConnection;141;0;139;0
WireConnection;141;1;142;0
WireConnection;143;0;141;0
WireConnection;140;0;64;0
WireConnection;140;3;143;0
WireConnection;149;0;140;0
WireConnection;149;1;150;1
WireConnection;149;2;152;0
WireConnection;174;0;173;0
WireConnection;174;1;177;0
WireConnection;169;0;168;0
WireConnection;169;1;172;0
WireConnection;177;0;176;0
WireConnection;177;1;178;0
WireConnection;184;0;182;0
WireConnection;184;1;183;0
WireConnection;170;0;171;0
WireConnection;170;1;167;0
WireConnection;175;0;174;0
WireConnection;175;1;179;0
WireConnection;180;0;175;0
WireConnection;173;0;169;0
WireConnection;172;0;170;0
WireConnection;151;1;140;0
WireConnection;151;0;149;0
WireConnection;0;0;151;0
ASEEND*/
//CHKSM=206A2B1252AE37D78564E4C0803B564FB764AF06