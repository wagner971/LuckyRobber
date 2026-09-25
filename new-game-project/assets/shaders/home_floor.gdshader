shader_type spatial;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 tile = abs(fract(world_position.xz / 0.85) - 0.5);
	vec2 edge = smoothstep(vec2(0.482), vec2(0.498), tile);
	float seam = max(edge.x, edge.y);
	float variation = sin(world_position.x * 5.1 + world_position.z * 1.7) * 0.015;
	ALBEDO = mix(vec3(0.20, 0.025, 0.31) + variation, vec3(0.06, 0.008, 0.10), seam * 0.65);
	ROUGHNESS = 0.36;
	METALLIC = 0.18;
	SPECULAR = 0.55;
}
