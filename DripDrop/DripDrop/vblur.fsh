precision mediump float;

varying mediump vec4 f_texcoord;
uniform sampler2D tex0;
uniform mediump vec2 windowSize;

void main() {
    mediump vec4 color = texture2D(tex0, f_texcoord.st);
    
    mediump float h = 1.0 / windowSize.y;
    mediump vec2 dy = vec2(0.0, h);
    
    color *= 6.0;
    color += 4.0*texture2D(tex0, f_texcoord.st + dy);
    color += 4.0*texture2D(tex0, f_texcoord.st - dy);
    color += 1.0*texture2D(tex0, f_texcoord.st + 2.0*dy);
    color += 1.0*texture2D(tex0, f_texcoord.st - 2.0*dy);

    gl_FragColor = color / 4.0;
}