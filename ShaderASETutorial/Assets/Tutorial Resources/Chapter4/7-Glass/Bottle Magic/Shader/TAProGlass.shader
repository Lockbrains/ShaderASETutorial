// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/Glass"
{
	Properties
	{
		_MatCap("MatCap", 2D) = "white" {}
		_MatCap2("MatCap2", 2D) = "white" {}
		_MatCapScale("MatCapScale", Float) = 1
		_Color0("Color 0", Color) = (0,0,0,0)
		_CubeMap("CubeMap", CUBE) = "black" {}
		_ReflectionIntensity("ReflectionIntensity", Range( 0 , 1)) = 0.4235294
		[Toggle(_ENBALEUVCUT_ON)] _EnbaleUVCut("EnbaleUVCut", Float) = 0
		_UVCut("UVCut", Range( 0 , 1)) = 0
		_Shell("Shell", Float) = 0
		_DartIntensity("DartIntensity", Float) = 1
		_DartScale("DartScale", Float) = 10

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
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" "Queue"="Transparent" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENBALEUVCUT_ON


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

			uniform float _Shell;
			uniform sampler2D _MatCap;
			uniform float _MatCapScale;
			uniform samplerCUBE _CubeMap;
			uniform float _ReflectionIntensity;
			uniform sampler2D _MatCap2;
			uniform float4 _Color0;
			uniform float _DartScale;
			uniform float _DartIntensity;
			uniform float _UVCut;
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
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 Anim95 = ( v.ase_normal * _Shell );
				
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
				vertexValue = Anim95;
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
				float3 worldToViewDir17 = normalize( mul( UNITY_MATRIX_V, float4( normalizedWorldNormal, 0 ) ).xyz );
				float2 temp_output_21_0 = (( ( ( worldToViewDir17 * _MatCapScale ) * 0.5 ) + 0.5 )).xy;
				float4 Base60 = tex2D( _MatCap, temp_output_21_0 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float4 Reflection57 = ( texCUBE( _CubeMap, reflect( -ase_worldViewDir , normalizedWorldNormal ) ) * _ReflectionIntensity );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV66 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode66 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV66 , 0.0001 ), 1.0 ) );
				float ReflectionFresnel67 = fresnelNode66;
				float4 lerpResult68 = lerp( Base60 , Reflection57 , ReflectionFresnel67);
				float2 MatcapUV38 = temp_output_21_0;
				float fresnelNdotV36 = dot( ase_worldNormal, ase_worldViewDir );
				float ior36 = 2.0;
				ior36 = pow( max( ( 1 - ior36 ) / ( 1 + ior36 ) , 0.0001 ), 2 );
				float fresnelNode36 = ( ior36 + ( 1.0 - ior36 ) * pow( max( 1.0 - fresnelNdotV36 , 0.0001 ), 5 ) );
				float4 Refract61 = tex2D( _MatCap2, ( MatcapUV38 + saturate( fresnelNode36 ) ) );
				float2 texCoord91 = i.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float simpleNoise90 = SimpleNoise( texCoord91*_DartScale );
				float4 FinalColor49 = ( lerpResult68 + Refract61 + _Color0 + ( simpleNoise90 * _DartIntensity ) );
				float luminance26 = Luminance(max( Base60 , Refract61 ).rgb);
				float Alpha47 = luminance26;
				float2 texCoord80 = i.ase_texcoord2.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				clip( _UVCut - texCoord80.y);
				#ifdef _ENBALEUVCUT_ON
				float staticSwitch76 = 0.0;
				#else
				float staticSwitch76 = 0.0;
				#endif
				float4 appendResult3 = (float4(FinalColor49.rgb , ( Alpha47 + staticSwitch76 )));
				float4 ReturnColor93 = appendResult3;
				
				
				finalColor = ReturnColor93;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
330.8571;317.1429;2194.286;711.0001;-1240.93;546.655;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;72;-2482.503,-608.9788;Inherit;False;2486.169;351.8945;Base;11;16;17;31;29;20;18;19;21;38;22;60;Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;16;-2423.503,-554.4125;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;17;-2194.049,-555.8304;Inherit;False;World;View;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;31;-2185.885,-401.0548;Inherit;False;Property;_MatCapScale;MatCapScale;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1930.99,-531.5131;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1786.073,-371.7986;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1628.073,-531.7985;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1472.073,-506.7984;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;73;-1732.451,-160.2026;Inherit;False;1730.921;459.1963;Refract;7;51;36;37;39;40;41;61;Refract;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-1320.073,-505.7984;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1665.455,76.30362;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;74;-1530.321,335.7448;Inherit;False;1523.429;641.3871;Reflection;10;54;52;55;53;56;59;58;66;67;57;Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1087.146,-534.4384;Inherit;False;MatcapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;36;-1525.308,41.25986;Inherit;True;SchlickIOR;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;54;-1475.942,397.7448;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;52;-1296.241,522.4933;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;37;-1224.328,43.26379;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;55;-1248.321,410.7447;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1247.26,-56.25222;Inherit;False;38;MatcapUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1010.456,-38.4339;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ReflectOpNode;53;-1025.321,421.7447;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;56;-799.4359,385.7448;Inherit;True;Property;_CubeMap;CubeMap;4;0;Create;True;0;0;0;False;0;False;-1;None;9c261d678785c104abf4c8b211481375;True;0;False;black;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-795.321,598.7444;Inherit;False;Property;_ReflectionIntensity;ReflectionIntensity;5;0;Create;True;0;0;0;False;0;False;0.4235294;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-775.3466,-521.4348;Inherit;True;Property;_MatCap;MatCap;0;0;Create;True;0;0;0;False;0;False;-1;None;b50425a06e1957449a10eb4ead4fd4e2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-816.2776,-59.11912;Inherit;True;Property;_MatCap2;MatCap2;1;0;Create;True;0;0;0;False;0;False;-1;None;d05be2335e9d442498f459f48227ef09;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-398.8532,-524.7515;Inherit;False;Base;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;75;-1320.732,1060.789;Inherit;False;1313.934;1111.837;FinalColor;13;89;49;44;43;68;88;63;62;64;69;90;92;91;FinalColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-388.818,464.2069;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;66;-838.0086,721.4174;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-292.8374,-52.81921;Inherit;False;Refract;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;1000.011,423.6805;Inherit;False;60;Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-471.9187,716.7156;Inherit;False;ReflectionFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-224.7972,442.7243;Inherit;False;Reflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;1001.511,497.6808;Inherit;False;61;Refract;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1003.867,1873.265;Inherit;True;Property;_DartScale;DartScale;10;0;Create;True;0;0;0;False;0;False;10;425.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-1093.867,1753.265;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;64;-988.085,1200.487;Inherit;False;57;Reflection;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;90;-746.8669,1770.265;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-998.8544,1289.337;Inherit;False;67;ReflectionFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-719.8669,2040.267;Inherit;False;Property;_DartIntensity;DartIntensity;9;0;Create;True;0;0;0;False;0;False;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-982.0421,1110.789;Inherit;False;60;Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;46;1214.771,442.679;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-423.8669,1766.265;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;68;-703.7689,1124.996;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;43;-753.3674,1494.71;Inherit;False;Property;_Color0;Color 0;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4399942,0.3969635,0.6320754,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;777.7344,-91.4828;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;81;858.7344,78.51721;Inherit;False;Property;_UVCut;UVCut;7;0;Create;True;0;0;0;False;0;False;0;0.585;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;847.7344,-186.4828;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LuminanceNode;26;1359.152,436.0984;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-728.0416,1359.789;Inherit;False;61;Refract;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;79;1121.734,-87.48279;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;1527.036,430.1281;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;861.734,-270.4828;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-393.249,1165.285;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-238.2263,1156.385;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;1337.816,-300.4044;Inherit;False;47;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;76;1316.734,-209.4828;Inherit;False;Property;_EnbaleUVCut;EnbaleUVCut;6;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;1368.816,-449.4044;Inherit;False;49;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;1589.734,-275.4828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;2075.494,-3.114616;Inherit;False;Property;_Shell;Shell;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;83;2042.494,-169.1146;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;2259.494,-138.1146;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;1768.296,-444.7363;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;1939.119,-451.6491;Inherit;False;ReturnColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;2440.799,-140.7388;Inherit;False;Anim;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;2260.799,-374.7388;Inherit;False;95;Anim;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;2284.799,-485.7388;Inherit;False;93;ReturnColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;15;2660.962,-454.0071;Float;False;True;-1;2;ASEMaterialInspector;100;1;TAPro/Glass;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;83;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;LightMode=ForwardBase;Queue=Transparent=Queue=0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;17;0;16;0
WireConnection;29;0;17;0
WireConnection;29;1;31;0
WireConnection;18;0;29;0
WireConnection;18;1;20;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;21;0;19;0
WireConnection;38;0;21;0
WireConnection;36;2;51;0
WireConnection;37;0;36;0
WireConnection;55;0;54;0
WireConnection;40;0;39;0
WireConnection;40;1;37;0
WireConnection;53;0;55;0
WireConnection;53;1;52;0
WireConnection;56;1;53;0
WireConnection;22;1;21;0
WireConnection;41;1;40;0
WireConnection;60;0;22;0
WireConnection;58;0;56;0
WireConnection;58;1;59;0
WireConnection;61;0;41;0
WireConnection;67;0;66;0
WireConnection;57;0;58;0
WireConnection;90;0;91;0
WireConnection;90;1;92;0
WireConnection;46;0;70;0
WireConnection;46;1;71;0
WireConnection;88;0;90;0
WireConnection;88;1;89;0
WireConnection;68;0;62;0
WireConnection;68;1;64;0
WireConnection;68;2;69;0
WireConnection;26;0;46;0
WireConnection;79;0;78;0
WireConnection;79;1;81;0
WireConnection;79;2;80;2
WireConnection;47;0;26;0
WireConnection;44;0;68;0
WireConnection;44;1;63;0
WireConnection;44;2;43;0
WireConnection;44;3;88;0
WireConnection;49;0;44;0
WireConnection;76;1;77;0
WireConnection;76;0;79;0
WireConnection;82;0;48;0
WireConnection;82;1;76;0
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;3;0;50;0
WireConnection;3;3;82;0
WireConnection;93;0;3;0
WireConnection;95;0;84;0
WireConnection;15;0;94;0
WireConnection;15;1;96;0
ASEEND*/
//CHKSM=79103BDC839DE9D3991728658EC6FD68C0ABFF8E