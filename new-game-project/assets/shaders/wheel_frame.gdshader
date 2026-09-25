shader_type canvas_item;
void fragment() {
	vec4 art = texture(TEXTURE, UV);
	vec2 pixel = UV * vec2(941.0, 1672.0);
	float frame = smoothstep(414.0, 416.0, length(pixel - vec2(470.0, 756.0)));
	// Keep the supplied pointer above the disc; the source PNG stays intact.
	float pointer = step(407.0, pixel.x) * step(pixel.x, 535.0)
		* step(260.0, pixel.y) * step(pixel.y, 401.0)
		* smoothstep(0.06, 0.18, art.r - art.b);
	art.a *= max(frame, pointer);
	COLOR = art;
}
