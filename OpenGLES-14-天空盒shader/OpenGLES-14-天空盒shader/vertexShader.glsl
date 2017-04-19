uniform mat4 u_mvpMatrix;
attribute vec3 a_position;

varying lowp vec3 v_texCoord[1];

void main()
{
    v_texCoord[0] = a_position;
    gl_Position = u_mvpMatrix * vec4(a_position,1.0);
}
