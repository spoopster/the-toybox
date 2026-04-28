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

lowp float pixelscale = 2.0;

void main(void)
{
    if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;

    pixelscale = ColorizeOut.r;

    lowp vec2 pCoord = floor(TexCoord0*TextureSizeOut.xy/pixelscale)*pixelscale/TextureSizeOut.xy;
    
    lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
    //lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);
    lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? pCoord - mod(pCoord, pa) + pa * 0.5 : pCoord);

    gl_FragColor = vec4(texColor.rgb + ColorOffsetOut * texColor.a, texColor.a);
}
