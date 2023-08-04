# stable renderer
 A stable renderer focused on rendering various GLSL compute shaders. Shader code can be imported from modified [Shadertoy](https://www.shadertoy.com/) fragment shader code.
 
## Requirements

* OpenGL 4.6
* GLAD
* GLM
* GLFW

These libraries can be downloaded separately to this repository and installed appropriately for inclusion in compiling/linking.

## Use

Rendering various compute shader code e.g. fractal geometry, ray casting/tracing/marching, fluid simulations, etc. In particular, various compute shader files have been added in the [shaders](src/shaders) folder, which can be switched to by changing the compute shader directory used by the compute program class created in [main.cpp](src/main.cpp). These particular changes would require a restart of the program, though by changing the currently selected compute shader file's code directly and saving the changes, the compiled changes will be rendered without a restart.
