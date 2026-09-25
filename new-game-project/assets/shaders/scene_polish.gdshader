shader_type canvas_item;
render_mode unshaded;

// A single transparent pass over the 3D scene. No screen read, blur, or
// per-object material work: it remains inexpensive on Compatibility/mobile.
uniform vec3 edge_color : source_color = vec3(0.025, 0.073, 0.13);
uniform vec3 beam_color : source_color = vec3(0.95, 0.72, 0.43);
uniform vec2 beam_origin = vec2(0.12, -0.10);
uniform float beam_slope = 0.34;
uniform float edge_strength : hint_range(0.0, 0.3) = 0.18;
uniform float beam_strength : hint_range(0.0, 0.15) = 0.09;

void fragment() {
	vec2 uv = UV;
	float radius = length((uv - vec2(0.5, 0.46)) * vec2(1.22, 1.0));
	float edge = smoothstep(0.36, 0.73, radius) * edge_strength;

	float depth = smoothstep(0.0, 0.12, uv.y) * (1.0 - smoothstep(0.48, 0.90, uv.y));
	float diagonal = uv.x - beam_origin.x - uv.y * beam_slope;
	float wide = 1.0 - smoothstep(0.05, 0.25, abs(diagonal));
	float narrow = 1.0 - smoothstep(0.025, 0.10, abs(diagonal - 0.27));
	float beam = (wide * 0.70 + narrow * 0.30) * depth * beam_strength;

	float alpha = min(edge + beam, 0.32);
	vec3 tint = (edge_color * edge + beam_color * beam) / max(alpha, 0.0001);
	COLOR = vec4(tint, alpha);
}
