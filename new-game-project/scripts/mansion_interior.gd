extends RefCounted

static func part(art: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(art,size,at,Color(color))
	mesh.name = label
	return mesh

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))

static func cabinet(art: Node3D, level: Node3D, label: String, at: Vector3, size: Vector3) -> void:
	part(art,label,size,at,"766451")
	part(art,label+"StoneTop",Vector3(size.x+0.06,0.06,size.z+0.06),at+Vector3.UP*(size.y/2+0.03),"d5c7ab")
	solid(level,Vector3(size.x,size.y+0.06,size.z),at+Vector3.UP*0.03)

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "MansionInterior"
	level.add_child(art)
	for x in [-7.14,7.14]:
		part(art,"OakSkirting",Vector3(0.055,0.17,13.5),Vector3(x,0.18,-3.6),"8a7861")
	for side in [-1.0,1.0]:
		for z in [-9.8,-8.8,-7.8,-5.8,-4.8,-3.8,-2.8,-1.8,-0.8,0.2,1.2,2.2]:
			part(art,"ParquetJoint",Vector3(4.42,0.004,0.014),Vector3(side*4.87,0.075,z),"aa9071")
		for z in [-8.9,-5.5,-1.5,2.05]:
			solid(level,Vector3(0.40,0.83,0.40),Vector3(side*2.30,0.49,z))
	gallery(art,level)
	music(art,level)
	library(art,level)
	lounge(art,level)
	suite(art,level)
	bath(art,level)
	kitchen(art,level)

static func gallery(art: Node3D, level: Node3D) -> void:
	part(art,"GalleryRugBorder",Vector3(3.78,0.018,3.16),Vector3(-4.85,0.088,-8.45),"5d5364")
	part(art,"GalleryRug",Vector3(3.56,0.006,2.94),Vector3(-4.85,0.100,-8.45),"88777d")
	# The statue has its own integrated plinth; no second pedestal intersects it.
	for x in [-6.16,-3.56]:
		portrait(art,Vector3(x,0.78,-10.45),"586f78")
	part(art,"GalleryBench",Vector3(1.32,0.10,0.46),Vector3(-6.12,0.43,-6.72),"776354")
	for x in [-6.58,-5.66]: part(art,"BenchLeg",Vector3(0.09,0.32,0.36),Vector3(x,0.24,-6.72),"b49a6d")
	solid(level,Vector3(1.32,0.42,0.46),Vector3(-6.12,0.29,-6.72))
	lamp(art,Vector3(-4.8,2.7,-8.6),"f7ddb4",0.56,4.3)

static func music(art: Node3D, level: Node3D) -> void:
	part(art,"MusicRugBorder",Vector3(3.62,0.018,2.79),Vector3(4.8,0.088,-8.7),"755762")
	part(art,"MusicRug",Vector3(3.38,0.006,2.55),Vector3(4.8,0.100,-8.7),"b1988b")
	part(art,"PianoBenchSeat",Vector3(0.96,0.12,0.36),Vector3(4.8,0.46,-7.94),"654c59")
	for x in [4.45,5.15]: part(art,"PianoBenchLeg",Vector3(0.08,0.31,0.27),Vector3(x,0.245,-7.94),"534b50")
	solid(level,Vector3(0.96,0.44,0.36),Vector3(4.8,0.30,-7.94))
	window(art,Vector3(4.8,0.83,-10.44),false)
	for x in [3.55,6.05]: part(art,"MusicDrape",Vector3(0.32,0.90,0.17),Vector3(x,0.70,-10.37),"6e4a58")
	cabinet(art,level,"MusicCabinet",Vector3(6.70,0.36,-8.9),Vector3(0.52,0.55,1.24))
	for z in [-9.28,-9.08,-8.88,-8.68]: part(art,"SheetMusic",Vector3(0.08,0.24,0.13),Vector3(6.65,0.80,z),"c3b18e")
	lamp(art,Vector3(4.8,2.6,-8.8),"f3d8b2",0.54,4.0)

static func library(art: Node3D, level: Node3D) -> void:
	part(art,"LibraryRug",Vector3(2.93,0.018,4.67),Vector3(-4.75,0.086,-3.49),"687d7e")
	# Safe in the owner's archive, a work desk along the side wall.
	for x in [-3.95,-2.97]:
		cabinet(art,level,"ArchiveShelf",Vector3(x,0.40,-5.78),Vector3(0.87,0.64,0.45))
		for i in range(5):
			part(art,"ArchiveBook",Vector3(0.12,0.35+(i%2)*0.06,0.21),Vector3(x-0.31+i*0.155,0.46,-5.535),["607e76","947757","695562"][i%3])
	part(art,"DeskTop",Vector3(0.91,0.08,3.34),Vector3(-6.24,0.72,-2.6),"b79d78")
	for z in [-3.92,-1.28]:
		cabinet(art,level,"DeskPedestal",Vector3(-6.24,0.35,z),Vector3(0.80,0.55,0.46))
	solid(level,Vector3(0.91,0.68,3.34),Vector3(-6.24,0.42,-2.6))
	part(art,"LeatherDeskMat",Vector3(0.73,0.009,1.05),Vector3(-6.20,0.768,-3.35),"435d65")
	part(art,"DeskKeyboard",Vector3(0.18,0.027,0.52),Vector3(-5.87,0.79,-3.35),"c1c5b8")
	for z in [-3.53,-3.35,-3.17]: part(art,"KeyboardRow",Vector3(0.13,0.004,0.035),Vector3(-5.87,0.807,z),"627d85")
	window(art,Vector3(-7.12,0.70,-2.8),true)
	lamp(art,Vector3(-4.9,2.5,-3.2),"eadbbb",0.46,4.9)

static func lounge(art: Node3D, level: Node3D) -> void:
	part(art,"LoungeRug",Vector3(3.9,0.02,3.26),Vector3(-4.74,0.088,1.26),"b3987e")
	# Upholstered permanent seating faces the stealable TV, with a low table between.
	part(art,"SofaBase",Vector3(0.80,0.36,1.97),Vector3(-6.04,0.34,1.23),"65566c")
	part(art,"SofaBack",Vector3(0.19,0.71,2.02),Vector3(-6.41,0.57,1.23),"55465c")
	for z in [0.40,2.06]: part(art,"SofaArm",Vector3(0.83,0.43,0.18),Vector3(-6.02,0.52,z),"55465c")
	for z in [0.79,1.64]: part(art,"SofaCushion",Vector3(0.64,0.13,0.74),Vector3(-5.94,0.59,z),"8f7c8c")
	solid(level,Vector3(0.95,0.75,2.02),Vector3(-6.06,0.46,1.23))
	cabinet(art,level,"TVConsole",Vector3(-3.13,0.32,1.24),Vector3(0.60,0.48,1.80))
	part(art,"CoffeeTableTop",Vector3(0.72,0.08,1.05),Vector3(-4.68,0.41,1.24),"dccbad")
	part(art,"CoffeeTableFoot",Vector3(0.43,0.29,0.72),Vector3(-4.68,0.23,1.24),"78634f")
	solid(level,Vector3(0.72,0.37,1.05),Vector3(-4.68,0.265,1.24))
	part(art,"ArtBook",Vector3(0.36,0.035,0.38),Vector3(-4.66,0.47,1.35),"58757b")
	lamp(art,Vector3(-5.3,2.25,1.5),"efd8b4",0.45,4.2)

static func suite(art: Node3D, level: Node3D) -> void:
	part(art,"SuiteRug",Vector3(3.7,0.017,3.25),Vector3(4.95,0.087,-5.07),"a98e89")
	part(art,"BedFrame",Vector3(1.68,0.31,2.00),Vector3(6.0,0.28,-4.83),"71604f")
	part(art,"Mattress",Vector3(1.55,0.21,1.90),Vector3(6.0,0.54,-4.83),"ddd2ba")
	part(art,"BedThrow",Vector3(1.57,0.055,1.11),Vector3(6.0,0.68,-4.43),"6f8187")
	part(art,"BedPillow",Vector3(1.22,0.12,0.36),Vector3(6.0,0.70,-5.48),"e5dcca")
	part(art,"Headboard",Vector3(1.72,0.73,0.13),Vector3(6.0,0.52,-5.88),"88715d")
	solid(level,Vector3(1.72,0.74,2.1),Vector3(6,0.45,-4.86))
	# Private PC belongs to a writing nook, not the kitchen by the front door.
	cabinet(art,level,"SuiteWritingDesk",Vector3(3.42,0.385,-4.65),Vector3(0.86,0.61,1.46))
	part(art,"WritingPad",Vector3(0.39,0.013,0.48),Vector3(3.42,0.757,-4.28),"e2d7bd")
	part(art,"Pen",Vector3(0.025,0.019,0.23),Vector3(3.49,0.78,-4.25),"b49967")
	window(art,Vector3(7.12,0.70,-5.0),true)
	lamp(art,Vector3(4.5,2.6,-5.15),"f0ddbd",0.46,4.5)

static func bath(art: Node3D, level: Node3D) -> void:
	part(art,"BathStoneFloor",Vector3(3.09,0.025,2.82),Vector3(5.56,0.087,-1.69),"a5bcbc")
	for z in [-2.76,-2.10,-1.44,-0.78]: part(art,"BathGrout",Vector3(3.0,0.005,0.019),Vector3(5.56,0.104,z),"829d9f")
	for z in [-3.17,-0.23]:
		part(art,"BathPrivacyWall",Vector3(2.61,0.86,0.12),Vector3(5.84,0.51,z),"c9d0c0")
		solid(level,Vector3(2.61,0.86,0.12),Vector3(5.84,0.51,z))
	cabinet(art,level,"BathVanity",Vector3(6.77,0.35,-0.93),Vector3(0.60,0.55,0.96))
	part(art,"SinkBasin",Vector3(0.36,0.045,0.59),Vector3(6.71,0.697,-0.93),"719d9e")
	part(art,"BasinTap",Vector3(0.15,0.16,0.045),Vector3(6.93,0.76,-0.93),"b4b7a0")
	part(art,"MirrorBacking",Vector3(0.04,1.10,1.0),Vector3(7.115,0.71,-0.93),"cbd0be")
	part(art,"BathMirror",Vector3(0.05,0.54,0.68),Vector3(7.08,1.0,-0.93),"94b3bb")
	part(art,"TowelRail",Vector3(0.05,0.05,0.66),Vector3(7.03,0.73,-2.76),"c4ae82")
	part(art,"FoldedTowel",Vector3(0.06,0.32,0.36),Vector3(7.01,0.56,-2.76),"dfd5c0")
	lamp(art,Vector3(5.7,2.4,-1.7),"d7e3d9",0.39,3.5)

static func kitchen(art: Node3D, level: Node3D) -> void:
	part(art,"KitchenStoneFloor",Vector3(4.46,0.020,3.28),Vector3(4.87,0.085,1.61),"bbbba7")
	cabinet(art,level,"KitchenCounter",Vector3(6.72,0.41,0.74),Vector3(0.74,0.65,1.37))
	part(art,"KitchenSink",Vector3(0.47,0.025,0.60),Vector3(6.68,0.808,0.58),"6f9197")
	part(art,"KitchenTap",Vector3(0.15,0.23,0.04),Vector3(6.94,0.88,0.58),"aab4aa")
	# A breakfast table occupies the room edge; the hall remains the carrying route.
	part(art,"BreakfastTop",Vector3(1.11,0.09,0.70),Vector3(4.26,0.64,1.94),"c5ad85")
	for x in [3.87,4.65]: part(art,"BreakfastLeg",Vector3(0.09,0.51,0.48),Vector3(x,0.345,1.94),"695a4d")
	solid(level,Vector3(1.11,0.605,0.70),Vector3(4.26,0.3825,1.94))
	part(art,"ServingTray",Vector3(0.41,0.03,0.32),Vector3(4.26,0.71,1.94),"8c9c8f")
	lamp(art,Vector3(5.0,2.6,1.7),"f1dfbb",0.40,3.7)

static func portrait(art: Node3D, at: Vector3, color: String) -> void:
	part(art,"PortraitFrame",Vector3(0.97,0.77,0.07),at,"b69c6f")
	part(art,"PortraitCanvas",Vector3(0.81,0.61,0.08),at+Vector3(0,0,0.04),color)
	part(art,"PortraitSilhouette",Vector3(0.29,0.36,0.019),at+Vector3(0,-0.04,0.087),"ab9879")
	part(art,"PortraitHead",Vector3(0.18,0.16,0.02),at+Vector3(0,0.20,0.087),"c9b99a")

static func window(art: Node3D, at: Vector3, side: bool) -> void:
	var size = Vector3(0.06,0.62,1.47) if side else Vector3(2.22,0.70,0.06)
	part(art,"WindowFrame",size,at,"b49c78")
	part(art,"NightWindow",size*Vector3(1.1,0.79,0.89) if side else size*Vector3(0.90,0.79,1.1),at,"6e8795")

static func lamp(art: Node3D, at: Vector3, color: String, energy: float, reach: float) -> void:
	var light = OmniLight3D.new()
	light.position = at
	light.light_color = Color(color)
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	art.add_child(light)
