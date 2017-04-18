//
//  ViewController.m
//  OpenGLES-4-GLKit实现三维变换
//
//  Created by 黄强强 on 17/3/22.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *context;
// 相当于shader
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (nonatomic, assign) BOOL bx;
@property (nonatomic, assign) BOOL by;
@property (nonatomic, assign) BOOL bz;
@property (nonatomic, assign) float degreeX;
@property (nonatomic, assign) float degreeY;
@property (nonatomic, assign) float degreeZ;

@property (nonatomic, assign) BOOL bmx;
@property (nonatomic, assign) BOOL bmy;
@property (nonatomic, assign) BOOL bmz;
@property (nonatomic, assign) float mX;
@property (nonatomic, assign) float mY;
@property (nonatomic, assign) float mZ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (!self.context) {
        return;
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    [self initScene];
}

- (void)initScene
{
    self.effect = [[GLKBaseEffect alloc] init];
    
    // 顶点
    /*
     |-0---1---
     | |\ /|
     | | 4 |
     | |/ \|
     |-3---2--
     */
    // 顶点索引
    GLuint indices[] = {
        0,2,3,
        0,1,2,
        0,3,4,
        0,4,1,
        1,4,2,
        4,3,2
    };
    
    
    GLfloat position[] = {
        -0.5, 0.5,0.0,   0.0,0.0,1.0,   0.0,1.0,
         0.5, 0.5,0.0,   1.0,0.0,1.0,   1.0,1.0,
         0.5,-0.5,0.0,   1.0,0.0,1.0,   1.0,0.0,
        -0.5,-0.5,0.0,   0.0,0.0,1.0,   0.0,0.0,
         0.0, 0.0,0.5,   1.0,1.0,0.0,   0.5,0.5
    };
    
    glEnable(GL_CULL_FACE);
    
    // 绑定VBO
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(position), position, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 设置顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (GLfloat *)NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, (GLfloat *)NULL + 3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float)*8, (GLfloat *)NULL + 6);
    
    // 纹理
    NSString *texturePath = [[NSBundle mainBundle] pathForResource:@"for_test.png" ofType:nil];
    NSDictionary *dict = @{GLKTextureLoaderOriginBottomLeft:@(1)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:dict error:nil];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Identity;
    self.effect.transform.projectionMatrix = GLKMatrix4Identity;
    
}
- (IBAction)clickX:(id)sender {
    _bx = !_bx;
}
- (IBAction)clickY:(id)sender {
    _by = !_by;
}
- (IBAction)clickZ:(id)sender {
    _bz = !_bz;
}
- (IBAction)clickmx:(id)sender {
    _bmx = !_bmx;
}
- (IBAction)clickmy:(id)sender {
    _bmy = !_bmy;
}
- (IBAction)clickmz:(id)sender {
    _bmz = !_bmz;
}

/**
 侧重数据变化
 */
- (void)update
{
    if (_bx) {
        _degreeX += 0.1;
    }
    if (_by) {
        _degreeY += 0.1;
    }
    if (_bz) {
        _degreeZ += 0.1;
    }
    if (_bmx) {
        _mX += 0.02;
    }
    if (_bmy) {
        _mY += 0.02;
    }
    if (_bmz) {
        _mZ += 0.02;
    }
    GLKMatrix4 modelViewMatrix;
    modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, -10.0);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, _mX, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, _mY, 0.0);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, _mZ);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _degreeX, 1.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _degreeY, 0.0, 1.0, 0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _degreeZ, 0.0, 0.0, 1.0);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // 投影矩阵
    GLKMatrix4 projectionMatrix;
    projectionMatrix = GLKMatrix4Identity;
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    projectionMatrix = GLKMatrix4MakePerspective(30, aspect, 5, 20);
    self.effect.transform.projectionMatrix = projectionMatrix;
}

/**
 侧重渲染场景
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.2, 0.3, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
}

@end
