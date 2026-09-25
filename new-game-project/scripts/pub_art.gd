extends RefCounted

const BRICK = Color("81574b")
const GREEN = Color("294c43")
const WOOD = Color("70503a")
const CREAM = Color("d7c6a2")
const BRASS = Color("c4a36a")

static func label(level: Node3D, caption: String, at: Vector3, size: int, color: Color) -> void:
	var text = Label3D.new()
	text.text = caption
	text.position = at
	text.font_size = size
	text.pixel_size = 0.008
	text.modulate = color
	text.outline_size = 2
	level.add_child(text)

static func lamp(level: HeistLevel, at: Vector3, post: bool = false) -> void:
	if post: Models.cylinder(level,0.07,2.15,at+Vector3.UP*1.07,GREEN)
	var height = 2.22 if post else 0.0
	Models.box(level,Vector3(0.38,0.10,0.38),at+Vector3.UP*(height+0.24),GREEN)
	var glass = Models.box(level,Vector3(0.25,0.40,0.25),at+Vector3.UP*height,Color("f7ce88"))
	glass.material_override.emission_enabled = true
	glass.material_override.emission = Color("c69249")
	var light = OmniLight3D.new()
	light.position = at+Vector3.UP*height+Vector3(0,0,0.3)
	light.light_color = Color("ffd8a0")
	light.light_energy = 0.65
	light.omni_range = 4.3
	level.add_child(light)

static func build(level: HeistLevel) -> void:
	Models.box(level,Vector3(80,0.2,80),Vector3(0,-0.19,0),Color("283e4c"))
	Models.box(level,Vector3(17,0.16,28),Vector3(0,-0.06,1),Color("65767a"))
	for side in [-1,1]:
		level.barrier(Vector3(0.2,3,29),Vector3(side*8.3,1,1.4))
		# Neighbouring terraced facades continue beyond the follow-camera view.
		for i in range(5):
			var z = -13+i*6.2
			Models.box(level,Vector3(3.8,2.1,5.6),Vector3(side*10.6,0.95,z),Color("52555a"))
			Models.box(level,Vector3(4.1,0.16,5.9),Vector3(side*10.6,2.05,z),Color("263c4b"))
			for offset in [-1.4,1.2]:
				Models.box(level,Vector3(0.035,0.67,0.67),Vector3(side*8.67,1.04,z+offset),Color("bcac81"))
				Models.box(level,Vector3(0.04,0.06,0.70),Vector3(side*8.63,1.03,z+offset),GREEN)
	level.barrier(Vector3(16.6,3,0.2),Vector3(0,1,-12.9))
	Models.box(level,Vector3(12.4,0.25,12.0),Vector3(0,-0.02,-3.0),Color("514b42"))
	for i in range(29): Models.box(level,Vector3(11.9,0.045,0.39),Vector3(0,0.12,2.65-i*0.4),WOOD.lightened(float(i%3)*0.035))
	# Billiard room at the rear left; upholstered snug on the right.
	Models.box(level,Vector3(3.8,0.025,3.9),Vector3(-4,0.15,-6.85),Color("46635b"))
	Models.box(level,Vector3(3.8,0.025,3.8),Vector3(3.8,0.15,-6.8),Color("804c4c"))
	for x in [2.05,5.55]: Models.box(level,Vector3(0.05,0.01,3.6),Vector3(x,0.17,-6.8),BRASS)
	level.wall(Vector3(12.1,1.6,0.2),Vector3(0,0.8,-9.15),CREAM)
	for side in [-1,1]:
		level.wall(Vector3(0.2,0.92,12.1),Vector3(side*6.05,0.46,-3.15),CREAM)
		Models.box(level,Vector3(0.05,0.48,11.8),Vector3(side*5.91,0.33,-3.1),GREEN)
		Models.box(level,Vector3(0.06,0.07,11.8),Vector3(side*5.87,0.62,-3.1),BRASS)
		level.wall(Vector3(4.4,0.82,0.22),Vector3(side*3.87,0.41,2.9),BRICK)
		for y in [0.13,0.30,0.47]: Models.box(level,Vector3(4.36,0.018,0.02),Vector3(side*3.87,y,3.019),Color("ac8d74"))
		for i in range(8): Models.box(level,Vector3(0.017,0.16,0.022),Vector3(side*3.87-1.95+i*0.55,0.22,3.02),Color("ac8d74"))
		# Street-facing glazed bays: gold panes and green frames, kept below sight lines.
		Models.box(level,Vector3(2.9,0.63,0.06),Vector3(side*4.0,0.72,3.04),GREEN)
		Models.box(level,Vector3(2.55,0.44,0.025),Vector3(side*4.0,0.77,3.085),Color("dccba1"))
		for offset in [-0.85,0.0,0.85]: Models.box(level,Vector3(0.045,0.45,0.03),Vector3(side*4.0+offset,0.77,3.10),GREEN)
		Models.box(level,Vector3(4.55,0.13,0.72),Vector3(side*3.9,1.10,3.1),GREEN)
		Models.box(level,Vector3(0.22,1.7,0.26),Vector3(side*1.65,0.85,3.0),GREEN)
		lamp(level,Vector3(side*1.67,1.44,3.25))
		var eave = Models.box(level,Vector3(0.8,0.17,12.3),Vector3(side*6.35,1.07,-3.1),Color("354b59"))
		eave.rotation.z = side*0.26
	# A wide opening remains between the billiard partition and main aisle.
	level.wall(Vector3(3.8,0.70,0.16),Vector3(-4.15,0.35,-4.65),GREEN)
	# Main bar faces the central aisle; loot rests close enough to reach across it.
	level.house_solid(level,Vector3(1.38,0.83,4.2),Vector3(4.65,0.415,0.0),GREEN)
	Models.box(level,Vector3(1.52,0.10,4.32),Vector3(4.6,0.88,0),WOOD)
	for z in [-1.45,-0.45,0.55,1.55]:
		Models.box(level,Vector3(0.03,0.56,0.74),Vector3(3.945,0.40,z),WOOD)
		Models.box(level,Vector3(0.04,0.04,0.65),Vector3(3.92,0.60,z),BRASS)
	PubModels.beam(level,Vector3(3.74,0.22,-1.85),Vector3(3.74,0.22,1.85),0.055,BRASS)
	# Radio and gramophone have separate supporting cabinets.
	level.house_solid(level,Vector3(1.16,0.67,0.66),Vector3(4.75,0.335,-3.45),WOOD)
	level.house_solid(level,Vector3(1.13,0.61,0.73),Vector3(-4.6,0.305,-3.0),WOOD)
	level.house_solid(level,Vector3(1.1,0.69,0.70),Vector3(-4.9,0.345,1.35),GREEN)
	Models.box(level,Vector3(1.17,0.06,0.76),Vector3(-4.9,0.72,1.35),WOOD)
	# Back-bar display, not duplicate stealable bottles.
	for y in [0.7,1.2]:
		Models.box(level,Vector3(0.32,0.07,3.0),Vector3(5.78,y,-0.2),WOOD)
		for i in range(7):
			Models.cylinder(level,0.055,0.23,Vector3(5.77,y+0.15,-1.4+i*0.40),Color("547666") if i%2==0 else Color("997344"))
	for x in [-3.3,0.0,2.9]:
		Models.box(level,Vector3(1.1,0.72,0.05),Vector3(x,1.04,-9.01),WOOD)
		Models.box(level,Vector3(0.94,0.56,0.02),Vector3(x,1.04,-8.97),Color("8e9c90"))
		Models.box(level,Vector3(0.65,0.18,0.025),Vector3(x,0.92,-8.95),Color("3e625d"))
	# Cue rack belongs to the billiards corner and stays against its outer wall.
	level.house_solid(level,Vector3(1.5,1.22,0.46),Vector3(0,0.61,-8.8),BRICK)
	Models.box(level,Vector3(1.12,0.83,0.035),Vector3(0,0.45,-8.545),Color("202d30"))
	Models.box(level,Vector3(1.72,0.12,0.62),Vector3(0,1.27,-8.78),WOOD)
	for x in [-0.23,0.0,0.23]:
		var ember = Models.box(level,Vector3(0.13,0.26,0.10),Vector3(x,0.26,-8.49),Color("efb562"))
		ember.material_override.emission_enabled = true
		ember.material_override.emission = Color("d98343")
	label(level,"1932",Vector3(0,1.46,-8.90),22,BRASS)
	for z in [-7.8,-7.45,-7.1]: PubModels.beam(level,Vector3(-5.7,0.2,z),Vector3(-5.7,1.63,z),0.03,CREAM)
	Models.box(level,Vector3(0.18,0.08,1.2),Vector3(-5.7,0.65,-7.45),WOOD)
	# Snug table and banquette reinforce the social setting without blocking loot.
	level.house_solid(level,Vector3(0.94,0.57,0.73),Vector3(-3.2,0.285,-1.4),WOOD)
	Models.box(level,Vector3(0.35,0.015,0.24),Vector3(-3.2,0.59,-1.4),CREAM)
	for x in [-3.85,-2.55]:
		Models.cylinder(level,0.18,0.12,Vector3(x,0.37,-1.4),Color("703d3e"))
		level.house_solid(level,Vector3(0.18,0.34,0.18),Vector3(x,0.17,-1.4),WOOD)
	Models.cylinder(level,0.20,0.12,Vector3(3.05,0.53,0),Color("703d3e"))
	level.house_solid(level,Vector3(0.20,0.48,0.20),Vector3(3.05,0.24,0),WOOD)
	level.house_solid(level,Vector3(1.0,0.42,0.56),Vector3(4.1,0.21,-4.85),WOOD)
	Models.box(level,Vector3(0.36,0.018,0.25),Vector3(4.1,0.44,-4.85),CREAM)
	lamp(level,Vector3(-5.6,1.3,-7.8))
	lamp(level,Vector3(5.5,1.3,-7.8))
	# Hanging pub name sits beside the doorway instead of covering the entrance.
	Models.box(level,Vector3(2.8,0.57,0.13),Vector3(-4,1.52,3.15),GREEN)
	label(level,"THE BRASS FOX",Vector3(-4,1.54,3.23),25,CREAM)
	# Broad pavement and a cobbled street continue beneath the moving camera.
	for row in range(17):
		for col in range(12):
			Models.box(level,Vector3(1.28,0.03,0.71),Vector3(-7.3+col*1.32,0.04,3.5+row*0.75),Color("6a797e").darkened(float((row+col)%3)*0.025))
	Models.box(level,Vector3(30,0.05,6.2),Vector3(0,0.05,13.4),Color("374a55"))
	for x in [-5.3,5.3]:
		lamp(level,Vector3(x,0.07,9.6),true)
		level.barrier(Vector3(0.3,3,0.3),Vector3(x,1,9.6))
		Models.box(level,Vector3(0.85,0.37,0.8),Vector3(x,0.2,5.3),BRICK)
		Models.ball(level,Vector3(0.88,0.60,0.83),Vector3(x,0.62,5.3),Color("496b59"))
	for x in [-6.9,6.9]:
		for z in [7.2,11.0,15.0]: Models.cylinder(level,0.07,0.68,Vector3(x,0.34,z),GREEN)
