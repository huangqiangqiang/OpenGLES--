//
//  ViewController.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModelManager.h"
#import "UtilityModel.h"
#import "SceneCar.h"

@interface ViewController ()
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) UtilityModelManager *modelManager;
@property (nonatomic, strong) NSMutableArray *cars;

@property (nonatomic, strong) UtilityModel *carModel;
@property (nonatomic, strong) UtilityModel *rinkModelFloor;
@property (nonatomic, strong) UtilityModel *rinkModelWalls;

@property (nonatomic, assign, readwrite) AGLKAxisAllignedBoundingBox rinkBoundingBox;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cars = [NSMutableArray array];
    
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:view.context];
    glEnable(GL_DEPTH_TEST);
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    // 灯光
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 1.0, 0.0);
    
    // 解析modelplist文件
    NSString *modelpath = [[NSBundle mainBundle] pathForResource:@"bumper.modelplist" ofType:nil];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:modelpath];
    
    // model赋值
    self.carModel = [self.modelManager modelNamed:@"bumperCar"];
    self.rinkModelFloor = [self.modelManager modelNamed:@"bumperRinkFloor"];
    self.rinkModelWalls = [self.modelManager modelNamed:@"bumperRinkWalls"];
    
    self.rinkBoundingBox = self.rinkModelFloor.axisAlignedBoundingBox;
    
    SceneCar *car1 = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, 1.0) velocity:GLKVector3Make(1.5, 0.0, 1.5) color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)];
    SceneCar *car2 = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(-1.0, 0.0, 1.0) velocity:GLKVector3Make(-1.5, 0.0, 1.5) color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)];
    SceneCar *car3 = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(1.0, 0.0, -1.0) velocity:GLKVector3Make(-1.5, 0.0, -1.5) color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)];
    SceneCar *car4 = [[SceneCar alloc] initWithModel:self.carModel position:GLKVector3Make(2.0, 0.0, -2.0) velocity:GLKVector3Make(-1.5, 0.0, -0.5) color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)];
    [self.cars addObject:car1];
    [self.cars addObject:car2];
    [self.cars addObject:car3];
    [self.cars addObject:car4];
    
    // model view matrix
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(10.5, 5.0, 0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0);
    
    self.baseEffect.texture2d0.name = self.modelManager.textureInfo.name;
    self.baseEffect.texture2d0.target = self.modelManager.textureInfo.target;
}

- (void)update
{
    [self.cars makeObjectsPerformSelector:@selector(updateWithController:) withObject:self];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_CULL_FACE);
    
    // projection matrix
    GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f),aspectRatio,4.0f,20.0f);
    
    [self.modelManager prepareToDraw];
    [self.baseEffect prepareToDraw];
    [self.rinkModelFloor draw];
    [self.rinkModelWalls draw];
    
    [self.cars makeObjectsPerformSelector:@selector(drawWithBaseEffect:) withObject:self.baseEffect];
}

- (void)dealloc
{
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    
    _baseEffect = nil;
    _cars = nil;
    _carModel = nil;
    _rinkModelFloor = nil;
    _rinkModelWalls = nil;
}

@end
