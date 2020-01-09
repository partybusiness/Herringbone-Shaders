Shader "Unlit/HerringBoneSingleTile"
{
	//This does a herringbone pattern using a single texture for the bricks
	Properties
	{
		_TextureSize("Texture Size", int) = 32
		_Tile("Tile", 2D) = "white" {}
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

			float _TextureSize;
			sampler2D _Tile;
			float4 _Tile_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Tile);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//round to nearest pixel
				fixed2 uv = floor(i.uv*_TextureSize);
				fixed2 tileUV = i.uv*_TextureSize - uv;
				//fixed4 col = 0;
				//offset for herringbone pattern
				if ((uv.x + uv.y) % 2 == 1) {
					if (round(uv.x - uv.y+_TextureSize) % 4 == 1) {
						uv = uv + fixed2(0, 1);
						tileUV = tileUV * fixed2(0.5, 1) + fixed2(0.5,0);
					}
					else {
						uv = uv + fixed2(-1, 0); 
						tileUV = fixed2(tileUV.y*0.5, -tileUV.x);
					}
				}
				else {
					if (round(uv.x - uv.y + _TextureSize) % 4 == 0) {
						tileUV = tileUV * fixed2(0.5, 1);
					}
					else {
						tileUV = fixed2(tileUV.y*0.5 + 0.5, -tileUV.x);
					}
				}
				uv = (uv) / _TextureSize;
				
				fixed2 scaling = i.uv*_TextureSize / 2;
				fixed4 col = tex2D(_Tile, tileUV, ddx(scaling), ddy(scaling));
				return col;
			}
			ENDCG
		}
	}
}
