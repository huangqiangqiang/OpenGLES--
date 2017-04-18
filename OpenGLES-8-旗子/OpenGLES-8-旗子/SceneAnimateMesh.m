//
//  SceneAnimateMesh.m
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneAnimateMesh.h"
#import "HQQOpenGLESUtil.h"

#define NUM_MESH_COLUMNS (40)
#define NUM_MESH_ROWS (20)
// 需要绘制的三角形数量
#define NUM_MESH_TRIANGLES ((NUM_MESH_ROWS - 1) * (NUM_MESH_COLUMNS - 1) * 2)
// 顶点索引的数量 ，(NUM_MESH_COLUMNS - 2)是产生的空三角形
#define NUM_MESH_INDICES (NUM_MESH_TRIANGLES + 2 + (NUM_MESH_COLUMNS - 2))



static void SceneMeshInitIndices(GLushort meshIndices[NUM_MESH_INDICES]);
static void SceneMeshUpdateNormals(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]);
static void SceneMeshUpdateMeshWithDefaultPositions(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]);


@interface SceneAnimateMesh()
{
    SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS];
}
@end

@implementation SceneAnimateMesh

void SceneMeshUpdateMeshWithDefaultPositions();

- (instancetype)init
{
    GLushort meshIndices[NUM_MESH_INDICES];
    // 生成索引
    SceneMeshInitIndices(meshIndices);
    // 生成顶点，法线
    SceneMeshUpdateMeshWithDefaultPositions(mesh);
    /*
     这个方法生成的data中保存的是指向数据的指针，并没有对数据进行复制操作。当flag为yes的时候，生成的data对象是bytes的所有者，当data对象被释放的时候也会同时释放bytes，所以bytes必须是通过malloc在堆上分配的内存。当flag为no的时候，bytes不会被自动释放，释放bytes时要注意时机，不要再data对象还被使用的时候释放bytes。
     */
    NSData *vertexData = [NSData dataWithBytesNoCopy:mesh length:sizeof(mesh) freeWhenDone:NO];
    NSData *indexData = [NSData dataWithBytes:meshIndices length:sizeof(meshIndices)];
    return [self initWithVertexAttributeData:vertexData indexData:indexData];
}

- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval
{
    for (int currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++) {
        float yOffset = sinf(currentColumn * 0.4 + anInterval * 2.0) * 2.0;
        for (int currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++) {
            mesh[currentColumn][currentRow].position.y = yOffset;
        }
    }
    
//    for(int currentColumn = 0; currentColumn < NUM_MESH_COLUMNS;
//        currentColumn++)
//    {
//        const GLfloat   phaseOffset = 2.0f * anInterval;
//        const GLfloat   phase = 4.0 * currentColumn / (float)NUM_MESH_COLUMNS;
//        
//        const GLfloat   yOffset = 2.0 * sinf(M_PI * (phase + phaseOffset));
//        
//        for(int currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++)
//        {
//            mesh[currentColumn][currentRow].position.y = yOffset;
//        }
//    }
    
    SceneMeshUpdateNormals(mesh);
    
    [self makeDynamicAndUpdateWithVertices:&mesh[0][0] numberOfVertices:sizeof(mesh) / sizeof(SceneMeshVertex)];
}

- (void)drawEntireMesh
{
    /*
     使用顶点索引的话，必须用glDrawElements函数绘制
     
     * GL_TRIANGLE_STRIP
     构建当前三角形的顶点的连接顺序依赖于要和前面已经出现过的2个顶点组成三角形的当前顶点的序号的奇偶性（如果从0开始）：
     如果当前顶点是奇数：
     组成三角形的顶点排列顺序：T = [n-1 n-2 n].
     如果当前顶点是偶数：
     组成三角形的顶点排列顺序：T = [n-2 n-21 n].
     比如开始绘制第一个三角形，连接0,1,2三个点，最后的顶点是2，是偶数，所以按照偶数的方式连接。
     这个顺序是为了保证所有的三角形都是按照相同的方向绘制的，使这个三角形串能够正确形成表面的一部分。
     
     <#GLsizei count#> 指定了使用的索引数量
     <#GLenum type#> 索引值的类型，必须是GL_UNSIGNED_BYTE或GL_UNSIGNED_SHORT
     <#const GLvoid *indices#> 索引的内存指针
     */
    glDrawElements(GL_TRIANGLE_STRIP, NUM_MESH_INDICES, GL_UNSIGNED_SHORT, (GLushort *)NULL);
}


/////////////////////////////////////////////////////////////////
// Revert mesh to defualt vertex attribtes
void SceneMeshUpdateMeshWithDefaultPositions(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS])
{
    int    currentRow;
    int    currentColumn;
    
    // For each position along +X axis of mesh
    for(currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++)
    {
        // For each position along -Z axis of mesh
        for(currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++)
        {
            mesh[currentColumn][currentRow].position = GLKVector3Make( currentColumn, 0.0f, -currentRow);
            
            GLKVector2 textureCoords = GLKVector2Make( (float)currentRow / (NUM_MESH_ROWS - 1), (float)currentColumn / (NUM_MESH_COLUMNS - 1));
            
            mesh[currentColumn][currentRow].texCoords0 = textureCoords;
        }
    }
    for (int i = 0; i < NUM_MESH_COLUMNS; i++) {
        for (int j = 0; j < NUM_MESH_ROWS; j++) {
            NSLog(@"%@",NSStringFromGLKVector2(mesh[i][j].texCoords0));
        }
    }
    SceneMeshUpdateNormals(mesh);
}


void SceneMeshInitIndices(GLushort meshIndices[NUM_MESH_INDICES])
{
    int    currentRow = 0;
    int    currentColumn = 0;
    int    currentMeshIndex = 0;
    
    // Start at 1 because algorithm steps back one index at start
    currentMeshIndex = 1;
    
    // For each position along +X axis of mesh
    for(currentColumn = 0; currentColumn < (NUM_MESH_COLUMNS - 1); currentColumn++)
    {
        if(0 == (currentColumn % 2))
        {
            // 偶数列
            currentMeshIndex--; // back: 覆盖重复的顶点
            
            // For each position along -Z axis of mesh
            for(currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++)
            {
                meshIndices[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndices[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        }
        else
        {
            // 奇数列
            currentMeshIndex--; // back: overwrite duplicate vertex
            
            // For each position along -Z axis of mesh
            for(currentRow = NUM_MESH_ROWS - 1; currentRow >= 0; currentRow--)
            {
                meshIndices[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS +
                currentRow;
                meshIndices[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        }
    }
    
    [HQQOpenGLESUtil print4Short:(short *)meshIndices count:NUM_MESH_INDICES];
    NSCAssert(currentMeshIndex == NUM_MESH_INDICES, @"Incorrect number of indices intialized.");
}


/////////////////////////////////////////////////////////////////
// Calculate smooth normal vectors by averaging the normal
// vectors of four planes adjacent to each vertex.  Normal
// vectors must be recalculated every time the vertex positions
// change.
void SceneMeshUpdateNormals(SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS])
{
    int    currentRow;
    int    currentColumn;
    
    // Calculate normals for vertices internal to the mesh
    for(currentRow = 1; currentRow < (NUM_MESH_ROWS - 1); currentRow++)
    {
        for(currentColumn = 1; currentColumn < (NUM_MESH_COLUMNS - 1); currentColumn++)
        {
            GLKVector3 position = mesh[currentColumn][currentRow].position;
            // 5 -> 6
            GLKVector3 vectorA = GLKVector3Subtract(mesh[currentColumn][currentRow+1].position,position);
            // 5 -> 9
            GLKVector3 vectorB = GLKVector3Subtract(mesh[currentColumn+1][currentRow].position,position);
            // 5 -> 4
            GLKVector3 vectorC = GLKVector3Subtract(mesh[currentColumn][currentRow-1].position,position);
            // 5 -> 1
            GLKVector3 vectorD = GLKVector3Subtract(mesh[currentColumn-1][currentRow].position,position);
            
            // Calculate normal vectors for four planes
            GLKVector3   normalBA = GLKVector3CrossProduct(vectorB, vectorA);
            GLKVector3   normalCB = GLKVector3CrossProduct(vectorC, vectorB);
            GLKVector3   normalDC = GLKVector3CrossProduct(vectorD, vectorC);
            GLKVector3   normalAD = GLKVector3CrossProduct(vectorA, vectorD);
            
            // Store the average the face normal vectors of the
            // four triangles that share the current vertex
            mesh[currentColumn][currentRow].normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(normalBA,normalCB),normalDC),normalAD),0.25);
        }
    } 
    
    // Calculate normals along X max and X min edges
    for(currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++)
    {
        mesh[0][currentRow].normal = mesh[1][currentRow].normal;
        mesh[NUM_MESH_COLUMNS-1][currentRow].normal = mesh[NUM_MESH_COLUMNS-2][currentRow].normal;
    }
    
    // Calculate normals along Z max and Z min edges
    for(currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++)
    {
        mesh[currentColumn][0].normal = mesh[currentColumn][1].normal;
        mesh[currentColumn][NUM_MESH_ROWS-1].normal = mesh[currentColumn][NUM_MESH_ROWS-2].normal;
    }
}

@end
