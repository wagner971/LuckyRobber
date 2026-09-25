class_name LabModels
extends RefCounted

# Nine silhouettes made only for Laboratory. A base, a recognizable working part,
# and one bright functional accent keep each readable at the gameplay camera size.
static func build(root: Node3D, type_id: String) -> void:
	var graphite := Color("273d4d")
	var steel := Color("839da7")
	var white := Color("d9e9e5")
	var cyan := Color("68e0d5")
	var amber := Color("eec46d")
	match type_id:
		"lab_microscope":
			b(root, Vector3(0.64, 0.10, 0.52), Vector3(0, 0.07, 0), graphite)
			b(root, Vector3(0.46, 0.06, 0.37), Vector3(0, 0.35, 0), steel)
			b(root, Vector3(0.11, 0.42, 0.12), Vector3(-0.19, 0.35, -0.12), white)
			var arm = b(root, Vector3(0.13, 0.54, 0.13), Vector3(0.05, 0.72, -0.10), white)
			arm.rotation.z = 0.48
			c(root, 0.11, 0.20, Vector3(0.21, 0.92, -0.10), graphite).rotation.z = PI / 2.0
			b(root, Vector3(0.25, 0.035, 0.24), Vector3(0, 0.39, 0), cyan)
		"lab_analyzer":
			b(root, Vector3(0.78, 0.66, 0.64), Vector3(0, 0.36, 0), white)
			b(root, Vector3(0.60, 0.27, 0.035), Vector3(0, 0.49, 0.34), graphite)
			b(root, Vector3(0.46, 0.13, 0.04), Vector3(0, 0.50, 0.365), cyan)
			for x in [-0.22, 0.0, 0.22]: c(root, 0.055, 0.18, Vector3(x, 0.79, -0.04), amber)
			b(root, Vector3(0.52, 0.07, 0.14), Vector3(0, 0.22, 0.35), steel)
		"lab_centrifuge":
			b(root, Vector3(1.03, 0.22, 1.03), Vector3(0, 0.12, 0), graphite)
			c(root, 0.42, 0.69, Vector3(0, 0.55, 0), white)
			c(root, 0.44, 0.10, Vector3(0, 0.96, 0), steel)
			c(root, 0.23, 0.035, Vector3(0, 1.02, 0), cyan)
			for x in [-0.28, 0.28]: b(root, Vector3(0.12, 0.08, 0.12), Vector3(x, 0.27, 0.44), amber)
		"lab_server":
			b(root, Vector3(1.00, 1.65, 0.69), Vector3(0, 0.84, 0), graphite)
			b(root, Vector3(0.83, 1.50, 0.035), Vector3(0, 0.84, 0.36), steel)
			for y in [0.29, 0.54, 0.79, 1.04, 1.29, 1.54]:
				b(root, Vector3(0.67, 0.16, 0.045), Vector3(0, y, 0.39), graphite)
				b(root, Vector3(0.13, 0.035, 0.05), Vector3(0.21, y, 0.42), cyan)
		"lab_robot_arm":
			b(root, Vector3(1.12, 0.19, 1.02), Vector3(0, 0.10, 0), graphite)
			c(root, 0.28, 0.36, Vector3(0, 0.36, 0), steel)
			var lower = b(root, Vector3(0.23, 0.75, 0.27), Vector3(0.19, 0.83, 0), amber)
			lower.rotation.z = -0.42
			c(root, 0.18, 0.27, Vector3(0.37, 1.16, 0), graphite).rotation.x = PI / 2.0
			var upper = b(root, Vector3(0.20, 0.68, 0.24), Vector3(0.59, 1.38, 0), steel)
			upper.rotation.z = 0.82
			for z in [-0.16, 0.16]: b(root, Vector3(0.14, 0.30, 0.09), Vector3(0.88, 1.37, z), graphite)
		"lab_laser":
			b(root, Vector3(1.08, 0.21, 0.92), Vector3(0, 0.11, 0), graphite)
			b(root, Vector3(0.19, 0.67, 0.19), Vector3(0, 0.52, 0), steel)
			var tube = c(root, 0.21, 1.03, Vector3(0, 0.86, 0), white)
			tube.rotation.z = PI / 2.0
			c(root, 0.26, 0.11, Vector3(0.55, 0.86, 0), amber).rotation.z = PI / 2.0
			b(root, Vector3(0.06, 0.44, 0.44), Vector3(0.62, 0.86, 0), cyan)
		"lab_specimen":
			b(root, Vector3(1.00, 0.19, 0.94), Vector3(0, 0.10, 0), graphite)
			for x in [-0.39, 0.39]:
				for z in [-0.36, 0.36]: b(root, Vector3(0.075, 1.22, 0.075), Vector3(x, 0.81, z), steel)
			b(root, Vector3(0.84, 1.14, 0.68), Vector3(0, 0.80, 0), Color("69c2c1", 0.64))
			Models.ball(root, Vector3(0.28, 0.44, 0.22), Vector3(0, 0.79, 0), Color("d3de86"))
			b(root, Vector3(1.02, 0.15, 0.96), Vector3(0, 1.50, 0), graphite)
		"lab_cryo_pod":
			b(root, Vector3(1.08, 0.28, 1.72), Vector3(0, 0.15, 0), graphite)
			b(root, Vector3(0.90, 0.43, 1.50), Vector3(0, 0.47, 0), white)
			b(root, Vector3(0.70, 0.07, 1.25), Vector3(0, 0.72, 0), cyan)
			for x in [-0.49, 0.49]: b(root, Vector3(0.11, 0.42, 1.55), Vector3(x, 0.55, 0), steel)
			b(root, Vector3(0.46, 0.16, 0.19), Vector3(0, 0.84, -0.57), graphite)
			b(root, Vector3(0.30, 0.055, 0.05), Vector3(0, 0.84, -0.47), amber)
		"lab_quantum_core":
			b(root, Vector3(1.34, 0.22, 1.34), Vector3(0, 0.12, 0), graphite)
			for x in [-0.52, 0.52]:
				for z in [-0.52, 0.52]: b(root, Vector3(0.12, 1.28, 0.12), Vector3(x, 0.77, z), steel)
			b(root, Vector3(1.38, 0.14, 1.38), Vector3(0, 1.48, 0), graphite)
			Models.ball(root, Vector3(0.72, 0.72, 0.72), Vector3(0, 0.84, 0), cyan)
			for z in [-0.59, 0.59]: b(root, Vector3(0.85, 0.10, 0.13), Vector3(0, 0.82, z), amber)
			for x in [-0.59, 0.59]: b(root, Vector3(0.13, 0.10, 0.85), Vector3(x, 0.82, 0), amber)


static func b(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	return Models.box(parent, size, at, color)


static func c(parent: Node3D, radius: float, height: float, at: Vector3, color: Color) -> MeshInstance3D:
	return Models.cylinder(parent, radius, height, at, color)
