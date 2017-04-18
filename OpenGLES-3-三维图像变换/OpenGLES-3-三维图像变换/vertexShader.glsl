attribute vec3 position;
attribute vec4 positionColor;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

varying lowp vec4 color;

void main()
{
    color = positionColor;
    
    vec4 pos = vec4(position,1.0);
    pos = projectionMatrix * modelViewMatrix * pos;
    gl_Position = pos;
}
