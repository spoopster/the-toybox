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

lowp float pixelscale = 2.0;
lowp float threshold = 0.6;

const mediump float PHI = 1.61803398874989484820459; // Φ = Golden Ratio 
lowp float gold_noise(lowp vec2 xy, lowp float seed)
{
    return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}

void main(void)
{
	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;

	lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);

    lowp float seed = ColorizeOut.r;

    lowp vec2 scaledCoord = floor(gl_FragCoord.xy/pixelscale)*pixelscale;
    lowp float lum = pow(gold_noise(scaledCoord, seed), 0.3)/texColor.a;
    lowp vec3 finalcolor = vec3(0.0,0.0,0.0);
    if(lum<threshold)
    {
        lowp float scaled = gold_noise(scaledCoord, lum/(1.0-threshold)+0.1);
        if(scaled>0.67) finalcolor = vec3(0.97, 0.97, 0.97);
        else if(scaled>0.33) finalcolor = vec3(0.5, 0.97, 0.125);
        else finalcolor = vec3(0.34, 0.72, 0.97);

        //finalcolor = vec3(lum);

        lum = 1.0;
        texColor.a = (texColor.a<0.01 ? 0.0 : 1.0);
    }
    else
    {
        lum = lum*texColor.a;
        texColor.a = 0.0;
    }

    //lum = lum*texColor.a;

    finalcolor = mix(texColor.rgb, finalcolor, (texColor.a<0.01 ? 0.0 : 1.0));
    gl_FragColor = vec4(finalcolor + ColorOffsetOut * texColor.a, texColor.a*100.);
}
