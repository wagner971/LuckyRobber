shader_type canvas_item;

uniform vec4 accent_color : source_color = vec4(0.42, 0.9, 0.78, 1.0);
uniform float locked = 0.0;

void fragment() {
	vec2 hero_uv = (UV - vec2(0.5)) * 0.94 + vec2(0.5);
	vec4 texel = texture(TEXTURE, hero_uv);
	vec3 color = (texel.rgb - vec3(0.5)) * 1.09 + vec3(0.5);
	float light = 1.0 - smoothstep(0.28, 0.78, distance(UV, vec2(0.50, 0.43))) * 0.13;
	color *= light;
	float bottom = smoothstep(0.69, 1.0, UV.y);
	color *= 1.0 - bottom * 0.44;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(gray), locked * 0.78);
	color *= 1.0 - locked * 0.42;
	vec2 box = abs(UV - vec2(0.5)) - vec2(0.466);
	float rounded_distance = length(max(box, vec2(0.0))) + min(max(box.x, box.y), 0.0) - 0.034;
	float rounded_alpha = 1.0 - smoothstep(-0.003, 0.003, rounded_distance);
	COLOR = vec4(color, texel.a * rounded_alpha);
}
