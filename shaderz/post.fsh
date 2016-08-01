uniform sampler2D colorSampler;
uniform sampler2D noiseSampler;
uniform sampler2D colorMap;

uniform sampler2D lastFrame;

uniform float u_time;
varying vec2 uv;
uniform vec4 params;


void main()
{
    vec4 traceResult = texture2D(colorSampler,  uv );
    
    
    

    float sampled_value = traceResult.x;
    
    
    float sampleCol = fract(params.z / 15.0 + 0.02);
    
    vec4 color = texture2D(colorMap, vec2(sampleCol, traceResult.x));

    vec4 fogColor = vec4(1.0); //texture2D(colorMap, (vec2(sampleCol, 0.0)));

    float fogAmount = 1.0 - exp( -traceResult.z);
    
    vec4 noise = texture2D(noiseSampler, fract(uv * 20. + u_time)) - 0.5;
    
    float ao = traceResult.w;
    
    if ( params.x < 1.0)
    {
        color = mix(color * ao, fogColor, fogAmount );

    }
    else if ( params.x < 2.0)
    {
        color = vec4(fogAmount + ao) / 2.0;
    }
        
    
    
    
    gl_FragColor = color ; //* noise.xxxx/7.;
}