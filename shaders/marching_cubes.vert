#version 430 core

layout (location = 0) in vec3 aPos;

// Uniform matrices for transformations
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Pass world position to geometry shader
out vec3 worldPos;

void main()
{
    // Transform vertex position to world space
    vec4 worldPosition = model * vec4(aPos, 1.0);
    worldPos = worldPosition.xyz;
    
    // Pass to geometry shader (no transformation here, geometry shader will handle it)
    gl_Position = worldPosition;
}