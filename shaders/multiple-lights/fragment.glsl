#version 330 core
out vec4 FragColor;

struct Switches {
    float directional, point, spot;
};

struct ADS {
    float ambient, diffuse, specular;
};

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;
uniform sampler2D texture_normal1;

struct DirLight {
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct PointLight {
    vec3 position;

    float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct SpotLight {
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;

    float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

#define NR_POINT_LIGHTS 4

in VS_OUT {
    vec3 FragPos;
    vec2 TexCoords;
    mat3 TBN;
} vs_out;

uniform DirLight dirLight;
uniform PointLight pointLights[NR_POINT_LIGHTS];
uniform SpotLight spotLight;
uniform Material material;
uniform Switches switches;
uniform ADS ads;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;


// function prototypes
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir);
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir);
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

vec3 getSpec() {
    vec3 spec = texture(texture_specular1, vs_out.TexCoords).rgb;
    return mat3(model) * spec;
}

vec3 combineAds(vec3 ambient, vec3 diffuse, vec3 specular) {
    return ambient+diffuse+specular;
//    vec3 result = vec3(0.0f);
//    result += ambient * ads.ambient;
//    result += diffuse * ads.diffuse;
//    result += specular * ads.specular;
//    return result;
}

void main()
{
    // properties
    vec3 normalTex = texture(texture_normal1, vs_out.TexCoords).rgb;
    vec3 norm = normalTex * 2. - 1.;
    norm = normalize(vs_out.TBN * norm);
    vec3 viewDir = normalize(spotLight.position - vs_out.FragPos);

    // == =====================================================
    // Our lighting is set up in 3 phases: directional, point lights and an optional flashlight
    // For each phase, a calculate function is defined that calculates the corresponding color
    // per lamp. In the main() function we take all the calculated colors and sum them up for
    // this fragment's final color.
    // == =====================================================
    // phase 1: directional lighting
    vec3 directional = CalcDirLight(dirLight, norm, viewDir);

    // phase 2: point lights
    vec3 ptLight = vec3(0);
    for (int i = 0; i < NR_POINT_LIGHTS; i++)
        ptLight += CalcPointLight(pointLights[i], norm, vs_out.FragPos, viewDir);

    // phase 3: spot light
    vec3 spot = CalcSpotLight(spotLight, norm, vs_out.FragPos, viewDir);

    vec3 result = vec3(0);
    //result += directional * switches.directional;
    //result += ptLight * switches.point;
    result += spot * switches.spot;

    // set final output color
    FragColor = vec4(vs_out.TBN*vec3(1.0, 1.0, 0.), 1.0);
}

// calculates the color when using a directional light.
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir)
{
    vec3 lightDir = normalize(-light.direction);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // combine results
    vec3 ambient = light.ambient * vec3(texture(texture_diffuse1, vs_out.TexCoords));
    vec3 diffuse = light.diffuse * diff * vec3(texture(texture_diffuse1, vs_out.TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, vs_out.TexCoords));
    return combineAds(ambient, diffuse, specular);
}

// calculates the color when using a point light.
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // attenuation
    float distance = length(light.position - fragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    // combine results
    vec3 ambient = light.ambient * vec3(texture(texture_diffuse1, vs_out.TexCoords));
    vec3 diffuse = light.diffuse * diff * vec3(texture(texture_diffuse1, vs_out.TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(texture_specular1, vs_out.TexCoords));

    return combineAds(ambient, diffuse, specular)*attenuation;
}

// calculates the color when using a spot light.
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // attenuation
    float distance = length(light.position - fragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    // spotlight intensity
    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = light.cutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
    // combine results
    vec3 ambient = light.ambient * vec3(texture(texture_diffuse1, vs_out.TexCoords));
    vec3 diffuse = light.diffuse * diff * vec3(texture(texture_diffuse1, vs_out.TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(texture_specular1, vs_out.TexCoords));
    ambient *= attenuation * intensity;
    diffuse *= attenuation * intensity;
    specular *= attenuation * intensity;
    return combineAds(ambient, diffuse, specular);
}



