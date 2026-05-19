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

lowp float size=9.0;
lowp vec3 goozmaColors[100];
lowp float goozmaColorSizes[100];
lowp float maxColorSize = 0.0;

void main(void)
{
    goozmaColors[0] = torgb(0,0,0);       goozmaColorSizes[0] = 30.0;
    goozmaColors[1] = torgb(0,0,0);       goozmaColorSizes[1] = 3.0;
	goozmaColors[2] = torgb(115,52,147);  goozmaColorSizes[2] = 1.0;
	goozmaColors[3] = torgb(181,32,166);  goozmaColorSizes[3] = 2.0;
	goozmaColors[4] = torgb(241,180,76);  goozmaColorSizes[4] = 1.0;
	goozmaColors[5] = torgb(222,248,95);  goozmaColorSizes[5] = 2.0;
	goozmaColors[6] = torgb(170,233,99);  goozmaColorSizes[6] = 3.0;
	goozmaColors[7] = torgb(88,189,215);  goozmaColorSizes[7] = 9.0;
    goozmaColors[8] = torgb(0,0,0);       goozmaColorSizes[8] = 10.0;
    goozmaColors[9] = torgb(0,0,0);       goozmaColorSizes[9] = 0.0; //end
    
    for(int idx=0; idx<int(size); idx++) maxColorSize += goozmaColorSizes[idx];

	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
	lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);

    lowp float timeVal = ColorizeOut.a;
    lowp float luminosityVal = texColor.r*_lum.r+texColor.g*_lum.g+texColor.b*_lum.b;
    lowp float finalLuminosity = (mod(1.0-luminosityVal+timeVal,1.0))*maxColorSize;

	lowp float minColorSize = 0.0;
    lowp vec3 selectedColor;
    for(int idx=0; idx<int(size); idx++)
    {
        if(minColorSize+goozmaColorSizes[idx] > finalLuminosity)
        {
            lowp float lerpVal = (finalLuminosity-minColorSize)/(goozmaColorSizes[idx]);
            
            selectedColor = mix(goozmaColors[idx], goozmaColors[idx+1], lerpVal);
            break;
        }
        
        minColorSize += goozmaColorSizes[idx];
    }

    lowp vec3 finalColor = mix(texColor.rgb, selectedColor, pow(luminosityVal, 0.15));
    gl_FragColor = vec4(finalColor + ColorOffsetOut * texColor.a, texColor.a);
}
