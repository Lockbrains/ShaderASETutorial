// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TAPro/ASE_FlagAnim"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_AnimIntensity("AnimIntensity", Float) = 0.5
		_Dir("Dir", Vector) = (0,0,1,0)
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
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float3 _Dir;
		uniform float _AnimIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Global_BurningValue;
		uniform float4 _Global_BurningColor;
		uniform float4 _Global_BurningColorRange;


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


		float4 BurnningFunction21( float posy, float noise, float burnValue, float width, float4 color, float burningRange, float4 colorRange )
		{
			float test = posy-noise-burnValue;
			clip(test);
			if(test<width)
			   return color;
			return smoothstep(burningRange,0,test)*colorRange;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float simplePerlin2D10 = snoise( ( v.texcoord.xy + ( float2( 1,0 ) * _Time.y ) ) );
			simplePerlin2D10 = simplePerlin2D10*0.5 + 0.5;
			v.vertex.xyz += ( _Dir * simplePerlin2D10 * _AnimIntensity * ( 1.0 - v.texcoord.xy.y ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = tex2D( _MainTex, uv_MainTex ).rgb;
			float3 ase_worldPos = i.worldPos;
			float posy21 = ase_worldPos.y;
			float gradientNoise20 = GradientNoise(i.uv_texcoord,_Global_BurningValue.z);
			gradientNoise20 = gradientNoise20*0.5 + 0.5;
			float noise21 = gradientNoise20;
			float burnValue21 = _Global_BurningValue.x;
			float width21 = _Global_BurningValue.y;
			float4 color21 = _Global_BurningColor;
			float burningRange21 = _Global_BurningValue.w;
			float4 colorRange21 = _Global_BurningColorRange;
			float4 localBurnningFunction21 = BurnningFunction21( posy21 , noise21 , burnValue21 , width21 , color21 , burningRange21 , colorRange21 );
			o.Emission = localBurnningFunction21.xyz;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
439.4286;923.4286;1699.429;759.0001;1906.548;303.8025;1.447689;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1215.193,717.2143;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;5;-1177.193,546.2143;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1182.479,387.6204;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1010.193,525.2143;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-881.1925,450.2143;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-752.1229,795.1696;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-1565.435,-261.6859;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;17;-1603.894,-39.98836;Inherit;False;Global;_Global_BurningValue;_Global_BurningValue;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;-0.86,0.01,10,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-1264.61,1.705002;Inherit;False;Global;_Global_BurningColor;_Global_BurningColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;119.4283,7.313888,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;11;-649.2,246.2085;Inherit;False;Property;_Dir;Dir;2;0;Create;True;0;0;0;False;0;False;0,0,1;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;13;-549.4771,796.1163;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;19;-1222.156,-471.5741;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;14;-603.2001,667.5095;Inherit;False;Property;_AnimIntensity;AnimIntensity;1;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-1312.435,-293.686;Inherit;True;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;10;-696.4785,420.6204;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-1282.119,184.5688;Inherit;False;Global;_Global_BurningColorRange;_Global_BurningColorRange;2;1;[HDR];Create;True;0;0;0;False;0;False;1024,28.08426,0,0;3.780393,0.3582789,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;24;-1761.929,-105.6465;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-265.2461,383.3299;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-242.3306,-325.6913;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;c6a811125d902934abf234d7f892bd48;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1986.93,-52.64651;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1981.93,-131.646;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;-1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;21;-709.6126,-163.1802;Inherit;False;float test = posy-noise-burnValue@$clip(test)@$if(test<width)$   return color@$return smoothstep(burningRange,0,test)*colorRange@;4;False;7;False;posy;FLOAT;0;In;;Inherit;False;False;noise;FLOAT;0;In;;Inherit;False;False;burnValue;FLOAT;0;In;;Inherit;False;False;width;FLOAT;0.1;In;;Inherit;False;False;color;FLOAT4;5,0,0,0;In;;Inherit;False;False;burningRange;FLOAT;0.1;In;;Inherit;False;True;colorRange;FLOAT4;0,0,0,0;In;;Inherit;False;BurnningFunction;True;False;0;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0.1;False;4;FLOAT4;5,0,0,0;False;5;FLOAT;0.1;False;6;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;3;160.0537,-51.4356;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TAPro/ASE_FlagAnim;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;5;0
WireConnection;7;1;4;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;13;0;9;2
WireConnection;20;0;16;0
WireConnection;20;1;17;3
WireConnection;10;0;8;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;15;0;11;0
WireConnection;15;1;10;0
WireConnection;15;2;14;0
WireConnection;15;3;13;0
WireConnection;21;0;19;2
WireConnection;21;1;20;0
WireConnection;21;2;17;1
WireConnection;21;3;17;2
WireConnection;21;4;18;0
WireConnection;21;5;17;4
WireConnection;21;6;27;0
WireConnection;3;0;1;0
WireConnection;3;2;21;0
WireConnection;3;11;15;0
ASEEND*/
//CHKSM=BB19F086C7D6528FA49412C2C261E6A1144BF6FC