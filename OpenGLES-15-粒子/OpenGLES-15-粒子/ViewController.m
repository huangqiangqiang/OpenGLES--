//
//  ViewController.m
//  OpenGLES-15-粒子
//
//  Created by 黄强强 on 17/4/19.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "AGLKPointParticleEffect.h"

@interface ViewController ()
@property (nonatomic, strong) AGLKPointParticleEffect *particleEffect;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;
@property (strong, nonatomic) NSArray *emitterBlocks;
@property (assign, nonatomic) NSInteger currentEmitterIndex;

@property (strong, nonatomic) GLKTextureInfo *ballParticleTexture;
@property (strong, nonatomic) GLKTextureInfo *burstParticleTexture;
@property (strong, nonatomic) GLKTextureInfo *smokeParticleTexture;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    // 开启混合功能
    glEnable(GL_BLEND);
    // 定义像素算法
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.9f, 0.9f, 0.9f, 1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f,1.0f,1.0f,1.0f);
    
    self.particleEffect = [[AGLKPointParticleEffect alloc] init];
    self.particleEffect.gravity = AGLKDefaultGravity;
    
    
    NSString *ball = [[NSBundle mainBundle] pathForResource:@"ball.png" ofType:nil];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:ball options:@{} error:nil];
    self.particleEffect.texture2d0.name = info.name;
    self.particleEffect.texture2d0.target = info.target;
    
    // 试着改变index查看四种栗子运动
    self.currentEmitterIndex = 2;
    
    self.emitterBlocks = @[^{
        self.autoSpawnDelta = 0.5f;
        float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
        [self.particleEffect
         addParticleAtPosition:GLKVector3Make(0.0, 0.0, 0.9)
         velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0)
         force:GLKVector3Make(0.0, 9.0, -1.0)
         size:5.0f
         lifeSpanSeconds:3.2f
         fadeDurationSeconds:0.5f];
    },
    ^{  // Billow
        self.autoSpawnDelta = 0.05f;
        
        // Reverse gravity
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.5f, 0.0f);
        
        for(int i = 0; i < 20; i++)
        {
            float randomXVelocity = -0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = 0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            
            [self.particleEffect
             addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity, 
                                     0.0, 
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f) 
             size:64.0f 
             lifeSpanSeconds:2.2f
             fadeDurationSeconds:3.0f];
        }
    },
    ^{  // Pulse
        self.autoSpawnDelta = 0.5f;
        
        // Turn off gravity
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            
            [self.particleEffect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f) 
             velocity:GLKVector3Make(
                                     randomXVelocity, 
                                     randomYVelocity, 
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f) 
             size:4.0f 
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }
    },
    ^{  // Fire ring
        self.autoSpawnDelta = 3.2f;
        
        // Turn off gravity
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            GLKVector3 velocity = GLKVector3Normalize(GLKVector3Make(randomXVelocity,randomYVelocity,0.0f));
            
            [self.particleEffect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:velocity
             force:GLKVector3MultiplyScalar(velocity, -1.5f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.1f];
        }
    }];
}

- (void)update
{
    NSTimeInterval timeElapsed = self.timeSinceLastResume;
    self.particleEffect.elapsedSeconds = timeElapsed;
    
    if (self.autoSpawnDelta < (timeElapsed - self.lastSpawnTime)) {
        self.lastSpawnTime = self.timeSinceLastResume;
        void(^emitter)() = self.emitterBlocks[self.currentEmitterIndex];
        emitter();
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.2, 0.2, 0.2, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    const GLfloat aspectRatio = view.drawableWidth * 1.0 / view.drawableHeight;
    [self preparePointOfViewWithAspectRatio:aspectRatio];
    
    self.particleEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    self.particleEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    
    
    [self.particleEffect prepareToDraw];
    [self.particleEffect draw];
}


- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f), aspectRatio, 0.1f, 20.0f);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(
                         0.0, 0.0, 1.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
    
}

@end
