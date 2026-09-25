shader_type spatial;
render_mode unshaded;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	vec2 p = world_position.xz;
	float wave = sin(p.x * 1.65 + p.y * 0.7 + TIME * 0.65) * sin(p.y * 2.0 - TIME * 0.5);
	float glint = smoothstep(0.86, 1.0, wave) * 0.2;
	float coast = exp(-abs(p.x) * 0.12);
	ALBEDO = mix(vec3(0.018,0.10,0.17), vec3(0.025,0.25,0.30), coast) + vec3(0.11,0.31,0.32) * glint;
}
