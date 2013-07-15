//
//  SplashPlopHack.m
//  SplashPlopHack
//
//  Created by Matt Stanton on 7/13/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

#import "SplashPlopHack.h"

#import "../../src/particle.h"

@interface SplashPlopHack () {
    SPHack::ParticleSystem* _particles;
}

@end

@implementation SplashPlopHack

- (id) initWithBounds:(CGRect)bounds radius:(CGFloat)radius {
    self = [super init];
    if (self) {
        SPHack::AABB aabb(SPHack::Vec2(bounds.origin.x, bounds.origin.y),
                          SPHack::Vec2(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height));
        _particles = new SPHack::ParticleSystem(aabb, static_cast<SPHack::Real>(radius));
    }
    return self;
    
}

- (void) dealloc {
    delete _particles;
}

- (void) addParticlesInRect:(CGRect)rect {
    SPHack::AABB aabb(SPHack::Vec2(rect.origin.x, rect.origin.y),
                      SPHack::Vec2(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
    _particles->AddParticles(aabb);
}

- (void) addParticlesInRect:(CGRect)rect maxParticles:(int)max {
    SPHack::AABB aabb(SPHack::Vec2(rect.origin.x, rect.origin.y),
                      SPHack::Vec2(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
    _particles->AddParticles(aabb, max);
}


- (void) step:(CGFloat)dt {
    _particles->Step(dt);
}

- (BOOL) isActive:(int)pid {
    return _particles->isActive(pid);
}

- (CGPoint) pos:(int)pid {
    SPHack::Vec2 point = _particles->pos(pid);
    return CGPoint{point.x, point.y};
}

- (CGFloat) radius {
    return _particles->radius();
}

- (int) size {
    return _particles->size();
}

- (CGRect) bounds {
    const SPHack::AABB& bounds = _particles->bounds();
    SPHack::Vec2 size = bounds.size();
    return CGRect{CGPoint{bounds.min()[0], bounds.max()[0]}, CGSize{size.x, size.y}};
}

- (CGFloat) density:(int)pid {
    return _particles->density(pid);
}

- (void) initDensity {
    _particles->InitDensity();
}

- (void) setGravity:(CGPoint)g {
    _particles->setGravity(SPHack::Vec2(g.x, g.y));
}

- (void) clear {
    _particles->Clear();
}

- (CGFloat) accelMagnitude:(int)pid {
    return _particles->accelMagnitude(pid);
}

- (void) setSurfaceTension:(CGFloat)tension {
    _particles->setSurfaceTension(tension);
}

- (void) setCFMScale:(CGFloat)scale {
    _particles->setCFMScale(scale);
}


@end
