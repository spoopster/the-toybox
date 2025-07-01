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

lowp vec3 hslToRgb(lowp vec3 hsl)
{
    lowp float r=0.0, g=0.0, b=0.0;
    lowp float c = (1.0-abs(2.0*hsl.b-1.0))*hsl.g;
    lowp float x = c*(1.0-abs(mod(hsl.r, 2.0)-1.0));

    if(hsl.r<=1.0) r=c, g=x;
    else if(hsl.r<=2.0) r=x, g=c;
    else if(hsl.r<=3.0) g=c, b=x;
    else if(hsl.r<=4.0) g=x, b=c;
    else if(hsl.r<=5.0) r=x, b=c;
    else r=c, b=x;

    return vec3(r,g,b)+vec3(hsl.b-c/2.0);
}

void main(void)
{
    if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
    lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
    lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);
    
    lowp float time = ColorizeOut.r;
    lowp vec3 color = vec3(mod(time,6.0), 1.0, 0.5);

    texColor.rgb = hslToRgb(color);

    gl_FragColor = vec4(texColor.rgb + ColorOffsetOut * texColor.a, texColor.a);
}
