// Saturation in max-channel space keeps highlights bounded and neutrals neutral.
vec3 vivid_color(vec3 input_color, float strength) {
 vec3 c = clamp(input_color,vec3(0.0),vec3(1.0));
 float peak = max(c.r,max(c.g,c.b));
 float low = min(c.r,min(c.g,c.b));
 float saturation = clamp((peak-low)/max(peak,0.0001),0.0,1.0);
 float protection = smoothstep(0.06,0.22,saturation);
 float boosted = 1.0-pow(max(0.0001,1.0-saturation),strength);
 float ratio = mix(1.0,boosted/max(saturation,0.0001),protection);
 c = mix(vec3(peak),c,ratio);
 return clamp(c,vec3(0.0),vec3(1.0));
}
