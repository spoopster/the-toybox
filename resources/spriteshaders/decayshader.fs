#ifndef GL_ES
#  define lowp
#  define mediump
#endif

varying lowp vec4 Color0;
varying mediump vec2 TexCoord0;
varying lowp vec4 ColorizeOut;
varying lowp vec3 ColorOffsetOut;
varying lowp vec2 TextureSizeOut;
varying lowp float PixelationAmountOut;
varying lowp vec3 ClipPlaneOut;

uniform sampler2D Texture0;
const lowp vec3 _lum = vec3(0.212671, 0.715160, 0.072169);

lowp vec3 torgb(int r, int g, int b)
{
	return vec3(float(r)/255.0, float(g)/255.0, float(b)/255.0);
}

void main(void)
{
	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
	lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - ToyboxMod(TexCoord0, pa) + pa * 0.5 : TexCoord0);

    lowp vec3 finalColor = mix(texColor.rgb, vec3(1.0,1.0,1.0), 0.5);
    gl_FragColor = vec4(finalColor + ColorOffsetOut * texColor.a, texColor.a);
}
