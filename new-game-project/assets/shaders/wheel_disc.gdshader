shader_type canvas_item;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	vec2 source_uv = vec2(0.500, 0.505) + (UV - 0.5) * 0.822;
	vec4 art = texture(TEXTURE, source_uv);
	art.a *= 1.0 - smoothstep(0.995, 1.0, length(p));
	COLOR = art;
}
