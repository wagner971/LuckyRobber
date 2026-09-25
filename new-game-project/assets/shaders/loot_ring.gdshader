shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 accent : source_color = vec4(0.55, 1.0, 0.80, 1.0);
uniform float focus = 0.0;

void fragment() {
	float r = length(UV * 2.0 - 1.0);
	float ring = smoothstep(0.77, 0.82, r) * (1.0 - smoothstep(0.89, 0.94, r));
	float halo = (1.0 - smoothstep(0.15, 0.94, r)) * 0.10;
	ALBEDO = accent.rgb;
	ALPHA = ring * mix(0.48, 0.85, focus) + halo * focus;
}
