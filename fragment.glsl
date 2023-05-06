
#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;

uniform float time;

void main()
{
    vec4 smiley = texture(texture2, TexCoord);
    FragColor = mix(texture(texture1, TexCoord), smiley, 0.5);
}