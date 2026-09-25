class_name CameraJuice
extends Node

var camera: Camera3D
var base_position := Vector3.ZERO
var base_size := 12.0
var follow_target: Node3D
var follow_origin := Vector3.ZERO
var follow_offset := Vector3.ZERO
var enabled := true
var duration := 0.0
var elapsed := 0.0
var strength := 0.0

func setup(target: Camera3D, player: Node3D = null) -> void:
	camera = target
	base_position = camera.position
	base_size = camera.size
	follow_target = player
	follow_origin = player.global_position if is_instance_valid(player) else Vector3.ZERO

func impact_punch(intensity: float) -> void:
	start(clampf(intensity, 0, 1), 0.10)

func alarm_pulse() -> void:
	start(0.72, 0.16)

func success_pulse() -> void:
	start(0.38, 0.22)

func busted_punch() -> void:
	start(0.50, 0.09)

func start(amount: float, seconds: float) -> void:
	if not enabled or not is_instance_valid(camera): return
	strength = maxf(strength, amount)
	duration = seconds
	elapsed = 0.0

func set_enabled(value: bool) -> void:
	enabled = value
	if not value: reset()

func reset() -> void:
	duration = 0.0
	elapsed = 0.0
	strength = 0.0
	if is_instance_valid(camera):
		camera.position = base_position + follow_offset
		camera.size = base_size

func _process(delta: float) -> void:
	if not is_instance_valid(camera): return
	if is_instance_valid(follow_target):
		var travel := follow_target.global_position - follow_origin
		var depth_follow := clampf(0.4 + (base_size - 8.8) * 0.05, 0.4, 0.75)
		var desired := Vector3(clampf(travel.x * 0.65, -5.5, 5.5), 0.0, clampf(travel.z * depth_follow, -10.5, 3.0))
		follow_offset = follow_offset.lerp(desired, 1.0 - exp(-delta * 3.8))
	if duration <= 0.0:
		camera.position = base_position + follow_offset
		return
	elapsed += delta
	var t := minf(1.0, elapsed / duration)
	var envelope := sin(t * PI) * (1.0 - t * 0.25)
	camera.position = base_position + follow_offset + Vector3(0.036, -0.018, 0.028) * strength * envelope
	camera.size = base_size * (1.0 - 0.015 * strength * envelope)
	if t >= 1.0: reset()
