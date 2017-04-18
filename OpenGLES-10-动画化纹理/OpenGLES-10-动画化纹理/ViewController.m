//
//  ViewController.m
//  OpenGLES-10-动画化纹理
//
//  Created by 黄强强 on 17/4/13.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "SceneAnimateMesh.h"
#import "SceneCanLightModel.h"
#import "AGLKTextureTransformBaseEffect.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;

@property (nonatomic, strong) SceneAnimateMesh *animateMesh;
@property (nonatomic, strong) SceneCanLightModel *canLightModel;

@property (nonatomic, assign) GLKMatrixStackRef matrixStackRef;

@property (nonatomic, assign) float light0offsetX;
@property (nonatomic, assign) float light0offsetZ;
@property (nonatomic, assign) float light1offsetX;
@property (nonatomic, assign) float light1offsetZ;
@end


GLKVector3 spotLight0Position = {10.0, 15.0, -10.0};
GLKVector3 spotLight1Position = {30.0, 15.0, -10.0};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 基本设置
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_DEPTH_TEST);
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    
    self.baseEffect.material.ambientColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    self.baseEffect.lightingType = GLKLightingTypePerVertex;
//    self.baseEffect.lightModelTwoSided = GL_FALSE;
//    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.6f, 0.6f, 0.6f, 1.0f);
    
    // 灯光
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    self.baseEffect.light0.spotExponent = 20.0;
    self.baseEffect.light0.spotCutoff = 30.0;
    
    self.baseEffect.light1.enabled = GL_TRUE;
    self.baseEffect.light1.diffuseColor = GLKVector4Make(0.0, 1.0, 1.0, 1.0);
    self.baseEffect.light1.spotExponent = 20.0;
    self.baseEffect.light1.spotCutoff = 30.0;
    
    self.baseEffect.light2.enabled = GL_TRUE;
    self.baseEffect.light2Position = GLKVector4Make(1.0, 0.5, 0.0, 0.0);
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    
    // 纹理
    self.textureInfo = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"RadiusSelectionTool"].CGImage options:@{} error:nil];
    self.baseEffect.texture2d0.name = self.textureInfo.name;
    self.baseEffect.texture2d0.target = self.textureInfo.target;
    
    // 设置model view projection
    GLKVector3 eyePosition = GLKVector3Make(20.0, 25.0, 5.0);
    GLKVector3 lookPosition = GLKVector3Make(20.0, 0.0, -15.0);
    GLKVector3 upPosition = GLKVector3Make(0.0, 1.0, 0.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, lookPosition.x, lookPosition.y, lookPosition.z, upPosition.x, upPosition.y, upPosition.z);
    
    // 初始化顶点模型
    self.animateMesh = [[SceneAnimateMesh alloc] init];
    self.canLightModel = [[SceneCanLightModel alloc] init];
    
    // 初始化矩阵栈
    self.matrixStackRef = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(self.matrixStackRef, self.baseEffect.transform.modelviewMatrix);
}

- (void)update
{
    self.light0offsetX = 30.0 * sinf(self.timeSinceLastResume);
    self.light0offsetZ = 30.0 * cosf(self.timeSinceLastResume);
    self.light1offsetX = -30.0 * sinf(self.timeSinceLastResume);
    self.light1offsetZ = 30.0 * cosf(self.timeSinceLastResume);
    
    // 纹理动画
    self.baseEffect.textureMatrix2d0 = GLKMatrix4MakeTranslation(0.5, 0.5, 0.0);
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Rotate(self.baseEffect.textureMatrix2d0, self.timeSinceLastResume, 0.0, 0.0, 1.0);
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Translate(self.baseEffect.textureMatrix2d0, -0.5, -0.5, 0.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float aspect = ((GLKView *)self.view).drawableWidth * 1.0 / ((GLKView *)self.view).drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 100);
    
    [self drawLight0];
    [self drawLight1];
    
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    [self.animateMesh updateMeshWithElapsedTime:self.timeSinceLastResume];
    [self.baseEffect prepareToDrawMultitextures];
    [self.animateMesh prepareToDraw];
    [self.animateMesh drawEntireMesh];
}

- (void)drawLight0
{
    GLKMatrixStackPush(self.matrixStackRef);
    GLKMatrixStackTranslate(self.matrixStackRef, spotLight0Position.x, spotLight0Position.y, spotLight0Position.z);
    GLKMatrixStackRotateX(self.matrixStackRef, GLKMathDegreesToRadians(self.light0offsetX));
    GLKMatrixStackRotateZ(self.matrixStackRef, GLKMathDegreesToRadians(self.light0offsetZ));
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStackRef);
    
    self.baseEffect.light0Position = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    self.baseEffect.light0SpotDirection = GLKVector3Make(0.0, -1.0, 0.0);
    
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    GLKMatrixStackPop(self.matrixStackRef);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStackRef);
}

- (void)drawLight1
{
    GLKMatrixStackPush(self.matrixStackRef);
    GLKMatrixStackTranslate(self.matrixStackRef, spotLight1Position.x, spotLight1Position.y, spotLight1Position.z);
    GLKMatrixStackRotateX(self.matrixStackRef, GLKMathDegreesToRadians(self.light1offsetX));
    GLKMatrixStackRotateZ(self.matrixStackRef, GLKMathDegreesToRadians(self.light1offsetZ));
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStackRef);
    
    self.baseEffect.light1Position = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    self.baseEffect.light1SpotDirection = GLKVector3Make(0.0, -1.0, 0.0);
    
    self.baseEffect.texture2d0.enabled = GL_FALSE;
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.canLightModel draw];
    
    GLKMatrixStackPop(self.matrixStackRef);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.matrixStackRef);
}


@end
