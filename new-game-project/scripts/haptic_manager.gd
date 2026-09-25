class_name HapticManager
extends Node

const PATTERNS := {
	"pickup_light": [18, 0.25], "pickup_heavy": [28, 0.45],
	"load_light": [25, 0.40], "load_medium": [34, 0.55],
	"load_heavy": [42, 0.72], "load_very_heavy": [52, 0.85],
	"alarm": [55, 0.88], "upgrade": [38, 0.58],
	"strength": [44, 0.65], "escape": [30, 0.57],
	"busted": [40, 0.56],
}

var enabled := true
var force_mobile_for_test := false
var vibration_calls := 0
var sequence := 0

func is_mobile() -> bool:
	return force_mobile_for_test or OS.has_feature("mobile")

func play(pattern: String) -> void:
	if not enabled or not is_mobile() or not PATTERNS.has(pattern): return
	var definition: Array = PATTERNS[pattern]
	vibrate(int(definition[0]), float(definition[1]))
	if pattern in ["strength", "escape"]:
		sequence += 1
		var current := sequence
		get_tree().create_timer(0.09).timeout.connect(func():
			if is_instance_valid(self) and enabled and current == sequence:
				vibrate(18, 0.38)
		)

func vibrate(milliseconds: int, strength: float) -> void:
	if not enabled or not is_mobile(): return
	vibration_calls += 1
	if not force_mobile_for_test: Input.vibrate_handheld(milliseconds, strength)

func set_enabled(value: bool) -> void:
	enabled = value
	if not value: sequence += 1
