extends RefCounted


# Exterior retail dressing surrounds an interior with solid display furniture.
# The entrance and stock doorway stay clear; Balance supplies the stealable stock.
static func build(level: Node3D) -> void:
	var art := Node3D.new()
	art.name = "ElectronicsStoreArt"
	level.add_child(art)
	var navy := Color("253a4d")
	var steel := Color("798f9c")
	var cyan := Color("56cbd4")
	var cream := Color("e8ede7")
	build_surroundings(art)

	# Storefront and loading bay: commercial asphalt, painted bays, bright sign.
	box(art, "ParkingLot", Vector3(14.2, 0.038, 6.25), Vector3(0, -0.059, 6.75), Color("596b78"), true)
	box(art, "LoadingBay", Vector3(3.65, 0.018, 5.62), Vector3(0, -0.033, 6.30), Color("435d6e"), true)
	for x in [-1.78, 1.78]:
		box(art, "LoadingBayLine", Vector3(0.07, 0.01, 5.30), Vector3(x, -0.02, 6.28), Color("f4c766"), true)
	for x in [-5.2, -3.15, 3.15, 5.2]:
		box(art, "ParkingStripe", Vector3(0.055, 0.01, 3.55), Vector3(x, -0.028, 7.48), cream, true)
	box(art, "Sidewalk", Vector3(14.2, 0.075, 0.68), Vector3(0, -0.038, 3.72), Color("adbcc2"), true)
	for x in [-5.1, -3.4, -1.7, 1.7, 3.4, 5.1]:
		box(art, "SidewalkJoint", Vector3(0.032, 0.008, 0.64), Vector3(x, 0.005, 3.72), steel, true)
	box(art, "AsphaltEdge", Vector3(14.4, 0.047, 1.62), Vector3(0, -0.081, 10.43), Color("263a4b"), true)
	box(art, "Curb", Vector3(14.4, 0.095, 0.14), Vector3(0, -0.028, 9.56), Color("bdc5c3"), true)
	box(art, "Street", Vector3(14.4, 0.039, 4.45), Vector3(0, -0.077, 12.65), Color("2a4050"), true)
	box(art, "StreetNearCurb", Vector3(14.4, 0.08, 0.15), Vector3(0, -0.028, 14.82), Color("aab8bd"), true)
	for x in [-5.3, -1.1, 3.1]:
		box(art, "RoadDash", Vector3(1.3, 0.007, 0.055), Vector3(x, -0.051, 10.50), Color("d6c491"), true)
		box(art, "StreetDash", Vector3(1.25, 0.007, 0.06), Vector3(x, -0.049, 12.75), Color("d6c491"), true)
	for x in [-2.12, 2.12]:
		box(art, "Bollard", Vector3(0.17, 0.76, 0.17), Vector3(x, 0.38, 4.29), Color("d6aa57"))
		box(art, "BollardStripe", Vector3(0.18, 0.10, 0.18), Vector3(x, 0.61, 4.29), navy)
	for x in [-4.10, 4.10]: box(art, "StoreHeader", Vector3(4.9, 0.20, 0.28), Vector3(x, 1.15, 3.29), navy)
	for x in [-4.10, 4.10]: box(art, "HeaderCyanEdge", Vector3(4.93, 0.035, 0.30), Vector3(x, 1.27, 3.29), cyan)
	var sign_board := box(art, "TechPlusSignBoard", Vector3(4.0, 0.79, 0.14), Vector3(3.65, 1.53, 3.50), Color("7de1e8"))
	var sign_material := Models.material(Color("7de1e8"))
	sign_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign_board.material_override = sign_material
	for i in range(5):
		glyph(art, ["T", "E", "C", "H", "+"][i], 2.25 + float(i) * 0.70, 1.53, 3.60)
	for x in [-4.10, 4.10]:
		glass(art, Vector3(4.72, 0.62, 0.055), Vector3(x, 0.75, 3.41))
		box(art, "WindowLowerRail", Vector3(4.79, 0.07, 0.11), Vector3(x, 0.46, 3.43), steel)
		box(art, "WindowUpperRail", Vector3(4.79, 0.06, 0.11), Vector3(x, 1.08, 3.43), cyan)
		for offset in [-1.52, 0.0, 1.52]:
			box(art, "WindowMullion", Vector3(0.055, 0.58, 0.10), Vector3(x + offset, 0.77, 3.43), steel)
	# Display posters are on the wall, not props in the player's path.
	for x in [-5.6, 5.6]:
		box(art, "SalePosterFrame", Vector3(0.63, 0.72, 0.055), Vector3(x, 0.78, 3.49), navy)
		box(art, "SalePoster", Vector3(0.50, 0.56, 0.062), Vector3(x, 0.78, 3.54), Color("4fc6d3"))
		box(art, "SalePosterIcon", Vector3(0.31, 0.18, 0.069), Vector3(x, 0.84, 3.59), cream)
	box(art, "TrashBin", Vector3(0.57, 0.61, 0.53), Vector3(6.04, 0.31, 7.56), navy)
	box(art, "TrashBinLid", Vector3(0.65, 0.08, 0.61), Vector3(6.04, 0.64, 7.56), steel)
	lamp(art, Vector3(0, 2.05, 3.3), Color("d5f4fb"), 0.86, 4.4)

	preload("res://scripts/electronics_interior.gd").build(level)


static func build_surroundings(art: Node3D) -> void:
	# Visual-only retail block. The playable shop, parking spots and van keep
	# their original collision and routes while camera follow sees a whole street.
	var district := Node3D.new()
	district.name = "ElectronicsSurroundings"
	art.add_child(district)
	var asphalt := Color("263d4b")
	var concrete := Color("9aabb0")
	var curb := Color("c6c9be")
	box(district, "RetailBlockGround", Vector3(64, 0.20, 72), Vector3(0, -0.32, 4), asphalt, true)
	# The original parking apron continues around both neighboring shop fronts.
	for side in [-1.0, 1.0]:
		box(district, "SideParkingApron", Vector3(12.1, 0.044, 11.5), Vector3(side * 13.1, -0.12, 6.9), Color("536773"), true)
		for offset in [0.0, 2.8, 5.6]:
			box(district, "SideParkingStripe", Vector3(0.07, 0.012, 3.7), Vector3(side * (9.0 + offset), -0.09, 8.15), Color("c9c8aa"), true)
		box(district, "ShopSidewalk", Vector3(11.5, 0.075, 0.88), Vector3(side * 13.0, -0.09, 2.95), concrete, true)
		neighbor_shop(district, side)
		# A lit service lane fills the rear and side follow views.
		box(district, "ServiceLane", Vector3(3.0, 0.045, 17.5), Vector3(side * 8.3, -0.14, -6.1), Color("3e5660"), true)
		for z in [-11.3, -6.4, -1.5]:
			box(district, "ServiceLaneStripe", Vector3(0.10, 0.013, 1.5), Vector3(side * 8.3, -0.11, z), Color("e2c474"), true)
		for z in [-8.0, -5.2]:
			box(district, "ServiceBin", Vector3(0.74, 0.72, 0.63), Vector3(side * 9.4, 0.24, z), Color("315c62"))
			box(district, "ServiceBinLid", Vector3(0.82, 0.08, 0.70), Vector3(side * 9.4, 0.63, z), Color("263b43"))
		street_light(district, side * 20.4, 15.35)
		street_light(district, side * 20.4, 23.5)
	# The road continues well past the old edge; broad sidewalks and an
	# opposing row of shops give the foreground depth in portrait framing.
	box(district, "RetailRoadExtension", Vector3(64, 0.06, 9.0), Vector3(0, -0.145, 18.5), Color("2c4351"), true)
	for x in [-27.0, -19.0, -11.0, -3.0, 5.0, 13.0, 21.0, 29.0]:
		box(district, "RoadCenterDash", Vector3(2.8, 0.011, 0.11), Vector3(x, -0.10, 18.1), Color("d9bc78"), true)
	for z in [23.0, 25.4]:
		box(district, "FarSidewalk", Vector3(64, 0.07, 2.3), Vector3(0, -0.09, z), concrete, true)
	box(district, "OppositeCurb", Vector3(64, 0.12, 0.17), Vector3(0, -0.05, 22.0), curb, true)
	for x in [-19.2, -9.6, 0.0, 9.6, 19.2]:
		box(district, "CrosswalkBar", Vector3(0.58, 0.012, 2.5), Vector3(x, -0.10, 20.65), Color("b9c5c5"), true)
	for x in [-22.0, -10.0, 2.0, 14.0, 26.0]:
		box(district, "OppositeShopBody", Vector3(9.7, 2.3, 5.5), Vector3(x, 0.94, 30.0), Color("465766"))
		box(district, "OppositeShopRoof", Vector3(10.2, 0.24, 6.0), Vector3(x, 2.2, 30.0), Color("203747"))
		box(district, "OppositeAwning", Vector3(8.6, 0.16, 0.92), Vector3(x, 1.64, 26.9), Color("568195"))
		for window_x in [-2.75, 0.0, 2.75]:
			box(district, "OppositeWindow", Vector3(1.72, 0.92, 0.065), Vector3(x + window_x, 0.93, 27.21), Color("a9c7b9"))
	# Rear loading court and warehouse roofs replace the dark void behind stock.
	box(district, "RearLoadingCourt", Vector3(32, 0.05, 8.0), Vector3(0, -0.14, -9.4), Color("5a6e75"), true)
	for x in [-12.8, -7.8, -2.8, 2.8, 7.8, 12.8]:
		box(district, "LoadingCourtStripe", Vector3(0.10, 0.012, 2.2), Vector3(x, -0.105, -8.9), Color("d5bc7d"), true)
	for x in [-10.5, 10.5]:
		box(district, "DeliveryPallet", Vector3(1.5, 0.13, 1.25), Vector3(x, -0.025, -9.6), Color("967957"))
		for offset in [-0.36, 0.36]:
			box(district, "DeliveryCrate", Vector3(0.60, 0.57, 0.72), Vector3(x + offset, 0.33, -9.6), Color("ae926a"))
			box(district, "DeliveryCrateBand", Vector3(0.62, 0.055, 0.74), Vector3(x + offset, 0.57, -9.6), Color("d1b885"))
	for x in [-13.2, 0.0, 13.2]:
		box(district, "WarehouseBody", Vector3(10.6, 2.55, 7.0), Vector3(x, 1.02, -17.0), Color("50626c"))
		box(district, "WarehouseRoof", Vector3(11.0, 0.23, 7.4), Vector3(x, 2.38, -17.0), Color("263d4b"))
		box(district, "WarehouseLoadingDoor", Vector3(3.7, 1.25, 0.08), Vector3(x, 0.65, -13.45), Color("81979d"))
		for rib_x in [-1.1, 0.0, 1.1]:
			box(district, "LoadingDoorRib", Vector3(0.065, 1.2, 0.10), Vector3(x + rib_x, 0.65, -13.39), Color("aec3c2"))
		box(district, "WarehouseLightBar", Vector3(1.5, 0.09, 0.10), Vector3(x, 1.58, -13.38), Color("f1cf8b"))
		for offset in [-2.8, 2.8]:
			box(district, "WarehouseRoofFan", Vector3(1.3, 0.10, 1.3), Vector3(x + offset, 2.55, -17), Color("81959a"))
			box(district, "WarehouseRoofFanHub", Vector3(0.38, 0.12, 0.38), Vector3(x + offset, 2.63, -17), Color("314957"))
	box(district, "RearBlockAsphalt", Vector3(64, 0.04, 13), Vector3(0, -0.16, -26), Color("344957"), true)


static func neighbor_shop(parent: Node3D, side: float) -> void:
	var x := side * 14.25
	box(parent, "NeighborStoreBody", Vector3(10.8, 2.5, 9.9), Vector3(x, 0.98, -2.8), Color("566a77"))
	box(parent, "NeighborRoof", Vector3(11.2, 0.25, 10.25), Vector3(x, 2.38, -2.8), Color("273d4d"))
	box(parent, "NeighborRoofTrim", Vector3(11.25, 0.11, 0.25), Vector3(x, 2.49, 2.33), Color("70a2ac"))
	box(parent, "NeighborSign", Vector3(5.0, 0.65, 0.13), Vector3(x, 1.86, 2.27), Color("d4a65f" if side < 0 else "83b3a4"))
	for offset in [-3.45, 0.0, 3.45]:
		box(parent, "NeighborWindowFrame", Vector3(2.25, 1.0, 0.1), Vector3(x + offset, 0.82, 2.24), Color("2a4350"))
		box(parent, "NeighborWindowGlow", Vector3(1.99, 0.76, 0.11), Vector3(x + offset, 0.82, 2.31), Color("d9be91" if side < 0 else "a8d5cc"))
	box(parent, "NeighborAwning", Vector3(9.7, 0.15, 0.85), Vector3(x, 1.41, 2.57), Color("345a6e"))
	for offset in [-3.0, 0.0, 3.0]:
		box(parent, "RoofVent", Vector3(0.9, 0.55, 0.9), Vector3(x + offset, 2.76, -3.0), Color("82979b"))
		box(parent, "RoofVentCap", Vector3(1.10, 0.10, 1.10), Vector3(x + offset, 3.07, -3.0), Color("385362"))
	for z in [-6.2, 0.2]:
		box(parent, "RoofDrainage", Vector3(9.3, 0.022, 0.11), Vector3(x, 2.52, z), Color("75919b"))


static func street_light(parent: Node3D, x: float, z: float) -> void:
	box(parent, "StreetlightPole", Vector3(0.17, 2.5, 0.17), Vector3(x, 1.13, z), Color("34444b"))
	box(parent, "StreetlightArm", Vector3(0.90, 0.12, 0.16), Vector3(x - signf(x) * 0.36, 2.32, z), Color("34444b"))
	box(parent, "StreetlightGlow", Vector3(0.47, 0.075, 0.20), Vector3(x - signf(x) * 0.76, 2.23, z), Color("f2cc80"))


static func box(parent: Node3D, part_name: String, size: Vector3, at: Vector3, color: Color, ground: bool = false) -> MeshInstance3D:
	var piece := Models.box(parent, size, at, color)
	piece.name = part_name
	Models.set_toon_profile(piece, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	return piece


static func glass(parent: Node3D, size: Vector3, at: Vector3) -> void:
	var pane := Models.box(parent, size, at, Color(0.52, 0.84, 0.91, 0.36))
	pane.name = "StorefrontGlass"
	var material := Models.material(Color(0.52, 0.84, 0.91, 0.36))
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pane.material_override = material
	pane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func glyph(parent: Node3D, character: String, x: float, y: float, z: float) -> void:
	var bars: Array = []
	match character:
		"T": bars = [[0.0, 0.27, 0.52, 0.08], [0.0, -0.02, 0.08, 0.54]]
		"E": bars = [[-0.22, 0.0, 0.08, 0.62], [0.0, 0.27, 0.50, 0.08], [-0.02, 0.0, 0.44, 0.08], [0.0, -0.27, 0.50, 0.08]]
		"C": bars = [[-0.22, 0.0, 0.08, 0.62], [0.0, 0.27, 0.50, 0.08], [0.0, -0.27, 0.50, 0.08]]
		"H": bars = [[-0.22, 0.0, 0.08, 0.62], [0.22, 0.0, 0.08, 0.62], [0.0, 0.0, 0.50, 0.08]]
		"+": bars = [[0.0, 0.0, 0.50, 0.08], [0.0, 0.0, 0.08, 0.50]]
	for bar in bars:
		var stroke := Models.box(parent, Vector3(bar[2], bar[3], 0.08), Vector3(x + bar[0], y + bar[1], z), Color("173748"))
		stroke.name = "TechPlusLetter"
		var material := Models.material(Color("173748"))
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stroke.material_override = material


static func lamp(parent: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	parent.add_child(light)
