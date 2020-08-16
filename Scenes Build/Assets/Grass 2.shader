// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Grass 2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
        _ALphaScale ("Alpha Scale", Range(0, 1)) = 1

        _ScrollX ("Base layer Scroll speed X", Float) = 1.0
		_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
		_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
		_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
		_Scroll2Scale("Scroll2 UV Scale", float) = 1 //第二层滚动的uv缩放
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        ZWrite off
        Blend SrcAlpha oneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half4 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD2;
                float3 worldPos : TEXCOORD1;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;  
            fixed _ALphaScale;
            half _ScrollX;
			half _ScrollY;
			half _Scroll2X;
			half _Scroll2Y;
			half _Scroll2Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time.y);
                o.uv.zw = v.texcoord.xy * _Scroll2Scale + frac(float2(_Scroll2X, _Scroll2Y) * _Time.y);
 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

               float4 grassWind = tex2D(_MainTex, i.uv.xy);
               float2 scrollUV = (((grassWind.xy - 0.5) * ((tex2D(_MainTex, i.uv.zw).xy * 2.0) - 1.0)) + 0.5).xy;

               fixed4 texColor = tex2D(_MainTex, scrollUV);

               fixed3 albedo = texColor.rgb * _Color.rgb;

               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

               fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

               return fixed4(ambient + diffuse, texColor.a * _ALphaScale);
            }
            ENDCG
        }
    }

    Fallback "Transparent/VertexList"
}
