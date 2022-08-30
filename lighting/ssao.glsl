
#ifndef SSAO_SAMPLES_NUM
#define SSAO_SAMPLES_NUM 16
#endif

#ifndef SSAO_SAMPLES_ARRAY
#if defined(GLSLVIEWER)
#define SSAO_SAMPLES_ARRAY u_ssaoSamples
uniform vec3 u_ssaoSamples[SSAO_SAMPLES_NUM];
#else
#define SSAO_SAMPLES_ARRAY u_samples
#endif
#endif

#ifndef SSAO_NOISE_NUM
#define SSAO_NOISE_NUM 4
#endif

#ifndef SSAO_NOISE_ARRAY
#if defined(GLSLVIEWER)
#define SSAO_NOISE_ARRAY u_ssaoNoise
uniform vec3 u_ssaoNoise[SSAO_NOISE_NUM];
#else 
#define SSAO_NOISE_ARRAY u_noise
#endif
#endif

#ifndef PROJECTION_MATRIX
#if defined(GLSLVIEWER)
#define PROJECTION_MATRIX u_projectionMatrix
#else
#define PROJECTION_MATRIX u_projection
#endif
#endif

#ifndef FNC_SSAO
#define FNC_SSAO
float ssao(sampler2D texPosition, sampler2D texNormal, vec2 st, float radius, float bias) {
    vec4 position   = texture2D(texPosition, st);
    vec3 normal     = texture2D(texNormal, st).rgb;

    float noiseS    = sqrt(float(SSAO_NOISE_NUM));
    int  noiseX     = int( mod(gl_FragCoord.x - 0.5, noiseS) );
    int  noiseY     = int( mod(gl_FragCoord.y - 0.5, noiseS) );
    vec3 random     = SSAO_NOISE_ARRAY[noiseX + noiseY * int(noiseS)];

    vec3 tangent  = normalize(random - normal * dot(random, normal));
    vec3 binormal = cross(normal, tangent);
    mat3 tbn      = mat3(tangent, binormal, normal);

    float occlusion = 0.0;
    for (int i = 0; i < SSAO_SAMPLES_NUM; ++i) {
        vec3 samplePosition = tbn * SSAO_SAMPLES_ARRAY[i];
        samplePosition = position.xyz + samplePosition * radius;

        vec4 offsetUV = vec4(samplePosition, 1.0);
        offsetUV = PROJECTION_MATRIX * offsetUV;
        offsetUV.xy /= offsetUV.w;
        offsetUV.xy = offsetUV.xy * 0.5 + 0.5;

        float sampleDepth = texture2D(texPosition, offsetUV.xy).z;
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(position.z - sampleDepth));
        occlusion += (sampleDepth >= samplePosition.z + bias ? 1.0 : 0.0) * rangeCheck;
    }

    occlusion /= float(SSAO_SAMPLES_NUM);
    return 1.0-occlusion;
}

float ssao(sampler2D texPosition, sampler2D texNormal, vec2 st, float radius) {
    return ssao(texPosition, texNormal, st, radius, 0.05);
}

float ssao(sampler2D texPosition, sampler2D texNormal, vec2 st) {
    return ssao(texPosition, texNormal, st, 1.0, 0.05);
}

#endif