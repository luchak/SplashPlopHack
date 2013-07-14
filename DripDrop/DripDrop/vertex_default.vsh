attribute vec4 v_position;
attribute vec4 v_texcoord;

varying vec4 f_texcoord;

void main() {
    gl_Position = v_position;
    f_texcoord = v_texcoord;
}