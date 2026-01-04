#version 330

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>


in vec3 Position;
in vec2 UV0;
in vec4 Color;

uniform sampler2D Sampler0;
uniform vec2 ScreenSize;
uniform float GuiScale;

out vec2 texCoord0;
out vec4 vertexColor;


void main() {
    vec2 pos = Position.xy;

    float GuiScale = ScreenSize.x * 0.5 * ProjMat[0][0];
    vec2 anchor = vec2(ScreenSize.x * 0.5, ScreenSize.y) / GuiScale;


    if (Position.z == 27) {
        vertexColor = vec4(1.0,0.0,0.0,1.0);
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, Position.z, 1.0);
    texCoord0 = UV0;
}