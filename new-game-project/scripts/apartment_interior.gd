extends RefCounted

static func part(parent: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(parent,size,at,Color(color))
	mesh.name = label
	return mesh

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "ApartmentInterior"
	level.add_child(art)
	# Materials, furniture orientation and functional fixtures identify each room.
	# Keep x:[-1.25,1.25] in the Living completely open for loading trips.
	for z in range(7):
		part(art,"OakPlankJoint",Vector3(7.05,0.004,0.016),Vector3(0,0.069,0.59+z*0.36),"b89470")
	for x in [0.36,1.0,1.64,2.28,2.92,3.52]:
		part(art,"BathGrout",Vector3(0.015,0.004,3.65),Vector3(x,0.068,-1.72),"b8d0ce")
	for z in [-3.43,-2.79,-2.15,-1.51,-0.87,-0.23]:
		part(art,"BathGrout",Vector3(3.32,0.004,0.015),Vector3(1.82,0.068,z),"b8d0ce")
	for side in [-1.0,1.0]:
		part(art,"InteriorSkirting",Vector3(0.045,0.08,6.65),Vector3(side*3.52,0.12,-0.20),"b49e83")
	part(art,"RearSkirting",Vector3(7.10,0.08,0.045),Vector3(0,0.12,-3.52),"b49e83")
	living(art,level)
	kitchen(art,level)
	bathroom(art,level)
	light(art,"LivingWarmFill",Vector3(-1.8,2.3,1.7),Color("ffe0af"),0.52,3.9)
	light(art,"KitchenWarmFill",Vector3(-1.6,2.4,-2.5),Color("fff0cf"),0.40,3.1)

static func living(art: Node3D, level: Node3D) -> void:
	# Facing chair and TV form one reading/lounge corner. The low console is
	# perpendicular to the wall; its screen faces into the room, not the entry.
	part(art,"LoungeRug",Vector3(2.25,0.014,1.56),Vector3(-2.10,0.078,1.52),"a67d64")
	part(art,"LoungeRugInset",Vector3(2.03,0.004,1.34),Vector3(-2.10,0.088,1.52),"c5a382")
	part(art,"TVConsole",Vector3(0.55,0.36,1.70),Vector3(-3.05,0.26,1.30),"8d755f")
	part(art,"TVConsoleTop",Vector3(0.64,0.07,1.78),Vector3(-3.05,0.475,1.30),"d3bb92")
	for z in [0.92,1.68]:
		part(art,"ConsoleDoor",Vector3(0.025,0.23,0.66),Vector3(-2.761,0.28,z),"b09372")
		part(art,"ConsolePull",Vector3(0.035,0.027,0.17),Vector3(-2.738,0.32,z),"4e626b")
	solid(level,Vector3(0.55,0.43,1.70),Vector3(-3.05,0.295,1.30))
	# The right side is a small work nook. Laptop and fan sit on the same desk.
	part(art,"WritingDeskTop",Vector3(1.92,0.09,0.71),Vector3(2.52,0.635,0.97),"d2b48a")
	for x in [1.63,3.35]:
		for z in [0.72,1.22]:
			part(art,"DeskLeg",Vector3(0.065,0.52,0.065),Vector3(x,0.34,z),"526774")
	part(art,"DeskDrawer",Vector3(0.64,0.20,0.56),Vector3(3.0,0.51,0.98),"9f8466")
	part(art,"DeskPull",Vector3(0.20,0.027,0.025),Vector3(3.0,0.52,1.275),"e0cda8")
	solid(level,Vector3(1.92,0.59,0.71),Vector3(2.52,0.375,0.97))
	part(art,"DeskMat",Vector3(0.98,0.009,0.56),Vector3(2.93,0.685,0.97),"567a7b")
	# Flamingo is an intentionally eccentric souvenir beside the front window,
	# rather than a blockage in the central corridor.
	part(art,"SouvenirPlinth",Vector3(0.67,0.16,0.66),Vector3(2.95,0.16,2.62),"b99d77")
	plant(art,Vector3(3.19,0.08,1.83),0.65)
	part(art,"EntryShoeTray",Vector3(0.54,0.08,0.30),Vector3(1.70,0.11,2.88),"6b7e7d")
	for x in [1.59,1.80]: part(art,"Slippers",Vector3(0.13,0.05,0.23),Vector3(x,0.17,2.88),"a39276")
	window(art,Vector3(3.515,0.67,2.23),true)
	# A framed print above the media console belongs to the wall, not the floor.
	part(art,"WallPrintFrame",Vector3(0.04,0.44,0.73),Vector3(-3.51,0.58,1.26),"775e4f")
	part(art,"WallPrint",Vector3(0.014,0.35,0.64),Vector3(-3.484,0.58,1.26),"c6b184")
	part(art,"PrintLandscape",Vector3(0.014,0.11,0.53),Vector3(-3.472,0.48,1.26),"608883")

static func kitchen(art: Node3D, level: Node3D) -> void:
	# Actual kitchen appliances, with the microwave on a continuous rear counter.
	part(art,"KitchenUnits",Vector3(3.07,0.48,0.73),Vector3(-1.90,0.33,-2.95),"81938a")
	part(art,"KitchenWorktop",Vector3(3.17,0.08,0.83),Vector3(-1.90,0.61,-2.95),"eee3c9")
	solid(level,Vector3(3.07,0.57,0.73),Vector3(-1.90,0.355,-2.95))
	for x in [-3.0,-2.27,-1.54,-0.81]:
		part(art,"CupboardFace",Vector3(0.65,0.38,0.023),Vector3(x,0.34,-2.568),"acb5a3")
		part(art,"CupboardPull",Vector3(0.21,0.027,0.035),Vector3(x,0.47,-2.55),"526c72")
	part(art,"SinkRim",Vector3(0.72,0.021,0.55),Vector3(-2.60,0.66,-2.95),"a6bbba")
	part(art,"SinkBowl",Vector3(0.56,0.023,0.40),Vector3(-2.60,0.674,-2.94),"587e88")
	part(art,"KitchenTap",Vector3(0.044,0.21,0.044),Vector3(-2.60,0.76,-3.23),"cad5cb")
	part(art,"KitchenTapSpout",Vector3(0.044,0.04,0.18),Vector3(-2.60,0.86,-3.16),"cad5cb")
	part(art,"ChoppingBoard",Vector3(0.34,0.025,0.42),Vector3(-1.93,0.67,-2.94),"b38e5f")
	part(art,"KitchenBacksplash",Vector3(3.22,0.28,0.025),Vector3(-1.90,0.57,-3.51),"bdcabc")
	for x in [-2.94,-2.27,-1.60,-0.93]:
		part(art,"BacksplashJoint",Vector3(0.017,0.27,0.009),Vector3(x,0.57,-3.49),"dee0cc")
	part(art,"KitchenRunner",Vector3(1.0,0.012,1.14),Vector3(-1.37,0.075,-1.47),"8a9d8d")
	window(art,Vector3(-3.515,0.63,-2.50),true)

static func bathroom(art: Node3D, level: Node3D) -> void:
	# The cistern backs onto the right wall; the bowl faces the open aisle.
	part(art,"Vanity",Vector3(1.15,0.49,0.58),Vector3(2.75,0.33,-3.08),"8ea8a6")
	part(art,"VanityTop",Vector3(1.23,0.07,0.64),Vector3(2.75,0.61,-3.08),"e7ece1")
	part(art,"Basin",Vector3(0.63,0.022,0.38),Vector3(2.75,0.656,-3.07),"83acb3")
	part(art,"VanityTap",Vector3(0.065,0.14,0.075),Vector3(2.75,0.70,-3.30),"c2d4d0")
	part(art,"MirrorFrame",Vector3(0.89,0.53,0.045),Vector3(2.75,0.91,-3.52),"557b85")
	part(art,"Mirror",Vector3(0.76,0.41,0.013),Vector3(2.75,0.91,-3.49),"afccd0")
	solid(level,Vector3(1.15,0.58,0.58),Vector3(2.75,0.365,-3.08))
	part(art,"ShowerTray",Vector3(1.13,0.12,1.38),Vector3(0.81,0.13,-2.76),"d6e0d9")
	part(art,"ShowerInset",Vector3(0.99,0.02,1.22),Vector3(0.81,0.20,-2.76),"a6c5c5")
	part(art,"ShowerDrain",Vector3(0.12,0.005,0.12),Vector3(0.81,0.213,-2.76),"6f939b")
	part(art,"ShowerRiser",Vector3(0.045,0.95,0.045),Vector3(0.82,0.75,-3.42),"789da4")
	part(art,"ShowerHead",Vector3(0.27,0.06,0.20),Vector3(0.82,1.20,-3.33),"a3bcba")
	var glass = part(art,"ShowerScreen",Vector3(0.022,0.97,1.35),Vector3(1.39,0.71,-2.76),"9fc9cf")
	var surface = glass.material_override as StandardMaterial3D
	surface.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	surface.albedo_color.a = 0.13
	surface.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	part(art,"ShowerScreenRail",Vector3(0.035,0.035,1.37),Vector3(1.39,1.21,-2.76),"b6cbca")
	solid(level,Vector3(1.15,0.20,1.40),Vector3(0.81,0.16,-2.76))
	part(art,"BathMat",Vector3(0.9,0.012,0.60),Vector3(0.85,0.08,-1.56),"779e9e")
	part(art,"TowelRail",Vector3(0.55,0.035,0.07),Vector3(2.00,0.53,0.29),"6f969e")
	part(art,"FoldedTowel",Vector3(0.38,0.31,0.04),Vector3(2.00,0.40,0.25),"e7d7b8")
	part(art,"ToiletRollHolder",Vector3(0.045,0.09,0.12),Vector3(3.49,0.54,-1.17),"6e939a")
	part(art,"ToiletRoll",Vector3(0.11,0.17,0.19),Vector3(3.42,0.54,-1.17),"eee9d6")

static func plant(parent: Node3D, at: Vector3, scale: float) -> void:
	var pot = Models.cylinder(parent,0.20*scale,0.32*scale,at+Vector3(0,0.16*scale,0),Color("a98864"))
	pot.name = "HouseplantPot"
	for i in range(3):
		var leaf = part(parent,"HouseplantLeaf",Vector3(0.13,0.45,0.22)*scale,at+Vector3((i-1)*0.10,0.50,0)*scale,"588468")
		leaf.rotation.z = (i-1)*0.38

static func window(parent: Node3D, at: Vector3, side_wall: bool) -> void:
	var frame = Node3D.new()
	frame.position = at
	if side_wall: frame.rotation.y = PI/2
	parent.add_child(frame)
	part(frame,"WindowFrame",Vector3(0.92,0.38,0.07),Vector3.ZERO,"e0d7bb")
	part(frame,"WindowNightGlass",Vector3(0.77,0.25,0.085),Vector3.ZERO,"547b92")
	part(frame,"WindowMullion",Vector3(0.04,0.30,0.10),Vector3.ZERO,"bdc7b8")

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))

static func light(parent: Node3D, label: String, at: Vector3, color: Color, energy: float, radius: float) -> void:
	var lamp = OmniLight3D.new()
	lamp.name = label
	lamp.position = at
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = radius
	lamp.shadow_enabled = false
	parent.add_child(lamp)
