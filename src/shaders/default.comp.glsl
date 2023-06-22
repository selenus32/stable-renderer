#version 460 core
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
layout(rgba32f, binding = 0) uniform image2D imgOutput;

uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform int iFrame;

vec4 quat(vec3 v, float a)
{
    return vec4(v * sin(a / 2.0), cos(a / 2.0));
}

vec4 quatinv(vec4 q)
{
    return vec4(-q.xyz,q.w);
}

vec4 p2q(vec3 p)
{
    return vec4(p,0);
}

vec4 q_mul(in vec4 q1, in vec4 q2)
{
    return vec4(q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y, 
                q1.w*q2.y - q1.x*q2.z + q1.y*q2.w + q1.z*q2.x, 
                q1.w*q2.z + q1.x*q2.y - q1.y*q2.x + q1.z*q2.w, 
                q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z);
}

vec3 rotate(vec3 p, vec3 v, float a)
{
    vec4 q = quat(v, a);
    return q_mul(q_mul(q, p2q(p)), quatinv(q)).xyz;
}

//////////////////////////////////////////////////
// Bunny volume data
//////////////////////////////////////////////////

// Packed 32^3 bunny data as 32x32 uint where each bit represents density per voxel
#define BUNNY_VOLUME_SIZE 32
const uint packedBunny[1024] = uint[1024](0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 917504u, 917504u, 917504u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 1966080u, 12531712u, 16742400u, 16742400u, 16723968u, 16711680u, 8323072u, 4128768u, 2031616u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 6144u, 2063360u, 16776704u, 33553920u, 33553920u, 33553920u, 33553920u, 33520640u, 16711680u, 8323072u, 8323072u, 2031616u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 268435456u, 402653184u, 134217728u, 201326592u, 67108864u, 0u, 0u, 7168u, 2031104u, 16776960u, 33554176u, 33554176u, 33554304u, 33554176u, 33554176u, 33554176u, 33553920u, 16744448u, 8323072u, 4128768u, 1572864u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 805306368u, 939524096u, 402653184u, 478150656u, 260046848u, 260046848u, 260046848u, 125832192u, 130055680u, 67108608u, 33554304u, 33554304u, 33554304u, 33554304u, 33554304u, 33554304u, 33554304u, 33554176u, 16776704u, 8355840u, 4128768u, 917504u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 805306368u, 1056964608u, 1056964608u, 528482304u, 528482304u, 260046848u, 260046848u, 260046848u, 130039296u, 130154240u, 67108739u, 67108807u, 33554375u, 33554375u, 33554370u, 33554368u, 33554368u, 33554304u, 33554304u, 16776960u, 8330240u, 4128768u, 393216u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 939524096u, 1040187392u, 1040187392u, 520093696u, 251658240u, 251658240u, 260046848u, 125829120u, 125829120u, 130088704u, 63045504u, 33554375u, 33554375u, 33554375u, 33554407u, 33554407u, 33554370u, 33554370u, 33554374u, 33554310u, 16776966u, 4144642u, 917504u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 15360u, 130816u, 262017u, 4194247u, 33554383u, 67108847u, 33554415u, 33554407u, 33554407u, 33554375u, 33554375u, 33554318u, 2031502u, 32262u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 31744u, 130816u, 262019u, 2097151u, 134217727u, 134217727u, 67108863u, 33554415u, 33554407u, 33554415u, 33554383u, 2097102u, 982926u, 32262u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 31744u, 130816u, 524263u, 117964799u, 127926271u, 134217727u, 67108863u, 16777215u, 4194303u, 4194303u, 2097151u, 1048574u, 65422u, 16134u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 3u, 31751u, 130951u, 524287u, 252182527u, 261095423u, 261095423u, 59768830u, 2097150u, 1048574u, 1048575u, 262143u, 131070u, 65534u, 16134u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 7u, 31751u, 130959u, 503840767u, 520617982u, 529530879u, 261095423u, 1048575u, 1048574u, 1048574u, 524286u, 524287u, 131070u, 65534u, 16134u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 3u, 1799u, 32527u, 134348750u, 1040449534u, 1057488894u, 520617982u, 51380223u, 1048575u, 1048575u, 524287u, 524287u, 524287u, 131070u, 65534u, 15886u, 6u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 1536u, 3968u, 8175u, 65535u, 1006764030u, 1040449534u, 1057488894u, 50855934u, 524286u, 524286u, 524287u, 524287u, 524286u, 262142u, 131070u, 65534u, 32270u, 14u, 6u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 3968u, 8160u, 8191u, 805371903u, 2080505854u, 2114191358u, 101187582u, 34078718u, 524286u, 524286u, 524286u, 524286u, 524286u, 524286u, 262142u, 131070u, 32766u, 8078u, 3590u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 8128u, 8176u, 16383u, 2013331455u, 2080505854u, 235143166u, 101187582u, 524286u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 524286u, 262142u, 131070u, 32766u, 16382u, 8070u, 1024u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 8160u, 8184u, 1879064574u, 2013331455u, 470024190u, 67371006u, 524286u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 524286u, 262142u, 65534u, 16382u, 8160u, 1024u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 8128u, 8184u, 805322750u, 402718719u, 134479870u, 524286u, 524286u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 262142u, 65534u, 16382u, 16368u, 1792u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 3968u, 8184u, 16382u, 131071u, 262142u, 524286u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 262142u, 65534u, 16382u, 16368u, 1792u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 1792u, 8184u, 16380u, 65535u, 262143u, 524286u, 524286u, 1048574u, 1048574u, 1048575u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 262142u, 65534u, 16376u, 16368u, 1792u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 8176u, 16376u, 32767u, 262143u, 524286u, 1048574u, 1048574u, 1048575u, 1048575u, 1048575u, 1048575u, 1048574u, 1048574u, 524286u, 262142u, 32766u, 16376u, 8176u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 4032u, 8184u, 32766u, 262142u, 524286u, 524286u, 1048575u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 262142u, 32766u, 16376u, 8176u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 384u, 8184u, 32766u, 131070u, 262142u, 524286u, 1048575u, 1048574u, 1048574u, 1048574u, 1048574u, 1048574u, 524286u, 524286u, 131070u, 32766u, 16368u, 1920u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 4080u, 32764u, 65534u, 262142u, 524286u, 524286u, 524286u, 1048574u, 1048574u, 524286u, 524286u, 524286u, 262142u, 131070u, 32764u, 8160u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 256u, 16376u, 32760u, 131068u, 262140u, 262142u, 524286u, 524286u, 524286u, 524286u, 524286u, 262142u, 131070u, 65532u, 16368u, 3840u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 3968u, 32752u, 65528u, 131068u, 262142u, 262142u, 262142u, 262142u, 262142u, 262142u, 262140u, 131064u, 32752u, 7936u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 8064u, 32736u, 65528u, 131070u, 131070u, 131070u, 131070u, 131070u, 131070u, 65532u, 32752u, 8160u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 3456u, 16376u, 32764u, 65534u, 65534u, 65534u, 32766u, 32764u, 16380u, 4048u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 48u, 2680u, 8188u, 8188u, 8188u, 8188u, 4092u, 120u, 16u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 120u, 248u, 508u, 508u, 508u, 248u, 240u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 96u, 240u, 504u, 504u, 504u, 240u, 96u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 224u, 224u, 224u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u);

float sampleBunny(vec3 uvs)
{
    vec3 voxelUvs = max(vec3(0.0), min(uvs * vec3(BUNNY_VOLUME_SIZE), vec3(BUNNY_VOLUME_SIZE)-1.0));
    uvec3 intCoord = uvec3(voxelUvs);
    uint arrayCoord = intCoord.x + intCoord.z * uint(BUNNY_VOLUME_SIZE);

    // Very simple clamp to edge. It would be better to do it for each texture sample
    // before the filtering but that would be more expenssive...
    // Also adding small offset to catch cube intersection floating point error
    if (uvs.x < -0.001 || uvs.y < -0.001 || uvs.z < -0.001 ||
        uvs.x>1.001 || uvs.y>1.001 || uvs.z>1.001)
        return 0.0;

    // sample the uint representing a packed volume data of 32 voxel (1 or 0)
    uint bunnyDepthData = packedBunny[arrayCoord];
    float voxel = (bunnyDepthData & (1u << intCoord.y)) > 0u ? 1.0 : 0.0;

    return voxel;
}

//////////////////////////////////////////////////
// Cube intersection
//////////////////////////////////////////////////

bool slabs(vec3 p0, vec3 p1, vec3 rayOrigin, vec3 invRaydir, out float outTMin, out float outTMax)
{
    vec3 t0 = (p0 - rayOrigin) * invRaydir;
    vec3 t1 = (p1 - rayOrigin) * invRaydir;
    vec3 tmin = min(t0, t1), tmax = max(t0, t1);
    float maxtmin = max(max(tmin.x, tmin.y), tmin.z);
    float mintmax = min(min(tmax.x, tmax.y), tmax.z);
    outTMin = maxtmin;
    outTMax = mintmax;
    return maxtmin <= mintmax;
}

//////////////////////////////////////////////////
// MAIN
//////////////////////////////////////////////////

void main()
{
    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    vec2 uv = vec2(0.);
    uv.x = float(texelCoord.x) / gl_NumWorkGroups.x;
    uv.y = float(texelCoord.y) / gl_NumWorkGroups.y;

    float time = iTime;

    // View diretion in camera space
    vec3 viewDir = vec3(0.);

    viewDir.x = (float(texelCoord.y) - gl_NumWorkGroups.y * 0.5) / gl_NumWorkGroups.y;
    viewDir.y = (float(texelCoord.x) - gl_NumWorkGroups.x * 0.5) / gl_NumWorkGroups.y;
    viewDir.z = 1.0;
    viewDir = normalize(viewDir);

    // Compute camera properties
    float camDist = 1.1;
    vec3 camUp = vec3(0, 1.0, 0);
    vec3 camPos = vec3(0.,0.,2.);
    float angle = 0.5;
    camPos = rotate(camPos, vec3(1., 0., 0.), angle*iTime);
    vec3 camTarget = vec3(0., 0., 0.);

    // And from them evaluted ray direction in world space
    vec3 forward = normalize(camTarget-camPos);
    vec3 left = normalize(cross(forward, camUp));
    vec3 up = cross(left, forward);
    vec3 worldDir = viewDir.x * left + viewDir.y * up + viewDir.z * forward;

    vec3 color = vec3(0.0);

    //////////////////////////////////////////////////////////////////////////////////////////
    //// Compute intersection with cube containing the bunny
    float near = 0.0;
    float far = 0.0;
    vec3 D = normalize(worldDir);
    if (slabs(vec3(-0.5), vec3(0.5), camPos, 1.0 / D, near, far))
    {
        vec3 StartPos = camPos + D * near;

        StartPos = (StartPos + 0.5) * 32.0;
        // Round to axis aligned volume
        if (StartPos.x < 0.0) StartPos.x = 0.0f;
        if (StartPos.y < 0.0) StartPos.y = 0.0f;
        if (StartPos.z < 0.0) StartPos.z = 0.0f;
        if (StartPos.x > 32.0) StartPos.x = 32.0;
        if (StartPos.y > 32.0) StartPos.y = 32.0;
        if (StartPos.z > 32.0) StartPos.z = 32.0;

        vec3 P = StartPos;

        // Amanatides 3D-DDA data preparation
        vec3 stepSign = sign(D);
        vec3 tDelta = abs(1.0 / D);
        vec3 tMax = vec3(0.0, 0.0, 0.0);
        vec3 refPoint = floor(P);
        tMax.x = stepSign.x > 0.0 ? refPoint.x + 1.0 - P.x : P.x - refPoint.x; // floor is more consistent than ceil
        tMax.y = stepSign.y > 0.0 ? refPoint.y + 1.0 - P.y : P.y - refPoint.y;
        tMax.z = stepSign.z > 0.0 ? refPoint.z + 1.0 - P.z : P.z - refPoint.z;
        tMax.x *= tDelta.x;
        tMax.y *= tDelta.y;
        tMax.z *= tDelta.z;

        const float LowB = -0.01;
        const float HighB = 32.01;
        while (P.x >= LowB && P.y >= LowB && P.z >= LowB && P.x <= HighB && P.y <= HighB && P.z <= HighB)
        {
#if 0
            // Slow reference
            //P += D * 0.005;
#else
            // Amanatides 3D-DDA 
            if (tMax.x < tMax.y)
            {
                if (tMax.x < tMax.z)
                {
                    P.x += stepSign.x;
                    tMax.x += tDelta.x;
                }
                else
                {
                    P.z += stepSign.z;
                    tMax.z += tDelta.z;
                }
            }
            else
            {
                if (tMax.y < tMax.z)
                {
                    P.y += stepSign.y;
                    tMax.y += tDelta.y;
                }
                else
                {
                    P.z += stepSign.z;
                    tMax.z += tDelta.z;
                }
            }
#endif

            vec3 Voxel = P;
            if (sampleBunny(vec3(Voxel) / 32.) > 0.)
            {
                color = Voxel / 32.0;
                break;
            }
        }

        // Debug
        //color = fract(StartPos);
        //color = vec3(far-near,0,0);
        //color = abs(sin(worldDir*10.0));


    }

    vec4 pixel = vec4(color, 1.0);

    imageStore(imgOutput, texelCoord, pixel);
}


