shader_type canvas_item;
#include "res://assets/shaders/vivid_color.gdshaderinc"

void fragment() {
	vec4 scene = texture(TEXTURE, UV);
	COLOR = vec4(vivid_color(scene.rgb,1.65),scene.a);
}
