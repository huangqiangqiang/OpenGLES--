//
//  ViewController.m
//  OpenGLES-2-旋转
//
//  Created by 黄强强 on 17/3/20.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <GLKViewDelegate>
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint GPUProgram;
@end

@implementation ViewController

#define PI 3.1415926f

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
    
    [self initScene];
}

- (void)initScene
{
    /*
     纹理坐标系和iOS坐标细的顶点要对应，如：纹理坐标系的（0，0）点和ios的坐标系的（0，0）点要对应，纹理坐标系的（1，0）点和ios的坐标系的（1，0）点要对应...
     */
    float z = -1.0;
    float position[] = {
        0.5, -0.5, z,  1.0, 1.0,  // 右下
        0.5,  0.5, z,  1.0, 0.0,  // 右上
        -0.5, 0.5, z,  0.0, 0.0,  // 左上
        -0.5, 0.5, z,  0.0, 0.0,  // 左上
        -0.5,-0.5, z,  0.0, 1.0,  // 左下
         0.5,-0.5, z,  1.0, 1.0   // 右下
    };
    
    // 创建VBO
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(position), position, GL_STATIC_DRAW);
    
    // 设置顶点
    GLint positionLocation = glGetAttribLocation(self.GPUProgram, "position");
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, 0);
    glEnableVertexAttribArray(positionLocation);
    
    // 设置纹理坐标
    GLint textureLocation = glGetAttribLocation(self.GPUProgram, "textureCoordinate");
    glVertexAttribPointer(textureLocation, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textureLocation);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    /*
     当一个三角形的产生的片元（像素）少于绑定的纹理的纹素，或一个拥有大量纹素的纹理被映射到帧缓存内的一个只覆盖几个像素的三角形中。
     就需要使用glTexParameteri配置每个绑定的纹理。
     
     GL_LINEAR - GL_TEXTURE_MIN_FILTER:指定当多个纹素对应一个像素时，从多个匹配的纹素中取样颜色，然后通过线性插值法混合这些颜色。
     GL_NEAREST - GL_TEXTURE_MIN_FILTER:指定当多个纹素对应一个像素时，与片元U，V坐标最近的纹素被取样。
     
     GL_LINEAR - GL_TEXTURE_MAG_FILTER:这个参数用在没有足够的纹素来唯一的对应片元的情况下，混合附近纹素的颜色来计算片元的颜色。会有一个放大的效果，并会让它模糊的渲染到三角形上。
     GL_NEAREST - GL_TEXTURE_MAG_FILTER:这个参数用在没有足够的纹素来唯一的对应片元的情况下，只取U，V坐标最近的纹素颜色，并放大纹理，这会使他有点像素化地出现在渲染的三角形上。
     
     当U，V坐标值小于0或大于1时，程序要指定发生了什么，重复纹理或者去边缘
     GL_CLAMP_TO_EDGE - GL_TEXTURE_WRAP_S:S轴超出0-1的范围后，取边缘。
     GL_REPEAT - GL_TEXTURE_WRAP_S:S轴超出0-1的范围后，重复纹理。
     GL_CLAMP_TO_EDGE - GL_TEXTURE_WRAP_T:T轴超出0-1的范围后，取边缘。
     GL_REPEAT - GL_TEXTURE_WRAP_T:T轴超出0-1的范围后，重复纹理。
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    UIImage *image = [UIImage imageNamed:@"for_test.jpg"];
    GLuint width = (GLuint)CGImageGetWidth(image.CGImage);
    GLuint height = (GLuint)CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(context);
    free(imageData);
    
    // 设置z轴旋转矩阵 (角度转弧度 π/180×角度)
    GLint rotateMatrixLocation = glGetUniformLocation(self.GPUProgram, "rotateMatrix");
    GLint moveMatrixLocation = glGetUniformLocation(self.GPUProgram, "moveMatrix");
    float rotate = PI / 180 * 90;
    float s = sin(rotate);
    float c = cos(rotate);
    // OpenGLES是列主序矩阵，对于一个一维数组表示的二维矩阵，会先填满每一列
    GLfloat rotateZMatrix[] = {
        c,  -s, 0.0,0.0,
        s,  c,  0.0,0.0,
        0.0,0.0,1.0,0.0,
        0.0,0.0,0.0,1.0
    };
    GLfloat rotateXMatrix[] = {
        1.0,0.0,0.0,0.0,
        0.0,  c, -s,0.0,
        0.0,  s,  c,0.0,
        0.0,0.0,0.0,1.0
    };
    GLfloat rotateYMatrix[] = {
          c,0.0,  s,0.0,
        0.0,1.0,0.0,0.0,
         -s,0.0,  c,0.0,
        0.0,0.0,0.0,1.0
    };
    // 平移矩阵
    GLfloat moveXMatrix[] = {
        1.0,0.0,0.0,0.3,
        0.0,1.0,0.0,0.0,
        0.0,0.0,1.0,0.0,
        0.0,0.0,0.0,1.0
    };
    GLfloat moveYMatrix[] = {
        1.0,0.0,0.0,0.0,
        0.0,1.0,0.0,0.1,
        0.0,0.0,1.0,0.0,
        0.0,0.0,0.0,1.0
    };
    GLfloat moveZMatrix[] = {
        1.0,0.0,0.0,0.0,
        0.0,1.0,0.0,0.0,
        0.0,0.0,1.0,0.0,
        0.0,0.0,0.0,1.0
    };
    // 缩放矩阵
    GLfloat scaleMatrix[] = {
        0.2,0.0,0.0,0.0,
        0.0,0.2,0.0,0.0,
        0.0,0.0,0.2,0.0,
        0.0,0.0,0.0,1.0
    };
    
    // 设置矩阵
    glUniformMatrix4fv(rotateMatrixLocation, 1, GL_FALSE, rotateZMatrix);
    glUniformMatrix4fv(moveMatrixLocation, 1, GL_FALSE, moveXMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.2, 0.2, 0.6, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

#pragma mark - shader的编译和链接

- (void)createProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"vertexShader.vsh" ofType:nil];
    NSString *fragShaderPath = [[NSBundle mainBundle] pathForResource:@"fragShader.fsh" ofType:nil];
    
    NSString *vertexSource = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentSource = [NSString stringWithContentsOfFile:fragShaderPath encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *vCode = [vertexSource UTF8String];
    const GLchar *fCode = [fragmentSource UTF8String];
    
    GLuint vShader = [self compileShaderWithType:GL_VERTEX_SHADER source:vCode];
    GLuint fShader = [self compileShaderWithType:GL_FRAGMENT_SHADER source:fCode];
    
    self.GPUProgram = [self linkWithVS:vShader FS:fShader];
}

- (GLuint)compileShaderWithType:(GLenum)type source:(const char *)source
{
    GLuint shader;
    shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    GLint compileStatus = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        char info[1024] = {0};
        GLsizei len = 0;
        glGetShaderInfoLog(shader, 1024, &len, info);
        printf("%s\n",info);
    }
    return shader;
}

- (GLuint)linkWithVS:(GLuint)vs FS:(GLuint)fs
{
    GLuint GPUProgram = glCreateProgram();
    glAttachShader(GPUProgram, vs);
    glAttachShader(GPUProgram, fs);
    // 链接
    glLinkProgram(GPUProgram);
    
    GLint linkStatue = GL_FALSE;
    glGetProgramiv(GPUProgram, GL_LINK_STATUS, &linkStatue);
    if (linkStatue == GL_FALSE) {
        char info[1024] = {0};
        GLsizei len = 0;
        glGetProgramInfoLog(GPUProgram, 1024, &len, info);
        printf("%s\n",info);
        glDeleteProgram(GPUProgram);
    }
    else{
        glUseProgram(GPUProgram);
    }
    
    glDeleteShader(vs);
    glDeleteShader(fs);
    
    return GPUProgram;
}

@end
