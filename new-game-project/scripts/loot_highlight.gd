class_name LootHighlight
extends Node3D

const OUTLINE = preload("res://assets/shaders/loot_outline.gdshader")
const RING = preload("res://assets/shaders/loot_ring.gdshader")
const NORMAL_COLOR = Color("a0ffd2")
const LOCKED_COLOR = Color("ffd38a")
var item: LootItem
var outline: MeshInstance3D
var ring: MeshInstance3D
var outline_material: ShaderMaterial
var ring_material: ShaderMaterial
var focus := 0.0
var accent := NORMAL_COLOR

func setup(owner_item: LootItem) -> void:
	item = owner_item
	name = "StealableHighlight"
	outline_material = ShaderMaterial.new()
	outline_material.shader = OUTLINE
	# Batch the complete prop into one silhouette pass, irrespective of its parts.
	var builder := SurfaceTool.new()
	builder.begin(Mesh.PRIMITIVE_TRIANGLES)
	append_geometry(item.model, builder, item.model.global_transform.affine_inverse())
	outline = MeshInstance3D.new()
	outline.mesh = builder.commit()
	outline.material_override = outline_material
	outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	outline.extra_cull_margin = 0.25
	item.model.add_child(outline)
	ring_material = ShaderMaterial.new()
	ring_material.shader = RING
	var plane := PlaneMesh.new()
	var diameter := float(item.data.radius) * 2.0 + 0.40
	plane.size = Vector2(diameter, diameter)
	ring = MeshInstance3D.new()
	ring.mesh = plane
	ring.material_override = ring_material
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = 0.035
	add_child(ring)
	update_visual(0.0, false, true, false)

func append_geometry(node: Node, builder: SurfaceTool, inverse: Transform3D) -> void:
	if node is MeshInstance3D and node.mesh != null:
		var transform: Transform3D = inverse * node.global_transform
		for surface in node.mesh.get_surface_count():
			if node.mesh is ArrayMesh and node.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES: continue
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			# Smooth coincident hard-edge normals only on the outline shell to avoid
			# cracks around blocky corners. The visible model keeps its original normals.
			var joined := {}
			for i in vertices.size():
				var key := vertices[i].snapped(Vector3.ONE * 0.0001)
				joined[key] = joined.get(key, Vector3.ZERO) + normals[i]
			var normal_basis := transform.basis.inverse().transposed()
			for i in (indices.size() if not indices.is_empty() else vertices.size()):
				var index: int = indices[i] if not indices.is_empty() else i
				var normal: Vector3 = joined[vertices[index].snapped(Vector3.ONE * 0.0001)]
				builder.set_normal((normal_basis * normal).normalized())
				builder.add_vertex(transform * vertices[index])
	for child in node.get_children(): append_geometry(child, builder, inverse)

func update_visual(delta: float, near: bool, available: bool, paused: bool) -> void:
	var special: bool = is_instance_valid(item.rarity_marker) or item.data.type_id == "lucky_block"
	var shown: bool = available and (special or not item.get_meta("suppress_highlight", false))
	visible = shown
	outline.visible = shown
	if not shown: return
	if not paused: focus = move_toward(focus, 1.0 if near else 0.0, delta * 7.0)
	accent = NORMAL_COLOR
	if special:
		accent = item.rarity_marker.surface.get_shader_parameter("accent") if is_instance_valid(item.rarity_marker) else Color("ffdf70")
	elif item.strength_lock.visible:
		accent = LOCKED_COLOR
	outline_material.set_shader_parameter("accent", accent)
	outline_material.set_shader_parameter("width", lerpf(3.5, 5.0, focus))
	ring_material.set_shader_parameter("accent", accent)
	ring_material.set_shader_parameter("focus", focus)
