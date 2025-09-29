#pragma once

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <vector>
#include <string>

// Sphere structure for metaballs
struct Sphere {
    glm::vec3 position;
    float radius;
    glm::vec3 velocity;
    glm::vec3 color;
    
    Sphere(glm::vec3 pos, float r, glm::vec3 vel = glm::vec3(0.0f))
        : position(pos), radius(r), velocity(vel), color(glm::vec3(0.3f, 0.7f, 1.0f)) {}
};

// Camera class for 3D navigation
class Camera {
public:
    glm::vec3 Position;
    glm::vec3 Front;
    glm::vec3 Up;
    glm::vec3 Right;
    glm::vec3 WorldUp;
    
    float Yaw;
    float Pitch;
    float MovementSpeed;
    float MouseSensitivity;
    float Zoom;
    
    Camera(glm::vec3 position = glm::vec3(0.0f, 0.0f, 3.0f), 
           glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f), 
           float yaw = -90.0f, float pitch = 0.0f);
    
    glm::mat4 GetViewMatrix();
    void ProcessKeyboard(int direction, float deltaTime);
    void ProcessMouseMovement(float xoffset, float yoffset, bool constrainPitch = true);
    void ProcessMouseScroll(float yoffset);
    
private:
    void updateCameraVectors();
};

// Shader utility class
class Shader {
public:
    unsigned int ID;
    
    Shader(const std::string& vertexPath, const std::string& fragmentPath);
    Shader(const std::string& vertexPath, const std::string& geometryPath, const std::string& fragmentPath);
    
    void use();
    void setBool(const std::string& name, bool value) const;
    void setInt(const std::string& name, int value) const;
    void setFloat(const std::string& name, float value) const;
    void setVec3(const std::string& name, const glm::vec3& value) const;
    void setMat4(const std::string& name, const glm::mat4& mat) const;
    
private:
    void checkCompileErrors(unsigned int shader, std::string type);
    std::string readFile(const std::string& filePath);
};

// Marching Cubes utility functions
namespace MarchingCubes {
    // Grid generation
    std::vector<glm::vec3> generateGridPoints(float gridSize, int resolution);
    
    // Scalar field calculation
    float calculateScalarField(const glm::vec3& position, const std::vector<Sphere>& spheres);
    
    // Utility functions
    glm::vec3 calculateGradient(const glm::vec3& position, const std::vector<Sphere>& spheres, float epsilon = 0.01f);
}

// Math constants
namespace Constants {
    const float PI = 3.14159265359f;
    const float TWO_PI = 2.0f * PI;
    const float HALF_PI = PI / 2.0f;
}

// Keyboard movement directions
enum Camera_Movement {
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT,
    UP,
    DOWN
};