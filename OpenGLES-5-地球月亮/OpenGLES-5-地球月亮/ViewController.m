//
//  ViewController.m
//  OpenGLES-5-地球月亮
//
//  Created by 黄强强 on 17/3/22.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "sphere.h"
#import "Qua.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, assign) float aspect;
@property (nonatomic, assign) float degreeEarthX;
@property (nonatomic, assign) float degreeEarthY;
@property (nonatomic, assign) float degreeMoon;

@property (nonatomic, assign) GLKMatrixStackRef stackMatrixRef;

@property (nonatomic, strong) GLKTextureInfo *earthTextureInfo;
@property (nonatomic, strong) GLKTextureInfo *moonTextureInfo;

@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint normalBuffer;
@property (nonatomic, assign) GLuint textureBuffer;

@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UISwitch *switchSence;
@property (weak, nonatomic) IBOutlet UISwitch *switchShowMoon;
// 手势
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) CGPoint prevPoint;

@property (nonatomic, strong) Qua *qua;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.qua = [[Qua alloc] init];
    [self.qua on];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (!self.context) {
        return;
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    self.aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    // 深度缓冲区
    glEnable(GL_DEPTH_TEST);
    
    [self initLight];
    
    [self initData];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.view addGestureRecognizer:self.pan];
//    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
//    self.tap.numberOfTapsRequired = 2;
//    [self.view addGestureRecognizer:self.tap];
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    if (!self.switchButton.isOn) {
        return;
    }
    CGPoint point = [pan locationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.prevPoint = point;
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        float offsetX = point.x - self.prevPoint.x;
        float offsetY = point.y - self.prevPoint.y;
        _degreeEarthX += offsetX / 100;
        _degreeEarthY += offsetY / 100;
        
        self.prevPoint = point;
    }
}

- (void)onTap:(UITapGestureRecognizer *)tap
{
    
}

- (void)initLight
{
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(1.0, 0.0, 0.8, 0.0);
    self.effect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.effect.light0.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
}

- (void)initData
{
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVerts), sphereVerts, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_normalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.normalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereNormals), sphereNormals, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_textureBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereTexCoords), sphereTexCoords, GL_STATIC_DRAW);
    
    NSString *earthPath = [[NSBundle mainBundle] pathForResource:@"14749427013_8ee23ca364_h.jpg" ofType:nil];
//    NSString *earthPath = [[NSBundle mainBundle] pathForResource:@"equirectangularoblique.png" ofType:nil];
    self.earthTextureInfo = [GLKTextureLoader textureWithContentsOfFile:earthPath options:@{GLKTextureLoaderOriginBottomLeft:@(1)} error:nil];
    
    NSString *moonPath = [[NSBundle mainBundle] pathForResource:@"Moon256x128.png" ofType:nil];
    self.moonTextureInfo = [GLKTextureLoader textureWithContentsOfFile:moonPath options:@{GLKTextureLoaderOriginBottomLeft:@(1)} error:nil];
    
    GLKMatrix4 modelViewMatrix;
    modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, -5.0);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    GLKMatrix4 projectionMatrix;
    projectionMatrix = GLKMatrix4Identity;
    projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * self.aspect, 1.0 * self.aspect, -1.0, 1.0, 1.0, 120.0);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    self.stackMatrixRef = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(self.stackMatrixRef, self.effect.transform.modelviewMatrix);
}

- (GLuint)loadVertexBuffer:(float *)vertex attrib:(GLKVertexAttrib)type
{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);
    return buffer;
}

- (void)drawEarth
{
    self.effect.texture2d0.name = self.earthTextureInfo.name;
    self.effect.texture2d0.target = self.earthTextureInfo.target;
    
    // 压栈
    GLKMatrixStackPush(self.stackMatrixRef);
    if (self.switchSence.isOn) {
        GLKMatrixStackMultiplyMatrix4(self.stackMatrixRef, self.qua.sensor);
//        GLKMatrixStackScale(self.stackMatrixRef, 1.5, 1.5, 1.5);
    }else{
        GLKMatrixStackRotate(self.stackMatrixRef, _degreeEarthX, 0.0, 1.0, 0.0);
        GLKMatrixStackRotate(self.stackMatrixRef, _degreeEarthY, 1.0, 0.0, 0.0);
//        GLKMatrixStackScale(self.stackMatrixRef, 1.5, 1.5, 1.5);
    }
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.stackMatrixRef);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    // 出栈
    GLKMatrixStackPop(self.stackMatrixRef);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.stackMatrixRef);
}

- (void)drawMoon
{
    self.effect.texture2d0.name = self.moonTextureInfo.name;
    
    // 压栈
    GLKMatrixStackPush(self.stackMatrixRef);
    GLKMatrixStackRotate(self.stackMatrixRef, GLKMathDegreesToRadians(_degreeMoon), 0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(self.stackMatrixRef, 0.0, 0.0, 1.0);
    GLKMatrixStackScale(self.stackMatrixRef, 0.25, 0.25, 0.25);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.stackMatrixRef);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    // 出栈
    GLKMatrixStackPop(self.stackMatrixRef);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.stackMatrixRef);
}

- (void)update
{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (!self.switchButton.isOn) {
        _degreeEarthX -= 0.05;
    }
    _degreeMoon -= 1;
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.normalBuffer);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.textureBuffer);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);
    
    [self drawEarth];
    if (self.switchShowMoon.isOn) {
        [self drawMoon];
    }
}


@end
