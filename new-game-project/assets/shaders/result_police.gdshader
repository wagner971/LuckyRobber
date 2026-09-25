shader_type canvas_item;
void fragment() {
 // Soft alternating reflections confined to the sides; the center stays clean.
 float phase = 0.5 + 0.5*sin(TIME*1.7);
 float vertical = exp(-pow((UV.y-0.48)*2.1,2.0));
 float left = pow(1.0-UV.x,6.0)*phase;
 float right = pow(UV.x,6.0)*(1.0-phase);
 vec3 tint = mix(vec3(0.09,0.35,1.0),vec3(1.0,0.09,0.13),left/max(left+right,0.0001));
 vec2 edge = min(UV,vec2(1.0)-UV);
 float fade = smoothstep(0.0,0.025,edge.x)*smoothstep(0.0,0.018,edge.y);
 COLOR = vec4(tint,(left+right)*vertical*0.22*fade);
}
