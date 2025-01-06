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

lowp float NUM_STRIPS = 8.0;
lowp float SCROLL_SPEED = 2.0;
lowp float STRIP_INTENSITY = 0.3;
lowp float ALPHA_FREQ = 0.12;

lowp vec3 rgbToHsl(lowp vec3 color)
{
    lowp float hue=0.0, sat=0.0, lum=0.0;
    lowp float cmx=max(color.r, max(color.g, color.b));
    lowp float cmn=min(color.r, min(color.g, color.b));
    lowp float dif=cmx-cmn;

    lum = (cmx+cmn)/2.0;
    if(abs(dif)>0.01)
    {
        sat = dif/(1.0-abs(2.0*lum-1.0));
        
        if(cmx==color.r) hue = mod((color.g-color.b)/dif, 6.0);
        else if(cmx==color.g) hue = (color.b-color.r)/dif+2.0;
        else hue = (color.r-color.g)/dif+4.0;
    }

    return vec3(hue,sat,lum);
}
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

    // Converts color to pure green, makes it more saturated
    lowp vec3 hsl = rgbToHsl(texColor.rgb);
    hsl.g = 1.0;
    hsl.r = 2.0;
    texColor.rgb = hslToRgb(hsl);
    //texColor.g += 0.15;

    // Adds horizontal "brighter" strips
    lowp float m = mod(time*SCROLL_SPEED+(TexCoord0.y)*NUM_STRIPS, 1.0)*2.0;
    m = (floor(m)-0.5)*2.0;
    if(m>=0.0) texColor.g += m*STRIP_INTENSITY;
    else texColor.rgb += m*STRIP_INTENSITY;

    // Makes transparency flicker
    if(mod(time, ALPHA_FREQ)<(ALPHA_FREQ*0.5)) texColor.a *= 0.85;
    else texColor.rgba *= 0.55;

    gl_FragColor = vec4(texColor + ColorOffsetOut * texColor.a, texColor.a);
}
