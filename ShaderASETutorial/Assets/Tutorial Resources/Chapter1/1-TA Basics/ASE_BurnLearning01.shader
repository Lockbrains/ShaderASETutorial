// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/ASE_BurnLearning01"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Width("Width", Float) = 0.1
		_Global_BurningValue("_Global_BurningValue", Float) = 0
		_NoiseScale("NoiseScale", Float) = 5
		[HDR]_BurningColor("BurningColor", Color) = (1,0,0,0)
		_burningRange("burningRange", Float) = 0.1
		[HDR]_Global_BurningColor("_Global_BurningColor", Color) = (1,0,0,0)
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv2_texcoord2;
			float3 worldPos;
		};

		uniform sampler2D _MainTex;
		uniform float _NoiseScale;
		uniform float _Global_BurningValue;
		uniform float _Width;
		uniform float _burningRange;
		uniform float4 _BurningColor;
		uniform float4 _Global_BurningColor;


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


		float4 MyBurningFunction41( float posy, float noise, float value, float width, float burningRange, float4 color, float4 burningColor )
		{
			float test = posy-noise-value;
			clip(test);
			//highlight
			if(test<width)
			    return color;
			return smoothstep(burningRange,0,test)*burningColor;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = tex2D( _MainTex, i.uv2_texcoord2 ).rgb;
			float3 ase_worldPos = i.worldPos;
			float posy41 = ase_worldPos.y;
			float gradientNoise30 = GradientNoise(i.uv2_texcoord2,_NoiseScale);
			gradientNoise30 = gradientNoise30*0.5 + 0.5;
			float noise41 = gradientNoise30;
			float value41 = _Global_BurningValue;
			float width41 = _Width;
			float burningRange41 = _burningRange;
			float4 color41 = _BurningColor;
			float4 burningColor41 = _Global_BurningColor;
			float4 localMyBurningFunction41 = MyBurningFunction41( posy41 , noise41 , value41 , width41 , burningRange41 , color41 , burningColor41 );
			o.Emission = localMyBurningFunction41.xyz;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
284;209.7143;1699.429;773.2858;1165.896;268.8139;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-909.5616,105.2108;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-783.5616,242.2109;Inherit;False;Property;_NoiseScale;NoiseScale;3;0;Create;True;0;0;0;False;0;False;5;8.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;28;-108.0271,43.585;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;37;-396.3004,455.6786;Inherit;False;Property;_Width;Width;1;0;Create;True;0;0;0;False;0;False;0.1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-421.7924,599.5363;Inherit;False;Property;_BurningColor;BurningColor;4;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,0;59.01769,1.544966,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;30;-478.0511,75.90511;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-309.8144,-314.6428;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-693.3984,366.0326;Inherit;False;Property;_Global_BurningValue;_Global_BurningValue;2;0;Create;True;0;0;0;False;0;False;0;-1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-69.44244,618.8904;Inherit;False;Property;_Global_BurningColor;_Global_BurningColor;6;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,0;1,0.0691991,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-223.6423,454.8299;Inherit;False;Property;_burningRange;burningRange;5;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;72.18571,-337.6429;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;7bb9f7571bfbc7d48b0dcd5fa41095b4;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-537.1517,-269.5719;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;46;-264.1513,-49.01499;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;47;-794.9484,-320.8218;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-704.7979,-154.76;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;41;258.7075,114.1851;Inherit;False;float test = posy-noise-value@$clip(test)@$//highlight$if(test<width)$    return color@$$return smoothstep(burningRange,0,test)*burningColor@$;4;False;7;False;posy;FLOAT;0;In;;Inherit;False;False;noise;FLOAT;0;In;;Inherit;False;False;value;FLOAT;0;In;;Inherit;False;False;width;FLOAT;0;In;;Inherit;False;True;burningRange;FLOAT;0.2;In;;Inherit;False;False;color;FLOAT4;5,0,0,0;In;;Inherit;False;True;burningColor;FLOAT4;1,0,0,0;In;;Inherit;False;MyBurningFunction;True;False;0;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0.2;False;5;FLOAT4;5,0,0,0;False;6;FLOAT4;1,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-63.349,-141.7398;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;3;761.7416,-93.87032;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TAPro/ASE_BurnLearning01;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;24;-3431.475,-415.8262;Inherit;False;1786.937;765.1497;Anim;0;Anim;1,1,1,1;0;0
WireConnection;30;0;31;0
WireConnection;30;1;32;0
WireConnection;5;1;4;0
WireConnection;48;0;47;3
WireConnection;48;1;49;0
WireConnection;41;0;28;2
WireConnection;41;1;30;0
WireConnection;41;2;29;0
WireConnection;41;3;37;0
WireConnection;41;4;44;0
WireConnection;41;5;39;0
WireConnection;41;6;45;0
WireConnection;3;0;5;0
WireConnection;3;2;41;0
ASEEND*/
//CHKSM=785FBFE3470CB49FAC50E658E635726773CEF69D