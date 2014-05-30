uniform sampler2D canvas_depth;
uniform sampler2D depthmap;
uniform sampler2D normalmap;
uniform float z = 0.0;
uniform float scale = 1.0;
//extern mat3 rotation;



vec4 EncodeFloatRGBA( float v ) {
  vec4 enc = vec4(1.0, 255.0, 65025.0, 16581375.0) * v;
  enc = fract(enc);
  enc -= enc.yzww * vec4(1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0);
  return enc;
}
float DecodeFloatRGBA( vec4 rgba ) {
  return dot( rgba, vec4(1.0, 1/255.0, 1/65025.0, 1/16581375.0) );
}




void effects(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords)
{
	vec2 canvas_coords = screen_coords / love_ScreenSize.xy;
	canvas_coords.y = 1 - canvas_coords.y;
	float canvas_depth = DecodeFloatRGBA(Texel(canvas_depth, canvas_coords));
	
	vec4 depth_color = Texel(depthmap, texture_coords);
	//float depth = depth_color.r * 255.0 + depth_color.g * 65025.0 + depth_color.b * 160581375.0;
	float depth = DecodeFloatRGBA(depth_color);
	depth =  depth * scale + color.r + z;
	//float depth = Texel(depthmap, texture_coords).r * scale + gl_FragCoord.z;

	if(canvas_depth < depth)
	{
		vec4 diffuse = Texel(texture, texture_coords);
		vec4 normal = Texel(normalmap, texture_coords);
		//normal = normal * 2 - 1;
		//normal = normal * rotation;
		//normal = normal / 2 + 0.5;

		love_Canvases[0] = diffuse;
		love_Canvases[1] = vec4(normal.rgb, diffuse.a);
		love_Canvases[2] = EncodeFloatRGBA(depth);
	}
	else
	{
		discard;
	}
}