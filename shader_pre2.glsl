//uniform sampler2D canvas_depth;
uniform sampler2D depthmap;
uniform sampler2D normalmap;
uniform float z = 0;
uniform float scale = 1;
//extern mat3 rotation;


void effects(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords)
{
	//vec2 canvas_coords = screen_coords / love_ScreenSize.xy;
	//canvas_coords.y = 1 - canvas_coords.y;
	//vec4 canvas_depth_color = Texel(canvas_depth, canvas_coords);
	//int canvas_depth = int(canvas_depth_color.r * 255);
	
	vec4 depth_color = Texel(depthmap, texture_coords);
	//float depth = depth_color.r * 255 + depth_color.g * 65025.0 + depth_color.b * 160581375.0;
	int depth = int(depth_color.r * 255 * scale + color.r * 255 + z);
	//float depth = Texel(depthmap, texture_coords).r * scale + gl_FragCoord.z;
	
	vec4 diffuse = Texel(texture, texture_coords);

	//if(depth < canvas_depth)
	//{
	//	discard;
	//}
	//else
	//{
		vec4 normal = Texel(normalmap, texture_coords);
		//normal = normal * 2 - 1;
		//normal = normal * rotation;
		//normal = normal / 2 + 0.5;

		love_Canvases[0] = diffuse;
		love_Canvases[1] = vec4(normal.rgb, floor(diffuse.a));
		love_Canvases[2] = vec4(float(depth / 255.0), 0.0, 0.0, floor(diffuse.a));
	//}
}