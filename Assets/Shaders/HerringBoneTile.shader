Shader "Unlit/HerringBoneTile"
{
	//This will show herringbone tiles, selected based on the Red and Green channels of the main texture
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TextureSize("Texture Size", int) = 32
		_Tiles("Tiles", 2D) = "white" {}
		_NumberOfTiles("Number of Tiles", int) = 32
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _TextureSize;
			sampler2D _Tiles;
			float4 _TilesTex_ST;
			float _NumberOfTiles;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//round to nearest pixel for maze UV
				fixed2 uv = floor(i.uv*_TextureSize);
				//get remainder UV for that pixel for the tile uv
				fixed2 tileUV = i.uv*_TextureSize - uv;
				
				//offset for herringbone pattern
				//and modify tile uv based on part and direction
				if ((uv.x + uv.y) % 2 == 1) {
					if (round(uv.x - uv.y+_TextureSize) % 4 == 1) {						
						uv = uv + fixed2(-1, 0);
						tileUV = tileUV * fixed2(0.5, 1) + fixed2(0.5,0);
					}
					else {
						uv = uv + fixed2(0, 1);
						tileUV = fixed2(tileUV.y*0.5, 1-tileUV.x);
					}
				}
				else {
					if (round(uv.x - uv.y + _TextureSize) % 4 == 0) {
						tileUV = tileUV * fixed2(0.5, 1);
					}
					else {
						tileUV = fixed2(tileUV.y*0.5 + 0.5, 1-tileUV.x);
					}
				}

				uv = (uv) / _TextureSize;
				fixed2 offset = tex2D(_MainTex, uv).xy;
				fixed2 offsetScale = fixed2(_NumberOfTiles, _NumberOfTiles*2);
				offset = floor(offset * offsetScale) / offsetScale;
				tileUV.y = tileUV.y * 0.5;
				fixed2 scaling = i.uv*_TextureSize/2;
				fixed4 col = tex2D(_Tiles, (tileUV/_NumberOfTiles)+offset, ddx(scaling), ddy(scaling));
				
				return col;
			}
			ENDCG
		}
	}
}
