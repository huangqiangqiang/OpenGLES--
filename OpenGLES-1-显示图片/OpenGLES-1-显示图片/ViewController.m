//
//  ViewController.m
//  OpenGLES-1-显示图片
//
//  Created by 黄强强 on 17/3/20.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/glext.h>

@interface ViewController ()
/**
 <#Annotations#>
 */
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic , strong) GLKBaseEffect* mEffect;

@property (nonatomic, assign) GLuint buffer;

@property (nonatomic, strong) GLKTextureInfo *t1;
@property (nonatomic, strong) GLKTextureInfo *t2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     EAGLContext（Embedded Apple GL）封装了一个特定于iOS平台的上下文。
     一个应用可以使用多个上下文context， context会保存OpenGLES的状态，还会控制GPU区执行渲染运算。
     
     */
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (!self.context) {
        NSLog(@"不支持OpenGLES!");
        return;
    }
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    [EAGLContext setCurrentContext:self.context];
    
    /*
     GLKBaseEffect类提供了不依赖于OpenGLES版本渲染的方法。
     GLKBaseEffect还会在需要的时候自动创建GPU程序（shader）。
     */
    self.mEffect = [[GLKBaseEffect alloc] init];
    
    [self initScene];
}

- (void)initScene
{
    float postion[] = {
         0.5, -0.5, 0.0f,       1.0,0.0f, // 右下
         0.5,  0.5, 0.0f,       1.0, 1.0, // 右上
        -0.5,  0.5, 0.0f,      0.0f, 1.0, // 左上
        
         0.5, -0.5, 0.0f,       1.0,0.0f, // 右下
        -0.5, -0.5, 0.0f,      0.0f,0.0f, // 左下
        -0.5,  0.5, 0.0f,      0.0f, 1.0  // 左上
    };
    
    GLuint buffer;
    // 生成一个缓存标识符,0值表示没有缓存
    glGenBuffers(1, &buffer);
    // glBindBuffer第一个参数说明绑定哪一种类型的缓存。GLES2.0版本只支持两种类型 GL_ARRAY_BUFFER\GL_ELEMENT_ARRAY_BUFFER。
    // GL_ARRAY_BUFFER类型用于指定一个顶点属性数组。
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(postion), postion, GL_STATIC_DRAW);
    _buffer = buffer;
    
    /*
     GLuint indx,            点的类型（纹理还是顶点）
     GLint size,             一个点有多少个分量
     GLenum type,            每个分量的类型
     GLboolean normalized,   是否归一化
     GLsizei stride,         每个点的偏移量（间隔多少）
     const GLvoid* ptr       从多少开始
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (GLfloat *)NULL + 3);
    
    [self createTexture];
}

- (void)createTexture
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"for_test.jpg" ofType:nil];
    NSDictionary *dict = @{GLKTextureLoaderOriginBottomLeft:@(1)};
    self.t1 = [GLKTextureLoader textureWithContentsOfFile:path options:dict error:nil];
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"beetle.png" ofType:nil];
    self.t2 = [GLKTextureLoader textureWithContentsOfFile:path2 options:dict error:nil];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


/**
 GLKView需要重绘时调用

 @param view <#view description#>
 @param rect <#rect description#>
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    /*
     glClearColor用来设置当前上下文的清除颜色。用于上下文的帧缓存被清除时初始化每个像素点的颜色。
     */
    glClearColor(0.2, 0.2, 0.5, 1.0);
    
    /*
     glClear指定帧缓存中的“像素颜色渲染缓存”中的每一个像素的颜色为前面设置的glClearColor颜色。
     
     帧缓存与某个Core Animation层连接的
     CoreAnimation合成器生成最后的后帧缓存时会连接所有的CoreAnimation层
     每个帧缓存中都有一个像素颜色渲染缓存，用来与CoreAnimation层分享数据
     
     如果其他的缓存被使用了，则在参数中指定
     */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = self.t1.name;
    /*
     准备好当前的context，生成GPU程序
     */
    [self.mEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    self.mEffect.texture2d0.name = self.t2.name;
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
}

/**
 释放内存
 */
- (void)dealloc
{
    glDeleteBuffers(1, &_buffer);
    GLKView *view = (GLKView *)self.view;
    view.context = nil;
    [EAGLContext setCurrentContext:nil];
}


@end
