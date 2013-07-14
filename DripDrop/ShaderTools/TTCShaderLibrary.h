//
//  TTShaderLibrary.h
//  fancyfluids
//
//  Created by Matt Stanton on 8/2/12.
//  Copyright (c) 2012 Matt Stanton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTCShaderProgram.h"

@interface TTCShaderLibrary : NSObject

- (id) initWithBasePath:(NSString*)path;
- (BOOL) compileFragmentShaderWithName:(NSString*)name;
- (BOOL) compileVertexShaderWithName:(NSString*)name;
- (TTCShaderProgram*) programWithShaders:(NSArray*)shader_names error:(NSError**)error;

@end
