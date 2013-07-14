//
//  SplashPlopHack.h
//  SplashPlopHack
//
//  Created by Matt Stanton on 7/13/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@interface SplashPlopHack : NSObject

- (id) initWithBounds:(CGRect)rect radius:(CGFloat)radius;
- (void) addParticlesInRect:(CGRect)rect;
- (void) addParticlesInRect:(CGRect)rect maxParticles:(int)max;
- (void) step:(CGFloat)dt;
- (BOOL) isActive:(int)pid;
- (CGPoint) pos:(int)pid;
- (CGFloat) radius;
- (int) size;
- (CGRect) bounds;
- (CGFloat) density:(int)pid;
- (void) initDensity;
- (void) setGravity:(CGPoint)g;
- (void) clear;
- (CGFloat) accelMagnitude:(int)pid;

@end
