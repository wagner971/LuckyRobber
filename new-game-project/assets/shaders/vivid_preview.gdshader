shader_type canvas_item;
#include "res://assets/shaders/vivid_color.gdshaderinc"
uniform float strength = 1.65;
void fragment() {
 vec4 scene = texture(TEXTURE,UV);
 COLOR = vec4(vivid_color(scene.rgb,strength),scene.a);
}
