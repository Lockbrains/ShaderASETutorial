// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE_Burn"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_AlphaTest("AlphaTest", Float) = 0
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _AlphaTest;
			uniform float4 _Global_BurningValue;
			uniform float4 _Global_BurningColor;
			uniform float4 _Global_BurningColorRange;
			//https://www.shadertoy.com/view/XdXGW8
			float2 GradientNoiseDir( float2 x )
			{
				const float2 k = float2( 0.3183099, 0.3678794 );
				x = x * k + k.yx;
				return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
			}
			
			float GradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 i = floor( p );
				float2 f = frac( p );
				float2 u = f * f * ( 3.0 - 2.0 * f );
				return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
						dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
						lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
						dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
			}
			
			float4 BurnningFunction29( float posy, float noise, float burnValue, float width, float4 color, float burningRange, float4 colorRange )
			{
				float test = posy-noise-burnValue;
				clip(test);
				if(test<width)
				   return color;
				return smoothstep(burningRange,0,test)*colorRange;
			}
			

			
			V2FData vert ( MeshData v )
			{
				V2FData o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				clip( tex2DNode1.a - _AlphaTest);
				float posy29 = WorldPosition.y;
				float2 texCoord4 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float gradientNoise3 = GradientNoise(texCoord4,_Global_BurningValue.z);
				gradientNoise3 = gradientNoise3*0.5 + 0.5;
				float noise29 = gradientNoise3;
				float burnValue29 = _Global_BurningValue.x;
				float width29 = _Global_BurningValue.y;
				float4 color29 = _Global_BurningColor;
				float burningRange29 = _Global_BurningValue.w;
				float4 colorRange29 = _Global_BurningColorRange;
				float4 localBurnningFunction29 = BurnningFunction29( posy29 , noise29 , burnValue29 , width29 , color29 , burningRange29 , colorRange29 );
				
				
				finalColor = ( tex2DNode1 + localBurnningFunction29 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
384.5714;315.4286;1699.429;633.2858;1104.314;-99.96962;1.04055;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-992.7144,354.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;18;-1031.174,576.1976;Inherit;False;Global;_Global_BurningValue;_Global_BurningValue;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;-1.74,0.01,10.09,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;14;-649.4361,144.6119;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;1;-448.0659,-190.4102;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;e1361fd45e809864f9b2fa8243bdd8f9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;3;-739.7144,322.5;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-267.0659,47.58981;Inherit;False;Property;_AlphaTest;AlphaTest;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-667.8901,706.891;Inherit;False;Global;_Global_BurningColor;_Global_BurningColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;119.4283,7.313888,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;30;-651.1865,896.1207;Inherit;False;Global;_Global_BurningColorRange;_Global_BurningColorRange;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;3.780393,0.3582789,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClipNode;10;-19.06596,-117.4102;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;29;-197.1865,204.1207;Inherit;False;float test = posy-noise-burnValue@$clip(test)@$if(test<width)$   return color@$return smoothstep(burningRange,0,test)*colorRange@;4;False;7;False;posy;FLOAT;0;In;;Inherit;False;False;noise;FLOAT;0;In;;Inherit;False;False;burnValue;FLOAT;0;In;;Inherit;False;False;width;FLOAT;0.1;In;;Inherit;False;False;color;FLOAT4;5,0,0,0;In;;Inherit;False;False;burningRange;FLOAT;0.1;In;;Inherit;False;True;colorRange;FLOAT4;0,0,0,0;In;;Inherit;False;BurnningFunction;True;False;0;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0.1;False;4;FLOAT4;5,0,0,0;False;5;FLOAT;0.1;False;6;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1409.21,484.5399;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;-1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;15;-1189.209,510.5394;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1414.21,563.5394;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;287.0782,140.6632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;594.255,169.4151;Float;False;True;-1;2;ASEMaterialInspector;100;1;ASE_Burn;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;3;0;4;0
WireConnection;3;1;18;3
WireConnection;10;0;1;0
WireConnection;10;1;1;4
WireConnection;10;2;11;0
WireConnection;29;0;14;2
WireConnection;29;1;3;0
WireConnection;29;2;18;1
WireConnection;29;3;18;2
WireConnection;29;4;26;0
WireConnection;29;5;18;4
WireConnection;29;6;30;0
WireConnection;15;0;16;0
WireConnection;15;1;17;0
WireConnection;27;0;10;0
WireConnection;27;1;29;0
WireConnection;0;0;27;0
ASEEND*/
//CHKSM=B1FCEE590EC85830DB5A96B8E82E7412EB848631