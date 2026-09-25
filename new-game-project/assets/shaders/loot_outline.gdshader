shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform vec4 accent : source_color = vec4(0.55, 1.0, 0.80, 1.0);
uniform float width = 3.5;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 normal_view = MODELVIEW_NORMAL_MATRIX * NORMAL;
	vec2 direction = (PROJECTION_MATRIX * vec4(normal_view, 0.0)).xy;
	// Pixel-sized silhouette: small loot stays readable as the camera pulls back.
	clip.xy += direction / max(length(direction), 0.001) * width * 2.0 / VIEWPORT_SIZE * clip.w;
	POSITION = clip;
}

void fragment() {
	ALBEDO = accent.rgb;
}
