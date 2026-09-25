shader_type canvas_item;
#include "res://assets/shaders/vivid_color.gdshaderinc"

void fragment() {
	vec4 scene = texture(TEXTURE, UV);
	vec2 centered = (UV - vec2(0.5, 0.43)) * vec2(1.15, 0.80);
	float vignette = smoothstep(0.24, 0.78, length(centered));
	float footer = smoothstep(0.68, 0.95, UV.y);
	float header = 1.0 - smoothstep(0.0, 0.20, UV.y);
	vec3 vivid = vivid_color(scene.rgb,1.85);
	COLOR = vec4(vivid * (1.0 - vignette * 0.10 - footer * 0.20 - header * 0.04), scene.a);
}
