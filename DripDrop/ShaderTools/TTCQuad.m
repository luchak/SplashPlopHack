//
//  TTCQuad.m
//  fancyfluids
//
//  Created by Matt Stanton on 8/2/12.
//  Copyright (c) 2012 Matt Stanton. All rights reserved.
//

#import "TTCQuad.h"

#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char*)NULL + (i))

@interface TTCQuad () {
    GLuint _vao;
    GLuint _vbo;
    GLuint _ibo;
}

@property (nonatomic, assign) GLuint vao;
@property (nonatomic, assign) GLuint vbo;
@property (nonatomic, assign) GLuint ibo;

@end

@implementation TTCQuad

@synthesize vao = _vao;
@synthesize vbo = _vbo;
@synthesize ibo = _ibo;

+ (id) quad {
    static id quad = nil;
    
    if (quad == nil) {
        quad = [[self alloc] init];
    }
    
    return quad;
}

- (id) init {
    self = [super init];
    
    if (self) {
        float quad_vertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f,
            -1.0f,  1.0f, 0.0f, 1.0f,
            1.0f, -1.0f, 1.0f, 0.0f,
            1.0f,  1.0f, 1.0f, 1.0f
        };
        
        glGenBuffers(1, &_vbo);
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(quad_vertices), quad_vertices, GL_STATIC_DRAW);
        
        glGenVertexArraysOES(1, &_vao);
        glBindVertexArrayOES(self.vao);
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
        glVertexAttribPointer(TTC_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), BUFFER_OFFSET(0 * sizeof(float)));
        glEnableVertexAttribArray(TTC_ATTRIB_POSITION);
        glVertexAttribPointer(TTC_ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), BUFFER_OFFSET(2 * sizeof(float)));
        glEnableVertexAttribArray(TTC_ATTRIB_TEXCOORD);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArrayOES(0);
    }
    
    return self;
}

- (void) dealloc {
    glDeleteVertexArraysOES(1, &_vao);
    glDeleteBuffers(1, &_vbo);
}

- (void) drawWithProgram:(TTCShaderProgram*)program {
    glUseProgram(program.program_id);
    glBindVertexArrayOES(self.vao);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArrayOES(0);
    glUseProgram(0);
}

@end
