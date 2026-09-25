extends RefCounted

# Visual campus and shell details. LaboratoryInterior adds solid workstations;
# structural dividers and play boundaries belong to HeistLevel.
static func build(level: Node3D) -> void:
	var art := Node3D.new()
	art.name = "LaboratoryArt"
	level.add_child(art)
	var concrete := Color("536d77")
	var wall := Color("849ea6")
	var dark := Color("263c4c")
	var cyan := Color("73d6cd")
	var amber := Color("e4c785")
	# Broad campus outside every follow position; this is not a square floating
	# in a void. The van's rear still faces the central airlock.
	box(art, "CampusGround", Vector3(62, 0.10, 82), Vector3(0, -0.26, 2), Color("253b48"), true)
	box(art, "FrontForecourt", Vector3(19.6, 0.06, 14.3), Vector3(0, -0.16, 10.4), concrete, true)
	box(art, "ServiceDrive", Vector3(4.5, 0.07, 29), Vector3(0, -0.12, 24), Color("435661"), true)
	for z in [5.1, 7.7, 10.3, 12.9, 15.5, 18.1, 20.7, 23.3, 25.9, 28.5, 31.1, 33.7]:
		box(art, "DriveJoint", Vector3(4.2, 0.011, 0.055), Vector3(0, -0.077, z), Color("849198"), true)
	box(art, "OuterRoad", Vector3(62, 0.07, 9), Vector3(0, -0.17, 37), Color("243444"), true)
	for x in [-18.0, -6.0, 6.0, 18.0]: box(art, "RoadDash", Vector3(2.3, 0.01, 0.09), Vector3(x, -0.127, 37), Color("bdad81"), true)
	for side in [-1.0, 1.0]:
		box(art, "CampusSideWalk", Vector3(4.0, 0.05, 31), Vector3(side * 10.8, -0.16, 0.8), Color("637985"), true)
		box(art, "PerimeterFence", Vector3(0.13, 0.72, 31), Vector3(side * 13.2, 0.22, 0.8), dark)
		for z in [-12, -5, 2, 9, 16]:
			box(art, "FencePost", Vector3(0.27, 1.04, 0.27), Vector3(side * 13.2, 0.37, z), wall)
		for z in [-9, -1, 7, 15]:
			box(art, "CampusPlanter", Vector3(1.55, 0.28, 1.7), Vector3(side * 11.1, -0.01, z), dark)
			box(art, "CampusShrub", Vector3(1.12, 0.51, 1.20), Vector3(side * 11.1, 0.32, z), Color("3d6964"))
		# A separate low service annex frames the laboratory like a working site.
		box(art, "ServiceAnnex", Vector3(5.6, 1.35, 11.0), Vector3(side * 18.2, 0.51, -5.5), Color("526b78"))
		box(art, "AnnexRoof", Vector3(5.8, 0.13, 11.2), Vector3(side * 18.2, 1.26, -5.5), dark)
		for z in [-8.4, -5.5, -2.6]:
			box(art, "AnnexWindow", Vector3(0.11, 0.41, 1.46), Vector3(side * 15.35, 0.72, z), cyan)
			box(art, "AnnexWindowSill", Vector3(0.18, 0.06, 1.55), Vector3(side * 15.28, 0.47, z), wall)
		for z in [5.4, 13.2]:
			box(art, "SecurityLampPole", Vector3(0.17, 2.3, 0.17), Vector3(side * 8.8, 1.07, z), dark)
			box(art, "SecurityLampHead", Vector3(0.58, 0.16, 0.38), Vector3(side * 8.8, 2.22, z), amber)
		box(art, "EntryBollard", Vector3(0.33, 0.86, 0.33), Vector3(side * 2.8, 0.27, 5.0), amber)
		box(art, "EntryBollardCap", Vector3(0.36, 0.09, 0.36), Vector3(side * 2.8, 0.75, 5.0), dark)
	# Rear utility yard has cooling towers and piping instead of a flat roof edge.
	box(art, "RearUtilityYard", Vector3(21, 0.05, 16), Vector3(0, -0.16, -19.5), Color("566c78"), true)
	for side in [-1.0, 1.0]:
		var tower = Models.cylinder(art, 1.65, 2.6, Vector3(side * 5.9, 1.19, -20.8), Color("657e89"))
		tower.name = "CoolingTower"
		box(art, "TowerFan", Vector3(2.3, 0.10, 2.3), Vector3(side * 5.9, 2.57, -20.8), dark)
		box(art, "RearDuct", Vector3(0.28, 0.22, 7.6), Vector3(side * 5.9, 0.18, -14.7), cyan)
	for x in [-10.0, 10.0]: box(art, "RearSecurityWall", Vector3(0.25, 0.78, 18), Vector3(x, 0.29, -20), dark)
	box(art, "RearCampusStrip", Vector3(62, 0.05, 13), Vector3(0, -0.16, -37), Color("254149"), true)
	# Cutaway shell: clean slab, hazard lines, accessible mirrored work bays.
	for side in [-1.0, 1.0]:
		box(art, "FacadeBand", Vector3(5.95, 0.15, 0.22), Vector3(side * 4.7, 1.03, 3.72), dark)
		box(art, "FacadeLight", Vector3(0.62, 0.20, 0.07), Vector3(side * 5.8, 0.74, 3.61), cyan)
		box(art, "WingWallCap", Vector3(0.21, 0.12, 15.4), Vector3(side * 7.72, 0.82, -4.0), dark)
		for z in [-1.0, -5.2, -8.6]:
			box(art, "WallInstrument", Vector3(0.06, 0.35, 0.72), Vector3(side * 7.58, 0.46, z), dark)
			box(art, "WallInstrumentScreen", Vector3(0.07, 0.19, 0.49), Vector3(side * 7.52, 0.47, z), cyan)
	for z in [2.2, 0.4, -1.4, -3.2, -5.0, -6.8, -8.6]:
		box(art, "CenterHallJoint", Vector3(4.1, 0.012, 0.045), Vector3(0, 0.083, z), Color("8da9ac"), true)
	for x in [-1.78, 1.78]: box(art, "CenterGuideline", Vector3(0.065, 0.013, 12.3), Vector3(x, 0.086, -3.9), cyan, true)
	box(art, "CoreIsolationRing", Vector3(2.7, 0.016, 2.7), Vector3(0, 0.093, -10), Color("394b5e"), true)
	# The recovered duplication apparatus belongs to the isolation bay. It is
	# recognizable in the heist and represented by the same chamber in its menu.
	box(art, "DuplicatorDock", Vector3(2.7, 0.22, 0.55), Vector3(0, 0.15, -11.1), dark)
	box(art, "DuplicatorGlass", Vector3(2.25, 0.13, 0.12), Vector3(0, 0.47, -11.15), cyan)
	for side in [-1.0, 1.0]:
		box(art, "DuplicatorPylon", Vector3(0.20, 0.88, 0.22), Vector3(side * 1.15, 0.55, -11.1), wall)
		box(art, "DuplicatorEmitter", Vector3(0.27, 0.17, 0.27), Vector3(side * 1.15, 1.02, -11.1), cyan)
	var device_sign := Label3D.new()
	device_sign.text = "DUPLICATOR"
	device_sign.font_size = 44
	device_sign.pixel_size = 0.007
	device_sign.modulate = cyan
	device_sign.position = Vector3(0, 1.20, -11.58)
	art.add_child(device_sign)
	for side in [-1.0, 1.0]:
		box(art, "CoreHazardLine", Vector3(0.10, 0.013, 2.35), Vector3(side * 1.43, 0.106, -10), amber, true)
		box(art, "EntryAirlockStripe", Vector3(1.12, 0.014, 0.16), Vector3(side * 0.65, 0.091, 3.28), amber, true)
	var sign := Label3D.new()
	sign.text = "HELIX LAB"
	sign.font_size = 54
	sign.pixel_size = 0.008
	sign.modulate = cyan
	sign.position = Vector3(0, 1.13, 3.75)
	sign.rotation_degrees.x = -25
	art.add_child(sign)
	preload("res://scripts/laboratory_interior.gd").build(level)


static func box(parent: Node3D, name: String, size: Vector3, at: Vector3, color: Color, ground: bool = false) -> MeshInstance3D:
	var piece := Models.box(parent, size, at, color)
	piece.name = name
	piece.set_meta("exterior", true)
	Models.set_toon_profile(piece, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	return piece
