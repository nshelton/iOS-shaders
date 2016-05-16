attribute vec4 a_position;
varying vec2 uv;
varying vec2 v_coord;
uniform vec3 u_resolution;


void main() {
    gl_Position = a_position;
    uv = (a_position.xy + 1.0) * 0.5;
    v_coord = 4. * (uv - 0.5) * vec2(u_resolution.x/u_resolution.y, 1.);

}
