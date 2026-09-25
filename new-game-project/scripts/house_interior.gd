extends RefCounted

# Furnished family home. The two branch lanes at x = +/-1.15 stay open.
static func part(parent: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(parent,size,at,Color(color))
	mesh.name = label
	return mesh

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "SuburbanInterior"
	level.add_child(art)
	for side in [-1.0,1.0]:
		part(art,"Skirting",Vector3(0.045,0.09,10.55),Vector3(side*4.92,0.13,-2.27),"c3b89d")
	for z in [-7.35,-6.85,-6.35,-5.85,-5.35,-4.85,-4.35,-3.85,-3.35,-2.85,-2.35]:
		part(art,"LoungeOakJoint",Vector3(4.74,0.004,0.018),Vector3(2.52,0.067,z),"c4aa85")
	lounge(art,level)
	kitchen(art,level)
	garage(art,level)
	bathroom(art,level)

static func lounge(art: Node3D, level: Node3D) -> void:
	# The screen and sofa share an axis; side details frame, never occupy, it.
	part(art,"LoungeRugBorder",Vector3(3.05,0.017,3.18),Vector3(2.93,0.079,-5.05),"a59079")
	part(art,"LoungeRug",Vector3(2.83,0.006,2.96),Vector3(2.93,0.091,-5.05),"c8b49a")
	part(art,"MediaCabinet",Vector3(1.82,0.43,0.57),Vector3(2.90,0.325,-7.00),"957758")
	part(art,"MediaTop",Vector3(1.92,0.075,0.64),Vector3(2.90,0.578,-7.00),"c9ac83")
	for x in [2.47,3.33]:
		part(art,"MediaDrawer",Vector3(0.79,0.31,0.025),Vector3(x,0.35,-6.699),"ac8c64")
		part(art,"DrawerPull",Vector3(0.23,0.035,0.032),Vector3(x,0.39,-6.674),"465d61")
	solid(level,Vector3(1.82,0.50,0.57),Vector3(2.90,0.35,-7.00))
	part(art,"CoffeeTableTop",Vector3(1.00,0.075,0.53),Vector3(2.90,0.43,-5.40),"927151")
	for x in [2.50,3.30]:
		for z in [-5.59,-5.21]: part(art,"CoffeeTableLeg",Vector3(0.07,0.32,0.07),Vector3(x,0.24,z),"5d6258")
	solid(level,Vector3(1.00,0.38,0.53),Vector3(2.90,0.28,-5.40))
	part(art,"Magazine",Vector3(0.33,0.027,0.27),Vector3(2.78,0.484,-5.4),"587d86")
	part(art,"MagazineInset",Vector3(0.25,0.008,0.13),Vector3(2.78,0.502,-5.4),"d3ceb4")
	part(art,"SideTable",Vector3(0.57,0.44,0.55),Vector3(4.33,0.31,-4.08),"b39570")
	solid(level,Vector3(0.57,0.44,0.55),Vector3(4.33,0.31,-4.08))
	Models.cylinder(art,0.13,0.04,Vector3(4.33,0.55,-4.08),Color("596c6a"))
	part(art,"LampStem",Vector3(0.045,0.31,0.045),Vector3(4.33,0.70,-4.08),"a88e5f")
	var shade = Models.cylinder(art,0.24,0.28,Vector3(4.33,0.93,-4.08),Color("f0d3a4"))
	(shade.mesh as CylinderMesh).top_radius = 0.16
	light(art,Vector3(4.33,1.35,-4.08),Color("ffdcaa"),0.48,3.4)
	light(art,Vector3(2.65,2.3,-6.2),Color("f4e3c1"),0.35,3.3)
	window(art,Vector3(4.92,0.60,-5.6))

static func kitchen(art: Node3D, level: Node3D) -> void:
	# A fitted sink under the partition, fridge on its right, dining set in front.
	part(art,"KitchenBase",Vector3(1.50,0.50,0.60),Vector3(2.50,0.34,-1.14),"a6b8a6")
	part(art,"KitchenWorktop",Vector3(1.59,0.075,0.66),Vector3(2.50,0.623,-1.14),"e0d9bf")
	solid(level,Vector3(1.50,0.59,0.60),Vector3(2.50,0.375,-1.14))
	for x in [2.13,2.87]:
		part(art,"KitchenDoor",Vector3(0.68,0.40,0.025),Vector3(x,0.36,-0.824),"bfc7ae")
		part(art,"KitchenPull",Vector3(0.20,0.026,0.037),Vector3(x,0.48,-0.803),"65817e")
	part(art,"SinkRim",Vector3(0.64,0.024,0.46),Vector3(2.25,0.672,-1.13),"bdcebd")
	part(art,"SinkBowl",Vector3(0.49,0.018,0.32),Vector3(2.25,0.692,-1.11),"668d91")
	part(art,"KitchenTap",Vector3(0.045,0.20,0.045),Vector3(2.25,0.76,-1.37),"b7cfcb")
	part(art,"TapSpout",Vector3(0.045,0.04,0.17),Vector3(2.25,0.85,-1.29),"b7cfcb")
	part(art,"ChoppingBoard",Vector3(0.34,0.02,0.43),Vector3(2.95,0.675,-1.13),"b99663")
	part(art,"DiningRug",Vector3(2.40,0.012,1.71),Vector3(3.12,0.079,1.32),"b59d7e")
	part(art,"DiningTable",Vector3(1.35,0.09,0.85),Vector3(3.30,0.635,1.30),"c4a376")
	for x in [2.75,3.85]:
		for z in [0.99,1.61]: part(art,"DiningLeg",Vector3(0.075,0.55,0.075),Vector3(x,0.35,z),"84715c")
	solid(level,Vector3(1.35,0.60,0.85),Vector3(3.30,0.38,1.30))
	part(art,"Placemat",Vector3(0.46,0.008,0.58),Vector3(2.99,0.687,1.30),"72988a")
	Models.cylinder(art,0.16,0.019,Vector3(2.99,0.704,1.30),Color("e9dfc6"))
	part(art,"Mug",Vector3(0.12,0.14,0.12),Vector3(3.47,0.76,1.04),"7a9da0")
	part(art,"EntryBench",Vector3(1.45,0.28,0.39),Vector3(3.35,0.235,2.82),"ae9877")
	solid(level,Vector3(1.45,0.28,0.39),Vector3(3.35,0.235,2.82))
	part(art,"BenchCushion",Vector3(1.32,0.06,0.36),Vector3(3.35,0.40,2.82),"879d8b")
	light(art,Vector3(3.25,2.3,0.45),Color("f7e1ba"),0.57,3.5)

static func garage(art: Node3D, level: Node3D) -> void:
	# Rolling tool chest and bench form one work wall, with usable floor in front.
	part(art,"WorkshopMat",Vector3(2.92,0.012,1.32),Vector3(-3.10,0.079,-0.35),"60757c")
	part(art,"WorkbenchTop",Vector3(1.42,0.10,0.64),Vector3(-2.35,0.69,-1.11),"b39a72")
	for x in [-2.96,-1.74]:
		for z in [-1.34,-0.88]: part(art,"BenchLeg",Vector3(0.075,0.59,0.075),Vector3(x,0.38,z),"435969")
	solid(level,Vector3(1.42,0.65,0.64),Vector3(-2.35,0.40,-1.11))
	part(art,"ToolBoard",Vector3(1.43,0.42,0.035),Vector3(-2.35,0.67,-1.488),"967e62")
	for x in [-2.87,-2.55,-2.23,-1.91]:
		part(art,"ToolHook",Vector3(0.032,0.05,0.06),Vector3(x,0.76,-1.455),"354c59")
		part(art,"ToolHandle",Vector3(0.041,0.20,0.034),Vector3(x,0.65,-1.43),"4b6970")
		part(art,"ToolHead",Vector3(0.12,0.054,0.04),Vector3(x,0.765,-1.43),"c0c9bb")
	part(art,"BenchVise",Vector3(0.23,0.17,0.23),Vector3(-2.68,0.82,-1.08),"557d87")
	part(art,"ViseJaw",Vector3(0.29,0.055,0.09),Vector3(-2.68,0.93,-1.08),"9dafac")
	part(art,"SpareWheelRack",Vector3(0.58,0.12,1.31),Vector3(-4.54,0.16,0.95),"627678")
	solid(level,Vector3(0.58,0.33,1.31),Vector3(-4.54,0.255,0.95))
	for z in [0.57,1.20]:
		var tire = Models.cylinder(art,0.28,0.19,Vector3(-4.51,0.41,z),Color("283e48"))
		tire.rotation.z = PI/2
		var hub = Models.cylinder(art,0.13,0.20,Vector3(-4.49,0.41,z),Color("889da2"))
		hub.rotation.z = PI/2
	# A wall-mounted electrical panel stays out of the route.
	part(art,"FusePanel",Vector3(0.06,0.42,0.31),Vector3(-4.92,0.55,2.10),"879893")
	part(art,"PanelSwitch",Vector3(0.02,0.09,0.06),Vector3(-4.879,0.53,2.10),"4a6871")
	light(art,Vector3(-3.05,2.2,0.2),Color("dbe7e7"),0.46,3.5)

static func bathroom(art: Node3D, level: Node3D) -> void:
	# Larger, quieter tiles; bath/duck in one corner, vanity opposite the toilet.
	for x in [-4.6,-3.7,-2.8,-1.9,-1.0]:
		part(art,"BathGrout",Vector3(0.017,0.004,5.95),Vector3(x,0.068,-4.675),"b5c9c5")
	for z in [-7.25,-6.35,-5.45,-4.55,-3.65,-2.75]:
		part(art,"BathGrout",Vector3(4.75,0.004,0.017),Vector3(-2.55,0.068,z),"b5c9c5")
	part(art,"BathRunner",Vector3(1.15,0.013,1.72),Vector3(-2.96,0.079,-5.44),"8aa8a4")
	part(art,"DuckCabinet",Vector3(0.65,0.52,0.57),Vector3(-4.45,0.36,-5.30),"a1b6ad")
	part(art,"DuckShelfTop",Vector3(0.70,0.06,0.62),Vector3(-4.45,0.65,-5.30),"e3dec6")
	solid(level,Vector3(0.65,0.60,0.57),Vector3(-4.45,0.38,-5.30))
	part(art,"BathVanity",Vector3(0.61,0.50,1.23),Vector3(-4.57,0.34,-3.02),"9db0a8")
	part(art,"VanityTop",Vector3(0.68,0.07,1.30),Vector3(-4.57,0.625,-3.02),"e8e1ca")
	part(art,"VanityBasin",Vector3(0.42,0.026,0.60),Vector3(-4.53,0.673,-3.02),"789fa4")
	part(art,"VanityTap",Vector3(0.15,0.18,0.047),Vector3(-4.75,0.76,-3.02),"b8cdcb")
	solid(level,Vector3(0.61,0.59,1.23),Vector3(-4.57,0.375,-3.02))
	part(art,"VanityMirrorFrame",Vector3(0.04,0.44,1.10),Vector3(-4.918,0.58,-3.02),"718e91")
	part(art,"VanityMirror",Vector3(0.018,0.34,0.99),Vector3(-4.888,0.58,-3.02),"b6d1cc")
	part(art,"LinenCabinet",Vector3(1.17,0.72,0.55),Vector3(-1.07,0.44,-7.13),"a0b1a4")
	solid(level,Vector3(1.17,0.72,0.55),Vector3(-1.07,0.44,-7.13))
	for x in [-1.32,-0.85]:
		for y in [0.29,0.43,0.57]: part(art,"FoldedLinen",Vector3(0.36,0.095,0.32),Vector3(x,y,-6.83),"dddcc6")
	part(art,"TowelBar",Vector3(0.065,0.04,0.58),Vector3(-0.15,0.52,-5.51),"71908e")
	part(art,"HangingTowel",Vector3(0.035,0.34,0.41),Vector3(-0.18,0.39,-5.51),"dcd5bb")
	part(art,"RollHolder",Vector3(0.055,0.14,0.20),Vector3(-0.16,0.53,-3.45),"859d9b")
	part(art,"ToiletRoll",Vector3(0.13,0.17,0.18),Vector3(-0.25,0.54,-3.45),"eee8d4")
	window(art,Vector3(-4.92,0.60,-6.78))
	light(art,Vector3(-2.6,2.3,-5.1),Color("deece1"),0.46,4.6)

static func window(parent: Node3D, at: Vector3) -> void:
	part(parent,"WindowFrame",Vector3(0.06,0.38,1.27),at,"dbd4bc")
	part(parent,"WindowGlass",Vector3(0.08,0.27,1.10),at,"688e9b")
	part(parent,"WindowMullion",Vector3(0.10,0.30,0.045),at,"b9c9bd")

static func light(parent: Node3D, at: Vector3, tint: Color, energy: float, reach: float) -> void:
	var lamp = OmniLight3D.new()
	lamp.position = at
	lamp.light_color = tint
	lamp.light_energy = energy
	lamp.omni_range = reach
	lamp.shadow_enabled = false
	parent.add_child(lamp)