#version 460 core
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
layout(rgba32f, binding = 0) uniform image2D imgOutput;

uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform int iFrame;

vec2 cMult(vec2 a, vec2 b) {
    return vec2(a.x*a.x-a.y*b.y,a.x*b.y+a.y*b.x);
}

void main()
{
    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    vec2 uv = vec2(0.);
    uv.x = (float(texelCoord.x)-0.5*gl_NumWorkGroups.x) / gl_NumWorkGroups.y;
    uv.y = (float(texelCoord.y)-0.5*gl_NumWorkGroups.y) / gl_NumWorkGroups.y;

    uv *= 3.;

    vec3 color = vec3(0.);
    vec2 c = uv;
    vec2 z = vec2(0.);

    for (int i = 0; i < 100; i++) {
        z = cMult(z,z) + c;

        if (length(z) < 2.) {
            float b = float(i);
            color = vec3(b/15.,b/25.,b/20.);
        }
    }

    vec4 pixel = vec4(color, 1.0);

    imageStore(imgOutput, texelCoord, pixel);
}