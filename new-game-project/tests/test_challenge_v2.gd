extends "res://tests/route_harness.gd"

var alarm_counts = {"alarm": 0, "noise_warning": 0}
var purchases_log: Array = []

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	test_v2_config()
	test_v2_migration()
	test_v2_purchases()
	await test_noise()
	await test_settlement()
	await test_all_routes()
	await noise_comparison_routes()
	await campaign_v2()
	var output = FileAccess.open("res://tests/challenge_v2_measurements.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks": checks, "failures": failures, "routes": measurements, "campaign": campaign_runs, "purchases": purchases_log}, "\t"))
	output.close()
	print("CHALLENGE V2 SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func test_v2_config() -> void:
	var expected = {"strength": 23000, "grip": 42450, "carry": 46050, "capacity": 63600, "noise": 49600}
	var count = 0
	var total = 0
	for key in Balance.UPGRADE_KEYS:
		var sum = 0
		for level in range(1, Balance.max_level(key)):
			var independent = [1000, 2400, 5800, 13800][level - 1] if key == "strength" else int(floor({"grip":250,"carry":300,"capacity":900,"noise":700}[key] * pow(1.13, level - 1) / 50 + 0.5)) * 50
			check(Balance.upgrade_cost(key, level) == independent, "Exact formula price %s L%d" % [key, level])
			count += 1
			sum += Balance.upgrade_cost(key, level)
		check(sum == expected[key], "Exact total %s $%d" % [key, sum])
		total += sum
		check(Balance.upgrade_cost(key, Balance.max_level(key)) == 0 and not Balance.effect(key, Balance.max_level(key)).is_empty(), "MAX display safe, no purchase beyond " + key)
	check(count == 80 and total == 224700, "Exactly 80 purchases, total $224700")
	check(Balance.round_to_50(624.999) == 600 and Balance.round_to_50(625) == 650 and Balance.round_to_50(675) == 700, "Rounding ties go up consistently")
	check(is_equal_approx(Balance.grip_speed(20), 1.57) and is_equal_approx(Balance.pickup_time(0.5, 20), 0.5 / 1.57), "Grip MAX = 157 percent; smallest real loot above 0.25s minimum")
	check(Balance.pickup_time(0.1, 20) == 0.25 and Balance.LOAD_DURATION == 0.3, "Safety minimum retained, loading unchanged")
	check(is_equal_approx(Balance.carry_multiplier(20), 1.285) and Balance.van_capacity(20) == 46, "Carry MAX 128.5 percent and van MAX 46")
	check(Balance.noise_multiplier(1) == 1 and is_equal_approx(Balance.noise_multiplier(20), 0.81) and Balance.noise_multiplier(99) >= 0.81, "Noise L1=100 percent, L20=81 percent with floor")
	check(Balance.NOISE == {"LIGHT": 4.0, "MEDIUM": 7.0, "HEAVY": 12.0, "VERY_HEAVY": 18.0}, "Four exact base Noise classes")
	for weight in Balance.WEIGHTS:
		for level in range(1, 21):
			check(is_equal_approx(5 * Balance.carry_factor(weight, level), minf(5, 5 * Balance.WEIGHTS[weight] * (1 + 0.015 * (level - 1)))), "Capped speed %s L%d" % [weight, level])
	for location in Balance.LOCATION_ORDER:
		var totals = Balance.totals(location)
		check(totals.cargo == Balance.LOCATIONS[location].expected_cargo and totals.value == Balance.LOCATIONS[location].expected_value, "Expected inventory " + location)
		var base = 0.0
		for spawn in Balance.LOCATIONS[location].items: base += {"LIGHT": 4, "MEDIUM": 7, "HEAVY": 12, "VERY_HEAVY": 18}[Balance.ITEMS[spawn[1]].weight_class]
		check(is_equal_approx(Balance.alarm_threshold(location), base * 0.65), "Threshold from full base inventory " + location)
	check(Balance.effect("grip", 7).contains("118% → 121%") and Balance.effect("noise", 8).contains("93% → 92%"), "Shop effects reflect formulas rather than inconsistent example text")

func test_v2_migration() -> void:
	var profile = SaveStore.new("res://tests/migration_v2.json")
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../checkpoints/before-challenge-v2/progress.json"))
	write_json(profile.path, raw)
	profile.load_progress()
	check(profile.data.schema_version == SaveStore.SCHEMA and FileAccess.file_exists(profile.path + ".schema3.bak"), "Real-save COPY migration backs up V1 before writing current schema")
	check(profile.data.wallet == raw.wallet and profile.data.upgrades == {"strength": 4, "grip": 15, "carry": 11, "capacity": 12, "noise": 1}, "Real snapshot maps 4/4/3/4 to 4/15/11/12 plus Noise1 without charge")
	for key in ["unlocked", "objectives", "trophies", "contracts", "contract_bonuses", "bonuses", "cosmetics", "successes", "failures"]:
		var migrated = profile.data[key]
		# Later-added locations gain empty objective rows when the old snapshot loads.
		if key == "objectives":
			migrated = migrated.duplicate(true)
		for location in ["laboratory", "pyramid", "castle"]:
				check(migrated[location] == {"cash": false, "signature": false, "full_clear": false}, "Migration adds empty %s objectives" % location)
				migrated.erase(location)
		var expected = raw[key]
		if key == "trophies":
			expected = expected.duplicate()
			var old_trophy = expected.find("bust")
			if old_trophy >= 0: expected[old_trophy] = "duck"
		check(migrated == expected, "Migration preserves " + key)
	check(is_equal_approx(profile.data.records.normal.house, raw.records.normal.house), "Migration preserves historical V1 records")
	var restored = SaveStore.new(profile.path)
	restored.load_progress()
	check(restored.data.upgrades == profile.data.upgrades and restored.data.wallet == profile.data.wallet, "V2 reload never migrates levels twice")
	for key in ["grip", "carry", "capacity"]:
		var old_max = 6 if key == "capacity" else 5
		for level in range(1, old_max + 1):
			var fixture = {"upgrades": {key: level}}
			check(profile.migrate_v3(fixture).upgrades[key] == 1 + roundi(float(level - 1) / (old_max - 1) * 19), "Proportional migration %s old L%d" % [key, level])
	var legacy = {"schema_version": 2, "wallet": 4700, "upgrades": {"strength": 3, "grip": 4, "carry": 4, "capacity": 4}, "objectives": {"apartment": [true,true,false], "house": [true,true,true]}, "trophies": ["flamingo", "bust"], "records": {"house": 37.2833}}
	write_json("res://tests/migration_v2_legacy.json", legacy)
	var legacy_store = SaveStore.new("res://tests/migration_v2_legacy.json")
	legacy_store.load_progress()
	check(legacy_store.data.upgrades.grip == 15 and legacy_store.data.wallet == 4700 and legacy_store.unlocked("villa"), "Schema2 chains safely into schema4")
	profile.data.wallet += 100
	profile.save_progress()
	var damaged = FileAccess.open(profile.path, FileAccess.WRITE)
	damaged.store_string("{broken")
	damaged.close()
	restored.load_progress()
	check(restored.data.wallet == raw.wallet and restored.notice.contains("backup"), "Corrupt V2 file recovers backup")

func test_v2_purchases() -> void:
	var profile = SaveStore.new("res://tests/purchases_v2.json")
	check(profile.data.upgrades == {"strength": 1, "grip": 1, "carry": 1, "capacity": 1, "noise": 1}, "Fresh game has all five stats at L1")
	profile.data.wallet = 224700
	for i in range(Balance.LOCATION_ORDER.size()):
		profile.data.unlocked = Balance.LOCATION_ORDER.slice(0, i + 1)
		for key in Balance.UPGRADE_KEYS:
			var cap: int
			if key == "strength": cap = [2,3,4,4,5,5,5,5,5][i]
			elif key == "capacity" and i == 0: cap = 6 # Apartment Final Job pilot: Van cap alone is raised to L6 at tier 0.
			else: cap = [4,7,10,13,16,18,20,20,20][i] # Laboratory adds a tier before Museum MAX.
			check(Balance.purchase_cap(key, profile.data) == cap, "Global tier cap %s / %s" % [Balance.LOCATION_ORDER[i], key])
			while profile.data.upgrades[key] < cap:
				check(profile.purchase(key, true), "Real purchase " + key)
			var before = profile.data.wallet
			check(not profile.purchase(key, true) and profile.data.wallet == before, "Tier/MAX blocks transaction " + key)
	check(profile.data.wallet == 0 and Progression.upgrades_maxed(profile.data), "All 80 live purchases cost $224700 and reach five-stat MAX")
	check(not Progression.campaign_cleared(profile.data), "MAX does not imply Campaign")
	profile.data = profile.defaults()
	profile.data.upgrades.grip = 15
	profile.data.wallet = 100000
	check(not profile.purchase("grip", true) and profile.data.upgrades.grip == 15, "Grandfathered level stays active above tier while purchases blocked")
	profile.data.unlocked.append("mansion")
	check(profile.purchase("grip", true) and profile.data.upgrades.grip == 16, "Later global unlock permits grandfathered level to advance")
	check(not profile.purchase("noise", false), "Purchases blocked inside round")
	profile.data.wallet = 599
	check(not profile.purchase("noise", true) and profile.data.wallet == 599, "Insufficient funds no negative balance")
	profile.data.objectives.museum.cash = true
	profile.data.objectives.museum.signature = true
	check(Progression.campaign_cleared(profile.data) and not Progression.upgrades_maxed(profile.data), "Campaign/contract access independent of MAX")
	for location in Balance.LOCATION_ORDER:
		for id in Balance.OBJECTIVE_IDS: profile.data.objectives[location][id] = true
	profile.data.trophies = Balance.TROPHIES.keys()
	for id in Balance.CONTRACTS: profile.data.contracts[id] = true
	Progression.refresh(profile.data)
	check(Progression.mastery_complete(profile.data) and not Progression.upgrades_maxed(profile.data), "Mastery now includes Laboratory objectives, trophy and medals without MAX")
	check(profile.data.cosmetics.owned.size() == 4, "Four exclusive cosmetics retained")

func observe_feedback(kind: String, _message: String) -> void:
	if alarm_counts.has(kind): alarm_counts[kind] += 1

func test_noise() -> void:
	await new_session("apartment")
	stand_by(world.items[0])
	tick(1)
	check(run.current_noise == 0 and not world.items[0].noise_generated_this_run, "READY generates no noise")
	begin()
	tick(0.1)
	check(run.current_noise == 0, "Starting pickup generates no noise")
	run.intention = Vector2.RIGHT
	tick(0.02)
	check(run.current_noise == 0, "Interrupted pickup generates no noise")
	run.intention = Vector2.ZERO
	tick(1)
	var item = run.carried
	var expected = Balance.pickup_noise("MEDIUM", run.upgrades.strength, run.upgrades.noise)
	check(item != null and is_equal_approx(run.current_noise, expected), "Successful pickup adds precise upgraded noise")
	check(run.drop() and is_equal_approx(run.current_noise, expected), "DROP adds no noise")
	tick(1.3)
	stand_by(item)
	tick(1)
	check(run.carried == item and is_equal_approx(run.current_noise, expected), "Repickup adds no noise for same instance")
	run.add_pickup_noise(item)
	check(is_equal_approx(run.current_noise, expected), "Repeated callback is idempotent")
	await new_session("apartment")
	check(run.current_noise == 0 and not run.alarm_active and not world.items[0].noise_generated_this_run, "Next round resets noise/alarm/instance flags")
	begin()
	var threshold = run.alarm_threshold
	run.upgrades.noise = 1
	check(run.alarm_threshold == threshold, "Upgrade level cannot change base threshold")
	alarm_counts = {"alarm": 0, "noise_warning": 0}
	run.feedback.connect(observe_feedback)
	run.current_noise = threshold * 0.75 - 1
	load_item(world.items[0])
	check(alarm_counts.noise_warning == 1 and not run.alarm_active, "75-percent warning once with no early alarm")
	run.current_noise = threshold - 7
	run.remaining = 30
	# Explicit unit fixture: pickup completed on the next call, exact 30 -> 12.
	run.carried = world.items[2]
	run.add_pickup_noise(run.carried)
	check(run.alarm_active and run.remaining == 12 and alarm_counts.alarm == 1, "Threshold equality triggers alarm; 30 becomes exactly12")
	run.carried = null
	run.pause()
	tick(4)
	check(run.remaining == 12, "Paused alarm timer does not decrease")
	run.resume()
	stand_by(world.items[4])
	tick(1)
	check(run.drop(), "DROP remains available after alarm")
	tick(1.3)
	load_item(world.items[4])
	check(run.cargo.size() == 2 and alarm_counts.alarm == 1 and alarm_counts.noise_warning == 1, "Can pick and load after alarm; no retrigger or repeated warning")
	run.escape()
	check(run.result.success and store.data.wallet == 210, "Escape after alarm banks both items")
	sell_pending()
	check(store.data.wallet == 210, "No later sale pays the same loot twice")
	await new_session("museum", "rush")
	begin()
	run.current_noise = run.alarm_threshold
	run.remaining = 7
	run.carried = world.items[0]
	run.add_pickup_noise(run.carried)
	check(run.remaining == 7 and run.alarm_active, "Contract alarm with7 seconds never adds time")
	run.remaining = 0
	run.escape()
	check(not run.result.success and store.data.wallet == 0, "Alarm timeout loses carried loot")
	await new_session("apartment", "small_van")
	check(run.current_noise == 0 and not run.alarm_active and run.remaining == 60 and run.capacity() == 8, "Contract restart resets alarm and keeps overrides")
	begin()
	load_item(world.items[0])
	run.current_noise = run.alarm_threshold
	run.carried = world.items[1]
	run.add_pickup_noise(run.carried)
	run.remaining = 0
	run.escape()
	check(run.result.lost == 190 and store.data.wallet == 0, "Timeout loses both loaded and carried loot")

func drive_indices(indices: Array, label: String) -> bool:
	var success = await super.drive_indices(indices, label)
	var m: Dictionary = measurements.back()
	m["route_instance_ids"] = indices.map(func(i): return world.items[i].instance_id_in_run)
	m["noise"] = run.current_noise
	m["threshold"] = run.alarm_threshold
	m["alarm_at"] = run.time_when_alarm_triggered
	m["remaining"] = run.remaining
	print("NOISE %.3f / %.3f | alarm %.2fs | left %.2fs" % [run.current_noise, run.alarm_threshold, run.time_when_alarm_triggered, run.remaining])
	return success

func campaign_v2() -> void:
	var profile = SaveStore.new("res://tests/campaign_v2.json")
	for round_number in range(1, 81):
		if Progression.campaign_cleared(profile.data): break
		var location = "apartment"
		for id in Balance.LOCATION_ORDER:
			if profile.unlocked(id): location = id
		if location == "apartment" and Progression.final_job_unlocked(profile.data) and not profile.data.apartment_final_job_completed:
			# Suburban now gates on the Final Job, not on 2 objectives: earn Van L6
			# (the pilot's own separate Apartment cap) before attempting it, exactly
			# like a real player saving up, then run STEAL EVERYTHING physically.
			while profile.data.upgrades.capacity < 6:
				var van_cost = Balance.upgrade_cost("capacity", profile.data.upgrades.capacity)
				if not profile.purchase("capacity", true): break
				purchases_log.append({"before_round": round_number, "key": "capacity", "level": profile.data.upgrades.capacity, "cost": van_cost, "wallet_after": profile.data.wallet})
			if profile.data.upgrades.capacity >= 6:
				await new_session("apartment", "FINAL_JOB", profile)
				var order = [1, 3, 4, 8, 0, 2, 5, 6, 7] # light items first, heavy mid, short final leg — the pilot's best-tested route.
				var final_job_success = await drive_indices(order, "campaign_v2_final_job_%02d" % round_number)
				if final_job_success: sell_pending()
				campaign_runs.append({"round": round_number, "location": "apartment.FINAL_JOB", "loot": run.cargo_value, "time": run.elapsed, "remaining": run.remaining, "wallet_after": profile.data.wallet, "upgrades": profile.data.upgrades.duplicate(), "success": final_job_success})
				check(final_job_success and profile.data.apartment_final_job_completed and profile.unlocked("house"), "Physical Final Job completes and unlocks Suburban")
				if not final_job_success: break
				continue
			# Not enough saved for Van L6 yet this round — fall through to a normal
			# Apartment round below to keep earning, and retry next round.
		var required: int = Balance.ITEMS[Balance.LOCATIONS[location].special].required_strength
		# Transparent policy: signature strength first, minimum useful cargo next.
		var target_capacity: int = {"apartment": 1, "house": 3, "villa": 6, "electronics": 6, "mansion": 6, "laboratory": 6, "museum": 6}[location]
		var wanted = "strength" if profile.data.upgrades.strength < required else "capacity"
		while (wanted == "strength" and profile.data.upgrades.strength < required) or (wanted == "capacity" and profile.data.upgrades.capacity < target_capacity):
			var cost = Balance.upgrade_cost(wanted, profile.data.upgrades[wanted])
			if not profile.purchase(wanted, true): break
			purchases_log.append({"before_round": round_number, "key": wanted, "level": profile.data.upgrades[wanted], "cost": cost, "wallet_after": profile.data.wallet})
			wanted = "strength" if profile.data.upgrades.strength < required else "capacity"
		await new_session(location, "normal", profile)
		var signature = not profile.data.objectives[location].signature and profile.data.upgrades.strength >= required
		var chosen = choose_indices("normal", signature)
		var success = await drive_indices(chosen, "campaign_v2_%02d_%s" % [round_number, location])
		if success: sell_pending()
		campaign_runs.append({"round": round_number, "location": location, "loot": run.cargo_value, "time": run.elapsed, "remaining": run.remaining, "wallet_after": profile.data.wallet, "upgrades": profile.data.upgrades.duplicate(), "success": success})
		if not success: break
	check(Progression.campaign_cleared(profile.data), "Physical earned-cash campaign reaches Museum and unlocks contracts")
	var bought = 0
	for key in Balance.UPGRADE_KEYS: bought += profile.data.upgrades[key] - 1
	check(not Progression.upgrades_maxed(profile.data) and bought < 80, "Campaign finishes below80 purchases: %d/80" % bought)
	print("CAMPAIGN V2: %d runs, %d purchases, wallet $%d" % [campaign_runs.size(), bought, profile.data.wallet])

func write_json(path: String, value: Variant) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))
	file.close()

func noise_comparison_routes() -> void:
	for location in Balance.LOCATION_ORDER:
		var profile = SaveStore.new("res://tests/noise_comparison_v2.json")
		profile.data.upgrades = MAXED.duplicate()
		profile.data.upgrades.noise = 1
		await new_session(location, "normal", profile)
		var indices: Array = []
		for i in range(world.items.size()): indices.append(i)
		var completed = await drive_indices(indices, location + ".max_except_noise1")
		# Diagnostic, not a requirement that Noise1 can full-clear every route.
		check(run.alarm_active and run.time_when_alarm_triggered >= 0, "Physical low-noise-control greed triggers alarm " + location)
		print("DIAGNOSTIC noise1 ", location, " full_clear=", completed, " remaining=", run.remaining)
