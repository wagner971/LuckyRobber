extends RefCounted


const INTERIOR = preload("res://scripts/apartment_interior.gd")

# Exterior dressing plus furnished, physically solid room fixtures.
static func build(level: Node3D) -> void:
	build_neighborhood(level)
	# A narrow sidewalk and one parking bay replace the empty square of concrete.
	part(level, "ApartmentSidewalk", Vector3(9.0, 0.035, 0.9), Vector3(0, -0.055, 3.93), Color("c1b9aa"), ToonMaterial.Profile.GROUND)
	for x in [-2.8, -0.95, 0.95, 2.8]:
		part(level, "SidewalkJoint", Vector3(0.035, 0.008, 0.84), Vector3(x, -0.032, 3.93), Color("8d9695"), ToonMaterial.Profile.GROUND)
	part(level, "ApartmentParkingBay", Vector3(3.7, 0.09, 3.95), Vector3(0, -0.13, 6.15), Color("566774"), ToonMaterial.Profile.GROUND)
	for x in [-1.58, 1.58]:
		part(level, "ParkingLine", Vector3(0.055, 0.012, 3.4), Vector3(x, -0.076, 6.2), Color("d7cfaf"), ToonMaterial.Profile.GROUND)
	for x in [-1.16, 1.16]:
		part(level, "LoadEdge", Vector3(0.09, 0.012, 0.48), Vector3(x, -0.031, 4.48), Color("78dbb8"), ToonMaterial.Profile.GROUND)
	part(level, "Curb", Vector3(9.15, 0.12, 0.18), Vector3(0, -0.075, 4.45), Color("e2d8c3"), ToonMaterial.Profile.GROUND)
	part(level, "StreetEdge", Vector3(9.3, 0.035, 0.75), Vector3(0, -0.15, 8.23), Color("283d50"), ToonMaterial.Profile.GROUND)
	for x in [-2.55, 2.55]:
		part(level, "StreetDash", Vector3(0.8, 0.006, 0.045), Vector3(x, -0.125, 8.27), Color("c2b999"), ToonMaterial.Profile.GROUND)

	# One obvious entry aligned with the rear of the van and the central Living lane.
	part(level, "EntryMat", Vector3(1.18, 0.018, 0.54), Vector3(0, 0.045, 3.58), Color("80634e"), ToonMaterial.Profile.GROUND)
	part(level, "EntryMatInset", Vector3(0.86, 0.006, 0.29), Vector3(0, 0.059, 3.59), Color("bca080"), ToonMaterial.Profile.GROUND)
	part(level, "PorchLamp", Vector3(0.16, 0.22, 0.14), Vector3(1.53, 0.69, 3.36), Color("ffcc71"))
	var porch := OmniLight3D.new()
	porch.name = "ApartmentPorchLight"
	porch.light_color = Color("ffd69a")
	porch.light_energy = 0.36
	porch.omni_range = 2.3
	porch.shadow_enabled = false
	porch.position = Vector3(1.53, 1.0, 3.52)
	level.add_child(porch)

	# A wall AC and mailbox are enough to say small urban apartment.
	part(level, "ExteriorAC", Vector3(0.23, 0.40, 0.62), Vector3(-3.81, 0.50, -2.35), Color("d5dad3"))
	for z in [-2.53, -2.38, -2.23]:
		part(level, "ACVent", Vector3(0.018, 0.20, 0.045), Vector3(-3.94, 0.50, z), Color("5d7179"))
	part(level, "Mailbox", Vector3(0.34, 0.28, 0.13), Vector3(3.01, 0.54, 3.36), Color("41627a"))
	part(level, "MailboxSlot", Vector3(0.22, 0.025, 0.018), Vector3(3.01, 0.59, 3.44), Color("dbe3da"))
	part(level, "RearFacadeCap", Vector3(7.75, 0.075, 0.20), Vector3(0, 1.25, -3.65), Color("6b7d82"))

	INTERIOR.build(level)


static func build_neighborhood(level: Node3D) -> void:
	# This visual-only city block continues beyond every camera follow position.
	# Keep it below the playable slab so the original floor and van bay win overlaps.
	part(level, "CityBlockGround", Vector3(38, 0.24, 38), Vector3(0, -0.205, 1.5), Color("263d4a"), ToonMaterial.Profile.GROUND)
	part(level, "CrossStreet", Vector3(38, 0.035, 12.8), Vector3(0, -0.066, 13.6), Color("2d4150"), ToonMaterial.Profile.GROUND)
	for x in [-15.0, -10.0, -5.0, 5.0, 10.0, 15.0]:
		part(level, "StreetCenterDash", Vector3(2.15, 0.009, 0.085), Vector3(x, -0.043, 10.9), Color("b9b69b"), ToonMaterial.Profile.GROUND)
	for z in [8.8, 18.4]:
		part(level, "StreetCurb", Vector3(38, 0.11, 0.16), Vector3(0, -0.008, z), Color("adb4ac"), ToonMaterial.Profile.GROUND)
		part(level, "StreetSidewalk", Vector3(38, 0.035, 1.0), Vector3(0, -0.038, z + (0.57 if z > 10.0 else -0.57)), Color("a9b3b0"), ToonMaterial.Profile.GROUND)
	for x in [-14.0, -11.0, -8.0, 8.0, 11.0, 14.0]:
		part(level, "NeighborhoodWalkJoint", Vector3(0.035, 0.008, 1.0), Vector3(x, -0.016, 7.7), Color("71878d"), ToonMaterial.Profile.GROUND)
	# Sidewalks and planted strips lead the eye into the neighboring apartment blocks.
	for side in [-1.0, 1.0]:
		var x: float = side * 5.45
		part(level, "SideWalk", Vector3(1.65, 0.045, 12.0), Vector3(x, -0.05, 0.3), Color("a9b2ad"), ToonMaterial.Profile.GROUND)
		for z in [-4.5, -2.0, 0.5, 3.0, 5.5]:
			part(level, "SideWalkJoint", Vector3(1.5, 0.008, 0.03), Vector3(x, -0.023, z), Color("70848a"), ToonMaterial.Profile.GROUND)
		part(level, "GardenStrip", Vector3(1.0, 0.045, 9.8), Vector3(side * 6.85, -0.08, -0.8), Color("38564b"), ToonMaterial.Profile.GROUND)
		for z in [-3.4, -0.6, 2.0]:
			part(level, "GardenShrub", Vector3(0.68, 0.44, 0.7), Vector3(side * 6.85, 0.18, z), Color("426f57"))
			part(level, "ShrubHighlight", Vector3(0.47, 0.12, 0.47), Vector3(side * 6.85, 0.43, z), Color("609071"))
		build_neighbor(level, side)
		build_streetlamp(level, side * 8.1, 8.2)
	# A low retaining wall closes the distant rear edge without hiding the cutaway.
	part(level, "RearLane", Vector3(38, 0.03, 3.2), Vector3(0, -0.062, -8.0), Color("344a53"), ToonMaterial.Profile.GROUND)
	part(level, "RearSidewalk", Vector3(38, 0.035, 1.1), Vector3(0, -0.036, -5.1), Color("879a9c"), ToonMaterial.Profile.GROUND)
	for x in [-15.0, -12.0, -9.0, -6.0, -3.0, 0.0, 3.0, 6.0, 9.0, 12.0, 15.0]:
		part(level, "RearSidewalkJoint", Vector3(0.035, 0.008, 1.05), Vector3(x, -0.012, -5.1), Color("5d777c"), ToonMaterial.Profile.GROUND)
	part(level, "RearLaneMarking", Vector3(38, 0.007, 0.06), Vector3(0, -0.041, -6.4), Color("80959a"), ToonMaterial.Profile.GROUND)
	for x in [-14.0, -7.0, 0.0, 7.0, 14.0]:
		part(level, "RearWallPost", Vector3(0.35, 0.8, 0.4), Vector3(x, 0.32, -10.2), Color("526474"))
	part(level, "RearWall", Vector3(38, 0.55, 0.3), Vector3(0, 0.22, -10.2), Color("405565"))


static func build_neighbor(level: Node3D, side: float) -> void:
	var x := side * 10.25
	part(level, "NeighborFoundation", Vector3(5.85, 0.16, 9.3), Vector3(x, -0.035, -0.65), Color("696f71"), ToonMaterial.Profile.GROUND)
	part(level, "NeighborFacade", Vector3(5.45, 0.75, 8.65), Vector3(x, 0.42, -0.65), Color("64767b"))
	part(level, "NeighborRoof", Vector3(5.7, 0.23, 8.9), Vector3(x, 0.91, -0.65), Color("344c60"))
	part(level, "NeighborRoofInset", Vector3(5.15, 0.06, 8.2), Vector3(x, 1.05, -0.65), Color("405b6c"))
	for z in [-3.45, -1.55, 0.35, 2.25]:
		part(level, "NeighborRoofSeam", Vector3(5.15, 0.012, 0.05), Vector3(x, 1.086, z), Color("273c4e"))
	for z in [-2.9, 1.25]:
		part(level, "NeighborSkylightFrame", Vector3(1.35, 0.07, 0.92), Vector3(x - side * 1.2, 1.12, z), Color("82919a"))
		part(level, "NeighborSkylight", Vector3(1.08, 0.015, 0.67), Vector3(x - side * 1.2, 1.16, z), Color("d8ad69"))
	# Warm windows on the street-facing wall make the dark block feel occupied.
	for window_x in [-1.65, 0.0, 1.65]:
		part(level, "NeighborWindowFrame", Vector3(0.96, 0.44, 0.055), Vector3(x + window_x, 0.42, 3.70), Color("233b4b"))
		part(level, "NeighborWarmWindow", Vector3(0.72, 0.25, 0.018), Vector3(x + window_x, 0.43, 3.74), Color("e2b973"))


static func build_streetlamp(level: Node3D, x: float, z: float) -> void:
	part(level, "StreetlampFoot", Vector3(0.40, 0.09, 0.40), Vector3(x, 0.01, z), Color("283c49"))
	part(level, "StreetlampPole", Vector3(0.10, 2.35, 0.10), Vector3(x, 1.22, z), Color("334450"))
	part(level, "StreetlampHead", Vector3(0.52, 0.15, 0.46), Vector3(x, 2.43, z), Color("4a5f65"))
	part(level, "StreetlampGlow", Vector3(0.42, 0.025, 0.36), Vector3(x, 2.34, z), Color("f4c57e"))
	var glow := OmniLight3D.new()
	glow.name = "ApartmentStreetlight"
	glow.light_color = Color("ffbf74")
	glow.light_energy = 0.48
	glow.omni_range = 3.6
	glow.shadow_enabled = false
	glow.position = Vector3(x, 2.18, z)
	level.add_child(glow)


static func part(level: Node3D, part_name: String, size: Vector3, at: Vector3, color: Color, profile: ToonMaterial.Profile = ToonMaterial.Profile.PROP) -> MeshInstance3D:
	var mesh := Models.box(level, size, at, color)
	mesh.name = part_name
	Models.set_toon_profile(mesh, profile)
	return mesh
