// 在fragShader中，数字类型的变量都要声明精度
varying lowp vec2 varyTexCoord;

uniform sampler2D img;

void main()
{
    gl_FragColor = texture2D(img,varyTexCoord);
}

