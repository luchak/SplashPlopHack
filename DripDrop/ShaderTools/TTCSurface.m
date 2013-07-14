//
//  TTCSurface.m
//  fancyfluids
//
//  Created by Matt Stanton on 8/2/12.
//  Copyright (c) 2012 Matt Stanton. All rights reserved.
//

#import "TTCSurface.h"

#import <GLKit/GLKit.h>

BOOL CheckExtension(NSString* name) {
    NSString *extensionsString = [NSString stringWithCString:(const char*)glGetString(GL_EXTENSIONS) encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: name];
}

BOOL FloatSupported() {
    static BOOL checked = NO;
    static BOOL supported;
    
    if (!checked) {
        checked = YES;
        supported = CheckExtension(@"GL_OES_texture_float");
    }
    
    return supported;
}

BOOL HalfFloatSupported() {
    static BOOL checked = NO;
    static BOOL supported;
    
    if (!checked) {
        checked = YES;
        supported = CheckExtension(@"GL_EXT_color_buffer_half_float") && CheckExtension(@"GL_OES_texture_half_float");
    }
    
    return supported;
}

@interface TTCSurface () {
    BOOL _allocated;
    GLuint _framebuffer_id;
    GLuint _texture_id;
    GLuint _color_buffer_id;
    int _width;
    int _height;
    int _depth;
    BOOL _full_float;
    GLenum _format;
    GLenum _float_type;
}

- (BOOL) setupBuffers;

@property (nonatomic, assign) BOOL allocated;
@property (nonatomic, assign) GLuint framebuffer_id;
@property (nonatomic, assign) GLuint texture_id;
@property (nonatomic, assign) GLuint color_buffer_id;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int depth;
@property (nonatomic, assign) BOOL full_float;
@property (nonatomic, assign) GLenum format;
@property (nonatomic, assign) GLenum float_type;

@end

@implementation TTCSurface

@synthesize allocated = _allocated;
@synthesize framebuffer_id = _framebuffer_id;
@synthesize texture_id = _texture_id;
@synthesize color_buffer_id = _color_buffer_id;
@synthesize width = _width;
@synthesize height = _height;
@synthesize depth = _depth;
@synthesize full_float = _full_float;
@synthesize format = _format;
@synthesize float_type = _float_type;

- (id) init {
    return [self initWithWidth:0 height:0 depth:0];
}

- (id) initWithWidth:(int)width height:(int)height depth:(int)depth {
    return [self initWithWidth:width height:height depth:depth fullFloat:NO];
}

- (id) initWithWidth:(int)width height:(int)height depth:(int)depth fullFloat:(BOOL)full_float {
    self = [super init];
    
    if (self) {
        self.width = width;
        self.height = height;
        self.depth = depth;
        self.full_float = full_float;
        
        self.allocated = [self setupBuffers];
    }
    
    return self;
}

- (void) dealloc {
    if (self.allocated) {
        self.allocated = NO;
    }
}

- (void) bindAsOutput {
    if (!self.allocated) return;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer_id);
    glViewport(0, 0, self.width, self.height);
}

- (void) unbindAsOutput {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (NSMutableData*) readWithDepth4 {
    if (!self.allocated) return nil;
    
    NSMutableData* data = [NSMutableData dataWithCapacity:(sizeof(float)*self.width*self.height*4)];
    float* pixels = (float*)[data mutableBytes];
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer_id);
    
    // Should make sure the implementation read format and read type are GL_RGBA and GL_FLOAT, respectively.
    glReadPixels(0, 0, self.width, self.height, GL_RGBA, GL_FLOAT, pixels);
    GLenum status = glGetError();
    NSAssert1(GL_NO_ERROR == status, @"GL error %d in pixel read", status);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    return data;
}

- (BOOL) setupBuffers {
    if (self.depth < 1 || self.depth > 4) {
        if (self.depth != 0) {
            NSLog(@"Invalid depth: %d", self.depth);
        }
        return NO;
    }
    
    if (self.full_float && !FloatSupported()) {
        NSLog(@"Single-precision float not supported");
        return NO;
    }
    
    if (!self.full_float && !HalfFloatSupported()) {
        NSLog(@"Half-precision float not supported");
        return NO;
    }
    
    glGenFramebuffers(1, &_framebuffer_id);
    glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer_id);
    
    glGenTextures(1, &_texture_id);
    glBindTexture(GL_TEXTURE_2D, self.texture_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    self.float_type = self.full_float ? GL_FLOAT : GL_HALF_FLOAT_OES;
    switch (self.depth) {
        case 1:
            self.format = GL_RED_EXT;
            break;
            
        case 2:
            self.format = GL_RG_EXT;
            break;
            
        case 3:
            self.format = GL_RGB;
            break;
            
        case 4:
            self.format = GL_RGBA;
            break;
    }
    
    glTexImage2D(GL_TEXTURE_2D, 0, self.format, self.width, self.height, 0, self.format, self.float_type, 0);
    
    GLenum status = glGetError();
    NSAssert1(GL_NO_ERROR == status, @"GL error %d in surface allocation", status);
    
    glGenRenderbuffers(1, &_color_buffer_id);
    glBindRenderbuffer(GL_RENDERBUFFER, self.color_buffer_id);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.texture_id, 0);
    
    status = glGetError();
    NSAssert1(GL_NO_ERROR == status, @"GL error %d when attaching color buffer", status);
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert1(GL_FRAMEBUFFER_COMPLETE == status, @"Failed to attach framebuffer, status: %d", status);
    
    glClearColor(1.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    return YES;
}

@end
