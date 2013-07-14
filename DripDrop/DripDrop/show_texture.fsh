precision mediump float;

varying mediump vec4 f_texcoord;
uniform sampler2D tex0;
uniform mediump vec2 windowSize;

vec4 texture2DBilinear( sampler2D textureSampler, vec2 uv )
{
    vec2 f = fract( uv.xy * windowSize ); // get the decimal part
    vec4 tl = texture2D(textureSampler, uv);
    vec4 tr = texture2D(textureSampler, uv + vec2(1.0/windowSize.x, 0));
    vec4 bl = texture2D(textureSampler, uv + vec2(0, 1.0/windowSize.y));
    vec4 br = texture2D(textureSampler, uv + vec2(1.0/windowSize.x , 1.0/windowSize.y));
    vec4 tA = mix( tl, tr, f.x );
    vec4 tB = mix( bl, br, f.x );
    return mix( tA, tB, f.y );
}

void main() {
    mediump vec4 color = texture2DBilinear(tex0, f_texcoord.st);
    
//    color *= 4.0;
//    mediump float h = 1.0 / windowSize.y;
//    mediump vec2 dx = vec2(h, 0.0);
//    mediump vec2 dy = vec2(0.0, h);
//    color += 2.0*texture2D(tex0, f_texcoord.st + dx);
//    color += 2.0*texture2D(tex0, f_texcoord.st + dy);
//    color += 2.0*texture2D(tex0, f_texcoord.st - dx);
//    color += 2.0*texture2D(tex0, f_texcoord.st - dy);
//    color += texture2D(tex0, f_texcoord.st + dx + dy);
//    color += texture2D(tex0, f_texcoord.st + dx - dy);
//    color += texture2D(tex0, f_texcoord.st - dx + dy);
//    color += texture2D(tex0, f_texcoord.st - dx - dy);
//    color /= 16.0;
    
    if (color.r < 0.0) {
        gl_FragColor = mix(vec4(0.4, 0.4, 1.0, 1.0), vec4(1.0, 1.0, 1.0, 0.0), 1.0-pow(16.0*abs(color.r), 3.0));
    } else {
        discard;
    }
}