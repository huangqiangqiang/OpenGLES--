//
//  ViewController.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "SceneRinkModel.h"
#import "SceneCarModel.h"
#import "SceneCar.h"

@interface ViewController () <SceneCarControllerProtocal>
@property (nonatomic, strong) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) SceneModel *rinkModel;
@property (strong, nonatomic) SceneModel *carModel;
/**
 眼睛的位置
 */
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (weak, nonatomic) IBOutlet UISwitch *switchMode;

/**
 眼睛看向的位置
 */
@property (nonatomic, assign) GLKVector3 lookAtPosition;
@property (nonatomic, strong) NSMutableArray *cars;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.position = GLKVector4Make(1.0, 0.8, 0.4,0.0);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    self.cars= [NSMutableArray array];
    
    self.rinkModel = [[SceneRinkModel alloc] init];
    self.carModel = [[SceneCarModel alloc] init];
    
    SceneCar *carA = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, 1.0) velocity:GLKVector3Make(-0.7f, 0.0, 1.5f) color:GLKVector4Make(1.0, 0.0, 0.0, 1.0)];
    SceneCar *carB = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(-1.0, 0.0, 1.0) velocity:GLKVector3Make(1.5f, 0.0, -0.6f) color:GLKVector4Make(0.0, 1.0, 0.0, 1.0)];
    SceneCar *carC = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, -1.0) velocity:GLKVector3Make(1.0f, 0.0, 1.5f) color:GLKVector4Make(0.0, 0.0, 1.0, 1.0)];
    SceneCar *carD = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(-1.0, 0.0, -1.0) velocity:GLKVector3Make(-1.5f, 0.0, -1.2f) color:GLKVector4Make(1.0, 0.0, 1.0, 1.0)];
    [self.cars addObject:carA];
    [self.cars addObject:carB];
    [self.cars addObject:carC];
    [self.cars addObject:carD];
    
    self.eyePosition = GLKVector3Make(0.0, 5.0, 10.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
}

- (void)update
{
    if (self.switchMode.isOn) {
        // 第一人称视角
        SceneCar *car = [self.cars lastObject];
        GLKVector3 lookat = GLKVector3Add(car.position, car.velocity);
        self.eyePosition = GLKVector3Make(car.position.x, car.position.y + 0.5, car.position.z);
        self.lookAtPosition = GLKVector3Make(lookat.x, lookat.y + 0.2, lookat.z);
    }else{
        // 第三人称视角
        self.eyePosition = GLKVector3Make(0.0, 5.0, 10.0);
        self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
    }
    [self.cars makeObjectsPerformSelector:@selector(updateWithController:) withObject:self];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f), aspectRatio, 0.1f, 25.0f);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x,self.eyePosition.y,self.eyePosition.z,self.lookAtPosition.x,self.lookAtPosition.y,self.lookAtPosition.z,0, 1, 0);
    
    [self.baseEffect prepareToDraw];
    [self.rinkModel draw];
    [self.cars makeObjectsPerformSelector:@selector(drawWithBaseEffect:) withObject:self.baseEffect];
}

#pragma mark - protocol

- (SceneAxisAllignedBoundingBox)rinkBoundingBox
{
    return self.rinkModel.axisAlignedBoundingBox;
}

@end
