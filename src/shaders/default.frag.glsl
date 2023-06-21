#version 460 core
out vec4 FragColor;

in vec2 texCoord;

uniform sampler2D computeTexture;

void main()
{
    vec3 texCol = texture(computeTexture, texCoord).rgb;
    FragColor = vec4(texCol, 1.0);
}