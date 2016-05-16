uniform sampler2D colorSampler;
uniform sampler2D noiseSampler;
uniform sampler2D persistent;

uniform float u_time;
varying vec2 uv;

void main()
{
    vec4 traceResult = texture2D(colorSampler,  uv );
    vec4 noise = texture2D(noiseSampler, fract(uv * 20. + u_time)) - 0.5;
    gl_FragColor = traceResult + noise.xxxx/7.;
}