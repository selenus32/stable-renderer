#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <iostream>
#include <fstream>
#include <stdexcept>
#include <string>

class Shader {
	public:
        GLuint ID;
        Shader(const char* vertexFile, const char* fragmentFile);
		void Activate();
		void Delete();
	private:
        GLuint createShader(const char* shaderFile, GLenum shaderType);
};

std::string get_file_contents(const char* filename)
{
    std::ifstream in(filename);
    //if (!in) {
    //    throw std::runtime_error("Failed to open file: " + std::string(filename));
    //}

    std::string contents((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
    in.close();

    //if (contents.empty()) {
    //    throw std::runtime_error("Empty file: " + std::string(filename));
    //}

    return contents;
}

GLuint Shader::createShader(const char* shaderFile, GLenum shaderType) {
    std::string shaderCode = get_file_contents(shaderFile);
    const char* shaderCode_c = shaderCode.c_str();

    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderCode_c, NULL);
    glCompileShader(shader);
    return shader;
}

Shader::Shader(const char* vertexFile, const char* fragmentFile) {
    GLuint vertexShader = createShader(vertexFile, GL_VERTEX_SHADER);
    GLuint fragmentShader = createShader(fragmentFile, GL_FRAGMENT_SHADER);

    ID = glCreateProgram();
    glAttachShader(ID, vertexShader);
    glAttachShader(ID, fragmentShader);
    glLinkProgram(ID);

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    //std::cout << ID << std::endl;
}

void Shader::Activate() {
    glUseProgram(ID);
}

void Shader::Delete() {
    glDeleteProgram(ID);
}