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

lowp vec3 hash33(lowp vec3 p) // iq - "replace this by something better. really. do"
{
    p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
              dot(p,vec3(269.5,183.3,246.1)),
              dot(p,vec3(113.5,271.9,124.6)));

    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

/*vec3 hash33(vec3 p) // Hash Function for random weights
{
    float n = sin(dot(p,vec3(7.0,157.0,113.0)));
    return fract(32768.0*n*vec3(64.0,8.0,1.0))*2.0 - 1.0;
}*/

lowp float tetraNoise(lowp vec2 o, lowp float time) // Perlin(ish) Noise Function adapted from Stefan Gustavson's 'Simplex Noise Demystified' (Math)
{
    lowp vec3 p = vec3(o.x + 0.008*time, o.y + 0.004*time,0.005*time);
    lowp vec3 i = floor(p + dot(p, vec3(0.33333,0.33333,0.33333)));
    p -= i - dot(i, vec3(0.16666,0.16666,0.16666));
    lowp vec3 i1 = step(p.yzx, p);
    lowp vec3 i2 = max(i1, 1.0-i1.zxy);
    i1 = min(i1, 1.0-i1.zxy);
    lowp vec3 p1 = p - i1 + 0.16666, p2 = p - i2 + 0.33333, p3 = p - 0.5;
    lowp vec4 v = max(0.5 - vec4(dot(p,p), dot(p1,p1), dot(p2,p2), dot(p3,p3)), 0.0);
    lowp vec4 d = vec4(dot(p, hash33(i)), dot(p1, hash33(i + i1)), dot(p2, hash33(i + i2)), dot(p3, hash33(i + 1.0)));
    lowp float n = clamp(dot(d,v*v*v*8.0)*1.732 + 0.5, 0.0, 1.0);
    return n;
}

void main(void)
{
	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;

    lowp float pixel = (ColorizeOut.g>0.0 ? ColorizeOut.g : 1.0);
    lowp vec2 pCoord = floor(TexCoord0*TextureSizeOut.xy/pixel)*pixel/TextureSizeOut.xy;

	lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? pCoord - mod(pCoord, pa) + pa * 0.5 : pCoord);

    lowp float fx = tetraNoise(pCoord*vec2(10.0, 6.0), ColorizeOut.r);
    if((fx>0.75 && fx<1.0) || (fx>0.0 && fx<0.25) || (fx>0.43 && fx<0.57))
    {
        fx = 0.0;
    }
    else
    {
        fx = 1.0;
    }

    lowp vec3 col = vec3(fx, fx, fx);

    gl_FragColor = vec4(col * texColor.a*(1.0-fx), (1.0-fx)*texColor.a);
}
