shader_type canvas_item;
uniform vec4 accent : source_color = vec4(0.36, 0.10, 0.53, 1.0);
uniform float celebration = 0.0;
void fragment() {
	vec2 p = UV - vec2(0.5, 0.39);
	float halo = exp(-dot(p * vec2(1.5, 1.0), p * vec2(1.5, 1.0)) * 9.0);
	vec3 base = mix(vec3(0.055, 0.021, 0.079), vec3(0.10, 0.035, 0.145), 1.0 - UV.y);
	base += accent.rgb * halo * 0.28;
	if (celebration > 0.0) {
		float rays = pow(max(0.0, cos(atan(p.y, p.x) * 12.0 + TIME * 0.12)), 10.0);
		base += accent.rgb * rays * halo * celebration * 0.035;
	}
	COLOR = vec4(base, 1.0);
}
