class_name PyramidArt
extends RefCounted

# One authored cutaway: Sarcophagus with Anubis, paired central chests, and a rear Throne.
# Every ornament is visual-only. HeistLevel.wall owns the collision geometry.
const SAND := Color("ad9677")
const STONE := Color("a08d79")
const EDGE := Color("c6b395")
const LAPIS := Color("286b84")
const GOLD := Color("e0b464")
const TURQUOISE := Color("50b8ae")

static func part(level, size: Vector3, at: Vector3, color: Color, ground := false, exterior := false) -> MeshInstance3D:
	var node := Models.box(level, size, at, color)
	Models.set_toon_profile(node, ToonMaterial.Profile.GROUND if ground else ToonMaterial.Profile.PROP)
	if exterior: node.set_meta("exterior", true)
	return node

static func fill(level, at: Vector3, color: Color, energy: float, radius: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = radius
	lamp.omni_attenuation = 1.5
	lamp.light_cull_mask = level.INTERIOR_LAYER
	lamp.shadow_enabled = false
	lamp.position = at
	level.add_child(lamp)
	level.fill_lights.append(lamp)

static func column(level, at: Vector3) -> void:
	part(level, Vector3(0.7, 0.15, 0.7), at + Vector3(0, 0.08, 0), STONE)
	var shaft := Models.cylinder(level, 0.23, 1.15, at + Vector3(0, 0.69, 0), Color("b7aa91"))
	Models.set_toon_profile(shaft, ToonMaterial.Profile.PROP)
	for height in [0.28, 1.02]:
		var band := Models.cylinder(level, 0.25, 0.11, at + Vector3(0, height, 0), LAPIS)
		Models.set_toon_profile(band, ToonMaterial.Profile.PROP)
	part(level, Vector3(0.70, 0.15, 0.70), at + Vector3(0, 1.33, 0), Color("345e72"))
	part(level, Vector3(0.27, 0.045, 0.27), at + Vector3(0, 1.43, 0), GOLD)

static func glyph_panel(level, at: Vector3, face_z := true) -> void:
	var panel_size := Vector3(0.76, 0.58, 0.055) if face_z else Vector3(0.055, 0.58, 0.76)
	part(level, panel_size, at, Color("a18c72"))
	var inset_size := Vector3(0.61, 0.42, 0.02) if face_z else Vector3(0.02, 0.42, 0.61)
	var forward := Vector3(0, 0, 0.038) if face_z else Vector3(0.038, 0, 0)
	part(level, inset_size, at + forward, Color("736b5f"))
	for i in range(3):
		var stripe_size := Vector3(0.1 + 0.045 * i, 0.055, 0.015) if face_z else Vector3(0.015, 0.055, 0.1 + 0.045 * i)
		var offset := Vector3(-0.17 + i * 0.16, 0.12 - i * 0.12, 0.052) if face_z else Vector3(0.052, 0.12 - i * 0.12, -0.17 + i * 0.16)
		part(level, stripe_size, at + offset, GOLD if i == 1 else TURQUOISE)

static func ankh(level, at: Vector3, scale := 1.0, exterior := false) -> void:
	# Raised five-piece carving, legible from the gameplay camera.
	var pieces := [
		[Vector3(-0.11, 0.12, 0), Vector3(0.055, 0.18, 0.025)],
		[Vector3(0.11, 0.12, 0), Vector3(0.055, 0.18, 0.025)],
		[Vector3(0, 0.22, 0), Vector3(0.24, 0.055, 0.025)],
		[Vector3(0, 0.015, 0), Vector3(0.33, 0.055, 0.025)],
		[Vector3(0, -0.12, 0), Vector3(0.06, 0.25, 0.025)],
	]
	for piece in pieces:
		part(level, piece[1] * scale, at + piece[0] * scale, GOLD, false, exterior)

static func palm(level, at: Vector3, height := 1.0) -> void:
	var trunk := Models.cylinder(level, 0.11 * height, 1.45 * height, at + Vector3.UP * 0.725 * height, Color("735d4a"))
	trunk.set_meta("exterior", true)
	Models.set_toon_profile(trunk, ToonMaterial.Profile.PROP)
	for band in [0.31, 0.66, 1.01]:
		var ring := Models.cylinder(level, 0.12 * height, 0.055 * height, at + Vector3.UP * band * height, Color("9a7855"))
		ring.set_meta("exterior", true)
		Models.set_toon_profile(ring, ToonMaterial.Profile.PROP)
	for i in range(7):
		var angle := TAU * i / 7.0
		var direction := Vector3(cos(angle), 0, -sin(angle))
		for section in range(3):
			var reach: float = (0.28 + section * 0.28) * height
			var leaf := part(level, Vector3((0.40 - section * 0.06) * height, 0.055 * height, (0.22 - section * 0.045) * height), at + Vector3.UP * (1.47 - section * 0.11) * height + direction * reach, Color("277067") if i % 2 == 0 else Color("348779"), false, true)
			leaf.rotation.y = angle

static func distant_pyramid(level, at: Vector3, width: float, height: float) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = width * 0.68
	mesh.height = height
	mesh.radial_segments = 4
	var silhouette := MeshInstance3D.new()
	silhouette.mesh = mesh
	silhouette.material_override = Models.material(Color("33495d"))
	silhouette.position = at + Vector3.UP * height * 0.5
	silhouette.rotation.y = PI / 4.0
	silhouette.set_meta("exterior", true)
	level.add_child(silhouette)
	Models.set_toon_profile(silhouette, ToonMaterial.Profile.PROP)

static func obelisk(level, at: Vector3) -> void:
	part(level, Vector3(0.87, 0.2, 0.87), at + Vector3.UP * 0.10, Color("7e7771"), false, true)
	part(level, Vector3(0.64, 0.17, 0.64), at + Vector3.UP * 0.28, EDGE, false, true)
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.19
	shaft_mesh.bottom_radius = 0.26
	shaft_mesh.height = 1.58
	shaft_mesh.radial_segments = 4
	var shaft := MeshInstance3D.new()
	shaft.mesh = shaft_mesh
	shaft.material_override = Models.material(Color("b4a28e"))
	shaft.position = at + Vector3.UP * 1.15
	shaft.rotation.y = PI / 4.0
	shaft.set_meta("exterior", true)
	level.add_child(shaft)
	Models.set_toon_profile(shaft, ToonMaterial.Profile.PROP)
	for h in [0.76, 1.13, 1.5]:
		part(level, Vector3(0.26, 0.06, 0.035), at + Vector3(0, h, 0.28), Color("6f6a63"), false, true)
	var cap := CylinderMesh.new()
	cap.top_radius = 0.0
	cap.bottom_radius = 0.25
	cap.height = 0.43
	cap.radial_segments = 4
	var tip := MeshInstance3D.new()
	tip.mesh = cap
	tip.material_override = Models.material(GOLD)
	tip.position = at + Vector3.UP * 2.15
	tip.rotation.y = PI / 4.0
	tip.set_meta("exterior", true)
	level.add_child(tip)
	Models.set_toon_profile(tip, ToonMaterial.Profile.PROP)

static func guardian(level, at: Vector3) -> void:
	# Small blocky Sphinx sentry flanking the van, kept outside the playable breach.
	part(level, Vector3(0.93, 0.20, 0.82), at + Vector3.UP * 0.1, Color("817970"), false, true)
	part(level, Vector3(0.53, 0.34, 0.62), at + Vector3.UP * 0.39, Color("bfaa8b"), false, true)
	part(level, Vector3(0.46, 0.43, 0.44), at + Vector3.UP * 0.76, Color("ddc29c"), false, true)
	part(level, Vector3(0.57, 0.12, 0.48), at + Vector3.UP * 1.02, LAPIS, false, true)
	part(level, Vector3(0.40, 0.07, 0.07), at + Vector3(0, 0.78, 0.25), GOLD, false, true)
	for side in [-1, 1]:
		part(level, Vector3(0.14, 0.13, 0.08), at + Vector3(side * 0.13, 0.86, 0.27), Color("263d4e"), false, true)

static func desert(level) -> void:
	# Blue-hour sandstone field; the tiled causeway extends beyond the collision fence.
	extended_desert(level)
	var outside := part(level, Vector3(13.0, 0.25, 20.0), Vector3(0, -0.20, 2.0), Color("43556a"), true, true)
	outside.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Individual broad stones and seams read like the reference at phone scale.
	part(level, Vector3(3.05, 0.035, 8.55), Vector3(0, -0.045, 7.15), Color("777a77"), true, true)
	for row in range(12):
		var z: float = 3.1 + row * 0.70
		for lane in [-1, 0, 1]:
			var shift: float = 0.08 if row % 2 else -0.08
			part(level, Vector3(0.87, 0.014, 0.62), Vector3(lane * 0.92 + shift, -0.018, z), Color("a39b88") if (row + lane) % 3 == 0 else Color("8d8d84"), true, true)
	for edge in [-1, 1]:
		part(level, Vector3(0.16, 0.11, 8.55), Vector3(edge * 1.59, 0.025, 7.15), EDGE, false, true)
	for at in [Vector3(-4.7, -0.075, 5.15), Vector3(4.7, -0.075, 5.35), Vector3(-4.5, -0.075, 8.5), Vector3(4.5, -0.075, 8.85), Vector3(-3.25, -0.075, 10.1), Vector3(3.4, -0.075, 10.4)]:
		var dune := Models.ball(level, Vector3(1.35, 0.065, 0.52), at, Color("706d6e"))
		dune.set_meta("exterior", true)
		Models.set_toon_profile(dune, ToonMaterial.Profile.GROUND)
	for at in [Vector3(-5.8, 0, 3.1), Vector3(5.8, 0, 3.4), Vector3(-5.8, 0, 9.7), Vector3(5.8, 0, 9.9)]:
		palm(level, at, 0.95 if at.z > 8 else 1.15)
	for at in [Vector3(-4.0, 0, 7.2), Vector3(4.0, 0, 7.2)]:
		obelisk(level, at)
	for at in [Vector3(-2.65, 0, 4.65), Vector3(2.65, 0, 4.65)]:
		guardian(level, at)
	for at in [Vector3(-4.35, 0.11, 4.2), Vector3(4.45, 0.11, 4.5), Vector3(-3.5, 0.12, 6.1), Vector3(3.55, 0.12, 6.55), Vector3(-2.8, 0.1, 9.2), Vector3(3.25, 0.1, 9.5)]:
		var rock := part(level, Vector3(0.52, 0.24, 0.46), at, Color("8c8983"), false, true)
		rock.rotation.y = at.x
	for at in [Vector3(-5.9, 0, -6.2), Vector3(5.9, 0, -6.7)]:
		distant_pyramid(level, at, 1.6, 1.5)


static func extended_desert(level) -> void:
	# Visual-only landscape replaces the empty background at every camera
	# follow limit. The temple remains a raised archaeological island.
	var desert_sand := Color("716d67")
	var moon_sand := Color("817c72")
	var buried_stone := Color("8c8374")
	part(level, Vector3(62.0, 0.16, 82.0), Vector3(0, -0.20, 2.0), desert_sand, true, true)
	for side in [-1.0, 1.0]:
		# Broad, shallow dune bands give the desert structure without clutter.
		for band in range(5):
			var dune_x: float = side * (9.2 + float(band % 2) * 4.1)
			var dune_z := -24.0 + float(band) * 11.0
			var dune := Models.ball(level, Vector3(3.2, 0.10, 1.15), Vector3(dune_x, -0.105, dune_z), Color("928579") if band % 2 == 0 else Color("625f61"))
			dune.set_meta("exterior", true)
			Models.set_toon_profile(dune, ToonMaterial.Profile.GROUND)
	# The tiled causeway continues past the van into the lower portrait frame.
	part(level, Vector3(3.32, 0.045, 16.0), Vector3(0, -0.088, 20.4), Color("797a75"), true, true)
	for side in [-1.0, 1.0]:
		part(level, Vector3(0.17, 0.09, 16.0), Vector3(side * 1.68, -0.015, 20.4), EDGE, false, true)
	for row in range(17):
		var tile_z := 12.75 + float(row) * 0.91
		for lane in [-1, 0, 1]:
			part(level, Vector3(0.91, 0.014, 0.80), Vector3(float(lane) * 0.98 + (0.06 if row % 2 else -0.06), -0.057, tile_z), Color("b7ad98") if (row + lane) % 4 == 0 else Color("a49d8c"), true, true)
	# Paired ruin courts frame the temple without making a second maze.
	for side in [-1.0, 1.0]:
		var court_x: float = side * 10.8
		part(level, Vector3(5.4, 0.055, 13.4), Vector3(court_x, -0.11, -0.9), Color("676b69"), true, true)
		for z in [-6.8, -2.6, 1.6, 5.8]:
			part(level, Vector3(4.8, 0.023, 0.10), Vector3(court_x, -0.067, z), buried_stone, true, true)
		for z in [-5.5, 1.5, 6.8]:
			part(level, Vector3(0.72, 0.22, 0.72), Vector3(side * 13.1, 0.035, z), Color("746d67"), false, true)
			part(level, Vector3(0.38, 0.66, 0.38), Vector3(side * 13.1, 0.48, z), Color("afa18a"), false, true)
			part(level, Vector3(0.58, 0.11, 0.58), Vector3(side * 13.1, 0.87, z), LAPIS, false, true)
		for z in [-11.8, 13.4, 20.5]:
			palm(level, Vector3(side * 12.4, -0.11, z), 0.88)
		for z in [-10.2, -7.4, 9.5, 12.4, 18.4]:
			var rubble := part(level, Vector3(0.94, 0.24, 0.62), Vector3(side * 8.0, -0.01, z), Color("a59985"), false, true)
			rubble.rotation.y = side * 0.19
		obelisk(level, Vector3(side * 3.5, -0.10, 19.1))
	# An excavation yard and distant pyramid silhouettes behind the sanctum.
	part(level, Vector3(24.0, 0.045, 12.5), Vector3(0, -0.105, -14.6), moon_sand, true, true)
	part(level, Vector3(7.1, 0.025, 3.35), Vector3(0, -0.061, -11.55), Color("6a7270"), true, true)
	for side in [-1.0, 1.0]:
		part(level, Vector3(0.12, 0.03, 3.40), Vector3(side * 3.54, -0.039, -11.55), EDGE, true, true)
		part(level, Vector3(0.66, 0.22, 0.66), Vector3(side * 2.55, 0.045, -13.5), buried_stone, false, true)
		part(level, Vector3(0.36, 0.54, 0.36), Vector3(side * 2.55, 0.43, -13.5), Color("aa9b84"), false, true)
	part(level, Vector3(1.2, 0.035, 1.2), Vector3(0, -0.037, -11.55), LAPIS, true, true)
	for x in [-10.0, -5.0, 5.0, 10.0]:
		part(level, Vector3(0.87, 0.20, 0.87), Vector3(x, 0.04, -13.3), buried_stone, false, true)
		part(level, Vector3(0.47, 0.78, 0.47), Vector3(x, 0.53, -13.3), Color("aa9b84"), false, true)
		part(level, Vector3(0.66, 0.11, 0.66), Vector3(x, 0.98, -13.3), LAPIS, false, true)
	for x in [-15.0, 15.0]:
		distant_pyramid(level, Vector3(x, -0.11, -24.0), 6.0, 4.4)
	distant_pyramid(level, Vector3(0, -0.11, -18.0), 3.8, 2.7)
	distant_pyramid(level, Vector3(0, -0.11, -30.0), 9.0, 6.2)
	part(level, Vector3(62.0, 0.04, 8.0), Vector3(0, -0.11, 38.0), Color("5d5d61"), true, true)


static func terraces(level) -> void:
	# Warm stepped casing wraps the cutaway without hiding its playable rooms.
	for side in [-1, 1]:
		for step in range(3):
			var width := 0.63 - step * 0.12
			var x: float = float(side) * (4.8 + step * 0.43)
			part(level, Vector3(width, 0.18 + step * 0.08, 6.25 - step * 0.45), Vector3(x, 0.09 + step * 0.04, -0.68), Color("857e77").lightened(step * 0.045), true, true)
			part(level, Vector3(width, 0.035, 6.25 - step * 0.45), Vector3(x, 0.20 + step * 0.08, -0.68), Color("afa08c"), true, true)
		for z in [-3.55, -2.5, -1.45, -0.4, 0.65, 1.7]:
			part(level, Vector3(0.035, 0.11, 0.42), Vector3(side * 5.11, 0.43, z), Color("706f6b"), false, true)
	# The small stepped crown sits behind the sanctum, clear of the walkable top tier.
	for step in range(3):
		part(level, Vector3(4.25 - step * 0.75, 0.23, 0.78 - step * 0.1), Vector3(0, 0.12 + step * 0.22, -5.65), Color("978b7d").darkened(step * 0.04), false, true)
	part(level, Vector3(0.5, 0.22, 0.34), Vector3(0, 0.80, -5.65), GOLD, false, true)

static func sun_mosaic(level) -> void:
	# Broad floor emblem on the approach to the throne, not behind it.
	part(level, Vector3(3.2, 0.022, 0.82), Vector3(0, 0.06, -2.2), Color("39586a"), true)
	var disc := Models.cylinder(level, 0.33, 0.035, Vector3(0, 0.09, -2.2), GOLD)
	Models.set_toon_profile(disc, ToonMaterial.Profile.GROUND)
	var centre := Models.cylinder(level, 0.16, 0.04, Vector3(0, 0.115, -2.2), LAPIS)
	Models.set_toon_profile(centre, ToonMaterial.Profile.GROUND)
	for side in [-1, 1]:
		for i in range(4):
			var feather := part(level, Vector3(0.34 - i * 0.045, 0.028, 0.14), Vector3(side * (0.46 + i * 0.31), 0.09, -2.2 + i * 0.055), GOLD if i % 2 == 0 else TURQUOISE, true)
			feather.rotation.y = side * (0.10 + i * 0.07)

static func build(level) -> void:
	level.tongue_flames = true
	level.halo_alpha = 0.25
	level.wall_top_lift = 0.08
	desert(level)
	var floor_tiles := [
		[Vector3(3.5, 0.16, 3.8), Vector3(-3.3, -0.05, 1.3), Color("e1b773")],
		[Vector3(3.5, 0.16, 3.8), Vector3(3.3, -0.05, 1.3), Color("81baad")],
		[Vector3(3.1, 0.16, 3.8), Vector3(0, -0.05, 1.3), Color("b8b29b")],
		[Vector3(7.8, 0.16, 3.4), Vector3(0, -0.05, -2.3), Color("7596a2")],
		[Vector3(3.8, 0.16, 1.2), Vector3(0, -0.05, -4.6), Color("596d78")],
	]
	for tile in floor_tiles: part(level, tile[0], tile[1], tile[2], true)
	# Inlaid lapis route from the breach to the burial chamber. It never blocks movement.
	part(level, Vector3(1.05, 0.024, 5.35), Vector3(0, 0.057, 0.62), Color("2d6578"), true)
	for x in [-0.57, 0.57]: part(level, Vector3(0.045, 0.028, 5.35), Vector3(x, 0.064, 0.62), GOLD, true)
	for z in [-1.55, -0.4, 0.75, 1.9, 2.75]:
		part(level, Vector3(0.37, 0.03, 0.055), Vector3(0, 0.075, z), GOLD, true)
	# The left chamber holds Sarcophagus and Anubis; Mask and Scarab flank the rear Throne.
	part(level, Vector3(2.45, 0.06, 1.60), Vector3(-3.25, 0.044, 1.90), Color("3c6171"), true)
	for z in [1.09, 2.71]: part(level, Vector3(2.5, 0.035, 0.055), Vector3(-3.25, 0.089, z), GOLD, true)
	part(level, Vector3(1.7, 0.06, 1.4), Vector3(0, 0.044, -3.65), Color("3f5869"), true)
	for z in [-4.37, -2.93]: part(level, Vector3(1.76, 0.035, 0.055), Vector3(0, 0.089, z), GOLD, true)
	for side in [-1, 1]:
		part(level, Vector3(0.75, 0.025, 0.67), Vector3(side * 0.85, 0.043, 1.60), Color("6b7480"), true)
		part(level, Vector3(1.0, 0.055, 0.88), Vector3(side * 2.2, 0.043, -3.15), Color("4a6270"), true)
	part(level, Vector3(1.1, 0.06, 1.05), Vector3(-4.05, 0.044, 0.45), Color("40596b"), true)
	# Walls retain the tested collision footprint and wide central/wing openings.
	level.wall(Vector3(3.7, 0.65, 0.23), Vector3(-3.2, 0.325, 3.2), STONE)
	level.wall(Vector3(3.7, 0.65, 0.23), Vector3(3.2, 0.325, 3.2), STONE)
	for side in [-1, 1]:
		level.wall(Vector3(0.23, 0.83, 4.0), Vector3(side * 5.05, 0.415, 1.3), STONE)
		level.wall(Vector3(3.6, 0.77, 0.23), Vector3(side * 3.35, 0.385, -0.6), STONE)
		level.wall(Vector3(0.23, 0.84, 3.5), Vector3(side * 3.9, 0.42, -2.35), STONE)
		level.wall(Vector3(2.1, 0.84, 0.23), Vector3(side * 2.95, 0.42, -4.0), STONE)
		level.wall(Vector3(0.23, 0.84, 1.3), Vector3(side * 1.9, 0.42, -4.65), STONE)
		level.wall(Vector3(0.23, 0.72, 0.6), Vector3(side * 1.55, 0.36, -0.3), STONE)
		level.wall(Vector3(0.23, 0.72, 0.9), Vector3(side * 1.55, 0.36, 2.75), STONE)
	level.wall(Vector3(4.0, 0.84, 0.23), Vector3(0, 0.42, -5.3), STONE)
	terraces_and_details(level)

static func terraces_and_details(level) -> void:
	terraces(level)
	sun_mosaic(level)
	# Open monumental entrance: tall side pylons frame the breach but never span over the thief.
	for side in [-1, 1]:
		part(level, Vector3(0.75, 0.24, 0.83), Vector3(side * 1.93, 0.12, 3.43), Color("82786c"), false, true)
		part(level, Vector3(0.61, 1.47, 0.64), Vector3(side * 1.93, 0.96, 3.43), Color("b8a58e"), false, true)
		part(level, Vector3(0.78, 0.18, 0.79), Vector3(side * 1.93, 1.80, 3.43), EDGE, false, true)
		part(level, Vector3(0.41, 0.54, 0.03), Vector3(side * 1.93, 0.97, 3.77), LAPIS, false, true)
		ankh(level, Vector3(side * 1.93, 0.94, 3.80), 0.58, true)
		# The wall's front face gets a simple repeating carved frieze.
		for x in [2.6, 3.35, 4.1]:
			part(level, Vector3(0.60, 0.33, 0.035), Vector3(side * x, 0.43, 3.36), Color("a69178"), false, true)
			ankh(level, Vector3(side * x, 0.40, 3.39), 0.33, true)
		# Loose fallen masonry makes the silhouette taper into the desert.
		for z in [4.35, 5.25, 8.4]:
			var block := part(level, Vector3(0.39, 0.24, 0.51), Vector3(side * (3.55 + 0.12 * z), 0.12, z), Color("918b82"), false, true)
			block.rotation.y = side * 0.28
	# Two blue temple banners on the far facade, clear of the floor mosaic.
	for side in [-1, 1]:
		part(level, Vector3(0.34, 0.68, 0.03), Vector3(side * 0.82, 0.53, -5.13), LAPIS)
		ankh(level, Vector3(side * 0.82, 0.50, -5.09), 0.48)
	# Warm exterior flames outline the portal and the causeway; only two need a real light.
	for side in [-1, 1]:
		level.torch(Vector3(side * 2.82, 0, 3.89), false, Color("ffd191"), 1.7, 3.1, true, 0.95)
		level.torch(Vector3(side * 4.65, 0, 6.55), false, Color("ffd191"), 1.4, 2.8, false, 0.85)
	# Stone courses and blue capitals make the shell read as carved architecture.
	for side in [-1, 1]:
		for z in [-3.5, -2.55, -1.6]:
			part(level, Vector3(0.08, 0.075, 0.55), Vector3(side * 3.79, 0.67, z), LAPIS)
		for z in [0.2, 1.35, 2.5]:
			part(level, Vector3(0.08, 0.075, 0.55), Vector3(side * 4.94, 0.65, z), LAPIS)
		column(level, Vector3(side * 1.9, 0, 3.52))
		column(level, Vector3(side * 1.83, 0, -0.93))
		glyph_panel(level, Vector3(side * 2.65, 0.53, -3.88))
		glyph_panel(level, Vector3(side * 3.45, 0.53, 3.08))
	# Winged sun, an oversized silhouette above the unused rear sanctum.
	var sun := Models.ball(level, Vector3(0.56, 0.42, 0.1), Vector3(0, 0.66, -5.17), GOLD)
	Models.set_toon_profile(sun, ToonMaterial.Profile.PROP)
	for side in [-1, 1]:
		for i in range(3):
			part(level, Vector3(0.42 - i * 0.07, 0.09, 0.07), Vector3(side * (0.55 + i * 0.36), 0.69 - i * 0.11, -5.16), GOLD)
	# A few large tiles and broken entrance stones: broad shapes remain legible at phone size.
	for x in [-3.95, -2.65, 2.65, 3.95]:
		part(level, Vector3(0.75, 0.022, 0.07), Vector3(x, 0.054, 2.7), EDGE, true)
	for side in [-1, 1]:
		for i in range(3):
			var rubble := part(level, Vector3(0.30 - i * 0.05, 0.14, 0.28), Vector3(side * (1.55 + i * 0.17), 0.07, 3.43 + i * 0.2), STONE.darkened(i * 0.08))
			rubble.rotation.y = 0.36 * i
	# 16 visible flames, ten low-cost local lights, and broad cool room fills.
	var torches := [
		Vector3(-4.69, 0, 2.85), Vector3(-4.69, 0, 1.2), Vector3(-4.69, 0, -0.35),
		Vector3(4.69, 0, 2.85), Vector3(4.69, 0, 1.2), Vector3(4.69, 0, -0.35),
		Vector3(-1.82, 0, 2.88), Vector3(1.82, 0, 2.88),
		Vector3(-3.5, 0, -1.0), Vector3(3.5, 0, -1.0),
		Vector3(-3.5, 0, -3.6), Vector3(3.5, 0, -3.6),
		Vector3(-1.48, 0, -4.88), Vector3(1.48, 0, -4.88),
		Vector3(-1.45, 0, -0.27), Vector3(1.45, 0, -0.27),
	]
	for i in range(torches.size()):
		var lit := i in [0, 2, 3, 5, 6, 7, 8, 9, 10, 11]
		level.torch(torches[i], false, Color("ffd09a"), 1.05, 2.7, lit, 0.6)
	fill(level, Vector3(-3.25, 2.5, 1.1), Color("ffd18a"), 1.65, 3.8)
	fill(level, Vector3(3.25, 2.5, 1.1), Color("92ded2"), 1.45, 3.8)
	fill(level, Vector3(0, 2.5, 1.1), Color("cad9d7"), 1.1, 3.8)
	fill(level, Vector3(0, 2.7, -2.2), Color("a7c7d0"), 1.35, 4.1)
	fill(level, Vector3(0, 2.5, -4.55), Color("a5b7d2"), 0.65, 3.5)
