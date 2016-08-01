precision highp float;

uniform sampler2D noiseSampler;
uniform float u_time;
uniform vec3 u_resolution;
varying vec2 uv;
varying vec2 v_coord;
uniform mat4 u_modelViewTransform;

uniform vec4 params;

#define PI 3.1415

#define MAX_ITER  50

float dthresh = params.y;
float minRad2 = params.z;
float SCALE =  params.x; // + sin(u_time/50. + uv.x)/2. ;
vec4 scale = vec4(SCALE, SCALE, SCALE, abs(SCALE)) / minRad2;






//--------ACKO's helpers  -------------------------------------------------------


    vec4 fold(vec4 z) {
          return vec4(2.*clamp(z.xyz, -1., 1.) - z.xyz, z.w);
        }
 
    vec4 warp(vec4 z) {
          float th = cos(clamp(z.y, -1., 1.) * 3.14) * .1 + .1;
          float c = cos(th);
          float s = sin(th);
          z.xz *= mat2(c, s, -s, c);
          z.w *= 1.1;
          return z;
        }
 
    vec4 rotate(vec4 z, float th) {
          float c = cos(th);
          float s = sin(th);
          z.xz *= mat2(c, s, -s, c);
          return z;
        }
 
    vec4 affine(vec4 z, float factor, vec3 offset) {
          z.xyz *= factor * vec3(-1., -1., -1.);
          z.xyz += offset;
          z.w *= abs(factor);
          return z;
        }
 
    vec4 mandel(vec4 z, vec3 offset) {
          float x = z.x;
          float y = z.y;
     
          z.w = 2. * length(z.xy) * z.w + 1.;
     
          z.x = x*x - y*y + offset.x;
          z.y = 2.*x*y + offset.y;
     
          return z;
        }
 
    vec4 invert(vec4 z, float factor) {
          float r2 = dot(z.xyz, z.xyz);
          float f = factor / r2;
          return z * f;
        }
 
    vec4 invertRadius(vec4 z, float radius2, float limit) {
          float r2 = dot(z.xyz, z.xyz);
          float f = clamp(radius2 / r2, 1., limit);
          return z * f;
        }
 

//----------------------------------------------------------------------------------------
float DE(vec3 pos)
{
    //	return (length(pos)-4.0);
    
    vec4 p = vec4(pos,1);
    vec4 p0 = p;  // p.w is the distance estimate
    
    for (int i = 0; i < 10; i++)
    {
        p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;
        
        // sphere folding: if (r2 < minRad2) p /= minRad2; else if (r2 < 1.0) p /= r2;
        float r2 = dot(p.xyz, p.xyz);
        p *= clamp(max(minRad2/r2, minRad2), 0.0, 1.0);
        
        // scale, translate
        p = p*scale + p0;
    }
    
    return ((length(p.xyz) - abs(SCALE - 1.0)) / p.w);
}

vec3 gradient(vec3 p, float d) {
    
    vec2 e = vec2(0., d );
    return normalize(
                     vec3(
                          DE(p+e.yxx) - DE(p-e.yxx),
                          DE(p+e.xyx) - DE(p-e.xyx),
                          DE(p+e.xxy) - DE(p-e.xxy)
                          )
                     );
}


float AO(vec3 p, vec3 n, float delta){
    const int steps = 3;
    
    float a = 0.0;
    float weight = 0.75;
    float m;
    for(int i=1; i<=steps; i++) {
        float d = (float(i) / float(steps)) * delta;
        a += weight*(d - DE(p + n*d));
        weight *= 0.5;
    }
    return clamp(1.0 - a, 0.0, 1.0);
}

void main() {
    //raymarcher!
    vec3 camera = vec3(u_modelViewTransform[3].xyz);    vec3 point;
    bool hit = false;
    
    vec4 n = texture2D(noiseSampler, fract(v_coord * sin(u_time * 100.)));
    vec2 jitter = 0.0 * (n.xy - 0.5) / u_resolution.xy;
    
    vec3 ray = normalize( vec3(v_coord + jitter, 1.0) );
    ray = (u_modelViewTransform * vec4(ray, 0.0)).xyz;
    
    // raycasting parameter
    float t = 0.;
    float iter = 0.0;
    
    // ray stepping
    for(int i = 0; i < MAX_ITER; i++) {
        point = camera + ray * t;
        float dist = DE(point);
        
        if (dist <exp ( t * dthresh)/ pow(10.0, 3.4) ) //exp ( t * dthresh) )
            break;

        iter ++;
        t += dist;
    }
    
    vec3 normal = gradient(point, exp ( t * dthresh)/ pow(15.0, 3.4) );
    
    float ao = AO(point, normal, length(point)/6.);
    
    
    float shade = abs(dot(normal, ray));

    
    gl_FragColor = vec4(iter/float(MAX_ITER), shade, t , ao );
    
}
