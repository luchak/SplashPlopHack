//
//  TTShaderLibrary.m
//  fancyfluids
//
//  Created by Matt Stanton on 8/2/12.
//  Copyright (c) 2012 Matt Stanton. All rights reserved.
//

#import "TTCShaderLibrary.h"

#import <GLKit/GLKit.h>

@interface TTCShaderLibrary () {
    NSString* _path;
    NSMutableDictionary* _shaders;
}

- (BOOL) compileShaderWithName:(NSString*)name ofType:(GLenum) type;

@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSMutableDictionary* shaders;

@end

@implementation TTCShaderLibrary

@synthesize path = _path;
@synthesize shaders = _shaders;

- (id) init {
    return [self initWithBasePath:nil];
}

- (id) initWithBasePath:(NSString *)path {
    self = [super init];
    if (self) {
        self.path = path;
        self.shaders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL) compileFragmentShaderWithName:(NSString*)name {
    return [self compileShaderWithName:name ofType:GL_FRAGMENT_SHADER];
}

- (BOOL) compileVertexShaderWithName:(NSString*)name {
    return [self compileShaderWithName:name ofType:GL_VERTEX_SHADER];
}

- (BOOL) compileShaderWithName:(NSString*)name ofType:(GLenum)type {
    NSString* extension;
    switch (type) {
        case GL_FRAGMENT_SHADER:
            extension = @"fsh";
            break;
            
        case GL_VERTEX_SHADER:
            extension = @"vsh";
            break;
            
        default:
            NSLog(@"Unrecognized shader type: %d", type);
            return NO;
            break;
    }
    NSString* shader_path = [[NSBundle mainBundle] pathForResource:name ofType:extension inDirectory:self.path];
    if (nil == shader_path) {
        NSLog(@"Unable to find path for shader with name %@ and extension %@", name, extension);
        return NO;
    }
    NSString* shader_text = [NSString stringWithContentsOfFile:shader_path encoding:NSUTF8StringEncoding error:NULL];
    if (nil == shader_text) {
        NSLog(@"Unable to load shader from path %@", shader_path);
        return NO;
    }
    const GLchar* shader_text_utf8 = (const GLchar*)[shader_text UTF8String];
    GLint shader_text_length = [shader_text length];
    
    GLuint shader_id = glCreateShader(type);
    glShaderSource(shader_id, 1, &shader_text_utf8, &shader_text_length);
    glCompileShader(shader_id);
    
    GLint did_compile;
    glGetShaderiv(shader_id, GL_COMPILE_STATUS, &did_compile);
    if (did_compile != GL_TRUE) {
        NSLog(@"Failed to compile shader with name %@ and extension %@.", name, extension);
        GLint log_length;
        glGetShaderiv(shader_id, GL_INFO_LOG_LENGTH, &log_length);
        if (log_length > 0) {
            GLchar* log = (GLchar*)malloc(log_length);
            glGetShaderInfoLog(shader_id, log_length, &log_length, log);
            NSLog(@"Shader compile log:\n%s", log);
            free(log);
        }
        glDeleteShader(shader_id);
        return NO;
    } else {
        [self.shaders setObject:[NSNumber numberWithInt:shader_id] forKey:name];
        return YES;
    }
}

- (TTCShaderProgram*) programWithShaders:(NSArray*)shader_names error:(NSError**)error {
    NSMutableArray* shader_ids = [NSMutableArray array];
    for (NSString* shader_name in shader_names) {
        NSNumber* shader_id = [self.shaders objectForKey:shader_name];
        if (nil == shader_id) {
            NSLog(@"Could not find shader with name %@.", shader_name);
            if (error != NULL) {
                NSMutableDictionary* error_details = [NSMutableDictionary dictionary];
                [error_details setValue:[NSString stringWithFormat:@"Shader %@ not found", shader_name] forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"com.trontronic" code:100 userInfo:error_details];
            }
            return nil;
        }
        [shader_ids addObject:shader_id];
    }
    
    TTCShaderProgram* program = [[TTCShaderProgram alloc] init];
    BOOL success = [program createFromShaders:shader_ids];
    if (!success) {
        if (error != NULL) {
            NSMutableDictionary* error_details = [NSMutableDictionary dictionary];
            [error_details setValue:[NSString stringWithFormat:@"Program failed to compile"] forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"com.trontronic" code:101 userInfo:error_details];
        }
        return nil;
    }
    
    return program;
}

@end
