attribute vec3 position;
attribute vec2 textureCoordinate;
uniform mat4 rotateMatrix; // 旋转矩阵
uniform mat4 moveMatrix; // 平移矩阵

varying lowp vec2 varyTexCoord; // 传递参数

void main()
{
    varyTexCoord = textureCoordinate;
    
    vec4 pos = vec4(position,1.0);
    pos = pos * rotateMatrix * moveMatrix;
    gl_Position = pos;
}
