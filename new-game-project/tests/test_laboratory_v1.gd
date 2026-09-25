extends "res://tests/route_harness.gd"

func _initialize() -> void: call_deferred("test")

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	var config: Dictionary = Balance.LOCATIONS.laboratory
	check(Balance.LOCATION_ORDER.find("laboratory") == Balance.LOCATION_ORDER.find("museum") - 1, "Laboratory is directly before Museum")
	check(Balance.totals("laboratory") == {"cargo": 39, "value": 7250}, "Nine laboratory instruments have their intended cargo and value")
	var types: Array = config.items.map(func(row): return row[1])
	check(types.size() == 9 and types.all(func(type_id): return str(type_id).begins_with("lab_")), "Every Laboratory loot type is unique to the level")
	var unique_types := {}
	for type_id in types: unique_types[type_id] = true
	check(unique_types.size() == types.size(), "No laboratory loot prop repeats in the same map")
	check(config.special == "lab_quantum_core" and Balance.TROPHIES.lab_core.location == "laboratory", "Quantum Core is the signature and trophy")
	var profile = SaveStore.new("res://tests/laboratory_v1_profile.json")
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("laboratory"))
	for location in Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("laboratory")):
		profile.data.objectives[location].cash = true
		profile.data.objectives[location].signature = true
	profile.data.apartment_final_job_completed = true
	for key in Balance.UPGRADE_KEYS: profile.data.upgrades[key] = Balance.required_level(key, "mansion")
	Progression.refresh(profile.data)
	check(profile.unlocked("laboratory") and not profile.unlocked("museum"), "Mansion progression opens Laboratory before Museum")
	profile.data.objectives.laboratory.cash = true
	profile.data.objectives.laboratory.signature = true
	for key in Balance.UPGRADE_KEYS: profile.data.upgrades[key] = Balance.required_level(key, "laboratory")
	Progression.refresh(profile.data)
	check(profile.unlocked("museum") and not profile.unlocked("pyramid"), "Two Laboratory objectives open Museum but not Chapter 2")
	var legacy = SaveStore.new("res://tests/laboratory_legacy_profile.json")
	legacy.data.unlocked = ["apartment", "house", "villa", "electronics", "mansion", "museum"]
	legacy.data.objectives.mansion.cash = true
	legacy.data.objectives.mansion.signature = true
	Progression.refresh(legacy.data)
	check(legacy.data.unlocked.find("laboratory") == legacy.data.unlocked.find("museum") - 1, "Existing Museum saves gain Laboratory in the right order")
	for mode in ["normal", "rush", "small_van", "client_order"]:
		await new_session("laboratory", mode)
		var selected: Array = range(config.items.size()) if mode == "normal" else choose_indices(mode)
		var solved = await drive_indices(selected, "laboratory." + mode)
		check(solved and run.result.get("full_clear", false) if mode == "normal" else solved and run.result.get("contract_met", false), "Physical Laboratory %s route is solvable" % mode)
		var rear := world.van.model.to_global(Vector3(-1.7, 0, 0))
		var cab := world.van.model.to_global(Vector3(1.7, 0, 0))
		check(world.walls.size() > 0 and rear.z < cab.z and rear.distance_to(world.van.load_position) < cab.distance_to(world.van.load_position), "Laboratory keeps route walls and a rear-facing van")
	var output = FileAccess.open("res://tests/laboratory_v1_measurements.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks": checks, "failures": failures, "routes": measurements}, "\t", true, true))
	output.close()
	print("LABORATORY V1 SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
