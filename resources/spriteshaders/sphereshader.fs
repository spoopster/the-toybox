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

#define SDF_DIST .01
#define RAYMARCH_STEPS 50
#define MAX_DIST 50.0
#define PI 3.1415926538

struct Ray {
    lowp vec3 dir;
    lowp vec3 origin;
};

lowp vec4 spherepos = vec4(0.0, 1.0, 3.0, 1.0);

lowp float GetMinSceneDistanceFromPoint(lowp vec3 point) {
    //define sphere here for now vec4(position.xyz, radius)
    lowp vec4 sphere = spherepos;
    
    // get distance from point to sphere
    return length(point - sphere.xyz) - sphere.w;
}

lowp float calcShading(lowp vec3 p) 
{
    // light source
    lowp vec3 light_position = vec3(0.0, 2.0, 0.0);
    
    // light direction
    lowp vec3 light_dir = normalize(light_position - p);
    
    // calculate hitpoint normal (gradient of sdf at p)
    lowp float dist = GetMinSceneDistanceFromPoint(p);
    lowp vec2 epsilon = vec2(0.01, 0);
    lowp vec3 normal = normalize(dist - vec3(GetMinSceneDistanceFromPoint(p - epsilon.xyy), 
                                        GetMinSceneDistanceFromPoint(p - epsilon.yxy), 
                                        GetMinSceneDistanceFromPoint(p - epsilon.yyx)));
    
    // calculate diffuse contribution
    return clamp(dot(normal, light_dir), 0.0, 1.0);
}

lowp float Raymarch(Ray r)
{
    lowp float dist_0 = 0.0; //distance from origin
    
    // main raymarch loop
    for(int i=0; i < RAYMARCH_STEPS; i++) {

        // march ray from origin in direction
        lowp vec3 t = r.origin + r.dir * dist_0;
        
        // get distance
        lowp float d = GetMinSceneDistanceFromPoint(t);
        
        //advance/march along ray
        dist_0 += d;
        
        //compute sdf
        if(dist_0 > MAX_DIST || d < SDF_DIST) {
            // found a hit
            return dist_0;
        }
    } 
}

lowp mat3 rotx(lowp float angle)
{
    return mat3(
        1.0, 0.0, 0.0,
        0.0, cos(angle), -sin(angle),
        0.0, sin(angle), cos(angle)
    );
}
lowp mat3 roty(lowp float angle)
{
    return mat3(
        cos(angle), 0.0, sin(angle),
        0.0, 1.0, 0.0,
        -sin(angle), 0.0, cos(angle)
    );
}

lowp float pixelscale = 1.;
lowp float desiredRes = 32.0;

void main(void)
{
	if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
	lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;

	lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - mod(TexCoord0, pa) + pa * 0.5 : TexCoord0);

    lowp float time = ColorizeOut.a;
    lowp int frame = int(floor(time*30.));
    frame = int(min(float(frame),float(0)));

    lowp vec3 finalcolor = texColor.rgb;

    // Normalized pixel coordinates (from 0 to 1)
    //vec2 uv = fragCoord/iResolution.xy;
    
    // Normalized pixel coordinates (from -1 to 1)

    lowp vec2 texsizenorm = vec2(TextureSizeOut.x/TextureSizeOut.y, 1.0);

    lowp vec2 retrocoord = floor(TexCoord0*TextureSizeOut.xy/pixelscale)*pixelscale/TextureSizeOut.xy;
    lowp vec2 uv = (retrocoord-0.5/texsizenorm)*vec2(1.,-1.)*texsizenorm;

    // Create ray
    Ray ray;
    ray.dir = normalize(vec3(uv.x, uv.y, 1.0));
    ray.origin = vec3(0.0, 1.0, 0.0);
    
    // raymarching
    lowp float m = Raymarch(ray);
    
    if(m < MAX_DIST) {
        // calculate hit point
        lowp vec3 hitpoint = ray.origin + ray.dir * m;

        lowp mat3 transf = mat3(1.0);
        transf = transf*rotx(radians(20.));
        transf = transf*roty(radians(time*360.));

        lowp vec3 normalized = (hitpoint-spherepos.xyz);
        normalized = normalized*transf;
        
        

       //normalized = glRotatef(radians(9.0), normalized.x, normalized.y, normalized.z);

        lowp vec2 suv = vec2(0.5+atan(normalized.z,normalized.x)/(2.*PI), 0.5-asin(normalized.y)/PI);

        lowp vec4 col = Color0 * texture2D(Texture0, suv);
    
        // shade point
        lowp float diffuse = calcShading(hitpoint);
        if(diffuse<0.0005) diffuse = 0.5;
        else  if(diffuse<0.15) diffuse = 0.7;
        else diffuse = 1.0;

        finalcolor = col.rgb*vec3(diffuse);
        gl_FragColor = vec4(finalcolor + ColorOffsetOut * texColor.a, texColor.a);
    }
    else
    {
        lowp float alph = 0.0;
        for(int i=-2; i<=2; i++)
        {
            for(int j=-2; j<=2; j++)
            {
                if(int(abs(float(i))+abs(float(j)))<=2 && (i!=0 && j!=0))
                {
                    lowp vec2 coordoffset = vec2(float(i),float(j))*1.7*pixelscale/TextureSizeOut.xy;
                    lowp vec2 newuv = (retrocoord+coordoffset-0.5/texsizenorm)*vec2(1.,-1.)*texsizenorm;

                    Ray ray2;
                    ray2.dir = normalize(vec3(newuv.x, newuv.y, 1.0));
                    ray2.origin = vec3(0.0, 1.0, 0.0);
                    if(Raymarch(ray2)<MAX_DIST)
                    {
                        alph = 1.0;
                        break;
                    }
                }
            }
            if(alph > 0.5)
            {
                break;
            }
        }

        // background
        lowp vec3 col = vec3(0.0);
        finalcolor = col;
        gl_FragColor = vec4(finalcolor + ColorOffsetOut * texColor.a, alph);
    }

    
}
