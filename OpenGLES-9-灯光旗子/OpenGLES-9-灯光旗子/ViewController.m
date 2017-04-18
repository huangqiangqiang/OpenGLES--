//
//  ViewController.m
//  OpenGLES-9-灯光旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "SceneAnimateMesh.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneCanLightModel.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) SceneAnimateMesh *animatedMesh;
@property (nonatomic, strong) SceneCanLightModel *canLightModel;
@property (nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property (nonatomic, assign) GLKMatrixStackRef matrixStack;

@property (nonatomic, assign) float spotLight0XAngelDeg;
@property (nonatomic, assign) float spotLight0ZAngelDeg;
@property (nonatomic, assign) float spotLight1XAngelDeg;
@property (nonatomic, assign) float spotLight1ZAngelDeg;
@end

static const GLKVector4 spotLight0Position = {30.0, 18.0, -10.0, 1.0};
static const GLKVector4 spotLight1Position = {10.0, 18.0, -10.0, 1.0};
static const GLKVector4 spotLight2Position = {1.0, 0.5, 0.0, 0.0};
@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredFramesPerSecond = 60.0;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    glEnable(GL_DEPTH_TEST);
    
    // 灯光参数设置
    self.baseEffect.lightingType = GLKLightingTypePerPixel;
    
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.position = GLKVector4Make(0, 0, 0, 1);
    // 这个角度决定了灯光圆锥体的宽度
    self.baseEffect.light0.spotCutoff = 30.0;
    // 定义聚光灯圆锥体内的光线照射方向的矢量
    self.baseEffect.light0.spotDirection = GLKVector3Make(0.0, -1.0, 0.0);
    // 聚光灯的灯光从中心到边缘变暗的速度
    self.baseEffect.light0.spotExponent = 20.f;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    
    self.baseEffect.light1.enabled = GL_TRUE;
    self.baseEffect.light1.diffuseColor = GLKVector4Make(0.0, 1.0, 1.0, 1.0);
    self.baseEffect.light1.spotCutoff = 30.0;
    self.baseEffect.light1.spotExponent = 20.f;
    
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2.position = spotLight2Position;GLKVector4Make(1.0, 1.0, 1.0, 0.0);
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.9, 0.9, 0.9, 1.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20.0, 25.0, 15.0, 20.0, 5.0, -10.0, 0.0, 1.0, 0.0);
    
    self.animatedMesh = [[SceneAnimateMesh alloc] init];
    self.canLightModel = [[SceneCanLightModel alloc] init];
    
    self.matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(self.matrixStack, self.baseEffect.transform.modelviewMatrix);
}

- (void)update
{
    [self updateSpotLightDirections];
}

- (void)updateSpotLightDirections
{
    self.spotLight0XAngelDeg = 30.0 * sinf(self.timeSinceLastResume);
    self.spotLight0ZAngelDeg = 30.0 * cosf(self.timeSinceLastResume);
    self.spotLight1XAngelDeg = -30.0 * sinf(self.timeSinceLastResume);
    self.spotLight1ZAngelDeg = 30.0 * cosf(self.timeSinceLastResume);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 100.f);
    
    [self drawLight0];
    [self drawLight1];
    
    [self.animatedMesh updateMeshWithElapsedTime:self.timeSinceLastResume];
    
    [self.baseEffect prepareToDraw];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
}

- (void)drawLight0
{
    
    GLKMatrixStackPush(self.matrixStack);
    GLKMatrixStackTranslate(self.matrixStack, spotLight0Position.x, spotLight0Position.y, spotLight0Position.z);
    GLKMatrixStackRotate(self.matrixStack, GLKMathDegreesToRadians(self.spotLight0XAngelDeg), 1.0, 0.0, 0.0);
    GLKMatrixStackRotate(self.matrixStack, GLKMathDegreesToRadians(self.spotLight0ZAngelDeg), 0.0, 0.0, 1.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStack);
    self.baseEffect.light0.position = GLKVector4Make(0, 0, 0, 1);
    // 定义聚光灯圆锥体内的光线照射方向的矢量
    self.baseEffect.light0.spotDirection = GLKVector3Make(0.0, -1.0, 0.0);
    
    [self.baseEffect prepareToDraw];
    [self.canLightModel draw];
    
    GLKMatrixStackPop(self.matrixStack);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStack);
}

- (void)drawLight1
{
    GLKMatrixStackPush(self.matrixStack);
    GLKMatrixStackTranslate(self.matrixStack, spotLight1Position.x, spotLight1Position.y, spotLight1Position.z);
    GLKMatrixStackRotate(self.matrixStack, GLKMathDegreesToRadians(self.spotLight1XAngelDeg), 1.0, 0.0, 0.0);
    GLKMatrixStackRotate(self.matrixStack, GLKMathDegreesToRadians(self.spotLight1ZAngelDeg), 0.0, 0.0, 1.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStack);
    
    self.baseEffect.light1.position = GLKVector4Make(0, 0, 0, 1);
    self.baseEffect.light1.spotDirection = GLKVector3Make(0.0, -1.0, 0.0);
    
    [self.baseEffect prepareToDraw];
    [self.canLightModel draw];
    
    GLKMatrixStackPop(self.matrixStack);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStack);
}

- (void)dealloc
{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    
    self.animatedMesh = nil;
    self.canLightModel = nil;
}

@end
