shader_type canvas_item;
uniform vec4 tint : source_color = vec4(0.02,1.0,0.52,1.0);
uniform float rotation_speed = 0.10;
uniform float beam_strength = 0.28;
void fragment() {
 vec2 p = UV - vec2(0.5);
 float radius = length(p);
 float a = atan(p.y,p.x) + TIME * rotation_speed;
 float beam = pow(max(0.0,cos(a*11.0)),12.0);
 float halo = exp(-radius*radius*17.0);
 float fade = 1.0-smoothstep(0.26,0.5,radius);
 float breath = 0.85+0.15*sin(TIME*2.0);
 COLOR = vec4(tint.rgb, (beam*beam_strength+halo*0.23)*fade*breath);
}
