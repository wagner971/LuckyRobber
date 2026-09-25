class_name HeistLevel
extends Node3D

const HOUSE_ART = preload("res://scripts/house_art.gd")
const APARTMENT_ART = preload("res://scripts/apartment_art.gd")
const VILLA_ART = preload("res://scripts/villa_art.gd")
const ELECTRONICS_ART = preload("res://scripts/electronics_art.gd")
const CASTLE_SURROUNDINGS = preload("res://scripts/castle_surroundings.gd")
const MANSION_ART = preload("res://scripts/mansion_art.gd")
const LABORATORY_ART = preload("res://scripts/laboratory_art.gd")
const MUSEUM_ART = preload("res://scripts/museum_art.gd")
const TRAINING_ART = preload("res://scripts/training_art.gd")
const PIRATE_ART = preload("res://scripts/pirate_ship_art.gd")
const VIKING_ART = preload("res://scripts/viking_art.gd")
const PUB_ART = preload("res://scripts/pub_art.gd")
const PREHISTORIC_ART = preload("res://scripts/prehistoric_art.gd")
const TRAINING_ITEMS = [["tv", "small_tv", -2.12, -0.30], ["pc", "gaming_pc", 2.30, -2.02], ["chair", "chair", 1.20, -0.70]]

var items: Array[LootItem] = []
var player: ThiefPlayer
var van: LootVan
var camera: Camera3D
var scene_environment: Environment
var walls: Array[Rect2] = []
var location_id = "apartment"
var training_layout := false
var security: SecurityPatrol

func setup(location: String, capacity_level: int, loop_only: bool = false, training: bool = false) -> void:
	location_id = location
	training_layout = training
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("162532")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d5e6ed")
	env.ambient_light_energy = 0.30
	scene_environment = env
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.adjustment_enabled = true
	env.adjustment_brightness = 0.96
	env.adjustment_contrast = 1.12
	env.adjustment_saturation = 1.04
	# Compatibility uses its reduced-cost glow path. Only bright accents bleed.
	env.glow_enabled = true
	env.glow_intensity = 0.11
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 0.95
	environment.environment = env
	add_child(environment)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_color = Color("fff0d6")
	light.light_energy = 0.65
	light.shadow_enabled = true
	add_child(light)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 10.0
	add_child(camera)
	camera.position = Vector3(0, 18, 14)
	camera.look_at(Vector3(0, 0, 0.6))
	if location == "house":
		camera.position = Vector3(0, 18, 18)
		camera.look_at(Vector3(0, 0, -0.15))
		camera.size = 10.8
	elif location == "villa":
		camera.position = Vector3(0, 21, 19)
		camera.look_at(Vector3(0, 0, -2.0))
		camera.size = 11.6
	elif location == "electronics":
		camera.position = Vector3(0, 18, 18)
		camera.look_at(Vector3(0, 0, 0.4))
		camera.size = 12.2
	elif location == "mansion":
		camera.position = Vector3(0, 23, 23)
		camera.look_at(Vector3(0, 0, -1.25))
		camera.size = 14.0
	elif location == "laboratory":
		camera.position = Vector3(0, 22, 23)
		camera.look_at(Vector3(0, 0, -1.0))
		camera.size = 14.4
	elif location == "museum":
		camera.position = Vector3(0, 24, 24)
		camera.look_at(Vector3(0, 0, -1.3))
		camera.size = 15.6
	elif location == "pyramid":
		camera.position = Vector3(0, 16, 17)
		camera.look_at(Vector3(0, 0, 0.6))
	elif location == "castle":
		camera.position = Vector3(0, 16, 17)
		camera.look_at(Vector3(0, 0, 0.6))
	if location == "pirate_ship":
		camera.position = Vector3(0,22,22)
		camera.look_at(Vector3(0,0,-1.9))
		camera.size = 12.8
	if location in ["vikings", "english_pub", "prehistoric"]:
		camera.position = Vector3(0,23,24)
		camera.look_at(Vector3(0,0,-1.7))
		camera.size = 14.5
	camera.current = true
	match location:
		"apartment":
			if training_layout: build_training_garage()
			else: build_apartment()
		"house":
			build_house()
			# Brighter moonlit suburb; the local porch and room lights add warm windows.
			env.background_color = Color("17283d")
			env.ambient_light_color = Color("a8bfd4")
			env.ambient_light_energy = 0.50
			light.light_color = Color("dce9fa")
			light.light_energy = 0.56
		"villa":
			build_villa()
			env.background_color = Color("142137")
			env.ambient_light_color = Color("c2cde1")
			env.ambient_light_energy = 0.41
			light.light_color = Color("e6e5ee")
			light.light_energy = 0.55
		"electronics":
			build_electronics()
			env.background_color = Color("142336")
			env.ambient_light_color = Color("b4c6d4")
			env.ambient_light_energy = 0.39
			light.light_color = Color("dee9f2")
			light.light_energy = 0.46
		"mansion":
			build_mansion()
			env.background_color = Color("172138")
			env.ambient_light_color = Color("c0d0df")
			env.ambient_light_energy = 0.42
			light.light_color = Color("f5e4c8")
			light.light_energy = 0.58
		"laboratory":
			build_laboratory()
			env.background_color = Color("112535")
			env.ambient_light_color = Color("afcdd2")
			env.ambient_light_energy = 0.39
			light.light_color = Color("d0e8e7")
			light.light_energy = 0.49
		"museum":
			build_museum()
			env.background_color = Color("19263a")
			env.ambient_light_color = Color("c8d4dc")
			env.ambient_light_energy = 0.38
			light.light_color = Color("f6ead8")
			light.light_energy = 0.53
		"pyramid":
			interior_rects = PYRAMID_TIERS
			build_pyramid()
			# Blue-hour desert and a readable, cool tomb; braziers supply small warm accents.
			env.background_color = Color("101d30")
			env.ambient_light_color = Color("9da5a8")
			env.ambient_light_energy = 1.65
			light.light_cull_mask = 1
			light.light_color = Color("f4d8ab")
			light.light_energy = 0.6
			light.rotation_degrees = Vector3(-62, -35, 0)
		"castle":
			interior_rects = CASTLE_ROOMS
			build_castle()
			# Lighting Pass V1: one cool night for the whole castle. A desaturated blue-grey
			# ambient keeps shadows blue instead of black, and a single weak global moonlight
			# (inside too) shapes walls, towers, floor and van. Torches add local warmth only.
			env.background_color = Color("111827")
			env.ambient_light_color = Color("29344a")
			env.ambient_light_energy = CASTLE_AMBIENT
			light.light_cull_mask = 0xFFFFF
			light.light_color = Color("b4c2e0")
			light.light_energy = CASTLE_MOON
			light.rotation_degrees = Vector3(-62, -30, 0)
		"pirate_ship":
			PIRATE_ART.build(self)
			env.background_color = Color("103342")
			env.ambient_light_color = Color("9ccad7")
			env.ambient_light_energy = 0.43
			light.light_color = Color("f3e2c4")
			light.light_energy = 0.62
		"vikings":
			VIKING_ART.build(self)
			env.background_color = Color("1b354a")
			env.ambient_light_color = Color("a9c8dc")
			env.ambient_light_energy = 0.40
			light.light_color = Color("e8e0ce")
			light.light_energy = 0.59
		"english_pub":
			PUB_ART.build(self)
			env.background_color = Color("172a38")
			env.ambient_light_color = Color("b9c5c9")
			env.ambient_light_energy = 0.38
			light.light_color = Color("f2dfb8")
			light.light_energy = 0.57
		"prehistoric":
			PREHISTORIC_ART.build(self)
			env.background_color = Color("18352f")
			env.ambient_light_color = Color("a9c4ba")
			env.ambient_light_energy = 0.40
			light.light_color = Color("f2ddb4")
			light.light_energy = 0.56
		_: build_default_floorplan(location)
	if location == "apartment":
		# A lower, more isometric view reveals the facades around the starter heist.
		camera.position = Vector3(0, 14, 15) if training_layout else Vector3(0, 17, 17)
		camera.look_at(Vector3(0, 0, 1.0 if training_layout else 0.6))
		camera.size = 7.5 if training_layout else 8.8
		env.background_color = Color("152438")
		env.ambient_light_color = Color("d5e6ed")
		env.ambient_light_energy = 0.30
		if training_layout:
			env.ambient_light_color = Color("a5c4db")
			env.ambient_light_energy = 0.48
			light.light_color = Color("d6e4f0")
			light.light_energy = 0.52
			light.rotation_degrees = Vector3(-48, -28, 0)
	var spawn_rows: Array = TRAINING_ITEMS if training_layout else Balance.LOCATIONS[location].items
	for row in spawn_rows:
		if loop_only and not items.is_empty(): break
		var item = LootItem.new()
		add_child(item)
		item.setup(row[1], ("training" if training_layout else location) + "." + row[0], row[4] if row.size() > 4 else "")
		item.position = Vector3(row[2], 0.08, row[3])
		if training_layout:
			# Raise the item root, not its visual: pickup reparents the root to
			# CarryAnchor and correctly removes this supporting-surface elevation.
			if row[0] == "tv": item.position.y = 0.58
			if row[0] == "pc": item.position.y = 0.715
			if row[0] == "chair": item.model.rotation.y = PI
		if location == "house":
			if row[0] == "tv":
				item.position.y = 0.59
			if row[0] == "sofa": item.model.rotation.y = PI
			if row[0] == "duck": item.position.y = 0.68
			if row[0] == "chair": item.model.rotation.y = PI / 2
			if row[0] == "toilet": item.model.rotation.y = -PI / 2
		if location == "villa":
			match row[0]:
				"tv": item.position.y = 0.625
				"monitor":
					item.position.y = 0.79
					item.model.rotation.y = -PI / 6
				"pc": item.model.rotation.y = -PI / 4
				"sofa", "chair": item.model.rotation.y = PI
				"toilet": item.model.rotation.y = -PI / 2
		if location == "apartment" and not training_layout:
			match row[0]:
				"tv_a":
					item.position.y = 0.51
					item.model.rotation.y = PI / 3
				"chair_a", "toilet": item.model.rotation.y = -PI / 2
				"fan", "laptop": item.position.y = 0.69
				"microwave": item.position.y = 0.65
				"flamingo": item.position.y = 0.24
		if location == "laboratory":
			if row[0] == "microscope": item.position.y = 0.73
			if row[0] == "analyzer": item.position.y = 0.72
			if row[0] == "robot_arm": item.model.rotation.y = PI
		if location == "mansion":
			match row[0]:
				"pc_a", "monitor":
					item.position.y = 0.76 if row[0] == "pc_a" else 0.751
					item.model.rotation.y = PI / 2
				"pc_b": item.position.y = 0.75
				"tv":
					item.position.y = 0.595
					item.model.rotation.y = -PI / 2
				"fridge", "toilet": item.model.rotation.y = -PI / 2
		if location == "electronics":
			match row[0]:
				"vending": item.model.rotation.y = PI / 2
				"tv_a", "tv_b", "tv_c": item.position.y = 0.625
				"monitor_a", "monitor_b": item.position.y = 0.761
				"pc_a", "pc_b", "pc_c": item.position.y = 0.65
		if location == "pirate_ship" and row[0] in ["sextant", "compass"]: item.position.y = 0.67
		if location == "vikings":
			item.position.y = 0.13
			if row[0] in ["helmet", "horn"]: item.position.y = 0.70
			if row[0] == "raven": item.position.y = 0.60
		if location == "english_pub":
			item.position.y = 0.15
			match row[0]:
				"gramophone": item.position.y = 0.62
				"radio": item.position.y = 0.70
				"tankard": item.position.y = 0.76
				"register", "pumps":
					item.position.y = 0.94
					item.model.rotation.y = -PI/2
		if location == "prehistoric" and row[0] in ["necklace", "amber"]: item.position.y = 0.59
		items.append(item)
	van = LootVan.new()
	add_child(van)
	if location == "house": van.load_position = Vector3(0, 0, 5.6)
	if location in ["pirate_ship", "vikings", "english_pub", "prehistoric"]: van.load_position = Vector3(0,0,6.4)
	van.setup(capacity_level)
	Models.set_toon_profile(van.model, ToonMaterial.Profile.CHARACTER)
	# The rear cargo doors face the entrance at every location.
	van.model.position = Vector3(0, 0, 6.0)
	van.model.rotation.y = -PI / 2
	# Outdoor edges keep the thief on the diorama, with no long escape routes.
	var side_depth := 25.0 if location == "house" else (27.0 if location == "villa" else (28.0 if location == "mansion" else (22.0 if location == "electronics" else 12.2)))
	var side_mid := 1.6 if location == "house" else (1.0 if location == "villa" else (1.8 if location == "mansion" else (4.0 if location == "electronics" else 0.6)))
	var side_x := 6.5 if location == "house" else (6.8 if location == "villa" else (8.0 if location == "mansion" else (7.2 if location == "electronics" else 5.75)))
	if location == "museum":
		side_depth = 31.0
		side_mid = 1.75
		side_x = 8.9
	if location == "laboratory":
		side_depth = 31.0
		side_mid = 1.75
		side_x = 8.9
	if location in ["pirate_ship", "vikings", "english_pub", "prehistoric"]:
		side_depth = 34.0
		side_mid = 1.5
		side_x = 10.0
	barrier(Vector3(0.2, 3, side_depth), Vector3(-side_x, 1, side_mid))
	barrier(Vector3(0.2, 3, side_depth), Vector3(side_x, 1, side_mid))
	var front_span := 13.0 if location == "house" else (13.6 if location == "villa" else (16.0 if location == "mansion" else (14.4 if location == "electronics" else 11.5)))
	var front_z := 14.1 if location == "house" else (13.5 if location == "villa" else (15.6 if location == "mansion" else (15.0 if location == "electronics" else 6.6)))
	if location == "museum":
		front_span = 17.8
		front_z = 17.1
	if location == "laboratory":
		front_span = 17.8
		front_z = 17.1
	if location in ["pirate_ship", "vikings", "english_pub", "prehistoric"]:
		front_span = 20.0
		front_z = 17.0
	barrier(Vector3(front_span, 3, 0.2), Vector3(0, 1, front_z))
	if location in ["pyramid", "castle"]:
		van.model.position = Vector3(0, 0, 6.35)
		barrier(Vector3(1.5, 3, 3.9), Vector3(0, 1, 6.5))
		walls.append(Rect2(-0.75, 4.55, 1.5, 3.9))
	else:
		if location in ["pirate_ship", "vikings", "english_pub", "prehistoric"]:
			van.model.position = Vector3(0,0,8.5)
			barrier(Vector3(1.5,3,3.5),Vector3(0,1,8.55))
			walls.append(Rect2(-0.75,6.80,1.5,3.5))
		elif location == "house":
			van.model.position = Vector3(0, 0, 7.6)
			barrier(Vector3(1.5, 3, 3.5), Vector3(0, 1, 7.65))
			walls.append(Rect2(-0.75, 5.90, 1.5, 3.5))
		else:
			Models.box(self, Vector3(1.95, 0.035, 3.5), Vector3(0, -0.055, 5.5), Color("53646b"))
			barrier(Vector3(1.5, 3, 3.0), Vector3(0, 1, 6.15))
			walls.append(Rect2(-0.75, 4.65, 1.5, 3.0))
	player = ThiefPlayer.new()
	add_child(player)
	player.position = Vector3(-1.9, 0, 2.15) if training_layout else Vector3(-0.7 if location == "apartment" else 0.0, 0, 2.85 if location == "apartment" else 3.65)
	if not training_layout: place_room_labels(location)
	if location == "pyramid":
		light_hero_loot(["sarcophagus", "golden_throne", "giant_anubis"])
		ground_loot({"sarcophagus": [Vector2(2.0, 1.3), 0.13], "golden_throne": [Vector2(1.5, 1.35), 0.13], "giant_anubis": [Vector2(1.2, 1.2), 0.13], "obelisk_fragment": [Vector2(0.9, 0.9), 0.1]})
	if location == "castle":
		light_hero_loot(["vampire_throne", "dracula_coffin", "pipe_organ", "gothic_mirror"])
		ground_loot({"vampire_throne": [Vector2(1.9, 1.6), 0.33], "dracula_coffin": [Vector2(1.3, 2.3), 0.13], "pipe_organ": [Vector2(1.9, 1.1), 0.1], "gothic_mirror": [Vector2(1.1, 0.9), 0.1], "relic_chest": [Vector2(1.2, 0.9), 0.1], "gargoyle_statue": [Vector2(1.2, 1.0), 0.1], "bat_idol": [Vector2(0.9, 0.8), 0.1]})
		var van_blob = contact_blob(Vector2(1.9, 4.2), Vector3(0, -0.03, 6.35))
		van_blob.set_meta("exterior", true)
		# Moonlit forecourt: a broad, faint, cool pool so the van and breach read at night.
		var yard = OmniLight3D.new()
		yard.light_color = Color("aab8dc")
		yard.omni_range = 5.5
		yard.omni_attenuation = 1.0
		yard.light_energy = 1.1
		yard.light_cull_mask = 1
		yard.shadow_enabled = false
		yard.position = Vector3(0, 2.6, 5.6)
		add_child(yard)
		fill_lights.append(yard)
	if location == "apartment":
		var van_shadow = contact_blob(Vector2(3.35, 3.75), Vector3(0, -0.035, 6.0))
		van_shadow.name = "ApartmentVanShadow"
	if not interior_rects.is_empty(): apply_interior_layers()
	if not training_layout and location in SecurityPatrol.LOCATIONS:
		security = SecurityPatrol.new()
		add_child(security)
		security.setup(self)

func set_visual_polish(enabled: bool) -> void:
	if not is_instance_valid(scene_environment): return
	scene_environment.adjustment_enabled = enabled
	scene_environment.glow_enabled = enabled

# Emergency fallback greybox; every playable location has a dedicated plan.
func build_default_floorplan(location: String) -> void:
	var outside = Models.box(self, Vector3(11.5, 0.25, 12), Vector3(0, -0.20, 0.6), Color("243d49"))
	var floor_base = Models.box(self, Vector3(10, 0.16, 7.7), Vector3(0, -0.05, -0.65), Color("e9d6b1"))
	Models.set_toon_profile(outside, ToonMaterial.Profile.GROUND)
	Models.set_toon_profile(floor_base, ToonMaterial.Profile.GROUND)
	for x in [-2.5, 2.5]:
		for z in [-2.6, 1.0]:
			var room_floor = Models.box(self, Vector3(4.65, 0.025, 3.4), Vector3(x, 0.05, z), Color("b5d6cf") if x > 0 else Color("d9bfa0"))
			Models.set_toon_profile(room_floor, ToonMaterial.Profile.GROUND)
	var rug = Models.box(self, Vector3(2.2, 0.025, 2), Vector3(-2.4, 0.08, 1.0), Color("d17d70"))
	Models.set_toon_profile(rug, ToonMaterial.Profile.GROUND)
	wall(Vector3(10.25, 0.72, 0.2), Vector3(0, 0.36, -4.55))
	wall(Vector3(0.2, 0.72, 7.7), Vector3(-5.05, 0.36, -0.65))
	wall(Vector3(0.2, 0.72, 7.7), Vector3(5.05, 0.36, -0.65))
	wall(Vector3(3.7, 0.42, 0.18), Vector3(-3.2, 0.21, 3.2))
	wall(Vector3(3.7, 0.42, 0.18), Vector3(3.2, 0.21, 3.2))
	build_partitions(location)

# The three learnable objects have permanent, believable places in a small
# electronics workshop. Presentation is isolated from Apartment and other jobs.
func build_training_garage() -> void:
	TRAINING_ART.build(self)

# Compact urban starter home. The tested doorway, three-room split and short van
# route stay fixed; ApartmentArt supplies only non-colliding presentation details.
func build_apartment() -> void:
	var outside = Models.box(self, Vector3(9.3, 0.25, 10.2), Vector3(0, -0.20, 0.5), Color("838b8d"))
	var floor_base = Models.box(self, Vector3(8.0, 0.16, 7.45), Vector3(0, -0.05, -0.18), Color("cbbda5"))
	Models.set_toon_profile(outside, ToonMaterial.Profile.GROUND)
	Models.set_toon_profile(floor_base, ToonMaterial.Profile.GROUND)
	var living_floor = Models.box(self, Vector3(7.3, 0.025, 2.8), Vector3(0, 0.05, 1.8), Color("d0b692"))
	var kitchen_floor = Models.box(self, Vector3(3.55, 0.025, 4.05), Vector3(-1.825, 0.05, -1.625), Color("bac6b5"))
	var bath_floor = Models.box(self, Vector3(3.55, 0.025, 4.05), Vector3(1.825, 0.05, -1.625), Color("abc6ca"))
	for tile in [living_floor, kitchen_floor, bath_floor]: Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	wall(Vector3(0.2, 0.72, 6.85), Vector3(-3.65, 0.36, -0.225))
	wall(Vector3(0.2, 0.72, 6.85), Vector3(3.65, 0.36, -0.225))
	wall(Vector3(7.5, 1.20, 0.2), Vector3(0, 0.60, -3.65))
	wall(Vector3(2.3, 0.42, 0.18), Vector3(-2.5, 0.21, 3.2))
	wall(Vector3(2.3, 0.42, 0.18), Vector3(2.5, 0.21, 3.2))
	# Living/back partition, one wide central doorway (x:[-1.4,1.4]).
	wall(Vector3(2.25, 0.66, 0.18), Vector3(-2.525, 0.33, 0.4))
	wall(Vector3(2.25, 0.66, 0.18), Vector3(2.525, 0.33, 0.4))
	# Kitchen/Bath spine.
	wall(Vector3(0.18, 0.65, 4.05), Vector3(0, 0.325, -1.625))
	APARTMENT_ART.build(self)

# A broad central hall with four distinct wings. The two openings in each side
# partition keep every room one turn from the hall; no hallway maze or door props.
func build_villa() -> void:
	var outside = Models.box(self, Vector3(13.5, 0.25, 24.9), Vector3(0, -0.20, 1.35), Color("465b58"))
	var floor_base = Models.box(self, Vector3(12.0, 0.16, 12.35), Vector3(0, -0.05, -2.975), Color("e8d8bf"))
	for part in [outside, floor_base]: Models.set_toon_profile(part, ToonMaterial.Profile.GROUND)
	for room in [
		[Vector3(-3.8, 0.05, 0.05), Vector3(4.35, 0.025, 6.25), Color("c6a87d")], # lounge
		[Vector3(3.8, 0.05, 0.05), Vector3(4.35, 0.025, 6.25), Color("a98d72")], # study
		[Vector3(-3.8, 0.05, -6.125), Vector3(4.35, 0.025, 5.95), Color("d2b998")], # music
		[Vector3(3.8, 0.05, -6.125), Vector3(4.35, 0.025, 5.95), Color("b4c7c1")], # bath
		[Vector3(0, 0.055, -2.95), Vector3(2.94, 0.028, 12.1), Color("d9c39e")], # hall
	]:
		var tile = Models.box(self, room[1], room[0], room[2])
		Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	wall(Vector3(12.2, 1.12, 0.2), Vector3(0, 0.56, -9.15))
	for x in [-6.05, 6.05]: wall(Vector3(0.2, 0.75, 12.35), Vector3(x, 0.375, -2.975))
	for x in [-3.8, 3.8]:
		wall(Vector3(4.5, 0.72, 0.18), Vector3(x, 0.36, -3.1))
		wall(Vector3(4.5, 0.65, 0.18), Vector3(x, 0.325, 3.2))
	for x in [-1.55, 1.55]:
		wall(Vector3(0.18, 0.7, 2.8), Vector3(x, 0.35, -7.75))
		wall(Vector3(0.18, 0.7, 4.25), Vector3(x, 0.35, -2.625))
		wall(Vector3(0.18, 0.7, 2.1), Vector3(x, 0.35, 2.15))
	VILLA_ART.build(self)

# A larger estate with a broad, unobstructed ceremonial hall. The rear gallery
# and music wing are reached from the hall rather than a four-box room grid.
func build_mansion() -> void:
	var outside = Models.box(self, Vector3(16.0, 0.25, 27.8), Vector3(0, -0.20, 1.55), Color("364d49"))
	var floor_base = Models.box(self, Vector3(14.4, 0.16, 13.8), Vector3(0, -0.05, -3.6), Color("e1d2b8"))
	for part in [outside, floor_base]: Models.set_toon_profile(part, ToonMaterial.Profile.GROUND)
	for zone in [
		[Vector3(0, 0.055, -3.6), Vector3(5.1, 0.027, 13.45), Color("d2bd98")], # grand hall
		[Vector3(-4.85, 0.055, -2.0), Vector3(4.55, 0.027, 8.7), Color("a58970")], # library/study
		[Vector3(4.85, 0.055, -2.0), Vector3(4.55, 0.027, 8.7), Color("c8b297")], # suite
		[Vector3(-4.85, 0.058, -8.55), Vector3(4.55, 0.027, 4.05), Color("b9a689")], # trophy gallery
		[Vector3(4.85, 0.058, -8.55), Vector3(4.55, 0.027, 4.05), Color("9f8c79")], # music room
	]:
		var tile = Models.box(self, zone[1], zone[0], zone[2])
		Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	var stone = Color("dfd3c0")
	wall(Vector3(14.65, 1.17, 0.24), Vector3(0, 0.585, -10.62), stone)
	for x in [-7.3, 7.3]: wall(Vector3(0.24, 0.82, 13.95), Vector3(x, 0.41, -3.6), stone)
	for x in [-4.88, 4.88]: wall(Vector3(4.85, 0.58, 0.2), Vector3(x, 0.29, 3.35), stone)
	# Only the two rear wings have a cross-wall; their doors open to the central hall.
	# The whole central axis and the side openings stay wide enough for heavy loot.
	wall(Vector3(4.7, 0.55, 0.18), Vector3(-4.9, 0.275, -6.15), stone)
	wall(Vector3(4.7, 0.55, 0.18), Vector3(4.9, 0.275, -7.15), stone)
	MANSION_ART.build(self)

# Symmetric research institute: a central spine connects three mirrored work
# bays to rear containment. Doors in each divider sit opposite one another, so
# every unique instrument has a deliberate station and a clear return route.
func build_laboratory() -> void:
	var outside = Models.box(self, Vector3(19.4, 0.25, 31.0), Vector3(0, -0.20, 1.75), Color("465d69"))
	var foundation = Models.box(self, Vector3(15.5, 0.16, 15.5), Vector3(0, -0.05, -4.0), Color("c6d7d6"))
	for part in [outside, foundation]: Models.set_toon_profile(part, ToonMaterial.Profile.GROUND)
	for zone in [
		[Vector3(0, 0.055, -4.0), Vector3(4.3, 0.027, 15.2), Color("b8d4d2")], # spine / airlock
		[Vector3(-4.95, 0.055, -4.0), Vector3(5.1, 0.027, 15.2), Color("a8bec8")], # west lab
		[Vector3(4.95, 0.055, -4.0), Vector3(5.1, 0.027, 15.2), Color("a8bec8")], # east lab
		[Vector3(0, 0.061, -9.65), Vector3(15.0, 0.026, 3.5), Color("91afb7")], # containment
	]:
		var tile = Models.box(self, zone[1], zone[0], zone[2])
		Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	var shell := Color("a8c1c4")
	wall(Vector3(15.5, 1.28, 0.23), Vector3(0, 0.64, -11.76), shell)
	for side in [-1.0, 1.0]:
		wall(Vector3(0.23, 0.82, 15.5), Vector3(side * 7.75, 0.41, -4.0), shell)
		wall(Vector3(6.0, 0.72, 0.19), Vector3(side * 4.75, 0.36, 3.74), shell)
		# Three matching doorways at the front, middle and rear station.
		for z in [2.70, -1.70, -5.60, -10.76]:
			wall(Vector3(0.18, 0.55, 2.0), Vector3(side * 2.2, 0.275, z), Color("8eb7ba"))
	LABORATORY_ART.build(self)

# The chapter-one finale is a public gallery, not another house. The long open
# central floor branches to themed wings; only the special exhibit has a narrow
# rear threshold. Decorative displays never carry physics colliders.
func build_museum() -> void:
	var outside = Models.box(self, Vector3(17.8, 0.25, 31.0), Vector3(0, -0.20, 1.75), Color("58646c"))
	var floor_base = Models.box(self, Vector3(16.2, 0.16, 15.55), Vector3(0, -0.05, -4.225), Color("e6e4db"))
	for part in [outside, floor_base]: Models.set_toon_profile(part, ToonMaterial.Profile.GROUND)
	for zone in [
		[Vector3(0, 0.055, -3.2), Vector3(6.0, 0.027, 9.7), Color("ece9de")], # grand gallery
		[Vector3(0, 0.059, -10.2), Vector3(6.0, 0.027, 3.5), Color("b9d8d9")], # special exhibit
		[Vector3(-5.54, 0.055, -5.7), Vector3(4.85, 0.027, 11.3), Color("d3c09a")], # ancient
		[Vector3(5.54, 0.055, -5.7), Vector3(4.85, 0.027, 11.3), Color("becbd1")], # sculpture
		[Vector3(-5.54, 0.059, 1.78), Vector3(4.85, 0.027, 3.45), Color("8e9ca4")], # security/storage
		[Vector3(2.8, 0.059, 1.78), Vector3(9.95, 0.027, 3.45), Color("ded8c8")], # entry hall
	]:
		var tile = Models.box(self, zone[1], zone[0], zone[2])
		Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	var stone = Color("d8dce0")
	wall(Vector3(16.5, 0.88, 0.26), Vector3(0, 0.44, -12.12), stone)
	for x in [-8.2, 8.2]: wall(Vector3(0.26, 0.88, 15.65), Vector3(x, 0.44, -4.23), stone)
	for x in [-5.37, 5.37]: wall(Vector3(5.7, 0.65, 0.24), Vector3(x, 0.325, 3.6), stone)
	# A broad ceremonial opening leads to the strange rear exhibit. Side wings
	# stay open to the central gallery, with no maze-like internal corridors.
	for x in [-5.3, 5.3]: wall(Vector3(4.5, 0.58, 0.20), Vector3(x, 0.29, -8.45), stone)
	for x in [-2.0, 2.0]: wall(Vector3(0.2, 0.62, 1.8), Vector3(x, 0.31, -11.14), stone)
	MUSEUM_ART.build(self)

# First commercial map: one broad sales floor, arcade wing with no dividing wall,
# and a shallow stock strip across the rear. Checkout is furniture, not a room.
func build_electronics() -> void:
	var outside = Models.box(self, Vector3(14.4, 0.25, 22.0), Vector3(0, -0.20, 4.0), Color("526169"))
	var floor_base = Models.box(self, Vector3(13.1, 0.16, 8.45), Vector3(0, -0.05, -0.975), Color("e3e5df"))
	for part in [outside, floor_base]: Models.set_toon_profile(part, ToonMaterial.Profile.GROUND)
	for zone in [
		[Vector3(-4.3, 0.052, -0.07), Vector3(4.3, 0.026, 5.78), Color("555677")], # arcade
		[Vector3(2.05, 0.051, -0.07), Vector3(8.35, 0.026, 5.78), Color("d9e2e1")], # sales
		[Vector3(0, 0.054, -3.92), Vector3(12.75, 0.027, 2.42), Color("899ba3")], # stock
		[Vector3(0, 0.06, 2.65), Vector3(12.7, 0.026, 1.03), Color("b8c8c9")], # entry
	]:
		var tile = Models.box(self, zone[1], zone[0], zone[2])
		Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	wall(Vector3(13.3, 1.32, 0.2), Vector3(0, 0.66, -5.2), Color("bacbd1"))
	for x in [-6.6, 6.6]: wall(Vector3(0.2, 0.72, 8.55), Vector3(x, 0.36, -0.975), Color("bacbd1"))
	# Wide stock access at x [-1.6, 1.6]; the rest reads as one open store.
	for x in [-4.1, 4.1]: wall(Vector3(5.0, 0.54, 0.18), Vector3(x, 0.27, -2.67), Color("9cabb0"))
	# Storefront glazing flanks the central loading entrance.
	for x in [-4.1, 4.1]: wall(Vector3(5.0, 0.43, 0.18), Vector3(x, 0.215, 3.27), Color("7796a2"))
	ELECTRONICS_ART.build(self)

# Detached single-storey cutaway. The five-room split stays physically readable;
# garage/driveway and the asymmetrical furniture do the visual identity work.
func build_house() -> void:
	var outside = Models.box(self, Vector3(13.0, 0.25, 21.4), Vector3(0, -0.20, -0.1), Color("426b53"))
	var floor_base = Models.box(self, Vector3(10, 0.16, 10.95), Vector3(0, -0.05, -2.275), Color("d4c6a9"))
	Models.set_toon_profile(outside, ToonMaterial.Profile.GROUND)
	Models.set_toon_profile(floor_base, ToonMaterial.Profile.GROUND)
	var living_floor = Models.box(self, Vector3(6.45, 0.025, 2.8), Vector3(1.825, 0.05, 1.8), Color("dcc39d"))
	var garage_floor = Models.box(self, Vector3(3.65, 0.025, 4.7), Vector3(-3.225, 0.055, 0.75), Color("7b8e9a"))
	var bath_floor = Models.box(self, Vector3(4.95, 0.025, 6.15), Vector3(-2.575, 0.05, -4.675), Color("abc3c1"))
	var kitchen_floor = Models.box(self, Vector3(4.95, 0.025, 2.0), Vector3(2.575, 0.05, -0.6), Color("bdc9b7"))
	var bedroom_floor = Models.box(self, Vector3(4.95, 0.025, 6.15), Vector3(2.575, 0.05, -4.675), Color("d9c2a5"))
	for tile in [living_floor, garage_floor, bath_floor, kitchen_floor, bedroom_floor]: Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	wall(Vector3(10.25, 1.13, 0.2), Vector3(0, 0.565, -7.75))
	wall(Vector3(0.2, 0.72, 10.95), Vector3(-5.05, 0.36, -2.275))
	wall(Vector3(0.2, 0.72, 10.95), Vector3(5.05, 0.36, -2.275))
	wall(Vector3(3.7, 0.42, 0.18), Vector3(-3.2, 0.21, 3.2))
	wall(Vector3(3.7, 0.42, 0.18), Vector3(3.2, 0.21, 3.2))
	# Open the space directly below the kitchen into the living/entrance area.
	# Central spine: Garage/Bath column vs Kitchen/Bedroom column — the route choice.
	wall(Vector3(0.18, 0.65, 8.15), Vector3(0, 0.325, -3.675))
	# Left column front/back divider (Garage near / Bath far), doorway over the left lane.
	wall(Vector3(3.65, 0.92, 0.18), Vector3(-3.225, 0.46, -1.6))
	# The divider above the kitchen keeps the sofa lounge a distinct room.
	wall(Vector3(3.65, 0.92, 0.18), Vector3(3.225, 0.46, -1.6))
	HOUSE_ART.build(self)

func house_solid(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> void:
	Models.box(parent, size, at, color)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	body.position = at
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	parent.add_child(body)
	walls.append(Rect2(Vector2(at.x - size.x / 2, at.z - size.z / 2), Vector2(size.x, size.z)))

# Chapter 2 cutaway tomb, laid out from the Final Job time budget (see Balance
# "pyramid"). The left alcove holds Sarcophagus and Anubis. Chests line the
# central antechamber; Mask and Scarab flank the Throne at the very back, with the
# floor mosaic before it. The right wing remains the Hall of Gods. Breach gap
# (x:[-1.35,1.35]), access lanes (x=±1.15)
# and van load point retain the tested footprint. The exterior is visual-only
# sandstone architecture, causeway and desert; the sun skips the interior layer.
const PYRAMID_TIERS = [Rect2(-5.15, -0.7, 10.3, 4.0), Rect2(-4.0, -4.1, 8.0, 3.5), Rect2(-2.0, -5.3, 4.0, 1.3)]
# Dracula's Castle keeps one rectangular keep; its interior is the whole walled block.
const CASTLE_ROOMS = [Rect2(-5.15, -4.05, 10.3, 7.35)]
const INTERIOR_LAYER = 2
const TORCH_RANGE = 3.3
var torches: Array = []
var fill_lights: Array = []
var tongue_flames = false
var wall_top_lift = 0.25
var halo_alpha = 0.55
var contact_blobs: Array = []
static var _blob_material: StandardMaterial3D
var interior_rects: Array = []
var interior_state: Dictionary = {}
var torch_time = 0.0
static var _halo_materials: Dictionary = {}
static var _flame_materials: Dictionary = {}

func build_pyramid() -> void:
	PyramidArt.build(self)

# Brazier (floor) or sconce (on a wall top): layered unshaded flame, additive halo and a
# warm OmniLight3D. Flicker is animated in _process; no shadows, so it stays mobile-cheap.
# emit=false keeps the flame and fake glow but no real light (cheap filler torches);
# reach>0 makes a short accent light that dies fast; spot=true aims a wall sconce at the floor.
func torch(at: Vector3, sconce: bool, color: Color = Color("ffb057"), energy: float = -1.0, reach: float = -1.0, emit: bool = true, glow: float = 1.3, spot: bool = false) -> void:
	var base_y = 0.62 if sconce else 0.0
	if sconce:
		var bracket = Models.box(self, Vector3(0.14, 0.1, 0.14), at + Vector3.UP * 0.7, Color("3a2b24"))
		Models.set_toon_profile(bracket, ToonMaterial.Profile.PROP)
	else:
		var post = Models.cylinder(self, 0.1, 0.5, at + Vector3.UP * 0.25, Color("3a2b24"))
		Models.set_toon_profile(post, ToonMaterial.Profile.PROP)
	var bowl = Models.cylinder(self, 0.17, 0.1, at + Vector3.UP * (base_y + 0.53), Color("5a4632"))
	Models.set_toon_profile(bowl, ToonMaterial.Profile.PROP)
	var flame_root = Node3D.new()
	flame_root.position = at + Vector3.UP * (base_y + 0.62)
	add_child(flame_root)
	var materials = flame_materials(color)
	var flames: Array = []
	for layer in range(3):
		var mesh: Mesh
		if tongue_flames and layer < 2:
			# Tapered flame tongue instead of a glowing bulb.
			var cone = CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = [0.1, 0.065][layer]
			cone.height = [0.36, 0.26][layer]
			cone.radial_segments = 6
			mesh = cone
		else:
			var sphere = SphereMesh.new()
			sphere.radial_segments = 10
			sphere.rings = 6
			mesh = sphere
		var flame = MeshInstance3D.new()
		flame.mesh = mesh
		flame.material_override = materials[layer]
		if tongue_flames:
			flame.scale = [Vector3.ONE, Vector3.ONE, Vector3(0.07, 0.1, 0.07)][layer]
			flame.position = Vector3(0, [0.16, 0.12, 0.05][layer], 0)
		else:
			flame.scale = [Vector3(0.24, 0.38, 0.24), Vector3(0.16, 0.28, 0.16), Vector3(0.08, 0.16, 0.08)][layer]
			flame.position = Vector3(0, [0.1, 0.1, 0.07][layer], 0)
		flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flame_root.add_child(flame)
		flames.append(flame)
	var halo = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(glow, glow)
	halo.mesh = quad
	halo.material_override = halo_material(color, halo_alpha)
	halo.position = Vector3(0, 0.12, 0)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	flame_root.add_child(halo)
	var outdoor = not inside(at)
	var light: Light3D = null
	if emit:
		if spot:
			var spot_light = SpotLight3D.new()
			spot_light.spot_range = reach if reach > 0.0 else TORCH_RANGE
			spot_light.spot_angle = 55.0
			spot_light.spot_attenuation = 1.2
			light = spot_light
		else:
			var omni = OmniLight3D.new()
			omni.omni_range = reach if reach > 0.0 else TORCH_RANGE
			omni.omni_attenuation = 2.0 if reach > 0.0 else 0.9
			light = omni
		light.light_color = color
		# Interior torches light only the interior layer, so they never wash out the
		# exterior; torches standing outside the walls light both.
		light.light_energy = energy if energy > 0.0 else (1.5 if outdoor else 3.2)
		light.light_cull_mask = 0xFFFFF if outdoor else INTERIOR_LAYER
		light.shadow_enabled = false
		light.position = Vector3(0, 0.35, 0)
		flame_root.add_child(light)
		if spot: light.look_at(light.global_position + Vector3(-side_sign(at.x) * 0.55, -1.0, 0.35).normalized(), Vector3(0, 0, -1))
	var scales: Array = flames.map(func(flame): return flame.scale)
	# Castle torches flicker slower and each at its own pace (never in sync).
	var speed = 7.0 if not tongue_flames else 3.6 + fmod(float(torches.size()) * 0.73, 1.6)
	torches.append({"light": light, "base": light.light_energy if light != null else 0.0, "depth": 0.4 if reach > 0.0 else 1.0, "flames": flames, "scales": scales, "halo": halo, "phase": float(torches.size()) * 1.7, "speed": speed})

# Flame and halo materials are shared per light colour: the default warm torch keeps its
# original look; tinted rooms (gold Treasury, red Great Hall, cold Crypt) derive theirs.
static func flame_materials(tint: Color = Color("ffb057")) -> Array:
	var key = tint.to_html()
	if not _flame_materials.has(key):
		var colors = [Color(1.0, 0.45, 0.12, 0.85), Color(1.0, 0.72, 0.22), Color(1.0, 0.95, 0.7)]
		if tint != Color("ffb057"): colors = [Color(tint.r, tint.g, tint.b, 0.85), tint.lightened(0.35), tint.lightened(0.75)]
		var materials: Array = []
		for color in colors:
			var material = StandardMaterial3D.new()
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.albedo_color = color
			if color.a < 1.0: material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			materials.append(material)
		_flame_materials[key] = materials
	return _flame_materials[key]

static func halo_material(tint: Color = Color("ffb057"), alpha: float = 0.55) -> StandardMaterial3D:
	var key = tint.to_html() + str(alpha)
	if not _halo_materials.has(key):
		var gradient = Gradient.new()
		var inner = Color(1.0, 0.62, 0.25, alpha) if tint == Color("ffb057") else Color(tint.r, tint.g, tint.b, alpha)
		gradient.set_color(0, inner)
		gradient.set_color(1, Color(inner.r, inner.g * 0.75, inner.b * 0.5, 0.0))
		var texture = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 64
		texture.height = 64
		var material = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		material.albedo_texture = texture
		_halo_materials[key] = material
	return _halo_materials[key]

func inside(point: Vector3) -> bool:
	for rect in interior_rects:
		if rect.has_point(Vector2(point.x, point.z)): return true
	return false

static func set_layers(node: Node, mask: int) -> void:
	if node is VisualInstance3D and not node is Light3D: node.layers = mask
	for child in node.get_children(): set_layers(child, mask)

# Static interior geometry goes on the interior layer once; the thief and each loot piece
# switch layers only when they cross the pyramid edge, so the sun never lights the tomb.
func apply_interior_layers() -> void:
	for child in get_children():
		if child.has_meta("exterior"): continue
		if child is VisualInstance3D and not child is Light3D and inside(child.global_position):
			child.layers = INTERIOR_LAYER
		elif child is Node3D and child.get_child_count() > 0 and child is not LootItem and child != player and child != van and inside(child.global_position):
			set_layers(child, INTERIOR_LAYER)
	update_dynamic_layers()

func update_dynamic_layers() -> void:
	var movers: Array = [player]
	movers.append_array(items)
	for node in movers:
		if not is_instance_valid(node): continue
		var is_inside = inside(node.global_position)
		if interior_state.get(node, null) != is_inside:
			interior_state[node] = is_inside
			set_layers(node, INTERIOR_LAYER if is_inside else 1)

func _process(delta: float) -> void:
	if torches.is_empty(): return
	torch_time += delta
	for entry in torches:
		var t: float = torch_time * entry.speed + entry.phase
		var flicker = 0.86 + 0.08 * sin(t) + 0.05 * sin(t * 2.3 + 1.1) + 0.03 * sin(t * 5.7)
		if entry.light != null: entry.light.light_energy = entry.base * lerpf(1.0, flicker, entry.depth)
		var sway = Vector3(1.0 + 0.06 * sin(t * 1.9), flicker, 1.0 + 0.06 * cos(t * 1.6))
		for i in range(entry.flames.size()):
			entry.flames[i].scale = entry.scales[i] * sway
		entry.halo.scale = Vector3.ONE * (0.92 + 0.12 * flicker)
	update_dynamic_layers()
	update_contact_blobs()

# Dracula's Castle (Chapter 2), after the approved floor plan and the same backward
# budget as Pyramid: a compact keep, no maze. GREAT HALL runs from the breach to the
# THRONE ROOM along one continuous red carpet; TREASURY opens left, CRYPT right. The
# Throne on its three-step dais is the focal point; the Coffin waits in the Crypt next to
# the breach so the post-alarm run after the Throne is one short trip. Each room has its
# own light: red Great Hall / Throne Room, gold Treasury, cold violet Crypt. Breach gap,
# lanes (x=±1.15) and the van load point match the shared footprint.
const CASTLE_AMBIENT = 2.4
const CASTLE_MOON = 0.55
const HALL_LIGHT = Color("ffc07a")
const THRONE_LIGHT = Color("ffb866")
const TREASURY_LIGHT = Color("ffd095")
const CRYPT_LIGHT = Color("a9b2e8")

func fill_light(at: Vector3, color: Color, reach: float, energy: float) -> void:
	var fill = OmniLight3D.new()
	fill.light_color = color
	fill.omni_range = reach
	fill.omni_attenuation = 1.0
	fill.light_energy = energy
	fill.light_cull_mask = INTERIOR_LAYER
	fill.shadow_enabled = false
	fill.position = at
	add_child(fill)
	fill_lights.append(fill)

func light_hero_loot(types: Array) -> void:
	for item in items:
		if item.data.type_id not in types: continue
		var glow = OmniLight3D.new()
		glow.light_color = Color("ffe8cc")
		glow.omni_range = 1.8
		glow.omni_attenuation = 2.0
		glow.light_energy = 0.7
		glow.light_cull_mask = INTERIOR_LAYER
		glow.shadow_enabled = false
		glow.position = Vector3(0, 1.4, 0.35)
		item.add_child(glow)

# Soft blob contact shadow: an unshaded, transparent gradient plane, no collision.
static func blob_material() -> StandardMaterial3D:
	if _blob_material == null:
		var gradient = Gradient.new()
		gradient.set_color(0, Color(0.03, 0.04, 0.08, 0.5))
		gradient.set_color(1, Color(0.03, 0.04, 0.08, 0.0))
		var texture = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 64
		texture.height = 64
		_blob_material = StandardMaterial3D.new()
		_blob_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_blob_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_blob_material.albedo_texture = texture
	return _blob_material

func contact_blob(size: Vector2, at: Vector3) -> MeshInstance3D:
	var plane = PlaneMesh.new()
	plane.size = size
	var blob = MeshInstance3D.new()
	blob.mesh = plane
	blob.material_override = blob_material()
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	blob.position = at
	add_child(blob)
	return blob

# Blobs follow their loot while it rests on the floor and vanish once it is lifted.
func ground_loot(types: Dictionary) -> void:
	for item in items:
		if not types.has(item.data.type_id): continue
		var entry: Array = types[item.data.type_id]
		var blob = contact_blob(entry[0], Vector3(item.position.x, entry[1], item.position.z))
		contact_blobs.append([blob, item, entry[1]])

func update_contact_blobs() -> void:
	for entry in contact_blobs:
		var item: LootItem = entry[1]
		entry[0].visible = is_instance_valid(item) and item.state in [LootItem.State.AVAILABLE, LootItem.State.PICKING_UP]
		if entry[0].visible: entry[0].position = Vector3(item.global_position.x, entry[2], item.global_position.z)

func build_castle() -> void:
	tongue_flames = true
	halo_alpha = 0.32
	wall_top_lift = 0.12
	CASTLE_SURROUNDINGS.build(self)
	var outside = Models.box(self, Vector3(13, 0.25, 15), Vector3(0, -0.20, 1.6), Color("34425a"))
	outside.set_meta("exterior", true)
	Models.set_toon_profile(outside, ToonMaterial.Profile.GROUND)
	var path = Models.box(self, Vector3(2.6, 0.03, 3.4), Vector3(0, -0.06, 4.9), Color("4a4f5e"))
	path.set_meta("exterior", true)
	Models.set_toon_profile(path, ToonMaterial.Profile.GROUND)
	var hall_floor = Models.box(self, Vector3(3.1, 0.16, 4.3), Vector3(0, -0.05, 1.1), Color("9a948e"))
	var treasury_floor = Models.box(self, Vector3(3.5, 0.16, 4.3), Vector3(-3.3, -0.05, 1.1), Color("a8926a"))
	var crypt_floor = Models.box(self, Vector3(3.5, 0.16, 4.3), Vector3(3.3, -0.05, 1.1), Color("5c6076"))
	var throne_floor = Models.box(self, Vector3(10.1, 0.16, 2.9), Vector3(0, -0.05, -2.45), Color("9a8678"))
	var treasury_rug = Models.box(self, Vector3(2.4, 0.03, 2.8), Vector3(-3.1, 0.07, 1.15), Color("6a1e2a"))
	var crypt_slab = Models.box(self, Vector3(1.3, 0.08, 2.4), Vector3(2.75, 0.08, 2.0), Color("3c3f52"))
	for tile in [hall_floor, treasury_floor, crypt_floor, throne_floor, treasury_rug, crypt_slab]: Models.set_toon_profile(tile, ToonMaterial.Profile.GROUND)
	# One continuous red carpet with gold trim, from outside the breach to the throne steps.
	var carpet = Models.box(self, Vector3(1.5, 0.03, 5.3), Vector3(0, 0.075, 1.05), Color("761824"))
	for x in [-0.8, 0.8]:
		var trim = Models.box(self, Vector3(0.1, 0.035, 5.3), Vector3(x, 0.075, 1.05), Color("d9a13a"))
		Models.set_toon_profile(trim, ToonMaterial.Profile.GROUND)
	Models.set_toon_profile(carpet, ToonMaterial.Profile.GROUND)
	# Three-step throne dais, the focal point of the map.
	for step in range(3):
		var tread = Models.box(self, Vector3(2.9 - step * 0.6, 0.08, 2.2 - step * 0.4), Vector3(0, 0.08 + step * 0.08, -2.35 - step * 0.1), Color("7c7686") if step < 2 else Color("4e2a36"))
		var edge = Models.box(self, Vector3(2.95 - step * 0.6, 0.03, 0.06), Vector3(0, 0.125 + step * 0.08, -1.25 - step * 0.3), Color("d9a13a"))
		Models.set_toon_profile(tread, ToonMaterial.Profile.GROUND)
		Models.set_toon_profile(edge, ToonMaterial.Profile.GROUND)
	var stone = Color("7f869e")
	# Thick outer walls, taller than the partitions, so the keep reads heavy.
	wall(Vector3(3.7, 0.9, 0.44), Vector3(-3.2, 0.45, 3.25), stone)
	wall(Vector3(3.7, 0.9, 0.44), Vector3(3.2, 0.45, 3.25), stone)
	wall(Vector3(0.44, 1.0, 7.7), Vector3(-5.1, 0.5, -0.37), stone)
	wall(Vector3(0.44, 1.0, 7.7), Vector3(5.1, 0.5, -0.37), stone)
	wall(Vector3(10.64, 1.0, 0.44), Vector3(0, 0.5, -4.0), stone)
	# Throne Room front wall, open over the Great Hall (x:[-1.55,1.55]).
	wall(Vector3(3.45, 0.8, 0.3), Vector3(-3.275, 0.4, -1.0), stone)
	wall(Vector3(3.45, 0.8, 0.3), Vector3(3.275, 0.4, -1.0), stone)
	# Great Hall walls with one wide doorway into each wing (z:[0.0,2.3]).
	for x in [-1.55, 1.55]:
		wall(Vector3(0.26, 0.8, 1.0), Vector3(x, 0.4, -0.5), stone)
		wall(Vector3(0.26, 0.8, 0.9), Vector3(x, 0.4, 2.75), stone)
	# Battlements and massive corner towers (outside the play area).
	var merlon = Color("959cb4")
	for i in range(11):
		var m = Models.box(self, Vector3(0.45, 0.24, 0.44), Vector3(-5.0 + i * 1.0, 1.12, -4.0), merlon)
		Models.set_toon_profile(m, ToonMaterial.Profile.PROP)
	for i in range(7):
		for side in [-1, 1]:
			var m = Models.box(self, Vector3(0.44, 0.24, 0.45), Vector3(side * 5.1, 1.12, -3.4 + i * 1.0), merlon)
			Models.set_toon_profile(m, ToonMaterial.Profile.PROP)
	for i in range(3):
		for side in [-1, 1]:
			var m = Models.box(self, Vector3(0.45, 0.24, 0.44), Vector3(side * (2.8 + i * 0.95), 1.02, 3.25), merlon)
			Models.set_toon_profile(m, ToonMaterial.Profile.PROP)
	for at in [Vector3(-5.3, 0, -4.2), Vector3(5.3, 0, -4.2), Vector3(-5.3, 0, 3.45), Vector3(5.3, 0, 3.45)]:
		var tower = Models.box(self, Vector3(1.3, 1.7, 1.3), at + Vector3.UP * 0.85, Color("4e546a"))
		var crown_ring = Models.box(self, Vector3(1.45, 0.2, 1.45), at + Vector3.UP * 1.8, Color("5f667e"))
		var roof = cone_part(at + Vector3.UP * 2.35, 0.9, 1.0, Color("3b2d55"))
		var flag = Models.box(self, Vector3(0.04, 0.55, 0.38), at + Vector3(-side_sign(at.x) * 0.67, 1.1, 0), Color("9e1f2a"))
		for part in [tower, crown_ring, roof, flag]:
			part.set_meta("exterior", true)
			Models.set_toon_profile(part, ToonMaterial.Profile.PROP)
	# Forced entry: squat gate towers with gargoyles, a smashed gate, bent portcullis bars, rubble.
	for x in [-1.95, 1.95]:
		var gate_tower = Models.box(self, Vector3(0.8, 1.35, 0.8), Vector3(x, 0.68, 3.55), Color("737a92"))
		var gate_cap = Models.box(self, Vector3(0.95, 0.16, 0.95), Vector3(x, 1.42, 3.55), merlon)
		for part in [gate_tower, gate_cap]:
			part.set_meta("exterior", true)
			Models.set_toon_profile(part, ToonMaterial.Profile.PROP)
		gargoyle_decor(Vector3(x, 1.5, 3.55), 1.3, true)
	for side in [-1, 1]:
		var door = Models.box(self, Vector3(0.95, 0.08, 0.55), Vector3(side * 0.95, 0.06, 3.85), Color("4a2e1e"))
		door.rotation = Vector3(0, side * 0.5, side * 0.12)
		var band = Models.box(self, Vector3(0.97, 0.09, 0.06), Vector3(side * 0.95, 0.07, 3.85), Color("2a2a30"))
		band.rotation = door.rotation
		for part in [door, band]:
			part.set_meta("exterior", true)
			Models.set_toon_profile(part, ToonMaterial.Profile.PROP)
		for i in range(3):
			var bar = Models.box(self, Vector3(0.05, 0.75, 0.05), Vector3(side * (1.22 - i * 0.1), 0.38, 3.42), Color("2a2a30"))
			bar.rotation.z = side * (0.25 + 0.2 * i)
			bar.set_meta("exterior", true)
			Models.set_toon_profile(bar, ToonMaterial.Profile.PROP)
	for x in [-1.55, 1.55]:
		for i in range(8):
			var size = 0.42 - (i % 4) * 0.06
			var rubble = Models.box(self, Vector3(size, size * 0.7, size * 0.85), Vector3(x + signf(x) * (0.14 * (i % 4) + 0.1), size * 0.35 + (0.12 if i < 2 else 0.0), 3.5 + (i / 2) * 0.2), Color("6e7488").darkened(0.07 * (i % 3)))
			rubble.rotation = Vector3(0.2 * (i % 2), 0.45 * (i + 1), 0.15 * ((i + 1) % 2))
			rubble.set_meta("exterior", true)
			Models.set_toon_profile(rubble, ToonMaterial.Profile.PROP)
	# Throne Chamber identity: bat banners flanking the throne and on the side walls, two
	# gargoyles crouched on the top wall crest (architecture, never mistaken for loot).
	for at in [Vector3(-1.35, 0.6, -3.76), Vector3(1.35, 0.6, -3.76), Vector3(-3.6, 0.6, -3.76), Vector3(3.6, 0.6, -3.76), Vector3(-4.86, 0.6, 1.1), Vector3(4.86, 0.6, 1.1)]:
		banner(at, absf(at.x) > 4.5)
	for x in [-2.3, 2.3]:
		gargoyle_decor(Vector3(x, 1.0, -4.0), 1.5, false)
	var window = Models.box(self, Vector3(0.45, 0.5, 0.05), Vector3(0, 0.62, -3.77), Color("d0243a"))
	var window_arch = Models.ball(self, Vector3(0.45, 0.28, 0.05), Vector3(0, 0.88, -3.77), Color("d0243a"))
	for part in [window, window_arch]: Models.set_toon_profile(part, ToonMaterial.Profile.MARKER)
	# Great Hall: two suits of armour on the edges.
	for x in [-1.3, 1.3]:
		armor(Vector3(x, 0, -0.35))
	# Crypt: a few skulls and candle niches (no collision).
	for at in [Vector3(4.55, 0.12, 2.75), Vector3(4.4, 0.12, -0.45)]:
		var skull = Models.box(self, Vector3(0.22, 0.2, 0.22), at, Color("e8e2d0"))
		Models.set_toon_profile(skull, ToonMaterial.Profile.PROP)
	for z in [0.2, 2.2]:
		var niche = Models.box(self, Vector3(0.06, 0.5, 0.42), Vector3(4.87, 0.32, z), Color("221a36"))
		Models.set_toon_profile(niche, ToonMaterial.Profile.PROP)
	var cross_post = Models.box(self, Vector3(0.08, 0.7, 0.14), Vector3(4.84, 0.5, 1.2), Color("8e97b0"))
	var cross_arm = Models.box(self, Vector3(0.08, 0.12, 0.46), Vector3(4.84, 0.68, 1.2), Color("8e97b0"))
	for part in [cross_post, cross_arm]: Models.set_toon_profile(part, ToonMaterial.Profile.PROP)
	# Lighting Pass V1: cold night everywhere, local warmth from a few amber torches,
	# identity from materials. Each room has one broad faint fill (never readable as a
	# source); only 10 torches emit short accent light, the rest are flame + small glow.
	fill_light(Vector3(0, 1.9, 1.1), Color("b8b6b4"), 4.6, 0.8)
	fill_light(Vector3(0, 1.9, -2.45), Color("d8a684"), 6.6, 1.3)
	fill_light(Vector3(-3.3, 1.9, 1.1), Color("d9c396"), 4.6, 1.15)
	fill_light(Vector3(3.3, 1.9, 1.1), Color("8f97bf"), 4.6, 1.2)
	for at in [Vector3(-4.6, 0, 2.8), Vector3(-4.6, 0, -0.6), Vector3(-1.85, 0, 2.8), Vector3(-1.85, 0, -0.6)]:
		var accent = at in [Vector3(-1.85, 0, 2.8), Vector3(-4.6, 0, -0.6)]
		torch(at, false, TREASURY_LIGHT, 1.0, 2.8, accent, 0.55)
	# Crypt: cold candles, plus one warm flame by the Coffin for warm/cool contrast.
	for at in [Vector3(4.6, 0, 2.8), Vector3(4.6, 0, -0.6), Vector3(1.85, 0, -0.6)]:
		torch(at, false, CRYPT_LIGHT, 0.8, 2.6, at == Vector3(4.6, 0, -0.6), 0.5)
	torch(Vector3(1.85, 0, 2.8), false, THRONE_LIGHT, 0.9, 2.6, true, 0.55)
	for at in [Vector3(-1.3, 0, -3.45), Vector3(1.3, 0, -3.45), Vector3(-2.4, 0, -1.45), Vector3(2.4, 0, -1.45), Vector3(-4.5, 0, -3.45), Vector3(4.5, 0, -3.45)]:
		torch(at, false, THRONE_LIGHT, 1.2, 3.0, absf(at.x) < 2.0, 0.6)
	for at in [Vector3(-1.45, 0, -0.8), Vector3(1.45, 0, -0.8)]:
		torch(at, true, HALL_LIGHT, 1.6, 3.0, true, 0.5, true)
	for at in [Vector3(-2.6, 0, 4.0), Vector3(2.6, 0, 4.0)]:
		torch(at, false, HALL_LIGHT, 1.1, 3.0, true, 0.6)
	# Night forest around the keep.
	for at in [Vector3(-5.5, 0, -2.0), Vector3(5.5, 0, -1.2), Vector3(-5.1, 0, 5.2), Vector3(-3.8, 0, 7.4), Vector3(5.0, 0, 5.4), Vector3(4.1, 0, 7.6), Vector3(-5.6, 0, 1.5), Vector3(5.6, 0, 1.9)]:
		pine(at)
	for at in [Vector3(-3.4, 0.12, 5.0), Vector3(-2.3, 0.1, 6.6), Vector3(3.4, 0.13, 4.8), Vector3(2.6, 0.1, 7.0), Vector3(-4.2, 0.12, 4.1)]:
		var rock = Models.box(self, Vector3(0.45, 0.26, 0.4), at, Color("5a5f74"))
		rock.rotation.y = at.x
		rock.set_meta("exterior", true)
		Models.set_toon_profile(rock, ToonMaterial.Profile.PROP)

static func side_sign(x: float) -> float:
	return 1.0 if x > 0 else -1.0

func cone_part(at: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var cone = CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = radius
	cone.height = height
	cone.radial_segments = 4
	var node = MeshInstance3D.new()
	node.mesh = cone
	node.material_override = Models.material(color)
	node.position = at
	node.rotation_degrees.y = 45
	add_child(node)
	return node

func banner(at: Vector3, side_wall: bool) -> void:
	var size = Vector3(0.05, 0.62, 0.4) if side_wall else Vector3(0.4, 0.62, 0.05)
	var cloth = Models.box(self, size, at, Color("9e1f2a"))
	var tip = Models.box(self, Vector3(size.x, 0.1, size.z) * Vector3(1, 1, 1), at + Vector3.DOWN * 0.34, Color("7a1620"))
	var inward = Vector3(-side_sign(at.x) * 0.03, 0, 0) if side_wall else Vector3(0, 0, 0.03 if at.z < 0 else -0.03)
	var wing = Vector3(0.05, 0.07, 0.28) if side_wall else Vector3(0.28, 0.07, 0.05)
	var bat = Models.box(self, wing, at + inward + Vector3.UP * 0.06, Color("f2c14e"))
	for part in [cloth, tip, bat]: Models.set_toon_profile(part, ToonMaterial.Profile.PROP)

func gargoyle_decor(at: Vector3, size: float, exterior: bool) -> void:
	var dark = Color("3a3f55")
	var parts: Array = []
	parts.append(Models.box(self, Vector3(0.26, 0.26, 0.24) * size, at + Vector3.UP * 0.13 * size, dark))
	parts.append(Models.box(self, Vector3(0.18, 0.16, 0.18) * size, at + Vector3(0, 0.34, 0.06) * size, dark))
	for side in [-1, 1]:
		var wing = Models.box(self, Vector3(0.24, 0.22, 0.04) * size, at + Vector3(side * 0.2, 0.28, -0.06) * size, dark)
		wing.rotation.z = side * 0.4
		parts.append(wing)
		parts.append(Models.box(self, Vector3(0.04, 0.08, 0.04) * size, at + Vector3(side * 0.05, 0.46, 0.06) * size, dark))
	for part in parts:
		if exterior: part.set_meta("exterior", true)
		Models.set_toon_profile(part, ToonMaterial.Profile.PROP)

func armor(at: Vector3) -> void:
	var steel = Color("a9b0c4")
	var parts = [
		Models.box(self, Vector3(0.3, 0.06, 0.26), at + Vector3.UP * 0.03, Color("3a3f55")),
		Models.box(self, Vector3(0.2, 0.36, 0.14), at + Vector3.UP * 0.24, steel),
		Models.box(self, Vector3(0.26, 0.3, 0.16), at + Vector3.UP * 0.55, steel),
		Models.box(self, Vector3(0.16, 0.16, 0.16), at + Vector3.UP * 0.8, steel),
		Models.box(self, Vector3(0.12, 0.03, 0.02), at + Vector3(0, 0.8, 0.085), Color("15101c")),
		Models.box(self, Vector3(0.04, 0.2, 0.04), at + Vector3(0, 0.98, 0), Color("9e1f2a")),
		Models.box(self, Vector3(0.03, 1.0, 0.03), at + Vector3(side_sign(at.x) * -0.18, 0.5, 0.05), Color("5a4632")),
	]
	for part in parts: Models.set_toon_profile(part, ToonMaterial.Profile.PROP)

func pine(at: Vector3) -> void:
	var trunk = Models.cylinder(self, 0.08, 0.4, at + Vector3.UP * 0.2, Color("4a3426"))
	trunk.set_meta("exterior", true)
	Models.set_toon_profile(trunk, ToonMaterial.Profile.PROP)
	for i in range(3):
		var cone_mesh = CylinderMesh.new()
		cone_mesh.top_radius = 0.0
		cone_mesh.bottom_radius = 0.55 - i * 0.13
		cone_mesh.height = 0.6
		cone_mesh.radial_segments = 6
		var cone = MeshInstance3D.new()
		cone.mesh = cone_mesh
		cone.material_override = Models.material(Color("1f5a4a").darkened(i * 0.05))
		cone.position = at + Vector3.UP * (0.55 + i * 0.35)
		cone.set_meta("exterior", true)
		add_child(cone)
		Models.set_toon_profile(cone, ToonMaterial.Profile.PROP)

func place_room_labels(location: String) -> void:
	var rooms: Array = []
	match location:
		"apartment":
			rooms = [["LIVING", Vector2(-0.2, 2.75)], ["KITCHEN", Vector2(-1.15, -0.25)], ["BATH", Vector2(1.90, -0.60)]]
		"house":
			rooms = [["GARAGE", Vector2(-2.6, -0.2)], ["BATH", Vector2(-2.6, -4.8)], ["KITCHEN", Vector2(1.45, -0.35)], ["LOUNGE", Vector2(1.2, -3.2)]]
		"villa":
			rooms = [["LOUNGE", Vector2(-4.15, 2.35)], ["STUDY", Vector2(3.35, 2.35)], ["MUSIC", Vector2(-4.4, -8.5)], ["MASTER BATH", Vector2(3.45, -8.5)]]
		"electronics":
			rooms = [["ARCADE", Vector2(-3.95, 1.90)], ["DISPLAY", Vector2(3.5, -0.76)], ["SERVICE", Vector2(-0.05, -4.9)]]
		"mansion":
			rooms = [] # Architecture, floor materials and loot identify each wing.
		"laboratory":
			rooms = [] # Mirrored stations and the isolated core identify the route.
		"museum":
			rooms = [] # Exhibits and banners do the wayfinding.
		"castle":
			rooms = [["THRONE CHAMBER", Vector2(0, -4.1)], ["TREASURY", Vector2(-3.2, -0.65)], ["CRYPT", Vector2(3.2, -0.65)], ["GREAT HALL", Vector2(0, -0.2)]]
		"pyramid":
			rooms = [] # Colour, floor inlay and relic staging identify the rooms without text on loot.
		_:
			pass
	for room in rooms:
		var label = Label3D.new()
		label.text = room[0]
		label.font_size = 22 if location == "apartment" else (24 if location == "electronics" else 28)
		label.pixel_size = 0.008 if location in ["apartment", "electronics"] else 0.009
		label.modulate = Color("556f718a") if location == "apartment" else (Color("7e99a2") if location == "electronics" else Color("617777"))
		label.outline_size = 0
		label.rotation_degrees.x = -90
		label.position = Vector3(room[1].x, 0.09, room[1].y)
		add_child(label)

func build_partitions(location: String) -> void:
	# Compact greyboxes share the tested doorway and two clear access lanes.
	# Each layout changes the wing depth/openings, never the player's movement rules.
	var cross_z = -1.1
	var width = 3.0
	var center_x = 3.55
	var spine_length = 1.55
	match location:
		"house": spine_length = 2.5
		"villa":
			cross_z = -0.7
			spine_length = 2.25
		"electronics":
			cross_z = -0.9
			width = 2.8
			center_x = 3.65
			spine_length = 2.85
		"mansion":
			cross_z = -0.7
			width = 2.1
			center_x = 4.0
			spine_length = 2.7
		"museum":
			cross_z = -0.1
			width = 2.6
			center_x = 3.7
			spine_length = 3.85
	for x in [-center_x, center_x]: wall(Vector3(width, 0.66, 0.18), Vector3(x, 0.33, cross_z))
	wall(Vector3(0.18, 0.65, spine_length), Vector3(0, 0.325, -4.55 + spine_length / 2))

func barrier(size: Vector3, at: Vector3) -> void:
	var body = StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.position = at
	body.add_child(collision)
	add_child(body)

func wall(size: Vector3, at: Vector3, color: Color = Color("f5e5c8")) -> void:
	Models.box(self, size, at, color)
	Models.box(self, Vector3(size.x, 0.05, size.z), at + Vector3.UP * (size.y / 2), Color("fff3de") if color == Color("f5e5c8") else color.lightened(wall_top_lift))
	var body = StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(size.x, 3, size.z)
	collision.shape = shape
	body.position = Vector3(at.x, 1.5, at.z)
	body.add_child(collision)
	add_child(body)
	walls.append(Rect2(Vector2(at.x - size.x / 2, at.z - size.z / 2), Vector2(size.x, size.z)))

func accessible(item: LootItem) -> bool:
	var from = player.global_position + Vector3.UP * 0.5
	var to = item.global_position + Vector3.UP * 0.5
	var query = PhysicsRayQueryParameters3D.create(from, to, 1)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func valid_drop(point: Vector3, radius: float) -> bool:
	var back_limit := -7.5 if location_id == "house" else (-8.85 if location_id == "villa" else (-10.3 if location_id == "mansion" else (-5.0 if location_id == "electronics" else -4.3)))
	var front_limit := 9.7 if location_id == "house" else (12.8 if location_id == "villa" else (15.2 if location_id == "mansion" else (14.4 if location_id == "electronics" else 5.8)))
	var side_limit := 7.0 if location_id == "mansion" else (5.8 if location_id == "villa" else (6.35 if location_id == "electronics" else 4.8))
	if location_id == "museum":
		back_limit = -11.78
		front_limit = 16.6
		side_limit = 7.9
	if location_id == "laboratory":
		back_limit = -11.65
		front_limit = 16.6
		side_limit = 7.45
	if location_id == "pirate_ship":
		if not PIRATE_ART.walkable(point, radius): return false
		back_limit = -10.8
		front_limit = 17.0
		side_limit = 5.3
	if location_id == "prehistoric" and not PREHISTORIC_ART.walkable(point,radius): return false
	if location_id in ["vikings", "english_pub", "prehistoric"]:
		back_limit = -12.7
		front_limit = 16.6
		side_limit = 8.0
	if absf(point.x) > side_limit - radius or point.z < back_limit + radius or point.z > front_limit - radius: return false
	for rect in walls:
		if rect.grow(radius + 0.08).has_point(Vector2(point.x, point.z)): return false
	return true

func drop_position(item: LootItem) -> Vector3:
	var origin = player.global_position
	for distance in [0.7, 0.45, 0.0]:
		for step in range(16):
			var angle = float(step) * TAU / 16.0
			var point = origin + Vector3(sin(angle), 0, cos(angle)) * distance
			point.y = 0.08
			if valid_drop(point, float(item.data.radius)):
				var query = PhysicsRayQueryParameters3D.create(origin + Vector3.UP * 0.5, point + Vector3.UP * 0.5, 1)
				if get_world_3d().direct_space_state.intersect_ray(query).is_empty(): return point
	return Vector3.INF

func splash(at: Vector3) -> void:
	var water = Models.cylinder(self, 0.48, 0.015, at + Vector3.UP * 0.015, Color("64cadf"))
	var tween = create_tween()
	tween.tween_property(water, "scale", Vector3(1.5, 1, 1.5), 0.4)
	tween.tween_interval(1.0)
	tween.tween_property(water, "scale", Vector3.ZERO, 0.4)
	tween.tween_callback(water.queue_free)
