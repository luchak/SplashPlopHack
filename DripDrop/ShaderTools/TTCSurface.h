//
//  TTCSurface.h
//  fancyfluids
//
//  Created by Matt Stanton on 8/2/12.
//  Copyright (c) 2012 Matt Stanton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCSurface : NSObject

- (id) initWithWidth:(int)width height:(int)height depth:(int)depth;
// My iPad only seems to support half floats if you're going to try to read things back
// (and possibly even if you just want to render).
- (id) initWithWidth:(int)width height:(int)height depth:(int)depth fullFloat:(BOOL)full_float;
- (void) bindAsOutput;
- (void) unbindAsOutput;

// Always reads with depth 4.
- (NSMutableData*) readWithDepth4;

@property (readonly, nonatomic, assign) GLuint framebuffer_id;
@property (readonly, nonatomic, assign) GLuint texture_id;

@end
