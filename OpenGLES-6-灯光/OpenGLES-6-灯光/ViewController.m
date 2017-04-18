//
//  ViewController.m
//  OpenGLES-6-灯光
//
//  Created by 黄强强 on 17/3/26.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "ViewController.h"


/**
 一个顶点
 包括顶点位置和法线
 */
typedef struct{
    GLKVector3 position;
    GLKVector3 normal;
}SceneVertex;

/**
 一个三角形
 包含三个顶点
 */
typedef struct {
    SceneVertex vertices[3];
}SceneTriangle;

SceneTriangle SceneTriangleMake(SceneVertex vertex1, SceneVertex vertex2, SceneVertex vertex3);

SceneTriangle SceneTriangleMake(SceneVertex vertex1, SceneVertex vertex2, SceneVertex vertex3)
{
    SceneTriangle triangle;
    triangle.vertices[0] = vertex1;
    triangle.vertices[1] = vertex2;
    triangle.vertices[2] = vertex3;
    return triangle;
};

SceneVertex vertexA = {
    {-0.5,0.5,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexB = {
    {-0.5,0.0,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexC = {
    {-0.5,-0.5,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexD = {
    {0.0,0.5,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexE = {
    {0.0,0.0,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexF = {
    {0.0,-0.5,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexG = {
    {0.5,0.5,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexH = {
    {0.5,0.0,-0.5},
    {0.0,0.0,1.0}
};
SceneVertex vertexI = {
    {0.5,-0.5,-0.5},
    {0.0,0.0,1.0}
};

@interface ViewController ()
{
    SceneTriangle triangles[8];
}
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint normalBuffer;
@property (nonatomic, assign) float vertexE_height;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);
    
    {
        self.slider.minimumValue = -1.0;
        self.slider.maximumValue = 0.0;
    }
    
    {
        // 灯光
        self.baseEffect = [[GLKBaseEffect alloc] init];
        self.baseEffect.light0.enabled = GL_TRUE;
        // 灯光位置
        self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0.0);
        // 漫反射
        self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);
    }
    
    {
        // 三角形
        triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
        triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
        triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
        triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
        triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
        triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
        triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
        triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    }
    
    {
        // 准备数据
        GLuint vertexBuffer;
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(triangles), triangles, GL_DYNAMIC_DRAW);
        self.vertexBuffer = vertexBuffer;
    }
    
    {
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-60), 1.0, 0.0, 0.0);
//        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(30), 0.0, 0.0, 1.0);
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    
    glClearColor(0.1, 0.1, 0.2, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    {
        // 设置顶点
        glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), (GLvoid *)NULL + offsetof(SceneVertex, position));
    }
    
    {
        // 法线
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, normal));
    }
    
    // 要画24个点成为8个三角形
    glDrawArrays(GL_TRIANGLES, 0, sizeof(triangles) / sizeof(SceneVertex));
}

- (IBAction)dragSlider:(id)sender {
    self.vertexE_height = self.slider.value;
}

- (void)setVertexE_height:(float)vertexE_height
{
    _vertexE_height = vertexE_height;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = self.vertexE_height;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    // 更新法向量
    SceneTrianglesUpdateFaceNormals(triangles);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangles), triangles, GL_DYNAMIC_DRAW);
}

GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA,const GLKVector3 vectorB)
{
    // 算两个向量的叉积，再单位化
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}

static GLKVector3 SceneTriangleFaceNormal(const SceneTriangle triangle)
{
    // 一个三角形的两个向量
    GLKVector3 vectorA = GLKVector3Subtract(triangle.vertices[1].position, triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(triangle.vertices[2].position, triangle.vertices[0].position);
    return SceneVector3UnitNormal(vectorA, vectorB);
}

static void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[8])
{
    for (int i = 0; i < 8; i++) {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

@end
