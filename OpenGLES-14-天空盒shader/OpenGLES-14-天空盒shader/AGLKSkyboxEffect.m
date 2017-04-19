//
//  AGLKSkyboxEffect.m
//  OpenGLES-14-天空盒shader
//
//  Created by 黄强强 on 17/4/18.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "AGLKSkyboxEffect.h"
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/ES3/gl.h>


const static int AGLKSkyboxNumVertexIndices = 36;
const static int AGLKSkyboxNumCoords = 24;

enum {
    AGLKMVPMatrix,
    AGLKSamplersCube,
    AGLKNumUniforms
};

@interface AGLKSkyboxEffect()
{
    GLint _uniforms[AGLKNumUniforms];
}
@property (nonatomic, strong) GLKEffectPropertyTexture *textureCubeMap;
@property (nonatomic, strong) GLKEffectPropertyTransform *transform;

@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint indicesBuffer;
@property (nonatomic, assign) GLuint vertexArrayID;
@property (nonatomic, assign) GLint vertex;
@property (nonatomic, assign) GLubyte indices;
@end

@implementation AGLKSkyboxEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textureCubeMap = [[GLKEffectPropertyTexture alloc] init];
        self.textureCubeMap.enabled = GL_TRUE;
        self.textureCubeMap.name = 0;
        self.textureCubeMap.target = GLKTextureTargetCubeMap;
        self.textureCubeMap.envMode = GLKTextureEnvModeReplace;
        self.transform = [[GLKEffectPropertyTransform alloc] init];
        self.center = GLKVector3Make(0, 0, 0);
        self.xSize = 1.0f;
        self.ySize = 1.0f;
        self.zSize = 1.0f;
        
        // 创建skybox顶点
        
        /*
                  +y
         -----------------
         |\6           7 \
         | \              \
         |  \              \
         |   \ -------------|
         |    | 2         3 |
         |    |             |
         | 4  |        5    |  +x
          \   |             |
           \  |             |
            \ |             |
             \| 0         1 |
              ---------------
         
         */
        float vertices[AGLKSkyboxNumCoords] = {
            -0.5, -0.5,  0.5, // 0
             0.5, -0.5,  0.5, // 1
            -0.5,  0.5,  0.5, // 2
             0.5,  0.5,  0.5, // 3
            -0.5, -0.5, -0.5, // 4
             0.5, -0.5, -0.5, // 5
            -0.5,  0.5, -0.5, // 6
             0.5,  0.5, -0.5  // 7
        };
        
        const GLubyte indices[AGLKSkyboxNumVertexIndices] = {
            1,2,3,
            0,2,1,
            4,6,0,
            6,2,0,
            6,3,2,
            6,7,3,
            3,7,5,
            1,3,5,
            0,1,5,
            4,0,5,
            6,4,5,
            7,6,5
        };
        
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_indicesBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indicesBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    }
    return self;
}

- (void)prepareToDraw
{
    if (self.program == 0) {
        [self loadShaders];
    }
    
    if (self.program != 0) {
        glUseProgram(self.program);
        
        // 设置shader
        GLKMatrix4 modelViewMatrix = self.transform.modelviewMatrix;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, self.center.x, self.center.y, self.center.z);
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, self.xSize, self.ySize, self.zSize);
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, modelViewMatrix);
        glUniformMatrix4fv(_uniforms[AGLKMVPMatrix], 1, GL_FALSE, mvpMatrix.m);
        
        glUniform1i(_uniforms[AGLKSamplersCube], 0);
        
        if (self.vertexArrayID == 0) {
            glGenVertexArrays(1, &_vertexArrayID);
            glBindVertexArray(self.vertexArrayID);
            glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
            
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, NULL);
        }
        else{
            glBindVertexArray(self.vertexArrayID);
        }
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indicesBuffer);
        
        if (self.textureCubeMap.enabled) {
            glBindTexture(GL_TEXTURE_CUBE_MAP, self.textureCubeMap.name);
        }else{
            glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
        }
    }
}

- (void)draw
{
    glDrawElements(GL_TRIANGLES, AGLKSkyboxNumVertexIndices, GL_UNSIGNED_BYTE, NULL);
}


- (void)dealloc
{
    if(0 != self.vertexArrayID)
    {
        glDeleteVertexArrays(1, &_vertexArrayID);
        self.vertexArrayID = 0;
    }
    if(0 != self.vertexBuffer)
    {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &_vertexBuffer);
    }
    if(0 != self.indicesBuffer)
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &_indicesBuffer);
    }
    if(0 != self.program)
    {
        glUseProgram(0);
        glDeleteProgram(self.program);
    }
}



#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
//
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    self.program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"vertexShader" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"fragmentShader" ofType:@"glsl"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(self.program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(self.program, GLKVertexAttribPosition,
                         "a_position");
    
    // Link program.
    if (![self linkProgram:self.program])
    {
        NSLog(@"Failed to link program: %d", self.program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.program)
        {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    _uniforms[AGLKMVPMatrix] = glGetUniformLocation(self.program, "u_mvpMatrix");
    _uniforms[AGLKSamplersCube] = glGetUniformLocation(self.program, "u_samplersCube");
    
    // Delete vertex and fragment shaders.
    if (vertShader)
    {
        glDetachShader(self.program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(self.program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) 
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) 
    {
        return NO;
    }
    
    return YES;
}

@end
