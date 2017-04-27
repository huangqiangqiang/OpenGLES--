//
//  ViewController.m
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/26.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "UtilityModelManager.h"
#import "UtilityBillboardManager.h"
#import "UtilityBillboardManager+viewAdditions.h"

@interface ViewController ()
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) UtilityModelManager *modelManager;
@property (nonatomic, strong) UtilityModel *parkModel;
@property (nonatomic, strong) UtilityModel *cylinderModel;
@property (nonatomic, strong) UtilityBillboardManager *billboardManager;

@property (assign, nonatomic) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
@property (assign, nonatomic) float angle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"park.modelplist" ofType:nil];
    self.modelManager = [[UtilityModelManager alloc] initWithModelPath:path];
    self.cylinderModel = [self.modelManager modelNamed:@"cylinder"];
    self.parkModel = [self.modelManager modelNamed:@"park"];
    
    // 灯光
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 1.0, 0.0);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    
    // 设置position
    self.eyePosition = GLKVector3Make(15, 8, 15);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
    self.angle = 0.0f;
    
    // 纹理
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = self.modelManager.textureInfo.name;
    self.baseEffect.texture2d0.target = self.modelManager.textureInfo.target;
    
    // 创建树
    [self addBillboardTrees];
}

- (void)addBillboardTrees
{
    if (self.billboardManager == nil) {
        self.billboardManager = [[UtilityBillboardManager alloc] init];
    }
    
    for (int j = -4; j < 4; j++) {
        for (int i = -4; i < 4; i++) {
            const NSInteger treeIndex = 1;
            const GLfloat minTextureT = treeIndex * 0.25f;
            
            [self.billboardManager addBillboardAtPosition:GLKVector3Make(i * -10.0f - 5.0f, 0.0, j * -10.0f - 5.0f) size:GLKVector2Make(8.0f, 8.0f) minTextureCoords:GLKVector2Make(3.0f/8.0f, 1.0f - minTextureT) maxTextureCoords:GLKVector2Make(7.0f/8.0f, 1.0f - (minTextureT + 0.25f))];
        }
    }
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    const GLfloat  aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f), aspectRatio, 0.5f, 200.0f);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(
                         self.eyePosition.x,      // Eye position
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,   // Look-at position
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         self.upVector.x,         // Up direction
                         self.upVector.y,
                         self.upVector.z);
    
    self.angle += 0.01;
    self.eyePosition = GLKVector3Make(15.0f * sinf(self.angle), 18.0f + 5.0f * sinf(0.3f * self.angle), 15.0f * cosf(self.angle));
    
    // park
    [self.baseEffect prepareToDraw];
    [self.modelManager prepareToDraw];
    [self.parkModel draw];
    
    // 圆筒
    const GLKMatrix4 savedModelview = self.baseEffect.transform.modelviewMatrix;
    const GLKMatrix4 translationModelview = GLKMatrix4Translate(savedModelview, -5.0f, 0.0f, -5.0f);
    self.baseEffect.transform.modelviewMatrix = translationModelview;
    [self.baseEffect prepareToDraw];
    [self.cylinderModel draw];
    
    // 树
    self.baseEffect.transform.modelviewMatrix = savedModelview;
    [self.baseEffect prepareToDraw];
    
    const GLKVector3 lookDirection = GLKVector3Subtract(self.lookAtPosition, self.eyePosition);
    [self.billboardManager updateWithEyePosition:self.eyePosition lookDirection:lookDirection];
    [self.billboardManager drawWithEyePosition:self.eyePosition lookDirection:lookDirection upVector:self.upVector];
}


@end
