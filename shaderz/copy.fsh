uniform sampler2D colorSampler;
varying vec2 uv;

void main()
{
    gl_FragColor = texture2D(colorSampler, uv);
}