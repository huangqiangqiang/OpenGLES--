
// 初始位置
attribute vec3 a_emissionPosition;
// 初始速度
attribute vec3 a_emissionVelocity;
// 初始作用力
attribute vec3 a_emissionForce;
// 大小
attribute vec2 a_size;
// 开始和结束时间
attribute vec2 a_emissionAndDeathTimes;

uniform highp mat4 u_mvpMatrix;
// 重力
uniform vec3 u_gravity;
// 经过了多少时间
uniform float u_elapsedSeconds;

void main()
{
    // 栗子产生后到现在经过的时间 = 现在的时间 - 栗子创建的时间
    highp float elapsedTime = u_elapsedSeconds - a_emissionAndDeathTimes.x;
    // 当前速度
    // v = v0 + at
    highp vec3 velocity = a_emissionVelocity + ((a_emissionForce + u_gravity) * elapsedTime);
    
    // 当前位置
    // s = s0 + vt
    highp vec3 untransformedPosition = a_emissionPosition + (a_emissionVelocity + velocity) * 0.5 * elapsedTime;
    
    gl_Position = u_mvpMatrix * vec4(untransformedPosition, 1.0);
    // gl_Position.w 大体相当于栗子与平截体近面之间的距离
    gl_PointSize = a_size.x / gl_Position.w;
}
