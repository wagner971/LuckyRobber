class_name ResultPresentation
extends Control

const DESIGN = Vector2(941, 1672)
const WIN = preload("res://assets/ui/results/alley-clean.png")
const LOSE = preload("res://assets/ui/results/alley-clean.png")
var canvas: Control
var amount: Label
var caption: Label
var wallet: Label
var diamonds: Label
var replay: Button
var home: Button
var notice: Button
var font: Font
var reward_title: Label
var reward_cash: CashVisual
var money_rain: ResultMoneyRain
var animation_time := 0.0
var celebrates := false
var failure_title: Label
var failure_emblem: TextureRect
var failure_sparks: CPUParticles2D

func setup(success: bool, location_name: String, heavy: Font, replay_text: String, replay_action: Callable, home_action: Callable) -> void:
	font = heavy
	celebrates = success
	mouse_filter = MOUSE_FILTER_IGNORE
	size_flags_vertical = SIZE_EXPAND_FILL
	size_flags_horizontal = SIZE_EXPAND_FILL
	canvas = Control.new()
	canvas.size = DESIGN
	canvas.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(canvas)
	var art := TextureRect.new()
	art.texture = WIN if success else LOSE
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art.size = DESIGN
	art.mouse_filter = MOUSE_FILTER_IGNORE
	var edge_fade := ShaderMaterial.new()
	edge_fade.shader = preload("res://assets/shaders/result_art.gdshader")
	art.material = edge_fade
	canvas.add_child(art)
	if success: create_celebration()
	else: create_failure()
	var close := action("×", Rect2(30,26,100,100), Color("7a23b7"), Color("340753"), home_action, 84)
	close.name = "ResultClose"
	close.tooltip_text = "Return to homescreen"
	close.add_theme_color_override("font_color", Color.WHITE)
	var chip := Panel.new()
	chip.position = Vector2(505,32)
	chip.size = Vector2(407,90)
	chip.mouse_filter = MOUSE_FILTER_IGNORE
	chip.add_theme_stylebox_override("panel", HudStyle.plate(Color("200632e6"),Color("7830aa"),28))
	canvas.add_child(chip)
	icon(HudStyle.ICONS.cash, Rect2(519,44,62,62))
	wallet = label_at("$0",Rect2(586,39,185,72),44,HudStyle.GOLD)
	icon(preload("res://assets/ui/diamond.png"),Rect2(783,52,45,45))
	diamonds = label_at("0",Rect2(830,39,69,72),36,HudStyle.CYAN)
	label_at(location_name.to_upper(),Rect2(100,215,741,72),43,Color("d7adf4"))
	caption = label_at("CASH BANKED" if success else "UNBANKED LOOT LOST",Rect2(85,837,771,70),46,HudStyle.GOLD if success else HudStyle.RED)
	amount = label_at("+$0" if success else "$0",Rect2(50,913,841,200),150,HudStyle.GOLD if success else HudStyle.RED)
	amount.name = "ResultAmount"
	amount.add_theme_color_override("font_shadow_color", Color("563002") if success else Color("451025"))
	amount.add_theme_constant_override("shadow_offset_y",12)
	amount.add_theme_constant_override("shadow_outline_size",8)
	amount.add_theme_color_override("font_outline_color",Color("ffea87") if success else Color("ffa08c"))
	amount.add_theme_constant_override("outline_size",2)
	amount.pivot_offset = Vector2(420.5,100)
	notice = Button.new()
	notice.position = Vector2(70,1117)
	notice.size = Vector2(801, 60)
	notice.add_theme_font_override("font",font)
	notice.add_theme_font_size_override("font_size",27)
	for state in ["normal","hover","pressed","focus"]: notice.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	notice.add_theme_color_override("font_color",HudStyle.CYAN)
	notice.add_theme_color_override("font_hover_color",Color.WHITE)
	canvas.add_child(notice)
	replay = action(replay_text,Rect2(70,1200,801,171),Color("fff04f"),Color("ffba0b"),replay_action,65)
	replay.name = "ResultReplay"
	replay.icon = preload("res://assets/ui/results/retry.svg")
	replay.expand_icon = true
	replay.add_theme_constant_override("icon_max_width",86)
	replay.add_theme_constant_override("h_separation",32)
	home = action("RETURN TO HOMESCREEN",Rect2(70,1420,801,155),Color("63ffdb"),Color("00d6ab"),home_action,43)
	home.name = "ResultHome"
	home.icon = preload("res://assets/ui/results/home.svg")
	home.expand_icon = true
	home.add_theme_constant_override("icon_max_width",72)
	home.add_theme_constant_override("h_separation",24)
	resized.connect(fit)
	fit.call_deferred()
	set_process(true)
	animate_at(0.0)

func failure_sprite(texture: Texture2D, rect: Rect2, node_name: String) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.position = rect.position
	sprite.size = rect.size
	sprite.pivot_offset = rect.size*0.5
	sprite.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(sprite)
	return sprite

func create_failure() -> void:
	var lights := ColorRect.new()
	lights.name = "PoliceReflection"
	lights.size = DESIGN
	lights.mouse_filter = MOUSE_FILTER_IGNORE
	var light_material := ShaderMaterial.new()
	light_material.shader = preload("res://assets/shaders/result_police.gdshader")
	lights.material = light_material
	canvas.add_child(lights)
	var halo := ColorRect.new()
	halo.name = "FailureHalo"
	halo.position = Vector2(20,205)
	halo.size = Vector2(901,901)
	halo.mouse_filter = MOUSE_FILTER_IGNORE
	var halo_material := ShaderMaterial.new()
	halo_material.shader = preload("res://assets/shaders/result_rays.gdshader")
	halo_material.set_shader_parameter("tint",Color("ff403d"))
	halo_material.set_shader_parameter("beam_strength",0.16)
	halo_material.set_shader_parameter("rotation_speed",-0.05)
	halo.material = halo_material
	canvas.add_child(halo)
	failure_sparks = CPUParticles2D.new()
	failure_sparks.name = "FailureSparks"
	failure_sparks.position = Vector2(470,640)
	failure_sparks.amount = 12
	failure_sparks.lifetime = 3.8
	failure_sparks.preprocess = 3.8
	failure_sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	failure_sparks.emission_rect_extents = Vector2(310,170)
	failure_sparks.direction = Vector2.UP
	failure_sparks.spread = 22.0
	failure_sparks.gravity = Vector2.ZERO
	failure_sparks.initial_velocity_min = 18.0
	failure_sparks.initial_velocity_max = 32.0
	failure_sparks.scale_amount_min = 1.5
	failure_sparks.scale_amount_max = 3.0
	var fade := Gradient.new()
	fade.set_color(0,Color("ff8d6900"))
	fade.add_point(0.25,Color("ff8d6970"))
	fade.set_color(fade.get_point_count()-1,Color("ff554000"))
	failure_sparks.color_ramp = fade
	canvas.add_child(failure_sparks)
	failure_emblem = failure_sprite(preload("res://assets/ui/results/busted-emblem.png"),Rect2(306,488,329,334),"AnimatedFailureEmblem")
	failure_title = title_label("BUSTED!",Rect2(80,290,781,240),HudStyle.RED,"AnimatedBusted")

func create_celebration() -> void:
	var rays := ColorRect.new()
	rays.position = Vector2(20,205)
	rays.size = Vector2(901,901)
	rays.mouse_filter = MOUSE_FILTER_IGNORE
	var ray_material := ShaderMaterial.new()
	ray_material.shader = preload("res://assets/shaders/result_rays.gdshader")
	rays.material = ray_material
	canvas.add_child(rays)
	money_rain = ResultMoneyRain.new()
	money_rain.name = "ResultMoneyRain"
	money_rain.size = DESIGN
	canvas.add_child(money_rain)
	reward_cash = CashVisual.new()
	reward_cash.name = "ResultCash3D"
	reward_cash.animated = true
	reward_cash.position = Vector2(201,495)
	reward_cash.size = Vector2(540,340)
	reward_cash.pivot_offset = reward_cash.size*0.5
	canvas.add_child(reward_cash)
	reward_title = title_label("ESCAPED!",Rect2(80,290,781,240),Color("5cffb0"),"AnimatedEscaped")

# Plain lettering, no outline: the headline is a real label, not baked artwork.
func title_label(value: String, rect: Rect2, color: Color, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.pivot_offset = rect.size*0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",150)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	return label

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	animation_time += delta
	animate_at(animation_time)

func pop_progress(time: float) -> float:
	var t := clampf(time,0.0,1.0)-1.0
	return 1.0+2.70158*t*t*t+1.70158*t*t

func animate_at(time: float) -> void:
	if not celebrates:
		animate_failure(time)
		return
	var title_pop := lerpf(0.62,1.0,pop_progress(time/0.58))
	var title_idle := sin(maxf(0.0,time-0.58)*TAU/3.2)*0.014
	reward_title.scale = Vector2.ONE*(title_pop+title_idle)
	reward_title.rotation = lerpf(-0.065,0.0,clampf(time/0.58,0.0,1.0))
	reward_title.modulate.a = clampf(time/0.16,0.0,1.0)
	var cash_pop := lerpf(0.68,1.0,pop_progress((time-0.12)/0.60))
	var cash_idle := sin(maxf(0.0,time-0.72)*TAU/1.9)*0.065
	reward_cash.scale = Vector2.ONE*(cash_pop+cash_idle)
	reward_cash.position.y = 495.0+sin(time*TAU/3.4)*7.0
	reward_cash.modulate.a = clampf((time-0.12)/0.18,0.0,1.0)
	# The money amount pops once the count-up finishes, then breathes gently.
	var reward_pop := sin(clampf((time-0.55)/0.42,0.0,1.0)*PI)*0.11
	var amount_idle := sin(maxf(0.0,time-0.97)*TAU/2.6)*0.018
	amount.scale = Vector2.ONE*(1.0+reward_pop+amount_idle)

func animate_failure(time: float) -> void:
	var impact := lerpf(1.30,1.0,pop_progress(time/0.48))
	var breath := sin(maxf(0.0,time-0.65)*TAU/3.5)*0.012
	var shake := smoothstep(0.12,0.20,time)*(1.0-smoothstep(0.24,0.65,time))
	failure_title.scale = Vector2.ONE*(impact+breath)
	failure_title.position.x = 80.0+sin(time*62.0)*5.0*shake
	failure_title.rotation = lerpf(0.035,0.0,clampf(time/0.48,0.0,1.0))
	failure_title.modulate.a = clampf(time/0.15,0.0,1.0)
	var emblem_pop := lerpf(0.70,1.0,pop_progress((time-0.15)/0.55))
	var emblem_idle := sin(maxf(0.0,time-0.70)*TAU/2.3)*0.055
	failure_emblem.scale = Vector2.ONE*(emblem_pop+emblem_idle)
	failure_emblem.position.y = 488.0+sin(time*TAU/3.8)*4.0
	failure_emblem.rotation = sin(maxf(0.0,time-0.70)*TAU/4.6)*0.018
	failure_emblem.modulate.a = clampf((time-0.15)/0.18,0.0,1.0)
	var loss_pop := sin(clampf((time-0.55)/0.42,0.0,1.0)*PI)*0.085
	var loss_idle := sin(maxf(0.0,time-0.97)*TAU/3.0)*0.015
	amount.scale = Vector2.ONE*(1.0+loss_pop+loss_idle)

func icon(texture: Texture2D, rect: Rect2) -> void:
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(image)

func label_at(value: String, rect: Rect2, pixels: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",pixels)
	fit_text(label,rect.size.x,pixels)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	return label

func fit_text(label: Label, width: float, maximum: int) -> void:
	var measured := font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,maximum).x
	label.add_theme_font_size_override("font_size",mini(maximum,int(maximum*width/maxf(1.0,measured))))

func set_wallet(value: String) -> void:
	wallet.text = value
	fit_text(wallet,185,44)

func set_notice(value: String) -> void:
	notice.text = value
	var measured := font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,27).x
	notice.add_theme_font_size_override("font_size",mini(27,int(27.0*790.0/maxf(1.0,measured))))

func action(value: String, rect: Rect2, top: Color, bottom: Color, callback: Callable, pixels: int) -> Button:
	var b := Button.new()
	b.text = value
	b.position = rect.position
	b.size = rect.size
	b.add_theme_font_override("font",font)
	b.add_theme_font_size_override("font_size",pixels)
	b.add_theme_constant_override("outline_size",0)
	for state in ["normal","hover","pressed","focus"]:
		var empty := StyleBoxEmpty.new()
		empty.content_margin_left = 44 if rect.size.x > 200 else 0
		empty.content_margin_right = 30 if rect.size.x > 200 else 0
		b.add_theme_stylebox_override(state,empty)
	for state in ["font_color","font_hover_color","font_pressed_color"]: b.add_theme_color_override(state,Color("190329"))
	b.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	canvas.add_child(b)
	var shadow := Panel.new()
	shadow.show_behind_parent = true
	shadow.position = Vector2(0,9)
	shadow.size = rect.size
	shadow.mouse_filter = MOUSE_FILTER_IGNORE
	var style := HudStyle.plate(bottom.darkened(0.48),bottom.darkened(0.12),32)
	style.shadow_color = Color(top,0.22)
	style.shadow_size = 18
	shadow.add_theme_stylebox_override("panel",style)
	b.add_child(shadow)
	var fill := ColorRect.new()
	fill.show_behind_parent = true
	fill.size = rect.size
	fill.mouse_filter = MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/result_button.gdshader")
	mat.set_shader_parameter("bounds",rect.size)
	mat.set_shader_parameter("top_color",top)
	mat.set_shader_parameter("bottom_color",bottom)
	fill.material = mat
	b.add_child(fill)
	b.mouse_entered.connect(func(): fill.modulate = Color(1.1,1.1,1.1))
	b.mouse_exited.connect(func(): fill.modulate = Color.WHITE)
	b.pressed.connect(callback)
	UiJuice.button_touch(b)
	return b

func fit() -> void:
	if not is_instance_valid(canvas): return
	var factor := maxf(0.01,minf(size.x/DESIGN.x,size.y/DESIGN.y))
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size-DESIGN*factor)*0.5

func set_amount(total: int, success: bool) -> void:
	var value := str(absi(total))
	var grouped := ""
	for i in range(value.length()):
		if i > 0 and (value.length()-i)%3 == 0: grouped += ","
		grouped += value[i]
	amount.text = ("+$" if success else "$") + grouped
	amount.add_theme_font_size_override("font_size",mini(150, int(1100.0/maxi(amount.text.length(),7))))
