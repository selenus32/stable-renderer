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
        Shader(const char* computeFile);

        void setUniform1i(const char* locVar, GLint v0);
        void setUniform2i(const char* locVar, GLint v0, GLint v1);
        void setUniform1f(const char* locVar, GLfloat v0);
        void setUniform2f(const char* locVar, GLfloat v0, GLfloat v1);

		void Activate();
		void Delete();
	private:
        GLuint createShader(const char* shaderFile, GLenum shaderType);
};

std::string get_file_contents(const char* filename) {
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
}

Shader::Shader(const char* computeFile) {
    GLuint computeShader = createShader(computeFile, GL_COMPUTE_SHADER);

    ID = glCreateProgram();
    glAttachShader(ID, computeShader);
    glLinkProgram(ID);

    glDeleteShader(computeShader);
}

void Shader::setUniform1i(const char* locVar, GLint v0) {
    glProgramUniform1i(ID,glGetUniformLocation(ID, locVar), v0);
}

void Shader::setUniform2i(const char* locVar, GLint v0, GLint v1) {
    glProgramUniform2i(ID,glGetUniformLocation(ID, locVar), v0, v1);
}

void Shader::setUniform1f(const char* locVar, GLfloat v0) {
    glProgramUniform1f(ID, glGetUniformLocation(ID, locVar), v0);
}

void Shader::setUniform2f(const char* locVar, GLfloat v0, GLfloat v1) {
    glProgramUniform2f(ID, glGetUniformLocation(ID, locVar), v0, v1);
}

void Shader::Activate() {
    glUseProgram(ID);
}

void Shader::Delete() {
    glDeleteProgram(ID);
}