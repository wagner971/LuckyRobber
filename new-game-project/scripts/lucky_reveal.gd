class_name LuckyReveal
extends GiftReveal

const PURPLE_FRAME := preload("res://assets/ui/reward_cards/purple-lucky-frame.png")
const RED_FRAME := preload("res://assets/ui/reward_cards/unlucky-frame.png")
const PURPLE_CUBE := preload("res://assets/ui/reward_cards/purple-lucky-cube.png")
const CRACKED_CUBE := preload("res://assets/ui/reward_cards/purple-unlucky-cube.png")
var effect_id := ""
var description: Label
var block_model: Node3D
var button_fill: ColorRect

func _ready() -> void:
	effect_id = str(prize.lucky)
	super._ready()
	name = "LuckyReveal"
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	for child in gift.get_children():
		if child != lid: child.free()
	for child in lid.get_children(): child.free()
	block_model = LuckyEffects.model()
	gift.add_child(block_model)
	block_model.scale = Vector3.ONE*1.65
	description = Label.new()
	description.add_theme_font_override("font",font)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	description.text = LuckyEffects.CATALOG[effect_id][1]
	add_child(description)
	claim.text = "NEXT RUN · GOT IT"
	for state in ["normal","hover","pressed","disabled"]:
		claim.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	for state in ["font_color","font_hover_color","font_pressed_color"]:
		claim.add_theme_color_override(state,Color("003e19"))
	button_fill = ColorRect.new()
	button_fill.show_behind_parent = true
	button_fill.mouse_filter = MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/result_button.gdshader")
	mat.set_shader_parameter("top_color",Color("56ff42"))
	mat.set_shader_parameter("bottom_color",Color("00e42c"))
	button_fill.material = mat
	claim.add_child(button_fill)
	UiJuice.button_touch(claim)
	layout()
	update_visual()

func layout() -> void:
	if claim == null: return
	var usable := size-Vector2(insets.x+insets.z,insets.y+insets.w)
	var w := minf(usable.x-16,(usable.y-16)*9.0/16.0)
	var h := w*16.0/9.0
	card = Rect2(Vector2(insets.x+(usable.x-w)/2,insets.y+(usable.y-h)/2),Vector2(w,h))
	claim.position = card.position+card.size*Vector2(0.075,0.856)
	claim.size = card.size*Vector2(0.85,0.096)
	claim.add_theme_font_size_override("font_size",int(w*0.059))
	if button_fill != null:
		button_fill.size = claim.size
		button_fill.material.set_shader_parameter("bounds",claim.size)
	queue_redraw()

func update_visual() -> void:
	if gift == null: return
	if elapsed >= 0.85 and not opened:
		opened = true
		cue.emit("pickup")
	if elapsed >= 1.75 and not revealed:
		revealed = true
		cue.emit("special_reveal")
	claim.visible = elapsed >= 2.1
	actor.hide()
	question.hide()
	confetti.hide()
	gift.visible = elapsed < 1.25
	var growth := 0.7+0.3*sin(clampf(elapsed/0.25,0,1)*PI/2)
	var burst := clampf((elapsed-0.85)/0.4,0,1)
	gift.scale = Vector3.ONE*growth*(1+burst*0.4)
	gift.rotation = Vector3(0,elapsed*0.35,sin(elapsed*50)*0.035*(1-burst))
	picture.modulate = Color(1,1,1,1-burst)
	picture.position = card.position+card.size*Vector2(0.1,0.20)
	picture.size = card.size*Vector2(0.8,0.38)
	if description != null:
		description.visible = revealed
		description.position = card.position+card.size*Vector2(0.10,0.685)
		var pixels := int(card.size.x*0.052)
		while font.get_multiline_string_size(description.text,HORIZONTAL_ALIGNMENT_LEFT,card.size.x*0.80,pixels).y > card.size.y*0.092 and pixels > 12:
			pixels -= 1
		description.add_theme_font_size_override("font_size",pixels)
		description.size = card.size*Vector2(0.80,0.10)
		description.add_theme_color_override("font_color",Color("fff2ff") if LuckyEffects.positive(effect_id) else Color("fff3e7"))
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if gift.visible else SubViewport.UPDATE_DISABLED
	queue_redraw()

func lettering(value: String, baseline: Vector2, pixels: int, color: Color, _edge: Color) -> void:
	var at := baseline-Vector2(font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x/2,0)
	draw_string(font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,color)

func _draw() -> void:
	if font == null or effect_id == "": return
	var good := LuckyEffects.positive(effect_id)
	draw_rect(Rect2(Vector2.ZERO,size),Color("060b13f7"))
	draw_texture_rect(PURPLE_FRAME if good else RED_FRAME,card,false)
	var w := card.size.x
	var h := card.size.y
	var center := card.position+card.size*Vector2(0.5,0.39)
	var glow := Color("cf7aff") if good else Color("ffb124")
	lettering("LUCKY BLOCK",Vector2(card.get_center().x,card.position.y+h*0.118),int(w*0.105),Color("f6e7ff") if good else Color("ffd7c4"),Color.BLACK)
	lettering("ONE HEIST. ONE TWIST.",Vector2(card.get_center().x,card.position.y+h*0.160),int(w*0.040),Color("e2c4ff") if good else Color("ffc4ad"),Color.BLACK)
	# Bounded animated rays and a separate hero; effect text remains live.
	for i in range(14):
		var angle := i*TAU/14+elapsed*0.045
		var radius := w*(0.43+sin(i*1.8)*0.025)
		draw_polygon(PackedVector2Array([center,center+Vector2(cos(angle),sin(angle))*radius,center+Vector2(cos(angle+0.17),sin(angle+0.17))*radius]),PackedColorArray([Color(glow,0.70 if good else 0.86),Color(glow,0),Color(glow,0)]))
	for i in range(7,0,-1): draw_circle(center,w*(0.16+i*0.024),Color(glow,0.033))
	if elapsed < 1.25:
		for i in range(4): star(center+Vector2(sin(i*2.1+elapsed)*w*0.36,cos(i*2.1)*h*0.13),w*0.021,Color("efcaff"))
		return
	var reveal_t := clampf((elapsed-1.25)/0.40,0,1)
	var pop := 0.78+0.22*sin(reveal_t*PI/2)+0.085*sin(reveal_t*PI)
	var hero_size := w*(0.54 if good else 0.69)*pop*(1+sin(elapsed*2.8)*0.022)
	draw_set_transform(center+Vector2(0,sin(elapsed*1.8)*h*0.003),sin(elapsed*1.5)*0.024)
	draw_texture_rect(PURPLE_CUBE if good else CRACKED_CUBE,Rect2(Vector2.ONE*-hero_size/2,Vector2.ONE*hero_size),false,Color(1,1,1,reveal_t))
	draw_set_transform(Vector2.ZERO)
	for i in range(6):
		var angle := i*TAU/6+elapsed*0.10
		var at := center+Vector2(cos(angle)*w*0.37,sin(angle)*h*0.16)
		star(at,w*(0.014+0.009*(0.5+0.5*sin(elapsed*2+i))),Color("e9baff"))
	if not revealed: return
	var badge := Rect2(card.position+card.size*Vector2(0.27,0.552),card.size*Vector2(0.46,0.060))
	var edge := Color("37105c") if good else Color("510900")
	var badge_fill := Color("44106c") if good else Color("650900")
	for i in range(3,0,-1): draw_style_box(plate(Color(glow,0.06),Color(glow,0.12),20,2),badge.grow(i*2))
	draw_style_box(plate(badge_fill,Color("df9aff") if good else Color("ff722e"),18,2),badge)
	lettering("LUCKY!" if good else "UNLUCKY!",Vector2(card.get_center().x,card.position.y+h*0.596),int(w*0.073),Color("f8deff") if good else Color("ff834b"),edge)
	var title: String = LuckyEffects.CATALOG[effect_id][0]
	var pixels := int(w*0.10)
	while font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x > w*0.87: pixels -= 1
	lettering(title,Vector2(card.get_center().x,card.position.y+h*0.666),pixels,Color("fffaf2"),edge)
	var line_y := card.position.y+h*0.791
	draw_line(Vector2(card.position.x+w*0.14,line_y),Vector2(card.position.x+w*0.43,line_y),Color(edge,0.45),1.5,true)
	draw_line(Vector2(card.position.x+w*0.57,line_y),Vector2(card.position.x+w*0.86,line_y),Color(edge,0.45),1.5,true)
	star(Vector2(card.get_center().x,line_y),w*0.014,Color("dfafff"))
	var footer := "APPLIES TO YOUR NEXT RUN ONLY"
	var footer_size := int(w*0.034)
	var at := Vector2(card.get_center().x-font.get_string_size(footer,HORIZONTAL_ALIGNMENT_LEFT,-1,footer_size).x/2,card.position.y+h*0.825)
	draw_string(font,at,footer,HORIZONTAL_ALIGNMENT_LEFT,-1,footer_size,Color("f5dbff") if good else Color("ffd0b9"))
	if claim.visible:
		var shadow := claim.get_rect()
		shadow.position.y += h*0.007
		draw_style_box(plate(Color("006d19"),Color("b9ff7a"),20,2),shadow)

