class_name RarityVisual
extends Node3D

const SURFACE = preload("res://assets/shaders/rarity_surface.gdshader")
const GROUND = preload("res://assets/shaders/rarity_ground.gdshader")
const PERIODS = [3.8, 3.2, 2.7]
const DURATIONS = [0.45, 0.55, 0.65]
var surface: ShaderMaterial
var ground: ShaderMaterial
var item: Node3D
var tier := 0
var elapsed := 0.0
var proximity := 0.0
var active := true
var meshes: Array[MeshInstance3D] = []

func setup(owner_item: Node3D, choice: Dictionary) -> void:
	item = owner_item
	tier = maxi(0, LootRarity.TIERS.find(choice.tier))
	name = "RareLootMarker"
	surface = ShaderMaterial.new()
	surface.shader = SURFACE
	surface.set_shader_parameter("accent", choice.color)
	surface.set_shader_parameter("rim_gain", [0.10, 0.14, 0.18][tier])
	surface.set_shader_parameter("sweep_gain", [0.12, 0.18, 0.26][tier])
	collect_meshes(item.get("model"))
	var bounds := AABB()
	var first := true
	var inverse := item.global_transform.affine_inverse()
	for mesh in meshes:
		var local_bounds: AABB = (inverse * mesh.global_transform) * mesh.get_aabb()
		bounds = local_bounds if first else bounds.merge(local_bounds)
		first = false
		mesh.material_overlay = surface
	surface.set_shader_parameter("sweep_bounds", Vector2(bounds.position.y + bounds.position.x * 0.45 - 0.15, bounds.end.y + bounds.end.x * 0.45 + 0.15))
	ground = ShaderMaterial.new()
	ground.shader = GROUND
	ground.set_shader_parameter("accent", choice.color)
	ground.set_shader_parameter("strength", [0.12, 0.17, 0.23][tier])
	var disc := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	var diameter := float(item.get("data").radius) * 2.0 + 0.65
	plane.size = Vector2(diameter, diameter)
	disc.mesh = plane
	disc.material_override = ground
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.position.y = 0.012
	add_child(disc)
	# The first sweep arrives after the player has had a moment to read the room.
	elapsed = 0.8
	update_visual(0.0, false, true, false)

func collect_meshes(node: Node) -> void:
	if node is MeshInstance3D: meshes.append(node)
	for child in node.get_children(): collect_meshes(child)

func update_visual(delta: float, near: bool, available: bool, paused: bool) -> void:
	if active != available:
		active = available
		for mesh in meshes:
			if is_instance_valid(mesh): mesh.material_overlay = surface if active else null
	visible = available
	surface.set_shader_parameter("active", 1.0 if available else 0.0)
	if not available or paused: return
	elapsed += delta
	proximity = move_toward(proximity, 1.0 if near else 0.0, delta * 5.0)
	var cycle := fmod(elapsed, float(PERIODS[tier]))
	var duration: float = DURATIONS[tier]
	var sweeping := cycle < duration
	surface.set_shader_parameter("world_to_loot", item.global_transform.affine_inverse())
	surface.set_shader_parameter("proximity", proximity)
	surface.set_shader_parameter("sweep_position", clampf(cycle / duration, 0.0, 1.0))
	surface.set_shader_parameter("sweep_visible", sin(PI * cycle / duration) if sweeping else 0.0)
	ground.set_shader_parameter("strength", float([0.12, 0.17, 0.23][tier]) * (1.0 + proximity * 0.18))
