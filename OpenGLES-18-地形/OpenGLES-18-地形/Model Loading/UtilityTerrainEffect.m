//
//  UtilityTerrainEffect.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityTerrainEffect.h"
#import "TETerrain+viewAdditions.h"
#import "UtilityTextureInfo+viewAdditions.h"
#import "TETerrain+modelAdditions.h"

#define MAX_TEXTURES (5)

@interface UtilityTerrainEffect()
{
    GLint uniforms[TETerrainNumUniforms];
    // 纹理矩阵
    GLKMatrix3 textureMatrices[MAX_TEXTURES];
}
@property(assign, nonatomic) GLfloat metersPerUnit;
@end

@implementation UtilityTerrainEffect

- (instancetype)initWithTerrain:(TETerrain *)aTerrain
{
    if (self = [super init]) {
        
        const GLfloat metersPerUnit = self.metersPerUnit;
        // 地形的长宽
        const GLfloat widthMeters = aTerrain.widthMeters;
        const GLfloat lengthMeters = aTerrain.lengthMeters;
        // 长度单位
        self.metersPerUnit = aTerrain.metersPerUnit;
        
        // 默认纹理矩阵
        textureMatrices[0] = GLKMatrix3MakeScale(1.0f / widthMeters,
                                                 1.0f,
                                                 1.0f / lengthMeters);
        
        textureMatrices[1] = GLKMatrix3MakeScale(1.0f / metersPerUnit,
                                                 1.0f / metersPerUnit,
                                                 1.0f / metersPerUnit);
        
        textureMatrices[2] = GLKMatrix3MakeScale(1.0f / metersPerUnit,
                                                 1.0f / metersPerUnit,
                                                 1.0f / metersPerUnit);
        
        textureMatrices[3] = GLKMatrix3MakeScale(1.0f / metersPerUnit,
                                                 1.0f / metersPerUnit, 
                                                 1.0f / metersPerUnit);
        
        textureMatrices[4] = GLKMatrix3MakeScale(1.0f / metersPerUnit,
                                                 1.0f / metersPerUnit, 
                                                 1.0f / metersPerUnit);
    }
    return self;
}


- (void)prepareToDraw
{
    [super prepareToDraw];
    
    // bind textures
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.lightAndWeightsTextureInfo.name);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.detailTextureInfo0.name);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.detailTextureInfo1.name);
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, self.detailTextureInfo2.name);
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, self.detailTextureInfo3.name);
}


/**
 编译链接shader，由每个effect子类去传shader名称
 */
- (void)prepareOpenGL
{
    [self loadShadersWithName:@"UtilityTerrainShader"];
}


/**
 设置uniform变量
 */
- (void)updateUniformValues
{
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.modelviewMatrix);
    // mvp矩阵
    glUniformMatrix4fv(uniforms[TETerrainMVPMatrix], 1, GL_FALSE, mvpMatrix.m);
    // texture 矩阵
    glUniformMatrix3fv(uniforms[TETerrainTexureMatrices], MAX_TEXTURES, GL_FALSE, textureMatrices[0].m);
    // 全局环境光
    glUniform4fv(uniforms[TETerrainGlobalAmbientColor], 1, self.globalAmbientLightColor.v);
    
    const GLint samplerIDs[MAX_TEXTURES] = {0, 1, 2, 3, 4};
    glUniform1iv(uniforms[TETerrainSamplers2D], MAX_TEXTURES, samplerIDs);
}


/**
 绑定shader属性
 */
- (void)bindAttribLocations
{
    glBindAttribLocation(self.program, TETerrainPositionAttrib, "a_position");
}

- (void)configureUniformLocations
{
    uniforms[TETerrainMVPMatrix] = glGetUniformLocation(self.program, "u_mvpMatrix");
    uniforms[TETerrainTexureMatrices] = glGetUniformLocation(self.program, "u_texMatrices");
    uniforms[TETerrainGlobalAmbientColor] = glGetUniformLocation(self.program, "u_globalAmbientColor");
    uniforms[TETerrainSamplers2D] = glGetUniformLocation(self.program,"u_units");
}

@end
