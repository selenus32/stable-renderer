#version 330 core
out vec4 FragColor;

uniform ivec2 iResolution;             // Viewport resolution (in pixels)
uniform float iTime;                  // Shader playback time (in seconds)
uniform float iTimeDelta;             // Render time (in seconds)
uniform float iFrameRate;             // Shader frame rate
uniform int iFrame;                   // Shader playback frame
//uniform float iChannelTime[4];      // Channel playback time (in seconds)
//uniform vec3 iChannelResolution[4]; // Channel resolution (in pixels) 
//uniform vec4 iMouse;                // Mouse pixel coords. xy: current (if MLB down), zw: click
//uniform samplerXX iChannel10..3;    // Input channel. XX = 2D/Cube
//uniform vec4 iDate;                 // Year, month, day, time in seconds
//uniform float iSampleRate;          // Sound sample rate (i.e., 44100)

vec2 fragCoord = gl_FragCoord.xy;

void main() {
    vec2 uv = fragCoord / iResolution.xy;

    vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));

    FragColor = vec4(col, 1.0);
}