precision mediump float;

varying mediump vec4 f_texcoord;
uniform sampler2D tex0;
uniform mediump vec2 windowSize;

void main() {
    mediump vec4 color = texture2D(tex0, f_texcoord.st);
    
    mediump float h = 1.0 / windowSize.x;
    mediump vec2 dx = vec2(h, 0.0);
    
    color *= 6.0;
    color += 4.0*texture2D(tex0, f_texcoord.st + dx);
    color += 4.0*texture2D(tex0, f_texcoord.st - dx);
    color += 1.0*texture2D(tex0, f_texcoord.st + 2.0*dx);
    color += 1.0*texture2D(tex0, f_texcoord.st - 2.0*dx);
    
    gl_FragColor = color / 4.0;
}