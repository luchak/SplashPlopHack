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

varying mediump vec2 screenPos;
varying mediump float radius;
varying lowp vec4 colorVarying;

void main() {
    // Sphere shaded
    if( distance(gl_FragCoord.xy, screenPos) > radius ) discard;
    else gl_FragColor = colorVarying;
}