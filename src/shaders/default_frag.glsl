#version 460 core
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

void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    float samples = 50.;
    float a = iTime * 0.2;
    vec2 uv = (fragCoord - 0.5) / iResolution.xy * 3.;//cos(iTime);
    for (float i = 0.; i < samples; i++) {
        uv = (abs(uv.xy) - 0.5) * 1.1 * mat2(cos(a), -sin(a), sin(a), cos(a));
    }

    // Time varying pixel color
    vec3 col = vec3(length(uv.xy), length(uv.xy)/8., length(uv.xy) / 2.);

    // Output to screen
    FragColor = vec4(col, 1.0);
}