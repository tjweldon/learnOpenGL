
#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;

uniform float mixf;

void main()
{
    vec4 smiley = texture(texture2, TexCoord.xy);
    FragColor = mix(texture(texture1, TexCoord), smiley, mixf);
}