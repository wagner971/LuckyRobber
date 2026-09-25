extends RefCounted

static func part(parent: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(parent,size,at,Color(color))
	mesh.name = label
	return mesh

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "VillaInterior"
	level.add_child(art)
	for x in [-5.92,5.92]:
		part(art,"StoneSkirting",Vector3(0.05,0.13,11.96),Vector3(x,0.15,-2.97),"cbbd9f")
	for z in [-9.01,-3.23,-2.97]:
		for x in [-3.8,3.8]: part(art,"RoomSkirting",Vector3(4.13,0.11,0.04),Vector3(x,0.14,z),"cbbd9f")
	# Quiet timber seams and ivory paneling, rather than a different bright color per room.
	for z in [-8.5,-7.8,-7.1,-6.4,-5.7,-5.0,-4.3,-3.6,-2.6,-1.9,-1.2,-0.5,0.2,0.9,1.6,2.3]:
		part(art,"OakJoint",Vector3(4.1,0.004,0.016),Vector3(-3.8,0.068,z),"b49a7b")
	for z in [-8.3,-7.15,-6.0,-4.85,-3.7]:
		for x in [2.2,3.35,4.5,5.65]:
			part(art,"StoneTileJoint",Vector3(1.08,0.004,0.014),Vector3(x,0.068,z),"b6c8c2")
	for x in [2.2,3.35,4.5,5.65]: part(art,"StoneTileJoint",Vector3(0.014,0.004,5.65),Vector3(x,0.068,-6.1),"b6c8c2")
	lounge(art,level)
	study(art,level)
	music(art,level)
	bath(art,level)

static func lounge(art: Node3D, level: Node3D) -> void:
	part(art,"SalonRugBorder",Vector3(3.12,0.016,4.23),Vector3(-4.02,0.079,-0.05),"806b69")
	part(art,"SalonRug",Vector3(2.89,0.006,3.99),Vector3(-4.02,0.090,-0.05),"b5a290")
	# The sofa faces the TV, and only the TV lifts off the permanent console.
	part(art,"MediaCredenza",Vector3(2.02,0.46,0.58),Vector3(-4.13,0.34,-2.64),"6e665e")
	part(art,"MediaStoneTop",Vector3(2.12,0.08,0.65),Vector3(-4.13,0.61,-2.64),"dfd2b4")
	for x in [-4.62,-3.64]:
		part(art,"MediaDoor",Vector3(0.89,0.34,0.027),Vector3(x,0.36,-2.332),"8b7e6a")
		part(art,"BrassPull",Vector3(0.22,0.025,0.035),Vector3(x,0.40,-2.306),"ccb682")
	solid(level,Vector3(2.02,0.57,0.58),Vector3(-4.13,0.365,-2.64))
	part(art,"CoffeeTable",Vector3(1.03,0.08,0.62),Vector3(-4.1,0.40,0.0),"bfa986")
	for x in [-4.5,-3.7]: part(art,"CoffeeTableBase",Vector3(0.08,0.30,0.48),Vector3(x,0.24,0),"536773")
	solid(level,Vector3(1.03,0.36,0.62),Vector3(-4.1,0.26,0))
	part(art,"ArtBook",Vector3(0.36,0.035,0.30),Vector3(-4.25,0.46,0),"647d85")
	part(art,"ArtBookJacket",Vector3(0.26,0.006,0.18),Vector3(-4.25,0.483,0),"e1d3ab")
	part(art,"LampTable",Vector3(0.53,0.51,0.55),Vector3(-5.47,0.34,1.66),"8c7a66")
	solid(level,Vector3(0.53,0.51,0.55),Vector3(-5.47,0.34,1.66))
	part(art,"LampStem",Vector3(0.04,0.29,0.04),Vector3(-5.47,0.76,1.66),"bda06c")
	var shade = Models.cylinder(art,0.23,0.27,Vector3(-5.47,0.99,1.66),Color("e4d2aa"))
	(shade.mesh as CylinderMesh).top_radius = 0.16
	window(art,Vector3(-5.91,0.59,-0.77),true)
	light(art,Vector3(-5.2,1.65,1.4),Color("ffe1b9"),0.55,3.5)

static func study(art: Node3D, level: Node3D) -> void:
	# A side-wall workstation keeps the hall-to-safe diagonal open.
	part(art,"StudyRug",Vector3(2.75,0.014,4.0),Vector3(4.23,0.078,-0.05),"899697")
	part(art,"DeskTop",Vector3(0.79,0.09,1.95),Vector3(5.30,0.735,0.30),"bfac89")
	for x in [5.02,5.58]:
		for z in [-0.53,1.13]: part(art,"DeskLeg",Vector3(0.07,0.65,0.07),Vector3(x,0.40,z),"556975")
	solid(level,Vector3(0.79,0.70,1.95),Vector3(5.30,0.43,0.30))
	part(art,"DeskLeatherMat",Vector3(0.66,0.01,1.60),Vector3(5.30,0.79,0.15),"536e73")
	part(art,"Keyboard",Vector3(0.45,0.03,0.22),Vector3(5.22,0.815,0.85),"718891")
	for z in [0.79,0.85,0.91]: part(art,"KeyRow",Vector3(0.37,0.007,0.023),Vector3(5.22,0.836,z),"bdc5b6")
	part(art,"DeskPaper",Vector3(0.41,0.016,0.31),Vector3(5.31,0.807,-0.44),"e0d8bf")
	# Built-in storage frames the safe without burying or blocking its door.
	part(art,"StudyBookcase",Vector3(1.43,0.64,0.41),Vector3(2.76,0.40,-2.78),"817562")
	part(art,"BookcaseTop",Vector3(1.53,0.05,0.46),Vector3(2.76,0.755,-2.78),"c7b182")
	solid(level,Vector3(1.43,0.71,0.41),Vector3(2.76,0.435,-2.78))
	for i in range(7):
		part(art,"BoundBooks",Vector3(0.12,0.34+(i%3)*0.035,0.21),Vector3(2.24+i*0.17,0.47,-2.55),["778b83","ac9471","526d7c"][i%3])
	window(art,Vector3(5.91,0.60,-1.65),true)
	light(art,Vector3(4.8,2.1,-0.15),Color("f0e4cb"),0.50,3.8)

static func music(art: Node3D, level: Node3D) -> void:
	# An actual practice corner: piano against the rear wall, chair at its keys.
	part(art,"MusicRugBorder",Vector3(3.18,0.016,2.87),Vector3(-3.80,0.079,-7.30),"8b7778")
	part(art,"MusicRug",Vector3(2.94,0.005,2.61),Vector3(-3.80,0.090,-7.30),"c4b59d")
	part(art,"RecordCabinet",Vector3(0.49,0.62,1.22),Vector3(-5.59,0.39,-4.40),"8e7e68")
	solid(level,Vector3(0.49,0.62,1.22),Vector3(-5.59,0.39,-4.40))
	for z in [-4.8,-4.60,-4.40,-4.20,-4.00]:
		part(art,"SheetMusicFolders",Vector3(0.24,0.30,0.12),Vector3(-5.31,0.42,z),"637c7f")
	window(art,Vector3(-3.75,0.76,-9.01),false)
	for x in [-4.79,-2.71]:
		part(art,"MusicCurtain",Vector3(0.18,0.65,0.10),Vector3(x,0.65,-8.96),"7e8f89")
	light(art,Vector3(-3.7,2.25,-7.5),Color("ffe2b9"),0.60,4.4)

static func bath(art: Node3D, level: Node3D) -> void:
	# Freestanding tub under the window, double vanity along the outer wall.
	part(art,"BathRunner",Vector3(1.31,0.014,2.07),Vector3(3.07,0.078,-6.71),"8da7a3")
	part(art,"DoubleVanity",Vector3(0.63,0.51,2.15),Vector3(5.50,0.36,-7.40),"a2b2a6")
	part(art,"VanityStoneTop",Vector3(0.71,0.08,2.23),Vector3(5.50,0.655,-7.40),"e6dfc9")
	solid(level,Vector3(0.63,0.62,2.15),Vector3(5.50,0.39,-7.40))
	# A local wall backing supports mirrors above the basins while the rest
	# of the perimeter stays low enough for the cutaway camera.
	part(art,"VanityBackPanel",Vector3(0.065,1.25,2.36),Vector3(5.96,0.70,-7.40),"d6d6bf")
	for z in [-7.93,-6.87]:
		part(art,"BasinRim",Vector3(0.49,0.025,0.67),Vector3(5.46,0.708,z),"cad8ce")
		part(art,"BasinInset",Vector3(0.34,0.018,0.50),Vector3(5.43,0.73,z),"75999d")
		part(art,"VanityTap",Vector3(0.15,0.16,0.045),Vector3(5.73,0.79,z),"b2c5ba")
		part(art,"MirrorFrame",Vector3(0.04,0.40,0.77),Vector3(5.91,1.06,z),"b7a987")
		part(art,"MirrorGlass",Vector3(0.02,0.31,0.66),Vector3(5.879,1.06,z),"afc7c2")
	part(art,"TowelBench",Vector3(1.21,0.36,0.44),Vector3(3.22,0.27,-3.48),"ac9c81")
	solid(level,Vector3(1.21,0.36,0.44),Vector3(3.22,0.27,-3.48))
	for y in [0.50,0.59]: part(art,"FoldedBathTowels",Vector3(0.62,0.075,0.33),Vector3(3.22,y,-3.48),"d8d7c2")
	part(art,"TowelRail",Vector3(0.09,0.045,0.57),Vector3(5.86,0.58,-5.68),"a8b7a4")
	part(art,"HangingTowel",Vector3(0.03,0.39,0.39),Vector3(5.82,0.43,-5.68),"c6d1be")
	part(art,"ToiletRoll",Vector3(0.13,0.18,0.18),Vector3(5.84,0.54,-3.74),"e5dfca")
	window(art,Vector3(3.02,0.73,-9.015),false)
	light(art,Vector3(3.9,2.4,-6.5),Color("e3ede4"),0.50,4.6)

static func window(parent: Node3D, at: Vector3, side: bool) -> void:
	var frame = Node3D.new()
	parent.add_child(frame)
	frame.position = at
	if side: frame.rotation.y = PI/2
	part(frame,"WindowFrame",Vector3(1.65,0.43,0.05),Vector3.ZERO,"d8d0b8")
	part(frame,"NightGlass",Vector3(1.47,0.30,0.07),Vector3.ZERO,"738f9e")
	part(frame,"Mullion",Vector3(0.045,0.35,0.10),Vector3.ZERO,"c9cdbb")

static func light(parent: Node3D, at: Vector3, tint: Color, energy: float, reach: float) -> void:
	var lamp = OmniLight3D.new()
	lamp.position = at
	lamp.light_color = tint
	lamp.light_energy = energy
	lamp.omni_range = reach
	lamp.shadow_enabled = false
	parent.add_child(lamp)
