#ifndef MINECRAFT_FOG_GLSL
#define MINECRAFT_FOG_GLSL

layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};

const float FOG_DISTANCE_SCALE = 0.25; // lower = fog is closer (1.0 = vanilla)
const float FOG_DARKNESS       = 0.45; // lower = darker fog (1.0 = vanilla)
const float FOG_START_RATIO    = 0.15; // fog starts at this fraction of its end distance
// --------------------

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd) {
    // Pull the render distance fog in close, and start it early so it ramps up gradually
    renderDistanceEnd *= FOG_DISTANCE_SCALE;
    renderDistanceStart = renderDistanceEnd * FOG_START_RATIO;

    environmentalStart *= FOG_DISTANCE_SCALE;
    environmantalEnd   *= FOG_DISTANCE_SCALE;

    return max(
        linear_fog_value(sphericalVertexDistance, environmentalStart, environmantalEnd),
        linear_fog_value(cylindricalVertexDistance, renderDistanceStart, renderDistanceEnd)
    );
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmantalEnd, renderDistanceStart, renderDistanceEnd);

    // Darken the fog color
    vec3 darkFog = fogColor.rgb * FOG_DARKNESS;

    return vec4(mix(inColor.rgb, darkFog, fogValue * fogColor.a), inColor.a);
}

float fog_spherical_distance(vec3 pos) {
    return length(pos);
}

float fog_cylindrical_distance(vec3 pos) {
    float distXZ = length(pos.xz);
    float distY = abs(pos.y);
    return max(distXZ, distY);
}

#endif