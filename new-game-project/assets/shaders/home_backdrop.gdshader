shader_type canvas_item;

void fragment() {
	vec2 step_uv = TEXTURE_PIXEL_SIZE * 2.0;
	vec4 center = texture(TEXTURE, UV) * 0.52;
	vec4 soft = texture(TEXTURE, UV + vec2(step_uv.x, 0.0)) * 0.12;
	soft += texture(TEXTURE, UV - vec2(step_uv.x, 0.0)) * 0.12;
	soft += texture(TEXTURE, UV + vec2(0.0, step_uv.y)) * 0.12;
	soft += texture(TEXTURE, UV - vec2(0.0, step_uv.y)) * 0.12;
	vec4 backdrop = center + soft;
	backdrop.rgb *= vec3(0.80, 0.84, 0.92);
	COLOR = backdrop;
}
