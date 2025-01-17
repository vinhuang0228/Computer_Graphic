#version 330 core
# define PI 3.1415926535

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;

out vec3 vertex_color;
out vec3 vertex_normal;
out vec3 vertex_pos;

uniform mat4 mvp;
uniform mat4 mv;
uniform int cur_light_mode;
uniform int shade_mode;

uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;

uniform vec3 light_dir;
uniform vec3 light_pos;

uniform vec3 intensity;
uniform int shininess;
uniform int angle;
uniform vec3 viewPos;

void main()
{
	// [TODO]
	gl_Position = mvp * vec4(aPos.x, aPos.y, aPos.z, 1.0);
	//vertex_color = aColor;
	//vertex_normal = aNormal;
	// gouraud

    vec4 pos = mv * vec4(aPos.x, aPos.y, aPos.z, 1.0);
	vertex_pos = vec3(pos.x, pos.y, pos.z);
	vec4 normal = transpose(inverse(mv)) * vec4(aNormal.x, aNormal.y, aNormal.z, 0.0f);
	vertex_normal = vec3(normal.x, normal.y, normal.z);

	// ambient
	vec3 ambient = vec3(0.15f,0.15f,0.15f) *ka;

	//diffuse
	vec3 norm = normalize(vertex_normal);
	vec3 lightDir = normalize(light_pos - vertex_pos);
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = intensity * kd * diff;

	//specular
	vec3 viewDir = normalize(light_dir-vertex_pos);
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(norm, halfwayDir), 0.0), shininess);
	vec3 specular = intensity * ks * spec;

	//attenuation
	float distance = length(light_pos - vertex_pos);
	float att_p = 1.0f / (0.01 + 0.8 * distance + 0.1 * distance * distance);
	att_p = min(att_p, 1);
	float att_s = 1.0f / (0.05 + 0.3 * distance + 0.6 * distance * distance);
	float theta = dot(lightDir,normalize(-vec3(0,0,-1)));
	//float spot_effect = pow(max(dot(normalize(vertex_pos - light_pos), normalize(light_dir)), 0), 50);
	float spot_effect = pow(max(theta, 0), 50);


	if (cur_light_mode == 0)
		vertex_color = ambient + diffuse + specular;
	else if (cur_light_mode == 1)
		vertex_color = att_p * (ambient + diffuse + specular);
	else if (cur_light_mode == 2){
		 if (theta > cos( radians (angle ) )){ //cos(angle * PI / 180)
			vertex_color = spot_effect * (ambient + diffuse + specular);
		}
		else
			vertex_color = spot_effect * ambient * att_s;
	}

}
