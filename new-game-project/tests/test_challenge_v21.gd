extends "res://tests/test_challenge_v2.gd"

var alarm_snapshot: Dictionary = {}

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	test_v2_config()
	await test_noise()
	await test_settlement()
	await test_patch_rules()
	await test_all_routes()
	await test_museum_order()
	var output = FileAccess.open("res://tests/challenge_v21_measurements.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"routes":measurements}, "\t", true, true))
	output.close()
	print("CHALLENGE V2.1 SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func new_session(location: String, mode: String = "normal", profile: SaveStore = null) -> void:
	await super.new_session(location, mode, profile)
	alarm_snapshot = {}
	run.feedback.connect(func(kind: String, _message: String):
		if kind == "alarm":
			alarm_snapshot = {"loaded_items_at_alarm":run.cargo.size(), "loaded_cargo_at_alarm":run.cargo_used, "noise_at_alarm":run.current_noise, "carried_at_alarm":run.carried.instance_id_in_run if run.carried != null else ""}
	)

func drive_indices(indices: Array, label: String) -> bool:
	var success = await super.drive_indices(indices, label)
	measurements.back().merge(alarm_snapshot)
	if not alarm_snapshot.is_empty():
		print("AT ALARM: %d loaded / %d cargo / %.3f noise" % [alarm_snapshot.loaded_items_at_alarm, alarm_snapshot.loaded_cargo_at_alarm, alarm_snapshot.noise_at_alarm])
	return success

func test_patch_rules() -> void:
	check(Balance.ALARM_THRESHOLD_FACTOR == 0.65 and Balance.ALARM_WINDOW == 12.0, "Threshold65 percent, alarm window remains12 seconds")
	check(Balance.ITEMS.museum_artifact == {"display_name":"GIANT DIAMOND","cash_value":2500,"cargo_space":8,"required_strength":5,"pickup_duration":3.5,"weight_class":"VERY_HEAVY","radius":0.72}, "Museum signature is the eight-cargo Giant Diamond")
	check(Balance.totals("museum") == {"cargo":45,"value":9700}, "Museum exhibits total 45 cargo and $9700")
	check(Balance.van_capacity(19) == 44 and Balance.van_capacity(20) == 46, "Van formula unchanged: L19=44 L20=46")
	check(Balance.CONTRACTS["museum.small_van"] == {"location":"museum","mode":"small_van","name":"SMALL VAN","duration":60,"capacity_limit":18,"threshold":4000,"order":{},"bonus":1500}, "Museum Small Van only changes capacity to18")
	for location in Balance.LOCATION_ORDER:
		var base = Balance.location_noise(location)
		var level1 = 0.0
		var level20 = 0.0
		for spawn in Balance.LOCATIONS[location].items:
			var weight: String = Balance.ITEMS[spawn[1]].weight_class
			level1 += Balance.NOISE[weight] * Balance.noise_multiplier(1)
			level20 += Balance.NOISE[weight] * Balance.noise_multiplier(20)
		check(is_equal_approx(level1, base) and is_equal_approx(level20, base * 0.81), "Full inventory noise totals L1=100/L20=81 percent " + location)
		check(is_equal_approx(Balance.alarm_threshold(location) / level20, 0.65 / 0.81), "Threshold is80.2469 percent of MAX full-clear noise " + location)
		await new_session(location)
		var fixed = run.alarm_threshold
		run.upgrades.noise = 1
		check(is_equal_approx(fixed, base * 0.65) and run.alarm_threshold == fixed, "Location threshold independent of Noise Control " + location)
		check(run.remaining == Balance.LOCATIONS[location].duration, "Normal timer matches the location budget " + location)
	var profile = SaveStore.new("res://tests/v21_capacity_profile.json")
	profile.data.upgrades = MAXED.duplicate()
	profile.data.upgrades.capacity = 19
	await new_session("museum", "normal", profile)
	run.cargo_used = 38 # Mathematical capacity edge; isolates capacity from time/noise.
	check(run.block_reason(world.items[0]) == "NOT ENOUGH VAN SPACE", "L19 cannot accept the eight-cargo diamond at 38 cargo")
	profile.data.upgrades.capacity = 20
	await new_session("museum", "normal", profile)
	run.cargo_used = 38
	check(run.block_reason(world.items[0]) == "", "L20 accepts the eight-cargo diamond at 38 cargo")

func test_museum_order() -> void:
	await new_session("museum", "small_van")
	var ok = await drive_indices([0,2], "museum.small_van_exact_artifact_statue")
	check(ok and run.result.contract_met and run.cargo_used == 16 and run.cargo_value == 4000, "Physical diamond+statue solution uses 16 cargo/$4000")
	check(run.loaded_counts() == {"museum_artifact":1,"large_statue":1}, "Required Museum solution contains precisely artifact and statue")
