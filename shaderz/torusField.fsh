precision highp float;

uniform sampler2D noiseSampler;
uniform float u_time;
uniform vec3 u_resolution;
varying vec2 uv;
varying vec2 v_coord;
uniform mat4 u_modelViewTransform;

#define shadeDelta 0.003

float sdTorus( vec3 p, vec2 t )
{
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

float DE(vec3 z)
{
    z = opRep(z, vec3(2.0));
    return sdTorus(z, vec2(0.5, 0.1));
}

vec3 gradient(vec3 p) {
    
    vec2 e = vec2(0., shadeDelta);
    return normalize(
         vec3(
              DE(p+e.yxx) - DE(p-e.yxx),
              DE(p+e.xyx) - DE(p-e.xyx),
              DE(p+e.xxy) - DE(p-e.xxy)
              )
         );
}

#define MAX_ITER 30
#define termThres 0.004
#define PI 3.1415

void main() {
    //raymarcher!
    vec3 camera = vec3(0.,0., u_time);
    vec3 point;
    bool hit = false;
    
    vec4 n = texture2D(noiseSampler, fract(v_coord));
    vec2 jitter =  2. * (n.xy - 0.5) / u_resolution.xy;
    
    vec3 ray = normalize( vec3(v_coord + jitter, 1.0) );
    ray = (u_modelViewTransform * vec4(ray, 0.0)).xyz;
    
    // raycasting parameter
    float t = 0.;
    float iter = 0.0;
    
    // ray stepping
    for(int i = 0; i < MAX_ITER; i++) {
        point = camera + ray * t;
        float dist = DE(point);
        
        if (abs(dist) < termThres)
            break;

        iter ++;
        t += dist;
    }
    
    float shade = dot(gradient(point), ray);
    float ao = 1. - iter/float(MAX_ITER);
    
    gl_FragColor = vec4(vec3(ao * abs(shade)), 1.);
    
}
