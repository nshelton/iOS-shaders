uniform sampler2D colorSampler;
uniform sampler2D noiseSampler;
uniform sampler2D colorMap;

uniform float u_time;
varying vec2 uv;
uniform vec4 params;



void main()
{
    
    vec4 traceResult = texture2D(colorSampler, uv);
    
    
    float sampleCol = fract(params.z / 15.0 + 0.02);
    
    vec4 color = texture2D(colorMap, vec2(sampleCol, 1. - traceResult.x));

    vec4 fogColor = 0.5 * texture2D(colorMap, (vec2(sampleCol, 0.0)));

    float fogAmount = pow(exp( - traceResult.z),  params.y/2.0);
    
//    vec4 noise = texture2D(noiseSampler, fract(uv * 20. + u_time)) - 0.5;
    
    float ao = traceResult.w;
    
    if ( params.x < 0.5)
    {
        color = vec4(fogAmount);

    }
    else if ( params.x < 1.5)
    {
        color = vec4(sqrt(fogAmount) * (traceResult.y + traceResult.w) * color);
    }
    else if ( params.x < 2.5)
    {
        
        color = vec4((traceResult.y + traceResult.w) * color);
    }
    
    
    gl_FragColor = color;
//    gl_FragColor = traceResult;
}
