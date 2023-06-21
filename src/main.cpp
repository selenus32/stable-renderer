#include "shaderClass.h"

glm::ivec2 iResolution = glm::ivec2(1280,720);

void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) glfwSetWindowShouldClose(window, 1);
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

int main()
{
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    GLFWwindow* window = glfwCreateWindow(iResolution.x, iResolution.y, "Renderer", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSetWindowAspectRatio(window, 16, 9);

    gladLoadGL();
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    glViewport(0, 0, iResolution.x, iResolution.y);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glLineWidth(4.0f);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);

    GLfloat iTime = 0.;
    GLfloat iTimeDelta = 0.;
    GLfloat lastFrameTime = 0.;
    GLfloat iFrameRate = 0.;
    GLint iFrame = 0;

    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    
    while (!glfwWindowShouldClose(window))
    {
        iTime = glfwGetTime();
        iTimeDelta = iTime - lastFrameTime;
        lastFrameTime = iTime;
        iFrameRate = 1 / iTimeDelta;
        iFrame++;
        
        processInput(window);

        if (iFrame % 16 == 0) {
            std::string title = "Renderer - " + std::to_string(GLint(iFrameRate)) + " fps, " + std::to_string(GLint(iTimeDelta*1000.)) + " ms";
            glfwSetWindowTitle(window, title.c_str());
        }
        
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
        glfwGetWindowSize(window, &iResolution.x, &iResolution.y);

        Shader shaderProgram("././src/shaders/default_vert.glsl", "././src/shaders/default_frag.glsl");
        shaderProgram.Activate();

        glUniform2i(glGetUniformLocation(shaderProgram.ID, "iResolution"), iResolution.x,iResolution.y); // Viewport resolution (in pixels)
        glUniform1f(glGetUniformLocation(shaderProgram.ID, "iTime"), iTime); // Shader playback time (in seconds)
        glUniform1f(glGetUniformLocation(shaderProgram.ID, "iTimeDelta"), iTimeDelta);
        glUniform1f(glGetUniformLocation(shaderProgram.ID, "iFrameRate"), iFrameRate);
        glUniform1i(glGetUniformLocation(shaderProgram.ID, "iFrame"), iFrame);

        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glfwSwapBuffers(window);
        glfwPollEvents();

        
        shaderProgram.Delete();
    }

    glfwTerminate();
    return 0;
}

