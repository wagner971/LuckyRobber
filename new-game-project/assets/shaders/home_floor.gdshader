shader_type spatial;

// Dark concrete tiles for the Home garage; lamps and neon do the colouring.
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 tile = abs(fract(world_position.xz / 0.85) - 0.5);
	vec2 edge = smoothstep(vec2(0.478), vec2(0.498), tile);
	float seam = max(edge.x, edge.y);
	float variation = sin(world_position.x * 5.1 + world_position.z * 1.7) * 0.012;
	ALBEDO = mix(vec3(0.17, 0.11, 0.22) + variation, vec3(0.05, 0.02, 0.08), seam * 0.7);
	ROUGHNESS = 0.42;
	METALLIC = 0.12;
	SPECULAR = 0.5;
}
