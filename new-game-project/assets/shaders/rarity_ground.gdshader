shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 accent : source_color = vec4(0.32, 0.73, 1.0, 1.0);
uniform float strength = 0.12;

void fragment() {
	float radius = length(UV * 2.0 - 1.0);
	float halo = 1.0 - smoothstep(0.18, 1.0, radius);
	ALBEDO = accent.rgb;
	ALPHA = halo * halo * strength;
}
