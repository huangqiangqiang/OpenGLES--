//
//  AGLKPointParticleEffect.m
//  OpenGLES-15-粒子
//
//  Created by 黄强强 on 17/4/19.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "AGLKPointParticleEffect.h"
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct
{
    GLKVector3 emissionPosition;
    GLKVector3 emissionVelocity;
    GLKVector3 emissionForce;
    GLKVector2 size;
    GLKVector2 emissionTimeAndLife;
}
AGLKParticleAttributes;

enum
{
    AGLKMVPMatrix,
    AGLKSamplers2D,
    AGLKElapsedSeconds,
    AGLKGravity,
    AGLKNumUniforms
};

typedef enum {
    AGLKParticleEmissionPosition = 0,
    AGLKParticleEmissionVelocity,
    AGLKParticleEmissionForce,
    AGLKParticleSize,
    AGLKParticleEmissionTimeAndLife,
} AGLKParticleAttrib;

@interface AGLKPointParticleEffect()
{
    GLint uniforms[AGLKNumUniforms];
}
@property (nonatomic, assign) GLuint program;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *particleAttributeBuffer;
@property (nonatomic, strong) NSMutableData *particleAttributesData;
@property (nonatomic, strong) GLKEffectPropertyTransform *transform;
@property (nonatomic, strong) GLKEffectPropertyTexture *texture2d0, *texture2d1;
@property (nonatomic, assign) BOOL particleDataWasUpdated;
@end

@implementation AGLKPointParticleEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transform = [[GLKEffectPropertyTransform alloc] init];
        self.texture2d0 = [[GLKEffectPropertyTexture alloc] init];
        self.texture2d0.enabled = YES;
        self.texture2d0.name = 0;
        self.texture2d0.target = GLKTextureTarget2D;
        self.texture2d0.envMode = GLKTextureEnvModeReplace;
        self.particleAttributesData = [NSMutableData data];
        
        self.gravity = AGLKDefaultGravity;
        self.elapsedSeconds = 0.0f;
    }
    return self;
}

- (void)addParticleAtPosition:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity force:(GLKVector3)aForce size:(float)aSize lifeSpanSeconds:(NSTimeInterval)aSpan fadeDurationSeconds:(NSTimeInterval)aDuration
{
    AGLKParticleAttributes partical;
    partical.emissionPosition = aPosition;
    partical.emissionVelocity = aVelocity;
    partical.emissionForce = aForce;
    partical.size = GLKVector2Make(aSize, aDuration);
    partical.emissionTimeAndLife = GLKVector2Make(self.elapsedSeconds, self.elapsedSeconds + aSpan);
    
    [self.particleAttributesData appendBytes:&partical length:sizeof(partical)];
    self.particleDataWasUpdated = YES;
}

- (void)prepareToDraw
{
    if (self.program == 0) {
        [self loadShaders];
    }
    
    if (self.program != 0) {
        glUseProgram(self.program);
        
        if (self.particleDataWasUpdated) {
            if (self.particleAttributeBuffer == nil && self.particleAttributesData != nil) {
                self.particleAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(AGLKParticleAttributes) numberOfVertices:(GLsizei)[self.particleAttributesData length] / sizeof(AGLKParticleAttributes)  bytes:(void *)[self.particleAttributesData bytes]  usage:GL_DYNAMIC_DRAW];
            }
            else{
                [self.particleAttributeBuffer reinitWithAttribStride:sizeof(AGLKParticleAttributes) numberOfVertices:(GLsizei)[self.particleAttributesData length] / sizeof(AGLKParticleAttributes) bytes:(void *)[self.particleAttributesData bytes]];
            }
        }
        
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, self.transform.modelviewMatrix);
        glUniformMatrix4fv(uniforms[AGLKMVPMatrix], 1, GL_FALSE, mvpMatrix.m);
        
        glUniform3fv(uniforms[AGLKGravity], 1, self.gravity.v);
        glUniform1fv(uniforms[AGLKElapsedSeconds], 1, &_elapsedSeconds);
        
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionPosition numberOfCoordinates:3 attribOffset:offsetof(AGLKParticleAttributes, emissionPosition) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionVelocity numberOfCoordinates:3 attribOffset:offsetof(AGLKParticleAttributes, emissionVelocity) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionForce numberOfCoordinates:3 attribOffset:offsetof(AGLKParticleAttributes, emissionForce) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleSize numberOfCoordinates:2 attribOffset:offsetof(AGLKParticleAttributes, size) shouldEnable:YES];
        [self.particleAttributeBuffer prepareToDrawWithAttrib:AGLKParticleEmissionTimeAndLife numberOfCoordinates:2 attribOffset:offsetof(AGLKParticleAttributes, emissionTimeAndLife) shouldEnable:YES];
        
        glActiveTexture(GL_TEXTURE0);
        if (self.texture2d0.name != 0 && self.texture2d0.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
        }
        else{
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }
}

- (NSUInteger)numberOfParticals
{
    return [self.particleAttributesData length] / sizeof(AGLKParticleAttributes);
}

- (void)draw
{
    [self.particleAttributeBuffer drawArrayWithMode:GL_POINTS startVertexIndex:0 numberOfVertices:(GLsizei)[self numberOfParticals]];
}

#pragma mark -  OpenGL ES 2 shader compilation

/////////////////////////////////////////////////////////////////
//
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    self.program = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"vertexShader" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER
                        file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:
                          @"fragmentShader" ofType:@"glsl"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER
                        file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(self.program, vertShader);
    glAttachShader(self.program, fragShader);
    
    glBindAttribLocation(self.program, AGLKParticleEmissionPosition, "a_emissionPosition");
    glBindAttribLocation(self.program, AGLKParticleEmissionVelocity, "a_emissionVelocity");
    glBindAttribLocation(self.program, AGLKParticleEmissionForce, "a_emissionForce");
    glBindAttribLocation(self.program, AGLKParticleSize, "a_size");
    glBindAttribLocation(self.program, AGLKParticleEmissionTimeAndLife, "a_emissionAndDeathTimes");
    
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
    
    uniforms[AGLKMVPMatrix] = glGetUniformLocation(self.program ,"u_mvpMatrix");
    uniforms[AGLKSamplers2D] = glGetUniformLocation(self.program, "u_samplers2D");
    uniforms[AGLKGravity] = glGetUniformLocation(self.program, "u_gravity");
    uniforms[AGLKElapsedSeconds] = glGetUniformLocation(self.program, "u_elapsedSeconds");
    
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
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file
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

const GLKVector3 AGLKDefaultGravity = {0.0f, -9.8f, 0.0f};
