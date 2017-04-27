//
//  ViewController.m
//  OpenGLES-17-渲染优化
//
//  Created by 黄强强 on 17/4/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModelManager.h"
#import "AGLKFrustum.h"

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) UtilityModelManager *modelManager;
@property (nonatomic, strong) UtilityModel *starship;
@property (assign, nonatomic) AGLKFrustum frustum;

@property (assign, nonatomic) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
@property (assign, nonatomic) float angle;

@property (weak, nonatomic) IBOutlet UILabel *ftpLabel;
@property (assign, nonatomic) BOOL shouldCull;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (assign, nonatomic) float filteredFPS;
@end

@implementation ViewController


/**
 基于视平截体的剔除
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    self.preferredFramesPerSecond = 60.0f;
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"starships.modelplist" ofType:nil];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:path];
    self.starship = [self.modelManager modelNamed:@"starship2"];
    
    // 灯光
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 1.0, 0.0);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    
    // 设置position
    self.eyePosition = GLKVector3Make(15, 5, 15);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
    self.angle = 0.0f;
    
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = self.modelManager.textureInfo.name;
    self.baseEffect.texture2d0.target = self.modelManager.textureInfo.target;
    
    self.shouldCull = YES;
    
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 50.0f;
}

- (void)update
{
    NSTimeInterval time = self.timeSinceLastUpdate;
    float unfilteredFPS = 0.0f;
    if (0.0 < time) {
        unfilteredFPS = 1.0 / time;
        self.filteredFPS += 0.2f * (unfilteredFPS - self.filteredFPS);
        self.ftpLabel.text = [NSString stringWithFormat:@"帧数:%.1f",self.filteredFPS];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.frustum = AGLKFrustumMakeFrustumWithParameters(GLKMathDegreesToRadians(60.0f),aspectRatio, 0.5f, 200.0f);
    self.baseEffect.transform.projectionMatrix = AGLKFrustumMakePerspective(&_frustum);
    
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(15.0f * sinf(self.angle), self.eyePosition.y, 15.0f * cosf(self.angle));
    NSLog(@"eyePosition:%@",NSStringFromGLKVector3(self.eyePosition));
    AGLKFrustumSetPositionAndDirection(&_frustum, self.eyePosition, self.lookAtPosition, self.upVector);
    self.baseEffect.transform.modelviewMatrix = AGLKFrustumMakeModelview(&_frustum);
    
    [self.modelManager prepareToDraw];
    [self drawModels];
}

- (void)drawModels
{
    for (int i = -8; i < 8; i++) {
        for (int j = -8; j < 8; j++) {
            
            GLKVector3 transformPosition = GLKVector3Make(i * 30.0, 0.0, j * 30.0);
            if (!self.shouldCull || AGLKFrustumOut != AGLKFrustumCompareSphere(&_frustum, transformPosition, 7.33f)) {
                
                GLKMatrix4 saveModelViewMatrix = self.baseEffect.transform.modelviewMatrix;
                self.baseEffect.transform.modelviewMatrix = GLKMatrix4Translate(saveModelViewMatrix, transformPosition.x, transformPosition.y, transformPosition.z);
                [self.baseEffect prepareToDraw];
                [self.starship draw];
                
                self.baseEffect.transform.modelviewMatrix = saveModelViewMatrix;
            }
        }
    }
}

- (IBAction)takeShouldCullFrom:(UISwitch *)sender {
    self.shouldCull = sender.isOn;
}

- (IBAction)changeEyePosition:(UISlider *)sender {
    self.eyePosition = GLKVector3Make(self.eyePosition.x, 5.0f + sender.value, self.eyePosition.z);
}

@end
