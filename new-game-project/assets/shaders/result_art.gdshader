shader_type canvas_item;
void fragment() {
 vec4 art = texture(TEXTURE,UV);
 vec2 edge = min(UV,vec2(1.0)-UV);
 art.a *= smoothstep(0.0,0.025,edge.x)*smoothstep(0.0,0.018,edge.y);
 COLOR = art;
}
