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

    unsigned int texture;

    glGenTextures(1, &texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, iResolution.x, iResolution.y, 0, GL_RGBA,GL_FLOAT, NULL);

    glBindImageTexture(0, texture, 0, GL_FALSE, 0, GL_READ_ONLY, GL_RGBA32F);
    
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

        Shader computeProgram("././src/shaders/default.comp.glsl");
        Shader shaderProgram("././src/shaders/default.vert.glsl", "././src/shaders/default.frag.glsl");

        shaderProgram.setUniform1i("computeTexture", 0);
        computeProgram.setUniform1f("iTime", iTime);
        computeProgram.setUniform1f("iTimeDelta", iTimeDelta);
        computeProgram.setUniform1f("iFrameRate", iFrameRate);
        computeProgram.setUniform1i("iFrame", iFrame);

        computeProgram.Activate();

        glDispatchCompute(iResolution.x, iResolution.y, 1);
        glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);

        glActiveTexture(GL_TEXTURE0);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, iResolution.x, iResolution.y, 0, GL_RGBA, GL_FLOAT, NULL);
        glBindImageTexture(0, texture, 0, GL_FALSE, 0, GL_READ_ONLY, GL_RGBA32F);
        glBindTexture(GL_TEXTURE_2D, texture);
       
        shaderProgram.Activate();
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(window);
        glfwPollEvents();

        computeProgram.Delete();
        shaderProgram.Delete();
    }

    glfwTerminate();
    return 0;
}

