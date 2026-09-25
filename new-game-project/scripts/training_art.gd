extends RefCounted

# An electronics hobby garage. Each movable object belongs to a workstation;
# decoration stays against the walls and the central loading route stays empty.
static func part(parent: Node3D, label: String, size: Vector3, at: Vector3, color: String) -> MeshInstance3D:
	var mesh = Models.box(parent, size, at, Color(color))
	mesh.name = label
	return mesh

static func build(level: Node3D) -> void:
	var art = Node3D.new()
	art.name = "TrainingGarageArt"
	level.add_child(art)
	grounds(art)
	part(art, "ConcreteSlab", Vector3(6.75,0.16,6.05), Vector3(0,-0.05,0.25), "a4aaa6")
	part(art, "FloorInset", Vector3(6.18,0.025,5.62), Vector3(0,0.045,0.25), "a6aba7")
	for x in [-1.04,1.04]:
		part(art,"ConcreteJoint",Vector3(0.018,0.005,5.6),Vector3(x,0.06,0.25),"8a9492")
	for z in [-0.85,1.35]:
		part(art,"ConcreteJoint",Vector3(6.15,0.005,0.018),Vector3(0,0.06,z),"8a9492")
	# Physical envelope: low cutaway sides, taller back wall for the workshop.
	level.wall(Vector3(6.7,1.4,0.20),Vector3(0,0.7,-2.7),Color("c7c9b9"))
	for side in [-1.0,1.0]:
		level.wall(Vector3(0.20,0.85,5.8),Vector3(side*3.24,0.425,0.25),Color("c7c9b9"))
		level.wall(Vector3(2.3,0.42,0.20),Vector3(side*2.2,0.21,3.2),Color("c7c9b9"))
		part(art,"SideWainscot",Vector3(0.025,0.36,5.65),Vector3(side*3.128,0.23,0.25),"506c73")
		part(art,"SideSkirting",Vector3(0.04,0.065,5.65),Vector3(side*3.11,0.10,0.25),"344b56")
		part(art,"ExteriorRoofEdge",Vector3(0.32,0.12,6.16),Vector3(side*3.34,0.94,0.26),"344959")
		part(art,"DoorTrack",Vector3(0.07,0.59,0.10),Vector3(side*1.03,0.36,3.08),"6f878c")
	part(art,"RearWainscot",Vector3(6.25,0.36,0.03),Vector3(0,0.23,-2.58),"506c73")
	part(art,"RearSkirting",Vector3(6.25,0.065,0.04),Vector3(0,0.10,-2.55),"344b56")
	part(art,"RearCoping",Vector3(6.9,0.12,0.34),Vector3(0,1.48,-2.73),"435967")
	workshop(art,level)
	# The TV has its own media cabinet; it stays here when the TV is stolen.
	part(art,"MediaCabinet",Vector3(1.72,0.43,0.72),Vector3(-2.12,0.29,-0.30),"51666c")
	part(art,"MediaCabinetTop",Vector3(1.83,0.08,0.81),Vector3(-2.12,0.545,-0.30),"c7ad80")
	for x in [-2.53,-1.70]:
		part(art,"CabinetDoor",Vector3(0.76,0.29,0.025),Vector3(x,0.30,0.071),"637b80")
		part(art,"CabinetPull",Vector3(0.19,0.035,0.04),Vector3(x,0.38,0.096),"b3beb8")
	solid(level,Vector3(1.72,0.49,0.72),Vector3(-2.12,0.30,-0.30))
	# A single workshop mat groups the PC and chair, away from the exit.
	part(art,"WorkstationMat",Vector3(2.05,0.012,1.72),Vector3(1.7,0.065,-0.91),"61777c")
	part(art,"MatBorder",Vector3(1.94,0.005,0.032),Vector3(1.7,0.075,-0.08),"8d9c96")
	# Open shutter threshold; no door mesh across the player's route.
	part(art,"Threshold",Vector3(2.02,0.035,0.30),Vector3(0,0.025,3.15),"7b8b8d")
	for x in [-0.83,-0.56,-0.28,0.0,0.28,0.56,0.83]:
		part(art,"ThresholdGrip",Vector3(0.08,0.007,0.26),Vector3(x,0.047,3.15),"c5ba8b")
	part(art,"FloorDrain",Vector3(2.7,0.012,0.16),Vector3(0,-0.027,3.62),"344a56")
	for x in range(-6,7):
		part(art,"DrainSlot",Vector3(0.05,0.005,0.12),Vector3(x*0.19,-0.019,3.62),"71898e")
	# Real fixtures explain the warm room against the blue evening outside.
	part(art,"WorkshopStripHousing",Vector3(2.4,0.10,0.18),Vector3(0.4,1.46,-2.49),"364d57")
	glow(part(art,"WorkshopStrip",Vector3(2.18,0.045,0.12),Vector3(0.4,1.41,-2.40),"ffe7b8"),Color("ffe1a5"))
	light(art,"WorkshopWarmLight",Vector3(0.45,2.4,-1.25),Color("ffe0ad"),1.15,5.1)
	for side in [-1.0,1.0]:
		part(art,"EntryLampBack",Vector3(0.25,0.30,0.14),Vector3(side*2.87,0.65,3.34),"304652")
		glow(part(art,"EntryLamp",Vector3(0.15,0.15,0.06),Vector3(side*2.87,0.66,3.43),"ffdb96"),Color("ffd393"))
		light(art,"EntryWarmLight",Vector3(side*2.8,1.25,3.7),Color("ffd59a"),0.42,2.8)

static func workshop(art: Node3D, level: Node3D) -> void:
	# PC repair bench at the back right. The PC occupies its right end;
	# a parts mat and tools occupy the left end, and the chair faces the bench.
	part(art,"WorkbenchTop",Vector3(2.43,0.10,0.87),Vector3(1.85,0.665,-2.02),"d0b68b")
	part(art,"BenchFrontRail",Vector3(2.25,0.15,0.06),Vector3(1.85,0.54,-1.61),"43565e")
	for x in [0.75,2.93]:
		for z in [-2.36,-1.69]:
			part(art,"BenchLeg",Vector3(0.09,0.56,0.09),Vector3(x,0.34,z),"425b66")
	solid(level,Vector3(2.4,0.63,0.84),Vector3(1.85,0.36,-2.02))
	part(art,"RepairMat",Vector3(0.93,0.012,0.51),Vector3(1.28,0.72,-1.99),"376d70")
	part(art,"PartsTray",Vector3(0.27,0.06,0.21),Vector3(1.04,0.755,-2.05),"637b82")
	part(art,"ScrewdriverHandle",Vector3(0.08,0.045,0.20),Vector3(1.54,0.75,-1.96),"c58a4f")
	part(art,"ScrewdriverShaft",Vector3(0.025,0.025,0.14),Vector3(1.54,0.75,-1.80),"c1cccb")
	# Dedicated tool board and organized closed storage; no decorative loot copies.
	part(art,"ToolBoardFrame",Vector3(2.7,0.85,0.10),Vector3(-1.45,0.90,-2.54),"344a55")
	part(art,"ToolBoard",Vector3(2.55,0.72,0.04),Vector3(-1.45,0.90,-2.47),"a0835f")
	for x in range(11):
		for y in range(3):
			part(art,"Peg",Vector3(0.026,0.026,0.008),Vector3(-2.59+x*0.23,0.66+y*0.22,-2.443),"6e604f")
	for i in range(4):
		var x := -2.34+i*0.53
		part(art,"HangingToolHandle",Vector3(0.065,0.24,0.07),Vector3(x,0.86,-2.39),"bc874a")
		part(art,"HangingToolHead",Vector3(0.19 if i%2 == 0 else 0.10,0.095,0.08),Vector3(x,1.03,-2.39),"9eafb1")
	part(art,"StorageCabinet",Vector3(1.05,0.47,0.57),Vector3(-2.49,0.32,-2.12),"526a74")
	for y in [0.20,0.37,0.53]:
		part(art,"StorageDrawer",Vector3(0.92,0.12,0.025),Vector3(-2.49,y,-1.82),"698087")
		part(art,"DrawerHandle",Vector3(0.24,0.027,0.035),Vector3(-2.49,y+0.025,-1.80),"c1c8bd")
	solid(level,Vector3(1.05,0.5,0.57),Vector3(-2.49,0.32,-2.12))
	# Fuse box / conduit and a coiled hose are workshop fixtures, not trophies.
	part(art,"FuseBox",Vector3(0.32,0.40,0.11),Vector3(2.83,1.08,-2.51),"738b8e")
	part(art,"Conduit",Vector3(0.045,0.8,0.045),Vector3(3.04,0.93,-2.50),"5d747b")
	var hose = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.21
	torus.outer_radius = 0.27
	torus.rings = 16
	torus.ring_segments = 8
	hose.mesh = torus
	hose.material_override = Models.material(Color("566c68"))
	hose.rotation_degrees.x = 90
	hose.position = Vector3(-2.96,0.62,1.55)
	hose.rotation_degrees.y = 90
	hose.name = "WallHose"
	art.add_child(hose)

static func grounds(art: Node3D) -> void:
	part(art,"NeighborhoodGround",Vector3(38,0.22,40),Vector3(0,-0.20,1.0),"314d4b")
	part(art,"Driveway",Vector3(7.1,0.04,7.7),Vector3(0,-0.065,6.95),"687b80")
	for z in [4.65,6.45,8.25]:
		part(art,"DrivewayJoint",Vector3(7.1,0.007,0.022),Vector3(0,-0.04,z),"506771")
	part(art,"Street",Vector3(38,0.04,13),Vector3(0,-0.067,16.5),"293e50")
	part(art,"Sidewalk",Vector3(38,0.075,1.3),Vector3(0,-0.027,10.25),"869b9d")
	part(art,"Curb",Vector3(38,0.10,0.14),Vector3(0,-0.01,10.92),"b0b9ae")
	for x in range(-9,10):
		part(art,"PavementJoint",Vector3(0.02,0.008,1.3),Vector3(x*1.8,0.015,10.25),"697f88")
	for x in [-12,-7,-2,3,8,13]:
		part(art,"StreetDash",Vector3(1.8,0.009,0.07),Vector3(x,-0.04,13.6),"aaa991")
	part(art,"RearGarden",Vector3(20,0.04,7),Vector3(0,-0.06,-6.4),"3e6051")
	for side in [-1.0,1.0]:
		part(art,"SidePath",Vector3(1.15,0.04,10.8),Vector3(side*4.00,-0.06,1.8),"82918e")
		part(art,"BoundaryFence",Vector3(0.14,0.67,16),Vector3(side*5.0,0.27,0.6),"526875")
		for z in [-6,-3,0,3,6,8.5]:
			part(art,"FencePost",Vector3(0.22,0.79,0.22),Vector3(side*5.0,0.34,z),"6c8087")
		for z in [-3.8,0.2,5.2]:
			shrub(art,Vector3(side*4.6,0,z))
		# Subdued neighboring garages fill camera-follow margins, not the play space.
		part(art,"Neighbor",Vector3(5.6,1.3,8.8),Vector3(side*8.6,0.59,-0.4),"4b626f")
		part(art,"NeighborRoof",Vector3(5.9,0.18,9.1),Vector3(side*8.6,1.34,-0.4),"2d465a")
		for z in [-3.5,-1.5,0.5,2.5]:
			part(art,"RoofSeam",Vector3(5.6,0.018,0.035),Vector3(side*8.6,1.44,z),"39566b")
	part(art,"RearFence",Vector3(20,0.85,0.18),Vector3(0,0.35,-7.8),"516c70")
	for x in [-7,-4,0,4,7]: shrub(art,Vector3(x,0,-6.9))

static func shrub(parent: Node3D, at: Vector3) -> void:
	part(parent,"PlantedShrub",Vector3(0.67,0.38,0.72),at+Vector3(0,0.14,0),"426950")
	part(parent,"ShrubCrown",Vector3(0.50,0.17,0.52),at+Vector3(0.02,0.39,0),"5b805e")

static func glow(mesh: MeshInstance3D, color: Color) -> void:
	var material = mesh.material_override as StandardMaterial3D
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.55

static func light(parent: Node3D, label: String, at: Vector3, color: Color, energy: float, radius: float) -> void:
	var lamp = OmniLight3D.new()
	lamp.name = label
	lamp.position = at
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = radius
	lamp.shadow_enabled = false
	parent.add_child(lamp)

static func solid(level: Node3D, size: Vector3, at: Vector3) -> void:
	level.barrier(size,at)
	level.walls.append(Rect2(at.x-size.x/2,at.z-size.z/2,size.x,size.z))
