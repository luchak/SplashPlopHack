//
//  DDViewController.m
//  DripDrop
//
//  Created by Matt Stanton on 7/13/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

#import "DDAppdelegate.h"
#import "DDViewController.h"
#import <SplashPlopHack/SplashPlopHack.h>
#import "../ShaderTools/TTCShaderLibrary.h"
#import "../ShaderTools/TTCSurface.h"
#import "../ShaderTools/TTCQuad.h"

#import "DDAudioPlayer.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_WINDOW_SIZE,
    UNIFORM_PARTICLE_RADIUS,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    NUM_ATTRIBUTES
};

static float phiShrinkFactor = 4.0;

@interface DDViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    SplashPlopHack* _sph;
    GLfloat* _pos;
    int _num_active;
    
    CMMotionManager* _motionManager;
    
    TTCShaderProgram* _surfaceRenderParticleSplatProgram;
    TTCShaderProgram* _renderSplattedPositionsProgram;
    TTCShaderProgram* _phiProgram;
    TTCShaderProgram* _hblurProgram;
    TTCShaderProgram* _vblurProgram;
    TTCSurface* _positionWeightSplatSurface;
    TTCSurface* _phiSurface;
    TTCSurface* _phiTempSurface;
    
    DDAudioPlayer* _audioPlayer;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation DDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    [self setPreferredFramesPerSecond:30];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    _sph = [[SplashPlopHack alloc] initWithBounds:CGRectMake(0.0, 0.0, 1.0, 1.0) radius:0.027];
    [_sph addParticlesInRect:CGRectMake(0.0, 0.0, 0.5, 0.5)];
    [_sph initDensity];
    
    _pos = malloc(sizeof(GLfloat)*2*[_sph size]);
    _num_active = 0;

    _motionManager = [(DDAppDelegate*)[UIApplication sharedApplication].delegate motionManager];
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    
    [self setupGL];
    
    _audioPlayer = [[DDAudioPlayer alloc] init];
    [_audioPlayer setupAudio];
}

- (void)dealloc
{
    free(_pos);
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // yes width and height are transposed, no I don't know why this fixes it.
    _positionWeightSplatSurface = [[TTCSurface alloc] initWithWidth:self.view.bounds.size.height/phiShrinkFactor height:self.view.bounds.size.width/phiShrinkFactor depth:4 fullFloat:NO];
    _phiSurface = [[TTCSurface alloc] initWithWidth:self.view.bounds.size.height/phiShrinkFactor height:self.view.bounds.size.width/phiShrinkFactor depth:4 fullFloat:NO];
    _phiTempSurface = [[TTCSurface alloc] initWithWidth:self.view.bounds.size.height/phiShrinkFactor height:self.view.bounds.size.width/phiShrinkFactor depth:4 fullFloat:NO];
    TTCShaderLibrary* shaderLibrary = [[TTCShaderLibrary alloc] init];
    [shaderLibrary compileFragmentShaderWithName:@"fShader"];
    [shaderLibrary compileVertexShaderWithName:@"vShader"];
    [shaderLibrary compileFragmentShaderWithName:@"show_texture"];
    [shaderLibrary compileVertexShaderWithName:@"vertex_default"];
    [shaderLibrary compileFragmentShaderWithName:@"phi"];
    [shaderLibrary compileFragmentShaderWithName:@"hblur"];
    [shaderLibrary compileFragmentShaderWithName:@"vblur"];

    
    [_positionWeightSplatSurface bindAsOutput];
    _surfaceRenderParticleSplatProgram = [shaderLibrary programWithShaders:@[@"fShader", @"vShader"] error:NULL];
    [_surfaceRenderParticleSplatProgram validate];
    _renderSplattedPositionsProgram = [shaderLibrary programWithShaders:@[@"show_texture", @"vertex_default"] error:NULL];
    [_renderSplattedPositionsProgram validate];
    _phiProgram = [shaderLibrary programWithShaders:@[@"phi", @"vertex_default"] error:NULL];
    [_phiProgram validate];
    _hblurProgram = [shaderLibrary programWithShaders:@[@"hblur", @"vertex_default"] error:NULL];
    [_hblurProgram validate];
    _vblurProgram = [shaderLibrary programWithShaders:@[@"vblur", @"vertex_default"] error:NULL];
    [_vblurProgram validate];
    [_positionWeightSplatSurface unbindAsOutput];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    _surfaceRenderParticleSplatProgram = nil;
    _renderSplattedPositionsProgram = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    _modelViewProjectionMatrix = GLKMatrix4MakeOrtho(0.5*(1.0-aspect), 1.0 + 0.5*(aspect-1.0), 0.0, 1.0, -1.0, 1.0);

    [_sph step:1.0/30.0];
    
    _num_active = 0;
    for (int i = 0; i < [_sph size]; i++) {
        if ([_sph isActive:i]) {
            CGPoint ppos = [_sph pos:i];
            _pos[_num_active*2] = ppos.x;
            _pos[_num_active*2+1] = ppos.y;
            _num_active++;
        }
    }
    
    // -x is down
    // +y is left
    CMAcceleration g = _motionManager.deviceMotion.gravity;
    [_sph setGravity:CGPointMake(-g.y, g.x)];
    
    if ([_audioPlayer numClips] > 0) {
        [_audioPlayer playClip:0];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [_surfaceRenderParticleSplatProgram use];
    glUniformMatrix4fv([_surfaceRenderParticleSplatProgram locationForUniformWithName:@"modelViewProjectionMatrix"], 1, 0, _modelViewProjectionMatrix.m);
    glUniform2f([_surfaceRenderParticleSplatProgram locationForUniformWithName:@"windowSize"], self.view.bounds.size.width/phiShrinkFactor, self.view.bounds.size.height/phiShrinkFactor);
    glUniform1f([_surfaceRenderParticleSplatProgram locationForUniformWithName:@"particleRadius"], [_sph radius]);
    
    [_positionWeightSplatSurface bindAsOutput];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    [_surfaceRenderParticleSplatProgram drawPoints:_pos withDimension:2 andLength:_num_active];
    [_positionWeightSplatSurface unbindAsOutput];
    glBlendFunc(GL_ONE, GL_ZERO);
    glDisable(GL_BLEND);
    
    
    [_phiProgram use];
    glUniform2f([_phiProgram locationForUniformWithName:@"windowSize"], self.view.bounds.size.width/phiShrinkFactor, self.view.bounds.size.height/phiShrinkFactor);
    glUniform1f([_phiProgram locationForUniformWithName:@"particleRadius"], [_sph radius]);
    [_phiSurface bindAsOutput];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [_phiProgram bindTexture2D:_positionWeightSplatSurface.texture_id atIndex:0 toUniform:@"tex0"];
    [[TTCQuad quad] drawWithProgram:_phiProgram];
    
    [_hblurProgram use];
    glUniform2f([_hblurProgram locationForUniformWithName:@"windowSize"], self.view.bounds.size.width/phiShrinkFactor, self.view.bounds.size.height/phiShrinkFactor);
    [_phiTempSurface bindAsOutput];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [_hblurProgram bindTexture2D:_phiSurface.texture_id atIndex:0 toUniform:@"tex0"];
    [[TTCQuad quad] drawWithProgram:_hblurProgram];

    [_vblurProgram use];
    glUniform2f([_vblurProgram locationForUniformWithName:@"windowSize"], self.view.bounds.size.width/phiShrinkFactor, self.view.bounds.size.height/phiShrinkFactor);
    [_phiSurface bindAsOutput];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [_vblurProgram bindTexture2D:_phiTempSurface.texture_id atIndex:0 toUniform:@"tex0"];
    [[TTCQuad quad] drawWithProgram:_vblurProgram];
    
    [((GLKView*)self.view) bindDrawable];
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [_renderSplattedPositionsProgram use];
    glUniform2f([_renderSplattedPositionsProgram locationForUniformWithName:@"windowSize"], self.view.bounds.size.width/phiShrinkFactor, self.view.bounds.size.height/phiShrinkFactor);
    [_renderSplattedPositionsProgram bindTexture2D:_phiSurface.texture_id atIndex:0 toUniform:@"tex0"];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [[TTCQuad quad] drawWithProgram:_renderSplattedPositionsProgram];
    glDisable(GL_BLEND);
}


@end
