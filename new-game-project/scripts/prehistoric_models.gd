class_name PrehistoricModels
extends RefCounted

const BONE = Color("dfcc9e")
const ROCK = Color("7f8171")
const WOOD = Color("77513a")
const HIDE = Color("b98654")
const DARK = Color("394442")

static func beam(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color) -> MeshInstance3D:
	return PirateModels.beam(root,a,b,width,color)

static func build(root: Node3D, type_id: String) -> void:
	match type_id:
		"prehistoric_skull":
			Models.ball(root,Vector3(1.4,1.22,1.08),Vector3(0,0.82,-0.14),BONE)
			Models.box(root,Vector3(0.40,0.65,0.40),Vector3(0,0.55,0.49),BONE)
			for side in [-1,1]:
				Models.ball(root,Vector3(0.34,0.30,0.12),Vector3(side*0.42,0.96,0.36),DARK)
				var points = [Vector3(side*0.48,0.55,0.35),Vector3(side*0.71,0.32,0.65),Vector3(side*0.82,0.25,1.02),Vector3(side*0.74,0.50,1.30),Vector3(side*0.53,0.83,1.44)]
				for i in range(points.size()-1): beam(root,points[i],points[i+1],0.19-i*0.035,BONE)
			Models.box(root,Vector3(0.17,0.23,0.04),Vector3(0,0.67,0.715),DARK)
		"prehistoric_saber":
			Models.box(root,Vector3(1.18,0.16,0.85),Vector3(0,0.08,0),ROCK)
			Models.ball(root,Vector3(0.94,0.68,0.76),Vector3(0,0.56,0),BONE)
			Models.box(root,Vector3(0.70,0.24,0.40),Vector3(0,0.40,0.30),BONE)
			for side in [-1,1]:
				Models.ball(root,Vector3(0.22,0.20,0.12),Vector3(side*0.25,0.67,0.33),DARK)
				var tooth = Models.cylinder(root,0.075,0.40,Vector3(side*0.27,0.30,0.49),BONE)
				tooth.mesh = tooth.mesh.duplicate()
				tooth.mesh.bottom_radius = 0.015
		"prehistoric_mortar":
			Models.ball(root,Vector3(1.11,0.71,0.99),Vector3(0,0.34,0),ROCK)
			Models.cylinder(root,0.40,0.06,Vector3(0,0.63,0),Color("4b5449"))
			Models.cylinder(root,0.31,0.012,Vector3(0,0.665,0),Color("a29564"))
			beam(root,Vector3(-0.22,0.70,0.1),Vector3(0.35,0.91,-0.13),0.18,Color("adb19e"))
		"prehistoric_hide":
			for side in [-1,1]:
				beam(root,Vector3(side*0.7,0.03,0.22),Vector3(side*0.64,1.76,-0.05),0.09,WOOD)
				beam(root,Vector3(side*0.7,0.03,-0.35),Vector3(side*0.64,1.4,-0.05),0.075,WOOD)
			for y in [0.42,1.64]: beam(root,Vector3(-0.79,y,0),Vector3(0.79,y,0),0.09,WOOD)
			Models.box(root,Vector3(1.13,0.92,0.065),Vector3(0,1.1,0),HIDE)
			for side in [-1,1]:
				for y in [0.64,1.5]: Models.box(root,Vector3(0.34,0.20,0.07),Vector3(side*0.51,y,0),HIDE).rotation.z = side*0.4
			for x in [-0.4,0.0,0.4]: beam(root,Vector3(x,1.53,0.03),Vector3(x,1.69,0.03),0.027,BONE)
		"prehistoric_spear":
			Models.ball(root,Vector3(0.58,0.22,0.44),Vector3(0,0.1,0),ROCK)
			beam(root,Vector3(-0.17,0.1,0),Vector3(0.15,1.54,0),0.065,WOOD)
			var tip = Models.cylinder(root,0.13,0.36,Vector3(0.18,1.68,0),Color("6d9294"))
			tip.mesh = tip.mesh.duplicate()
			tip.mesh.top_radius = 0
			tip.rotation.z = -0.22
			for y in [1.38,1.43,1.48]: Models.box(root,Vector3(0.105,0.025,0.10),Vector3(0.13,y,0),BONE)
		"prehistoric_drum":
			Models.cylinder(root,0.38,0.63,Vector3(0,0.34,0),WOOD)
			Models.cylinder(root,0.42,0.08,Vector3(0,0.7,0),HIDE)
			for i in range(8):
				var a = i*TAU/8
				beam(root,Vector3(sin(a)*0.4,0.65,cos(a)*0.4),Vector3(sin(a+0.4)*0.37,0.12,cos(a+0.4)*0.37),0.025,BONE)
			beam(root,Vector3(-0.22,0.76,0.1),Vector3(0.22,0.76,-0.1),0.045,WOOD)
		"prehistoric_amber":
			Models.ball(root,Vector3(0.54,0.61,0.43),Vector3(0,0.32,0),Color("eea438"))
			Models.box(root,Vector3(0.11,0.19,0.018),Vector3(0,0.34,0.215),Color("68422c"))
			for side in [-1,1]:
				beam(root,Vector3(0,0.35,0.23),Vector3(side*0.15,0.46,0.23),0.02,Color("68422c"))
				beam(root,Vector3(0,0.3,0.23),Vector3(side*0.12,0.22,0.23),0.02,Color("68422c"))
			Models.box(root,Vector3(0.10,0.16,0.025),Vector3(-0.14,0.49,0.14),Color("ffe49a"))
		"prehistoric_painting":
			Models.box(root,Vector3(1.18,1.27,0.25),Vector3(0,0.70,0),Color("b59a72"))
			Models.ball(root,Vector3(0.83,0.34,0.06),Vector3(0,0.77,0.145),Color("874638"))
			Models.box(root,Vector3(0.20,0.28,0.035),Vector3(0.4,0.71,0.15),Color("874638"))
			for x in [-0.24,0.22]: beam(root,Vector3(x,0.73,0.16),Vector3(x-0.06,0.39,0.16),0.045,Color("874638"))
			beam(root,Vector3(0.40,0.83,0.17),Vector3(0.52,1.0,0.17),0.035,BONE)
			for x in [-0.32,-0.1,0.14]: Models.ball(root,Vector3.ONE*0.05,Vector3(x,1.12,0.16),Color("874638"))
		"prehistoric_fur":
			Models.box(root,Vector3(0.78,0.24,0.67),Vector3(0,0.17,0),Color("805a42"))
			Models.cylinder(root,0.26,0.76,Vector3(0,0.42,0),HIDE).rotation.z = PI/2
			for x in [-0.23,0.23]:
				var band = PirateModels.ring(root,0.275,Vector3(x,0.42,0),BONE)
				band.rotation.z = PI/2
		"prehistoric_necklace":
			Models.box(root,Vector3(0.52,0.065,0.48),Vector3(0,0.04,0),HIDE)
			PirateModels.ring(root,0.19,Vector3(0,0.10,0),WOOD)
			for i in range(9):
				var a = i*TAU/9
				Models.ball(root,Vector3(0.085,0.055,0.11),Vector3(sin(a)*0.20,0.125,cos(a)*0.20),BONE)
			Models.box(root,Vector3(0.08,0.04,0.17),Vector3(0,0.11,0.25),BONE)
