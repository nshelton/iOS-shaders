uniform sampler2D colorSampler;
uniform sampler2D noiseSampler;
uniform sampler2D colorMap;

uniform sampler2D persistent;

uniform float u_time;
varying vec2 uv;

void main()
{
    vec4 traceResult = texture2D(colorSampler,  uv );
    vec4 color = texture2D(colorMap, vec2(sqrt(traceResult.x), 0.5) );
    vec4 noise = texture2D(noiseSampler, fract(uv * 20. + u_time)) - 0.5;
    gl_FragColor = color * traceResult.y + noise.xxxx/7.;
}