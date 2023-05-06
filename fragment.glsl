
#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;

uniform float time;

void main()
{
    float osc = (1.0 + 0.75 * sin(time * 10.0));
    vec2 dynTexCoords = (TexCoord.xy - vec2(0.5))*osc + vec2(0.5);
    vec4 smiley = texture(texture2, dynTexCoords);
    smiley = smiley * step(0.5, 1-distance(dynTexCoords, vec2(0.5)));
    FragColor = mix(texture(texture1, TexCoord), smiley, 0.5);
}