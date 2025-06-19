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

const int MAX_STEPS = 200;
const lowp float MISS_DIST = 200.0;
const lowp float HIT_DIST = 0.001;
const int MENGER_ITERATIONS = 6;
const lowp mat3 IDENTITY_MAT = mat3(vec3(1.0,0.0,0.0), vec3(0.0,1.0,0.0), vec3(0.0,0.0,1.0));
const lowp float FUCKING_PI = 3.1415926535897932384626433832795;

lowp mat3 rotateY(lowp float theta) {
    lowp float c = cos(theta);
    lowp float s = sin(theta);
    return mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, c, -s),
        vec3(0.0, s, c)
    );
}
lowp mat3 rotateX(lowp float theta) {
    lowp float c = cos(theta);
    lowp float s = sin(theta);
    return mat3(
        vec3(c, 0.0, s),
        vec3(0.0, 1.0, 0.0),
        vec3(-s, 0.0, c)
    );
}

lowp float max3(lowp float a, lowp float b, lowp float c)
{
    return max(max(a,b),c);
}
lowp float min3(lowp float a, lowp float b, lowp float c)
{
    return min(min(a,b),c);
}

lowp float sdCube(lowp vec3 rayPos, lowp float sideLength, lowp mat3 transform) {
    rayPos *= transform;

    lowp float halfWidth = sideLength*0.5;
    lowp vec3 corner = vec3(halfWidth, halfWidth, halfWidth);

    lowp vec3 foldedPos = abs(rayPos);
    lowp vec3 ctr = foldedPos - corner;
    lowp vec3 closestToOutsideRay = max(ctr, 0.0);
    lowp float cornerToRayMaxComponent = max(max(ctr.x, ctr.y), ctr.z);
    lowp float distToInsideRay = min(cornerToRayMaxComponent, 0.0);
    return length(closestToOutsideRay) + distToInsideRay;
} 
lowp float sdCross(lowp vec3 rayPos, lowp float crossWidth, lowp mat3 transform) {
    rayPos *= transform;

    lowp float halfWidth = crossWidth*0.5;
    lowp vec3 corner = vec3(halfWidth, halfWidth, halfWidth);
    lowp vec3 foldedPos = abs(rayPos);

    lowp vec3 ctr = foldedPos - corner;
    lowp float minComp = min(min(ctr.x, ctr.y), ctr.z);
    lowp float maxComp = max(max(ctr.x, ctr.y), ctr.z);
    lowp float midComp = ctr.x + ctr.y + ctr.z - minComp - maxComp;
        
    lowp vec2 closestOutsidePoint = max(vec2(minComp, midComp), 0.0);
    lowp vec2 closestInsidePoint = min(vec2(midComp, maxComp), 0.0);

    return length(closestOutsidePoint) + -length(closestInsidePoint);
}
lowp float sdMengerSponge(lowp vec3 rayPos, lowp float sidelength, lowp mat3 transform) {
    rayPos *= transform;
    lowp float spongeCube = sdCube(rayPos, sidelength, IDENTITY_MAT);
    lowp float mengerSpongeDist = spongeCube;
    
    lowp float scale = 1.0;
    for(int i = 0; i < MENGER_ITERATIONS; ++i) {
        lowp float boxedWidth = sidelength / scale;
        lowp float translation = -boxedWidth / 2.0;
        lowp vec3 ray = rayPos - translation;
        lowp vec3 repeatedPos = ToyboxMod(ray, boxedWidth);
        repeatedPos += translation;
        repeatedPos *= scale;
        
        lowp float crossesDist = sdCross(repeatedPos*3.0, sidelength, IDENTITY_MAT)/3.0;
        crossesDist /= scale;
        scale *= 3.0;
        
        mengerSpongeDist = max(mengerSpongeDist, -crossesDist);
    }
    return mengerSpongeDist;
}
int calcMengerSponge(lowp vec2 coord)
{
    lowp vec3 rayDir = vec3(coord.x, coord.y-0.15, 1.0);
    rayDir = normalize(rayDir);

    lowp mat3 transform = rotateY(0.5)*rotateX(ToyboxMod(ColorizeOut.r, FUCKING_PI));

    lowp float dist = 0.0;
    bool hit = false;
    int iterations = 0;
    for(int i=0; i<MAX_STEPS; i+=1)
    {
        lowp float posToScene = sdMengerSponge(dist*rayDir-vec3(0.0,0.0,2.5), 2.0, transform);
        dist += posToScene;
        if(posToScene < HIT_DIST)
        {
            hit = true;
            break;
        }
        if(posToScene > MISS_DIST)
        {
            break; 
        }

        iterations = i;
    }

    if(hit)
    {
        return iterations;
    }
    return -1;
}

void main(void)
{
    if(dot(gl_FragCoord.xy, ClipPlaneOut.xy) < ClipPlaneOut.z)
		discard;
    lowp vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
    lowp vec4 texColor = Color0 * texture2D(Texture0, PixelationAmountOut > 0.0 ? TexCoord0 - ToyboxMod(TexCoord0, pa) + pa * 0.5 : TexCoord0);
    gl_FragColor = texColor;
    //*

    lowp vec2 pixelCoord = TexCoord0.xy;
    pixelCoord = pixelCoord*2.0-vec2(1.0,1.0);
    pixelCoord.y *= -1.0;

    gl_FragColor = vec4(abs(pixelCoord.xy), 0.0, 1.0);

    int res = calcMengerSponge(pixelCoord);

    if(res==-1)
    {
        gl_FragColor = vec4(0.0,0.0,0.0,0.0);
    }
    else
    {
        lowp float luminosity = 1.0-float(res)/float(MAX_STEPS);
        luminosity = pow(luminosity, 4.0);

        lowp vec3 color = vec3(luminosity, luminosity, luminosity);

        gl_FragColor = vec4(color, 1.0);
    }
    //*/
}
