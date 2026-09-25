class_name PirateModels
extends RefCounted

const WOOD = Color("75462f")
const GOLD = Color("e9b952")
const IRON = Color("293b49")
const ROPE = Color("c9af79")

static func beam(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color) -> MeshInstance3D:
	var mesh = Models.box(root, Vector3(width, a.distance_to(b), width), (a+b)*0.5, color)
	mesh.quaternion = Quaternion(Vector3.UP, (b-a).normalized())
	return mesh

static func ring(root: Node3D, radius: float, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = radius*0.76
	torus.outer_radius = radius
	torus.rings = 16
	torus.ring_segments = 6
	mesh.mesh = torus
	mesh.material_override = Models.material(color)
	root.add_child(mesh)
	mesh.position = at
	return mesh

static func build(root: Node3D, type_id: String) -> void:
	match type_id:
		"pirate_spyglass":
			for angle in [0.0, 2.094, 4.188]:
				beam(root, Vector3(sin(angle)*0.3,0.02,cos(angle)*0.3), Vector3(0,0.85,0), 0.055, WOOD)
			Models.cylinder(root,0.11,0.62,Vector3(0,0.93,0),GOLD).rotation.x = PI/2
			Models.cylinder(root,0.14,0.14,Vector3(0,0.93,0.34),IRON).rotation.x = PI/2
			Models.cylinder(root,0.105,0.015,Vector3(0,0.93,0.42),Color("53cedb")).rotation.x = PI/2
		"pirate_sextant":
			Models.box(root,Vector3(0.48,0.07,0.32),Vector3(0,0.04,0),WOOD)
			for i in range(8):
				var a = -0.85+float(i)*0.21
				beam(root,Vector3(sin(a)*0.32,0.49-cos(a)*0.32,0),Vector3(sin(a+0.21)*0.32,0.49-cos(a+0.21)*0.32,0),0.045,GOLD)
			for x in [-0.25,0.25]: beam(root,Vector3(0,0.49,0),Vector3(x,0.21,0),0.045,GOLD)
			beam(root,Vector3(-0.13,0.08,0),Vector3(0.13,0.51,0),0.06,IRON)
			Models.cylinder(root,0.05,0.30,Vector3(0,0.48,0),GOLD).rotation.z = PI/2
		"pirate_compass":
			Models.box(root,Vector3(0.49,0.12,0.49),Vector3(0,0.07,0),WOOD)
			Models.cylinder(root,0.22,0.07,Vector3(0,0.16,0),GOLD)
			Models.cylinder(root,0.18,0.012,Vector3(0,0.202,0),Color("f2e2ae"))
			Models.box(root,Vector3(0.045,0.02,0.28),Vector3(0,0.22,0),Color("b03939")).rotation.y = 0.5
			for i in range(4):
				var a = i*PI/2
				Models.box(root,Vector3(0.025,0.02,0.04),Vector3(sin(a)*0.145,0.22,cos(a)*0.145),IRON)
		"pirate_parrot":
			Models.cylinder(root,0.34,0.10,Vector3(0,0.05,0),WOOD)
			beam(root,Vector3(0,0.1,0),Vector3(0,0.9,0),0.075,GOLD)
			beam(root,Vector3(-0.3,0.86,0),Vector3(0.3,0.86,0),0.065,WOOD)
			Models.box(root,Vector3(0.30,0.46,0.27),Vector3(0,1.11,0),Color("ce4048"))
			Models.box(root,Vector3(0.29,0.27,0.28),Vector3(0,1.43,0.055),Color("e14d4b"))
			Models.box(root,Vector3(0.13,0.13,0.18),Vector3(0,1.39,0.23),GOLD)
			Models.box(root,Vector3(0.13,0.42,0.07),Vector3(0,0.84,-0.14),Color("2e81b5")).rotation.x = -0.35
			for side in [-1,1]:
				Models.box(root,Vector3(0.06,0.34,0.24),Vector3(side*0.18,1.12,-0.035),Color("2b9f96"))
				Models.box(root,Vector3(0.014,0.075,0.07),Vector3(side*0.151,1.47,0.14),Color("f9ecd5"))
		"pirate_rum":
			Models.cylinder(root,0.46,0.95,Vector3(0,0.5,0),WOOD)
			for y in [0.12,0.82]: Models.cylinder(root,0.475,0.09,Vector3(0,y,0),IRON)
			Models.cylinder(root,0.40,0.045,Vector3(0,1,0),Color("ad7644"))
			Models.box(root,Vector3(0.30,0.25,0.025),Vector3(0,0.5,0.465),Color("dcc28a"))
			Models.box(root,Vector3(0.08,0.16,0.03),Vector3(0,0.5,0.49),Color("713927"))
		"pirate_cannon":
			Models.box(root,Vector3(1.10,0.27,0.67),Vector3(0,0.30,0),WOOD)
			for x in [-0.42,0.42]:
				for z in [-0.43,0.43]:
					Models.cylinder(root,0.26,0.13,Vector3(x,0.27,z),IRON).rotation.x = PI/2
			Models.cylinder(root,0.25,1.65,Vector3(-0.12,0.67,0),IRON).rotation.z = PI/2
			Models.cylinder(root,0.285,0.12,Vector3(-0.98,0.67,0),GOLD).rotation.z = PI/2
			Models.cylinder(root,0.205,0.013,Vector3(-1.047,0.67,0),Color("101b26")).rotation.z = PI/2
			Models.ball(root,Vector3(0.37,0.37,0.37),Vector3(0.7,0.67,0),IRON)
		"pirate_anchor":
			ring(root,0.18,Vector3(0,1.58,0),GOLD).rotation.x = PI/2
			beam(root,Vector3(0,0.25,0),Vector3(0,1.45,0),0.14,IRON)
			beam(root,Vector3(-0.4,1.17,0),Vector3(0.4,1.17,0),0.14,WOOD)
			for s in [-1,1]:
				beam(root,Vector3(0,0.25,0),Vector3(s*0.52,0.46,0),0.15,IRON)
				beam(root,Vector3(s*0.52,0.46,0),Vector3(s*0.57,0.76,0),0.17,IRON)
				Models.box(root,Vector3(0.28,0.14,0.16),Vector3(s*0.51,0.71,0),GOLD).rotation.z = s*0.5
			Models.box(root,Vector3(0.8,0.1,0.6),Vector3(0,0.05,0),WOOD)
		"pirate_wheel":
			Models.box(root,Vector3(0.8,0.12,0.65),Vector3(0,0.06,0),WOOD)
			Models.box(root,Vector3(0.16,1.05,0.17),Vector3(0,0.6,-0.12),WOOD)
			ring(root,0.5,Vector3(0,1.12,0),WOOD).rotation.x = PI/2
			for i in range(8):
				var a = i*TAU/8
				beam(root,Vector3(0,1.12,0),Vector3(sin(a)*0.64,1.12+cos(a)*0.64,0),0.07,GOLD)
			Models.cylinder(root,0.13,0.16,Vector3(0,1.12,0),GOLD).rotation.x = PI/2
		"pirate_chest":
			Models.box(root,Vector3(1.38,0.62,0.88),Vector3(0,0.36,0),WOOD)
			for i in range(3): Models.box(root,Vector3(1.38,0.13,0.88-i*0.18),Vector3(0,0.73+i*0.10,0),Color("915835"))
			for x in [-0.5,0.5]:
				Models.box(root,Vector3(0.09,0.76,0.92),Vector3(x,0.44,0),GOLD)
			Models.box(root,Vector3(0.23,0.23,0.075),Vector3(0,0.55,0.49),GOLD)
			Models.box(root,Vector3(0.05,0.09,0.02),Vector3(0,0.54,0.54),IRON)
			for x in [-0.36,0.0,0.36]: Models.cylinder(root,0.14,0.035,Vector3(x,1.01,0),GOLD)
		"pirate_figurehead":
			Models.box(root,Vector3(0.94,0.19,0.8),Vector3(0,0.10,0),IRON)
			Models.ball(root,Vector3(0.68,0.87,0.60),Vector3(0,1.0,0),GOLD)
			for i in range(8):
				var a = i*TAU/8
				var p = Vector3(sin(a)*0.53,0.33,cos(a)*0.46)
				beam(root,Vector3(0,0.82,0),p,0.14,GOLD)
				beam(root,p,p+Vector3(sin(a)*0.10,0.20,cos(a)*0.10),0.12,GOLD)
			for x in [-0.17,0.17]: Models.box(root,Vector3(0.10,0.12,0.045),Vector3(x,1.07,0.3),Color("24bfae"))
