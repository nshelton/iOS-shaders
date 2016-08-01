uniform sampler2D colorBuffer;
varying vec2 uv;

void main()
{
    gl_FragColor = texture2D(colorBuffer, uv);
}