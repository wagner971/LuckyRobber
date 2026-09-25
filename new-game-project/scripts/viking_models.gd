class_name VikingModels
extends RefCounted

const WOOD = Color("76503c")
const IRON = Color("536572")
const GOLD = Color("d4a957")
const BLUE = Color("365f78")
const IVORY = Color("e8dec3")

static func beam(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color) -> MeshInstance3D:
	return PirateModels.beam(root,a,b,width,color)

static func build(root: Node3D, type_id: String) -> void:
	match type_id:
		"viking_runestone":
			Models.box(root,Vector3(1.1,0.16,0.8),Vector3(0,0.08,0),Color("52616a"))
			Models.box(root,Vector3(0.81,1.5,0.48),Vector3(0,0.91,0),Color("879c9e"))
			Models.box(root,Vector3(0.65,0.21,0.44),Vector3(0,1.75,0),Color("879c9e"))
			for y in [0.54,0.97,1.4]:
				beam(root,Vector3(-0.1,y-0.15,0.253),Vector3(-0.1,y+0.16,0.253),0.032,Color("84e1d6"))
				beam(root,Vector3(-0.1,y+0.15,0.253),Vector3(0.14,y,0.253),0.032,Color("84e1d6"))
				beam(root,Vector3(-0.1,y-0.12,0.253),Vector3(0.14,y,0.253),0.032,Color("84e1d6"))
		"viking_anvil":
			Models.cylinder(root,0.47,0.52,Vector3(0,0.27,0),WOOD)
			Models.box(root,Vector3(0.72,0.15,0.48),Vector3(0,0.59,0),IRON)
			Models.box(root,Vector3(0.35,0.29,0.31),Vector3(0,0.80,0),IRON)
			Models.box(root,Vector3(0.82,0.18,0.42),Vector3(0,1.0,0),Color("889ba6"))
			var horn = Models.cylinder(root,0.16,0.52,Vector3(-0.63,1.0,0),IRON)
			horn.mesh = horn.mesh.duplicate()
			horn.mesh.top_radius = 0.025
			horn.rotation.z = PI/2
		"viking_shield":
			Models.box(root,Vector3(0.65,0.1,0.55),Vector3(0,0.05,0),WOOD)
			beam(root,Vector3(0,0.1,-0.1),Vector3(0,1.0,-0.1),0.09,WOOD)
			Models.cylinder(root,0.54,0.13,Vector3(0,0.84,0),IRON).rotation.x = PI/2
			Models.cylinder(root,0.47,0.15,Vector3(0,0.84,0),BLUE).rotation.x = PI/2
			Models.box(root,Vector3(0.09,0.87,0.035),Vector3(0,0.84,0.1),IVORY)
			Models.box(root,Vector3(0.87,0.09,0.035),Vector3(0,0.84,0.1),IVORY)
			Models.ball(root,Vector3(0.28,0.28,0.16),Vector3(0,0.84,0.14),GOLD)
		"viking_axe":
			Models.box(root,Vector3(0.60,0.12,0.46),Vector3(0,0.06,0),WOOD)
			beam(root,Vector3(-0.20,0.15,0),Vector3(0.15,1.43,0),0.095,WOOD)
			Models.box(root,Vector3(0.55,0.35,0.09),Vector3(0.10,1.19,0),IRON)
			Models.box(root,Vector3(0.15,0.49,0.10),Vector3(0.4,1.13,0),Color("c1d4d9")).rotation.z = -0.18
			Models.box(root,Vector3(0.14,0.12,0.12),Vector3(0.11,1.33,0),GOLD)
		"viking_helmet":
			Models.ball(root,Vector3(0.60,0.50,0.52),Vector3(0,0.22,0),IRON)
			Models.cylinder(root,0.29,0.075,Vector3(0,0.13,0),GOLD)
			Models.box(root,Vector3(0.06,0.25,0.035),Vector3(0,0.16,0.265),GOLD)
			Models.box(root,Vector3(0.045,0.12,0.4),Vector3(0,0.44,-0.02),GOLD)
		"viking_horn":
			Models.box(root,Vector3(0.48,0.055,0.31),Vector3(0,0.035,0),WOOD)
			for i in range(5):
				var segment = Models.cylinder(root,0.12-float(i)*0.019,0.16,Vector3(0.18-i*0.085,0.40-i*0.055,0),IVORY)
				segment.rotation.z = float(i)*0.22+0.3
			Models.cylinder(root,0.13,0.06,Vector3(0.205,0.48,0),GOLD).rotation.z = 0.3
			beam(root,Vector3(-0.1,0.06,0),Vector3(0.03,0.25,0),0.045,GOLD)
		"viking_cauldron":
			for x in [-0.44,0.44]: beam(root,Vector3(x,0.04,0),Vector3(x*0.6,0.40,0),0.09,IRON)
			Models.ball(root,Vector3(1.05,0.8,0.83),Vector3(0,0.57,0),IRON)
			Models.cylinder(root,0.44,0.1,Vector3(0,0.90,0),IRON)
			Models.cylinder(root,0.37,0.015,Vector3(0,0.956,0),Color("9d7134"))
			for x in [-0.55,0.55]: PirateModels.ring(root,0.13,Vector3(x,0.70,0),GOLD).rotation.x = PI/2
		"viking_loom":
			for x in [-0.56,0.56]:
				Models.box(root,Vector3(0.13,1.75,0.13),Vector3(x,0.9,0),WOOD)
				Models.box(root,Vector3(0.32,0.10,0.68),Vector3(x,0.05,0),WOOD)
			for y in [0.42,1.72]: beam(root,Vector3(-0.63,y,0),Vector3(0.63,y,0),0.12,WOOD)
			Models.box(root,Vector3(0.87,0.88,0.035),Vector3(0,1.02,0.03),Color("a95547"))
			for x in [-0.32,-0.16,0.0,0.16,0.32]: beam(root,Vector3(x,0.4,0.05),Vector3(x,1.69,0.05),0.017,IVORY)
			for y in [0.78,1.15,1.30]: Models.box(root,Vector3(0.86,0.08,0.022),Vector3(0,y,0.06),IVORY)
		"viking_throne":
			for x in [-0.51,0.51]:
				for z in [-0.35,0.35]: Models.box(root,Vector3(0.17,0.59,0.17),Vector3(x,0.31,z),WOOD)
			Models.box(root,Vector3(1.28,0.20,0.91),Vector3(0,0.64,0),WOOD)
			Models.box(root,Vector3(1.12,1.5,0.18),Vector3(0,1.24,-0.38),WOOD)
			Models.box(root,Vector3(0.67,1.0,0.045),Vector3(0,1.37,-0.265),Color("913f3d"))
			Models.box(root,Vector3(0.94,0.04,0.68),Vector3(0,0.76,0.03),Color("d4c4a5"))
			for x in [-0.57,0.57]:
				Models.box(root,Vector3(0.15,0.12,1.0),Vector3(x,0.96,0),GOLD)
				Models.box(root,Vector3(0.19,0.56,0.19),Vector3(x,1.85,-0.39),GOLD)
				Models.box(root,Vector3(0.25,0.18,0.32),Vector3(x,2.12,-0.28),GOLD)
			beam(root,Vector3(-0.32,1.42,-0.23),Vector3(0.32,1.77,-0.23),0.065,GOLD)
			beam(root,Vector3(0.32,1.42,-0.23),Vector3(-0.32,1.77,-0.23),0.065,GOLD)
		"viking_raven":
			Models.box(root,Vector3(0.68,0.14,0.57),Vector3(0,0.07,0),IRON)
			Models.box(root,Vector3(0.20,0.23,0.15),Vector3(0,0.25,0),GOLD)
			Models.ball(root,Vector3(0.40,0.53,0.30),Vector3(0,0.60,0),Color("263b50"))
			Models.box(root,Vector3(0.25,0.22,0.25),Vector3(0,0.94,0.06),GOLD)
			Models.box(root,Vector3(0.12,0.09,0.22),Vector3(0,0.91,0.24),GOLD)
			for side in [-1,1]:
				Models.box(root,Vector3(0.64,0.10,0.39),Vector3(side*0.36,0.70,-0.03),GOLD).rotation.z = side*0.40
				for i in range(3): Models.box(root,Vector3(0.09,0.05,0.26),Vector3(side*(0.18+i*0.15),0.72,-0.20),Color("263b50"))
