class_name MoveInput
extends Control

var direction = Vector2.ZERO
var pointer = -1
var origin = Vector2.ZERO
var finger = Vector2.ZERO
var enabled = false
var keyboard_ready = true

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

func reset() -> void:
	pointer = -1
	direction = Vector2.ZERO
	keyboard_ready = false
	queue_redraw()

func keyboard() -> Vector2:
	var v = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if not keyboard_ready:
		if v == Vector2.ZERO: keyboard_ready = true
		return Vector2.ZERO
	return v.limit_length()

func movement() -> Vector2:
	if not enabled: return Vector2.ZERO
	var keys = keyboard()
	return keys if keys.length() > 0 else direction

func _gui_input(event: InputEvent) -> void:
	if not enabled or pointer != -1: return
	if event is InputEventScreenTouch and event.pressed:
		pointer = event.index
		origin = event.position
		finger = origin
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pointer = -2
		origin = event.position
		finger = origin
		accept_event()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not enabled or pointer == -1: return
	if event is InputEventScreenTouch and event.index == pointer and (not event.pressed or event.canceled): reset()
	elif event is InputEventScreenDrag and event.index == pointer:
		finger = event.position
		update_direction()
	elif event is InputEventMouseButton and pointer == -2 and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: reset()
	elif event is InputEventMouseMotion and pointer == -2:
		finger = event.position
		update_direction()
	queue_redraw()

func update_direction() -> void:
	direction = ((finger - origin) / 78.0).limit_length()
	if direction.length() <= Balance.INPUT_DEADZONE: direction = Vector2.ZERO

func _draw() -> void:
	if pointer == -1 or not enabled: return
	var thumb = origin + (finger - origin).limit_length(78)
	draw_circle(origin + Vector2(0, 4), 82, Color("1c062c80"))
	draw_circle(origin, 78, Color("49176c70"))
	draw_arc(origin, 78, 0, TAU, 64, Color("c065ff90"), 3, true)
	draw_arc(origin, 58, 0, TAU, 64, Color("c065ff30"), 2, true)
	for i in range(4):
		var axis = Vector2.RIGHT.rotated(i * PI / 2)
		draw_line(origin + axis * 65, origin + axis * 71, Color("e1b5ffaa"), 3, true)
	draw_circle(thumb + Vector2(0, 4), 29, Color("1c062caa"))
	draw_circle(thumb, 28, Color("992ce5ee"))
	draw_arc(thumb, 27, 0, TAU, 40, Color("e1b6ff"), 3, true)
	draw_arc(thumb, 20, PI * 1.1, PI * 1.75, 20, Color("e3faffbb"), 3, true)
