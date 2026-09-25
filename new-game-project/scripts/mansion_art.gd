extends RefCounted

# The exterior remains visual dressing. MansionInterior supplies solid furniture
# around the open ceremonial hall and the level owns the structural walls.
static func build(level: Node3D) -> void:
	var art := Node3D.new()
	art.name = "MansionArt"
	level.add_child(art)
	var limestone := Color("e8ddc8")
	var gold := Color("d8ae64")
	var navy := Color("25364a")
	var wine := Color("792c40")
	var warm := Color("ffe0a5")
	build_surroundings(art)
	# The estate is deliberately wider and deeper than Villa: a stone motor court,
	# long arrival lane, symmetrical gardens and a portico framing the cutaway.
	box(art, "MotorCourt", Vector3(14.2, 0.035, 5.1), Vector3(0, -0.055, 5.75), Color("a4a7a0"), true)
	box(art, "Driveway", Vector3(4.6, 0.038, 11.9), Vector3(0, -0.038, 9.35), Color("777f84"), true)
	for x in [-2.36, 2.36]:
		box(art, "DrivewayPaleEdge", Vector3(0.13, 0.042, 11.9), Vector3(x, -0.016, 9.35), limestone, true)
	for z in [3.95, 5.1, 7.2]:
		box(art, "CourtJoint", Vector3(13.65, 0.007, 0.038), Vector3(0, -0.031, z), limestone, true)
	for x in [-6.35, 6.35]:
		box(art, "GardenParterre", Vector3(1.6, 0.06, 9.8), Vector3(x, -0.025, 9.6), Color("315548"), true)
		for z in [4.5, 5.5, 6.5, 9.0, 10.0, 11.0, 13.6]: hedge(art, Vector3(x, 0, z))
		box(art, "GatePier", Vector3(0.67, 1.05, 0.67), Vector3(x, 0.525, 14.45), limestone)
		box(art, "GateCap", Vector3(0.85, 0.13, 0.85), Vector3(x, 1.11, 14.45), gold)
		box(art, "GateLantern", Vector3(0.27, 0.37, 0.27), Vector3(x, 1.39, 14.45), warm)
		lamp(art, Vector3(x, 1.6, 14.45), warm, 0.65, 3.0)
	for x in [-4.65, 4.65]:
		for z in [5.0, 9.5]:
			box(art, "EstateLampPost", Vector3(0.11, 0.9, 0.11), Vector3(x, 0.45, z), navy)
			box(art, "EstateLamp", Vector3(0.28, 0.35, 0.28), Vector3(x, 1.05, z), warm)
			box(art, "EstateLampCap", Vector3(0.39, 0.07, 0.39), Vector3(x, 1.25, z), navy)
			lamp(art, Vector3(x, 1.3, z), warm, 0.40, 2.8)
	# Identical little fountains frame the arrival but never occupy the van lane.
	for x in [-4.65, 4.65]:
		var basin = Models.cylinder(art, 0.77, 0.13, Vector3(x, 0.04, 6.7), limestone)
		basin.name = "FountainBasin"
		Models.set_toon_profile(basin, ToonMaterial.Profile.PROP)
		var water = Models.cylinder(art, 0.60, 0.017, Vector3(x, 0.119, 6.7), Color("72aeb2"))
		Models.set_toon_profile(water, ToonMaterial.Profile.GROUND)
		box(art, "FountainSpout", Vector3(0.16, 0.4, 0.16), Vector3(x, 0.31, 6.7), gold)
	# Grand entrance: a broad three-bay portico, steps and warm-lit windows.
	box(art, "EntrySteps", Vector3(5.4, 0.08, 0.75), Vector3(0, 0.03, 3.76), limestone, true)
	for x in [-2.35, 2.35]:
		box(art, "PorticoColumn", Vector3(0.38, 1.4, 0.38), Vector3(x, 0.7, 3.53), limestone)
		box(art, "PorticoBase", Vector3(0.58, 0.13, 0.58), Vector3(x, 0.08, 3.53), Color("b0a795"))
		box(art, "PorticoCapital", Vector3(0.62, 0.14, 0.62), Vector3(x, 1.44, 3.53), gold)
		box(art, "EntrySconce", Vector3(0.19, 0.34, 0.15), Vector3(x * 1.35, 0.85, 3.38), warm)
		lamp(art, Vector3(x * 1.35, 1.1, 3.65), warm, 0.70, 3.4)
	for x in [-5.0, 5.0]:
		box(art, "FrontWindow", Vector3(1.55, 0.49, 0.04), Vector3(x, 0.60, 3.47), Color("d8ba83"))
		box(art, "WindowFrame", Vector3(1.68, 0.065, 0.06), Vector3(x, 0.88, 3.47), limestone)
		box(art, "WindowCross", Vector3(0.06, 0.49, 0.07), Vector3(x, 0.60, 3.46), navy)
	for x in [-7.3, 7.3]:
		box(art, "SideCornice", Vector3(0.36, 0.13, 14.0), Vector3(x, 0.87, -3.6), navy)
	box(art, "RearCornice", Vector3(14.8, 0.13, 0.4), Vector3(0, 1.22, -10.62), navy)
	# Burgundy runner and medallion make the Great Hall the visual anchor. The
	# broad empty floor on either side lets the thief carry piano/statue freely.
	box(art, "GreatHallRug", Vector3(3.25, 0.02, 10.5), Vector3(0, 0.087, -3.35), wine, true)
	box(art, "GreatHallInset", Vector3(2.8, 0.006, 10.02), Vector3(0, 0.102, -3.35), Color("953d50"), true)
	for x in [-1.43, 1.43]:
		box(art, "HallGoldTrim", Vector3(0.06, 0.008, 9.9), Vector3(x, 0.109, -3.35), gold, true)
	for z in [-7.95, 0.95]:
		box(art, "HallCrossTrim", Vector3(2.9, 0.008, 0.06), Vector3(0, 0.111, z), gold, true)
	var medallion = Models.cylinder(art, 0.72, 0.012, Vector3(0, 0.117, -3.4), gold)
	medallion.name = "HallMedallion"
	Models.set_toon_profile(medallion, ToonMaterial.Profile.GROUND)
	var center = Models.cylinder(art, 0.53, 0.014, Vector3(0, 0.128, -3.4), navy)
	Models.set_toon_profile(center, ToonMaterial.Profile.GROUND)
	for x in [-2.30, 2.30]:
		for z in [-8.9, -5.5, -1.5, 2.05]:
			box(art, "HallColumn", Vector3(0.26, 0.83, 0.26), Vector3(x, 0.42, z), limestone)
			box(art, "HallColumnBase", Vector3(0.40, 0.09, 0.40), Vector3(x, 0.075, z), gold)
			box(art, "HallColumnCap", Vector3(0.43, 0.08, 0.43), Vector3(x, 0.88, z), gold)
	lamp(art, Vector3(0, 2.2, -3.3), warm, 0.65, 5.5)
	preload("res://scripts/mansion_interior.gd").build(level)


static func build_surroundings(art: Node3D) -> void:
	# Grand outer estate. Purely visual meshes extend beyond every follow view;
	# original entrance, loot, walls and van routes keep their collision footprint.
	var estate := Node3D.new()
	estate.name = "MansionSurroundings"
	art.add_child(estate)
	var night_lawn := Color("29443d")
	var limestone := Color("b9b9aa")
	var hedge_dark := Color("2b5145")
	var slate := Color("344956")
	box(estate, "EstateGround", Vector3(64.0, 0.22, 82.0), Vector3(0, -0.31, 3.0), night_lawn, true)
	# Complete the axial motor approach and the public road beyond the gate.
	box(estate, "GateDriveExtension", Vector3(4.8, 0.05, 11.0), Vector3(0, -0.12, 20.4), Color("77868b"), true)
	for x in [-2.48, 2.48]:
		box(estate, "DriveEdging", Vector3(0.16, 0.065, 11.0), Vector3(x, -0.085, 20.4), limestone, true)
	for z in [16.8, 19.2, 21.6, 24.0]:
		box(estate, "DriveJoint", Vector3(4.6, 0.009, 0.04), Vector3(0, -0.086, z), Color("556d72"), true)
	box(estate, "MansionStreet", Vector3(64.0, 0.09, 11.0), Vector3(0, -0.14, 31.3), Color("293d4c"), true)
	for z in [25.7, 36.9]:
		box(estate, "StreetCurb", Vector3(64.0, 0.11, 0.19), Vector3(0, -0.06, z), Color("c4c6b8"), true)
		box(estate, "StreetWalk", Vector3(64.0, 0.045, 1.18), Vector3(0, -0.11, z + (-0.69 if z < 30 else 0.69)), limestone, true)
	for x in [-28.0, -21.0, -14.0, -7.0, 7.0, 14.0, 21.0, 28.0]:
		box(estate, "StreetDash", Vector3(2.6, 0.012, 0.11), Vector3(x, -0.084, 31.3), Color("cfc399"), true)
	# Side service courts and roofed annexes give Mansion a broader silhouette
	# than Villa's garden promenades. Everything begins outside the main shell.
	for side in [-1.0, 1.0]:
		box(estate, "SideServiceWalk", Vector3(1.45, 0.045, 23.0), Vector3(side * 8.75, -0.11, -1.35), Color("939d97"), true)
		for z in [-10.0, -6.0, -2.0, 2.0, 6.0, 10.0]:
			box(estate, "ServiceJoint", Vector3(1.40, 0.009, 0.04), Vector3(side * 8.75, -0.080, z), Color("667a7c"), true)
		box(estate, "AnnexCourt", Vector3(6.4, 0.045, 17.2), Vector3(side * 13.25, -0.14, -2.0), Color("566d66"), true)
		for z in [-8.8, -5.0, -1.2, 2.6, 6.4]:
			box(estate, "CourtPaver", Vector3(5.4, 0.009, 0.055), Vector3(side * 13.25, -0.11, z), Color("85978d"), true)
		annex(estate, side * 13.6, -4.7)
		for z in [-10.9, -7.3, -3.7, -0.1, 3.5, 7.1, 10.7]:
			box(estate, "ClippedHedge", Vector3(0.70, 0.52, 1.25), Vector3(side * 9.9, 0.12, z), hedge_dark)
		for z in [-15.0, -9.0, 4.0, 11.0]:
			mansion_tree(estate, Vector3(side * 19.5, -0.10, z), 0.95)
		box(estate, "SideBoundaryWall", Vector3(0.22, 0.65, 36.0), Vector3(side * 20.2, 0.19, -0.2), Color("798c84"))
		for z in [-17.5, -11.5, -5.5, 0.5, 6.5, 12.5, 17.5]:
			box(estate, "WallPier", Vector3(0.44, 0.92, 0.44), Vector3(side * 20.2, 0.32, z), limestone)
		# Continue the original front hedges beyond the gate toward the road.
		for z in [16.5, 19.0, 21.5, 24.0]:
			box(estate, "GateAvenueHedge", Vector3(1.0, 0.43, 0.75), Vector3(side * 6.35, 0.11, z), hedge_dark)
	# A grand rear terrace and long reflecting canal occupy the formerly empty
	# upper portrait area. Stone urns repeat the hall's gilded rhythm outside.
	box(estate, "RearTerrace", Vector3(17.8, 0.065, 2.2), Vector3(0, -0.09, -12.15), Color("b8b7a9"), true)
	for x in [-8.3, -4.1, 0.0, 4.1, 8.3]:
		box(estate, "TerraceBaluster", Vector3(0.23, 0.58, 0.23), Vector3(x, 0.26, -13.2), limestone)
	box(estate, "RearGarden", Vector3(20.0, 0.055, 14.0), Vector3(0, -0.14, -19.0), Color("365747"), true)
	box(estate, "CanalRim", Vector3(4.1, 0.08, 9.5), Vector3(0, -0.087, -19.0), limestone, true)
	box(estate, "CanalWater", Vector3(3.7, 0.012, 9.1), Vector3(0, -0.04, -19.0), Color("587f8a"), true)
	for x in [-6.0, 6.0]:
		box(estate, "GardenHedgeRow", Vector3(0.65, 0.45, 12.8), Vector3(x, 0.09, -19.0), hedge_dark)
		for z in [-14.0, -18.0, -22.0]:
			box(estate, "GardenUrnPlinth", Vector3(0.76, 0.45, 0.76), Vector3(x * 1.32, 0.16, z), Color("aeb1a4"))
			box(estate, "GardenUrn", Vector3(0.43, 0.48, 0.43), Vector3(x * 1.32, 0.62, z), Color("d4c7a6"))
	box(estate, "RearEstateWall", Vector3(47.0, 0.67, 0.24), Vector3(0, 0.20, -27.1), Color("76877c"))
	for x in [-22.0, -16.5, -11.0, -5.5, 0.0, 5.5, 11.0, 16.5, 22.0]:
		box(estate, "RearWallPier", Vector3(0.46, 0.93, 0.46), Vector3(x, 0.32, -27.1), limestone)
	for x in [-18.0, -13.0, 13.0, 18.0]:
		mansion_tree(estate, Vector3(x, -0.10, -24.0), 0.84)
	box(estate, "OppositeVerge", Vector3(64.0, 0.04, 6.0), Vector3(0, -0.14, 41.0), Color("304d41"), true)


static func annex(parent: Node3D, x: float, z: float) -> void:
	box(parent, "AnnexFoundation", Vector3(6.0, 0.14, 9.8), Vector3(x, -0.10, z), Color("91948b"), true)
	box(parent, "AnnexFacade", Vector3(5.7, 1.00, 9.45), Vector3(x, 0.49, z), Color("746f71"))
	box(parent, "AnnexRoof", Vector3(6.35, 0.24, 10.05), Vector3(x, 1.12, z), Color("2f4353"))
	box(parent, "AnnexRoofInset", Vector3(5.85, 0.04, 9.55), Vector3(x, 1.26, z), Color("3c5260"))
	for window_x in [-1.75, 0.0, 1.75]:
		box(parent, "AnnexWindowFrame", Vector3(0.92, 0.49, 0.08), Vector3(x + window_x, 0.56, z + 4.78), Color("314252"))
		box(parent, "AnnexWindowGlow", Vector3(0.67, 0.29, 0.025), Vector3(x + window_x, 0.57, z + 4.83), Color("d4ad75"))


static func mansion_tree(parent: Node3D, at: Vector3, scale_factor: float) -> void:
	box(parent, "EstateTreeTrunk", Vector3(0.31, 1.12, 0.31) * scale_factor, at + Vector3(0, 0.56 * scale_factor, 0), Color("6a5849"))
	box(parent, "EstateTreeCrown", Vector3(1.52, 1.32, 1.52) * scale_factor, at + Vector3(0, 1.64 * scale_factor, 0), Color("2d5648"))
	box(parent, "EstateTreeCrownTop", Vector3(0.98, 0.68, 1.02) * scale_factor, at + Vector3(0, 2.45 * scale_factor, 0), Color("3a6751"))


static func box(parent: Node3D, name: String, size: Vector3, at: Vector3, color: Color, ground: bool = false) -> MeshInstance3D:
	var part := Models.box(parent, size, at, color)
	part.name = name
	Models.set_toon_profile(part, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	return part


static func hedge(parent: Node3D, at: Vector3) -> void:
	box(parent, "FormalHedge", Vector3(1.02, 0.45, 0.77), at + Vector3(0, 0.23, 0), Color("2e5949"))
	box(parent, "HedgeTop", Vector3(0.88, 0.23, 0.67), at + Vector3(0, 0.54, 0), Color("46735a"))


static func lamp(parent: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	parent.add_child(light)
