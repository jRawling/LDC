Shader "GE Mobile/Diffuse - Lightmap - Texture Map - NoLight [Fragment]" {
	Properties {
		_TexturePower("Texture Power", Range(1.0, 20.0)) = 1.0
		_EmissionPower("Emission Power", Range(0.0, 20.0)) = 1.0
		_MainTex("Diffuse Texture", 2D) = "white" {}
		_LightMap("Light Map", 2D) = "white" {LightMapMode}
		_EmissionMap("Emission Map", 2D) = "white" {}
	}
	
	SubShader {
		//Pass for One Directional Light
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vertexProgram
				#pragma fragment fragmentProgram
				#pragma exclude_renderers flash
				#include "UnityCG.cginc"
				
				//User-Defined Variables
				uniform sampler2D _MainTex;
				uniform half4 _MainTex_ST;
				
				uniform sampler2D _LightMap;
				uniform half4 _LightMap_ST;
				
				uniform sampler2D _EmissionMap;
				uniform half4 _EmissionMap_ST;
				
				uniform half _TexturePower;
				uniform half _EmissionPower;
				
				//Base input structure
				struct Input {
					half4 vertexPositionModel : POSITION;
					half3 normalWorld : NORMAL;
					half4 texCoords : TEXCOORD0;
					half4 texCoordLM : TEXCOORD1;
				} ;
				
				//Base output structure
				struct Output {
					half4 vertexPosition : SV_POSITION;
					half4 texCoords : TEXCOORD0;
					half4 texCoordLM :TEXCOORD1;
					half4 vertexPositionWorld : TEXCOORD2;
					half3 normalWorld : TEXCOORD3;
				} ;
				
				//Vertex Program
				Output vertexProgram(Input input) {
					Output output;
					//For constructing tangent space
					output.normalWorld = normalize(mul(half4(input.normalWorld, 0.0), _World2Object).xyz);
					output.vertexPosition = mul(UNITY_MATRIX_MVP, input.vertexPositionModel);
					
					//For fragment program processing
					output.vertexPositionWorld = mul(_Object2World, input.vertexPositionModel);
					output.texCoords.xy = TRANSFORM_TEX(input.texCoords, _MainTex);
					output.texCoordLM.xy = TRANSFORM_TEX(input.texCoordLM, _LightMap);
					return output;
				}
				
				//Fragment Program
				half4 fragmentProgram (Output output) : COLOR {
					half4 mainTex = tex2D(_MainTex, output.texCoords.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					half4 lightMap = tex2D(_LightMap, output.texCoordLM.xy * _LightMap_ST.xy + _LightMap_ST.zw);
					half4 emissionMap = tex2D(_EmissionMap, output.texCoordLM.xy * _EmissionMap_ST.xy + _EmissionMap_ST.zw);
					
					//Lighting
					half3 ambientLight = half3(UNITY_LIGHTMODEL_AMBIENT.rgb);		//Ambient
					
					//Output to frame buffer
					return half4(_TexturePower * mainTex.rgb * lightMap.rgb * ambientLight + emissionMap * _EmissionPower , 1.0);
				}
			ENDCG
		}
	}
	
	FallBack "Diffuse"
}

