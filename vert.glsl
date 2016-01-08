varying vec4 vpos;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	vpos = transform_projection * vertex_position;
	vpos.z = 1 - VaryingColor.r;
	vpos.x = vpos.x / (vpos.z - vpos.y);
	vpos.y = vpos.y / ((-vpos.z * -1) - vpos.y);
	//VaryingColor = vec4(255, 255, 255, 255)
	return vpos;
}