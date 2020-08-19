Shader "Unlit/SkyGrass"
{
    Properties
    {
        _GrassNorm2Tex ("GrassNorm2Tex", 2D) = "white" {}
        _GrassNorm1Tex ("GrassNorm1Tex", 2D) = "White" {}
        _GrassMaskTex ("GrassMaskTex", 2D) = "White" {}

        _ALphaScale ("Alpha Scale", Range(0, 1)) = 1

        _Color("Color", Color) = (1, 1, 1, 1)

        _ScrollX ("Base layer Scroll speed X", Float) = 1.0
		_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
		_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
		_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
		_Scroll2Scale("Scroll2 UV Scale", float) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100
        

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            ZWrite off
            Blend SrcAlpha oneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 scrollUV : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            fixed _ALphaScale;
            half _ScrollX;
			half _ScrollY;
			half _Scroll2X;
			half _Scroll2Y;
			half _Scroll2Scale;

            fixed4 _Color;

            sampler2D _GrassNorm2Tex;
            float4 _GrassNorm2Tex_ST;

            sampler2D _GrassNorm1Tex;
            float4 _GrassNorm1Tex_ST;

            sampler2D _GrassMaskTex;
            float4 _GrassMaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.scrollUV.xy = TRANSFORM_TEX(v.texcoord, _GrassNorm2Tex)  + frac(float2(_ScrollX, _ScrollY) * _Time.y); //
				
                o.scrollUV.zw = v.texcoord.zw * _Scroll2Scale + frac(float2(_Scroll2X, _Scroll2Y) * _Time.y); //TRANSFORM_TEX(v.texcoord, _GrassNorm1Tex)

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 grassNorm2 = tex2D(_GrassNorm2Tex, i.scrollUV.xy);
                float2 scrollUV1 =  (((grassNorm2.xy - 0.5) * ((tex2D(_GrassNorm2Tex, i.scrollUV.zw).xy * 2.0) - 1.0)) + 0.5).xy;
                float2 scrollUV2 = tex2D(_GrassNorm1Tex, (i.worldPos.xz * float2(0.5, 0.25)) -(scrollUV1 * 0.01)).xy;
                float2 grassNorm1 = tex2D(_GrassNorm1Tex, i.worldPos.xz - scrollUV1 * 0.125 + scrollUV2 * 0.03).xy;
                float2 grassUV1 = (lerp(scrollUV2, grassNorm1, grassNorm2.zz) * 2.0 - 1.0);
                float mask = tex2D(_GrassMaskTex, i.worldPos.xy * 0.25).y * 2.0 + 0.25;
                float2 grassUV2 = ((scrollUV1 * 2.0 - 1.0) * grassNorm2.zz) * 0.5;
                float2 grassUV = (grassUV1 + grassUV2) * grassNorm2.xy * mask;
                float3 grassScroll = float3(grassUV.x, 0, grassUV.y);

                fixed4 texColor = tex2D(_GrassNorm2Tex, grassUV1 + grassUV2);
                texColor.g = 1;
                return texColor;
                
                // fixed3 worldNormal = normalize(i.worldNormal + (grassScroll * 0.5));
                // fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // fixed3 albedo = texColor.rgb * _Color.rgb;

                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                // fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                // return fixed4(ambient + diffuse * 1, texColor.a * _ALphaScale);
            }
            ENDCG
        }
    }
}
