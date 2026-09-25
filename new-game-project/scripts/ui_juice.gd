class_name UiJuice
extends RefCounted

static func button_touch(button: Button) -> void:
	button.button_down.connect(func():
		if button.has_meta("touch_tween"):
			var previous: Tween = button.get_meta("touch_tween")
			if previous.is_valid(): previous.kill()
		button.pivot_offset = button.size * 0.5
		var down = button.create_tween()
		button.set_meta("touch_tween", down)
		down.tween_property(button, "scale", Vector2.ONE * 0.975, 0.065).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	button.button_up.connect(func():
		if not is_instance_valid(button): return
		if button.has_meta("touch_tween"):
			var previous: Tween = button.get_meta("touch_tween")
			if previous.is_valid(): previous.kill()
		var tween = button.create_tween()
		button.set_meta("touch_tween", tween)
		tween.tween_property(button, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

static func modal_enter(overlay: Control, body: Control) -> void:
	overlay.modulate.a = 0.0
	var tree := overlay.get_tree()
	await tree.process_frame
	await tree.process_frame
	if not is_instance_valid(overlay) or overlay.is_queued_for_deletion() or overlay.has_meta("dismissing") or not is_instance_valid(body): return
	body.pivot_offset = body.size * 0.5
	body.scale = Vector2.ONE * 0.96
	var tween = overlay.create_tween().set_parallel(true)
	overlay.set_meta("modal_motion", tween)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)
	tween.tween_property(body, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func dismiss(overlay: Control) -> void:
	overlay.set_meta("dismissing", true)
	if overlay.has_meta("modal_motion"):
		var previous: Tween = overlay.get_meta("modal_motion")
		if previous.is_valid(): previous.kill()
	# The old modal cannot swallow the next touch while fading away.
	_ignore_pointer(overlay)
	var tween = overlay.create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(overlay.queue_free)

static func _ignore_pointer(node: Node) -> void:
	if node is Control: node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): _ignore_pointer(child)

static func pulse(control: Control, amount: float = 1.06, seconds: float = 0.20) -> Tween:
	if not is_instance_valid(control): return null
	control.pivot_offset = control.size * 0.5
	control.scale = Vector2.ONE * amount
	var tween := control.create_tween()
	tween.tween_property(control, "scale", Vector2.ONE, seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween

static func flash(control: Control, color: Color, seconds: float = 0.35) -> Tween:
	if not is_instance_valid(control): return null
	control.modulate = color
	var tween := control.create_tween()
	tween.tween_property(control, "modulate", Color.WHITE, seconds)
	return tween

static func count_label(label: Label, old_value: int, new_value: int, seconds: float, prefix: String = "$", suffix: String = "") -> Tween:
	if not is_instance_valid(label): return null
	label.text = "%s%s%s" % [prefix, grouped_number(old_value), suffix]
	var tween := label.create_tween()
	tween.tween_method(func(value: float):
		if is_instance_valid(label): label.text = "%s%s%s" % [prefix, grouped_number(roundi(value)), suffix]
	, float(old_value), float(new_value), seconds)
	return tween

static func grouped_number(value: int) -> String:
	var digits := str(absi(value))
	var result := ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0: result += ","
		result += digits[i]
	return ("-" if value < 0 else "") + result
