extends "res://tests/route_harness.gd"

var simulation: Array = []
var intervals: Array = []

func profile(pending: bool = false, location: String = "apartment") -> SaveStore:
	var p = SaveStore.new("res://tests/variety_fixture.json")
	p.session_only = true
	p.data.upgrades = MAXED.duplicate()
	p.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	if pending: SpecialJobs.make_pending(p.data, location)
	return p

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	test_scheduler()
	test_persistence()
	await test_outcomes()
	await test_rewards()
	await test_special_alarm()
	await simulate_thirty()
	await test_physical_specials()
	var output = FileAccess.open("res://tests/variety_v01_measurements.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"simulation":simulation,"intervals":intervals,"physical_routes":measurements}, "\t", true, true))
	output.close()
	print("VARIETY SEQUENCE: ", " ".join(simulation))
	print("VARIETY INTERVALS: ", intervals)
	print("VARIETY SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func test_scheduler() -> void:
	for interval in [2, 3, 4]:
		var p = profile()
		check(p.data.special_interval in [2, 3, 4] and p.data.runs_since_special == 0 and not p.data.special_pending, "Fresh interval valid, empty cycle")
		p.data.special_interval = interval
		for i in range(interval):
			SpecialJobs.finish(p.data, "normal", "house", true)
			check(p.data.special_pending == (i + 1 == interval), "Exact threshold %d, normal %d" % [interval, i + 1])
		check(p.data.special_location_id == "house" and p.data.special_type == "RUSH_HOUR", "Offer belongs to triggering location")
		var frozen = p.data.duplicate(true)
		for i in range(8): SpecialJobs.finish(p.data, "normal", "museum", true)
		SpecialJobs.make_pending(p.data, "museum")
		check(p.data == frozen, "Ignoring eight normals freezes one identical pending offer")
		SpecialJobs.finish(p.data, "special", "house", false)
		check(p.data == frozen, "READY special abandon preserves offer")
		SpecialJobs.begin(p.data, "house")
		check(not SpecialJobs.can_play(p.data, "house"), "Started special cannot be launched twice")
		SpecialJobs.finish(p.data, "special", "house", true)
		check(not p.data.special_pending and p.data.runs_since_special == 0 and p.data.special_interval in [2,3,4], "Consumed offer begins fresh 2-4 cycle")
		SpecialJobs.finish(p.data, "normal", "house", true)
		check(not p.data.special_pending, "No consecutive special after one normal")
	var p = profile()
	var initial = p.data.duplicate(true)
	for mode in ["rush", "small_van", "client_order"]: SpecialJobs.finish(p.data, mode, "apartment", true)
	SpecialJobs.finish(p.data, "normal", "apartment", false)
	check(p.data == initial, "Mastery and READY normal never advance scheduler")
	check(SpecialJobs.DEFINITIONS.size() == 1, "Only Rush Hour implemented")

func test_persistence() -> void:
	var fresh_path = "res://tests/variety_new_%d.json" % Time.get_ticks_usec()
	var fresh = SaveStore.new(fresh_path)
	fresh.load_progress()
	check(FileAccess.file_exists(fresh_path) and fresh.data.special_interval in [2,3,4], "First ever launch saves chosen interval immediately")
	var fresh_reload = SaveStore.new(fresh_path)
	fresh_reload.load_progress()
	check(fresh_reload.data == fresh.data, "First-launch interval survives restart without playing")
	fresh.data.runs_since_special = 1
	fresh.save_progress()
	fresh_reload = SaveStore.new(fresh_path)
	fresh_reload.load_progress()
	check(fresh_reload.data.runs_since_special == 1 and fresh_reload.data.special_interval == fresh.data.special_interval, "Unfinished NORMAL restart neither counts nor rerolls")
	DirAccess.remove_absolute(fresh_path)
	DirAccess.remove_absolute(fresh_path + ".bak")
	var path = "res://tests/variety_persistence.json"
	var p = SaveStore.new(path)
	p.data.upgrades = MAXED.duplicate()
	p.data.wallet = 23456
	p.data.objectives.apartment = {"cash":true,"signature":true,"full_clear":true}
	p.data.apartment_final_job_completed = true # Final Job pilot: House must be genuinely unlocked for the pending-in-House scenario below.
	p.data.bonuses = ["apartment"]
	p.data.trophies = ["flamingo"]
	p.data.contracts["apartment.rush"] = true
	p.data.contract_bonuses = ["apartment.rush"]
	p.data.records.normal.apartment = 42.5
	p.data.records.rush.apartment = 22.5
	p.data.cosmetics.owned = ["van_mint"]
	p.data.cosmetics.equipped.van = "van_mint"
	p.data.successes = 10
	p.data.failures = 3
	Progression.refresh(p.data)
	var legacy = p.data.duplicate(true)
	legacy.schema_version = 4
	for key in ["runs_since_special","special_interval","special_pending","special_type","special_location_id","special_in_progress"]: legacy.erase(key)
	legacy.records.erase("special")
	legacy.mode_stats.erase("special")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var restored = SaveStore.new(path)
	restored.load_progress()
	check(restored.data.schema_version == SaveStore.SCHEMA and FileAccess.file_exists(path + ".schema4.bak"), "V2.1 schema4 safely migrates to5 with backup")
	var untouched = true
	for key in legacy:
		if key in ["schema_version", "records", "mode_stats"]: continue
		untouched = untouched and legacy[key] == restored.data[key]
	for mode in legacy.records:
		untouched = untouched and legacy.records[mode] == restored.data.records[mode] and legacy.mode_stats[mode] == restored.data.mode_stats[mode]
	check(untouched, "Existing money, levels, unlocks, medals, records, cosmetics, trophies and statistics identical")
	check(restored.data.runs_since_special == 0 and not restored.data.special_pending and restored.data.special_interval in [2,3,4], "Migration creates valid fresh special cycle")
	var chosen = restored.data.special_interval
	for i in range(5):
		p = SaveStore.new(path)
		p.load_progress()
		check(p.data.special_interval == chosen, "Reload never rerolls migration interval")
	SpecialJobs.make_pending(p.data, "house")
	p.save_progress()
	var pending = p.data.duplicate(true)
	for i in range(5):
		restored = SaveStore.new(path)
		restored.load_progress()
		check(restored.data == pending and SpecialJobs.can_play(restored.data, "house"), "Pending offer and permanent progress survive full reload")
	SpecialJobs.begin(restored.data, "house")
	restored.save_progress()
	p = SaveStore.new(path)
	p.load_progress()
	check(not p.data.special_pending and p.data.runs_since_special == 0 and p.data.wallet == 23456, "Hard-close after special starts consumes attempt without reward")
	chosen = p.data.special_interval
	restored = SaveStore.new(path)
	restored.load_progress()
	check(restored.data.special_interval == chosen and restored.data.runs_since_special == 0, "Recovery persisted once; next restart does not consume or reroll again")

func test_outcomes() -> void:
	for outcome in ["success", "failure", "abandon"]:
		var p = profile()
		p.data.special_interval = 2
		await new_session("apartment", "normal", p)
		begin()
		if outcome == "success":
			world.player.position = world.van.load_position
			run.escape()
		elif outcome == "failure": tick(61)
		else: run.abandon()
		check(p.data.runs_since_special == 1, "NORMAL " + outcome + " counts once")
		run.abandon()
		run.escape()
		check(p.data.runs_since_special == 1, "Duplicate result cannot count again")
		await new_session("house", "normal", p)
		begin()
		run.abandon()
		check(p.data.special_pending and p.data.special_location_id == "house" and run.result.special_unlocked, "Second completed NORMAL announces job in same location")
		await new_session("apartment", "normal", p)
		begin()
		run.abandon()
		check(p.data.special_location_id == "house" and p.data.runs_since_special == 2, "Actual normal still playable while offer frozen")
		await new_session("house", "special", p)
		check(run.remaining == 35 and run.capacity() == Balance.van_capacity(20) and run.rules.contract_id == "", "Rush35 with full normal capacity, no mastery contract")
		begin()
		check(p.data.special_pending and p.data.special_in_progress, "Started job remains reserved until outcome")
		if outcome == "success":
			world.player.position = world.van.load_position
			run.escape()
		elif outcome == "failure": tick(36)
		else: run.abandon()
		check(not p.data.special_pending and p.data.runs_since_special == 0 and p.data.special_interval in [2,3,4], "SPECIAL " + outcome + " consumes and resets")
		var interval = p.data.special_interval
		run.abandon()
		check(p.data.special_interval == interval and p.data.runs_since_special == 0, "Duplicate finish cannot reroll special cycle")
	var p = profile(true)
	await new_session("apartment", "special", p)
	run.pause()
	tick(10)
	run.resume()
	run.abandon()
	check(p.data.special_pending and not p.data.special_in_progress, "READY pause and abandon do not consume")
	p = profile()
	await new_session("apartment", "normal", p)
	run.abandon()
	check(p.data.runs_since_special == 0, "Actual NORMAL READY abandon excluded")
	for mode in ["rush", "small_van", "client_order"]:
		await new_session("apartment", mode, p)
		begin()
		run.abandon()
		check(p.data.runs_since_special == 0, "Actual Mastery " + mode + " excluded")

func test_rewards() -> void:
	var p = profile(true, "house")
	await new_session("house", "special", p)
	begin()
	for item in world.items:
		if item.data.type_id in ["sofa", "bathtub"]: load_item(item)
	run.escape()
	check(run.result.loot_value == 830 and run.result.rush_bonus == 332 and run.result.earned == 1162 and p.data.wallet == 1162, "Sofa, bathtub and Rush bonus bank immediately")
	sell_pending()
	check(p.data.wallet == 1162, "No extra sale can pay the same items")
	check(p.data.objectives.house.cash and p.data.contract_bonuses.is_empty() and Progression.contract_count(p.data) == 0, "Base loot awards career cash, never Mastery medals or rewards")
	p = profile()
	var changes = Progression.settle(p.data, "house", "special", {}, [], 650, false, 25)
	check(p.data.wallet == 910 and changes.rush_bonus == 260 and not p.data.objectives.house.cash, "Base650 + bonus260 does not complete $800 objective")
	for kind in ["carried", "dropped", "loading", "timeout"]:
		p = profile(true)
		await new_session("apartment", "special", p)
		begin()
		load_item(world.items[0])
		stand_by(world.items[1])
		tick(2)
		if kind == "timeout":
			tick(36)
			check(run.result.earned == 0 and run.result.rush_bonus == 0 and p.data.wallet == 0, "Timeout loses all secured and carried loot; bonus zero")
		else:
			if kind == "dropped": run.drop()
			world.player.position = world.van.load_position
			if kind == "loading": tick(0.1)
			# Escape requires empty hands. Finish isolates settlement from that existing gate.
			run.finish(true)
			check(run.result.loot_value == 140 and run.result.rush_bonus == 56 and p.data.wallet == 196, "Only loaded loot banks for " + kind + " object")
	p = profile(true)
	p.data.records.normal.apartment = 45.0
	await new_session("apartment", "special", p)
	begin()
	# Interaction fixture, deliberately not a physical full-clear route claim.
	for item in world.items: load_item(item)
	run.escape()
	check(run.result.success and run.result.full_clear and run.cargo.size() == world.items.size(), "Full clear requires every loaded instance and successful escape")
	check(p.data.objectives.apartment.full_clear and p.data.objectives.apartment.signature and p.data.trophies == ["flamingo"], "Special full clear grants career objectives and actual trophy")
	check(run.result.rush_bonus == 484 and run.result.bonus == 250 and p.data.wallet == 1944, "Rush484, unique250 and base1210 bank together")
	sell_pending()
	check(p.data.wallet == 1944, "No extra full-haul payment remains")
	check(p.data.records.normal.apartment == 45 and p.data.records.special.apartment < 35 and p.data.records.rush.is_empty(), "Special full-clear record cannot overwrite NORMAL or Mastery record")

func test_special_alarm() -> void:
	for left in [20.0, 8.0]:
		var p = profile(true)
		await new_session("apartment", "special", p)
		begin()
		run.remaining = left
		run.current_noise = run.alarm_threshold
		run.carried = world.items[0]
		run.add_pickup_noise(run.carried)
		check(run.alarm_active and run.remaining == minf(left, 12), "Rush alarm remaining min(%d,12)" % left)
		var noise = run.current_noise
		run.add_pickup_noise(run.carried)
		check(run.current_noise == noise, "Special noise generated once per instance")
		run.carried = null
	for location in Balance.LOCATION_ORDER:
		var normal = Balance.session(location, "normal", MAXED)
		var special = Balance.session(location, "special", MAXED)
		check(normal.duration == Balance.LOCATIONS[location].duration and special.duration == 35 and normal.capacity == special.capacity, "Only timer changes in special rules " + location)
		await new_session(location, "special", profile(true, location))
		check(run.alarm_threshold == Balance.alarm_threshold(location) and run.upgrades == MAXED, "Same noise threshold and all upgrades " + location)

func simulate_thirty() -> void:
	seed(21092026)
	var p = profile()
	var normal_count = 0
	for i in range(30):
		var mode = "special" if p.data.special_pending else "normal"
		var location = p.data.special_location_id if mode == "special" else Balance.LOCATION_ORDER[i % 6]
		var chosen = p.data.special_interval
		if mode == "special":
			check(normal_count == chosen and normal_count in [2,3,4], "Simulation interval %d before special %d" % [normal_count, i + 1])
			check(simulation.is_empty() or simulation.back() == "N", "Simulation specials never consecutive")
			intervals.append(normal_count)
			normal_count = 0
		else: normal_count += 1
		await new_session(location, mode, p)
		begin()
		if i % 3 == 0: tick(run.remaining + 1)
		elif i % 3 == 1: run.abandon()
		else:
			world.player.position = world.van.load_position
			run.escape()
		simulation.append("S" if mode == "special" else "N")
		check(run.phase == RunManager.Phase.FINISHED, "Simulation outcome %d complete" % (i + 1))
		if mode == "normal": check(p.data.special_interval == chosen and p.data.special_pending == (normal_count == chosen), "Simulation threshold stable and exact")
	check(simulation.size() == 30 and normal_count <= 4, "Thirty real round lifecycle outcomes; no long drought")

func test_physical_specials() -> void:
	for location in Balance.LOCATION_ORDER:
		await new_session(location, "special", profile(true, location))
		# Reuse the established Mastery Rush subset solely to select a known viable route.
		run.rules.contract_id = location + ".rush"
		# Pyramid has no Mastery Rush yet: pick the best NORMAL-style subset with a 7s
		# safety margin, since the geometric estimate is optimistic for its deep rooms.
		var indices: Array
		if location == "mansion":
			# Mansion Mastery Rush has a distinct 55s goal; the 35s Special Job
			# has no minimum loot requirement. Steal the signature and one safe.
			indices = [0, 2]
		elif location == "laboratory":
			# The 55s Mastery route is too greedy for the 35s Special Job.
			# The rear Quantum Core is a meaningful single-target sprint.
			indices = [8]
		elif Balance.CONTRACTS.has(location + ".rush"): indices = choose_indices("rush")
		else:
			run.remaining -= 7.0
			indices = choose_indices("normal")
			run.remaining += 7.0
		run.rules.contract_id = ""
		var completed = await drive_indices(indices, location + ".rush_hour")
		check(completed and run.elapsed < 35, "Physical Rush Hour escape in " + location)
		check(run.result.rush_bonus == SpecialJobs.bonus(run.cargo_value, "RUSH_HOUR") and not store.data.special_pending, "Physical route pays exact bonus and consumes job")
