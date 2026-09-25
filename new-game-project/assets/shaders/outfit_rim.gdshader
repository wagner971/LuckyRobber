shader_type canvas_item;
uniform vec4 rarity_color : source_color = vec4(0.33,1.0,0.03,1.0);
varying vec4 modulation;
void vertex() {
	modulation = COLOR;
}
void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float rim = 0.0;
	float halo = 0.0;
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.785398;
		vec2 direction = vec2(cos(a), sin(a)) * TEXTURE_PIXEL_SIZE;
		rim = max(rim, texture(TEXTURE, UV + direction * 2.5).a);
		halo += texture(TEXTURE, UV + direction * 9.0).a * 0.125;
	}
	float glow_alpha = max(rim * 0.95, halo * 0.40) * (1.0 - base.a);
	float alpha = base.a + glow_alpha;
	vec3 rgb = (base.rgb * base.a + rarity_color.rgb * glow_alpha) / max(alpha, 0.001);
	COLOR = vec4(rgb, alpha) * modulation;
}
