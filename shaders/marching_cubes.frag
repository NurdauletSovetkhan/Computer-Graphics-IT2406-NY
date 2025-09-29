#version 430 core

// Input from geometry shader
in vec3 FragPos;
in vec3 Normal;
in vec3 Color;

// Output color
out vec4 FragColor;

// Lighting uniforms
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform vec3 viewPos;

void main()
{
    // Ambient lighting
    float ambientStrength = 0.2;
    vec3 ambient = ambientStrength * lightColor;
    
    // Diffuse lighting
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    
    // Specular lighting (Blinn-Phong)
    float specularStrength = 0.8;
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(norm, halfwayDir), 0.0), 64);
    vec3 specular = specularStrength * spec * lightColor;
    
    // Combine lighting components
    vec3 result = (ambient + diffuse + specular) * Color;
    
    FragColor = vec4(result, 1.0);
}