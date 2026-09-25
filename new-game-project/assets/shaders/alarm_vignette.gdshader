shader_type canvas_item;
render_mode unshaded;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec2 canvas_size = vec2(720.0, 1280.0);

void fragment() {
	// Static instrument-frame corners, not a full-screen damage vignette.
	// Canvas units keep stroke thickness consistent on tall/wide displays.
	vec2 p = min(UV, vec2(1.0) - UV) * canvas_size;
	float vertical = (1.0 - smoothstep(1.0, 2.0, abs(p.x - 7.0)))
		* (1.0 - smoothstep(44.0, 64.0, p.y)) * smoothstep(5.0, 7.0, p.y);
	float horizontal = (1.0 - smoothstep(1.0, 2.0, abs(p.y - 7.0)))
		* (1.0 - smoothstep(44.0, 64.0, p.x)) * smoothstep(5.0, 7.0, p.x);
	float corner_light = (1.0 - smoothstep(0.0, 24.0, min(p.x, p.y)))
		* (1.0 - smoothstep(28.0, 110.0, max(p.x, p.y)));
	float alpha = max(vertical, horizontal) * 0.48 + corner_light * 0.055;
	COLOR = vec4(1.0, 0.68, 0.30, alpha * intensity);
}
