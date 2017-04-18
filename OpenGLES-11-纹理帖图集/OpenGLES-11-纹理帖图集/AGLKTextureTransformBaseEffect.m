//
//  AGLKTextureTransformBaseEffect.m
//  OpenGLES-9-灯光旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "AGLKTextureTransformBaseEffect.h"


enum {
    AGLKModelviewMatrix,
    AGLKMVPMatrix,
    AGLKNormalMatrix,
    AGLKTex0Matrix,
    AGLKTex1Matrix,
    AGLKSamplers,
    AGLKTex0Enabled,
    AGLKTex1Enabled,
    
    AGLKGlobalAmbient,
    
    AGLKLight0Pos,
    AGLKLight0Direction,
    AGLKLight0Diffuse,
    AGLKLight0Cutoff,
    AGLKLight0Exponent,
    
    AGLKLight1Pos,
    AGLKLight1Direction,
    AGLKLight1Diffuse,
    AGLKLight1Cutoff,
    AGLKLight1Exponent,
    
    AGLKLight2Pos,
    AGLKLight2Diffuse,
    
    AGLKNumUniforms
};

@interface AGLKTextureTransformBaseEffect()
{
    GLuint _uniforms[AGLKNumUniforms];
}
@property (nonatomic, assign) GLuint program;

@property (nonatomic, assign) GLKVector3 light0EyePosition;
@property (nonatomic, assign) GLKVector3 light0EyeDirection;
@property (nonatomic, assign) GLKVector3 light1EyePosition;
@property (nonatomic, assign) GLKVector3 light1EyeDirection;
@property (nonatomic, assign) GLKVector3 light2EyePosition;
@end

@implementation AGLKTextureTransformBaseEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textureMatrix2d0 = GLKMatrix4Identity;
        self.textureMatrix2d1 = GLKMatrix4Identity;
        self.material.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        self.lightModelAmbientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        self.texture2d0.enabled = GL_FALSE;
        self.texture2d1.enabled = GL_FALSE;
        self.light0.enabled = GL_FALSE;
        self.light1.enabled = GL_FALSE;
        self.light2.enabled = GL_FALSE;
    }
    return self;
}

- (void)prepareToDrawMultitextures
{
    if (self.program == 0) {
        [self loadShaders];
    }
    
    if (self.program != 0) {
        
        glUseProgram(self.program);
        
        GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, self.transform.modelviewMatrix);
        // 设置shader中的值
        glUniformMatrix4fv(_uniforms[AGLKModelviewMatrix], 1, GL_FALSE, self.transform.modelviewMatrix.m);
        glUniformMatrix4fv(_uniforms[AGLKMVPMatrix], 1, GL_FALSE, MVPMatrix.m);
        glUniformMatrix3fv(_uniforms[AGLKNormalMatrix], 1, GL_FALSE, self.transform.normalMatrix.m);
        glUniformMatrix4fv(_uniforms[AGLKTex0Matrix], 1, GL_FALSE, self.textureMatrix2d0.m);
        glUniformMatrix4fv(_uniforms[AGLKTex1Matrix], 1, GL_FALSE, self.textureMatrix2d1.m);
        
        // 设置纹理采样器（就是获取纹理图片的起始指针）
        const GLint samplerIDs[2] = {0,1};
        glUniform1iv(_uniforms[AGLKSamplers], 2, samplerIDs);
        
        // 计算全局的环境色，应该综合各个灯光的颜色
        GLKVector4 globalAmbient = GLKVector4Multiply(self.lightModelAmbientColor, self.material.ambientColor);
        
        if (self.light0.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light0.ambientColor, self.material.ambientColor));
        }
        if (self.light1.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light1.ambientColor, self.material.ambientColor));
        }
        if (self.light2.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light2.ambientColor, self.material.ambientColor));
        }
        
        glUniform4fv(_uniforms[AGLKGlobalAmbient], 1, globalAmbient.v);
        
        // 纹理
        glUniform1f(_uniforms[AGLKTex0Enabled], self.texture2d0.enabled ? 1.0 : 0.0);
        glUniform1f(_uniforms[AGLKTex1Enabled], self.texture2d1.enabled ? 1.0 : 0.0);
        
        
        if (self.light0.enabled) {
            glUniform4fv(_uniforms[AGLKLight0Pos], 1, self.light0EyePosition.v);
            glUniform3fv(_uniforms[AGLKLight0Direction], 1, self.light0EyeDirection.v);
            glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, GLKVector4Multiply(self.light0.diffuseColor, self.material.diffuseColor).v);
            glUniform1f(_uniforms[AGLKLight0Cutoff], GLKMathDegreesToRadians(self.light0.spotCutoff));
            glUniform1f(_uniforms[AGLKLight0Exponent], self.light0.spotExponent);
        }
        else{
            glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
        }
        
        if (self.light1.enabled) {
            glUniform4fv(_uniforms[AGLKLight1Pos], 1, self.light1EyePosition.v);
            glUniform3fv(_uniforms[AGLKLight1Direction], 1, self.light1EyeDirection.v);
            glUniform4fv(_uniforms[AGLKLight1Diffuse], 1, GLKVector4Multiply(self.light1.diffuseColor, self.material.diffuseColor).v);
            glUniform1f(_uniforms[AGLKLight1Cutoff], GLKMathDegreesToRadians(self.light1.spotCutoff));
            glUniform1f(_uniforms[AGLKLight1Exponent], self.light1.spotExponent);
        }
        else{
            glUniform4fv(_uniforms[AGLKLight1Diffuse], 1, GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
        }

        if (self.light2.enabled) {
            glUniform3fv(_uniforms[AGLKLight2Pos], 1, self.light2EyePosition.v);
            glUniform4fv(_uniforms[AGLKLight2Diffuse], 1, GLKVector4Multiply(self.light2.diffuseColor, self.material.diffuseColor).v);
        }
        else{
            glUniform4fv(_uniforms[AGLKLight2Diffuse], 1, GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f).v);
        }
        
        // 将所有纹理绑定到各自的单位
        glActiveTexture(GL_TEXTURE0);
        if (self.texture2d0.name != 0 && self.texture2d0.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
        }
        else{
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        
        glActiveTexture(GL_TEXTURE1);
        if (self.texture2d1.name != 0 && self.texture2d1.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d1.name);
        }
        else{
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        
    }
}

- (BOOL)loadShaders
{
    self.program = glCreateProgram();
    
    GLuint vertexShader, fragmentShader;
    NSString *vertexPath = [[NSBundle mainBundle] pathForResource:@"AGLKTextureMatrix2PointLightShader" ofType:@"vsh"];
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vertexPath]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    NSString *fragmentPath = [[NSBundle mainBundle] pathForResource:@"AGLKTextureMatrix2PointLightShader" ofType:@"fsh"];
    if (![self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER file:fragmentPath]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(self.program, vertexShader);
    glAttachShader(self.program, fragmentShader);
    
    // 把GLK参数绑定到program中，这个操作必须在program链接前
    glBindAttribLocation(self.program, GLKVertexAttribPosition, "a_position");
    glBindAttribLocation(self.program, GLKVertexAttribNormal, "a_normal");
    glBindAttribLocation(self.program, GLKVertexAttribTexCoord0, "a_texCoord0");
    glBindAttribLocation(self.program, GLKVertexAttribTexCoord1, "a_texCoord1");
    
    if (![self linkProgram:self.program]) {
        NSLog(@"Failed to link program: %d", _program);
        if (vertexShader)
        {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragmentShader)
        {
            glDeleteShader(fragmentShader);
            fragmentShader = 0;
        }
        if (self.program)
        {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        return NO;
    }
    
    // Get uniform locations.
    _uniforms[AGLKModelviewMatrix]      = glGetUniformLocation(_program, "u_modelviewMatrix");
    _uniforms[AGLKMVPMatrix]            = glGetUniformLocation(_program, "u_mvpMatrix");
    _uniforms[AGLKNormalMatrix]         = glGetUniformLocation(_program, "u_normalMatrix");
    _uniforms[AGLKTex0Matrix]           = glGetUniformLocation(_program, "u_tex0Matrix");
    _uniforms[AGLKTex1Matrix]           = glGetUniformLocation(_program, "u_tex1Matrix");
    _uniforms[AGLKSamplers]             = glGetUniformLocation(_program, "u_unit2d");
    _uniforms[AGLKTex0Enabled]          = glGetUniformLocation(_program, "u_tex0Enabled");
    _uniforms[AGLKTex1Enabled]          = glGetUniformLocation(_program, "u_tex1Enabled");
    _uniforms[AGLKGlobalAmbient]        = glGetUniformLocation(_program, "u_globalAmbient");
    _uniforms[AGLKLight0Pos]            = glGetUniformLocation(_program, "u_light0EyePos");
    _uniforms[AGLKLight0Direction]      = glGetUniformLocation(_program, "u_light0NormalEyeDirection");
    _uniforms[AGLKLight0Diffuse]        = glGetUniformLocation(_program, "u_light0Diffuse");
    _uniforms[AGLKLight0Cutoff]         = glGetUniformLocation(_program, "u_light0Cutoff");
    _uniforms[AGLKLight0Exponent]       = glGetUniformLocation(_program, "u_light0Exponent");
    _uniforms[AGLKLight1Pos]            = glGetUniformLocation(_program, "u_light1EyePos");
    _uniforms[AGLKLight1Direction]      = glGetUniformLocation(_program, "u_light1NormalEyeDirection");
    _uniforms[AGLKLight1Diffuse]        = glGetUniformLocation(_program, "u_light1Diffuse");
    _uniforms[AGLKLight1Cutoff]         = glGetUniformLocation(_program, "u_light1Cutoff");
    _uniforms[AGLKLight1Exponent]       = glGetUniformLocation(_program, "u_light1Exponent");
    _uniforms[AGLKLight2Pos]            = glGetUniformLocation(_program, "u_light2EyePos");
    _uniforms[AGLKLight2Diffuse]        = glGetUniformLocation(_program, "u_light2Diffuse");
    
    // Delete vertex and fragment shaders.
    if (vertexShader)
    {
        glDetachShader(self.program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader)
    {
        glDetachShader(self.program, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    const char *source = [[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (source == NULL) {
        return NO;
    }
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        NSLog(@"Shader compile log:%s\n",log);
        free(log);
    }
#endif
    
    GLint status = GL_FALSE;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

/////////////////////////////////////////////////////////////////
// Returns YES if the receiver's Shading Language programs
// link successfully. Logs an error message and returns NO
// otherwise.
// This method is based on Apple's sample code.
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}



/////////////////////////////////////////////////////////////////
// Call this method to set light0 position instead of setting
// effect.light0.position directly. This class needs to intercept
// changes to light positions so that the positions can be
// converted to eye coordinates.
- (void)setLight0Position:(GLKVector4)aPosition
{
    self.light0.position = aPosition;
    
    aPosition = GLKMatrix4MultiplyVector4( self.light0.transform.modelviewMatrix, aPosition);
    self.light0EyePosition = GLKVector3Make( aPosition.x, aPosition.y, aPosition.z);
}



/////////////////////////////////////////////////////////////////
// Call this method to set light0 spot direction instead of
// setting effect.light0.spotDirection directly. This class needs
// to intercept changes to convert to eye coordinates and
// renormalize.
- (void)setLight0SpotDirection:(GLKVector3)aDirection
{
    self.light0.spotDirection = aDirection;
    
    aDirection = GLKMatrix4MultiplyVector3( self.light0.transform.modelviewMatrix, aDirection);
    self.light0EyeDirection = GLKVector3Normalize( GLKVector3Make( aDirection.x, aDirection.y, aDirection.z));
}




/////////////////////////////////////////////////////////////////
// Call this method to set light1 position instead of setting
// effect.light1.position directly. This class needs to intercept
// changes to light positions so that the positions can be
// converted to eye coordinates.
- (void)setLight1Position:(GLKVector4)aPosition
{
    self.light1.position = aPosition;
    
    aPosition = GLKMatrix4MultiplyVector4(self.light1.transform.modelviewMatrix, aPosition);
    self.light1EyePosition = GLKVector3Make(aPosition.x, aPosition.y, aPosition.z);
}


/////////////////////////////////////////////////////////////////
// Call this method to set light1 spot direction instead of
// setting effect.light1.spotDirection directly. This class needs
// to intercept changes to convert to eye coordinates and
// renormalize.
- (void)setLight1SpotDirection:(GLKVector3)aDirection
{
    self.light1.spotDirection = aDirection;
    
    aDirection = GLKMatrix4MultiplyVector3(self.light1.transform.modelviewMatrix, aDirection);
    self.light1EyeDirection = GLKVector3Normalize(GLKVector3Make(aDirection.x, aDirection.y, aDirection.z));
}



/////////////////////////////////////////////////////////////////
// Call this method to set light2 position instead of setting
// effect.light2.position directly. This class needs to intercept 
// changes to light positions so that the positions can be 
// converted to eye coordinates.
- (void)setLight2Position:(GLKVector4)aPosition
{
    self.light2.position = aPosition;
    
    aPosition = GLKMatrix4MultiplyVector4(self.light2.transform.modelviewMatrix,aPosition);
    self.light2EyePosition = GLKVector3Make(aPosition.x, aPosition.y, aPosition.z);
}



@end
