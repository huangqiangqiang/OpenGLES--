//
//  ViewController.m
//  OpenGLES-3-三维图像变换
//
//  Created by 黄强强 on 17/3/21.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import "GLESMath.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLint program;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) float degreeX;
@property (nonatomic, assign) float degreeY;
@property (nonatomic, assign) float degreeZ;
@property (nonatomic, assign) GLuint myVertices;

@property (nonatomic, assign) BOOL bx;
@property (nonatomic, assign) BOOL by;
@property (nonatomic, assign) BOOL bz;
@end

@implementation ViewController

- (IBAction)clickX:(id)sender {
    _bx = !_bx;
}
- (IBAction)clickY:(id)sender {
    _by = !_by;
}
- (IBAction)clickZ:(id)sender {
    _bz = !_bz;
}

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
    
    [self createProgram];
    
    [self render];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)render
{
    glClearColor(0.2, 0.3, 0.6, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    GLuint indices[] = {
        0,2,3,
        0,1,2,
        0,3,4,
        0,4,1,
        1,4,2,
        3,2,4
    };
    /*
     *
     *  0-------1
     *  | \   / |
     *  |   4   |
     *  | /   \ |
     *  3-------2
     */
    if (self.myVertices == 0) {
        glGenBuffers(1, &_myVertices);
    }
    
    // 可能是坐标轴不一样
    GLfloat attrArr[] = {
        -0.5, 0.5, 0.0,     1.0,0.0,1.0,
        0.5, 0.5, 0.0,      1.0,0.0,1.0,
        0.5, -0.5, 0.0,     1.0,0.0,0.0,
        -0.5, -0.5, 0.0,    1.0,0.0,0.0,
        0.0, 0.0, 0.5,      1.0,1.0,0.0
    };
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint positionColor = glGetAttribLocation(self.program, "positionColor");
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
    glEnableVertexAttribArray(positionColor);
    
    glEnable(GL_CULL_FACE);
    
    // modelView矩阵
    KSMatrix4 modelViewMatrix;
    KSMatrix4 rotateMatrix;
    ksMatrixLoadIdentity(&modelViewMatrix);
    ksMatrixLoadIdentity(&rotateMatrix);
    
    ksTranslate(&modelViewMatrix, 0.0, 0.0, -10.0);
    ksRotate(&rotateMatrix, _degreeX, 1.0, 0.0, 0.0);
    ksRotate(&rotateMatrix, _degreeY, 0.0, 1.0, 0.0);
    ksRotate(&rotateMatrix, _degreeZ, 0.0, 0.0, 1.0);
    ksMatrixMultiply(&modelViewMatrix, &rotateMatrix, &modelViewMatrix);
    GLint modelViewMatrixLocation = glGetUniformLocation(self.program, "modelViewMatrix");
    glUniformMatrix4fv(modelViewMatrixLocation, 1, GL_FALSE, (GLfloat *)&modelViewMatrix.m[0][0]);
    
    // 投影矩阵
    GLuint projectionMatrixLocation = glGetUniformLocation(self.program, "projectionMatrix");
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    KSMatrix4 projectionMatrix;
    ksMatrixLoadIdentity(&projectionMatrix);
    float aspect = width / height; //长宽比
    ksPerspective(&projectionMatrix, 30.0, aspect, 5.0f, 20.0f); //透视变换，视角30°
    // 设置glsl里面的投影矩阵
    glUniformMatrix4fv(projectionMatrixLocation, 1, GL_FALSE, (GLfloat*)&projectionMatrix.m[0][0]);
    
    /*
     glDrawElements:第一个参数是点的类型，第二个参数是点的个数，第三个是第四个参数的类型，第四个参数是点的存储绘制顺序。
     */
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, indices);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];

}

- (void)onTimer
{
    if (_bx) {
        _degreeX += 1;
    }
    if (_by) {
        _degreeY += 1;
    }
    if (_bz) {
        _degreeZ += 1;
    }
    [self render];
}

#pragma mark -

- (void)createProgram
{
    NSString *vShaderPath = [[NSBundle mainBundle] pathForResource:@"vertexShader.glsl" ofType:nil];
    NSString *fShaderPath = [[NSBundle mainBundle] pathForResource:@"fragmentShader.glsl" ofType:nil];
    GLuint vshader = [self compileShader:vShaderPath type:GL_VERTEX_SHADER];
    GLuint fshader = [self compileShader:fShaderPath type:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    glLinkProgram(program);
    GLint status = GL_FALSE;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        char info[1024] = {0};
        GLsizei len = 0;
        glGetProgramInfoLog(program, 1024, &len, info);
        printf("%s\n",info);
        glDeleteProgram(program);
    }
    else{
        glUseProgram(program);
        self.program = program;
    }
    glDeleteShader(vshader);
    glDeleteShader(fshader);
}

- (GLuint)compileShader:(NSString *)shaderPath type:(GLenum)type
{
    NSString *shaderStr = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:nil];
    const char *source = [shaderStr UTF8String];
    GLuint shader;
    shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    GLint status = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        char info[1024] = {0};
        GLsizei len = 0;
        glGetShaderInfoLog(shader, 1024, &len, info);
        printf("%s\n",info);
    }
    return shader;
}


@end
