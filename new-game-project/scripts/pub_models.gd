class_name PubModels
extends RefCounted

const WOOD = Color("674332")
const BRASS = Color("d3ad64")
const DARK = Color("263633")
const CREAM = Color("e6d7ad")

static func beam(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color) -> MeshInstance3D:
	return PirateModels.beam(root,a,b,width,color)

static func build(root: Node3D, type_id: String) -> void:
	match type_id:
		"pub_billiards":
			for x in [-0.75,0.75]:
				for z in [-1.05,1.05]: Models.box(root,Vector3(0.21,0.85,0.21),Vector3(x,0.43,z),WOOD)
			Models.box(root,Vector3(1.95,0.28,2.8),Vector3(0,0.90,0),WOOD)
			Models.box(root,Vector3(1.66,0.06,2.49),Vector3(0,1.07,0),Color("286c50"))
			for x in [-0.86,0.86]:
				for z in [-1.23,0.0,1.23]: Models.cylinder(root,0.1,0.014,Vector3(x,1.108,z),Color("101d23"))
			for data in [[Vector3(-0.4,1.16,0.8),CREAM],[Vector3(0.1,1.16,-0.6),Color("9e3638")],[Vector3(0.26,1.16,-0.6),Color("e4b748")]]:
				Models.ball(root,Vector3.ONE*0.12,data[0],data[1])
			beam(root,Vector3(-0.6,1.13,1.0),Vector3(0.35,1.13,-0.1),0.035,CREAM)
		"pub_clock":
			Models.box(root,Vector3(0.80,0.17,0.55),Vector3(0,0.09,0),WOOD)
			Models.box(root,Vector3(0.58,1.8,0.40),Vector3(0,1.03,0),WOOD)
			Models.box(root,Vector3(0.34,1.06,0.025),Vector3(0,0.94,0.22),DARK)
			beam(root,Vector3(0,0.62,0.25),Vector3(0,1.34,0.25),0.035,BRASS)
			Models.cylinder(root,0.13,0.035,Vector3(0,0.66,0.25),BRASS).rotation.x = PI/2
			Models.box(root,Vector3(0.76,0.62,0.49),Vector3(0,1.93,0),WOOD)
			Models.cylinder(root,0.25,0.025,Vector3(0,1.97,0.265),CREAM).rotation.x = PI/2
			beam(root,Vector3(0,1.97,0.288),Vector3(0,2.14,0.288),0.025,DARK)
			beam(root,Vector3(0,1.97,0.288),Vector3(0.13,1.93,0.288),0.025,DARK)
			Models.box(root,Vector3(0.85,0.12,0.56),Vector3(0,2.30,0),BRASS)
		"pub_settee":
			var leather = Color("69373a")
			for x in [-0.88,0.88]:
				for z in [-0.31,0.31]: Models.box(root,Vector3(0.14,0.18,0.14),Vector3(x,0.1,z),WOOD)
			Models.box(root,Vector3(2.0,0.43,0.94),Vector3(0,0.4,0),leather)
			Models.box(root,Vector3(1.95,0.70,0.24),Vector3(0,0.8,-0.40),leather)
			for x in [-0.9,0.9]: Models.cylinder(root,0.19,1.02,Vector3(x,0.77,0),leather).rotation.x = PI/2
			for x in [-0.60,-0.2,0.2,0.6]:
				for y in [0.72,0.97]: Models.ball(root,Vector3.ONE*0.055,Vector3(x,y,-0.265),BRASS)
			Models.box(root,Vector3(0.04,0.02,0.63),Vector3(0,0.63,0),WOOD)
		"pub_register":
			Models.box(root,Vector3(0.83,0.21,0.64),Vector3(0,0.11,0),BRASS)
			Models.box(root,Vector3(0.68,0.41,0.39),Vector3(0,0.40,-0.06),BRASS)
			Models.box(root,Vector3(0.65,0.17,0.16),Vector3(0,0.72,-0.12),DARK)
			Models.box(root,Vector3(0.48,0.09,0.02),Vector3(0,0.73,-0.025),CREAM)
			Models.box(root,Vector3(0.63,0.035,0.03),Vector3(0,0.14,0.335),WOOD)
			for x in [-0.23,-0.08,0.08,0.23]:
				for z in [0.1,0.25]: Models.cylinder(root,0.037,0.06,Vector3(x,0.33,z),CREAM)
		"pub_beer_engine":
			Models.box(root,Vector3(0.72,0.09,0.44),Vector3(0,0.05,0),BRASS)
			for x in [-0.21,0.21]:
				Models.cylinder(root,0.08,0.54,Vector3(x,0.32,0),BRASS)
				beam(root,Vector3(x,0.55,0),Vector3(x,0.83,-0.12),0.065,WOOD)
				Models.ball(root,Vector3(0.16,0.22,0.14),Vector3(x,0.88,-0.14),CREAM)
				beam(root,Vector3(x,0.35,0),Vector3(x,0.35,0.22),0.055,BRASS)
		"pub_gramophone":
			Models.box(root,Vector3(0.64,0.22,0.57),Vector3(0,0.12,0),WOOD)
			Models.cylinder(root,0.22,0.035,Vector3(0,0.25,0.03),DARK)
			beam(root,Vector3(0.23,0.28,-0.16),Vector3(0.23,0.72,-0.16),0.065,BRASS)
			var horn = Models.cylinder(root,0.36,0.58,Vector3(0.10,0.78,0.01),BRASS)
			horn.mesh = horn.mesh.duplicate()
			horn.mesh.bottom_radius = 0.065
			horn.rotation.x = 0.95
			Models.cylinder(root,0.3,0.015,Vector3(0.10,0.95,0.25),Color("654929")).rotation.x = 0.95
			beam(root,Vector3(0.35,0.11,0),Vector3(0.48,0.11,0),0.045,BRASS)
		"pub_radio":
			Models.box(root,Vector3(0.79,0.48,0.35),Vector3(0,0.25,0),WOOD)
			Models.box(root,Vector3(0.72,0.12,0.33),Vector3(0,0.53,0),WOOD)
			Models.box(root,Vector3(0.61,0.27,0.035),Vector3(0,0.33,0.19),Color("b49c6e"))
			for x in [-0.23,-0.12,0.0,0.12,0.23]: Models.box(root,Vector3(0.026,0.27,0.02),Vector3(x,0.33,0.215),DARK)
			for x in [-0.23,0.23]: Models.cylinder(root,0.055,0.04,Vector3(x,0.11,0.20),BRASS).rotation.x = PI/2
		"pub_darts":
			Models.box(root,Vector3(0.64,0.11,0.45),Vector3(0,0.06,0),WOOD)
			beam(root,Vector3(0,0.1,0),Vector3(0,1.45,0),0.09,WOOD)
			Models.box(root,Vector3(1.08,1.04,0.10),Vector3(0,1.26,-0.03),WOOD)
			for data in [[0.46,DARK],[0.38,CREAM],[0.30,Color("387461")],[0.23,DARK],[0.11,Color("a44236")]]:
				Models.cylinder(root,data[0],0.018,Vector3(0,1.27,0.04+(0.46-data[0])*0.06),data[1]).rotation.x = PI/2
			for i in range(10):
				var a = i*TAU/10
				beam(root,Vector3(sin(a)*0.13,1.27+cos(a)*0.13,0.085),Vector3(sin(a)*0.45,1.27+cos(a)*0.45,0.085),0.013,BRASS)
			Models.cylinder(root,0.035,0.03,Vector3(0,1.27,0.10),Color("be5b45")).rotation.x = PI/2
		"pub_tankard":
			Models.box(root,Vector3(0.45,0.09,0.42),Vector3(0,0.045,0),WOOD)
			Models.cylinder(root,0.16,0.40,Vector3(0,0.29,0),BRASS)
			Models.cylinder(root,0.19,0.05,Vector3(0,0.52,0),CREAM)
			PirateModels.ring(root,0.16,Vector3(0.21,0.3,0),BRASS).rotation.x = PI/2
			Models.box(root,Vector3(0.16,0.16,0.025),Vector3(0,0.3,0.16),CREAM)
		"pub_sign":
			for x in [-0.48,0.48]: Models.box(root,Vector3(0.10,1.5,0.1),Vector3(x,0.76,0),WOOD)
			Models.box(root,Vector3(1.2,0.9,0.13),Vector3(0,1.06,0),BRASS)
			Models.box(root,Vector3(1.07,0.77,0.025),Vector3(0,1.06,0.08),Color("244e44"))
			Models.box(root,Vector3(0.37,0.24,0.045),Vector3(0,1.16,0.11),Color("dca064"))
			for x in [-0.16,0.16]: Models.box(root,Vector3(0.09,0.19,0.04),Vector3(x,1.33,0.11),Color("dca064")).rotation.z = -signf(x)*0.3
			Models.box(root,Vector3(0.17,0.12,0.05),Vector3(0,1.03,0.13),CREAM)
			Models.box(root,Vector3(0.73,0.06,0.03),Vector3(0,0.82,0.11),CREAM)
