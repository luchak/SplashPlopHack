//
//  TTCQuad.h
//  fancyfluids
//
//  Created by Matt Stanton on 8/2/12.
//  Copyright (c) 2012 Matt Stanton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTCShaderProgram.h"

@interface TTCQuad : NSObject

+ (id) quad;

- (void) drawWithProgram:(TTCShaderProgram*)program;

@end
