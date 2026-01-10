#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;
uniform vec2 ScreenSize;
uniform int FogShape;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;

    ivec3 iColor = ivec3(Color.xyz * 255.0 + 0.5);

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    // vec2 normalized = pos.xy/pos.w;

    // title shift
    // stop rendering text shadows
    // if(iColor.r < 50 && iColor.g < 50 && iColor.b < 50) {
    //     gl_Position = vec4(-2.0, -2.0, 0.0, 1.0);
    //     return;
    // }

    if(iColor == ivec3(78, 92, 36)) {
        vec3 pos = Position;
        gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
        gl_Position.xy += vec2(0, -0.5);
    }

    // actionbar shift for general ui/abilities, maybe i should move to the scoreboard/bossbar if anything?
    if(iColor == ivec3(255, 252, 252)){
        vec3 pos = Position;
        gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
        gl_Position.xy += vec2(0.7, 0);
    }

    // bossbar shift for progressbar at the top

    if(iColor == ivec3(255, 250, 250)){
        vec3 pos = Position;
        gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
        gl_Position.xy += vec2(0, -1);
    }





    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
}
