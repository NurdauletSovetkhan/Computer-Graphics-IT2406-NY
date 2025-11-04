#include <iostream>
#include <vector>
#include <cmath>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "utilities.h"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);
void processInput(GLFWwindow *window);

const unsigned int SCR_WIDTH = 1200;
const unsigned int SCR_HEIGHT = 800;

Camera camera(glm::vec3(0.0f, 0.0f, 6.0f));
float lastX = SCR_WIDTH / 2.0f;
float lastY = SCR_HEIGHT / 2.0f;
bool firstMouse = true;

float deltaTime = 0.0f;
float lastFrame = 0.0f;

const float GRID_SIZE = 8.0f;
const int GRID_RESOLUTION = 32;
const float ISO_LEVEL = 1.0f;

int main()
{
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "Spheres Merging Visualization", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);

    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }
    
    glEnable(GL_DEPTH_TEST);
    
    std::cout << "OpenGL Version: " << glGetString(GL_VERSION) << std::endl;    

    Shader marchingCubesShader("shaders/marching_cubes.vert", "shaders/marching_cubes.geom", "shaders/marching_cubes.frag");
    
    std::vector<Sphere> spheres;
    spheres.push_back(Sphere(glm::vec3(-1.5f, 0.0f, 0.0f), 1.0f, glm::vec3(0.5f, 0.0f, 0.0f)));
    spheres.push_back(Sphere(glm::vec3(1.5f, 0.0f, 0.0f), 1.2f, glm::vec3(-0.3f, 0.2f, 0.0f)));
    spheres.push_back(Sphere(glm::vec3(0.0f, 2.0f, 0.0f), 0.8f, glm::vec3(0.0f, -0.4f, 0.3f)));
    
    std::cout << "Создано сфер: " << spheres.size() << std::endl;

    std::vector<glm::vec3> gridPoints = MarchingCubes::generateGridPoints(GRID_SIZE, GRID_RESOLUTION);
    
    std::cout << "Создано точек сетки: " << gridPoints.size() << std::endl;

    unsigned int VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, gridPoints.size() * sizeof(glm::vec3), &gridPoints[0], GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (void*)0);
    glEnableVertexAttribArray(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0); 

    while (!glfwWindowShouldClose(window))
    {
        float currentFrame = static_cast<float>(glfwGetTime());
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;

        processInput(window);
        
        for (auto& sphere : spheres)
        {
            sphere.position += sphere.velocity * deltaTime;
            
            float boundary = GRID_SIZE * 0.4f;
            if (sphere.position.x > boundary || sphere.position.x < -boundary)
                sphere.velocity.x *= -1;
            if (sphere.position.y > boundary || sphere.position.y < -boundary)
                sphere.velocity.y *= -1;
            if (sphere.position.z > boundary || sphere.position.z < -boundary)
                sphere.velocity.z *= -1;
        }

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        marchingCubesShader.use();
        
        glm::mat4 model = glm::mat4(1.0f);
        glm::mat4 view = camera.GetViewMatrix();
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), 
                                              (float)SCR_WIDTH / (float)SCR_HEIGHT, 
                                              0.1f, 100.0f);
        
        marchingCubesShader.setMat4("model", model);
        marchingCubesShader.setMat4("view", view);
        marchingCubesShader.setMat4("projection", projection);
        
        marchingCubesShader.setFloat("gridSize", GRID_SIZE);
        marchingCubesShader.setInt("gridResolution", GRID_RESOLUTION);
        marchingCubesShader.setFloat("isoLevel", ISO_LEVEL);
        
        marchingCubesShader.setInt("numSpheres", static_cast<int>(spheres.size()));
        for (size_t i = 0; i < spheres.size() && i < 5; ++i)
        {
            std::string spherePosName = "spherePositions[" + std::to_string(i) + "]";
            std::string sphereRadName = "sphereRadii[" + std::to_string(i) + "]";
            marchingCubesShader.setVec3(spherePosName, spheres[i].position);
            marchingCubesShader.setFloat(sphereRadName, spheres[i].radius);
        }
        
        glm::vec3 lightPos(5.0f, 5.0f, 5.0f);
        marchingCubesShader.setVec3("lightPos", lightPos);
        marchingCubesShader.setVec3("lightColor", glm::vec3(1.0f, 1.0f, 1.0f));
        marchingCubesShader.setVec3("viewPos", camera.Position);

        glBindVertexArray(VAO);
        glDrawArrays(GL_POINTS, 0, static_cast<GLsizei>(gridPoints.size()));

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);

    glfwTerminate();
    return 0;
}

void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.ProcessKeyboard(FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.ProcessKeyboard(BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.ProcessKeyboard(LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.ProcessKeyboard(RIGHT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
        camera.ProcessKeyboard(UP, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS)
        camera.ProcessKeyboard(DOWN, deltaTime);
}

void framebuffer_size_callback([[maybe_unused]] GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

void mouse_callback([[maybe_unused]] GLFWwindow* window, double xposIn, double yposIn)
{
    float xpos = static_cast<float>(xposIn);
    float ypos = static_cast<float>(yposIn);

    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos;

    lastX = xpos;
    lastY = ypos;

    camera.ProcessMouseMovement(xoffset, yoffset);
}

void scroll_callback([[maybe_unused]] GLFWwindow* window, [[maybe_unused]] double xoffset, double yoffset)
{
    camera.ProcessMouseScroll(static_cast<float>(yoffset));
}