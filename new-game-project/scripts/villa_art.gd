extends RefCounted

const INTERIOR = preload("res://scripts/villa_interior.gd")


# Presentation only. Collision, loot and the four direct hall entrances belong to
# HeistLevel; these pieces can never silently close a route to the van.
static func build(level: Node3D) -> void:
	var art := Node3D.new()
	art.name = "VillaArt"
	level.add_child(art)
	var stone := Color("bfc3ba")
	var ivory := Color("e8dcc7")
	var gold := Color("d8ae64")
	var ink := Color("334455")
	var warm := Color("ffd6a1")
	build_estate_surroundings(art)

	# A formal forecourt replaces the suburban garage and lawn composition.
	box(art, "LongApproach", Vector3(4.45, 0.034, 4.2), Vector3(0, -0.052, 10.65), Color("87969a"), true)
	for x in [-2.24, 2.24]:
		box(art, "ApproachEdge", Vector3(0.13, 0.052, 4.25), Vector3(x, -0.028, 10.65), ivory, true)
	box(art, "GateApron", Vector3(13.3, 0.035, 0.95), Vector3(0, -0.053, 12.65), stone, true)
	for x in [-5.5, 5.5]:
		box(art, "GatePier", Vector3(0.6, 0.88, 0.6), Vector3(x, 0.44, 12.52), ivory)
		box(art, "GatePierCap", Vector3(0.76, 0.11, 0.76), Vector3(x, 0.93, 12.52), gold)
		box(art, "GateLamp", Vector3(0.26, 0.3, 0.26), Vector3(x, 1.12, 12.52), warm)
		lamp(art, Vector3(x, 1.25, 12.52), warm, 0.43, 2.5)
	for x in [-3.95, 3.95]:
		box(art, "GateWing", Vector3(2.25, 0.07, 0.11), Vector3(x, 0.52, 12.5), ink)
		for offset in [-0.8, -0.4, 0.0, 0.4, 0.8]:
			box(art, "GatePicket", Vector3(0.07, 0.64, 0.09), Vector3(x + offset, 0.35, 12.5), ink)
	box(art, "Courtyard", Vector3(10.4, 0.035, 5.1), Vector3(0, -0.055, 5.9), Color("adb2ac"), true)
	box(art, "ArrivalLane", Vector3(3.15, 0.018, 5.2), Vector3(0, -0.030, 5.9), Color("87969a"), true)
	for z in [3.72, 4.8, 5.88, 6.96, 8.04]:
		box(art, "CourtyardJoint", Vector3(10.2, 0.006, 0.035), Vector3(0, -0.033, z), Color("d8d1bf"), true)
	for x in [-5.34, 5.34]:
		box(art, "GardenBed", Vector3(1.54, 0.055, 4.35), Vector3(x, -0.021, 5.72), Color("344e45"), true)
		box(art, "StoneBorder", Vector3(0.14, 0.065, 4.5), Vector3(x + (-0.79 if x < 0 else 0.79), 0.002, 5.72), ivory, true)
	for x in [-5.3, 5.3]:
		for z in [4.0, 6.0, 8.0]:
			shrub(art, Vector3(x, 0.0, z))
	box(art, "ArrivalStep", Vector3(3.2, 0.08, 0.7), Vector3(0, 0.01, 3.47), stone, true)
	box(art, "EntryRunner", Vector3(1.9, 0.022, 1.18), Vector3(0, 0.068, 3.16), Color("75556a"), true)
	box(art, "EntryRunnerBorder", Vector3(1.61, 0.005, 0.87), Vector3(0, 0.082, 3.16), Color("9e7e80"), true)
	for x in [-2.15, 2.15]:
		box(art, "PorticoColumn", Vector3(0.32, 1.25, 0.32), Vector3(x, 0.62, 3.68), ivory)
		box(art, "PorticoFoot", Vector3(0.52, 0.13, 0.52), Vector3(x, 0.08, 3.68), stone)
		box(art, "PorticoCapital", Vector3(0.53, 0.11, 0.53), Vector3(x, 1.25, 3.68), gold)
		box(art, "EntryLantern", Vector3(0.19, 0.30, 0.15), Vector3(x * 1.36, 0.88, 3.37), gold)
		lamp(art, Vector3(x * 1.36, 1.16, 3.48), warm, 0.53, 3.4)
	# A slim roofline and rear terrace sell the larger villa without covering rooms.
	box(art, "RearTerrace", Vector3(10.8, 0.07, 1.18), Vector3(0, -0.06, -10.02), stone, true)
	for x in [-5.55, -3.7, 3.7, 5.55]:
		box(art, "RearBaluster", Vector3(0.17, 0.58, 0.17), Vector3(x, 0.29, -10.38), ivory)
	box(art, "RearRail", Vector3(11.3, 0.10, 0.13), Vector3(0, 0.62, -10.38), ivory)
	box(art, "RearCornice", Vector3(12.45, 0.12, 0.34), Vector3(0, 1.20, -9.15), ink)
	for x in [-6.05, 6.05]:
		box(art, "SideCornice", Vector3(0.35, 0.12, 12.45), Vector3(x, 0.83, -2.975), ink)

	# The long, open axis is the visual difference from the family house.
	box(art, "HallRunner", Vector3(1.48, 0.018, 8.8), Vector3(0, 0.084, -2.64), Color("a88268"), true)
	for x in [-0.76, 0.76]:
		box(art, "HallGoldEdge", Vector3(0.035, 0.006, 8.6), Vector3(x, 0.098, -2.64), gold, true)
	var medallion = Models.cylinder(art, 0.64, 0.012, Vector3(0, 0.101, -4.2), gold)
	medallion.name = "HallMedallion"
	Models.set_toon_profile(medallion, ToonMaterial.Profile.GROUND)
	var center = Models.cylinder(art, 0.45, 0.014, Vector3(0, 0.112, -4.2), Color("6a8490"))
	center.name = "HallMedallionCenter"
	Models.set_toon_profile(center, ToonMaterial.Profile.GROUND)
	for x in [-1.41, 1.41]:
		box(art, "HallSconce", Vector3(0.15, 0.23, 0.13), Vector3(x, 0.67, -7.9), gold)
		lamp(art, Vector3(x, 1.28, -7.9), warm, 0.48, 2.7)

	INTERIOR.build(level)


static func build_estate_surroundings(art: Node3D) -> void:
	# An estate, not another neighborhood: axial garden, stone approaches and
	# layered planting fill every camera-follow view without adding collision.
	var estate := Node3D.new()
	estate.name = "VillaSurroundings"
	art.add_child(estate)
	var lawn := Color("304b43")
	var pale_stone := Color("a9ada5")
	var hedge := Color("31574a")
	var dark_ink := Color("344753")
	box(estate, "EstateGround", Vector3(54.0, 0.20, 72.0), Vector3(0, -0.31, 2.0), Color("29463f"), true)
	# Continue the long drive past the playable gate to a quiet boulevard.
	box(estate, "ExtendedDrive", Vector3(4.4, 0.045, 12.6), Vector3(0, -0.12, 18.6), Color("879395"), true)
	for x in [-2.28, 2.28]:
		box(estate, "DriveStoneEdge", Vector3(0.16, 0.06, 12.6), Vector3(x, -0.09, 18.6), Color("c6c4b5"), true)
	for z in [15.0, 17.5, 20.0, 22.5]:
		box(estate, "DriveJoint", Vector3(4.2, 0.008, 0.035), Vector3(0, -0.09, z), Color("5e777a"), true)
	box(estate, "EstateBoulevard", Vector3(54.0, 0.09, 9.0), Vector3(0, -0.14, 29.1), Color("283d4b"), true)
	for z in [24.55, 33.65]:
		box(estate, "BoulevardCurb", Vector3(54.0, 0.10, 0.18), Vector3(0, -0.06, z), Color("c5c8be"), true)
		box(estate, "BoulevardWalk", Vector3(54.0, 0.04, 1.0), Vector3(0, -0.11, z + (-0.58 if z < 30 else 0.58)), pale_stone, true)
	for x in [-24.0, -18.0, -12.0, -6.0, 6.0, 12.0, 18.0, 24.0]:
		box(estate, "BoulevardDash", Vector3(2.2, 0.012, 0.10), Vector3(x, -0.084, 29.15), Color("d2c493"), true)
	# Symmetrical side gardens keep the villa's formal identity even at the
	# camera's extreme left and right follow positions.
	for side in [-1.0, 1.0]:
		box(estate, "SidePromenade", Vector3(1.45, 0.035, 19.0), Vector3(side * 7.6, -0.115, -1.6), pale_stone, true)
		for z in [-9.5, -5.5, -1.5, 2.5, 6.5]:
			box(estate, "PromenadeJoint", Vector3(1.38, 0.008, 0.035), Vector3(side * 7.6, -0.091, z), Color("6d7c7b"), true)
		box(estate, "FormalParterre", Vector3(3.3, 0.045, 15.8), Vector3(side * 10.3, -0.14, -2.3), lawn, true)
		for x_offset in [-1.28, 1.28]:
			box(estate, "ParterreHedge", Vector3(0.40, 0.38, 15.3), Vector3(side * 10.3 + x_offset, 0.08, -2.3), hedge)
		for z in [-8.9, -4.2, 0.5, 5.2]:
			box(estate, "ParterreCrossHedge", Vector3(2.2, 0.31, 0.36), Vector3(side * 10.3, 0.045, z), hedge)
		box(estate, "SidePoolRim", Vector3(1.75, 0.055, 2.35), Vector3(side * 10.3, -0.095, -6.45), Color("b8b6a6"), true)
		box(estate, "SidePoolWater", Vector3(1.4, 0.012, 2.0), Vector3(side * 10.3, -0.060, -6.45), Color("618a94"), true)
		for z in [-11.5, -6.5, -1.5, 3.5, 8.5]:
			cypress(estate, Vector3(side * 13.0, -0.10, z), 0.88)
		# Low outer wall and a distant, fully roofed guest wing frame the domain.
		box(estate, "EstateSideWall", Vector3(0.18, 0.58, 29.0), Vector3(side * 14.1, 0.16, -0.3), Color("778b82"))
		for z in [-13.8, -8.2, -2.6, 3.0, 8.6, 14.2]:
			box(estate, "EstateWallPier", Vector3(0.32, 0.79, 0.32), Vector3(side * 14.1, 0.27, z), Color("a9aaa0"))
		guest_wing(estate, side * 19.1, -2.5)
	# The rear terrace opens onto a reflecting pool and clipped hedges.
	box(estate, "RearGarden", Vector3(16.5, 0.045, 13.0), Vector3(0, -0.14, -16.1), Color("365649"), true)
	for x in [-5.2, 5.2]:
		box(estate, "RearGardenHedge", Vector3(0.48, 0.43, 10.0), Vector3(x, 0.08, -16.1), hedge)
	for z in [-11.8, -20.5]:
		box(estate, "RearGardenCrossHedge", Vector3(9.9, 0.35, 0.42), Vector3(0, 0.04, z), hedge)
	box(estate, "ReflectingPoolRim", Vector3(4.4, 0.07, 5.0), Vector3(0, -0.09, -16.0), Color("c2bfae"), true)
	box(estate, "ReflectingPoolWater", Vector3(3.95, 0.012, 4.55), Vector3(0, -0.046, -16.0), Color("638d99"), true)
	for x in [-7.1, 7.1]:
		for z in [-12.0, -17.0, -21.0]:
			cypress(estate, Vector3(x, -0.10, z), 0.70)
	box(estate, "RearEstateWall", Vector3(39.0, 0.60, 0.20), Vector3(0, 0.17, -24.2), Color("778b82"))
	for x in [-18.0, -12.0, -6.0, 0.0, 6.0, 12.0, 18.0]:
		box(estate, "RearWallPier", Vector3(0.36, 0.84, 0.36), Vector3(x, 0.29, -24.2), Color("a9aaa0"))
	# A final planted verge keeps the lower portrait edge grounded past the road.
	box(estate, "OppositeVerge", Vector3(54.0, 0.04, 5.8), Vector3(0, -0.14, 38.0), Color("304d42"), true)
	for x in [-22.0, -16.0, -10.0, 10.0, 16.0, 22.0]:
		shrub(estate, Vector3(x, -0.10, 36.2))


static func cypress(parent: Node3D, at: Vector3, scale_factor: float) -> void:
	box(parent, "CypressTrunk", Vector3(0.25, 1.05, 0.25) * scale_factor, at + Vector3(0, 0.53 * scale_factor, 0), Color("665849"))
	box(parent, "CypressCrown", Vector3(0.75, 2.25, 0.75) * scale_factor, at + Vector3(0, 1.42 * scale_factor, 0), Color("264c43"))
	box(parent, "CypressTip", Vector3(0.48, 0.72, 0.48) * scale_factor, at + Vector3(0, 2.55 * scale_factor, 0), Color("356055"))


static func guest_wing(parent: Node3D, x: float, z: float) -> void:
	box(parent, "GuestWingFoundation", Vector3(6.0, 0.13, 10.0), Vector3(x, -0.10, z), Color("89938e"), true)
	box(parent, "GuestWingFacade", Vector3(5.65, 0.90, 9.65), Vector3(x, 0.42, z), Color("858b84"))
	box(parent, "GuestWingRoof", Vector3(6.25, 0.22, 10.15), Vector3(x, 0.99, z), Color("354b56"))
	for window_x in [-1.65, 0.0, 1.65]:
		box(parent, "GuestWindowFrame", Vector3(0.9, 0.44, 0.08), Vector3(x + window_x, 0.48, z + 4.87), Color("344452"))
		box(parent, "GuestWarmWindow", Vector3(0.64, 0.26, 0.018), Vector3(x + window_x, 0.49, z + 4.92), Color("d3ae75"))


static func box(parent: Node3D, part_name: String, size: Vector3, at: Vector3, color: Color, ground: bool = false) -> MeshInstance3D:
	var piece := Models.box(parent, size, at, color)
	piece.name = part_name
	Models.set_toon_profile(piece, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	return piece


static func shrub(parent: Node3D, at: Vector3) -> void:
	box(parent, "FormalHedge", Vector3(0.78, 0.43, 0.62), at + Vector3(0, 0.23, 0), Color("2f5c4d"))
	box(parent, "FormalHedgeTop", Vector3(0.65, 0.24, 0.53), at + Vector3(0, 0.53, 0), Color("42715a"))


static func lamp(parent: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	parent.add_child(light)
