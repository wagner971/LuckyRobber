class_name LuckyWheelArt
extends Control

const ART = preload("res://assets/ui/wheel/lucky-wheel-stage.png")
const DESIGN = Vector2(941, 1672)
var canvas: Control
var disc: DailyWheelView
var spin: Button
var result: Label
var reset: Label

func setup(profile: Dictionary, font: Font, on_spin: Callable) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas = Control.new()
	canvas.size = DESIGN
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	add_art()
	disc = DailyWheelView.new()
	disc.position = Vector2(48, 334)
	disc.size = Vector2(844, 844)
	disc.pivot_offset = disc.size * 0.5
	canvas.add_child(disc)
	disc.setup(profile, font)
	var front := add_art()
	var material := ShaderMaterial.new()
	material.shader = preload("res://assets/shaders/wheel_frame.gdshader")
	front.material = material
	result = label_at("Spin for rewards", Rect2(249, 200, 444, 48), 35, font)
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color("10235c")
	plate.set_corner_radius_all(18)
	result.add_theme_stylebox_override("normal", plate)
	spin = Button.new()
	spin.name = "DailySpinButton"
	spin.position = Vector2(160, 1300)
	spin.size = Vector2(620, 196)
	spin.tooltip_text = "Spin for rewards"
	spin.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "focus", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0,0,0,0.55) if state == "disabled" else (Color(1,1,1,0.12) if state == "hover" else (Color(0,0,0,0.20) if state == "pressed" else Color.TRANSPARENT))
		style.set_corner_radius_all(85)
		spin.add_theme_stylebox_override(state, style)
	spin.pressed.connect(on_spin)
	canvas.add_child(spin)
	reset = label_at("1 FREE SPIN", Rect2(181, 1523, 578, 75), 38, font)
	var status_plate := StyleBoxFlat.new()
	status_plate.bg_color = Color("112858")
	status_plate.set_corner_radius_all(30)
	reset.add_theme_stylebox_override("normal", status_plate)
	resized.connect(fit)
	fit.call_deferred()

func add_art() -> TextureRect:
	var image := TextureRect.new()
	image.texture = ART
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.size = DESIGN
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(image)
	return image

func label_at(value: String, rect: Rect2, pixels: int, font: Font) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", pixels)
	label.add_theme_color_override("font_color", Color("d5f7ff"))
	label.add_theme_color_override("font_outline_color", Color("071332"))
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	return label

func fit() -> void:
	if not is_instance_valid(canvas): return
	var factor := maxf(0.01, minf(size.x / DESIGN.x, size.y / DESIGN.y))
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN * factor) * 0.5
