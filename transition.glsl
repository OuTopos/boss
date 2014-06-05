uniform sampler2D pre_canvas;
uniform sampler2D mask;
uniform float time = 1.0;
uniform float feather = 0.0;


vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords)
{
	if(time < 1.0)
	{
		vec4 mask_color = Texel(mask, texture_coords);
		if(time >= mask_color.g)
		{
			return mix(Texel(texture, texture_coords), Texel(pre_canvas, texture_coords), 0);
		}
		else
		{
			return Texel(pre_canvas, texture_coords);
		}
	}
	else
	{
		return Texel(texture, texture_coords);
	}
}