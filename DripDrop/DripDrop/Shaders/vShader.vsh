//
//  Shader.vsh
//  DripDrop
//
//  Created by Matt Stanton on 7/13/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

//attribute vec4 position;
//
//varying lowp vec4 colorVarying;
//
//uniform mat4 modelViewProjectionMatrix;
//
//void main()
//{
//    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
//    colorVarying = diffuseColor;
//    
//    gl_Position = modelViewProjectionMatrix * position;
//    gl_PointSize = 10.0;
//}

attribute vec4 position;
uniform mat4 modelViewProjectionMatrix;
varying vec2 particlePosition;
uniform mediump float particleRadius;
uniform mediump vec2 windowSize;

void main() {
    gl_Position = modelViewProjectionMatrix * position;
    particlePosition = position.xy;
    gl_PointSize = windowSize.y * 1.8 * particleRadius;
}
//    gl_PointSize = particleRadius * windowSize.y * 2.0;
//
//    // Convert position to window coordinates
//    vec2 halfsize = vec2(windowSize.x, windowSize.y) * 0.5;
//    screenPos = halfsize + ((gl_Position.xy / gl_Position.w) * halfsize);
    
//    // Convert radius to window coordinates
//    radius = gl_PointSize * 0.5;
//}