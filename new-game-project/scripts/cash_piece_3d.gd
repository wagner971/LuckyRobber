class_name CashPiece3D
extends Node3D

const BURST_TIME := 0.27
const FLOAT_TIME := 0.08
const MAGNET_TIME := 0.40

var active := false
var burst_id := 0
var age := 0.0
var delay := 0.0
var origin := Vector3.ZERO
var burst_end := Vector3.ZERO
var curve := Vector3.ZERO
var magnet: Node3D
var visual_scale := 1.0
var spin := Vector3.ZERO

func configure(body_mesh: BoxMesh, face_mesh: BoxMesh, band_mesh: BoxMesh, body_material: Material, face_material: Material, band_material: Material) -> void:
	add_part(body_mesh, body_material, Vector3.ZERO)
	add_part(face_mesh, face_material, Vector3(0, 0.016, 0))
	add_part(band_mesh, band_material, Vector3(0, 0.022, 0))
	hide()

func add_part(mesh: Mesh, material: Material, offset: Vector3) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = offset
	part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(part)

func launch(id: int, from: Vector3, outward: Vector3, target: Node3D, start_delay: float, size_factor: float, rotation_speed: Vector3, path_curve: Vector3) -> void:
	burst_id = id
	origin = from
	burst_end = from + outward
	magnet = target
	delay = start_delay
	visual_scale = size_factor
	spin = rotation_speed
	curve = path_curve
	age = 0.0
	active = true
	visible = true
	global_position = origin
	rotation = Vector3.ZERO
	scale = Vector3.ONE * visual_scale

func advance(delta: float) -> bool:
	if not active: return false
	age += delta
	if age < delay:
		hide()
		return false
	show()
	var time := age - delay
	rotation += spin * delta
	if time < BURST_TIME:
		var t := time / BURST_TIME
		var eased := 1.0 - pow(1.0 - t, 3.0)
		global_position = origin.lerp(burst_end, eased) + Vector3.UP * sin(t * PI) * 0.13
		scale = Vector3.ONE * visual_scale * (1.0 + sin(t * PI) * 0.12)
	elif time < BURST_TIME + FLOAT_TIME:
		global_position = burst_end + Vector3.UP * sin((time - BURST_TIME) / FLOAT_TIME * PI) * 0.025
	else:
		var t := clampf((time - BURST_TIME - FLOAT_TIME) / MAGNET_TIME, 0.0, 1.0)
		var current_target := magnet.global_position if is_instance_valid(magnet) else burst_end
		global_position = burst_end.lerp(current_target, t * t) + curve * sin(t * PI)
		scale = Vector3.ONE * visual_scale * (1.0 - smoothstep(0.72, 1.0, t))
		if t >= 1.0:
			deactivate()
			return true
	return false

func deactivate() -> void:
	active = false
	magnet = null
	hide()
	scale = Vector3.ZERO
