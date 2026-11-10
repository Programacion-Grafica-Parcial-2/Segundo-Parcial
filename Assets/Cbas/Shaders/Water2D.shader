// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water2D"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		_TimeScale("TimeScale", Range( -100 , 100)) = 1
		_altura("altura", Float) = 0
		_Frec("Frec", Range( 0 , 0.1)) = 0
		_FirstColor("FirstColor", Color) = (1,0,0,1)
		_SecondColor("SecondColor", Color) = (1,0,0,1)
		_FlowTexture("FlowTexture", 2D) = "bump" {}
		_Amp("Amp", Range( -15 , 15)) = 4
		_PanSpeed("PanSpeed", Vector) = (0,0,0,0)
		_TimeScalePanner("TimeScalePanner", Range( 0 , 5)) = 0
		_ReflectionMovement("ReflectionMovement", Range( 0 , 0.1)) = 0
		_ReflectionPos("ReflectionPos", Range( 0 , 1)) = 0
		_ImpactPos("ImpactPos", Vector) = (0,0,0,0)
		_ImpactStart("ImpactStart", Float) = -100
		_ImpactStrength("ImpactStrength", Range( 0 , 10)) = 1
		_Radious("Radious", Range( 0 , 20)) = 2
		_RippleFrec("RippleFrec", Range( 0 , 10)) = 5
		_RippleSpeed("RippleSpeed", Range( 0 , 50)) = 5
		_Decay("Decay", Range( 0 , 5)) = 1

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		GrabPass{ }

		Pass
		{
			Name "Default"
		CGPROGRAM
			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_POSITION

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform float _ReflectionPos;
			uniform sampler2D _FlowTexture;
			uniform float _TimeScalePanner;
			uniform float2 _PanSpeed;
			uniform float _ReflectionMovement;
			uniform float4 _FirstColor;
			uniform float4 _SecondColor;
			uniform float _TimeScale;
			uniform float _Frec;
			uniform float _Amp;
			uniform float _altura;
			uniform float4 _ImpactPos;
			uniform float _Radious;
			uniform float _RippleFrec;
			uniform float _ImpactStart;
			uniform float _RippleSpeed;
			uniform float _Decay;
			uniform float _ImpactStrength;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				float4 ase_clipPos = UnityObjectToClipPos(IN.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				OUT.ase_texcoord2 = screenPos;
				float3 ase_worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
				OUT.ase_texcoord4.xyz = ase_worldPos;
				
				OUT.ase_texcoord3 = IN.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				OUT.ase_texcoord4.w = 0;
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 screenPos = IN.ase_texcoord2;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult79 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float4 screenColor78 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,appendResult79);
				float2 appendResult60 = (float2(ase_grabScreenPosNorm.r , ( ase_grabScreenPosNorm.g + ( 1.0 - _ReflectionPos ) )));
				float mulTime87 = _Time.y * _TimeScalePanner;
				float2 panner85 = ( mulTime87 * _PanSpeed + float2( 0,0 ));
				float3 break101 = ( float3( appendResult60 ,  0.0 ) + UnpackScaleNormal( tex2D( _FlowTexture, panner85 ), _ReflectionMovement ) );
				float2 appendResult103 = (float2(break101.x , ( 1.0 - break101.y )));
				float4 screenColor42 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,appendResult103);
				float mulTime34 = _Time.y * _TimeScale;
				float3 ase_worldPos = IN.ase_texcoord4.xyz;
				float2 appendResult116 = (float2(ase_worldPos.x , ase_worldPos.y));
				float temp_output_117_0 = distance( appendResult116 , (_ImpactPos).xy );
				float temp_output_125_0 = ( _Time.y - _ImpactStart );
				float Amp136 = _Amp;
				float4 lerpResult77 = lerp( screenColor78 , ( ( screenColor42 + _FirstColor ) * _SecondColor ) , step( ( ( ( sin( ( mulTime34 + ( IN.ase_texcoord3.xyz.x * _Frec ) ) ) * _Amp ) + _altura ) - ( saturate( ( 1.0 - ( temp_output_117_0 / _Radious ) ) ) * sin( ( ( temp_output_117_0 * _RippleFrec ) - ( temp_output_125_0 * _RippleSpeed ) ) ) * exp( -( temp_output_125_0 * _Decay ) ) * _ImpactStrength * Amp136 ) ) , ( 1.0 - (0.0 + (IN.ase_texcoord3.xyz.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ));
				
				half4 color = lerpResult77;
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
193.5;92;659;656.5;1773.01;-227.9659;2.154093;True;False
Node;AmplifyShaderEditor.RangedFloatNode;88;-1825.389,658.2068;Inherit;False;Property;_TimeScalePanner;TimeScalePanner;8;0;Create;True;0;0;0;False;0;False;0;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1303.062,408.7362;Inherit;False;Property;_ReflectionPos;ReflectionPos;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;87;-1494.389,665.2068;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;86;-1594.154,537.2929;Inherit;False;Property;_PanSpeed;PanSpeed;7;0;Create;True;0;0;0;False;0;False;0,0;0.05,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;115;-1615.32,783.5016;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;109;-1656.355,972.5291;Inherit;False;Property;_ImpactPos;ImpactPos;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;99;-1122.832,434.941;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;57;-1157.852,154.0596;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;124;-1350.348,1146.953;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;85;-1358.705,489.3965;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-949.8495,387.0887;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;116;-1431.32,815.5016;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;120;-1467.32,925.5016;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1034.891,676.0131;Inherit;False;Property;_ReflectionMovement;ReflectionMovement;9;0;Create;True;0;0;0;False;0;False;0;0.0341;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1354.708,1222.673;Inherit;False;Property;_ImpactStart;ImpactStart;12;0;Create;True;0;0;0;False;0;False;-100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;13;-1050.424,-46.35138;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;117;-1247.32,838.5016;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-836.6517,41.74502;Inherit;False;Property;_Frec;Frec;2;0;Create;True;0;0;0;False;0;False;0;100.61;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-837.0655,330.5213;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;68;-990.0802,488.5638;Inherit;True;Property;_FlowTexture;FlowTexture;5;0;Create;True;0;0;0;False;1;;False;-1;None;7ddcba51d9fc0894d98b4ba77fbdfbd7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-979.8376,-178.8641;Inherit;False;Property;_TimeScale;TimeScale;0;0;Create;True;0;0;0;False;0;False;1;15;-100;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-1274.984,952.9237;Inherit;False;Property;_Radious;Radious;14;0;Create;True;0;0;0;False;0;False;2;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;125;-1151.004,1145.667;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-1136.265,1259.627;Inherit;False;Property;_Decay;Decay;17;0;Create;True;0;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-710.1987,361.6261;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-1192.193,1024.599;Inherit;False;Property;_RippleFrec;RippleFrec;15;0;Create;True;0;0;0;False;0;False;5;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;-704.954,-96.77991;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;131;-1033.517,1065.63;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;121;-1036.613,819.7524;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-666.608,-21.9728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-1007.699,1092.52;Inherit;False;Property;_RippleSpeed;RippleSpeed;16;0;Create;True;0;0;0;False;0;False;5;0;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-336.2885,24.71344;Inherit;False;Property;_Amp;Amp;6;0;Create;True;0;0;0;False;0;False;4;6;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-963.3832,1179.106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;122;-896.4291,821.0383;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;101;-559.3089,360.9663;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-1008.011,928.3237;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-829.2796,1027.294;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-525.5895,-81.73318;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;25;-360.7544,-81.15233;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;123;-745.9568,821.038;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;132;-662.3893,916.6802;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;127;-833.4875,1173.961;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;102;-434.6513,444.4353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-207.9951,77.77065;Inherit;False;Amp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;133;-524.6079,916.6798;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-224.2885,-96.28656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-218.4354,0.6067276;Inherit;False;Property;_altura;altura;1;0;Create;True;0;0;0;False;0;False;0;-92.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-571.9972,1145.406;Inherit;False;136;Amp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-592.2853,1057.34;Inherit;False;Property;_ImpactStrength;ImpactStrength;13;0;Create;True;0;0;0;False;0;False;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;128;-715.1971,1175.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;-381.3157,311.4571;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;135;-416.4095,877.3932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;42;-240.4375,324.7974;Inherit;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;24;-835.5905,111.7643;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-371.3012,903.0957;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;59;-80.37767,558.1889;Inherit;False;Property;_FirstColor;FirstColor;3;0;Create;True;0;0;0;False;0;False;1,0,0,1;0,0.02122927,1,0.6039216;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-63.92853,-84.01976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;80;-462.9278,-408.2333;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;138;129.8155,-2.400833;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;-240.1243,-351.4023;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;49.75269,381.4571;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;29;-227.2271,175.5003;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;100.1822,505.6342;Inherit;False;Property;_SecondColor;SecondColor;4;0;Create;True;0;0;0;False;0;False;1,0,0,1;0,0.02122927,1,0.6039216;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;213.1822,352.6341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;10;668.804,3.535106;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;78;-82.05057,-352.3592;Inherit;False;Global;_GrabScreen1;Grab Screen 1;3;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;77;771.0709,-37.20562;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;904.8373,-64.13669;Float;False;True;-1;2;ASEMaterialInspector;0;4;Water2D;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;87;0;88;0
WireConnection;99;0;96;0
WireConnection;85;2;86;0
WireConnection;85;1;87;0
WireConnection;97;0;57;2
WireConnection;97;1;99;0
WireConnection;116;0;115;1
WireConnection;116;1;115;2
WireConnection;120;0;109;0
WireConnection;117;0;116;0
WireConnection;117;1;120;0
WireConnection;60;0;57;1
WireConnection;60;1;97;0
WireConnection;68;1;85;0
WireConnection;68;5;94;0
WireConnection;125;0;124;0
WireConnection;125;1;108;0
WireConnection;61;0;60;0
WireConnection;61;1;68;0
WireConnection;34;0;5;0
WireConnection;131;0;125;0
WireConnection;121;0;117;0
WireConnection;121;1;111;0
WireConnection;37;0;13;1
WireConnection;37;1;36;0
WireConnection;126;0;125;0
WireConnection;126;1;114;0
WireConnection;122;0;121;0
WireConnection;101;0;61;0
WireConnection;129;0;117;0
WireConnection;129;1;112;0
WireConnection;130;0;131;0
WireConnection;130;1;113;0
WireConnection;32;0;34;0
WireConnection;32;1;37;0
WireConnection;25;0;32;0
WireConnection;123;0;122;0
WireConnection;132;0;129;0
WireConnection;132;1;130;0
WireConnection;127;0;126;0
WireConnection;102;0;101;1
WireConnection;136;0;82;0
WireConnection;133;0;132;0
WireConnection;81;0;25;0
WireConnection;81;1;82;0
WireConnection;128;0;127;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;135;0;123;0
WireConnection;42;0;103;0
WireConnection;24;0;13;2
WireConnection;134;0;135;0
WireConnection;134;1;133;0
WireConnection;134;2;128;0
WireConnection;134;3;110;0
WireConnection;134;4;137;0
WireConnection;26;0;81;0
WireConnection;26;1;23;0
WireConnection;138;0;26;0
WireConnection;138;1;134;0
WireConnection;79;0;80;1
WireConnection;79;1;80;2
WireConnection;104;0;42;0
WireConnection;104;1;59;0
WireConnection;29;0;24;0
WireConnection;105;0;104;0
WireConnection;105;1;106;0
WireConnection;10;0;138;0
WireConnection;10;1;29;0
WireConnection;78;0;79;0
WireConnection;77;0;78;0
WireConnection;77;1;105;0
WireConnection;77;2;10;0
WireConnection;0;0;77;0
ASEEND*/
//CHKSM=4C115643B74E96324801D844D89526818258E965