#version 460 core

layout (location = 0) in vec3 Position;
uniform ivec3 screen_xy;
        
void main() {
        gl_Position = vec4(Position.x, Position.y, Position.z, 1.0);
}
