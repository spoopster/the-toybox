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

lowp float cubic(lowp float x, lowp float a1, lowp float b1, lowp float a2, lowp float b2, lowp float xt)
{
	return x < xt ? (a1*pow(x,3.0)+b1*x) : (a2*pow(x-1.0,3.0)+b2*(x-1.0)+1.0);
}

lowp vec3 torgb(int r, int g, int b)
{
	return vec3(float(r)/255.0, float(g)/255.0, float(b)/255.0);
}

lowp float size=25.0;
lowp vec3 col[100];

void main(void)
{
	int idx=0; int numBlackStart = 10;
	for(idx=0; idx<=numBlackStart; idx++) col[idx] = mix(torgb(37,33,55), vec3(0.0), 1.0-pow(float(idx)/float(numBlackStart),3.0));
	col[idx++] = torgb(37,33,55);
	col[idx++] = torgb(115,52,147);
	col[idx++] = torgb(181,32,166);
	col[idx++] = torgb(241,180,76);
	col[idx++] = torgb(222,248,95);
	col[idx++] = torgb(170,233,99);
	col[idx++] = torgb(88,189,215);
	col[idx++] = torgb(22,47,54);
	col[idx++] = torgb(18,30,42);
	col[idx++] = torgb(10,21,24);
	for(idx; idx<=int(size); idx++) col[idx] = torgb(0,0,0);

	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
	lowp vec4 Color = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);

	lowp float t = ColorizeOut.a;
	lowp float lumval = Color.r*_lum.r+Color.g*_lum.g+Color.b*_lum.b;
	lowp float lum = (1.0-mod(1.0-lumval+t,1.0))*size+1.0;

	lowp vec3 newcol = mix(col[int(lum)], col[int(lum)+1], lum-floor(lum));

	lowp vec3 Colorized = mix(Color.rgb, newcol, pow(lumval, 0.15));
	gl_FragColor = vec4(Colorized + ColorOffsetOut * Color.a, Color.a);
}

