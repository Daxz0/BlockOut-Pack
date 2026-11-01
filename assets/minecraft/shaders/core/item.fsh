#version 330
#extension GL_ARB_separate_shader_objects : require

#ifdef GLINT
#include <minecraft:globals.glsl>
#endif
#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>

uniform sampler2D Sampler0;

#ifdef GLINT
uniform sampler2D GlintSampler;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
#endif
layout(location = 2) in vec4 vertexColor;
#ifndef OIT_ALPHA_ONLY
layout(location = 3) in vec4 lightMapColor;
layout(location = 4) in vec4 overlayColor;
#endif
layout(location = 5) in vec2 texCoord0;
#ifdef GLINT
layout(location = 6) in vec2 texCoordGlint;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

const vec3 GLOW_TINT = vec3(2.5, 0.3, 0.3);

#ifndef OIT_ALPHA_ONLY
vec4 calculateFinalColor(vec4 color, bool glow) {
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    if (!glow) {
        color *= lightMapColor;
    }

    #ifdef GLINT
    vec4 glintColor = GlintAlpha * texture(GlintSampler, texCoordGlint);
    color.rgb += glintColor.rgb * glintColor.rgb;
    #endif

    color = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);

    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    #endif

    return color;
}
#endif

void main() {
    vec4 tex = texture(Sampler0, texCoord0);

    bool glow = tex.a > 0.992 && tex.a < 0.999;

    vec4 color = tex;
    if (glow) {
        color.rgb *= GLOW_TINT * ColorModulator.rgb * mix(vec3(1.0), vertexColor.rgb, 0.35);
        color.a *= vertexColor.a * ColorModulator.a;
    }

    #ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
    #endif

    if (glow) {
        vec3 base = color.rgb * GLOW_TINT * ColorModulator.rgb;
        float lum = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        base += vec3(0.0, 0.35, 0.35) * lum * lum;   // lighter pixels go whiter
        color.rgb = base;
        color.a *= vertexColor.a * ColorModulator.a;
    } else {
        color *= vertexColor * ColorModulator;
    }

    #ifdef GLINT
    color.a = max(color.a, GlintAlpha);
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color, glow);
    #endif
    


}