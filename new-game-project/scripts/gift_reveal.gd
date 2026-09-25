class_name GiftReveal
extends Control

signal collected
signal cue(kind: String)
const EFFECT_COLORS := [Color("60ff08"),Color("009dff"),Color("b020ff"),Color("ffcc00")]
var outfit_rim: ShaderMaterial
var daily := false
var prize: Dictionary = {}
var elapsed := 0.0
var suspended := false
var accumulator := 0.0
var opened := false
var revealed := false
var rarity := 2
var font: Font
var viewport: SubViewport
var picture: TextureRect
var gift: Node3D
var lid: Node3D
var actor: ThiefVisual
var camera: Camera3D
var claim: Button
var question: Label
var confetti: Control
var card := Rect2()
var insets := Vector4.ZERO
var cash_icon := preload("res://assets/hud/cash.png")

func configure(is_daily: bool, reward: Dictionary, display_font: Font, safe: Vector4) -> void:
	daily = is_daily
	prize = reward
	rarity = clampi(int(reward.get("rarity",2)),0,3)
	font = display_font
	insets = safe

func _ready() -> void:
	name = "GiftReveal"
	add_to_group("menu_character_previews")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.size = Vector2i(560,640)
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	picture = TextureRect.new()
	picture.texture = viewport.get_texture()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outfit_rim = ShaderMaterial.new()
	outfit_rim.shader = preload("res://assets/shaders/outfit_rim.gdshader")
	add_child(picture)
	question = Label.new()
	question.text = "?"
	question.add_theme_font_override("font",font)
	question.add_theme_color_override("font_color",Color.WHITE)
	question.add_theme_color_override("font_outline_color",Color("16123b"))
	question.add_theme_constant_override("outline_size",12)
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(question)
	confetti = Control.new()
	confetti.mouse_filter = Control.MOUSE_FILTER_IGNORE
	confetti.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(confetti)
	confetti.draw.connect(func():
		var t := elapsed-4.05
		if daily or not revealed or t < 0 or t > 1.15: return
		for i in range(18):
			var angle := i*2.4
			var at := card.get_center()+Vector2(sin(angle)*(160+i*6)*t,-220*t+270*t*t+cos(angle)*130*t)
			confetti.draw_set_transform(at,angle+t*3)
			confetti.draw_rect(Rect2(Vector2.ZERO,Vector2(9,16)),Color(EFFECT_COLORS[rarity],1-t/1.15))
		confetti.draw_set_transform(Vector2.ZERO)
	)
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color.TRANSPARENT
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b7bee6")
	environment.ambient_light_energy = 0.65
	world.environment = environment
	viewport.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35,-32,0)
	light.light_color = Color("fff0cc")
	light.light_energy = 1.15
	viewport.add_child(light)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.15
	viewport.add_child(camera)
	camera.position = Vector3(2.7,2.0,5)
	camera.look_at(Vector3(0,0.85,0))
	gift = Node3D.new()
	viewport.add_child(gift)
	var paint := Color("19bbed") if daily else Color("8b37e7")
	var gold := Color("ffcf4d")
	# Hollow cubic body: the separate lid exposes the bright interior.
	Models.box(gift,Vector3(1.44,0.13,1.44),Vector3(0,0.07,0),paint)
	for side in [-1.0,1.0]:
		Models.box(gift,Vector3(1.44,1.13,0.11),Vector3(0,0.64,side*0.67),paint)
		Models.box(gift,Vector3(0.11,1.13,1.3),Vector3(side*0.67,0.64,0),paint)
		Models.box(gift,Vector3(0.24,1.17,0.025),Vector3(0,0.64,side*0.735),gold)
		Models.box(gift,Vector3(0.025,1.17,0.24),Vector3(side*0.735,0.64,0),gold)
	Models.box(gift,Vector3(1.2,0.04,1.2),Vector3(0,0.16,0),Color("ffeac0"))
	lid = Node3D.new()
	gift.add_child(lid)
	lid.position.y = 1.27
	Models.box(lid,Vector3(1.59,0.23,1.59),Vector3.ZERO,paint.lightened(0.14))
	Models.box(lid,Vector3(0.25,0.025,1.63),Vector3(0,0.13,0),gold)
	Models.box(lid,Vector3(1.63,0.025,0.25),Vector3(0,0.13,0),gold)
	for side in [-1.0,1.0]:
		var bow := Models.box(lid,Vector3(0.48,0.22,0.27),Vector3(side*0.27,0.30,0),gold)
		bow.rotation.z = side*0.4
	Models.box(lid,Vector3(0.24,0.27,0.30),Vector3(0,0.28,0),gold)
	for mesh in gift.find_children("*","MeshInstance3D",true,false):
		mesh.material_override.roughness = 0.25
		mesh.material_override.metallic_specular = 0.65
	actor = Models.thief()
	viewport.add_child(actor)
	actor.visible = false
	claim = Button.new()
	claim.text = "CLAIM" if daily else "CONTINUE"
	claim.add_theme_font_override("font",font)
	claim.add_theme_font_size_override("font_size",30)
	claim.add_theme_color_override("font_color",Color("082b36"))
	claim.add_theme_stylebox_override("normal",plate(Color("4aefbc"),Color("b2ffe7"),20,3))
	claim.add_theme_stylebox_override("hover",plate(Color("78f5cc"),Color.WHITE,20,3))
	claim.add_theme_stylebox_override("pressed",plate(Color("26bf92"),Color("b2ffe7"),20,3))
	claim.pressed.connect(func():
		claim.disabled = true
		collected.emit()
	)
	claim.visible = false
	add_child(claim)
	resized.connect(layout)
	layout()
	update_visual()

func plate(fill: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	return style

func layout() -> void:
	var usable := size-Vector2(insets.x+insets.z,insets.y+insets.w)
	var h := minf(usable.y-128,1080)
	var w := minf(usable.x-40,h*0.69)
	card = Rect2(Vector2(insets.x+(usable.x-w)/2,insets.y+(usable.y-h-88)/2),Vector2(w,h))
	claim.position = Vector2(card.position.x,card.end.y+20)
	claim.size = Vector2(w,90)
	question.position = card.position+Vector2(0,card.size.y*0.38)
	question.size = Vector2(w,card.size.y*0.23)
	question.add_theme_font_size_override("font_size",int(w*0.30))
	queue_redraw()

func _process(delta: float) -> void:
	if suspended: return
	accumulator += delta
	if accumulator < 1.0/30: return
	elapsed += accumulator
	accumulator = 0
	update_visual()

func update_visual() -> void:
	if elapsed >= 0.7 and not opened:
		opened = true
		cue.emit("pickup")
	var end_time := 1.8 if daily else 4.05
	if elapsed >= end_time and not revealed:
		revealed = true
		claim.visible = true
		cue.emit("cash_collect" if daily else "special_reveal")
	gift.visible = elapsed < 1.05
	actor.visible = elapsed >= 1.05 and not daily
	question.visible = actor.visible and not revealed
	var spawn := clampf(elapsed/0.25,0,1)
	var pulse := 0.7+0.3*sin(spawn*PI/2)+0.07*sin(spawn*PI)
	gift.scale = Vector3.ONE*pulse
	if elapsed > 0.25 and elapsed < 0.7:
		gift.rotation.z = sin(elapsed*65)*0.045
		gift.position.y = absf(sin(elapsed*20))*0.045
		gift.scale *= Vector3(1.0+sin(elapsed*35)*0.03,1.0-sin(elapsed*35)*0.045,1)
	if elapsed >= 0.7:
		var t := clampf((elapsed-0.7)/0.35,0,1)
		if elapsed < 1.05:
			camera.size = 3.15+t*0.5
			camera.look_at(Vector3(0,0.85+t*0.35,0))
		lid.position = Vector3(-t*0.38,1.27+sin(t*PI/2)*1.1,0)
		lid.rotation.z = -t*0.28
		gift.rotation.z = 0
	if actor.visible:
		picture.material = outfit_rim
		outfit_rim.set_shader_parameter("rarity_color",EFFECT_COLORS[rarity if revealed else int(elapsed/0.105)%4])
		camera.size = 2.65
		camera.look_at(Vector3(0,1.0,0))
		actor.animate(1.0/30,0)
		actor.rotation.y = -0.1+sin(elapsed*1.5)*0.08
		actor.scale = Vector3.ONE*(1.03 if not revealed else 1.24)
		picture.modulate = Color("33334f") if not revealed else Color.WHITE
		picture.position = card.position+Vector2(card.size.x*0.07,card.size.y*0.18)
		picture.size = Vector2(card.size.x*0.86,card.size.y*0.60)
	else:
		picture.material = null
		picture.modulate = Color.WHITE
		picture.position = card.position+Vector2(0,card.size.y*0.15)
		picture.size = Vector2(card.size.x,card.size.y*0.64)
	picture.pivot_offset = picture.size/2
	picture.scale = Vector2.ONE*(0.93+0.07*clampf((elapsed-1.05)/0.22,0,1)) if actor.visible else Vector2.ONE
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	confetti.queue_redraw()
	queue_redraw()

func caption(value: String, center: Vector2, pixels: int, color: Color) -> void:
	var at := center-Vector2(font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x/2,0)
	var outline: Color = Color("100b35") if daily else LevelGifts.COLORS[rarity if revealed else int(elapsed/0.105)%4].darkened(0.94)
	draw_string_outline(font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,7,outline)
	draw_string(font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,color)

func star(at: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(8):
		var angle := i*PI/4
		points.append(at+Vector2(sin(angle),cos(angle))*radius*(1.0 if i%2==0 else 0.26))
	for i in range(5,0,-1): draw_circle(at,radius*(0.55+i*0.18),Color(color,0.025))
	draw_colored_polygon(points,color)

func _draw() -> void:
	if font == null: return
	draw_rect(Rect2(Vector2.ZERO,size),Color("060d20f7"))
	var center := card.get_center()
	var tint: Color = Color("3fdcff") if daily else LevelGifts.COLORS[rarity if revealed else int(elapsed/0.105)%4]
	var phase := clampf((elapsed-1.05)/0.24,0,1)
	if elapsed < 1.05:
		caption("DAILY GIFT" if daily else "LEVEL COMPLETE GIFT",Vector2(center.x,card.position.y+card.size.y*0.13),int(card.size.x*0.066),Color.WHITE)
		for i in range(6): draw_circle(center,card.size.x*(0.26+i*0.025),Color(tint,0.018))
		draw_ellipse_shadow(center+Vector2(0,card.size.y*0.28),card.size.x*0.27)
		if elapsed > 0.45:
			for i in range(3): star(center+Vector2(sin(i*2.2+elapsed)*card.size.x*0.34,cos(i*2.2)*card.size.y*0.19),9,Color("ffe89a"))
		if elapsed >= 0.7:
			var flash := 1.0-clampf((elapsed-0.7)/0.35,0,1)
			for i in range(8): draw_circle(center,card.size.x*(0.1+i*0.025),Color("ffe6a6",flash*0.02))
		return
	var panel := Rect2(card.position+card.size*Vector2(0.12,0.27)*(1-phase),card.size*(0.76+0.24*phase))
	for i in range(6,0,-1): draw_style_box(plate(Color(tint,0.012),Color(tint,0.055),32+i*2,4),panel.grow(i*3))
	draw_style_box(plate(Color("14113e") if daily else tint.darkened(0.82),tint,30,8),panel)
	draw_style_box(plate(Color.TRANSPARENT,tint.lightened(0.35),24,3),panel.grow(-9))
	# Saturated rarity light concentrates around the live character, behind its silhouette.
	var effect: Color = tint if daily else EFFECT_COLORS[rarity if revealed else int(elapsed/0.105)%4]
	var ray_center := panel.position+panel.size*Vector2(0.5,0.47)
	for i in range(64):
		var a := i*TAU/64
		var b := (i+1)*TAU/64
		var reach := panel.size*Vector2(0.43,0.32)
		draw_polygon(PackedVector2Array([ray_center,ray_center+Vector2(sin(a),cos(a))*reach,ray_center+Vector2(sin(b),cos(b))*reach]),PackedColorArray([Color(effect,0.88 if not daily else 0.12),Color(effect,0),Color(effect,0)]))
	for i in range(12):
		var angle := i*TAU/12+elapsed*0.035
		var reach := panel.size*Vector2(0.46,0.32)
		var a := ray_center+Vector2(sin(angle),cos(angle))*reach
		var b := ray_center+Vector2(sin(angle+0.22),cos(angle+0.22))*reach
		draw_polygon(PackedVector2Array([ray_center,a,b]),PackedColorArray([Color(effect,0.95 if not daily else 0.075),Color(effect,0.06),Color(effect,0.06)]))
	for i in range(7):
		var x := (0.22 if i%2==0 else 0.76)+sin(elapsed*0.8+i)*0.025
		var y := 0.30+fposmod(i*0.113-elapsed*0.023,0.44)
		var point := panel.position+panel.size*Vector2(x,y)
		var width := panel.size.x*(0.014+i%3*0.005)
		draw_rect(Rect2(point-Vector2.ONE*width*0.45,Vector2.ONE*width*1.9),Color(effect,0.12))
		draw_rect(Rect2(point,Vector2.ONE*width),effect)
	for i in range(3):
		var at := panel.position+panel.size*Vector2(0.23 if i%2==0 else 0.77,0.34+i*0.17)+Vector2(sin(elapsed*1.4+i)*6,cos(elapsed*1.8+i)*9)
		star(at,panel.size.x*0.036,effect)
		star(at,panel.size.x*0.014,effect.lightened(0.60))
	var header := Rect2(panel.position+panel.size*Vector2(0.24,0.035),panel.size*Vector2(0.52,0.095))
	draw_style_box(plate(Color("21164d") if daily else tint.darkened(0.80),tint.lightened(0.2),22,4),header)
	caption("DAILY GIFT" if daily else "OUTFIT",Vector2(center.x,header.get_center().y+card.size.x*0.023),int(card.size.x*0.073),tint.lightened(0.5))
	if daily:
		draw_texture_rect(cash_icon,Rect2(panel.position+panel.size*Vector2(0.26,0.28),Vector2.ONE*panel.size.x*0.48),false)
		caption("+$%d" % int(prize.get("cash",300)),Vector2(center.x,panel.position.y+panel.size.y*0.70),int(card.size.x*0.15),Color("66f7b5"))
		caption("+%d DIAMONDS" % int(prize.get("diamonds",1)),Vector2(center.x,panel.position.y+panel.size.y*0.80),int(card.size.x*0.058),Color("98e9ff"))
	else:
		# Question mark is on a separate foreground label so the 3D silhouette sits behind it.
		caption("PROTOTYPE" if revealed else "MYSTERY OUTFIT",Vector2(center.x,panel.position.y+panel.size.y*0.83),int(card.size.x*(0.113 if revealed else 0.078)),Color.WHITE)
		var badge := Rect2(panel.position+panel.size*Vector2(0.24,0.865),panel.size*Vector2(0.52,0.077))
		draw_style_box(plate(tint.darkened(0.85),tint,24,4),badge)
		caption(LevelGifts.RARITIES[rarity] if revealed else "REVEALING...",Vector2(center.x,panel.position.y+panel.size.y*0.92),int(card.size.x*0.063),tint)
		if revealed: caption("PREVIEW ONLY · SKINS COMING LATER",Vector2(center.x,panel.position.y+panel.size.y*0.966),int(card.size.x*0.032),tint.lightened(0.65))

func draw_ellipse_shadow(at: Vector2, width: float) -> void:
	draw_set_transform(at,0,Vector2(1,0.23))
	draw_circle(Vector2.ZERO,width,Color("020714b0"))
	draw_set_transform(Vector2.ZERO)

func suspend(value: bool) -> void:
	suspended = value
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED if value else SubViewport.UPDATE_ONCE

func stop() -> void:
	suspend(true)
	set_process(false)
