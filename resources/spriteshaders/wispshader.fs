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

    lowp vec2 pCoord = floor(TexCoord0*TextureSizeOut.xy/pixelscale)*pixelscale/TextureSizeOut.xy;
    
    lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
    lowp vec4 texColor = texture2D(Texture0, PixelationAmountOut > 0.0 ? pCoord - mod(pCoord, pa) + pa * 0.5 : pCoord);

    lowp vec4 color = texColor;
    lowp float luminosityVal = (color.r*_lum.r+color.g*_lum.g+color.b*_lum.b);

//*
    if((luminosityVal<0.01) && color.a>0.75)
    {
        color.rgba = vec4(1.0);
    }
    else if((luminosityVal<0.4) && color.a>0.5)
    {
        color.rgba = vec4(0.3);
    }
    else
    {
        color.rgba = vec4(0.0);
    }
    //*/

    //color.rgb = -color.rgb;

    gl_FragColor = vec4(color.rgb*Color0.rgb + ColorOffsetOut * color.a, color.a*Color0.a);
    //gl_FragColor = vec4(texColor.rgb + ColorOffsetOut * texColor.a, texColor.a);
}
