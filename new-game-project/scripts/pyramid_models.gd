class_name PyramidModels
extends RefCounted

# Large top-facing shapes survive the small portrait gameplay viewport.
const GOLD := Color("e8ba61")
const PALE_GOLD := Color("ffdc86")
const LAPIS := Color("246b8a")
const DEEP_BLUE := Color("1d435f")
const TURQUOISE := Color("4bbeb6")
const SAND := Color("dfcca3")
const ONYX := Color("253943")
const RED := Color("aa5350")

static func box(parent: Node3D, size: Vector3, at: Vector3, tint: Color) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	piece.mesh = shape
	piece.position = at
	piece.material_override = Models.material(tint)
	parent.add_child(piece)
	return piece

static func ball(parent: Node3D, scale: Vector3, at: Vector3, tint: Color) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radial_segments = 10
	shape.rings = 6
	piece.mesh = shape
	piece.scale = scale
	piece.position = at
	piece.material_override = Models.material(tint)
	parent.add_child(piece)
	return piece

static func cylinder(parent: Node3D, radius: float, height: float, at: Vector3, tint: Color, sides := 10) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = sides
	piece.mesh = shape
	piece.position = at
	piece.material_override = Models.material(tint)
	parent.add_child(piece)
	return piece

static func pointed(parent: Node3D, radius: float, height: float, at: Vector3, tint: Color, sides := 4) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = 0.0
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = sides
	piece.mesh = shape
	piece.position = at
	piece.material_override = Models.material(tint)
	parent.add_child(piece)
	return piece

static func build(root: Node3D, type_id: String) -> void:
	match type_id:
		"canopic_jar":
			cylinder(root, 0.25, 0.09, Vector3(0, 0.05, 0), DEEP_BLUE)
			cylinder(root, 0.19, 0.46, Vector3(0, 0.33, 0), SAND)
			cylinder(root, 0.21, 0.08, Vector3(0, 0.55, 0), GOLD)
			cylinder(root, 0.13, 0.12, Vector3(0, 0.64, 0), LAPIS)
			ball(root, Vector3(0.17, 0.13, 0.17), Vector3(0, 0.73, 0), GOLD)
			for y in [0.27, 0.42]: cylinder(root, 0.205, 0.04, Vector3(0, y, 0), TURQUOISE)
			box(root, Vector3(0.13, 0.05, 0.025), Vector3(0, 0.37, 0.20), DEEP_BLUE)
		"pharaoh_mask":
			box(root, Vector3(0.78, 0.12, 0.63), Vector3(0, 0.07, 0), ONYX)
			box(root, Vector3(0.70, 0.08, 0.51), Vector3(0, 0.15, 0), GOLD)
			box(root, Vector3(0.72, 0.61, 0.19), Vector3(0, 0.48, -0.10), LAPIS)
			for side in [-1, 1]:
				box(root, Vector3(0.15, 0.55, 0.22), Vector3(side * 0.29, 0.43, 0.035), GOLD)
				box(root, Vector3(0.07, 0.40, 0.025), Vector3(side * 0.28, 0.45, 0.15), TURQUOISE)
				box(root, Vector3(0.095, 0.042, 0.025), Vector3(side * 0.12, 0.48, 0.17), ONYX)
			box(root, Vector3(0.34, 0.43, 0.17), Vector3(0, 0.43, 0.085), PALE_GOLD)
			box(root, Vector3(0.08, 0.17, 0.08), Vector3(0, 0.26, 0.17), GOLD)
			pointed(root, 0.085, 0.20, Vector3(0, 0.88, -0.03), TURQUOISE, 5)
		"treasure_chest":
			box(root, Vector3(0.98, 0.45, 0.66), Vector3(0, 0.24, 0), Color("675046"))
			box(root, Vector3(1.04, 0.20, 0.72), Vector3(0, 0.57, 0), Color("9a6b47"))
			box(root, Vector3(0.93, 0.035, 0.59), Vector3(0, 0.69, 0), DEEP_BLUE)
			for x in [-0.38, 0.38]:
				box(root, Vector3(0.09, 0.67, 0.75), Vector3(x, 0.37, 0), GOLD)
				box(root, Vector3(0.10, 0.055, 0.57), Vector3(x, 0.72, 0), PALE_GOLD)
			box(root, Vector3(0.27, 0.12, 0.07), Vector3(0, 0.42, 0.36), GOLD)
			for x in [-0.17, 0, 0.17]: ball(root, Vector3(0.11, 0.055, 0.1), Vector3(x, 0.72, 0.05), PALE_GOLD)
		"giant_scarab":
			box(root, Vector3(0.92, 0.13, 0.80), Vector3(0, 0.08, 0), ONYX)
			for side in [-1, 1]:
				var wing := box(root, Vector3(0.42, 0.10, 0.65), Vector3(side * 0.33, 0.30, -0.03), GOLD)
				wing.rotation_degrees.y = side * 22
				ball(root, Vector3(0.40, 0.12, 0.31), Vector3(side * 0.35, 0.39, -0.08), TURQUOISE)
			ball(root, Vector3(0.36, 0.28, 0.43), Vector3(0, 0.38, -0.04), LAPIS)
			ball(root, Vector3(0.15, 0.11, 0.15), Vector3(0, 0.59, -0.08), PALE_GOLD)
			ball(root, Vector3(0.27, 0.17, 0.23), Vector3(0, 0.31, 0.38), GOLD)
			box(root, Vector3(0.07, 0.24, 0.025), Vector3(0, 0.51, 0.00), TURQUOISE)
		"pharaoh_bust":
			box(root, Vector3(0.82, 0.18, 0.69), Vector3(0, 0.10, 0), ONYX)
			ball(root, Vector3(0.76, 0.24, 0.48), Vector3(0, 0.39, 0), GOLD)
			for side in [-1, 1]: box(root, Vector3(0.15, 0.43, 0.23), Vector3(side * 0.28, 0.78, 0.03), LAPIS)
			box(root, Vector3(0.59, 0.55, 0.41), Vector3(0, 0.91, -0.03), LAPIS)
			box(root, Vector3(0.36, 0.39, 0.31), Vector3(0, 0.9, 0.09), SAND)
			box(root, Vector3(0.54, 0.10, 0.43), Vector3(0, 1.22, -0.03), GOLD)
			for side in [-1, 1]:
				box(root, Vector3(0.095, 0.035, 0.02), Vector3(side * 0.11, 0.94, 0.26), ONYX)
				box(root, Vector3(0.05, 0.35, 0.035), Vector3(side * 0.2, 0.76, 0.25), GOLD)
			pointed(root, 0.07, 0.18, Vector3(0, 1.36, 0), TURQUOISE, 5)
		"obelisk_fragment":
			box(root, Vector3(0.78, 0.14, 0.78), Vector3(0, 0.08, 0), ONYX)
			box(root, Vector3(0.58, 1.60, 0.58), Vector3(0, 0.92, 0), Color("bb9279"))
			box(root, Vector3(0.64, 0.09, 0.64), Vector3(0, 1.72, 0), GOLD)
			pointed(root, 0.27, 0.40, Vector3(0, 1.97, 0), Color("d3a35f"))
			for y in [0.52, 0.86, 1.20, 1.54]:
				box(root, Vector3(0.27, 0.065, 0.035), Vector3(0, y, 0.31), LAPIS)
			box(root, Vector3(0.09, 0.24, 0.04), Vector3(0.17, 1.04, 0.31), TURQUOISE)
		"giant_anubis":
			box(root, Vector3(0.95, 0.21, 0.95), Vector3(0, 0.11, 0), GOLD)
			box(root, Vector3(0.74, 0.14, 0.74), Vector3(0, 0.28, 0), DEEP_BLUE)
			for side in [-1, 1]: box(root, Vector3(0.16, 0.66, 0.18), Vector3(side * 0.18, 0.65, 0.02), ONYX)
			box(root, Vector3(0.51, 0.85, 0.46), Vector3(0, 0.88, 0), ONYX)
			box(root, Vector3(0.63, 0.12, 0.52), Vector3(0, 1.23, 0), GOLD)
			box(root, Vector3(0.37, 0.39, 0.39), Vector3(0, 1.52, 0), ONYX)
			box(root, Vector3(0.2, 0.15, 0.35), Vector3(0, 1.43, 0.27), ONYX)
			for side in [-1, 1]:
				pointed(root, 0.10, 0.46, Vector3(side * 0.13, 1.93, -0.08), ONYX, 4)
				box(root, Vector3(0.065, 0.034, 0.025), Vector3(side * 0.1, 1.57, 0.21), GOLD)
			cylinder(root, 0.035, 1.6, Vector3(0.42, 0.95, 0.08), GOLD, 7)
			pointed(root, 0.12, 0.26, Vector3(0.42, 1.87, 0.08), TURQUOISE, 6)
		"golden_throne":
			box(root, Vector3(1.10, 0.41, 0.95), Vector3(0, 0.22, 0.04), Color("977955"))
			box(root, Vector3(1.0, 0.13, 0.84), Vector3(0, 0.49, 0.08), RED)
			box(root, Vector3(1.13, 1.31, 0.20), Vector3(0, 1.05, -0.37), GOLD)
			box(root, Vector3(0.87, 1.02, 0.045), Vector3(0, 1.06, -0.25), LAPIS)
			for side in [-1, 1]:
				box(root, Vector3(0.13, 0.53, 0.92), Vector3(side * 0.52, 0.65, 0.10), GOLD)
				box(root, Vector3(0.15, 0.13, 0.17), Vector3(side * 0.52, 0.96, 0.47), PALE_GOLD)
				box(root, Vector3(0.11, 0.67, 0.07), Vector3(side * 0.53, 1.13, -0.21), PALE_GOLD)
				ball(root, Vector3(0.16, 0.09, 0.16), Vector3(side * 0.26, 1.74, -0.37), TURQUOISE)
			box(root, Vector3(0.51, 0.19, 0.16), Vector3(0, 1.75, -0.36), PALE_GOLD)
			for x in [-0.27, 0, 0.27]: box(root, Vector3(0.10, 0.05, 0.03), Vector3(x, 1.25, -0.20), GOLD)
		"sarcophagus":
			# Recumbent painted lid; the level rotates it across the burial chamber.
			box(root, Vector3(0.78, 0.43, 1.61), Vector3(0, 0.24, 0), Color("a97f57"))
			box(root, Vector3(0.87, 0.19, 1.69), Vector3(0, 0.55, 0), GOLD)
			box(root, Vector3(0.66, 0.06, 1.35), Vector3(0, 0.67, 0.12), LAPIS)
			for z in [-0.16, 0.08, 0.32, 0.56]:
				box(root, Vector3(0.72, 0.075, 0.09), Vector3(0, 0.72, z), PALE_GOLD)
			for side in [-1, 1]:
				box(root, Vector3(0.095, 0.13, 1.66), Vector3(side * 0.41, 0.58, 0), DEEP_BLUE)
				box(root, Vector3(0.14, 0.08, 0.50), Vector3(side * 0.29, 0.74, -0.46), GOLD)
			ball(root, Vector3(0.27, 0.11, 0.29), Vector3(0, 0.75, -0.54), PALE_GOLD)
			for side in [-1, 1]: box(root, Vector3(0.07, 0.02, 0.04), Vector3(side * 0.105, 0.84, -0.59), ONYX)
			box(root, Vector3(0.09, 0.04, 0.07), Vector3(0, 0.84, -0.41), GOLD)
