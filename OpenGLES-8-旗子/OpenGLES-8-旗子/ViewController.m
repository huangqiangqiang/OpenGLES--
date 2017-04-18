//
//  ViewController.m
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "SceneAnimateMesh.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *context;

/**
 代替shader的功能，动态生成glsl语句
 */
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) SceneAnimateMesh *animateMesh;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    [view setContext:self.context];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.6, 0.6, 0.6, 1.0);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 0.8, 0.4, 0.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(20, 25, 5, 20, 0, -15, 0, 1, 0);
    
    glEnable(GL_DEPTH_TEST);
    
    self.animateMesh = [[SceneAnimateMesh alloc] init];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspectRatio, 0.1, 255.0);
    
    [self.animateMesh updateMeshWithElapsedTime:self.timeSinceLastResume];
    
    [self.baseEffect prepareToDraw];
    [self.animateMesh prepareToDraw];
    [self.animateMesh drawEntireMesh];
}

- (void)dealloc
{
    NSLog(@"%@ ------ dealloc",self.class);
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    view.context = nil;
    [EAGLContext setCurrentContext:nil];
    self.animateMesh = nil;
}

@end
