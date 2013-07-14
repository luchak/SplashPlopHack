//
//  Shader.fsh
//  DripDrop
//
//  Created by Matt Stanton on 7/13/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

//varying lowp vec4 colorVarying;
//
//void main()
//{
//    if( distance(gl_FragCoord.xy, gl_Position) > gl_PointSize ) discard;
//    gl_FragColor = colorVarying;
//}

// [Fragment shader]
// Circles with GL_POINTS

uniform mediump vec2 windowSize;
uniform mediump float particleRadius;
varying mediump vec2 particlePosition;

mediump float Poly6(mediump vec2 p1, mediump vec2 p2) {
    mediump vec2 r = p1-p2;
    r /= 1.0*particleRadius;
    mediump float t = 1.0 - dot(r,r);
    return max(t*t*t, 0.0);
}

void main() {
    mediump vec2 world_coords = gl_FragCoord.xy / windowSize.y;
    world_coords.x -= ((windowSize.x / windowSize.y) - 1.0) * 0.5;
    mediump float weight = Poly6(world_coords, particlePosition)*0.01;
    gl_FragColor.rg = particlePosition*weight;
    gl_FragColor.b = weight;
}