class_name ResultMoneyRain
extends Control

const BILL = preload("res://assets/ui/results/banknote.svg")
const COUNT := 22
var elapsed := 0.0
var particles: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	clip_contents = true
	var random := RandomNumberGenerator.new()
	random.seed = 93417
	for i in COUNT:
		particles.append({"x":random.randf_range(50,890),"y":random.randf_range(-150,1080),"speed":random.randf_range(110,200),"phase":random.randf_range(0,TAU),"size":random.randf_range(0.36,0.78),"turn":random.randf_range(-0.6,0.6)})

func particle_position(index: int, time: float) -> Vector2:
	var p: Dictionary = particles[index]
	return Vector2(float(p.x)+sin(time*1.1+float(p.phase))*44.0,fposmod(float(p.y)+time*float(p.speed)+160.0,1280.0)-160.0)

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	for i in particles.size():
		var p: Dictionary = particles[i]
		var at := particle_position(i,elapsed)
		var alpha := smoothstep(90.0,190.0,at.y)*(1.0-smoothstep(1030.0,1150.0,at.y))*0.72
		# The center stays readable behind the reward and amount.
		if at.x > 240 and at.x < 700: alpha *= 0.35
		var flip := 0.35+absf(cos(elapsed*1.8+float(p.phase)))*0.65
		draw_set_transform(at,float(p.phase)+elapsed*float(p.turn),Vector2(flip,1.0)*float(p.size))
		draw_texture_rect(BILL,Rect2(-56,-30,112,60),false,Color(1,1,1,alpha))
	draw_set_transform(Vector2.ZERO)
