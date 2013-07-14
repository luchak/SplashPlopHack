precision mediump float;

varying mediump vec4 f_texcoord;
uniform sampler2D tex0;

uniform mediump vec2 windowSize;
uniform mediump float particleRadius;

void main() {
    mediump vec4 color = texture2D(tex0, f_texcoord.st);
    if (abs(color.b) < 1e-20) gl_FragColor.r = 1.0*particleRadius;
    else {
        mediump vec2 world_coords = gl_FragCoord.xy / windowSize.y;
        world_coords.x -= ((windowSize.x / windowSize.y) - 1.0) * 0.5;
        
        mediump vec2 avg_coord = color.rg / color.b;
        mediump float phi = length(avg_coord - world_coords) - 0.5*particleRadius;
        gl_FragColor.r = phi;
    }
}