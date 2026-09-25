shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 beam_color : source_color = vec4(0.72, 0.2, 1.0, 1.0);
uniform float strength = 0.13;
uniform bool downward = false;

void fragment() {
	float height = downward ? UV.y : 1.0 - UV.y;
	float fade = pow(1.0 - height, 1.65) * smoothstep(0.0, 0.06, height);
	float filaments = 0.72 + 0.28 * pow(abs(sin(UV.x * 18.8496 + TIME * 0.10)), 6.0);
	ALBEDO = beam_color.rgb;
	ALPHA = strength * fade * filaments;
}
