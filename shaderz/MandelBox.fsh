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

#define dthresh 1.1
float minRad2 = 0.25 + sin(u_time/9.) / 5.;
float SCALE =  3. + params.x; // + sin(u_time/50. + uv.x)/2. ;
vec4 scale = vec4(SCALE, SCALE, SCALE, abs(SCALE)) / minRad2;

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

vec3 gradient(vec3 p) {
    
    vec2 e = vec2(0., 0.0001);
    return normalize(
                     vec3(
                          DE(p+e.yxx) - DE(p-e.yxx),
                          DE(p+e.xyx) - DE(p-e.xyx),
                          DE(p+e.xxy) - DE(p-e.xxy)
                          )
                     );
}


vec3 CameraPath( float t )
{
   return 0.7 * vec3(-.81 + 3. * sin(2.14*t),
               .05+2.5 * sin(.942*t+1.3),
               .05 + 3.5 * cos(3.594*t) );
}

vec3 hsv(in float h, in float s, in float v) {
    return mix(vec3(1.0), clamp((abs(fract(h + vec3(3, 2, 1) / 3.0) * 6.0 - 3.0) - 1.0), 0.0 , 1.0), s) * v;
}

void main() {
    //raymarcher!
    vec3 camera = vec3(u_modelViewTransform[3].xyz);// CameraPath(u_time/100.);
    vec3 point;
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
        
        if (dist < exp ( t * dthresh)/ pow(10.0, 3.4) )
            break;

        iter ++;
        t += dist;
    }
    
    float ao = 1. - iter/float(MAX_ITER);
    
    float shade = abs(dot(gradient(point), ray));

    
    gl_FragColor = vec4(ao, shade, t , 1.);
    
}
