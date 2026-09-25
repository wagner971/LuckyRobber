class_name HouseArt
extends RefCounted

const INTERIOR = preload("res://scripts/house_interior.gd")

# Suburban identity lives here, separate from the collision-tested room shell.
static func build(level: HeistLevel) -> void:
	var art := Node3D.new()
	art.name = "SuburbanHouseArt"
	level.add_child(art)
	var navy := Color("233951")
	var roof := Color("344a63")
	var trim := Color("e9dbc2")
	var stone := Color("acb9b6")
	var warm := Color("ffc981")
	var dark_green := Color("315d45")
	build_neighborhood(art)

	# A full street edge, driveway and rear lawn make this portrait composition
	# read as a property rather than a lone square room shell.
	box(art, Vector3(13.0, 0.10, 3.45), Vector3(0, -0.135, 12.35), Color("283949"))
	box(art, Vector3(13.0, 0.065, 1.04), Vector3(0, -0.07, 10.25), Color("aeb5b2"))
	box(art, Vector3(13.0, 0.11, 0.13), Vector3(0, -0.04, 10.82), Color("d3d0bc"))
	for x in [-5.3, -3.5, -1.7, 0.1, 1.9, 3.7, 5.5]:
		box(art, Vector3(0.045, 0.068, 1.0), Vector3(x, -0.029, 10.25), Color("87939a"))
	for x in [-5.0, -2.7, -0.4, 1.9, 4.2]:
		box(art, Vector3(1.15, 0.018, 0.11), Vector3(x, -0.065, 12.47), Color("e6c77f"))
	box(art, Vector3(5.95, 0.035, 6.80), Vector3(-2.08, -0.052, 6.58), Color("747f89"))
	box(art, Vector3(1.7, 0.04, 6.82), Vector3(0, -0.045, 6.58), Color("aeb7b4"))
	for z in [3.65, 4.55, 5.45, 6.35, 7.25, 8.15, 9.05, 9.95]:
		box(art, Vector3(1.64, 0.045, 0.055), Vector3(0, -0.012, z), Color("879492"))
	for x in [-5.35, 5.35]:
		box(art, Vector3(0.36, 0.055, 7.0), Vector3(x, -0.01, 6.50), dark_green)
	# A small front fence; the driveway and pedestrian gate remain completely open.
	for x in [-5.3, -4.5, 3.6, 4.4, 5.25]:
		box(art, Vector3(0.14, 0.48, 0.14), Vector3(x, 0.24, 9.72), trim)
	box(art, Vector3(1.85, 0.09, 0.09), Vector3(4.42, 0.36, 9.72), trim)
	# Mailbox, house number, shrubs and two uneven trees establish scale.
	box(art, Vector3(0.10, 0.72, 0.10), Vector3(4.35, 0.36, 9.25), Color("35404a"))
	box(art, Vector3(0.42, 0.29, 0.28), Vector3(4.35, 0.78, 9.25), Color("5f798d"))
	box(art, Vector3(0.47, 0.055, 0.34), Vector3(4.35, 0.94, 9.25), navy)
	box(art, Vector3(0.25, 0.06, 0.04), Vector3(4.35, 0.79, 9.41), trim)
	for x in [-5.4, 5.4]:
		level.house_solid(art, Vector3(0.12, 1.92, 0.12), Vector3(x, 0.96, 10.85), Color("344553"))
		box(art, Vector3(0.56, 0.10, 0.11), Vector3(x + (0.22 if x < 0 else -0.22), 1.89, 10.85), Color("344553"))
		box(art, Vector3(0.23, 0.17, 0.22), Vector3(x + (0.42 if x < 0 else -0.42), 1.82, 10.85), warm)
		light(art, Vector3(x + (0.42 if x < 0 else -0.42), 1.72, 10.85), warm, 0.9, 3.4)
	# A parked car in front of the garage, leaving the central van lane open.
	level.house_solid(art, Vector3(1.62, 0.55, 3.35), Vector3(-3.16, 0.53, 5.56), Color("557d9d"))
	box(art, Vector3(1.57, 0.17, 2.47), Vector3(-3.16, 0.89, 5.17), Color("426782"))
	box(art, Vector3(1.48, 0.52, 1.33), Vector3(-3.16, 1.02, 6.09), Color("3e5e79"))
	box(art, Vector3(1.34, 0.065, 1.05), Vector3(-3.16, 1.31, 6.04), Color("557d9d"))
	box(art, Vector3(1.30, 0.045, 0.56), Vector3(-3.16, 1.10, 6.76), Color("a4c9d2"))
	for x in [-3.99, -2.33]:
		for z in [4.45, 6.67]:
			var car_wheel = Models.cylinder(art, 0.32, 0.18, Vector3(x, 0.31, z), Color("263746"))
			car_wheel.rotation_degrees.z = 90
	for x in [-3.64, -2.68]:
		box(art, Vector3(0.28, 0.11, 0.07), Vector3(x, 0.57, 7.25), Color("ffe0a1"))
		box(art, Vector3(0.24, 0.10, 0.07), Vector3(x, 0.57, 3.87), Color("d66e65"))
	for x in [-3.99, -2.33]:
		box(art, Vector3(0.035, 0.09, 0.25), Vector3(x, 0.77, 5.60), Color("dce4df"))
	for at in [Vector3(4.78, 0, 3.75), Vector3(4.62, 0, 2.90), Vector3(-5.38, 0, 3.5), Vector3(4.9, 0, -8.6), Vector3(-4.4, 0, -9.5)]:
		bush(art, at)
	tree(art, Vector3(5.45, 0, 7.7), 0.80)
	tree(art, Vector3(-5.48, 0, -9.4), 0.75)
	tree(art, Vector3(5.22, 0, -9.65), 0.58)
	box(art, Vector3(2.1, 0.035, 0.85), Vector3(1.75, -0.038, -8.9), Color("77966c"))

	# Garage door and its low gable create the asymmetric silhouette. The rest of
	# the roof is only a narrow outer rim: the rooms remain open to the camera.
	box(art, Vector3(3.34, 0.76, 0.055), Vector3(-3.19, 0.43, 3.34), Color("647283"))
	for y in [0.20, 0.38, 0.56, 0.74]:
		box(art, Vector3(3.24, 0.027, 0.065), Vector3(-3.19, y, 3.38), Color("344759"))
	for x in [-4.78, -1.62]:
		box(art, Vector3(0.11, 0.85, 0.14), Vector3(x, 0.44, 3.38), trim)
	box(art, Vector3(10.55, 0.13, 0.54), Vector3(0, 1.20, -7.75), roof)
	for x in [-5.05, 5.05]:
		box(art, Vector3(0.55, 0.13, 10.95), Vector3(x, 0.86, -2.275), roof)
	box(art, Vector3(3.65, 0.13, 0.5), Vector3(3.23, 0.86, 3.2), roof)
	# Right front window, porch column and lantern: bright enough to read at night.
	box(art, Vector3(0.83, 0.39, 0.055), Vector3(4.03, 0.54, 3.33), Color("ffdc9a"))
	for x in [3.58, 4.48]:
		box(art, Vector3(0.07, 0.48, 0.10), Vector3(x, 0.54, 3.4), trim)
	box(art, Vector3(0.95, 0.07, 0.12), Vector3(4.03, 0.77, 3.40), trim)
	box(art, Vector3(0.95, 0.07, 0.12), Vector3(4.03, 0.30, 3.40), trim)
	box(art, Vector3(0.18, 0.84, 0.18), Vector3(1.48, 0.42, 3.63), trim)
	box(art, Vector3(0.22, 0.28, 0.16), Vector3(1.75, 0.71, 3.40), Color("293e50"))
	box(art, Vector3(0.12, 0.14, 0.08), Vector3(1.75, 0.71, 3.52), warm)
	light(art, Vector3(1.75, 1.05, 3.55), warm, 1.6, 3.2)
	box(art, Vector3(1.0, 0.028, 0.45), Vector3(0, 0.055, 3.5), Color("876c52"))

	INTERIOR.build(level)

static func build_neighborhood(art: Node3D) -> void:
	# The visual ground extends beyond all camera-follow positions. None of these
	# meshes have collision; the playable property and its tested routes stay put.
	var district := Node3D.new()
	district.name = "SuburbanSurroundings"
	art.add_child(district)
	flat(district, "OuterLawn", Vector3(48.0, 0.20, 64.0), Vector3(0, -0.30, 2.0), Color("2f5442"))
	# Continue the original street and sidewalks across the wider frame.
	flat(district, "NeighborhoodStreet", Vector3(48.0, 0.085, 15.0), Vector3(0, -0.135, 17.9), Color("283949"))
	for z in [10.8, 24.8]:
		flat(district, "LongCurb", Vector3(48.0, 0.10, 0.16), Vector3(0, -0.07, z), Color("c5c8bb"))
		flat(district, "LongSidewalk", Vector3(48.0, 0.045, 1.15), Vector3(0, -0.105, z + (-0.62 if z < 15.0 else 0.62)), Color("9ea9a8"))
	for x in [-21.0, -16.0, -11.0, -6.0, 6.0, 11.0, 16.0, 21.0]:
		flat(district, "StreetCenterDash", Vector3(2.0, 0.012, 0.10), Vector3(x, -0.085, 18.1), Color("c5b88e"))
	for x in [-21.0, -17.5, -14.0, -10.5, -7.0, 7.0, 10.5, 14.0, 17.5, 21.0]:
		flat(district, "SidewalkJoint", Vector3(0.04, 0.009, 1.13), Vector3(x, -0.075, 10.18), Color("71868a"))
	# Side lots have narrow planted boundaries, independent driveways and
	# recognisable roofed houses. Keep their facades darker than the active home.
	for side in [-1.0, 1.0]:
		var boundary_x: float = side * 7.05
		for z in [-13.4, -10.2, -7.0, -3.8, -0.6, 2.6, 5.8, 8.9]:
			box(district, Vector3(0.13, 0.48, 0.13), Vector3(boundary_x, 0.19, z), Color("82988b"))
		for z in [-11.8, -8.6, -5.4, -2.2, 1.0, 4.2, 7.4]:
			box(district, Vector3(0.065, 0.13, 3.05), Vector3(boundary_x, 0.31, z), Color("91a398"))
		flat(district, "NeighborDriveway", Vector3(2.45, 0.035, 9.6), Vector3(side * 9.2, -0.12, 6.0), Color("78898a"))
		flat(district, "NeighborFrontWalk", Vector3(1.0, 0.025, 3.3), Vector3(side * 7.45, -0.11, 3.5), Color("adb1a5"))
		neighbor_home(district, side * 9.2, -4.0, Color("536a72") if side < 0 else Color("706f75"))
		for z in [-12.0, -8.2, 1.5, 7.6]:
			bush(district, Vector3(side * 7.7, -0.11, z))
		tree(district, Vector3(side * 13.8, -0.10, 5.7), 0.95)
	# A deeper back garden and the next fenced property close the upper edge.
	flat(district, "BackGarden", Vector3(23.0, 0.045, 7.5), Vector3(0, -0.14, -13.25), Color("3a6047"))
	for x in [-5.0, -2.5, 0.0, 2.5, 5.0]:
		flat(district, "BackLawnStripe", Vector3(0.055, 0.008, 5.5), Vector3(x, -0.108, -13.0), Color("496c50"))
	# A small neighbor-facing patio makes the added depth feel like a backyard.
	flat(district, "BackPatio", Vector3(3.25, 0.035, 2.8), Vector3(2.0, -0.095, -13.3), Color("82918a"))
	for x in [0.7, 1.8, 2.9]:
		flat(district, "PatioJoint", Vector3(0.035, 0.008, 2.68), Vector3(x, -0.074, -13.3), Color("5d7775"))
	box(district, Vector3(1.05, 0.10, 0.75), Vector3(2.0, 0.26, -13.25), Color("806f59"))
	for x in [1.6, 2.4]:
		for z in [-13.5, -13.0]:
			box(district, Vector3(0.08, 0.32, 0.08), Vector3(x, 0.06, z), Color("5c5144"))
	for x in [-3.9, -2.7]:
		bush(district, Vector3(x, -0.10, -13.8))
	for x in [-18.0, -15.0, -12.0, -9.0, -6.0, -3.0, 0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0]:
		box(district, Vector3(0.13, 0.62, 0.16), Vector3(x, 0.25, -17.1), Color("758877"))
	box(district, Vector3(36.0, 0.43, 0.11), Vector3(0, 0.24, -17.1), Color("7d907d"))
	flat(district, "RearLane", Vector3(48.0, 0.035, 3.0), Vector3(0, -0.145, -19.0), Color("4a5e60"))
	neighbor_home(district, 0.0, -21.5, Color("596a72"))
	for x in [-14.0, -10.0, 9.8, 14.2]:
		tree(district, Vector3(x, -0.11, -21.0), 0.82)
	# Across the street, a low planted verge keeps the bottom of portrait views
	# from fading into the empty WorldEnvironment.
	flat(district, "OppositeVerge", Vector3(48.0, 0.035, 8.3), Vector3(0, -0.145, 30.2), Color("314e40"))
	for x in [-18.0, -13.0, -8.0, 8.0, 13.0, 18.0]:
		bush(district, Vector3(x, -0.10, 27.0))

static func neighbor_home(parent: Node3D, x: float, z: float, facade: Color) -> void:
	flat(parent, "NeighborFoundation", Vector3(6.3, 0.12, 8.8), Vector3(x, -0.09, z), Color("747d79"))
	box(parent, Vector3(6.0, 0.88, 8.4), Vector3(x, 0.43, z), facade)
	box(parent, Vector3(6.45, 0.20, 8.75), Vector3(x, 0.98, z), Color("304558"))
	box(parent, Vector3(5.65, 0.035, 7.95), Vector3(x, 1.10, z), Color("3d5363"))
	for window_x in [-1.85, 0.0, 1.85]:
		box(parent, Vector3(0.86, 0.48, 0.07), Vector3(x + window_x, 0.54, z + 4.25), Color("263947"))
		box(parent, Vector3(0.62, 0.30, 0.025), Vector3(x + window_x, 0.55, z + 4.30), Color("e0ad71"))
	box(parent, Vector3(1.15, 0.12, 0.45), Vector3(x, 0.92, z + 4.35), Color("31475a"))

static func flat(parent: Node3D, label: String, size: Vector3, at: Vector3, color: Color) -> void:
	var mesh := Models.box(parent, size, at, color)
	mesh.name = label
	Models.set_toon_profile(mesh, ToonMaterial.Profile.GROUND)

static func box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> void:
	Models.box(parent, size, at, color)

static func bush(parent: Node3D, at: Vector3) -> void:
	Models.box(parent, Vector3(0.48, 0.38, 0.52), at + Vector3(0, 0.19, 0), Color("315d45"))
	Models.box(parent, Vector3(0.36, 0.36, 0.38), at + Vector3(0.1, 0.40, -0.07), Color("497b54"))

static func tree(parent: Node3D, at: Vector3, scale_factor: float) -> void:
	Models.box(parent, Vector3(0.26, 1.32, 0.26) * scale_factor, at + Vector3(0, 0.66 * scale_factor, 0), Color("715d4c"))
	for offset in [Vector3(0, 1.62, 0), Vector3(-0.30, 1.38, 0.12), Vector3(0.28, 1.41, -0.08)]:
		Models.box(parent, Vector3(0.83, 0.69, 0.76) * scale_factor, at + offset * scale_factor, Color("345f47") if offset.x < 0 else Color("416f4c"))

static func light(parent: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = at
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = reach
	lamp.shadow_enabled = false
	parent.add_child(lamp)
