uniform sampler2D depthmap;
uniform sampler2D normalmap;
uniform float z = 0;
uniform float scale = 1;


void effects(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords)

{	vec4 diffuse = Texel(texture, texture_coords);
	vec4 normal = vec4(Texel(normalmap, texture_coords).rgb, floor(diffuse.a));
	vec4 depth = vec4(Texel(depthmap, texture_coords).r * scale + color.r + z / 255, 0.0, 0.0, floor(diffuse.a));

	//normal = normal * 2 - 1;
	//normal = normal * rotation;
	//normal = normal / 2 + 0.5;

	love_Canvases[0] = diffuse;
	love_Canvases[1] = normal;
	love_Canvases[2] = depth;
}