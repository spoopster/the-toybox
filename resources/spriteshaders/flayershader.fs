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

#define UI0 1597334673U
#define UI1 3812015801U
#define UI2 uvec2(UI0, UI1)
#define UI3 uvec3(UI0, UI1, 2798796415U)
#define UIF (1.0 / float(0xffffffffU))

lowp vec3 hash33(lowp vec3 p)
{
	uvec3 q = uvec3(ivec3(p)) * UI3;
	q = (q.x ^ q.y ^ q.z)*UI3;
	return -1. + 2. * vec3(q) * UIF;
}

lowp float remap(lowp float x, lowp float a, lowp float b, lowp float c, lowp float d)
{
    return (((x - a) / (b - a)) * (d - c)) + c;
}

// Gradient noise by iq (modified to be tileable)
lowp float gradientNoise(lowp vec3 x, lowp float freq)
{
    // grid
    lowp vec3 p = floor(x);
    lowp vec3 w = fract(x);
    
    // quintic interpolant
    lowp vec3 u = w * w * w * (w * (w * 6. - 15.) + 10.);

    
    // gradients
    lowp vec3 ga = hash33(mod(p + vec3(0., 0., 0.), freq));
    lowp vec3 gb = hash33(mod(p + vec3(1., 0., 0.), freq));
    lowp vec3 gc = hash33(mod(p + vec3(0., 1., 0.), freq));
    lowp vec3 gd = hash33(mod(p + vec3(1., 1., 0.), freq));
    lowp vec3 ge = hash33(mod(p + vec3(0., 0., 1.), freq));
    lowp vec3 gf = hash33(mod(p + vec3(1., 0., 1.), freq));
    lowp vec3 gg = hash33(mod(p + vec3(0., 1., 1.), freq));
    lowp vec3 gh = hash33(mod(p + vec3(1., 1., 1.), freq));
    
    // projections
    lowp float va = dot(ga, w - vec3(0., 0., 0.));
    lowp float vb = dot(gb, w - vec3(1., 0., 0.));
    lowp float vc = dot(gc, w - vec3(0., 1., 0.));
    lowp float vd = dot(gd, w - vec3(1., 1., 0.));
    lowp float ve = dot(ge, w - vec3(0., 0., 1.));
    lowp float vf = dot(gf, w - vec3(1., 0., 1.));
    lowp float vg = dot(gg, w - vec3(0., 1., 1.));
    lowp float vh = dot(gh, w - vec3(1., 1., 1.));
	
    // interpolation
    return va + 
           u.x * (vb - va) + 
           u.y * (vc - va) + 
           u.z * (ve - va) + 
           u.x * u.y * (va - vb - vc + vd) + 
           u.y * u.z * (va - vc - ve + vg) + 
           u.z * u.x * (va - vb - ve + vf) + 
           u.x * u.y * u.z * (-va + vb + vc - vd + ve - vf - vg + vh);
}

// Tileable 3D worley noise
lowp float worleyNoise(lowp vec3 uv, lowp float freq)
{    
    lowp vec3 id = floor(uv);
    lowp vec3 p = fract(uv);
    
    lowp float minDist = 10000.;
    for (lowp float x = -1.; x <= 1.; ++x)
    {
        for(lowp float y = -1.; y <= 1.; ++y)
        {
            for(lowp float z = -1.; z <= 1.; ++z)
            {
                lowp vec3 offset = vec3(x, y, z);
            	lowp vec3 h = hash33(mod(id + offset, vec3(freq))) * .5 + .5;
    			h += offset;
            	lowp vec3 d = p - h;
           		minDist = min(minDist, dot(d, d));
            }
        }
    }
    
    // inverted worley noise
    return 1. - minDist;
}

// Fbm for Perlin noise based on iq's blog
lowp float perlinfbm(lowp vec3 p, lowp float freq, lowp int octaves)
{
    lowp float G = exp2(-.85);
    lowp float amp = 1.;
    lowp float noise = 0.;
    for (int i = 0; i < octaves; ++i)
    {
        noise += amp * gradientNoise(p * freq, freq);
        freq *= 2.;
        amp *= G;
    }
    
    return noise;
}

// Tileable Worley fbm inspired by Andrew Schneider's Real-Time Volumetric Cloudscapes
// chapter in GPU Pro 7.
lowp float worleyFbm(lowp vec3 p, lowp float freq)
{
    return worleyNoise(p*freq, freq) * .625 +
        	 worleyNoise(p*freq*2., freq*2.) * .25 +
        	 worleyNoise(p*freq*4., freq*4.) * .125;
}

lowp vec4 wembley(lowp vec2 coord, lowp float didy)
{
    vec4 col = vec4(0.);
    
    float slices = 1024.; // number of layers of the 3d texture
    float freq = 4.;
    
    float pfbm= mix(1., perlinfbm(vec3(coord, floor(didy*slices)/slices), 4., 7), .5);
    pfbm = abs(pfbm * 2. - 1.); // billowy perlin noise
    
    col.g += worleyFbm(vec3(coord, floor(didy*slices)/slices), freq);
    col.b += worleyFbm(vec3(coord, floor(didy*slices)/slices), freq*2.);
    col.a += worleyFbm(vec3(coord, floor(didy*slices)/slices), freq*4.);
    col.r += remap(pfbm, 0., 1., col.g, 1.); // perlin-worley

    return col;
}


void main(void)
{
	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;

    lowp float slice = ColorizeOut.r*0.2;
    lowp float pixel = (ColorizeOut.g>0. ? ColorizeOut.g : 1.);
    lowp vec2 pCoord = floor(TexCoord0*TextureSizeOut.xy/pixel)*pixel/TextureSizeOut.xy;

	lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? pCoord - mod(pCoord, pa) + pa * 0.5 : pCoord);

    lowp float perlinWorley = wembley(pCoord.xy+ColorizeOut.ba, slice);
    
    // worley fbms with different frequencies
    lowp vec3 worley = wembley(pCoord.xy+ColorizeOut.ba, slice).yzw;
    lowp float wfbm = worley.x * .625 +
        		 worley.y * .125 +
        		 worley.z * .25; 

    // cloud shape modeled after the GPU Pro 7 chapter
    lowp float cloud = remap(perlinWorley, wfbm - 1., 1., 0., 1.);
    cloud = remap(cloud, .65, 1., 0.2, 1.5); // fake cloud coverage

    cloud = pow(max(cloud, 0.0), 2.)+0.1;

    texColor.rgb *= cloud;

    gl_FragColor = vec4(texColor.rgb + ColorOffsetOut * texColor.a, texColor.a);
}
