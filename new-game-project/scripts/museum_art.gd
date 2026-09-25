extends RefCounted

# Non-colliding public-museum architecture and exhibit staging. HeistLevel owns
# all walls and loot; these pieces cannot block a route or become fake pickups.
static func build(level: Node3D) -> void:
	var art := Node3D.new()
	art.name = "MuseumArt"
	level.add_child(art)
	var marble := Color("e9e8e1")
	var stone := Color("bec6cb")
	var ink := Color("34475c")
	var brass := Color("d9b46a")
	var sand := Color("c9ad78")
	var cyan := Color("67c9ce")
	var amber := Color("ffe3a9")
	build_surroundings(art)
	# Civic plaza instead of a private driveway: broad paving, two sculpture
	# blocks and lamps. The van parks brazenly at the steps, rear doors toward them.
	box(art, "PublicPlaza", Vector3(17.2, 0.036, 13.0), Vector3(0, -0.051, 10.25), Color("959fa5"), true)
	box(art, "VanApproach", Vector3(4.35, 0.039, 13.0), Vector3(0, -0.029, 10.25), Color("7b8992"), true)
	for z in [4.35, 5.65, 8.35, 10.95, 13.55, 16.0]:
		box(art, "PlazaJoint", Vector3(16.6, 0.007, 0.045), Vector3(0, -0.028, z), Color("c8cdd0"), true)
	for x in [-6.2, 6.2]:
		box(art, "PlazaSculptureBase", Vector3(1.2, 0.24, 1.2), Vector3(x, 0.12, 8.7), marble)
		box(art, "PlazaAbstractSculpture", Vector3(0.48, 0.76, 0.48), Vector3(x, 0.62, 8.7), stone)
		box(art, "PlazaSculptureCrown", Vector3(0.8, 0.14, 0.8), Vector3(x, 1.07, 8.7), brass)
		for z in [5.25, 12.7]:
			box(art, "CivicLampPost", Vector3(0.13, 1.14, 0.13), Vector3(x, 0.57, z), ink)
			box(art, "CivicLampHead", Vector3(0.38, 0.30, 0.38), Vector3(x, 1.30, z), amber)
			box(art, "CivicLampCap", Vector3(0.50, 0.075, 0.50), Vector3(x, 1.48, z), ink)
			lamp(art, Vector3(x, 1.55, z), amber, 0.55, 3.5)
	# Wide museum stairs and six pillars. A shallow pediment hints at the roof
	# without covering any play space in the cutaway camera.
	for step in range(3):
		box(art, "MuseumStep", Vector3(9.4 - step * 0.45, 0.045, 0.36), Vector3(0, -0.01 + step * 0.023, 4.28 - step * 0.32), marble, true)
	for x in [-6.8, -4.15, -2.1, 2.1, 4.15, 6.8]:
		box(art, "FacadeColumn", Vector3(0.40, 1.42, 0.40), Vector3(x, 0.71, 3.85), marble)
		box(art, "ColumnFoot", Vector3(0.60, 0.14, 0.60), Vector3(x, 0.08, 3.85), stone)
		box(art, "ColumnCapital", Vector3(0.65, 0.12, 0.65), Vector3(x, 1.47, 3.85), brass)
	box(art, "FacadeEntablature", Vector3(15.5, 0.22, 0.78), Vector3(0, 1.62, 3.88), ink)
	box(art, "FacadeCornice", Vector3(16.0, 0.095, 0.93), Vector3(0, 1.80, 3.88), marble)
	for x in [-5.55, 5.55]:
		box(art, "MuseumBanner", Vector3(0.54, 0.82, 0.05), Vector3(x, 0.85, 3.52), Color("377f8d"))
		box(art, "BannerGoldStripe", Vector3(0.12, 0.55, 0.06), Vector3(x, 0.85, 3.50), brass)
		lamp(art, Vector3(x, 1.65, 4.15), amber, 0.70, 3.5)
	for x in [-8.2, 8.2]:
		box(art, "SideCornice", Vector3(0.35, 0.12, 15.7), Vector3(x, 0.93, -4.22), ink)
	box(art, "RearCornice", Vector3(16.55, 0.12, 0.4), Vector3(0, 0.93, -12.12), ink)
	# Entrance: ticket desks stay on the edges. Repeated floor seams read as
	# marble, not the warm residential flooring of Mansion.
	for x in [-6.55, 6.55]:
		box(art, "TicketCounter", Vector3(1.45, 0.39, 0.62), Vector3(x, 0.24, 2.42), Color("747f88"))
		box(art, "TicketCounterTop", Vector3(1.52, 0.07, 0.69), Vector3(x, 0.48, 2.42), marble)
	for z in [1.85, 0.25, -1.35, -2.95, -4.55, -6.15, -7.75]:
		box(art, "GalleryMarbleJoint", Vector3(5.55, 0.006, 0.028), Vector3(0, 0.078, z), Color("c9c8c2"), true)
	for x in [-2.65, 2.65]:
		box(art, "GalleryMarbleRail", Vector3(0.027, 0.006, 9.9), Vector3(x, 0.079, -3.22), Color("c9c8c2"), true)
	for x in [-3.25, 3.25]:
		for z in [-6.55, -3.5, -0.45]:
			box(art, "GrandGalleryColumn", Vector3(0.30, 0.82, 0.30), Vector3(x, 0.41, z), marble)
			box(art, "GalleryColumnCap", Vector3(0.45, 0.08, 0.45), Vector3(x, 0.86, z), brass)
	# A low centre display and a quiet ochre floor medallion frame the diamond.
	var medallion = Models.cylinder(art, 1.35, 0.014, Vector3(0, 0.091, -4.1), Color("d4c7a9"))
	medallion.name = "GrandGalleryMedallion"
	Models.set_toon_profile(medallion, ToonMaterial.Profile.GROUND)
	var inset = Models.cylinder(art, 1.14, 0.016, Vector3(0, 0.102, -4.1), marble)
	Models.set_toon_profile(inset, ToonMaterial.Profile.GROUND)
	lamp(art, Vector3(0, 2.25, -4.1), amber, 0.80, 5.3)
	# Ancient wing: sandstone border, turquoise inlay and wall reliefs foreshadow
	# Pyramid without reusing its actual chamber or blocking the gallery mouth.
	box(art, "AncientBorder", Vector3(4.4, 0.02, 8.7), Vector3(-5.52, 0.083, -5.3), sand, true)
	box(art, "AncientInset", Vector3(4.05, 0.006, 8.35), Vector3(-5.52, 0.101, -5.3), Color("d6c9a8"), true)
	for z in [-9.7, -7.1, -4.5, -1.9]:
		box(art, "AncientTurquoiseStripe", Vector3(3.95, 0.007, 0.075), Vector3(-5.52, 0.108, z), Color("62a7a5"), true)
		box(art, "AncientRelief", Vector3(0.07, 0.44, 0.90), Vector3(-8.03, 0.51, z), Color("b39869"))
	lamp(art, Vector3(-5.5, 1.95, -5.4), amber, 0.72, 5.4)
	# Sculpture wing: cool stone with generous independent display footprints.
	for z in [-8.3, -4.7, -1.6]:
		box(art, "SculptureDisplayBorder", Vector3(3.25, 0.018, 2.6), Vector3(5.55, 0.082, z), Color("8da7b4"), true)
		box(art, "SculptureDisplayInset", Vector3(3.0, 0.006, 2.32), Vector3(5.55, 0.097, z), Color("cdd7da"), true)
	lamp(art, Vector3(5.55, 2.0, -5.0), Color("d7e5ef"), 0.77, 5.0)
	# Storage is the only utilitarian room: crate stacks and an equipment strip.
	box(art, "StorageFloorStripe", Vector3(4.3, 0.018, 0.12), Vector3(-5.55, 0.085, 0.05), Color("e7c36f"), true)
	for x in [-7.35, -6.66]:
		for z in [0.65, 1.40, 2.15]:
			box(art, "StorageCrate", Vector3(0.56, 0.40, 0.55), Vector3(x, 0.23, z), Color("a48965"))
			box(art, "StorageCrateLid", Vector3(0.59, 0.05, 0.58), Vector3(x, 0.46, z), Color("c1a77d"))
	lamp(art, Vector3(-5.3, 1.8, 1.7), Color("d5e9f2"), 0.56, 3.8)
	# Special exhibit: retro-tech colour appears only here. A ring and three
	# low display plaques stage the Time Machine without fake moving barriers.
	var outer = Models.cylinder(art, 2.15, 0.018, Vector3(0, 0.102, -10.22), ink)
	outer.name = "SpecialExhibitRing"
	Models.set_toon_profile(outer, ToonMaterial.Profile.GROUND)
	var inner = Models.cylinder(art, 1.9, 0.021, Vector3(0, 0.114, -10.22), cyan)
	Models.set_toon_profile(inner, ToonMaterial.Profile.GROUND)
	var pad = Models.cylinder(art, 1.65, 0.024, Vector3(0, 0.13, -10.22), Color("a6bdc4"))
	Models.set_toon_profile(pad, ToonMaterial.Profile.GROUND)
	for x in [-2.55, 2.55]:
		box(art, "SpecialExhibitPlaque", Vector3(0.50, 0.34, 0.25), Vector3(x, 0.22, -10.45), ink)
		box(art, "PlaqueCyan", Vector3(0.40, 0.08, 0.03), Vector3(x, 0.33, -10.30), cyan)
	lamp(art, Vector3(0, 2.2, -10.2), Color("a3e9e9"), 0.85, 4.8)


static func build_surroundings(art: Node3D) -> void:
	# Civic grounds beyond every camera-follow position. These are mesh-only;
	# the museum footprint, loot and original route barriers stay untouched.
	var grounds := Node3D.new()
	grounds.name = "MuseumSurroundings"
	art.add_child(grounds)
	var paving := Color("a8b3b6")
	var pale_stone := Color("d0d0c3")
	var dark_stone := Color("536a74")
	var garden := Color("29493f")
	var bronze := Color("b69a65")
	box(grounds, "CivicDistrictGround", Vector3(74, 0.22, 92), Vector3(0, -0.34, 5), Color("364953"), true)
	# Museum side promenades continue the entrance paving. Classical annexes
	# are set outside the existing gallery walls and remain non-colliding.
	for side in [-1.0, 1.0]:
		box(grounds, "SidePromenade", Vector3(2.9, 0.06, 32), Vector3(side * 10.2, -0.14, 1.0), paving, true)
		for z in [-13.0, -9.0, -5.0, -1.0, 3.0, 7.0, 11.0, 15.0]:
			box(grounds, "PromenadeJoint", Vector3(2.85, 0.01, 0.06), Vector3(side * 10.2, -0.106, z), pale_stone, true)
		for z in [-9.3, -2.7, 4.0, 10.7]:
			box(grounds, "PromenadePlanterRim", Vector3(1.34, 0.17, 1.62), Vector3(side * 11.85, -0.04, z), pale_stone, true)
			box(grounds, "PromenadePlanterSoil", Vector3(1.07, 0.035, 1.35), Vector3(side * 11.85, 0.05, z), garden, true)
			civic_tree(grounds, Vector3(side * 11.85, 0.08, z), 0.57)
		box(grounds, "AnnexCourtyard", Vector3(10.2, 0.055, 20.0), Vector3(side * 16.7, -0.17, -1.7), Color("7b9293"), true)
		museum_annex(grounds, side * 17.3, -4.6, side)
		for z in [6.0, 11.5, 17.0]:
			box(grounds, "PlantedSquareRim", Vector3(3.4, 0.11, 2.65), Vector3(side * 15.8, -0.10, z), pale_stone, true)
			box(grounds, "PlantedSquare", Vector3(3.04, 0.025, 2.28), Vector3(side * 15.8, -0.03, z), garden, true)
			civic_tree(grounds, Vector3(side * 15.8, -0.02, z), 0.85)
		for z in [3.4, 9.0, 14.6, 21.6]:
			civic_lamppost(grounds, Vector3(side * 10.8, -0.08, z))
		# An outer arcade closes the lateral horizon without mirroring a private
		# mansion garden or putting a facade directly against the museum wall.
		box(grounds, "OuterArcadeWalk", Vector3(3.2, 0.055, 26), Vector3(side * 23.4, -0.17, -1.5), Color("899fa0"), true)
		for z in [-11.0, -6.5, -2.0, 2.5, 7.0, 11.5]:
			box(grounds, "ArcadePier", Vector3(0.50, 1.72, 0.50), Vector3(side * 25.2, 0.75, z), pale_stone)
			box(grounds, "ArcadeCapital", Vector3(0.76, 0.14, 0.76), Vector3(side * 25.2, 1.69, z), bronze)
		box(grounds, "ArcadeCornice", Vector3(0.7, 0.18, 27.0), Vector3(side * 25.2, 1.82, -1.5), dark_stone)
	# Rear service court and archive blocks cover the view beyond the Time
	# Machine gallery while still reading as part of a public institution.
	box(grounds, "RearServiceCourt", Vector3(34, 0.06, 7.8), Vector3(0, -0.17, -16.1), Color("889b9e"), true)
	for x in [-14.0, -9.0, -4.0, 4.0, 9.0, 14.0]:
		box(grounds, "ServiceCourtJoint", Vector3(0.06, 0.01, 7.5), Vector3(x, -0.133, -16.1), pale_stone, true)
	for x in [-13.3, 0.0, 13.3]:
		box(grounds, "ArchiveWing", Vector3(11.8, 2.65, 7.7), Vector3(x, 1.10, -23.5), Color("b4b9b3"))
		box(grounds, "ArchiveRoof", Vector3(12.3, 0.25, 8.1), Vector3(x, 2.51, -23.5), dark_stone)
		box(grounds, "ArchiveRoofRidge", Vector3(9.7, 0.07, 0.16), Vector3(x, 2.67, -23.5), pale_stone)
		for offset in [-3.2, 0.0, 3.2]:
			box(grounds, "ArchiveWindowFrame", Vector3(1.72, 0.75, 0.11), Vector3(x + offset, 1.12, -19.59), dark_stone)
			box(grounds, "ArchiveWindow", Vector3(1.4, 0.53, 0.12), Vector3(x + offset, 1.12, -19.53), Color("b8c9c4"))
	box(grounds, "RearGardenStrip", Vector3(74, 0.045, 12), Vector3(0, -0.18, -33.1), garden, true)
	# The museum plaza opens into a proper boulevard rather than terminating
	# in the dark empty border visible during the escape run.
	box(grounds, "OuterPlaza", Vector3(24.0, 0.055, 10.4), Vector3(0, -0.15, 21.8), paving, true)
	for z in [18.2, 20.8, 23.4, 26.0]:
		box(grounds, "OuterPlazaJoint", Vector3(23.4, 0.01, 0.055), Vector3(0, -0.117, z), pale_stone, true)
	for x in [-12.0, -7.5, 7.5, 12.0]:
		box(grounds, "PlazaFlagstoneJoint", Vector3(0.06, 0.01, 10.0), Vector3(x, -0.116, 21.8), pale_stone, true)
	box(grounds, "PlazaCivicEmblem", Vector3(2.9, 0.014, 2.9), Vector3(0, -0.107, 22.2), Color("bbc4bf"), true)
	box(grounds, "PlazaEmblemCenter", Vector3(1.65, 0.015, 1.65), Vector3(0, -0.096, 22.2), Color("8aa2a2"), true)
	for side in [-1.0, 1.0]:
		box(grounds, "PlazaGardenRim", Vector3(9.8, 0.10, 8.0), Vector3(side * 18.8, -0.11, 21.4), pale_stone, true)
		box(grounds, "PlazaGarden", Vector3(9.3, 0.026, 7.45), Vector3(side * 18.8, -0.044, 21.4), garden, true)
		for x_offset in [-2.7, 2.7]:
			civic_tree(grounds, Vector3(side * 18.8 + x_offset, -0.02, 21.4), 0.68)
		box(grounds, "BannerPillar", Vector3(0.54, 2.25, 0.54), Vector3(side * 6.5, 1.01, 25.4), pale_stone)
		box(grounds, "BannerPillarCap", Vector3(0.79, 0.15, 0.79), Vector3(side * 6.5, 2.20, 25.4), bronze)
		box(grounds, "CivicBanner", Vector3(0.64, 1.05, 0.07), Vector3(side * 6.5, 1.59, 25.02), Color("397887"))
	box(grounds, "MuseumBoulevard", Vector3(74, 0.085, 10.0), Vector3(0, -0.18, 32.1), Color("293f4e"), true)
	for z in [27.0, 37.1]:
		box(grounds, "BoulevardCurb", Vector3(74, 0.13, 0.18), Vector3(0, -0.075, z), pale_stone, true)
	for x in [-31.5, -22.5, -13.5, -4.5, 4.5, 13.5, 22.5, 31.5]:
		box(grounds, "BoulevardDash", Vector3(3.0, 0.012, 0.12), Vector3(x, -0.129, 32.1), Color("cbbd8f"), true)
	for x in [-2.5, -1.5, -0.5, 0.5, 1.5, 2.5]:
		box(grounds, "CivicCrossing", Vector3(0.52, 0.012, 2.4), Vector3(x, -0.128, 28.4), Color("bcc8c8"), true)
	box(grounds, "OppositeWalk", Vector3(74, 0.08, 2.8), Vector3(0, -0.16, 38.6), paving, true)
	for x in [-26.0, -13.0, 0.0, 13.0, 26.0]:
		box(grounds, "CivicBlockBody", Vector3(11.2, 2.4, 6.2), Vector3(x, 0.97, 44.1), Color("657982"))
		box(grounds, "CivicBlockRoof", Vector3(11.7, 0.22, 6.55), Vector3(x, 2.28, 44.1), dark_stone)
		for offset in [-3.2, 0.0, 3.2]:
			box(grounds, "CivicBlockWindow", Vector3(1.65, 0.78, 0.10), Vector3(x + offset, 1.12, 40.93), Color("cfb993"))


static func museum_annex(parent: Node3D, x: float, z: float, side: float) -> void:
	box(parent, "AnnexBody", Vector3(8.5, 2.25, 12.2), Vector3(x, 0.96, z), Color("b7bfba"))
	box(parent, "AnnexRoof", Vector3(8.85, 0.22, 12.55), Vector3(x, 2.18, z), Color("3d5865"))
	box(parent, "AnnexCornice", Vector3(8.9, 0.12, 0.28), Vector3(x, 2.31, z + 6.12), Color("d5d2c5"))
	for offset in [-2.7, 0.0, 2.7]:
		box(parent, "AnnexWindowFrame", Vector3(1.58, 0.77, 0.1), Vector3(x + offset, 1.13, z + 6.13), Color("435d67"))
		box(parent, "AnnexWindowGlow", Vector3(1.33, 0.54, 0.11), Vector3(x + offset, 1.13, z + 6.19), Color("d5c396"))
		box(parent, "AnnexRoofVent", Vector3(0.64, 0.39, 0.8), Vector3(x + offset, 2.49, z - 1.3), Color("85999b"))
	box(parent, "AnnexSideBanner", Vector3(0.08, 0.92, 0.58), Vector3(x - side * 4.28, 1.11, z + 3.4), Color("397887"))


static func civic_tree(parent: Node3D, at: Vector3, scale_factor: float) -> void:
	box(parent, "CivicTreeTrunk", Vector3(0.29, 1.04, 0.29) * scale_factor, at + Vector3(0, 0.52 * scale_factor, 0), Color("685747"))
	box(parent, "CivicTreeCrown", Vector3(1.28, 1.15, 1.28) * scale_factor, at + Vector3(0, 1.36 * scale_factor, 0), Color("2f6254"))
	box(parent, "CivicTreeTop", Vector3(0.86, 0.58, 0.92) * scale_factor, at + Vector3(0, 2.08 * scale_factor, 0), Color("417565"))


static func civic_lamppost(parent: Node3D, at: Vector3) -> void:
	box(parent, "DistrictLampPost", Vector3(0.14, 2.1, 0.14), at + Vector3(0, 1.05, 0), Color("344b55"))
	box(parent, "DistrictLampHead", Vector3(0.43, 0.25, 0.43), at + Vector3(0, 2.22, 0), Color("ffe2a5"))
	box(parent, "DistrictLampCap", Vector3(0.54, 0.075, 0.54), at + Vector3(0, 2.39, 0), Color("344b55"))


static func box(parent: Node3D, part_name: String, size: Vector3, at: Vector3, color: Color, ground: bool = false) -> MeshInstance3D:
	var piece := Models.box(parent, size, at, color)
	piece.name = part_name
	Models.set_toon_profile(piece, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	return piece


static func lamp(parent: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	parent.add_child(light)
