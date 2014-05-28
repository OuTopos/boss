varying vec4 vpos;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    vpos = transform_projection * vertex_position;
  // vpos.x = vpos.x * 0.9 * vpos.y;
   vpos.z = VaryingColor.r;
   //VaryingColor = vec4(255, 255, 255, 255)
    return vpos;
}