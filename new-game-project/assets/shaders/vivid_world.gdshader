shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
#include "res://assets/shaders/vivid_color.gdshaderinc"
void fragment() {
 // One screen sample, before HUD and alarms. No blur or per-object passes.
 vec3 scene = texture(screen_texture,SCREEN_UV).rgb;
 COLOR = vec4(vivid_color(scene,1.65),1.0);
}
