shader_type canvas_item;

// Cover-crops the preview inside the control and rounds its corners, so the
// hero card reads like a framed 3D render rather than a stretched rectangle.
uniform vec2 cover_scale = vec2(1.0, 1.0);
uniform vec2 rect_size = vec2(684.0, 320.0);
uniform float radius = 26.0;
uniform float locked = 0.0;

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * cover_scale + vec2(0.5);
	vec4 texel = texture(TEXTURE, uv);
	vec3 color = (texel.rgb - vec3(0.5)) * 1.06 + vec3(0.5);
	float bottom = smoothstep(0.58, 1.0, UV.y);
	color *= 1.0 - bottom * 0.5;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(gray), locked * 0.78);
	color *= 1.0 - locked * 0.42;
	vec2 p = UV * rect_size;
	vec2 half_size = rect_size * 0.5;
	vec2 q = abs(p - half_size) - (half_size - vec2(radius));
	float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
	float alpha = 1.0 - smoothstep(-1.0, 1.0, d);
	COLOR = vec4(color, texel.a * alpha);
}
