shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back, shadows_disabled;

uniform vec4 accent : source_color = vec4(0.32, 0.73, 1.0, 1.0);
uniform mat4 world_to_loot;
uniform vec2 sweep_bounds = vec2(-0.5, 2.5);
uniform float sweep_position = 0.0;
uniform float sweep_visible = 0.0;
uniform float rim_gain = 0.11;
uniform float sweep_gain = 0.14;
uniform float proximity = 0.0;
uniform float active = 1.0;
varying vec3 loot_position;

void vertex() {
	// One diagonal band across the whole prop, including its separate block meshes.
	loot_position = (world_to_loot * MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float edge = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 3.4);
	float span = max(0.2, sweep_bounds.y - sweep_bounds.x);
	float coordinate = loot_position.y + loot_position.x * 0.45;
	float center = mix(sweep_bounds.x, sweep_bounds.y, sweep_position);
	float band = 1.0 - smoothstep(span * 0.008, span * 0.038, abs(coordinate - center));
	float rim = edge * rim_gain * (1.0 + proximity * 0.65);
	ALBEDO = mix(accent.rgb, vec3(1.0), band * sweep_visible * 0.30);
	ALPHA = clamp((rim + band * sweep_visible * sweep_gain) * active, 0.0, 0.42);
}
