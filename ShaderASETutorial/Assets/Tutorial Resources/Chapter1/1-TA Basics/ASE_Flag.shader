// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE_Flag"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Mask("Mask", 2D) = "white" {}
		_AnimIntensity("AnimIntensity", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _AnimIntensity;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Global_BurningValue;
		uniform float4 _Global_BurningColor;
		uniform float4 _Global_BurningColorRange;
		uniform float _Metallic;
		uniform float _Smoothness;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


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


		float4 BurnningFunction23( float posy, float noise, float burnValue, float width, float4 color, float burningRange, float4 colorRange, float needBurn )
		{
			if(needBurn>0)
			{
			    float test = posy-noise-burnValue;
			    clip(test);
			    if(test<width)
			    return color;
			    return smoothstep(burningRange,0,test)*colorRange;
			}
			return float4(0,0,0,0);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float simplePerlin2D4 = snoise( ( v.texcoord.xy + ( float2( 1,0 ) * _Time.y ) ) );
			simplePerlin2D4 = simplePerlin2D4*0.5 + 0.5;
			float2 uv_Mask = v.texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode15 = tex2Dlod( _Mask, float4( uv_Mask, 0, 0.0) );
			v.vertex.xyz += ( float3(0,0,1) * simplePerlin2D4 * _AnimIntensity * ( 1.0 - v.texcoord.xy.y ) * tex2DNode15.r );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = tex2D( _MainTex, uv_MainTex ).rgb;
			float3 ase_worldPos = i.worldPos;
			float posy23 = ase_worldPos.y;
			float gradientNoise19 = GradientNoise(i.uv_texcoord,_Global_BurningValue.z);
			gradientNoise19 = gradientNoise19*0.5 + 0.5;
			float noise23 = gradientNoise19;
			float burnValue23 = _Global_BurningValue.x;
			float width23 = _Global_BurningValue.y;
			float4 color23 = _Global_BurningColor;
			float burningRange23 = _Global_BurningValue.w;
			float4 colorRange23 = _Global_BurningColorRange;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode15 = tex2D( _Mask, uv_Mask );
			float FlagMask25 = tex2DNode15.r;
			float needBurn23 = FlagMask25;
			float4 localBurnningFunction23 = BurnningFunction23( posy23 , noise23 , burnValue23 , width23 , color23 , burningRange23 , colorRange23 , needBurn23 );
			o.Emission = localBurnningFunction23.xyz;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
433.1429;530.8572;1699.429;779.0001;2304.856;273.0073;1;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;6;-932.3634,872.4217;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;8;-894.3634,701.4217;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-899.6493,542.8281;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-727.3634,680.4217;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;15;-590.1372,1141.973;Inherit;True;Property;_Mask;Mask;3;0;Create;True;0;0;0;False;0;False;-1;None;5ae69fe7279d359459496325d53f3d36;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-469.2938,950.377;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-598.3634,605.4217;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-2389.332,-240.3782;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;17;-2443.361,-60.45379;Inherit;False;Global;_Global_BurningValue;_Global_BurningValue;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;-0.24,0.01,10,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-189.2483,1179.823;Inherit;False;FlagMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1636.96,229.682;Inherit;False;25;FlagMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;4;-411.6493,582.8281;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;24;-2096.03,230.7253;Inherit;False;Global;_Global_BurningColorRange;_Global_BurningColorRange;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;3.780393,0.3582789,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;14;-266.6472,951.3237;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;19;-2077.331,-245.3783;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;10;-367.8207,421.7179;Inherit;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;18;-2038.148,11.94036;Inherit;False;Global;_Global_BurningColor;_Global_BurningColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;119.4283,7.313888,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-1720.299,-324.8552;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;12;-320.3704,822.7169;Inherit;False;Property;_AnimIntensity;AnimIntensity;4;0;Create;True;0;0;0;False;0;False;0.5;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;17.58385,538.5376;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-346.5789,-375.484;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;2e3c2bfd97b0e4b4f9ada21f18a21cdb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-438.6495,336.9709;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-426.6495,207.971;Inherit;False;Property;_Metallic;Metallic;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;23;-1328.568,-141.5208;Inherit;False;if(needBurn>0)${$    float test = posy-noise-burnValue@$    clip(test)@$    if(test<width)$    return color@$    return smoothstep(burningRange,0,test)*colorRange@$}$return float4(0,0,0,0)@;4;False;8;False;posy;FLOAT;0;In;;Inherit;False;False;noise;FLOAT;0;In;;Inherit;False;False;burnValue;FLOAT;0;In;;Inherit;False;False;width;FLOAT;0.1;In;;Inherit;False;False;color;FLOAT4;5,0,0,0;In;;Inherit;False;False;burningRange;FLOAT;0.1;In;;Inherit;False;False;colorRange;FLOAT4;0,0,0,0;In;;Inherit;False;True;needBurn;FLOAT;1;In;;Inherit;False;BurnningFunction;True;False;0;8;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0.1;False;4;FLOAT4;5,0,0,0;False;5;FLOAT;0.1;False;6;FLOAT4;0,0,0,0;False;7;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;410.8813,-20.13988;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ASE_Flag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;0
WireConnection;9;1;6;0
WireConnection;7;0;5;0
WireConnection;7;1;9;0
WireConnection;25;0;15;1
WireConnection;4;0;7;0
WireConnection;14;0;13;2
WireConnection;19;0;16;0
WireConnection;19;1;17;3
WireConnection;11;0;10;0
WireConnection;11;1;4;0
WireConnection;11;2;12;0
WireConnection;11;3;14;0
WireConnection;11;4;15;1
WireConnection;23;0;35;2
WireConnection;23;1;19;0
WireConnection;23;2;17;1
WireConnection;23;3;17;2
WireConnection;23;4;18;0
WireConnection;23;5;17;4
WireConnection;23;6;24;0
WireConnection;23;7;33;0
WireConnection;0;0;1;0
WireConnection;0;2;23;0
WireConnection;0;3;2;0
WireConnection;0;4;3;0
WireConnection;0;11;11;0
ASEEND*/
//CHKSM=E3A343586F37BD19307F2FC1080C1BB5030FDBBF