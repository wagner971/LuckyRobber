shader_type canvas_item;

void fragment() {
	vec2 small_grid = UV * vec2(34.0, 62.0);
	vec2 small_edge = min(fract(small_grid), 1.0 - fract(small_grid));
	float small_line = 1.0 - smoothstep(0.0, 0.035, min(small_edge.x, small_edge.y));
	vec2 big_grid = UV * vec2(6.0, 11.0);
	vec2 big_edge = min(fract(big_grid), 1.0 - fract(big_grid));
	float big_line = 1.0 - smoothstep(0.0, 0.015, min(big_edge.x, big_edge.y));
	COLOR = vec4(0.83, 0.65, 0.96, small_line * 0.045 + big_line * 0.06);
}
