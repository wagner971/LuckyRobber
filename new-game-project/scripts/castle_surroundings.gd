extends RefCounted


# Visual-only night estate beyond the playable keep and van approach.
static func build(level: Node3D) -> void:
	var art := Node3D.new()
	art.name = "CastleSurroundings"
	level.add_child(art)
	var soil := Color("293a4e")
	var paving := Color("566175")
	var stone := Color("788095")
	var water := Color("1c3446")
	box(art, "NightEstateGround", Vector3(66, 0.16, 84), Vector3(0, -0.20, 3), soil, true)
	# Side courts meet the original keep's raised slab and transition into woods.
	for side in [-1.0, 1.0]:
		box(art, "KeepSideCourt", Vector3(4.0, 0.065, 22.0), Vector3(side * 8.3, -0.15, 1.0), Color("3b4a5e"), true)
		for z in [-8.5, -4.1, 0.3, 4.7, 9.1]:
			box(art, "SideCourtJoint", Vector3(3.85, 0.012, 0.07), Vector3(side * 8.3, -0.108, z), Color("647083"), true)
		for z in [-9.2, -5.0, -0.8, 3.4, 7.6, 11.8]:
			pine(art, Vector3(side * 11.1, -0.11, z), 0.85 if int(z) % 2 else 1.05)
		for z in [-11.4, -2.4, 6.6, 15.6]:
			pine(art, Vector3(side * 15.0, -0.11, z), 1.15)
		for z in [-6.8, 1.2, 8.5]:
			box(art, "ForestRock", Vector3(1.0, 0.31, 0.77), Vector3(side * 8.8, -0.02, z), Color("60677a"))
		# A damaged boundary wall and two small watch posts frame the skyline.
		box(art, "OuterBoundary", Vector3(0.24, 0.63, 23.0), Vector3(side * 19.2, 0.19, -0.8), Color("4d5a6d"))
		for z in [-10.4, -4.6, 1.2, 7.0]:
			box(art, "BoundaryPier", Vector3(0.53, 0.94, 0.53), Vector3(side * 19.2, 0.33, z), stone)
		watch_post(art, side * 15.4, -13.2)
	# The left wing fades into trees; the crypt's right wing overlooks a small
	# ordered graveyard, recognizable without cluttering the playable room.
	box(art, "GraveyardFloor", Vector3(8.0, 0.05, 17.0), Vector3(13.0, -0.15, 0.3), Color("364754"), true)
	for z in [-5.0, -0.2, 4.6]:
		grave(art, 7.8, z)
	for x in [10.4, 13.0, 15.6]:
		for z in [-5.6, -1.8, 2.0, 5.8]:
			grave(art, x, z)
	box(art, "ForestFloor", Vector3(8.0, 0.04, 17.0), Vector3(-13.0, -0.15, 0.3), Color("244039"), true)
	for z in [-6.6, -1.8, 3.0, 7.8]:
		pine(art, Vector3(-7.9, -0.11, z), 0.82)
	for x in [-15.5, -12.8, -10.1]:
		for z in [-6.3, 0.0, 6.3]:
			box(art, "ForestBrush", Vector3(0.92, 0.23, 1.15), Vector3(x, -0.005, z), Color("2a5548"))
	# Rear terrace and ruined outer curtain occupy the void beyond the Throne.
	box(art, "RearStoneCourt", Vector3(22.0, 0.065, 8.0), Vector3(0, -0.15, -9.4), Color("4d5a6d"), true)
	for x in [-9.0, -6.0, -3.0, 0.0, 3.0, 6.0, 9.0]:
		box(art, "RearCourtSeam", Vector3(0.055, 0.012, 7.7), Vector3(x, -0.108, -9.4), Color("788195"), true)
	for x in [-3.5, 3.5]:
		box(art, "RearMemorialPlinth", Vector3(0.93, 0.22, 0.93), Vector3(x, 0.02, -9.8), Color("777d8e"))
		box(art, "RearMemorial", Vector3(0.47, 1.0, 0.47), Vector3(x, 0.61, -9.8), Color("8990a1"))
		box(art, "RearMemorialTop", Vector3(0.67, 0.13, 0.67), Vector3(x, 1.18, -9.8), Color("5b647b"))
	box(art, "RearCourtCrest", Vector3(1.5, 0.014, 1.5), Vector3(0, -0.107, -9.8), Color("6b5976"), true)
	box(art, "RuinedRearWall", Vector3(24.0, 0.75, 0.39), Vector3(0, 0.27, -13.25), Color("5b667a"))
	for x in [-11.0, -8.2, -5.4, -2.6, 2.6, 5.4, 8.2, 11.0]:
		box(art, "RearMerlon", Vector3(0.74, 0.35, 0.46), Vector3(x, 0.80, -13.25), stone)
	for x in [-8.0, 8.0]:
		box(art, "RearButtress", Vector3(0.70, 1.05, 1.0), Vector3(x, 0.47, -12.87), Color("758094"))
	for x in [-17.0, -11.7, 11.7, 17.0]:
		pine(art, Vector3(x, -0.11, -18.0), 1.2)
	box(art, "RearForestCanopy", Vector3(66.0, 0.06, 20.0), Vector3(0, -0.14, -26.0), Color("203a3a"), true)
	# A moat makes the approach feel like a castle, with the existing van and
	# entrance on a bridge axis. The painted water never affects movement.
	box(art, "MoatBanks", Vector3(60.0, 0.07, 10.2), Vector3(0, -0.155, 14.3), Color("344454"), true)
	box(art, "MoatWater", Vector3(59.0, 0.02, 8.6), Vector3(0, -0.105, 14.3), water, true)
	for z in [9.7, 18.9]:
		box(art, "MoatStoneEdge", Vector3(60.0, 0.13, 0.23), Vector3(0, -0.05, z), stone, true)
	for x in [-25.0, -18.0, -11.0, 11.0, 18.0, 25.0]:
		box(art, "MoatMoonReflection", Vector3(2.3, 0.012, 0.12), Vector3(x, -0.091, 13.4), Color("4b6675"), true)
	# Stone bridge and long road continue past the van to a forest track.
	box(art, "BridgeDeck", Vector3(3.7, 0.10, 13.0), Vector3(0, -0.06, 13.9), paving, true)
	for side in [-1.0, 1.0]:
		box(art, "BridgeParapet", Vector3(0.26, 0.37, 11.8), Vector3(side * 1.94, 0.17, 13.9), Color("69758b"))
		for z in [9.1, 12.0, 14.9, 17.8]:
			box(art, "BridgePost", Vector3(0.48, 0.63, 0.48), Vector3(side * 1.94, 0.30, z), stone)
	for z in [7.8, 9.9, 12.0, 14.1, 16.2, 18.3]:
		box(art, "BridgeCourse", Vector3(3.42, 0.012, 0.075), Vector3(0, -0.002, z), Color("9aa0a3"), true)
	box(art, "ForestRoad", Vector3(3.7, 0.055, 19.0), Vector3(0, -0.12, 29.7), Color("4c5260"), true)
	for z in [21.1, 24.1, 27.1, 30.1, 33.1, 36.1]:
		box(art, "ForestRoadSeam", Vector3(3.55, 0.012, 0.085), Vector3(0, -0.087, z), Color("777e89"), true)
	for side in [-1.0, 1.0]:
		for z in [22.0, 27.2, 32.4, 37.6]:
			pine(art, Vector3(side * 6.7, -0.11, z), 1.03)
	box(art, "FarForest", Vector3(66.0, 0.05, 10.0), Vector3(0, -0.14, 40.0), Color("203a3a"), true)


static func box(parent: Node3D, part_name: String, size: Vector3, at: Vector3, color: Color, ground: bool = false) -> MeshInstance3D:
	var piece := Models.box(parent, size, at, color)
	piece.name = part_name
	piece.set_meta("exterior", true)
	Models.set_toon_profile(piece, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	return piece


static func pine(parent: Node3D, at: Vector3, scale_factor: float) -> void:
	box(parent, "NightPineTrunk", Vector3(0.24, 0.77, 0.24) * scale_factor, at + Vector3(0, 0.39 * scale_factor, 0), Color("584735"))
	for tier in range(2):
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.0
		mesh.bottom_radius = (0.68 - float(tier) * 0.16) * scale_factor
		mesh.height = 0.98 * scale_factor
		mesh.radial_segments = 6
		var crown := MeshInstance3D.new()
		crown.mesh = mesh
		crown.material_override = Models.material(Color("204c46") if tier == 0 else Color("2c6255"))
		crown.position = at + Vector3(0, (0.91 + float(tier) * 0.48) * scale_factor, 0)
		crown.set_meta("exterior", true)
		parent.add_child(crown)
		Models.set_toon_profile(crown, ToonMaterial.Profile.PROP)


static func grave(parent: Node3D, x: float, z: float) -> void:
	box(parent, "GraveBase", Vector3(0.80, 0.10, 1.0), Vector3(x, -0.025, z), Color("4a5363"), true)
	box(parent, "Headstone", Vector3(0.46, 0.67, 0.19), Vector3(x, 0.34, z - 0.34), Color("8990a1"))
	box(parent, "HeadstoneCarving", Vector3(0.27, 0.06, 0.02), Vector3(x, 0.40, z - 0.23), Color("4e586b"))


static func watch_post(parent: Node3D, x: float, z: float) -> void:
	box(parent, "OuterWatchBase", Vector3(2.0, 0.14, 2.0), Vector3(x, -0.01, z), Color("576276"), true)
	box(parent, "OuterWatchBody", Vector3(1.55, 2.0, 1.55), Vector3(x, 1.06, z), Color("59647a"))
	box(parent, "OuterWatchBand", Vector3(1.83, 0.16, 1.83), Vector3(x, 2.13, z), Color("81899d"))
	var roof := CylinderMesh.new()
	roof.top_radius = 0.0
	roof.bottom_radius = 1.14
	roof.height = 0.95
	roof.radial_segments = 4
	var cap := MeshInstance3D.new()
	cap.mesh = roof
	cap.material_override = Models.material(Color("352b4e"))
	cap.position = Vector3(x, 2.68, z)
	cap.rotation.y = PI / 4.0
	cap.set_meta("exterior", true)
	parent.add_child(cap)
	Models.set_toon_profile(cap, ToonMaterial.Profile.PROP)
	box(parent, "OuterWatchWindow", Vector3(0.45, 0.55, 0.04), Vector3(x, 1.37, z + 0.80), Color("c59b71"))
