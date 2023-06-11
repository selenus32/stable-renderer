#include "shaderClass.h"

glm::ivec2 iResolution = glm::ivec2(800,600);

// Camera, Input
/*
GLfloat fov = 90;

glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);

void mouse_callback(GLFWwindow* window, double xpos, double ypos);

float pitch, yaw;

float lastX = SCR_WIDTH / 2.0f;
float lastY = SCR_HEIGHT / 2.0f;
bool firstMouse = true;

float deltaTime = 0.0f;	// Time between current frame and last frame
float lastFrame = 0.0f; // Time of last frame

void processInput(GLFWwindow* window)
{
    glm::mat4 cameraMatrix = glm::mat4(1.0f);

    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) glfwSetWindowShouldClose(window, 1);

    float currentFrame = glfwGetTime();
    deltaTime = currentFrame - lastFrame;
    lastFrame = currentFrame;

    float cameraSpeed = 25.0f * deltaTime; // adjust accordingly

    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        cameraPos += cameraSpeed * cameraFront;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        cameraPos -= cameraSpeed * cameraFront;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
}

void mouse_callback(GLFWwindow* window, double xposIn, double yposIn)
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
    float yoffset = lastY - ypos; // reversed since y-coordinates go from bottom to top

    lastX = xpos;
    lastY = ypos;

    yaw += xoffset;
    pitch += yoffset;

    if (pitch > 89.0f)
        pitch = 89.0f;
    if (pitch < -89.0f)
        pitch = -89.0f;

    glm::vec3 direction;
    direction.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
    direction.y = sin(glm::radians(pitch));
    direction.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
    cameraFront = glm::normalize(direction);
}
*/

void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) glfwSetWindowShouldClose(window, 1);
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

GLuint createQuadVAO() {
    glm::vec3 vertices[] = {
            glm::vec3(-1.,-1.,0.),
            glm::vec3(1., -1.,0.),
            glm::vec3(-1.,1.,0.),
            glm::vec3(1.,1.,0.),
    };

    GLuint indices[] = {
        0,1,2,
        1,3,2,
    };

    GLuint VAO, VBO, EBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);

    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(glm::vec3), (void*)0);
    glEnableVertexAttribArray(0);

    glBindVertexArray(0);

    return VAO;
}


int main()
{
    // Initialize GLFW
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    // Create GLFW window
    GLFWwindow* window = glfwCreateWindow(iResolution.x, iResolution.y, "Renderer", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSetWindowAspectRatio(window, 16, 9);
    //Camera, Input
    //glfwSetCursorPosCallback(window, mouse_callback);
    //glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    // Load OpenGL functions using GLAD
    gladLoadGL();
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    //Create Quad VAO
    GLuint quadVAO = createQuadVAO();

    // Viewport and draw settings
    glViewport(0, 0, iResolution.x, iResolution.y);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glLineWidth(4.0f);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);

    // Shader uniforms init
    GLfloat iTime = 0.;
    GLfloat iTimeDelta = 0.;
    GLfloat lastFrameTime = 0.;
    GLfloat iFrameRate = 0.;
    GLint iFrame = 0;
    
    // Render loop
    while (!glfwWindowShouldClose(window))
    {
        // Shader uniforms
        iTime = glfwGetTime();
        iTimeDelta = iTime - lastFrameTime;
        lastFrameTime = iTime;
        iFrameRate = 1 / iTimeDelta;
        iFrame++;
        
        // input
        processInput(window);

        // FPS title
        std::string title = "Renderer - " + std::to_string(iFrameRate) + " fps";
        glfwSetWindowTitle(window, title.c_str());

        glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

        // Clear the screen
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glfwGetWindowSize(window, &iResolution.x, &iResolution.y);

        // Define and activate shaders
        Shader shaderProgram("././src/shaders/default_vert.glsl", "././src/shaders/default_frag.glsl");
        shaderProgram.Activate();

        // Send uniforms to their locations within the shader program
        glUniform2i(glGetUniformLocation(shaderProgram.ID, "iResolution"), iResolution.x,iResolution.y); // Viewport resolution (in pixels)
        glUniform1f(glGetUniformLocation(shaderProgram.ID, "iTime"), iTime); // Shader playback time (in seconds)
        glUniform1f(glGetUniformLocation(shaderProgram.ID, "iTimeDelta"), iTimeDelta);
        glUniform1f(glGetUniformLocation(shaderProgram.ID, "iFrameRate"), iFrameRate);
        glUniform1i(glGetUniformLocation(shaderProgram.ID, "iFrame"), iFrame);

        // Draw quad 
        glBindVertexArray(quadVAO);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        
        // Swap buffers
        glfwSwapBuffers(window);
        glfwPollEvents();

        // Delete shader program
        shaderProgram.Delete();
    }

    glfwTerminate();
    return 0;
}

