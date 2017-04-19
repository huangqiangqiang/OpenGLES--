//
//  ViewController.m
//  OpenGLES-13-天空盒
//
//  Created by 黄强强 on 17/4/18.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModelManager.h"
#import "AGLKSkyboxEffect.h"

@interface ViewController ()
@property (nonatomic, strong) AGLKSkyboxEffect *skyBoxEffect;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) UtilityModelManager *modelManager;
@property (strong, nonatomic, strong) UtilityModel *boatModel;


@property (assign, nonatomic) float angle;
@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    view.drawableDepthFormat =GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.9f, 0.9f, 0.9f, 1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"boat.modelplist" ofType:nil];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:path];
    self.boatModel = [self.modelManager modelNamed:@"boat"];
    
    self.skyBoxEffect = [[AGLKSkyboxEffect alloc] init];
    self.skyBoxEffect.xSize = 6.0f;
    self.skyBoxEffect.ySize = 6.0f;
    self.skyBoxEffect.zSize = 6.0f;
    
    self.eyePosition = GLKVector3Make(0.0, 3.0, 3.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.skyBoxEffect.center = self.eyePosition;
    
    NSString *cubeFile = [[NSBundle mainBundle] pathForResource:@"skybox0.png" ofType:nil];
    GLKTextureInfo *texture = [GLKTextureLoader cubeMapWithContentsOfFile:cubeFile options:nil error:nil];
    self.skyBoxEffect.textureCubeMap.name = texture.name;
    self.skyBoxEffect.textureCubeMap.target = texture.target;
}

- (void)update
{
    self.skyBoxEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z, 0.0, 1.0, 0.0);
    
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(3.0f * sinf(self.angle), 3.0f, 3.0f * cosf(self.angle));
    self.lookAtPosition = GLKVector3Make(0.0, 1.5 + 3.0f * sinf(0.3 * self.angle), 0.0);
    
    self.skyBoxEffect.center = self.eyePosition;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float aspect = ((GLKView *)self.view).drawableWidth * 1.0 / ((GLKView *)self.view).drawableHeight;
    self.skyBoxEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.f), aspect, 0.1f, 20.0f);
    self.baseEffect.transform.modelviewMatrix = self.skyBoxEffect.transform.modelviewMatrix;
    self.baseEffect.transform.projectionMatrix = self.skyBoxEffect.transform.projectionMatrix;
    
    [self.skyBoxEffect prepareToDraw];
    glDepthMask(false);
    [self.skyBoxEffect draw];
    
    [self.baseEffect prepareToDraw];
    [self.modelManager prepareToDraw];
    glDepthMask(true);
    [self.boatModel draw];
}


@end
