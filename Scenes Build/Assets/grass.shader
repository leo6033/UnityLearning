// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _MaskColor("Mask Color", Color) = (0, 0, 0, 1)
        _ALphaScale ("Alpha Scale", Range(0, 1)) = 1
        
        
        _ScrollX ("Base layer Scroll speed X", Float) = 1.0
		_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
		_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
		_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
		_Scroll2Scale("Scroll2 UV Scale", float) = 1 //第二层滚动的uv缩放

        _UvScale("UV Scale", float) = 1.0

        _GrassMap("Grass Map", 2D) = "white" {}
        _MaskMap(" Mask Map", 2D) = "White" {}
        // _BurnFirstColor ("Burn First Color", Color) = (1, 0, 0, 1)
        // _BurnSecondColor ("Burn Second Color", Color) = (1, 0, 0, 1)
        // _BurnAmount ("Burn Amount", Range(0, 1)) = 0
       
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        pass
        {
            ZWrite On
            ColorMask 0
        }
        
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
                float4 vertex : SV_POSITION;
                half4 scrollUV : TEXCOORD0;
                float2 uvGrassMap : TEXCOORD1;
                float2 uvGrassMask : TEXCOORD5;
                float2 uvGrass : TEXCOORD6;
                float3 worldNormal : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                float3 lightDir : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            fixed _ALphaScale;
            fixed _UvScale;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _MaskColor;
            half _ScrollX;
			half _ScrollY;
			half _Scroll2X;
			half _Scroll2Y;
			half _Scroll2Scale;

            sampler2D _GrassMap;
			float4 _GrassMap_ST;

            sampler2D _MaskMap;
			float4 _MaskMap_ST;
            
            sampler2D _MainMap;
			float4 _MainMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.uvGrassMap = TRANSFORM_TEX(v.texcoord, _GrassMap);

                o.uvGrassMask = (v.texcoord - _MaskMap_ST.zw) * _MaskMap_ST.xy;

                o.uvGrass = (v.texcoord - _MainMap_ST.zw) * _MainMap_ST.xy;

                o.scrollUV.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time.y);
				
                o.scrollUV.zw = v.texcoord.xy * _Scroll2Scale + frac(float2(_Scroll2X, _Scroll2Y) * _Time.y);

                // TANGENT_SPACE_ROTATION;
                // o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 grass = tex2D(_GrassMap, i.uvGrassMap).rgb;
                fixed4 mask = tex2D(_MaskMap, i.uvGrassMask).rgba;

                fixed colorStrength = (sin(_Time.y) + 1 ) / 2;

                fixed3 worldNormal = normalize(i.worldNormal + (grass * 0.5));
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float4 grassWind = tex2D(_MainTex, i.scrollUV.xy);
                float2 scrollUV = grass +  i.worldPos.xz * _UvScale + (((grassWind.xy - 0.5) * ((tex2D(_MainTex, i.scrollUV.zw).xy * 2.0) - 1.0)) + 0.5).xy + (colorStrength*_MaskColor.rgb*mask.a);
                fixed4 texColor = tex2D(_MainTex, scrollUV);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                // float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;

                // float atten = tex2D(_MaskMap, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;

                // UNITY_LISHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + diffuse * 1, texColor.a * _ALphaScale);
            }
            ENDCG
        }
    }

    Fallback "VertexList"
}
