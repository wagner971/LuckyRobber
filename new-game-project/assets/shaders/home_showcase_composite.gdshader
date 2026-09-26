shader_type canvas_item;
#include "res://assets/shaders/vivid_color.gdshaderinc"

// Home backdrop grading: punchy saturation, a little contrast, purple shadows
// and warm highlights, then a vignette that keeps the UI readable at the edges.
void fragment() {
	vec4 scene = texture(TEXTURE, UV);
	vec3 color = vivid_color(scene.rgb, 1.7);
	color = (color - vec3(0.5)) * 1.14 + vec3(0.5);
	float luma = dot(color, vec3(0.299, 0.587, 0.114));
	color += (1.0 - luma) * vec3(0.035, -0.012, 0.070) + luma * vec3(0.045, 0.018, -0.025);
	vec2 centered = (UV - vec2(0.5, 0.45)) * vec2(1.10, 0.78);
	float vignette = smoothstep(0.30, 0.85, length(centered));
	float footer = smoothstep(0.66, 0.97, UV.y);
	float header = 1.0 - smoothstep(0.0, 0.22, UV.y);
	color *= 1.0 - vignette * 0.22 - footer * 0.30 - header * 0.10;
	COLOR = vec4(clamp(color, vec3(0.0), vec3(1.0)), scene.a);
}
