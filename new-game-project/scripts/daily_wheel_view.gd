class_name DailyWheelView
extends Control

# Clockwise from twelve o'clock. Medium cash has two illustrated sectors.
# Geometry does not change reward odds; the info panel shows the actual weights.
const VISUAL_PRIZES = [2, 4, 5, 6, 3, 1, 3, 0]
const ART = preload("res://assets/ui/wheel/lucky-wheel-disc.png")

static func slots_for(prize_index: int) -> Array[int]:
	var slots: Array[int] = []
	for i in VISUAL_PRIZES.size():
		if VISUAL_PRIZES[i] == prize_index: slots.append(i)
	return slots

static func target_rotation(prize_index: int, variation: int = 0) -> float:
	var slots := slots_for(prize_index)
	return fposmod(-float(slots[posmod(variation, slots.size())]) * TAU / 8.0, TAU)

static func prize_at_rotation(angle: float) -> int:
	var slot := posmod(roundi(fposmod(-angle, TAU) / (TAU / 8.0)), 8)
	return VISUAL_PRIZES[slot]

func setup(profile: Dictionary, font: Font) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art := TextureRect.new()
	art.texture = ART
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = preload("res://assets/shaders/wheel_disc.gdshader")
	art.material = material
	add_child(art)
	var unit := DailyWheel.cash_unit(profile)
	for i in VISUAL_PRIZES.size():
		var prize: Dictionary = DailyWheel.PRIZES[VISUAL_PRIZES[i]]
		var caption := Label.new()
		caption.text = "$%d" % (unit * int(prize.scale)) if prize.kind == "cash" else (str(prize.amount) + " GEMS" if prize.kind == "diamonds" else ("VAN" if prize.ticket == "van" else "SKIN"))
		caption.add_theme_font_override("font", font)
		caption.add_theme_font_size_override("font_size", 30)
		caption.add_theme_color_override("font_color", Color.WHITE)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.size = Vector2(210, 48)
		caption.pivot_offset = caption.size * 0.5
		var angle := -PI * 0.5 + float(i) * TAU / 8.0
		caption.position = size * 0.5 + Vector2.from_angle(angle) * size.x * 0.409 - caption.pivot_offset
		caption.rotation = angle + PI * 0.5
		add_child(caption)
