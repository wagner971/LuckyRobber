shader_type canvas_item;
uniform vec4 top_color : source_color = vec4(1.0,0.94,0.32,1.0);
uniform vec4 bottom_color : source_color = vec4(1.0,0.65,0.0,1.0);
uniform vec2 bounds = vec2(800.0,160.0);
void fragment() {
 vec2 p = UV * bounds;
 float radius = 32.0;
 vec2 q = abs(p - bounds * 0.5) - (bounds * 0.5 - vec2(radius));
 float d = length(max(q,vec2(0.0))) + min(max(q.x,q.y),0.0) - radius;
 vec3 c = mix(top_color.rgb,bottom_color.rgb,UV.y);
 c += vec3(0.15) * pow(1.0 - UV.y,5.0);
 c = mix(c,vec3(1.0,1.0,0.9),0.7 * (1.0-smoothstep(1.0,3.0,abs(d+3.0))));
 c *= 1.0 - 0.22 * smoothstep(0.93,0.99,UV.y);
 COLOR = vec4(c,1.0-smoothstep(-1.0,1.0,d));
}
