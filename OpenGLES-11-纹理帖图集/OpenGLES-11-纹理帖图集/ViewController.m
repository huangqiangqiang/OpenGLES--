//
//  ViewController.m
//  OpenGLES-11-纹理帖图集
//
//  Created by 黄强强 on 17/4/14.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "AGLKTextureTransformBaseEffect.h"
#import "SceneAnimateMesh.h"

@interface ViewController ()
@property (nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property (nonatomic, strong) SceneAnimateMesh *animateMesh;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:view.context];
    self.baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    
    self.baseEffect.lightModelAmbientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    
    // 灯光
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 1.0, 0.0);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    
    // model view
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20.0, 20.0, 15.0, 20.0, 0.0, -20.0, 0.0, 1.0, 0.0);
    
    
    GLKTextureInfo *info = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"RabbitTextureAtlas"].CGImage options:@{} error:nil];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = info.name;
    self.baseEffect.texture2d0.target = info.target;
    
    self.animateMesh = [[SceneAnimateMesh alloc] init];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float aspect = ((GLKView *)self.view).drawableWidth * 1.0 / ((GLKView *)self.view).drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80), aspect, 0.1, 100.0);
    self.baseEffect.transform.projectionMatrix = GLKMatrix4Rotate(self.baseEffect.transform.projectionMatrix, GLKMathDegreesToRadians(-90), 0.0, 0.0, 1.0);
    
    [self updateTextureTransform];
    
    [self.baseEffect prepareToDrawMultitextures];
    [self.animateMesh prepareToDraw];
    [self.animateMesh drawEntireMesh];
}


- (void)updateTextureTransform
{
    int numberOfMovieFrames = 51;
    int numberOfMovieFramesPerRow = 8;
    int numberOfMovieFramesPerColumn = 8;
    int numberOfFramesPerSecond = 15;
    
    int movieFrameNumber = (int)floor(self.timeSinceLastResume * numberOfFramesPerSecond) % numberOfMovieFrames;
    
    GLfloat currentRowPosition = (movieFrameNumber % numberOfMovieFramesPerRow) * 1.0f / numberOfMovieFramesPerRow;
    GLfloat currentColumnPosition = (movieFrameNumber / numberOfMovieFramesPerColumn) * 1.0f / numberOfMovieFramesPerColumn;
    
    NSLog(@"%f - %f",currentRowPosition, currentColumnPosition);
    
    self.baseEffect.textureMatrix2d0 = GLKMatrix4MakeTranslation(currentRowPosition, currentColumnPosition, 0.0);
    self.baseEffect.textureMatrix2d0 = GLKMatrix4Scale(self.baseEffect.textureMatrix2d0, 0.125, 0.125, 1.0);
}

@end
