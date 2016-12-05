uniform sampler2D traceResult;
uniform sampler2D reconstruction;

uniform vec4 params;

uniform vec3 resolution;
varying vec2 uv;

uniform mat4 frameToFrame;


void main()
{
    
    
    
    
//    vec3 d = 1.0 / resolution.xyz;
//    d.z = 0.0;
//    
    vec4 observation = texture2D(traceResult, uv);
    
//    project this point into model
    
    vec2 v_coord = 2. * (uv - 0.5) * vec2(resolution.x/resolution.y, 1.);
    vec3 ray = normalize( vec3(v_coord, 1.0) );
    vec3 deproj = observation.z * ray;
    
//    project back into last image
    vec4 model_coords = frameToFrame * vec4(deproj, 1.0);
    
    
    vec2 uv_warp = model_coords.xy / model_coords.z;
    uv_warp /= 2.0;
    uv_warp /= vec2(resolution.x/resolution.y, 1.);
    uv_warp += 0.5;
    
    vec4 model = texture2D(reconstruction, uv_warp);

    vec3 d = 4.0 / vec3(resolution.xy, 0.0);
    
    vec4 n = texture2D(reconstruction, uv_warp + vec2(d.x, d.z));
    vec4 e = texture2D(reconstruction, uv_warp + vec2(-d.x, d.z));
    vec4 s = texture2D(reconstruction, uv_warp + vec2(d.z, d.y));
    vec4 w = texture2D(reconstruction, uv_warp + vec2(d.z, -d.y));
    
    
    
    vec4 min_z = min(min(n,e), min(s,w));
    vec4 max_z = max(max(n,e), max(s,w));
    
    float diff = abs(model.z-model_coords.z);
//    float alpha = diff / max((model.z, model_coords.z), min_z.z);
//    alpha = alpha * alpha;
    
    
//    float alpha = clamp(1.0 / exp(diff*diff / 2.0 ) , 0.0, 1.0);
    
//    if(model_coords.z > max_z.z || model_coords.z < min_z.z)
//        alpha = 0.0;
    

    
// TODO : try 4x update; discard if not the right frag
    
    float alpha = 0.0;

    if ( params.w > 0.5)
    {
        alpha = (1.0 -  diff / max( max(model.z, model_coords.z), max_z.z));
        alpha *= alpha;

    }
    if ( params.w > 1.5)
    {
        alpha = 0.99;
    }
    
    gl_FragColor = model * ( alpha) + observation * (1.0 - alpha);

    
    //
//    n0 = (n0e + n0w + n0s + n0n + n0) / 5.0;

//    float alpha =      1.0/(1.0 + abs(model.z-observation.z) * 1.0);

//  float d = model.z - observation.z;
//    float alpha = params.w * 0.95;
    
    
//    gl_FragColor.xy = 50.0 * (uv - uv_warp);
//    }
     //mix(n0, n1, 0.1);
}