//
//  ViewController.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "UtilityCamera.h"
#import "UtilityTerrainEffect.h"
#import "TETerrain+viewAdditions.h"
#import "TETerrain+modelAdditions.h"
#import "UtilityPickTerrainEffect.h"

@interface ViewController () <UIGestureRecognizerDelegate, UtilityOpenGLCameraDelegate>
{
    // 眼睛的位置向量与Y轴的角度
    float angle;       // look direction angle about Y axis
    // 眼睛看向的位置向量与Y轴的角度
    float targetAngle; // Target look direction angle about Y axis
}
@property (weak, nonatomic) id <ViewControllerDataSource> dataSource;
@property (nonatomic, strong) UtilityCamera *camera;
@property (nonatomic, strong) UtilityTerrainEffect *terrainEffect;
@property (nonatomic, strong) UtilityPickTerrainEffect *pickTerrainEffect;
@property (nonatomic, assign) GLKVector3 referencePosition;
@property (nonatomic, assign) GLKVector3 targetPosition;
@property (nonatomic, assign) GLfloat pitchOffset;
@property (nonatomic, strong) NSArray *tiles;

@property (nonatomic, weak) IBOutlet UILabel *fpsField;
@property (nonatomic, assign) float filteredFPS;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *forwordBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = (id <ViewControllerDataSource>)[UIApplication sharedApplication].delegate;
    
    GLKView *glView = (GLKView *)self.view;
    glView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:glView.context];
    self.preferredFramesPerSecond = 60;
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    targetAngle = angle = 1.0f * M_PI / 4.0f; // Arbitrary angle
    self.referencePosition = GLKVector3Make(400.0f, 0.0f, 400.0f);
    self.targetPosition = self.referencePosition;
    
    self.camera = [[UtilityCamera alloc] init];
    self.camera.delegate = self;
    // 设置model view矩阵
    [self.camera setPosition:self.referencePosition lookAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)];
    
    TETerrain *terrain = [self.dataSource terrain];
    self.tiles = [terrain tiles];
    self.terrainEffect = [[UtilityTerrainEffect alloc] initWithTerrain:terrain];
    self.terrainEffect.globalAmbientLightColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    
    self.terrainEffect.lightAndWeightsTextureInfo = terrain.lightAndWeightsTextureInfo;
    self.terrainEffect.detailTextureInfo0 = terrain.detailTextureInfo0;
    self.terrainEffect.detailTextureInfo1 = terrain.detailTextureInfo1;
    self.terrainEffect.detailTextureInfo2 = terrain.detailTextureInfo2;
    self.terrainEffect.detailTextureInfo3 = terrain.detailTextureInfo3;
    
    self.pickTerrainEffect = [[UtilityPickTerrainEffect alloc] initWithTerrain:terrain];
    
    // 单击手势
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.delegate = self;
    // 拖拽手势
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [self.view addGestureRecognizer:self.panRecognizer];
    self.panRecognizer.delegate = self;
}


static const GLfloat TEHeadHeightMeters = (2.0f);


/**
 摄像机的视角和位置即将发生改变
 */
- (BOOL)camera:(UtilityCamera *)aCamera willChangeEyePosition:(GLKVector3 *)eyePositionPtr lookAtPosition:(GLKVector3 *)lookAtPositionPtr
{
    TETerrain *terrain = [self.dataSource terrain];
    // 单位
    const float metersPerUnit = terrain.metersPerUnit;
    
//    _referencePosition.x = MIN(MAX(2, self.referencePosition.x), terrain.widthMeters - 2);
//    _referencePosition.z = MIN(MAX(2, self.referencePosition.z), terrain.lengthMeters - 2);
    
    // 计算位与X和Z坐标的地形的高度
    float heightAtReferencePosition = [terrain calculatedHeightAtXPosMeters:self.referencePosition.x zPosMeters:self.referencePosition.z surfaceNormal:NULL];
    
    // 加上摄像机的高度
    _referencePosition.y = TEHeadHeightMeters + heightAtReferencePosition;
    
    // 根据 referencePosition 和 angle 算出 lookAtPosition
    GLKVector3 lookAtPosition = GLKVector3Make(self.referencePosition.x + cosf(angle) * metersPerUnit,
                                               self.referencePosition.y,
                                               self.referencePosition.z + sinf(angle) * metersPerUnit);
    // 加上Y轴的偏移量
    lookAtPosition.y += self.pitchOffset;
    
    *lookAtPositionPtr = lookAtPosition;
    *eyePositionPtr = self.referencePosition;
    
    return YES;
}

- (void)update
{
    // direction为0说明摄像头的位置有没有发生改变
    GLKVector3 direction = GLKVector3Subtract(self.targetPosition, self.referencePosition);
    direction.y = 0.0f;
//    NSLog(@"direction:%@",NSStringFromGLKVector3(direction));
    const float distance = GLKVector3Length(direction);

    if(angle != targetAngle || distance > 0.0f)
    {
        if (distance > 0.0f) {
            // 模拟低通滤波器
            direction.x /= distance;
            direction.z /= distance;
        }
        self.referencePosition = GLKVector3Add(self.referencePosition, direction);
        [self.camera moveBy:direction];
        self.referencePosition = [self.camera position];
        angle = targetAngle;
    }
    
    // 显示帧数
    NSTimeInterval elapsedTime = [self timeSinceLastUpdate];
    if (elapsedTime > 0.0f) {
        float unfilteredFPS = 1.0f / elapsedTime;
        self.filteredFPS += 0.2f * (unfilteredFPS - self.filteredFPS);
        self.fpsField.text = [NSString stringWithFormat:@"%03.1f FPS", self.filteredFPS];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 设置投影矩阵
    const GLfloat aspectRatio = view.drawableWidth * 1.0 / view.drawableHeight;
    [self.camera configurePerspectiveFieldOfViewRad:GLKMathDegreesToRadians(45.f) aspectRatio:aspectRatio near:0.5f far:5000.f];
    
    // 绘制
    TETerrain *terrain = [self.dataSource terrain];
    [terrain drawTerrainWithinTiles:self.tiles withCamera:self.camera terrainEffect:self.terrainEffect];
}

#pragma mark - Responding to gestures

/////////////////////////////////////////////////////////////////
//
- (TEPickTerrainInfo)pickTerrainAndModelsAtViewLocation:(CGPoint)aViewLocation
{
    GLKView *glView = (GLKView *)self.view;
    
    // Make the view's context current
    [EAGLContext setCurrentContext:glView.context];
    
    TETerrain *terrain = [[self dataSource] terrain];
    
    [terrain prepareToPickTerrain:self.tiles withCamera:self.camera pickEffect:self.pickTerrainEffect];
    
    const GLfloat width = [glView drawableWidth] / 2;
    const GLfloat height = [glView drawableHeight] / 2;
    
    // Get info for picked location
    const GLKVector2 scaledProjectionPosition = {
        aViewLocation.x / width,
        aViewLocation.y / height
    };
    
    const TEPickTerrainInfo pickInfo = [self.pickTerrainEffect terrainInfoForProjectionPosition:scaledProjectionPosition];
    
    // Restore OpenGL state that pickTerrainEffect changed
    glBindFramebuffer(GL_FRAMEBUFFER, 0); // default frame buffer
    glViewport(0, 0, width, height); // full area of glView
    
    return pickInfo;
}

/**
 移动摄像机的位置
 */
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    // CG坐标系和GL坐标系的Y轴是反的
    location.y = self.view.bounds.size.height - location.y;
    
    TEPickTerrainInfo pickInfo = [self pickTerrainAndModelsAtViewLocation:location];
    
    const float constMetersPerUnit = self.dataSource.terrain.metersPerUnit;
    
    if(0.0f < pickInfo.position.x && 0.0f < pickInfo.position.y)
    {
        self.targetPosition = GLKVector3Make(pickInfo.position.x * constMetersPerUnit,
                                             0.0f,
                                             pickInfo.position.y * constMetersPerUnit);
    }
}

// 转动视角
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateChanged) {
        // 获取手指在屏幕上拖动的速度,x轴和y轴方向的速度
        CGPoint velocity = [recognizer velocityInView:self.view];
        targetAngle -= (velocity.x / self.view.bounds.size.width) * 0.03f;
        // pitch是围绕X轴旋转，也叫做俯仰角，pitchOffset是Y轴的偏移量
        self.pitchOffset += (velocity.y / self.view.bounds.size.height) * 0.2f;
    }
}

@end
