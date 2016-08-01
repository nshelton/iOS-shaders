uniform sampler2D traceResult;
uniform sampler2D lastFrame;

uniform vec3 resolution;
varying vec2 uv;

void main()
{
    
    vec4 n1 = texture2D(traceResult, uv);
    
//    vec3 d = 1.0 / resolution.xyz;
//    d.z = 0.0;
//    
//    vec4 n0 = texture2D(lastFrame, uv);
//    vec4 n0e = texture2D(lastFrame, uv+ vec2(d.x, d.z));
//    vec4 n0w = texture2D(lastFrame, uv+ vec2(-d.x, d.z));
//    vec4 n0n = texture2D(lastFrame, uv+ vec2(d.z, d.y));
//    vec4 n0s = texture2D(lastFrame, uv+ vec2(d.z, -d.y));
//    
//    n0 = (n0e + n0w + n0s + n0n + n0) / 5.0;
//    
//    float weight = 1.0 / exp( - abs(n0.z - n1.z) /2.0);
    
    gl_FragColor = n1; // mix(n0, n1, 0.05);
}