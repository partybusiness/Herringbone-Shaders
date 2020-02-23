Shader "Unlit/WangTile"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tiles("Tiles", 2D) = "white" {}
		_TextureSize("Texture Size", int) = 32
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
			sampler2D _Tiles;
			float _TextureSize;
			
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
				uv = (uv) / _TextureSize;
				
				//bottom and left of the tile is decided by sampleLocation
				//right and top use offset samples to match
				bool2 sampleLocation = tex2D(_MainTex, uv).xy > 0.5;
				bool2 sampleLocationRight = tex2D(_MainTex, uv + fixed2(1 / _TextureSize, 0)).xy > 0.5;
				bool2 sampleLocationAbove = tex2D(_MainTex, uv + fixed2(0, 1 / _TextureSize)).xy > 0.5;

				//math is a little weird but it allows all neighbouring wang tiles to match edges
				//you could do simpler math if you know it's point filter with no mip maps
				int index = 0;

				index += 1 * (sampleLocationRight.x ^ sampleLocation.x);
				index += 2 * sampleLocation.x;
				index += 4 * (sampleLocationAbove.y ^ sampleLocation.y);
				index += 8 * sampleLocation.y;


				fixed2 offset = fixed2(index%4,index/4)/4;
				fixed2 scaling = i.uv;
				fixed4 col = tex2D(_Tiles, (tileUV / 4)+offset, ddx(scaling), ddy(scaling));
				return col;
			}
			ENDCG
		}
	}
}
