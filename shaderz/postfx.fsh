uniform sampler2D colorSampler;

varying vec2 uv;

void main()
{
    
    vec2 c_uv = uv - 0.5;
    float r = texture2D(colorSampler, 0.99 * c_uv + 0.5 ).r;
    float g = texture2D(colorSampler,  c_uv + 0.5).g;
    float b = texture2D(colorSampler, 1.00 * c_uv + 0.5 ).b;
    
    
//    gl_FragColor = texture2D(colorSampler,  c_uv + 0.5);

    gl_FragColor = vec4(r, g, b, 1.0);
}