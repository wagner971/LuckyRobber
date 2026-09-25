class_name CashBurst3D
extends Node3D

signal collected(amount: int)

const MAX_ACTIVE := 40

var run: RunManager
var active_pieces: Array[CashPiece3D] = []
var pool: Array[CashPiece3D] = []
var all_pieces: Array[CashPiece3D] = []
var pending := {}
var next_burst_id := 0
var clock := 0.0
var random := RandomNumberGenerator.new()
var body_mesh: BoxMesh
var face_mesh: BoxMesh
var band_mesh: BoxMesh
var body_material: StandardMaterial3D
var face_material: StandardMaterial3D
var band_material: StandardMaterial3D

func setup(owner_run: RunManager) -> void:
	run = owner_run
	random.randomize()
	body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.30, 0.024, 0.14)
	face_mesh = BoxMesh.new()
	face_mesh.size = Vector3(0.294, 0.008, 0.134)
	band_mesh = BoxMesh.new()
	band_mesh.size = Vector3(0.07, 0.009, 0.146)
	body_material = make_material(Color("176f43"))
	face_material = make_material(Color("50ed88"))
	band_material = make_material(Color("f2dfaa"))

func make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

static func piece_count(value: int) -> int:
	if value < 150: return 9
	if value < 500: return 12
	if value < 1500: return 16
	return 19

func play_reward_vfx(amount: int) -> int:
	if not is_instance_valid(run) or not is_instance_valid(run.level): return 0
	var source: Node3D = run.level.van.money_burst_origin
	var target: Node3D = run.level.player.money_magnet_anchor
	if not is_instance_valid(source) or not is_instance_valid(target): return 0
	var desired := piece_count(amount)
	var minimum_visible := mini(6, desired)
	while MAX_ACTIVE - active_pieces.size() < minimum_visible and not active_pieces.is_empty():
		var oldest: CashPiece3D = active_pieces.pop_front()
		release_piece(oldest)
	var count := mini(desired, MAX_ACTIVE - active_pieces.size())
	if count <= 0: return 0
	next_burst_id += 1
	pending[next_burst_id] = {"remaining": count, "amount": amount}
	for index in count:
		var piece := obtain_piece()
		var angle := TAU * (float(index) + random.randf_range(-0.24, 0.24)) / float(count)
		var radius := random.randf_range(0.78, 1.24)
		var outward := Vector3(cos(angle) * radius, random.randf_range(0.12, 0.40), sin(angle) * radius)
		var tangent := Vector3(-sin(angle), 0, cos(angle))
		var curve := tangent * random.randf_range(-0.23, 0.23) + Vector3.UP * random.randf_range(0.10, 0.25)
		var spin := Vector3(random.randf_range(-9, 9), random.randf_range(-12, 12), random.randf_range(-10, 10))
		piece.launch(next_burst_id, source.global_position, outward, target, random.randf_range(0, 0.045), random.randf_range(0.86, 1.14), spin, curve)
		active_pieces.append(piece)
	return count

func obtain_piece() -> CashPiece3D:
	if not pool.is_empty(): return pool.pop_back()
	var piece := CashPiece3D.new()
	add_child(piece)
	piece.configure(body_mesh, face_mesh, band_mesh, body_material, face_material, band_material)
	all_pieces.append(piece)
	return piece

func _process(delta: float) -> void:
	if not is_instance_valid(run) or run.phase == RunManager.Phase.FINISHED:
		clear_active()
		return
	if run.phase == RunManager.Phase.PAUSED: return
	clock += delta
	for index in range(active_pieces.size() - 1, -1, -1):
		var piece := active_pieces[index]
		if piece.advance(delta):
			active_pieces.remove_at(index)
			release_piece(piece)

func release_piece(piece: CashPiece3D) -> void:
	piece.deactivate()
	pool.append(piece)
	var state: Dictionary = pending[piece.burst_id]
	state.remaining -= 1
	if state.remaining == 0:
		pending.erase(piece.burst_id)
		collected.emit(state.amount)

func clear_active() -> void:
	for piece in active_pieces: piece.deactivate()
	pool.append_array(active_pieces)
	active_pieces.clear()
	pending.clear()
